import SwiftUI

struct SectionHeader: View {
    let emoji: String
    let title: String

    var body: some View {
        HStack {
            Text(emoji)
            Text(title.uppercased())
                .font(CozyTypography.caption)
                .foregroundStyle(CozyColors.textSecondary)
                .tracking(1.5)
        }
    }
}
