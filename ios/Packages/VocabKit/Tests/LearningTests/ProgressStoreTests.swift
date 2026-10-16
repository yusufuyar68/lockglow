import XCTest
import Learning

final class ProgressStoreTests: XCTestCase {
    private var directory: URL!
    private var calendar: Calendar!
    /// Noon on two consecutive days (UTC), far from midnight.
    private let day1 = Date(timeIntervalSince1970: 1_760_011_200)
    private var day2: Date { day1.addingTimeInterval(86_400) }

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("ProgressStoreTests-\(UUID().uuidString)")
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        calendar = utc
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func makeStore() -> ProgressStore {
        return ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
    }

    private func progress(_ ids: Int...) -> [Int: WordProgress] {
        var result: [Int: WordProgress] = [:]
        for id in ids {
            result[id] = Leitner.markKnown(WordProgress(wordID: id), at: day1)
        }
        return result
    }

    private func writeRaw(_ text: String, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(text.utf8).write(to: url)
    }

    private func unreadableFiles() throws -> [URL] {
        let names = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        return names.filter { $0.hasPrefix("progress-unreadable-") }.sorted().map { directory.appendingPathComponent($0) }
    }

    func testMissingFileIsFreshProgress() throws {
        let result = try makeStore().load()
        XCTAssertTrue(result.progress.isEmpty)
        XCTAssertEqual(result.outcome, .fresh)
    }

    func testRoundTripKeepsFractionalDates() throws {
        let store = ProgressStore(fileURL: directory.appendingPathComponent("nested/progress.json"))
        let now = Date(timeIntervalSince1970: 1_700_000_000.375)
        var a = Leitner.review(WordProgress(wordID: 42), grade: .good, at: now)
        a.saved = true
        let b = Leitner.markKnown(WordProgress(wordID: 7), at: now)
        try store.save([42: a, 7: b])

        let loaded = try store.load()
        XCTAssertEqual(loaded.outcome, .loaded)
        XCTAssertEqual(loaded.progress.count, 2)
        XCTAssertEqual(loaded.progress[42], a)
        XCTAssertEqual(loaded.progress[7], b)
    }

    func testFileUsesSnakeCaseKeysSortedByWordID() throws {
        let store = makeStore()
        try store.save([9: WordProgress(wordID: 9), 3: WordProgress(wordID: 3)])
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: store.fileURL)) as? [[String: Any]]
        let rows = try XCTUnwrap(object)
        XCTAssertEqual(rows.map { $0["word_id"] as? Int }, [3, 9])
        XCTAssertNotNil(rows[0]["known_override"])
    }

    func testDamagedFileIsSetAsideNotOverwritten() throws {
        let store = makeStore()
        try writeRaw("not json", to: store.fileURL)

        let result = try store.load(now: day1)
        XCTAssertTrue(result.progress.isEmpty)
        let aside = try XCTUnwrap(try unreadableFiles().first)
        XCTAssertEqual(result.outcome, .startedOver(setAside: aside))
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.fileURL.path))

        // Saving afterwards writes a new file and leaves the damaged one as it was.
        try store.save(progress(5), now: day1, calendar: calendar)
        XCTAssertEqual(try String(contentsOf: aside, encoding: .utf8), "not json")
        XCTAssertEqual(try store.load().progress.keys.sorted(), [5])
    }

    func testDamagedFileRestoresFromBackup() throws {
        let store = makeStore()
        try store.save(progress(1), now: day1, calendar: calendar)
        try store.save(progress(1, 2), now: day1, calendar: calendar)  // backup = {1}
        try writeRaw("{\"broken\"", to: store.fileURL)

        let result = try store.load(now: day2)
        XCTAssertEqual(result.progress.keys.sorted(), [1])
        guard case let .restoredFromBackup(setAside, backupDate) = result.outcome else {
            return XCTFail("expected a restore, got \(result.outcome)")
        }
        XCTAssertEqual(setAside, try unreadableFiles().first)
        let taken = try XCTUnwrap(backupDate)
        XCTAssertTrue(calendar.isDate(taken, inSameDayAs: day1))
    }

    func testMissingFileWithBackupRestoresBackup() throws {
        let store = makeStore()
        try store.save(progress(1), now: day1, calendar: calendar)
        try store.save(progress(1, 2), now: day1, calendar: calendar)
        try FileManager.default.removeItem(at: store.fileURL)

        let result = try store.load(now: day2)
        XCTAssertEqual(result.progress.keys.sorted(), [1])
        guard case .restoredFromBackup(setAside: nil, backupDate: _) = result.outcome else {
            return XCTFail("expected a restore without a set-aside file, got \(result.outcome)")
        }
    }

    func testBackupIsTakenOncePerDay() throws {
        let store = makeStore()
        func backupIDs() throws -> [Int] {
            let backup = ProgressStore(fileURL: store.backupURL)
            return try backup.load().progress.keys.sorted()
        }

        try store.save(progress(1), now: day1, calendar: calendar)
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.backupURL.path), "nothing to back up before the first file")
        try store.save(progress(1, 2), now: day1, calendar: calendar)
        try store.save(progress(1, 2, 3), now: day1, calendar: calendar)
        XCTAssertEqual(try backupIDs(), [1], "the backup keeps the day's first state")

        try store.save(progress(1, 2, 3, 4), now: day2, calendar: calendar)
        XCTAssertEqual(try backupIDs(), [1, 2, 3], "a new day backs up the last state of the previous one")
        XCTAssertEqual(try store.load().progress.keys.sorted(), [1, 2, 3, 4])
    }

    func testDamagedFileIsNotCopiedToBackup() throws {
        let store = makeStore()
        try store.save(progress(1), now: day1, calendar: calendar)
        try store.save(progress(1, 2), now: day1, calendar: calendar)  // backup = {1}, taken on day 1
        try writeRaw("garbage", to: store.fileURL)

        // A save on a new day would normally refresh the backup; a damaged file must not replace it.
        try store.save(progress(9), now: day2, calendar: calendar)
        XCTAssertEqual(try ProgressStore(fileURL: store.backupURL).load().progress.keys.sorted(), [1])
    }

    func testUnreadableFileThrowsAndIsLeftAlone() throws {
        let store = makeStore()
        // A folder where the file should be: it exists but cannot be read as data.
        try FileManager.default.createDirectory(at: store.fileURL, withIntermediateDirectories: true)

        XCTAssertThrowsError(try store.load()) { error in
            guard case ProgressStore.LoadError.unreadable = error else {
                return XCTFail("unexpected error \(error)")
            }
        }
        var isFolder: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.fileURL.path, isDirectory: &isFolder))
        XCTAssertTrue(isFolder.boolValue)
        XCTAssertTrue(try unreadableFiles().isEmpty)
    }
}
