import Foundation

/// Static cat definition - NOT stored in SwiftData
/// Represents the cat roster as defined in Specs/cats.yaml
struct CatDefinition: Identifiable, Equatable {
    let id: String
    let name: String
    let appearance: String
    let asdMultiplier: Int
    let description: String

    /// Steps required to unlock this cat for a given ASD
    func stepsRequired(asd: Int) -> Int {
        asdMultiplier * asd
    }
}

// MARK: - Cat Roster
/// Hardcoded cat roster
/// Cats are unlocked based on cumulative steps since day zero
/// Each cat's threshold = asdMultiplier * user's Average Steps per Day
let catRoster: [CatDefinition] = [
    CatDefinition(
        id: "luna",
        name: "Luna",
        appearance: "cat_white",
        asdMultiplier: 0,
        description: "Welcome home! Luna would like some pets, please."
    ),
    CatDefinition(
        id: "topaz",
        name: "Topaz",
        appearance: "cat_orange_tabby",
        asdMultiplier: 1,
        description: "Topaz is a floppy tabby who follows you everywhere. He might as well be a dog!"
    ),
    CatDefinition(
        id: "pizza",
        name: "Pizza",
        appearance: "cat_calico",
        asdMultiplier: 3,
        description: "Pizza is shy, quirky, and such a good girl!"
    ),
    CatDefinition(
        id: "trouble",
        name: "Trouble",
        appearance: "cat_black",
        asdMultiplier: 7,
        description: "Trouble is the sweetest kitty in the world, but trouble always seems to find her."
    ),
    CatDefinition(
        id: "mumu",
        name: "Mumu",
        appearance: "cat_bw",
        asdMultiplier: 14,
        description: "Mumu is a smart boy with a very big heart!"
    ),
    CatDefinition(
        id: "jacques",
        name: "Jacques",
        appearance: "cat_tuxedo",
        asdMultiplier: 21,
        description: "Jacques is well-groomed and always on a mission."
    ),
    CatDefinition(
        id: "chessie",
        name: "Chessie",
        appearance: "cat_gray_tabby",
        asdMultiplier: 30,
        description: "Chessie is a perfect lady. She does not care for kittens."
    ),
    CatDefinition(
        id: "biscuit",
        name: "Biscuit",
        appearance: "cat_siamese",
        asdMultiplier: 45,
        description: "Biscuit is a little unhinged and full of big energy!"
    ),
    CatDefinition(
        id: "lara",
        name: "Lara",
        appearance: "cat_brown",
        asdMultiplier: 60,
        description: "Lara is a lovely lady. Kind, polite, and always gracious."
    ),
    CatDefinition(
        id: "misty",
        name: "Misty",
        appearance: "cat_gray",
        asdMultiplier: 90,
        description: "Misty is adventurous and strong. Try to keep up!"
    )
]

// MARK: - Helper Functions
extension Array where Element == CatDefinition {
    /// Find a cat definition by ID
    func cat(withID id: String) -> CatDefinition? {
        first { $0.id == id }
    }

    /// Get cats that can be unlocked at the given cumulative steps
    func catsUnlockableAt(cumulativeSteps: Int, asd: Int) -> [CatDefinition] {
        filter { cumulativeSteps >= $0.stepsRequired(asd: asd) }
    }

    /// Get the next cat to unlock after the given cumulative steps
    func nextCatToUnlock(cumulativeSteps: Int, asd: Int) -> CatDefinition? {
        sorted { $0.asdMultiplier < $1.asdMultiplier }
            .first { cumulativeSteps < $0.stepsRequired(asd: asd) }
    }
}
