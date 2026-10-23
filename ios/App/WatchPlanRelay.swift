import Foundation

/// Tells the Apple Watch bridge that the widget plan changed (is5-watch). `AppModel` calls
/// `planDidChange()` after every successful `widget_plan.json` write; `WatchBridge` (iOS only,
/// WatchConnectivity) installs the handler at launch and sends the new plan to the watch. Without a
/// handler (no watch support, the Linux check) nothing happens.
enum WatchPlanRelay {
    static var handler: (() -> Void)?

    static func planDidChange() {
        handler?()
    }
}
