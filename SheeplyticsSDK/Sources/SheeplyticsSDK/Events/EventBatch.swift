//
//  EventBatch.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 16.11.2024.
//

import Foundation

extension Sheeplytics {
    
    class EventBatch {
        
        /// The list of batched events.
        private(set) var events: [Event]
        
        init() {
            self.events = []
        }
        
        func add(_ event: Event) {
            events.append(event)
        }
    }
}
