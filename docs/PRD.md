# Product Requirements Document
## Cozy Kitties Health Tracker

**Version:** 1.0
**Last Updated:** March 6, 2026
**Author:** Kathryn Styons

---

## 1. Overview

### 1.1 Vision
Cozy Kitties Health Tracker transforms Apple Health data into a cozy apartment-building simulation. Users nurture a virtual sanctuary that evolves based on their real-world wellness habits—growing a cat colony through walking streaks, cultivating indoor plants through quality sleep, and brightening their environment through peaceful surroundings.

### 1.2 Problem Statement
Traditional health tracking apps rely on guilt, notifications, and numerical dashboards that can feel clinical or punishing. Users often abandon these apps when they "break streaks" or see declining metrics, creating a negative feedback loop that discourages long-term engagement.

### 1.3 Solution
A "shame-free" wellness companion where:
- Progress is celebrated through delightful visual changes
- Lack of progress simply results in a quieter, dimmer atmosphere—never punishment
- Health metrics are abstracted into cozy, emotionally resonant metaphors
- Users feel motivated by nurturing virtual companions rather than chasing numbers

---

## 2. Target Audience

### 2.1 Primary Users
- **Age:** 25-45
- **Characteristics:**
  - Interested in wellness but overwhelmed by data-heavy fitness apps
  - Appreciate cozy/cute aesthetics (cottagecore, hygge, lo-fi vibes)
  - Cat lovers or pet enthusiasts
  - Prefer gentle motivation over aggressive gamification
  - Own an iPhone with Apple Health enabled

### 2.2 User Personas

**Persona 1: "Gentle Goal-Setter"**
- Sarah, 32, works from home
- Wants to walk more but hates feeling guilty when she misses days
- Loves her two cats and playing cozy games like Stardew Valley
- Needs: Non-judgmental progress tracking, cute rewards

**Persona 2: "Wellness Curious"**
- Marcus, 28, office worker
- Uses Apple Watch but ignores most health notifications
- Would engage more with health data if it felt less clinical
- Needs: Fun abstraction of health metrics, low-pressure engagement

---

## 3. Core Features (MVP)

### 3.1 The Apartment
The central visual space representing the user's wellness journey.

| State | Description |
|-------|-------------|
| **Starting State** | Sparse "builder-grade" studio apartment—bare walls, minimal furniture, single window |
| **Evolved State** | Lush sanctuary filled with cats, plants, cozy furniture, and warm lighting |

### 3.2 Cat Colony (Steps Mechanic)

**Data Source:** HealthKit Step Count

| Mechanic | Details |
|----------|---------|
| **Streak Tracking** | Track consecutive days meeting step goal |
| **Default Goal** | 5,000 steps/day (user-adjustable) |
| **Cat Unlock** | New cat appears after 5-day streak |
| **Cat Behavior** | Cats lounge, play, and interact in the apartment |
| **Max Cats (MVP)** | 10 unique cats with distinct appearances |

**Shame-Free Design:**
- Breaking a streak does NOT remove cats
- Cats may "nap more" or appear less active during low-activity periods
- Streak counter resets but progress (unlocked cats) persists

### 3.3 Indoor Garden (Sleep Mechanic)

**Data Source:** HealthKit Sleep Analysis

| Mechanic | Details |
|----------|---------|
| **Sleep Quality** | Based on total sleep duration |
| **Plant Growth** | Good sleep = plants grow and flourish |
| **Plant Types** | Pothos, succulents, monstera, ferns, flowers |
| **Visual Feedback** | Plants become more vibrant with consistent good sleep |

