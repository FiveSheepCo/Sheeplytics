//
//  Sheeplytics.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 22.08.2024.
//

public final class Sheeplytics: Sendable {
    private init() {}
}

extension Sheeplytics {

    public static func initialize(config: Sheeplytics.Config) async throws {
        try await SheeplyticsActor.shared.initialize(config: config)
    }

    public static func initialize(_ instance: String) async throws {
        try await Self.initialize(config: Config(instance: instance))
    }

    public static func initializeAsync(config: Sheeplytics.Config, completion: @Sendable @escaping () -> Void = {}) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.initialize(config: config)
            completion()
        }
    }

    public static func initializeAsync(_ instance: String, completion: @Sendable @escaping () -> Void = {}) {
        Self.initializeAsync(config: Config(instance: instance), completion: completion)
    }

    public static func logOut() async {
        await SheeplyticsActor.shared.logOut()
    }

    /// Set or unset a flag.
    public static func setFlag(_ name: String, active value: Bool = true, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.setFlag(name, active: value, metadata: metadata)
        }
    }

    /// Log an action that has just happened.
    public static func logAction(_ name: String, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.logAction(name, metadata: metadata)
        }
    }

    /// Submit a choice that has been made.
    public static func submitChoice(_ name: String, value: String, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.submitChoice(name, value: value, metadata: metadata)
        }
    }

    /// Submit a choice that has been made.
    public static func submitChoice<E>(_ name: String, value: E, metadata: Metadata = [:])
    where E: RawRepresentable, E.RawValue == String {
        let rawValue = value.rawValue
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.submitChoice(name, value: rawValue, metadata: metadata)
        }
    }

    /// Set a custom JSON value.
    public static func setValue(_ name: String, value: some IntoJsonValue, metadata: Metadata = [:]) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.setValue(name, value: value, metadata: metadata)
        }
    }

    /// Send a group of events in a batch.
    public static func withBatch(_ block: @escaping @Sendable () async -> Void) {
        withAsyncNoThrow {
            try await SheeplyticsActor.shared.withBatch(block)
        }
    }

    /// Inject metadata into every future event.
    ///
    /// - NOTE: Existing injected metadata is overridden on key collision.
    /// Event metadata takes precedence over injected metadata.
    public static func injectMetadata(_ metadata: Metadata) {
        Task { await SheeplyticsActor.shared.injectMetadata(metadata) }
    }
}
