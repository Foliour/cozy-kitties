# Refactor Plan v4: Joystick → Drag-to-Scroll Navigation

## Summary

Replace joystick-controlled player character navigation with direct drag-to-scroll viewport panning. This is the minimal, focused version — ship the core interaction, iterate later.

## Current vs New Architecture

### Current (Joystick + Player)
```
Joystick Input → playerPosition updates → camera follows player
PlayerView sprite always centered in viewport
60 FPS timer for continuous movement
.allowsHitTesting(false) on scene — touches pass through to joystick
```

### New (Drag-to-Scroll)
```
DragGesture → viewportOffset (direct scroll)
No player sprite — user "drags the world"
Momentum scrolling with cozy spring
Hard clamp at scene bounds
Initial viewport centered on cat area
```

---

## Files to DELETE

| File | Reason |
|------|--------|
| `Views/Apartment/JoystickView.swift` | Virtual joystick no longer needed |
| `Views/Apartment/PlayerView.swift` | No player character (also contains `PlayerDirection` and `PlayerState` enums — confirmed no other references) |
| `Resources/Sprites/Player/character.png` | Player sprite asset |
| `character.png` (root directory) | Duplicate artifact |

---

## Files to MODIFY

### `Views/Apartment/ApartmentView.swift`

This is the only file that needs code changes.

#### State Variables to REMOVE
```swift
@State private var playerPosition: CGPoint
@State private var playerDirection: PlayerDirection
@State private var isPlayerWalking: Bool
@State private var joystickDirection: CGVector
private let playerSpeed: CGFloat
private let playerDisplayScale: CGFloat
@State private var lastUpdateTime: Date
```

#### State Variables to ADD
```swift
@State private var viewportOffset: CGPoint = .zero
@State private var gestureStartOffset: CGPoint = .zero
@State private var isGestureActive: Bool = false
@State private var viewportSize: CGSize = .zero
@State private var hasSetInitialPosition: Bool = false
```

#### Functions to REMOVE
- `updatePlayerFromJoystick()`
- `startMovementLoop()`
- `movePlayer(dt:)`
- `cameraOffset(viewportSize:)`

#### UI Components to REMOVE
- `PlayerView` instance and its `.allowsHitTesting(false)`
- `JoystickView` instance and its HStack container
- `.allowsHitTesting(false)` on the scene layer — **CRITICAL: must be removed for DragGesture to receive touches**
- `startMovementLoop()` call from `.onAppear`

#### UI Components to CHANGE
- Debug position indicator: `playerPosition` → `viewportOffset`
- Scene `.offset(cameraOffset(viewportSize:))` → `.offset(x: -viewportOffset.x, y: -viewportOffset.y)`
- Sync `viewportSize` from GeometryReader: add `viewportSize = geometry.size` in body

#### Functions to ADD
- `clampedOffset(_:)` — hard clamp to scene bounds (uses stored `viewportSize`)
- `applyMomentum(from:)` — spring-based momentum on drag end

---

## Navigation Implementation

### State
```swift
@State private var viewportOffset: CGPoint = .zero
@State private var gestureStartOffset: CGPoint = .zero
@State private var isGestureActive: Bool = false
@State private var viewportSize: CGSize = .zero
@State private var hasSetInitialPosition: Bool = false
```

`viewportSize` is stored in `@State` because the gesture handlers need access to it, and it originates as a local inside the `GeometryReader` closure. Sync it in the body:
```swift
GeometryReader { geometry in
    let _ = updateViewportSize(geometry.size)
    // ... rest of body
}

private func updateViewportSize(_ size: CGSize) {
    if viewportSize != size { viewportSize = size }
}
```

### Gesture (inline in body, on the OUTER ZStack)
```swift
// Attach to the outer ZStack, before .onAppear:
.simultaneousGesture(
    DragGesture(minimumDistance: 12)
        .onChanged { value in
            if !isGestureActive {
                isGestureActive = true
                gestureStartOffset = viewportOffset
            }

            var t = Transaction()
            t.animation = nil
            withTransaction(t) {
                viewportOffset = clampedOffset(
                    CGPoint(
                        x: gestureStartOffset.x - value.translation.width,
                        y: gestureStartOffset.y - value.translation.height
                    )
                )
            }
        }
        .onEnded { value in
            isGestureActive = false
            applyMomentum(from: value)
        }
)
```

### Bounds Clamping
```swift
private func clampedOffset(_ offset: CGPoint) -> CGPoint {
    let maxX = max(0, sceneSize.width - viewportSize.width)
    let maxY = max(0, sceneSize.height - viewportSize.height)
    return CGPoint(
        x: max(0, min(offset.x, maxX)),
        y: max(0, min(offset.y, maxY))
    )
}
```

### Momentum Scrolling
```swift
private func applyMomentum(from value: DragGesture.Value) {
    let projectedX = gestureStartOffset.x - value.predictedEndTranslation.width
    let projectedY = gestureStartOffset.y - value.predictedEndTranslation.height

    let target = clampedOffset(CGPoint(x: projectedX, y: projectedY))

    // Cozy spring: languid response, minimal bounce
    withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
        viewportOffset = target
    }
}
```

### Initial Viewport Position
```swift
// Use .onChange(of: viewportSize) — NOT .onAppear — because viewportSize is .zero
// when .onAppear fires (GeometryReader hasn't laid out yet).
@State private var hasSetInitialPosition = false

.onChange(of: viewportSize) { _, newSize in
    guard !hasSetInitialPosition, newSize != .zero else { return }
    hasSetInitialPosition = true
    let initialX = max(0, min(400 - newSize.width / 2, sceneSize.width - newSize.width))
    let initialY = max(0, min(450 - newSize.height / 2, sceneSize.height - newSize.height))
    viewportOffset = CGPoint(x: initialX, y: initialY)
    gestureStartOffset = viewportOffset
}
```

