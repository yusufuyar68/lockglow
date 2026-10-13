import XCTest
import CoreModels
import SharedState
import Scheduler

/// The rotation must be continuous: reloading a timeline, tapping a button or rewriting the
/// plan never restarts the queue; only time (interval boundaries) moves it on.
final class RotationContinuityTests: XCTestCase {
    // 2023-11-14 22:10:00 UTC, ten minutes after an hourly boundary. Boundaries after it:
    // 23:00, 00:00, 01:00 ... so 3.5 hours later (01:40) exactly three boundaries were crossed.
    private let t0 = Date(timeIntervalSince1970: 1_699_999_800)
    private let hour: TimeInterval = 3600
    private let offsets: [TimeInterval] = [0, 10_800, 19_800, -18_000]

    // MARK: Helpers

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

    private func makePlan(
        queue: [WidgetWord],
        planID: String = "plan",
        updatedAt: Date,
        interval: Int = 3600
    ) -> WidgetPlan {
        return WidgetPlan(
            planID: planID,
            isPremium: false,
            intervalSeconds: interval,
            queue: queue,
            updatedAt: updatedAt
        )
    }

    private func shownID(at date: Date, _ input: RotationInput, offset: TimeInterval = 0) -> Int? {
        let word = TimelinePlanner.wordAt(
            date,
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            interval: input.interval,
            alignmentOffset: offset
        )
        return word?.id
    }

    private func timeline(
        _ input: RotationInput,
        now: Date,
        offset: TimeInterval = 0
    ) -> [TimelinePlanner.PlannedEntry] {
        return TimelinePlanner.plan(
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            now: now,
            interval: input.interval,
            alignmentOffset: offset
        )
    }

    /// The state the widget writes after a tap.
    private func stateAfter(
        _ cursor: RotationCursor,
        input: RotationInput,
        known: Set<Int>,
        at date: Date
    ) -> WidgetState {
        return WidgetState(
            planID: input.planID,
            cursorOffset: cursor.offset,
            cursorAnchor: cursor.anchor,
            knownIDs: known.sorted(),
            updatedAt: date
        )
    }

    private func hourlyInput(queueIDs: [Int] = Array(1...10)) -> (plan: WidgetPlan, input: RotationInput) {
        let plan = makePlan(queue: makeWords(queueIDs), updatedAt: t0)
        let input = RotationInput.resolve(plan: plan, state: nil, seedWords: [])
        return (plan, input)
    }

    // MARK: 1. Time moves the rotation; regenerating a timeline does not restart it

    func testWordAtAdvancesWithTimeAndARegeneratedTimelineContinues() {
        let setup = hourlyInput()
        let input = setup.input
        XCTAssertEqual(input.cursorOffset, 0)
        XCTAssertEqual(input.cursorAnchor, t0)

        XCTAssertEqual(shownID(at: t0, input), 1)
        let later = t0.addingTimeInterval(3.5 * hour)
        XCTAssertEqual(shownID(at: later, input), 4) // R[3]

        // The widget reloads at `later` (backgrounding, .atEnd, ...): no restart at word 1.
        let regenerated = timeline(input, now: later)
        XCTAssertEqual(regenerated[0].word.id, 4)
        XCTAssertEqual(regenerated[1].word.id, 5)

        // The timeline written at t0 already contained the same word for that moment.
        let original = timeline(input, now: t0)
        let originalEntry = original.last(where: { $0.date <= later })
        XCTAssertEqual(originalEntry?.word.id, 4)
    }

    func testEveryTimelineEntryMatchesWordAtForItsDate() {
        let input = hourlyInput().input
        for offset in offsets {
            let entries = timeline(input, now: t0.addingTimeInterval(1234), offset: offset)
            XCTAssertFalse(entries.isEmpty)
            for entry in entries {
                XCTAssertEqual(entry.word.id, shownID(at: entry.date, input, offset: offset), "offset \(offset)")
            }
        }
    }

    func testAllInstancesShowTheSameWordAtTheSameTime() {
        // Home and Lock Screen widgets run the same pure function on the same files.
        let input = hourlyInput().input
        let moment = t0.addingTimeInterval(2 * hour + 5)
        let home = timeline(input, now: moment)[0].word.id
        let lock = timeline(input, now: moment)[0].word.id
        XCTAssertEqual(home, lock)
        XCTAssertEqual(shownID(at: moment, input), home)
    }

