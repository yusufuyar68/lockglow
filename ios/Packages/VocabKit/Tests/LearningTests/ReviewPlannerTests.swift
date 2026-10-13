import XCTest
import CoreModels
import Learning

final class ReviewPlannerTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let hour: TimeInterval = 3600
    private let day: TimeInterval = 86_400

    private func words(_ ids: ClosedRange<Int>) -> [WidgetWord] {
        return ids.map { id in
            WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e")
        }
    }

    private func learning(_ id: Int, due: Date) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .learning
        p.box = 1
        p.dueAt = due
        return p
    }

    private func known(_ id: Int, due: Date) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = .known
        p.box = 5
        p.dueAt = due
        return p
    }

    private func ids(_ list: [WidgetWord]) -> [Int] {
        return list.map { $0.id }
    }

    /// 1 and 2 learning and overdue, 3 known with an overdue refresher, 4 learning but due in 3 h,
    /// 5 known and not due for 20 days, 6 only seen on the widget, 7 and 8 never seen.
    private func mixedProgress() -> [Int: WordProgress] {
        var seen = WordProgress(wordID: 6)
        seen.exposures = 4
        return [
            1: learning(1, due: now.addingTimeInterval(-1 * hour)),
            2: learning(2, due: now.addingTimeInterval(-2 * hour)),
            3: known(3, due: now.addingTimeInterval(-1 * day)),
            4: learning(4, due: now.addingTimeInterval(3 * hour)),
            5: known(5, due: now.addingTimeInterval(20 * day)),
            6: seen,
        ]
    }

    func testDueWordsAreMostOverdueFirst() {
        let due = ReviewPlanner.dueWords(feed: words(1...8), progress: mixedProgress(), now: now, limit: 10)
        XCTAssertEqual(ids(due), [3, 2, 1])
    }

    func testDueWordsRespectTheLimit() {
        let due = ReviewPlanner.dueWords(feed: words(1...8), progress: mixedProgress(), now: now, limit: 2)
        XCTAssertEqual(ids(due), [3, 2])
        XCTAssertTrue(ReviewPlanner.dueWords(feed: words(1...8), progress: mixedProgress(), now: now, limit: 0).isEmpty)
    }

    func testDueWordsAppearWhenTheirTimeComes() {
        let later = now.addingTimeInterval(4 * hour)
        let due = ReviewPlanner.dueWords(feed: words(1...8), progress: mixedProgress(), now: later, limit: 10)
        XCTAssertEqual(ids(due), [3, 2, 1, 4])
    }

    func testEqualDueDatesKeepFeedOrder() {
        let progress = [
            1: learning(1, due: now),
            2: learning(2, due: now),
            3: learning(3, due: now),
        ]
        XCTAssertEqual(ids(ReviewPlanner.dueWords(feed: words(1...3), progress: progress, now: now, limit: 10)), [1, 2, 3])
        XCTAssertEqual(ids(ReviewPlanner.dueWords(feed: words(1...3).reversed(), progress: progress, now: now, limit: 10)), [3, 2, 1])
    }

    func testWordsOutsideTheFeedAndDuplicatesAreIgnored() {
        var feed = words(1...2)
        feed.append(contentsOf: words(1...2)) // duplicated ids
        let due = ReviewPlanner.dueWords(feed: feed, progress: mixedProgress(), now: now, limit: 10)
        XCTAssertEqual(ids(due), [2, 1]) // 3 is due too but is not in the feed
    }

    func testNewWordsSkipEveryReviewedWordInFeedOrder() {
        let fresh = ReviewPlanner.newWords(feed: words(1...8), progress: mixedProgress(), limit: 10)
        XCTAssertEqual(ids(fresh), [6, 7, 8]) // 6 was only seen, never reviewed
        XCTAssertEqual(ids(ReviewPlanner.newWords(feed: words(1...8), progress: mixedProgress(), limit: 2)), [6, 7])
        XCTAssertTrue(ReviewPlanner.newWords(feed: words(1...8), progress: mixedProgress(), limit: 0).isEmpty)
    }

    func testNewWordsWithNoProgressAreTheFirstFeedWords() {
        XCTAssertEqual(ids(ReviewPlanner.newWords(feed: words(1...30), progress: [:], limit: 10)), Array(1...10))
    }

    func testCounts() {
        let endOfDay = now.addingTimeInterval(6 * hour)
        let counts = ReviewPlanner.counts(feed: words(1...8), progress: mixedProgress(), dueBy: endOfDay)
        XCTAssertEqual(counts.known, 2) // 3, 5
        XCTAssertEqual(counts.learning, 3) // 1, 2, 4
        XCTAssertEqual(counts.dueToday, 4) // 1, 2, 3 and 4 (due in 3 h); 5 is 20 days away

        let rightNow = ReviewPlanner.counts(feed: words(1...8), progress: mixedProgress(), dueBy: now)
        XCTAssertEqual(rightNow.dueToday, 3)
    }

    func testCountsOnlyLookAtFeedWords() {
        let counts = ReviewPlanner.counts(feed: words(1...3), progress: mixedProgress(), dueBy: now)
        XCTAssertEqual(counts, ProgressCounts(known: 1, learning: 2, dueToday: 3))
        XCTAssertEqual(ReviewPlanner.counts(feed: words(1...3), progress: [:], dueBy: now), ProgressCounts())
    }
}
