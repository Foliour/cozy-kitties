import Foundation

/// Static cat definition - NOT stored in SwiftData
/// Represents the cat roster as defined in Specs/cats.yaml
struct CatDefinition: Identifiable, Equatable {
    let id: String
    let name: String
    let appearance: String
    let streakRequired: Int
    let description: String
}

// MARK: - Cat Roster
/// Hardcoded cat roster matching Specs/cats.yaml
/// Cats are unlocked based on consecutive days meeting the step goal
let catRoster: [CatDefinition] = [
    CatDefinition(
        id: "trouble",
        name: "Trouble",
        appearance: "cat_black",
        streakRequired: 0,
        description: "A mischievous black cat"
    ),
    CatDefinition(
        id: "topaz",
        name: "Topaz",
        appearance: "cat_orange_tabby",
        streakRequired: 1,
        description: "Warm as a sunny afternoon"
    ),
    CatDefinition(
        id: "pizza",
        name: "Pizza",
        appearance: "cat_calico",
        streakRequired: 3,
        description: "A colorful calico with a warm personality"
    ),
    CatDefinition(
        id: "luna",
        name: "Luna",
        appearance: "cat_white",
        streakRequired: 7,
        description: "Elegant and mysterious"
    ),
    CatDefinition(
        id: "biscuit",
        name: "Biscuit",
        appearance: "cat_siamese",
        streakRequired: 14,
        description: "Cream-colored and always kneading"
    ),
    CatDefinition(
        id: "pepper",
        name: "Pepper",
        appearance: "cat_tuxedo",
        streakRequired: 21,
        description: "Formally dressed at all times"
    ),
    CatDefinition(
        id: "marmalade",
        name: "Marmalade",
        appearance: "cat_brown",
        streakRequired: 30,
        description: "Warm as a sunny afternoon"
    ),
    CatDefinition(
        id: "cloud",
        name: "Cloud",
        appearance: "cat_persian_white",
        streakRequired: 45,
        description: "Fluffy Persian royalty"
    ),
    CatDefinition(
        id: "espresso",
        name: "Espresso",
        appearance: "cat_brown",
        streakRequired: 60,
        description: "Dark roast energy"
    ),
    CatDefinition(
        id: "captain",
        name: "Captain",
        appearance: "cat_calico_eyepatch",
        streakRequired: 90,
        description: "Calico with a distinguished eyepatch marking"
    )
]

// MARK: - Helper Functions
extension Array where Element == CatDefinition {
    /// Find a cat definition by ID
    func cat(withID id: String) -> CatDefinition? {
        first { $0.id == id }
    }

    /// Get cats that can be unlocked at the given streak
    func catsUnlockableAt(streak: Int) -> [CatDefinition] {
        filter { $0.streakRequired <= streak }
    }

    /// Get the next cat to unlock after the given streak
    func nextCatToUnlock(afterStreak streak: Int) -> CatDefinition? {
        sorted { $0.streakRequired < $1.streakRequired }
            .first { $0.streakRequired > streak }
    }
}
