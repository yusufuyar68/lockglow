import Foundation
import UserNotifications
import Learning

/// Turns `ReminderPlanner` reminders into local notifications (nothing leaves the phone).
/// The plan is replaced as a whole every time: when the app goes to the background and when the
/// reminder setting changes, so the counts in tomorrow's text follow today's studying.
enum ReminderScheduler {
    static let identifierPrefix = "lockglow.reminder."

    /// Asks for permission the first time; false when the user said no now or earlier.
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    static func isDenied() async -> Bool {
        return await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .denied
    }

    /// Removes the pending reminders and schedules `reminders` (an empty list only removes).
    static func replace(with reminders: [Reminder]) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ours)
        if reminders.isEmpty {
            return
        }
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        default:
            return
        }
        let calendar = Calendar.current
        for (index, reminder) in reminders.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Tekrar zamanı"
            content.body = message(for: reminder)
            content.sound = .default
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            // Same identifiers every time: adding one replaces the request with that identifier.
            let request = UNNotificationRequest(identifier: identifierPrefix + "\(index)", content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    static func message(for reminder: Reminder) -> String {
        switch (reminder.dueCount, reminder.newCount) {
        case (0, let fresh):
            return "Bugünün \(fresh) yeni kelimesi hazır. İki dakikanı ayır."
        case (let due, 0):
            return "\(due) kelime tekrar bekliyor. Unutmadan pekiştir."
        case (let due, let fresh):
            return "\(due) kelime tekrar, \(fresh) yeni kelime seni bekliyor."
        }
    }
}

/// Opens "Tekrar" when a reminder is tapped. Set as the notification center's delegate at launch,
/// before any response can arrive.
@MainActor
final class NotificationRouter: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationRouter()

    /// True from a reminder tap until RootView has switched to "Tekrar".
    @Published var reviewRequested = false

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.identifier.hasPrefix(ReminderScheduler.identifierPrefix) {
            Task { @MainActor in
                NotificationRouter.shared.reviewRequested = true
            }
        }
        completionHandler()
    }
}
