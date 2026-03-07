# Technical Design Document
## Cozy Kitties Health Tracker

**Version:** 1.0
**Last Updated:** March 6, 2026
**Author:** Kathryn Styons

---

## 1. Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        SwiftUI Views                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐│
│  │ ApartmentView│ │CatCollection│ │ProgressView │ │Settings ││
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └────┬────┘│
└─────────┼───────────────┼───────────────┼──────────────┼────┘
          │               │               │              │
          ▼               ▼               ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                      ViewModels (Observable)                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ ApartmentViewModel│ │GameStateViewModel│ │SettingsVM   │ │
│  └────────┬────────┘  └────────┬────────┘  └──────┬───────┘ │
└───────────┼────────────────────┼───────────────────┼────────┘
            │                    │                   │
            ▼                    ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                         Services                             │
│  ┌───────────────┐  ┌───────────────┐  ┌──────────────────┐ │
│  │HealthKitService│  │  AudioService │  │ GameStateService │ │
│  └───────┬───────┘  └───────────────┘  └────────┬─────────┘ │
└──────────┼──────────────────────────────────────┼───────────┘
           │                                      │
           ▼                                      ▼
┌─────────────────────┐              ┌────────────────────────┐
│     HealthKit       │              │      SwiftData         │
│  (Apple Framework)  │              │   (Local Persistence)  │
└─────────────────────┘              └────────────────────────┘
```

### 1.2 Design Patterns

| Pattern | Usage |
|---------|-------|
| **MVVM** | ViewModels mediate between Views and Services |
| **Repository** | GameStateService abstracts SwiftData operations |
| **Singleton** | HealthKitService, AudioService (single instances) |
| **Observer** | `@Observable` macro for reactive state updates |

### 1.3 Technology Stack

| Layer | Technology |
|-------|------------|
| UI Framework | SwiftUI (iOS 26+) |
| UI Design | Liquid Glass (`glassEffect` modifier) |
| Data Persistence | SwiftData |
| Health Data | HealthKit |
| Audio | AVFoundation |
| Architecture | MVVM with Swift Observation |
| Minimum Target | iOS 26.0 |
| Language | Swift 6 |

---

## 2. Project Structure

```
CozyKitties/
├── App/
│   ├── CozyKittiesApp.swift          # App entry point
│   └── AppState.swift                 # Global app state
│
├── Models/
│   ├── Cat.swift                      # Cat model (SwiftData)
│   ├── Plant.swift                    # Plant model (SwiftData)
│   ├── GameState.swift                # Main game state (SwiftData)
│   ├── HealthData.swift               # HealthKit data structures
│   └── WeatherState.swift             # Weather enum
│
├── ViewModels/
│   ├── ApartmentViewModel.swift       # Main apartment logic
│   ├── GameStateViewModel.swift       # Progression/unlocks
│   ├── OnboardingViewModel.swift      # Onboarding flow
│   └── SettingsViewModel.swift        # Settings management
│
├── Views/
│   ├── Apartment/
│   │   ├── ApartmentView.swift        # Main apartment scene
│   │   ├── CatView.swift              # Individual cat rendering
│   │   ├── PlantView.swift            # Individual plant rendering
│   │   ├── WindowView.swift           # Window with weather
│   │   └── FurnitureView.swift        # Static furniture elements
│   │
│   ├── Collection/
│   │   ├── CatCollectionView.swift    # Cat gallery
│   │   └── CatDetailView.swift        # Individual cat info
│   │
│   ├── Progress/
│   │   ├── ProgressView.swift         # Stats dashboard
│   │   └── StreakIndicator.swift      # Streak visualization
│   │
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift
│   │   ├── WelcomeView.swift
│   │   ├── HealthKitPermissionView.swift
│   │   ├── GoalSettingView.swift
│   │   └── ApartmentIntroView.swift
│   │
│   ├── Settings/
│   │   └── SettingsView.swift
│   │
│   └── Components/
│       ├── GlassCard.swift            # Reusable Liquid Glass card
│       ├── GlassButton.swift          # Liquid Glass button
│       └── GlassTabBar.swift          # Custom tab bar
│
├── Services/
│   ├── HealthKitService.swift         # HealthKit integration
│   ├── GameStateService.swift         # Game logic & persistence
│   └── AudioService.swift             # Ambient sounds
│
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Cats/                      # Cat images
│   │   ├── Plants/                    # Plant images
│   │   ├── Furniture/                 # Furniture images
│   │   └── Colors/                    # Color assets
│   │
│   └── Sounds/
│       ├── purring.mp3
│       ├── rain.mp3
│       └── cozy-ambience.mp3
│
├── Extensions/
│   ├── View+GlassEffect.swift         # Liquid Glass helpers
│   ├── Date+Helpers.swift
│   └── Color+Theme.swift
│
├── Design/
│   └── DesignTokens.swift             # Spacing, typography, radius, shadow constants
│
├── Preview Content/
│   └── PreviewData.swift              # SwiftUI preview helpers
│
Specs/                                  # Machine-readable content definitions (root level)
├── cats.yaml                           # Cat roster with unlock conditions
├── plants.yaml                         # Plant definitions and growth triggers
└── tasks.yaml                          # Task manifest for agentic development

