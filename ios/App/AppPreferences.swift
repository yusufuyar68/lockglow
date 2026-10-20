import Foundation
import CoreModels

/// App-private persisted settings (UserDefaults). Learning progress itself lives in
/// `ProgressStore` (Application Support/progress.json), not here.
enum AppPreferences {
    /// Rotation intervals offered in "Ayarlar", in minutes. The widget clamps to at least 300 s.
    static let rotationMinuteChoices = [5, 15, 30, 60, 120]
    static let dailyNewWordChoices = [5, 10, 15, 20]
    static let defaultRotationMinutes = 60
    static let defaultDailyNewWords = 10
    /// Start levels offered in the onboarding and in "Ayarlar" (the content has A1-B1 cards).
    static let startLevelChoices: [Level] = [.a1, .a2, .b1]

    private static let rotationKey = "lockglow.rotationMinutes"
    private static let dailyNewWordsKey = "lockglow.dailyNewWords"
    private static let knownKey = "lockglow.knownWordIDs"
    private static let studiedDayKey = "lockglow.newWordsStudiedDay"
    private static let studiedCountKey = "lockglow.newWordsStudiedCount"
    private static let reminderEnabledKey = "lockglow.reminderEnabled"
    private static let reminderMinuteKey = "lockglow.reminderMinuteOfDay"
    private static let topicsKey = "lockglow.selectedTopicIDs"
    private static let startLevelKey = "lockglow.startLevel"
    private static let onboardingKey = "lockglow.onboardingCompleted"

    /// The onboarding was finished or skipped; after that it opens only from "Ayarlar".
    /// UI tests pass `-lockglow.onboardingCompleted YES` to start on the tabs.
    static var onboardingCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: onboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: onboardingKey)
        }
    }

    /// Topics (`category.id`) whose words rotate on the widget and in "Akış". Empty = every topic.
    static var selectedTopicIDs: Set<String> {
        get {
            return Set(UserDefaults.standard.stringArray(forKey: topicsKey) ?? [])
        }
        set {
            UserDefaults.standard.set(newValue.sorted(), forKey: topicsKey)
        }
    }

    /// The level new words start from. Nil (never chosen, or an unknown value) keeps the
    /// curriculum order, A1 first.
    static var startLevel: Level? {
        get {
            guard let stored = UserDefaults.standard.string(forKey: startLevelKey) else {
                return nil
            }
            return Level(rawValue: stored)
        }
        set {
            if let level = newValue {
                UserDefaults.standard.set(level.rawValue, forKey: startLevelKey)
            } else {
                UserDefaults.standard.removeObject(forKey: startLevelKey)
            }
        }
    }

    /// Daily "Tekrar" reminder: off until the user turns it on (it needs notification permission).
    static var reminderEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: reminderEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: reminderEnabledKey)
        }
    }

    static let defaultReminderMinuteOfDay = 20 * 60

    /// Reminder time in minutes after local midnight (default 20:00).
    static var reminderMinuteOfDay: Int {
        get {
            let stored = UserDefaults.standard.object(forKey: reminderMinuteKey) as? Int
            if let stored = stored, (0..<1440).contains(stored) {
                return stored
            }
            return defaultReminderMinuteOfDay
        }
        set {
            UserDefaults.standard.set(newValue, forKey: reminderMinuteKey)
        }
    }

    /// Minutes between word changes on the widget. Anything not in the choices reads as the default.
    static var rotationMinutes: Int {
        get {
            let stored = UserDefaults.standard.integer(forKey: rotationKey)
            return rotationMinuteChoices.contains(stored) ? stored : defaultRotationMinutes
        }
        set {
            UserDefaults.standard.set(newValue, forKey: rotationKey)
        }
    }

    /// Daily goal of new words. Anything not in the choices reads as the default.
    static var dailyNewWords: Int {
        get {
            let stored = UserDefaults.standard.integer(forKey: dailyNewWordsKey)
            return dailyNewWordChoices.contains(stored) ? stored : defaultDailyNewWords
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dailyNewWordsKey)
        }
    }

    /// LEGACY: words marked as known on the widget before the learning progress file existed.
    /// `AppModel` moves them into the progress file once, then calls `clearKnownWordIDs()`.
    static var knownWordIDs: Set<Int> {
        let stored = UserDefaults.standard.array(forKey: knownKey) as? [Int] ?? []
        return Set(stored)
    }

    static func clearKnownWordIDs() {
        UserDefaults.standard.removeObject(forKey: knownKey)
    }

    // MARK: New words studied today

    /// How many never-reviewed words were reviewed today (local calendar day). It limits how many
    /// new words "Tekrar" offers per day.
    static func newWordsStudiedToday(now: Date = Date()) -> Int {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: now).timeIntervalSince1970
        if defaults.double(forKey: studiedDayKey) != today {
            return 0
        }
        return defaults.integer(forKey: studiedCountKey)
    }

    static func addNewWordsStudied(_ count: Int, now: Date = Date()) {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: now).timeIntervalSince1970
        let total = newWordsStudiedToday(now: now) + count
        defaults.set(today, forKey: studiedDayKey)
        defaults.set(total, forKey: studiedCountKey)
    }

    static func resetNewWordsStudied() {
        UserDefaults.standard.removeObject(forKey: studiedDayKey)
        UserDefaults.standard.removeObject(forKey: studiedCountKey)
    }
}