---

## Sprite Tap Interactions (Future)

Groundwork is laid by removing `.allowsHitTesting(false)` and using `.simultaneousGesture`. See GitHub issues for follow-up work.

---

## Implementation Order (automation-friendly)

> **Principle:** Modify before delete. Project must compile after every phase. Use content patterns for edits, not line numbers.

### Phase 0: CHECKPOINT
```bash
git stash push -m "pre-refactor checkpoint"
```

### Phase 1: PREFLIGHT
Grep entire codebase for `JoystickView`, `PlayerView`, `PlayerDirection`, `PlayerState` — confirm no references outside ApartmentView.swift, JoystickView.swift, PlayerView.swift. If found elsewhere → STOP.

### Phase 2: MODIFY ApartmentView.swift

**All removals first, then all additions.**

**Removals:**
- Remove state variables: `playerPosition`, `playerDirection`, `isPlayerWalking`, `joystickDirection`, `playerSpeed`, `playerDisplayScale`, `lastUpdateTime`
- Remove functions: `updatePlayerFromJoystick()`, `startMovementLoop()`, `movePlayer(dt:)`, `cameraOffset(viewportSize:)`
- Remove the `PlayerView(...)` block and its `.allowsHitTesting(false)`
- Remove the `JoystickView { direction in` HStack block
- Remove `.allowsHitTesting(false)` from the `backyardScene` frame
- Remove `startMovementLoop()` call from `.onAppear`
- **Keep** `updateDayNightState()`, `startDayNightTimer()`, and `syncHealthDataAndCheckUnlocks()` calls in `.onAppear`

**Additions:**
- Add state: `viewportOffset`, `gestureStartOffset`, `isGestureActive`, `viewportSize`, `hasSetInitialPosition`
- Sync `viewportSize` from GeometryReader proxy
- Replace `.offset(cameraOffset(viewportSize: viewportSize))` with `.offset(x: -viewportOffset.x, y: -viewportOffset.y)`
- Add `.simultaneousGesture(DragGesture(...))` on the outer ZStack
- Add `clampedOffset(_:)` and `applyMomentum(from:)` functions
- Add initial viewport centering via `.onChange(of: viewportSize)` with one-shot guard
- Update debug indicator: `playerPosition` → `viewportOffset`

### Phase 3: VERIFY COMPILATION
```bash
xcodebuild build -scheme CozyKitties -destination 'platform=iOS Simulator,name=iPhone 16' CODE_SIGNING_ALLOWED=NO 2>&1 | tail -20
```
If build fails → fix before proceeding.

### Phase 4: DELETE FILES
```bash
# Track untracked files first for rollback safety
git add CozyKitties/Resources/Sprites/Player/character.png
git add character.png 2>/dev/null

# Verify Player directory only contains character.png
ls CozyKitties/Resources/Sprites/Player/
# If unexpected files → STOP

rm CozyKitties/Views/Apartment/JoystickView.swift
rm CozyKitties/Views/Apartment/PlayerView.swift
rm -rf CozyKitties/Resources/Sprites/Player/
rm -f character.png
```

### Phase 5: CLEAN PBXPROJ

**Pre-edit verification:**
```bash
grep -c "0AFF92CC5346219D81409E1E\|92C6AEDF3E9F53F63B99F3E1\|F7D65632321659741F10D78B\|178BE2CF5ACECB0B8FB9BF02\|5319B7A70D2EBB8ACF98024F\|44E7F26ADE5DD7C3034C2001\|2C884F3F52EFD531E1DE7ECE" CozyKitties.xcodeproj/project.pbxproj
```
Expected: 14 matches. If different → STOP.

**Remove these lines (full UUIDs):**

JoystickView.swift:
- `0AFF92CC5346219D81409E1E /* JoystickView.swift in Sources */` (PBXBuildFile + PBXSourcesBuildPhase)
- `92C6AEDF3E9F53F63B99F3E1 /* JoystickView.swift */` (PBXFileReference + PBXGroup child in Apartment)

PlayerView.swift:
- `F7D65632321659741F10D78B /* PlayerView.swift in Sources */` (PBXBuildFile + PBXSourcesBuildPhase)
- `178BE2CF5ACECB0B8FB9BF02 /* PlayerView.swift */` (PBXFileReference + PBXGroup child in Apartment)

character.png:
- `5319B7A70D2EBB8ACF98024F /* character.png in Resources */` (PBXBuildFile + PBXResourcesBuildPhase)
- `44E7F26ADE5DD7C3034C2001 /* character.png */` (PBXFileReference + PBXGroup child in Player)

Player group (empty after above):
- Entire `2C884F3F52EFD531E1DE7ECE /* Player */` PBXGroup block (3 lines)
- Parent ref `2C884F3F52EFD531E1DE7ECE /* Player */,` in Sprites group

**Post-edit validation:**
```bash
plutil -lint CozyKitties.xcodeproj/project.pbxproj
```
If invalid → `git checkout -- CozyKitties.xcodeproj/project.pbxproj` and retry.

### Phase 6: FINAL VERIFICATION
```bash
xcodebuild build -scheme CozyKitties -destination 'platform=iOS Simulator,name=iPhone 16' CODE_SIGNING_ALLOWED=NO 2>&1 | tail -20
```

### Phase 7: COMMIT
```bash
git add -A
git commit -m "refactor: replace joystick navigation with drag-to-scroll panning"
```

### Rollback
```bash
git stash pop   # restores to pre-refactor state
```
