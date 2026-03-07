import SwiftUI
import SwiftData

/// Main apartment scene showing cats, plants, and weather window
/// This is the primary view where users see their cozy apartment
struct ApartmentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared

    // Current weather state (default to sunny)
    @State private var currentWeather: WeatherState = .sunny
    // Current streak (derived from HealthKit)
    @State private var currentStreak: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - warm cream color
                Color(red: 0.98, green: 0.96, blue: 0.92)
                    .ignoresSafeArea()

                // Floor area
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.75, blue: 0.65),
                                    Color(red: 0.8, green: 0.7, blue: 0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: geometry.size.height * 0.35)
                }
                .ignoresSafeArea()

                // Window with weather
                WindowView(weather: currentWeather)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.18)

                // Plants
                ForEach(gameStateService.getPlants(), id: \.id) { plant in
                    PlantView(plant: plant)
                        .position(
                            x: geometry.size.width * plant.positionX,
                            y: geometry.size.height * plant.positionY
                        )
                }

                // Cats
                ForEach(gameStateService.getUnlockedCats()) { cat in
                    CatView(cat: cat, isUnlocked: true)
                        .position(catPosition(for: cat, in: geometry.size))
                }

                // Cozy rug in center
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.8, green: 0.6, blue: 0.5),
                                Color(red: 0.7, green: 0.5, blue: 0.4)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 180, height: 120)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.75)
            }
        }
        .onAppear {
            gameStateService.configure(with: modelContext)
        }
    }

    // MARK: - Cat Positioning

    /// Calculate cat position based on index for distribution
    private func catPosition(for cat: CatDefinition, in size: CGSize) -> CGPoint {
        let unlockedCats = gameStateService.getUnlockedCats()
        guard let index = unlockedCats.firstIndex(where: { $0.id == cat.id }) else {
            return CGPoint(x: size.width * 0.5, y: size.height * 0.7)
        }

        // Distribute cats around the rug area
        let positions: [(x: CGFloat, y: CGFloat)] = [
            (0.5, 0.72),   // Center
            (0.3, 0.68),   // Left
            (0.7, 0.68),   // Right
            (0.2, 0.78),   // Far left
            (0.8, 0.78),   // Far right
            (0.4, 0.82),   // Bottom left
            (0.6, 0.82),   // Bottom right
            (0.35, 0.62),  // Upper left
            (0.65, 0.62),  // Upper right
            (0.5, 0.58),   // Top center
        ]

        let pos = positions[index % positions.count]
        return CGPoint(x: size.width * pos.x, y: size.height * pos.y)
    }
}

#Preview {
    ApartmentView()
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
