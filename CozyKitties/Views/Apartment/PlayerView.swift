import SwiftUI
import UIKit

// MARK: - Player Direction & State

enum PlayerDirection: CaseIterable {
    case down, right, up, left
}

enum PlayerState {
    case idle, walking
}

// MARK: - Player View

/// Animated player sprite that can move around the scene
/// Uses a 1024x1024 sprite sheet (16x16 grid of 64x64 frames)
struct PlayerView: View {
    let position: CGPoint
    let direction: PlayerDirection
    let isWalking: Bool
    let displayScale: CGFloat

    @State private var currentFrame: Int = 0
    @State private var animationTimer: Timer?
    @State private var frames: [UIImage] = []

    // Sprite sheet configuration - 16x16 grid of 64x64 frames
    private let frameSize: CGFloat = 64
    private let gridColumns: Int = 16
    private let walkFPS: Double = 8

    var body: some View {
        Group {
            if !frames.isEmpty && currentFrame < frames.count {
                Image(uiImage: frames[currentFrame])
                    .interpolation(.none)
                    .resizable()
                    .frame(width: frameSize * displayScale, height: frameSize * displayScale)
                    .scaleEffect(x: direction == .left ? -1 : 1, y: 1)
            } else {
                // Fallback while loading
                Image(systemName: "figure.walk")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                    .frame(width: frameSize * displayScale, height: frameSize * displayScale)
            }
        }
        .position(position)
        .onAppear {
            loadFrames()
        }
        .onChange(of: direction) { _, _ in
            loadFrames()
        }
        .onChange(of: isWalking) { _, newValue in
            loadFrames()
            if newValue {
                startAnimation()
            } else {
                stopAnimation()
                currentFrame = 0
            }
        }
        .onDisappear {
            stopAnimation()
        }
    }

    // MARK: - Frame Loading

    /// Load frames for current direction and state
    private func loadFrames() {
        guard let spriteSheet = loadSpriteSheet() else { return }

        let frameIndices = getFrameIndices()
        var loadedFrames: [UIImage] = []

        for index in frameIndices {
            let row = index / gridColumns
            let col = index % gridColumns
            if let frame = extractFrame(from: spriteSheet, row: row, col: col) {
                loadedFrames.append(frame)
            }
        }

        frames = loadedFrames
        currentFrame = 0
    }

    /// Get sprite sheet cell indices for current state/direction
    /// Based on standard RPG sprite sheet layout:
    /// - Row 0: Idle poses (down at col 0, up at col 1, etc.)
    /// - Rows 3-4: Walk animations
    private func getFrameIndices() -> [Int] {
        if isWalking {
            switch direction {
            case .down:
                // Walk down: row 3, cols 0-2 (cells 48-50)
                return [48, 49, 50]
            case .up:
                // Walk up: row 3, cols 5-6 (cells 53-54)
                return [53, 54]
            case .right, .left:
                // Walk right/left: row 4, cols 0-5 (cells 64-69)
                return [64, 65, 66, 67, 68, 69]
            }
        } else {
            // Idle poses
            switch direction {
            case .down:
                return [0]   // Row 0, Col 0
            case .up:
                return [16]  // Row 1, Col 0
            case .right, .left:
                return [32]  // Row 2, Col 0
            }
        }
    }

    private func loadSpriteSheet() -> UIImage? {
        if let path = Bundle.main.path(forResource: "character", ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return UIImage(named: "character")
    }

    private func extractFrame(from sheet: UIImage, row: Int, col: Int) -> UIImage? {
        guard let cgImage = sheet.cgImage else { return nil }

        let frameRect = CGRect(
            x: CGFloat(col) * frameSize,
            y: CGFloat(row) * frameSize,
            width: frameSize,
            height: frameSize
        )

        guard let croppedCGImage = cgImage.cropping(to: frameRect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: .up)
    }

    // MARK: - Animation

    private func startAnimation() {
        guard frames.count > 1 else { return }
        stopAnimation()

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / walkFPS, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % frames.count
        }
    }

    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.3)
        PlayerView(
            position: CGPoint(x: 150, y: 150),
            direction: .down,
            isWalking: true,
            displayScale: 2.0
        )
    }
    .frame(width: 300, height: 300)
}
