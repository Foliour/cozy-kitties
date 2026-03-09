import Foundation
import SwiftData

/// Day/night mode setting
enum DayNightMode: Int, CaseIterable {
    case auto = 0      // Based on actual time of day
    case alwaysDay = 1
    case alwaysNight = 2

    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .alwaysDay: return "Always Day"
        case .alwaysNight: return "Always Night"
        }
    }
}

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

    /// Day/night mode setting (stored as Int for SwiftData)
    var dayNightModeRaw: Int = 0

    /// Computed property for day/night mode
    var dayNightMode: DayNightMode {
        get { DayNightMode(rawValue: dayNightModeRaw) ?? .auto }
        set { dayNightModeRaw = newValue.rawValue }
    }

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
        dayNightModeRaw: Int = 0,
        unlockedCatIDs: [String] = [],
        plants: [Plant] = []
    ) {
        self.longestStreak = longestStreak
        self.totalGoodNights = totalGoodNights
        self.dailyStepGoal = dailyStepGoal
        self.soundEnabled = soundEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.dayZero = dayZero
        self.dayNightModeRaw = dayNightModeRaw
        self.unlockedCatIDs = unlockedCatIDs
        self.plants = plants
    }
}
