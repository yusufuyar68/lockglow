import Foundation

/// On-device usage measurements: is studying light enough? (docs/tasarim/ogrenme_ilkeleri.md
/// §1c item 10 and §2.13). Per local day: answers and how many were right at the first try, round
/// lengths, rounds left with "Bitir", taps per new word, "Biliyorum" words checked 3 days later and
/// the Leitner boxes; and whether each daily reminder was opened.
///
/// Stays on the phone: no network, no export, not in the App Group (the widget never reads it),
/// not in device backups. "İlerlemeyi sıfırla" deletes it (`LocalMetricsRecorder.reset`).
/// No words and no answers are stored, only counts and durations.
///
/// A pure value: every change takes the clock and the calendar. `LocalMetricsRecorder` keeps it
/// in a file.
public struct LocalMetrics: Codable, Equatable, Sendable {
    /// Days and reminders older than this many days (before the newest change) are dropped.
    public static let keptDays = 120
    /// An answer slower than this still counts, but its time is left out (the phone was put down).
    public static let maxAnswerSeconds: TimeInterval = 120

    /// One entry per local day with any change, oldest first.
    public var days: [DayMetrics]
    /// The daily reminders that were scheduled, oldest first; at most one per day.
    public var reminders: [ReminderRecord]

    public init(days: [DayMetrics] = [], reminders: [ReminderRecord] = []) {
        self.days = days
        self.reminders = reminders
    }

    /// "2026-10-22": the local day of `date` by `calendar`. Sorts like the dates.
    public static func dayKey(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return pad(parts.year ?? 0, width: 4) + "-" + pad(parts.month ?? 0, width: 2) + "-" + pad(parts.day ?? 0, width: 2)
    }

    private static func pad(_ value: Int, width: Int) -> String {
        let text = String(value)
        return String(repeating: "0", count: max(0, width - text.count)) + text
    }

    // MARK: Changes

    /// One answered question in "Tekrar".
    /// - `isNew`: the word had never been answered before (its first question).
    /// - `firstTryCorrect`: whether the first attempt at this question was right; nil when the
    ///   question has no right answer to compare with.
    /// - `seconds`: from the question appearing to the answer; nil when not timed.
    public mutating func recordAnswer(isNew: Bool, firstTryCorrect: Bool?, seconds: TimeInterval?, at now: Date, calendar: Calendar) {
        updateDay(now, calendar: calendar) { day in
            if isNew {
                day.newWords += 1
            } else {
                day.reviews += 1
            }
            if let correct = firstTryCorrect {
                day.firstTryAnswers += 1
                if correct {
                    day.firstTryCorrect += 1
                }
            }
            if let seconds = seconds, seconds >= 0, seconds <= LocalMetrics.maxAnswerSeconds {
                day.answerSeconds += seconds
                day.timedAnswers += 1
            }
        }
    }

    /// A "Tekrar" round ended: its active length, and whether "Bitir" ended it before the last card.
    public mutating func recordRound(seconds: TimeInterval, endedEarly: Bool, at now: Date, calendar: Calendar) {
        guard seconds > 0 else {
            return
        }
        updateDay(now, calendar: calendar) { day in
            day.roundSeconds.append(seconds)
            if endedEarly {
                day.roundsEndedEarly += 1
            }
        }
    }

    /// A new word was introduced: the taps it took from its first card to the next word.
    public mutating func recordNewWord(taps: Int, at now: Date, calendar: Calendar) {
        guard taps >= 0 else {
            return
        }
        updateDay(now, calendar: calendar) { day in
            day.newWordTaps.append(taps)
        }
    }

    /// The check question of a word marked "Biliyorum" or "Bunu zaten biliyorum" (3 days later).
    public mutating func recordKnownCheck(passed: Bool, at now: Date, calendar: Calendar) {
        updateDay(now, calendar: calendar) { day in
            if passed {
                day.knownChecksPassed += 1
            } else {
                day.knownChecksFailed += 1
            }
        }
    }

    /// The Leitner boxes now; the day keeps its last snapshot.
    public mutating func recordBoxes(_ counts: BoxCounts, at now: Date, calendar: Calendar) {
        updateDay(now, calendar: calendar) { day in
            day.boxes = counts
        }
    }

