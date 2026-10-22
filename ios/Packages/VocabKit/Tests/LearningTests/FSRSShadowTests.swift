import XCTest
import CoreModels
import Learning

/// FSRS in Leitner's shadow (docs/ozellik_planlari/fsrs.md 4.3 step 1): Leitner schedules every
/// answer and each answer is logged; `FSRS.replay` rebuilds from the log what FSRS would have done.
final class FSRSShadowTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_700_000_000)
    private let minute: TimeInterval = 60
    private let day: TimeInterval = 86_400
    private let fsrs = FSRS.lockglow

    private func at(days: Double, minutes: Double = 0) -> Date {
        return start.addingTimeInterval(days * day + minutes * minute)
    }

    /// Answers `p` with Leitner, as the app does, and logs the answer.
    private func answer(_ p: inout WordProgress, _ grade: ReviewGrade, at date: Date, into log: inout [ReviewLogEntry]) {
        let before = p
        p = Leitner.review(p, grade: grade, at: date)
        guard let entry = ReviewLogEntry(before: before, after: p, source: .review) else {
            return XCTFail("an answer always makes an entry")
        }
        log.append(entry)
    }

    /// FSRS's own schedule, answer by answer.
    private func direct(_ answers: [(ReviewGrade, Date)], from card: FSRSCard = FSRSCard()) -> FSRSCard {
        return answers.reduce(card) { c, a in fsrs.review(c, grade: a.0, at: a.1) }
    }

    private func entry(_ id: Int, reviews: Int) -> ReviewLogEntry {
        return ReviewLogEntry(wordID: id, at: at(days: Double(reviews)), grade: .good, source: .review, reviews: reviews)
    }

    func testLockglowSettings() {
        XCTAssertEqual(fsrs.desiredRetention, 0.9)
        XCTAssertEqual(fsrs.learningSteps, [600])
        XCTAssertEqual(fsrs.relearningSteps, [600])
        XCTAssertEqual(fsrs.weights, FSRS.defaultWeights)
    }

    func testReplayIsFSRSAnswerByAnswer() {
        var log: [ReviewLogEntry] = []
        var a = WordProgress(wordID: 1)
        var b = WordProgress(wordID: 2)
        let answersA: [(ReviewGrade, Date)] = [
            (.good, at(days: 0)), (.good, at(days: 1)), (.again, at(days: 3)), (.good, at(days: 3, minutes: 10)), (.hard, at(days: 5)),
        ]
        let answersB: [(ReviewGrade, Date)] = [(.easy, at(days: 0, minutes: 1)), (.good, at(days: 8))]
        answer(&a, answersA[0].0, at: answersA[0].1, into: &log)
        answer(&b, answersB[0].0, at: answersB[0].1, into: &log)
        for item in answersA.dropFirst() {
            answer(&a, item.0, at: item.1, into: &log)
        }
        answer(&b, answersB[1].0, at: answersB[1].1, into: &log)

        let replay = fsrs.replay(log)
        XCTAssertTrue(replay.incomplete.isEmpty)
        XCTAssertEqual(replay.cards.count, 2)
        XCTAssertEqual(replay.cards[1], direct(answersA))
        XCTAssertEqual(replay.cards[2], direct(answersB))
    }

    func testTheShadowNeverSchedules() {
        // Leitner's dates stay Leitner's; the shadow has its own (the table in fsrs.md 2).
        let waits: [(ReviewGrade, leitner: TimeInterval, fsrs: TimeInterval)] = [
            (.again, 10 * minute, 10 * minute),
            (.hard, 12 * 3600, 15 * minute),
            (.good, 1 * day, 2 * day),
            (.easy, 2 * day, 8 * day),
        ]
        for (index, item) in waits.enumerated() {
            var log: [ReviewLogEntry] = []
            var p = WordProgress(wordID: index)
            answer(&p, item.0, at: start, into: &log)
            XCTAssertEqual(p.dueAt, start.addingTimeInterval(item.leitner), "\(item.0)")
            XCTAssertEqual(fsrs.replay(log).cards[index]?.dueAt, start.addingTimeInterval(item.fsrs), "\(item.0)")
        }
    }

    func testTwoAnswersOnOneDayUseTheSameDayFormula() throws {
        var log: [ReviewLogEntry] = []
        var p = WordProgress(wordID: 1)
        answer(&p, .again, at: at(days: 0), into: &log)
        answer(&p, .good, at: at(days: 0, minutes: 10), into: &log)
        let card = try XCTUnwrap(fsrs.replay(log).cards[1])
        let expected = fsrs.nextMemory(fsrs.initialMemory(.again), elapsedDays: 0, grade: .good)
        XCTAssertEqual(card.memory, expected)
        XCTAssertEqual(card.phase, .review)
        XCTAssertEqual(card.lastReviewAt, at(days: 0, minutes: 10))
    }

    func testALateWidgetAnswerIsReplayedInTimeOrder() {
        var log: [ReviewLogEntry] = []
        var p = WordProgress(wordID: 1)
        answer(&p, .good, at: at(days: 0), into: &log)
        answer(&p, .good, at: at(days: 2), into: &log)
        // The widget's "Bilmiyorum" from the day before reaches the app only now.
        let widget = at(days: 1)
        let ingested = ProgressIngest.applyLogged([LearningEvent(type: .unknown, wordID: 1, at: widget)], to: [1: p])
        log += ingested.answers
        XCTAssertEqual(log.map { $0.reviews }, [1, 2, 3])
        XCTAssertEqual(fsrs.replay(log).cards[1], direct([(.good, at(days: 0)), (.again, widget), (.good, at(days: 2))]))
    }

    func testAWordAnsweredBeforeTheLogStartsFromItsSeed() throws {
        // As an earlier build left it: box 3 (4 days), one lapse, due at `start`.
        var old = WordProgress(wordID: 4)
        old.state = .learning
        old.box = 3
        old.lapses = 1
        old.reviews = 4
        old.dueAt = start
        old.lastSeenAt = at(days: -4)
        var p = old
        var log: [ReviewLogEntry] = []
        let first = at(days: 1)
        answer(&p, .good, at: first, into: &log)
        answer(&p, .again, at: at(days: 9), into: &log)

        let seed = try XCTUnwrap(log.first?.seed)
        let seeded = fsrs.seededCard(seed, firstAnswerAt: first)
        XCTAssertEqual(seeded.phase, .review)
        XCTAssertNil(seeded.step)
        XCTAssertEqual(seeded.memory?.stability, 4)
        XCTAssertEqual(seeded.memory?.difficulty ?? 0, 7.39, accuracy: 0.01)
        XCTAssertEqual(seeded.lastReviewAt, at(days: -4))
        XCTAssertEqual(seeded.dueAt, start)

        let replay = fsrs.replay(log)
        XCTAssertTrue(replay.incomplete.isEmpty)
        XCTAssertEqual(replay.cards[4], direct([(.good, first), (.again, at(days: 9))], from: seeded))
    }

    func testSeedsFollowThePlan() {
        func seeded(_ state: LearningState, box: Int = 1, lapses: Int = 0, due: Date? = nil, claimed: Bool = false) -> FSRSCard {
            let seed = ReviewLogEntry.Seed(state: state, box: box, lapses: lapses, dueAt: due ?? start, knownOverride: claimed)
            return fsrs.seededCard(seed, firstAnswerAt: start)
        }
        // Difficulty: "Bildim", then one "Bilemedim" step per lapse (fsrs.md 4.2: 2.12, 7.39, 9.13).
        XCTAssertEqual(seeded(.learning).memory?.difficulty ?? 0, 2.12, accuracy: 0.01)
        XCTAssertEqual(seeded(.learning, lapses: 1).memory?.difficulty ?? 0, 7.39, accuracy: 0.01)
        XCTAssertEqual(seeded(.learning, lapses: 2).memory?.difficulty ?? 0, 9.13, accuracy: 0.01)
        let many = seeded(.learning, lapses: 1_000_000).memory?.difficulty ?? 0
        XCTAssertGreaterThan(many, 9.9)
        XCTAssertLessThanOrEqual(many, 10)

        // Stability: the box's interval (out-of-range boxes clamped), 30 days for a known word.
        XCTAssertEqual((0...6).map { seeded(.learning, box: $0).memory?.stability }, [1, 1, 2, 4, 8, 16, 16])
        XCTAssertEqual(seeded(.known, box: 5).memory?.stability, 30)
        XCTAssertEqual(seeded(.known, box: 5).lastReviewAt, at(days: -30))

        // No memory to estimate: an unchecked "Biliyorum", a word sent back to "Tanış".
        XCTAssertEqual(seeded(.known, claimed: true), FSRSCard())
        XCTAssertEqual(seeded(.new), FSRSCard())

        // Answered early: the last answer is never put after the first logged one.
        XCTAssertEqual(seeded(.learning, box: 3, due: at(days: 10)).lastReviewAt, start)
    }

    func testMissingAnswersMakeAWordIncomplete() {
        let log = [
            entry(1, reviews: 3),
            entry(2, reviews: 1), entry(2, reviews: 3),
            entry(3, reviews: 1), entry(3, reviews: 1),
            entry(4, reviews: 1), entry(4, reviews: 2),
        ]
        // 1 began before the log and has no seed (the log was trimmed); 2 misses its second
        // answer; 3 has the first answer twice (an older progress file came back from its backup).
        let replay = fsrs.replay(log)
        XCTAssertEqual(replay.incomplete, [1, 2, 3])
        XCTAssertEqual(Set(replay.cards.keys), [4])
        XCTAssertEqual(fsrs.replay([]), FSRSReplay())
    }

    func testTheBiliyorumCheckIsTheFirstFSRSAnswer() {
        let check = start.addingTimeInterval(Leitner.knownCheckDelay)
        var log: [ReviewLogEntry] = []
        var p = Leitner.markKnown(WordProgress(wordID: 5), at: start)
        answer(&p, .good, at: check, into: &log)
        XCTAssertEqual(log.first?.knownCheck, true)
        XCTAssertEqual(fsrs.replay(log).cards[5], direct([(.good, check)]))

        // A claim on a word answered before the log: no memory is made up (fsrs.md 4.2 step 3).
        var old = WordProgress(wordID: 6)
        old.state = .learning
        old.box = 2
        old.reviews = 3
        old.dueAt = start
        var q = Leitner.markKnown(old, at: start)
        var oldLog: [ReviewLogEntry] = []
        answer(&q, .good, at: check, into: &oldLog)
        XCTAssertNotNil(oldLog.first?.seed)
        XCTAssertEqual(fsrs.replay(oldLog).cards[6], direct([(.good, check)]))
    }

    func testTheLogFileGivesTheSameReplay() throws {
        var log: [ReviewLogEntry] = []
        var p = WordProgress(wordID: 1)
        answer(&p, .good, at: start.addingTimeInterval(0.375), into: &log)
        answer(&p, .hard, at: at(days: 1, minutes: 7.5), into: &log)
        answer(&p, .again, at: at(days: 3), into: &log)

        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("FSRSShadow-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = ReviewLog(fileURL: directory.appendingPathComponent("review_log.jsonl"))
        try file.append(log)
        let read = try file.entries()
        XCTAssertEqual(read, log)
        XCTAssertEqual(fsrs.replay(read), fsrs.replay(log))
    }
}
