//
//  ValueEvent.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.09.2024.
//

extension Sheeplytics {

    public struct ValueEvent: EventPayload, Codable {
        static let kind: Sheeplytics.EventKind = .value

        let value: JsonValue

        init(value: JsonValue) {
            self.value = value
        }
    }
}
