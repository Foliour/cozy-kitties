import SwiftUI
import SwiftData

/// Settings view with step goal slider, sound toggle, and HealthKit status
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared
    @State private var stepGoal: Double = 5000
    @State private var soundEnabled: Bool = true
    @State private var healthKitAuthorized: Bool = false
    @State private var debugInfo: String = ""
    @State private var debugDaysToAdd: Int = 5
    @State private var debugDayZero: Date = Date()
    @State private var showResetConfirmation: Bool = false

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

                // Reset Game Section
                Section {
                    Button(action: { showResetConfirmation = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundStyle(.red)
                            Text("Reset Game")
                                .foregroundStyle(.red)
                        }
                    }
                } header: {
                    Label("Data", systemImage: "externaldrive")
                } footer: {
                    Text("This will reset all progress, unlock only the starter cat, and set today as your new Day Zero.")
                }

                // Debug Section (only in DEBUG builds)
                #if DEBUG
                Section {
                    // Day Zero display and picker
                    DatePicker(
                        "Day Zero",
                        selection: $debugDayZero,
                        displayedComponents: .date
                    )
                    .onChange(of: debugDayZero) { _, newValue in
                        gameStateService.setDayZero(newValue)
                    }

                    // Days stepper
                    Stepper(value: $debugDaysToAdd, in: 1...50) {
                        HStack {
                            Text("Days to add:")
                            Spacer()
                            Text("\(debugDaysToAdd)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button(action: { addTestSteps() }) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundStyle(.green)
                            Text("Add 5,000 Steps (\(debugDaysToAdd) days)")
                        }
                    }

                    Button(action: { checkStreak() }) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundStyle(.blue)
                            Text("Check Streak & Unlock Cats")
                        }
                    }

                    Button(action: { resetOnboarding() }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundStyle(.orange)
                            Text("Reset Onboarding")
                        }
                    }

                    // Debug info display
                    if !debugInfo.isEmpty {
                        Text(debugInfo)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Debug", systemImage: "hammer")
                } footer: {
                    Text("Cat unlock thresholds: 0, 1, 3, 7, 14, 21, 30, 45, 60, 90 days")
                }
                #endif
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            loadSettings()
        }
        .alert("Reset Game?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                gameStateService.resetGame()
                loadSettings() // Refresh UI
            }
        } message: {
            Text("This will reset all your progress. You'll keep only Trouble (the starter cat) and today will become your new Day Zero. This cannot be undone.")
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
            debugDayZero = state.dayZero
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

    private func addTestSteps() {
        let daysToAdd = debugDaysToAdd
        Task {
            do {
                await MainActor.run {
                    debugInfo = "Requesting authorization..."
                }
                try await HealthKitService.shared.requestAuthorization()

                await MainActor.run {
                    debugInfo = "Writing \(daysToAdd) days of steps..."
                }

                // Write steps for the specified number of days
                for day in 1...daysToAdd {
                    try await HealthKitService.shared.writeTestSteps(5000, daysAgo: day)
                }

                await MainActor.run {
                    debugInfo = "Added 5,000 steps for \(daysToAdd) days!"
                }

                // Auto-check streak after adding
                await checkStreakInternal()
            } catch {
                await MainActor.run {
                    debugInfo = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func checkStreak() {
        Task {
            await checkStreakInternal()
        }
    }

    private func checkStreakInternal() async {
        guard let state = gameStateService.gameState else {
            await MainActor.run {
                debugInfo = "Error: No game state"
            }
            return
        }

        let goal = state.dailyStepGoal
        var info = "Step Goal: \(goal)\n"
        info += "Unlocked: \(state.unlockedCatIDs.joined(separator: ", "))\n\n"

        // Check recent days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for daysAgo in 0...6 {
            guard let checkDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            do {
                let steps = try await HealthKitService.shared.fetchSteps(for: checkDate)
                let dayLabel = daysAgo == 0 ? "Today" : daysAgo == 1 ? "Yesterday" : "\(daysAgo) days ago"
                let met = steps >= goal ? "✓" : "✗"
                info += "\(dayLabel): \(steps) steps \(met)\n"
            } catch {
                info += "Day -\(daysAgo): Error\n"
            }
        }

        // Calculate streak (respecting dayZero)
        let streak = await HealthKitService.shared.calculateCurrentStreak(goal: goal, dayZero: state.dayZero)
        info += "\nDay Zero: \(state.dayZero.formatted(date: .abbreviated, time: .omitted))"
        info += "\nStreak: \(streak) days"

        // Check for unlocks
        let newCats = gameStateService.checkAndUnlockCats(currentStreak: streak)
        if !newCats.isEmpty {
            info += "\n🎉 Unlocked: \(newCats.map { $0.name }.joined(separator: ", "))"
        }

        await MainActor.run {
            debugInfo = info
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
