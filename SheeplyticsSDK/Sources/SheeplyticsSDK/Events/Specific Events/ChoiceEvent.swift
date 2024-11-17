//
//  ChoiceEvent.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 20.08.2024.
//

extension Sheeplytics {

    public struct ChoiceEvent: EventPayload, Codable {
        static let kind: Sheeplytics.EventKind = .choice

        let value: String

        init(value: String) {
            self.value = value
        }
    }
}
