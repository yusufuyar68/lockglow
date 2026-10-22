import XCTest
import CoreModels
import Scheduler

/// Edge cases of `TimelinePlanner`: the exact second of a boundary, dates before 1970, time zones
/// and daylight saving time, and out-of-range inputs. Every expected value is worked out by hand
/// in the comments: boundary index = floor((unixTime + alignmentOffset) / interval).
final class TimelineEdgeCaseTests: XCTestCase {
    // 2023-11-14 22:00:00 UTC, an hourly boundary: 1_699_999_200 = 472_222 * 3600 (and 5_666_664 * 300).
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

    private func shownID(
        at date: Date,
        queue: [WidgetWord],
        cursor: Int = 0,
        anchor: Date,
        interval: TimeInterval = 3600,
        offset: TimeInterval = 0
    ) -> Int? {
        return TimelinePlanner.wordAt(
            date,
            queue: queue,
            knownIDs: [],
            cursorOffset: cursor,
            cursorAnchor: anchor,
            interval: interval,
            alignmentOffset: offset
        )?.id
    }

    private func utc(_ seconds: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: seconds)
    }

    // MARK: The boundary second

    func testWordChangesExactlyOnTheBoundarySecond() {
        let queue = makeWords([1, 2, 3])
        // Anchor 21:30:00 -> index floor(1_699_997_400 / 3600) = 472_221.
        let anchor = t0.addingTimeInterval(-1800)
        // 21:59:59 -> floor(1_699_999_199 / 3600) = 472_221: elapsed 0, R[0] = 1.
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(-1), queue: queue, anchor: anchor), 1)
        // 22:00:00 -> 472_222: elapsed 1, R[1] = 2. The word changes ON the boundary second.
        XCTAssertEqual(shownID(at: t0, queue: queue, anchor: anchor), 2)
        // 22:00:00.999 and 22:59:59 are still in 472_222.
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(0.999), queue: queue, anchor: anchor), 2)
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(hour - 1), queue: queue, anchor: anchor), 2)
        // 23:00:00 -> 472_223: elapsed 2, R[2] = 3.
        XCTAssertEqual(shownID(at: t0.addingTimeInterval(hour), queue: queue, anchor: anchor), 3)

        // One second apart, but a boundary lies between them.
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: t0.addingTimeInterval(-1), to: t0, interval: hour), 1)
        // 3599 seconds apart inside one interval: no boundary.
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: t0, to: t0.addingTimeInterval(hour - 1), interval: hour), 0)
    }

    func testRoundingAnAnchorDownNeverMovesItIntoAnotherInterval() {
        // A tap 0.4 s before 22:00 is stored as 21:59:59 (same interval as the tap).
        let beforeBoundary = t0.addingTimeInterval(-0.4)
        let storedBefore = TimelinePlanner.roundedDownToWholeSecond(beforeBoundary)
        XCTAssertEqual(storedBefore, t0.addingTimeInterval(-1))
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: storedBefore, to: beforeBoundary, interval: hour), 0)

        // A tap 0.4 s after 22:00 is stored as 22:00:00 (the boundary itself, same interval).
        let afterBoundary = t0.addingTimeInterval(0.4)
        let storedAfter = TimelinePlanner.roundedDownToWholeSecond(afterBoundary)
        XCTAssertEqual(storedAfter, t0)
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: storedAfter, to: afterBoundary, interval: hour), 0)

        // Floor, not truncation: -0.5 s rounds down to -1 s.
        XCTAssertEqual(TimelinePlanner.roundedDownToWholeSecond(utc(-0.5)), utc(-1))
        // Non-finite dates are returned unchanged instead of trapping.
        XCTAssertEqual(TimelinePlanner.roundedDownToWholeSecond(utc(.infinity)), utc(.infinity))
    }

    func testTimelineThatStartsOnABoundaryHasNoDuplicateEntry() {
        let queue = makeWords([1, 2, 3])
        let anchor = t0.addingTimeInterval(-1800) // 21:30, index 472_221
        // now = 22:00:00 (index 472_222, elapsed 1). Horizon 2 h ends exactly on 00:00.
        let entries = TimelinePlanner.plan(
            queue: queue,
            knownIDs: [],
            cursorOffset: 0,
            cursorAnchor: anchor,
            now: t0,
            interval: hour,
            horizon: 2 * hour
        )
        // 22:00 (elapsed 1 -> 2), 23:00 (elapsed 2 -> 3), 00:00 (elapsed 3 -> R[0] = 1).
        // The boundary equal to the horizon end is included ("date > horizonEnd" stops).
        XCTAssertEqual(entries.map { $0.date }, [t0, t0.addingTimeInterval(hour), t0.addingTimeInterval(2 * hour)])
        XCTAssertEqual(entries.map { $0.word.id }, [2, 3, 1])

        // One second shorter: 00:00 is past the horizon.
        let shorter = TimelinePlanner.plan(
            queue: queue,
            knownIDs: [],
            cursorOffset: 0,
            cursorAnchor: anchor,
            now: t0,
            interval: hour,
            horizon: 2 * hour - 1
        )
        XCTAssertEqual(shorter.count, 2)
    }

    func testZeroOrNegativeHorizonAndEntryLimit() {
        let queue = makeWords([1, 2, 3])
        func count(horizon: TimeInterval, maxEntries: Int) -> Int {
            return TimelinePlanner.plan(
                queue: queue,
                knownIDs: [],
                cursorOffset: 0,
                cursorAnchor: t0,
                now: t0.addingTimeInterval(10),
                interval: hour,
                horizon: horizon,
                maxEntries: maxEntries
            ).count
        }
        // Horizon 0 (and a negative one, treated as 0): only the entry for "now".
        XCTAssertEqual(count(horizon: 0, maxEntries: 96), 1)
        XCTAssertEqual(count(horizon: -100, maxEntries: 96), 1)
        // No entries allowed: empty, not a crash.
        XCTAssertEqual(count(horizon: 48 * hour, maxEntries: 0), 0)
        XCTAssertEqual(count(horizon: 48 * hour, maxEntries: -5), 0)
    }

    // MARK: Dates before 1970 (negative Unix time)

    func testBoundariesBeforeNineteenSeventyUseFloorNotTruncation() {
        // Interval 300 s. Anchor -100 s: floor(-100 / 300) = floor(-0.33) = -1.
        // Date +100 s: floor(100 / 300) = 0. The boundary at 0 was crossed: elapsed 1.
        // (Truncation would give 0 - 0 = 0 and miss it.)
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: utc(-100), to: utc(100), interval: 300), 1)
        // -301 s: floor(-1.003) = -2; -1 s: floor(-0.003) = -1. The boundary at -300 was crossed.
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: utc(-301), to: utc(-1), interval: 300), 1)
        // -299 s and -1 s are both in index -1: nothing crossed.
        XCTAssertEqual(TimelinePlanner.elapsedBoundaries(from: utc(-299), to: utc(-1), interval: 300), 0)

        let queue = makeWords([1, 2, 3])
        XCTAssertEqual(shownID(at: utc(100), queue: queue, anchor: utc(-100), interval: 300), 2)
    }

    // MARK: Out-of-range inputs

    func testExtremeCursorOffsetsWrapWithoutOverflow() {
        let queue = makeWords([1, 2, 3])
        // Int.max = 2^63 - 1. 2^63 mod 3 = 2 (2^odd mod 3), so Int.max mod 3 = 1 -> R starts at index 1.
        XCTAssertEqual(shownID(at: t0, queue: queue, cursor: Int.max, anchor: t0), 2)
        // Int.min = -2^63. Swift's % keeps the sign: -2; positive modulo (-2 + 3) % 3 = 1 -> index 1.
        XCTAssertEqual(shownID(at: t0, queue: queue, cursor: Int.min, anchor: t0), 2)
    }

    func testUnusableIntervalsAreClampedToFiveMinutes() {
        XCTAssertEqual(TimelinePlanner.clampedInterval(.nan), 300)
        XCTAssertEqual(TimelinePlanner.clampedInterval(-.infinity), 300)
        XCTAssertEqual(TimelinePlanner.clampedInterval(-3600), 300)
        XCTAssertEqual(TimelinePlanner.clampedInterval(0), 300)
        XCTAssertEqual(TimelinePlanner.clampedInterval(300), 300)
        XCTAssertEqual(TimelinePlanner.clampedInterval(301), 301)

        // A plan with interval_seconds 0 (or negative) rotates every 300 s.
        // t0 is a multiple of 300, so the next boundary is t0 + 300.
        let queue = makeWords([1, 2, 3])
        for interval: TimeInterval in [0, -3600, .nan] {
            XCTAssertEqual(shownID(at: t0.addingTimeInterval(299), queue: queue, anchor: t0, interval: interval), 1, "\(interval)")
            XCTAssertEqual(shownID(at: t0.addingTimeInterval(300), queue: queue, anchor: t0, interval: interval), 2, "\(interval)")
        }
    }

    // MARK: Time zones

    func testNegativeOffsetPutsTheDailyBoundaryOnLocalMidnight() {
        // New York in winter is UTC-5 (offset -18_000). Local midnight is 05:00 UTC.
        // 2023-11-15 05:00:00 UTC = 1_700_024_400; (1_700_024_400 - 18_000) / 86_400 = 19_676 exactly.
        let midnight = utc(1_700_024_400)
        // Anchor t0 (22:00 UTC = 17:00 local): floor((1_699_999_200 - 18_000) / 86_400) = floor(19_675.7) = 19_675.
        let queue = makeWords([1, 2, 3])
        XCTAssertEqual(shownID(at: midnight.addingTimeInterval(-1), queue: queue, anchor: t0, interval: 86_400, offset: -18_000), 1)
        XCTAssertEqual(shownID(at: midnight, queue: queue, anchor: t0, interval: 86_400, offset: -18_000), 2)
    }

    func testHalfAndQuarterHourZonesChangeOnLocalFullHours() {
        let queue = makeWords([1, 2, 3])
        func secondEntry(offset: TimeInterval) -> Date? {
            let entries = TimelinePlanner.plan(
                queue: queue,
                knownIDs: [],
                cursorOffset: 0,
                cursorAnchor: t0,
                now: t0,
                interval: hour,
                alignmentOffset: offset
            )
            return entries.count > 1 ? entries[1].date : nil
        }
        // India, UTC+5:30 (19_800). t0 = 03:30 local. floor((1_699_999_200 + 19_800) / 3600) = 472_227;
        // next boundary 472_228 * 3600 - 19_800 = 1_700_001_000 = t0 + 30 min (04:00 local).
        XCTAssertEqual(secondEntry(offset: 19_800), t0.addingTimeInterval(1800))
        // Nepal, UTC+5:45 (20_700). floor(1_700_019_900 / 3600) = 472_227;
        // 472_228 * 3600 - 20_700 = 1_700_000_100 = t0 + 15 min (04:00 local).
        XCTAssertEqual(secondEntry(offset: 20_700), t0.addingTimeInterval(900))
    }

    func testLocalAlignmentOffsetSwitchesOnTheExactDaylightSavingSecond() throws {
        let berlin = try XCTUnwrap(TimeZone(identifier: "Europe/Berlin"))
        let newYork = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        let istanbul = try XCTUnwrap(TimeZone(identifier: "Europe/Istanbul"))
        func offset(_ seconds: TimeInterval, _ zone: TimeZone) -> TimeInterval {
            return TimelinePlanner.localAlignmentOffset(for: utc(seconds), timeZone: zone)
        }

        // EU: summer time starts on the last Sunday of March at 01:00 UTC.
        // 2026-03-29 01:00:00 UTC = 1_774_746_000. CET (+1 h) until the second before, then CEST (+2 h).
        XCTAssertEqual(offset(1_774_745_999, berlin), 3600)
        XCTAssertEqual(offset(1_774_746_000, berlin), 7200)
        // ... and ends on the last Sunday of October at 01:00 UTC: 2026-10-25 01:00:00 UTC = 1_792_890_000.
        XCTAssertEqual(offset(1_792_889_999, berlin), 7200)
        XCTAssertEqual(offset(1_792_890_000, berlin), 3600)

        // US: 2nd Sunday of March, 02:00 EST = 07:00 UTC. 2026-03-08 07:00:00 UTC = 1_772_953_200.
        XCTAssertEqual(offset(1_772_953_199, newYork), -18_000)
        XCTAssertEqual(offset(1_772_953_200, newYork), -14_400)
        // 1st Sunday of November, 02:00 EDT = 06:00 UTC. 2026-11-01 06:00:00 UTC = 1_793_512_800.
        XCTAssertEqual(offset(1_793_512_799, newYork), -14_400)
        XCTAssertEqual(offset(1_793_512_800, newYork), -18_000)

        // Turkey has no daylight saving time (UTC+3 all year since 2016):
        // 2026-01-15 00:00 UTC = 1_768_435_200 and 2026-07-15 00:00 UTC = 1_784_073_600.
        XCTAssertEqual(offset(1_768_435_200, istanbul), 10_800)
        XCTAssertEqual(offset(1_784_073_600, istanbul), 10_800)
    }

    /// The app's interval choices of 5, 15, 30 and 60 minutes all divide one hour. A daylight saving
    /// change moves the offset by exactly 3600 s, which adds 3600 / interval (a whole number) to the
    /// anchor's AND the date's boundary index, so the elapsed count and the word never change.
    func testDaylightSavingChangeDoesNotMoveTheWordForIntervalsThatDivideAnHour() {
        let queue = makeWords(Array(1...10))
        // 2026-03-29 00:10:00 UTC (1_774_743_000), 50 minutes before Berlin switches from +1 h to +2 h.
        let anchor = utc(1_774_743_000)
        for interval: TimeInterval in [300, 900, 1800, 3600] {
            // Every 137 s for about 7.6 hours, across the switch at 01:00 UTC.
            for step in 0..<200 {
                let date = anchor.addingTimeInterval(TimeInterval(step * 137))
                XCTAssertEqual(
                    shownID(at: date, queue: queue, anchor: anchor, interval: interval, offset: 3600),
                    shownID(at: date, queue: queue, anchor: anchor, interval: interval, offset: 7200),
                    "interval \(interval), +\(step * 137) s"
                )
            }
        }
        // One case by hand, hourly, at 01:30 UTC (1_774_747_800):
        // offset 3600: anchor floor(1_774_746_600 / 3600) = 492_985, date floor(1_774_751_400 / 3600) = 492_986 -> 1.
        // offset 7200: anchor floor(1_774_750_200 / 3600) = 492_986, date floor(1_774_755_000 / 3600) = 492_987 -> 1.
        XCTAssertEqual(shownID(at: utc(1_774_747_800), queue: queue, anchor: anchor, offset: 3600), 2)
        XCTAssertEqual(shownID(at: utc(1_774_747_800), queue: queue, anchor: anchor, offset: 7200), 2)
    }

    /// Design limit (not a crash): with the 2 hour interval, a daylight saving change moves the
    /// 2 hour grid by one hour, so a timeline rebuilt after the change can show the previous word
    /// once more. The widget always uses `localAlignmentOffset(for: now)`.
    func testDaylightSavingChangeCanRepeatOneWordWithATwoHourInterval() {
        let queue = makeWords(Array(1...10))
        // Anchor 2026-03-29 00:00:00 UTC (1_774_742_400 = 246_492 * 7200), 01:00 in Berlin (CET).
        let anchor = utc(1_774_742_400)
        // 01:30 UTC (1_774_747_800) is 03:30 CEST, just after the switch at 01:00 UTC.
        let afterSwitch = utc(1_774_747_800)

        // Timeline built before the switch (offset 3600, boundaries on odd UTC hours):
        // anchor floor(1_774_746_000 / 7200) = floor(246_492.5) = 246_492,
        // date   floor(1_774_751_400 / 7200) = floor(246_493.25) = 246_493 -> elapsed 1 -> word 2.
        XCTAssertEqual(shownID(at: afterSwitch, queue: queue, anchor: anchor, interval: 7200, offset: 3600), 2)

        // Timeline rebuilt after the switch (offset 7200, boundaries on even UTC hours):
        // anchor floor(1_774_749_600 / 7200) = 246_493,
        // date   floor(1_774_755_000 / 7200) = floor(246_493.75) = 246_493 -> elapsed 0 -> word 1 again.
        XCTAssertEqual(shownID(at: afterSwitch, queue: queue, anchor: anchor, interval: 7200, offset: 7200), 1)

        // From 02:00 UTC (1_774_749_600) both agree again: elapsed 1 -> word 2.
        // offset 3600: floor(1_774_753_200 / 7200) = 246_493; offset 7200: floor(1_774_756_800 / 7200) = 246_494.
        let twoUTC = utc(1_774_749_600)
        XCTAssertEqual(shownID(at: twoUTC, queue: queue, anchor: anchor, interval: 7200, offset: 3600), 2)
        XCTAssertEqual(shownID(at: twoUTC, queue: queue, anchor: anchor, interval: 7200, offset: 7200), 2)
    }
}
