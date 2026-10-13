import XCTest
import CoreModels
import Scheduler

final class TimelinePlannerTests: XCTestCase {
    // 2023-11-14 22:13:20 UTC. The hourly boundary before it is 1_699_999_200.
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

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

    private func ids(_ entries: [TimelinePlanner.PlannedEntry]) -> [Int] {
        return entries.map { $0.word.id }
    }

    /// Timeline whose rotation was anchored at `now` (elapsed 0), so entry 0 is R[0].
    private func plan(
        _ queue: [WidgetWord],
        known: Set<Int> = [],
        cursor: Int = 0,
        interval: TimeInterval = 3600,
        maxEntries: Int = TimelinePlanner.defaultMaxEntries
    ) -> [TimelinePlanner.PlannedEntry] {
        return TimelinePlanner.plan(
            queue: queue,
            knownIDs: known,
            cursorOffset: cursor,
            cursorAnchor: now,
            now: now,
            interval: interval,
            maxEntries: maxEntries
        )
    }

    func testFirstEntryIsNowAndLaterEntriesAreAlignedToTheInterval() {
        let entries = plan(makeWords([1, 2, 3, 4, 5]))
        XCTAssertEqual(entries[0].date, now)
        XCTAssertEqual(entries[1].date.timeIntervalSince1970, 1_700_002_800, accuracy: 0.001)
        XCTAssertEqual(entries[2].date.timeIntervalSince1970, 1_700_006_400, accuracy: 0.001)
        for entry in entries.dropFirst() {
            let remainder = entry.date.timeIntervalSince1970.truncatingRemainder(dividingBy: 3600)
            XCTAssertEqual(remainder, 0, accuracy: 0.001)
            XCTAssertGreaterThan(entry.date, now)
        }
    }

    func testHourlyTimelineCoversTheHorizon() {
        let entries = plan(makeWords([1, 2, 3]))
        // now + 48 boundaries inside the 48 h horizon.
        XCTAssertEqual(entries.count, 49)
        let last = entries[entries.count - 1].date
        XCTAssertLessThanOrEqual(last.timeIntervalSince(now), 48 * 3600)
        XCTAssertEqual(TimelinePlanner.reloadDate(for: entries), last)
    }

    func testAlignmentOffsetMovesBoundariesToLocalTime() {
        // UTC+3: daily boundaries should fall on 21:00 UTC (local midnight).
        let entries = TimelinePlanner.plan(
            queue: makeWords([1, 2, 3]),
            knownIDs: [],
            cursorOffset: 0,
            cursorAnchor: now,
            now: now,
            interval: 86_400,
            alignmentOffset: 3 * 3600
        )
        XCTAssertEqual(entries.count, 3)
        let secondsIntoUTCDay = entries[1].date.timeIntervalSince1970.truncatingRemainder(dividingBy: 86_400)
        XCTAssertEqual(secondsIntoUTCDay, 21 * 3600, accuracy: 0.001)
    }

    func testLocalAlignmentOffsetUsesTheGivenTimeZone() throws {
        let istanbul = try XCTUnwrap(TimeZone(identifier: "Europe/Istanbul"))
        XCTAssertEqual(TimelinePlanner.localAlignmentOffset(for: now, timeZone: istanbul), 3 * 3600)
        let utc = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        XCTAssertEqual(TimelinePlanner.localAlignmentOffset(for: now, timeZone: utc), 0)
    }

    func testQueueWrapsAround() {
        let entries = plan(makeWords([1, 2, 3]))
        XCTAssertEqual(Array(ids(entries).prefix(7)), [1, 2, 3, 1, 2, 3, 1])
    }

    func testCursorOffsetStartsMidQueueAndWraps() {
        let queue = makeWords([1, 2, 3])
        XCTAssertEqual(Array(ids(plan(queue, cursor: 2)).prefix(4)), [3, 1, 2, 3])
        XCTAssertEqual(Array(ids(plan(queue, cursor: 5)).prefix(3)), [3, 1, 2])
        XCTAssertEqual(Array(ids(plan(queue, cursor: -1)).prefix(3)), [3, 1, 2])
    }

    func testKnownIDsAreSkipped() {
        let queue = makeWords([1, 2, 3, 4])
        XCTAssertEqual(Array(ids(plan(queue, known: [2, 3])).prefix(5)), [1, 4, 1, 4, 1])
        // The cursor points at a known word: the first playable word after it is used.
        XCTAssertEqual(Array(ids(plan(queue, known: [2, 3], cursor: 1)).prefix(3)), [4, 1, 4])
    }

    func testAllKnownGivesEmptyPlan() {
        let entries = plan(makeWords([1, 2]), known: [1, 2])
        XCTAssertTrue(entries.isEmpty)
        XCTAssertNil(TimelinePlanner.reloadDate(for: entries))
    }

    func testIntervalIsClampedToFiveMinutes() {
        XCTAssertEqual(TimelinePlanner.clampedInterval(10), 300)
        XCTAssertEqual(TimelinePlanner.clampedInterval(3600), 3600)
        XCTAssertEqual(TimelinePlanner.clampedInterval(.infinity), 300)

        let entries = plan(makeWords([1, 2, 3]), interval: 10)
        XCTAssertEqual(entries[2].date.timeIntervalSince(entries[1].date), 300, accuracy: 0.001)
        let remainder = entries[1].date.timeIntervalSince1970.truncatingRemainder(dividingBy: 300)
        XCTAssertEqual(remainder, 0, accuracy: 0.001)
    }

    func testMaxEntriesCap() {
        let queue = makeWords([1, 2, 3])
        // 5 minute interval over 48 h would be 577 entries; the default cap is 96.
        XCTAssertEqual(plan(queue, interval: 300).count, 96)
        XCTAssertEqual(plan(queue, interval: 300, maxEntries: 10).count, 10)

        let single = plan(queue, interval: 300, maxEntries: 1)
        XCTAssertEqual(single.count, 1)
        XCTAssertEqual(single[0].date, now)
    }

    func testEmptyQueueGivesEmptyPlan() {
        let entries = plan([])
        XCTAssertTrue(entries.isEmpty)
        XCTAssertNil(TimelinePlanner.reloadDate(for: entries))
        XCTAssertNil(
            TimelinePlanner.wordAt(now, queue: [], knownIDs: [], cursorOffset: 0, cursorAnchor: now, interval: 3600)
        )
    }

    func testPlanIsDeterministic() {
        let queue = makeWords([1, 2, 3, 4, 5])
        let first = plan(queue, known: [4], cursor: 3, interval: 7200)
        let second = plan(queue, known: [4], cursor: 3, interval: 7200)
        XCTAssertEqual(first.map { $0.date }, second.map { $0.date })
        XCTAssertEqual(ids(first), ids(second))
    }

    func testWholeSecondRounding() {
        let fractional = Date(timeIntervalSince1970: 1_700_000_000.25)
        XCTAssertEqual(TimelinePlanner.roundedDownToWholeSecond(fractional).timeIntervalSince1970, 1_700_000_000, accuracy: 0.0001)
        XCTAssertEqual(TimelinePlanner.roundedDownToWholeSecond(now), now)
    }
}
