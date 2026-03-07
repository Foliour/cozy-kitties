# Agentic Development Plan
## Cozy Kitties Health Tracker

**Created:** March 6, 2026
**Status:** Active
**Approach:** Lights-out factory-style development with Council reviews

---

## 1. Philosophy

### 1.1 Core Principles
- **Minimal human intervention**: User should only authenticate and approve
- **Self-correcting**: Find and fix problems autonomously
- **Quality gates**: Council reviews at checkpoints before proceeding
- **Context management**: Use sub-agents to prevent context overflow
- **Not over-engineered**: Simple, working code over clever abstractions

### 1.2 Success Criteria
- [ ] App runs in simulator
- [ ] All tests pass
- [ ] Council approves final review
- [ ] Fastlane configured and ready for submission
- [ ] User can authenticate and push with one command

---

## 2. Tooling Decisions

### 2.1 Project Generation: Manual Xcode Project
**Why**: Council Review #1 determined XcodeGen adds unnecessary complexity for a single-target app. Creating the project manually is simpler and has fewer dependencies.

**Approach**: Create project structure manually, then use `xcodebuild` for building. Alternatively, use a minimal Bash script to create the .xcodeproj structure.

**Asset Strategy**: Use SF Symbols as placeholders for cats and plants. This ships MVP fast and can be replaced with custom art later.
- Cats: `cat.fill` with different colors
- Plants: `leaf.fill`, `camera.macro`, `leaf.circle.fill` variants
- Weather: `sun.max.fill`, `cloud.fill`, `cloud.rain.fill`

### 2.2 Simulator Verification: idb (iOS Development Bridge)
**Why**: Per project guidelines, NEVER use screenshots. Use `idb ui describe-all` to read the accessibility tree.

```bash
# Get UI state
idb ui describe-all --udid $UDID

# Interact
idb ui tap X Y --udid $UDID
```

### 2.3 Testing: XCTest with Protocol Mocking
**Why**: HealthKit can't run in simulator without real data. Use protocol abstraction + MockHealthStore for unit tests.

