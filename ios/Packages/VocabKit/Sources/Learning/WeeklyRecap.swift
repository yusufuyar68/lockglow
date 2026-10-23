import Foundation
import CoreModels

/// Monday's "Geçen hafta" screen (docs/tasarim/ogrenme_ilkeleri.md 2.5;
/// docs/ozellik_planlari/ilerleme_ekrani.md, open question 2): once, at an opening on Monday, a
/// calm look back at last week. The words met, the words that moved up a step, the (at most
/// three) words that were hardest and one suggestion for this week. Pure and deterministic.
///
/// It reads `ProgressSummary` and never changes it: the week's bounds, its study days and the
/// words met and moved up are `summary.lastWeek`. Only the hardest words come from elsewhere,
/// the review log (`ReviewLog`), since `progress.json` keeps each word's last answer only.
///
/// No streak, no comparison with an earlier week, no percentage, no praise, no zero: a part with
/// nothing in it is left out, and a week with nothing to show gives no recap at all.
public struct WeeklyRecap: Equatable, Sendable {
    /// The one suggestion for the week that starts now. Two short sentences at most, "sen", no
    /// exclamation mark and no number (docs/tasarim/terimler.md).
    public enum Suggestion: Equatable, Sendable {
        /// Many reviews are due: those first, new words can wait. The number is never shown
        /// (terimler.md: "Büyük birikmiş sayı gösterilmez").
        case reviewsFirst
        /// The hardest words: read their example aloud once (production effect).
        case readAloud(wordCount: Int)
        /// Last week had one or two study days: short rounds spread over the week hold better
        /// (spaced practice). The day count is not repeated here.
        case spreadOut
        /// Anything else: the same rhythm; due words come by themselves.
        case sameRhythm

        public var text: String {
            switch self {
            case .reviewsFirst:
                return "Bu hafta önce zamanı gelen kelimeleri tekrar et. Yeni kelimeler bekleyebilir."
            case .readAloud(let count):
                let words = count == 1 ? "Bu kelimenin örnek cümlesini" : "Bu kelimelerin örnek cümlelerini"
                return "\(words) bir kez sesli oku. Sesli okumak, kelimeyi akılda tutmaya yardım eder."
            case .spreadOut:
                return "Kısa turları haftanın birkaç gününe yay. Böyle öğrenilen kelime akılda daha iyi kalır."
            case .sameRhythm:
                return "Aynı düzenle devam edebilirsin. Zamanı gelen kelimeler Tekrar'a kendiliğinden gelir."
            }
        }
    }

    /// Monday 00:00 of the week the recap speaks about (`summary.lastWeek.start`). Save it once
    /// the recap has been on screen and pass it back to `isDue` as `shownForWeek`.
    public let weekStart: Date
    /// The next Monday 00:00 (exclusive).
    public let weekEnd: Date
    /// Days with an answer that left a trace (`ProgressSummary.Week.studyDays`); may be 0 when
    /// the week's words are only estimated, and then no day count is said.
    public let studyDays: Int
    /// Words answered for the first time that week, earliest first (`metWordIDs`).
    public let metWordIDs: [Int]
    /// Words that moved up at least one step that week: `movedUpWordIDs`, then the step up to
    /// "Yerleşti" or a refresher remembered after a long wait (`recalledAfterLongGapWordIDs`).
    /// Each once, met words left out (their first answer is not a move).
    public let movedUpWordIDs: [Int]
    /// The hardest words of the week, at most `hardWordLimit`, the hardest first
    /// (`hardWords(log:progress:from:to:wordIDs:)`).
    public let hardWordIDs: [Int]
    public let suggestion: Suggestion

    /// A recap as it is; the app makes one with `make` (this is for previews and tests).
    public init(
        weekStart: Date,
        weekEnd: Date,
        studyDays: Int,
        metWordIDs: [Int],
        movedUpWordIDs: [Int],
        hardWordIDs: [Int],
        suggestion: Suggestion
    ) {
        self.weekStart = weekStart
        self.weekEnd = weekEnd
        self.studyDays = studyDays
        self.metWordIDs = metWordIDs
        self.movedUpWordIDs = movedUpWordIDs
        self.hardWordIDs = hardWordIDs
        self.suggestion = suggestion
    }

