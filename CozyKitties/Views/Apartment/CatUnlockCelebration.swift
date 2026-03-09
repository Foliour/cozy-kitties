import SwiftUI

/// Celebration overlay shown when a new cat is unlocked
struct CatUnlockCelebration: View {
    let cat: CatDefinition
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var confettiParticles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Confetti layer
            ForEach(confettiParticles) { particle in
                ConfettiView(particle: particle)
            }

            // Content card
            VStack(spacing: 24) {
                // Header
                Text("NEW CAT UNLOCKED!")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Cat icon placeholder (would show actual cat sprite)
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "cat.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)
                }
                .scaleEffect(showContent ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showContent)

                // Cat name
                Text(cat.name)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // Cat description
                Text(cat.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Streak info
                Text("\(cat.streakRequired) day streak achieved!")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.2))
                    .clipShape(Capsule())

                // Dismiss button
                Button(action: { dismiss() }) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.15))
            )
            .padding(.horizontal, 24)
            .scaleEffect(showContent ? 1.0 : 0.8)
            .opacity(showContent ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showContent = true
            }
            spawnConfetti()
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }

    private func spawnConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

        for i in 0..<50 {
            let particle = ConfettiParticle(
                id: i,
                color: colors.randomElement() ?? .orange,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                delay: Double.random(in: 0...0.5)
            )
            confettiParticles.append(particle)
        }
    }
}

// MARK: - Confetti

struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let x: CGFloat
    let delay: Double
}

struct ConfettiView: View {
    let particle: ConfettiParticle

    @State private var y: CGFloat = -20
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .position(x: particle.x, y: y)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeIn(duration: 2.5)
                    .delay(particle.delay)
                ) {
                    y = UIScreen.main.bounds.height + 50
                    rotation = Double.random(in: 360...720)
                }
                withAnimation(
                    .easeIn(duration: 1.0)
                    .delay(particle.delay + 1.5)
                ) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    CatUnlockCelebration(
        cat: CatDefinition(
            id: "whiskers",
            name: "Whiskers",
            appearance: "cat_tabby",
            streakRequired: 5,
            description: "A curious tabby who loves exploring"
        ),
        onDismiss: {}
    )
}
