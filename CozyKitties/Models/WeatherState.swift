import Foundation

/// Weather state based on environmental audio exposure levels
/// Lower noise = sunnier weather (positive correlation with calm environments)
enum WeatherState: String, CaseIterable {
    case sunny          // < 60 dB average
    case partlyCloudy   // 60-70 dB
    case overcast       // 70-80 dB
    case gentleRain     // > 80 dB (still cozy!)

    /// Opacity for the window view (affects light coming through)
    var windowOpacity: Double {
        switch self {
        case .sunny: return 1.0
        case .partlyCloudy: return 0.85
        case .overcast: return 0.7
        case .gentleRain: return 0.6
        }
    }

    /// Creates weather state from decibel level
    static func from(decibels: Double) -> WeatherState {
        switch decibels {
        case ..<60: return .sunny
        case 60..<70: return .partlyCloudy
        case 70..<80: return .overcast
        default: return .gentleRain
        }
    }

    var displayName: String {
        switch self {
        case .sunny: return "Sunny"
        case .partlyCloudy: return "Partly Cloudy"
        case .overcast: return "Overcast"
        case .gentleRain: return "Gentle Rain"
        }
    }
}
