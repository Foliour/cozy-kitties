import SwiftUI
import SwiftData

/// Simple 3-step onboarding: Welcome, HealthKit permission, Goal setting
/// Uses PageTabViewStyle for swipe navigation
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared
    @State private var currentPage = 0
    @State private var stepGoal: Double = 5000

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.96, blue: 0.92)
                .ignoresSafeArea()

            VStack {
                // Page indicator
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, Spacing.lg)

                // Page content
                TabView(selection: $currentPage) {
                    welcomePage
                        .tag(0)

                    healthKitPage
                        .tag(1)

                    goalSettingPage
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
                .foregroundStyle(.orange)

            Text("Welcome to CozyKitties")
                .font(Typography.largeTitle)
                .multilineTextAlignment(.center)

            Text("Build a cozy apartment filled with adorable cats by staying active and getting good sleep.")
                .font(Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Spacer()

            Button(action: { withAnimation { currentPage = 1 } }) {
                Text("Get Started")
                    .font(Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
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

            Text("Health Data")
                .font(Typography.largeTitle)
                .multilineTextAlignment(.center)

            Text("CozyKitties uses your step count to unlock new cats, sleep data to grow plants, and noise levels to set the weather.")
                .font(Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            VStack(alignment: .leading, spacing: Spacing.md) {
                healthFeatureRow(icon: "figure.walk", text: "Steps unlock new cats")
                healthFeatureRow(icon: "moon.zzz.fill", text: "Sleep grows plants")
                healthFeatureRow(icon: "speaker.wave.2.fill", text: "Noise sets weather")
            }
            .padding(Spacing.lg)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .padding(.horizontal, Spacing.xl)

            Spacer()

            Button(action: { requestHealthKitPermission() }) {
                Text("Allow Health Access")
                    .font(Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .padding(.horizontal, Spacing.xl)

            Button(action: { withAnimation { currentPage = 2 } }) {
                Text("Skip for Now")
                    .font(Typography.body)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func healthFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 30)

            Text(text)
                .font(Typography.body)
        }
    }

    private func requestHealthKitPermission() {
        // In production, this would call HealthKitService.shared.requestAuthorization()
        // For now, just advance to the next page
        Task {
            // try await HealthKitService.shared.requestAuthorization()
            await MainActor.run {
                withAnimation { currentPage = 2 }
            }
        }
    }

    // MARK: - Goal Setting Page

    private var goalSettingPage: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "target")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Set Your Goal")
                .font(Typography.largeTitle)
                .multilineTextAlignment(.center)

            Text("Choose a daily step goal. You'll unlock new cats by meeting your goal on consecutive days.")
                .font(Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            VStack(spacing: Spacing.md) {
                Text("\(Int(stepGoal).formatted()) steps")
                    .font(Typography.title)

                Slider(value: $stepGoal, in: 1000...20000, step: 500)
                    .tint(.green)
                    .padding(.horizontal, Spacing.lg)

                HStack {
                    Text("1,000")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("20,000")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, Spacing.lg)
            }
            .padding(Spacing.lg)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .padding(.horizontal, Spacing.xl)

            Spacer()

            Button(action: { completeOnboarding() }) {
                Text("Start My Journey")
                    .font(Typography.headline)
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

    private func completeOnboarding() {
        gameStateService.updateStepGoal(Int(stepGoal))
        gameStateService.completeOnboarding()
        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
