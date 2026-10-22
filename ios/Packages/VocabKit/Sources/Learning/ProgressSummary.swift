import Foundation
import CoreModels

/// What the "İlerleme" screen shows (docs/tasarim/alternatifler/sakin_ilerleme.md;
/// docs/tasarim/ogrenme_ilkeleri.md 1.11 and 2.5). Pure and deterministic.
///
/// Progress is counted in words, never in a run of days: nothing here drops to zero because a
/// day was skipped, and no sentence ever says "0 gün". Only a word that was really forgotten
/// moves down a shelf.
///
/// The shelves are the Leitner boxes: box 1 ... 5 are "Raf 1" ... "Raf 5"; a known word that a
/// review proved is "Yerleşti"; a "Biliyorum" word that no review checked yet stays apart, in
/// "Kendin işaretlediklerin".
///
/// `progress.json` keeps no history. "This week" is read from each word's last answer
/// (`lastAnswer(of:)`) and first answer (`WordProgress.firstReviewedAt`). Words answered before
/// those dates were recorded fall back to estimates (the gap reading in `lastAnswer(of:)`,
/// `estimatedFirstAnswer(of:)`). Exact dates from elsewhere (a review log, recorded study days)
/// go in through `StudyHistory` and always win.
public struct ProgressSummary: Equatable, Sendable {
    /// A shelf of the library, bottom to top, then the separate box of self-marked words.
    public enum Shelf: Int, CaseIterable, Comparable, Identifiable, Sendable {
        case box1 = 1
        case box2
        case box3
        case box4
        case box5
        /// Graduated from the last box, or a "Biliyorum" that a review proved.
        case settled
        /// "Biliyorum" that no review has checked yet: shown apart, never counted as settled.
        case selfMarked

        public var id: Int {
            return rawValue
        }

        /// The Leitner box (1 ... `Leitner.maxBox`); nil for `settled` and `selfMarked`.
        public var box: Int? {
            return rawValue <= Leitner.maxBox ? rawValue : nil
        }

        /// The shelf of a word; nil for a word that was never answered (or was sent back to
        /// the new words).
        public static func of(_ progress: WordProgress) -> Shelf? {
            switch progress.state {
            case .new:
                return nil
            case .learning:
                return Shelf(rawValue: min(max(progress.box, 1), Leitner.maxBox))
            case .known:
                return progress.knownOverride ? .selfMarked : .settled
            }
        }

        public static func < (lhs: Shelf, rhs: Shelf) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    /// The words on one shelf, by id in ascending order (the screen sorts them by headword).
    public struct ShelfContent: Equatable, Identifiable, Sendable {
        public let shelf: Shelf
        public let wordIDs: [Int]

        public var id: Shelf {
            return shelf
        }

        public var count: Int {
            return wordIDs.count
        }
    }

    /// One week, Monday 00:00 to the next Monday 00:00, local time.
    public struct Week: Equatable, Sendable {
        public let start: Date
        public let end: Date
        /// Days with at least one answer that left a trace (a word's last answer, or a date in
        /// `StudyHistory`). It can miss a day whose answers were all answered again later; it
        /// never counts a day without an answer.
        public let studyDays: Int
        /// Words answered for the first time in this week, earliest first.
        public let metWordIDs: [Int]
        /// Words whose last answer in this week was right and moved them up at least one shelf.
        /// A new word's first answer is not a move: it is in `metWordIDs`.
        public let movedUpWordIDs: [Int]
        /// Words on the top shelf remembered after a wait of two weeks or more: the step up to
        /// "Yerleşti", or a refresher.
        public let recalledAfterLongGapWordIDs: [Int]

        /// Nothing in this week left a trace.
        public var isQuiet: Bool {
            return studyDays == 0 && metWordIDs.isEmpty && movedUpWordIDs.isEmpty
                && recalledAfterLongGapWordIDs.isEmpty
        }
    }

    /// One topic's words and how far the user got with them. No ranking and no percentage: the
    /// screen draws the three parts and says the numbers.
    public struct GroupProgress: Equatable, Identifiable, Sendable {
        public let id: String
        public let title: String
        /// The group's words (each once).
        public let total: Int
        /// Known words: settled or self-marked.
        public let known: Int
        /// Words on shelves 1–5.
        public let learning: Int

        /// Words not met yet.
        public var notStarted: Int {
            return max(0, total - known - learning)
        }

