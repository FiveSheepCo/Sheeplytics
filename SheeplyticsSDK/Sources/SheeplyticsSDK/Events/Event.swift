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
        let timestamp: Date
        
        /// Inner JSON Payload
        let data: Data
        
        init(kind: EventKind, appId: String, userId: String, data: Data) {
            self.kind = kind
            self.appId = appId
            self.userId = userId
            self.data = data
            self.timestamp = Date.now
        }
    }
}
