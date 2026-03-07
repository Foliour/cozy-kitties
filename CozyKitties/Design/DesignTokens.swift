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

// MARK: - Typography
enum Typography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
}

// MARK: - Shadow
enum Shadow {
    static let sm = ShadowStyle(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let md = ShadowStyle(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let lg = ShadowStyle(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
}

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
