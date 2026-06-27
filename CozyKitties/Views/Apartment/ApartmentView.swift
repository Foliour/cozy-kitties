import SwiftUI
import SwiftData
import UIKit

/// Main backyard scene showing cats
/// Drag-to-scroll viewport panning
struct ApartmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    private var gameStateService = GameStateService.shared

    // Scene dimensions - actual PNG size (848x1048 pixels)
    private let sceneSize = CGSize(width: 848, height: 1048)

    // Viewport navigation
    @State private var viewportOffset: CGPoint = .zero
    @State private var gestureStartOffset: CGPoint = .zero
    @State private var isGestureActive: Bool = false
    @State private var viewportSize: CGSize = .zero
    @State private var hasSetInitialPosition: Bool = false

    // Force refresh trigger
    @State private var isLoaded = false

    // Cat unlock celebration
    @State private var celebratingCat: CatDefinition?
    @State private var showCelebration = false
    @State private var celebrationQueue: [CatDefinition] = []

    // Day/night cycle
    @State private var isDaytime: Bool = true

    // Pet toast
    @State private var toastMessage: String?

    // HealthKit alert (shown at most once per session)
    @State private var showHealthKitAlert = false
    @State private var didCheckHealthKitAccess = false

    // Randomized cat layout - reshuffled on each appear/foreground
    @State private var catSpawnAssignments: [String: Int] = [:]
    @State private var catAnimationAssignments: [String: CatAnimationType] = [:]
    @State private var catFacingAssignments: [String: Bool] = [:]

    var body: some View {
        GeometryReader { geometry in
            let _ = updateViewportSize(geometry.size)

            ZStack {
                // Game scene layer (clipped to viewport)
                ZStack(alignment: .topLeading) {
                    backyardScene(scaledSize: sceneSize)
                        .frame(width: sceneSize.width, height: sceneSize.height)
                        .offset(x: -viewportOffset.x, y: -viewportOffset.y)
                }
                .frame(width: viewportSize.width, height: viewportSize.height, alignment: .topLeading)
                .clipped()

                // HUD layer
                VStack {
                    HStack {
                        #if DEBUG
                        Text("(\(Int(viewportOffset.x)), \(Int(viewportOffset.y)))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                            .padding()
                        #endif
                        Spacer()
                    }

                    Spacer()

                    // Pet toast
                    if let message = toastMessage {
                        Text(message)
                            .font(CozyTypography.body)
                            .foregroundStyle(CozyColors.textOnColor)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                            .shadow(CozyElevation.floating)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, Spacing.lg)
                    }
                }
            }
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
            .onAppear {
                gameStateService.configure(with: modelContext)
                randomizeCatLayout()
                DispatchQueue.main.async {
                    isLoaded = true
                }
                syncHealthDataAndCheckUnlocks()
                updateDayNightState()
            }
            .task {
                await dayNightPollingLoop()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    randomizeCatLayout()
                    syncHealthDataAndCheckUnlocks()
                }
            }
            .onChange(of: viewportSize) { _, newSize in
                guard !hasSetInitialPosition, newSize != .zero else { return }
                hasSetInitialPosition = true
                let initialX = max(0, min(400 - newSize.width / 2, sceneSize.width - newSize.width))
                let initialY = max(0, min(450 - newSize.height / 2, sceneSize.height - newSize.height))
                viewportOffset = CGPoint(x: initialX, y: initialY)
                gestureStartOffset = viewportOffset
            }
        }
        .alert("Health Access Needed", isPresented: $showHealthKitAlert) {
            Button("Allow Access") {
                Task {
                    try? await HealthKitService.shared.requestAuthorization()
                    syncHealthDataAndCheckUnlocks()
                }
            }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text("CozyKitties needs access to your step count to unlock cats.")
        }
        .overlay {
            if showCelebration, let cat = celebratingCat {
                CatUnlockCelebration(
                    cat: cat,
                    asd: gameStateService.gameState?.averageStepsPerDay ?? 5000
                ) {
                    gameStateService.markCelebrated(catID: cat.id)
                    showCelebration = false
                    celebratingCat = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showNextCelebration()
                    }
                }
            }
        }
    }

    // MARK: - Health Data Sync

    private func syncHealthDataAndCheckUnlocks() {
        Task {
            let uncelebrated = await gameStateService.syncHealthData()

            await MainActor.run {
                if uncelebrated.isEmpty == false {
                    randomizeCatLayout()
                }
                celebrationQueue = uncelebrated
                showNextCelebration()

                // If onboarding is done but no steps are syncing, HealthKit may be denied
                // Only show once per session
                if !didCheckHealthKitAccess,
                   let state = gameStateService.gameState,
                   state.hasCompletedOnboarding,
                   state.cumulativeSteps == 0,
                   gameStateService.getUnlockedCats().count <= 1 {
                    didCheckHealthKitAccess = true
                    showHealthKitAlert = true
                }
            }
        }
    }

    private func showNextCelebration() {
        guard !celebrationQueue.isEmpty, !showCelebration else { return }
        let next = celebrationQueue.removeFirst()
        celebratingCat = next
        showCelebration = true
    }

    // MARK: - Pet Toast

    private func showPetToast(_ name: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            toastMessage = "You petted \(name)"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.3)) {
                toastMessage = nil
            }
        }
    }

    // MARK: - Viewport Navigation

    private func updateViewportSize(_ size: CGSize) {
        if viewportSize != size { viewportSize = size }
    }

    private func clampedOffset(_ offset: CGPoint) -> CGPoint {
        let maxX = max(0, sceneSize.width - viewportSize.width)
        let maxY = max(0, sceneSize.height - viewportSize.height)
        return CGPoint(
            x: max(0, min(offset.x, maxX)),
            y: max(0, min(offset.y, maxY))
        )
    }

    private func applyMomentum(from value: DragGesture.Value) {
        let projectedX = gestureStartOffset.x - value.predictedEndTranslation.width
        let projectedY = gestureStartOffset.y - value.predictedEndTranslation.height

        let target = clampedOffset(CGPoint(x: projectedX, y: projectedY))

        withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
            viewportOffset = target
        }
    }

    // MARK: - Backyard Scene

    @ViewBuilder
    private func backyardScene(scaledSize: CGSize) -> some View {
        ZStack {
            backyardBackground

            // Cats layer
            if isLoaded {
                ForEach(gameStateService.getUnlockedCats()) { cat in
                    let anim = catAnimationAssignments[cat.id] ?? .idle
                    let facing = catFacingAssignments[cat.id] ?? false
                    let spawn = catSpawnAssignments[cat.id] ?? -1
                    CatView(
                        cat: cat,
                        isUnlocked: true,
                        assignedAnimation: anim,
                        assignedFacingLeft: facing
                    ) { name in
                        showPetToast(name)
                    }
                    .id("\(cat.id)-\(spawn)-\(String(describing: anim))-\(facing)")
                    .position(catPosition(for: cat, in: scaledSize))
                }
            }
        }
    }

    // MARK: - Day/Night Cycle

    private var backgroundImageName: String {
        isDaytime ? "backyard-day" : "backyard-night"
    }

    private func updateDayNightState() {
        guard let state = gameStateService.gameState else {
            isDaytime = isActuallyDaytime()
            return
        }

        switch state.dayNightMode {
        case .auto:
            isDaytime = isActuallyDaytime()
        case .alwaysDay:
            isDaytime = true
        case .alwaysNight:
            isDaytime = false
        }
    }

    private func isActuallyDaytime() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour < 20
    }

    private func dayNightPollingLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(300))
            updateDayNightState()
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var backyardBackground: some View {
        if let uiImage = UIImage(named: backgroundImageName) ?? loadBundleImage("\(backgroundImageName).png") {
            Image(uiImage: uiImage)
                .interpolation(.none)
                .resizable()
                .scaledToFill()
        } else {
            Color.green
                .overlay(
                    Text("\(backgroundImageName).png not found")
                        .foregroundColor(.white)
                )
        }
    }

    private func loadBundleImage(_ name: String) -> UIImage? {
        if let path = Bundle.main.path(forResource: "Scenes/\(name)", ofType: nil) {
            return UIImage(contentsOfFile: path)
        }
        if let path = Bundle.main.path(forResource: name, ofType: nil, inDirectory: "Scenes") {
            return UIImage(contentsOfFile: path)
        }
        let nameWithoutExt = (name as NSString).deletingPathExtension
        if let path = Bundle.main.path(forResource: nameWithoutExt, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }

    // MARK: - Cat Positioning & Randomization

    private static let catSpawnPoints: [CGPoint] = [
        CGPoint(x: 205, y: 227),
        CGPoint(x: 426, y: 101),
        CGPoint(x: 675, y: 347),
        CGPoint(x: 392, y: 401),
        CGPoint(x: 519, y: 478),
        CGPoint(x: 670, y: 533),
        CGPoint(x: 439, y: 654),
        CGPoint(x: 143, y: 575),
        CGPoint(x: 319, y: 733),
        CGPoint(x: 242, y: 810),
        CGPoint(x: 200, y: 918),
        CGPoint(x: 502, y: 926),
    ]

    private func randomizeCatLayout() {
        let unlockedCats = gameStateService.getUnlockedCats()
        guard !unlockedCats.isEmpty else { return }

        let spawnIndices = Array(0..<Self.catSpawnPoints.count).shuffled()
        var newSpawnAssignments: [String: Int] = [:]
        for (i, cat) in unlockedCats.enumerated() {
            newSpawnAssignments[cat.id] = spawnIndices[i % spawnIndices.count]
        }

        let allTypes: [CatAnimationType] = [.idle, .pounce, .sit, .sleep]
        var newAnimAssignments: [String: CatAnimationType] = [:]

        if unlockedCats.count >= allTypes.count {
            let shuffledCats = unlockedCats.shuffled()
            for (i, cat) in shuffledCats.enumerated() {
                if i < allTypes.count {
                    newAnimAssignments[cat.id] = allTypes[i]
                } else {
                    newAnimAssignments[cat.id] = allTypes.randomElement()!
                }
            }
        } else {
            for cat in unlockedCats {
                newAnimAssignments[cat.id] = allTypes.randomElement()!
            }
        }

        var newFacingAssignments: [String: Bool] = [:]
        for cat in unlockedCats {
            newFacingAssignments[cat.id] = Bool.random()
        }

        catSpawnAssignments = newSpawnAssignments
        catAnimationAssignments = newAnimAssignments
        catFacingAssignments = newFacingAssignments
    }

    private func catPosition(for cat: CatDefinition, in size: CGSize) -> CGPoint {
        guard let spawnIndex = catSpawnAssignments[cat.id] else {
            return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        }
        return Self.catSpawnPoints[spawnIndex]
    }
}

#Preview {
    ApartmentView()
        .modelContainer(for: [GameState.self], inMemory: true)
}
