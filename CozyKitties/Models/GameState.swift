import Foundation
import SwiftData

@Model
final class GameState {
    // NOTE: currentStreak is NOT stored - it is derived from HealthKit on each app launch
    // This ensures consistency with HealthKit as the source of truth

    var longestStreak: Int = 0
    var totalGoodNights: Int = 0
    var dailyStepGoal: Int = 5000
    var soundEnabled: Bool = true
    var hasCompletedOnboarding: Bool = false

    /// Day zero - when the user started playing (for streak tracking)
    var dayZero: Date = Date()

    // Track which cats have been unlocked (by ID) - unlocks are permanent
    var unlockedCatIDs: [String] = []

    @Relationship(deleteRule: .cascade)
    var plants: [Plant] = []

    init(
        longestStreak: Int = 0,
        totalGoodNights: Int = 0,
        dailyStepGoal: Int = 5000,
        soundEnabled: Bool = true,
        hasCompletedOnboarding: Bool = false,
        dayZero: Date = Date(),
        unlockedCatIDs: [String] = [],
        plants: [Plant] = []
    ) {
        self.longestStreak = longestStreak
        self.totalGoodNights = totalGoodNights
        self.dailyStepGoal = dailyStepGoal
        self.soundEnabled = soundEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.dayZero = dayZero
        self.unlockedCatIDs = unlockedCatIDs
        self.plants = plants
    }
}
