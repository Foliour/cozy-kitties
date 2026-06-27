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
            #if DEBUG
            print("Failed to setup audio session: \(error)")
            #endif
        }
    }

    // MARK: - Ambience Playback

    /// Start playing ambient sounds
    func playAmbience(_ type: AmbienceType = .cozy) {
        guard isEnabled else { return }

        if currentAmbience != type {
            stopAmbience()
        }

        // TODO: Implement actual audio file loading
        currentAmbience = type
        #if DEBUG
        print("[AudioService] Would play ambience: \(type.rawValue)")
        #endif
    }

    /// Stop all ambient sounds
    func stopAmbience() {
        for (_, player) in audioPlayers {
            player.stop()
        }
        audioPlayers.removeAll()
        currentAmbience = nil
        #if DEBUG
        print("[AudioService] Stopped ambience")
        #endif
    }

    /// Play a short purring sound effect (for cat interactions)
    func playPurr() {
        guard isEnabled else { return }

        // TODO: Implement actual purr sound playback
        #if DEBUG
        print("[AudioService] Would play purr sound")
        #endif
    }

    // MARK: - Configuration

    /// Enable or disable audio
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled

        if !enabled {
            stopAmbience()
        }
    }
}
