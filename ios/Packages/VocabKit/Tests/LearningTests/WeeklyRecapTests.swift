import XCTest
import CoreModels
import Learning

/// Weeks of October 2026, Istanbul time, as in ProgressSummaryTests: "now" is mostly Monday
/// 26 October, so the recap's week is Monday 19 to Monday 26. Progress is built with the real
/// `Leitner.review`; the summary is the real `ProgressSummary.make`.
final class WeeklyRecapTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 3 * 3600)!
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int = 10, minute: Int = 0, month: Int = 10) -> Date {
        return calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
    }

    /// A word answered with `answers`, in order.
    private func word(_ id: Int, _ answers: [(ReviewGrade, Date)]) -> WordProgress {
        return answers.reduce(WordProgress(wordID: id)) { p, answer in
            Leitner.review(p, grade: answer.0, at: answer.1)
        }
    }

    /// "Bildim" `count` times, each on its due day, the first at `first`.
    private func climb(_ id: Int, from first: Date, answers count: Int) -> WordProgress {
        var p = WordProgress(wordID: id)
        var at = first
        for _ in 0..<count {
            p = Leitner.review(p, grade: .good, at: at)
            at = p.dueAt!
        }
        return p
    }

    private func summary(_ progress: [Int: WordProgress], now: Date, wordIDs: Set<Int>? = nil) -> ProgressSummary {
        return ProgressSummary.make(progress: progress, now: now, calendar: calendar, wordIDs: wordIDs)
    }

    private func entry(_ id: Int, _ grade: ReviewGrade, _ at: Date, source: ReviewLogEntry.Source = .review) -> ReviewLogEntry {
        return ReviewLogEntry(wordID: id, at: at, grade: grade, source: source, reviews: 1)
    }

    private func widgetWord(_ id: Int, sensitivity: Int? = nil) -> WidgetWord {
        return WidgetWord(
            id: id,
            lemma: "word\(id)",
            pos: "noun",
            level: "A2",
            defMicro: "a word",
            defShort: "a word",
            exampleEN: "This is a word.",
            glossTR: "kelime",
            sensitivity: sensitivity
        )
    }

    /// A week with one word met (1) and one word moved up from step 2 to step 3 (2).
    private var ordinaryWeek: [Int: WordProgress] {
        return [
            1: word(1, [(.good, date(20))]),
            2: word(2, [(.good, date(12)), (.good, date(13)), (.good, date(21))]),
        ]
    }

    // MARK: When

    func testDueOnMondayUntilShown() {
        let monday = summary(ordinaryWeek, now: date(26, 9))
        XCTAssertTrue(WeeklyRecap.isDue(summary: monday, calendar: calendar, shownForWeek: nil))
        // Shown for last week: not again.
        XCTAssertFalse(WeeklyRecap.isDue(summary: monday, calendar: calendar, shownForWeek: date(19, 0)))
        // An older week's recap does not count.
        XCTAssertTrue(WeeklyRecap.isDue(summary: monday, calendar: calendar, shownForWeek: date(12, 0)))
        // The whole of Monday, local time.
        XCTAssertTrue(WeeklyRecap.isDue(summary: summary(ordinaryWeek, now: date(26, 0, minute: 5)), calendar: calendar, shownForWeek: nil))
        XCTAssertTrue(WeeklyRecap.isDue(summary: summary(ordinaryWeek, now: date(26, 23, minute: 55)), calendar: calendar, shownForWeek: nil))
    }

    func testNotDueOnOtherDays() {
        for day in [20, 21, 25, 27, 28] {
            let s = summary(ordinaryWeek, now: date(day, 9))
            XCTAssertFalse(WeeklyRecap.isDue(summary: s, calendar: calendar, shownForWeek: nil), "day \(day)")
        }
    }

    func testNotDueAfterAQuietWeek() {
        // Answered two weeks ago only: nothing happened last week, so nothing is said about it.
        let old = [7: word(7, [(.good, date(12))])]
        let s = summary(old, now: date(26, 9))
        XCTAssertTrue(s.lastWeek.isQuiet)
        XCTAssertFalse(WeeklyRecap.isDue(summary: s, calendar: calendar, shownForWeek: nil))
        XCTAssertNil(WeeklyRecap.make(summary: s, progress: old, log: [], dueCount: 0))
        // An empty library.
        XCTAssertFalse(WeeklyRecap.isDue(summary: summary([:], now: date(26, 9)), calendar: calendar, shownForWeek: nil))
    }

    func testMondayAlsoInARegionWhoseWeekStartsOnSunday() {
        var sundayFirst = calendar
        sundayFirst.firstWeekday = 1
        let s = ProgressSummary.make(progress: ordinaryWeek, now: date(26, 9), calendar: sundayFirst)
        XCTAssertTrue(WeeklyRecap.isDue(summary: s, calendar: sundayFirst, shownForWeek: nil))
        let sunday = ProgressSummary.make(progress: ordinaryWeek, now: date(25, 9), calendar: sundayFirst)
        XCTAssertFalse(WeeklyRecap.isDue(summary: sunday, calendar: sundayFirst, shownForWeek: nil))
    }

    // MARK: Words from the summary

    func testMetAndMovedUpWordsAreTheSummarysLastWeek() throws {
        let s = summary(ordinaryWeek, now: date(26, 9))
        let recap = try XCTUnwrap(WeeklyRecap.make(summary: s, progress: ordinaryWeek, log: [], dueCount: 0))
        XCTAssertEqual(recap.weekStart, date(19, 0))
        XCTAssertEqual(recap.weekEnd, date(26, 0))
        XCTAssertEqual(recap.metWordIDs, s.lastWeek.metWordIDs)
        XCTAssertEqual(recap.metWordIDs, [1])
        XCTAssertEqual(recap.movedUpWordIDs, [2])
        XCTAssertEqual(recap.studyDays, 2)
        XCTAssertEqual(recap.sentence, "Geçen hafta 2 gün çalıştın.")
        XCTAssertEqual(recap.hardWordIDs, [])
        // Two study days, nothing hard, nothing due: spread the rounds over the week.
        XCTAssertEqual(recap.suggestion, .spreadOut)
    }

    func testTheStepToYerlestiCountsAsMovedUp() throws {
        // Six "Bildim": the sixth, on 21 October, takes the word from step 5 to "Yerleşti".
        let settled = climb(3, from: date(20, month: 9), answers: 6)
        XCTAssertEqual(settled.state, .known)
        let progress = ordinaryWeek.merging([3: settled]) { a, _ in a }
        let s = summary(progress, now: date(26, 9))
        XCTAssertEqual(s.lastWeek.recalledAfterLongGapWordIDs, [3])
        let recap = try XCTUnwrap(WeeklyRecap.make(summary: s, progress: progress, log: [], dueCount: 0))
        XCTAssertEqual(recap.movedUpWordIDs, [2, 3])
        XCTAssertFalse(recap.metWordIDs.contains(3))
    }

    func testWordsThatAreNotLoadedAreLeftOut() throws {
        let s = summary(ordinaryWeek, now: date(26, 9))
        let recap = try XCTUnwrap(WeeklyRecap.make(summary: s, progress: ordinaryWeek, log: [], dueCount: 0, wordIDs: [2]))
        XCTAssertEqual(recap.metWordIDs, [])
        XCTAssertEqual(recap.movedUpWordIDs, [2])
        XCTAssertNil(WeeklyRecap.make(summary: s, progress: ordinaryWeek, log: [], dueCount: 0, wordIDs: [99]))
    }

    func testAWeekWithAStudyDayButNoWordGivesNoRecap() throws {
        // A failed "Biliyorum" check on 20 October: a study day, but the word left the shelves.
        let failed = Leitner.review(Leitner.markKnown(WordProgress(wordID: 5), at: date(10)), grade: .again, at: date(20))
        XCTAssertEqual(failed.state, .new)
        let progress = [5: failed]
        let s = summary(progress, now: date(26, 9))
        XCTAssertEqual(s.lastWeek.studyDays, 1)
        XCTAssertTrue(WeeklyRecap.isDue(summary: s, calendar: calendar, shownForWeek: nil))
        XCTAssertNil(WeeklyRecap.make(summary: s, progress: progress, log: [], dueCount: 0))

        // With the log the miss is known: the word is one of the week's hard words.
        let recap = try XCTUnwrap(WeeklyRecap.make(summary: s, progress: progress, log: [entry(5, .again, date(20))], dueCount: 0))
        XCTAssertEqual(recap.hardWordIDs, [5])
        XCTAssertEqual(recap.metWordIDs, [])
        XCTAssertEqual(recap.movedUpWordIDs, [])
        XCTAssertEqual(recap.suggestion, .readAloud(wordCount: 1))
    }

    // MARK: Hard words

    func testHardWordsCountBilemedimTwiceAndZorOnce() {
        let log = [
            entry(10, .again, date(20)), entry(10, .again, date(21)),
            entry(11, .hard, date(19)), entry(11, .hard, date(20)), entry(11, .hard, date(21)), entry(11, .hard, date(22)),
            entry(12, .again, date(22)), entry(12, .hard, date(23)),
            entry(13, .hard, date(24)),
            entry(14, .good, date(24)), entry(14, .easy, date(25)),
        ]
        let progress = Dictionary(uniqueKeysWithValues: (10...14).map { ($0, WordProgress(wordID: $0)) })
        XCTAssertEqual(WeeklyRecap.hardWords(log: log, progress: progress, from: date(19, 0), to: date(26, 0)), [10, 11, 12])
        XCTAssertEqual(WeeklyRecap.hardWords(log: log, progress: progress, from: date(19, 0), to: date(26, 0), limit: 9), [10, 11, 12, 13])
    }

    func testHardWordTiesGoToMoreMissesThenLaterTroubleThenLowerID() {
        let log = [
            entry(30, .again, date(20)),
            entry(31, .again, date(22)),
            entry(32, .hard, date(21)), entry(32, .hard, date(21, 11)),
            entry(29, .again, date(22)),
        ]
        let progress = Dictionary(uniqueKeysWithValues: (29...32).map { ($0, WordProgress(wordID: $0)) })
        XCTAssertEqual(WeeklyRecap.hardWords(log: log, progress: progress, from: date(19, 0), to: date(26, 0), limit: 4), [29, 31, 30, 32])
    }

    func testHardWordsAreOnlyTekrarAnswersOfTheWeek() {
        let log = [
            // A widget "Bilmiyorum" is often a word not studied yet.
            entry(40, .again, date(20), source: .widget),
            entry(41, .again, date(20)),
            // Before the week and on the next Monday 00:00 (the end is not in the week).
            entry(42, .again, date(18, 23, minute: 59)),
            entry(42, .again, date(26, 0)),
            // No progress now: the progress was reset since.
            entry(43, .again, date(21)),
            // Not loaded (a removed card or a deleted own word).
            entry(44, .again, date(21)),
        ]
        let progress = Dictionary(uniqueKeysWithValues: [40, 41, 42, 44].map { ($0, WordProgress(wordID: $0)) })
        XCTAssertEqual(
            WeeklyRecap.hardWords(log: log, progress: progress, from: date(19, 0), to: date(26, 0), wordIDs: [40, 41, 42, 43]),
            [41]
        )
    }

    func testHardWordsFallBackToTheLastAnswerWithoutALog() {
        let progress = [
            // Step 2, then "Bilemedim" on 21 October: one slip.
            20: word(20, [(.good, date(12)), (.good, date(13)), (.again, date(21))]),
            // "Zor" on 20 October.
            21: word(21, [(.good, date(19)), (.hard, date(20))]),
            22: word(22, [(.good, date(20))]),
            // Missed before the week.
            23: word(23, [(.good, date(10)), (.again, date(14))]),
        ]
        let start = date(19, 0)
        let end = date(26, 0)
        XCTAssertEqual(WeeklyRecap.hardWords(log: [], progress: progress, from: start, to: end), [20, 21])
        // Widget answers alone are not "Tekrar" answers: still the fallback.
        XCTAssertEqual(WeeklyRecap.hardWords(log: [entry(22, .again, date(21), source: .widget)], progress: progress, from: start, to: end), [20, 21])
        // A log with "Tekrar" answers in the week is trusted over progress.json.
        XCTAssertEqual(WeeklyRecap.hardWords(log: [entry(22, .good, date(20))], progress: progress, from: start, to: end), [])
    }

    // MARK: Suggestion and text

    func testSuggestionOrder() {
        XCTAssertEqual(WeeklyRecap.suggestion(hardWordCount: 2, studyDays: 1, dueCount: 21), .reviewsFirst)
        XCTAssertEqual(WeeklyRecap.suggestion(hardWordCount: 2, studyDays: 1, dueCount: 20), .readAloud(wordCount: 2))
        XCTAssertEqual(WeeklyRecap.suggestion(hardWordCount: 0, studyDays: 1, dueCount: 0), .spreadOut)
        XCTAssertEqual(WeeklyRecap.suggestion(hardWordCount: 0, studyDays: 2, dueCount: 5), .spreadOut)
        XCTAssertEqual(WeeklyRecap.suggestion(hardWordCount: 0, studyDays: 3, dueCount: 0), .sameRhythm)
        // Days not counted (estimated words only): no advice about days.
        XCTAssertEqual(WeeklyRecap.suggestion(hardWordCount: 0, studyDays: 0, dueCount: 0), .sameRhythm)
    }

    /// Calm text (ogrenme_ilkeleri 2.5, terimler.md): no exclamation mark, no zero, no number in
    /// a suggestion, at most two sentences of about 12 words, none of the pressure words.
    func testTextsAreCalm() {
        let suggestions: [WeeklyRecap.Suggestion] = [.reviewsFirst, .readAloud(wordCount: 1), .readAloud(wordCount: 3), .spreadOut, .sameRhythm]
        let banned = ["kaçır", "seri", "birikti", "özledik", "harika", "güzel iş", "tebrik", "yüzde", "%"]
        for suggestion in suggestions {
            let text = suggestion.text
            XCTAssertFalse(text.contains("!"), text)
            XCTAssertFalse(text.contains(where: \.isNumber), text)
            let sentences = text.split(separator: ".").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            XCTAssertLessThanOrEqual(sentences.count, 2, text)
            for sentence in sentences {
                XCTAssertLessThanOrEqual(sentence.split(separator: " ").count, 12, sentence)
            }
            let lowered = text.lowercased(with: Locale(identifier: "tr_TR"))
            for word in banned {
                XCTAssertFalse(lowered.contains(word), "\(word) in: \(text)")
            }
        }
        XCTAssertTrue(WeeklyRecap.Suggestion.readAloud(wordCount: 1).text.hasPrefix("Bu kelimenin örnek cümlesini"))
        XCTAssertTrue(WeeklyRecap.Suggestion.readAloud(wordCount: 2).text.hasPrefix("Bu kelimelerin örnek cümlelerini"))

        func recap(days: Int) -> WeeklyRecap {
            return WeeklyRecap(weekStart: date(19, 0), weekEnd: date(26, 0), studyDays: days, metWordIDs: [1], movedUpWordIDs: [], hardWordIDs: [], suggestion: .sameRhythm)
        }
        XCTAssertEqual(recap(days: 0).sentence, "Geçen haftaya kısa bir bakış.")
        XCTAssertEqual(recap(days: 1).sentence, "Geçen hafta 1 gün çalıştın.")
        XCTAssertEqual(recap(days: 7).sentence, "Geçen hafta 7 gün çalıştın.")
        for days in 0...7 {
            let sentence = recap(days: days).sentence
            XCTAssertFalse(sentence.contains("0"), sentence)
            XCTAssertFalse(sentence.contains("!"), sentence)
        }
    }

    // MARK: Sharing

    func testShareCardSkipsPersonalTopicsAndOwnWords() {
        let own = CustomWordID.first + 3
        let words = [
            1: widgetWord(1),
            2: widgetWord(2, sensitivity: 1),
            own: widgetWord(own),
            4: widgetWord(4),
        ]
        let recap = WeeklyRecap(
            weekStart: date(19, 0),
            weekEnd: date(26, 0),
            studyDays: 3,
            metWordIDs: [1, 2, own, 99],
            movedUpWordIDs: [4, 1],
            hardWordIDs: [2],
            suggestion: .sameRhythm
        )
        XCTAssertEqual(recap.shareWords(from: words).map(\.id), [1, 4])
    }

    func testShareCardHoldsAtMostSixWordsMetFirst() {
        let words = Dictionary(uniqueKeysWithValues: (1...10).map { ($0, widgetWord($0)) })
        let recap = WeeklyRecap(
            weekStart: date(19, 0),
            weekEnd: date(26, 0),
            studyDays: 5,
            metWordIDs: [3, 1, 2, 5, 4],
            movedUpWordIDs: [9, 8, 7],
            hardWordIDs: [],
            suggestion: .sameRhythm
        )
        XCTAssertEqual(recap.shareWords(from: words).map(\.id), [3, 1, 2, 5, 4, 9])
        XCTAssertEqual(recap.shareWords(from: words, limit: 2).map(\.id), [3, 1])
    }
}
