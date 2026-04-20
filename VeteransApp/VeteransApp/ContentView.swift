import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    // Theme State - Set to requested custom colors
    @State private var currentTheme: NeoTheme = NeoTheme(
        name: "CustomRequested",
        backgroundColor: Color(red: 190/255, green: 228/255, blue: 255/255), // Lighter tint of the old Medal blue, but notably more blue
        tileColors: [
            Color(red: 233/255, green: 234/255, blue: 249/255), // [0] Breathing (#e9eaf9)
            Color(red: 216/255, green: 249/255, blue: 216/255), // [1] Daily Check-ins (#d8f9d8)
            Color(red: 255/255, green: 237/255, blue: 237/255), // [2] Resources (#ffeded)
            Color(red: 250/255, green: 255/255, blue: 228/255)  // [3] Notifications (#faffe4)
        ],
        accentColor: .black,
        textColor: .black
    )

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
                                NavigationLink(destination: VStack {
                                    Text("Breathing Exercises")
                                        .font(.largeTitle)
                                        .fontWeight(.black)
                                        .padding(.top, 60)
                                    Spacer()
                                }) {
                                    CustomBreathingTile(theme: currentTheme)
                                }
                                .buttonStyle(NeoButtonStyle(backgroundColor: currentTheme.tileColors[0], shadowColor: currentTheme.accentColor))
                                
                                NavigationLink(destination: VStack {
                                    Text("Daily Check-ins")
                                        .font(.largeTitle)
                                        .fontWeight(.black)
                                        .padding(.top, 60)
                                    Spacer()
                                }) {
                                    BentoTile(title: "Daily\nCheck-ins", icon: "bubble.left.and.bubble.right.fill", theme: currentTheme, tileIndex: 1, size: .medium, imageName: "checkin_veteran", imageOffset: 28)
                                }
                                .buttonStyle(NeoButtonStyle(backgroundColor: currentTheme.tileColors[1], shadowColor: currentTheme.accentColor))
                            }
                            
                            // Resources — image left, label right, no category list
                            NavigationLink(destination: ResourcesView(theme: currentTheme)) {
                                HStack(spacing: 0) {
                                    // Image fills left ~55% of tile
                                    BentoTile(title: "", icon: "books.vertical.fill", theme: currentTheme, tileIndex: 2, size: .medium, showArrow: false, forceDarkText: true, imageName: "resources_veteran", imageScale: 0.7, imageOffset: 45)
                                        .frame(maxWidth: .infinity)
                                    
                                    // Arrow at top, RESOURCES text at bottom — consistent with other tiles
                                    VStack(alignment: .trailing, spacing: 6) {
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text("RESOURCES")
                                            .font(.system(size: 16, weight: .black))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.trailing, 16)
                                    .padding(.vertical, 12)
                                }
                            }
                            .buttonStyle(NeoButtonStyle(backgroundColor: currentTheme.tileColors[2], shadowColor: currentTheme.accentColor))
                            
                            // Notifications Section
                            NavigationLink(destination: Text("Today's Schedule")) {
                                NotificationTile(theme: currentTheme)
                            }
                            .buttonStyle(NeoButtonStyle(backgroundColor: currentTheme.tileColors[3], shadowColor: currentTheme.accentColor))
                        }
                    }
                    .padding(16)
                }
                
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            UIScrollView.appearance().delaysContentTouches = false
        }
    }
}

struct CustomBreathingTile: View {
    let theme: NeoTheme
    
    var body: some View {
        ZStack {
            // Background is guaranteed to be solid
            theme.tileColors[0]
            
            // Image placed at the bottom, slightly shifted so it doesn't overlap the arrow
            VStack {
                Spacer()
                if let uiImage = UIImage(named: "breathing_exercise") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 110)
                        .offset(x: -10, y: 15)
                }
            }
            
