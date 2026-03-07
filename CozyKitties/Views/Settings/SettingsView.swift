import SwiftUI
import SwiftData

/// Settings view with step goal slider, sound toggle, and HealthKit status
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared
    @State private var stepGoal: Double = 5000
    @State private var soundEnabled: Bool = true
    @State private var healthKitAuthorized: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // Step Goal Section
                Section {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Text("Daily Step Goal")
                            Spacer()
                            Text("\(Int(stepGoal).formatted())")
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $stepGoal, in: 1000...20000, step: 500) {
                            Text("Step Goal")
                        } onEditingChanged: { editing in
                            if !editing {
                                gameStateService.updateStepGoal(Int(stepGoal))
                            }
                        }
                        .tint(.orange)

                        HStack {
                            Text("1,000")
                                .font(Typography.caption)
                                .foregroundStyle(.tertiary)
                            Spacer()
                            Text("20,000")
                                .font(Typography.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, Spacing.sm)
                } header: {
                    Label("Activity", systemImage: "figure.walk")
                }

                // Sound Section
                Section {
                    Toggle(isOn: $soundEnabled) {
                        HStack {
                            Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .foregroundStyle(.purple)
                            Text("Sound Effects")
                        }
                    }
                    .tint(.purple)
                    .onChange(of: soundEnabled) { _, newValue in
                        gameStateService.toggleSound(newValue)
                    }
                } header: {
                    Label("Audio", systemImage: "speaker.wave.2")
                }

                // HealthKit Section
                Section {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text("HealthKit Status")
                        Spacer()
                        Text(healthKitAuthorized ? "Connected" : "Not Connected")
                            .foregroundStyle(healthKitAuthorized ? .green : .secondary)
                    }

                    if !healthKitAuthorized {
                        Button(action: { requestHealthKitAccess() }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundStyle(.red)
                                Text("Connect HealthKit")
                            }
                        }
                    }

                    // Data types
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        dataTypeRow(icon: "figure.walk", name: "Steps", description: "Unlocks new cats")
                        dataTypeRow(icon: "moon.zzz.fill", name: "Sleep", description: "Grows plants")
                        dataTypeRow(icon: "speaker.wave.2.fill", name: "Audio Exposure", description: "Sets weather")
                    }
                    .padding(.vertical, Spacing.sm)
                } header: {
                    Label("Health Data", systemImage: "heart.text.square")
                } footer: {
                    Text("All health data is processed on-device and never leaves your phone.")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Cats Collected")
                        Spacer()
                        let unlockedCount = gameStateService.getUnlockedCats().count
                        Text("\(unlockedCount)/\(catRoster.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Plants Grown")
                        Spacer()
                        let unlockedPlants = gameStateService.getPlants().filter { $0.unlockedAt != nil }.count
                        Text("\(unlockedPlants)/\(PlantType.allCases.count)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                }

                // Debug Section (only in DEBUG builds)
                #if DEBUG
                Section {
                    Button(action: { resetOnboarding() }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundStyle(.red)
                            Text("Reset Onboarding")
                                .foregroundStyle(.red)
                        }
                    }
                } header: {
                    Label("Debug", systemImage: "hammer")
                }
                #endif
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            loadSettings()
        }
    }

    // MARK: - Helper Views

    private func dataTypeRow(icon: String, name: String, description: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(Typography.caption)
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Actions

    private func loadSettings() {
        gameStateService.configure(with: modelContext)
        if let state = gameStateService.gameState {
            stepGoal = Double(state.dailyStepGoal)
            soundEnabled = state.soundEnabled
        }
        // Check HealthKit status
        // healthKitAuthorized = HealthKitService.shared.isAuthorized
    }

    private func requestHealthKitAccess() {
        Task {
            // try await HealthKitService.shared.requestAuthorization()
            // await MainActor.run {
            //     healthKitAuthorized = HealthKitService.shared.isAuthorized
            // }
        }
    }

    private func resetOnboarding() {
        if let state = gameStateService.gameState {
            state.hasCompletedOnboarding = false
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
