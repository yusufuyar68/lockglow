import Foundation
import SharedState

/// The progress widget's words (docs/tasarim/terimler.md; ogrenme_ilkeleri 2.1 and §3): calm and
/// in the same voice in every state. No streak, no red, no "0", no countdown, no call to action
/// and no backlog number above `ProgressStatus.shownCountLimit` ("10+"); no suffix after a number
/// or a time ("Sıradaki tekrar: bugün 21:40", not "21:40'ta"). Each visible line comes as
/// versions, fullest first: the view shows the first that fits whole, and every version says what
/// it is about (never a bare time). VoiceOver gets whole sentences with words, never "3 / 5"
/// (read "bölü").
enum ProgressText {
    /// The two rows of the rectangular family and what VoiceOver reads for them.
    struct Rows: Equatable {
        /// The first row's versions, fullest first.
        let first: [String]
        /// The second row's versions, fullest first; empty when there is no second row.
        let second: [String]
        let spoken: String
    }

    /// One line (the inline family) and what VoiceOver reads for it.
    struct Line: Equatable {
        let versions: [String]
        let spoken: String
    }

    /// The first row and the inline line before the app has written any numbers.
    static let appName = "Lockglow"
    static let openAppHint = "Uygulamayı bir kez aç"

    /// "6", or "10+" above the limit.
    static func count(_ n: Int) -> String {
        let limit = ProgressStatus.shownCountLimit
        return n > limit ? "\(limit)+" : "\(n)"
    }

    /// "6 kelime", or "10 kelimeden fazla" above the limit (no suffix on the number).
    static func spokenWords(_ n: Int) -> String {
        let limit = ProgressStatus.shownCountLimit
        return n > limit ? "\(limit) kelimeden fazla" : "\(n) kelime"
    }

    /// When `date` is, seen from `now`: ("bugün", "21:40"), ("yarın", "09:15") or ("24 Ekim",
    /// "09:00") (terimler §1: 24-hour time, two-digit hours).
    static func when(_ date: Date, now: Date, calendar: Calendar) -> (day: String, time: String) {
        let time = WidgetTime.clock(date, timeZone: calendar.timeZone)
        if calendar.isDate(date, inSameDayAs: now) {
            return ("bugün", time)
        }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now), calendar.isDate(date, inSameDayAs: tomorrow) {
            return ("yarın", time)
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "d MMMM"
        return (formatter.string(from: date), time)
    }

    /// A later day in numbers, day first: "26.10" (the shortest form of "26 Ekim").
    static func numericDay(_ date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }

    // MARK: Rectangular ("Sıradaki")

    /// First row: when the next review is ("şimdi" when one is due). Second row: how many words
    /// are in line today ("sırada": waiting, not done; the app's "Bugün: 3 yeni kelime, 12
    /// tekrar." counts what was done). A new user with nothing scheduled sees the daily goal.
    static func rectangular(_ status: ProgressStatus?, calendar: Calendar) -> Rows {
        guard let status = status else {
            return Rows(first: [appName], second: [openAppHint], spoken: "\(appName). \(openAppHint).")
        }
        if status.dueNow == 0 && status.nextDue == nil {
            let goal = goalLine(status)
            return Rows(
                first: ["Henüz tekrar yok"],
                second: goal?.versions ?? [],
                spoken: ["Henüz tekrar yok.", goal?.spoken].compactMap { $0 }.joined(separator: " ")
            )
        }
        let next = nextLine(status, calendar: calendar)
        let today: [String]
        let todaySpoken: String
        if status.dueToday > 0 {
            let n = count(status.dueToday)
            today = ["Bugün \(n) kelime sırada", "\(n) kelime sırada"]
            todaySpoken = "Bugün \(spokenWords(status.dueToday)) sırada."
        } else {
            today = ["Bugün tekrar yok"]
            todaySpoken = "Bugün tekrar yok."
        }
        return Rows(first: next.versions, second: today, spoken: "\(next.spoken). \(todaySpoken)")
    }

    // MARK: Inline

    /// The rectangular family's first row; a new user with nothing scheduled sees the daily goal.
    static func inline(_ status: ProgressStatus?, calendar: Calendar) -> Line {
        guard let status = status else {
            return Line(versions: [appName], spoken: "\(appName). \(openAppHint).")
        }
        if status.dueNow == 0 && status.nextDue == nil {
            return goalLine(status) ?? Line(versions: ["Henüz tekrar yok"], spoken: "Henüz tekrar yok.")
        }
        let next = nextLine(status, calendar: calendar)
        return Line(versions: next.versions, spoken: next.spoken + ".")
    }

