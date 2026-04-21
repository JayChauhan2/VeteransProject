//
//  VeteransAppApp.swift
//  VeteransApp
//
//  Created by Jay Chauhan on 4/19/26.
//

import SwiftUI
import SwiftData
import UserNotifications
import Combine

// Global router to detect when a notification is tapped
class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()
    @Published var tappedEventId: String? = nil
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Explicitly tell iOS to show the notification banner and play sound even when the app is open and active
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Triggered exactly when the user physically taps on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        
        // Pass the UUID of the tapped scheduled item to the global router
        DispatchQueue.main.async {
            NotificationRouter.shared.tappedEventId = identifier
        }
        
        completionHandler()
    }
}

@main
struct TroopCompanionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // Using a shared instance so it can be commanded from AppDelegate, and observed by SwiftUI
    @StateObject private var router = NotificationRouter.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
