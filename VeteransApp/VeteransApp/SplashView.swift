import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scaleIn: CGFloat = 0.85
    @State private var opacityIn: Double = 0

    var body: some View {
        if isActive {
            ContentView()
        } else {
            splash
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        scaleIn = 1.0
                        opacityIn = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            isActive = true
                        }
                    }
                }
        }
    }

    var splash: some View {
        ZStack {
            // ─── Background ───────────────────────────────────────────────
            Color(red: 0.95, green: 0.92, blue: 0.82) // warm parchment
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ─── Main card ────────────────────────────────────────────
                ZStack {
                    // Hard shadow layer (neobrutalism offset)
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.black)
                        .frame(width: 300, height: 200)
                        .offset(x: 6, y: 6)

                    // Card face
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(red: 0.36, green: 0.54, blue: 0.66)) // medal sky blue
                        .frame(width: 300, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .overlay(
                            VStack(spacing: 12) {
                                Text("🇺🇸")
                                    .font(.system(size: 44))

                                Text("TROOP\nCOMPANION")
                                    .font(.system(size: 26, weight: .black, design: .monospaced))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .lineSpacing(2)

                                // Neobrutalist tag strip
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(height: 32)
                                        .offset(x: 3, y: 3)
                                    Rectangle()
                                        .fill(Color(red: 0.85, green: 0.70, blue: 0.20)) // medal gold
                                        .frame(height: 32)
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                                    Text("THIS IS YOUR SPLASH SCREEN")
                                        .font(.system(size: 10, weight: .black, design: .monospaced))
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding()
                        )
                }
                .scaleEffect(scaleIn)
                .opacity(opacityIn)

                Spacer()

                // ─── Branding footer ──────────────────────────────────────
                Text("Your mission. Your wellness.")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.black.opacity(0.5))
                    .padding(.bottom, 48)
                    .opacity(opacityIn)
            }
        }
    }
}

#Preview {
    SplashView()
}