        /// Every word of the group was met; reviews go on, new words come from other topics.
        public var everyWordMet: Bool {
            return total > 0 && notStarted == 0
        }
    }

    /// A topic (or any other group of words) for `GroupProgress`.
    public struct WordGroup: Equatable, Sendable {
        public let id: String
        public let title: String
        public let wordIDs: [Int]

        public init(id: String, title: String, wordIDs: [Int]) {
            self.id = id
            self.title = title
            self.wordIDs = wordIDs
        }
    }

    /// Dates the app knows exactly from elsewhere. Empty by default: everything is then read
    /// from `progress.json`. Any entry here wins over `progress.json`.
    public struct StudyHistory: Equatable, Sendable {
        /// When each word was answered for the first time (a review log, say).
        public var firstAnswers: [Int: Date]
        /// One moment of each day with at least one answer (any time of the day will do).
        public var studyDays: [Date]

        public init(firstAnswers: [Int: Date] = [:], studyDays: [Date] = []) {
            self.firstAnswers = firstAnswers
            self.studyDays = studyDays
        }

        public static let none = StudyHistory()
    }

    /// The calm sentence at the top of the screen.
    public struct WeeklyNote: Equatable, Sendable {
        public enum Kind: Equatable, Sendable {
            /// On Monday, once: last week.
            case lastWeek
            /// This week so far.
            case thisWeek
            /// Nothing yet this week: the library is still there.
            case quiet
            /// No word was ever answered.
            case emptyLibrary
        }

        public let kind: Kind
        /// Monday of the week the note speaks about. For `lastWeek`, save it once the note has
        /// been on screen and pass it back as `recapShownForWeek`: the recap shows only once.
        public let weekStart: Date
        public let text: String
    }

    /// What a word's last answer was (`lastAnswer(of:)`).
    public struct LastAnswer: Equatable, Sendable {
        public enum Kind: Equatable, Sendable {
            /// "Bilemedim": down to a lower shelf, asked again soon.
            case forgot
            /// "Zor": same shelf, half the wait.
            case stayed
            /// "Bildim" or "Kolay": one or two shelves up.
            case movedUp
            /// A right answer on the top shelf: the step up to "Yerleşti", or a refresher.
            case recalledOnTop
        }

        public let date: Date
        public let kind: Kind
    }

    /// When the summary was made.
    public let now: Date
    /// Every shelf in `Shelf.allCases` order, empty ones too.
    public let shelves: [ShelfContent]
    /// Words that were answered at least once or marked known: everything on the shelves.
    public let libraryCount: Int
    /// "Uzun süreli hafızaya geçen" words: shelves 4 and 5 and "Yerleşti", ascending ids.
    /// Self-marked words are left out (no review checked them). The screen calls them "üst
    /// raflardaki kelimeler", never "kalıcı": forgetting never stops completely
    /// (sakin_ilerleme.md, "Neden kalıcı demiyoruz?").
    public let longTermWordIDs: [Int]
    public let thisWeek: Week
    public let lastWeek: Week
    /// One row per group given to `make`, in the same order.
    public let topics: [GroupProgress]
    public let note: WeeklyNote

    /// The words on `shelf`.
    public func words(on shelf: Shelf) -> [Int] {
        return shelves.first { $0.shelf == shelf }?.wordIDs ?? []
    }

    // MARK: Making

    private static let day: TimeInterval = 86_400
    /// `Leitner.review` writes `lastSeenAt` and `dueAt` from the same moment; the gap between them
    /// is matched with this tolerance.
    private static let gapTolerance: TimeInterval = 1

