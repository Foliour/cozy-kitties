import Foundation
import HealthKit
import Observation

@Observable
final class HealthKitService: HealthKitServiceProtocol {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current

    /// Maximum number of days to scan back for streak calculation on first launch
    private let maxRetroactiveDays = 90

    // MARK: - Required HealthKit Types
    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKCategoryType(.sleepAnalysis)
        ]
        // Environmental audio exposure may not be available on all devices
        if let audioType = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure) {
            types.insert(audioType)
        }
        return types
    }

    private var writeTypes: Set<HKSampleType> {
        // Only needed for debug/testing - write step count
        [HKQuantityType(.stepCount)]
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.healthDataNotAvailable
        }

        try await healthStore.requestAuthorization(
            toShare: writeTypes, // Allow writing for debug test data
            read: readTypes
        )
    }

    // MARK: - Debug: Write Test Data

    /// Writes test step data for debugging purposes
    /// - Parameters:
    ///   - steps: Number of steps to add
    ///   - daysAgo: How many days ago (0 = today, 1 = yesterday, etc.)
    func writeTestSteps(_ steps: Int, daysAgo: Int) async throws {
        let stepType = HKQuantityType(.stepCount)
        let today = calendar.startOfDay(for: Date())

        guard let targetDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
            throw HealthKitError.queryFailed("Invalid date")
        }

        // Create sample at noon of the target day (point-in-time sample)
        guard let sampleTime = calendar.date(byAdding: .hour, value: 12, to: targetDate) else {
            throw HealthKitError.queryFailed("Invalid sample time")
        }

        let quantity = HKQuantity(unit: .count(), doubleValue: Double(steps))
        let sample = HKQuantitySample(
            type: stepType,
            quantity: quantity,
            start: sampleTime,
            end: sampleTime  // Point-in-time sample
        )

        try await healthStore.save(sample)
        print("HealthKit: Wrote \(steps) steps for \(daysAgo) days ago")
    }

    /// Writes 5000 steps for the last 5 days (for testing cat unlocks)
    func writeTestStepsForLastFiveDays() async throws {
        print("HealthKit: Writing test steps for last 5 days...")
        for day in 1...5 {
            try await writeTestSteps(5000, daysAgo: day)
        }
        print("HealthKit: Done writing test steps")
    }

    /// Debug: Fetch and print steps for recent days
    func debugPrintRecentSteps(goal: Int) async {
        print("HealthKit Debug: Checking recent steps (goal: \(goal))...")
        let today = calendar.startOfDay(for: Date())

        for daysAgo in 0...7 {
            guard let checkDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            do {
                let steps = try await fetchSteps(for: checkDate)
                let dateStr = DateFormatter.localizedString(from: checkDate, dateStyle: .short, timeStyle: .none)
                let metGoal = steps >= goal ? "YES" : "NO"
                print("  Day -\(daysAgo) (\(dateStr)): \(steps) steps, met goal: \(metGoal)")
            } catch {
                print("  Day -\(daysAgo): Error - \(error)")
            }
        }
    }

    // MARK: - Step Data

    func fetchSteps(for date: Date) async throws -> Int {
        let stepType = HKQuantityType(.stepCount)
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

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

    func calculateCurrentStreak(goal: Int, dayZero: Date? = nil) async -> Int {
        var streak = 0
        let today = calendar.startOfDay(for: Date())
        let dayZeroStart = dayZero.map { calendar.startOfDay(for: $0) }

        // Start from yesterday (today is still in progress)
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return 0
        }

        // Scan back up to maxRetroactiveDays
        for dayOffset in 0..<maxRetroactiveDays {
            guard let checkDate = calendar.date(byAdding: .day, value: -dayOffset, to: yesterday) else {
                break
            }

            // Don't count days before dayZero
            if let dayZeroStart = dayZeroStart, checkDate < dayZeroStart {
                break
            }

            // Use fetchStepsSafe which returns 0 on error instead of throwing
            let steps = await fetchStepsSafe(for: checkDate)

            if steps >= goal {
                streak += 1
            } else {
                // Streak broken (either no data or below goal)
                break
            }
        }

        return streak
    }

    /// Fetch steps without throwing - returns 0 if no data or error
    private func fetchStepsSafe(for date: Date) async -> Int {
        do {
            return try await fetchSteps(for: date)
        } catch {
            // No data for this day = 0 steps
            return 0
        }
    }

    /// Fetch today's steps - returns 0 if no data or error
    func fetchTodaySteps() async -> Int {
        return await fetchStepsSafe(for: Date())
    }

    // MARK: - Sleep Data

    func fetchSleepData(for date: Date) async throws -> SleepRecord? {
        let sleepType = HKCategoryType(.sleepAnalysis)

        // Sleep for a given date typically starts the evening before
        // Look for sleep samples that end on the target date
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Look back to the previous evening
        let previousEvening = calendar.date(byAdding: .hour, value: -12, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: previousEvening,
            end: endOfDay,
            options: .strictEndDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sleepSamples = samples as? [HKCategorySample], !sleepSamples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }

                // Sum up all sleep time (in-bed or asleep)
                // Filter for asleep states only (not in-bed awake)
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
                ]

                let totalMinutes = sleepSamples
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0) { total, sample in
                        let duration = sample.endDate.timeIntervalSince(sample.startDate)
                        return total + Int(duration / 60)
                    }

                continuation.resume(returning: SleepRecord(date: date, totalMinutes: totalMinutes))
            }

            healthStore.execute(query)
        }
    }

    func countGoodNights(since startDate: Date) async throws -> Int {
        var goodNights = 0
        let today = calendar.startOfDay(for: Date())
        var checkDate = calendar.startOfDay(for: startDate)

        while checkDate < today {
            if let sleepRecord = try await fetchSleepData(for: checkDate),
               sleepRecord.isGoodNight {
                goodNights += 1
            }

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: checkDate) else {
                break
            }
            checkDate = nextDate
        }

        return goodNights
    }

    // MARK: - Noise Data

    func fetchAverageNoiseLevel(for date: Date) async throws -> Double? {
        guard let noiseType = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure) else {
            return nil
        }

        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: noiseType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let decibels = result?.averageQuantity()?.doubleValue(for: .decibelAWeightedSoundPressureLevel())
                continuation.resume(returning: decibels)
            }

            healthStore.execute(query)
        }
    }

    /// Convenience method to get current weather state based on today's noise level
    func getCurrentWeatherState() async throws -> WeatherState {
        if let decibels = try await fetchAverageNoiseLevel(for: Date()) {
            return WeatherState.from(decibels: decibels)
        }
        // Default to sunny if no noise data available
        return .sunny
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
