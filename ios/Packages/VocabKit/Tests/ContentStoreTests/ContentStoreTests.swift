import XCTest
import GRDB
import CoreModels
import TextFold
import ContentStore

/// Builds a throwaway database with the contract section 3 schema (the parts ContentStore
/// reads), then queries it through the read-only ContentStore.
/// These tests need FTS5 in the system SQLite (present on macOS and iOS).
final class ContentStoreTests: XCTestCase {
    private var directory: URL!
    private var databasePath: String!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ContentStoreTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        databasePath = directory.appendingPathComponent("content.sqlite").path
        try buildDatabase()
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    func testCardCountAndMeta() throws {
        let store = try ContentStore(path: databasePath)
        XCTAssertEqual(try store.cardCount(), 5)
        XCTAssertEqual(try store.meta("content_version"), "test-1")
        XCTAssertNil(try store.meta("missing_key"))
    }

    func testFreeCardsFiltersAndOrders() throws {
        let store = try ContentStore(path: databasePath)

        let all = try store.freeCards(maxLevelRank: 7, limit: 10)
        // id 3 is not free, id 4 is sensitive. Order: level_rank, freq_rank (NULL last), rowid.
        XCTAssertEqual(all.map { $0.id }, [1, 5, 2])

        let beginner = try store.freeCards(maxLevelRank: 1, limit: 10)
        XCTAssertEqual(beginner.map { $0.id }, [1, 5])

        let limited = try store.freeCards(maxLevelRank: 7, limit: 1)
        XCTAssertEqual(limited.map { $0.id }, [1])
    }

    func testFreeCardsComeInAscendingLevelOrder() throws {
        // Extra free cards inserted so that neither rowid nor frequency alone gives level order:
        // the B1 card has the best frequency of all, the A2 card a higher rowid than the A1 "house".
        let writer = try DatabaseQueue(path: databasePath)
        try writer.write { db in
            try self.insertCard(db, id: 6, lemma: "travel", level: "B1", levelRank: 3, freqRank: 5, sensitivity: 0, isFree: 1, ipa: nil, gloss: "seyahat")
            try self.insertCard(db, id: 7, lemma: "water", level: "A2", levelRank: 2, freqRank: 300, sensitivity: 0, isFree: 1, ipa: nil, gloss: "su")
            try self.insertCard(db, id: 8, lemma: "house", level: "A1", levelRank: 1, freqRank: 10, sensitivity: 0, isFree: 1, ipa: nil, gloss: "ev")
        }

        let store = try ContentStore(path: databasePath)
        let all = try store.freeCards(maxLevelRank: 7, limit: 5000)
        // A1 by frequency (NULL last): 8, 1, 5; then A2: 7; then B1: 6; then C1: 2.
        XCTAssertEqual(all.map { $0.id }, [8, 1, 5, 7, 6, 2])
        XCTAssertEqual(all.map { $0.level }, ["A1", "A1", "A1", "A2", "B1", "C1"])

        let upToA2 = try store.freeCards(maxLevelRank: 2, limit: 5000)
        XCTAssertEqual(upToA2.map { $0.id }, [8, 1, 5, 7])
    }

