import Foundation
import os
import WatchConnectivity
import WatchKit
import WidgetKit
import CoreModels
import SharedState

extension Notification.Name {
    /// Posted on the main queue after a new plan from the phone was saved.
    static let lockglowWatchPlanDidChange = Notification.Name("lockglowWatchPlanDidChange")
}

/// The watch's side of the phone sync (is5-watch, `WatchSync` in SharedState; the phone's side is
/// App/WatchBridge.swift).
///
/// - Every newer plan the phone sends (application context, or complication user info, which
///   wakes the app in the background) is saved as the watch's `widget_plan.json`, without the
///   words marked known on the watch lately (`WatchKnownLedger`); then the complications reload.
/// - The taps the watch app leaves in its outbox (the watch's `events/` mailbox) are handed to
///   WatchConnectivity, which keeps them until the phone receives them.
final class WatchSession: NSObject, WCSessionDelegate {
    static let shared = WatchSession()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow.watch",
        category: "sync"
    )
    /// File work, in order: plans arrive on WatchConnectivity's queue, flushes come from the app.
    private let queue = DispatchQueue(label: "lockglow.watch.sync")
    private let store = WatchStore.appStore()
    /// The system's WatchConnectivity background tasks, kept until nothing is pending. Main queue only.
    private var pendingTasks: [WKWatchConnectivityRefreshBackgroundTask] = []
    private var observations: [NSKeyValueObservation] = []

    /// Starts the session once (launch, also a background launch for new data). Safe to call again.
    func activate() {
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.default
        if session.delegate == nil {
            session.delegate = self
            // Apple: complete a WatchConnectivity background task only once `hasContentPending` is false.
            observations = [
                session.observe(\.activationState) { [weak self] _, _ in
                    self?.completeTasksIfDone()
                },
                session.observe(\.hasContentPending) { [weak self] _, _ in
                    self?.completeTasksIfDone()
                },
            ]
        }
        if session.activationState == .notActivated {
            session.activate()
        }
    }

    /// Keeps a background task the system gave the app to receive data until every pending
    /// transfer has arrived and been saved; at most 20 seconds, so the system never has to stop the app.
    func track(_ task: WKWatchConnectivityRefreshBackgroundTask) {
        DispatchQueue.main.async {
            self.pendingTasks.append(task)
            self.activate()
            self.completeTasksIfDone()
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                self.completeAllTasks()
            }
        }
    }

    /// Hands every tap in the outbox to WatchConnectivity, then deletes its file. Without an
    /// activated session the taps wait in the outbox for the next flush (activation, the app coming
    /// to the front, the next tap).
    func flushOutbox() {
        queue.async {
            guard WCSession.isSupported(), let store = self.store else {
                return
            }
            let session = WCSession.default
            guard session.activationState == .activated else {
                return
            }
            let mailbox = store.eventMailbox
            let stored: [StoredEvent]
            do {
                stored = try mailbox.list()
            } catch {
                self.logger.error("outbox not readable: \(error.localizedDescription, privacy: .public)")
                return
            }
            for item in stored {
                guard let payload = WatchSync.eventPayload(item.event) else {
                    continue
                }
                session.transferUserInfo(payload)
                try? mailbox.delete(item)
            }
            mailbox.deleteUndecodableFiles()
        }
    }

    // MARK: Plans from the phone

    /// Runs on `queue`.
    private func receive(_ payload: [String: Any]) {
        guard let incoming = WatchSync.plan(from: payload), let store = store else {
            return
        }
        let now = Date()
        guard WatchSync.isNewer(incoming, than: store.readPlan(), now: now) else {
            return
        }
        // Only the tap path writes the ledger (main queue); here it is read.
        let plan = WatchKnownLedger.read(from: store.containerURL).filter(incoming, now: now)
        do {
            try store.writePlan(plan)
        } catch {
            logger.error("plan not saved: \(error.localizedDescription, privacy: .public)")
            return
        }
        logger.info("new plan from the phone: \(plan.queue.count) words")
        WidgetCenter.shared.reloadAllTimelines()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .lockglowWatchPlanDidChange, object: nil)
        }
    }

    /// After the file work queued so far, completes the background tasks once nothing is pending.
    private func completeTasksIfDone() {
        queue.async {
            DispatchQueue.main.async {
                let session = WCSession.default
                guard session.activationState == .activated, !session.hasContentPending else {
                    return
                }
                self.completeAllTasks()
            }
        }
    }

    /// Main queue only.
    private func completeAllTasks() {
        let tasks = pendingTasks
        pendingTasks = []
        for task in tasks {
            task.setTaskCompletedWithSnapshot(false)
        }
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            logger.error("session not activated: \(error.localizedDescription, privacy: .public)")
        }
        if activationState == .activated {
            // The newest context may have arrived while the app was not running.
            let context = session.receivedApplicationContext
            queue.async {
                self.receive(context)
            }
            flushOutbox()
        }
        completeTasksIfDone()
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        queue.async {
            self.receive(applicationContext)
        }
        completeTasksIfDone()
    }

    /// Complication user info from the phone (`transferCurrentComplicationUserInfo`) carries a plan.
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        queue.async {
            self.receive(userInfo)
        }
        completeTasksIfDone()
    }

    /// A tap the system could not deliver goes back into the outbox; the next flush sends it again.
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        guard let error = error else {
            return
        }
        logger.error("tap not delivered: \(error.localizedDescription, privacy: .public)")
        guard let event = WatchSync.event(from: userInfoTransfer.userInfo), let store = store else {
            return
        }
        queue.async {
            try? store.eventMailbox.append(event)
        }
    }
}
