import SwiftUI

struct ResourcesView: View {
    let theme: NeoTheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // Emergency Hotlines
                VStack(alignment: .leading, spacing: 16) {
                    Text("Emergency Hotlines ☎️")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(theme.textColor)
                    
                    ResourceButton(title: "Crisis Line: Dial 988, then press 1", icon: "phone.fill", action: {
                        if let url = URL(string: "tel://988") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[0])
                        
                    ResourceButton(title: "Text 838255", icon: "message.fill", action: {
                        if let url = URL(string: "sms://838255") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[0])
                    
                    ResourceButton(title: "Chat online at VeteransCrisisLine.net", icon: "bubble.left.and.bubble.right.fill", action: {
                        if let url = URL(string: "https://www.veteranscrisisline.net/get-help-now/chat/") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[0])
                }
                
                // VA Mental Health Services
                VStack(alignment: .leading, spacing: 16) {
                    Text("VA Mental Health Services ⛑️")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(theme.textColor)
                        
                    ResourceButton(title: "Warriors Heart Virginia", icon: "heart.fill", action: {
                        if let url = URL(string: "https://www.warriorsheart.com/virginia/") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[1])
                    
                    ResourceButton(title: "Boulder Crest Foundation", icon: "building.columns.fill", action: {
                        if let url = URL(string: "https://bouldercrest.org/") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[1])
                    
                    ResourceButton(title: "Vets' Retreat Virginia", icon: "house.fill", action: {
                        if let url = URL(string: "https://vetsretreatvirginia.org/") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[1])
                    
                    ResourceButton(title: "Wounded Warrior Project", icon: "figure.walk", action: {
                        if let url = URL(string: "https://www.woundedwarriorproject.org/") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[1])
                }
                
                // Support & Donate
                VStack(alignment: .leading, spacing: 16) {
                    Text("Support & Donate ❤️")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(theme.textColor)
                        
                    ResourceButton(title: "Semper Fi & America’s Fund", icon: "star.fill", action: {
                        if let url = URL(string: "https://thefund.org/") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[2])
                    
                    ResourceButton(title: "Gary Sinise Foundation", icon: "hands.sparkles.fill", action: {
                        if let url = URL(string: "https://www.garysinisefoundation.org/") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[2])
                    
                    ResourceButton(title: "Virginia Veterans Services", icon: "map.fill", action: {
                        if let url = URL(string: "https://virginiaveteransservicesfoundation.org/") { UIApplication.shared.open(url) }
                    }, theme: theme, color: theme.tileColors[2])
                }
            }
            .padding(20)
        }
        .background(theme.backgroundColor.ignoresSafeArea())
        // Apply delay removal for snappy taps in this list
        .onAppear {
            UIScrollView.appearance().delaysContentTouches = false
        }
        .navigationTitle("Resources")
        // Use inline title display to match the neo-brutalist aesthetic cleanly
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResourceButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let theme: NeoTheme
    let color: Color
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.leading)
                    
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 64)
            .foregroundColor(.black)
        }
        .buttonStyle(NeoButtonStyle(backgroundColor: color, shadowColor: theme.accentColor))
    }
}
