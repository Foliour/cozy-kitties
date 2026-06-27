import SwiftUI

struct CozyProgressBar: View {
    let progress: Double

    private var clampedProgress: Double {
        min(max(progress, 0.0), 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: Radius.full)
                    .fill(CozyColors.recessedFill)

                RoundedRectangle(cornerRadius: Radius.full)
                    .fill(CozyColors.accent)
                    .frame(width: geometry.size.width * clampedProgress)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8),
                        value: clampedProgress
                    )
            }
        }
        .frame(height: 10)
    }
}
