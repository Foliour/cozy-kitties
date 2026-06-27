import SwiftUI

// MARK: - Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Radius
enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let full: CGFloat = 9999
}

// MARK: - Colors
enum CozyColors {
    static let accent = Color("accent")
    static let accentSecondary = Color("accentSecondary")
    static let backgroundStart = Color("backgroundStart")
    static let backgroundEnd = Color("backgroundEnd")
    static let cardSurface = Color("cardSurface")
    static let surfaceBorder = Color("surfaceBorder")
    static let recessedFill = Color("recessedFill")
    static let textPrimary = Color("textPrimary")
    static let textSecondary = Color("textSecondary")
    static let textOnColor = Color("textOnColor")
    static let toggleInactive = Color("toggleInactive")
    static let destructive = Color("destructive")
}

// MARK: - Typography
enum CozyTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title = Font.system(size: 28, weight: .semibold)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let statLarge = Font.system(size: 40, weight: .bold)
    static let statMedium = Font.system(size: 22, weight: .bold)
}

// MARK: - Elevation
enum CozyElevation {
    static let elevated = ShadowStyle(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    static let floating = ShadowStyle(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
}

// MARK: - Shadow Style
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extension for Shadow
extension View {
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
