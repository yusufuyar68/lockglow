import XCTest
import Dispatch
import CoreModels
import SharedState

/// `AppGroupStore` with damaged files, odd file system states and concurrent writers.
/// Contract: reads are best effort (nil for missing or undecodable files), writes are atomic.
final class AppGroupStoreEdgeTests: XCTestCase {
    private var directory: URL!
    // Whole seconds only: the ISO 8601 coding has no fractional seconds.
    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14T22:13:20Z

    override func setUpWithError() throws {
        directory = try makeTemporaryDirectory("AppGroupStoreEdgeTests")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func makePlan(_ number: Int, words: Int = 3) -> WidgetPlan {
        return WidgetPlan(
            planID: "plan-\(number)",
            isPremium: false,
            intervalSeconds: 3600,
            queue: (0..<words).map { makeTestWord(number * 1000 + $0) },
            updatedAt: fixedDate.addingTimeInterval(TimeInterval(number))
        )
    }

    private func makeState(_ number: Int) -> WidgetState {
        return WidgetState(
            planID: "plan-1",
            cursorOffset: number,
            cursorAnchor: fixedDate.addingTimeInterval(TimeInterval(number)),
            knownIDs: Array(0..<(number % 5)),
            updatedAt: fixedDate.addingTimeInterval(TimeInterval(number))
        )
    }

    private let validPlanJSON = """
        {"version":1,"plan_id":"p","is_premium":false,"interval_seconds":3600,"updated_at":"2023-11-14T22:13:20Z",\
        "queue":[{"id":1,"lemma":"word1","pos":"n","level":"A1","def_micro":"micro","def_short":"short",\
        "example_en":"example","gloss_tr":"tr"}]}
        """

    private let validStateJSON = """
        {"version":1,"plan_id":"p","cursor_offset":2,"cursor_anchor":"2023-11-14T22:13:20Z","known_ids":[5,7],\
        "updated_at":"2023-11-14T22:13:20Z"}
        """

    // MARK: Damaged JSON

    func testTheValidSamplesDecode() throws {
        // Guard for the tests below: the damaged variants differ from these in one place each.
        let store = AppGroupStore(containerURL: directory)
        try Data(validPlanJSON.utf8).write(to: store.planURL)
        try Data(validStateJSON.utf8).write(to: store.stateURL)
        XCTAssertEqual(
            store.readPlan(),
            WidgetPlan(planID: "p", isPremium: false, intervalSeconds: 3600, queue: [makeTestWord(1)], updatedAt: fixedDate)
        )
        XCTAssertEqual(
            store.readState(),
            WidgetState(planID: "p", cursorOffset: 2, cursorAnchor: fixedDate, knownIDs: [5, 7], updatedAt: fixedDate)
        )
    }

    func testDamagedPlanFilesReadAsNil() throws {
        let store = AppGroupStore(containerURL: directory)
        let variants: [(name: String, data: Data)] = [
            ("empty file", Data()),
            ("null", Data("null".utf8)),
            ("array", Data("[]".utf8)),
            ("cut in half (interrupted non-atomic write)", Data(validPlanJSON.utf8.prefix(validPlanJSON.utf8.count / 2))),
            ("valid plan followed by leftover bytes", Data((validPlanJSON + "}]}").utf8)),
            ("queue missing", Data(validPlanJSON.replacingOccurrences(of: "\"queue\"", with: "\"queues\"").utf8)),
            ("date as a number", Data(validPlanJSON.replacingOccurrences(of: "\"2023-11-14T22:13:20Z\"", with: "1700000000").utf8)),
            ("date not ISO 8601", Data(validPlanJSON.replacingOccurrences(of: "2023-11-14T22:13:20Z", with: "yesterday").utf8)),
            ("interval as a string", Data(validPlanJSON.replacingOccurrences(of: ":3600", with: ":\"3600\"").utf8)),
            ("plan_id null", Data(validPlanJSON.replacingOccurrences(of: "\"p\"", with: "null").utf8)),
            ("word without lemma", Data(validPlanJSON.replacingOccurrences(of: "\"lemma\":\"word1\",", with: "").utf8)),
            ("not UTF-8", Data([0x7B, 0x22, 0xC3, 0x28, 0x22, 0x3A, 0x31, 0x7D])),
        ]
        for variant in variants {
            try variant.data.write(to: store.planURL)
            XCTAssertNil(store.readPlan(), variant.name)
        }
    }

    func testDamagedStateFilesReadAsNil() throws {
        let store = AppGroupStore(containerURL: directory)
        let variants: [(name: String, json: String)] = [
            ("fractional offset", validStateJSON.replacingOccurrences(of: "\"cursor_offset\":2", with: "\"cursor_offset\":2.5")),
            ("offset beyond Int", validStateJSON.replacingOccurrences(of: "\"cursor_offset\":2", with: "\"cursor_offset\":99999999999999999999")),
            ("known ids as strings", validStateJSON.replacingOccurrences(of: "[5,7]", with: "[\"5\",\"7\"]")),
            ("anchor missing", validStateJSON.replacingOccurrences(of: "\"cursor_anchor\"", with: "\"anchor\"")),
            ("anchor not a date", validStateJSON.replacingOccurrences(of: "\"cursor_anchor\":\"2023-11-14T22:13:20Z\"", with: "\"cursor_anchor\":\"soon\"")),
            ("plan_id missing", validStateJSON.replacingOccurrences(of: "\"plan_id\":\"p\",", with: "")),
        ]
        for variant in variants {
            XCTAssertNotEqual(variant.json, validStateJSON, "the replacement did not apply: \(variant.name)")
            try Data(variant.json.utf8).write(to: store.stateURL)
            XCTAssertNil(store.readState(), variant.name)
        }
    }

    func testUnknownKeysAndPrettyPrintingAreAccepted() throws {
        // A newer app version may add keys; an older widget must still read the file.
        let store = AppGroupStore(containerURL: directory)
        let json = """
            {
              "future_setting" : { "a" : [1, 2] },
              "queue" : [
                { "id" : 1, "lemma" : "word1", "pos" : "n", "level" : "A1", "def_micro" : "micro",
                  "def_short" : "short", "example_en" : "example", "gloss_tr" : "tr", "audio" : "word1.m4a" }
              ],
              "updated_at" : "2023-11-14T22:13:20Z",
              "interval_seconds" : 3600,
              "is_premium" : false,
              "plan_id" : "p",
              "version" : 1
            }
            """
        try Data(json.utf8).write(to: store.planURL)
        XCTAssertEqual(
            store.readPlan(),
            WidgetPlan(planID: "p", isPremium: false, intervalSeconds: 3600, queue: [makeTestWord(1)], updatedAt: fixedDate)
        )
    }

    // MARK: Odd file system states

    func testADirectoryInPlaceOfThePlanFileReadsAsNilAndWritingThrows() throws {
        let store = AppGroupStore(containerURL: directory)
        try FileManager.default.createDirectory(at: store.planURL, withIntermediateDirectories: true)
        XCTAssertNil(store.readPlan())
        XCTAssertThrowsError(try store.writePlan(makePlan(1)))
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.planURL.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
    }

    func testAFileInPlaceOfTheContainerMakesWritesThrowAndReadsNil() throws {
        let fileContainer = directory.appendingPathComponent("not-a-folder")
        try Data("x".utf8).write(to: fileContainer)
        let store = AppGroupStore(containerURL: fileContainer)
        XCTAssertThrowsError(try store.writeState(makeState(1)))
        XCTAssertThrowsError(try store.writePlan(makePlan(1)))
        XCTAssertNil(store.readState())
        XCTAssertNil(store.readPlan())
    }

    func testAShorterPlanReplacesTheWholeLongerFile() throws {
        // An in-place write without truncation would leave the tail of the long plan behind
        // (see "valid plan followed by leftover bytes" above). Atomic writes replace the file.
        let store = AppGroupStore(containerURL: directory)
        let long = makePlan(1, words: 200)
        let short = makePlan(2, words: 1)
        try store.writePlan(long)
        let longSize = try Data(contentsOf: store.planURL).count
        try store.writePlan(short)
        XCTAssertEqual(store.readPlan(), short)
        XCTAssertLessThan(try Data(contentsOf: store.planURL).count, longSize / 10)
    }

    // MARK: Concurrent writers

    func testConcurrentPlanWritesNeverExposeAHalfWrittenFile() throws {
        let store = AppGroupStore(containerURL: directory)
        let plans = (0..<40).map { makePlan($0, words: 60) }
        let byID = Dictionary(uniqueKeysWithValues: plans.map { ($0.planID, $0) })
        try store.writePlan(plans[0])
        let log = ConcurrentLog()

        // 8 writers share the 40 plans; 4 readers read 100 times each meanwhile.
        DispatchQueue.concurrentPerform(iterations: 12) { worker in
            if worker < 8 {
                for index in stride(from: worker, to: plans.count, by: 8) {
                    do {
                        try store.writePlan(plans[index])
                    } catch {
                        log.add("write \(index) failed: \(error)")
                    }
                }
            } else {
                for attempt in 0..<100 {
                    // Never missing (a plan existed before), never damaged, never a mix of two plans.
                    guard let read = store.readPlan() else {
                        log.add("read \(attempt) by \(worker): nil")
                        continue
                    }
                    if byID[read.planID] != read {
                        log.add("read \(attempt) by \(worker): \(read.planID) differs from what was written")
                    }
                }
            }
        }
        XCTAssertEqual(log.items, [])
        let last = try XCTUnwrap(store.readPlan())
        XCTAssertEqual(byID[last.planID], last)
    }

    func testAppAndWidgetWritingAtTheSameTimeDoNotDisturbEachOther() throws {
        // Single-writer rule: the app writes the plan, the widget the state, at any moment.
        let store = AppGroupStore(containerURL: directory)
        let plans = (0..<30).map { makePlan($0, words: 20) }
        let states = (0..<30).map { makeState($0) }
        let log = ConcurrentLog()
        DispatchQueue.concurrentPerform(iterations: 2) { worker in
            for index in 0..<30 {
                do {
                    if worker == 0 {
                        try store.writePlan(plans[index])
                    } else {
                        try store.writeState(states[index])
                    }
                } catch {
                    log.add("worker \(worker), write \(index) failed: \(error)")
                }
            }
        }
        XCTAssertEqual(log.items, [])
        XCTAssertEqual(store.readPlan(), plans[29])
        XCTAssertEqual(store.readState(), states[29])
    }
}