            // Text and Arrow at the Top
            VStack {
                HStack(alignment: .top) {
                    Text("BREATHING\nEXERCISES")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.textColor)
                        .padding(.top, 2)
                }
                Spacer()
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .clipped()
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
            Text(name) // Proper capitalization - first letter up, rest lowercase
                .font(.system(size: 42, weight: .black))
                .foregroundColor(theme.textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ReminderSettingsModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedInterval: String = "1 Hour before"
    let intervals = ["At time of event", "5 Minutes before", "15 Minutes before", "30 Minutes before", "1 Hour before", "1 Day before"]
    let theme: NeoTheme
    
    var body: some View {
        NavigationStack {
            VStack {
                List(intervals, id: \.self) { interval in
                    Button(action: {
                        selectedInterval = interval
                    }) {
                        HStack {
                            Text(interval)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            if selectedInterval == interval {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
                
                Button(action: {
                    dismiss()
                }) {
                    Text("SET DEMO REMINDER")
                        .font(.system(size: 18, weight: .black))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                }
            }
        }
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
    var forceDarkText: Bool = false
    var imageName: String? = nil
    var imageScale: CGFloat = 1.0     // Scale the image inside the tile
    var imageOffset: CGFloat = 0      // Push image down inside the tile
    
    var textColor: Color { forceDarkText ? .black : theme.textColor }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image fills the tile but never enters the bottom label zone
            if let imageName = imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(imageScale)
                    .offset(y: imageOffset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 36) // Reserve the label strip — image never bleeds into it
                    .clipped()
                    .mask(
                        LinearGradient(
                            colors: [.black, .black, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            // Label — always sits at the bottom, guaranteed visible
            HStack(alignment: .center) {
                Text(title.uppercased())
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer()
                if showArrow {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(textColor)
                }
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .clipped()
    }
}

struct NotificationTile: View {
    let theme: NeoTheme
    @State private var rotationAngle: Double = 0
    @State private var showReminderSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TODAY'S NOTIFICATIONS")
                    .font(.system(size: 16, weight: .black))
                Spacer()
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    // Rotate from the top to look like a bell swinging
                    .rotationEffect(.degrees(rotationAngle), anchor: .top)
                    .onTapGesture {
                        openSettings()
                    }
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
        // Hook up the new interactive sheet
        .sheet(isPresented: $showReminderSettings, onDismiss: {
            // When the modal is dismissed (e.g. setting changed), return to normal smoothly!
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                rotationAngle = 0
            }
        }) {
            ReminderSettingsModal(theme: theme)
                .presentationDetents([.medium, .large])
        }
    }
    
    // Snappy transition directly to crooked state
    private func openSettings() {
        // Animate simply and quickly to the crooked pose
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { 
            rotationAngle = 20 
        } 
        
        // Pop the modal immediately
        showReminderSettings = true
    }
}

struct NotificationItem: View {
    let time: String
    let location: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Text(time)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black.opacity(0.4)) // Lighter time text
                Image(systemName: "mappin.and.ellipse") // Map marker instead of bullet
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black.opacity(0.4))
                Text(location)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black.opacity(0.4))
            }
            
            Text(title)
                .font(.system(size: 19, weight: .black))
                .foregroundColor(.black)
            
            if !message.isEmpty {
                Text("(\(message))")
                    .font(.system(size: 15, weight: .bold))
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

// MARK: - Horizontal Flag Banner (scrolls left → right below notifications)

struct HorizontalFlagBanner: View {
    let flagCount = 12
    let duration: Double = 8.0 // seconds for one full pass
    let flagSpacing: CGFloat = 62  // Wider spacing for bigger flags
    let flagSize: CGFloat = 52     // Bigger flags

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                // rawOffset goes 0 → flagSpacing, then loops (conveyor belt)
                let rawOffset = CGFloat(elapsed.truncatingRemainder(dividingBy: duration) / duration) * flagSpacing

                Canvas { context, size in
                    let totalFlags = Int(ceil(size.width / flagSpacing)) + 2
                    for i in 0..<totalFlags {
                        let x = CGFloat(i) * flagSpacing + rawOffset - flagSpacing
                        let y = size.height / 2
                        context.draw(
                            Text("🇺🇸").font(.system(size: flagSize)),
                            at: CGPoint(x: x, y: y)
                        )
                    }
                }
            }
        }
        .frame(height: flagSize + 16)
        .allowsHitTesting(false)
    }
}
