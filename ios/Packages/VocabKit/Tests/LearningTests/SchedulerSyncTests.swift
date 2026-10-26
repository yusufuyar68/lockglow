import XCTest
import CoreModels
import Learning

/// iCloud sync between a device on FSRS and one on Leitner (the setting itself is not synced).
/// The app passes every sync through `FSRSMigration.adopted(_:local:by:)` before it saves it
/// (`AppModel.syncWithCloud`): Leitner never keeps FSRS's long waits, it never sends its earlier
/// dates back, and FSRS takes the records as they come.
final class SchedulerSyncTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_760_011_200)
    private let day: TimeInterval = 86_400

    private func at(days: Double) -> Date {
        return start.addingTimeInterval(days * day)
    }

    /// One device: its progress, its sync state and the scheduler it runs.
    private struct Device {
        let kind: SchedulerKind
        var progress: [Int: WordProgress] = [:]
        var state = SyncState()
    }

    /// iCloud's copy, as the last upload left it.
    private var cloud: SyncSnapshot?
    /// The time of each sync: one second apart, after every answer of the tests.
    private var clock = Date(timeIntervalSince1970: 1_800_000_000)

    override func setUp() {
        super.setUp()
        cloud = nil
        clock = Date(timeIntervalSince1970: 1_800_000_000)
    }

    /// One sync as `AppModel+Sync.swift` runs it. `merged`: the progress the merge alone gave
    /// (nil when nothing changed); `saved`: what this device saved after the guard (nil: nothing).
    @discardableResult
    private func sync(_ device: inout Device) throws -> (merged: [Int: WordProgress]?, saved: [Int: WordProgress]?) {
        clock = clock.addingTimeInterval(1)
        let raw = SyncMerge.sync(
            progress: device.progress,
            words: CustomWordList(),
            remote: cloud,
            state: device.state,
            now: clock,
            makeUUID: { UUID().uuidString }
        )
        let result = FSRSMigration.adopted(raw, local: device.progress, by: device.kind)
        if let saved = result.progress {
            device.progress = saved
        }
        device.state = result.state
        if let upload = result.upload {
            cloud = try SyncSnapshot.decode(upload.encoded())
        }
        return (raw.progress, result.progress)
    }

    /// A word FSRS answered last (its memory counts every answer), due on `dueAt`.
    private func answeredByFSRS(_ id: Int, state: LearningState, box: Int, dueAt: Date, refresherStep: Int? = nil, stability: Double) -> WordProgress {
        var p = WordProgress(wordID: id)
        p.state = state
        p.box = box
        p.reviews = 7
        p.lapses = 1
        p.dueAt = dueAt
        p.refresherStep = refresherStep
        p.firstReviewedAt = at(days: -90)
        p.lastSeenAt = start
        p.lastReviewedAt = start
        p.lastGrade = .good
        p.fsrs = FSRSState(
            stability: stability, difficulty: 4, phase: .review, step: nil, lastReviewAt: start, reviews: 7,
            shelfBefore: ProgressSummary.Shelf.box5.rawValue
        )
        return p
    }

    /// Device A on FSRS: a known word FSRS gave 200 days (Leitner's step 1: 60), a new word's
    /// first "Bildim" (FSRS: 2 days, Leitner: 1) and a word Leitner answered.
    private func fsrsDevice() -> Device {
        var a = Device(kind: .fsrs)
        a.progress[1] = answeredByFSRS(1, state: .known, box: 5, dueAt: at(days: 200), refresherStep: 1, stability: 210)
        a.progress[2] = FSRSScheduler().review(WordProgress(wordID: 2), grade: .good, at: start)
        a.progress[3] = Leitner.review(WordProgress(wordID: 3), grade: .good, at: start)
        return a
    }

    func testALeitnerDeviceNeverKeepsFSRSWaits() throws {
        var a = fsrsDevice()
        try sync(&a)
        try sync(&a)
        var b = Device(kind: .leitner)

        let merged = try XCTUnwrap(try sync(&b).merged)

        // What the merge alone would have left: FSRS's dates.
        XCTAssertEqual(merged[1]?.dueAt, at(days: 200))
        XCTAssertEqual(merged[2]?.dueAt, at(days: 2))
        // What Leitner keeps: its own longest wait for each step.
        XCTAssertEqual(b.progress[1]?.dueAt, start.addingTimeInterval(Leitner.refresherWait(step: 1)))
        XCTAssertEqual(b.progress[2]?.dueAt, at(days: 1))
        XCTAssertEqual(b.progress[3], merged[3], "Leitner's own date stays")
        // Only the due date changes: step, "Yerleşti", counters and the memory come as they are.
        XCTAssertEqual(Set(b.progress.keys), Set(merged.keys))
        for (id, came) in merged {
            var kept = try XCTUnwrap(b.progress[id], "word \(id)")
            kept.dueAt = came.dueAt
            XCTAssertEqual(kept, came, "word \(id)")
        }
    }

    func testAnFSRSDeviceTakesTheRecordsAsTheyCome() throws {
        var a = fsrsDevice()
        try sync(&a)
        try sync(&a)
        var c = Device(kind: .fsrs)

        let merged = try XCTUnwrap(try sync(&c).merged)

        XCTAssertEqual(c.progress, merged)
        XCTAssertEqual(c.progress[1]?.dueAt, at(days: 200))
        XCTAssertEqual(FSRSMigration.adopted(merged, by: .fsrs), merged)
    }

    func testTheGuardChangesNothingTwice() {
        let progress = fsrsDevice().progress
        let once = FSRSMigration.adopted(progress, by: .leitner)
        XCTAssertNotEqual(once, progress)
        XCTAssertEqual(once, FSRSMigration.handBack(progress))
        XCTAssertEqual(FSRSMigration.adopted(once, by: .leitner), once)
        XCTAssertEqual(FSRSMigration.adopted([:], by: .leitner), [:])
    }

    func testTheGuardLeavesFSRSResultsAlone() throws {
        var a = fsrsDevice()
        try sync(&a)
        clock = clock.addingTimeInterval(1)
        let raw = SyncMerge.sync(progress: a.progress, words: CustomWordList(), remote: cloud, state: a.state, now: clock)
        XCTAssertEqual(FSRSMigration.adopted(raw, local: a.progress, by: .fsrs), raw)
    }

    /// The Leitner device's earlier dates stay on it: they never reach iCloud nor the FSRS device,
    /// and later syncs save nothing and upload nothing (no sync loop).
    func testTheFSRSDeviceKeepsItsWaits() throws {
        var a = fsrsDevice()
        try sync(&a)
        try sync(&a)
        let fsrsCopy = a.progress
        let uploaded = cloud
        var b = Device(kind: .leitner)
        try sync(&b)
        let leitnerCopy = b.progress
        XCTAssertNotEqual(leitnerCopy, fsrsCopy)
        XCTAssertEqual(cloud, uploaded, "the earlier dates are not uploaded")
        XCTAssertEqual(b.state.base?.cards.first(where: { $0.progress.wordID == 1 })?.progress.dueAt, leitnerCopy[1]?.dueAt,
                       "the base holds them, so they do not count as a change made here")

        for _ in 0..<2 {
            XCTAssertNil(try sync(&b).saved)
            XCTAssertNil(try sync(&a).merged)
        }
        XCTAssertEqual(a.progress, fsrsCopy)
        XCTAssertEqual(a.progress[1]?.dueAt, at(days: 200))
        XCTAssertEqual(b.progress, leitnerCopy)
        XCTAssertEqual(cloud, uploaded)

        // A new FSRS answer on A goes to B with Leitner's wait, and A keeps its own.
        let later = at(days: 70)
        let word = try XCTUnwrap(a.progress[1])
        a.progress[1] = FSRSScheduler().review(word, grade: .good, at: later)
        let fsrsDue = try XCTUnwrap(a.progress[1]?.dueAt)
        let cap = later.addingTimeInterval(Leitner.refresherWait(step: a.progress[1]?.refresherStep ?? 0))
        XCTAssertGreaterThan(fsrsDue, cap, "FSRS waits longer than Leitner would")
        try sync(&a)
        try sync(&b)
        XCTAssertEqual(b.progress[1]?.dueAt, cap)
        XCTAssertEqual(b.progress[1]?.reviews, a.progress[1]?.reviews)
        try sync(&b)
        try sync(&a)
        XCTAssertEqual(a.progress[1]?.dueAt, fsrsDue)

        // An answer on B itself is B's own change: it goes to iCloud and to A as usual.
        let own = try XCTUnwrap(b.progress[3])
        b.progress[3] = Leitner.review(own, grade: .good, at: at(days: 75))
        try sync(&b)
        try sync(&a)
        XCTAssertEqual(a.progress[3], b.progress[3])
    }
}
