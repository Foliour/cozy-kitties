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
        ZStack {
            // App background gradient
            LinearGradient(
                colors: [CozyColors.backgroundStart, CozyColors.backgroundEnd],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GlassEffectContainer {
                // Tab content
                Group {
                    switch selectedTab {
                    case 0:
                        ApartmentView()
                    case 1:
                        NavigationStack {
                            CollectionView()
                                .toolbar(.hidden, for: .navigationBar)
                        }
                    case 2:
                        NavigationStack {
                            SettingsView()
                                .toolbar(.hidden, for: .navigationBar)
                        }
                    default:
                        ApartmentView()
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: selectedTab)
                .safeAreaInset(edge: .bottom) {
                    PillNavBar(selectedTab: $selectedTab)
                        .padding(.bottom, Spacing.sm)
                }
            }
        }
    }

    // MARK: - Initialization

    private func initialize() {
        gameStateService.configure(with: modelContext)

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
        .modelContainer(for: [GameState.self], inMemory: true)
}