    /// - Parameters:
    ///   - progress: every word's progress (`AppModel.progress`).
    ///   - now: the moment the screen is shown.
    ///   - calendar: local days and weeks. Weeks always start on Monday, whatever the region.
    ///   - wordIDs: the loaded words; progress of other ids (a card removed from the content) is
    ///     left out. Nil keeps every id.
    ///   - topics: the topics to show, in display order (`WordGroup.topics(_:topicsOf:words:)`).
    ///   - history: exact dates the app knows, if any.
    ///   - recapShownForWeek: the `weekStart` of the last Monday recap that was shown.
    public static func make(
        progress: [Int: WordProgress],
        now: Date,
        calendar: Calendar = .current,
        wordIDs: Set<Int>? = nil,
        topics: [WordGroup] = [],
        history: StudyHistory = .none,
        recapShownForWeek: Date? = nil
    ) -> ProgressSummary {
        let included = progress
            .filter { wordIDs?.contains($0.key) ?? true }
            .sorted { $0.key < $1.key }

        var byShelf: [Shelf: [Int]] = [:]
        var longTerm: [Int] = []
        for (id, p) in included {
            guard let shelf = Shelf.of(p) else {
                continue
            }
            byShelf[shelf, default: []].append(id)
            if shelf == .settled || (shelf.box ?? 0) >= 4 {
                longTerm.append(id)
            }
        }
        let shelves = Shelf.allCases.map { ShelfContent(shelf: $0, wordIDs: byShelf[$0] ?? []) }
        let libraryCount = shelves.reduce(0) { $0 + $1.count }

        let thisStart = weekStart(containing: now, calendar: calendar)
        let lastStart = calendar.date(byAdding: .day, value: -7, to: thisStart) ?? thisStart.addingTimeInterval(-7 * day)
        let nextStart = calendar.date(byAdding: .day, value: 7, to: thisStart) ?? thisStart.addingTimeInterval(7 * day)
        let thisWeek = week(from: thisStart, to: nextStart, records: included, history: history, calendar: calendar)
        let lastWeek = week(from: lastStart, to: thisStart, records: included, history: history, calendar: calendar)

        let rows = topics.map { group in
            groupProgress(group, progress: progress, wordIDs: wordIDs)
        }
        let note = weeklyNote(
            thisWeek: thisWeek,
            lastWeek: lastWeek,
            libraryCount: libraryCount,
            now: now,
            calendar: calendar,
            recapShownForWeek: recapShownForWeek
        )
        return ProgressSummary(
            now: now,
            shelves: shelves,
            libraryCount: libraryCount,
            longTermWordIDs: longTerm,
            thisWeek: thisWeek,
            lastWeek: lastWeek,
            topics: rows,
            note: note
        )
    }

    /// Monday 00:00 of the week `date` falls in, local time. Weeks start on Monday whatever the
    /// region's first weekday: the recap comes on Monday (ogrenme_ilkeleri 2.5).
    public static func weekStart(containing date: Date, calendar: Calendar) -> Date {
        let dayStart = calendar.startOfDay(for: date)
        // 1 = Sunday ... 7 = Saturday.
        let weekday = calendar.component(.weekday, from: dayStart)
        let sinceMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -sinceMonday, to: dayStart) ?? dayStart
    }

    // MARK: Reading progress.json

    /// The word's last answer. Nil for a word that was never answered, a word sent back to the
    /// new words, and a "Biliyorum" word waiting for its check.
    ///
    /// Exact from `lastReviewedAt` and `lastGrade`. A word answered before those fields existed
    /// is read from the gap between `lastSeenAt` and `dueAt` (both written from the same moment
    /// by `Leitner.review`); nil when the gap matches no answer: a widget tap moved `lastSeenAt`
    /// since, or marking a word known left a gap that looks like an answer.
    public static func lastAnswer(of progress: WordProgress) -> LastAnswer? {
        guard progress.reviews > 0 else {
            return nil
        }
        if let at = progress.lastReviewedAt, let grade = progress.lastGrade {
            switch progress.state {
            case .new:
                return nil
            case .learning:
                switch grade {
                case .again:
                    return LastAnswer(date: at, kind: .forgot)
                case .hard:
                    return LastAnswer(date: at, kind: .stayed)
                case .good, .easy:
                    return LastAnswer(date: at, kind: .movedUp)
                }
            case .known:
                // A wrong answer never leaves a word known.
                return progress.knownOverride || grade == .again ? nil : LastAnswer(date: at, kind: .recalledOnTop)
            }
        }
        guard let due = progress.dueAt, let seen = progress.lastReviewedAt ?? progress.lastSeenAt else {
            return nil
        }
        let gap = due.timeIntervalSince(seen)
        func matches(_ wait: TimeInterval) -> Bool {
            return abs(gap - wait) <= gapTolerance
        }
        switch progress.state {
        case .new:
            return nil
        case .learning:
            if matches(Leitner.relearnDelay) {
                return LastAnswer(date: seen, kind: .forgot)
            }
            guard let interval = interval(ofBox: progress.box) else {
                return nil
            }
            if matches(interval) {
                return LastAnswer(date: seen, kind: .movedUp)
            }
            if matches(interval * Leitner.hardFactor) {
                return LastAnswer(date: seen, kind: .stayed)
            }
            return nil
        case .known:
            if progress.knownOverride {
                return nil
            }
            let waits = Leitner.refresherDays.indices.map { Leitner.refresherWait(step: $0) }
            if waits.contains(where: { matches($0) || matches($0 * Leitner.hardFactor) }) {
                return LastAnswer(date: seen, kind: .recalledOnTop)
            }
            return nil
        }
    }

