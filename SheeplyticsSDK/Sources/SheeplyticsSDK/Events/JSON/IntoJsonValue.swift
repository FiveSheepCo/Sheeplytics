//
//  IntoEventMetadataValue.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

public extension Sheeplytics {
    
    /// Protocol for types that can be converted into a metadata value.
    protocol IntoJsonValue: Sendable {
        
        /// Convert `self` into a metadata value.
        func into() -> JsonValue
    }
}
