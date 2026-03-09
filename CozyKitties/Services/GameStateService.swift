import Foundation
import SwiftData
import Observation

@Observable
final class GameStateService {
    static let shared = GameStateService()

    private var modelContext: ModelContext?
    private(set) var gameState: GameState?

    /// Cats that were recently unlocked and need celebration
    var catsAwaitingCelebration: [CatDefinition] = []

    private init() {}

    // MARK: - Initialization

    /// Configure the service with a SwiftData model context
    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateGameState()
    }

    /// Load existing game state or create a new one
    func loadOrCreateGameState() {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<GameState>()

        do {
            let existingStates = try modelContext.fetch(descriptor)
            if let existing = existingStates.first {
                gameState = existing
            } else {
                // Create new game state with default values
                let newState = GameState()

                // Initialize default plants
                for plantType in PlantType.allCases {
                    let plant = Plant(id: plantType.rawValue, type: plantType)
                    newState.plants.append(plant)
                }

                // Mochi is unlocked by default (0 streak required)
                newState.unlockedCatIDs = ["trouble"]

                modelContext.insert(newState)
                try modelContext.save()
                gameState = newState
            }
        } catch {
            print("Failed to load or create game state: \(error)")
        }
    }

    // MARK: - Cat Management

    /// Check and unlock any cats based on the current streak
    /// - Parameter currentStreak: The player's current streak from HealthKit
    /// - Returns: Array of newly unlocked cat definitions
    func checkAndUnlockCats(currentStreak: Int) -> [CatDefinition] {
        guard let gameState = gameState else { return [] }

        var newlyUnlocked: [CatDefinition] = []

        for cat in catRoster {
            // Check if cat should be unlocked and isn't already
            if cat.streakRequired <= currentStreak &&
               !gameState.unlockedCatIDs.contains(cat.id) {
                gameState.unlockedCatIDs.append(cat.id)
                newlyUnlocked.append(cat)
            }
        }

        // Update longest streak if this is a new record
        if currentStreak > gameState.longestStreak {
            gameState.longestStreak = currentStreak
        }

        // Add newly unlocked cats to celebration queue
        catsAwaitingCelebration.append(contentsOf: newlyUnlocked)

        saveContext()

        return newlyUnlocked
    }

    /// Get all unlocked cat definitions
    func getUnlockedCats() -> [CatDefinition] {
        guard let gameState = gameState else {
            print("GameStateService: getUnlockedCats - gameState is nil")
            return []
        }

        print("GameStateService: getUnlockedCats - unlockedCatIDs: \(gameState.unlockedCatIDs)")
        let cats = catRoster.filter { gameState.unlockedCatIDs.contains($0.id) }
        print("GameStateService: getUnlockedCats - found \(cats.count) cats: \(cats.map { $0.name })")
        return cats
    }

    /// Get the next cat to unlock and days remaining
    func getNextCatToUnlock(currentStreak: Int) -> (cat: CatDefinition, daysRemaining: Int)? {
        guard let nextCat = catRoster.nextCatToUnlock(afterStreak: currentStreak) else {
            return nil
        }

        let daysRemaining = nextCat.streakRequired - currentStreak
        return (nextCat, daysRemaining)
    }

    // MARK: - Plant Management

    /// Update plant growth based on total good nights
    /// - Parameter goodNights: Total cumulative good nights from HealthKit
    func updatePlantGrowth(goodNights: Int) {
        guard let gameState = gameState else { return }

        // Update totalGoodNights
        gameState.totalGoodNights = goodNights

        for plant in gameState.plants {
            let required = plant.type.goodNightsToUnlock

            if plant.unlockedAt == nil && goodNights >= required {
                // Unlock the plant
                plant.unlockedAt = Date()
                plant.growthStage = 1
            } else if plant.unlockedAt != nil {
                // Calculate growth stage based on nights since unlock threshold
                let nightsSinceUnlock = goodNights - required
                plant.growthStage = min(3, max(1, 1 + nightsSinceUnlock / 3))
            }
        }

        saveContext()
    }

    /// Get all plants
    func getPlants() -> [Plant] {
        gameState?.plants ?? []
    }

    // MARK: - Streak Management

    /// Update longest streak if the new value is a record
    func updateLongestStreak(_ streak: Int) {
        guard let gameState = gameState else { return }

        if streak > gameState.longestStreak {
            gameState.longestStreak = streak
            saveContext()
        }
    }

    /// Record a good night (called when sleep data shows 7+ hours)
    func recordGoodNight() {
        guard let gameState = gameState else { return }

        gameState.totalGoodNights += 1
        saveContext()
    }

    // MARK: - Health Data Sync

    /// Sync health data and check for unlocks
    /// - Returns: Array of newly unlocked cats (for celebration UI)
    @MainActor
    func syncHealthData() async -> [CatDefinition] {
        guard let gameState = gameState else {
            print("GameStateService: syncHealthData - no gameState!")
            return []
        }

        do {
            print("GameStateService: Syncing health data...")
            print("GameStateService: Step goal = \(gameState.dailyStepGoal)")
            print("GameStateService: Already unlocked cats = \(gameState.unlockedCatIDs)")

            // Debug: print recent steps
            await HealthKitService.shared.debugPrintRecentSteps(goal: gameState.dailyStepGoal)

            // Get current streak from HealthKit (only counting days since dayZero)
            let streak = await HealthKitService.shared.calculateCurrentStreak(goal: gameState.dailyStepGoal, dayZero: gameState.dayZero)
            print("GameStateService: Current streak = \(streak) days (since dayZero: \(gameState.dayZero))")

            // Check and unlock cats based on streak
            let newlyUnlocked = checkAndUnlockCats(currentStreak: streak)

            if !newlyUnlocked.isEmpty {
                print("GameStateService: Unlocked \(newlyUnlocked.count) new cats: \(newlyUnlocked.map { $0.name })")
            } else {
                print("GameStateService: No new cats unlocked")
            }

            return newlyUnlocked
        } catch {
            print("GameStateService: Failed to sync health data - \(error)")
            return []
        }
    }

    // MARK: - Settings

    /// Update the daily step goal
    func updateStepGoal(_ goal: Int) {
        guard let gameState = gameState else { return }

        gameState.dailyStepGoal = goal
        saveContext()
    }

    /// Toggle sound enabled/disabled
    func toggleSound(_ enabled: Bool) {
        guard let gameState = gameState else { return }

        gameState.soundEnabled = enabled
        saveContext()
    }

    /// Mark onboarding as completed
    func completeOnboarding() {
        guard let gameState = gameState else { return }

        gameState.hasCompletedOnboarding = true
        saveContext()
    }

    // MARK: - Day Zero Management

    /// Set day zero (for debug purposes) - also resets unlocked cats
    func setDayZero(_ date: Date) {
        guard let gameState = gameState else { return }

        gameState.dayZero = date
        // Reset to only starter cat since streak is now recalculated from new dayZero
        gameState.unlockedCatIDs = ["trouble"]
        gameState.longestStreak = 0
        catsAwaitingCelebration = []
        saveContext()
    }

    /// Get the current day zero
    func getDayZero() -> Date? {
        return gameState?.dayZero
    }

    /// Reset the entire game with a new day zero
    func resetGame() {
        guard let gameState = gameState else { return }

        // Reset all progress
        gameState.longestStreak = 0
        gameState.totalGoodNights = 0
        gameState.dayZero = Date()

        // Keep only the starter cat (Trouble)
        gameState.unlockedCatIDs = ["trouble"]

        // Reset plants
        for plant in gameState.plants {
            plant.unlockedAt = nil
            plant.growthStage = 0
        }

        // Clear celebration queue
        catsAwaitingCelebration = []

        saveContext()
    }

    // MARK: - Private Helpers

    private func saveContext() {
        guard let modelContext = modelContext else { return }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save game state: \(error)")
        }
    }
}
