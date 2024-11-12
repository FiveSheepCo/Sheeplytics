# Sheeplytics
> A small but powerful analytics framework for iOS/macOS apps.

## Overview

We believe that analytics should be simple, lightweight, and nonobstructive. Sheeplytics gets out of your way, and lets you focus on building your app. It's designed to be safe, easy to setup and integrate, and error-resilient.

Sheeplytics is a fast and easy solution for those who simply want to track events in their app, without the need for complex analytics tools. It's perfect for indie developers, small teams, and hobbyists. It also preserves privacy by reducing the amount of third-parties that have access to user data, by using a self-hosted backend.

**Goals**

- **Simplicity**: The SDK is simple to setup, use and understand.
- **Efficiency**: The SDK is lightweight, asynchronous, and non-blocking.
- **Resiliency**: The SDK will never throw an error or crash your app.

**Non-Goals**

- **Guaranteed Delivery**: The SDK does not guarantee that events are delivered to the backend.
- **Network Resilience**: The SDK does not queue events during network or backend outages.

## Project Structure

- **Sheeplytics SDK**: The Swift SDK.
- **Sheeplytics Worker**: The Cloudflare worker.

### Event Types

| Event Type | Payload Type | Behavior  | Description         | Example                                |
|------------|--------------|-----------|---------------------|----------------------------------------|
| Flag       | Boolean      | Override  | Track occurrences.  | `onboardingComplete: true`             |
| Action     | String       | Increment | Count interactions. | `clickedRewardClaimButton: 25`         |
| Choice     | String       | Override  | Track choices.      | `appTheme: dark`                       |
| Value      | JSON         | Override  | Track actions.      | `userInterfaceLanguages: ["en", "de"]` |

### Architecture

The Sheeplytics backend consists of a frontend-agnostic Cloudflare worker that receives events from platform-specific SDKs. The worker stores events in a Cloudflare D1 database, and provides a REST-based query interface to retrieve analytics data.

## Swift SDK
> Our SDK can be integrated in seconds, and provides a simple API.
> 
> It's designed to utilize Swift's actor-based concurrency model to ensure thread safety without blocking the main thread.
> 
> The public-facing SDK interface is synchronous, actor-less and `Sendable`, dispatching the actual work on the internal `SheeplyticsActor`.

### Usage

```swift
import Sheeplytics

@main
struct MyApp: App {
    init() {

        // Initialize the SDK with the backend URL
        Sheeplytics.initializeAsync("https://worker.url")
    }
    
    var body: some View {
        WindowGroup {
            ContentView()
                .onAppear {

                    // Submit a flag event
                    try? await Sheeplytics.setFlag("appLaunched")
                }
        }
    }
}
```

## Backend Worker

### Authorization
> All authoriation is done as a standard `Bearer` token in the `Authorization` header.

- Query endpoints require the `QUERY_KEY` token.
- Admin endpoints require the `ADMIN_KEY` token.

These tokens are safely stored in the Cloudflare worker's environment variables.

### Query Interface

All query endpoints support the following optional parameters:
- `filter[appId]: string`: Filter by app ID.
- `filter[userId]: string`: Filter by user ID.
- `filter[eventName]: string`: Filter by event name.

- `GET /query/events`: Query the base event stream.
  - Optional Parameters:
    - `filter[eventKind]: string`: Filter by event kind.
    - `filter[eventName]: string`: Filter by event name.
    - `filter[startDate]: string`: Filter by start date.
    - `filter[endDate]: string`: Filter by end date.
    - `order: "asc" | "desc"`: Order the results.
- `GET /query/actions`: Query action events.
  - Optional Parameters:
    - `aggregate: "count" | "sum" | "avg"`: Aggregate the results.
    - `order: "asc" | "desc"`: Order the results.
- `GET /query/flags`: Query flag events.
  - Optional Parameters:
    - `aggregate: "count"`: Aggregate the results.
    - `order: "asc" | "desc"`: Order the results.
- `GET /query/choices`: Query choice events.
  - Optional Parameters:
    - `aggregate: "count"`: Aggregate the results.
    - `order: "asc" | "desc"`: Order the results.
- `GET /query/values`: Query value events.
  - Optional Parameters:
    - `order: "asc" | "desc"`: Order the results.

## Development

### Worker Development and Deployment

**Migrate local database**
`npm run db:migrate-dev`

**Migrate remote database**
`npm run db:migrate-prod`

**Run worker locally**
`npm run dev`

**Deploy worker**
`npm run deploy`
