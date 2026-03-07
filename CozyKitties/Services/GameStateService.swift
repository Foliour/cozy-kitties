import Foundation
import SwiftData
import Observation

@Observable
final class GameStateService {
    static let shared = GameStateService()

    private var modelContext: ModelContext?
    private(set) var gameState: GameState?

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
                newState.unlockedCatIDs = ["mochi"]

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

        saveContext()

        return newlyUnlocked
    }

    /// Get all unlocked cat definitions
    func getUnlockedCats() -> [CatDefinition] {
        guard let gameState = gameState else { return [] }

        return catRoster.filter { gameState.unlockedCatIDs.contains($0.id) }
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
