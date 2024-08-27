//
//  Metadata.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

public extension Sheeplytics {
    typealias Metadata = [String: any Sheeplytics.IntoJsonValue]
}

extension Sheeplytics.Metadata: Sendable {}