**Shame-Free Design:**
- Poor sleep = plants remain static (don't wilt or die)
- Extended poor sleep = plants appear "dormant" but don't disappear
- Recovery is immediate—good night's sleep = instant visual improvement

### 3.4 Window Weather (Environment Mechanic)

**Data Source:** HealthKit Environmental Audio Levels

| Mechanic | Details |
|----------|---------|
| **Noise Tracking** | Ambient noise levels from Apple Watch |
| **Weather States** | Sunny, partly cloudy, overcast, gentle rain |
| **Quiet = Sunny** | Low noise exposure = bright, sunny view |
| **Loud = Overcast** | High noise exposure = cloudier, dimmer view |

**Shame-Free Design:**
- Even "bad weather" is cozy (rain on windows, soft lighting)
- No storms or harsh weather—just variations of peaceful ambiance
- Weather transitions smoothly, never jarring

### 3.5 Apartment Customization (Future/Stretch)

| Feature | MVP Status |
|---------|------------|
| Furniture placement | Post-MVP |
| Color themes | Post-MVP |
| Seasonal decorations | Post-MVP |
| Multiple rooms | Post-MVP |

---

## 4. User Experience

### 4.1 First Launch / Onboarding

1. **Welcome Screen** - App introduction with cozy visuals
2. **HealthKit Permission** - Explain what data we access and why
3. **Goal Setting** - Set daily step goal (default: 5,000)
4. **Retroactive Rewards** - Scan up to 90 days of HealthKit history; grant any cats the user has already earned based on past walking streaks. Display: "Your past walks have already earned you [X] cats!"
5. **Meet Your Apartment** - Tour the starting space with pre-earned cats already present
6. **Starter Cat** - If no cats were earned retroactively, grant Mochi as starter cat

### 4.2 Daily Usage Pattern

```
User opens app
    ↓
Sees current apartment state (cats, plants, weather)
    ↓
Ambient animations play (cats moving, plants swaying)
    ↓
Optional: Tap elements for details (cat names, streak info)
    ↓
Optional: Check progress toward next unlock
    ↓
Close app feeling cozy
```

**Expected Session Length:** 30 seconds - 2 minutes
**Expected Frequency:** 1-3 times daily

### 4.3 Key Screens

| Screen | Purpose |
|--------|---------|
| **Apartment View** | Main screen—immersive view of apartment |
| **Cat Collection** | Gallery of all unlocked cats with names |
| **Progress View** | Current streaks, sleep stats, next unlocks |
| **Settings** | Step goal, notifications, HealthKit permissions |

---

## 5. Design Principles

### 5.1 Shame-Free Philosophy
- **Never punish:** No loss of progress, no guilt messaging
- **Always recoverable:** Any "bad" state can improve immediately
- **Gentle feedback:** Visual dimming, not alarming indicators
- **Celebrate consistency:** Streaks matter, but breaking them isn't catastrophic

### 5.2 Visual Design: Liquid Glass
- Leverage iOS 26 Liquid Glass design language
- Translucent, glassy UI elements that feel premium
- Floating controls that don't obstruct the apartment view
- Subtle depth and blur effects
- Warm, cozy color palette beneath the glass

### 5.3 Interaction Design
- **Minimal interaction required:** App is primarily observational
- **Delightful details:** Tap cats for purring haptics, tap plants for growth info
- **No notifications by default:** Opt-in for gentle daily reminders
- **No social features:** Private, personal sanctuary

---

## 6. Technical Requirements

### 6.1 Platform
- **iOS 26+** (required for Liquid Glass)
- **iPhone only** (MVP)
- iPad and Apple Watch: Post-MVP

### 6.2 HealthKit Data Access

| Data Type | Permission | Purpose |
|-----------|------------|---------|
| Step Count | Read | Cat colony mechanic |
| Sleep Analysis | Read | Plant growth mechanic |
| Environmental Audio | Read | Weather mechanic |

### 6.3 Data Storage
- **Local only:** SwiftData for persistence
- **No backend:** All data stays on device
- **No accounts:** No sign-up required

### 6.4 Privacy
- Zero data collection
- Zero analytics (MVP)
- Zero network calls
- Full offline functionality

---

## 7. MVP Scope

### 7.1 Included in MVP
- [x] Single apartment view with ambient animations
- [x] 10 unlockable cats via step streaks
- [x] 5 plant types responding to sleep data
- [x] 4 weather states responding to noise data
- [x] Basic onboarding flow
- [x] Cat collection gallery
- [x] Simple progress/stats view
- [x] Settings (step goal, sound toggle)
- [x] Liquid Glass UI throughout
- [x] Optional ambient sounds (purring, rain, cozy atmosphere)

### 7.2 Excluded from MVP (Future Versions)
- [ ] Multiple rooms / apartment expansion
- [ ] Furniture customization
- [ ] Seasonal events / decorations
- [ ] Cat accessories / outfits
- [ ] Additional health metrics (heart rate, workouts, etc.)
- [ ] Apple Watch companion app
- [ ] iPad optimization
- [ ] Widgets
- [ ] Siri Shortcuts
- [ ] CloudKit sync across devices

---

## 8. Success Metrics

### 8.1 Engagement (Post-Launch Tracking)
| Metric | Target |
|--------|--------|
| D1 Retention | > 40% |
| D7 Retention | > 25% |
| Avg. Sessions/Day | > 1.5 |
| Avg. Session Length | 30-90 seconds |

### 8.2 App Store
| Metric | Target |
|--------|--------|
| Rating | > 4.5 stars |
| Reviews mentioning "cozy" or "cute" | > 30% |

### 8.3 Health Outcomes (Qualitative)
- Users report feeling motivated without guilt
- Users maintain walking habits longer than with other apps

---

## 9. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| HealthKit permission denied | Medium | High | Graceful degradation—show demo mode with simulated data |
| Environmental audio unavailable (no Watch) | Medium | Low | Weather defaults to "partly sunny," feature is optional |
| Low engagement after initial novelty | Medium | Medium | Plan regular content updates (new cats, plants) |
| App rejection for minimal functionality | Low | High | Ensure robust HealthKit integration and unique value proposition |

---

## 10. Timeline

| Milestone | Target |
|-----------|--------|
| PRD Complete | Day 1 |
| Technical Design Complete | Day 1 |
| Xcode Project + Fastlane Setup | Day 1 |
| Core Implementation | Day 1-2 |
| App Store Submission | Day 2 |
| Expected Review Completion | Day 3-5 |

---

## 11. Resolved Decisions

1. **Cat naming:** Cats come pre-named (see Appendix A) - simpler for MVP
2. **Sound:** Optional ambient sounds (purring, rain) - toggle in settings
3. **Notifications:** Include opt-in daily reminder - decision pending
4. **Streak forgiveness:** Uniform daily goals for MVP - consider post-MVP
5. **Retroactive rewards:** On first launch, scan 90 days of HealthKit history and grant any earned cats immediately - creates "magic moment"
6. **Streak as derived value:** Current streak is calculated from HealthKit on each app launch, not stored - ensures data consistency

---

## Appendix A: Cat Roster (MVP)

| # | Cat Name | Appearance | Unlock Condition |
|---|----------|------------|------------------|
| 1 | Mochi | White fluffy | Starter cat (free) |
| 2 | Shadow | Black sleek | 5-day streak |
| 3 | Marmalade | Orange tabby | 10-day streak |
| 4 | Luna | Gray with white socks | 15-day streak |
| 5 | Biscuit | Cream colored | 20-day streak |
| 6 | Pepper | Tuxedo | 25-day streak |
| 7 | Olive | Tortoiseshell | 30-day streak |
| 8 | Cloud | White Persian | 35-day streak |
| 9 | Espresso | Dark brown | 40-day streak |
| 10 | Captain | Calico with eyepatch marking | 45-day streak |

---

## Appendix B: Plant Types (MVP)

| Plant | Growth Trigger | Visual States |
|-------|----------------|---------------|
| Pothos | 3 good nights | Small → Trailing vines |
| Succulent | 5 good nights | Single → Cluster |
| Monstera | 7 good nights | Sprout → Full leaves |
| Fern | 10 good nights | Sparse → Lush |
| Flowers | 14 good nights | Buds → Blooming |

"Good night" = 7+ hours of sleep recorded

---

*End of PRD*
