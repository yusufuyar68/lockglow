import Foundation
import CoreModels
import Learning

/// App-private persisted settings (UserDefaults). Learning progress itself lives in
/// `ProgressStore` (Application Support/progress.json), not here. The rules behind the
/// defaults and the carry-over from earlier builds are `SettingsRules` (tested on Linux).
enum AppPreferences {
    /// Rotation intervals offered in "Ayarlar", in minutes: 30, 60, 120, 240. The widget clamps to
    /// at least 300 s.
    static let rotationMinuteChoices = SettingsRules.rotationMinuteChoices
    static let dailyNewWordChoices = SettingsRules.dailyNewWordChoices
    static let defaultRotationMinutes = SettingsRules.defaultRotationMinutes
    /// The daily goal of a user who never chose one, for the stored start level: 5 from A1 and
    /// A2 (and without a level), 10 from B1.
    static var defaultDailyNewWords: Int {
        return SettingsRules.defaultDailyNewWords(startLevel: startLevel)
    }
    /// Start levels offered in the onboarding and in "Ayarlar" (the content has A1-B1 cards).
    static let startLevelChoices: [Level] = [.a1, .a2, .b1]

    private static let rotationKey = "lockglow.rotationMinutes"
    private static let dailyNewWordsKey = "lockglow.dailyNewWords"
    private static let knownKey = "lockglow.knownWordIDs"
    private static let studiedDayKey = "lockglow.newWordsStudiedDay"
    private static let studiedCountKey = "lockglow.newWordsStudiedCount"
    private static let reviewsDoneDayKey = "lockglow.reviewsDoneDay"
    private static let reviewsDoneCountKey = "lockglow.reviewsDoneCount"
    private static let reminderEnabledKey = "lockglow.reminderEnabled"
    private static let reminderMinuteKey = "lockglow.reminderMinuteOfDay"
    private static let topicsKey = "lockglow.selectedTopicIDs"
    private static let startLevelKey = "lockglow.startLevel"
    private static let onboardingKey = "lockglow.onboardingCompleted"

    /// The flag as stored, nil when it was never written (`OnboardingGate`). Read with
    /// `bool(forKey:)`, not `as? Bool`: a launch argument arrives as the text "YES" / "NO".
    static var onboardingCompletedStored: Bool? {
        if UserDefaults.standard.object(forKey: onboardingKey) == nil {
            return nil
        }
        return UserDefaults.standard.bool(forKey: onboardingKey)
    }

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

    /// Minutes between word changes on the widget. 5 and 15 minutes, offered by earlier builds,
    /// read as 30 and are written back as 30 the first time (at launch, `AppModel`); anything
    /// else not in the choices reads as the default hour.
    static var rotationMinutes: Int {
        get {
            let stored = storedInt(forKey: rotationKey)
            let minutes = SettingsRules.rotationMinutes(stored: stored)
            if let stored = stored, SettingsRules.legacyRotationMinutes.contains(stored) {
                UserDefaults.standard.set(minutes, forKey: rotationKey)
            }
            return minutes
        }
        set {
            UserDefaults.standard.set(newValue, forKey: rotationKey)
        }
    }

    /// Daily goal of new words: the user's own number, otherwise the start level's
    /// (`defaultDailyNewWords`), so a goal nobody chose follows a new level.
    ///
    /// Saving the number the start level gives while the user never chose one saves nothing:
    /// `AppModel.setDailyNewWords` is also how a view hands the model a new level's goal, and
    /// that goal must keep following the level. So the setter is for that sync, and the level
    /// must be saved before it; a user's choice goes through `chooseDailyNewWords` first (a tap
    /// in "Ayarlar"), which counts even for the level's own number.
    static var dailyNewWords: Int {
        get {
            return AppPreferences.dailyNewWords(startLevel: startLevel)
        }
        set {
            if chosenDailyNewWords == nil && newValue == defaultDailyNewWords {
                return
            }
            UserDefaults.standard.set(newValue, forKey: dailyNewWordsKey)
        }
    }

    /// The goal with `level` as the start level: the user's own number, or the level's. The
    /// onboarding shows it before the level is saved.
    static func dailyNewWords(startLevel level: Level?) -> Int {
        return SettingsRules.dailyNewWords(stored: storedInt(forKey: dailyNewWordsKey), startLevel: level)
    }

    /// The user's own daily goal; nil while they never chose one (the start level decides).
    static var chosenDailyNewWords: Int? {
        return SettingsRules.chosenDailyNewWords(stored: storedInt(forKey: dailyNewWordsKey))
    }

    /// The user picked this goal in "Ayarlar": it stays whatever the level, also when it is the
    /// number the level would give.
    static func chooseDailyNewWords(_ count: Int) {
        guard dailyNewWordChoices.contains(count) else {
            return
        }
        UserDefaults.standard.set(count, forKey: dailyNewWordsKey)
    }

    /// A stored number, nil when the key was never written. `integer(forKey:)` also reads a
    /// launch argument, which arrives as text.
    private static func storedInt(forKey key: String) -> Int? {
        if UserDefaults.standard.object(forKey: key) == nil {
            return nil
        }
        return UserDefaults.standard.integer(forKey: key)
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

    // MARK: Feed encounters

    /// The feed's first encounters (`FeedEncounterStore` in FeedView.swift): word id → the first
    /// day the card was on screen.
    static let feedFirstSeenKey = "lockglow.feedFirstSeen"
    /// Posted by `clearFeedFirstSeen`: a feed on screen forgets its first encounters too.
    static let feedFirstSeenCleared = Notification.Name("lockglow.feedFirstSeen.cleared")

    /// "İlerlemeyi sıfırla": every feed card is a first encounter again.
    static func clearFeedFirstSeen() {
        UserDefaults.standard.removeObject(forKey: feedFirstSeenKey)
        NotificationCenter.default.post(name: feedFirstSeenCleared, object: nil)
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

    // MARK: Reviews done today

    /// How many answers today were for words already studied before (local calendar day): the
    /// "M tekrar" of "Bugün: N yeni kelime, M tekrar." on the "Tekrar" screens.
    static func reviewsDoneToday(now: Date = Date()) -> Int {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: now).timeIntervalSince1970
        if defaults.double(forKey: reviewsDoneDayKey) != today {
            return 0
        }
        return defaults.integer(forKey: reviewsDoneCountKey)
    }

    static func addReviewsDone(_ count: Int, now: Date = Date()) {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: now).timeIntervalSince1970
        let total = reviewsDoneToday(now: now) + count
        defaults.set(today, forKey: reviewsDoneDayKey)
        defaults.set(total, forKey: reviewsDoneCountKey)
    }

    static func resetReviewsDone() {
        UserDefaults.standard.removeObject(forKey: reviewsDoneDayKey)
        UserDefaults.standard.removeObject(forKey: reviewsDoneCountKey)
    }
}
