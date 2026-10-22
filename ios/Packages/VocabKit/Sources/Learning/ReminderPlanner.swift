import Foundation
import CoreModels

/// One daily reminder: when it fires, what is waiting and the word its text names.
public struct Reminder: Equatable, Sendable {
    public let fireDate: Date
    /// Reviews due by `fireDate` if nothing is studied before then.
    public let dueCount: Int
    /// New words that day's goal offers.
    public let newCount: Int
    /// The word the text names: the most overdue review when one is due, else the next new word.
    /// Nil when there is none fit for a one-line notification (`ReminderText.shownWord`).
    public let word: String?
    /// Turkish meaning of `word`, only for a new word: a review's meaning would give the answer away.
    public let meaning: String?
    /// Which wording the text uses (`ReminderText.variant`); it turns from one day to the next.
    public let variant: Int

    public init(
        fireDate: Date,
        dueCount: Int,
        newCount: Int,
        word: String? = nil,
        meaning: String? = nil,
        variant: Int = 0
    ) {
        self.fireDate = fireDate
        self.dueCount = dueCount
        self.newCount = newCount
        self.word = word
        self.meaning = meaning
        self.variant = variant
    }

    /// Notification title (`ReminderText.message`).
    public var title: String {
        return ReminderText.message(for: self).title
    }

    /// Notification body, one line (`ReminderText.message`).
    public var body: String {
        return ReminderText.message(for: self).body
    }
}

/// Plans the daily "Tekrar" reminders. Pure; the app turns the result into local notifications.
public enum ReminderPlanner {
    /// One reminder a day for `days` days at `minuteOfDay` (minutes after local midnight by
    /// `calendar`), starting today if that time is still ahead. A day with nothing to do (no
    /// review due, no new word offered) gets no reminder; that is how today's reminder disappears
    /// once the round is done.
    ///
    /// Counts and the named word come from the current progress, as if nothing were studied until
    /// then. Studying only lowers the counts, so the app plans again each time it goes to the
    /// background.
    ///
    /// Reviews come from `feed` (every word); new words from `newWordFeed`, the user's deck
    /// (`DeckFilter.feed`), as in "Tekrar". Nil means `feed`.
    public static func plan(
        feed: [WidgetWord],
        newWordFeed: [WidgetWord]? = nil,
        progress: [Int: WordProgress],
        now: Date,
        minuteOfDay: Int,
        days: Int,
        dailyNewGoal: Int,
        newStudiedToday: Int,
        calendar: Calendar
    ) -> [Reminder] {
        guard days > 0, (0..<1440).contains(minuteOfDay) else {
            return []
        }
        let goal = max(dailyNewGoal, 0)
        let newWords = ReviewPlanner.newWords(feed: newWordFeed ?? feed, progress: progress, limit: goal)
        let startOfToday = calendar.startOfDay(for: now)

        var result: [Reminder] = []
        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday),
                  let fireDate = calendar.date(
                      bySettingHour: minuteOfDay / 60,
                      minute: minuteOfDay % 60,
                      second: 0,
                      of: day
                  ),
                  fireDate > now
            else {
                continue
            }
            let dueWords = ReviewPlanner.dueWords(feed: feed, progress: progress, now: fireDate, limit: Int.max)
            let offered = offset == 0 ? min(newWords.count, max(goal - newStudiedToday, 0)) : newWords.count
            if dueWords.isEmpty && offered == 0 {
                continue
            }
            // The text calls to reviews first; new words only when nothing is due.
            let named = dueWords.first ?? newWords.first
            let word = named.flatMap { ReminderText.shownWord($0.lemma) }
            let meaning = dueWords.isEmpty && word != nil ? ReminderText.shownWord(named?.glossTR) : nil
            result.append(Reminder(
                fireDate: fireDate,
                dueCount: dueWords.count,
                newCount: offered,
                word: word,
                meaning: meaning,
                variant: ReminderText.variant(for: fireDate, calendar: calendar)
            ))
        }
        return result
    }
}

