# Asset Management Guide
## Cozy Kitties Health Tracker

**Purpose:** Prevent agentic development chaos with sprites, animations, and scenes.

---

## The Problems This Solves

| Problem | Cause | Solution |
|---------|-------|----------|
| Agent creates new sprites instead of using existing | No manifest of what exists | `ASSETS.yaml` manifest |
| Duplicate entities across features | Assets referenced by path, not ID | Asset Registry pattern |
| Tiled layers get lost | No documentation of layer structure | `SCENE_SPEC.yaml` |
| Agent doesn't know sprite has animation | Metadata not machine-readable | Animation metadata in manifest |

---

## Core Principle: Single Source of Truth

```
ASSETS.yaml (manifest)
    ↓
AssetRegistry.swift (loads manifest)
    ↓
All code references assets by ID
    ↓
Agent reads ASSETS.yaml before ANY asset work
```

**Rule:** If it's not in `ASSETS.yaml`, it doesn't exist. If you add an asset, add it to the manifest FIRST.

---

## Directory Structure

```
CozyKitties/
├── Assets.xcassets/           # Xcode asset catalog (colors, app icon)
├── Resources/
│   ├── ASSETS.yaml            # THE MANIFEST - source of truth
│   ├── SCENE_SPEC.yaml        # Scene/tilemap layer documentation
│   │
│   ├── Sprites/
│   │   ├── Cats/
│   │   │   ├── mochi.png           # Static or sprite sheet
│   │   │   ├── mochi.json          # Animation data (if animated)
│   │   │   ├── shadow.png
│   │   │   └── ...
│   │   │
│   │   ├── Plants/
│   │   │   ├── pothos_stage0.png
│   │   │   ├── pothos_stage1.png
│   │   │   └── ...
│   │   │
│   │   └── UI/
│   │       ├── tab_home.png
│   │       └── ...
│   │
│   ├── Scenes/
│   │   ├── apartment.tmx           # Tiled map file
│   │   ├── apartment.json          # Exported from Tiled
│   │   └── apartment_tileset.png   # Tileset image
│   │
│   └── Audio/
│       ├── purr.mp3
│       └── rain_ambience.mp3
```

---

## ASSETS.yaml - The Manifest

This is the **single source of truth**. Agents MUST read this before any asset work.

