//
//  Config.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 04.08.2024.
//

import Foundation

extension Sheeplytics {
    
    /// The Sheeplytics configuration.
    public struct Config: Sendable {
        let endpoint: String
        let appIdentifier: AppIdentifier
        let userIdentifier: UserIdentifier
        
        public init(
            endpoint: String,
            appIdentifier: AppIdentifier = .bundleId,
            userIdentifier: UserIdentifier = .autoDetect
        ) {
            self.endpoint = endpoint
            self.appIdentifier = appIdentifier
            self.userIdentifier = userIdentifier
        }
    }
}
