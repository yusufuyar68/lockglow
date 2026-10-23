import XCTest
import Learning

final class ReviewActivityTrackerTests: XCTestCase {
    private typealias Progress = ReviewActivityTracker.Progress

    private let start = Date(timeIntervalSince1970: 1_800_000_000)
    private let minute: TimeInterval = 60

    /// A tracker whose round shows "Kart 1 / 10" in an activity.
    private func showing() -> ReviewActivityTracker {
        var tracker = ReviewActivityTracker()
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 1, total: 10), enabled: true), .start(Progress(card: 1, total: 10)))
        return tracker
    }

    // MARK: Counter

    func testTheCardOnScreenIsTheNextOneAndNeverPastTheLast() {
        XCTAssertEqual(Progress(done: 0, total: 10), Progress(card: 1, total: 10))
        XCTAssertEqual(Progress(done: 3, total: 10), Progress(card: 4, total: 10))
        XCTAssertEqual(Progress(done: 10, total: 10), Progress(card: 10, total: 10))
        XCTAssertEqual(Progress(done: 0, total: 0), Progress(card: 1, total: 0))
    }

    // MARK: A round

    func testItStartsWithTheRoundFollowsTheCounterAndEndsWithIt() {
        var tracker = showing()
        XCTAssertTrue(tracker.isShowing)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: true), .update(Progress(card: 2, total: 10)))
        // The same counter again changes nothing.
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: true), .none)
        // A second try in "Tanış + Hatırla" adds a card.
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 3, total: 11), enabled: true), .update(Progress(card: 3, total: 11)))
        // The last card, or "Bitir".
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: true), .end)
        XCTAssertFalse(tracker.isShowing)
        XCTAssertNil(tracker.progress)
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: true), .none)
    }

    func testTheNextRoundStartsANewActivity() {
        var tracker = showing()
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: true), .end)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 1, total: 5), enabled: true), .start(Progress(card: 1, total: 5)))
    }

    func testSwitchedOffNoActivityStarts() {
        var tracker = ReviewActivityTracker()
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 1, total: 10), enabled: false), .none)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: false), .none)
        XCTAssertFalse(tracker.isShowing)
        XCTAssertEqual(tracker.didEnterBackground(at: start), .none)
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: false), .none)
    }

    // MARK: Leaving the app

    func testLeavingMovesTheStaleDateAndComingBackSoonKeepsIt() {
        var tracker = showing()
        XCTAssertEqual(tracker.didEnterBackground(at: start), .update(Progress(card: 1, total: 10)))
        XCTAssertEqual(tracker.leftAt, start)
        XCTAssertEqual(tracker.didBecomeActive(at: start.addingTimeInterval(29 * minute)), .none)
        XCTAssertTrue(tracker.isShowing)
        XCTAssertNil(tracker.leftAt)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: true), .update(Progress(card: 2, total: 10)))
    }

    func testThirtyMinutesAwayCloseItUntilTheRoundGoesOn() {
        var tracker = showing()
        XCTAssertEqual(tracker.didEnterBackground(at: start), .update(Progress(card: 1, total: 10)))
        XCTAssertEqual(tracker.didBecomeActive(at: start.addingTimeInterval(30 * minute)), .end)
        XCTAssertFalse(tracker.isShowing)
        XCTAssertFalse(tracker.isClosedForRound)
        // Back in the app without answering: nothing to show, nothing to move.
        XCTAssertEqual(tracker.didEnterBackground(at: start.addingTimeInterval(31 * minute)), .none)
        XCTAssertEqual(tracker.didBecomeActive(at: start.addingTimeInterval(90 * minute)), .none)
        // The next card: the round is going on again.
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: true), .start(Progress(card: 2, total: 10)))
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: true), .end)
    }

    /// Back after the timeout, the user ends the round without another card: nothing to close.
    func testARoundEndedAfterTheTimeoutClosesNothing() {
        var tracker = showing()
        _ = tracker.didEnterBackground(at: start)
        XCTAssertEqual(tracker.didBecomeActive(at: start.addingTimeInterval(45 * minute)), .end)
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: true), .none)
    }

    /// The thirty minutes count from the last time the user left, not from the first.
    func testTheTimeoutCountsFromTheLastLeave() {
        var tracker = showing()
        _ = tracker.didEnterBackground(at: start)
        XCTAssertEqual(tracker.didBecomeActive(at: start.addingTimeInterval(20 * minute)), .none)
        _ = tracker.didEnterBackground(at: start.addingTimeInterval(25 * minute))
        XCTAssertEqual(tracker.didBecomeActive(at: start.addingTimeInterval(50 * minute)), .none)
        XCTAssertTrue(tracker.isShowing)
    }

    /// An activation without a background before it (Control Center, an alert) changes nothing.
    func testAnActivationWithoutLeavingDoesNothing() {
        var tracker = showing()
        XCTAssertEqual(tracker.didBecomeActive(at: start.addingTimeInterval(60 * minute)), .none)
        XCTAssertTrue(tracker.isShowing)
    }

    func testTheStaleDateIsThirtyMinutesLater() {
        XCTAssertEqual(ReviewActivityTracker.timeout, 30 * minute)
        XCTAssertEqual(ReviewActivityTracker.staleDate(from: start), start.addingTimeInterval(30 * minute))
    }

    // MARK: Closed from outside

    func testSwipedAwayItStaysClosedUntilTheNextRound() {
        var tracker = showing()
        _ = tracker.didEnterBackground(at: start)
        tracker.endedOutside()
        XCTAssertFalse(tracker.isShowing)
        XCTAssertNil(tracker.leftAt)
        XCTAssertEqual(tracker.didBecomeActive(at: start.addingTimeInterval(60 * minute)), .none)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: true), .none)
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: true), .none)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 1, total: 10), enabled: true), .start(Progress(card: 1, total: 10)))
    }

    func testAFailedStartIsNotRetriedInTheSameRound() {
        var tracker = showing()
        tracker.startFailed()
        XCTAssertFalse(tracker.isShowing)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: true), .none)
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: true), .none)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 1, total: 10), enabled: true), .start(Progress(card: 1, total: 10)))
    }

    func testEndedOutsideWithoutAnActivityChangesNothing() {
        var tracker = ReviewActivityTracker()
        tracker.endedOutside()
        XCTAssertEqual(tracker, ReviewActivityTracker())
    }

    // MARK: The switch in "Ayarlar"

    func testSwitchingOffClosesItAndOnWaitsForTheNextRound() {
        var tracker = showing()
        XCTAssertEqual(tracker.settingChanged(enabled: false), .end)
        XCTAssertFalse(tracker.isShowing)
        XCTAssertEqual(tracker.settingChanged(enabled: false), .none)
        XCTAssertEqual(tracker.settingChanged(enabled: true), .none)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: true), .none)
        XCTAssertEqual(tracker.roundChanged(to: nil, enabled: true), .none)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 1, total: 10), enabled: true), .start(Progress(card: 1, total: 10)))
    }

    /// A round that started switched off never had an activity closed: switched on, it shows one
    /// from its next card on.
    func testARoundStartedSwitchedOffShowsItOnceSwitchedOn() {
        var tracker = ReviewActivityTracker()
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 1, total: 10), enabled: false), .none)
        XCTAssertEqual(tracker.settingChanged(enabled: true), .none)
        XCTAssertEqual(tracker.roundChanged(to: Progress(card: 2, total: 10), enabled: true), .start(Progress(card: 2, total: 10)))
    }
}
