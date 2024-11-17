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
        let instance: String
        let queryKey: String?
        let appIdentifier: AppIdentifier
        let userIdentifier: UserIdentifier

        public init(
            instance: String,
            queryKey: String? = nil,
            appIdentifier: AppIdentifier = .bundleId,
            userIdentifier: UserIdentifier = .autoDetect
        ) {
            self.instance = instance
            self.queryKey = queryKey
            self.appIdentifier = appIdentifier
            self.userIdentifier = userIdentifier
        }
    }
}
