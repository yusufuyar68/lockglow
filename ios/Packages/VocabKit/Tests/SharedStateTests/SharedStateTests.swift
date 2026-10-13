import XCTest
import CoreModels
import SharedState

final class SharedStateTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SharedStateTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    // Whole seconds only: the ISO 8601 coding has no fractional seconds.
    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    private func makeWord(_ id: Int) -> WidgetWord {
        return WidgetWord(
            id: id,
            lemma: "word\(id)",
            pos: "n",
            level: "A1",
            ipaUS: nil,
            defMicro: "micro",
            defShort: "short",
            exampleEN: "example",
            glossTR: "tr"
        )
    }

    // MARK: Plan and state

    func testPlanRoundTrip() throws {
        let store = AppGroupStore(containerURL: directory)
        XCTAssertNil(store.readPlan())

        let plan = WidgetPlan(
            planID: "plan-1",
            isPremium: false,
            intervalSeconds: 3600,
            queue: [makeWord(1), makeWord(2)],
            updatedAt: fixedDate
        )
        try store.writePlan(plan)
        XCTAssertEqual(store.readPlan(), plan)
    }

    func testPlanJSONUsesContractKeys() throws {
        let store = AppGroupStore(containerURL: directory)
        let plan = WidgetPlan(planID: "p", isPremium: true, intervalSeconds: 600, queue: [makeWord(1)], updatedAt: fixedDate)
        try store.writePlan(plan)

        let data = try Data(contentsOf: store.planURL)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        for key in ["version", "plan_id", "is_premium", "interval_seconds", "queue", "updated_at"] {
            XCTAssertNotNil(object[key], "missing key \(key)")
        }
        XCTAssertEqual(object["version"] as? Int, 1)
        XCTAssertEqual(object["plan_id"] as? String, "p")
        XCTAssertEqual(object["updated_at"] as? String, "2023-11-14T22:13:20Z")
    }

    func testStateRoundTripAndKnownIDs() throws {
        let store = AppGroupStore(containerURL: directory)
        XCTAssertNil(store.readState())

        var state = WidgetState(planID: "plan-1", cursorOffset: 3, cursorAnchor: fixedDate, knownIDs: [5], updatedAt: fixedDate)
        state.markKnown(7)
        state.markKnown(7)
        XCTAssertEqual(state.knownIDs, [5, 7])

        try store.writeState(state)
        XCTAssertEqual(store.readState(), state)

        let data = try Data(contentsOf: store.stateURL)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        for key in ["version", "plan_id", "cursor_offset", "cursor_anchor", "known_ids", "updated_at"] {
            XCTAssertNotNil(object[key], "missing key \(key)")
        }
        XCTAssertEqual(object["cursor_anchor"] as? String, "2023-11-14T22:13:20Z")
    }

    func testCorruptFilesReadAsNil() throws {
        let store = AppGroupStore(containerURL: directory)
        try Data("not json".utf8).write(to: store.planURL)
        try Data("{}".utf8).write(to: store.stateURL)
        XCTAssertNil(store.readPlan())
        XCTAssertNil(store.readState())
    }

    func testWriteCreatesMissingContainerDirectory() throws {
        let nested = directory.appendingPathComponent("not/yet/created", isDirectory: true)
        let store = AppGroupStore(containerURL: nested)
        try store.writeState(WidgetState(planID: "x", cursorOffset: 0, cursorAnchor: fixedDate, knownIDs: [], updatedAt: fixedDate))
        XCTAssertNotNil(store.readState())
    }

    // MARK: Event mailbox

    func testMailboxAppendListDelete() throws {
        let store = AppGroupStore(containerURL: directory)
        let mailbox = store.eventMailbox
        XCTAssertTrue(try mailbox.list().isEmpty)

        let first = WidgetEvent(type: .next, wordID: 1, at: Date(timeIntervalSince1970: 1_700_000_000), source: .systemSmall)
        let second = WidgetEvent(type: .known, wordID: 2, at: Date(timeIntervalSince1970: 1_700_000_005), source: .systemMedium)
        // Appended out of order on purpose: listing must sort by timestamp prefix.
        try mailbox.append(second)
        try mailbox.append(first)

        let stored = try mailbox.list()
        XCTAssertEqual(stored.map { $0.event }, [first, second])

        for item in stored {
            try mailbox.delete(item)
        }
        XCTAssertTrue(try mailbox.list().isEmpty)
    }

    func testMailboxFileNameFormat() throws {
        let mailbox = AppGroupStore(containerURL: directory).eventMailbox
        let event = WidgetEvent(type: .reveal, wordID: 9, at: Date(timeIntervalSince1970: 1_700_000_000), source: .accessoryRectangular)
        let url = try mailbox.append(event)
        let name = url.lastPathComponent
        XCTAssertTrue(name.hasPrefix("1700000000000-"), name)
        XCTAssertTrue(name.hasSuffix(".json"), name)
        let uuidPart = String(name.dropFirst("1700000000000-".count).dropLast(".json".count))
        XCTAssertNotNil(UUID(uuidString: uuidPart), name)
    }

    func testMailboxEventJSONUsesContractKeys() throws {
        let mailbox = AppGroupStore(containerURL: directory).eventMailbox
        let event = WidgetEvent(type: .known, wordID: 42, at: Date(timeIntervalSince1970: 1_700_000_000), source: .accessoryInline)
        let url = try mailbox.append(event)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        XCTAssertEqual(object["type"] as? String, "known")
        XCTAssertEqual(object["word_id"] as? Int, 42)
        XCTAssertEqual(object["source"] as? String, "accessory_inline")
        XCTAssertEqual(object["at"] as? String, "2023-11-14T22:13:20Z")
    }

    func testUndecodableEventFilesAreSkippedAndCanBePurged() throws {
        let mailbox = AppGroupStore(containerURL: directory).eventMailbox
        let good = WidgetEvent(type: .next, wordID: 1, at: fixedDate, source: .systemSmall)
        try mailbox.append(good)
        try FileManager.default.createDirectory(at: mailbox.directory, withIntermediateDirectories: true)
        try Data("garbage".utf8).write(to: mailbox.directory.appendingPathComponent("1-bad.json"))

        XCTAssertEqual(try mailbox.list().map { $0.event }, [good])
        XCTAssertEqual(mailbox.deleteUndecodableFiles(), 1)
        XCTAssertEqual(try mailbox.list().map { $0.event }, [good])
        XCTAssertEqual(mailbox.deleteUndecodableFiles(), 0)
    }

    func testAppGroupLocatorRejectsMissingOrUnexpandedIdentifier() {
        // The test bundle has no WGAppGroupID key.
        XCTAssertNil(AppGroupLocator.groupIdentifier(bundle: Bundle(for: SharedStateTests.self)))
    }
}
