import Foundation

extension Sheeplytics {

    @MainActor
    final class EventCache {
        private init() {}

        /// UserDefaults instance used to store the cached events.
        private static let defaults = UserDefaults.standard

        /// A cached event.
        struct CachedEvent: Codable {

            /// The stripped event.
            let event: StrippedEvent

            /// The cache revocation date.
            let expiresAt: Date
        }

        /// Check whether an event should be sent to the server.
        static func shouldSend(event: Event) -> Bool {

            // Get the cache key
            let key = event.cacheKey

            // Strip the event of all volatile data
            let event = event.stripped

            // Check if the event is already in the cache
            if let data = defaults.data(forKey: key) {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode(CachedEvent.self, from: data) {

                    // Check whether the cached event has expired
                    if Date.now > decoded.expiresAt {

                        // Send the event if the cached event has expired
                        return true
                    }

                    // Send the event if the cached event differs
                    return event != decoded.event
                }
            }

            // Send the event if it is not in the cache
            return true
        }

        /// Store the specified event in the cache.
        static func store(event: Event) {
            self.store(event.stripped, forKey: event.cacheKey)
        }

        private static func getExpirationDate() -> Date {
            let now = Date.now
            let idealDate = Calendar.current.date(byAdding: .day, value: 3, to: now)
            return idealDate ?? now.addingTimeInterval(86400 * 3)
        }

        private static func store(_ strippedEvent: StrippedEvent, forKey key: String) {
            let expiresAtDate = getExpirationDate()
            let cachedEvent = CachedEvent(event: strippedEvent, expiresAt: expiresAtDate)
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(cachedEvent) {
                defaults.set(data, forKey: key)
            }
        }
    }
}
