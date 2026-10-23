import SwiftUI
import WatchKit

/// The Apple Watch app (is5-watch, watchOS 10): the word of the hour from the phone's plan, read
/// aloud on request, with "Sonraki kelime" and "Biliyorum". See ios/Watch/README.md.
@main
struct LockglowWatchApp: App {
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) private var appDelegate
    @StateObject private var model = WatchModel()

    var body: some Scene {
        WindowGroup {
            WatchWordView()
                .environmentObject(model)
        }
        // New data from the phone while the app is in the background (a complication transfer):
        // SwiftUI's way of handing the task over. The delegate below covers the WatchKit way.
        .backgroundTask(.watchConnectivity) {
            await WatchSession.shared.receivePending()
        }
    }
}

/// Starts the phone sync at every launch (also a background launch for new data) and keeps any
/// WatchConnectivity background task the system gives the delegate until the data has arrived
/// (`WatchSession.track`).
final class WatchAppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        WatchSession.shared.activate()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let connectivityTask = task as? WKWatchConnectivityRefreshBackgroundTask {
                WatchSession.shared.track(connectivityTask)
            } else {
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}
