import XCTest
import CoreModels
import Learning

/// The two schedulers behind `ReviewScheduler` (docs/ozellik_planlari/fsrs.md 4.3 step 2):
/// Leitner as before, and FSRS with Lockglow's rules (basamak from stability, known at 30 days,
/// the "Biliyorum" check, graduation only from basamak 4 or 5, "Zor" never under 12 hours),
/// keeping every field in Leitner's terms.
final class FSRSSchedulerTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_700_000_000)
    private let minute: TimeInterval = 60
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400
    private let scheduler = FSRSScheduler()
    private let grades: [ReviewGrade] = [.again, .hard, .good, .easy]

    private var engine: FSRS {
        return scheduler.fsrs
    }

    private func at(days: Double, minutes: Double = 0) -> Date {
        return start.addingTimeInterval(days * day + minutes * minute)
    }

    /// Words in every kind of state, for answers at `start`.
    private func samples() -> [WordProgress] {
        let fresh = WordProgress(wordID: 1)

        var learning = WordProgress(wordID: 2)
        learning.state = .learning
        learning.box = 3
        learning.reviews = 4
        learning.lapses = 1
        learning.dueAt = start
        learning.lastSeenAt = at(days: -4)
        learning.lastReviewedAt = at(days: -4)
        learning.lastGrade = .good
        learning.firstReviewedAt = at(days: -20)

        // Answered before `lastReviewedAt` existed.
        var unlogged = WordProgress(wordID: 3)
        unlogged.state = .learning
        unlogged.box = 2
        unlogged.reviews = 2
        unlogged.dueAt = start

        var known = WordProgress(wordID: 4)
        known.state = .known
        known.box = 5
        known.reviews = 9
        known.refresherStep = 1
        known.dueAt = start
        known.lastReviewedAt = at(days: -60)
        known.lastGrade = .good
        known.firstReviewedAt = at(days: -120)

        let claimed = Leitner.markKnown(WordProgress(wordID: 5), at: at(days: -3))

        // Sent back to "Tanış" by a failed check.
        var backToIntro = WordProgress(wordID: 6)
        backToIntro.reviews = 1
        backToIntro.lapses = 1
        backToIntro.lastReviewedAt = at(days: -1)
        backToIntro.lastGrade = .again
        backToIntro.firstReviewedAt = at(days: -1)

        return [fresh, learning, unlogged, known, claimed, backToIntro]
    }

    /// A word taken through right FSRS answers, each on its due date, until it is known.
    private func graduated() throws -> (progress: WordProgress, now: Date) {
        var now = start
        var p = scheduler.review(WordProgress(wordID: 1), grade: .good, at: now)
        var answers = 0
        while p.state != .known && answers < 20 {
            now = try XCTUnwrap(p.dueAt)
            p = scheduler.review(p, grade: .good, at: now)
            answers += 1
        }
        XCTAssertEqual(p.state, .known)
        return (p, now)
    }

    /// Answers `p` with `s` and logs the answer.
    private func answer(
        _ p: inout WordProgress,
        _ grade: ReviewGrade,
        at date: Date,
        with s: ReviewScheduler,
        into log: inout [ReviewLogEntry]
    ) {
        let before = p
        p = s.review(p, grade: grade, at: date)
        guard let entry = ReviewLogEntry(before: before, after: p, source: .review) else {
            return XCTFail("an answer always makes an entry")
        }
        log.append(entry)
    }

    // MARK: Schedulers

    func testLeitnerSchedulerIsLeitner() {
        let leitner = LeitnerScheduler()
        XCTAssertEqual(leitner.kind, .leitner)
        for p in samples() {
            for grade in grades {
                XCTAssertEqual(leitner.review(p, grade: grade, at: start), Leitner.review(p, grade: grade, at: start), "word \(p.wordID) \(grade)")
            }
        }
    }

    func testBothAreReviewSchedulers() {
        XCTAssertEqual(scheduler.kind, .fsrs)
        let schedulers: [ReviewScheduler] = [LeitnerScheduler(), FSRSScheduler()]
        XCTAssertEqual(schedulers.map { $0.kind }, [.leitner, .fsrs])
        for s in schedulers {
            let after = s.review(WordProgress(wordID: 1), grade: .good, at: start)
            XCTAssertEqual(after.reviews, 1, "\(s.kind)")
            XCTAssertEqual(after.state, .learning, "\(s.kind)")
            XCTAssertEqual(after.box, 1, "\(s.kind)")
        }
    }

    func testBookkeepingIsLeitner() {
        for p in samples() {
            for grade in grades {
                let leitner = Leitner.review(p, grade: grade, at: start)
                let fsrs = scheduler.review(p, grade: grade, at: start)
                let label = "word \(p.wordID) \(grade)"
                XCTAssertEqual(fsrs.reviews, leitner.reviews, label)
                XCTAssertEqual(fsrs.lastSeenAt, leitner.lastSeenAt, label)
                XCTAssertEqual(fsrs.lastReviewedAt, leitner.lastReviewedAt, label)
                XCTAssertEqual(fsrs.lastGrade, leitner.lastGrade, label)
                XCTAssertEqual(fsrs.firstReviewedAt, leitner.firstReviewedAt, label)
                XCTAssertEqual(fsrs.lapses, leitner.lapses, label)
                XCTAssertEqual(fsrs.exposures, p.exposures, label)
                XCTAssertEqual(fsrs.saved, p.saved, label)
                let entry = ReviewLogEntry(before: p, after: fsrs, source: .review)
                XCTAssertNotNil(entry, label)
                XCTAssertEqual(entry, ReviewLogEntry(before: p, after: leitner, source: .review), label)
            }
        }
    }

    func testLapsesCountAgainAfterAStep() {
        for p in samples() {
            let after = scheduler.review(p, grade: .again, at: start)
            let expected = p.box > 0 || p.state == .known ? p.lapses + 1 : p.lapses
            XCTAssertEqual(after.lapses, expected, "word \(p.wordID)")
        }
    }

    // MARK: First answers

    func testFirstAnswers() throws {
        XCTAssertEqual(FSRSScheduler.hardStepWait, 12 * hour)
        // "Zor": FSRS's same-day step would be 15 minutes; Lockglow waits Leitner's 12 hours.
        let waits: [(ReviewGrade, TimeInterval, FSRSCard.Phase, Int?)] = [
            (.again, 10 * minute, .learning, 0),
            (.hard, 12 * hour, .learning, 0),
            (.good, 2 * day, .review, nil),
            (.easy, 8 * day, .review, nil),
        ]
        for (grade, wait, phase, step) in waits {
            let p = scheduler.review(WordProgress(wordID: 1), grade: grade, at: start)
            let label = "\(grade)"
            XCTAssertEqual(p.dueAt, start.addingTimeInterval(wait), label)
            XCTAssertEqual(p.state, .learning, label)
            XCTAssertEqual(p.box, 1, label)
            XCTAssertEqual(p.lapses, 0, label)
            XCTAssertEqual(p.reviews, 1, label)
            XCTAssertEqual(p.firstReviewedAt, start, label)
            let state = try XCTUnwrap(p.fsrs, label)
            let memory = engine.initialMemory(grade)
            XCTAssertEqual(state.stability, memory.stability, label)
            XCTAssertEqual(state.difficulty, memory.difficulty, label)
            XCTAssertEqual(state.phase, phase, label)
            XCTAssertEqual(state.step, step, label)
            XCTAssertEqual(state.lastReviewAt, start, label)
            XCTAssertEqual(state.reviews, 1, label)
            XCTAssertEqual(state.shelfBefore, 0, label)
        }
    }

    func testSecondRightAnswerJumpsToItsStep() throws {
        let first = scheduler.review(WordProgress(wordID: 1), grade: .good, at: start)
        let second = scheduler.review(first, grade: .good, at: at(days: 2))
        let expected = engine.nextMemory(engine.initialMemory(.good), elapsedDays: 2, grade: .good)
        let state = try XCTUnwrap(second.fsrs)
        XCTAssertEqual(state.stability, expected.stability)
        XCTAssertEqual(state.difficulty, expected.difficulty)
        XCTAssertEqual(second.box, FSRSScheduler.box(forStability: expected.stability))
        XCTAssertEqual(second.box, 4)
        XCTAssertEqual(second.state, .learning)
        XCTAssertEqual(second.dueAt, at(days: 2 + Double(engine.scheduledDays(stability: expected.stability))))
        XCTAssertEqual(state.reviews, 2)
        XCTAssertEqual(state.shelfBefore, ProgressSummary.Shelf.box1.rawValue)
    }

    // MARK: Steps

    func testBoxForStability() {
        let table: [(Double, Int)] = [
            (0.5, 1), (1, 1), (1.99, 1), (2, 2), (4, 3), (8, 4), (16, 5), (29.9, 5), (30, 5), (500, 5),
        ]
        for (stability, box) in table {
            XCTAssertEqual(FSRSScheduler.box(forStability: stability), box, "\(stability)")
        }
    }

    func testRefresherStepForStability() {
        let table: [(Double, Int?)] = [
            (1, nil), (29.9, nil), (30, nil), (59.9, nil), (60, 1), (119.9, 1), (120, 2), (500, 2),
        ]
        for (stability, step) in table {
            XCTAssertEqual(FSRSScheduler.refresherStep(forStability: stability), step, "\(stability)")
        }
    }

    func testRightAnswersGraduateAtThirtyDays() throws {
        var now = start
        var p = scheduler.review(WordProgress(wordID: 1), grade: .good, at: now)
        var answers = 0
        while p.state != .known && answers < 20 {
            now = try XCTUnwrap(p.dueAt)
            let before = p
            p = scheduler.review(p, grade: .good, at: now)
            answers += 1
            let stability = try XCTUnwrap(p.fsrs).stability
            if p.state == .learning {
                XCTAssertLessThan(stability, FSRSScheduler.knownStability)
                XCTAssertGreaterThanOrEqual(p.box, before.box)
                XCTAssertLessThanOrEqual(try XCTUnwrap(p.dueAt).timeIntervalSince(now), FSRSScheduler.unprovenMaximumWait)
            } else {
                XCTAssertGreaterThanOrEqual(stability, FSRSScheduler.knownStability)
                // Only from basamak 4 or 5, through the recall question.
                XCTAssertGreaterThanOrEqual(before.box, ReviewPlanner.recallFromBox)
            }
        }
        XCTAssertEqual(p.state, .known)
        XCTAssertEqual(p.box, Leitner.maxBox)
        XCTAssertFalse(p.knownOverride)
        let state = try XCTUnwrap(p.fsrs)
        XCTAssertEqual(state.phase, .review)
        XCTAssertEqual(p.refresherStep, FSRSScheduler.refresherStep(forStability: state.stability))
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(Double(engine.scheduledDays(stability: state.stability)) * day))

        // Later right answers keep it known, "Zor" included.
        for grade in [ReviewGrade.hard, .good, .hard, .easy] {
            now = try XCTUnwrap(p.dueAt)
            p = scheduler.review(p, grade: grade, at: now)
            let stability = try XCTUnwrap(p.fsrs).stability
            XCTAssertEqual(p.state, .known, "\(grade)")
            XCTAssertEqual(p.box, Leitner.maxBox, "\(grade)")
            XCTAssertEqual(p.refresherStep, FSRSScheduler.refresherStep(forStability: stability), "\(grade)")
            XCTAssertEqual(p.dueAt, now.addingTimeInterval(Double(engine.scheduledDays(stability: stability)) * day), "\(grade)")
        }
    }

    /// Basamak 3 with stability 4, last answered at `start`.
    private func onStep3() -> WordProgress {
        var p = WordProgress(wordID: 1)
        p.state = .learning
        p.box = 3
        p.reviews = 3
        p.dueAt = at(days: 4)
        p.lastSeenAt = start
        p.lastReviewedAt = start
        p.lastGrade = .good
        p.firstReviewedAt = at(days: -10)
        p.fsrs = FSRSState(stability: 4, difficulty: 5, phase: .review, step: nil, lastReviewAt: start, reviews: 3, shelfBefore: 2)
        return p
    }

    func testABigJumpBelowStep4ClimbsToStep5First() throws {
        XCTAssertEqual(FSRSScheduler.unprovenMaximumWait, 16 * day)
        // "Kolay" on time, and a "Bildim" long overdue: both pass 30 days of stability.
        let jumps: [(ReviewGrade, Double)] = [(.easy, 8), (.good, 40)]
        for (grade, days) in jumps {
            let label = "\(grade) after \(days) days"
            let now = at(days: days)
            let p = scheduler.review(onStep3(), grade: grade, at: now)
            let state = try XCTUnwrap(p.fsrs, label)
            XCTAssertGreaterThanOrEqual(state.stability, FSRSScheduler.knownStability, label)
            XCTAssertTrue(FSRSScheduler.isKnown(state.card), label)
            XCTAssertGreaterThan(engine.scheduledDays(stability: state.stability), 16, label)
            // Not "Yerleşti" yet: basamak 5, back within 16 days for the recall question.
            XCTAssertEqual(p.state, .learning, label)
            XCTAssertEqual(p.box, Leitner.maxBox, label)
            XCTAssertEqual(p.box, FSRSScheduler.box(forStability: state.stability), label)
            XCTAssertNil(p.refresherStep, label)
            XCTAssertFalse(p.knownOverride, label)
            XCTAssertEqual(p.dueAt, now.addingTimeInterval(FSRSScheduler.unprovenMaximumWait), label)
            XCTAssertEqual(ReviewPlanner.questionKind(for: p, hasCloze: true), .recall, label)
            XCTAssertEqual(state.shelfBefore, ProgressSummary.Shelf.box3.rawValue, label)
            XCTAssertEqual(FSRSScheduler.lastAnswer(of: p)?.kind, .movedUp, label)

            // The next right answer, from basamak 5, graduates.
            let next = try XCTUnwrap(p.dueAt, label)
            let known = scheduler.review(p, grade: .good, at: next)
            let knownState = try XCTUnwrap(known.fsrs, label)
            XCTAssertEqual(known.state, .known, label)
            XCTAssertEqual(known.box, Leitner.maxBox, label)
            XCTAssertFalse(known.knownOverride, label)
            XCTAssertEqual(known.refresherStep, FSRSScheduler.refresherStep(forStability: knownState.stability), label)
            XCTAssertEqual(known.dueAt, next.addingTimeInterval(Double(engine.scheduledDays(stability: knownState.stability)) * day), label)
            XCTAssertEqual(knownState.shelfBefore, ProgressSummary.Shelf.box5.rawValue, label)
            XCTAssertEqual(FSRSScheduler.lastAnswer(of: known)?.kind, .recalledOnTop, label)
        }
    }

    func testANewWordNeverGraduatesFromStep1() throws {
        // "Kolay", then "Kolay" on its due date: stability over 30 days from basamak 1.
        let first = scheduler.review(WordProgress(wordID: 1), grade: .easy, at: start)
        XCTAssertEqual(first.box, 1)
        let now = try XCTUnwrap(first.dueAt)
        let p = scheduler.review(first, grade: .easy, at: now)
        XCTAssertGreaterThanOrEqual(try XCTUnwrap(p.fsrs).stability, FSRSScheduler.knownStability)
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, Leitner.maxBox)
        XCTAssertEqual(p.dueAt, now.addingTimeInterval(16 * day))
    }

    func testHardInASameDayStepWaitsTwelveHours() throws {
        // Relearning: a known word forgotten, then "Zor" in its 10-minute step.
        let (known, _) = try graduated()
        let forgotAt = try XCTUnwrap(known.dueAt)
        let forgot = scheduler.review(known, grade: .again, at: forgotAt)
        XCTAssertEqual(forgot.fsrs?.phase, .relearning)
        let hardAt = try XCTUnwrap(forgot.dueAt)
        let relearning = scheduler.review(forgot, grade: .hard, at: hardAt)
        let state = try XCTUnwrap(relearning.fsrs)
        XCTAssertEqual(state.phase, .relearning, "FSRS itself would ask again in 15 minutes")
        XCTAssertEqual(state.step, 0)
        XCTAssertEqual(relearning.state, .learning)
        XCTAssertEqual(relearning.box, forgot.box)
        XCTAssertEqual(relearning.dueAt, hardAt.addingTimeInterval(FSRSScheduler.hardStepWait))

        // Learning: a new word forgotten, then "Zor" in its 10-minute step.
        let missed = scheduler.review(WordProgress(wordID: 2), grade: .again, at: start)
        let learning = scheduler.review(missed, grade: .hard, at: at(days: 0, minutes: 10))
        XCTAssertEqual(learning.fsrs?.phase, .learning)
        XCTAssertEqual(learning.box, 1)
        XCTAssertEqual(learning.dueAt, at(days: 0, minutes: 10).addingTimeInterval(12 * hour))
    }

    func testNonFiniteStabilityFallsBackToLeitner() {
        var p = WordProgress(wordID: 1)
        p.state = .learning
        p.box = 2
        p.reviews = 2
        p.dueAt = at(days: 2)
        p.lastReviewedAt = start
        p.lastGrade = .good
        p.fsrs = FSRSState(stability: .infinity, difficulty: 5, phase: .review, step: nil, lastReviewAt: start, reviews: 2, shelfBefore: 1)
        for grade in grades {
            XCTAssertEqual(scheduler.review(p, grade: grade, at: at(days: 2)), Leitner.review(p, grade: grade, at: at(days: 2)), "\(grade)")
        }
    }

    func testRightAnswerNeverLowersTheStep() throws {
        var p = WordProgress(wordID: 1)
        p.state = .learning
        p.box = 4
        p.reviews = 3
        p.dueAt = at(days: 1)
        p.lastReviewedAt = start
        p.lastGrade = .good
        p.fsrs = FSRSState(stability: 1, difficulty: 5, phase: .review, step: nil, lastReviewAt: start, reviews: 3, shelfBefore: 3)

        let after = scheduler.review(p, grade: .hard, at: at(days: 1))
        let stability = try XCTUnwrap(after.fsrs).stability
        XCTAssertLessThan(FSRSScheduler.box(forStability: stability), 4, "the memory alone would go down")
        XCTAssertEqual(after.box, 4)
        XCTAssertEqual(after.state, .learning)
        XCTAssertEqual(after.dueAt, at(days: 1 + Double(engine.scheduledDays(stability: stability))))
    }

    func testAgainNeverRaisesTheStep() throws {
        var p = WordProgress(wordID: 1)
        p.state = .learning
        p.box = 1
        p.reviews = 3
        p.dueAt = at(days: 100)
        p.lastReviewedAt = start
        p.lastGrade = .good
        p.fsrs = FSRSState(stability: 100, difficulty: 5, phase: .review, step: nil, lastReviewAt: start, reviews: 3, shelfBefore: 1)

        let after = scheduler.review(p, grade: .again, at: at(days: 300))
        let stability = try XCTUnwrap(after.fsrs).stability
        XCTAssertGreaterThan(FSRSScheduler.box(forStability: stability), 1, "the memory alone would go up")
        XCTAssertEqual(after.box, 1)
        XCTAssertEqual(after.state, .learning)
        XCTAssertEqual(after.lapses, 1)
        XCTAssertEqual(after.dueAt, at(days: 300, minutes: 10))
    }

    func testAgainOnAKnownWord() throws {
        let (known, now) = try graduated()
        let due = try XCTUnwrap(known.dueAt)
        XCTAssertGreaterThan(due, now)
        let after = scheduler.review(known, grade: .again, at: due)
        let state = try XCTUnwrap(after.fsrs)
        XCTAssertEqual(after.state, .learning)
        XCTAssertEqual(after.lapses, known.lapses + 1)
        XCTAssertNil(after.refresherStep)
        XCTAssertFalse(after.knownOverride)
        XCTAssertEqual(after.dueAt, due.addingTimeInterval(10 * minute))
        XCTAssertEqual(after.box, min(FSRSScheduler.box(forStability: state.stability), Leitner.maxBox))
        XCTAssertEqual(state.phase, .relearning)
        XCTAssertEqual(state.shelfBefore, ProgressSummary.Shelf.settled.rawValue)
    }

    // MARK: "Biliyorum"

    func testRightCheckOfANewWordMakesItKnown() throws {
        let claimed = Leitner.markKnown(WordProgress(wordID: 1), at: start)
        XCTAssertTrue(claimed.awaitsKnownCheck)
        let checkAt = at(days: 3)
        XCTAssertEqual(claimed.dueAt, checkAt)

        let after = scheduler.review(claimed, grade: .good, at: checkAt)
        let state = try XCTUnwrap(after.fsrs)
        XCTAssertEqual(after.state, .known)
        XCTAssertFalse(after.knownOverride)
        XCTAssertFalse(after.awaitsKnownCheck)
        XCTAssertGreaterThanOrEqual(state.stability, FSRSScheduler.knownStability)
        XCTAssertEqual(state.phase, .review)
        XCTAssertNil(state.step)
        XCTAssertEqual(state.reviews, 1)
        XCTAssertEqual(state.shelfBefore, ProgressSummary.Shelf.selfMarked.rawValue)
        let due = try XCTUnwrap(after.dueAt)
        XCTAssertEqual(due, checkAt.addingTimeInterval(Double(engine.scheduledDays(stability: state.stability)) * day))
        XCTAssertEqual(due.timeIntervalSince(checkAt), 30 * day, accuracy: day)
        XCTAssertEqual(ReviewLogEntry(before: claimed, after: after, source: .review)?.knownCheck, true)
    }

    func testWrongCheckSendsTheWordBackToIntro() throws {
        let claimed = Leitner.markKnown(WordProgress(wordID: 1), at: start)
        let after = scheduler.review(claimed, grade: .again, at: at(days: 3))
        XCTAssertEqual(after.state, .new)
        XCTAssertEqual(after.box, 0)
        XCTAssertNil(after.dueAt)
        XCTAssertTrue(after.returnsToIntro)
        XCTAssertFalse(after.knownOverride)
        XCTAssertNil(after.refresherStep)
        XCTAssertEqual(after.lapses, Leitner.review(claimed, grade: .again, at: at(days: 3)).lapses)
        let state = try XCTUnwrap(after.fsrs)
        XCTAssertEqual(state.reviews, 1)
        XCTAssertEqual(state.stability, engine.initialMemory(.again).stability)
    }

    func testRightCheckOfALearningWordMakesItKnown() throws {
        var p = scheduler.review(WordProgress(wordID: 1), grade: .good, at: start)
        p = scheduler.review(p, grade: .good, at: at(days: 2))
        let before = try XCTUnwrap(p.fsrs)
        let claimed = Leitner.markKnown(p, at: at(days: 3))
        XCTAssertEqual(claimed.fsrs, before)
        let checkAt = at(days: 6)
        XCTAssertEqual(claimed.dueAt, checkAt)

        let after = scheduler.review(claimed, grade: .good, at: checkAt)
        let state = try XCTUnwrap(after.fsrs)
        XCTAssertEqual(after.state, .known)
        XCTAssertFalse(after.knownOverride)
        XCTAssertGreaterThanOrEqual(state.stability, FSRSScheduler.knownStability)
        XCTAssertGreaterThanOrEqual(state.stability, engine.nextMemory(before.card.memory ?? engine.initialMemory(.good), elapsedDays: 4, grade: .good).stability)
        XCTAssertEqual(after.dueAt, checkAt.addingTimeInterval(Double(engine.scheduledDays(stability: state.stability)) * day))
    }

    // MARK: Memory

    func testStaleMemoryIsIgnored() throws {
        var p = scheduler.review(WordProgress(wordID: 1), grade: .good, at: start)
        p = scheduler.review(p, grade: .good, at: at(days: 2))
        let leitnerAt = try XCTUnwrap(p.dueAt)
        p = LeitnerScheduler().review(p, grade: .good, at: leitnerAt)
        let stale = try XCTUnwrap(p.fsrs)
        XCTAssertNotEqual(stale.reviews, p.reviews)

        let now = try XCTUnwrap(p.dueAt)
        let estimate = scheduler.estimatedCard(of: p, at: now)
        XCTAssertEqual(scheduler.card(of: p, at: now), estimate)
        XCTAssertEqual(estimate.memory?.stability, Leitner.intervalDays[p.box - 1])
        XCTAssertEqual(estimate.lastReviewAt, leitnerAt)
        XCTAssertNotEqual(estimate.memory?.stability, stale.stability)

        let after = scheduler.review(p, grade: .good, at: now)
        let expected = engine.review(estimate, grade: .good, at: now)
        let state = try XCTUnwrap(after.fsrs)
        XCTAssertEqual(state.stability, expected.memory?.stability)
        XCTAssertEqual(state.difficulty, expected.memory?.difficulty)
        XCTAssertEqual(after.dueAt, expected.dueAt)
        XCTAssertEqual(state.reviews, after.reviews)
    }

    func testEstimatedCardWithoutAMemory() {
        XCTAssertEqual(scheduler.estimatedCard(of: WordProgress(wordID: 1), at: start), FSRSCard())

        let claimedNew = Leitner.markKnown(WordProgress(wordID: 2), at: start)
        XCTAssertEqual(scheduler.estimatedCard(of: claimedNew, at: at(days: 3)), FSRSCard())

        var learning = WordProgress(wordID: 3)
        learning.state = .learning
        learning.box = 2
        learning.reviews = 2
        learning.lastReviewedAt = start
        learning.lastGrade = .good
        learning.dueAt = at(days: 2)
        let claimedLearning = Leitner.markKnown(learning, at: at(days: 1))
        XCTAssertEqual(scheduler.estimatedCard(of: claimedLearning, at: at(days: 4)), FSRSCard())

        let backToIntro = Leitner.review(claimedNew, grade: .again, at: at(days: 3))
        XCTAssertTrue(backToIntro.returnsToIntro)
        XCTAssertEqual(scheduler.estimatedCard(of: backToIntro, at: at(days: 4)), FSRSCard())
    }

    func testEstimatedCardOfAKnownWordUsesItsRefresherWait() {
        var p = WordProgress(wordID: 1)
        p.state = .known
        p.box = 5
        p.reviews = 8
        p.refresherStep = 2
        p.lastReviewedAt = start
        p.lastGrade = .good
        p.dueAt = at(days: 120)
        let card = scheduler.estimatedCard(of: p, at: at(days: 120))
        XCTAssertEqual(card.memory?.stability, 120)
        XCTAssertEqual(card.phase, .review)
        XCTAssertEqual(card.lastReviewAt, start)
    }

    func testInvalidWeightsFallBackToDefaults() {
        XCTAssertEqual(FSRSScheduler(weights: [1, 2, 3]).fsrs.weights, FSRS.defaultWeights)
        var personal = FSRS.defaultWeights
        personal[0] = 0.5
        XCTAssertEqual(FSRSScheduler(weights: personal).fsrs.weights, personal)
        XCTAssertEqual(FSRSScheduler().fsrs.learningSteps, [600])
        XCTAssertEqual(FSRSScheduler().fsrs.maximumIntervalDays, FSRSScheduler.maximumIntervalDays)
    }

    func testReplayMatchesLiveAnswers() throws {
        var log: [ReviewLogEntry] = []

        var a = WordProgress(wordID: 1)
        answer(&a, .good, at: start, with: scheduler, into: &log)
        answer(&a, .good, at: at(days: 2), with: scheduler, into: &log)
        for grade in [ReviewGrade.again, .good, .hard] {
            let due = try XCTUnwrap(a.dueAt)
            answer(&a, grade, at: due, with: scheduler, into: &log)
        }

        var b = Leitner.markKnown(WordProgress(wordID: 2), at: start)
        answer(&b, .good, at: at(days: 3), with: scheduler, into: &log)
        let bDue = try XCTUnwrap(b.dueAt)
        answer(&b, .good, at: bDue, with: scheduler, into: &log)

        var c = WordProgress(wordID: 3)
        answer(&c, .easy, at: at(days: 0, minutes: 5), with: scheduler, into: &log)
        c = Leitner.markKnown(c, at: at(days: 1))
        answer(&c, .good, at: at(days: 4), with: scheduler, into: &log)

        XCTAssertEqual(log.filter { $0.knownCheck == true }.count, 2)

        let replay = scheduler.replay(log)
        XCTAssertTrue(replay.incomplete.isEmpty)
        for p in [a, b, c] {
            let live = try XCTUnwrap(p.fsrs).card
            let replayed = try XCTUnwrap(replay.cards[p.wordID])
            let label = "word \(p.wordID)"
            XCTAssertEqual(replayed.memory, live.memory, label)
            XCTAssertEqual(replayed.phase, live.phase, label)
            XCTAssertEqual(replayed.step, live.step, label)
            XCTAssertEqual(replayed.lastReviewAt, live.lastReviewAt, label)
            XCTAssertEqual(replay.reviews[p.wordID], p.reviews, label)
        }
        XCTAssertEqual(b.state, .known)
        XCTAssertEqual(c.state, .known)
    }

    func testWaitNeverPassesAYear() throws {
        var now = start
        var p = scheduler.review(WordProgress(wordID: 1), grade: .easy, at: now)
        var wait: TimeInterval = 0
        for _ in 0..<15 {
            now = try XCTUnwrap(p.dueAt)
            p = scheduler.review(p, grade: .easy, at: now)
            wait = try XCTUnwrap(p.dueAt).timeIntervalSince(now)
            XCTAssertLessThanOrEqual(wait, Double(FSRSScheduler.maximumIntervalDays) * day)
            if p.state == .learning {
                XCTAssertLessThanOrEqual(wait, FSRSScheduler.unprovenMaximumWait)
            }
        }
        XCTAssertEqual(wait, 365 * day)
        XCTAssertEqual(p.state, .known)
    }

    // MARK: Coding

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    /// A learning word's record as `progress.json` holds it, with `fsrs` as given (raw JSON).
    private func record(fsrs: String?) -> Data {
        var json = """
        {"word_id": 7, "state": "learning", "box": 3, "due_at": 1700100000, "exposures": 2, \
        "last_seen_at": 1700000000, "reviews": 4, "lapses": 1, "known_override": false, "saved": true, \
        "last_reviewed_at": 1700000000, "last_grade": "good"
        """
        if let fsrs = fsrs {
            json += ", \"fsrs\": " + fsrs
        }
        json += "}"
        return Data(json.utf8)
    }

    private func memoryJSON(stability: String = "10.5", difficulty: String = "4.25", phase: String = "review") -> String {
        return """
        {"stability": \(stability), "difficulty": \(difficulty), "phase": "\(phase)", \
        "last_review_at": 1700000000, "reviews": 4, "shelf_before": 2}
        """
    }

    private func assertRestLoads(_ p: WordProgress, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(p.wordID, 7, file: file, line: line)
        XCTAssertEqual(p.state, .learning, file: file, line: line)
        XCTAssertEqual(p.box, 3, file: file, line: line)
        XCTAssertEqual(p.dueAt, Date(timeIntervalSince1970: 1_700_100_000), file: file, line: line)
        XCTAssertEqual(p.reviews, 4, file: file, line: line)
        XCTAssertEqual(p.lapses, 1, file: file, line: line)
        XCTAssertTrue(p.saved, file: file, line: line)
        XCTAssertEqual(p.lastReviewedAt, start, file: file, line: line)
        XCTAssertEqual(p.lastGrade, .good, file: file, line: line)
    }

    func testRecordWithoutMemoryLoads() throws {
        let p = try makeDecoder().decode(WordProgress.self, from: record(fsrs: nil))
        XCTAssertNil(p.fsrs)
        assertRestLoads(p)
    }

    func testNoMemoryIsLeftOut() throws {
        let data = try makeEncoder().encode(WordProgress(wordID: 1))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertNil(object["fsrs"])
        XCTAssertNotNil(object["word_id"])
    }

    func testMemoryRoundTrip() throws {
        var p = WordProgress(wordID: 1)
        p.state = .learning
        p.box = 2
        p.reviews = 3
        p.lastReviewedAt = start
        p.lastGrade = .hard
        p.fsrs = FSRSState(stability: 10.5, difficulty: 4.25, phase: .relearning, step: 0, lastReviewAt: start, reviews: 3, shelfBefore: 2)
        let data = try makeEncoder().encode(p)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertNotNil(object["fsrs"])
        let back = try makeDecoder().decode(WordProgress.self, from: data)
        XCTAssertEqual(back, p)
        XCTAssertEqual(back.fsrs, p.fsrs)

        let read = try makeDecoder().decode(WordProgress.self, from: record(fsrs: memoryJSON()))
        XCTAssertEqual(
            read.fsrs,
            FSRSState(stability: 10.5, difficulty: 4.25, phase: .review, step: nil, lastReviewAt: start, reviews: 4, shelfBefore: 2)
        )
    }

    func testUnusableMemoryDropsOnlyTheMemory() throws {
        let broken = [
            memoryJSON(stability: "-1"),
            memoryJSON(stability: "0"),
            memoryJSON(difficulty: "11"),
            memoryJSON(difficulty: "0.5"),
            memoryJSON(phase: "frozen"),
            "\"not a memory\"",
        ]
        for fsrs in broken {
            let p = try makeDecoder().decode(WordProgress.self, from: record(fsrs: fsrs))
            XCTAssertNil(p.fsrs, fsrs)
            assertRestLoads(p)
        }
    }
}
