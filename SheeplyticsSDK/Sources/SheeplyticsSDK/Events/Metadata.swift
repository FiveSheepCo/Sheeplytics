//
//  Metadata.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

extension Sheeplytics {
    public typealias Metadata = [String: any Sheeplytics.IntoJsonValue]
}

extension Sheeplytics.Metadata: Sendable {}
