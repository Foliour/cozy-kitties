import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class GameStateService {
    static let shared = GameStateService()

    private var modelContext: ModelContext?
    private(set) var gameState: GameState?

    private init() {}

    // MARK: - Initialization

    /// Configure the service with a SwiftData model context (runs once)
    func configure(with modelContext: ModelContext) {
        guard self.modelContext == nil else { return }
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
                // Migration: backfill celebratedCatIDs for existing users
                if existing.celebratedCatIDs.isEmpty && !existing.unlockedCatIDs.isEmpty {
                    existing.celebratedCatIDs = existing.unlockedCatIDs
                    try modelContext.save()
                }
            } else {
                let newState = GameState()
                newState.unlockedCatIDs = ["luna"]
                newState.celebratedCatIDs = ["luna"]

                modelContext.insert(newState)
                try modelContext.save()
                gameState = newState
            }
        } catch {
            #if DEBUG
            print("Failed to load or create game state: \(error)")
            #endif
        }
    }

    // MARK: - Cat Management

    /// Get all unlocked cats using hybrid logic:
    /// A cat is unlocked if it's in unlockedCatIDs (permanent) OR meets the current threshold.
    /// Newly derived unlocks are persisted to unlockedCatIDs (high-water mark).
    func getUnlockedCats() -> [CatDefinition] {
        guard let gameState = gameState else { return [] }

        let asd = gameState.averageStepsPerDay
        let steps = gameState.cumulativeSteps
        var unlocked = Set(gameState.unlockedCatIDs)
        var didPersistNew = false

        for cat in catRoster {
            if steps >= cat.stepsRequired(asd: asd) && !unlocked.contains(cat.id) {
                unlocked.insert(cat.id)
                gameState.unlockedCatIDs.append(cat.id)
                didPersistNew = true
            }
        }

        if didPersistNew { saveContext() }

        return catRoster.filter { unlocked.contains($0.id) }
    }

    /// Check if a specific cat is unlocked
    func isCatUnlocked(_ catID: String) -> Bool {
        guard let gameState = gameState else { return false }
        if gameState.unlockedCatIDs.contains(catID) { return true }
        let asd = gameState.averageStepsPerDay
        let steps = gameState.cumulativeSteps
        if let cat = catRoster.cat(withID: catID), steps >= cat.stepsRequired(asd: asd) {
            gameState.unlockedCatIDs.append(catID)
            saveContext()
            return true
        }
        return false
    }

    /// Update cumulative steps and return uncelebrated cats
    func checkAndUnlockCats(cumulativeSteps: Int) -> [CatDefinition] {
        guard let gameState = gameState else { return [] }

        gameState.cumulativeSteps = cumulativeSteps
        let allUnlocked = getUnlockedCats()
        let uncelebrated = allUnlocked.filter { !gameState.celebratedCatIDs.contains($0.id) }

        saveContext()
        return uncelebrated
    }

    /// Mark a cat's celebration as seen (persisted)
    func markCelebrated(catID: String) {
        guard let gameState = gameState else { return }
        if !gameState.celebratedCatIDs.contains(catID) {
            gameState.celebratedCatIDs.append(catID)
            saveContext()
        }
    }

    /// Get the next cat to unlock and steps remaining
    func getNextCatToUnlock(cumulativeSteps: Int) -> (cat: CatDefinition, stepsRemaining: Int)? {
        guard let gameState = gameState else { return nil }
        let asd = gameState.averageStepsPerDay

        guard let nextCat = catRoster.nextCatToUnlock(cumulativeSteps: cumulativeSteps, asd: asd) else {
            return nil
        }

        let stepsRemaining = nextCat.stepsRequired(asd: asd) - cumulativeSteps
        return (nextCat, stepsRemaining)
    }

    // MARK: - Health Data Sync

    /// Sync health data and return uncelebrated cats
    func syncHealthData() async -> [CatDefinition] {
        guard let gameState = gameState else {
            #if DEBUG
            print("GameStateService: syncHealthData - no gameState!")
            #endif
            return []
        }

        do {
            try await HealthKitService.shared.requestAuthorization()

            #if DEBUG
            print("GameStateService: Syncing health data...")
            print("GameStateService: ASD = \(gameState.averageStepsPerDay)")
            await HealthKitService.shared.debugPrintRecentSteps()
            #endif

            let cumulative = await HealthKitService.shared.fetchCumulativeSteps(since: gameState.dayZero)

            #if DEBUG
            print("GameStateService: Cumulative steps = \(cumulative) (since dayZero: \(gameState.dayZero))")
            #endif

            let uncelebrated = checkAndUnlockCats(cumulativeSteps: cumulative)

            #if DEBUG
            print("GameStateService: Unlocked \(getUnlockedCats().count) cats, \(uncelebrated.count) uncelebrated")
            #endif

            return uncelebrated
        } catch {
            #if DEBUG
            print("GameStateService: Failed to sync health data - \(error)")
            #endif
            return []
        }
    }

    // MARK: - Settings

    func updateAverageStepsPerDay(_ asd: Int) {
        guard let gameState = gameState else { return }
        gameState.averageStepsPerDay = max(1000, min(asd, 30000))
        saveContext()
    }

    func toggleSound(_ enabled: Bool) {
        guard let gameState = gameState else { return }
        gameState.soundEnabled = enabled
        saveContext()
    }

    func updateDayNightMode(_ mode: DayNightMode) {
        guard let gameState = gameState else { return }
        gameState.dayNightMode = mode
        saveContext()
    }

    func completeOnboarding() {
        guard let gameState = gameState else { return }
        gameState.hasCompletedOnboarding = true
        saveContext()
    }

    // MARK: - Day Zero Management

    func setDayZero(_ date: Date) {
        guard let gameState = gameState else { return }
        gameState.dayZero = date
        gameState.unlockedCatIDs = ["luna"]
        gameState.celebratedCatIDs = ["luna"]
        gameState.cumulativeSteps = 0
        saveContext()
    }

    func getDayZero() -> Date? {
        return gameState?.dayZero
    }

    func resetGame() {
        guard let gameState = gameState else { return }
        gameState.dayZero = Date()
        gameState.cumulativeSteps = 0
        gameState.unlockedCatIDs = ["luna"]
        gameState.celebratedCatIDs = ["luna"]
        saveContext()
    }

    // MARK: - Private Helpers

    private func saveContext() {
        guard let modelContext = modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            #if DEBUG
            print("GameStateService: saveContext FAILED - \(error)")
            #endif
        }
    }
}
