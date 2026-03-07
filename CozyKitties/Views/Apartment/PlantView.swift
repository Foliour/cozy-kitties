import SwiftUI

/// Individual plant view using SF Symbols
/// Shows growth stages via opacity and scale
struct PlantView: View {
    let plant: Plant

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Plant icon
            plantIcon
                .font(.system(size: plantSize))
                .foregroundStyle(plantColor)
                .opacity(plantOpacity)
                .scaleEffect(plantScale)
                .shadow(Shadow.sm)

            // Plant name (only shown if unlocked)
            if plant.unlockedAt != nil {
                Text(plant.type.displayName)
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Plant Icon

    @ViewBuilder
    private var plantIcon: some View {
        switch plant.type {
        case .pothos:
            Image(systemName: "leaf.fill")
        case .succulent:
            Image(systemName: "camera.macro")
        case .monstera:
            Image(systemName: "leaf.fill")
        case .fern:
            Image(systemName: "leaf.arrow.triangle.circlepath")
        case .flowers:
            Image(systemName: "camera.macro")
        }
    }

    // MARK: - Plant Color

    private var plantColor: Color {
        guard plant.unlockedAt != nil else {
            return .gray.opacity(0.3) // Not yet unlocked
        }

        switch plant.type {
        case .pothos:
            return Color(red: 0.2, green: 0.6, blue: 0.3)
        case .succulent:
            return Color(red: 0.4, green: 0.7, blue: 0.5)
        case .monstera:
            return Color(red: 0.1, green: 0.5, blue: 0.2)
        case .fern:
            return Color(red: 0.3, green: 0.65, blue: 0.35)
        case .flowers:
            return Color(red: 0.9, green: 0.4, blue: 0.5)
        }
    }

    // MARK: - Growth Stage Properties

    private var plantOpacity: Double {
        guard plant.unlockedAt != nil else { return 0.3 }

        switch plant.growthStage {
        case 0: return 0.5
        case 1: return 0.7
        case 2: return 0.85
        default: return 1.0
        }
    }

    private var plantScale: CGFloat {
        guard plant.unlockedAt != nil else { return 0.6 }

        switch plant.growthStage {
        case 0: return 0.6
        case 1: return 0.75
        case 2: return 0.9
        default: return 1.0
        }
    }

    private var plantSize: CGFloat {
        switch plant.type {
        case .monstera: return 44
        case .pothos: return 36
        case .fern: return 38
        case .succulent: return 32
        case .flowers: return 34
        }
    }
}

#Preview("Unlocked Plant - Full Growth") {
    PlantView(
        plant: Plant(
            id: "pothos_preview",
            type: .pothos,
            growthStage: 3,
            positionX: 0.5,
            positionY: 0.5,
            unlockedAt: Date()
        )
    )
    .padding()
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
}

#Preview("Locked Plant") {
    PlantView(
        plant: Plant(
            id: "monstera_preview",
            type: .monstera
        )
    )
    .padding()
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
}
