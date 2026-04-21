import SwiftUI

// MARK: - List View (Neo Brutalism)
struct BreathingExercisesListView: View {
    let theme: NeoTheme
    
    // Hardcoded color as requested: Home screen breathing button color (#e9eaf9)
    // From ContentView: Color(red: 233/255, green: 234/255, blue: 249/255)
    let buttonColor = Color(red: 233/255, green: 234/255, blue: 249/255)
    
    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Text("Breathing Exercises")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(theme.textColor)
                        .padding(.top, 20)
                    
                    Text("Select a breathing exercise to begin")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .padding(.bottom, 30)
                    
                    VStack(spacing: 20) {
                        
                        // Box Breathing
                        BreathingOptionTile(
                            title: "Box Breathing",
                            description: "A structured breath pattern to reset focus and steady the mind during tense moments.",
                            buttonColor: buttonColor,
                            destination: BreathingExerciseDetailView(
                                title: "Box Breathing",
                                baseSteps: [
                                    "Find a comfortable seated or lying down position.",
                                    "Inhale slowly and deeply through your nose for a count of 4",
                                    "Hold your breath for a count of 4",
                                    "Exhale slowly and completely through your mouth for a count of 4",
                                    "Hold your breath again for a count of 4"
                                ]
                            ).navigationBarBackButtonHidden(true)
                        )
                        
                        // Deep Breathing
                        BreathingOptionTile(
                            title: "Deep Breathing",
                            description: "Long, full breaths that ease physical tension and promote a sense of calm.",
                            buttonColor: buttonColor,
                            destination: BreathingExerciseDetailView(
                                title: "Deep Breathing",
                                baseSteps: [
                                    "Sit Comfortably or lie down.",
                                    "Place one hand on your stomach and one hand on your chest.",
                                    "Breathe in slowly through your nose. Feel your stomach expand as you inhale.\nIf you are breathing from the stomach, the hand on your chest shouldn't move. Focus on filling your lower lungs with air.",
                                    "Slowly exhale, releasing all the air through your mouth. Use your hand to feel your stomach fall as you exhale."
                                ]
                            ).navigationBarBackButtonHidden(true)
                        )
                        
                        // Wim Hof Breathing
                        BreathingOptionTile(
                            title: "Wim Hof Breathing",
                            description: "A powerful breathing method that energizes the body and builds resilience through controlled intensity.",
                            buttonColor: buttonColor,
                            destination: BreathingExerciseDetailView(
                                title: "Wim Hof Breathing",
                                baseSteps: [
                                    "Start by sitting or lying down in a comfortable, quiet place where you won’t be disturbed.",
                                    "Inhale deeply through your nose, expanding your belly as you breathe in. Then exhale fully through your mouth. Repeat this cycle for 30-40 breaths.",
                                    "Breath Retention: After your last exhale, let the air out fully and hold your breath as long as you can.",
                                    "Relax and let your body adjust to the sensation.",
                                    "Inhale deeply and hold your breath for about 15 seconds before exhaling. This completes one round."
                                ]
                            ).navigationBarBackButtonHidden(true)
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Meditating Person Graphic
                    if let uiImage = UIImage(named: "person-meditating.png") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .padding(.bottom, 20)
                    } else if let altImage = UIImage(named: "person-meditating") {
                        Image(uiImage: altImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BreathingOptionTile<Destination: View>: View {
    let title: String
    let description: String
    let buttonColor: Color
    let destination: Destination
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(title.uppercased())
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: isExpanded ? "checkmark.circle.fill" : "questionmark.circle")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.black)
                        }
                        
                        Text(description)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .lineLimit(isExpanded ? nil : 2)
                            .fixedSize(horizontal: false, vertical: isExpanded)
                    }
                }
                .padding(20)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                NavigationLink(destination: destination) {
                    Text("START EXERCISE →")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(NeoButtonStyle(backgroundColor: .white, shadowColor: .black))
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .neobrutal(backgroundColor: buttonColor, shadowColor: .black)
    }
}


// MARK: - Detail View (Serene / Calm)
struct BreathingExerciseDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let title: String
    let baseSteps: [String]
    
    @State private var currentStepIndex: Int = 0
    @State private var pulseState: Bool = false
    @State private var showExitAlert: Bool = false
    
    var allSteps: [String] {
        if baseSteps.isEmpty { return [] }
        let repeatSteps = Array(repeating: Array(baseSteps.dropFirst()), count: 3).flatMap { $0 }
        return [baseSteps[0]] + repeatSteps
    }
    
    var body: some View {
        ZStack {
            // Calm Background Gradient
            LinearGradient(
                colors: [
                    Color(red: 247/255, green: 250/255, blue: 255/255),
                    Color(red: 235/255, green: 242/255, blue: 250/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Gentle pulsing circle
            Circle()
                .fill(Color(red: 210/255, green: 225/255, blue: 240/255))
                .scaleEffect(pulseState ? 1.4 : 1.0)
                .opacity(pulseState ? 0.4 : 0.8)
                .blur(radius: 40)
                .padding(40)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: pulseState)
                .onAppear {
                    pulseState = true
                }
            
            VStack {
                HStack {
                    Button(action: {
                        showExitAlert = true
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(white: 0.4))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color(white: 0.4))
                    }
                    .padding()
                    Spacer()
                }
                
                Text(title)
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(Color(white: 0.2))
                    .padding(.top, 10)
                
                Spacer()
                
                if currentStepIndex < allSteps.count {
                    Text(allSteps[currentStepIndex])
                        .font(.system(size: 22, weight: .regular, design: .serif))
                        .foregroundColor(Color(white: 0.25))
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal, 30)
                        .id(currentStepIndex)
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.95)), removal: .opacity))
                } else {
                    Text("You’ve completed the exercise!")
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(Color(white: 0.25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
                
                if currentStepIndex < allSteps.count {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            currentStepIndex += 1
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 50)
                            .background(
                                Capsule()
                                    .fill(Color(red: 170/255, green: 190/255, blue: 210/255))
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    }
                    .padding(.bottom, 60)
                } else {
                    Button(action: {
                        dismiss() // Back to Neo-brutalist list matching HTML flow
                    }) {
                        Text("Finish")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 50)
                            .background(
                                Capsule()
                                    .fill(Color(red: 170/255, green: 190/255, blue: 210/255))
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .alert("End Exercise Early?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Exercise", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to exit? Your progress will be lost.")
        }
    }
}
