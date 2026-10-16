import SwiftUI
import UserNotifications

@main
struct LockglowApp: App {
    @StateObject private var model = AppModel()

    init() {
        // Before launch finishes, so a tap on a reminder that launched the app is not missed.
        UNUserNotificationCenter.current().delegate = NotificationRouter.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
    }
}
