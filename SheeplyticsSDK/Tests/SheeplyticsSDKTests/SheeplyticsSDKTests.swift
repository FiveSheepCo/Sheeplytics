import Foundation
import Testing

@testable import SheeplyticsSDK

let mockConfig = Sheeplytics.Config(
    instance: "http://localhost:8787",
    appIdentifier: .custom("co.fivesheep.SheeplyticsSDKTests"),
    userIdentifier: .custom("testUser")
)

@Test func initializeSharedInstance() async throws {
    try await Sheeplytics.initialize(config: mockConfig)
    try await SheeplyticsActor.shared.ensureInitialized()
}

@Test func encodeAndDecodeFlagEvent() async throws {
    try await Sheeplytics.initialize(config: mockConfig)

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
    try await Sheeplytics.initialize(config: mockConfig)
    try await SheeplyticsActor.shared.setFlag(
        "didReceiveAdConsent",
        metadata: [
            "foo": true,
            "bar": 123,
            "baz": 3.14,
            "qux": "hello",
        ])
}

@Test func sendActionEvent() async throws {
    try await Sheeplytics.initialize(config: mockConfig)
    try await SheeplyticsActor.shared.logAction(
        "didExportChat",
        metadata: [
            "foo": true,
            "bar": 123,
            "baz": 3.14,
            "qux": "hello",
        ])
}

@Test func sendChoiceEvent() async throws {
    try await Sheeplytics.initialize(config: mockConfig)
    enum ChatFilter: String, CaseIterable {
        case all = "all"
        case unread = "unread"
    }
    try await SheeplyticsActor.shared.submitChoice("chatFilter", value: ChatFilter.unread.rawValue)
}

@Test func sendValueEvent() async throws {
    try await Sheeplytics.initialize(config: mockConfig)
    try await SheeplyticsActor.shared.setValue("fish", value: "eel")
    try await SheeplyticsActor.shared.setValue("tonsOfOil", value: 150000)
}
