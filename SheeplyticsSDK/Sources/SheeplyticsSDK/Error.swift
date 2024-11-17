//
//  SheeplyticsError.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 04.08.2024.
//

extension Sheeplytics {

    public enum Error: Swift.Error {

        /// The Sheeplytics instance has not been initialized.
        case notInitialized

        /// The provided endpoint is not a proper URL.
        case endpointNotAnURL

        /// The app identifier is missing or invalid.
        case missingAppIdentifier

        /// The user identifier is missing or invalid.
        case missingUserIdentifier

        /// The event data is invalid.
        case invalidEventData

        /// The request returned with a status code != 200.
        case requestError(statusCode: Int)
    }
}
