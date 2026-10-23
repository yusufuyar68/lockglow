import XCTest
import CoreModels
import SharedState
import Scheduler

/// `TimelinePlanner.shownWord`, the word the iOS 18 controls read aloud and move past: it must be
/// the word the widget's timeline shows (entry 0 of `WordProvider.makeEntries`, rebuilt below).
final class ShownWordTests: XCTestCase {
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
        anchor: Date? = nil,
        interval: TimeInterval = 3600
    ) -> RotationInput {
        return RotationInput(
            planID: "p",
            queue: makeWords(queueIDs),
            knownIDs: known,
            cursorOffset: cursor,
            cursorAnchor: anchor ?? t0,
            interval: interval,
            isSeed: false
        )
    }

    /// Entry 0 of the widget's timeline: `WordProvider.makeEntries` (Widgets/WordProvider.swift),
    /// which plans again without the known set when every queued word is known.
    private func widgetEntryID(_ input: RotationInput, now: Date, offset: TimeInterval) -> Int? {
        var planned = TimelinePlanner.plan(
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            now: now,
            interval: input.interval,
            alignmentOffset: offset
        )
        if planned.isEmpty {
            planned = TimelinePlanner.plan(
                queue: input.queue,
                knownIDs: [],
                cursorOffset: input.cursorOffset,
                cursorAnchor: input.cursorAnchor,
                now: now,
                interval: input.interval,
                alignmentOffset: offset
            )
        }
        return planned.first?.word.id
    }

    func testMatchesTheWidgetTimelineFirstEntry() {
        let knownSets: [Set<Int>] = [[], [3], [1, 2], [2, 4, 6], [1, 2, 3, 4, 5, 6, 7]]
        let cursors = [0, 1, 6, 7, -3, Int.max]
        let anchors = [t0, t0.addingTimeInterval(-5 * hour - 1), t0.addingTimeInterval(2 * hour + 17)]
        let intervals: [TimeInterval] = [3600, 1800, 14_400, 0, .nan]
        let nows = [
            t0,
            t0.addingTimeInterval(1),
            t0.addingTimeInterval(hour - 1),
            t0.addingTimeInterval(3 * hour + 1234),
            t0.addingTimeInterval(-hour),
            Date(timeIntervalSince1970: 1e20),
        ]
        let offsets: [TimeInterval] = [0, 10_800, -18_000]
        for known in knownSets {
            for cursor in cursors {
                for anchor in anchors {
                    for interval in intervals {
                        let input = makeInput(
                            queueIDs: Array(1...7),
                            known: known,
                            cursor: cursor,
                            anchor: anchor,
                            interval: interval
                        )
                        for now in nows {
                            for offset in offsets {
                                let shown = TimelinePlanner.shownWord(input: input, now: now, alignmentOffset: offset)
                                XCTAssertEqual(
                                    shown?.id,
                                    widgetEntryID(input, now: now, offset: offset),
                                    "known \(known) cursor \(cursor) anchor \(anchor) interval \(interval) now \(now) offset \(offset)"
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    func testEveryWordKnownStillShowsAWord() {
        // Lap from index 0: [1, 2, 3]; two boundaries after the anchor: 3.
        let input = makeInput(queueIDs: [1, 2, 3], known: [1, 2, 3])
        let shown = TimelinePlanner.shownWord(input: input, now: t0.addingTimeInterval(2 * hour + 5))
        XCTAssertEqual(shown?.id, 3)
    }

    func testEmptyQueueShowsNothing() {
        let input = makeInput(queueIDs: [])
        XCTAssertNil(TimelinePlanner.shownWord(input: input, now: t0.addingTimeInterval(hour)))
    }

    /// The "Sonraki kelime" control: "Next" on the shown word, then the widget shows the next word
    /// that is not known, at once.
    func testNextOnTheShownWordShowsTheFollowingWord() throws {
        // Lap from index 0 without 3: [1, 2, 4, 5, 6]. One boundary after the anchor: 2.
        let input = makeInput(queueIDs: [1, 2, 3, 4, 5, 6], known: [3])
        let now = t0.addingTimeInterval(hour + 1800)
        let shown = try XCTUnwrap(TimelinePlanner.shownWord(input: input, now: now))
        XCTAssertEqual(shown.id, 2)

        // Next on 2 (queue index 1): the rotation starts at index 2 now; 3 is known, so 4.
        let cursor = TimelinePlanner.cursorAfterNext(shownWordID: shown.id, input: input, now: now)
        let after = makeInput(
            queueIDs: [1, 2, 3, 4, 5, 6],
            known: [3],
            cursor: cursor.offset,
            anchor: cursor.anchor
        )
        XCTAssertEqual(TimelinePlanner.shownWord(input: after, now: now)?.id, 4)
    }

    /// The control's events carry their own source; the app's mailbox reads them back.
    func testControlEventsRoundTripThroughTheMailbox() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShownWordTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let mailbox = AppGroupStore(containerURL: directory).eventMailbox
        let event = WidgetEvent(type: .next, wordID: 7, at: Date(timeIntervalSince1970: 1_700_000_000), source: .control)
        let url = try mailbox.append(event)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        XCTAssertEqual(object["source"] as? String, "control")
        XCTAssertEqual(try mailbox.list().map(\.event), [event])
    }
}
