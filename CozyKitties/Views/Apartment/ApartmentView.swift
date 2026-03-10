import SwiftUI
import SwiftData
import UIKit

/// Main backyard scene showing cats, plants, and outdoor environment
/// Drag-to-scroll viewport panning
struct ApartmentView: View {
    @Environment(\.modelContext) private var modelContext
    private var gameStateService = GameStateService.shared

    // Scene dimensions - actual PNG size (928x1117 pixels)
    private let sceneSize = CGSize(width: 928, height: 1117)

    // Viewport navigation
    @State private var viewportOffset: CGPoint = .zero
    @State private var gestureStartOffset: CGPoint = .zero
    @State private var isGestureActive: Bool = false
    @State private var viewportSize: CGSize = .zero
    @State private var hasSetInitialPosition: Bool = false

    // Current weather state
    @State private var currentWeather: WeatherState = .sunny

    // Force refresh trigger
    @State private var isLoaded = false

    // Cat unlock celebration
    @State private var celebratingCat: CatDefinition?
    @State private var showCelebration = false

    // Day/night cycle
    @State private var isDaytime: Bool = true

    // Pet toast
    @State private var toastMessage: String?

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

                // HUD layer - on top of clipped scene
                VStack {
                    // Weather indicator (top-right) and debug position
                    HStack {
                        #if DEBUG
                        // Debug position indicator
                        Text("(\(Int(viewportOffset.x)), \(Int(viewportOffset.y)))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                            .padding()
                        #endif
                        Spacer()
                        weatherIndicator
                            .padding()
                    }

                    Spacer()

                    // Pet toast
                    if let message = toastMessage {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 24)
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
                DispatchQueue.main.async {
                    isLoaded = true
                }
                syncHealthDataAndCheckUnlocks()
                updateDayNightState()
                startDayNightTimer()
            }
            .onChange(of: viewportSize) { _, newSize in
                guard !hasSetInitialPosition, newSize != .zero else { return }
                hasSetInitialPosition = true
                let initialX = max(0, min(400 - newSize.width / 2, sceneSize.width - newSize.width))
                let initialY = max(0, min(450 - newSize.height / 2, sceneSize.height - newSize.height))
                viewportOffset = CGPoint(x: initialX, y: initialY)
                gestureStartOffset = viewportOffset
            }
            .onChange(of: gameStateService.catsAwaitingCelebration.count) { oldCount, newCount in
                // Trigger celebration when cats are added to the queue
                if newCount > oldCount && !showCelebration {
                    showNextCelebration()
                }
            }
        }
        .overlay {
            // Cat unlock celebration overlay
            if showCelebration, let cat = celebratingCat {
                CatUnlockCelebration(cat: cat) {
                    showCelebration = false
                    celebratingCat = nil
                    // Check if there are more cats to celebrate
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
            // First sync health data (may unlock new cats)
            _ = await gameStateService.syncHealthData()

            // Check for any cats awaiting celebration (from Settings or sync)
            await MainActor.run {
                showNextCelebration()
            }
        }
    }

    private func showNextCelebration() {
        // Check if there are cats awaiting celebration
        if let firstCat = gameStateService.catsAwaitingCelebration.first {
            celebratingCat = firstCat
            showCelebration = true
            // Remove the first cat from the queue
            gameStateService.catsAwaitingCelebration.removeFirst()
        }
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

        // Cozy spring: languid response, minimal bounce
        withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
            viewportOffset = target
        }
    }

    // MARK: - Backyard Scene

    @ViewBuilder
    private func backyardScene(scaledSize: CGSize) -> some View {
        ZStack {
            // Ground layer - background image
            backyardBackground

            // Plants layer
            ForEach(gameStateService.getPlants(), id: \.id) { plant in
                PlantView(plant: plant)
                    .position(
                        x: scaledSize.width * plant.positionX,
                        y: scaledSize.height * plant.positionY
                    )
            }

            // Cats layer
            if isLoaded {
                ForEach(gameStateService.getUnlockedCats()) { cat in
                    CatView(cat: cat, isUnlocked: true) { name in
                        showPetToast(name)
                    }
                    .position(catPosition(for: cat, in: scaledSize))
                }
            }
        }
    }

    // MARK: - Day/Night Cycle

    /// Determines the background image name based on day/night setting
    private var backgroundImageName: String {
        isDaytime ? "backyard-day" : "backyard-night"
    }

    /// Updates isDaytime based on settings and actual time
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

    /// Returns true if the current local time is between 6 AM and 8 PM
    private func isActuallyDaytime() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour < 20  // 6 AM to 8 PM
    }

    /// Start a timer to check day/night transition periodically
    private func startDayNightTimer() {
        // Check every minute for day/night changes
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
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

    // MARK: - Weather Indicator

    @ViewBuilder
    private var weatherIndicator: some View {
        let weatherColor: Color = {
            switch currentWeather {
            case .sunny: return Color(hex: "#87CEEB")
            case .partlyCloudy: return Color(hex: "#9CA3AF")
            case .overcast: return Color(hex: "#6B7280")
            case .gentleRain: return Color(hex: "#374151")
            }
        }()

        Circle()
            .fill(weatherColor)
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            )
            .shadow(radius: 4)
    }

    // MARK: - Cat Positioning

    /// Spawn points for cats (in pixels, based on 926x1111 scene)
    private static let catSpawnPoints: [CGPoint] = [
        CGPoint(x: 444, y: 235),
        CGPoint(x: 160, y: 240),
        CGPoint(x: 620, y: 228),
        CGPoint(x: 460, y: 400),
        CGPoint(x: 690, y: 400),
        CGPoint(x: 280, y: 575),
        CGPoint(x: 140, y: 688),
        CGPoint(x: 550, y: 658),
        CGPoint(x: 242, y: 905),
        CGPoint(x: 520, y: 900),
    ]

    /// Pre-shuffled spawn point assignments to ensure no duplicates
    /// Uses a seeded shuffle so assignments are consistent across app launches
    private static let shuffledSpawnIndices: [Int] = {
        var indices = Array(0..<catSpawnPoints.count)
        // Seeded shuffle using a simple deterministic algorithm
        var seed = 12345
        for i in stride(from: indices.count - 1, through: 1, by: -1) {
            seed = (seed &* 1103515245 &+ 12345) & 0x7fffffff
            let j = seed % (i + 1)
            indices.swapAt(i, j)
        }
        return indices
    }()

    private func catPosition(for cat: CatDefinition, in size: CGSize) -> CGPoint {
        // Find this cat's index in the roster to assign a unique spawn point
        guard let rosterIndex = catRoster.firstIndex(where: { $0.id == cat.id }) else {
            return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        }

        // Use the shuffled index to get a unique spawn point
        let spawnIndex = Self.shuffledSpawnIndices[rosterIndex % Self.shuffledSpawnIndices.count]
        return Self.catSpawnPoints[spawnIndex]
    }
}

#Preview {
    ApartmentView()
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