    // MARK: 2. Next

    func testNextShowsTheFollowingWordThenAdvancesAtTheNextBoundary() {
        let setup = hourlyInput()
        let tapTime = t0.addingTimeInterval(3.5 * hour) // 01:40:00
        XCTAssertEqual(shownID(at: tapTime, setup.input), 4)

        let cursor = TimelinePlanner.cursorAfterNext(shownWordID: 4, input: setup.input, now: tapTime)
        XCTAssertEqual(cursor.offset, 4) // queue index of word 4 is 3
        XCTAssertEqual(cursor.anchor, tapTime)

        let state = stateAfter(cursor, input: setup.input, known: [], at: tapTime)
        let after = RotationInput.resolve(plan: setup.plan, state: state, seedWords: [])

        let entries = timeline(after, now: tapTime)
        XCTAssertEqual(entries[0].word.id, 5)
        XCTAssertEqual(entries[1].word.id, 6)
        XCTAssertEqual(entries[1].date.timeIntervalSince(tapTime), 20 * 60, accuracy: 0.001) // 02:00

        XCTAssertEqual(shownID(at: tapTime.addingTimeInterval(5), after), 5)
        XCTAssertEqual(shownID(at: tapTime.addingTimeInterval(20 * 60), after), 6)
        XCTAssertEqual(shownID(at: tapTime.addingTimeInterval(80 * 60), after), 7)
    }

    func testNextOnTheLastWordWrapsToTheFirst() {
        let input = hourlyInput().input
        let cursor = TimelinePlanner.cursorAfterNext(shownWordID: 10, input: input, now: t0)
        XCTAssertEqual(cursor.offset, 0)
    }

    func testTapOnAWordThatIsNotInTheQueueUsesTheWordShownNow() {
        let input = hourlyInput().input
        let tapTime = t0.addingTimeInterval(3.5 * hour) // word 4 is on screen
        XCTAssertEqual(TimelinePlanner.cursorAfterNext(shownWordID: 999, input: input, now: tapTime).offset, 4)
        XCTAssertEqual(TimelinePlanner.cursorAfterKnow(shownWordID: 999, input: input, now: tapTime).offset, 3)
    }

    func testTapAnchorIsRoundedDownToAWholeSecond() {
        let input = hourlyInput().input
        let tapTime = t0.addingTimeInterval(3.5 * hour + 0.75)
        let cursor = TimelinePlanner.cursorAfterNext(shownWordID: 4, input: input, now: tapTime)
        XCTAssertEqual(cursor.anchor, t0.addingTimeInterval(3.5 * hour))
    }

    // MARK: 3. Know

    func testKnowSkipsTheWordAndKeepsTheOrder() {
        let setup = hourlyInput()
        let tapTime = t0.addingTimeInterval(3.5 * hour)
        XCTAssertEqual(shownID(at: tapTime, setup.input), 4)

        let cursor = TimelinePlanner.cursorAfterKnow(shownWordID: 4, input: setup.input, now: tapTime)
        XCTAssertEqual(cursor.offset, 3)
        XCTAssertEqual(cursor.anchor, tapTime)

        let state = stateAfter(cursor, input: setup.input, known: [4], at: tapTime)
        let after = RotationInput.resolve(plan: setup.plan, state: state, seedWords: [])
        XCTAssertEqual(after.knownIDs, [4])

        let entries = timeline(after, now: tapTime)
        XCTAssertEqual(entries.prefix(10).map { $0.word.id }, [5, 6, 7, 8, 9, 10, 1, 2, 3, 5])
        XCTAssertFalse(entries.contains(where: { $0.word.id == 4 }))
    }

    // MARK: 4. Plan rewrite by the app

    func testPlanRewriteKeepsTheVisibleWordAndContinuesFromIt() {
        for offset in offsets {
            assertRewriteContinuity(offset: offset)
        }
    }

