import SwiftUI

/// Window view that displays weather based on WeatherState
/// Weather is derived from environmental audio exposure levels
struct WindowView: View {
    let weather: WeatherState

    var body: some View {
        ZStack {
            // Window frame
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(windowBackgroundColor)
                .opacity(weather.windowOpacity)

            // Window panes
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    windowPane
                    windowPane
                }
                HStack(spacing: 4) {
                    windowPane
                    windowPane
                }
            }
            .padding(Spacing.sm)

            // Weather overlay
            weatherIcon
                .font(.system(size: 40))
                .foregroundStyle(weatherIconColor)
                .shadow(Shadow.md)
        }
        .frame(width: 120, height: 160)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.brown.opacity(0.6), lineWidth: 8)
        )
    }

    // MARK: - Subviews

    private var windowPane: some View {
        RoundedRectangle(cornerRadius: Radius.sm)
            .fill(windowBackgroundColor.opacity(0.3))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var weatherIcon: some View {
        switch weather {
        case .sunny:
            Image(systemName: "sun.max.fill")
        case .partlyCloudy:
            Image(systemName: "cloud.sun.fill")
        case .overcast:
            Image(systemName: "cloud.fill")
        case .gentleRain:
            Image(systemName: "cloud.rain.fill")
        }
    }

    // MARK: - Colors

    private var windowBackgroundColor: Color {
        switch weather {
        case .sunny:
            return Color.blue.opacity(0.6)
        case .partlyCloudy:
            return Color.blue.opacity(0.4)
        case .overcast:
            return Color.gray.opacity(0.5)
        case .gentleRain:
            return Color.gray.opacity(0.6)
        }
    }

    private var weatherIconColor: Color {
        switch weather {
        case .sunny:
            return .yellow
        case .partlyCloudy:
            return .white
        case .overcast:
            return .gray
        case .gentleRain:
            return .blue
        }
    }
}

#Preview("Sunny") {
    WindowView(weather: .sunny)
        .padding()
        .background(Color(red: 0.98, green: 0.96, blue: 0.92))
}

#Preview("Partly Cloudy") {
    WindowView(weather: .partlyCloudy)
        .padding()
        .background(Color(red: 0.98, green: 0.96, blue: 0.92))
}

#Preview("Rainy") {
    WindowView(weather: .gentleRain)
        .padding()
        .background(Color(red: 0.98, green: 0.96, blue: 0.92))
}
