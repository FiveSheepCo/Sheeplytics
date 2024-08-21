import Testing
import Foundation
@testable import SheeplyticsSDK

let mockConfig = Sheeplytics.Config(
    instance: "http://localhost:8787",
    appIdentifier: .custom("co.fivesheep.SheeplyticsSDKTests"),
    userIdentifier: .custom("testUser")
)

@Test @MainActor func initializeSharedInstance() async throws {
    try Sheeplytics.initialize(config: mockConfig)
    try Sheeplytics.shared.ensureInitialized()
}

@Test @MainActor func encodeAndDecodeFlagEvent() async throws {
    try Sheeplytics.initialize(config: mockConfig)
    
    let specificEvent = Sheeplytics.FlagEvent(value: true)
    let wrappedEvent = try Sheeplytics.shared.wrap("foo", data: specificEvent)
    
    let reconstructedSpecificEvent: Sheeplytics.FlagEvent = try JsonUtil.fromJsonData(wrappedEvent.data)
    #expect(reconstructedSpecificEvent.value == true)
    
    let json: String = try JsonUtil.toJsonString(wrappedEvent)
    let reconstructedWrappedEvent: Sheeplytics.Event = try JsonUtil.fromJsonString(json)
    #expect(reconstructedWrappedEvent.kind == .flag)
    #expect(reconstructedWrappedEvent.appId == "co.fivesheep.SheeplyticsSDKTests")
    #expect(reconstructedWrappedEvent.userId == "testUser")
}

@Test @MainActor func sendFlagEvent() async throws {
    try Sheeplytics.initialize(config: mockConfig)
    try await Sheeplytics.setFlag("didReceiveAdConsent", metadata: [
        "foo": true,
        "bar": 123,
        "baz": 3.14,
        "qux": "hello"
    ])
}

@Test @MainActor func sendActionEvent() async throws {
    try Sheeplytics.initialize(config: mockConfig)
    try await Sheeplytics.logAction("didExportChat", metadata: [
        "foo": true,
        "bar": 123,
        "baz": 3.14,
        "qux": "hello"
    ])
}

@Test @MainActor func sendChoiceEvent() async throws {
    try Sheeplytics.initialize(config: mockConfig)
    enum ChatFilter: String, CaseIterable {
        case all = "all"
        case unread = "unread"
    }
    try await Sheeplytics.submitChoice("chatFilter", value: ChatFilter.unread)
}