    private func assertRewriteContinuity(offset: TimeInterval) {
        let message = "offset \(offset)"
        let feed = makeWords(Array(1...200))
        let oldQueue = QueueBuilder.build(feed: feed, excluding: [], startAt: nil, limit: 96)
        let oldPlan = makePlan(queue: oldQueue, planID: "old", updatedAt: t0)
        // The user marked word 3 as known earlier.
        let oldState = WidgetState(
            planID: "old",
            cursorOffset: 0,
            cursorAnchor: t0,
            knownIDs: [3],
            updatedAt: t0
        )
        let oldInput = RotationInput.resolve(plan: oldPlan, state: oldState, seedWords: [])

        // The app backgrounds 5 h 12 min later, at a fractional instant.
        let realNow = t0.addingTimeInterval(5.2 * hour + 17.4)
        let rewriteTime = TimelinePlanner.roundedDownToWholeSecond(realNow)
        let currentID = shownID(at: rewriteTime, oldInput, offset: offset)
        XCTAssertNotNil(currentID, message)
        XCTAssertEqual(shownID(at: realNow, oldInput, offset: offset), currentID, message)

        let newQueue = QueueBuilder.build(feed: feed, excluding: [3], startAt: currentID, limit: 96)
        XCTAssertEqual(newQueue.first?.id, currentID, message)
        let newPlan = makePlan(queue: newQueue, planID: "new", updatedAt: rewriteTime)
        // The old state belongs to plan "old": it must be ignored for plan "new".
        let newInput = RotationInput.resolve(plan: newPlan, state: oldState, seedWords: [])
        XCTAssertEqual(newInput.cursorOffset, 0, message)
        XCTAssertEqual(newInput.cursorAnchor, rewriteTime, message)
        XCTAssertTrue(newInput.knownIDs.isEmpty, message)

        // At the rewrite moment the widget keeps showing the same word ...
        XCTAssertEqual(shownID(at: rewriteTime, newInput, offset: offset), currentID, message)
        XCTAssertEqual(shownID(at: realNow, newInput, offset: offset), currentID, message)
        // ... and every later boundary shows what the old plan would have shown.
        let secondsAhead: [TimeInterval] = [0, 60, 1800, 3600, 5400, 7200, 25 * 3600, 60 * 3600]
        for seconds in secondsAhead {
            let moment = rewriteTime.addingTimeInterval(seconds)
            XCTAssertEqual(
                shownID(at: moment, newInput, offset: offset),
                shownID(at: moment, oldInput, offset: offset),
                "\(message), +\(seconds) s"
            )
        }
    }

    func testChangingTheIntervalKeepsTheVisibleWord() {
        let feed = makeWords(Array(1...200))
        let oldPlan = makePlan(queue: QueueBuilder.build(feed: feed, excluding: [], startAt: nil, limit: 96), updatedAt: t0)
        let oldInput = RotationInput.resolve(plan: oldPlan, state: nil, seedWords: [])

        let rewriteTime = t0.addingTimeInterval(2 * hour + 5 * 60)
        let currentID = shownID(at: rewriteTime, oldInput)
        XCTAssertEqual(currentID, 3)

        // The app now writes a 2 hour interval.
        let newQueue = QueueBuilder.build(feed: feed, excluding: [], startAt: currentID, limit: 96)
        let newPlan = makePlan(queue: newQueue, planID: "new", updatedAt: rewriteTime, interval: 7200)
        let newInput = RotationInput.resolve(plan: newPlan, state: nil, seedWords: [])
        XCTAssertEqual(shownID(at: rewriteTime, newInput), 3)
        XCTAssertEqual(shownID(at: rewriteTime.addingTimeInterval(2 * hour), newInput), 4)
    }

    // MARK: 5. Negative elapsed time

