import Foundation

/// `progress_snapshot.json`: a few numbers for the Lock Screen progress widget. Written ONLY by
/// the app (`AppModel.writeProgressSnapshot`, each time it writes the widget plan), read by the
/// widget; the widget never writes it (contract section 6, single writer).
///
/// No word ids, words or meanings: only today's new-word goal and count and the due dates of the
/// reviews and refreshers. What changes with time (what is due now, today's counts after
/// midnight) is worked out by `status(at:calendar:)`, so the widget stays right between two writes
/// without the app.
public struct ProgressSnapshot: Codable, Equatable, Sendable {
    public static let currentVersion = 1
    public static let fileName = "progress_snapshot.json"
    /// The earliest due dates kept. The widget never shows a count above
    /// `ProgressStatus.shownCountLimit`, so counts that reach this many are "at least".
    public static let dueDateLimit = 100

    public var version: Int
    /// When the app wrote the file. `newWordsToday` belongs to this moment's local day.
    public var writtenAt: Date
    /// The daily goal of new words ("Ayarlar", `AppPreferences.dailyNewWords`).
    public var dailyGoal: Int
    /// New words studied on the local day of `writtenAt` (the ring on the "Tekrar" start screen:
    /// only words recalled in "Hatırla" count).
    public var newWordsToday: Int
    /// Due dates of the reviews and refreshers, earliest first, at most `dueDateLimit`; those
    /// already due are included.
    public var dueDates: [Date]

    /// Sorts `dueDates` and keeps the earliest `dueDateLimit`. Negative counts become 0.
    public init(
        version: Int = ProgressSnapshot.currentVersion,
        writtenAt: Date,
        dailyGoal: Int,
        newWordsToday: Int,
        dueDates: [Date]
    ) {
        self.version = version
        self.writtenAt = writtenAt
        self.dailyGoal = max(0, dailyGoal)
        self.newWordsToday = max(0, newWordsToday)
        self.dueDates = Array(dueDates.sorted().prefix(ProgressSnapshot.dueDateLimit))
    }

    /// What the widget shows at `date`. The day's new-word count restarts at local midnight:
    /// on another day than `writtenAt` it is 0 until the app writes again. `dueToday` counts what
    /// is due before the next local midnight; a review at exactly midnight is tomorrow's, as the
    /// widget labels it ("yarın 00:00").
    public func status(at date: Date, calendar: Calendar = .current) -> ProgressStatus {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        var dueNow = 0
        var dueToday = 0
        var nextDue: Date?
        // No reliance on the order: a decoded file skips the sorting initializer.
        for due in dueDates {
            if due <= date {
                dueNow += 1
            } else if nextDue.map({ due < $0 }) ?? true {
                nextDue = due
            }
            if due < endOfDay {
                dueToday += 1
            }
        }
        return ProgressStatus(
            date: date,
            dailyGoal: dailyGoal,
            newWordsToday: calendar.isDate(date, inSameDayAs: writtenAt) ? newWordsToday : 0,
            dueNow: dueNow,
            dueToday: dueToday,
            nextDue: nextDue
        )
    }

    /// The moments after `start` (up to `end`, at most `limit`) when what the widget shows can
    /// change, for its timeline: the first review falling due while none is due (from then on
    /// "Sıradaki tekrar: şimdi" stays until the app writes again), and each local midnight (today's counts
    /// restart, "yarın" becomes today). Later due dates of the same day change nothing shown:
    /// the day's total is already counted.
    public func timelineDates(after start: Date, until end: Date, limit: Int, calendar: Calendar = .current) -> [Date] {
        var dates: [Date] = []
        var current = start
        while dates.count < limit {
            let startOfDay = calendar.startOfDay(for: current)
            guard let midnight = calendar.date(byAdding: .day, value: 1, to: startOfDay), midnight > current else {
                break
            }
            var next = midnight
            let status = status(at: current, calendar: calendar)
            if status.dueNow == 0, let due = status.nextDue, due < midnight {
                next = due
            }
            if next > end {
                break
            }
            dates.append(next)
            current = next
        }
        return dates
    }

    enum CodingKeys: String, CodingKey {
        case version
        case writtenAt = "written_at"
        case dailyGoal = "daily_goal"
        case newWordsToday = "new_words_today"
        case dueDates = "due_dates"
    }
}

/// The progress widget's numbers at one moment (`ProgressSnapshot.status(at:calendar:)`).
public struct ProgressStatus: Equatable, Sendable {
    /// The widget shows at most this count; above it, "10+" (no big backlog number,
    /// docs/tasarim/ogrenme_ilkeleri.md §3; a "Tekrar" round is at most 10 words).
    public static let shownCountLimit = 10

    /// The moment this status is for.
    public var date: Date
    public var dailyGoal: Int
    /// New words studied on `date`'s local day.
    public var newWordsToday: Int
    /// Reviews and refreshers due at `date`.
    public var dueNow: Int
    /// Reviews and refreshers due before the next local midnight (those due now included).
    public var dueToday: Int
    /// The earliest due date after `date`; nil when none is known.
    public var nextDue: Date?

    public init(date: Date, dailyGoal: Int, newWordsToday: Int, dueNow: Int, dueToday: Int, nextDue: Date?) {
        self.date = date
        self.dailyGoal = dailyGoal
        self.newWordsToday = newWordsToday
        self.dueNow = dueNow
        self.dueToday = dueToday
        self.nextDue = nextDue
    }

    /// Today's goal of new words is met (the ring is full).
    public var goalReached: Bool {
        return dailyGoal > 0 && newWordsToday >= dailyGoal
    }

    /// How full the ring is: 0...1.
    public var goalFraction: Double {
        guard dailyGoal > 0 else {
            return 0
        }
        return max(0, min(1, Double(newWordsToday) / Double(dailyGoal)))
    }
}

extension AppGroupStore {
    public var progressSnapshotURL: URL {
        return containerURL.appendingPathComponent(ProgressSnapshot.fileName)
    }

    /// Best effort: nil for a missing or undecodable file.
    public func readProgressSnapshot() -> ProgressSnapshot? {
        guard let data = try? Data(contentsOf: progressSnapshotURL) else {
            return nil
        }
        return try? JSONCoding.makeDecoder().decode(ProgressSnapshot.self, from: data)
    }

    /// The app only (single writer). Atomic, readable after the first unlock (`AtomicFile`).
    public func writeProgressSnapshot(_ snapshot: ProgressSnapshot) throws {
        let data = try JSONCoding.makeEncoder().encode(snapshot)
        try AtomicFile.write(data, to: progressSnapshotURL)
    }
}
