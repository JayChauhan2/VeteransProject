import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    // Theme State - Set to 'Medal' style (Index 8)
    @State private var currentTheme: NeoTheme = ThemeManager.themes[8]

    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background color (bottom)
                currentTheme.backgroundColor.ignoresSafeArea()
                
                // 2. Scrollable content (middle)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Header
                        HeaderView(name: "Jay", theme: currentTheme)
                            .padding(.top, 10)
                        
                        // Bento Grid
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                NavigationLink(destination: Text("Breathing Exercises")) {
                                    BentoTile(title: "Breathing\nExercises", icon: "wind", theme: currentTheme, tileIndex: 0, size: .small)
                                }
                                .buttonStyle(NeoButtonStyle(backgroundColor: currentTheme.tileColors[0], shadowColor: currentTheme.accentColor))
                                
                                NavigationLink(destination: Text("Daily Check-ins")) {
                                    BentoTile(title: "Daily\nCheck-ins", icon: "bubble.left.and.bubble.right.fill", theme: currentTheme, tileIndex: 1, size: .medium)
                                }
                                .buttonStyle(NeoButtonStyle(backgroundColor: currentTheme.tileColors[1], shadowColor: currentTheme.accentColor))
                            }
                            
                            VStack(spacing: 16) {
                                NavigationLink(destination: Text("Resources")) {
                                    ZStack(alignment: .topTrailing) {
                                        HStack {
                                            // White BentoTile for maximum readability
                                            BentoTile(title: "Resources", icon: "books.vertical.fill", theme: currentTheme, tileIndex: 2, size: .medium, showArrow: false, forceDarkText: true)
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 8) {
                                                Text("Medical Benefits")
                                                Text("Housing Support")
                                                Text("Peer Community")
                                            }
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.trailing, 20)
                                        }
                                        
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(16)
                                    }
                                }
                                // White background = guaranteed readability regardless of theme
                                .buttonStyle(NeoButtonStyle(backgroundColor: .white, shadowColor: currentTheme.accentColor))
                            }
                            
                            // Notifications Section
                            NavigationLink(destination: Text("Today's Schedule")) {
                                NotificationTile(theme: currentTheme)
                            }
                            .buttonStyle(NeoButtonStyle(backgroundColor: currentTheme.tileColors[0], shadowColor: currentTheme.accentColor))
                        }
                    }
                    .padding(16)
                }
                
                // 3. Flag Parade — LAST in ZStack = always on top of everything
                FlagParadeView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TroopCompanion")
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(currentTheme.textColor)
                }
            }
        }
    }
}

// MARK: - Subviews

struct HeaderView: View {
    let name: String
    let theme: NeoTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("WELCOME BACK,")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.textColor.opacity(0.7))
            Text(name.uppercased())
                .font(.system(size: 42, weight: .black))
                .foregroundColor(theme.textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum TileSize {
    case small, medium, large
}

struct BentoTile: View {
    let title: String
    let icon: String
    let theme: NeoTheme
    let tileIndex: Int
    let size: TileSize
    var showArrow: Bool = true
    var forceDarkText: Bool = false // Forces black text for readability on light backgrounds
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                if showArrow {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            Spacer()
            Text(title.uppercased())
                .font(.system(size: 18, weight: .black))
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(forceDarkText ? .black : theme.textColor)
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
    }
}

struct NotificationTile: View {
    let theme: NeoTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TODAY'S NOTIFICATIONS")
                    .font(.system(size: 16, weight: .black))
                Spacer()
                Image(systemName: "bell.fill")
            }
            
            Divider().background(theme.accentColor).frame(height: 2)
            
            VStack(alignment: .leading, spacing: 14) {
                NotificationItem(time: "3PM - 4PM", location: "Local hospital", title: "Doctor's Appointment", message: "")
                NotificationItem(time: "5PM - 6PM", location: "Twin Hickory Park", title: "Daily Walk", message: "Remember to see Dorothy!")
            }
        }
        .foregroundColor(theme.textColor)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct NotificationItem: View {
    let time: String
    let location: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(time)
                    .font(.system(size: 14, weight: .bold))
                Text("•")
                Text(location)
                    .font(.system(size: 14, weight: .bold)) // Bolder location
            }
            .foregroundColor(.black) // Fixed high contrast
            
            Text(title)
                .font(.system(size: 19, weight: .black)) // Slightly larger title
                .foregroundColor(.black)
            
            if !message.isEmpty {
                Text("(\(message))")
                    .font(.system(size: 15, weight: .bold)) // Bolder sub-message
                    .italic()
                    .foregroundColor(.black)
            }
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

// MARK: - Patriotic Flag Parade (Dignified Crawl)

struct FlagParadeView: View {
    let flagCount = 10
    let duration: Double = 20.0 // Total seconds for one full loop
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let progress = CGFloat((elapsed.truncatingRemainder(dividingBy: duration)) / duration)
                
                ZStack {
                    ForEach(0..<flagCount, id: \.self) { i in
                        StandardFlag(index: i, total: flagCount, bounds: geo.size, progress: progress)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct StandardFlag: View {
    let index: Int
    let total: Int
    let bounds: CGSize
    let progress: CGFloat
    
    var body: some View {
        let startX = bounds.width * 0.5
        let startY: CGFloat = -60
        let endX = bounds.width + 300
        let endY = bounds.height * 0.5
        
        let itemProgress = (CGFloat(index) / CGFloat(total) + progress).truncatingRemainder(dividingBy: 1.0)
        
        let x = startX + (endX - startX) * itemProgress
        let y = startY + (endY - startY) * itemProgress
        
        Text("🇺🇸")
            .font(.system(size: 65))
            .position(x: x, y: y)
    }
}
