//
//  Sheeplytics+Internal.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

import Foundation

internal extension Sheeplytics {
    
    /// Wrap a specific event payload into a proper event.
    func wrap<TEvent>(_ event: TEvent) throws -> Event where TEvent: EventPayload {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(event) else {
            throw Sheeplytics.Error.invalidEventData
        }
        return Event(
            kind: TEvent.kind,
            appId: self.appIdentifier,
            userId: self.userIdentifier,
            data: jsonData
        )
    }
    
    func buildPostRequest(to url: URL, data: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(self.appIdentifier, forHTTPHeaderField: "X-AppId")
        request.setValue(self.userIdentifier, forHTTPHeaderField: "X-UserId")
        request.httpMethod = "POST"
        request.httpBody = data
        return request
    }
    
    func send(_ event: Event) async throws {
        let url = endpointUrl.appending(path: "/ingest")
        let req = buildPostRequest(to: url, data: try JsonUtil.toJsonData(event))
        let (_, response) = try await URLSession.shared.data(for: req)
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            let error = Sheeplytics.Error.requestError(statusCode: response.statusCode)
            logger.error("Failed to send event: \(error.localizedDescription)")
            throw error
        }
    }
}
