//
//  EventPayload.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

extension Sheeplytics {

    protocol EventPayload: Encodable {
        static var kind: EventKind { get }
    }
}
