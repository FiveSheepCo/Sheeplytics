//
//  BaseEvent.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

import Foundation

public extension Sheeplytics {
    
    struct Event: Codable {
        
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
        let metadata: [String: MetadataValue]
        
        init(
            kind: EventKind,
            appId: String,
            userId: String,
            data: Data,
            metadata: [String: any IntoMetadataValue] = [:]
        ) {
            self.kind = kind
            self.appId = appId
            self.userId = userId
            self.data = data
            self.timestamp = Date.now.ISO8601Format(.iso8601)
            self.metadata = metadata.mapValues { $0.into() }
        }
    }
}
