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
    /// Average Steps per Day - calibrated during onboarding, used for cat unlock thresholds
    var averageStepsPerDay: Int = 5000

    /// Cached cumulative steps since day zero (source of truth is HealthKit)
    var cumulativeSteps: Int = 0

    var soundEnabled: Bool = true
    var hasCompletedOnboarding: Bool = false

    /// Day zero - when the user started playing
    var dayZero: Date = Date()

    /// Day/night mode setting (stored as Int for SwiftData)
    var dayNightModeRaw: Int = 0

    /// Computed property for day/night mode
    var dayNightMode: DayNightMode {
        get { DayNightMode(rawValue: dayNightModeRaw) ?? .auto }
        set { dayNightModeRaw = newValue.rawValue }
    }

    // Track which cats have been unlocked (by ID) - unlocks are permanent (high-water mark)
    var unlockedCatIDs: [String] = []

    // Track which cats the user has already seen the celebration for
    var celebratedCatIDs: [String] = []

    init(
        averageStepsPerDay: Int = 5000,
        cumulativeSteps: Int = 0,
        soundEnabled: Bool = true,
        hasCompletedOnboarding: Bool = false,
        dayZero: Date = Date(),
        dayNightModeRaw: Int = 0,
        unlockedCatIDs: [String] = [],
        celebratedCatIDs: [String] = []
    ) {
        self.averageStepsPerDay = averageStepsPerDay
        self.cumulativeSteps = cumulativeSteps
        self.soundEnabled = soundEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.dayZero = dayZero
        self.dayNightModeRaw = dayNightModeRaw
        self.unlockedCatIDs = unlockedCatIDs
        self.celebratedCatIDs = celebratedCatIDs
    }
}
