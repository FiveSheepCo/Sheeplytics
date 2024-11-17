import Foundation

extension Sheeplytics {

    struct StrippedEvent: Codable, Equatable, Sendable {
        let appId: String
        let userId: String
        let data: Data

        init(event: Event) {
            self.appId = event.appId
            self.userId = event.userId
            self.data = event.data
        }
    }
}
