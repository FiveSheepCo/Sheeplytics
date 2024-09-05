//
//  Swift+MetadataValue.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

extension Sheeplytics.JsonValue: Sheeplytics.IntoJsonValue {
    public func into() -> Sheeplytics.JsonValue {
        self
    }
}

extension Swift.String: Sheeplytics.IntoJsonValue {
    public func into() -> Sheeplytics.JsonValue {
        .string(self)
    }
}

extension Swift.Double: Sheeplytics.IntoJsonValue {
    public func into() -> Sheeplytics.JsonValue {
        .number(self)
    }
}

extension Swift.Int: Sheeplytics.IntoJsonValue {
    public func into() -> Sheeplytics.JsonValue {
        .number(Double(self))
    }
}

extension Swift.Bool: Sheeplytics.IntoJsonValue {
    public func into() -> Sheeplytics.JsonValue {
        .bool(self)
    }
}

extension Swift.Array: Sheeplytics.IntoJsonValue where Element: Sheeplytics.IntoJsonValue {
    public func into() -> Sheeplytics.JsonValue {
        .array(self.map { $0.into() })
    }
}
