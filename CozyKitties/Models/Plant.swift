import Foundation
import SwiftData

// MARK: - PlantType Enum
enum PlantType: String, Codable, CaseIterable {
    case pothos
    case succulent
    case monstera
    case fern
    case flowers

    var goodNightsToUnlock: Int {
        switch self {
        case .pothos: return 3
        case .succulent: return 5
        case .monstera: return 7
        case .fern: return 10
        case .flowers: return 14
        }
    }

    var displayName: String {
        switch self {
        case .pothos: return "Pothos"
        case .succulent: return "Succulent"
        case .monstera: return "Monstera"
        case .fern: return "Fern"
        case .flowers: return "Flowers"
        }
    }

    var defaultPosition: (x: Double, y: Double) {
        switch self {
        case .pothos: return (0.15, 0.7)
        case .succulent: return (0.85, 0.65)
        case .monstera: return (0.25, 0.5)
        case .fern: return (0.75, 0.55)
        case .flowers: return (0.5, 0.6)
        }
    }
}

// MARK: - Plant Model
@Model
final class Plant {
    var id: String
    var typeRawValue: String
    var growthStage: Int // 0-3
    var positionX: Double
    var positionY: Double
    var unlockedAt: Date?

    var type: PlantType {
        get { PlantType(rawValue: typeRawValue) ?? .pothos }
        set { typeRawValue = newValue.rawValue }
    }

    init(
        id: String,
        type: PlantType,
        growthStage: Int = 0,
        positionX: Double,
        positionY: Double,
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.typeRawValue = type.rawValue
        self.growthStage = growthStage
        self.positionX = positionX
        self.positionY = positionY
        self.unlockedAt = unlockedAt
    }

    /// Creates a plant with default position based on type
    convenience init(id: String, type: PlantType) {
        let position = type.defaultPosition
        self.init(
            id: id,
            type: type,
            growthStage: 0,
            positionX: position.x,
            positionY: position.y,
            unlockedAt: nil
        )
    }
}
