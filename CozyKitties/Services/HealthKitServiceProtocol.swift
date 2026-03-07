import Foundation
import HealthKit

// MARK: - HealthKit Data Structures
struct DailySteps {
    let date: Date
    let count: Int

    func metGoal(_ goal: Int) -> Bool {
        count >= goal
    }
}

struct SleepRecord {
    let date: Date
    let totalMinutes: Int

    /// A "good night" is 7+ hours of sleep (420 minutes)
    var isGoodNight: Bool {
        totalMinutes >= 420
    }
}

struct NoiseExposure {
    let date: Date
    let averageDecibels: Double

    var weatherState: WeatherState {
        WeatherState.from(decibels: averageDecibels)
    }
}

// MARK: - HealthKit Service Protocol
protocol HealthKitServiceProtocol {
    /// Requests authorization to read HealthKit data
    /// - Throws: If authorization request fails
    func requestAuthorization() async throws

    /// Fetches step count for a specific date
    /// - Parameter date: The date to fetch steps for
    /// - Returns: The number of steps for that date
    func fetchSteps(for date: Date) async throws -> Int

    /// Calculates the current streak of consecutive days meeting the step goal
    /// Scans backwards from yesterday (today is still in progress)
    /// - Parameter goal: The daily step goal to check against
    /// - Returns: The number of consecutive days meeting the goal
    func calculateCurrentStreak(goal: Int) async throws -> Int

    /// Fetches sleep data for a specific date
    /// - Parameter date: The date to fetch sleep data for
    /// - Returns: Sleep record if available, nil otherwise
    func fetchSleepData(for date: Date) async throws -> SleepRecord?

    /// Counts the number of "good nights" (7+ hours sleep) since a given date
    /// - Parameter startDate: The date to start counting from
    /// - Returns: Total count of good nights
    func countGoodNights(since startDate: Date) async throws -> Int

    /// Fetches the average environmental audio exposure level for a date
    /// - Parameter date: The date to fetch noise data for
    /// - Returns: Average decibel level if available, nil otherwise
    func fetchAverageNoiseLevel(for date: Date) async throws -> Double?
}
