import SwiftUI
import SwiftData
import UIKit

/// Grid view showing all cats (unlocked + locked)
/// Locked cats are shown as silhouettes
struct CatCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    private var gameStateService = GameStateService.shared
    @State private var selectedCat: CatDefinition?
    @State private var isLoaded = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Spacing.lg) {
                    ForEach(catRoster) { cat in
                        CatCollectionCell(
                            cat: cat,
                            isUnlocked: isCatUnlocked(cat)
                        )
                        .onTapGesture {
                            if isCatUnlocked(cat) {
                                selectedCat = cat
                            }
                        }
                    }
                }
                .padding(Spacing.md)
            }
            .background(Color(red: 0.98, green: 0.96, blue: 0.92))
            .navigationTitle("Cat Collection")
            .sheet(item: $selectedCat) { cat in
                CatDetailSheet(cat: cat)
            }
        }
        .onAppear {
            gameStateService.configure(with: modelContext)
            DispatchQueue.main.async {
                isLoaded = true
            }
        }
    }

    private func isCatUnlocked(_ cat: CatDefinition) -> Bool {
        guard isLoaded else { return false }
        return gameStateService.gameState?.unlockedCatIDs.contains(cat.id) ?? false
    }
}

// MARK: - Cat Collection Cell

struct CatCollectionCell: View {
    let cat: CatDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Cat icon - sprite for unlocked, generic for locked
            if isUnlocked {
                CatThumbnailView(cat: cat)
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            } else {
                Image(systemName: "cat.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.gray.opacity(0.4))
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }

            // Name or locked indicator
            if isUnlocked {
                Text(cat.name)
                    .font(Typography.headline)
                    .foregroundStyle(.primary)
            } else {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("\(cat.streakRequired) days")
                        .font(Typography.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg)
                .fill(isUnlocked ? Color.white.opacity(0.6) : Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Cat Thumbnail View

struct CatThumbnailView: View {
    let cat: CatDefinition
    @State private var spriteFrame: UIImage?

    var body: some View {
        Group {
            if let sprite = spriteFrame {
                Image(uiImage: sprite)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "cat.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.gray.opacity(0.4))
            }
        }
        .task {
            loadSpriteFrame()
        }
    }

    private func loadSpriteFrame() {
        // Map cat appearance to sprite base name
        let spriteBaseName: String
        switch cat.appearance {
        case "cat_black":
            spriteBaseName = "Black"
        case "cat_orange_tabby":
            spriteBaseName = "OrangeTabby"
        case "cat_brown":
            spriteBaseName = "Brown"
        case "cat_white":
            spriteBaseName = "White"
        case "cat_siamese":
            spriteBaseName = "Siamese"
        case "cat_tuxedo":
            spriteBaseName = "Tuxedo"
        case "cat_calico":
            spriteBaseName = "Calico"
        default:
            return
        }

        // Load the idle sprite sheet using same method as CatView
        let spriteName = "\(spriteBaseName)-Idle"

        var image: UIImage?
        if let path = Bundle.main.path(forResource: spriteName, ofType: "png") {
            image = UIImage(contentsOfFile: path)
        }
        if image == nil, let url = Bundle.main.url(forResource: spriteName, withExtension: "png") {
            image = UIImage(contentsOfFile: url.path)
        }
        if image == nil {
            image = UIImage(named: spriteName)
        }

        guard let spriteSheet = image, let cgImage = spriteSheet.cgImage else {
            return
        }

        // Extract first frame (48x48)
        let frameRect = CGRect(x: 0, y: 0, width: 48, height: 48)
        if let croppedImage = cgImage.cropping(to: frameRect) {
            spriteFrame = UIImage(cgImage: croppedImage, scale: 1.0, orientation: .up)
        }
    }
}

// MARK: - Cat Detail Sheet

struct CatDetailSheet: View {
    let cat: CatDefinition
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Header
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Cat sprite
            CatThumbnailView(cat: cat)
                .frame(width: 150, height: 150)

            // Cat info
            Text(cat.name)
                .font(Typography.largeTitle)

            Text(cat.description)
                .font(Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Text("Unlocked at \(cat.streakRequired) day streak")
                .font(Typography.caption)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .padding()
        .background(Color(red: 0.98, green: 0.96, blue: 0.92))
    }
}

#Preview {
    CatCollectionView()
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
