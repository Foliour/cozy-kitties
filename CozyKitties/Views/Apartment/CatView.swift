import SwiftUI

/// Individual cat view using SF Symbols
/// Displays a cat with different colors based on appearance
/// Includes tap gesture to show name and idle animation
struct CatView: View {
    let cat: CatDefinition
    let isUnlocked: Bool
    var onTap: (() -> Void)? = nil

    @State private var showingName = false
    @State private var animationScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Cat icon with idle animation
            Image(systemName: "cat.fill")
                .font(.system(size: 50))
                .foregroundStyle(catColor)
                .scaleEffect(animationScale)
                .shadow(Shadow.sm)
                .onAppear {
                    startIdleAnimation()
                }

            // Name label (shown on tap)
            if showingName {
                Text(cat.name)
                    .font(Typography.caption)
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showingName.toggle()
            }
            onTap?()

            // Auto-hide name after 2 seconds
            if showingName {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showingName = false
                    }
                }
            }
        }
    }

    // MARK: - Cat Color

    private var catColor: Color {
        guard isUnlocked else {
            return .gray.opacity(0.5) // Silhouette for locked cats
        }

        // Color based on cat appearance
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

    // MARK: - Animation

    private func startIdleAnimation() {
        guard isUnlocked else { return }

        // Subtle breathing/idle animation
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            animationScale = 1.05
        }
    }
}

#Preview("Unlocked Cat") {
    CatView(
        cat: catRoster[0],
        isUnlocked: true
    )
    .padding()
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
}

#Preview("Locked Cat") {
    CatView(
        cat: catRoster[2],
        isUnlocked: false
    )
    .padding()
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
}
