import XCTest
import CoreModels
import Learning

/// No space left on the phone (here: a read-only folder). A save that fails must throw, so the
/// app keeps the answer in memory and tries again with the next save (`AppModel.persistProgress`),
/// and the progress already on disk must stay readable.
final class ProgressLowStorageTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_792_749_600)
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ProgressLowStorageTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
        try? FileManager.default.removeItem(at: directory)
    }

    /// Makes `directory` read-only; skips where permissions are not enforced (root in Docker).
    private func makeReadOnly() throws {
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: directory.path)
        let probe = directory.appendingPathComponent("probe")
        if FileManager.default.createFile(atPath: probe.path, contents: Data()) {
            try? FileManager.default.removeItem(at: probe)
            throw XCTSkip("folder permissions are not enforced here (root)")
        }
    }

    func testAFailedSaveThrowsAndKeepsTheSavedProgress() throws {
        let store = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        let saved = [1: Leitner.review(WordProgress(wordID: 1), grade: .good, at: now)]
        try store.save(saved, now: now)
        try makeReadOnly()

        var answered = saved
        answered[2] = Leitner.review(WordProgress(wordID: 2), grade: .again, at: now)
        // The next day: the save would also refresh the backup first.
        XCTAssertThrowsError(try store.save(answered, now: now.addingTimeInterval(86_400)))

        let loaded = try store.load(now: now)
        XCTAssertEqual(loaded.progress, saved)
        XCTAssertEqual(loaded.outcome, .loaded)
    }

    func testAFirstSaveIntoAFullFolderThrowsAndLoadsAsFresh() throws {
        let store = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        try makeReadOnly()
        XCTAssertThrowsError(try store.save([1: WordProgress(wordID: 1)], now: now))
        let loaded = try store.load(now: now)
        XCTAssertTrue(loaded.progress.isEmpty)
        XCTAssertEqual(loaded.outcome, .fresh)
    }
}
