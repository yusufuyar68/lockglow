import XCTest
import CoreModels
import SharedState
import Scheduler

/// What the widget meets on a phone in a bad state, through the path its timeline uses
/// (`WordDataSource.load`: read the two files, resolve the rotation; `WordProvider.makeEntries`:
/// plan the entries). Nothing may crash, and the timeline stays within WidgetKit's limits.
final class WidgetCrashScenarioTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_792_749_600)
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WidgetCrashScenarioTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        // A test may have made the folder read-only.
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
        try? FileManager.default.removeItem(at: directory)
    }

    private func word(_ id: Int) -> WidgetWord {
        return WidgetWord(id: id, lemma: "word\(id)", pos: "noun", level: "A1", defMicro: "m", defShort: "s", exampleEN: "We like word\(id).", glossTR: "anlam")
    }

    /// `WordDataSource.load` + `WordProvider.makeEntries` (the widget's files are compiled into
    /// the app's widget extension only, so their two steps are repeated here).
    private func timeline(store: AppGroupStore?, seed: [WidgetWord]) -> [TimelinePlanner.PlannedEntry] {
        let plan = store?.readPlan()
        let state = store?.readState()
        let hasPlan = !(plan?.queue.isEmpty ?? true)
        let input = RotationInput.resolve(plan: plan, state: state, seedWords: hasPlan ? [] : seed)
        let offset = TimelinePlanner.localAlignmentOffset(for: now)
        let planned = TimelinePlanner.plan(queue: input.queue, knownIDs: input.knownIDs, cursorOffset: input.cursorOffset, cursorAnchor: input.cursorAnchor, now: now, interval: input.interval, alignmentOffset: offset)
        if planned.isEmpty {
            return TimelinePlanner.plan(queue: input.queue, knownIDs: [], cursorOffset: input.cursorOffset, cursorAnchor: input.cursorAnchor, now: now, interval: input.interval, alignmentOffset: offset)
        }
        return planned
    }

    private func assertWithinLimits(_ entries: [TimelinePlanner.PlannedEntry], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertLessThanOrEqual(entries.count, TimelinePlanner.defaultMaxEntries, file: file, line: line)
        if let last = entries.last {
            XCTAssertLessThanOrEqual(last.date.timeIntervalSince(now), TimelinePlanner.defaultHorizon, file: file, line: line)
        }
    }

    // MARK: First launch, no App Group

    /// The widget was added before the app was ever opened: no plan, no state. The bundled seed
    /// words rotate; without them (a damaged bundle) there are no entries and the provider shows
    /// its static sample (`WordProvider.getTimeline`).
    func testFirstLaunchWithoutContent() {
        let store = AppGroupStore(containerURL: directory)
        let seed = (1...5).map(word)
        let fromSeed = timeline(store: store, seed: seed)
        XCTAssertFalse(fromSeed.isEmpty)
        XCTAssertTrue(fromSeed.allSatisfy { entry in seed.contains(entry.word) })
        assertWithinLimits(fromSeed)
        XCTAssertTrue(timeline(store: store, seed: []).isEmpty)
    }

    /// The App Group container is unavailable (missing entitlement): no store at all.
    func testMissingAppGroupRotatesTheSeed() {
        let seed = (1...3).map(word)
        let entries = timeline(store: nil, seed: seed)
        XCTAssertFalse(entries.isEmpty)
        XCTAssertTrue(entries.allSatisfy { entry in seed.contains(entry.word) })
        XCTAssertTrue(timeline(store: nil, seed: []).isEmpty)
    }

    /// Every queued word marked known on the widget: words keep coming (the known ones again).
    func testEveryQueuedWordKnownStillGivesEntries() throws {
        let store = AppGroupStore(containerURL: directory)
        let queue = (1...4).map(word)
        let plan = WidgetPlan(planID: "p", isPremium: false, intervalSeconds: 3600, queue: queue, updatedAt: now)
        try store.writePlan(plan)
        try store.writeState(WidgetState(planID: "p", cursorOffset: 2, cursorAnchor: now, knownIDs: queue.map { $0.id }, updatedAt: now))
        let entries = timeline(store: store, seed: [])
        XCTAssertFalse(entries.isEmpty)
        assertWithinLimits(entries)
    }

    // MARK: Damaged files

    /// A plan cut off at any byte (a full disk during a non-atomic copy, a damaged backup restore)
    /// or with wrong values reads as "no plan" or as a usable plan, never as a crash.
    func testDamagedPlanFilesNeverCrashTheTimeline() throws {
        let store = AppGroupStore(containerURL: directory)
        let good = WidgetPlan(planID: "p", isPremium: false, intervalSeconds: 1800, queue: (1...96).map(word), updatedAt: now)
        try store.writePlan(good)
        let bytes = try Data(contentsOf: store.planURL)
        let seed = (1...3).map(word)
        for cut in stride(from: 0, to: bytes.count, by: max(1, bytes.count / 60)) {
            try bytes.prefix(cut).write(to: store.planURL)
            assertWithinLimits(timeline(store: store, seed: seed))
        }
        let odd = [
            #"{"version":1,"plan_id":"p","is_premium":false,"interval_seconds":0,"queue":[],"updated_at":"2026-10-23T10:00:00Z"}"#,
            #"{"version":1,"plan_id":"p","is_premium":false,"interval_seconds":-60,"queue":[{"id":1,"lemma":"a","pos":"n","level":"A1","def_micro":"m","def_short":"s","example_en":"e"}],"updated_at":"2026-10-23T10:00:00Z"}"#,
            #"{"version":1,"plan_id":"p","is_premium":false,"interval_seconds":9223372036854775807,"queue":[{"id":1,"lemma":"a","pos":"n","level":"A1","def_micro":"m","def_short":"s","example_en":"e"}],"updated_at":"9999-12-31T23:59:59Z"}"#,
            #"{"version":1,"plan_id":"p","is_premium":false,"interval_seconds":3600,"queue":[{"id":-5,"lemma":"","pos":"","level":"","def_micro":"","def_short":"","example_en":""}],"updated_at":"0001-01-01T00:00:00Z"}"#,
            #"{"queue": "not a list"}"#,
            "\u{0}\u{1}\u{2}",
            "",
        ]
        for text in odd {
            try Data(text.utf8).write(to: store.planURL)
            assertWithinLimits(timeline(store: store, seed: seed))
        }
    }

    /// A state with a cursor or an anchor far out of range (a clock set to another century).
    func testExtremeStateValuesNeverCrashTheTimeline() throws {
        let store = AppGroupStore(containerURL: directory)
        try store.writePlan(WidgetPlan(planID: "p", isPremium: false, intervalSeconds: 3600, queue: (1...10).map(word), updatedAt: now))
        let anchors = [Date.distantPast, Date.distantFuture, Date(timeIntervalSince1970: -1e12), Date(timeIntervalSince1970: 1e12), now]
        for offset in [Int.min, -1, 0, 7, Int.max] {
            for anchor in anchors {
                try store.writeState(WidgetState(planID: "p", cursorOffset: offset, cursorAnchor: anchor, knownIDs: [1, 2, 3], updatedAt: now))
                let entries = timeline(store: store, seed: [])
                XCTAssertFalse(entries.isEmpty)
                assertWithinLimits(entries)
            }
        }
    }

    /// A plan far larger than the app writes (96 words): the timeline is still at most 96 entries.
    func testAnOversizedPlanGivesABoundedTimeline() throws {
        let store = AppGroupStore(containerURL: directory)
        try store.writePlan(WidgetPlan(planID: "big", isPremium: false, intervalSeconds: 300, queue: (1...5000).map(word), updatedAt: now))
        let entries = timeline(store: store, seed: [])
        XCTAssertEqual(entries.count, TimelinePlanner.defaultMaxEntries)
        assertWithinLimits(entries)
    }

    // MARK: Low storage

    /// A plan write that fails (no space left: here a read-only folder) leaves the previous plan
    /// whole: the write is atomic, and the widget keeps rotating the old plan.
    func testAFailedPlanWriteKeepsThePreviousPlan() throws {
        let store = AppGroupStore(containerURL: directory)
        let old = WidgetPlan(planID: "old", isPremium: false, intervalSeconds: 3600, queue: (1...5).map(word), updatedAt: now)
        try store.writePlan(old)
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: directory.path)
        // The Linux check runs as root in Docker, where a read-only folder is still writable.
        let probe = directory.appendingPathComponent("probe")
        if FileManager.default.createFile(atPath: probe.path, contents: Data()) {
            try? FileManager.default.removeItem(at: probe)
            throw XCTSkip("folder permissions are not enforced here (root)")
        }
        let new = WidgetPlan(planID: "new", isPremium: false, intervalSeconds: 3600, queue: (6...9).map(word), updatedAt: now)
        XCTAssertThrowsError(try store.writePlan(new))
        XCTAssertEqual(store.readPlan(), old)
        XCTAssertThrowsError(try store.writeState(WidgetState(planID: "old", cursorOffset: 1, cursorAnchor: now, knownIDs: [], updatedAt: now)))
        XCTAssertThrowsError(try store.eventMailbox.append(WidgetEvent(type: .next, wordID: 1, at: now, source: .systemSmall)))
        XCTAssertFalse(timeline(store: store, seed: []).isEmpty)
    }
}
