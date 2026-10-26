import SwiftUI
import UIKit
import UserNotifications

@main
struct LockglowApp: App {
    init() {
        #if DEBUG && targetEnvironment(simulator)
        if NativeTransferHarness.isEnabled { return }
        #endif
        // Before launch finishes, so a tap on a reminder that launched the app is not missed.
        UNUserNotificationCenter.current().delegate = NotificationRouter.shared
        // is5-watch: before launch finishes too, so taps queued on the Apple Watch are delivered.
        WatchBridge.shared.activate()
        // SwiftUI's .tint does not reach dialogs (UIAlertController): "Vazgeç" stays ink, not
        // system blue (rule 2). Theme.tint is dynamic, so it follows dark mode and high contrast.
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Theme.tint)
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG && targetEnvironment(simulator)
            if NativeTransferHarness.isEnabled {
                NativeTransferHarness()
            } else {
                LockglowRootContent()
            }
            #else
            LockglowRootContent()
            #endif
        }
        // is5-canli: closes the round's Live Activity left alone for 30 minutes, when iOS runs it.
        .backgroundTask(.appRefresh(ReviewLiveActivity.refreshTaskID)) {
            await ReviewLiveActivity.shared.backgroundRefresh()
        }
    }
}

/// Kept outside the test-harness branch so a fixture launch never constructs or starts AppModel.
private struct LockglowRootContent: View {
    @StateObject private var model = AppModel()

    var body: some View {
        RootView()
            .environmentObject(model)
    }
}
