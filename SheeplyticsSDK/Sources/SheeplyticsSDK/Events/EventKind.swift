//
//  EventType.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 04.08.2024.
//

import Foundation

public extension Sheeplytics {
    
    enum EventKind: String, Codable, Sendable {
        
        /// A boolean flag that can be set or unset.
        case flag
        
        /// An action that has been completed by the user.
        case action
    }
}
