import Foundation
import HealthKit
import Observation

@Observable
final class HealthKitService: HealthKitServiceProtocol {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current

    // MARK: - Required HealthKit Types
    private var readTypes: Set<HKObjectType> {
        [HKQuantityType(.stepCount)]
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.healthDataNotAvailable
        }

        #if DEBUG
        let shareTypes: Set<HKSampleType> = [HKQuantityType(.stepCount)]
        #else
        let shareTypes: Set<HKSampleType> = []
        #endif

        try await healthStore.requestAuthorization(
            toShare: shareTypes,
            read: readTypes
        )
    }

    // MARK: - Debug: Write Test Data

    #if DEBUG
    /// Writes test step data for debugging purposes
    func writeTestSteps(_ steps: Int, daysAgo: Int) async throws {
        let stepType = HKQuantityType(.stepCount)
        let today = calendar.startOfDay(for: Date())

        guard let targetDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
            throw HealthKitError.queryFailed("Invalid date")
        }

        guard let sampleTime = calendar.date(byAdding: .hour, value: 12, to: targetDate) else {
            throw HealthKitError.queryFailed("Invalid sample time")
        }

        let quantity = HKQuantity(unit: .count(), doubleValue: Double(steps))
        let sample = HKQuantitySample(
            type: stepType,
            quantity: quantity,
            start: sampleTime,
            end: sampleTime
        )

        try await healthStore.save(sample)
        print("HealthKit: Wrote \(steps) steps for \(daysAgo) days ago")
    }

    /// Debug: Fetch and print steps for recent days
    func debugPrintRecentSteps() async {
        print("HealthKit Debug: Checking recent steps...")
        let today = calendar.startOfDay(for: Date())

        for daysAgo in 0...7 {
            guard let checkDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            do {
                let steps = try await fetchSteps(for: checkDate)
                let dateStr = DateFormatter.localizedString(from: checkDate, dateStyle: .short, timeStyle: .none)
                print("  Day -\(daysAgo) (\(dateStr)): \(steps) steps")
            } catch {
                print("  Day -\(daysAgo): Error - \(error)")
            }
        }
    }
    #endif

    // MARK: - Step Data

    func fetchSteps(for date: Date) async throws -> Int {
        let stepType = HKQuantityType(.stepCount)
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw HealthKitError.queryFailed("Failed to calculate end of day for \(date)")
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }

            healthStore.execute(query)
        }
    }

    /// Fetch cumulative steps from dayZero through today (inclusive)
    func fetchCumulativeSteps(since dayZero: Date) async -> Int {
        let stepType = HKQuantityType(.stepCount)
        let start = calendar.startOfDay(for: dayZero)
        let end = Date() // Right now, to include today's steps so far

        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        do {
            return try await withCheckedThrowingContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: stepType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    continuation.resume(returning: Int(steps))
                }

                healthStore.execute(query)
            }
        } catch {
            return 0
        }
    }

    /// Fetch steps without throwing - returns 0 if no data or error
    private func fetchStepsSafe(for date: Date) async -> Int {
        do {
            return try await fetchSteps(for: date)
        } catch {
            return 0
        }
    }

    /// Fetch today's steps - returns 0 if no data or error
    func fetchTodaySteps() async -> Int {
        return await fetchStepsSafe(for: Date())
    }

    // MARK: - Historical Analysis

    /// Analyzes the last N days of step data to suggest an average steps per day
    /// Returns nil if insufficient data (fewer than 7 days)
    func analyzeHistoricalAverageSteps(days: Int = 30) async -> Int? {
        let today = calendar.startOfDay(for: Date())
        var totalSteps = 0
        var daysWithData = 0

        for daysAgo in 1...days {
            guard let checkDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let steps = await fetchStepsSafe(for: checkDate)
            if steps > 0 {
                totalSteps += steps
                daysWithData += 1
            }
        }

        guard daysWithData >= 7 else { return nil }
        return totalSteps / daysWithData
    }
}

// MARK: - Errors
enum HealthKitError: Error, LocalizedError {
    case healthDataNotAvailable
    case authorizationDenied
    case queryFailed(String)

    var errorDescription: String? {
        switch self {
        case .healthDataNotAvailable:
            return "Health data is not available on this device."
        case .authorizationDenied:
            return "HealthKit authorization was denied."
        case .queryFailed(let message):
            return "HealthKit query failed: \(message)"
        }
    }
}
