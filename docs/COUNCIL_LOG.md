# Council Review Log
## Cozy Kitties Health Tracker

---

## Review #1: Pre-Implementation Plan Review
**Date:** March 6, 2026
**Phase:** Before execution begins
**Document Reviewed:** AGENTIC_PLAN.md

---

### Priya (Product Lead)

> **Overall Assessment:** The plan is solid, but I'm concerned about scope creep and over-engineering.
>
> **Concerns:**
> 1. **XcodeGen adds complexity**: For a single-target app with no modules, is XcodeGen necessary? It's another tool to install, another failure point. A manually created Xcode project might be simpler for MVP.
>
> 2. **Testing scope**: The testing strategy focuses heavily on services but light on UI. For a visual app about cozy cats, the *feel* matters more than perfect service coverage. Don't over-test internals.
>
> 3. **Phase 4 "Polish" is vague**: What does "bug fixes from Council review" mean? We need clearer exit criteria.
>
> **Recommendations:**
> - Consider skipping XcodeGen and manually creating the project. It's one command: `xcodebuild` can work with a standard project.
> - Focus testing on: (a) streak calculation correctness, (b) cat unlock logic, (c) onboarding completes. That's it for MVP.
> - Add specific exit criteria for Phase 4.

---

### Marcus (Systems Engineer)

> **Overall Assessment:** Architecture is reasonable. A few technical gaps need addressing.
>
> **Concerns:**
> 1. **SwiftData + Specs YAML conflict**: The plan says we load cat/plant definitions from YAML, but we're also using SwiftData models. Who owns the source of truth? If a cat's `streakRequired` is in YAML, why store it in SwiftData too?
>
> 2. **Retroactive rewards query performance**: Scanning 90 days of HealthKit data on first launch could be slow. Is there a loading state? What if it takes 5+ seconds?
>
> 3. **idb dependency**: The plan assumes idb is installed. Is it? Should there be a fallback verification method?
>
> **Recommendations:**
> - Clarify: YAML specs are the *definitions*, SwiftData stores *user state* (which cats are unlocked, when). Don't duplicate the definitions in SwiftData.
> - Add a loading/splash screen during retroactive scan with progress indication.
> - Check if idb is installed first. If not, fall back to `xcrun simctl` for basic launch verification.

---

### Sasha (Front-End Architect)

> **Overall Assessment:** UI implementation plan is too thin. For an app where visuals ARE the product, we need more detail.
>
> **Concerns:**
> 1. **No asset strategy**: Where do cat/plant images come from? Are we using SF Symbols as placeholders? Procedurally generated? This is a blocker for UI work.
>
> 2. **Apartment layout undefined**: The plan mentions "positions" in plant YAML but doesn't explain how the apartment is laid out. Is it a fixed aspect ratio? How do cats/plants position relative to furniture?
>
> 3. **Animation approach missing**: The PRD promises "ambient animations" but the technical plan doesn't specify how. SwiftUI animations? TimelineView? This affects performance and feel.
>
> **Recommendations:**
> - Decide asset strategy NOW: I suggest using SF Symbols for cats (cat.fill, etc.) and plants (leaf.fill, etc.) as colored placeholders. Ship MVP with symbols, replace with art later.
> - Define apartment as a fixed canvas (e.g., 390x600 points) and position elements absolutely within it. Scale the canvas to fit screen.
> - Use SwiftUI's `withAnimation` for simple transitions, `TimelineView` for continuous ambient movement (cats breathing, plants swaying).

---

### Dev (Agentic Engineer)

> **Overall Assessment:** Good agentic structure. A few gaps in the automation chain.
>
> **Concerns:**
> 1. **No pre-flight checks**: Before Phase 1, we should verify: Xcode installed? Correct version? Simulator available? Fastlane installed? These checks prevent wasted cycles.
>
> 2. **Task tracking is manual**: The plan says to update `Specs/tasks.yaml` on completion, but there's no automation. Agents should auto-update task status.
>
> 3. **No rollback strategy**: If Phase 3 fails badly, can we revert? Should we commit after each successful phase?
>
> 4. **Missing: How do sub-agents report back?** The plan spawns agents but doesn't specify how results are collected and validated.
>
> **Recommendations:**
> - Add Phase 0: Environment Verification. Check all tools before starting.
> - Git commit after each phase. Use conventional commits: `feat(phase-1): project setup complete`
> - Sub-agents should return structured output: `{ success: bool, files_created: [], tests_passed: bool, errors: [] }`

---

## Council Synthesis

### Blocking Issues (Must Address)
1. **Asset strategy undefined** — Need to decide placeholder approach before UI work
2. **YAML vs SwiftData source of truth** — Clarify data ownership

### High Priority (Address Before Starting)
3. Add Phase 0: Environment verification
4. Define apartment layout system
5. Skip XcodeGen, use standard Xcode project (simpler)

### Medium Priority (Address During Execution)
6. Add loading state for retroactive scan
7. Add git commits between phases
8. Clarify animation approach

### Accepted As-Is
- Testing strategy (Priya's concern noted, but current scope is reasonable)
- idb usage (will check if installed first)
- Sub-agent patterns

---

## Decisions Made

| Issue | Decision | Rationale |
|-------|----------|-----------|
| XcodeGen vs manual | **Skip XcodeGen, create project manually** | Simpler for single-target app, fewer dependencies |
| Asset strategy | **Use SF Symbols as placeholders** | Ships MVP fast, can replace with real art later |
| YAML vs SwiftData | **YAML = definitions, SwiftData = user state** | YAML defines what exists, SwiftData tracks what user has unlocked |
| Apartment layout | **Fixed 390x600 canvas, absolute positioning** | Simple, predictable, scales uniformly |
| Animation | **SwiftUI animations + TimelineView for ambient** | Native, performant, no external deps |
| Environment checks | **Add Phase 0** | Prevent wasted cycles on missing tools |
| Git commits | **Commit after each phase** | Enables rollback, tracks progress |

---

## Updated Plan

Based on Council feedback, the following changes will be made:

1. Add **Phase 0: Environment Verification** before Phase 1
2. Skip XcodeGen — create Xcode project using `xcodebuild` or manual structure
3. Use **SF Symbols** as placeholder assets for cats and plants
4. Apartment uses **fixed 390x600 canvas** with absolute positioning
5. **Git commit** after each successful phase
6. Clarify in code: Specs YAML → definitions, SwiftData → user state only

---

*Review #1 Complete. Proceeding to execution with amendments.*
