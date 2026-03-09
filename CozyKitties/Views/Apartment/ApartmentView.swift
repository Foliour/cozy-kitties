import SwiftUI
import SwiftData
import UIKit

/// Main backyard scene showing cats, plants, and outdoor environment
/// Player sprite navigates the scene, camera follows player
struct ApartmentView: View {
    @Environment(\.modelContext) private var modelContext
    private var gameStateService = GameStateService.shared

    // Scene dimensions - actual PNG size (926x1111 pixels)
    private let sceneSize = CGSize(width: 926, height: 1111)

    // Player state - start 5% left and 10% up from center (of 926x1111 scene)
    @State private var playerPosition: CGPoint = CGPoint(x: 417, y: 444)
    @State private var playerDirection: PlayerDirection = .down
    @State private var isPlayerWalking: Bool = false
    @State private var joystickDirection: CGVector = .zero

    // Player configuration
    private let playerSpeed: CGFloat = 200 // Points per second
    private let playerDisplayScale: CGFloat = 2.0

    // Current weather state
    @State private var currentWeather: WeatherState = .sunny

    // Force refresh trigger
    @State private var isLoaded = false

    // Animation timer for player movement
    @State private var lastUpdateTime: Date = Date()

    // Cat unlock celebration
    @State private var celebratingCat: CatDefinition?
    @State private var showCelebration = false

    var body: some View {
        GeometryReader { geometry in
            let viewportSize = geometry.size

            ZStack {
                // Game scene layer (clipped to viewport)
                ZStack(alignment: .topLeading) {
                    // Scene layer - offset to follow player (camera)
                    // allowsHitTesting(false) lets touches pass through to joystick
                    backyardScene(scaledSize: sceneSize)
                        .frame(width: sceneSize.width, height: sceneSize.height)
                        .offset(cameraOffset(viewportSize: viewportSize))
                        .allowsHitTesting(false)
                }
                .frame(width: viewportSize.width, height: viewportSize.height, alignment: .topLeading)
                .clipped()

                // Player layer - always centered in viewport (on top of scene)
                PlayerView(
                    position: CGPoint(x: viewportSize.width / 2, y: viewportSize.height / 2),
                    direction: playerDirection,
                    isWalking: isPlayerWalking,
                    displayScale: playerDisplayScale
                )
                .allowsHitTesting(false)

                // HUD layer - on top of clipped scene
                VStack {
                    // Weather indicator (top-right)
                    HStack {
                        Spacer()
                        weatherIndicator
                            .padding()
                    }

                    Spacer()

                    // Joystick (bottom-left) - positioned above tab bar
                    HStack(alignment: .bottom) {
                        JoystickView { direction in
                            joystickDirection = direction
                            updatePlayerFromJoystick()
                        }
                        .frame(width: 90, height: 90)
                        .padding(.leading, 16)
                        .padding(.bottom, 16)

                        Spacer()
                    }
                }
            }
            .onAppear {
                gameStateService.configure(with: modelContext)
                DispatchQueue.main.async {
                    isLoaded = true
                }
                startMovementLoop()
                syncHealthDataAndCheckUnlocks()
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

    // MARK: - Camera System

    /// Calculate scene offset so camera follows player
    /// Keeps player centered, but clamps at scene edges
    private func cameraOffset(viewportSize: CGSize) -> CGSize {
        // Desired: player at center of viewport
        // Offset = (viewport center) - (player position in scene)
        var offsetX = (viewportSize.width / 2) - playerPosition.x
        var offsetY = (viewportSize.height / 2) - playerPosition.y

        // Clamp so we don't show outside the scene
        let maxOffsetX: CGFloat = 0
        let minOffsetX = viewportSize.width - sceneSize.width
        let maxOffsetY: CGFloat = 0
        let minOffsetY = viewportSize.height - sceneSize.height

        offsetX = max(minOffsetX, min(maxOffsetX, offsetX))
        offsetY = max(minOffsetY, min(maxOffsetY, offsetY))

        return CGSize(width: offsetX, height: offsetY)
    }

    // MARK: - Player Movement

    private func updatePlayerFromJoystick() {
        let isMoving = abs(joystickDirection.dx) > 0.1 || abs(joystickDirection.dy) > 0.1
        isPlayerWalking = isMoving

        if isMoving {
            // Determine facing direction based on joystick
            if abs(joystickDirection.dy) > abs(joystickDirection.dx) {
                playerDirection = joystickDirection.dy < 0 ? .up : .down
            } else {
                playerDirection = joystickDirection.dx < 0 ? .left : .right
            }
        }
    }

    private func startMovementLoop() {
        // Use a timer to update player position smoothly
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            let now = Date()
            let dt = now.timeIntervalSince(lastUpdateTime)
            lastUpdateTime = now

            if isPlayerWalking {
                movePlayer(dt: dt)
            }
        }
    }

    private func movePlayer(dt: TimeInterval) {
        // Normalize joystick direction
        let length = sqrt(joystickDirection.dx * joystickDirection.dx + joystickDirection.dy * joystickDirection.dy)
        guard length > 0.1 else { return }

        let normalizedX = joystickDirection.dx / length
        let normalizedY = joystickDirection.dy / length

        // Calculate new position
        var newX = playerPosition.x + normalizedX * playerSpeed * CGFloat(dt)
        var newY = playerPosition.y + normalizedY * playerSpeed * CGFloat(dt)

        // Clamp to scene bounds (minimal margin to keep player visible)
        let margin: CGFloat = 8
        newX = max(margin, min(sceneSize.width - margin, newX))
        newY = max(margin, min(sceneSize.height - margin, newY))

        playerPosition = CGPoint(x: newX, y: newY)
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
                    CatView(cat: cat, isUnlocked: true)
                        .position(catPosition(for: cat, in: scaledSize))
                }
            }
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var backyardBackground: some View {
        if let uiImage = UIImage(named: "backyard3") ?? loadBundleImage("backyard3.png") {
            Image(uiImage: uiImage)
                .interpolation(.none)
                .resizable()
                .scaledToFill()
        } else {
            Color.green
                .overlay(
                    Text("backyard3.png not found")
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
