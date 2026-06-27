import Foundation
import HealthKit

// MARK: - HealthKit Data Structures
struct DailySteps {
    let date: Date
    let count: Int
}

// MARK: - HealthKit Service Protocol
protocol HealthKitServiceProtocol {
    /// Requests authorization to read HealthKit data
    func requestAuthorization() async throws

    /// Fetches step count for a specific date
    func fetchSteps(for date: Date) async throws -> Int

    /// Fetches cumulative steps from dayZero through today (inclusive)
    func fetchCumulativeSteps(since dayZero: Date) async -> Int

    /// Analyzes historical step data to suggest an average steps per day
    func analyzeHistoricalAverageSteps(days: Int) async -> Int?
}
