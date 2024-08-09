//
//  ActionEvent.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

public extension Sheeplytics {
    
    struct ActionEvent: EventPayload, Codable {
        static let kind: Sheeplytics.EventKind = .action
        
        init() {
        }
    }
}