    /// The reminders now scheduled (the app replaces its whole plan each time). Reminders whose
    /// time has passed stay as they are; the ones still ahead are replaced by `fireDates`. An
    /// empty list (reminders off, or the day's work done) removes the ones still ahead.
    public mutating func recordReminderPlan(_ fireDates: [Date], now: Date, calendar: Calendar) {
        var kept = reminders.filter { $0.fireDate <= now }
        var plannedDays = Set(kept.map { LocalMetrics.dayKey($0.fireDate, calendar: calendar) })
        for date in fireDates.sorted() where date > now {
            let key = LocalMetrics.dayKey(date, calendar: calendar)
            if plannedDays.insert(key).inserted {
                kept.append(ReminderRecord(fireDate: date))
            }
        }
        reminders = kept.sorted { $0.fireDate < $1.fireDate }
        trim(now: now, calendar: calendar)
    }

    /// The reminder delivered at `deliveredAt` was tapped.
    public mutating func recordReminderOpened(deliveredAt: Date, calendar: Calendar) {
        let key = LocalMetrics.dayKey(deliveredAt, calendar: calendar)
        if let index = reminders.lastIndex(where: { LocalMetrics.dayKey($0.fireDate, calendar: calendar) == key }) {
            reminders[index].opened = true
            reminders[index].appOpenedAfter = true
        } else {
            // Scheduled before measuring began.
            var record = ReminderRecord(fireDate: deliveredAt)
            record.opened = true
            record.appOpenedAfter = true
            reminders.append(record)
            reminders.sort { $0.fireDate < $1.fireDate }
        }
        trim(now: deliveredAt, calendar: calendar)
    }

    /// The app was in use at `now` (it came to the front, or left it): a reminder that fired
    /// earlier the same day was not ignored.
    public mutating func recordAppActive(at now: Date, calendar: Calendar) {
        let key = LocalMetrics.dayKey(now, calendar: calendar)
        for index in reminders.indices where reminders[index].fireDate <= now
            && LocalMetrics.dayKey(reminders[index].fireDate, calendar: calendar) == key {
            reminders[index].appOpenedAfter = true
        }
    }

    private mutating func updateDay(_ now: Date, calendar: Calendar, _ change: (inout DayMetrics) -> Void) {
        let key = LocalMetrics.dayKey(now, calendar: calendar)
        if let index = days.lastIndex(where: { $0.day == key }) {
            change(&days[index])
        } else {
            var day = DayMetrics(day: key)
            change(&day)
            days.append(day)
            days.sort { $0.day < $1.day }
        }
        trim(now: now, calendar: calendar)
    }

    private mutating func trim(now: Date, calendar: Calendar) {
        guard let cutoff = calendar.date(byAdding: .day, value: -LocalMetrics.keptDays, to: now) else {
            return
        }
        let cutoffKey = LocalMetrics.dayKey(cutoff, calendar: calendar)
        days.removeAll { $0.day < cutoffKey }
        reminders.removeAll { $0.fireDate < cutoff }
    }

    // MARK: Report

