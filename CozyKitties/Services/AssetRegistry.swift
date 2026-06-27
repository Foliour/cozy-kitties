import Foundation
import SwiftUI
import UIKit
import Observation

// MARK: - Asset Registry
// Single source of truth for all game assets.

@Observable
final class AssetRegistry {
    static let shared = AssetRegistry()

    private init() {
        loadAssets()
    }

    // MARK: - Asset Collections

    private(set) var cats: [String: CatAsset] = [:]
    private(set) var audio: [String: AudioAsset] = [:]
    private(set) var scene: SceneAsset?

    // MARK: - Loading

    private func loadAssets() {
        loadCatAssets()
        loadAudioAssets()
        loadSceneAsset()
    }

    // MARK: - Cat Assets

    private func loadCatAssets() {
        cats = [
            "mochi": CatAsset(
                id: "cat_mochi",
                displayName: "Mochi",
                file: "Sprites/Cats/mochi",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#FFFFFF", secondary: "#F5F5F5")
            ),
            "shadow": CatAsset(
                id: "cat_shadow",
                displayName: "Shadow",
                file: "Sprites/Cats/shadow",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#1A1A1A", secondary: "#333333")
            ),
            "marmalade": CatAsset(
                id: "cat_marmalade",
                displayName: "Marmalade",
                file: "Sprites/Cats/marmalade",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#FF8C00", secondary: "#FFA500")
            ),
            "luna": CatAsset(
                id: "cat_luna",
                displayName: "Luna",
                file: "Sprites/Cats/luna",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#4A4A4A", secondary: "#6A6A6A")
            ),
            "biscuit": CatAsset(
                id: "cat_biscuit",
                displayName: "Biscuit",
                file: "Sprites/Cats/biscuit",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#D2B48C", secondary: "#C4A77D")
            ),
            "patches": CatAsset(
                id: "cat_patches",
                displayName: "Patches",
                file: "Sprites/Cats/patches",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#FFFFFF", secondary: "#FF8C00")
            ),
            "midnight": CatAsset(
                id: "cat_midnight",
                displayName: "Midnight",
                file: "Sprites/Cats/midnight",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#191970", secondary: "#000080")
            ),
            "ginger": CatAsset(
                id: "cat_ginger",
                displayName: "Ginger",
                file: "Sprites/Cats/ginger",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#B7410E", secondary: "#CD5C5C")
            ),
            "snowball": CatAsset(
                id: "cat_snowball",
                displayName: "Snowball",
                file: "Sprites/Cats/snowball",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#FFFAFA", secondary: "#F0F0F0")
            ),
            "cinnamon": CatAsset(
                id: "cat_cinnamon",
                displayName: "Cinnamon",
                file: "Sprites/Cats/cinnamon",
                type: .spriteSheet,
                frameSize: CGSize(width: 64, height: 64),
                animations: [
                    "idle": AnimationData(frames: [0, 1, 2, 3], fps: 4, loop: true),
                    "sleep": AnimationData(frames: [4, 5, 6, 7], fps: 2, loop: true),
                    "play": AnimationData(frames: [8, 9, 10, 11, 12, 13], fps: 8, loop: true)
                ],
                colors: AssetColors(primary: "#D2691E", secondary: "#8B4513")
            )
        ]
    }

    // MARK: - Audio Assets

    private func loadAudioAssets() {
        audio = [
            "purr": AudioAsset(
                id: "audio_purr",
                file: "Audio/purr",
                type: .sfx,
                durationSeconds: 2.5,
                loop: false
            ),
            "meow": AudioAsset(
                id: "audio_meow",
                file: "Audio/meow",
                type: .sfx,
                durationSeconds: 1.0,
                loop: false
            ),
            "cozy_music": AudioAsset(
                id: "audio_cozy",
                file: "Audio/cozy_music",
                type: .music,
                durationSeconds: nil,
                loop: true
            )
        ]
    }

    // MARK: - Scene Asset

    private func loadSceneAsset() {
        scene = SceneAsset(
            id: "scene_apartment",
            type: .tilemap,
            tiledFile: "Scenes/apartment.tmx",
            exportedJson: "Scenes/apartment.json",
            tileset: "Scenes/apartment_tileset",
            tileSize: CGSize(width: 16, height: 16),
            mapSizeTiles: CGSize(width: 24, height: 40),
            pixelSize: CGSize(width: 384, height: 640),
            layers: [
                SceneLayer(name: "floor", zIndex: 0, type: .tile),
                SceneLayer(name: "walls", zIndex: 1, type: .tile),
                SceneLayer(name: "furniture", zIndex: 2, type: .tile),
                SceneLayer(name: "furniture_front", zIndex: 3, type: .tile),
                SceneLayer(name: "cat_spawns", zIndex: -1, type: .object)
            ]
        )
    }

    // MARK: - Public API

    /// Get cat asset by key
    func cat(_ key: String) -> CatAsset? {
        cats[key]
    }

    /// Get cat image (placeholder until real sprites are added)
    func catImage(_ key: String) -> Image {
        if let asset = cats[key] {
            if let uiImage = UIImage(named: asset.file) {
                return Image(uiImage: uiImage)
            }
        }
        return Image(systemName: "cat.fill")
    }

    /// Get cat placeholder color
    func catColor(_ key: String) -> Color {
        guard let asset = cats[key],
              let hex = asset.colors?.primary else {
            return .gray
        }
        return Color(hex: hex)
    }

    /// Get audio asset by key
    func audioAsset(_ key: String) -> AudioAsset? {
        audio[key]
    }

    /// Check if an asset file exists in the bundle
    func assetExists(_ path: String) -> Bool {
        Bundle.main.path(forResource: path, ofType: nil) != nil
    }
}

// MARK: - Asset Models

struct CatAsset {
    let id: String
    let displayName: String
    let file: String
    let type: SpriteType
    let frameSize: CGSize
    let animations: [String: AnimationData]
    let colors: AssetColors?
}

struct AudioAsset {
    let id: String
    let file: String
    let type: AudioType
    let durationSeconds: Double?
    let loop: Bool
}

struct SceneAsset {
    let id: String
    let type: SceneType
    let tiledFile: String
    let exportedJson: String
    let tileset: String
    let tileSize: CGSize
    let mapSizeTiles: CGSize
    let pixelSize: CGSize
    let layers: [SceneLayer]
}

struct SceneLayer {
    let name: String
    let zIndex: Int
    let type: LayerType
}

struct AnimationData {
    let frames: [Int]
    let fps: Int
    let loop: Bool
}

struct AssetColors {
    let primary: String
    let secondary: String
}

// MARK: - Enums

enum SpriteType {
    case `static`
    case spriteSheet
    case animated
}

enum AudioType {
    case sfx
    case music
}

enum SceneType {
    case tilemap
    case staticImage
}

enum LayerType {
    case tile
    case object
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
