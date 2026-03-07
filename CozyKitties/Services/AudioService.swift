import Foundation
import AVFoundation
import Observation

@Observable
final class AudioService {
    static let shared = AudioService()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var audioSession: AVAudioSession?

    var isEnabled: Bool = true
    private(set) var currentAmbience: AmbienceType?

    enum AmbienceType: String {
        case cozy       // Default indoor sounds
        case rain       // When weather is gentleRain
        case purring    // When viewing cat details
    }

    private init() {
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession?.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Ambience Playback

    /// Start playing ambient sounds
    /// - Parameter type: The type of ambience to play
    func playAmbience(_ type: AmbienceType = .cozy) {
        guard isEnabled else { return }

        // Stop current ambience if different
        if currentAmbience != type {
            stopAmbience()
        }

        // TODO: Implement actual audio file loading
        // This is a stub that will be implemented when audio files are added
        //
        // Example implementation:
        // guard let url = Bundle.main.url(forResource: type.rawValue, withExtension: "mp3") else {
        //     print("Audio file not found: \(type.rawValue).mp3")
        //     return
        // }
        //
        // do {
        //     let player = try AVAudioPlayer(contentsOf: url)
        //     player.numberOfLoops = -1 // Loop indefinitely
        //     player.volume = 0.5
        //     player.play()
        //     audioPlayers[type.rawValue] = player
        //     currentAmbience = type
        // } catch {
        //     print("Failed to play ambience: \(error)")
        // }

        currentAmbience = type
        print("[AudioService] Would play ambience: \(type.rawValue)")
    }

    /// Stop all ambient sounds
    func stopAmbience() {
        for (_, player) in audioPlayers {
            player.stop()
        }
        audioPlayers.removeAll()
        currentAmbience = nil
        print("[AudioService] Stopped ambience")
    }

    /// Play a short purring sound effect (for cat interactions)
    func playPurr() {
        guard isEnabled else { return }

        // TODO: Implement actual purr sound playback
        // This is a stub that will be implemented when audio files are added
        //
        // Example implementation:
        // guard let url = Bundle.main.url(forResource: "purring", withExtension: "mp3") else {
        //     print("Purring sound file not found")
        //     return
        // }
        //
        // do {
        //     let player = try AVAudioPlayer(contentsOf: url)
        //     player.volume = 0.7
        //     player.play()
        //     audioPlayers["purr"] = player
        // } catch {
        //     print("Failed to play purr: \(error)")
        // }

        print("[AudioService] Would play purr sound")
    }

    // MARK: - Configuration

    /// Enable or disable audio
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled

        if !enabled {
            stopAmbience()
        }
    }

    /// Update ambience based on weather state
    func updateAmbienceForWeather(_ weather: WeatherState) {
        guard isEnabled else { return }

        switch weather {
        case .gentleRain:
            playAmbience(.rain)
        default:
            playAmbience(.cozy)
        }
    }
}
