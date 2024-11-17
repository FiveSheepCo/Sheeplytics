//
//  FlagEvent.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

extension Sheeplytics {

    public struct FlagEvent: EventPayload, Codable {
        static let kind: Sheeplytics.EventKind = .flag

        let value: Bool

        init(value: Bool) {
            self.value = value
        }
    }
}
