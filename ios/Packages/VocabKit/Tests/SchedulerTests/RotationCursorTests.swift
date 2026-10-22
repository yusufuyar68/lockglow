import XCTest
import CoreModels
import SharedState
import Scheduler

/// Edge cases of the "Next" / "Know" cursor (`cursorAfterNext`, `cursorAfterKnow`) and of
/// `RotationInput.resolve`: empty queues, taps on words that are not in the queue, taps on the
/// boundary second. Expected values are worked out by hand in the comments.
final class RotationCursorTests: XCTestCase {
    // 2023-11-14 22:00:00 UTC, an hourly boundary (1_699_999_200 = 472_222 * 3600).
    private let t0 = Date(timeIntervalSince1970: 1_699_999_200)
    private let hour: TimeInterval = 3600

    private func makeWords(_ ids: [Int]) -> [WidgetWord] {
        return ids.map { id in
            WidgetWord(
                id: id,
                lemma: "word\(id)",
                pos: "n",
                level: "A1",
                defMicro: "micro",
                defShort: "short",
                exampleEN: "example"
            )
        }
    }

    private func makeInput(
        queueIDs: [Int],
        known: Set<Int> = [],
        cursor: Int = 0,
        anchor: Date? = nil
    ) -> RotationInput {
        return RotationInput(
            planID: "p",
            queue: makeWords(queueIDs),
            knownIDs: known,
            cursorOffset: cursor,
            cursorAnchor: anchor ?? t0,
            interval: hour,
            isSeed: false
        )
    }

    /// The input the widget uses after writing `cursor` to `widget_state.json`.
    private func inputAfter(_ cursor: RotationCursor, _ input: RotationInput, known: Set<Int>? = nil) -> RotationInput {
        return RotationInput(
            planID: input.planID,
            queue: input.queue,
            knownIDs: known ?? input.knownIDs,
            cursorOffset: cursor.offset,
            cursorAnchor: cursor.anchor,
            interval: input.interval,
            isSeed: input.isSeed
        )
    }

    private func shownID(at date: Date, _ input: RotationInput, offset: TimeInterval = 0) -> Int? {
        return TimelinePlanner.wordAt(
            date,
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            interval: input.interval,
            alignmentOffset: offset
        )?.id
    }

    // MARK: Empty queue

    func testEmptyQueueKeepsTheOffsetAndOnlyMovesTheAnchor() {
        let input = makeInput(queueIDs: [], cursor: 5)
        let now = t0.addingTimeInterval(10.7)
        // Nothing to move through: offset stays 5, the anchor is the tap time rounded down (t0 + 10).
        let next = TimelinePlanner.cursorAfterNext(shownWordID: 1, input: input, now: now)
        XCTAssertEqual(next, RotationCursor(offset: 5, anchor: t0.addingTimeInterval(10)))
        let know = TimelinePlanner.cursorAfterKnow(shownWordID: 1, input: input, now: now)
        XCTAssertEqual(know, RotationCursor(offset: 5, anchor: t0.addingTimeInterval(10)))
    }

