//
//  FlagEvent.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

public extension Sheeplytics {
    
    struct FlagEvent: EventPayload, Codable {
        static let kind: Sheeplytics.EventKind = .flag
        
        let value: Bool
        
        init(value: Bool) {
            self.value = value
        }
    }
}
