import XCTest
import CoreModels
import SharedState
import Scheduler

/// The Apple Watch rotation (`WatchRotation`): one word per hour from the phone's plan, the
/// watch's own cursor, and the "Biliyorum" / "Sonraki kelime" taps. Alignment offset 0 (UTC).
final class WatchRotationTests: XCTestCase {
    // 2023-11-14 22:00:00 UTC, an hourly boundary (1_699_999_200 = 472_222 * 3600).
    private let t0 = Date(timeIntervalSince1970: 1_699_999_200)
    private let hour: TimeInterval = 3600

    private func words(_ ids: [Int]) -> [WidgetWord] {
        return ids.map { id in
            WidgetWord(id: id, lemma: "word\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")
        }
    }

    /// A plan written by the phone at `t0`, with the phone widget's 30-minute interval.
    private func plan(_ ids: [Int], id: String = "p") -> WidgetPlan {
        return WidgetPlan(planID: id, isPremium: false, intervalSeconds: 1800, queue: words(ids), updatedAt: t0)
    }

    private func wordID(_ input: RotationInput, at date: Date) -> Int? {
        return WatchRotation.word(at: date, input: input, alignmentOffset: 0)?.id
    }

    func testTheWatchRotatesHourlyWhateverThePhoneInterval() {
        let input = WatchRotation.input(plan: plan([1, 2, 3]), state: nil, seedWords: [])
        XCTAssertEqual(input.interval, 3600)
        XCTAssertFalse(input.isSeed)
        XCTAssertEqual(wordID(input, at: t0), 1)
        XCTAssertEqual(wordID(input, at: t0.addingTimeInterval(1800)), 1)
        XCTAssertEqual(wordID(input, at: t0.addingTimeInterval(hour - 1)), 1)
        XCTAssertEqual(wordID(input, at: t0.addingTimeInterval(hour)), 2)
        XCTAssertEqual(wordID(input, at: t0.addingTimeInterval(3 * hour)), 1)
    }

    func testTheWatchStateOfThisPlanIsUsedAndAnOtherPlansStateIsNot() {
        let state = WidgetState(planID: "p", cursorOffset: 2, cursorAnchor: t0, knownIDs: [1], updatedAt: t0)
        let input = WatchRotation.input(plan: plan([1, 2, 3]), state: state, seedWords: [])
        XCTAssertEqual(input.cursorOffset, 2)
        XCTAssertEqual(input.knownIDs, [1])
        XCTAssertEqual(wordID(input, at: t0), 3)
        // Lap from index 2 without word 1: 3, 2, 3, ...
        XCTAssertEqual(wordID(input, at: t0.addingTimeInterval(hour)), 2)

        let fresh = WatchRotation.input(plan: plan([1, 2, 3], id: "q"), state: state, seedWords: [])
        XCTAssertEqual(fresh.cursorOffset, 0)
        XCTAssertEqual(fresh.knownIDs, [])
        XCTAssertEqual(wordID(fresh, at: t0), 1)
    }

    func testWithoutAPlanTheSeedWordsRotate() {
        let input = WatchRotation.input(plan: nil, state: nil, seedWords: words([7, 8]))
        XCTAssertTrue(input.isSeed)
        XCTAssertEqual(input.planID, RotationInput.seedPlanID)
        XCTAssertEqual(input.queue.map { $0.id }, [7, 8])
        XCTAssertNotNil(wordID(input, at: t0))
        XCTAssertNil(WatchRotation.word(at: t0, input: WatchRotation.input(plan: nil, state: nil, seedWords: []), alignmentOffset: 0))
    }

    func testWhenEveryWordIsKnownTheWatchStillShowsWords() {
        let state = WidgetState(planID: "p", cursorOffset: 0, cursorAnchor: t0, knownIDs: [1, 2], updatedAt: t0)
        let input = WatchRotation.input(plan: plan([1, 2]), state: state, seedWords: [])
        XCTAssertEqual(wordID(input, at: t0), 1)
        XCTAssertEqual(wordID(input, at: t0.addingTimeInterval(hour)), 2)
        XCTAssertEqual(WatchRotation.entries(input: input, now: t0, alignmentOffset: 0).first?.word.id, 1)
    }

    func testTheComplicationTimelineHasOneEntryPerHourForTwoDays() {
        let input = WatchRotation.input(plan: plan([1, 2, 3, 4, 5]), state: nil, seedWords: [])
        let now = t0.addingTimeInterval(600)
        let entries = WatchRotation.entries(input: input, now: now, alignmentOffset: 0)
        XCTAssertEqual(entries.count, 49)
        XCTAssertEqual(entries[0].date, now)
        XCTAssertEqual(entries[1].date, t0.addingTimeInterval(hour))
        XCTAssertEqual(entries.last?.date, t0.addingTimeInterval(48 * hour))
        for entry in entries {
            XCTAssertEqual(entry.word.id, wordID(input, at: entry.date), "\(entry.date)")
        }
        XCTAssertTrue(WatchRotation.entries(input: WatchRotation.input(plan: nil, state: nil, seedWords: []), now: now, alignmentOffset: 0).isEmpty)
    }

