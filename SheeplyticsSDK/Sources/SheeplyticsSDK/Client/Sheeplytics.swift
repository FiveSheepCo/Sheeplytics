import Foundation
import OSLog

/// Helper method to run code asynchronously in the background while ignoring any errors.
internal func withAsyncNoThrow(_ body: @escaping @Sendable () async throws -> Void) {
    Task.detached {
        try? await body()
    }
}

// We declare `Sheeplytics` as `@unchecked Sendable`.
// It wouldn't usually be `Sendable` because of its mutable properties.
//
// All writes to these properties are made safe by explicitly
// marking the `initialize` methods as `@MainActor`.
//
// The Swift compiler cannot verify this, but it should be perfectly sound.
public final class Sheeplytics: @unchecked Sendable {
    
    /// The shared instance.
    @MainActor internal static let shared = Sheeplytics()
    
    let logger: Logger

    // Unchecked mutable properties
    // *IMPORTANT*: Writes MUST happen through `MainActor`!
    private(set) var endpointUrl: URL!
    private(set) var appIdentifier: String!
    private(set) var userIdentifier: String!
    
    // *IMPORTANT*: Writes MUST happen through `MainActor`!
    /// Global metadata to be injected into every event.
    private(set) var injectedMetadata: Metadata = [:]
    
    private init() {
        self.logger = Logger(subsystem: "co.fivesheep.sheeplytics", category: "Sheeplytics")
    }
    
    internal func ensureInitialized() throws {
        guard let _ = endpointUrl, let _ = appIdentifier, let _ = userIdentifier else {
            logger.error("Sheeplytics not initialized. Call Sheeplytics.initialize(config:) first.")
            throw Error.notInitialized
        }
    }
}

public extension Sheeplytics {
    
    // This MUST be `MainActor`-isolated at all times, because it ensures
    // sound and synchronized access to the mutable properties of `Sheeplytics`.
    @MainActor static func initialize(config: Sheeplytics.Config) throws {
        try Self.shared.initialize(config: config)
    }
    
    // This MUST be `MainActor`-isolated at all times, because it ensures
    // sound and synchronized access to the mutable properties of `Sheeplytics`.
    @MainActor static func initialize(_ instance: String) throws {
        try Self.initialize(config: Config(instance: instance))
    }
    
    /// Set or unset a flag.
    static func setFlag(_ name: String, active value: Bool = true, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await Self.shared.setFlag(name, active: value, metadata: metadata)
        }
    }
    
    /// Log an action that has just happened.
    static func logAction(_ name: String, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await Self.shared.logAction(name, metadata: metadata)
        }
    }
    
    /// Submit a choice that has been made.
    static func submitChoice(_ name: String, value: String, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await Self.shared.submitChoice(name, value: value, metadata: metadata)
        }
    }
    
    /// Submit a choice that has been made.
    static func submitChoice<E>(_ name: String, value: E, metadata: Metadata = [:]) where E: RawRepresentable, E.RawValue == String {
        let rawValue = value.rawValue
        withAsyncNoThrow {
            try await Self.shared.submitChoice(name, value: rawValue, metadata: metadata)
        }
    }
    
    /// Inject metadata into every future event.
    ///
    /// - NOTE: Existing injected metadata is overridden on key collision.
    /// Event metadata takes precedence over injected metadata.
    static func injectMetadata(_ metadata: Metadata) {
        Task { @MainActor in
            Self.shared.injectMetadata(metadata)
        }
    }
}

internal extension Sheeplytics {
    
    // This MUST be `MainActor`-isolated at all times, because it ensures
    // sound and synchronized access to the mutable properties of `Sheeplytics`.
    @MainActor func initialize(config: Sheeplytics.Config) throws {
        
        // Parse endpoint URL
        guard let url = URL(string: config.instance) else {
            throw Sheeplytics.Error.endpointNotAnURL
        }
        
        // Retrieve app identifier
        guard let appIdentifier = config.appIdentifier.resolvedValue else {
            throw Sheeplytics.Error.missingAppIdentifier
        }
        
        // Retrieve user identifier
        guard let userIdentifier = config.userIdentifier.resolvedValue else {
            throw Sheeplytics.Error.missingUserIdentifier
        }
        
        self.endpointUrl = url
        self.appIdentifier = appIdentifier
        self.userIdentifier = userIdentifier
    }
    
    // This MUST be `MainActor`-isolated at all times, because it ensures
    // sound and synchronized access to the mutable properties of `Sheeplytics`.
    @MainActor func initialize(_ instance: String) throws {
        try self.initialize(config: Config(instance: instance))
    }
    
    func setFlag(_ name: String, active value: Bool = true, metadata: Metadata = [:]) async throws {
        try self.ensureInitialized()
        
        let event = try self.wrap(
            name,
            data: FlagEvent(value: value),
            metadata: self.resolveMetadata(metadata)
        )
        
        try await self.send(event)
    }
    
    func logAction(_ name: String, metadata: Metadata = [:]) async throws {
        try self.ensureInitialized()
        
        let event = try self.wrap(
            name,
            data: ActionEvent(),
            metadata: self.resolveMetadata(metadata)
        )
        
        try await self.send(event)
    }
    
    func submitChoice(_ name: String, value: String, metadata: Metadata = [:]) async throws {
        try self.ensureInitialized()
        
        let event = try self.wrap(
            name,
            data: ChoiceEvent(value: value),
            metadata: self.resolveMetadata(metadata)
        )
        
        try await self.send(event)
    }
    
    @MainActor func injectMetadata(_ metadata: Metadata) {
        self.injectedMetadata.merge(metadata) { _, newValue in
            return newValue // always override existing values
        }
    }
}
