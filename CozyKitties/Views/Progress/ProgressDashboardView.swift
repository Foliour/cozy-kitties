import SwiftUI
import SwiftData

/// Progress dashboard showing streak, next cat unlock, and sleep/plant status
/// Uses glass card styling for a modern iOS 18 look
struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared

    // Simulated current streak (would come from HealthKit in production)
    @State private var currentStreak: Int = 3
    @State private var todaySteps: Int = 4250
    @State private var stepGoal: Int = 5000

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Current Streak Card
                    streakCard

                    // Next Cat Progress Card
                    nextCatCard

                    // Today's Progress Card
                    todayProgressCard

                    // Sleep & Plants Card
                    sleepPlantsCard
                }
                .padding(Spacing.md)
            }
            .background(Color(red: 0.98, green: 0.96, blue: 0.92))
            .navigationTitle("Progress")
        }
        .onAppear {
            gameStateService.configure(with: modelContext)
            if let state = gameStateService.gameState {
                stepGoal = state.dailyStepGoal
            }
        }
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        GlassCard {
            VStack(spacing: Spacing.md) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Current Streak")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                        Text("\(currentStreak) days")
                            .font(Typography.title)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("Best")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                        Text("\(gameStateService.gameState?.longestStreak ?? 0) days")
                            .font(Typography.headline)
                    }
                }
            }
        }
    }

    // MARK: - Next Cat Card

    private var nextCatCard: some View {
        GlassCard {
            VStack(spacing: Spacing.md) {
                HStack {
                    Image(systemName: "cat.fill")
                        .font(.title)
                        .foregroundStyle(.purple)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Next Cat")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)

                        if let nextCat = gameStateService.getNextCatToUnlock(currentStreak: currentStreak) {
                            Text(nextCat.cat.name)
                                .font(Typography.headline)
                        } else {
                            Text("All cats unlocked!")
                                .font(Typography.headline)
                        }
                    }

                    Spacer()

                    if let nextCat = gameStateService.getNextCatToUnlock(currentStreak: currentStreak) {
                        VStack(alignment: .trailing, spacing: Spacing.xs) {
                            Text("\(nextCat.daysRemaining) days left")
                                .font(Typography.caption)
                                .foregroundStyle(.secondary)

                            // Progress bar
                            ProgressView(
                                value: Double(currentStreak),
                                total: Double(nextCat.cat.streakRequired)
                            )
                            .tint(.purple)
                            .frame(width: 80)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Today's Progress Card

    private var todayProgressCard: some View {
        GlassCard {
            VStack(spacing: Spacing.md) {
                HStack {
                    Image(systemName: "figure.walk")
                        .font(.title)
                        .foregroundStyle(.green)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Today's Steps")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                        Text("\(todaySteps.formatted())")
                            .font(Typography.title)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("Goal: \(stepGoal.formatted())")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)

                        let progress = min(Double(todaySteps) / Double(stepGoal), 1.0)
                        Text("\(Int(progress * 100))%")
                            .font(Typography.headline)
                            .foregroundStyle(progress >= 1.0 ? .green : .primary)
                    }
                }

                ProgressView(value: Double(todaySteps), total: Double(stepGoal))
                    .tint(todaySteps >= stepGoal ? .green : .blue)
            }
        }
    }

    // MARK: - Sleep & Plants Card

    private var sleepPlantsCard: some View {
        GlassCard {
            VStack(spacing: Spacing.md) {
                HStack {
                    // Sleep section
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.title2)
                            .foregroundStyle(.indigo)

                        Text("Good Nights")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)

                        Text("\(gameStateService.gameState?.totalGoodNights ?? 0)")
                            .font(Typography.headline)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()
                        .frame(height: 60)

                    // Plants section
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "leaf.fill")
                            .font(.title2)
                            .foregroundStyle(.green)

                        Text("Plants Grown")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)

                        let unlockedPlants = gameStateService.getPlants().filter { $0.unlockedAt != nil }
                        Text("\(unlockedPlants.count)/\(PlantType.allCases.count)")
                            .font(Typography.headline)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Glass Card Component

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .shadow(Shadow.sm)
    }
}

#Preview {
    ProgressDashboardView()
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
