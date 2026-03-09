import Foundation
import SwiftUI
import UIKit
import Observation

// MARK: - Asset Registry
// Single source of truth for all game assets.
// Mirrors the structure defined in Resources/ASSETS.yaml

@Observable
final class AssetRegistry {
    static let shared = AssetRegistry()

    private init() {
        loadAssets()
    }

    // MARK: - Asset Collections

    private(set) var cats: [String: CatAsset] = [:]
    private(set) var plants: [String: PlantAsset] = [:]
    private(set) var weather: [String: WeatherAsset] = [:]
    private(set) var audio: [String: AudioAsset] = [:]
    private(set) var scene: SceneAsset?

    // MARK: - Loading

    private func loadAssets() {
        // Load cat assets
        loadCatAssets()

        // Load plant assets
        loadPlantAssets()

        // Load weather assets
        loadWeatherAssets()

        // Load audio assets
        loadAudioAssets()

        // Load scene asset
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

    // MARK: - Plant Assets

    private func loadPlantAssets() {
        plants = [
            "pothos": PlantAsset(
                id: "plant_pothos",
                displayName: "Pothos",
                type: .multiStage,
                stages: [
                    PlantStage(stage: 0, file: "Sprites/Plants/pothos_stage0", size: CGSize(width: 32, height: 32)),
                    PlantStage(stage: 1, file: "Sprites/Plants/pothos_stage1", size: CGSize(width: 32, height: 48)),
                    PlantStage(stage: 2, file: "Sprites/Plants/pothos_stage2", size: CGSize(width: 48, height: 64)),
                    PlantStage(stage: 3, file: "Sprites/Plants/pothos_stage3", size: CGSize(width: 64, height: 96))
                ]
            ),
            "succulent": PlantAsset(
                id: "plant_succulent",
                displayName: "Succulent",
                type: .multiStage,
                stages: [
                    PlantStage(stage: 0, file: "Sprites/Plants/succulent_stage0", size: CGSize(width: 24, height: 24)),
                    PlantStage(stage: 1, file: "Sprites/Plants/succulent_stage1", size: CGSize(width: 32, height: 32)),
                    PlantStage(stage: 2, file: "Sprites/Plants/succulent_stage2", size: CGSize(width: 40, height: 40)),
                    PlantStage(stage: 3, file: "Sprites/Plants/succulent_stage3", size: CGSize(width: 48, height: 48))
                ]
            ),
            "monstera": PlantAsset(
                id: "plant_monstera",
                displayName: "Monstera",
                type: .multiStage,
                stages: [
                    PlantStage(stage: 0, file: "Sprites/Plants/monstera_stage0", size: CGSize(width: 32, height: 32)),
                    PlantStage(stage: 1, file: "Sprites/Plants/monstera_stage1", size: CGSize(width: 48, height: 56)),
                    PlantStage(stage: 2, file: "Sprites/Plants/monstera_stage2", size: CGSize(width: 64, height: 80)),
                    PlantStage(stage: 3, file: "Sprites/Plants/monstera_stage3", size: CGSize(width: 80, height: 112))
                ]
            ),
            "fern": PlantAsset(
                id: "plant_fern",
                displayName: "Fern",
                type: .multiStage,
                stages: [
                    PlantStage(stage: 0, file: "Sprites/Plants/fern_stage0", size: CGSize(width: 24, height: 28)),
                    PlantStage(stage: 1, file: "Sprites/Plants/fern_stage1", size: CGSize(width: 36, height: 42)),
                    PlantStage(stage: 2, file: "Sprites/Plants/fern_stage2", size: CGSize(width: 48, height: 56)),
                    PlantStage(stage: 3, file: "Sprites/Plants/fern_stage3", size: CGSize(width: 60, height: 72))
                ]
            ),
            "flowers": PlantAsset(
                id: "plant_flowers",
                displayName: "Flowers",
                type: .multiStage,
                stages: [
                    PlantStage(stage: 0, file: "Sprites/Plants/flowers_stage0", size: CGSize(width: 24, height: 24)),
                    PlantStage(stage: 1, file: "Sprites/Plants/flowers_stage1", size: CGSize(width: 32, height: 40)),
                    PlantStage(stage: 2, file: "Sprites/Plants/flowers_stage2", size: CGSize(width: 40, height: 52)),
                    PlantStage(stage: 3, file: "Sprites/Plants/flowers_stage3", size: CGSize(width: 48, height: 64))
                ]
            )
        ]
    }

    // MARK: - Weather Assets

    private func loadWeatherAssets() {
        weather = [
            "sunny": WeatherAsset(
                id: "weather_sunny",
                file: "Sprites/Weather/sunny",
                type: .static,
                size: CGSize(width: 128, height: 96),
                animation: nil
            ),
            "cloudy": WeatherAsset(
                id: "weather_cloudy",
                file: "Sprites/Weather/cloudy",
                type: .static,
                size: CGSize(width: 128, height: 96),
                animation: nil
            ),
            "rainy": WeatherAsset(
                id: "weather_rainy",
                file: "Sprites/Weather/rainy",
                type: .animated,
                size: CGSize(width: 128, height: 96),
                animation: AnimationData(frames: [0, 1, 2, 3], fps: 6, loop: true)
            ),
            "stormy": WeatherAsset(
                id: "weather_stormy",
                file: "Sprites/Weather/stormy",
                type: .animated,
                size: CGSize(width: 128, height: 96),
                animation: AnimationData(frames: [0, 1, 2, 3, 4, 5], fps: 8, loop: true)
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
            "rain_ambience": AudioAsset(
                id: "audio_rain",
                file: "Audio/rain_ambience",
                type: .music,
                durationSeconds: nil,
                loop: true
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
                SceneLayer(name: "window", zIndex: 4, type: .tile),
                SceneLayer(name: "cat_spawns", zIndex: -1, type: .object),
                SceneLayer(name: "plant_positions", zIndex: -1, type: .object),
                SceneLayer(name: "window_area", zIndex: -1, type: .object)
            ]
        )
    }

    // MARK: - Public API

    /// Get cat asset by key (e.g., "mochi", "shadow")
    func cat(_ key: String) -> CatAsset? {
        cats[key]
    }

    /// Get cat image (placeholder until real sprites are added)
    func catImage(_ key: String) -> Image {
        // For now, return a system image placeholder
        // When sprites are added, this will load from the bundle
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

    /// Get plant asset by key
    func plant(_ key: String) -> PlantAsset? {
        plants[key]
    }

    /// Get plant image for a specific growth stage
    func plantImage(_ key: String, stage: Int) -> Image {
        if let asset = plants[key],
           let stageAsset = asset.stages.first(where: { $0.stage == stage }) {
            if let uiImage = UIImage(named: stageAsset.file) {
                return Image(uiImage: uiImage)
            }
        }
        return Image(systemName: "leaf.fill")
    }

    /// Get weather asset by key
    func weather(_ key: String) -> WeatherAsset? {
        self.weather[key]
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

struct PlantAsset {
    let id: String
    let displayName: String
    let type: PlantAssetType
    let stages: [PlantStage]
}

struct PlantStage {
    let stage: Int
    let file: String
    let size: CGSize
}

struct WeatherAsset {
    let id: String
    let file: String
    let type: SpriteType
    let size: CGSize
    let animation: AnimationData?
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

enum PlantAssetType {
    case multiStage
    case spriteSheet
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
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
