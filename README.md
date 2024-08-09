# Sheeplytics
> A small but powerful analytics framework for iOS apps.

## Projects

- **Sheeplytics SDK**: The Swift SDK.
- **Sheeplytics Worker**: The Cloudflare worker.

## Usage

```swift
import Sheeplytics

@main
struct MyApp: App {
    init() {
        try? Sheeplytics.initialize("https://worker.url")
    }
    
    var body: some View {
        WindowGroup {
            ContentView()
                .task {
                    try? await Sheeplytics.setFlag("appLaunched")
                }
        }
    }
}
```

## Worker

**Migrate local database**
`npm run db:migrate-dev`

**Migrate remote database**
`npm run db:migrate-prod`

**Run worker locally**
`npm run dev`

**Deploy worker**
`npm run deploy`
