import Foundation
import GRDB
import CoreModels
import TextFold

/// Read-only access to `content.sqlite` (contract section 3). App only: the widget
/// extension must never link this module or open SQLite.
public final class ContentStore {
    private let dbQueue: DatabaseQueue

    /// Opens the database read-only. Throws if the file is missing or is not a SQLite database.
    public init(path: String) throws {
        var configuration = GRDB.Configuration()
        configuration.readonly = true
        dbQueue = try DatabaseQueue(path: path, configuration: configuration)
    }

    public func cardCount() throws -> Int {
        return try dbQueue.read { db -> Int in
            return try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM card") ?? 0
        }
    }

    /// Value from `content_meta` (for example "content_version"), or nil if the key is absent.
    public func meta(_ key: String) throws -> String? {
        return try dbQueue.read { db -> String? in
            return try String.fetchOne(
                db,
                sql: "SELECT value FROM content_meta WHERE key = ?",
                arguments: [key]
            )
        }
    }

    /// Free cards up to `maxLevelRank` (A1 = 1 ... C2 = 6, S = 7), easiest and most frequent
    /// first. Personal-topic cards (sensitivity 1) are included: they stay in Akış, Sözlük and
    /// Tekrar, and only the widget queue leaves them out (`QueueComposer`). The Turkish gloss is
    /// optional (LEFT JOIN).
    public func freeCards(maxLevelRank: Int, limit: Int) throws -> [WidgetWord] {
        let sql = """
            SELECT \(selectColumns)
            \(fromClause)
            WHERE c.is_free = 1 AND c.sensitivity <= 1 AND c.level_rank <= ?
            \(orderClause)
            LIMIT ?
            """
        let cappedLimit = max(limit, 0)
        return try dbQueue.read { db -> [WidgetWord] in
            let rows = try Row.fetchAll(db, sql: sql, arguments: [maxLevelRank, cappedLimit])
            return rows.map { makeWord(from: $0) }
        }
    }

    /// Topics the user can choose: categories with at least one free card (the
    /// cards `freeCards` returns) among their members (`card_category`, main topic or not), in
    /// `category.sort` order, with that count. A card in several categories counts in each.
    public func topics() throws -> [ContentTopic] {
        let sql = """
            SELECT cat.id AS id, cat.grp AS grp, cat.name_en AS name_en, cat.name_tr AS name_tr,
                   cat.sort AS sort, COUNT(c.rowid) AS card_count
            FROM category AS cat
            JOIN card_category AS cc ON cc.category_id = cat.id
            JOIN card AS c ON c.rowid = cc.card_rowid
            WHERE c.is_free = 1 AND c.sensitivity <= 1
            GROUP BY cat.id
            ORDER BY cat.sort ASC, cat.id ASC
            """
        return try dbQueue.read { db -> [ContentTopic] in
            let rows = try Row.fetchAll(db, sql: sql)
            return rows.map { row -> ContentTopic in
                let id: String = row["id"]
                let group: String = row["grp"]
                let nameEN: String = row["name_en"]
                let nameTR: String = row["name_tr"]
                let sort: Int = row["sort"]
                let cardCount: Int = row["card_count"]
                return ContentTopic(id: id, group: group, nameEN: nameEN, nameTR: nameTR, sort: sort, cardCount: cardCount)
            }
        }
    }

    /// Every category each card belongs to (`card_category`), by card id: the deck filter's
    /// input. The feed query never joins this table, so a card is never listed twice.
    public func topicsByCard() throws -> [Int: Set<String>] {
        return try dbQueue.read { db -> [Int: Set<String>] in
            var result: [Int: Set<String>] = [:]
            let sql = "SELECT card_rowid AS id, category_id AS topic FROM card_category"
            for row in try Row.fetchAll(db, sql: sql) {
                let id: Int = row["id"]
                let topic: String = row["topic"]
                result[id, default: []].insert(topic)
            }
            return result
        }
    }

