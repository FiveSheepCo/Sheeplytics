import Foundation
import OSLog

@MainActor
public final class Sheeplytics {
    
    /// The shared instance.
    internal static let shared = Sheeplytics()
    
    let logger: Logger
    var endpointUrl: URL!
    var appIdentifier: String!
    var userIdentifier: String!
    
    /// Global metadata to be injected into every event.
    var injectedMetadata: Metadata = [:]
    
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
    
    static func initialize(config: Sheeplytics.Config) throws {
        try Self.shared.initialize(config: config)
    }
    
    static func initialize(_ instance: String) throws {
        try Self.initialize(config: Config(instance: instance))
    }
    
    /// Set or unset a flag.
    static func setFlag(_ name: String, active value: Bool = true, metadata: Metadata = [:]) async throws {
        try await Self.shared.setFlag(name, active: value, metadata: metadata)
    }
    
    /// Log an action that has just happened.
    static func logAction(_ name: String, metadata: Metadata = [:]) async throws {
        try await Self.shared.logAction(name, metadata: metadata)
    }
    
    /// Submit a choice that has been made.
    static func submitChoice(_ name: String, value: String, metadata: Metadata = [:]) async throws {
        try await Self.shared.submitChoice(name, value: value, metadata: metadata)
    }
    
    /// Submit a choice that has been made.
    static func submitChoice<E>(_ name: String, value: E, metadata: Metadata = [:]) async throws where E: RawRepresentable, E.RawValue == String {
        try await Self.shared.submitChoice(name, value: value.rawValue, metadata: metadata)
    }
    
    /// Inject metadata into every future event.
    ///
    /// - NOTE: Existing injected metadata is overridden on key collision.
    /// Event metadata takes precedence over injected metadata.
    static func injectMetadata(_ metadata: Metadata) {
        Self.shared.injectMetadata(metadata)
    }
}

internal extension Sheeplytics {
    
    func initialize(config: Sheeplytics.Config) throws {
        
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
    
    func initialize(_ instance: String) throws {
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
    
    func injectMetadata(_ metadata: Metadata) {
        self.injectedMetadata.merge(metadata) { _, newValue in
            return newValue // always override existing values
        }
    }
}
