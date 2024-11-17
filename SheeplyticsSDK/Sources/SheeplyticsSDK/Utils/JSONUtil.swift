//
//  JSONUtil.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 04.08.2024.
//

import Foundation

enum JsonUtil {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    static func fromJsonData<T>(_ jsonData: Data) throws -> T where T: Decodable {
        guard let data = try? decoder.decode(T.self, from: jsonData) else {
            throw Sheeplytics.Error.invalidEventData
        }
        return data
    }

    static func fromJsonString<T>(_ jsonString: String) throws -> T where T: Decodable {
        let jsonDecoder = JSONDecoder()
        guard let jsonData = jsonString.data(using: .utf8),
            let data = try? jsonDecoder.decode(T.self, from: jsonData)
        else { throw Sheeplytics.Error.invalidEventData }
        return data
    }

    static func toJsonData<T>(_ data: T) throws -> Data where T: Encodable {
        guard let jsonData = try? Self.encoder.encode(data) else {
            throw Sheeplytics.Error.invalidEventData
        }
        return jsonData
    }

    static func toJsonString<T>(_ data: T) throws -> String where T: Encodable {
        guard let jsonData = try? self.toJsonData(data),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else { throw Sheeplytics.Error.invalidEventData }
        return jsonString
    }
}
