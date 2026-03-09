import SwiftUI
import UIKit

/// Individual cat view with animated sprites
/// Loads sprite sheets, slices into frames, and swaps between them
struct CatView: View {
    let cat: CatDefinition
    let isUnlocked: Bool
    var onTap: (() -> Void)? = nil

    @State private var showingName = false
    @State private var currentFrame: Int = 0
    @State private var animationTimer: Timer?
    @State private var idleFrames: [UIImage] = []
    @State private var pounceFrames: [UIImage] = []
    @State private var sitFrames: [UIImage] = []

    // Random properties determined once per cat instance
    @State private var facingLeft: Bool = false
    @State private var animationType: AnimationType = .idle
    @State private var hasInitialized: Bool = false

    // Animation state for pounce combo pattern
    @State private var comboPhase: Int = 0  // 0 to (idleCadence-1) = idle, idleCadence = pounce
    @State private var idleCadence: Int = 2  // Number of idle loops before pounce (unique per cat)

    enum AnimationType {
        case idle       // Just idle animation
        case pounce     // variable idle-pounce combo (cadence varies per cat)
        case sit        // idle-idle-sit combo
    }

    // Sprite sheet configuration - frames are 48x48 pixels
    private let frameWidth: CGFloat = 48
    private let frameHeight: CGFloat = 48
    private let animationFPS: Double = 8
    private let displayScale: CGFloat = 1.6

    var body: some View {
        VStack(spacing: 4) {
            // Animated cat sprite
            if isUnlocked && !idleFrames.isEmpty {
                SpriteAnimationView(
                    frames: currentAnimationFrames,
                    currentFrame: currentFrame,
                    displayScale: displayScale
                )
                .scaleEffect(x: facingLeft ? -1 : 1, y: 1)
                .onAppear {
                    startAnimation()
                }
                .onDisappear {
                    stopAnimation()
                }
            } else if isUnlocked {
                // Loading state
                Color.clear
                    .frame(width: frameWidth * displayScale, height: frameHeight * displayScale)
                    .onAppear {
                        initializeRandomProperties()
                        loadFrames()
                    }
            } else {
                // Fallback for locked cats
                Image(systemName: "cat.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.gray.opacity(0.5))
            }

            // Name label (shown on tap)
            if showingName {
                Text(cat.name)
                    .font(.caption)
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showingName.toggle()
            }
            onTap?()

            // Auto-hide name after 2 seconds
            if showingName {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showingName = false
                    }
                }
            }
        }
    }

    /// Get current frames based on animation type and combo phase
    private var currentAnimationFrames: [UIImage] {
        switch animationType {
        case .idle:
            // Idle cats just loop idle forever
            return idleFrames
        case .sit:
            // Sit cats just loop sit forever (no alternating)
            return sitFrames.isEmpty ? idleFrames : sitFrames
        case .pounce:
            // Pounce cats alternate: idle loops, then pounce
            if comboPhase >= idleCadence {
                return pounceFrames.isEmpty ? idleFrames : pounceFrames
            }
            return idleFrames
        }
    }

    // MARK: - Initialization

    private func initializeRandomProperties() {
        guard !hasInitialized else { return }
        hasInitialized = true

        // Use cat ID for seeded randomness so it's consistent per cat
        // but different cats get different values
        var hasher = Hasher()
        hasher.combine(cat.id)
        hasher.combine("facing")
        let facingSeed = hasher.finalize()
        facingLeft = abs(facingSeed % 2) == 0

        hasher = Hasher()
        hasher.combine(cat.id)
        hasher.combine("animation")
        let animSeed = abs(hasher.finalize() % 3)
        switch animSeed {
        case 0:
            animationType = .idle
        case 1:
            animationType = .pounce
        case 2:
            animationType = .sit
        default:
            animationType = .idle
        }

        // Assign unique cadence for pounce cats based on roster index
        // Each pounce cat gets a different number of idle loops (2, 3, 4, etc.)
        if animationType == .pounce {
            if let rosterIndex = catRoster.firstIndex(where: { $0.id == cat.id }) {
                // Cadence starts at 2 and increases by roster index
                // This ensures no two cats have the same pounce rhythm
                idleCadence = 2 + rosterIndex
            }
        }
    }

    // MARK: - Sprite Loading

    private func loadFrames() {
        // Map cat appearance to sprite base name
        let spriteBaseName: String
        switch cat.appearance {
        case "cat_black":
            spriteBaseName = "Black"
        case "cat_orange_tabby":
            spriteBaseName = "OrangeTabby"
        case "cat_brown":
            spriteBaseName = "Brown"
        case "cat_white":
            spriteBaseName = "White"
        case "cat_siamese":
            spriteBaseName = "Siamese"
        case "cat_tuxedo":
            spriteBaseName = "Tuxedo"
        case "cat_calico":
            spriteBaseName = "Calico"
        default:
            return
        }

        // Load idle frames (always needed)
        if let idleImage = loadSprite(named: "\(spriteBaseName)-Idle") {
            idleFrames = sliceSpriteSheet(
                image: idleImage,
                frameWidth: frameWidth,
                frameHeight: frameHeight
            )
        }

        // Load action frames based on animation type
        switch animationType {
        case .pounce:
            if let pounceImage = loadSprite(named: "\(spriteBaseName)-Pounce") {
                pounceFrames = sliceSpriteSheet(
                    image: pounceImage,
                    frameWidth: frameWidth,
                    frameHeight: frameHeight
                )
            }
        case .sit:
            if let sitImage = loadSprite(named: "\(spriteBaseName)-Sit") {
                sitFrames = sliceSpriteSheet(
                    image: sitImage,
                    frameWidth: frameWidth,
                    frameHeight: frameHeight
                )
            }
        case .idle:
            break // No additional frames needed
        }
    }

    private func loadSprite(named name: String) -> UIImage? {
        if let path = Bundle.main.path(forResource: name, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "png") {
            return UIImage(contentsOfFile: url.path)
        }
        return UIImage(named: name)
    }

    // MARK: - Animation

    private func startAnimation() {
        stopAnimation()

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / animationFPS, repeats: true) { _ in
            advanceFrame()
        }
    }

    private func advanceFrame() {
        let frames = currentAnimationFrames
        guard !frames.isEmpty else { return }

        currentFrame += 1

        // Check if we completed a loop of the current animation
        if currentFrame >= frames.count {
            currentFrame = 0

            // Only pounce cats need phase transitions (idle-idle-...-pounce pattern)
            if animationType == .pounce {
                if comboPhase < idleCadence {
                    // Still in idle phases, advance to next
                    comboPhase += 1
                } else {
                    // Finished pounce, reset to idle phase 0
                    comboPhase = 0
                }
            }
            // Idle and sit cats just loop their animation continuously
        }
    }

    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

