import SwiftUI
import UIKit
import UserNotifications

@main
struct LockglowApp: App {
    @StateObject private var model = AppModel()

    init() {
        // Before launch finishes, so a tap on a reminder that launched the app is not missed.
        UNUserNotificationCenter.current().delegate = NotificationRouter.shared
        // SwiftUI's .tint does not reach dialogs (UIAlertController): "Vazgeç" stays ink, not
        // system blue (rule 2). Theme.tint is dynamic, so it follows dark mode and high contrast.
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Theme.tint)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
    }
}