```yaml
# ASSETS.yaml - Cozy Kitties Asset Manifest
# IMPORTANT: All assets must be registered here
# Agents: READ THIS FILE before creating or modifying any assets

version: "1.0"
last_updated: "2026-03-07"

# =============================================================================
# CATS - Sprite assets for cat characters
# =============================================================================
cats:
  mochi:
    id: "cat_mochi"
    display_name: "Mochi"
    file: "Sprites/Cats/mochi.png"
    type: sprite_sheet  # or "static" if single image
    frame_size: {width: 64, height: 64}
    animations:
      idle:
        frames: [0, 1, 2, 3]
        fps: 4
        loop: true
      sleep:
        frames: [4, 5, 6, 7]
        fps: 2
        loop: true
      play:
        frames: [8, 9, 10, 11, 12, 13]
        fps: 8
        loop: true
    colors:
      primary: "#FFFFFF"
      secondary: "#F5F5F5"
    notes: "White fluffy cat. Starter cat, always unlocked."

  shadow:
    id: "cat_shadow"
    display_name: "Shadow"
    file: "Sprites/Cats/shadow.png"
    type: sprite_sheet
    frame_size: {width: 64, height: 64}
    animations:
      idle:
        frames: [0, 1, 2, 3]
        fps: 4
        loop: true
      sleep:
        frames: [4, 5, 6, 7]
        fps: 2
        loop: true
    colors:
      primary: "#1A1A1A"
      secondary: "#333333"
    notes: "Sleek black cat. Unlocked at 5-day streak."

  # ... repeat for all 10 cats

# =============================================================================
# PLANTS - Sprite assets for plant growth stages
# =============================================================================
plants:
  pothos:
    id: "plant_pothos"
    display_name: "Pothos"
    type: multi_stage  # Multiple separate images per stage
    stages:
      - stage: 0
        file: "Sprites/Plants/pothos_stage0.png"
        size: {width: 32, height: 32}
      - stage: 1
        file: "Sprites/Plants/pothos_stage1.png"
        size: {width: 32, height: 48}
      - stage: 2
        file: "Sprites/Plants/pothos_stage2.png"
        size: {width: 48, height: 64}
      - stage: 3
        file: "Sprites/Plants/pothos_stage3.png"
        size: {width: 64, height: 96}
    notes: "Trailing vine plant. Grows with good sleep."

  # ... repeat for all 5 plants

# =============================================================================
# SCENE - Apartment background and tilemap
# =============================================================================
scene:
  apartment:
    id: "scene_apartment"
    type: tilemap  # or "static_image"
    tiled_file: "Scenes/apartment.tmx"
    exported_json: "Scenes/apartment.json"
    tileset: "Scenes/apartment_tileset.png"
    tile_size: {width: 16, height: 16}
    map_size: {width: 24, height: 40}  # in tiles
    pixel_size: {width: 384, height: 640}  # actual render size
    layers:
      - name: "floor"
        z_index: 0
        type: tile_layer
        notes: "Base floor tiles"
      - name: "walls"
        z_index: 1
        type: tile_layer
        notes: "Wall tiles"
      - name: "furniture"
        z_index: 2
        type: tile_layer
        notes: "Static furniture (couch, shelf, etc.)"
      - name: "decorations"
        z_index: 3
        type: tile_layer
        notes: "Small decorations on furniture"
      - name: "cat_positions"
        z_index: 100
        type: object_layer
        notes: "Spawn points for cats (invisible)"
      - name: "plant_positions"
        z_index: 101
        type: object_layer
        notes: "Positions for plants (invisible)"
    notes: "Main apartment scene. Designed in Tiled."

# =============================================================================
# WEATHER - Window overlay sprites
# =============================================================================
weather:
  sunny:
    id: "weather_sunny"
    file: "Sprites/Weather/sunny.png"
    type: static
    size: {width: 128, height: 96}
    notes: "Bright sunny sky with sun"

  cloudy:
    id: "weather_cloudy"
    file: "Sprites/Weather/cloudy.png"
    type: static
    size: {width: 128, height: 96}

  rainy:
    id: "weather_rainy"
    file: "Sprites/Weather/rainy.png"
    type: animated
    frame_size: {width: 128, height: 96}
    animations:
      rain:
        frames: [0, 1, 2, 3]
        fps: 6
        loop: true
    notes: "Rain animation for window"

# =============================================================================
# UI - Interface elements
# =============================================================================
ui:
  # Add UI sprites as needed

# =============================================================================
# AUDIO
# =============================================================================
audio:
  purr:
    id: "audio_purr"
    file: "Audio/purr.mp3"
    type: sfx
    duration_seconds: 2.5
    notes: "Cat purring sound for tapping cats"

  rain_ambience:
    id: "audio_rain"
    file: "Audio/rain_ambience.mp3"
    type: music
    loop: true
    notes: "Ambient rain for rainy weather"

# =============================================================================
# ASSET SOURCES - Where assets came from (for licensing/attribution)
# =============================================================================
sources:
  - name: "Cozy Cats Pack"
    url: "https://itch.io/example"  # Replace with actual URL
    license: "CC-BY"
    used_for: ["mochi", "shadow", "marmalade", "luna", "biscuit"]
    attribution: "Art by [Artist Name]"

  - name: "Indoor Plants Pack"
    url: "https://itch.io/example"
    license: "Royalty-free"
    used_for: ["pothos", "succulent", "monstera", "fern", "flowers"]
```

---

## SCENE_SPEC.yaml - Tiled Layer Documentation

For Tiled maps, document EXACTLY what each layer does:

```yaml
# SCENE_SPEC.yaml - Apartment Scene Specification
# IMPORTANT: When exporting from Tiled, ALL layers must be included

apartment:
  export_format: json
  export_settings:
    embed_tilesets: false
    resolve_object_properties: true

  layers:
    # TILE LAYERS (render order bottom to top)
    - name: floor
      type: tile
      z_order: 0
      required: true
      description: "Wood floor tiles. Must cover entire map."

    - name: walls
      type: tile
      z_order: 1
      required: true
      description: "Cream-colored walls. Edges of room."

    - name: furniture
      type: tile
      z_order: 2
      required: true
      description: "Couch, bookshelf, table, rug, etc."

    - name: furniture_front
      type: tile
      z_order: 3
      required: false
      description: "Front parts of furniture that should render OVER cats."

    - name: window
      type: tile
      z_order: 4
      required: true
      description: "Window frame. Weather renders BEHIND this."

    # OBJECT LAYERS (spawn points, not rendered)
    - name: cat_spawns
      type: object
      z_order: -1  # Not rendered
      required: true
      objects:
        - name: "spawn_mochi"
          type: point
          description: "Where Mochi spawns by default"
        - name: "spawn_generic_1"
          type: point
          description: "Generic cat spawn point 1"
        # ... up to 10 spawn points

    - name: plant_positions
      type: object
      z_order: -1
      required: true
      objects:
        - name: "plant_pothos"
          type: point
        - name: "plant_succulent"
          type: point
        # ... all 5 plant positions

    - name: window_area
      type: object
      z_order: -1
      required: true
      objects:
        - name: "weather_overlay"
          type: rect
          description: "Rectangle where weather animation renders"

  export_checklist:
    - "All layers visible and included"
    - "Object layers have correct names"
    - "Tileset embedded or path correct"
    - "Export as JSON, not TMX (for easier parsing)"
```

