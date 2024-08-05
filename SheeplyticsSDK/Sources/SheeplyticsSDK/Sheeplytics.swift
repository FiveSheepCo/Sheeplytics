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
    
    func initialize(config: Sheeplytics.Config) async throws {
        
        // Parse endpoint URL
        guard let url = URL(string: config.endpoint) else {
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
    
    func setFlag(_ name: String, active value: Bool = true) async throws {
        try self.ensureInitialized()
        
        let event = try self.wrap(FlagEvent(name: name, value: value))
        try await self.send(event)
    }
}

public extension Sheeplytics {
    
    static func initialize(config: Sheeplytics.Config) async throws {
        try await Self.shared.initialize(config: config)
    }
    
    static func setFlag(_ name: String, active value: Bool = true) async throws {
        try await Self.shared.setFlag(name, active: value)
    }
}
