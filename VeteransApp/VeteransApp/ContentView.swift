import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @AppStorage("hasSeededInitialData") private var hasSeeded = false
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
                                NavigationLink(destination: BreathingExercisesListView(theme: currentTheme)) {
                                    CustomBreathingTile(theme: currentTheme)
                                }
                                .buttonStyle(NeoButtonStyle(backgroundColor: currentTheme.tileColors[0], shadowColor: currentTheme.accentColor))
                                
                                NavigationLink(destination: ChatView(theme: currentTheme)) {
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
                            VStack {
                                NotificationTile(theme: currentTheme, items: items)
                            }
                            .neobrutal(backgroundColor: currentTheme.tileColors[3], shadowColor: currentTheme.accentColor)

                        }
                    }
                    .padding(16)
                }
                
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            UIScrollView.appearance().delaysContentTouches = false
            if !hasSeeded {
                seedInitialData()
                hasSeeded = true
            }
        }
    }
    
    private func seedInitialData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Find Wednesday (4) and Thursday (5) of the current week natively
        guard let wednesday = calendar.date(bySetting: .weekday, value: 4, of: today),
              let thursday = calendar.date(bySetting: .weekday, value: 5, of: today) else { return }
        
        let seedEvents = [
            ("VA Medical Checkup", "Routine checkup at the central VA clinic.", wednesday, 9, 30),
            ("Call Battle Buddy", "Check in with Mike from the old unit.", wednesday, 11, 00),
            ("Submit VA Prescriptions", "Refill standard medications on MyHealtheVet.", wednesday, 13, 15),
            ("Physical Therapy", "Knee and lower back mobility session.", wednesday, 15, 00),
            ("VFW Post Meeting", "Monthly chapter meeting and dinner.", wednesday, 18, 30),
            
            ("Morning Ruck/PT", "Light 3-mile ruck march to keep the legs active.", thursday, 6, 30),
            ("Meet with VSO", "Review the new pact act claim paperwork.", thursday, 10, 00),
            ("Community Service", "Help pack boxes at the local food bank.", thursday, 12, 00),
            ("VA Disability Call", "Telehealth follow up for the re-evaluation.", thursday, 14, 00),
            ("Pick up Meds", "Drive to the VA pharmacy to pick up the refills.", thursday, 16, 45)
        ]
        
        for event in seedEvents {
            if let eventDate = calendar.date(bySettingHour: event.3, minute: event.4, second: 0, of: event.2) {
                let newItem = Item(timestamp: eventDate, title: event.0, message: event.1, location: "Veterans Center")
                modelContext.insert(newItem)
            }
        }
        
        try? modelContext.save()
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
    @AppStorage("reminderOffsetString") private var selectedInterval: String = "5 Minutes before"
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
                    Text("SET REMINDER")
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
    var items: [Item]
    @Environment(\.modelContext) private var modelContext

    @State private var rotationAngle: Double = 0
    @State private var showReminderSettings = false
    @State private var showAddEvent = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TODAY'S NOTIFICATIONS")
                    .font(.system(size: 16, weight: .black))
                Spacer()
                
                // Add Event Button
                Button(action: {
                    showAddEvent = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
                .padding(.trailing, 8)
                
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
                if items.isEmpty {
                    Text("No events scheduled. Tap + to add one!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black.opacity(0.5))
                        .padding(.vertical, 8)
                } else {
                    List {
                        ForEach(items) { item in
                            let isPast = item.timestamp < Date().addingTimeInterval(-60)
                            NotificationItem(time: item.timestamp.formatted(date: .omitted, time: .shortened), location: item.location, title: item.title, message: item.message, isPast: isPast)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.visible)
                    .frame(height: 250)
                }
            }
        }
        .foregroundColor(theme.textColor)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $showAddEvent) {
            AddEventModal()
                .presentationDetents([.large])
        }
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
    var isPast: Bool = false
    
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
        .opacity(isPast ? 0.4 : 1.0)
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
import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Requests permissions for alerts, sounds, and badges if not already requested
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }
    
    /// Schedules a local notification at a specific date, minus the offset.
    func scheduleNotification(for item: Item, offsetSeconds: Double) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = item.message.isEmpty ? "You have an event coming up." : item.message
        content.sound = .default
        
        // Calculate the actual trigger date
        let triggerDate = item.timestamp.addingTimeInterval(-offsetSeconds)
        
        // Only schedule if the trigger time is in the future
        guard triggerDate > Date() else { return }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Use the event ID to keep it identifiable and replaceable if needed
        let identifier = item.id.uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule local notification: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification '\(item.title)' for \(triggerDate)")
            }
        }
    }
    
    /// Calculate offset in seconds from the string preference
    static func parseOffset(from string: String) -> Double {
        switch string {
        case "At time of event": return 0
        case "5 Minutes before": return 5 * 60
        case "15 Minutes before": return 15 * 60
        case "30 Minutes before": return 30 * 60
        case "1 Hour before": return 60 * 60
        case "1 Day before": return 24 * 60 * 60
        default: return 5 * 60
        }
    }
}
import SwiftUI
import SwiftData

struct AddEventModal: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var location: String = ""
    @State private var date: Date = Date()
    @State private var showError: Bool = false
    
    // Grabbing the global user preference to schedule the notification!
    @AppStorage("reminderOffsetString") private var reminderOffsetString: String = "5 Minutes before"
    
    var body: some View {
        // Pre-shuffled list of common veteran-specific event context suggestions
        let suggestions = ["VA Checkup", "Physical Therapy", "VFW Meetup", "Morning Run", "Call Battle Buddy", "Therapy Session", "Paperwork"].shuffled()
        
        NavigationStack {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(suggestions.prefix(4), id: \.self) { suggestion in
                                Button(action: {
                                    title = suggestion
                                }) {
                                    Text(suggestion)
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.black.opacity(0.1))
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 4)
                    
                    TextField("Message (Optional)", text: $message)
                    TextField("Location (Optional)", text: $location)
                }
                
                Section(header: Text("Time")) {
                    DatePicker("Date & Time", selection: $date)
                }
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    let isTitleEmpty = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    
                    Button("Save") {
                        if isTitleEmpty {
                            showError = true
                        } else {
                            saveEvent()
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                    // Visually looks disabled (gray) but stays tappable to trigger the alert pop-up
                    .foregroundColor(isTitleEmpty ? Color.gray : .black)
                }
            }
            .alert("Missing Title", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a title to save this event.")
            }
        }
    }
    
    private func saveEvent() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? "New Event" : trimmedTitle
        
        let newItem = Item(timestamp: date, title: finalTitle, message: message, location: location)
        
        // Save to Database
        modelContext.insert(newItem)
        
        // Schedule push notification locally checking permissions first natively!
        NotificationManager.shared.requestAuthorization { granted, _ in
            if granted {
                let offset = NotificationManager.parseOffset(from: reminderOffsetString)
                NotificationManager.shared.scheduleNotification(for: newItem, offsetSeconds: offset)
            }
        }
    }
}
