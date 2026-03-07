import SwiftUI
import SwiftData

/// Main content view that handles onboarding and tab navigation
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared
    @State private var showOnboarding = false
    @State private var selectedTab = 0
    @State private var isInitialized = false

    var body: some View {
        Group {
            if !isInitialized {
                // Loading state
                ProgressView()
                    .onAppear {
                        initialize()
                    }
            } else if showOnboarding {
                OnboardingView {
                    withAnimation {
                        showOnboarding = false
                    }
                }
            } else {
                mainTabView
            }
        }
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            ApartmentView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            CatCollectionView()
                .tabItem {
                    Label("Cats", systemImage: "cat.fill")
                }
                .tag(1)

            ProgressDashboardView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.orange)
    }

    // MARK: - Initialization

    private func initialize() {
        gameStateService.configure(with: modelContext)

        // Check if onboarding has been completed
        if let state = gameStateService.gameState {
            showOnboarding = !state.hasCompletedOnboarding
        } else {
            showOnboarding = true
        }

        isInitialized = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