    /// When a word was most likely answered for the first time. Exact for a word answered once.
    /// Otherwise it assumes the word climbed one shelf per "Bildim", each on its due day
    /// (1 + 2 + 4 ... days): a word answered late or after a slip can look a little newer than
    /// it is, one answered "Kolay" a little older. Nil for words on no shelf, known words (the
    /// climb to "Yerleşti" takes weeks), "Biliyorum" words, and words with more answers than such
    /// a climb and its slips explain (an old word that slipped back down).
    public static func estimatedFirstAnswer(of progress: WordProgress) -> Date? {
        guard progress.state == .learning, progress.reviews > 0, let last = earliestLastAnswer(of: progress) else {
            return nil
        }
        if progress.reviews == 1 {
            return last
        }
        let box = min(max(progress.box, 1), Leitner.maxBox)
        // A straight climb needs `box` answers; each slip adds two (the wrong answer and the one
        // after it) and one "Zor" may add one more.
        guard progress.reviews <= box + 2 * progress.lapses + 1 else {
            return nil
        }
        let climbDays = Leitner.intervalDays.prefix(box - 1).reduce(0, +)
        return last.addingTimeInterval(-climbDays * day)
    }

    /// The last answer when it is known; otherwise the earliest it can have been, the longest
    /// wait the word's shelf allows before `dueAt`.
    private static func earliestLastAnswer(of progress: WordProgress) -> Date? {
        if let answer = lastAnswer(of: progress) {
            return answer.date
        }
        guard progress.state == .learning, let due = progress.dueAt, let interval = interval(ofBox: progress.box) else {
            return nil
        }
        return due.addingTimeInterval(-interval)
    }

    /// The wait after a right answer that leaves a word in `box`.
    private static func interval(ofBox box: Int) -> TimeInterval? {
        let index = min(max(box, 1), Leitner.maxBox) - 1
        guard Leitner.intervalDays.indices.contains(index) else {
            return nil
        }
        return Leitner.intervalDays[index] * day
    }

    // MARK: Parts

    private static func week(
        from start: Date,
        to end: Date,
        records: [(key: Int, value: WordProgress)],
        history: StudyHistory,
        calendar: Calendar
    ) -> Week {
        func inWeek(_ date: Date) -> Bool {
            return date >= start && date < end
        }
        var days = Set<Date>()
        for date in history.studyDays where inWeek(date) {
            days.insert(calendar.startOfDay(for: date))
        }
        var met: [(date: Date, id: Int)] = []
        var movedUp: [Int] = []
        var recalled: [Int] = []
        for (id, p) in records {
            // A recorded answer marks its day whatever happened to the word since (a failed
            // "Biliyorum" check takes it off the shelves).
            if let answered = p.lastReviewedAt, inWeek(answered) {
                days.insert(calendar.startOfDay(for: answered))
            }
            guard Shelf.of(p) != nil else {
                continue
            }
            if let exact = history.firstAnswers[id] ?? p.firstReviewedAt {
                if inWeek(exact) {
                    met.append((exact, id))
                    days.insert(calendar.startOfDay(for: exact))
                }
            } else if let estimate = estimatedFirstAnswer(of: p), inWeek(estimate) {
                met.append((estimate, id))
            }
            guard let answer = lastAnswer(of: p), inWeek(answer.date) else {
                continue
            }
            days.insert(calendar.startOfDay(for: answer.date))
            switch answer.kind {
            case .movedUp:
                // Box 1, or a single answer, is a new word's first answer, not a move.
                if p.box >= 2 && p.reviews >= 2 {
                    movedUp.append(id)
                }
            case .recalledOnTop:
                // Box 5: graduated or refreshed. A "Biliyorum" proved by its check keeps a lower box.
                if p.box >= Leitner.maxBox {
                    recalled.append(id)
                }
            case .forgot, .stayed:
                break
            }
        }
        met.sort { a, b in
            if a.date != b.date {
                return a.date < b.date
            }
            return a.id < b.id
        }
        return Week(
            start: start,
            end: end,
            studyDays: min(days.count, 7),
            metWordIDs: met.map { $0.id },
            movedUpWordIDs: movedUp,
            recalledAfterLongGapWordIDs: recalled
        )
    }