**Source**: [Advanced HealthKit Testing](https://medium.com/@azharanwar/advanced-unit-testing-in-swift-protocols-dependency-injection-and-healthkit-4795ef4f33ec)

```swift
protocol HealthKitServiceProtocol {
    func fetchSteps(for date: Date) async throws -> Int
}

class MockHealthKitService: HealthKitServiceProtocol {
    var stepsToReturn: Int = 5000
    func fetchSteps(for date: Date) async throws -> Int {
        return stepsToReturn
    }
}
```

### 2.4 Liquid Glass: iOS 26 Native API
**Source**: [Liquid Glass Reference](https://github.com/conorluddy/LiquidGlassReference)

```swift
// Basic glass effect
view.glassEffect()

// Interactive glass
view.glassEffect().interactive()

// Glass container for morphing
GlassEffectContainer {
    // content
}
```

---

## 3. Sub-Agent Strategy

### 3.1 Agent Types & Responsibilities

| Agent Type | Purpose | When to Use |
|------------|---------|-------------|
| **Explore** | Codebase understanding, file finding | Before implementation |
| **Bash** | Git, xcodebuild, xcodegen, fastlane | Build/test operations |
| **General-purpose** | Implementation tasks | Writing code |
| **Plan** | Architecture decisions | Before major changes |

### 3.2 Context Management Rules
1. **Spawn sub-agent** when task is self-contained and > 3 files
2. **Stay in main context** for orchestration and reviews
3. **Clear context** by summarizing to docs, not re-reading files
4. **Parallel agents** when tasks are independent

### 3.3 Agent Task Patterns

```yaml
# Pattern: Implementation Task
- spawn: general-purpose
  prompt: |
    Implement [FEATURE] following Specs/[spec].yaml
    Files to create: [list]
    Acceptance criteria: [from tasks.yaml]
    Write tests in CozyKittiesTests/

# Pattern: Build & Verify
- spawn: Bash
  prompt: |
    Build project: xcodebuild -scheme CozyKitties ...
    Run tests: xcodebuild test ...
    Report: pass/fail with errors
```

---

## 4. Council of LLMs

### 4.1 Council Members (Reusable)

| Name | Role | Focus |
|------|------|-------|
| **Priya** | Product Lead | User value, simplicity, not over-engineered |
| **Marcus** | Systems Engineer | Architecture, edge cases, data flow |
| **Sasha** | Front-End Architect | UI patterns, maintainability, design system |
| **Dev** | Agentic Engineer | Automation, test coverage, CI/CD |

### 4.2 Review Checkpoints

| Checkpoint | Trigger | Focus |
|------------|---------|-------|
| **Pre-Implementation** | After plan finalized | Architecture sanity check |
| **Post-Core** | After services done | Data flow, testability |
| **Post-UI** | After views done | UX, design consistency |
| **Pre-Submission** | Before fastlane | Final quality gate |

### 4.3 Review Process
1. Summarize current state and decisions
2. Each council member reviews from their perspective
3. Collect feedback and prioritize
4. Address blocking issues before proceeding
5. Document decisions in `docs/COUNCIL_LOG.md`

---

## 5. Execution Phases

### Phase 0: Environment Verification
**Agents**: Bash
**Tasks**:
- [ ] Verify Xcode installed and version
- [ ] Verify iOS 26 SDK available
- [ ] Verify simulator available (iPhone 16 or similar)
- [ ] Check if idb installed (optional, fall back to simctl)
- [ ] Verify fastlane installed
- [ ] Initialize git repository

**Quality Gate**: All tools available, git initialized

### Phase 1: Project Setup
**Agents**: Bash
**Tasks**:
- [ ] Install XcodeGen (if needed)
- [ ] Create project.yml
- [ ] Generate .xcodeproj
- [ ] Create entitlements file
- [ ] Create Info.plist
- [ ] Verify build succeeds

**Quality Gate**: Project compiles with `xcodebuild`

### Phase 2: Core Services
**Agents**: General-purpose (parallel)
**Tasks**:
- [ ] DesignTokens.swift
- [ ] HealthKitServiceProtocol + HealthKitService
- [ ] GameStateService
- [ ] AudioService
- [ ] SwiftData models

**Quality Gate**: Unit tests pass

### Phase 3: UI Implementation
**Agents**: General-purpose
**Tasks**:
- [ ] ApartmentView + subviews
- [ ] CatCollectionView
- [ ] ProgressView
- [ ] SettingsView
- [ ] OnboardingFlow
- [ ] GlassEffect components

**Quality Gate**: App launches in simulator, UI elements visible via idb

### Phase 4: Integration & Polish
**Agents**: General-purpose + Bash
**Tasks**:
- [ ] Connect services to views
- [ ] Implement retroactive rewards
- [ ] Add ambient sounds
- [ ] UI tests
- [ ] Bug fixes from Council review

**Quality Gate**: Full flow works in simulator

### Phase 5: App Store Prep
**Agents**: Bash + General-purpose
**Tasks**:
- [ ] Configure fastlane metadata
- [ ] Create app icon (placeholder or generated)
- [ ] Write privacy policy
- [ ] Configure Appfile with real credentials
- [ ] Dry-run fastlane

**Quality Gate**: `fastlane release --dry-run` succeeds

---

## 6. Testing Strategy

### 6.1 Test Categories

| Category | Location | Runner | Coverage Target |
|----------|----------|--------|-----------------|
| Unit Tests | CozyKittiesTests/ | xcodebuild test | Services, ViewModels |
| UI Tests | CozyKittiesUITests/ | xcodebuild test | Onboarding, navigation |
| Simulator Verify | Manual via idb | idb ui describe-all | Visual presence |

### 6.2 Mock Strategy

```swift
// MockHealthKitService
var mockSteps: [Date: Int] = [:]
var mockSleep: [Date: Int] = [:]  // minutes
var mockNoise: Double = 55.0

// MockGameState
var mockUnlockedCatIDs: [String] = ["mochi"]
var mockPlants: [Plant] = []
```

### 6.3 Test Execution

```bash
# Run all tests
xcodebuild test \
  -scheme CozyKitties \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test
xcodebuild test \
  -scheme CozyKitties \
  -only-testing:CozyKittiesTests/GameStateServiceTests
```

---

## 7. Simulator Verification Protocol

### 7.1 Verification Steps
```bash
# 1. Boot simulator
xcrun simctl boot "iPhone 16"

# 2. Install app
xcrun simctl install booted /path/to/CozyKitties.app

# 3. Launch app
xcrun simctl launch booted com.kathrynstyons.cozykitties

# 4. Read UI state
idb ui describe-all --udid $UDID

# 5. Verify elements exist
idb ui describe-all --udid $UDID | grep -i "ApartmentView\|Mochi\|glass"
```

### 7.2 Expected UI Elements (Post-Launch)
- ApartmentView (main container)
- WindowView (weather display)
- At least one CatView (Mochi starter)
- GlassTabBar (bottom navigation)

---

## 8. Error Recovery

### 8.1 Build Failures
1. Read full error output
2. Identify root cause (syntax, import, dependency)
3. Fix in source file
4. Rebuild and verify

### 8.2 Test Failures
1. Run failing test in isolation
2. Check test setup (mocks configured?)
3. Check assertion logic
4. Fix either test or implementation
5. Re-run full suite

### 8.3 Simulator Issues
1. Check simulator is booted: `xcrun simctl list devices booted`
2. Check app installed: `xcrun simctl listapps booted`
3. Check idb connected: `idb list-targets`
4. Retry with fresh boot if needed

---

## 9. Documentation Outputs

| Document | Purpose | Updated When |
|----------|---------|--------------|
| `docs/AGENTIC_PLAN.md` | This document | Major process changes |
| `docs/COUNCIL_LOG.md` | Council review history | After each review |
| `docs/BUILD_LOG.md` | Build/test results | After each phase |
| `Specs/tasks.yaml` | Task status tracking | Task completion |

---

## 10. Handoff Checklist

Before asking user to authenticate:
- [ ] App builds without warnings
- [ ] All tests pass
- [ ] App runs in simulator (verified via idb)
- [ ] Onboarding flow completes
- [ ] At least one cat visible in apartment
- [ ] Glass effects rendering
- [ ] Fastlane metadata complete
- [ ] Privacy policy URL ready
- [ ] Council final review passed
- [ ] User can run `fastlane beta` after auth

---

*This plan will be reviewed by the Council before execution begins.*
