import Foundation
import OSLog

/// Helper method to run code asynchronously in the background while ignoring any errors.
internal func withAsyncNoThrow(_ body: @escaping @Sendable () async throws -> Void) {
    Task {
        try? await body()
    }
}

internal final actor SheeplyticsActor {
    public static let shared: SheeplyticsActor = .init()
    
    let logger: Logger
    
    private(set) var endpointUrl: URL!
    private(set) var appIdentifier: String!
    private(set) var userIdentifier: String!
    
    /// Global metadata to be injected into every event.
    private(set) var injectedMetadata: Sheeplytics.Metadata = [:]
    
    private init() {
        self.logger = Logger(subsystem: "co.fivesheep.sheeplytics", category: "Sheeplytics")
    }
    
    internal func ensureInitialized() throws {
        guard let _ = endpointUrl, let _ = appIdentifier, let _ = userIdentifier else {
            logger.error("Sheeplytics not initialized. Call `Sheeplytics.initialize` first.")
            throw Sheeplytics.Error.notInitialized
        }
    }
}

internal extension SheeplyticsActor {
    
    func initialize(config: Sheeplytics.Config) async throws {
        
        // Parse endpoint URL
        guard let url = URL(string: config.instance) else {
            throw Sheeplytics.Error.endpointNotAnURL
        }
        
        // Retrieve app identifier
        guard let appIdentifier = await config.appIdentifier.resolvedValue else {
            throw Sheeplytics.Error.missingAppIdentifier
        }
        
        // Retrieve user identifier
        guard let userIdentifier = await config.userIdentifier.resolvedValue else {
            throw Sheeplytics.Error.missingUserIdentifier
        }
        
        self.endpointUrl = url
        self.appIdentifier = appIdentifier
        self.userIdentifier = userIdentifier
    }
    
    func initialize(_ instance: String) async throws {
        try await self.initialize(config: Sheeplytics.Config(instance: instance))
    }
    
    func setFlag(_ name: String, active value: Bool = true, metadata: Sheeplytics.Metadata = [:]) async throws {
        try self.ensureInitialized()
        
        let event = try self.wrap(
            name,
            data: Sheeplytics.FlagEvent(value: value),
            metadata: self.resolveMetadata(metadata)
        )
        
        try await self.send(event)
    }
    
    func logAction(_ name: String, metadata: Sheeplytics.Metadata = [:]) async throws {
        try self.ensureInitialized()
        
        let event = try self.wrap(
            name,
            data: Sheeplytics.ActionEvent(),
            metadata: self.resolveMetadata(metadata)
        )
        
        try await self.send(event)
    }
    
    func submitChoice(_ name: String, value: String, metadata: Sheeplytics.Metadata = [:]) async throws {
        try self.ensureInitialized()
        
        let event = try self.wrap(
            name,
            data: Sheeplytics.ChoiceEvent(value: value),
            metadata: self.resolveMetadata(metadata)
        )
        
        try await self.send(event)
    }
    
    func setValue(_ name: String, value: some Sheeplytics.IntoJsonValue, metadata: Sheeplytics.Metadata = [:]) async throws {
        try self.ensureInitialized()
        
        let event = try self.wrap(
            name,
            data: Sheeplytics.ValueEvent(value: value.into()),
            metadata: self.resolveMetadata(metadata)
        )
        
        try await self.send(event)
    }
    
    func injectMetadata(_ metadata: Sheeplytics.Metadata) {
        self.injectedMetadata.merge(metadata) { _, newValue in
            return newValue // always override existing values
        }
    }
}
