import SwiftUI

struct AccentBlockModifier: ViewModifier {
    var elevated: Bool

    func body(content: Content) -> some View {
        content
            .foregroundStyle(CozyColors.textOnColor)
            .padding(Spacing.md)
            .background(
                LinearGradient(
                    colors: [CozyColors.accent, CozyColors.accentSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .if(elevated) { view in
                view.shadow(CozyElevation.elevated)
            }
    }
}

private extension View {
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    func accentBlock(elevated: Bool = true) -> some View {
        modifier(AccentBlockModifier(elevated: elevated))
    }
}
