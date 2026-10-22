import Foundation
import UserNotifications
import Learning

/// Turns `ReminderPlanner` reminders into local notifications (nothing leaves the phone).
/// The plan is replaced as a whole every time: when the app goes to the background and when the
/// reminder setting changes, so tomorrow's word follows today's studying. The texts are
/// `ReminderText` and the record of what was sent is `ReminderLog` (pure Swift, tested on Linux).
enum ReminderScheduler {
    static let identifierPrefix = "lockglow.reminder."
    /// One stack in Notification Center if earlier days' reminders were not opened.
    static let threadIdentifier = "gunluk"
    /// `userInfo` key of the reminder's word: a tap opens its card when "Tekrar" has nothing.
    static let wordIDKey = "word_id"

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

    static func isAuthorized() async -> Bool {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    /// Removes the pending reminders and schedules `reminders` (an empty list only removes), then
    /// writes down what is waiting (`ReminderLog`). No buttons (no category): a tap opens
    /// "Tekrar". No badge, no Time Sensitive level, the default sound (2.10).
    static func replace(with reminders: [Reminder]) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ours)
        guard !reminders.isEmpty, await isAuthorized() else {
            ReminderLog.replaceScheduled(with: [])
            return
        }
        let calendar = Calendar.current
        var scheduled: [SentReminder] = []
        for (index, reminder) in reminders.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.threadIdentifier = threadIdentifier
            content.interruptionLevel = .active
            content.relevanceScore = 0.3
            if let wordID = reminder.wordID {
                content.userInfo = [wordIDKey: wordID]
            }
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            // Same identifiers every time: adding one replaces the request with that identifier.
            let request = UNNotificationRequest(identifier: identifierPrefix + "\(index)", content: content, trigger: trigger)
            do {
                try await center.add(request)
                scheduled.append(reminder.sent)
            } catch {
                continue
            }
        }
        ReminderLog.replaceScheduled(with: scheduled)
    }
}

/// Opens "Tekrar" when a reminder is tapped (its word's card when "Tekrar" has nothing). Set as
/// the notification center's delegate at launch, before any response can arrive.
@MainActor
final class NotificationRouter: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationRouter()

    /// True from a reminder tap until RootView has opened "Tekrar" or the word.
    @Published var reviewRequested = false
    /// The tapped reminder's word, if it had one.
    @Published var requestedWordID: Int?

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let request = response.notification.request
        if request.identifier.hasPrefix(ReminderScheduler.identifierPrefix) {
            let wordID = request.content.userInfo[ReminderScheduler.wordIDKey] as? Int
            Task { @MainActor in
                NotificationRouter.shared.requestedWordID = wordID
                NotificationRouter.shared.reviewRequested = true
            }
        }
        completionHandler()
    }
}
