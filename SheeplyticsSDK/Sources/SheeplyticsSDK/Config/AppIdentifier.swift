//
//  AppIdentifier.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

import Foundation

extension Sheeplytics.Config {

    /// Identiication method for the client app.
    public enum AppIdentifier: Sendable {

        /// Use the bundle identifier for identification.
        case bundleId

        /// Use a custom value for identification.
        case custom(String)

        @MainActor internal var resolvedValue: String? {
            switch self {
            case .bundleId:
                Bundle.main.bundleIdentifier
            case .custom(let identifier):
                identifier
            }
        }
    }
}