    func testElapsedIsNeverNegativeWhenTheAnchorIsInTheFuture() {
        let future = t0.addingTimeInterval(5 * hour)
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: future, to: t0, interval: 3600), 0)
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: t0, to: t0, interval: 3600), 0)
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: t0, to: t0.addingTimeInterval(3.5 * hour), interval: 3600), 3)

        let queue = makeWords([1, 2, 3, 4, 5])
        let word = TimelinePlanner.wordAt(
            t0,
            queue: queue,
            knownIDs: [],
            cursorOffset: 2,
            cursorAnchor: future,
            interval: 3600
        )
        XCTAssertEqual(word?.id, 3)

        let entries = TimelinePlanner.plan(
            queue: queue,
            knownIDs: [],
            cursorOffset: 2,
            cursorAnchor: future,
            now: t0,
            interval: 3600
        )
        XCTAssertEqual(entries[0].word.id, 3)
        // The word stays on R[0] until the anchor's boundary is reached.
        for entry in entries where entry.date < future {
            XCTAssertEqual(entry.word.id, 3)
        }
        for entry in entries {
            let expected = TimelinePlanner.wordAt(
                entry.date,
                queue: queue,
                knownIDs: [],
                cursorOffset: 2,
                cursorAnchor: future,
                interval: 3600
            )
            XCTAssertEqual(entry.word.id, expected?.id)
        }
    }

    // MARK: 6. Seed rotation

    func testSeedRotationIsDeterministicFromTheFixedAnchor() {
        let seed = makeWords(Array(101...107))
        let input = RotationInput.resolve(plan: nil, state: nil, seedWords: seed)
        XCTAssertTrue(input.isSeed)
        XCTAssertEqual(input.planID, "seed")
        XCTAssertEqual(input.interval, 3600)
        XCTAssertEqual(input.cursorOffset, 0)
        XCTAssertEqual(input.cursorAnchor, TimelinePlanner.seedAnchor)
        XCTAssertEqual(TimelinePlanner.seedAnchor.timeIntervalSince1970, 1_767_225_600)

        let anchor = TimelinePlanner.seedAnchor
        XCTAssertEqual(shownID(at: anchor, input), 101)
        XCTAssertEqual(shownID(at: anchor.addingTimeInterval(5.5 * hour), input), 106)
        XCTAssertEqual(shownID(at: anchor.addingTimeInterval(7 * hour), input), 101) // one full lap
        XCTAssertEqual(shownID(at: anchor.addingTimeInterval(7 * hour + 3 * hour), input), 104)

        // Two widget instances evaluating at different moments of the same hour agree.
        XCTAssertEqual(
            shownID(at: anchor.addingTimeInterval(5 * hour + 1), input),
            shownID(at: anchor.addingTimeInterval(5 * hour + 3599), input)
        )
        // A device clock set before the anchor shows the first word instead of failing.
        XCTAssertEqual(shownID(at: anchor.addingTimeInterval(-10 * hour), input), 101)

        // The seed timeline continues with time instead of restarting at the same word.
        let entries = timeline(input, now: anchor.addingTimeInterval(5.5 * hour))
        XCTAssertEqual(entries[0].word.id, 106)
        XCTAssertEqual(entries[1].word.id, 107)
        XCTAssertEqual(entries[2].word.id, 101)
    }

    // MARK: resolve()

    func testResolveUsesTheStateOnlyForTheSamePlan() {
        let plan = makePlan(queue: makeWords([1, 2, 3]), planID: "p", updatedAt: t0, interval: 7200)
        let anchor = t0.addingTimeInterval(1000)
        let matching = WidgetState(planID: "p", cursorOffset: 2, cursorAnchor: anchor, knownIDs: [1], updatedAt: anchor)
        let other = WidgetState(planID: "other", cursorOffset: 2, cursorAnchor: anchor, knownIDs: [1], updatedAt: anchor)

        let used = RotationInput.resolve(plan: plan, state: matching, seedWords: [])
        XCTAssertEqual(used.cursorOffset, 2)
        XCTAssertEqual(used.cursorAnchor, anchor)
        XCTAssertEqual(used.knownIDs, [1])
        XCTAssertEqual(used.interval, 7200)
        XCTAssertFalse(used.isSeed)

        let ignored = RotationInput.resolve(plan: plan, state: other, seedWords: [])
        XCTAssertEqual(ignored.cursorOffset, 0)
        XCTAssertEqual(ignored.cursorAnchor, t0)
        XCTAssertTrue(ignored.knownIDs.isEmpty)
    }

    func testResolveFallsBackToTheSeedWhenThePlanIsMissingOrEmpty() {
        let seed = makeWords([101, 102])
        let emptyPlan = makePlan(queue: [], updatedAt: t0)
        let fromEmptyPlan = RotationInput.resolve(plan: emptyPlan, state: nil, seedWords: seed)
        XCTAssertTrue(fromEmptyPlan.isSeed)
        XCTAssertEqual(fromEmptyPlan.queue.map { $0.id }, [101, 102])

        let anchor = TimelinePlanner.seedAnchor.addingTimeInterval(10 * hour)
        let seedState = WidgetState(planID: "seed", cursorOffset: 1, cursorAnchor: anchor, knownIDs: [101], updatedAt: anchor)
        let fromState = RotationInput.resolve(plan: nil, state: seedState, seedWords: seed)
        XCTAssertEqual(fromState.cursorOffset, 1)
        XCTAssertEqual(fromState.cursorAnchor, anchor)
        XCTAssertEqual(fromState.knownIDs, [101])
    }
}