    func testNextShowsTheFollowingWordAtOnceAndKeepsTheKnownSet() {
        let state = WidgetState(planID: "p", cursorOffset: 0, cursorAnchor: t0, knownIDs: [3], updatedAt: t0)
        let input = WatchRotation.input(plan: plan([1, 2, 3, 4]), state: state, seedWords: [])
        let tap = t0.addingTimeInterval(1234.7)
        let next = WatchRotation.stateAfterNext(shownWordID: 1, input: input, now: tap, alignmentOffset: 0)
        XCTAssertEqual(next.planID, "p")
        XCTAssertEqual(next.cursorOffset, 1)
        XCTAssertEqual(next.cursorAnchor, Date(timeIntervalSince1970: (t0.timeIntervalSince1970 + 1234.7).rounded(.down)))
        XCTAssertEqual(next.knownIDs, [3])

        let after = WatchRotation.input(plan: plan([1, 2, 3, 4]), state: next, seedWords: [])
        XCTAssertEqual(wordID(after, at: tap), 2)
        // Word 3 stays skipped: 2, 4, 1, ...
        XCTAssertEqual(wordID(after, at: t0.addingTimeInterval(hour)), 4)
    }

    func testKnowSkipsTheWordFromNowOn() {
        let input = WatchRotation.input(plan: plan([1, 2, 3]), state: nil, seedWords: [])
        let tap = t0.addingTimeInterval(60)
        let known = WatchRotation.stateAfterKnow(shownWordID: 1, input: input, now: tap, alignmentOffset: 0)
        XCTAssertEqual(known.knownIDs, [1])
        XCTAssertEqual(known.cursorOffset, 0)

        let after = WatchRotation.input(plan: plan([1, 2, 3]), state: known, seedWords: [])
        XCTAssertEqual(wordID(after, at: tap), 2)
        XCTAssertEqual(wordID(after, at: t0.addingTimeInterval(hour)), 3)
        XCTAssertEqual(wordID(after, at: t0.addingTimeInterval(2 * hour)), 2)
    }

    func testANewPlanKeepsTheWordOnScreenAndGoesOnFromIt() throws {
        // The watch moved on to word 3 with "Sonraki kelime"; the phone then sends plan q.
        let state = WidgetState(planID: "p", cursorOffset: 2, cursorAnchor: t0, knownIDs: [], updatedAt: t0)
        let old = WatchRotation.input(plan: plan([1, 2, 3, 4]), state: state, seedWords: [])
        let now = t0.addingTimeInterval(1800.5)
        XCTAssertEqual(wordID(old, at: now), 3)

        let newPlan = plan([9, 3, 8], id: "q")
        let kept = try XCTUnwrap(WatchRotation.stateKeepingWord(from: old, newPlan: newPlan, now: now, alignmentOffset: 0))
        XCTAssertEqual(kept.planID, "q")
        XCTAssertEqual(kept.cursorOffset, 1)
        XCTAssertEqual(kept.cursorAnchor, t0.addingTimeInterval(1800))
        XCTAssertEqual(kept.knownIDs, [])

        let after = WatchRotation.input(plan: newPlan, state: kept, seedWords: [])
        XCTAssertEqual(wordID(after, at: now), 3)
        XCTAssertEqual(wordID(after, at: t0.addingTimeInterval(hour)), 8)
        XCTAssertEqual(wordID(after, at: t0.addingTimeInterval(2 * hour)), 9)
    }

    func testANewPlanWithoutTheWordOnScreenStartsAtItsFirstWord() {
        let old = WatchRotation.input(plan: plan([1, 2]), state: nil, seedWords: [])
        XCTAssertNil(WatchRotation.stateKeepingWord(from: old, newPlan: plan([7, 8], id: "q"), now: t0, alignmentOffset: 0))
        // The same plan again: nothing to change.
        XCTAssertNil(WatchRotation.stateKeepingWord(from: old, newPlan: plan([1, 2]), now: t0, alignmentOffset: 0))
        // Seed words on screen, then the first plan.
        let seed = WatchRotation.input(plan: nil, state: nil, seedWords: words([5]))
        XCTAssertNil(WatchRotation.stateKeepingWord(from: seed, newPlan: plan([1, 2], id: "q"), now: t0, alignmentOffset: 0))
        let seedInPlan = WatchRotation.stateKeepingWord(from: seed, newPlan: plan([1, 5], id: "q"), now: t0, alignmentOffset: 0)
        XCTAssertEqual(seedInPlan?.cursorOffset, 1)
    }

    func testKnowingTheLastUnknownWordMovesOnInsteadOfShowingItAgain() {
        let state = WidgetState(planID: "p", cursorOffset: 0, cursorAnchor: t0, knownIDs: [1, 3], updatedAt: t0)
        let input = WatchRotation.input(plan: plan([1, 2, 3]), state: state, seedWords: [])
        XCTAssertEqual(wordID(input, at: t0), 2)
        let tap = t0.addingTimeInterval(60)
        let known = WatchRotation.stateAfterKnow(shownWordID: 2, input: input, now: tap, alignmentOffset: 0)
        XCTAssertEqual(known.knownIDs, [1, 2, 3])
        let after = WatchRotation.input(plan: plan([1, 2, 3]), state: known, seedWords: [])
        XCTAssertEqual(wordID(after, at: tap), 3)
    }
}
