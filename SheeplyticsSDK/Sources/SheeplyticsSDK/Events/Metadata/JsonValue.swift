//
//  EventMetadataValue.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

extension Sheeplytics {
    
    public indirect enum JsonValue: Codable {
        case string(String)
        case bool(Bool)
        case number(Double)
        case array([JsonValue])
        
        public func encode(to encoder: any Encoder) throws {
            var encoder = encoder.singleValueContainer()
            switch self {
                case .string(let value):
                    try encoder.encode(value)
                case .bool(let value):
                    try encoder.encode(value)
                case .number(let value):
                    try encoder.encode(value)
                case .array(let value):
                    try encoder.encode(value)
            }
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(Bool.self) {
                self = .bool(value)
            } else if let value = try? container.decode(String.self) {
                self = .string(value)
            } else if let value = try? container.decode(Double.self) {
                self = .number(value)
            } else if let value = try? container.decode([JsonValue].self) {
                self = .array(value)
            } else {
                throw DecodingError.typeMismatch(
                    JsonValue.self,
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid type for value."
                    )
                )
            }
        }
    }
}
