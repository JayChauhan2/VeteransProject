import SwiftUI

struct UIDisplayMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

// A highly localized, perfect background struct that draws the shadow strictly behind the box
// This guarantees zero double-vision and zero layout collapse because it sits securely behind the content.
struct NeoBackground: View {
    var color: Color
    
    var body: some View {
        ZStack {
            // Shadow
            Rectangle()
                .fill(Color.black)
                .offset(x: 4, y: 4)
            
            // Box and Stroke
            Rectangle()
                .fill(color)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 3))
        }
    }
}

struct ChatView: View {
    let theme: NeoTheme
    
    @State private var inputText: String = ""
    @State private var messages: [UIDisplayMessage] = [
        UIDisplayMessage(content: "Hey. How are you holding up today?", isUser: false)
    ]
    @State private var isTyping: Bool = false
    
    // Exact colors requested by user
    let userBubbleColor = Color(red: 216/255, green: 249/255, blue: 216/255) // Daily check-ins tile
    let aiBubbleColor = Color(red: 233/255, green: 234/255, blue: 249/255)   // Breathing exercises tile
    
    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Chat List
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(messages) { msg in
                                ChatBubble(message: msg, userColor: userBubbleColor, aiColor: aiBubbleColor)
                                    .id(msg.id)
                            }
                            
                            if isTyping {
                                HStack {
                                    Text("typing...")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.black.opacity(0.5))
                                        .padding(.leading, 10)
                                    Spacer()
                                }
                                .id("typing")
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: isTyping) { _ in
                        if isTyping {
                            withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                        }
                    }
                }
                
                Divider().background(Color.black).frame(height: 3)
                
                // Input Area
                HStack(alignment: .bottom, spacing: 16) {
                    TextField("Message...", text: $inputText)
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(NeoBackground(color: .white))
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.black)
                            .padding(16)
                            .background(NeoBackground(color: userBubbleColor))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTyping)
                    .opacity((inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTyping) ? 0.6 : 1.0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24) // Extra padding for safe area offset if needed
                .background(theme.backgroundColor)
            }
        }
        // Match Resources exactly
        .navigationTitle("Daily Check-in")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        let userMsg = UIDisplayMessage(content: text, isUser: true)
        messages.append(userMsg)
        inputText = ""
        isTyping = true
        
        let apiMessages = messages.map { GroqChatMessage(role: $0.isUser ? "user" : "assistant", content: $0.content) }
        
        GroqAPIService.shared.sendMessage(messages: apiMessages) { responseText in
            isTyping = false
            if let responseText = responseText {
                messages.append(UIDisplayMessage(content: responseText, isUser: false))
            } else {
                messages.append(UIDisplayMessage(content: "Connection error. Please try again later.", isUser: false))
            }
        }
    }
}

struct ChatBubble: View {
    let message: UIDisplayMessage
    let userColor: Color
    let aiColor: Color
    
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }
            
            Text(message.content)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 14) // Slightly tighter vertical padding for chat feels better
                .background(NeoBackground(color: message.isUser ? userColor : aiColor))
            
            if !message.isUser { Spacer(minLength: 40) }
        }
    }
}
