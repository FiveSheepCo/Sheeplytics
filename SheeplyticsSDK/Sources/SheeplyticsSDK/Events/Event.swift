//
//  BaseEvent.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

import Foundation

extension Sheeplytics {

    public struct Event: Codable, Sendable {

        /// Event Name
        let name: String

        /// Event Type
        let kind: EventKind

        /// App Identifier
        let appId: String

        /// User Identifier
        let userId: String

        /// Event Timestamp
        let timestamp: String

        /// Inner JSON Payload
        let data: Data

        /// Additional Metadata
        let metadata: [String: JsonValue]

        init(
            name: String,
            kind: EventKind,
            appId: String,
            userId: String,
            data: Data,
            metadata: [String: any IntoJsonValue] = [:]
        ) {
            self.name = name
            self.kind = kind
            self.appId = appId
            self.userId = userId
            self.data = data
            self.timestamp = Date.now.ISO8601Format(.iso8601)
            self.metadata = metadata.mapValues { $0.into() }
        }

        var cacheKey: String {
            let cacheFriendlyName =
                name
                .replacingOccurrences(of: " ", with: "_")
                .lowercased()
            return "sheeplytics/\(kind.rawValue)/\(cacheFriendlyName)"
        }

        var stripped: StrippedEvent {
            StrippedEvent(event: self)
        }
    }
}
