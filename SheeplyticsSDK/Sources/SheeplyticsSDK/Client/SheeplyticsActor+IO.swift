//
//  Sheeplytics+Internal.swift
//  SheeplyticsSDK
//
//  Created by Marco Quinten on 05.08.2024.
//

import Foundation

internal extension SheeplyticsActor {
    
    /// Wrap a specific event payload into a proper event.
    func wrap<TEvent>(_ name: String, data: TEvent, metadata: Sheeplytics.Metadata = [:]) throws -> Sheeplytics.Event where TEvent: Sheeplytics.EventPayload {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(data) else {
            throw Sheeplytics.Error.invalidEventData
        }
        return Sheeplytics.Event(
            name: name,
            kind: TEvent.kind,
            appId: self.appIdentifier,
            userId: self.userIdentifier,
            data: jsonData,
            metadata: metadata
        )
    }
    
    /// Inject global metadata into event metadata.
    func resolveMetadata(_ metadata: Sheeplytics.Metadata) -> Sheeplytics.Metadata {
        metadata.merging(self.injectedMetadata, uniquingKeysWith: { oldValue, _ in
            return oldValue // event value takes precedence over global value
        })
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
    
    func send(_ event: Sheeplytics.Event) async throws {
        
        // Check if a batch exists
        if let batch {
            
            // Add the event to the batch
            batch.add(event)
            return
        }
        
        // Build the request
        let url = endpointUrl.appending(path: "/ingest")
        let req = buildPostRequest(to: url, data: try JsonUtil.toJsonData(event))
        
        // Send the request and process the response
        let (_, response) = try await URLSession.shared.data(for: req)
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            let error = Sheeplytics.Error.requestError(statusCode: response.statusCode)
            logger.error("Failed to send event: \(error.localizedDescription)")
            throw error
        }
    }
    
    func send(_ batch: Sheeplytics.EventBatch) async throws {
        
        // Reset the batch after sending
        defer {
            self.batch = nil
        }
        
        // Build the request
        let url = endpointUrl.appending(path: "/ingest")
        let req = buildPostRequest(to: url, data: try JsonUtil.toJsonData(batch.events))
        
        // Send the request and process the response
        let (_, response) = try await URLSession.shared.data(for: req)
        if let response = response as? HTTPURLResponse {
            if response.statusCode != 200 {
                let error = Sheeplytics.Error.requestError(statusCode: response.statusCode)
                logger.error("Failed to send event batch: \(error.localizedDescription)")
                throw error
            } else {
                logger.info("Successfully sent event batch with \(batch.events.count) events.")
            }
        }
    }
}