.github/
└── workflows/
    └── ci.yml                          # Automated build, test, deploy pipeline
```

---

## 3. Data Models

### 3.1 SwiftData Schema

```swift
// GameState.swift
@Model
final class GameState {
    // NOTE: currentStreak is NOT stored — it is derived from HealthKit on each app launch
    // This ensures consistency with HealthKit as the source of truth
    var longestStreak: Int = 0
    var totalGoodNights: Int = 0
    var dailyStepGoal: Int = 5000
    var soundEnabled: Bool = true
    var hasCompletedOnboarding: Bool = false

    // Track which cats have been unlocked (by ID) — unlocks are permanent
    var unlockedCatIDs: [String] = []

    @Relationship(deleteRule: .cascade)
    var plants: [Plant] = []
}

// Cat.swift
@Model
final class Cat {
    var id: String              // e.g., "mochi", "shadow"
    var name: String            // Display name
    var appearance: String      // Asset name
    var unlockedAt: Date
    var streakRequired: Int     // Days needed to unlock

    // Position in apartment (normalized 0-1)
    var positionX: Double
    var positionY: Double
}

// Plant.swift
@Model
final class Plant {
    var id: String              // e.g., "pothos_1"
    var type: PlantType         // Enum: pothos, succulent, etc.
    var growthStage: Int        // 0-3 (dormant to full)
    var goodNightsRequired: Int // To unlock
    var unlockedAt: Date?

    var positionX: Double
    var positionY: Double
}
```

### 3.2 Enums

```swift
enum PlantType: String, Codable, CaseIterable {
    case pothos
    case succulent
    case monstera
    case fern
    case flowers

    var goodNightsToUnlock: Int {
        switch self {
        case .pothos: return 3
        case .succulent: return 5
        case .monstera: return 7
        case .fern: return 10
        case .flowers: return 14
        }
    }
}

enum WeatherState: String, CaseIterable {
    case sunny          // < 60 dB average
    case partlyCloudy   // 60-70 dB
    case overcast       // 70-80 dB
    case gentleRain     // > 80 dB (still cozy!)

    var windowOpacity: Double {
        switch self {
        case .sunny: return 1.0
        case .partlyCloudy: return 0.85
        case .overcast: return 0.7
        case .gentleRain: return 0.6
        }
    }
}

enum CatActivity: String {
    case sleeping
    case sitting
    case playing
    case walking
}
```

### 3.3 HealthKit Data Structures

```swift
struct DailySteps {
    let date: Date
    let count: Int
    var metGoal: Bool { count >= goalForDate }
}

struct SleepRecord {
    let date: Date
    let totalMinutes: Int
    var isGoodNight: Bool { totalMinutes >= 420 } // 7 hours
}

struct NoiseExposure {
    let date: Date
    let averageDecibels: Double

    var weatherState: WeatherState {
        switch averageDecibels {
        case ..<60: return .sunny
        case 60..<70: return .partlyCloudy
        case 70..<80: return .overcast
        default: return .gentleRain
        }
    }
}
```

---

## 4. Services

### 4.1 HealthKitService

```swift
@Observable
final class HealthKitService {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()

    var authorizationStatus: HKAuthorizationStatus = .notDetermined
    var isAuthorized: Bool { authorizationStatus == .sharingAuthorized }

