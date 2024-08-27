//
//  Sheeplytics.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 22.08.2024.
//


public final class Sheeplytics: Sendable {
    private init() {}
}

public extension Sheeplytics {
    
    static func initialize(config: Sheeplytics.Config) async {
        try? await SheeplyticsActor.shared.initialize(config: config)
    }
    
    static func initialize(_ instance: String) async {
        await Self.initialize(config: Config(instance: instance))
    }
    
    /// Set or unset a flag.
    static func setFlag(_ name: String, active value: Bool = true, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.setFlag(name, active: value, metadata: metadata)
        }
    }
    
    /// Log an action that has just happened.
    static func logAction(_ name: String, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.logAction(name, metadata: metadata)
        }
    }
    
    /// Submit a choice that has been made.
    static func submitChoice(_ name: String, value: String, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.submitChoice(name, value: value, metadata: metadata)
        }
    }
    
    /// Submit a choice that has been made.
    static func submitChoice<E>(_ name: String, value: E, metadata: Metadata = [:]) where E: RawRepresentable, E.RawValue == String {
        let rawValue = value.rawValue
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.submitChoice(name, value: rawValue, metadata: metadata)
        }
    }
    
    /// Inject metadata into every future event.
    ///
    /// - NOTE: Existing injected metadata is overridden on key collision.
    /// Event metadata takes precedence over injected metadata.
    static func injectMetadata(_ metadata: Metadata) {
        Task { await SheeplyticsActor.shared.injectMetadata(metadata) }
    }
}
