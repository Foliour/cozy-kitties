# Cozy Kitties Design System

> **Status:** Target design spec. The current codebase uses system defaults and must be migrated to this system. See [Migration Checklist](#migration-checklist) at the bottom.

## Overview

Cozy Kitties uses a warm, Liquid Glass-inspired design language with translucent surfaces, soft gradients, and accent-driven highlights. All design tokens are defined in `CozyKitties/Design/DesignTokens.swift` and applied through reusable SwiftUI view modifiers and components. **No view file should define its own colors, shadows, or corner radii inline.**

**Appearance:** Supports both light and dark mode. All colors are defined as **asset catalog color sets** with light and dark variants. Light mode uses a warm orange palette; dark mode uses a complementary purple palette. Do not use SwiftUI semantic colors (`.primary`, `.secondary`) — use `CozyColors` tokens instead.

**Minimum deployment target:** iOS 26

**Swift version:** Swift 6.2 with strict concurrency enabled. UI code runs on `@MainActor` by default (approachable concurrency). Use `@concurrent` for explicit background work (e.g., HealthKit queries). All `@Observable` classes should be `@MainActor`-isolated unless they specifically need background execution.

**Testing:** Use Swift Testing (`@Test`, `#expect`, `@Suite`) for all new tests. XCTest is only needed for UI tests.

**Persistence:** SwiftData with `@Model` (already adopted — `GameState` uses `@Model`).

---

## Color Palette

All colors are defined as **named color sets** in the asset catalog (`CozyKitties/Assets.xcassets`). Each color set contains a light and dark variant. `CozyColors` provides typed static accessors that reference these asset catalog names.

This approach lets SwiftUI automatically select the correct variant based on the user's appearance setting, and gives us dark mode support for free whenever we're ready. The dark theme uses a **purple palette** to complement the warm orange light theme.

### Primary Accents

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `accent` | `#FF7B3D` Vibrant Orange | `#9D7BFF` Glowing Purple | Primary buttons, active tabs, progress bars, floating hearts, glowing UI elements |
| `accentSecondary` | `#FF9A56` Soft Orange | `#C4B5FD` Soft Lavender | Gradients paired with primary accent |

### Backgrounds

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `backgroundStart` | `#F5F1EB` Warm Cream | `#1E1826` Deep Midnight Purple | Top of screen gradient |
| `backgroundEnd` | `#EDE5DB` Darker Cream | `#14101B` Almost Black | Bottom of screen gradient |

### Cards & Surfaces

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `cardSurface` | `#FFFFFF` White | `#2D243F` Deep Muted Purple | Card fill (see Card Styles for opacity) |
| `surfaceBorder` | `#FFFFFF` White | `#3D3055` Muted Purple | Card/container edges (see Card Styles for opacity) |
| `recessedFill` | `#E8DFD5` Warm Tan | `#3B334C` Muted Grey-Purple | Inactive buttons, progress bar tracks, locked cat backgrounds |

### Typography

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `textPrimary` | `#3D2F24` Dark Brown | `#F3E8FF` Light Purple | Main headings, titles, cat names |
| `textSecondary` | `#8B7355` Muted Brown | `#A78BFA` Muted Purple | Subtitles, hints, inactive icons, labels |
| `textOnColor` | `#FFFFFF` White | `#FFFFFF` White | Text on accent-colored backgrounds |

### System & Utility

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `toggleInactive` | `#F5F1EB` Warm Off-White | `#1E1B2E` Deep Purple | Settings toggle inactive background |
| `destructive` | `#E53E3E` Red | `#E53E3E` Red | Reset/delete actions, error states |

**Accessibility note:** `accent` (#FF7B3D) on `backgroundStart` (#F5F1EB) yields ~3.2:1 contrast. This passes WCAG AA for large text (18pt+ bold or 24pt+ regular) but **fails for body/caption text**. Only use `accent` color for `statLarge`, `statMedium`, `title`-weight text, and icons. Never use it for `caption` or `body` text on background colors.

**Card style:** Cards use iOS 26 Liquid Glass (`.glassEffect()`), tinted with `cardSurface` at 70-80% opacity and bordered with `surfaceBorder` at 60% opacity. This replaces the earlier opaque white + orange border design.

---

## Typography

System default sans-serif (SF Pro). **No `.rounded` design** — use `.default` or omit the design parameter. Hierarchy through size and weight only:

| Token | Size | Weight | Default Color | Usage |
|-------|------|--------|---------------|-------|
| `largeTitle` | 34 | Bold | `textPrimary` | Page titles ("Settings", "Collection") |
| `title` | 28 | Semibold | `textPrimary` | Section headers |
| `headline` | 17 | Semibold | `textPrimary` | Card titles, cat names |
| `body` | 17 | Regular | `textPrimary` | Body copy, descriptions, onboarding text |
| `caption` | 12 | Regular | `textSecondary` | Labels, footnotes, secondary info |
| `statLarge` | 40 | Bold | `accent` | Hero numbers (total step counts) |
| `statMedium` | 22 | Bold | `accent` | Secondary numbers (today's steps, percentages) |

The "Default Color" column is the typical pairing. Views may override the color when context demands it (e.g., `headline` text inside an AccentBlock uses `textOnColor` instead of `textPrimary`).

**Color rules summary:**
- Headers, names, titles, body copy: `textPrimary` (dark brown)
- Labels, captions, secondary info: `textSecondary` (medium brown)
- Hero numbers and stat highlights: `accent` (orange) — only at `statLarge` or `statMedium` sizes
- Text on orange/accent backgrounds: `textOnColor` (white)
- Destructive actions: `destructive` (red)

---

## Elevation (3-Tier Shadow System)

| Token | Usage | Implementation |
|-------|-------|----------------|
| `recessed` | Empty cat slots, progress bar tracks | Background `recessedFill`, no shadow. |
| `elevated` | Cards, setting panels, cat cards | `shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)` |
| `floating` | Pill nav bar, toast notifications | `shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)` |

**Note:** These shadow opacities are intentionally softer than the current `Shadow.sm/md/lg` values (which use 0.10/0.15/0.20). Verify visually during migration.

**Rules:**
- Every interactive card uses `elevated`
- Only the nav bar and toasts use `floating`
- Recessed elements use `recessedFill` background color with no outer shadow
- **Do not nest shadows.** AccentBlock uses `elevated` only when standalone (e.g., "Today" badge). When inside another elevated container (e.g., nav bar selected pill), AccentBlock uses **no shadow**. This is controlled via `.accentBlock(elevated: true/false)` parameter.

---

## Card Styles

### CozyCard (Primary) — implemented as `.cozyCard()` ViewModifier

The default card used across the app. Uses Liquid Glass for a translucent, depth-aware surface.

```
Background: .glassEffect() — Liquid Glass material
  Tint: cardSurface at 70-80% opacity (lets background gradient show through)
Border: surfaceBorder at 60% opacity (subtle edge definition)
Corner radius: Radius.lg (20pt)
Shadow: CozyElevation.elevated
Padding: Spacing.md (16pt) internal
```

**Liquid Glass note:** Cards must be inside a `GlassEffectContainer` (placed at the root of each tab's view hierarchy). The glass material automatically adapts its tint, blur, and refraction to the background content beneath it. In light mode, cards appear as frosted white; in dark mode, as frosted deep purple.

**Used for:** Settings panels, cat collection cards, progress sections, any content block.

**Press state:** Only on tappable cards (e.g., unlocked cat cards). On tap-down, scale to 0.98 with `.easeIn(duration: 0.15)`. Release springs back with `.spring(response: 0.3, dampingFraction: 0.7)`. Non-interactive cards (e.g., locked cat cards, info-only settings panels) do not animate.

### AccentBlock — implemented as `.accentBlock(elevated:)` ViewModifier

Accent-colored background with rounded corners. Used for highlighted stats and selected states. Uses the accent color (orange in light mode, purple in dark mode).

```
Background: accent gradient (accent → accentSecondary)
Corner radius: Radius.lg (20pt)
Text color: textOnColor (white)
Shadow: CozyElevation.elevated when elevated=true (default); none when elevated=false
Padding: Spacing.sm (8pt) when inline/nested (nav pill, segmented picker); Spacing.md (16pt) when standalone (Today badge)
```

**Used for:**
- "Today" step badge — `.accentBlock(elevated: true)` (standalone)
- Selected time-of-day option — `.accentBlock(elevated: false)` (nested in CozyCard)
- Nav bar selected pill — `.accentBlock(elevated: false)` (nested in floating nav bar)

---

## Navigation

### Tab Bar (Pill Nav Bar)

Three tabs: **Home**, **Collection**, **Settings**. Custom pill-shaped tab bar replacing the system `TabView`.

```
Background: .glassEffect() — Liquid Glass material (same as CozyCard but with floating elevation)
Shadow: CozyElevation.floating
Corner radius: Radius.xl (28pt)
Horizontal padding: Spacing.lg (24pt)
Height: ~70pt
Position: Bottom of screen, inside safe area
```

**Safe area:** Use `.safeAreaInset(edge: .bottom)` on the content view so scrollable content is never hidden behind the nav bar. ApartmentView must read the safe area inset via `GeometryReader` and adjust its pan bounds accordingly (subtract nav bar height from the bottom of the pannable region).

**Tab items:**
- Icons: `house.fill`, `pawprint.fill`, `gearshape.fill`
- Labels: "Home", "Collection", "Settings"
- **Unselected:** Icon + label in `textSecondary` (medium brown)
- **Selected:** Rounded accent pill (accent gradient, `Radius.lg`) with white icon + label (`textOnColor`). No shadow on the selected pill (it's nested inside the floating nav bar).
- **Tab switch animation:** Selected pill background animates with `.spring(response: 0.3, dampingFraction: 0.8)`. Content view switches with `withAnimation(.easeInOut(duration: 0.15))` on the `selectedTab` change — only the new tab view is in the hierarchy (no simultaneous rendering).

**Tab structure:**
| Tab | View | NavigationStack? | Content |
|-----|------|-------------------|---------|
| Home | ApartmentView | No | Interactive cat scene (full-bleed, no drill-down) |
| Collection | CollectionView | Yes | Progress summary + cat catalog. NavigationStack for cat detail sheet. |
| Settings | SettingsView | Yes | App configuration. NavigationStack for potential sub-pages. |

**Implementation note:** The PillNavBar manages a `@Binding var selectedTab: Int`. The parent view (ContentView) switches the displayed view based on this binding. Navigation bar titles are hidden (`.toolbar(.hidden, for: .navigationBar)`) — page titles are rendered as `largeTitle` text inside the scroll content.

---

## View-Specific Layouts

### Collection View (merged Progress + Cat Catalog)

Single `ScrollView` containing a `VStack`. The progress card scrolls with the content (not pinned).

**Top section:** Progress summary CozyCard showing:
- "Your Progress" header with trend icon in `textSecondary`
- Total steps as `statLarge` in `accent` orange
- "total steps walked" label in `textSecondary`
- "Today" AccentBlock badge (standalone, `.accentBlock(elevated: true)`) showing today's steps in `statMedium` / `textOnColor`
- Next cat row: `HStack` with "Next: [CatName]" in `headline` / `textPrimary` + cat emoji on the left, progress percentage in `accent` `statMedium` on the right
- CozyProgressBar showing progress toward next cat (full width below the next cat row)
- "[N] more steps!" motivational text in `caption` / `textSecondary`, left-aligned below the bar

**Below:** **2-column** `LazyVGrid` of cat cards (intentional change from current 3-column to give cards more room for the CozyCard border treatment).

**Cat card states:**
- **Unlocked:** CozyCard with cat thumbnail (sprite frame cropped to 48x48, displayed at 80x80pt with `.scaledToFit`, `.interpolation(.none)` for pixel art), cat name in `headline` / `textPrimary`, step count earned in `caption` / `accent`
- **Locked:** CozyCard with placeholder icon (`cat.fill` SF Symbol at 44pt, `textSecondary` at 0.4 opacity, centered in same 80x80pt frame as unlocked thumbnail), lock icon + step requirement in `caption` / `textSecondary`. Card uses same glass treatment (not dimmed).

**Data refresh:** The CollectionView uses `.task` and `.onAppear` to load progress data (replacing the old `@Binding var selectedTab` pattern from ProgressDashboardView).

### Settings View

`ScrollView` with `VStack` (not a `List` — this allows CozyCard styling). Sections:
- **Activity:** Daily step goal with custom slider (accent orange fill, recessed track)
- **Appearance:** Custom segmented picker (3 tappable blocks in a row; selected = `.accentBlock(elevated: false)`, unselected = `recessedFill` background with `textSecondary` text)
- **Health Data:** HealthKit connection button
- **About:** Version, cats collected, privacy
- **Data:** Reset game (uses `destructive` color)

Each section has a `SectionHeader`: emoji + uppercase label in `textSecondary` using `caption` weight with `tracking(1.5)` letter spacing.

**Debug section** (#if DEBUG): Exempt from design system — uses system defaults for rapid iteration.

### Apartment View (Home)

Full-bleed interactive scene. No cards. Background is the scene image, not the app gradient. The PillNavBar floats above via `safeAreaInset`.

---

## Progress Bar Style (CozyProgressBar)

```
Track: recessedFill background, Radius.full corner radius, height 10pt
Fill: accent (orange), same corner radius
Animation: .spring(response: 0.4, dampingFraction: 0.8) on width change
```

No thumb/circle indicator for v1 — clean bar only. Thumb can be added as a future enhancement.

---

## Spacing Scale

| Token | Value |
|-------|-------|
| `xs` | 4pt |
| `sm` | 8pt |
| `md` | 16pt |
| `lg` | 24pt |
| `xl` | 32pt |
| `xxl` | 48pt |

---

## Corner Radius Scale

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 8pt | Small buttons, badges |
| `md` | 12pt | Inner elements |
| `lg` | 20pt | Cards, panels, AccentBlock |
| `xl` | 28pt | Nav bar outer container |
| `full` | 9999pt | Pills, progress bars, circular elements |

---

## Patterns Not Yet Specified (Future Work)

These patterns exist in the app but are not part of the initial design system buildout:
- **Loading/empty states** — Currently uses system `ProgressView`
- **Sheet/modal presentation** — `CatDetailSheet` uses default sheet styling
- **Cat unlock celebration** — Confetti overlay, gradient button
- **Onboarding flow** — 3-page walkthrough
- **Alert/confirmation dialogs** — System alerts for destructive actions

Toast notifications already have their elevation defined (`floating`) and should use `CozyColors` for text. The toast content layout can be refined later.

These should all adopt `CozyColors` and `CozyTypography` for text and backgrounds but do not need dedicated components yet.

---

## Implementation Architecture

### Token Namespace

All tokens live in `CozyKitties/Design/DesignTokens.swift`. Use flat prefixed enums (not a nested struct) to minimize migration churn:

```swift
enum CozyColors {
    static let accent = Color("accent")
    static let textPrimary = Color("textPrimary")
    // ... each references a named color set in Colors.xcassets
}
enum CozyTypography {
    static let headline = Font.system(size: 17, weight: .semibold)
    static let statLarge = Font.system(size: 40, weight: .bold)
    static let statMedium = Font.system(size: 22, weight: .bold)
    // ...
}
enum CozyElevation {
    static let elevated = ShadowStyle(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    static let floating = ShadowStyle(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
}
// Spacing and Radius enums keep their current names (already short and clear)
```

**Rationale:** The current codebase uses `Spacing.md`, `Radius.lg`, etc. These names are already clear and don't conflict with SwiftUI types. Renaming them adds churn with no benefit. New enums (`CozyColors`, `CozyTypography`, `CozyElevation`) are added for tokens that don't exist yet.

### Component Files

```
CozyKitties/Design/
  DesignTokens.swift       -- All tokens (colors, typography, elevation, spacing, radius)
  Components/
    CozyCard.swift          -- .cozyCard() ViewModifier
    AccentBlock.swift       -- .accentBlock(elevated:) ViewModifier
    PillNavBar.swift        -- Custom floating tab bar View
    CozyProgressBar.swift   -- Orange progress bar with recessed track
    SectionHeader.swift     -- Emoji + uppercase section label
```

### Key Rules
1. **Single source of truth:** Change a color/radius/shadow in `DesignTokens.swift` and it updates everywhere.
2. **No inline design values:** Views never hardcode colors, shadows, or radii. Always reference token enums.
3. **Compose with components:** Use `.cozyCard()`, `.accentBlock()`, `CozyProgressBar`, and `SectionHeader` instead of building ad-hoc styled containers.
4. **iOS 26+ / Liquid Glass:** Use `.glassEffect()` for cards and nav bar. Wrap each tab's view hierarchy in a `GlassEffectContainer`.
5. **Light + Dark mode:** Colors are asset catalog color sets with distinct light (warm orange) and dark (purple) variants. Both modes are fully supported.
6. **Swift 6.2 strict concurrency:** All `@Observable` service classes are `@MainActor`. Use `@concurrent` only for explicit background work. No `DispatchQueue` calls — use structured concurrency (`async/await`, `Task`).
7. **Swift Testing:** New tests use `@Test`/`#expect`/`@Suite`. XCTest only for UI tests.

---

## Migration Checklist

Files that need changes to adopt this design system:

| File | Changes Needed |
|------|----------------|
| `Project settings` | Change deployment target to iOS 26. Enable Swift 6.2 language mode with strict concurrency. |
| `Colors.xcassets` | Create `CozyKitties/Assets.xcassets` with a named color set for each token (accent, accentSecondary, textPrimary, textSecondary, etc.). Each set has distinct light + dark variants per the Color Palette tables above. |
| `DesignTokens.swift` | Add `CozyColors` enum with static `Color("name")` accessors for each asset catalog color. Rename `Typography` to `CozyTypography` (drop `.rounded`, add `statLarge`/`statMedium`), add `CozyElevation`. Remove old `Shadow` enum (replaced by `CozyElevation`). **Keep** `ShadowStyle` struct and `View.shadow(_:)` extension (used by `CozyElevation`). Keep `Spacing`/`Radius` names. Remove `Color(hex:)` initializer (no longer needed). |
| `CozyKittiesApp.swift` | Remove `UITabBarAppearance` configuration. Remove `.preferredColorScheme(.light)` (both modes now supported). Add `GlassEffectContainer` if needed at root level. |
| `ContentView.swift` | Replace system `TabView` with `PillNavBar`. Reduce to 3 tabs (merge Cats+Progress). Remove tab bar styling. Wrap tab content in `GlassEffectContainer`. |
| `ProgressDashboardView.swift` | Fold into new `CollectionView.swift`. Delete `GlassCard` struct definition. Replace all system colors with `CozyColors`. Remove `@Binding var selectedTab` (use `.task`/`.onAppear` instead). |
| `CatCollectionView.swift` | Merge into `CollectionView.swift`. Switch from 3-col to 2-col grid (visual density change — verify on small screens). Replace cell backgrounds with `.cozyCard()`. |
| `SettingsView.swift` | Replace `List` with `ScrollView` + `VStack` + `.cozyCard()`. Replace system colors. Add `SectionHeader` components. Build custom segmented picker for light/dark mode. |
| `CatView.swift` | Replace any `.rounded` typography or system colors with design tokens. |
| `OnboardingView.swift` | Replace `.rounded` typography. Use `CozyColors` for backgrounds and text. |
| `CatUnlockCelebration.swift` | Replace `.rounded` typography. Use `CozyColors`. |
| `ApartmentView.swift` | Add bottom safe area inset for PillNavBar (adjust pan bounds via `GeometryReader`). Use `CozyColors` for toast and HUD text. |
| `GameStateService.swift` | Add `@MainActor` annotation. Replace any `DispatchQueue` usage with structured concurrency. |
| `HealthKitService.swift` | Verify concurrency safety — HealthKit queries should use `@concurrent` or run in a `Task` with proper actor isolation. |

**Shadow opacity changes to verify:** Current `Shadow.sm` = 0.10 opacity, `Shadow.md` = 0.15, `Shadow.lg` = 0.20. New `CozyElevation.elevated` = 0.08, `floating` = 0.15. The elevated shadow is intentionally softer. Review visually on device.

**Concurrency migration notes:** Swift 6.2's strict concurrency will flag any unsafe cross-actor data access at compile time. The main areas to watch:
- `GameStateService.shared` singleton — needs `@MainActor` since it's accessed from UI
- `HealthKitService` — HealthKit callbacks may need `@concurrent` or actor hop
- `AudioService` — verify AVAudioPlayer usage is main-actor safe
