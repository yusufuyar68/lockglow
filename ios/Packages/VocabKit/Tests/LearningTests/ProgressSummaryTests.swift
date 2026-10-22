import XCTest
import CoreModels
import Learning

/// Weeks of October 2026, Istanbul time: Monday 19, Monday 26 (the week of "now" in most tests),
/// Monday 2 November. Progress is built with the real `Leitner.review`, so the gaps the summary
/// reads are the ones the app writes.
final class ProgressSummaryTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 3 * 3600)!
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int = 10, minute: Int = 0, month: Int = 10) -> Date {
        return calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
    }

    private func daysBefore(_ days: Int, _ date: Date) -> Date {
        return calendar.date(byAdding: .day, value: -days, to: date)!
    }

    /// A word answered with `answers`, in order.
    private func word(_ id: Int, _ answers: [(ReviewGrade, Date)]) -> WordProgress {
        return answers.reduce(WordProgress(wordID: id)) { p, answer in
            Leitner.review(p, grade: answer.0, at: answer.1)
        }
    }

    /// "Bildim" `count` times, each on its due day, the first at `first`. Six answers graduate
    /// the word: the sixth comes 31 days after the first.
    private func climb(_ id: Int, from first: Date, answers count: Int) -> WordProgress {
        var p = WordProgress(wordID: id)
        var at = first
        for _ in 0..<count {
            p = Leitner.review(p, grade: .good, at: at)
            at = p.dueAt!
        }
        return p
    }

    private func summary(
        _ progress: [Int: WordProgress],
        now: Date,
        wordIDs: Set<Int>? = nil,
        topics: [ProgressSummary.WordGroup] = [],
        history: ProgressSummary.StudyHistory = .none,
        recapShownForWeek: Date? = nil
    ) -> ProgressSummary {
        return ProgressSummary.make(
            progress: progress,
            now: now,
            calendar: calendar,
            wordIDs: wordIDs,
            topics: topics,
            history: history,
            recapShownForWeek: recapShownForWeek
        )
    }

    /// No number in the sentence is 0 ("0 gün" never appears; ogrenme_ilkeleri 2.5).
    private func assertNoZero(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        let tokens = text.split(whereSeparator: { $0 == " " || $0 == "." || $0 == "," })
        XCTAssertFalse(tokens.contains("0"), "a zero in: \(text)", file: file, line: line)
        XCTAssertFalse(text.contains("0 gün"), text, file: file, line: line)
        XCTAssertFalse(text.contains("!"), text, file: file, line: line)
    }

    // MARK: Weeks

    func testWeekStartsOnMonday() {
        let monday = date(26, 0)
        XCTAssertEqual(ProgressSummary.weekStart(containing: date(28, 12), calendar: calendar), monday)
        XCTAssertEqual(ProgressSummary.weekStart(containing: monday, calendar: calendar), monday)
        XCTAssertEqual(ProgressSummary.weekStart(containing: date(1, 23, month: 11), calendar: calendar), monday)
        XCTAssertEqual(ProgressSummary.weekStart(containing: date(2, 0, month: 11), calendar: calendar), date(2, 0, month: 11))

        // A region whose weeks start on Sunday still gets Monday weeks.
        var sundayFirst = calendar
        sundayFirst.firstWeekday = 1
        XCTAssertEqual(ProgressSummary.weekStart(containing: date(1, 23, month: 11), calendar: sundayFirst), monday)
    }

    // MARK: Shelves

    func testShelvesFollowTheBoxes() {
        var progress: [Int: WordProgress] = [:]
        for box in 1...5 {
            var p = WordProgress(wordID: box)
            p.state = .learning
            p.box = box
            p.reviews = box
            progress[box] = p
        }
        progress[6] = climb(6, from: date(1, month: 9), answers: 6)
        progress[7] = Leitner.markKnown(WordProgress(wordID: 7), at: date(20))
        progress[8] = Leitner.markExposure(WordProgress(wordID: 8), at: date(20))

        let s = summary(progress, now: date(28, 12))

        XCTAssertEqual(s.shelves.map { $0.shelf }, ProgressSummary.Shelf.allCases)
        XCTAssertEqual(s.words(on: .box1), [1])
        XCTAssertEqual(s.words(on: .box3), [3])
        XCTAssertEqual(s.words(on: .box5), [5])
        XCTAssertEqual(s.words(on: .settled), [6])
        XCTAssertEqual(s.words(on: .selfMarked), [7])
        // Only seen on the widget: not in the library.
        XCTAssertEqual(s.libraryCount, 7)
        // Shelves 4 and 5 and "Yerleşti"; the untested "Biliyorum" word is left out.
        XCTAssertEqual(s.longTermWordIDs, [4, 5, 6])
    }

    func testWordIDsLeaveOutRemovedCards() {
        let progress = [
            1: word(1, [(.good, date(26))]),
            2: word(2, [(.good, date(26))]),
        ]
        let s = summary(progress, now: date(28, 12), wordIDs: [1])
        XCTAssertEqual(s.libraryCount, 1)
        XCTAssertEqual(s.thisWeek.metWordIDs, [1])
    }

    // MARK: Reading the last answer

    /// The same word as an earlier build wrote it: no recorded answer times or grade.
    private func legacy(_ p: WordProgress) -> WordProgress {
        var old = p
        old.lastReviewedAt = nil
        old.lastGrade = nil
        old.firstReviewedAt = nil
        old.refresherStep = nil
        return old
    }

    func testLastAnswerReadsTheGap() {
        // Each word as recorded now (exact) and as an earlier build wrote it (read from the gap):
        // both give the same answer.
        let good = word(1, [(.good, date(27))])
        let hard = word(2, [(.good, date(26)), (.hard, date(27))])
        let forgot = word(3, [(.good, date(26)), (.again, date(27))])
        let graduated = climb(4, from: daysBefore(31, date(27)), answers: 6)
        XCTAssertEqual(graduated.state, .known)
        let readers: [(WordProgress) -> WordProgress] = [{ $0 }, { self.legacy($0) }]
        for read in readers {
            XCTAssertEqual(ProgressSummary.lastAnswer(of: read(good))?.kind, .movedUp)
            XCTAssertEqual(ProgressSummary.lastAnswer(of: read(good))?.date, date(27))
            XCTAssertEqual(ProgressSummary.lastAnswer(of: read(hard))?.kind, .stayed)
            XCTAssertEqual(ProgressSummary.lastAnswer(of: read(forgot))?.kind, .forgot)
            XCTAssertEqual(ProgressSummary.lastAnswer(of: read(forgot))?.date, date(27))
            XCTAssertEqual(ProgressSummary.lastAnswer(of: read(graduated))?.kind, .recalledOnTop)
            XCTAssertEqual(ProgressSummary.lastAnswer(of: read(graduated))?.date, date(27))
        }

        // A widget tap since then moves `lastSeenAt`. The recorded answer stays exact; an
        // earlier build's word can't be told any more.
        let tapped = Leitner.markExposure(good, at: date(27, 18))
        XCTAssertEqual(ProgressSummary.lastAnswer(of: tapped)?.kind, .movedUp)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: tapped)?.date, date(27))
        XCTAssertNil(ProgressSummary.lastAnswer(of: legacy(tapped)))
        // "Biliyorum" is not an answer.
        XCTAssertNil(ProgressSummary.lastAnswer(of: Leitner.markKnown(WordProgress(wordID: 5), at: date(27))))
        XCTAssertNil(ProgressSummary.lastAnswer(of: WordProgress(wordID: 6)))
    }

    // MARK: This week

    func testMetThisWeekUsesTheFirstAnswer() {
        let progress = [
            // Met on Monday, answered once.
            1: word(1, [(.good, date(26))]),
            // Met on Monday, answered again on Tuesday: still met on Monday.
            2: word(2, [(.good, date(26)), (.good, date(27))]),
            // Met last Thursday, answered on its due days up to Sunday.
            3: word(3, [(.good, date(22)), (.good, date(23)), (.good, date(25))]),
            // "Biliyorum" this week: marked, not met.
            4: Leitner.markKnown(WordProgress(wordID: 4), at: date(27)),
        ]
        let s = summary(progress, now: date(28, 12))
        XCTAssertEqual(s.thisWeek.metWordIDs, [1, 2])
        XCTAssertEqual(s.lastWeek.metWordIDs, [3])
    }

    func testOldWordThatSlippedIsNotNew() {
        // Climbed to the last box in September, forgotten on Tuesday and right again after it.
        var p = climb(1, from: date(1, month: 9), answers: 5)
        p = Leitner.review(p, grade: .again, at: date(27))
        p = Leitner.review(p, grade: .good, at: date(27, 10, minute: 10))

        // As recorded now (first answer on record) and as an earlier build wrote it (estimated:
        // box 4 after a slip from box 5 says nothing about when it started).
        XCTAssertNil(ProgressSummary.estimatedFirstAnswer(of: legacy(p)))
        for record in [p, legacy(p)] {
            let s = summary([1: record], now: date(28, 12))
            XCTAssertTrue(s.thisWeek.metWordIDs.isEmpty)
            XCTAssertTrue(s.lastWeek.metWordIDs.isEmpty)
            // Its last answer this week took it up a shelf again.
            XCTAssertEqual(s.thisWeek.movedUpWordIDs, [1])
        }
    }

    func testHistoryWinsOverTheEstimate() {
        let progress = [
            1: word(1, [(.good, date(26))]),
            2: word(2, [(.good, date(27))]),
        ]
        let history = ProgressSummary.StudyHistory(
            firstAnswers: [1: date(20)],
            studyDays: [date(28, 9), date(5)]
        )
        let s = summary(progress, now: date(28, 12), history: history)
        XCTAssertEqual(s.thisWeek.metWordIDs, [2])
        XCTAssertEqual(s.lastWeek.metWordIDs, [1])
        // Monday (1's answer), Tuesday (2's answer), Wednesday (history).
        XCTAssertEqual(s.thisWeek.studyDays, 3)
        // Tuesday 20th (1's first answer); the 5th is in another week.
        XCTAssertEqual(s.lastWeek.studyDays, 1)
    }

    func testStudyDaysOnlyCountDaysWithAnAnswer() {
        let progress = [
            1: word(1, [(.good, date(26, 9))]),
            2: word(2, [(.good, date(26, 21))]),
            3: word(3, [(.good, date(26)), (.good, date(27))]),
        ]
        let s = summary(progress, now: date(28, 12))
        // Monday twice and Tuesday; nothing on Wednesday yet.
        XCTAssertEqual(s.thisWeek.studyDays, 2)
    }

    func testMovedUpLeavesOutFirstAnswers() {
        let progress = [
            // A first answer, "Bildim" and "Kolay": met, not moved.
            1: word(1, [(.good, date(26))]),
            2: word(2, [(.easy, date(26))]),
            // Up from shelf 1 to 2 on Tuesday.
            3: word(3, [(.good, date(26)), (.good, date(27))]),
            // "Zor" stays on its shelf.
            4: word(4, [(.good, date(26)), (.hard, date(27))]),
            // Up on Tuesday, then forgotten on Wednesday.
            5: word(5, [(.good, date(26)), (.good, date(27)), (.again, date(28, 9))]),
        ]
        let s = summary(progress, now: date(28, 12))
        XCTAssertEqual(s.thisWeek.movedUpWordIDs, [3])
        XCTAssertEqual(s.thisWeek.metWordIDs.count, 5)
    }

    func testRecalledAfterLongGap() {
        let progress = [
            // Six answers: the sixth, on Tuesday, takes it to "Yerleşti".
            1: climb(1, from: daysBefore(31, date(27)), answers: 6),
            // In "Yerleşti" since September 27; its refresher came on Tuesday.
            2: climb(2, from: daysBefore(61, date(27)), answers: 7),
            // Graduated last week: not this week.
            3: climb(3, from: daysBefore(31, date(21)), answers: 6),
        ]
        let s = summary(progress, now: date(28, 12))
        XCTAssertEqual(s.thisWeek.recalledAfterLongGapWordIDs, [1, 2])
        XCTAssertEqual(s.lastWeek.recalledAfterLongGapWordIDs, [3])
        XCTAssertTrue(s.thisWeek.metWordIDs.isEmpty)
    }

    // MARK: The sentence

    func testSentenceOfThisWeek() {
        let progress = [
            1: word(1, [(.good, date(26))]),
            2: word(2, [(.good, date(26)), (.good, date(27))]),
        ]
        let s = summary(progress, now: date(28, 12))
        XCTAssertEqual(s.note.kind, .thisWeek)
        XCTAssertEqual(s.note.weekStart, date(26, 0))
        XCTAssertEqual(s.note.text, "Bu hafta 2 gün çalıştın. 2 yeni kelimeyle tanıştın ve 1 kelime bir basamak çıktı.")
        assertNoZero(s.note.text)
    }

    func testSentenceWithThreeParts() {
        let progress = [
            1: word(1, [(.good, date(26))]),
            2: word(2, [(.good, date(26)), (.good, date(27))]),
            3: climb(3, from: daysBefore(31, date(27)), answers: 6),
        ]
        let s = summary(progress, now: date(28, 12))
        XCTAssertEqual(
            s.note.text,
            "Bu hafta 2 gün çalıştın. 2 yeni kelimeyle tanıştın, 1 kelime bir basamak çıktı ve 1 kelimeyi uzun bir aradan sonra da hatırladın."
        )
    }

    func testSentenceWithoutAKnownDay() {
        // Met on Monday, then tapped on the widget. An earlier build's word: the day can't be
        // told, the word still counts.
        let p = Leitner.markExposure(word(1, [(.good, date(26))]), at: date(26, 18))
        let s = summary([1: legacy(p)], now: date(28, 12))
        XCTAssertEqual(s.thisWeek.studyDays, 0)
        XCTAssertEqual(s.note.text, "Bu hafta 1 yeni kelimeyle tanıştın.")
        assertNoZero(s.note.text)

        // The answer time on record keeps the day.
        let exact = summary([1: p], now: date(28, 12))
        XCTAssertEqual(exact.thisWeek.studyDays, 1)
        XCTAssertEqual(exact.note.text, "Bu hafta 1 gün çalıştın. 1 yeni kelimeyle tanıştın.")
    }

    func testQuietWeekNeverSaysZero() {
        let progress = [
            1: word(1, [(.good, date(20))]),
            2: word(2, [(.good, date(21))]),
        ]
        let s = summary(progress, now: date(29, 12))
        XCTAssertTrue(s.thisWeek.isQuiet)
        XCTAssertEqual(s.note.kind, .quiet)
        XCTAssertEqual(s.note.text, "Kitaplığındaki 2 kelime yerinde duruyor.")
        assertNoZero(s.note.text)
    }

    func testEmptyLibrary() {
        let cases: [[Int: WordProgress]] = [[:], [1: Leitner.markExposure(WordProgress(wordID: 1), at: date(27))]]
        for progress in cases {
            let s = summary(progress, now: date(28, 12))
            XCTAssertEqual(s.libraryCount, 0)
            XCTAssertEqual(s.note.kind, .emptyLibrary)
            XCTAssertFalse(s.note.text.contains { $0.isNumber }, s.note.text)
        }
    }

    func testMondayShowsLastWeekOnce() {
        let progress = [
            1: word(1, [(.good, date(22))]),
            2: word(2, [(.good, date(23))]),
        ]
        let monday = date(26, 8)
        let recap = summary(progress, now: monday)
        XCTAssertEqual(recap.note.kind, .lastWeek)
        XCTAssertEqual(recap.note.weekStart, date(19, 0))
        XCTAssertEqual(recap.note.text, "Geçen hafta 2 gün çalıştın. 2 yeni kelimeyle tanıştın.")
        assertNoZero(recap.note.text)

        // Shown once: later that Monday, this week's note.
        let later = summary(progress, now: date(26, 20), recapShownForWeek: recap.note.weekStart)
        XCTAssertEqual(later.note.kind, .quiet)
        XCTAssertEqual(later.note.text, "Kitaplığındaki 2 kelime yerinde duruyor.")

        // Only on Monday.
        XCTAssertNotEqual(summary(progress, now: date(27, 8)).note.kind, .lastWeek)
        // A recap shown a week earlier does not hide this one.
        XCTAssertEqual(summary(progress, now: monday, recapShownForWeek: date(12, 0)).note.kind, .lastWeek)
    }

    func testMondayAfterAQuietWeekHasNoRecap() {
        let progress = [1: word(1, [(.good, date(12))])]
        let s = summary(progress, now: date(26, 8))
        XCTAssertTrue(s.lastWeek.isQuiet)
        XCTAssertEqual(s.note.kind, .quiet)
        assertNoZero(s.note.text)
    }

    // MARK: Topics

    func testTopicsCountKnownLearningAndNotStarted() {
        let progress = [
            1: climb(1, from: date(1, month: 9), answers: 6),
            2: word(2, [(.good, date(26))]),
            3: Leitner.markExposure(WordProgress(wordID: 3), at: date(26)),
            5: Leitner.markKnown(WordProgress(wordID: 5), at: date(26)),
        ]
        let topics = [
            ProgressSummary.WordGroup(id: "travel", title: "Seyahat", wordIDs: [1, 2, 3, 3, 4, 99]),
            ProgressSummary.WordGroup(id: "food", title: "Yemek", wordIDs: [1, 2, 5]),
        ]
        let s = summary(progress, now: date(28, 12), wordIDs: [1, 2, 3, 4, 5], topics: topics)

        XCTAssertEqual(s.topics.map { $0.id }, ["travel", "food"])
        let travel = s.topics[0]
        XCTAssertEqual(travel.title, "Seyahat")
        XCTAssertEqual(travel.total, 4)
        XCTAssertEqual(travel.known, 1)
        XCTAssertEqual(travel.learning, 1)
        XCTAssertEqual(travel.notStarted, 2)
        XCTAssertFalse(travel.everyWordMet)

        let food = s.topics[1]
        XCTAssertEqual(food.known, 2)
        XCTAssertEqual(food.learning, 1)
        XCTAssertTrue(food.everyWordMet)
    }

    func testTopicGroupsFromTheContent() {
        let words = [3, 1, 2].map { id in
            WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")
        }
        let topics = [
            ContentTopic(id: "food", group: "A", nameEN: "Food", nameTR: "Yemek", sort: 2, cardCount: 2),
            ContentTopic(id: "travel", group: "B", nameEN: "Travel", nameTR: "Seyahat", sort: 1, cardCount: 1),
            ContentTopic(id: "work", group: "C", nameEN: "Work", nameTR: "İş", sort: 3, cardCount: 0),
        ]
        let topicsOf: [Int: Set<String>] = [1: ["food", "travel"], 3: ["food"], 7: ["travel"]]

        let groups = ProgressSummary.WordGroup.topics(topics, topicsOf: topicsOf, words: words)
        XCTAssertEqual(groups, [
            ProgressSummary.WordGroup(id: "food", title: "Yemek", wordIDs: [3, 1]),
            ProgressSummary.WordGroup(id: "travel", title: "Seyahat", wordIDs: [1]),
            ProgressSummary.WordGroup(id: "work", title: "İş", wordIDs: []),
        ])
    }
}