    /// The learner details of one card (every example with its Turkish, notes, typical mistakes),
    /// decoded from the full card JSON in `card.json`. Nil if no card has this id.
    public func cardDetail(id: Int) throws -> CardDetail? {
        let json = try dbQueue.read { db -> String? in
            return try String.fetchOne(db, sql: "SELECT json FROM card WHERE rowid = ?", arguments: [id])
        }
        guard let json = json else {
            return nil
        }
        return try JSONDecoder().decode(CardDetail.self, from: Data(json.utf8))
    }

    /// Prefix search over `card_fts` (lemma and Turkish gloss). The query goes through
    /// `TextFold.fold` like the indexed text. Sensitive cards are never returned; locked
    /// (non-free) cards are, so the UI can show them as locked.
    public func search(_ query: String, limit: Int) throws -> [WidgetWord] {
        guard let match = ContentStore.ftsMatchExpression(for: query) else {
            return []
        }
        let sql = """
            SELECT \(selectColumns)
            \(fromClause)
            WHERE c.rowid IN (SELECT rowid FROM card_fts WHERE card_fts MATCH ?)
              AND c.sensitivity <= 1
            \(orderClause)
            LIMIT ?
            """
        let cappedLimit = max(limit, 0)
        return try dbQueue.read { db -> [WidgetWord] in
            let rows = try Row.fetchAll(db, sql: sql, arguments: [match, cappedLimit])
            return rows.map { makeWord(from: $0) }
        }
    }

    /// Builds a safe FTS5 expression: every folded token becomes a quoted prefix term,
    /// for example `look up t` -> `"look"* "up"* "t"*`. Returns nil if nothing searchable is left.
    public static func ftsMatchExpression(for query: String) -> String? {
        let folded = TextFold.fold(query)
        var terms: [String] = []
        for token in folded.split(separator: " ") {
            let hasLetterOrDigit = token.unicodeScalars.contains { CharacterSet.alphanumerics.contains($0) }
            if !hasLetterOrDigit {
                continue
            }
            let escaped = token.replacingOccurrences(of: "\"", with: "\"\"")
            terms.append("\"\(escaped)\"*")
        }
        if terms.isEmpty {
            return nil
        }
        return terms.joined(separator: " ")
    }
}

// MARK: - SQL building blocks

private let selectColumns = """
    c.rowid AS id, c.lemma AS lemma, c.pos AS pos, c.level AS level, c.ipa_us AS ipa_us, \
    c.def_micro AS def_micro, c.def_short AS def_short, c.example_en AS example_en, \
    l.gloss AS gloss_tr, l.gloss_short AS gloss_short_tr, c.sensitivity AS sensitivity
    """

private let fromClause = """
    FROM card AS c
    LEFT JOIN card_l1 AS l ON l.card_rowid = c.rowid AND l.lang = 'tr'
    """

// `freq_rank IS NULL` sorts cards without a frequency rank last (portable NULLS LAST).
private let orderClause = """
    ORDER BY c.level_rank ASC, c.freq_rank IS NULL ASC, c.freq_rank ASC, c.rowid ASC
    """

private func makeWord(from row: Row) -> WidgetWord {
    let id: Int = row["id"]
    let lemma: String = row["lemma"]
    let pos: String = row["pos"]
    let level: String = row["level"]
    let ipaUS: String? = row["ipa_us"]
    let defMicro: String = row["def_micro"]
    let defShort: String = row["def_short"]
    let exampleEN: String = row["example_en"]
    let glossTR: String? = row["gloss_tr"]
    let glossShortTR: String? = row["gloss_short_tr"]
    let sensitivity: Int = row["sensitivity"]
    return WidgetWord(
        id: id,
        lemma: lemma,
        pos: pos,
        level: level,
        ipaUS: ipaUS,
        defMicro: defMicro,
        defShort: defShort,
        exampleEN: exampleEN,
        glossTR: glossTR,
        glossShortTR: glossShortTR,
        sensitivity: sensitivity
    )
}
