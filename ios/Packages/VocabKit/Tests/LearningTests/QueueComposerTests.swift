import XCTest
import CoreModels
import Learning

final class QueueComposerTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400

    private func words(_ ids: ClosedRange<Int>) -> [WidgetWord] {
        return ids.map { id in
            WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "B1", defMicro: "m", defShort: "s", exampleEN: "e")
        }
    }

    private func learning(_ id: Int, due: Date) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = 2
        p.dueAt = due
        return p
    }

    private func known(_ id: Int, due: Date, override: Bool = false) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .known
        p.box = 5
        p.knownOverride = override
        p.dueAt = due
        return p
    }

    /// Words 1, 2 due reviews; 3 due refresher; 4 learning not due; 5 known not due; 6...10 new.
    private func mixedProgress() -> [Int: WordProgress] {
        return [
            1: learning(1, due: now.addingTimeInterval(-1 * hour)),
            2: learning(2, due: now.addingTimeInterval(-2 * hour)),
            3: known(3, due: now.addingTimeInterval(-1 * day)),
            4: learning(4, due: now.addingTimeInterval(3 * day)),
            5: known(5, due: now.addingTimeInterval(20 * day), override: true),
        ]
    }

    private func ids(_ list: [WidgetWord]) -> [Int] {
        return list.map { $0.id }
    }

    func testOnlyNewWordsKeepsFeedOrder() {
        let queue = QueueComposer.compose(feed: words(1...20), progress: [:], now: now, horizon: 0, maxNew: 3, limit: 10)
        XCTAssertEqual(ids(queue), Array(1...10))
    }

    func testMixFollowsThePatternAndFallbacks() {
        // Slots: review→2, new→6, review→1, review→(no review)→new 7, new→(no new)→refresher 3,
        // review→(all three empty)→not-yet-due 4, review→extra new 8, new→extra new 9.
        let queue = QueueComposer.compose(feed: words(1...10), progress: mixedProgress(), now: now, horizon: 0, maxNew: 2, limit: 8)
        XCTAssertEqual(ids(queue), [2, 6, 1, 7, 3, 4, 8, 9])
        XCTAssertFalse(queue.contains(where: { $0.id == 5 })) // known and not due: never queued
    }

    func testHorizonMakesUpcomingReviewsDue() {
        // With a 4-day horizon, word 4 (due in 3 days) is a review, not a top-up.
        let queue = QueueComposer.compose(feed: words(1...10), progress: mixedProgress(), now: now, horizon: 4 * day, maxNew: 2, limit: 4)
        XCTAssertEqual(ids(queue), [2, 6, 1, 4])
    }

    func testPinnedWordStaysFirst() {
        let pinned = words(4...4)[0]
        let queue = QueueComposer.compose(feed: words(1...10), progress: mixedProgress(), now: now, horizon: 0, maxNew: 2, limit: 8, pinFirst: pinned)
        XCTAssertEqual(ids(queue), [4, 2, 6, 1, 7, 3, 8, 9])
    }

    func testKnownPinnedWordIsNotPinned() {
        let pinned = words(5...5)[0]
        let queue = QueueComposer.compose(feed: words(1...10), progress: mixedProgress(), now: now, horizon: 0, maxNew: 2, limit: 8, pinFirst: pinned)
        XCTAssertEqual(ids(queue), [2, 6, 1, 7, 3, 4, 8, 9])
    }

    func testNoDuplicatesAndFeedShorterThanLimit() {
        var feed = words(1...10)
        feed.append(contentsOf: words(1...3)) // duplicated ids in the feed
        let queue = QueueComposer.compose(feed: feed, progress: mixedProgress(), now: now, horizon: 0, maxNew: 2, limit: 50)
        XCTAssertEqual(Set(ids(queue)).count, queue.count)
        XCTAssertEqual(Set(ids(queue)), Set([1, 2, 3, 4, 6, 7, 8, 9, 10]))
    }

    // MARK: Deck (topic choice)

    func testDeckQueueKeepsThePinnedWordThenUsesOnlyTheDeck() {
        // The word on screen (15) is outside the chosen deck (1...10): it stays first, the rest
        // come from the deck. Slots: new 1, new 2, new 3, then extra new 4 and 5.
        let pinned = words(15...15)[0]
        let queue = QueueComposer.compose(deck: words(1...10), fallbackFeed: words(1...20), progress: [:], now: now, horizon: 0, maxNew: 3, limit: 6, pinFirst: pinned)
        XCTAssertEqual(ids(queue), [15, 1, 2, 3, 4, 5])
    }

    func testDeckWithNothingLeftFallsBackToEveryWord() {
        // Every deck word (1...3) is known and not due. The pinned word (7) stays first, then
        // the new words of the whole feed: 4, 5 (maxNew 2), then extra new 6, 8.
        var progress: [Int: WordProgress] = [:]
        for id in 1...3 {
            progress[id] = known(id, due: now.addingTimeInterval(20 * day))
        }
        let pinned = words(7...7)[0]
        let queue = QueueComposer.compose(deck: words(1...3), fallbackFeed: words(1...10), progress: progress, now: now, horizon: 0, maxNew: 2, limit: 5, pinFirst: pinned)
        XCTAssertEqual(ids(queue), [7, 4, 5, 6, 8])

        let unpinned = QueueComposer.compose(deck: words(1...3), fallbackFeed: words(1...10), progress: progress, now: now, horizon: 0, maxNew: 2, limit: 5)
        XCTAssertEqual(ids(unpinned), [4, 5, 6, 7, 8])
    }

    func testDeckWithOnlyNotYetDueWordsDoesNotFallBack() {
        // Word 1 is learning (due in 3 days) and still rotates as a top-up; word 2 is known.
        let progress = [
            1: learning(1, due: now.addingTimeInterval(3 * day)),
            2: known(2, due: now.addingTimeInterval(20 * day)),
        ]
        let queue = QueueComposer.compose(deck: words(1...2), fallbackFeed: words(1...10), progress: progress, now: now, horizon: 0, maxNew: 2, limit: 5)
        XCTAssertEqual(ids(queue), [1])
    }

    func testDeckQueueEqualsThePlainQueueWhenTheDeckIsEverything() {
        let plain = QueueComposer.compose(feed: words(1...30), progress: mixedProgress(), now: now, horizon: day, maxNew: 5, limit: 20, pinFirst: words(4...4)[0])
        let deck = QueueComposer.compose(deck: words(1...30), fallbackFeed: words(1...30), progress: mixedProgress(), now: now, horizon: day, maxNew: 5, limit: 20, pinFirst: words(4...4)[0])
        XCTAssertEqual(ids(deck), ids(plain))
    }

    func testZeroLimitAndDeterminism() {
        XCTAssertTrue(QueueComposer.compose(feed: words(1...5), progress: [:], now: now, horizon: 0, maxNew: 2, limit: 0).isEmpty)
        let first = QueueComposer.compose(feed: words(1...30), progress: mixedProgress(), now: now, horizon: day, maxNew: 5, limit: 20)
        let second = QueueComposer.compose(feed: words(1...30), progress: mixedProgress(), now: now, horizon: day, maxNew: 5, limit: 20)
        XCTAssertEqual(ids(first), ids(second))
    }
}
