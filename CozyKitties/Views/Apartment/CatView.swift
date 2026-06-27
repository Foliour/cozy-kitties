import SwiftUI
import UIKit

/// Animation types for cats - shared between ApartmentView and CatView
enum CatAnimationType {
    case idle       // Just idle animation
    case pounce     // variable idle-pounce combo (cadence varies per cat)
    case sit        // sitting animation
    case sleep      // sleeping animation
}

/// Individual cat view with animated sprites
/// Loads sprite sheets, slices into frames, and swaps between them
struct CatView: View {
    let cat: CatDefinition
    let isUnlocked: Bool
    var assignedAnimation: CatAnimationType = .idle
    var assignedFacingLeft: Bool = false
    var onPetted: ((String) -> Void)? = nil

    @State private var showHeart = false
    @State private var currentFrame: Int = 0
    @State private var animationTimer: Timer?
    @State private var idleFrames: [UIImage] = []
    @State private var pounceFrames: [UIImage] = []
    @State private var sitFrames: [UIImage] = []
    @State private var sleepFrames: [UIImage] = []

    // Animation state for pounce combo pattern
    @State private var comboPhase: Int = 0  // 0 to (idleCadence-1) = idle, idleCadence = pounce
    @State private var idleCadence: Int = 2  // Number of idle loops before pounce (unique per cat)

    // Sprite sheet configuration - frames are 48x48 pixels
    private let frameWidth: CGFloat = 48
    private let frameHeight: CGFloat = 48
    private let animationFPS: Double = 8
    private let displayScale: CGFloat = 1.6

    var body: some View {
        ZStack {
            // Animated cat sprite
            if isUnlocked && !idleFrames.isEmpty {
                SpriteAnimationView(
                    frames: currentAnimationFrames,
                    currentFrame: currentFrame,
                    displayScale: displayScale
                )
                .scaleEffect(x: assignedFacingLeft ? -1 : 1, y: 1)
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
                        initializePounce()
                        loadFrames()
                    }
            } else {
                // Fallback for locked cats
                Image(systemName: "cat.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.gray.opacity(0.5))
            }

            // Heart animation above sprite
            if showHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.pink)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .offset(y: -frameHeight * displayScale / 2 + 4)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isUnlocked ? cat.name : "Locked cat")
        .accessibilityHint(isUnlocked ? "Double-tap to pet" : "Walk more steps to unlock")
        .onTapGesture {
            guard isUnlocked, !showHeart else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showHeart = true
            }
            onPetted?(cat.name)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showHeart = false
                }
            }
        }
    }

    /// Get current frames based on animation type and combo phase
    private var currentAnimationFrames: [UIImage] {
        switch assignedAnimation {
        case .idle:
            // Idle cats just loop idle forever
            return idleFrames
        case .sit:
            // Sit cats just loop sit forever (no alternating)
            return sitFrames.isEmpty ? idleFrames : sitFrames
        case .sleep:
            // Sleep cats just loop sleep forever
            return sleepFrames.isEmpty ? idleFrames : sleepFrames
        case .pounce:
            // Pounce cats alternate: idle loops, then pounce
            if comboPhase >= idleCadence {
                return pounceFrames.isEmpty ? idleFrames : pounceFrames
            }
            return idleFrames
        }
    }

    // MARK: - Initialization

    /// Set a random pounce cadence for pounce-type cats
    private func initializePounce() {
        if assignedAnimation == .pounce {
            idleCadence = Int.random(in: 2...5)
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
        case "cat_bw":
            spriteBaseName = "BW"
        case "cat_gray":
            spriteBaseName = "Gray"
        case "cat_gray_tabby":
            spriteBaseName = "GrayTabby"
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
        switch assignedAnimation {
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
        case .sleep:
            if let sleepImage = loadSprite(named: "\(spriteBaseName)-Sleep") {
                sleepFrames = sliceSpriteSheet(
                    image: sleepImage,
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
            if assignedAnimation == .pounce {
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