    /// The last `windowDays` days (today included) against the §2.13 targets. `dailyNewWords` is
    /// the goal chosen in "Ayarlar": its minutes label is the daily time target.
    public func report(dailyNewWords: Int, windowDays: Int = 28, now: Date, calendar: Calendar) -> LocalMetricsReport {
        let start = calendar.date(byAdding: .day, value: -(max(windowDays, 1) - 1), to: now) ?? now
        let startKey = LocalMetrics.dayKey(start, calendar: calendar)
        let todayKey = LocalMetrics.dayKey(now, calendar: calendar)
        let window = days.filter { $0.day >= startKey && $0.day <= todayKey }

        let answerDays = window.filter { $0.reviews + $0.newWords > 0 }
        let roundDays = window.filter { !$0.roundSeconds.isEmpty }
        let rounds = window.flatMap(\.roundSeconds)
        let taps = window.flatMap(\.newWordTaps).map { Double($0) }
        let firstTryAnswers = window.reduce(0) { $0 + $1.firstTryAnswers }
        let firstTryCorrect = window.reduce(0) { $0 + $1.firstTryCorrect }
        let timedAnswers = window.reduce(0) { $0 + $1.timedAnswers }
        let answerSeconds = window.reduce(0.0) { $0 + $1.answerSeconds }
        let earlyRounds = window.reduce(0) { $0 + $1.roundsEndedEarly }
        let checksPassed = window.reduce(0) { $0 + $1.knownChecksPassed }
        let checksFailed = window.reduce(0) { $0 + $1.knownChecksFailed }
        let checks = checksPassed + checksFailed

        let fired = reminders.filter { $0.fireDate <= now && $0.fireDate >= calendar.startOfDay(for: start) }
        // A reminder of today can still be answered today: ignored only once its day is over.
        let ignored = fired.filter {
            !$0.appOpenedAfter && LocalMetrics.dayKey($0.fireDate, calendar: calendar) < todayKey
        }

        let medianDailyMinutes = LocalMetrics.median(roundDays.map { $0.roundSeconds.reduce(0, +) / 60 })
        let medianTaps = LocalMetrics.median(taps)
        let earlyEndRate = rounds.isEmpty ? nil : Double(earlyRounds) / Double(rounds.count)
        let knownFailRate = checks == 0 ? nil : Double(checksFailed) / Double(checks)

        let targets = LocalMetricsTargets.self
        let acceptance = [
            AcceptanceCheck(
                goal: .dailyMinutes,
                value: medianDailyMinutes,
                limit: Double(targets.shownDailyMinutes(dailyNewWords: dailyNewWords)),
                samples: roundDays.count,
                minimumSamples: targets.minimumStudyDays
            ),
            AcceptanceCheck(
                goal: .tapsPerNewWord,
                value: medianTaps,
                limit: targets.maxMedianTapsPerNewWord,
                samples: taps.count,
                minimumSamples: targets.minimumNewWords
            ),
            AcceptanceCheck(
                goal: .earlyEndRate,
                value: earlyEndRate,
                limit: targets.maxEarlyEndRate,
                samples: rounds.count,
                minimumSamples: targets.minimumRounds
            ),
            AcceptanceCheck(
                goal: .knownCheckFailRate,
                value: knownFailRate,
                limit: targets.maxKnownCheckFailRate,
                samples: checks,
                minimumSamples: targets.minimumKnownChecks
            ),
        ]

        return LocalMetricsReport(
            windowDays: max(windowDays, 1),
            studyDays: Set(answerDays.map(\.day)).union(roundDays.map(\.day)).count,
            medianDailyAnswers: LocalMetrics.median(answerDays.map { Double($0.reviews + $0.newWords) }),
            medianDailyReviews: LocalMetrics.median(answerDays.map { Double($0.reviews) }),
            medianDailyNewWords: LocalMetrics.median(answerDays.map { Double($0.newWords) }),
            firstTryCorrectRate: firstTryAnswers == 0 ? nil : Double(firstTryCorrect) / Double(firstTryAnswers),
            firstTryAnswers: firstTryAnswers,
            meanSecondsPerAnswer: timedAnswers == 0 ? nil : answerSeconds / Double(timedAnswers),
            medianDailyMinutes: medianDailyMinutes,
            medianRoundMinutes: LocalMetrics.median(rounds.map { $0 / 60 }),
            rounds: rounds.count,
            earlyEndRate: earlyEndRate,
            medianTapsPerNewWord: medianTaps,
            knownChecks: checks,
            knownCheckFailRate: knownFailRate,
            remindersFired: fired.count,
            remindersOpened: fired.filter(\.opened).count,
            remindersIgnored: ignored.count,
            boxes: window.last(where: { $0.boxes != nil })?.boxes,
            acceptance: acceptance
        )
    }

    /// The middle value (the mean of the two middle ones for an even count); nil when empty.
    public static func median(_ values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count % 2 == 1 {
            return sorted[middle]
        }
        return (sorted[middle - 1] + sorted[middle]) / 2
    }

    enum CodingKeys: String, CodingKey {
        case days
        case reminders
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        days = try container.decodeIfPresent([DayMetrics].self, forKey: .days) ?? []
        reminders = try container.decodeIfPresent([ReminderRecord].self, forKey: .reminders) ?? []
    }
}

/// One local day's counts. Missing keys decode as zero, so a later build can add fields.
public struct DayMetrics: Codable, Equatable, Sendable {
    /// `LocalMetrics.dayKey`, "2026-10-22".
    public let day: String
    /// Questions on words answered before (reviews and refreshers).
    public var reviews: Int
    /// First questions of never-answered words.
    public var newWords: Int
    /// Questions with a right answer to compare with, and how many were right at the first try.
    public var firstTryAnswers: Int
    public var firstTryCorrect: Int
    /// Seconds per answer, summed over `timedAnswers` (slow answers left out).
    public var answerSeconds: Double
    public var timedAnswers: Int
    /// Active seconds of each round, in the order they ended.
    public var roundSeconds: [Double]
    /// Rounds ended with "Bitir" before the last card.
    public var roundsEndedEarly: Int
    /// Taps per new word, in the order they were introduced.
    public var newWordTaps: [Int]
    /// 3-day checks of "Biliyorum" words.
    public var knownChecksPassed: Int
    public var knownChecksFailed: Int
    /// The Leitner boxes at the day's last snapshot.
    public var boxes: BoxCounts?