---

## AssetRegistry.swift - Loading from Manifest

```swift
import Foundation

// Asset types matching ASSETS.yaml structure
struct CatAsset: Codable {
    let id: String
    let displayName: String
    let file: String
    let type: String
    let frameSize: Size?
    let animations: [String: AnimationData]?
    let notes: String?

    struct Size: Codable {
        let width: Int
        let height: Int
    }

    struct AnimationData: Codable {
        let frames: [Int]
        let fps: Int
        let loop: Bool
    }
}

struct AssetManifest: Codable {
    let version: String
    let cats: [String: CatAsset]
    let plants: [String: PlantAsset]
    let scene: [String: SceneAsset]
    // ... etc
}

@Observable
final class AssetRegistry {
    static let shared = AssetRegistry()

    private var manifest: AssetManifest?

    func load() {
        guard let url = Bundle.main.url(forResource: "ASSETS", withExtension: "yaml"),
              let data = try? Data(contentsOf: url) else {
            fatalError("ASSETS.yaml not found - check Resources folder")
        }
        // Parse YAML (use Yams or similar)
        // self.manifest = parsed result
    }

    // Get cat asset by ID - NEVER by file path
    func cat(_ id: String) -> CatAsset? {
        return manifest?.cats[id]
    }

    // Get sprite image for cat
    func catImage(_ id: String) -> UIImage? {
        guard let cat = cat(id) else { return nil }
        return UIImage(named: cat.file)
    }

    // ... similar for plants, scenes, etc.
}
```

---

## Rules for Agents

### Before ANY Asset Work, Read:
1. `Resources/ASSETS.yaml` - What assets exist
2. `Resources/SCENE_SPEC.yaml` - Scene layer structure
3. This document

### When Adding a New Asset:
1. **FIRST** add entry to `ASSETS.yaml`
2. **THEN** add the actual file to `Resources/Sprites/` or appropriate folder
3. **THEN** update code to use the new asset via `AssetRegistry`

### When Modifying an Existing Asset:
1. Check `ASSETS.yaml` for current metadata
2. Update the file in place (same path)
3. Update metadata in `ASSETS.yaml` if changed (frame count, etc.)
4. Do NOT create a new file with different name

### When Working with Tiled Maps:
1. Read `SCENE_SPEC.yaml` for layer structure
2. ALL layers listed must be present in export
3. Export as JSON format
4. Verify object layers have correct names

---

## Itch.io Asset Integration Workflow

When you buy assets from Itch.io:

### 1. Organize the Download
```
Downloads/
└── CozyKitsPack/
    ├── cats/
    │   ├── white_cat_idle.png      # Sprite sheet
    │   ├── white_cat_sleep.png
    │   ├── black_cat_idle.png
    │   └── ...
    ├── license.txt
    └── readme.txt
```

### 2. Map to Our Cats
Create a mapping file:
```yaml
# asset_mapping.yaml (temporary, for import)
source_pack: "CozyKitsPack"
mappings:
  - source: "cats/white_cat_*.png"
    target_id: "mochi"
    rename_to: "Sprites/Cats/mochi.png"
    notes: "Combine into single sprite sheet if needed"

  - source: "cats/black_cat_*.png"
    target_id: "shadow"
    rename_to: "Sprites/Cats/shadow.png"
```

### 3. Import and Register
1. Copy files to `Resources/Sprites/Cats/`
2. Rename to match our naming convention
3. Add entries to `ASSETS.yaml`
4. Update attribution in `ASSETS.yaml` sources section

### 4. Verify
- Build and run
- Check each cat renders correctly
- Verify animations play

---

## Common Mistakes to Avoid

| Mistake | Why It's Bad | What to Do Instead |
|---------|--------------|---------------------|
| Reference sprite by file path in code | Path changes break everything | Use `AssetRegistry.cat("mochi")` |
| Create new file for existing entity | Duplicates, confusion | Check `ASSETS.yaml` first |
| Export Tiled without all layers | Missing furniture, wrong z-order | Follow `SCENE_SPEC.yaml` checklist |
| Add asset without manifest entry | Agent won't know it exists | Add to `ASSETS.yaml` FIRST |
| Use different naming convention | Can't find assets | Follow existing pattern exactly |

---

## Quick Reference

```yaml
# To find an asset: Look in ASSETS.yaml
# To add an asset: Add to ASSETS.yaml FIRST, then add file
# To modify an asset: Same file path, update ASSETS.yaml metadata
# To use an asset in code: AssetRegistry.shared.cat("id")
# To export Tiled: Follow SCENE_SPEC.yaml exactly
```

---

*This document should be read by agents before any asset-related work.*
