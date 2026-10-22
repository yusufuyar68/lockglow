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
        // id 3 is not free, id 4 is offensive (sensitivity 2). Order: level_rank, freq_rank (NULL last), rowid.
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

    func testTopicsCountFreeNonSensitiveMembers() throws {
        let writer = try DatabaseQueue(path: databasePath)
        try writer.write { db in
            try db.execute(sql: """
                INSERT INTO category (id, grp, name_en, name_tr, access, free_count, hero, sort) VALUES
                  ('travel_tourism', 'B', 'Travel & Tourism', 'Seyahat & Turizm', 'S', 10, 0, 0),
                  ('empty_topic', 'A', 'Empty', 'Boş', 'F', 0, 0, 2),
                  ('workplace_office', 'D', 'Workplace', 'İş Yeri', 'P', 0, 0, 5),
                  ('success_productivity', 'C', 'Success', 'Başarı', 'S', 10, 0, 7);
                """)
            try self.insertCard(db, id: 6, lemma: "passport", level: "A2", levelRank: 2, freqRank: 900, sensitivity: 0, isFree: 1, ipa: nil, gloss: "pasaport", topic: "travel_tourism")
            try self.insertCard(db, id: 7, lemma: "flight", level: "A2", levelRank: 2, freqRank: 800, sensitivity: 0, isFree: 1, ipa: nil, gloss: "uçuş", topic: "travel_tourism")
            try self.insertCard(db, id: 8, lemma: "meeting", level: "B1", levelRank: 3, freqRank: 700, sensitivity: 0, isFree: 0, ipa: nil, gloss: "toplantı", topic: "workplace_office")
            try self.insertCard(db, id: 9, lemma: "secret", level: "B1", levelRank: 3, freqRank: 600, sensitivity: 1, isFree: 1, ipa: nil, gloss: "sır", topic: "workplace_office")
            // Second topics: card 1 ("general") is also a travel card; card 7 is also a success
            // card, a topic that is no card's main topic.
            try self.addTopic(db, card: 1, topic: "travel_tourism")
            try self.addTopic(db, card: 7, topic: "success_productivity")
        }

        let store = try ContentStore(path: databasePath)
        let topics = try store.topics()
        // Sort order: travel (0), general (1), workplace (5), success (7). "empty_topic" has no
        // card. "general" counts cards 1, 2 and 5 (3 is locked, 4 offensive); travel counts 6, 7
        // and card 1 through its second topic; "workplace_office" counts the personal card 9
        // (sensitivity 1 stays in the app), not the locked card 8.
        XCTAssertEqual(topics.map { $0.id }, ["travel_tourism", "general", "workplace_office", "success_productivity"])
        XCTAssertEqual(topics.map { $0.cardCount }, [3, 3, 1, 1])
        XCTAssertEqual(
            topics.first,
            ContentTopic(id: "travel_tourism", group: "B", nameEN: "Travel & Tourism", nameTR: "Seyahat & Turizm", sort: 0, cardCount: 3)
        )
    }

    func testTopicsByCardListsEveryMembership() throws {
        let writer = try DatabaseQueue(path: databasePath)
        try writer.write { db in
            try db.execute(sql: """
                INSERT INTO category (id, grp, name_en, name_tr, access, free_count, hero, sort)
                  VALUES ('travel_tourism', 'B', 'Travel & Tourism', 'Seyahat & Turizm', 'S', 10, 0, 0);
                """)
            try self.insertCard(db, id: 6, lemma: "passport", level: "A2", levelRank: 2, freqRank: 900, sensitivity: 0, isFree: 1, ipa: nil, gloss: "pasaport", topic: "travel_tourism")
            try self.addTopic(db, card: 2, topic: "travel_tourism")
        }

        let store = try ContentStore(path: databasePath)
        XCTAssertEqual(
            try store.topicsByCard(),
            [
                1: ["general"],
                2: ["general", "travel_tourism"],
                3: ["general"],
                4: ["general"],
                5: ["general"],
                6: ["travel_tourism"],
            ]
        )
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
        XCTAssertEqual(first.glossShortTR, "cicek")
        XCTAssertEqual(first.sensitivity, 0)
        XCTAssertFalse(first.isSensitive)

        // Card 5 has no card_l1 row: the LEFT JOIN yields a nil gloss.
        let noGloss = try XCTUnwrap(cards.first(where: { $0.id == 5 }))
        XCTAssertNil(noGloss.glossTR)
        XCTAssertNil(noGloss.glossShortTR)
        XCTAssertNil(noGloss.ipaUS)

        // Card 2 has a gloss but no short one.
        let noShort = try XCTUnwrap(cards.first(where: { $0.id == 2 }))
        XCTAssertEqual(noShort.glossTR, "direncli")
        XCTAssertNil(noShort.glossShortTR)
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

    func testSearchHidesOffensiveCards() throws {
        let store = try ContentStore(path: databasePath)
        XCTAssertTrue(try store.search("sensitive", limit: 10).isEmpty)
    }

    func testPersonalCardsStayInTheApp() throws {
        // Sensitivity 1 (relationships, work trouble…) leaves only the widget queue; the app lists
        // and finds it like any card, and says it is sensitive.
        let writer = try DatabaseQueue(path: databasePath)
        try writer.write { db in
            try self.insertCard(db, id: 6, lemma: "divorce", level: "B1", levelRank: 3, freqRank: 400, sensitivity: 1, isFree: 1, ipa: nil, gloss: "boşanma")
        }

        let store = try ContentStore(path: databasePath)
        let free = try store.freeCards(maxLevelRank: 7, limit: 10)
        XCTAssertEqual(free.map { $0.id }, [1, 5, 6, 2])
        let personal = try XCTUnwrap(free.first(where: { $0.id == 6 }))
        XCTAssertEqual(personal.sensitivity, 1)
        XCTAssertTrue(personal.isSensitive)

        XCTAssertEqual(try store.search("divorce", limit: 10).map { $0.id }, [6])
        XCTAssertEqual(try store.search("bosanma", limit: 10).map { $0.id }, [6])
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
                  gloss TEXT NOT NULL, gloss_short TEXT, equivalence TEXT NOT NULL, example_tr TEXT,
                  PRIMARY KEY (card_rowid, lang)
                );
                CREATE TABLE card_category (
                  card_rowid INTEGER NOT NULL REFERENCES card(rowid),
                  category_id TEXT NOT NULL REFERENCES category(id),
                  is_primary INTEGER NOT NULL, rank INTEGER NOT NULL,
                  PRIMARY KEY (card_rowid, category_id)
                );
                CREATE VIRTUAL TABLE card_fts USING fts5(
                  lemma_fold, gloss_fold, content='', tokenize='unicode61 remove_diacritics 2'
                );
                INSERT INTO content_meta (key, value) VALUES ('content_version', 'test-1');
                INSERT INTO category (id, grp, name_en, name_tr, access, free_count, hero, sort)
                  VALUES ('general', 'A', 'General', 'Genel', 'F', 100, 1, 1);
                """)

            // id, lemma, level, level_rank, freq_rank, sensitivity, is_free, ipa, gloss
            try self.insertCard(db, id: 1, lemma: "cicek", level: "A1", levelRank: 1, freqRank: 50, sensitivity: 0, isFree: 1, ipa: "/ipa/", gloss: "flower", glossShort: "cicek")
            try self.insertCard(db, id: 2, lemma: "resilient", level: "C1", levelRank: 5, freqRank: 900, sensitivity: 0, isFree: 1, ipa: nil, gloss: "direncli")
            try self.insertCard(db, id: 3, lemma: "look up to", level: "B2", levelRank: 4, freqRank: nil, sensitivity: 0, isFree: 0, ipa: nil, gloss: "saygi duymak")
            try self.insertCard(db, id: 4, lemma: "sensitive", level: "B1", levelRank: 3, freqRank: 10, sensitivity: 2, isFree: 1, ipa: nil, gloss: "hassas")
            try self.insertCard(db, id: 5, lemma: "breakfast", level: "A1", levelRank: 1, freqRank: nil, sensitivity: 0, isFree: 1, ipa: nil, gloss: nil)
        }
    }

    /// A second (not main) topic for a card.
    private func addTopic(_ db: Database, card: Int, topic: String) throws {
        try db.execute(
            sql: "INSERT INTO card_category (card_rowid, category_id, is_primary, rank) VALUES (?, ?, 0, 0)",
            arguments: [card, topic]
        )
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
        gloss: String?,
        glossShort: String? = nil,
        topic: String = "general"
    ) throws {
        try db.execute(
            sql: """
                INSERT INTO card (rowid, card_id, lemma, type, pos, sense_no, level, level_rank, freq_rank,
                                  ipa_us, def_micro, def_short, def_long, example_en,
                                  primary_topic, register, sensitivity, is_free, json)
                VALUES (?, ?, ?, 'word', 'n', 1, ?, ?, ?, ?, 'micro', 'short', 'long', 'example',
                        ?, 'neutral', ?, ?, '{}')
                """,
            arguments: [id, "en.test.\(id)", lemma, level, levelRank, freqRank, ipa, topic, sensitivity, isFree]
        )
        // Like the pipeline: the main topic is also a membership row.
        try db.execute(
            sql: "INSERT INTO card_category (card_rowid, category_id, is_primary, rank) VALUES (?, ?, 1, 0)",
            arguments: [id, topic]
        )
        var glossFold = ""
        if let gloss = gloss {
            try db.execute(
                sql: "INSERT INTO card_l1 (card_rowid, lang, gloss, gloss_short, equivalence) VALUES (?, 'tr', ?, ?, 'full')",
                arguments: [id, gloss, glossShort]
            )
            glossFold = TextFold.fold(gloss)
        }
        try db.execute(
            sql: "INSERT INTO card_fts (rowid, lemma_fold, gloss_fold) VALUES (?, ?, ?)",
            arguments: [id, TextFold.fold(lemma), glossFold]
        )
    }
}
