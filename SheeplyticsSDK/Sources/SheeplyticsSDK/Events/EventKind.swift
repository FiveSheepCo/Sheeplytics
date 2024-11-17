//
//  EventType.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 04.08.2024.
//

import Foundation

extension Sheeplytics {

    public enum EventKind: String, Codable, Sendable {

        /// A boolean flag that can be set or unset.
        case flag

        /// An action that has been completed by the user.
        case action

        /// A choice that has been made by the user.
        case choice

        /// A value set by the user.
        case value
    }
}
