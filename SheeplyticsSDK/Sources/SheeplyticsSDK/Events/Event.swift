//
//  BaseEvent.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

import Foundation

public extension Sheeplytics {
    
    struct Event: Codable {
        
        /// The type of event.
        let kind: EventKind
        
        /// The app identifier.
        let appId: String
        
        /// The user identifier.
        let userId: String
        
        /// The JSON payload.
        let data: Data
        
        init(kind: EventKind, appId: String, userId: String, data: Data) {
            self.kind = kind
            self.appId = appId
            self.userId = userId
            self.data = data
        }
    }
}
