import SwiftUI

struct PillNavBar: View {
    @Binding var selectedTab: Int

    private struct TabItem {
        let icon: String
        let label: String
    }

    private let tabs: [TabItem] = [
        TabItem(icon: "house.fill", label: "Home"),
        TabItem(icon: "pawprint.fill", label: "Collection"),
        TabItem(icon: "gearshape.fill", label: "Settings")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                let isSelected = selectedTab == index

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 20))
                        Text(tabs[index].label)
                            .font(CozyTypography.caption)
                    }
                    .foregroundStyle(isSelected ? CozyColors.textOnColor : CozyColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [CozyColors.accent, CozyColors.accentSecondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .matchedGeometryEffect(id: "selectedPill", in: pillNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 70)
        .glassEffect(in: .rect(cornerRadius: Radius.xl))
        .shadow(CozyElevation.floating)
        .padding(.horizontal, Spacing.lg)
    }

    @Namespace private var pillNamespace
}

#Preview {
    @Previewable @State var selectedTab = 0

    ZStack {
        LinearGradient(
            colors: [CozyColors.backgroundStart, CozyColors.backgroundEnd],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        Color.clear
            .safeAreaInset(edge: .bottom) {
                PillNavBar(selectedTab: $selectedTab)
            }
    }
}