    func testNoPlanAndNoSeedWordsGiveAnEmptyRotation() {
        // Widget without a plan whose bundled seed file could not be read.
        let input = RotationInput.resolve(plan: nil, state: nil, seedWords: [])
        XCTAssertTrue(input.isSeed)
        XCTAssertTrue(input.queue.isEmpty)
        XCTAssertNil(shownID(at: t0, input))
        let entries = TimelinePlanner.plan(
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            now: t0,
            interval: input.interval
        )
        XCTAssertTrue(entries.isEmpty)
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 0, input: input, now: t0).offset, 0)

        // A plan with an empty queue falls back to the (here also empty) seed words.
        let emptyPlan = WidgetPlan(planID: "p", isPremium: false, intervalSeconds: 600, queue: [], updatedAt: t0)
        let fromEmptyPlan = RotationInput.resolve(plan: emptyPlan, state: nil, seedWords: [])
        XCTAssertTrue(fromEmptyPlan.isSeed)
        XCTAssertEqual(fromEmptyPlan.interval, 3600) // the seed interval, not the plan's 600
    }

    // MARK: Taps on words that are not in the queue

    func testTapOnAnUnknownWordWhenEveryQueueWordIsKnownFallsBackToTheStoredOffset() {
        // Nothing is shown (every word known), and the tapped id 99 is not in the queue:
        // `tappedIndex` is nil, so the stored offset 1 is used. Next: (1 + 1) mod 3 = 2. Know: 1.
        let input = makeInput(queueIDs: [1, 2, 3], known: [1, 2, 3], cursor: 1)
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 99, input: input, now: t0).offset, 2)
        XCTAssertEqual(TimelinePlanner.cursorAfterKnow(shownWordID: 99, input: input, now: t0).offset, 1)

        // Stored offset -1 (any integer is allowed): Next (-1 + 1) mod 3 = 0, Know -1 mod 3 = 2.
        let negative = makeInput(queueIDs: [1, 2, 3], known: [1, 2, 3], cursor: -1)
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 99, input: negative, now: t0).offset, 0)
        XCTAssertEqual(TimelinePlanner.cursorAfterKnow(shownWordID: 99, input: negative, now: t0).offset, 2)
    }

    /// A damaged `widget_state.json` can hold any `cursor_offset`. In the fallback above, Next used
    /// to compute `Int.max + 1` and trap; the offset is now wrapped before the step.
    func testFallbackWithAnExtremeStoredOffsetDoesNotOverflow() {
        // Int.max mod 3 = 1 (2^63 mod 3 = 2): Next (1 + 1) mod 3 = 2, Know 1.
        let maxInput = makeInput(queueIDs: [1, 2, 3], known: [1, 2, 3], cursor: Int.max)
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 99, input: maxInput, now: t0).offset, 2)
        XCTAssertEqual(TimelinePlanner.cursorAfterKnow(shownWordID: 99, input: maxInput, now: t0).offset, 1)
        // Int.min % 3 = -2, positive modulo 1: Next 2, Know 1.
        let minInput = makeInput(queueIDs: [1, 2, 3], known: [1, 2, 3], cursor: Int.min)
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 99, input: minInput, now: t0).offset, 2)
        XCTAssertEqual(TimelinePlanner.cursorAfterKnow(shownWordID: 99, input: minInput, now: t0).offset, 1)
        // One-word queue: every step stays on index 0.
        let single = makeInput(queueIDs: [1], known: [1], cursor: Int.max)
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 99, input: single, now: t0).offset, 0)
        XCTAssertEqual(TimelinePlanner.cursorAfterKnow(shownWordID: 99, input: single, now: t0).offset, 0)
    }

    func testFallbackUsesTheSameAlignmentOffsetAsTheTimeline() {
        let input = makeInput(queueIDs: Array(1...10))
        // Tap at 22:30:05 UTC on a word that is not in the queue.
        let tap = t0.addingTimeInterval(1805)
        // UTC: anchor and tap are both in index 472_222 -> elapsed 0 -> word 1 (index 0) is shown.
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 99, input: input, now: tap).offset, 1)
        // India (+19_800): anchor floor(1_700_019_000 / 3600) = 472_227 (472_227.5),
        // tap floor(1_700_020_805 / 3600) = 472_228 -> elapsed 1 -> word 2 (index 1) is shown.
        XCTAssertEqual(
            TimelinePlanner.cursorAfterNext(shownWordID: 99, input: input, now: tap, alignmentOffset: 19_800).offset,
            2
        )
        XCTAssertEqual(
            TimelinePlanner.cursorAfterKnow(shownWordID: 99, input: input, now: tap, alignmentOffset: 19_800).offset,
            1
        )
    }

    func testTheTappedWordWinsOverTheWordTheTimeShows() {
        // At t0 + 3.5 h the rotation shows word 4, but a stale widget still showed word 2 and the
        // user tapped that one. The cursor follows the tapped word: Next -> index of 2 (1) + 1 = 2.
        let input = makeInput(queueIDs: Array(1...10), anchor: t0)
        let tap = t0.addingTimeInterval(3.5 * hour)
        XCTAssertEqual(shownID(at: tap, input), 4)
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 2, input: input, now: tap).offset, 2)
        XCTAssertEqual(TimelinePlanner.cursorAfterKnow(shownWordID: 2, input: input, now: tap).offset, 1)
    }

    // MARK: Know on the last word

    func testKnowOnTheLastWordWrapsToTheFirstUnknownWord() {
        let input = makeInput(queueIDs: [1, 2, 3, 4, 5])
        let cursor = TimelinePlanner.cursorAfterKnow(shownWordID: 5, input: input, now: t0)
        XCTAssertEqual(cursor.offset, 4)
        // Lap from index 4: ids 5 (now known), 1, 2, 3, 4 -> R = [1, 2, 3, 4]. R[0] = 1.
        let after = inputAfter(cursor, input, known: [5])
        XCTAssertEqual(shownID(at: t0, after), 1)
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(4 * hour), after), 1) // one full lap of 4
    }

    // MARK: Taps on and next to the boundary second

    func testNextOneSecondBeforeABoundaryShowsTheNextWordForOneSecond() {
        // Anchor 21:30 (index 472_221). At 21:59:59 (still 472_221) word 1 is shown.
        let input = makeInput(queueIDs: Array(1...10), anchor: t0.addingTimeInterval(-1800))
        let tap = t0.addingTimeInterval(-1)
        XCTAssertEqual(shownID(at: tap, input), 1)

        let cursor = TimelinePlanner.cursorAfterNext(shownWordID: 1, input: input, now: tap)
        XCTAssertEqual(cursor, RotationCursor(offset: 1, anchor: tap))
        let after = inputAfter(cursor, input)
        // "The following change happens at the next interval boundary", even when that is
        // one second later: word 2 at 21:59:59, word 3 from 22:00:00.
        XCTAssertEqual(shownID(at: tap, after), 2)
        XCTAssertEqual(shownID(at: t0, after), 3)
    }

    func testNextExactlyOnTheBoundaryShowsTheNextWordForAFullInterval() {
        let input = makeInput(queueIDs: Array(1...10), anchor: t0.addingTimeInterval(-1800))
        // At 22:00:00 (index 472_222, elapsed 1) word 2 is shown.
        XCTAssertEqual(shownID(at: t0, input), 2)
        let cursor = TimelinePlanner.cursorAfterNext(shownWordID: 2, input: input, now: t0)
        XCTAssertEqual(cursor, RotationCursor(offset: 2, anchor: t0))
        let after = inputAfter(cursor, input)
        // The anchor is the boundary itself: word 3 until 22:59:59, word 4 from 23:00:00.
        XCTAssertEqual(shownID(at: t0, after), 3)
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(hour - 1), after), 3)
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(hour), after), 4)
    }

    // MARK: Range

    func testCursorOffsetIsAlwaysAQueueIndex() {
        let ids = Array(1...7)
        for stored in -20...20 {
            let input = makeInput(queueIDs: ids, known: [3, 5], cursor: stored)
            for tapped in ids + [0, 99] {
                for minutes in [0, 59, 61, 600] {
                    let now = t0.addingTimeInterval(TimeInterval(minutes * 60))
                    let next = TimelinePlanner.cursorAfterNext(shownWordID: tapped, input: input, now: now)
                    let know = TimelinePlanner.cursorAfterKnow(shownWordID: tapped, input: input, now: now)
                    XCTAssertTrue((0..<7).contains(next.offset), "next: stored \(stored), tapped \(tapped)")
                    XCTAssertTrue((0..<7).contains(know.offset), "know: stored \(stored), tapped \(tapped)")
                }
            }
        }
    }

    // MARK: resolve()

    func testResolveKeepsAnOutOfRangeStoredOffsetAndThePlannerWrapsIt() {
        let plan = WidgetPlan(planID: "p", isPremium: false, intervalSeconds: 3600, queue: makeWords([1, 2, 3]), updatedAt: t0)
        let state = WidgetState(planID: "p", cursorOffset: 7, cursorAnchor: t0, knownIDs: [], updatedAt: t0)
        let input = RotationInput.resolve(plan: plan, state: state, seedWords: [])
        XCTAssertEqual(input.cursorOffset, 7)
        // 7 mod 3 = 1 -> R starts at word 2.
        XCTAssertEqual(shownID(at: t0, input), 2)
    }

    func testResolveTakesTheIntervalUnclampedFromThePlan() {
        let plan = WidgetPlan(planID: "p", isPremium: false, intervalSeconds: 60, queue: makeWords([1, 2, 3]), updatedAt: t0)
        let input = RotationInput.resolve(plan: plan, state: nil, seedWords: [])
        XCTAssertEqual(input.interval, 60)
        // The planner clamps 60 s to 300 s: t0 + 299 is still word 1, t0 + 300 is word 2.
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(299), input), 1)
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(300), input), 2)
    }
}
