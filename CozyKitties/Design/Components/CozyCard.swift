import SwiftUI

// MARK: - CozyCard ViewModifier

struct CozyCard: ViewModifier {
    let interactive: Bool

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .strokeBorder(CozyColors.surfaceBorder.opacity(0.6), lineWidth: 1)
            }
            .glassEffect(in: .rect(cornerRadius: Radius.lg))
            .shadow(CozyElevation.elevated)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(
                isPressed
                    ? .easeIn(duration: 0.15)
                    : .spring(response: 0.3, dampingFraction: 0.7),
                value: isPressed
            )
            .if(interactive) { view in
                view.simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
            }
    }
}

// MARK: - Conditional Modifier Helper

private extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - View Extension

extension View {
    func cozyCard(interactive: Bool = false) -> some View {
        modifier(CozyCard(interactive: interactive))
    }
}