/// What a reminder says: a short title and one line of body, warm and without pressure. Reviews
/// come first, new words only when nothing is due. No streaks, no guilt, no emoji; the English
/// word stands alone, never with a Turkish suffix.
public enum ReminderText {
    public struct Message: Equatable, Sendable {
        public let title: String
        public let body: String

        public init(title: String, body: String) {
            self.title = title
            self.body = body
        }
    }

    /// Wordings per kind of reminder; the day turns them (`variant(for:calendar:)`).
    public static let variantCount = 3

    /// Longer words and meanings fall back to the text without them (content max: 28).
    public static let maxShownLength = 32

    public static func message(for reminder: Reminder) -> Message {
        return message(
            dueCount: reminder.dueCount,
            newCount: reminder.newCount,
            word: reminder.word,
            meaning: reminder.meaning,
            variant: reminder.variant
        )
    }

    /// `meaning` is used only for new words; any `variant` works (it wraps around).
    public static func message(dueCount: Int, newCount: Int, word: String?, meaning: String?, variant: Int) -> Message {
        let pick = ((variant % variantCount) + variantCount) % variantCount
        if dueCount > 0 {
            guard let word = word else {
                let body = dueCount == 1 ? "Bir kelime tekrar için hazır." : "\(dueCount) kelime tekrar için hazır."
                return Message(title: "Tekrar zamanı", body: body)
            }
            switch pick {
            case 0:
                return Message(title: "Hatırlıyor musun: \(word)?", body: "Önce kendin hatırla, sonra anlamına bak.")
            case 1:
                return Message(title: "\(word) ne demekti?", body: "Unuttuysan sorun değil, tekrar bunun için var.")
            default:
                let body = dueCount == 1 ? "Bugün yalnızca \(word) var." : "\(word) ve \(dueCount - 1) kelime daha hazır."
                return Message(title: "Kısa bir tekrar", body: body)
            }
        }
        guard let word = word else {
            return Message(title: "Yeni kelimeler hazır", body: newWordsLine(newCount))
        }
        switch pick {
        case 0:
            return Message(title: "Sıradaki kelime: \(word)", body: "Örnek cümlesiyle öğren, daha kolay akılda kalır.")
        case 1:
            return Message(title: "Yeni kelimeler hazır", body: "Sırada \(word) var. Sesli söylemek akılda tutmaya yardım eder.")
        default:
            if let meaning = meaning {
                // Some meanings are questions ("ne dersin?"): no full stop after those.
                let stop = meaning.last.map { ".?!…".contains($0) } == true ? "" : "."
                return Message(title: "Yeni bir kelime: \(word)", body: "Anlamı: \(meaning)\(stop) Örnek cümlesi uygulamada.")
            }
            return Message(title: "Yeni bir kelime: \(word)", body: newWordsLine(newCount))
        }
    }

    /// The wording for `date`'s day: the number of calendar days since a fixed day, so consecutive
    /// days read differently and planning again does not change a day's text.
    public static func variant(for date: Date, calendar: Calendar) -> Int {
        let anchor = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
        let days = calendar.dateComponents([.day], from: anchor, to: calendar.startOfDay(for: date)).day ?? 0
        return ((days % variantCount) + variantCount) % variantCount
    }

    /// `text` on one line, or nil when it is empty or too long for a notification line.
    public static func shownWord(_ text: String?) -> String? {
        guard let text = text else {
            return nil
        }
        let line = text.split(whereSeparator: \.isNewline).joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        guard !line.isEmpty, line.count <= maxShownLength else {
            return nil
        }
        return line
    }

    private static func newWordsLine(_ count: Int) -> String {
        return count > 0 ? "Bugün \(count) yeni kelime var, istersen bir göz at." : "İstersen birkaç yeni kelimeye göz at."
    }
}