    private static func groupProgress(_ group: WordGroup, progress: [Int: WordProgress], wordIDs: Set<Int>?) -> GroupProgress {
        var seen = Set<Int>()
        var total = 0
        var known = 0
        var learning = 0
        for id in group.wordIDs where seen.insert(id).inserted && (wordIDs?.contains(id) ?? true) {
            total += 1
            switch progress[id]?.state {
            case .known?:
                known += 1
            case .learning?:
                learning += 1
            case .new?, nil:
                break
            }
        }
        return GroupProgress(id: group.id, title: group.title, total: total, known: known, learning: learning)
    }

    // MARK: The sentence

    private static func weeklyNote(
        thisWeek: Week,
        lastWeek: Week,
        libraryCount: Int,
        now: Date,
        calendar: Calendar,
        recapShownForWeek: Date?
    ) -> WeeklyNote {
        let isMonday = calendar.isDate(now, inSameDayAs: thisWeek.start)
        let recapShown = recapShownForWeek.map { calendar.isDate($0, inSameDayAs: lastWeek.start) } ?? false
        if isMonday && !recapShown && !lastWeek.isQuiet {
            return WeeklyNote(kind: .lastWeek, weekStart: lastWeek.start, text: sentence(lastWeek, opening: "Geçen hafta"))
        }
        if !thisWeek.isQuiet {
            return WeeklyNote(kind: .thisWeek, weekStart: thisWeek.start, text: sentence(thisWeek, opening: "Bu hafta"))
        }
        if libraryCount == 0 {
            return WeeklyNote(
                kind: .emptyLibrary,
                weekStart: thisWeek.start,
                text: "Kitaplığın henüz boş. İlk tekrar turunda tanıştığın kelimeler en alt rafa gelir."
            )
        }
        return WeeklyNote(
            kind: .quiet,
            weekStart: thisWeek.start,
            text: "Kitaplığındaki \(libraryCount) kelime yerinde duruyor."
        )
    }

    /// "Bu hafta 4 gün çalıştın. 12 yeni kelimeyle tanıştın ve 19 kelime bir üst rafa çıktı."
    /// A part whose number would be 0 is left out, so no number in it is ever 0. No praise, no
    /// percentage, no exclamation mark (ogrenme_ilkeleri 1.12, 2.5).
    private static func sentence(_ week: Week, opening: String) -> String {
        var parts: [String] = []
        if !week.metWordIDs.isEmpty {
            parts.append("\(week.metWordIDs.count) yeni kelimeyle tanıştın")
        }
        if !week.movedUpWordIDs.isEmpty {
            parts.append("\(week.movedUpWordIDs.count) kelime bir üst rafa çıktı")
        }
        if !week.recalledAfterLongGapWordIDs.isEmpty {
            parts.append("\(week.recalledAfterLongGapWordIDs.count) kelimeyi uzun bir aradan sonra da hatırladın")
        }
        let joined = joinedList(parts)
        guard week.studyDays > 0 else {
            return "\(opening) \(joined)."
        }
        let days = "\(opening) \(week.studyDays) gün çalıştın."
        return joined.isEmpty ? days : "\(days) \(joined)."
    }

    /// "a", "a ve b", "a, b ve c".
    private static func joinedList(_ parts: [String]) -> String {
        guard let last = parts.last else {
            return ""
        }
        if parts.count == 1 {
            return last
        }
        return parts.dropLast().joined(separator: ", ") + " ve " + last
    }
}

extension ProgressSummary.WordGroup {
    /// One group per topic, in the order given, holding the topic's words among `words` (a word
    /// can be in several topics). `topicsOf` is the content's card → topic map
    /// (`ContentStore.topicsByCard()`, `AppModel.topicsOf`).
    public static func topics(
        _ topics: [ContentTopic],
        topicsOf: [Int: Set<String>],
        words: [WidgetWord]
    ) -> [ProgressSummary.WordGroup] {
        var members: [String: [Int]] = [:]
        for word in words {
            for topic in topicsOf[word.id] ?? [] {
                members[topic, default: []].append(word.id)
            }
        }
        return topics.map { topic in
            ProgressSummary.WordGroup(id: topic.id, title: topic.nameTR, wordIDs: members[topic.id] ?? [])
        }
    }
}