    /// More than this many due reviews: the suggestion is `.reviewsFirst`. Two full rounds
    /// (`AppModel.reviewSessionLimit` is 10), the same pile "Tekrar" calls a break.
    public static let reviewsFirstAbove = 20
    /// The screen lists at most this many hard words.
    public static let hardWordLimit = 3
    /// The share card shows at most this many words.
    public static let shareWordLimit = 6

    /// The first line: "Geçen hafta 4 gün çalıştın." Never "0 gün": without a counted day it is
    /// a plain title.
    public var sentence: String {
        guard studyDays > 0 else {
            return "Geçen haftaya kısa bir bakış."
        }
        return "Geçen hafta \(min(studyDays, 7)) gün çalıştın."
    }

    // MARK: When

    /// True on Monday (local time) when last week left a trace and its recap was not shown yet.
    /// Weeks start on Monday whatever the region (`ProgressSummary.weekStart`). Tuesday and later
    /// the recap does not come: "İlerleme" has the week (ogrenme_ilkeleri 2.5: Monday, once).
    /// `make` may still find nothing to show; then nothing is shown.
    public static func isDue(summary: ProgressSummary, calendar: Calendar = .current, shownForWeek: Date?) -> Bool {
        guard calendar.isDate(summary.now, inSameDayAs: summary.thisWeek.start), !summary.lastWeek.isQuiet else {
            return false
        }
        if let shown = shownForWeek, calendar.isDate(shown, inSameDayAs: summary.lastWeek.start) {
            return false
        }
        return true
    }

    // MARK: Making

    /// The recap of `summary.lastWeek`; nil when it has no word to show (no word met, moved up
    /// or hard), whatever the study days.
    ///
    /// - Parameters:
    ///   - summary: `ProgressSummary.make(...)` for now (on Monday its `lastWeek` is the week).
    ///   - progress: every word's progress, for the hard words when the log has none.
    ///   - log: the review log's entries (`ReviewLog.entries()`); entries outside the week are
    ///     ignored. Empty or nil when it could not be read.
    ///   - dueCount: reviews due now (`ReviewPlanner.dueWords`), for the suggestion only.
    ///   - wordIDs: the loaded words; other ids are left out. Nil keeps every id.
    public static func make(
        summary: ProgressSummary,
        progress: [Int: WordProgress],
        log: [ReviewLogEntry]?,
        dueCount: Int,
        wordIDs: Set<Int>? = nil
    ) -> WeeklyRecap? {
        let week = summary.lastWeek
        func loaded(_ id: Int) -> Bool {
            return wordIDs?.contains(id) ?? true
        }
        let met = week.metWordIDs.filter(loaded)
        var seen = Set(met)
        var movedUp: [Int] = []
        for id in week.movedUpWordIDs + week.recalledAfterLongGapWordIDs where loaded(id) && seen.insert(id).inserted {
            movedUp.append(id)
        }
        let hard = hardWords(log: log ?? [], progress: progress, from: week.start, to: week.end, wordIDs: wordIDs)
        guard !met.isEmpty || !movedUp.isEmpty || !hard.isEmpty else {
            return nil
        }
        return WeeklyRecap(
            weekStart: week.start,
            weekEnd: week.end,
            studyDays: week.studyDays,
            metWordIDs: met,
            movedUpWordIDs: movedUp,
            hardWordIDs: hard,
            suggestion: suggestion(hardWordCount: hard.count, studyDays: week.studyDays, dueCount: dueCount)
        )
    }

