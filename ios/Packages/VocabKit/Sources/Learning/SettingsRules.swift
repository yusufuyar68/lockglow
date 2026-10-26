import Foundation
import CoreModels

/// What the onboarding's level choice sets, how settings of an earlier build carry over, and
/// what a daily goal costs (`docs/tasarim/ogrenme_ilkeleri.md` §1b, §2.8, §2.9). Pure; the app
/// (`AppPreferences`) reads and writes UserDefaults.
public enum SettingsRules {
    /// "Kelime ne sıklıkla değişsin?": 30 dk · 1 saat · 2 saat · 4 saat. More often than every half
    /// hour leaves each word a single glance and pulls the eye.
    public static let rotationMinuteChoices = [30, 60, 120, 240]
    public static let defaultRotationMinutes = 60
    /// Intervals earlier builds offered and this one does not; they become 30 minutes, the
    /// closest one left, instead of quietly falling back to the default hour.
    public static let legacyRotationMinutes: Set<Int> = [5, 15]
    public static let legacyRotationTarget = 30

    /// "Günde kaç yeni kelime?"
    public static let dailyNewWordChoices = [5, 10, 15, 20]

    /// The interval in effect for a stored value: an offered one stays, 5 and 15 minutes become
    /// 30, anything else (never set, an unknown number) is the default hour.
    public static func rotationMinutes(stored: Int?) -> Int {
        guard let stored = stored else {
            return defaultRotationMinutes
        }
        if rotationMinuteChoices.contains(stored) {
            return stored
        }
        if legacyRotationMinutes.contains(stored) {
            return legacyRotationTarget
        }
        return defaultRotationMinutes
    }

    /// The daily goal of someone who never chose one: 5 from A1 and A2, 10 from B1 (B2 too).
    /// Without a start level the words start at A1, so 5. Starting small keeps the reviews of the first weeks
    /// light for a beginner (§1 point 9).
    public static func defaultDailyNewWords(startLevel: Level?) -> Int {
        guard let level = startLevel, level >= .b1 else {
            return 5
        }
        return 10
    }

    /// The user's own goal: a stored number that is one of the choices. Nil means never chosen
    /// (nothing stored, or a number no longer offered), and then the start level decides.
    public static func chosenDailyNewWords(stored: Int?) -> Int? {
        guard let stored = stored, dailyNewWordChoices.contains(stored) else {
            return nil
        }
        return stored
    }

    /// The goal in effect: the user's own number, otherwise the start level's.
    public static func dailyNewWords(stored: Int?, startLevel: Level?) -> Int {
        return chosenDailyNewWords(stored: stored) ?? defaultDailyNewWords(startLevel: startLevel)
    }

    /// At least this many minutes a day, reviews included, once a goal's reviews have built up
    /// (§2.9): about 72 seconds per new word (its first meeting and about 5 reviews, at 8 to 10
    /// seconds a question) and a minute to start. A floor: it counts no forgotten words and no
    /// monthly refreshers, so "Ayarlar" says "en az" until the times are measured on a device
    /// (§2.13). 5 → 7, 10 → 13, 15 → 19, 20 → 25.
    public static func minimumMinutesPerDay(dailyNewWords: Int) -> Int {
        let goal = max(0, dailyNewWords)
        return 1 + (goal * 6 + 2) / 5
    }
}
