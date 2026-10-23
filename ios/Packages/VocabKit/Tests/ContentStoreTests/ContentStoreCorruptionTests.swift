import XCTest
import GRDB
import CoreModels
import ContentStore

/// A damaged content.sqlite must give an error the app can catch, never a crash:
/// `ContentLoader.load` falls back to the seed words when the cards cannot be read, keeps the
/// cards without topics when only the topics fail, and `AppModel.detail(for:)` shows a card
/// without its details when its JSON is broken.
final class ContentStoreCorruptionTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ContentStoreCorruptionTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    /// A writable copy of the real content, changed by `change`.
    private func damagedCopy(_ change: (Database) throws -> Void) throws -> String {
        let path = directory.appendingPathComponent("content-\(UUID().uuidString).sqlite").path
        try FileManager.default.copyItem(atPath: try RealContent.path(), toPath: path)
        let writer = try DatabaseQueue(path: path)
        try writer.write(change)
        try writer.close()
        return path
    }

    /// What `ContentLoader.load` reads, in its order. Throws where it would fall back.
    private func loadCards(_ path: String) throws -> [WidgetWord] {
        let store = try ContentStore(path: path)
        let words = try store.freeCards(maxLevelRank: 7, limit: 5000)
        _ = try store.cardCount()
        _ = try store.meta("content_version")
        return words
    }

    func testAnEmptyFileIsAnError() throws {
        let path = directory.appendingPathComponent("empty.sqlite").path
        XCTAssertTrue(FileManager.default.createFile(atPath: path, contents: Data()))
        XCTAssertThrowsError(try loadCards(path))
    }

    func testAFileThatIsNotADatabaseIsAnError() throws {
        let path = directory.appendingPathComponent("garbage.sqlite").path
        let bytes = Data((0..<65_536).map { UInt8(truncatingIfNeeded: $0 &* 31 &+ 7) })
        try bytes.write(to: URL(fileURLWithPath: path))
        XCTAssertThrowsError(try loadCards(path))
    }

    /// The file cut short (a damaged app bundle): either an error or fewer cards, never a crash.
    func testATruncatedDatabaseNeverCrashes() throws {
        let real = try Data(contentsOf: URL(fileURLWithPath: try RealContent.path()))
        for fraction in [0.001, 0.05, 0.3, 0.6, 0.95] {
            let path = directory.appendingPathComponent("cut-\(fraction).sqlite").path
            try real.prefix(Int(Double(real.count) * fraction)).write(to: URL(fileURLWithPath: path))
            if let words = try? loadCards(path), let store = try? ContentStore(path: path) {
                XCTAssertLessThanOrEqual(words.count, 5000)
                for word in words.prefix(20) {
                    _ = try? store.cardDetail(id: word.id)
                }
                _ = try? store.search("ka", limit: 50)
                _ = try? store.topics()
            }
        }
    }

    /// Without the topic tables the cards still load; only the topic choice is lost.
    func testMissingTopicTablesKeepTheCards() throws {
        let path = try damagedCopy { db in
            try db.execute(sql: "DROP TABLE card_category")
        }
        XCTAssertGreaterThanOrEqual(try loadCards(path).count, 1200)
        let store = try ContentStore(path: path)
        XCTAssertThrowsError(try store.topics())
        XCTAssertThrowsError(try store.topicsByCard())
    }

    /// Without the Turkish table the feed query fails: the app falls back to the seed words.
    func testMissingTurkishTableIsAnError() throws {
        let path = try damagedCopy { db in
            try db.execute(sql: "DROP TABLE card_l1")
        }
        XCTAssertThrowsError(try loadCards(path))
    }

    /// Without the search index the dictionary search fails alone.
    func testMissingSearchIndexFailsOnlyTheSearch() throws {
        let path = try damagedCopy { db in
            try db.execute(sql: "DROP TABLE card_fts")
        }
        XCTAssertGreaterThanOrEqual(try loadCards(path).count, 1200)
        let store = try ContentStore(path: path)
        XCTAssertThrowsError(try store.search("kahv", limit: 50))
    }

    /// A card whose JSON is broken: its details fail, the other cards are untouched.
    func testABrokenCardJSONFailsOnlyThatCard() throws {
        let path = try damagedCopy { db in
            try db.execute(sql: "UPDATE card SET json = '{\"examples\": [' WHERE rowid = (SELECT MIN(rowid) FROM card)")
        }
        let reader = try DatabaseQueue(path: path)
        let broken = try XCTUnwrap(try reader.read { db in
            try Int.fetchOne(db, sql: "SELECT MIN(rowid) FROM card")
        })
        try reader.close()
        let store = try ContentStore(path: path)
        let words = try store.freeCards(maxLevelRank: 7, limit: 5000)
        XCTAssertGreaterThanOrEqual(words.count, 1200)
        XCTAssertThrowsError(try store.cardDetail(id: broken))
        let other = try XCTUnwrap(words.first { $0.id != broken })
        XCTAssertNotNil(try store.cardDetail(id: other.id))
        XCTAssertNil(try store.cardDetail(id: -1))
    }
}