    /// The suggestion, first that fits: many due reviews, then the hard words, then one or two
    /// study days, then the same rhythm.
    public static func suggestion(hardWordCount: Int, studyDays: Int, dueCount: Int) -> Suggestion {
        if dueCount > reviewsFirstAbove {
            return .reviewsFirst
        }
        if hardWordCount > 0 {
            return .readAloud(wordCount: hardWordCount)
        }
        if (1...2).contains(studyDays) {
            return .spreadOut
        }
        return .sameRhythm
    }

    /// The words of `start ..< end` that were hardest in "Tekrar", the hardest first, at most
    /// `limit`. Each "Bilemedim" (also a missed "Hatırla" or a failed "Biliyorum" check) counts
    /// two, each "Zor" one; a tie goes to more "Bilemedim", then to the later trouble, then to
    /// the lower id. Only answers given in "Tekrar": a widget "Bilmiyorum" is often a word not
    /// studied yet. Words without progress now (reset) and words not loaded are left out.
    ///
    /// When the log has no "Tekrar" answer in the week (it could not be read, or the week came
    /// before it), each word's last answer stands in (`ProgressSummary.lastAnswer(of:)`): a
    /// "Bilemedim" or "Zor" in the week, more slips first.
    public static func hardWords(
        log: [ReviewLogEntry],
        progress: [Int: WordProgress],
        from start: Date,
        to end: Date,
        wordIDs: Set<Int>? = nil,
        limit: Int = hardWordLimit
    ) -> [Int] {
        func counts(_ id: Int) -> Bool {
            return progress[id] != nil && (wordIDs?.contains(id) ?? true)
        }
        struct Trouble {
            var score = 0
            var misses = 0
            var latest = Date.distantPast
        }
        let answers = log.filter { $0.source == .review && $0.at >= start && $0.at < end }
        var troubles: [Int: Trouble] = [:]
        if answers.isEmpty {
            for (id, p) in progress where counts(id) {
                guard let answer = ProgressSummary.lastAnswer(of: p), answer.date >= start, answer.date < end else {
                    continue
                }
                switch answer.kind {
                case .forgot:
                    troubles[id] = Trouble(score: 2 + p.lapses, misses: 1, latest: answer.date)
                case .stayed:
                    troubles[id] = Trouble(score: 1 + p.lapses, misses: 0, latest: answer.date)
                case .movedUp, .recalledOnTop:
                    break
                }
            }
        } else {
            for entry in answers where counts(entry.wordID) {
                let weight: Int
                switch entry.grade {
                case .again:
                    weight = 2
                case .hard:
                    weight = 1
                case .good, .easy:
                    continue
                }
                var trouble = troubles[entry.wordID, default: Trouble()]
                trouble.score += weight
                trouble.misses += entry.grade == .again ? 1 : 0
                trouble.latest = max(trouble.latest, entry.at)
                troubles[entry.wordID] = trouble
            }
        }
        let ranked = troubles.sorted { a, b in
            if a.value.score != b.value.score {
                return a.value.score > b.value.score
            }
            if a.value.misses != b.value.misses {
                return a.value.misses > b.value.misses
            }
            if a.value.latest != b.value.latest {
                return a.value.latest > b.value.latest
            }
            return a.key < b.key
        }
        return ranked.prefix(max(limit, 0)).map { $0.key }
    }

    // MARK: Sharing

    /// The words on the share card: met words first, then the ones that moved up, at most
    /// `limit`. Only content cards that may be shown anywhere: never a personal-topic card
    /// (`isSensitive`, kept off the widget too) and never a word the user added (`isUserAdded`:
    /// it can be personal). Nothing else about the user goes on the card.
    public func shareWords(from words: [Int: WidgetWord], limit: Int = WeeklyRecap.shareWordLimit) -> [WidgetWord] {
        var result: [WidgetWord] = []
        var seen = Set<Int>()
        for id in metWordIDs + movedUpWordIDs where result.count < limit && seen.insert(id).inserted {
            guard let word = words[id], !word.isSensitive, !word.isUserAdded else {
                continue
            }
            result.append(word)
        }
        return result
    }
}