    // MARK: Circular (the goal ring)

    /// What VoiceOver reads for the ring, as on the "Tekrar" start screen (`GoalRing`):
    /// "Günlük hedef 5 yeni kelime. Bugün 2 tanesini çalıştın." (no "0 tanesini" before the first),
    /// after "Bugünlük tamam." once the goal is met.
    static func goalSpoken(_ status: ProgressStatus?) -> String {
        guard let status = status else {
            return "\(appName). \(openAppHint)."
        }
        guard status.dailyGoal > 0 else {
            return "\(appName). Günlük hedef yok."
        }
        let goal = "Günlük hedef \(status.dailyGoal) yeni kelime."
        let spoken = status.newWordsToday > 0 ? goal + " Bugün \(status.newWordsToday) tanesini çalıştın." : goal
        return status.goalReached ? "Bugünlük tamam. " + spoken : spoken
    }

    /// The ring's center when it shows a symbol alone: a book before the first word of the day
    /// (no "0"), a check once the goal is met.
    static func goalSymbol(_ status: ProgressStatus?) -> String {
        return status?.goalReached == true ? "checkmark" : "character.book.closed"
    }

    /// The ring's counter while the goal is open and started, as the app's ring writes it:
    /// ("3", "/5"). Nil before the first word, once the goal is met, and without numbers.
    static func goalCounter(_ status: ProgressStatus?) -> (done: String, goal: String)? {
        guard let status = status, status.dailyGoal > 0, status.newWordsToday > 0, !status.goalReached else {
            return nil
        }
        return ("\(status.newWordsToday)", "/\(status.dailyGoal)")
    }

    // MARK: Parts

    /// The next review's day and time ("şimdi" when one is due), fullest first; the shortest still
    /// starts with "Tekrar:". A later day ends on its numeric form ("Tekrar: 26.10", as wide as
    /// "Tekrar: 21:40"), which fits the inline family at the largest text sizes, where "Tekrar:
    /// 26 Ekim" does not. `spoken` has no period. Only for a status with something due now or
    /// scheduled.
    private static func nextLine(_ status: ProgressStatus, calendar: Calendar) -> Line {
        guard status.dueNow == 0, let next = status.nextDue else {
            return Line(versions: ["Sıradaki tekrar: şimdi", "Tekrar: şimdi"], spoken: "Sıradaki tekrar: şimdi")
        }
        let (day, time) = when(next, now: status.date, calendar: calendar)
        let versions: [String]
        if day == "bugün" {
            versions = [
                "Sıradaki tekrar: bugün \(time)",
                "Sıradaki tekrar: \(time)",
                "Tekrar: bugün \(time)",
                "Tekrar: \(time)",
            ]
        } else if day == "yarın" {
            versions = [
                "Sıradaki tekrar: \(day) \(time)",
                "Tekrar: \(day) \(time)",
                "Tekrar: \(day)",
            ]
        } else {
            versions = [
                "Sıradaki tekrar: \(day) \(time)",
                "Tekrar: \(day) \(time)",
                "Tekrar: \(day)",
                "Tekrar: \(numericDay(next, calendar: calendar))",
            ]
        }
        return Line(versions: versions, spoken: "Sıradaki tekrar: \(day) \(time)")
    }

    /// The daily goal in words: before the first new word, while it is open, once it is met.
    /// The last versions are short enough for the inline family at the largest text sizes
    /// ("Hedef: 5", "Hedef: 3/5", without the spaces of "3 / 5" as the island's "4/10").
    /// Nil without a goal.
    private static func goalLine(_ status: ProgressStatus) -> Line? {
        let goal = status.dailyGoal
        guard goal > 0 else {
            return nil
        }
        let done = status.newWordsToday
        let versions: [String]
        if status.goalReached {
            versions = ["Bugünlük tamam"]
        } else if done == 0 {
            versions = [
                "Günlük hedef: \(goal) yeni kelime",
                "Hedef: \(goal) yeni kelime",
                "Hedef: \(goal) kelime",
                "Hedef: \(goal)",
            ]
        } else {
            versions = ["Günlük hedef: \(done) / \(goal)", "Hedef: \(done) / \(goal)", "Hedef: \(done)/\(goal)"]
        }
        return Line(versions: versions, spoken: goalSpoken(status))
    }
}
