import Testing
import Foundation
@testable import SheeplyticsSDK

let mockConfig = Sheeplytics.Config(
    instance: "http://localhost:8787",
    appIdentifier: .custom("co.fivesheep.SheeplyticsSDKTests"),
    userIdentifier: .custom("testUser")
)

@Test func initializeSharedInstance() async throws {
    await Sheeplytics.initialize(config: mockConfig)
    try await SheeplyticsActor.shared.ensureInitialized()
}

@Test func encodeAndDecodeFlagEvent() async throws {
    await Sheeplytics.initialize(config: mockConfig)
    
    let specificEvent = Sheeplytics.FlagEvent(value: true)
    let wrappedEvent = try await SheeplyticsActor.shared.wrap("foo", data: specificEvent)
    
    let reconstructedSpecificEvent: Sheeplytics.FlagEvent = try JsonUtil.fromJsonData(wrappedEvent.data)
    #expect(reconstructedSpecificEvent.value == true)
    
    let json: String = try JsonUtil.toJsonString(wrappedEvent)
    let reconstructedWrappedEvent: Sheeplytics.Event = try JsonUtil.fromJsonString(json)
    #expect(reconstructedWrappedEvent.kind == .flag)
    #expect(reconstructedWrappedEvent.appId == "co.fivesheep.SheeplyticsSDKTests")
    #expect(reconstructedWrappedEvent.userId == "testUser")
}

@Test func sendFlagEvent() async throws {
    await Sheeplytics.initialize(config: mockConfig)
    Sheeplytics.setFlag("didReceiveAdConsent", metadata: [
        "foo": true,
        "bar": 123,
        "baz": 3.14,
        "qux": "hello"
    ])
}

@Test func sendActionEvent() async throws {
    await Sheeplytics.initialize(config: mockConfig)
    Sheeplytics.logAction("didExportChat", metadata: [
        "foo": true,
        "bar": 123,
        "baz": 3.14,
        "qux": "hello"
    ])
}

@Test func sendChoiceEvent() async throws {
    await Sheeplytics.initialize(config: mockConfig)
    enum ChatFilter: String, CaseIterable {
        case all = "all"
        case unread = "unread"
    }
    Sheeplytics.submitChoice("chatFilter", value: ChatFilter.unread)
}

@Test func sendValueEvent() async throws {
    await Sheeplytics.initialize(config: mockConfig)
    Sheeplytics.submitChoice("fish", value: "eel")
}

