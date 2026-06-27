import SwiftUI
import SwiftData

/// Simple 3-step onboarding: Welcome, HealthKit permission, ASD calibration
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared
    @State private var currentPage = 0

    // ASD calibration state
    @State private var selectedOption: ASDOption = .default5000
    @State private var customASD: String = "5000"
    @State private var analyzedASD: Int?
    @State private var isAnalyzing: Bool = false
    @State private var analysisError: Bool = false

    enum ASDOption {
        case default5000
        case custom
        case analyzeHistory
    }

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CozyColors.backgroundStart, CozyColors.backgroundEnd],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? CozyColors.accent : CozyColors.recessedFill)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, Spacing.lg)

                TabView(selection: $currentPage) {
                    welcomePage
                        .tag(0)

                    healthKitPage
                        .tag(1)

                    asdCalibrationPage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            gameStateService.configure(with: modelContext)
        }
    }

    // MARK: - Welcome Page

    private var welcomePage: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "cat.fill")
                .font(.system(size: 80))
                .foregroundStyle(CozyColors.accent)

            Text("Welcome to CozyKitties")
                .font(CozyTypography.largeTitle)
                .foregroundStyle(CozyColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Build a cozy backyard filled with adorable cats by walking. The more you walk, the more cats you unlock!")
                .font(CozyTypography.body)
                .foregroundStyle(CozyColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Spacer()

            Button(action: { withAnimation { currentPage = 1 } }) {
                Text("Get Started")
                    .font(CozyTypography.headline)
                    .foregroundStyle(CozyColors.textOnColor)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(CozyColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
    }

    // MARK: - HealthKit Permission Page

    private var healthKitPage: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(.red)

            Text("Stay Active")
                .font(CozyTypography.largeTitle)
                .foregroundStyle(CozyColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("CozyKitties reads your daily steps to encourage regular walking. Cats are your reward for hitting your activity goals.")
                .font(CozyTypography.body)
                .foregroundStyle(CozyColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            VStack(alignment: .leading, spacing: Spacing.md) {
                healthFeatureRow(icon: "figure.walk", text: "Walk more to collect new cats")
                healthFeatureRow(icon: "lock.shield", text: "All data stays on your device")
            }
            .padding(Spacing.lg)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .padding(.horizontal, Spacing.xl)

            Spacer()

            Button(action: { requestHealthKitPermission() }) {
                Text("Allow Health Access")
                    .font(CozyTypography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .padding(.horizontal, Spacing.xl)

            Button(action: { withAnimation { currentPage = 2 } }) {
                Text("Skip for Now")
                    .font(CozyTypography.body)
                    .foregroundStyle(CozyColors.textSecondary)
            }
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func healthFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(CozyColors.textSecondary)
                .frame(width: 30)

            Text(text)
                .font(CozyTypography.body)
        }
    }

    private func requestHealthKitPermission() {
        Task {
            try? await HealthKitService.shared.requestAuthorization()
            await MainActor.run {
                withAnimation { currentPage = 2 }
            }
        }
    }

    // MARK: - ASD Calibration Page

    private var asdCalibrationPage: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "shoeprints.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Your Walking Pace")
                .font(CozyTypography.largeTitle)
                .foregroundStyle(CozyColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Set your average daily steps. This determines how many steps you need to unlock each cat.")
                .font(CozyTypography.body)
                .foregroundStyle(CozyColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            VStack(spacing: Spacing.md) {
                // Option 1: Default 5,000
                asdOptionButton(
                    title: "5,000 steps/day",
                    subtitle: "Recommended default",
                    icon: "star.fill",
                    isSelected: selectedOption == .default5000
                ) {
                    selectedOption = .default5000
                }

                // Option 2: Custom
                asdOptionButton(
                    title: "Custom amount",
                    subtitle: "Type your own target",
                    icon: "pencil",
                    isSelected: selectedOption == .custom
                ) {
                    selectedOption = .custom
                }

                if selectedOption == .custom {
                    HStack {
                        TextField("Steps per day", text: $customASD)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                        Text("steps/day")
                            .font(CozyTypography.caption)
                            .foregroundStyle(CozyColors.textSecondary)
                    }
                    .padding(.horizontal, Spacing.lg)
                }

                // Option 3: Analyze history
                asdOptionButton(
                    title: analyzedASDTitle,
                    subtitle: analyzedASDSubtitle,
                    icon: "waveform.path.ecg",
                    isSelected: selectedOption == .analyzeHistory
                ) {
                    selectedOption = .analyzeHistory
                    if analyzedASD == nil && !isAnalyzing {
                        analyzeStepHistory()
                    }
                }
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            Button(action: { completeOnboarding() }) {
                Text("Start My Journey")
                    .font(CozyTypography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private var analyzedASDTitle: String {
        if isAnalyzing { return "Analyzing..." }
        if let asd = analyzedASD { return "\(asd.formatted()) steps/day" }
        if analysisError { return "Not enough data" }
        return "Analyze my history"
    }

    private var analyzedASDSubtitle: String {
        if isAnalyzing { return "Checking your recent walking data" }
        if analyzedASD != nil { return "Based on your last 30 days" }
        if analysisError { return "Need at least 7 days of step data" }
        return "We'll suggest a goal from your data"
    }

    private func asdOptionButton(title: String, subtitle: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .green : .secondary)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CozyTypography.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(CozyTypography.caption)
                        .foregroundStyle(CozyColors.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding(Spacing.md)
            .background(isSelected ? Color.green.opacity(0.1) : Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func analyzeStepHistory() {
        isAnalyzing = true
        analysisError = false
        Task {
            let result = await HealthKitService.shared.analyzeHistoricalAverageSteps()
            await MainActor.run {
                isAnalyzing = false
                if let avg = result {
                    // Round to nearest 500 for a clean number
                    analyzedASD = max(1000, ((avg + 250) / 500) * 500)
                } else {
                    analysisError = true
                }
            }
        }
    }

    private func completeOnboarding() {
        let asd: Int
        switch selectedOption {
        case .default5000:
            asd = 5000
        case .custom:
            asd = max(1000, min(Int(customASD) ?? 5000, 30000))
        case .analyzeHistory:
            asd = analyzedASD ?? 5000
        }

        gameStateService.updateAverageStepsPerDay(asd)
        gameStateService.completeOnboarding()
        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .modelContainer(for: [GameState.self], inMemory: true)
}