// MARK: - Sprite Animation View

struct SpriteAnimationView: View {
    let frames: [UIImage]
    let currentFrame: Int
    let displayScale: CGFloat

    var body: some View {
        if currentFrame < frames.count {
            Image(uiImage: frames[currentFrame])
                .interpolation(.none)
                .resizable()
                .frame(
                    width: frames[currentFrame].size.width * displayScale,
                    height: frames[currentFrame].size.height * displayScale
                )
        }
    }
}

// MARK: - Sprite Sheet Slicer

func sliceSpriteSheet(image: UIImage, frameWidth: CGFloat, frameHeight: CGFloat) -> [UIImage] {
    guard let cgImage = image.cgImage else { return [] }

    let frameCount = Int(image.size.width / frameWidth)
    var frames: [UIImage] = []

    for i in 0..<frameCount {
        let frameX = CGFloat(i) * frameWidth
        let frameRect = CGRect(
            x: frameX,
            y: 0,
            width: frameWidth,
            height: frameHeight
        )

        if let croppedCGImage = cgImage.cropping(to: frameRect) {
            let frameImage = UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: .up)
            frames.append(frameImage)
        }
    }

    return frames
}

#Preview("Unlocked Cat") {
    CatView(
        cat: catRoster[0],
        isUnlocked: true
    )
    .padding()
    .background(Color.green.opacity(0.3))
}

#Preview("Locked Cat") {
    CatView(
        cat: catRoster[2],
        isUnlocked: false
    )
    .padding()
    .background(Color.green.opacity(0.3))
}
