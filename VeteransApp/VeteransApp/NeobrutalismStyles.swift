import SwiftUI

struct NeobrutalismModifier: ViewModifier {
    var backgroundColor: Color
    var strokeWidth: CGFloat = 3
    var shadowOffset: CGFloat = 5
    var shadowColor: Color = .black
    var strokeColor: Color = .black
    var isPressed: Bool = false // New state for compression
    
    func body(content: Content) -> some View {
        ZStack {
            // 1. The Shadow
            Rectangle()
                .fill(shadowColor)
                .offset(x: shadowOffset, y: shadowOffset)
            
            // 2. The Content
            content
                .background(backgroundColor)
                .overlay(
                    Rectangle()
                        .stroke(strokeColor, lineWidth: strokeWidth)
                )
                // When pressed, move the content TOWARDS the shadow
                .offset(x: isPressed ? shadowOffset * 0.8 : 0, 
                        y: isPressed ? shadowOffset * 0.8 : 0)
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
    }
}

// Custom ButtonStyle for the "Compression" effect
struct NeoButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var shadowColor: Color = .black
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .neobrutal(
                backgroundColor: backgroundColor,
                shadowColor: shadowColor,
                isPressed: configuration.isPressed
            )
    }
}

extension View {
    func neobrutal(backgroundColor: Color = .white, strokeWidth: CGFloat = 3, shadowOffset: CGFloat = 5, shadowColor: Color = .black, strokeColor: Color = .black, isPressed: Bool = false) -> some View {
        self.modifier(NeobrutalismModifier(backgroundColor: backgroundColor, strokeWidth: strokeWidth, shadowOffset: shadowOffset, shadowColor: shadowColor, strokeColor: strokeColor, isPressed: isPressed))
    }
}

struct AppColors {
    static let yellow = Color(red: 255/255, green: 222/255, blue: 0/255)
    static let mint = Color(red: 167/255, green: 255/255, blue: 131/255)
    static let cyan = Color(red: 0/255, green: 209/255, blue: 255/255)
    static let magenta = Color(red: 255/255, green: 0/255, blue: 255/255)
    static let orange = Color(red: 255/255, green: 138/255, blue: 0/255)
}