    // Required HealthKit types
    private let readTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKCategoryType(.sleepAnalysis),
        HKQuantityType(.environmentalAudioExposure)
    ]

    // MARK: - Authorization
    func requestAuthorization() async throws {
        try await healthStore.requestAuthorization(
            toShare: [],  // We only read, never write
            read: readTypes
        )
    }

    // MARK: - Step Data
    func fetchSteps(for date: Date) async throws -> Int
    func fetchStepsForDateRange(start: Date, end: Date) async throws -> [DailySteps]
    func calculateCurrentStreak(goal: Int) async throws -> Int

    // MARK: - Sleep Data
    func fetchSleepData(for date: Date) async throws -> SleepRecord?
    func countGoodNights(since: Date) async throws -> Int

    // MARK: - Noise Data
    func fetchAverageNoiseLevel(for date: Date) async throws -> Double?
    func getCurrentWeatherState() async throws -> WeatherState
}
```

### 4.2 GameStateService

```swift
@Observable
final class GameStateService {
    static let shared = GameStateService()

    private var modelContext: ModelContext?

    var gameState: GameState?

    // MARK: - Initialization
    func configure(with modelContext: ModelContext)
    func loadOrCreateGameState()

    // MARK: - Cat Management
    func checkAndUnlockCats(currentStreak: Int) -> [Cat]
    func getUnlockedCats() -> [Cat]
    func getNextCatToUnlock() -> (cat: CatDefinition, daysRemaining: Int)?

    // MARK: - Plant Management
    func updatePlantGrowth(goodNights: Int)
    func getPlants() -> [Plant]

    // MARK: - Streak Management
    // NOTE: Streak is derived from HealthKit, not stored
    // Call HealthKitService.calculateCurrentStreak() to get current value
    func updateLongestStreak(_ streak: Int)  // Only updates if new record
    func recordGoodNight()

    // MARK: - Settings
    func updateStepGoal(_ goal: Int)
    func toggleSound(_ enabled: Bool)
    func completeOnboarding()
}
```

### 4.3 AudioService

```swift
@Observable
final class AudioService {
    static let shared = AudioService()

    private var audioPlayers: [String: AVAudioPlayer] = [:]

    var isEnabled: Bool = true
    var currentAmbience: AmbienceType = .cozy

    enum AmbienceType {
        case cozy       // Default indoor sounds
        case rain       // When weather is gentleRain
        case purring    // When viewing cat details
    }

    // MARK: - Playback
    func playAmbience(_ type: AmbienceType)
    func stopAmbience()
    func playPurr()  // Short haptic + sound when tapping cat

    // MARK: - Configuration
    func setEnabled(_ enabled: Bool)
}
```

---

## 5. HealthKit Integration

### 5.1 Required Entitlements

```xml
<!-- CozyKitties.entitlements -->
<key>com.apple.developer.healthkit</key>
<true/>
<key>com.apple.developer.healthkit.access</key>
<array/>
<key>com.apple.developer.healthkit.background-delivery</key>
<true/>
```

### 5.2 Info.plist Keys

```xml
<key>NSHealthShareUsageDescription</key>
<string>Cozy Kitties uses your step count to grow your cat colony, sleep data to nurture your indoor plants, and noise levels to set the weather outside your apartment window. Your health data never leaves your device.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>Cozy Kitties does not write any health data.</string>

<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

### 5.3 Data Flow

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  HealthKit  │────▶│HealthKitService │────▶│GameStateService │
│   (Apple)   │     │   (Fetches)      │     │  (Processes)    │
└─────────────┘     └──────────────────┘     └────────┬────────┘
                                                      │
                                                      ▼
                                             ┌─────────────────┐
                                             │   SwiftData     │
                                             │  (Persists)     │
                                             └─────────────────┘
```

### 5.4 Query Strategies

| Data Type | Query Frequency | Strategy |
|-----------|-----------------|----------|
| Steps | On app launch + every 5 min foreground | `HKStatisticsQuery` for daily totals |
| Sleep | On app launch | `HKSampleQuery` for previous night |
| Noise | On app launch | `HKStatisticsQuery` for 24h average |

---

## 6. UI Implementation

### 6.1 Liquid Glass Components

```swift
// View+GlassEffect.swift
extension View {
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial)
            .glassEffect()  // iOS 26 native modifier
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    func glassButton() -> some View {
        self
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .glassEffect()
            .clipShape(Capsule())
    }
}

