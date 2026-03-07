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
        id: "mochi",
        name: "Mochi",
        appearance: "cat_white_fluffy",
        streakRequired: 0,
        description: "A fluffy white cloud of a cat"
    ),
    CatDefinition(
        id: "shadow",
        name: "Shadow",
        appearance: "cat_black_sleek",
        streakRequired: 5,
        description: "Sleek and mysterious"
    ),
    CatDefinition(
        id: "marmalade",
        name: "Marmalade",
        appearance: "cat_orange_tabby",
        streakRequired: 10,
        description: "Warm as a sunny afternoon"
    ),
    CatDefinition(
        id: "luna",
        name: "Luna",
        appearance: "cat_gray_socks",
        streakRequired: 15,
        description: "Gray with adorable white socks"
    ),
    CatDefinition(
        id: "biscuit",
        name: "Biscuit",
        appearance: "cat_cream",
        streakRequired: 20,
        description: "Cream-colored and always kneading"
    ),
    CatDefinition(
        id: "pepper",
        name: "Pepper",
        appearance: "cat_tuxedo",
        streakRequired: 25,
        description: "Formally dressed at all times"
    ),
    CatDefinition(
        id: "olive",
        name: "Olive",
        appearance: "cat_tortie",
        streakRequired: 30,
        description: "A beautiful tortoiseshell"
    ),
    CatDefinition(
        id: "cloud",
        name: "Cloud",
        appearance: "cat_persian_white",
        streakRequired: 35,
        description: "Fluffy Persian royalty"
    ),
    CatDefinition(
        id: "espresso",
        name: "Espresso",
        appearance: "cat_brown",
        streakRequired: 40,
        description: "Dark roast energy"
    ),
    CatDefinition(
        id: "captain",
        name: "Captain",
        appearance: "cat_calico_eyepatch",
        streakRequired: 45,
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
