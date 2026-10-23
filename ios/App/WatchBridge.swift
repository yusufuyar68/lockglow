import Foundation
import os
import WatchConnectivity
import CoreModels
import SharedState

/// The phone's side of the Apple Watch sync (is5-watch, `WatchSync` in SharedState; the watch's
/// side is Watch/App/WatchSession.swift).
///
/// - Sends the widget plan to the watch app whenever the app writes one (`WatchPlanRelay`), when
///   the session activates and when the watch app is installed: always as the application context,
///   and as complication user info, which wakes the watch app, while a Lockglow complication is on
///   the face (spaced out by `WatchSync.shouldSendComplicationUpdate`).
/// - Writes each tap received from the watch ("Biliyorum", "Sonraki kelime") into the App Group
///   `events/` mailbox, as the widget does, so `AppModel.ingestWidgetEvents()` applies it the next
///   time it runs (the app coming to the front or going to the background). The watch never grades
///   a word; `WatchSync.phoneMailboxEvent(from:)` drops anything but these two taps.
///
/// Until the watch app is embedded in the iPhone app (ios/Watch/README.md), `isWatchAppInstalled`
/// is false and nothing is sent.
final class WatchBridge: NSObject, WCSessionDelegate {
    static let shared = WatchBridge()

    private static let lastComplicationTransferKey = "watchLastComplicationTransferAt"

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "watch"
    )
    /// Plan reads and sends, off the main thread and in order.
    private let queue = DispatchQueue(label: "lockglow.watch-bridge")

    /// Called once at launch (`LockglowApp.init`).
    func activate() {
        guard WCSession.isSupported() else {
            return
        }
        WatchPlanRelay.handler = { [weak self] in
            self?.queue.async {
                self?.sendPlan()
            }
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    private func makeStore() -> AppGroupStore? {
        return AppGroupLocator.containerURL().map { AppGroupStore(containerURL: $0) }
    }

    /// Runs on `queue`. Reads the plan from disk, so it always sends the newest one.
    private func sendPlan() {
        let session = WCSession.default
        guard session.activationState == .activated, session.isPaired, session.isWatchAppInstalled else {
            return
        }
        guard let plan = makeStore()?.readPlan(), let payload = WatchSync.planPayload(for: plan) else {
            return
        }
        do {
            try session.updateApplicationContext(payload)
        } catch {
            logger.error("watch plan not sent: \(error.localizedDescription, privacy: .public)")
        }

        let defaults = UserDefaults.standard
        let now = Date()
        let last = defaults.object(forKey: WatchBridge.lastComplicationTransferKey) as? Date
        if session.isComplicationEnabled,
           WatchSync.shouldSendComplicationUpdate(
               lastSentAt: last,
               now: now,
               remainingTransfers: session.remainingComplicationUserInfoTransfers
           ) {
            session.transferCurrentComplicationUserInfo(payload)
            defaults.set(now, forKey: WatchBridge.lastComplicationTransferKey)
        }
    }

    /// Runs on WatchConnectivity's queue; the event file is on disk before the callback returns.
    private func storeEvent(from userInfo: [String: Any]) {
        guard let event = WatchSync.phoneMailboxEvent(from: userInfo) else {
            return
        }
        guard let store = makeStore() else {
            logger.error("App Group container unavailable; watch tap not recorded")
            return
        }
        do {
            try store.eventMailbox.append(event)
            logger.info("watch event \(event.type.rawValue, privacy: .public) word=\(event.wordID)")
        } catch {
            logger.error("watch tap not recorded: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            logger.error("watch session not activated: \(error.localizedDescription, privacy: .public)")
        }
        queue.async {
            self.sendPlan()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    /// The user switched to another watch: Apple asks to activate the session again for it.
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    /// The watch app was installed (or removed): it gets the current plan at once.
    func sessionWatchStateDidChange(_ session: WCSession) {
        queue.async {
            self.sendPlan()
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        storeEvent(from: userInfo)
    }
}