// GlassCard.swift
struct GlassCard<Content: View>: View {
    let content: Content

    var body: some View {
        content
            .padding()
            .glassCard()
    }
}
```

### 6.2 Main Apartment View Structure

```swift
struct ApartmentView: View {
    @Environment(ApartmentViewModel.self) var viewModel

    var body: some View {
        ZStack {
            // Background - apartment interior
            ApartmentBackgroundView()

            // Window with weather
            WindowView(weather: viewModel.currentWeather)
                .position(x: 200, y: 150)

            // Plants (positioned around apartment)
            ForEach(viewModel.plants) { plant in
                PlantView(plant: plant)
                    .position(plant.position)
            }

            // Cats (animated, positioned)
            ForEach(viewModel.cats) { cat in
                CatView(cat: cat)
                    .position(cat.position)
            }

            // Floating UI elements (Liquid Glass)
            VStack {
                Spacer()
                GlassTabBar(selection: $viewModel.selectedTab)
            }
        }
    }
}
```

### 6.3 Color Palette

```swift
// Color+Theme.swift
extension Color {
    // Warm, cozy palette
    static let cozyBackground = Color("CozyBackground")  // Warm cream
    static let cozyAccent = Color("CozyAccent")          // Soft coral
    static let cozyText = Color("CozyText")              // Warm brown
    static let cozySecondary = Color("CozySecondary")    // Muted sage

    // Weather-influenced
    static let sunnyGlow = Color.yellow.opacity(0.3)
    static let overcastDim = Color.gray.opacity(0.2)
}
```

### 6.4 Design Tokens

```swift
// Design/DesignTokens.swift
import SwiftUI

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let full: CGFloat = 9999
}

enum Typography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
}

