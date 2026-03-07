import SwiftUI
import SwiftData

/// Grid view showing all cats (unlocked + locked)
/// Locked cats are shown as silhouettes
struct CatCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateService = GameStateService.shared
    @State private var selectedCat: CatDefinition?

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
        }
    }

    private func isCatUnlocked(_ cat: CatDefinition) -> Bool {
        gameStateService.gameState?.unlockedCatIDs.contains(cat.id) ?? false
    }
}

// MARK: - Cat Collection Cell

struct CatCollectionCell: View {
    let cat: CatDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Cat icon
            Image(systemName: "cat.fill")
                .font(.system(size: 44))
                .foregroundStyle(catColor)
                .frame(width: 80, height: 80)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))

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

    private var catColor: Color {
        guard isUnlocked else {
            return .gray.opacity(0.4)
        }

        switch cat.appearance {
        case "cat_white_fluffy", "cat_persian_white":
            return .white
        case "cat_black_sleek":
            return .black
        case "cat_orange_tabby":
            return .orange
        case "cat_gray_socks":
            return .gray
        case "cat_cream":
            return Color(red: 1.0, green: 0.95, blue: 0.8)
        case "cat_tuxedo":
            return .black
        case "cat_tortie":
            return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "cat_brown":
            return .brown
        case "cat_calico_eyepatch":
            return Color(red: 1.0, green: 0.8, blue: 0.6)
        default:
            return .orange
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

            // Cat image
            Image(systemName: "cat.fill")
                .font(.system(size: 100))
                .foregroundStyle(catColor)
                .shadow(Shadow.lg)

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

    private var catColor: Color {
        switch cat.appearance {
        case "cat_white_fluffy", "cat_persian_white":
            return .white
        case "cat_black_sleek":
            return .black
        case "cat_orange_tabby":
            return .orange
        case "cat_gray_socks":
            return .gray
        case "cat_cream":
            return Color(red: 1.0, green: 0.95, blue: 0.8)
        case "cat_tuxedo":
            return .black
        case "cat_tortie":
            return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "cat_brown":
            return .brown
        case "cat_calico_eyepatch":
            return Color(red: 1.0, green: 0.8, blue: 0.6)
        default:
            return .orange
        }
    }
}

#Preview {
    CatCollectionView()
        .modelContainer(for: [GameState.self, Plant.self], inMemory: true)
}