    public init(day: String) {
        self.day = day
        reviews = 0
        newWords = 0
        firstTryAnswers = 0
        firstTryCorrect = 0
        answerSeconds = 0
        timedAnswers = 0
        roundSeconds = []
        roundsEndedEarly = 0
        newWordTaps = []
        knownChecksPassed = 0
        knownChecksFailed = 0
        boxes = nil
    }

    enum CodingKeys: String, CodingKey {
        case day
        case reviews
        case newWords = "new_words"
        case firstTryAnswers = "first_try_answers"
        case firstTryCorrect = "first_try_correct"
        case answerSeconds = "answer_seconds"
        case timedAnswers = "timed_answers"
        case roundSeconds = "round_seconds"
        case roundsEndedEarly = "rounds_ended_early"
        case newWordTaps = "new_word_taps"
        case knownChecksPassed = "known_checks_passed"
        case knownChecksFailed = "known_checks_failed"
        case boxes
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        day = try c.decode(String.self, forKey: .day)
        reviews = try c.decodeIfPresent(Int.self, forKey: .reviews) ?? 0
        newWords = try c.decodeIfPresent(Int.self, forKey: .newWords) ?? 0
        firstTryAnswers = try c.decodeIfPresent(Int.self, forKey: .firstTryAnswers) ?? 0
        firstTryCorrect = try c.decodeIfPresent(Int.self, forKey: .firstTryCorrect) ?? 0
        answerSeconds = try c.decodeIfPresent(Double.self, forKey: .answerSeconds) ?? 0
        timedAnswers = try c.decodeIfPresent(Int.self, forKey: .timedAnswers) ?? 0
        roundSeconds = try c.decodeIfPresent([Double].self, forKey: .roundSeconds) ?? []
        roundsEndedEarly = try c.decodeIfPresent(Int.self, forKey: .roundsEndedEarly) ?? 0
        newWordTaps = try c.decodeIfPresent([Int].self, forKey: .newWordTaps) ?? []
        knownChecksPassed = try c.decodeIfPresent(Int.self, forKey: .knownChecksPassed) ?? 0
        knownChecksFailed = try c.decodeIfPresent(Int.self, forKey: .knownChecksFailed) ?? 0
        boxes = try c.decodeIfPresent(BoxCounts.self, forKey: .boxes)
    }
}

/// How the studied words spread over the Leitner boxes. Words never answered are not counted.
public struct BoxCounts: Codable, Equatable, Sendable {
    /// Learning words per box: index 0 is box 1.
    public var boxes: [Int]
    /// Graduated from the last box.
    public var graduated: Int
    /// Marked "Biliyorum" (or "Bunu zaten biliyorum") rather than graduated.
    public var markedKnown: Int

    public init(boxes: [Int], graduated: Int, markedKnown: Int) {
        self.boxes = boxes
        self.graduated = graduated
        self.markedKnown = markedKnown
    }

    public init(progress: [Int: WordProgress]) {
        var boxes = Array(repeating: 0, count: Leitner.maxBox)
        var graduated = 0
        var markedKnown = 0
        for word in progress.values {
            switch word.state {
            case .new:
                continue
            case .learning:
                if word.box >= 1 && word.box <= boxes.count {
                    boxes[word.box - 1] += 1
                }
            case .known:
                if word.knownOverride {
                    markedKnown += 1
                } else {
                    graduated += 1
                }
            }
        }
        self.init(boxes: boxes, graduated: graduated, markedKnown: markedKnown)
    }

    enum CodingKeys: String, CodingKey {
        case boxes
        case graduated
        case markedKnown = "marked_known"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        boxes = try c.decodeIfPresent([Int].self, forKey: .boxes) ?? []
        graduated = try c.decodeIfPresent(Int.self, forKey: .graduated) ?? 0
        markedKnown = try c.decodeIfPresent(Int.self, forKey: .markedKnown) ?? 0
    }
}

/// One scheduled daily reminder.
public struct ReminderRecord: Codable, Equatable, Sendable {
    public let fireDate: Date
    /// The notification itself was tapped.
    public var opened: Bool
    /// The app came to the front after it fired, the same day (by the notification or not).
    public var appOpenedAfter: Bool

    public init(fireDate: Date) {
        self.fireDate = fireDate
        opened = false
        appOpenedAfter = false
    }

