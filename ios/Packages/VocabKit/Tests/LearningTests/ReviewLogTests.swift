import XCTest
import CoreModels
import Learning

/// The review log (`review_log.jsonl`): which changes are answers, the line format and size, a
/// crash in the middle of a write, unreadable lines, trimming, and the widget's answers.
final class ReviewLogTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000.5)
    private let day: TimeInterval = 86_400
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("ReviewLog-\(UUID().uuidString)")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func makeLog(maxBytes: Int = 8_000_000, trimmedBytes: Int = 6_000_000) -> ReviewLog {
        return ReviewLog(fileURL: directory.appendingPathComponent("review_log.jsonl"), maxBytes: maxBytes, trimmedBytes: trimmedBytes)
    }

    private func entry(_ id: Int, _ grade: ReviewGrade = .good, at: Date, reviews: Int = 1) -> ReviewLogEntry {
        return ReviewLogEntry(wordID: id, at: at, grade: grade, source: .review, reviews: reviews)
    }

    private func keys(_ line: Data) throws -> Set<String> {
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        return Set(object.keys)
    }

    // MARK: Which changes are answers

    func testAnAnswerMakesAnEntry() throws {
        let before = Leitner.markExposure(WordProgress(wordID: 7), at: now.addingTimeInterval(-day))
        let after = Leitner.review(before, grade: .hard, at: now)
        let e = try XCTUnwrap(ReviewLogEntry(before: before, after: after, source: .review))
        XCTAssertEqual(e, ReviewLogEntry(wordID: 7, at: now, grade: .hard, source: .review, reviews: 1))
        XCTAssertNil(e.knownCheck)
        XCTAssertNil(e.seed)
    }

    func testOtherChangesMakeNoEntry() {
        let start = Leitner.review(WordProgress(wordID: 1), grade: .good, at: now)
        XCTAssertNil(ReviewLogEntry(before: start, after: Leitner.markExposure(start, at: now), source: .widget))
        XCTAssertNil(ReviewLogEntry(before: start, after: Leitner.markKnown(start, at: now), source: .widget))
        XCTAssertNil(ReviewLogEntry(before: start, after: start, source: .review))
        // Two answers at once, or another word: not one answer.
        let twice = Leitner.review(Leitner.review(start, grade: .good, at: now), grade: .good, at: now)
        XCTAssertNil(ReviewLogEntry(before: start, after: twice, source: .review))
        let other = Leitner.review(WordProgress(wordID: 2), grade: .good, at: now)
        XCTAssertNil(ReviewLogEntry(before: WordProgress(wordID: 1), after: other, source: .review))
    }

    func testTheBiliyorumCheckIsMarked() throws {
        let claimed = Leitner.markKnown(WordProgress(wordID: 3), at: now)
        let check = now.addingTimeInterval(Leitner.knownCheckDelay)
        let e = try XCTUnwrap(ReviewLogEntry(before: claimed, after: Leitner.review(claimed, grade: .again, at: check), source: .review))
        XCTAssertEqual(e.knownCheck, true)
        XCTAssertEqual(e.reviews, 1)
        XCTAssertEqual(e.grade, .again)
        XCTAssertNil(e.seed, "never answered before: nothing to estimate")
    }

    func testAWordAnsweredBeforeTheLogGetsASeedOnce() throws {
        // As an earlier build left it: box 3, one lapse, four answers, no answer time on record.
        var old = WordProgress(wordID: 4)
        old.state = .learning
        old.box = 3
        old.lapses = 1
        old.reviews = 4
        old.dueAt = now.addingTimeInterval(-day)
        old.lastSeenAt = now.addingTimeInterval(-5 * day)
        let first = Leitner.review(old, grade: .good, at: now)
        let e = try XCTUnwrap(ReviewLogEntry(before: old, after: first, source: .review))
        XCTAssertEqual(e.reviews, 5)
        XCTAssertEqual(e.seed, ReviewLogEntry.Seed(state: .learning, box: 3, lapses: 1, dueAt: now.addingTimeInterval(-day), knownOverride: false))

        let second = Leitner.review(first, grade: .good, at: now.addingTimeInterval(8 * day))
        XCTAssertNil(try XCTUnwrap(ReviewLogEntry(before: first, after: second, source: .review)).seed)
    }

    // MARK: Lines

    func testLinesUseSnakeCaseAndLeaveOutEmptyFields() throws {
        XCTAssertEqual(try keys(ReviewLog.line(entry(1, at: now))), ["at", "grade", "reviews", "source", "word_id"])
        let full = ReviewLogEntry(
            wordID: 1, at: now, grade: .again, source: .widget, reviews: 6, knownCheck: true,
            seed: ReviewLogEntry.Seed(state: .known, box: 2, lapses: 0, dueAt: now, knownOverride: true)
        )
        let line = try ReviewLog.line(full)
        XCTAssertEqual(try keys(line), ["at", "grade", "known_check", "reviews", "seed", "source", "word_id"])
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        let seed = try XCTUnwrap(object["seed"] as? [String: Any])
        XCTAssertEqual(Set(seed.keys), ["box", "due_at", "known_override", "lapses", "state"])
        XCTAssertEqual(object["source"] as? String, "widget")
        XCTAssertEqual(object["grade"] as? String, "again")
        XCTAssertEqual(ReviewLog.decode(line + Data([0x0A])), [full])
    }

    func testALineIsAboutNinetyBytes() throws {
        // A date with a full fraction, as `Date()` gives it.
        let at = Date(timeIntervalSince1970: 1_792_700_000.123_456_7)
        let plain = try ReviewLog.line(ReviewLogEntry(wordID: 12_345, at: at, grade: .good, source: .review, reviews: 123))
        XCTAssertLessThanOrEqual(plain.count, 100)
        let seeded = try ReviewLog.line(ReviewLogEntry(
            wordID: 12_345, at: at, grade: .again, source: .widget, reviews: 124, knownCheck: true,
            seed: ReviewLogEntry.Seed(state: .learning, box: 5, lapses: 12, dueAt: at, knownOverride: false)
        ))
        // Once per word, on its first answer after the log began.
        XCTAssertLessThanOrEqual(seeded.count, 230)
    }

    // MARK: The file

    func testAppendReadAndRemove() throws {
        let log = makeLog()
        XCTAssertEqual(try log.entries(), [], "no file yet")
        let written = [entry(1, at: now), entry(2, .again, at: now.addingTimeInterval(1)), entry(1, .hard, at: now.addingTimeInterval(2), reviews: 2)]
        try log.append(Array(written[0..<2]))
        try log.append([])
        try log.append([written[2]])
        XCTAssertEqual(try log.entries(), written)
        XCTAssertEqual(try String(contentsOf: log.fileURL, encoding: .utf8).filter { $0 == "\n" }.count, 3)

        // From one answer's progress change.
        let before = WordProgress(wordID: 9)
        try log.append(before: before, after: Leitner.review(before, grade: .easy, at: now), source: .review)
        try log.append(before: before, after: Leitner.markExposure(before, at: now), source: .review)
        XCTAssertEqual(try log.entries().last, ReviewLogEntry(wordID: 9, at: now, grade: .easy, source: .review, reviews: 1))
        XCTAssertEqual(try log.entries().count, 4)

        try log.removeAll()
        XCTAssertEqual(try log.entries(), [])
        XCTAssertNoThrow(try log.removeAll())
    }

    func testDefaultPlaceIsBesideTheProgressFile() throws {
        let url = try ReviewLog.defaultURL()
        XCTAssertEqual(url.lastPathComponent, "review_log.jsonl")
        XCTAssertEqual(url.deletingLastPathComponent(), try ProgressStore.defaultURL().deletingLastPathComponent())
    }

    func testALineCutByACrashCostsOnlyThatLine() throws {
        let log = makeLog()
        let first = entry(1, at: now)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var text = try ReviewLog.line(first)
        text.append(0x0A)
        text.append(Data(#"{"at":1700000001,"gra"#.utf8))
        try text.write(to: log.fileURL)

        let next = entry(2, at: now.addingTimeInterval(5))
        try log.append([next])
        XCTAssertEqual(try log.entries(), [first, next])
    }

    func testLinesThisBuildCannotReadAreSkipped() throws {
        let log = makeLog()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let lines = [
            #"{"at":1700000000,"grade":"good","reviews":1,"source":"review","word_id":1}"#,
            #"{"at":1700000001,"grade":"perfect","reviews":1,"source":"review","word_id":2}"#,
            "not json",
            "",
            #"{"at":1700000002,"grade":"hard","reviews":2,"source":"voice","word_id":1}"#,
            #"{"at":1700000003,"grade":"again","new_field":true,"reviews":2,"source":"widget","word_id":1}"#,
        ]
        try Data((lines.joined(separator: "\n") + "\n").utf8).write(to: log.fileURL)
        XCTAssertEqual(try log.entries().map { $0.at.timeIntervalSince1970 }, [1_700_000_000, 1_700_000_003])
    }

    func testAboveTheLimitTheOldestLinesGo() throws {
        let one = try ReviewLog.line(entry(1, at: now)).count + 1
        let log = makeLog(maxBytes: 20 * one, trimmedBytes: 12 * one)
        var written: [ReviewLogEntry] = []
        for n in 1...50 {
            let e = entry(n % 7, at: now.addingTimeInterval(Double(n)), reviews: n)
            written.append(e)
            try log.append([e])
            let size = try Data(contentsOf: log.fileURL).count
            XCTAssertLessThanOrEqual(size, 20 * one + 8, "after answer \(n)")
        }
        let kept = try log.entries()
        XCTAssertGreaterThanOrEqual(kept.count, 10)
        XCTAssertLessThanOrEqual(kept.count, 21)
        XCTAssertEqual(kept, Array(written.suffix(kept.count)), "the newest lines, whole and in order")
    }

    // MARK: Widget answers

    func testWidgetAnswersAreLoggedInTheOrderApplied() throws {
        let claimed = Leitner.markKnown(WordProgress(wordID: 2), at: now.addingTimeInterval(-day))
        let events = [
            LearningEvent(type: .unknown, wordID: 2, at: now.addingTimeInterval(30)),
            LearningEvent(type: .next, wordID: 1, at: now),
            LearningEvent(type: .unknown, wordID: 1, at: now.addingTimeInterval(10)),
            LearningEvent(type: .known, wordID: 3, at: now.addingTimeInterval(20)),
        ]
        let logged = ProgressIngest.applyLogged(events, to: [2: claimed])
        XCTAssertEqual(logged.progress, ProgressIngest.apply(events, to: [2: claimed]))
        XCTAssertEqual(logged.answers, [
            ReviewLogEntry(wordID: 1, at: now.addingTimeInterval(10), grade: .again, source: .widget, reviews: 1),
            ReviewLogEntry(wordID: 2, at: now.addingTimeInterval(30), grade: .again, source: .widget, reviews: 1, knownCheck: true),
        ])
        XCTAssertTrue(logged.progress[2]?.returnsToIntro ?? false)
        XCTAssertTrue(ProgressIngest.applyLogged([], to: [:]).answers.isEmpty)
    }
}
