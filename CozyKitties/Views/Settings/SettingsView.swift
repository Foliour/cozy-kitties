import SwiftUI
import SwiftData

/// Settings view with ASD slider, appearance picker, and HealthKit status
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared
    @State private var averageStepsPerDay: Double = 5000
    @State private var soundEnabled: Bool = true
    @State private var dayNightMode: DayNightMode = .auto
    @State private var debugInfo: String = ""
    @State private var debugDaysToAdd: Int = 5
    @State private var debugDayZero: Date = Date()
    @State private var showResetConfirmation: Bool = false
    @State private var isLoadingSettings: Bool = true

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Page title
                HStack {
                    Text("Settings")
                        .font(CozyTypography.largeTitle)
                        .foregroundStyle(CozyColors.textPrimary)
                    Spacer()
                }

                // Activity Section
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader(emoji: "🏃", title: "Activity")

                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Text("Daily Step Goal")
                                .font(CozyTypography.headline)
                                .foregroundStyle(CozyColors.textPrimary)
                            Spacer()
                            Text("\(Int(averageStepsPerDay).formatted())")
                                .font(CozyTypography.headline)
                                .foregroundStyle(CozyColors.textSecondary)
                        }

                        Slider(value: $averageStepsPerDay, in: 1000...30000, step: 500) {
                            Text("Average Steps per Day")
                        } onEditingChanged: { editing in
                            if !editing {
                                gameStateService.updateAverageStepsPerDay(Int(averageStepsPerDay))
                            }
                        }
                        .tint(CozyColors.accent)

                        HStack {
                            Text("1,000")
                                .font(CozyTypography.caption)
                                .foregroundStyle(CozyColors.textSecondary)
                            Spacer()
                            Text("30,000")
                                .font(CozyTypography.caption)
                                .foregroundStyle(CozyColors.textSecondary)
                        }

                        Text("This determines how many steps you need to unlock each cat.")
                            .font(CozyTypography.caption)
                            .foregroundStyle(CozyColors.textSecondary)
                    }
                    .cozyCard()
                }

                // Appearance Section
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader(emoji: "🎨", title: "Appearance")

                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Time of Day")
                            .font(CozyTypography.headline)
                            .foregroundStyle(CozyColors.textPrimary)

                        HStack(spacing: Spacing.sm) {
                            ForEach(DayNightMode.allCases, id: \.self) { mode in
                                let isSelected = dayNightMode == mode
                                Button {
                                    dayNightMode = mode
                                    gameStateService.updateDayNightMode(mode)
                                } label: {
                                    Text(mode.displayName)
                                        .font(CozyTypography.caption)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, Spacing.sm)
                                }
                                .if(isSelected) { view in
                                    view.accentBlock(elevated: false)
                                }
                                .if(!isSelected) { view in
                                    view
                                        .foregroundStyle(CozyColors.textSecondary)
                                        .background(CozyColors.recessedFill)
                                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text("Auto changes background based on your local time (day 6AM–8PM).")
                            .font(CozyTypography.caption)
                            .foregroundStyle(CozyColors.textSecondary)
                    }
                    .cozyCard()
                }

                // Health Data Section
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader(emoji: "❤️", title: "Health Data")

                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Button(action: { requestHealthKitAccess() }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                                Text("Connect HealthKit")
                                    .font(CozyTypography.headline)
                                    .foregroundStyle(CozyColors.textPrimary)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: Spacing.md) {
                            Image(systemName: "figure.walk")
                                .font(.caption)
                                .foregroundStyle(CozyColors.textSecondary)
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Steps")
                                    .font(CozyTypography.caption)
                                    .foregroundStyle(CozyColors.textPrimary)
                                Text("Unlocks new cats")
                                    .font(.system(size: 10))
                                    .foregroundStyle(CozyColors.textSecondary)
                            }
                        }

                        Text("Your daily steps unlock new cats. All health data is processed on-device and never leaves your phone.")
                            .font(CozyTypography.caption)
                            .foregroundStyle(CozyColors.textSecondary)
                    }
                    .cozyCard()
                }

                // About Section
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader(emoji: "ℹ️", title: "About")

                    VStack(spacing: Spacing.md) {
                        HStack {
                            Text("Version")
                                .font(CozyTypography.body)
                                .foregroundStyle(CozyColors.textPrimary)
                            Spacer()
                            Text("1.0.0")
                                .font(CozyTypography.body)
                                .foregroundStyle(CozyColors.textSecondary)
                        }

                        HStack {
                            Text("Cats Collected")
                                .font(CozyTypography.body)
                                .foregroundStyle(CozyColors.textPrimary)
                            Spacer()
                            let unlockedCount = gameStateService.getUnlockedCats().count
                            Text("\(unlockedCount)/\(catRoster.count)")
                                .font(CozyTypography.body)
                                .foregroundStyle(CozyColors.textSecondary)
                        }

                        Link(destination: URL(string: "https://kathrynstyons.com/cozykitties/privacy")!) {
                            HStack {
                                Text("Privacy Policy")
                                    .font(CozyTypography.body)
                                    .foregroundStyle(CozyColors.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundStyle(CozyColors.textSecondary)
                            }
                        }
                    }
                    .cozyCard()
                }

                // Data Section
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader(emoji: "💾", title: "Data")

                    VStack(spacing: Spacing.md) {
                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundStyle(CozyColors.destructive)
                                Text("Reset Game")
                                    .font(CozyTypography.headline)
                                    .foregroundStyle(CozyColors.destructive)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)

                        Text("This will reset all progress, unlock only the starter cat, and set today as your new Day Zero.")
                            .font(CozyTypography.caption)
                            .foregroundStyle(CozyColors.textSecondary)
                    }
                    .cozyCard()
                }

                // Debug Section (only in DEBUG builds)
                #if DEBUG
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader(emoji: "🔧", title: "Debug")

                    VStack(spacing: Spacing.md) {
                        DatePicker(
                            "Day Zero",
                            selection: $debugDayZero,
                            displayedComponents: .date
                        )
                        .onChange(of: debugDayZero) { _, newValue in
                            guard !isLoadingSettings else { return }
                            gameStateService.setDayZero(newValue)
                        }

                        Stepper(value: $debugDaysToAdd, in: 1...50) {
                            HStack {
                                Text("Days to add:")
                                Spacer()
                                Text("\(debugDaysToAdd)")
                                    .foregroundStyle(CozyColors.textSecondary)
                            }
                        }

                        Button(action: { addTestSteps() }) {
                            HStack {
                                Image(systemName: "figure.walk")
                                    .foregroundStyle(.green)
                                Text("Add 5,000 Steps (\(debugDaysToAdd) days)")
                            }
                        }

                        Button(action: { checkSteps() }) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundStyle(.blue)
                                Text("Check Steps & Unlock Cats")
                            }
                        }

                        Button(action: { resetOnboarding() }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundStyle(.orange)
                                Text("Reset Onboarding")
                            }
                        }

                        if !debugInfo.isEmpty {
                            Text(debugInfo)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(CozyColors.textSecondary)
                        }

                        let asd = Int(averageStepsPerDay)
                        Text("Cat thresholds (ASD=\(asd)): \(catRoster.map { "\($0.stepsRequired(asd: asd).formatted())" }.joined(separator: ", ")) steps")
                            .font(CozyTypography.caption)
                            .foregroundStyle(CozyColors.textSecondary)
                    }
                    .cozyCard()
                }
                #endif
            }
            .padding(Spacing.md)
        }
        .onAppear {
            loadSettings()
        }
        .alert("Reset Game?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                gameStateService.resetGame()
                loadSettings()
            }
        } message: {
            Text("This will reset all your progress. You'll keep only Luna (the starter cat) and today will become your new Day Zero. This cannot be undone.")
        }
    }

    // MARK: - Actions

    private func loadSettings() {
        isLoadingSettings = true
        gameStateService.configure(with: modelContext)
        if let state = gameStateService.gameState {
            averageStepsPerDay = Double(state.averageStepsPerDay)
            soundEnabled = state.soundEnabled
            dayNightMode = state.dayNightMode
            debugDayZero = state.dayZero
        }
        DispatchQueue.main.async {
            isLoadingSettings = false
        }
    }

    private func requestHealthKitAccess() {
        Task {
            try? await HealthKitService.shared.requestAuthorization()
        }
    }

    #if DEBUG
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

                for day in 1...daysToAdd {
                    try await HealthKitService.shared.writeTestSteps(5000, daysAgo: day)
                }

                await MainActor.run {
                    debugInfo = "Added 5,000 steps for \(daysToAdd) days!"
                }

                await checkStepsInternal()
            } catch {
                await MainActor.run {
                    debugInfo = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func checkSteps() {
        Task {
            await checkStepsInternal()
        }
    }

    private func checkStepsInternal() async {
        guard let state = gameStateService.gameState else {
            await MainActor.run {
                debugInfo = "Error: No game state"
            }
            return
        }

        let asd = state.averageStepsPerDay
        var info = "ASD: \(asd)\n"
        let unlockedNames = gameStateService.getUnlockedCats().map { $0.name }
        info += "Unlocked: \(unlockedNames.joined(separator: ", "))\n\n"

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for daysAgo in 0...6 {
            guard let checkDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            do {
                let steps = try await HealthKitService.shared.fetchSteps(for: checkDate)
                let dayLabel = daysAgo == 0 ? "Today" : daysAgo == 1 ? "Yesterday" : "\(daysAgo) days ago"
                info += "\(dayLabel): \(steps) steps\n"
            } catch {
                info += "Day -\(daysAgo): Error - \(error.localizedDescription)\n"
            }
        }

        let cumulative = await HealthKitService.shared.fetchCumulativeSteps(since: state.dayZero)
        info += "\nDay Zero: \(state.dayZero.formatted(date: .abbreviated, time: .omitted))"
        info += "\nCumulative Steps: \(cumulative.formatted())"

        let uncelebrated = gameStateService.checkAndUnlockCats(cumulativeSteps: cumulative)
        if !uncelebrated.isEmpty {
            info += "\nNewly unlocked: \(uncelebrated.map { $0.name }.joined(separator: ", "))"
        }

        await MainActor.run {
            debugInfo = info
        }
    }
    #endif
}

// MARK: - Conditional Modifier Helper (for Settings segmented picker)

private extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [GameState.self], inMemory: true)
}
