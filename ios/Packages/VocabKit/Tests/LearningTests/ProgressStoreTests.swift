import XCTest
import Learning

final class ProgressStoreTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("ProgressStoreTests-\(UUID().uuidString)")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    func testMissingFileIsEmptyProgress() {
        let store = ProgressStore(fileURL: directory.appendingPathComponent("progress.json"))
        XCTAssertTrue(store.load().isEmpty)
    }

    func testRoundTripKeepsFractionalDates() throws {
        let store = ProgressStore(fileURL: directory.appendingPathComponent("nested/progress.json"))
        let now = Date(timeIntervalSince1970: 1_700_000_000.375)
        var a = Leitner.review(WordProgress(wordID: 42), grade: .good, at: now)
        a.saved = true
        let b = Leitner.markKnown(WordProgress(wordID: 7), at: now)
        try store.save([42: a, 7: b])

        let loaded = store.load()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[42], a)
        XCTAssertEqual(loaded[7], b)
    }

    func testFileUsesSnakeCaseKeysSortedByWordID() throws {
        let url = directory.appendingPathComponent("progress.json")
        let store = ProgressStore(fileURL: url)
        try store.save([9: WordProgress(wordID: 9), 3: WordProgress(wordID: 3)])
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]]
        let rows = try XCTUnwrap(object)
        XCTAssertEqual(rows.map { $0["word_id"] as? Int }, [3, 9])
        XCTAssertNotNil(rows[0]["known_override"])
    }

    func testCorruptFileIsEmptyProgress() throws {
        let url = directory.appendingPathComponent("progress.json")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: url)
        XCTAssertTrue(ProgressStore(fileURL: url).load().isEmpty)
    }
}