    enum CodingKeys: String, CodingKey {
        case fireDate = "fire_date"
        case opened
        case appOpenedAfter = "app_opened_after"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        fireDate = try c.decode(Date.self, forKey: .fireDate)
        opened = try c.decodeIfPresent(Bool.self, forKey: .opened) ?? false
        appOpenedAfter = try c.decodeIfPresent(Bool.self, forKey: .appOpenedAfter) ?? false
    }
}

/// The first acceptance targets of §2.13. They are our choice, not evidence, and are tuned after
/// the first measurements.
public enum LocalMetricsTargets {
    /// Median taps per new word: at most 4.
    public static let maxMedianTapsPerNewWord: Double = 4
    /// Rounds ended with "Bitir": under 25 %.
    public static let maxEarlyEndRate: Double = 0.25
    /// "Biliyorum" words failing their 3-day check: above 30 %, the button's place and text are
    /// rethought.
    public static let maxKnownCheckFailRate: Double = 0.30
    /// Fewest samples before a target is judged (our choice: one bad day is not a verdict).
    public static let minimumStudyDays = 3
    public static let minimumNewWords = 5
    public static let minimumRounds = 4
    public static let minimumKnownChecks = 5

    /// The daily minutes "Ayarlar" shows next to the daily new-word goal (§2.9): 5 → 7, 10 → 13,
    /// 15 → 19, 20 → 25. A floor until measured; the median study day should stay at or under it.
    public static func shownDailyMinutes(dailyNewWords: Int) -> Int {
        return max(dailyNewWords, 0) * 6 / 5 + 1
    }
}

/// One §2.13 target and where the window stands.
public struct AcceptanceCheck: Equatable, Sendable {
    public enum Goal: String, CaseIterable, Sendable {
        /// Median minutes on a study day, at most the minutes "Ayarlar" shows.
        case dailyMinutes
        /// Median taps per new word, at most 4.
        case tapsPerNewWord
        /// Share of rounds ended with "Bitir", under 25 %.
        case earlyEndRate
        /// Share of "Biliyorum" words failing the 3-day check, at most 30 %.
        case knownCheckFailRate
    }

    public enum Status: Equatable, Sendable {
        case met
        case missed
        /// Not enough samples yet to judge.
        case tooFewSamples
    }

    public let goal: Goal
    public let value: Double?
    public let limit: Double
    public let samples: Int
    public let status: Status

    public init(goal: Goal, value: Double?, limit: Double, samples: Int, minimumSamples: Int) {
        self.goal = goal
        self.value = value
        self.limit = limit
        self.samples = samples
        guard let value = value, samples >= minimumSamples else {
            status = .tooFewSamples
            return
        }
        let met: Bool
        switch goal {
        case .earlyEndRate:
            met = value < limit
        case .dailyMinutes, .tapsPerNewWord, .knownCheckFailRate:
            met = value <= limit
        }
        status = met ? .met : .missed
    }
}

/// A window of `LocalMetrics` in numbers. Nil: nothing measured yet.
public struct LocalMetricsReport: Equatable, Sendable {
    public let windowDays: Int
    /// Days with any answer or round.
    public let studyDays: Int
    /// Questions answered on a study day (median), and split into reviews and new words.
    public let medianDailyAnswers: Double?
    public let medianDailyReviews: Double?
    public let medianDailyNewWords: Double?
    /// Right at the first try, over `firstTryAnswers` questions.
    public let firstTryCorrectRate: Double?
    public let firstTryAnswers: Int
    /// Seconds per answer (mean; replaces the 8–10 s guess behind the §2.9 minutes).
    public let meanSecondsPerAnswer: Double?
    /// Minutes of rounds on a study day (median).
    public let medianDailyMinutes: Double?
    /// Minutes per round (median), over `rounds` rounds.
    public let medianRoundMinutes: Double?
    public let rounds: Int
    /// Share of rounds ended with "Bitir".
    public let earlyEndRate: Double?
    public let medianTapsPerNewWord: Double?
    /// 3-day checks of "Biliyorum" words, and the share that failed.
    public let knownChecks: Int
    public let knownCheckFailRate: Double?
    /// Reminders that fired in the window; opened by a tap; ignored (the app was not opened the
    /// rest of that day; today's reminder is never counted as ignored yet).
    public let remindersFired: Int
    public let remindersOpened: Int
    public let remindersIgnored: Int
    /// The last box snapshot in the window.
    public let boxes: BoxCounts?
    public let acceptance: [AcceptanceCheck]

    public var reminderOpenRate: Double? {
        return remindersFired == 0 ? nil : Double(remindersOpened) / Double(remindersFired)
    }
}
