//
//  AppIdentifier.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

import Foundation

public extension Sheeplytics.Config {
    
    /// Identiication method for the client app.
    enum AppIdentifier: Sendable {
        
        /// Use the bundle identifier for identification.
        case bundleId
        
        /// Use a custom value for identification.
        case custom(String)
        
        internal var resolvedValue: String? {
            switch self {
                case .bundleId:
                    Bundle.main.bundleIdentifier
                case .custom(let identifier):
                    identifier
            }
        }
    }
}
