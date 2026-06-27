import SwiftUI
import SwiftData
import UIKit

/// Merged Collection view: progress summary + cat catalog grid
struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared

    @State private var cumulativeSteps: Int = 0
    @State private var todaySteps: Int = 0
    @State private var isLoading: Bool = true
    @State private var selectedCat: CatDefinition?

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Page title
                HStack {
                    Text("Collection")
                        .font(CozyTypography.largeTitle)
                        .foregroundStyle(CozyColors.textPrimary)
                    Spacer()
                }

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    // Progress summary card
                    progressCard

                    // Cat grid
                    LazyVGrid(columns: columns, spacing: Spacing.md) {
                        ForEach(catRoster) { cat in
                            let asd = gameStateService.gameState?.averageStepsPerDay ?? 5000
                            CatCollectionCell(
                                cat: cat,
                                isUnlocked: isCatUnlocked(cat),
                                asd: asd
                            )
                            .onTapGesture {
                                if isCatUnlocked(cat) {
                                    selectedCat = cat
                                }
                            }
                        }
                    }
                }
            }
            .padding(Spacing.md)
        }
        .task {
            await loadProgressData()
        }
        .onAppear {
            gameStateService.configure(with: modelContext)
        }
        .sheet(item: $selectedCat) { cat in
            CatDetailSheet(
                cat: cat,
                asd: gameStateService.gameState?.averageStepsPerDay ?? 5000
            )
        }
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(spacing: Spacing.md) {
            // Header
            HStack {
                Text("Your Progress")
                    .font(CozyTypography.headline)
                    .foregroundStyle(CozyColors.textPrimary)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(CozyColors.textSecondary)
                Spacer()
            }

            // Total steps hero
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(cumulativeSteps.formatted())
                        .font(CozyTypography.statLarge)
                        .foregroundStyle(CozyColors.accent)
                    Text("total steps walked")
                        .font(CozyTypography.caption)
                        .foregroundStyle(CozyColors.textSecondary)
                }
                Spacer()

                // Today badge
                VStack(spacing: Spacing.xs) {
                    Text("Today")
                        .font(CozyTypography.caption)
                    Text(todaySteps.formatted())
                        .font(CozyTypography.statMedium)
                }
                .accentBlock(elevated: true)
            }

            // Next cat row
            if let nextCat = gameStateService.getNextCatToUnlock(cumulativeSteps: cumulativeSteps) {
                let asd = gameStateService.gameState?.averageStepsPerDay ?? 5000
                let threshold = nextCat.cat.stepsRequired(asd: asd)
                let progress = threshold > 0 ? Double(cumulativeSteps) / Double(threshold) : 0

                HStack {
                    Text("Next: \(nextCat.cat.name)")
                        .font(CozyTypography.headline)
                        .foregroundStyle(CozyColors.textPrimary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(CozyTypography.statMedium)
                        .foregroundStyle(CozyColors.accent)
                }

                CozyProgressBar(progress: progress)

                Text("\(nextCat.stepsRemaining.formatted()) more steps!")
                    .font(CozyTypography.caption)
                    .foregroundStyle(CozyColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("All cats unlocked!")
                    .font(CozyTypography.headline)
                    .foregroundStyle(CozyColors.textPrimary)
            }
        }
        .cozyCard()
    }

    // MARK: - Data Loading

    private func loadProgressData() async {
        gameStateService.configure(with: modelContext)
        _ = await gameStateService.syncHealthData()
        let today = await HealthKitService.shared.fetchTodaySteps()

        await MainActor.run {
            cumulativeSteps = gameStateService.gameState?.cumulativeSteps ?? 0
            todaySteps = today
            isLoading = false
        }
    }

    private func isCatUnlocked(_ cat: CatDefinition) -> Bool {
        return gameStateService.isCatUnlocked(cat.id)
    }
}

// MARK: - Cat Collection Cell

struct CatCollectionCell: View {
    let cat: CatDefinition
    let isUnlocked: Bool
    let asd: Int

    var body: some View {
        VStack(spacing: Spacing.sm) {
            if isUnlocked {
                CatThumbnailView(cat: cat)
                    .frame(width: 80, height: 80)
            } else {
                Image(systemName: "cat.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(CozyColors.textSecondary.opacity(0.4))
                    .frame(width: 80, height: 80)
            }

            if isUnlocked {
                Text(cat.name)
                    .font(CozyTypography.headline)
                    .foregroundStyle(CozyColors.textPrimary)

                let steps = cat.stepsRequired(asd: asd)
                if steps > 0 {
                    Text("\(steps.formatted()) steps")
                        .font(CozyTypography.caption)
                        .foregroundStyle(CozyColors.accent)
                }
            } else {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("\(cat.stepsRequired(asd: asd).formatted()) steps")
                        .font(CozyTypography.caption)
                }
                .foregroundStyle(CozyColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .cozyCard(interactive: isUnlocked)
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
                    .foregroundStyle(CozyColors.textSecondary.opacity(0.4))
            }
        }
        .task {
            loadSpriteFrame()
        }
    }

    private func loadSpriteFrame() {
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
        case "cat_bw":
            spriteBaseName = "BW"
        case "cat_gray":
            spriteBaseName = "Gray"
        case "cat_gray_tabby":
            spriteBaseName = "GrayTabby"
        default:
            return
        }

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

        let frameRect = CGRect(x: 0, y: 0, width: 48, height: 48)
        if let croppedImage = cgImage.cropping(to: frameRect) {
            spriteFrame = UIImage(cgImage: croppedImage, scale: 1.0, orientation: .up)
        }
    }
}

// MARK: - Cat Detail Sheet

struct CatDetailSheet: View {
    let cat: CatDefinition
    let asd: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.lg) {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(CozyColors.textSecondary)
                }
            }
            .padding(.horizontal)

            Spacer()

            CatThumbnailView(cat: cat)
                .frame(width: 150, height: 150)

            Text(cat.name)
                .font(CozyTypography.largeTitle)
                .foregroundStyle(CozyColors.textPrimary)

            Text(cat.description)
                .font(CozyTypography.body)
                .foregroundStyle(CozyColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            let steps = cat.stepsRequired(asd: asd)
            if steps > 0 {
                Text("Earned at \(steps.formatted()) steps")
                    .font(CozyTypography.caption)
                    .foregroundStyle(CozyColors.accent)
            } else {
                Text("Starter cat")
                    .font(CozyTypography.caption)
                    .foregroundStyle(CozyColors.textSecondary)
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [CozyColors.backgroundStart, CozyColors.backgroundEnd],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: [GameState.self], inMemory: true)
}
