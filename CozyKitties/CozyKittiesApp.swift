import SwiftUI
import SwiftData

@main
struct CozyKittiesApp: App {
    /// SwiftData model container for GameState and Plant models
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameState.self,
            Plant.self
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
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
