import XCTest
import CoreModels
import Scheduler

final class QueueBuilderTests: XCTestCase {
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

    private func ids(_ words: [WidgetWord]) -> [Int] {
        return words.map { $0.id }
    }

    func testKeepsOrderAndExcludesKnown() {
        let result = QueueBuilder.build(feed: makeWords([1, 2, 3, 4, 5]), excluding: [2], startAt: nil, limit: 3)
        XCTAssertEqual(ids(result), [1, 3, 4])
    }

    func testStartsAtTheCurrentWordAndWraps() {
        let result = QueueBuilder.build(feed: makeWords([1, 2, 3, 4, 5]), excluding: [2], startAt: 3, limit: 4)
        XCTAssertEqual(ids(result), [3, 4, 5, 1])
    }

    func testStartWordFirstEvenAtTheFeedEnd() {
        let result = QueueBuilder.build(feed: makeWords([1, 2, 3]), excluding: [], startAt: 3, limit: 10)
        XCTAssertEqual(ids(result), [3, 1, 2])
    }

    func testKnownStartWordStartsRightAfterIt() {
        let result = QueueBuilder.build(feed: makeWords([1, 2, 3, 4, 5]), excluding: [3], startAt: 3, limit: 3)
        XCTAssertEqual(ids(result), [4, 5, 1])

        // Known word is the last one in the feed: wraps to the beginning.
        let atEnd = QueueBuilder.build(feed: makeWords([1, 2, 3]), excluding: [3], startAt: 3, limit: 10)
        XCTAssertEqual(ids(atEnd), [1, 2])
    }

    func testStartWordMissingFromFeedKeepsFeedOrder() {
        let result = QueueBuilder.build(feed: makeWords([1, 2, 3]), excluding: [], startAt: 99, limit: 10)
        XCTAssertEqual(ids(result), [1, 2, 3])
    }

    func testZeroLimitAndEmptyFeed() {
        XCTAssertTrue(QueueBuilder.build(feed: makeWords([1]), excluding: [], startAt: nil, limit: 0).isEmpty)
        XCTAssertTrue(QueueBuilder.build(feed: [], excluding: [], startAt: 1, limit: 5).isEmpty)
    }
}
