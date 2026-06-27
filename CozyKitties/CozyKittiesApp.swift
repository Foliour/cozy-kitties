import SwiftUI
import SwiftData

@main
struct CozyKittiesApp: App {
    /// SwiftData model container for GameState
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameState.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // If the store is corrupted, delete it and retry
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            do {
                return try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                // Last resort: use in-memory container so the app doesn't crash
                let inMemoryConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                if let fallback = try? ModelContainer(for: schema, configurations: [inMemoryConfig]) {
                    return fallback
                }
                fatalError("Could not create ModelContainer after all recovery attempts: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
