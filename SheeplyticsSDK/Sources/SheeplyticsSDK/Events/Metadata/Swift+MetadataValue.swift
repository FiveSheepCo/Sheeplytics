//
//  Swift+MetadataValue.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

extension Swift.String: Sheeplytics.IntoMetadataValue {
    public func into() -> Sheeplytics.MetadataValue {
        .string(self)
    }
}

extension Swift.Double: Sheeplytics.IntoMetadataValue {
    public func into() -> Sheeplytics.MetadataValue {
        .number(self)
    }
}

extension Swift.Int: Sheeplytics.IntoMetadataValue {
    public func into() -> Sheeplytics.MetadataValue {
        .number(Double(self))
    }
}

extension Swift.Bool: Sheeplytics.IntoMetadataValue {
    public func into() -> Sheeplytics.MetadataValue {
        .bool(self)
    }
}