enum Shadow {
    static let sm = (color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let md = (color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let lg = (color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
}
```

---

## 7. Gamification Logic

### 7.1 Streak Calculation

```swift
func calculateStreak(stepHistory: [DailySteps], goal: Int) -> Int {
    var streak = 0
    let sortedDays = stepHistory.sorted { $0.date > $1.date }

    // Start from yesterday (today is still in progress)
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

    for day in sortedDays {
        guard Calendar.current.isDate(day.date, inSameDayAs: yesterday.addingDays(-streak)) else {
            continue
        }

        if day.count >= goal {
            streak += 1
        } else {
            break  // Streak broken
        }
    }

    return streak
}
```

### 7.2 Cat Unlock Thresholds

```swift
struct CatDefinition {
    let id: String
    let name: String
    let appearance: String
    let streakRequired: Int
}

let catRoster: [CatDefinition] = [
    CatDefinition(id: "mochi", name: "Mochi", appearance: "cat_white_fluffy", streakRequired: 0),
    CatDefinition(id: "shadow", name: "Shadow", appearance: "cat_black_sleek", streakRequired: 5),
    CatDefinition(id: "marmalade", name: "Marmalade", appearance: "cat_orange_tabby", streakRequired: 10),
    CatDefinition(id: "luna", name: "Luna", appearance: "cat_gray_socks", streakRequired: 15),
    CatDefinition(id: "biscuit", name: "Biscuit", appearance: "cat_cream", streakRequired: 20),
    CatDefinition(id: "pepper", name: "Pepper", appearance: "cat_tuxedo", streakRequired: 25),
    CatDefinition(id: "olive", name: "Olive", appearance: "cat_tortie", streakRequired: 30),
    CatDefinition(id: "cloud", name: "Cloud", appearance: "cat_persian_white", streakRequired: 35),
    CatDefinition(id: "espresso", name: "Espresso", appearance: "cat_brown", streakRequired: 40),
    CatDefinition(id: "captain", name: "Captain", appearance: "cat_calico_eyepatch", streakRequired: 45),
]
```

### 7.3 Plant Growth Logic

```swift
func updatePlantGrowth(goodNights: Int, plants: inout [Plant]) {
    for i in plants.indices {
        let required = plants[i].type.goodNightsToUnlock

        if plants[i].unlockedAt == nil && goodNights >= required {
            plants[i].unlockedAt = Date()
            plants[i].growthStage = 1
        } else if plants[i].unlockedAt != nil {
            // Growth stages based on consecutive good nights after unlock
            let nightsSinceUnlock = goodNights - required
            plants[i].growthStage = min(3, nightsSinceUnlock / 3)
        }
    }
}
```

---

## 8. Fastlane Configuration

### 8.1 Directory Structure

```
fastlane/
├── Appfile
├── Fastfile
├── Deliverfile
├── Matchfile
├── metadata/
│   ├── en-US/
│   │   ├── name.txt
│   │   ├── subtitle.txt
│   │   ├── description.txt
│   │   ├── keywords.txt
│   │   ├── promotional_text.txt
│   │   ├── privacy_url.txt
│   │   ├── support_url.txt
│   │   └── release_notes.txt
│   └── review_information/
│       ├── demo_user.txt
│       ├── demo_password.txt
│       ├── notes.txt
│       └── email_address.txt
├── screenshots/
│   └── en-US/
│       ├── iPhone_6.7/
│       └── iPhone_6.5/
└── Gymfile
```

### 8.2 Key Files

```ruby
# Appfile
app_identifier "com.kathrynstyons.cozykitties"
apple_id "your-apple-id@email.com"
team_id "YOUR_TEAM_ID"
itc_team_id "YOUR_ITC_TEAM_ID"

# Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    build_app(scheme: "CozyKitties")
    upload_to_testflight
  end

  desc "Build and submit to App Store"
  lane :release do
    build_app(scheme: "CozyKitties")
    deliver(
      submit_for_review: true,
      automatic_release: true,
      force: true,
      precheck_include_in_app_purchases: false
    )
  end

  desc "Upload metadata only"
  lane :metadata do
    deliver(
      skip_binary_upload: true,
      skip_screenshots: true,
      force: true
    )
  end

  desc "Upload screenshots only"
  lane :screenshots do
    deliver(
      skip_binary_upload: true,
      skip_metadata: true,
      force: true
    )
  end
end

# Deliverfile
price_tier 0
app_rating_config_path "./fastlane/rating_config.json"
submission_information({
  add_id_info_uses_idfa: false
})
```

### 8.3 Rating Configuration

```json
// fastlane/rating_config.json
{
  "CARTOON_FANTASY_VIOLENCE": 0,
  "REALISTIC_VIOLENCE": 0,
  "PROLONGED_GRAPHIC_SADISTIC_REALISTIC_VIOLENCE": 0,
  "PROFANITY_CRUDE_HUMOR": 0,
  "MATURE_SUGGESTIVE": 0,
  "HORROR": 0,
  "MEDICAL_TREATMENT_INFO": 0,
  "ALCOHOL_TOBACCO_DRUGS": 0,
  "GAMBLING": 0,
  "SEXUAL_CONTENT_NUDITY": 0,
  "GRAPHIC_SEXUAL_CONTENT_NUDITY": 0,
  "UNRESTRICTED_WEB_ACCESS": 0,
  "GAMBLING_CONTESTS": 0
}
```

---

## 9. Bundle ID & App Store Setup

### 9.1 Bundle Identifier
```
com.kathrynstyons.cozykitties
```

### 9.2 Required Capabilities
- HealthKit
- Background Modes (processing)

### 9.3 App Store Categories
- **Primary:** Health & Fitness
- **Secondary:** Lifestyle

---

## 10. Privacy & Data Handling

### 10.1 Data Collection: None

| Category | Collected | Linked to User | Tracking |
|----------|-----------|----------------|----------|
| Health & Fitness | No | No | No |
| Identifiers | No | No | No |
| Usage Data | No | No | No |

### 10.2 App Privacy Policy

All health data is:
- Read-only from HealthKit
- Processed entirely on-device
- Never transmitted to any server
- Never stored outside the app's sandbox

---

## 11. Testing Strategy

### 11.1 Unit Tests
- `GameStateServiceTests`: Streak calculation, unlock logic
- `HealthKitServiceTests`: Mock data parsing
- `PlantGrowthTests`: Growth stage transitions

### 11.2 UI Tests
- Onboarding flow completion
- Tab navigation
- Cat tap interaction

### 11.3 HealthKit Testing
- Use Xcode's Health app on Simulator to add test data
- Test with no HealthKit permissions (graceful degradation)
- Test with partial permissions (some types denied)

---

## 12. Future Considerations

### 12.1 Post-MVP Features Requiring Architecture Changes

| Feature | Required Changes |
|---------|------------------|
| CloudKit Sync | Add `@Attribute(.unique)` to models, implement sync service |
| Widgets | Add Widget extension target, shared App Group |
| Apple Watch | Add Watch extension, refactor HealthKitService for WatchConnectivity |
| iPad | Add iPad-specific layouts, consider multi-column |

### 12.2 Performance Considerations
- Limit cat animations when app is in background
- Lazy load cat/plant images
- Cache HealthKit queries for 5 minutes

---

## 13. CI/CD Pipeline

### 13.1 GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.app

      - name: Build
        run: |
          xcodebuild -scheme CozyKitties \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16' \
            build

      - name: Test
        run: |
          xcodebuild test \
            -scheme CozyKitties \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16'

  deploy-testflight:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    needs: build-and-test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Fastlane
        run: bundle install

      - name: Deploy to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        run: bundle exec fastlane beta
```

---

## 14. Specs Directory (Content Definitions)

Machine-readable YAML files that define game content, enabling separation of content from code and agent-friendly modifications.

### 14.1 Cat Roster

```yaml
# Specs/cats.yaml
cats:
  - id: mochi
    name: Mochi
    appearance: cat_white_fluffy
    streak_required: 0
    description: A fluffy white cloud of a cat

  - id: shadow
    name: Shadow
    appearance: cat_black_sleek
    streak_required: 5
    description: Sleek and mysterious

  - id: marmalade
    name: Marmalade
    appearance: cat_orange_tabby
    streak_required: 10
    description: Warm as a sunny afternoon

  - id: luna
    name: Luna
    appearance: cat_gray_socks
    streak_required: 15
    description: Gray with adorable white socks

  - id: biscuit
    name: Biscuit
    appearance: cat_cream
    streak_required: 20
    description: Cream-colored and always kneading

  - id: pepper
    name: Pepper
    appearance: cat_tuxedo
    streak_required: 25
    description: Formally dressed at all times

  - id: olive
    name: Olive
    appearance: cat_tortie
    streak_required: 30
    description: A beautiful tortoiseshell

  - id: cloud
    name: Cloud
    appearance: cat_persian_white
    streak_required: 35
    description: Fluffy Persian royalty

  - id: espresso
    name: Espresso
    appearance: cat_brown
    streak_required: 40
    description: Dark roast energy

  - id: captain
    name: Captain
    appearance: cat_calico_eyepatch
    streak_required: 45
    description: Calico with a distinguished eyepatch marking
```

### 14.2 Plant Definitions

```yaml
# Specs/plants.yaml
plants:
  - id: pothos
    name: Pothos
    good_nights_required: 3
    growth_stages: [sprout, small, trailing, lush]
    position: {x: 0.15, y: 0.7}

  - id: succulent
    name: Succulent
    good_nights_required: 5
    growth_stages: [single, pair, cluster, garden]
    position: {x: 0.85, y: 0.65}

  - id: monstera
    name: Monstera
    good_nights_required: 7
    growth_stages: [sprout, small_leaf, medium, full]
    position: {x: 0.25, y: 0.5}

  - id: fern
    name: Fern
    good_nights_required: 10
    growth_stages: [sparse, growing, full, lush]
    position: {x: 0.75, y: 0.55}

  - id: flowers
    name: Flowers
    good_nights_required: 14
    growth_stages: [buds, opening, blooming, flourishing]
    position: {x: 0.5, y: 0.6}
```

### 14.3 Loading Specs in Code

```swift
// Services/SpecsLoader.swift
import Foundation
import Yams

struct SpecsLoader {
    static func loadCatRoster() -> [CatDefinition] {
        guard let url = Bundle.main.url(forResource: "cats", withExtension: "yaml"),
              let data = try? Data(contentsOf: url),
              let yaml = try? Yams.load(yaml: String(data: data, encoding: .utf8)!) as? [String: Any],
              let cats = yaml["cats"] as? [[String: Any]] else {
            return []
        }
        // Parse and return CatDefinition array
    }
}
```

---

*End of Technical Design Document*
