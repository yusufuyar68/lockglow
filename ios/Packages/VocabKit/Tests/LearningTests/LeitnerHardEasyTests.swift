import XCTest
import CoreModels
import Learning

/// "Zor" (`.hard`) and "Kolay" (`.easy`) answers. Expected dates are written out by hand:
/// good/easy wait `intervalDays[box - 1]` days in the box they land in, hard waits half of
/// that in the box the word is already in.
final class LeitnerHardEasyTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400

    /// A word that sits in `box` (learning), reached by correct answers; `reviews` counts them.
    private func word(inBox box: Int) -> WordProgress {
        var p = WordProgress(wordID: 1)
        for _ in 0..<box {
            p = Leitner.review(p, grade: .good, at: now)
        }
        XCTAssertEqual(p.box, box)
        return p
    }

    private func known(_ p: WordProgress = WordProgress(wordID: 1)) -> WordProgress {
        return Leitner.markKnown(p, at: now)
    }

    // MARK: hard

    func testHardOnANewWordEntersBoxOneAndComesBackInHalfADay() {
        let p = Leitner.review(WordProgress(wordID: 1), grade: .hard, at: now)
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(12 * hour))
        XCTAssertEqual(p.reviews, 1)
        XCTAssertEqual(p.lastSeenAt, now)
        XCTAssertEqual(p.lapses, 0)
    }

    func testHardKeepsTheBoxAndHalvesTheInterval() {
        let later = now.addingTimeInterval(3 * day)
        let expectedDays: [Double] = [0.5, 1, 2, 4, 8]
        for (index, days) in expectedDays.enumerated() {
            let box = index + 1
            let p = Leitner.review(word(inBox: box), grade: .hard, at: later)
            XCTAssertEqual(p.box, box, "box \(box) stays")
            XCTAssertEqual(p.state, .learning)
            XCTAssertEqual(p.dueAt, later.addingTimeInterval(days * day), "box \(box)")
            XCTAssertEqual(p.lapses, 0, "hard is not a lapse")
            XCTAssertEqual(p.reviews, box + 1)
        }
    }

    func testHardInTheLastBoxDoesNotGraduate() {
        let p = Leitner.review(word(inBox: 5), grade: .hard, at: now)
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, 5)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(8 * day))
    }

    func testHardOnAKnownWordShortensTheRefresher() {
        // On a "Biliyorum" word this answers its check: remembered, so the claim is proven.
        let selfDeclared = Leitner.review(known(), grade: .hard, at: now)
        XCTAssertEqual(selfDeclared.state, .known)
        XCTAssertFalse(selfDeclared.knownOverride)
        XCTAssertEqual(selfDeclared.box, 0)
        XCTAssertEqual(selfDeclared.dueAt, now.addingTimeInterval(15 * day))
        XCTAssertEqual(selfDeclared.lapses, 0)
        XCTAssertEqual(selfDeclared.reviews, 1)

        var graduated = word(inBox: 5)
        graduated = Leitner.review(graduated, grade: .good, at: now)
        XCTAssertEqual(graduated.state, .known)
        graduated = Leitner.review(graduated, grade: .hard, at: now)
        XCTAssertEqual(graduated.state, .known)
        XCTAssertEqual(graduated.box, 5)
        XCTAssertEqual(graduated.dueAt, now.addingTimeInterval(15 * day))
    }

    func testHardFallsBetweenAgainAndGood() {
        for box in 1...5 {
            let start = word(inBox: box)
            let again = Leitner.review(start, grade: .again, at: now).dueAt!
            let hard = Leitner.review(start, grade: .hard, at: now).dueAt!
            let good = Leitner.review(start, grade: .good, at: now).dueAt!
            XCTAssertLessThan(again, hard, "box \(box)")
            XCTAssertLessThan(hard, good, "box \(box)")
        }
    }

    // MARK: easy

    func testEasyJumpsTwoBoxes() {
        // From box 0 (new) to 5, each landing in `intervalDays[newBox - 1]`.
        let cases: [(from: Int, box: Int, days: Double)] = [
            (0, 2, 2),
            (1, 3, 4),
            (2, 4, 8),
            (3, 5, 16),
        ]
        for item in cases {
            let start = item.from == 0 ? WordProgress(wordID: 1) : word(inBox: item.from)
            let p = Leitner.review(start, grade: .easy, at: now)
            XCTAssertEqual(p.box, item.box, "from box \(item.from)")
            XCTAssertEqual(p.state, .learning)
            XCTAssertEqual(p.dueAt, now.addingTimeInterval(item.days * day), "from box \(item.from)")
            XCTAssertEqual(p.lapses, 0)
            XCTAssertEqual(p.reviews, start.reviews + 1)
        }
    }

    func testEasyNeverPassesTheLastBox() {
        let p = Leitner.review(word(inBox: 4), grade: .easy, at: now)
        XCTAssertEqual(p.box, 5)
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(16 * day))
    }

    func testEasyInTheLastBoxGraduatesLikeGood() {
        let easy = Leitner.review(word(inBox: 5), grade: .easy, at: now)
        let good = Leitner.review(word(inBox: 5), grade: .good, at: now)
        XCTAssertEqual(easy.state, .known)
        XCTAssertEqual(easy.box, 5)
        XCTAssertEqual(easy.dueAt, now.addingTimeInterval(30 * day))
        // The same, but for the grade on record.
        XCTAssertEqual(easy.lastGrade, .easy)
        var easyAsGood = easy
        easyAsGood.lastGrade = .good
        XCTAssertEqual(easyAsGood, good)
    }

    func testEasyOnAKnownWordKeepsTheNormalRefresher() {
        let p = Leitner.review(known(), grade: .easy, at: now)
        XCTAssertEqual(p.state, .known)
        XCTAssertFalse(p.knownOverride)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(30 * day))
    }

    func testAgainFromBoxTwoGoesToBoxOne() {
        var p = Leitner.review(WordProgress(wordID: 1), grade: .easy, at: now)
        XCTAssertEqual(p.box, 2)
        p = Leitner.review(p, grade: .again, at: now)
        XCTAssertEqual(p.box, 1)
        XCTAssertEqual(p.lapses, 1)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(10 * 60))
    }

    func testBoxOrderOfTheFourGradesFromBoxThree() {
        let start = word(inBox: 3)
        let boxes = [ReviewGrade.again, .hard, .good, .easy].map { Leitner.review(start, grade: $0, at: now).box }
        XCTAssertEqual(boxes, [1, 3, 4, 5])
    }

    // MARK: the rest of the app sees the new dates

    func testPlannersSeeAHardAnswerTwelveHoursLater() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        // 08:00 UTC; a new word answered "Zor" is due again at 20:00.
        let morning = Date(timeIntervalSince1970: 1_760_011_200 - 4 * 3600)
        let feed = [WidgetWord(id: 1, lemma: "w", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")]
        let hard = [1: Leitner.review(WordProgress(wordID: 1), grade: .hard, at: morning)]
        let good = [1: Leitner.review(WordProgress(wordID: 1), grade: .good, at: morning)]

        let before = morning.addingTimeInterval(12 * hour - 1)
        let after = morning.addingTimeInterval(12 * hour)
        XCTAssertTrue(ReviewPlanner.dueWords(feed: feed, progress: hard, now: before, limit: 5).isEmpty)
        XCTAssertEqual(ReviewPlanner.dueWords(feed: feed, progress: hard, now: after, limit: 5).map { $0.id }, [1])
        XCTAssertTrue(ReviewPlanner.dueWords(feed: feed, progress: good, now: after, limit: 5).isEmpty)

        let endOfDay = utc.startOfDay(for: morning).addingTimeInterval(day)
        let counts = ReviewPlanner.counts(feed: feed, progress: hard, dueBy: endOfDay)
        XCTAssertEqual(counts, ProgressCounts(known: 0, learning: 1, dueToday: 1))
        let goodCounts = ReviewPlanner.counts(feed: feed, progress: good, dueBy: endOfDay)
        XCTAssertEqual(goodCounts, ProgressCounts(known: 0, learning: 1, dueToday: 0))

        // The 21:00 reminder the same evening mentions it; with "Bildim" nothing is due that day.
        func reminders(_ progress: [Int: WordProgress]) -> [Reminder] {
            return ReminderPlanner.plan(
                feed: feed, progress: progress, now: morning, minuteOfDay: 21 * 60, days: 1,
                dailyNewGoal: 0, newStudiedToday: 0, calendar: utc
            )
        }
        XCTAssertEqual(reminders(hard).map { $0.dueCount }, [1])
        XCTAssertTrue(reminders(good).isEmpty)
    }

    // MARK: progress.json

    func testProgressFileWrittenBeforeHardAndEasyStillLoads() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("LeitnerHardEasy-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        // The format of the build before this change (no new keys were added since).
        let legacy = """
        [{"word_id":5,"state":"learning","box":2,"due_at":1700086400,"exposures":3,"last_seen_at":1700000000,\
        "reviews":2,"lapses":0,"known_override":false,"saved":false},\
        {"word_id":6,"state":"new","box":0,"exposures":1,"reviews":0,"lapses":0,"known_override":false,"saved":true}]
        """
        let store = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        try Data(legacy.utf8).write(to: store.fileURL)

        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded)
        var progress = loaded.progress
        XCTAssertEqual(progress.count, 2)
        XCTAssertEqual(progress[5]?.box, 2)
        XCTAssertEqual(progress[5]?.dueAt, Date(timeIntervalSince1970: 1_700_086_400))

        progress[5] = Leitner.review(try XCTUnwrap(progress[5]), grade: .hard, at: now)
        progress[6] = Leitner.review(try XCTUnwrap(progress[6]), grade: .easy, at: now)
        try store.save(progress)

        let reloaded = try store.load()
        XCTAssertEqual(reloaded.outcome, .loaded)
        XCTAssertEqual(reloaded.progress, progress)
        XCTAssertEqual(reloaded.progress[5]?.box, 2)
        XCTAssertEqual(reloaded.progress[5]?.dueAt, now.addingTimeInterval(1 * day))
        XCTAssertEqual(reloaded.progress[6]?.box, 2)
        XCTAssertEqual(reloaded.progress[6]?.saved, true)
    }
}
