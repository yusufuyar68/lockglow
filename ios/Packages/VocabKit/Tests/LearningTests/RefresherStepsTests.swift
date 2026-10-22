import XCTest
import CoreModels
import Learning

/// A known word's refresher wait grows with each correct refresher: 30 → 60 → 120 days, then 120
/// (docs/tasarim/ogrenme_ilkeleri.md 2.3, until FSRS).
final class RefresherStepsTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400

    /// Graduated at `now`: six "Bildim" answers, each on its due day, the last at `now`.
    private func graduated(_ id: Int = 1) -> WordProgress {
        var p = WordProgress(wordID: id)
        var at = now.addingTimeInterval(-31 * day)
        for _ in 0..<6 {
            p = Leitner.review(p, grade: .good, at: at)
            at = p.dueAt ?? at
        }
        XCTAssertEqual(p.state, .known)
        XCTAssertEqual(p.lastReviewedAt, now)
        return p
    }

    /// `count` correct refreshers, each on its due date, from a word graduated at `now`.
    private func refreshed(_ count: Int, grade: ReviewGrade = .good) -> WordProgress {
        var p = graduated()
        for _ in 0..<count {
            p = Leitner.review(p, grade: grade, at: p.dueAt ?? now)
        }
        return p
    }

    private func wait(_ p: WordProgress) -> TimeInterval? {
        guard let due = p.dueAt, let at = p.lastReviewedAt else {
            return nil
        }
        return due.timeIntervalSince(at)
    }

    private func card(_ id: Int) -> WidgetWord {
        return WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")
    }

    func testTheWaitsAreThirtySixtyOneHundredTwenty() {
        XCTAssertEqual(Leitner.refresherDays, [30, 60, 120])
        XCTAssertEqual(Leitner.refresherDelay, 30 * day, "the first wait, as before")
        XCTAssertEqual(Leitner.refresherWait(step: 0), 30 * day)
        XCTAssertEqual(Leitner.refresherWait(step: 2), 120 * day)
        XCTAssertEqual(Leitner.refresherWait(step: 9), 120 * day, "past the last step: the last")
        XCTAssertEqual(Leitner.refresherWait(step: -1), 30 * day)
    }

    func testEachCorrectRefresherWaitsLonger() {
        let start = graduated()
        XCTAssertNil(start.refresherStep)
        XCTAssertEqual(wait(start), 30 * day)

        let waits = (1...4).map { wait(refreshed($0)) }
        XCTAssertEqual(waits, [60 * day, 120 * day, 120 * day, 120 * day])
        XCTAssertEqual((1...4).map { refreshed($0).refresherStep }, [1, 2, 2, 2])
        // "Kolay" on a refresher is "Bildim": one step.
        XCTAssertEqual(refreshed(1, grade: .easy).refresherStep, 1)
        XCTAssertEqual(refreshed(1, grade: .easy).state, .known)
    }

    func testZorKeepsTheStepAndHalvesItsWait() {
        let atTwo = refreshed(2)
        let hardAtTwo = Leitner.review(atTwo, grade: .hard, at: atTwo.dueAt ?? now)
        XCTAssertEqual(hardAtTwo.state, .known)
        XCTAssertEqual(hardAtTwo.refresherStep, 2)
        XCTAssertEqual(wait(hardAtTwo), 60 * day)

        let atOne = refreshed(1)
        let hardAtOne = Leitner.review(atOne, grade: .hard, at: atOne.dueAt ?? now)
        XCTAssertEqual(hardAtOne.refresherStep, 1)
        XCTAssertEqual(wait(hardAtOne), 30 * day)
        // The next "Bildim" moves on from there.
        let next = Leitner.review(hardAtOne, grade: .good, at: hardAtOne.dueAt ?? now)
        XCTAssertEqual(next.refresherStep, 2)
        XCTAssertEqual(wait(next), 120 * day)

        // On a word that just graduated: 15 days, as before.
        let fresh = graduated()
        XCTAssertEqual(wait(Leitner.review(fresh, grade: .hard, at: fresh.dueAt ?? now)), 15 * day)
    }

    func testAWrongRefresherStartsTheClimbAgain() {
        let atTwo = refreshed(2)
        var p = Leitner.review(atTwo, grade: .again, at: atTwo.dueAt ?? now)
        XCTAssertEqual(p.state, .learning)
        XCTAssertEqual(p.box, Leitner.refresherLapseBox)
        XCTAssertNil(p.refresherStep)
        // Boxes 3 → 4 → 5 → known: the refresher starts at 30 days again.
        for _ in 0..<3 {
            p = Leitner.review(p, grade: .good, at: p.dueAt ?? now)
        }
        XCTAssertEqual(p.state, .known)
        XCTAssertNil(p.refresherStep)
        XCTAssertEqual(wait(p), 30 * day)
    }

    func testTheBiliyorumCheckLeadsToThirtyDays() {
        let claimed = Leitner.markKnown(WordProgress(wordID: 1), at: now)
        let check = now.addingTimeInterval(Leitner.knownCheckDelay)
        let passed = Leitner.review(claimed, grade: .good, at: check)
        XCTAssertEqual(passed.state, .known)
        XCTAssertNil(passed.refresherStep)
        XCTAssertEqual(wait(passed), 30 * day)
        let refresher = Leitner.review(passed, grade: .good, at: passed.dueAt ?? now)
        XCTAssertEqual(wait(refresher), 60 * day)
    }

    func testBiliyorumOnARefresherKeepsItsStep() throws {
        // A refresher shows on the widget and "Biliyorum" is tapped there: a check in 3 days.
        // Passing it keeps the step the word had reached; it does not start over at 30 days.
        let atTwo = refreshed(2)
        let tap = (atTwo.dueAt ?? now).addingTimeInterval(-10 * hour)
        let claimed = try XCTUnwrap(ProgressIngest.apply([LearningEvent(type: .known, wordID: 1, at: tap)], to: [1: atTwo])[1])
        XCTAssertTrue(claimed.awaitsKnownCheck)
        XCTAssertEqual(claimed.refresherStep, 2)
        XCTAssertEqual(claimed.dueAt, tap.addingTimeInterval(Leitner.knownCheckDelay))

        let check = tap.addingTimeInterval(Leitner.knownCheckDelay)
        let passed = Leitner.review(claimed, grade: .good, at: check)
        XCTAssertFalse(passed.awaitsKnownCheck)
        XCTAssertEqual(passed.refresherStep, 2)
        XCTAssertEqual(wait(passed), 120 * day)
        XCTAssertEqual(wait(Leitner.review(claimed, grade: .hard, at: check)), 60 * day)

        let failed = Leitner.review(claimed, grade: .again, at: check)
        XCTAssertTrue(failed.returnsToIntro)
        XCTAssertNil(failed.refresherStep)
    }

    func testOpeningAKnownWordForLearningForgetsTheStep() {
        let p = Leitner.undoKnown(refreshed(2), at: now)
        XCTAssertEqual(p.state, .learning)
        XCTAssertNil(p.refresherStep)
    }

    func testAKnownWordFromAnEarlierBuildGoesOnToSixtyDays() {
        // Graduated under the fixed 30 days: no step on record.
        var old = graduated()
        old.lastReviewedAt = nil
        old.lastGrade = nil
        old.firstReviewedAt = nil
        let p = Leitner.review(old, grade: .good, at: old.dueAt ?? now)
        XCTAssertEqual(p.refresherStep, 1)
        XCTAssertEqual(wait(p), 60 * day)
    }

    func testStepsOutOfRangeAreClamped() {
        var high = graduated()
        high.refresherStep = 7
        let fromHigh = Leitner.review(high, grade: .good, at: high.dueAt ?? now)
        XCTAssertEqual(fromHigh.refresherStep, 2)
        XCTAssertEqual(wait(fromHigh), 120 * day)

        var low = graduated()
        low.refresherStep = -3
        let fromLow = Leitner.review(low, grade: .good, at: low.dueAt ?? now)
        XCTAssertEqual(fromLow.refresherStep, 1)
        XCTAssertEqual(wait(fromLow), 60 * day)
    }

    func testThePlannersFollowTheLongerWait() throws {
        let p = refreshed(2)
        let answered = try XCTUnwrap(p.lastReviewedAt)
        let feed = [card(1), card(2)]
        // "Tekrar" asks it 120 days after the last refresher, not 30.
        XCTAssertTrue(ReviewPlanner.dueWords(feed: feed, progress: [1: p], now: answered.addingTimeInterval(119 * day), limit: 5).isEmpty)
        XCTAssertEqual(ReviewPlanner.dueWords(feed: feed, progress: [1: p], now: answered.addingTimeInterval(120 * day), limit: 5).map { $0.id }, [1])

        // The widget offers it in the refresher slot when its date comes near (past the 6 h
        // window), like any refresher.
        let widgetTime = answered.addingTimeInterval(120 * day - 12 * hour)
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let queue = QueueComposer.compose(feed: feed, progress: [1: p, 2: graduated(2)], now: widgetTime, horizon: 2 * day, maxNew: 0, limit: 5, calendar: utc)
        XCTAssertEqual(queue.map { $0.id }, [1])

        // "İlerleme" reads the longer waits back, even without the answer time on record.
        var earlier = p
        earlier.lastReviewedAt = nil
        earlier.lastGrade = nil
        XCTAssertEqual(ProgressSummary.lastAnswer(of: earlier)?.kind, .recalledOnTop)
        XCTAssertEqual(ProgressSummary.lastAnswer(of: earlier)?.date, answered)
    }
}
