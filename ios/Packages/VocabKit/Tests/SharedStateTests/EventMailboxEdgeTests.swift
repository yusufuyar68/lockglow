import XCTest
import Dispatch
import CoreModels
import SharedState

/// `EventMailbox` with damaged files, odd file system states and concurrent use: the widget
/// appends while the app lists, purges and deletes.
final class EventMailboxEdgeTests: XCTestCase {
    private var directory: URL!
    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14T22:13:20Z

    override func setUpWithError() throws {
        directory = try makeTemporaryDirectory("EventMailboxEdgeTests")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private var mailbox: EventMailbox {
        return AppGroupStore(containerURL: directory).eventMailbox
    }

    private func names(in folder: URL) throws -> Set<String> {
        return Set(try FileManager.default.contentsOfDirectory(atPath: folder.path))
    }

    // MARK: Damaged and foreign files

    func testDamagedEventFilesAreSkippedThenPurgedButOtherFilesAreLeftAlone() throws {
        let mailbox = self.mailbox
        let good = WidgetEvent(type: .known, wordID: 7, at: fixedDate, source: .accessoryRectangular)
        let goodURL = try mailbox.append(good)
        let folder = mailbox.directory

        let valid = #"{"type":"next","word_id":1,"at":"2023-11-14T22:13:20Z","source":"system_small"}"#
        let damaged: [(file: String, data: Data)] = [
            ("1-empty.json", Data()),
            ("2-null.json", Data("null".utf8)),
            ("3-cut.json", Data(valid.utf8.prefix(30))),
            ("4-unknown-type.json", Data(valid.replacingOccurrences(of: "\"next\"", with: "\"skip\"").utf8)),
            ("5-string-id.json", Data(valid.replacingOccurrences(of: ":1,", with: ":\"1\",").utf8)),
            ("6-no-source.json", Data(valid.replacingOccurrences(of: ",\"source\":\"system_small\"", with: "").utf8)),
            ("7-number-date.json", Data(valid.replacingOccurrences(of: "\"2023-11-14T22:13:20Z\"", with: "1700000000").utf8)),
            ("8-not-utf8.json", Data([0x7B, 0x22, 0xC3, 0x28, 0x22, 0x7D])),
        ]
        for item in damaged {
            XCTAssertNotEqual(item.data, Data(valid.utf8), item.file)
            try item.data.write(to: folder.appendingPathComponent(item.file))
        }
        // Not event files: another extension, an atomic-write temporary file, and a folder whose
        // name ends in .json (it cannot be read as data, like a file locked by data protection).
        try Data("garbage".utf8).write(to: folder.appendingPathComponent("notes.txt"))
        try Data("garbage".utf8).write(to: folder.appendingPathComponent(".dat.nosync1234.AbC123"))
        try FileManager.default.createDirectory(
            at: folder.appendingPathComponent("9-folder.json"),
            withIntermediateDirectories: true
        )

        // list() returns only the decodable event and deletes nothing.
        XCTAssertEqual(try mailbox.list().map { $0.event }, [good])
        XCTAssertEqual(try names(in: folder).count, 12)

        // The purge removes exactly the 8 readable-but-undecodable .json files.
        XCTAssertEqual(mailbox.deleteUndecodableFiles(), 8)
        XCTAssertEqual(
            try names(in: folder),
            [goodURL.lastPathComponent, "notes.txt", ".dat.nosync1234.AbC123", "9-folder.json"]
        )
        XCTAssertEqual(mailbox.deleteUndecodableFiles(), 0)
        XCTAssertEqual(try mailbox.list().map { $0.event }, [good])
    }

    // MARK: Odd file system states

    func testMissingEventsFolderIsAnEmptyMailbox() throws {
        XCTAssertFalse(FileManager.default.fileExists(atPath: mailbox.directory.path))
        XCTAssertEqual(try mailbox.list(), [])
        XCTAssertEqual(mailbox.deleteUndecodableFiles(), 0)
    }

    func testAFileInPlaceOfTheEventsFolder() throws {
        let mailbox = self.mailbox
        // The mailbox URL is a directory URL (trailing slash); write the blocking file without it.
        let blocker = URL(fileURLWithPath: mailbox.directory.path)
        try Data("x".utf8).write(to: blocker)
        XCTAssertThrowsError(try mailbox.list())
        XCTAssertThrowsError(try mailbox.append(WidgetEvent(type: .next, wordID: 1, at: fixedDate, source: .systemSmall)))
        XCTAssertEqual(mailbox.deleteUndecodableFiles(), 0)
        // The blocking file is not touched.
        XCTAssertEqual(try Data(contentsOf: blocker), Data("x".utf8))
    }

    func testDeletingAnEventTwiceThrowsTheSecondTime() throws {
        let mailbox = self.mailbox
        try mailbox.append(WidgetEvent(type: .next, wordID: 1, at: fixedDate, source: .systemSmall))
        let stored = try XCTUnwrap(try mailbox.list().first)
        try mailbox.delete(stored)
        XCTAssertThrowsError(try mailbox.delete(stored))
    }

    // MARK: File names

    func testFileNameUsesTheEventTimeRoundedToTheNearestMillisecond() throws {
        // 1_700_000_000.9996 s * 1000 = 1_700_000_000_999.6 ms -> rounds UP to 1_700_000_001_000.
        let late = try mailbox.append(
            WidgetEvent(type: .next, wordID: 1, at: Date(timeIntervalSince1970: 1_700_000_000.9996), source: .systemSmall)
        )
        XCTAssertTrue(late.lastPathComponent.hasPrefix("1700000001000-"), late.lastPathComponent)
        // 1_700_000_000.0004 s -> 1_700_000_000_000.4 ms -> rounds down to 1_700_000_000_000.
        let early = try mailbox.append(
            WidgetEvent(type: .next, wordID: 2, at: Date(timeIntervalSince1970: 1_700_000_000.0004), source: .systemSmall)
        )
        XCTAssertTrue(early.lastPathComponent.hasPrefix("1700000000000-"), early.lastPathComponent)
        // Oldest first.
        XCTAssertEqual(try mailbox.list().map { $0.event.wordID }, [2, 1])
    }

    func testTwoEventsInTheSameMillisecondAreBothKept() throws {
        let mailbox = self.mailbox
        let first = WidgetEvent(type: .next, wordID: 1, at: fixedDate, source: .systemSmall)
        let second = WidgetEvent(type: .known, wordID: 2, at: fixedDate, source: .systemSmall)
        let firstURL = try mailbox.append(first)
        let secondURL = try mailbox.append(second)
        XCTAssertNotEqual(firstURL, secondURL)
        XCTAssertEqual(Set(try mailbox.list().map { $0.event.wordID }), [1, 2])
    }

    // MARK: Concurrency

    func testConcurrentAppendsAreAllKeptInTimeOrder() throws {
        let mailbox = self.mailbox
        let log = ConcurrentLog()
        // 200 taps, one millisecond apart, appended by 8 threads at once. The events folder does not
        // exist yet, so the first appends also race to create it.
        DispatchQueue.concurrentPerform(iterations: 8) { worker in
            for index in stride(from: worker, to: 200, by: 8) {
                let at = Date(timeIntervalSince1970: 1_700_000_000 + Double(index) / 1000)
                do {
                    try mailbox.append(WidgetEvent(type: .next, wordID: index, at: at, source: .systemSmall))
                } catch {
                    log.add("append \(index) failed: \(error)")
                }
            }
        }
        XCTAssertEqual(log.items, [])
        // File names are "<13-digit ms>-<uuid>.json", so name order is time order: ids 0, 1, ..., 199.
        XCTAssertEqual(try mailbox.list().map { $0.event.wordID }, Array(0..<200))
    }

    func testAppendsWhileTheAppPurgesAndListsAreNeverLost() throws {
        let mailbox = self.mailbox
        try FileManager.default.createDirectory(at: mailbox.directory, withIntermediateDirectories: true)
        let at = fixedDate
        let log = ConcurrentLog()
        // Workers 0-3 are the widget (50 appends each); workers 4-5 are the app, which lists and
        // purges damaged files at the same time. A half-written event must never be visible as a
        // .json file, or the purge would delete it.
        DispatchQueue.concurrentPerform(iterations: 6) { worker in
            if worker < 4 {
                for index in 0..<50 {
                    let id = worker * 50 + index
                    do {
                        try mailbox.append(WidgetEvent(type: .reveal, wordID: id, at: at, source: .systemMedium))
                    } catch {
                        log.add("append \(id) failed: \(error)")
                    }
                }
            } else {
                for round in 0..<40 {
                    let removed = mailbox.deleteUndecodableFiles()
                    if removed != 0 {
                        log.add("purge \(round) by \(worker) removed \(removed)")
                    }
                    if (try? mailbox.list()) == nil {
                        log.add("list \(round) by \(worker) failed")
                    }
                }
            }
        }
        XCTAssertEqual(log.items, [])
        XCTAssertEqual(Set(try mailbox.list().map { $0.event.wordID }), Set(0..<200))
    }
}