    func testCardDetailDecodesTheJSONColumn() throws {
        let writer = try DatabaseQueue(path: databasePath)
        try writer.write { db in
            try db.execute(
                sql: "UPDATE card SET json = ? WHERE rowid = 2",
                arguments: [#"{"examples":[{"en":"Kids are resilient.","tr":"Çocuklar dirençlidir."}],"l1":{"tr":{"note":"not"}}}"#]
            )
        }
        let store = try ContentStore(path: databasePath)
        let detail = try XCTUnwrap(try store.cardDetail(id: 2))
        XCTAssertEqual(detail.examples, [CardDetail.Example(en: "Kids are resilient.", tr: "Çocuklar dirençlidir.")])
        XCTAssertEqual(detail.noteTR, "not")
        // The test cards store '{}': everything empty, still decodes.
        XCTAssertEqual(try store.cardDetail(id: 1), CardDetail())
        XCTAssertNil(try store.cardDetail(id: 999))
    }

    func testFreeCardsMapsFields() throws {
        let store = try ContentStore(path: databasePath)
        let cards = try store.freeCards(maxLevelRank: 7, limit: 10)
        let first = try XCTUnwrap(cards.first)
        XCTAssertEqual(first.lemma, "cicek")
        XCTAssertEqual(first.level, "A1")
        XCTAssertEqual(first.pos, "n")
        XCTAssertEqual(first.glossTR, "flower")
        XCTAssertEqual(first.defMicro, "micro")
        XCTAssertEqual(first.exampleEN, "example")
        XCTAssertEqual(first.ipaUS, "/ipa/")

        // Card 5 has no card_l1 row: the LEFT JOIN yields a nil gloss.
        let noGloss = try XCTUnwrap(cards.first(where: { $0.id == 5 }))
        XCTAssertNil(noGloss.glossTR)
        XCTAssertNil(noGloss.ipaUS)
    }

    func testSearchUsesFoldedPrefixMatch() throws {
        let store = try ContentStore(path: databasePath)

        let byLemma = try store.search("Çiç", limit: 10)
        XCTAssertEqual(byLemma.map { $0.id }, [1])

        let byGloss = try store.search("flow", limit: 10)
        XCTAssertEqual(byGloss.map { $0.id }, [1])

        let phrase = try store.search("look up", limit: 10)
        XCTAssertEqual(phrase.map { $0.id }, [3])
    }

    func testSearchHidesSensitiveCards() throws {
        let store = try ContentStore(path: databasePath)
        XCTAssertTrue(try store.search("sensitive", limit: 10).isEmpty)
    }

    func testSearchWithUnsearchableQueryReturnsEmpty() throws {
        let store = try ContentStore(path: databasePath)
        XCTAssertTrue(try store.search("   ", limit: 10).isEmpty)
        XCTAssertTrue(try store.search("--- ...", limit: 10).isEmpty)
        // A stray quote must not produce an FTS syntax error.
        XCTAssertNoThrow(try store.search("fl\"ow", limit: 10))
    }

    func testFTSExpressionQuoting() {
        XCTAssertEqual(ContentStore.ftsMatchExpression(for: "  Look  Up "), "\"look\"* \"up\"*")
        XCTAssertEqual(ContentStore.ftsMatchExpression(for: "a\"b"), "\"a\"\"b\"*")
        XCTAssertNil(ContentStore.ftsMatchExpression(for: "  "))
        XCTAssertNil(ContentStore.ftsMatchExpression(for: "-- !!"))
    }

    func testMissingFileThrows() {
        let missing = directory.appendingPathComponent("nope.sqlite").path
        XCTAssertThrowsError(try ContentStore(path: missing))
    }

    // MARK: Fixture

    private func buildDatabase() throws {
        let queue = try DatabaseQueue(path: databasePath)
        try queue.write { db in
            try db.execute(sql: """
                CREATE TABLE content_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
                CREATE TABLE category (
                  id TEXT PRIMARY KEY, grp TEXT NOT NULL, name_en TEXT NOT NULL, name_tr TEXT NOT NULL,
                  access TEXT NOT NULL, free_count INTEGER NOT NULL, hero INTEGER NOT NULL, sort INTEGER NOT NULL
                );
                CREATE TABLE card (
                  rowid INTEGER PRIMARY KEY, card_id TEXT NOT NULL UNIQUE, lemma TEXT NOT NULL,
                  type TEXT NOT NULL, pos TEXT NOT NULL, sense_no INTEGER NOT NULL, sense_note TEXT,
                  level TEXT NOT NULL, level_rank INTEGER NOT NULL, freq_rank INTEGER, zipf REAL,
                  ipa_us TEXT, ipa_uk TEXT, def_micro TEXT NOT NULL, def_short TEXT NOT NULL,
                  def_long TEXT NOT NULL, example_en TEXT NOT NULL,
                  primary_topic TEXT NOT NULL REFERENCES category(id), register TEXT NOT NULL,
                  sensitivity INTEGER NOT NULL, is_free INTEGER NOT NULL, json TEXT NOT NULL
                );
                CREATE TABLE card_l1 (
                  card_rowid INTEGER NOT NULL REFERENCES card(rowid), lang TEXT NOT NULL,
                  gloss TEXT NOT NULL, equivalence TEXT NOT NULL, example_tr TEXT,
                  PRIMARY KEY (card_rowid, lang)
                );
                CREATE VIRTUAL TABLE card_fts USING fts5(
                  lemma_fold, gloss_fold, content='', tokenize='unicode61 remove_diacritics 2'
                );
                INSERT INTO content_meta (key, value) VALUES ('content_version', 'test-1');
                INSERT INTO category (id, grp, name_en, name_tr, access, free_count, hero, sort)
                  VALUES ('general', 'A', 'General', 'Genel', 'F', 100, 1, 1);
                """)

            // id, lemma, level, level_rank, freq_rank, sensitivity, is_free, ipa, gloss
            try self.insertCard(db, id: 1, lemma: "cicek", level: "A1", levelRank: 1, freqRank: 50, sensitivity: 0, isFree: 1, ipa: "/ipa/", gloss: "flower")
            try self.insertCard(db, id: 2, lemma: "resilient", level: "C1", levelRank: 5, freqRank: 900, sensitivity: 0, isFree: 1, ipa: nil, gloss: "direncli")
            try self.insertCard(db, id: 3, lemma: "look up to", level: "B2", levelRank: 4, freqRank: nil, sensitivity: 0, isFree: 0, ipa: nil, gloss: "saygi duymak")
            try self.insertCard(db, id: 4, lemma: "sensitive", level: "B1", levelRank: 3, freqRank: 10, sensitivity: 1, isFree: 1, ipa: nil, gloss: "hassas")
            try self.insertCard(db, id: 5, lemma: "breakfast", level: "A1", levelRank: 1, freqRank: nil, sensitivity: 0, isFree: 1, ipa: nil, gloss: nil)
        }
    }

    private func insertCard(
        _ db: Database,
        id: Int,
        lemma: String,
        level: String,
        levelRank: Int,
        freqRank: Int?,
        sensitivity: Int,
        isFree: Int,
        ipa: String?,
        gloss: String?
    ) throws {
        try db.execute(
            sql: """
                INSERT INTO card (rowid, card_id, lemma, type, pos, sense_no, level, level_rank, freq_rank,
                                  ipa_us, def_micro, def_short, def_long, example_en,
                                  primary_topic, register, sensitivity, is_free, json)
                VALUES (?, ?, ?, 'word', 'n', 1, ?, ?, ?, ?, 'micro', 'short', 'long', 'example',
                        'general', 'neutral', ?, ?, '{}')
                """,
            arguments: [id, "en.test.\(id)", lemma, level, levelRank, freqRank, ipa, sensitivity, isFree]
        )
        var glossFold = ""
        if let gloss = gloss {
            try db.execute(
                sql: "INSERT INTO card_l1 (card_rowid, lang, gloss, equivalence) VALUES (?, 'tr', ?, 'full')",
                arguments: [id, gloss]
            )
            glossFold = TextFold.fold(gloss)
        }
        try db.execute(
            sql: "INSERT INTO card_fts (rowid, lemma_fold, gloss_fold) VALUES (?, ?, ?)",
            arguments: [id, TextFold.fold(lemma), glossFold]
        )
    }
}
