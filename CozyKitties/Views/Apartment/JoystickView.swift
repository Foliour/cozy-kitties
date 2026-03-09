import SwiftUI

// MARK: - Joystick View

/// Virtual joystick for controlling player movement
/// Returns a normalized direction vector (-1 to 1 on each axis)
struct JoystickView: View {
    /// Callback with normalized direction vector (x, y from -1 to 1)
    let onDirectionChanged: (CGVector) -> Void

    // Joystick configuration (30% smaller: 60→42, 25→18)
    private let backgroundRadius: CGFloat = 42
    private let knobRadius: CGFloat = 18

    @State private var knobOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    var body: some View {
        ZStack {
            // Background circle - dark semi-transparent
            Circle()
                .fill(Color.black.opacity(0.5))
                .frame(width: backgroundRadius * 2, height: backgroundRadius * 2)

            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.6), lineWidth: 3)
                .frame(width: backgroundRadius * 2, height: backgroundRadius * 2)

            // Knob - bright and visible
            Circle()
                .fill(Color.white)
                .frame(width: knobRadius * 2, height: knobRadius * 2)
                .offset(knobOffset)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    updateKnobPosition(translation: value.translation)
                }
                .onEnded { _ in
                    isDragging = false
                    // Return knob to center
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        knobOffset = .zero
                    }
                    onDirectionChanged(.zero)
                }
        )
    }

    private func updateKnobPosition(translation: CGSize) {
        // Calculate distance from center
        let maxDistance = backgroundRadius - knobRadius
        let distance = sqrt(translation.width * translation.width + translation.height * translation.height)

        // Clamp to circle bounds
        if distance > maxDistance {
            let scale = maxDistance / distance
            knobOffset = CGSize(
                width: translation.width * scale,
                height: translation.height * scale
            )
        } else {
            knobOffset = translation
        }

        // Calculate normalized direction (-1 to 1)
        let normalizedX = knobOffset.width / maxDistance
        let normalizedY = knobOffset.height / maxDistance

        onDirectionChanged(CGVector(dx: normalizedX, dy: normalizedY))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.opacity(0.8)

        VStack {
            Spacer()
            HStack {
                JoystickView { direction in
                    print("Direction: \(direction)")
                }
                .padding(40)

                Spacer()
            }
        }
    }
}
