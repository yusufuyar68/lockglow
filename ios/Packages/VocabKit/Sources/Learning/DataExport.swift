import Foundation
import CoreModels

// "Verilerin" (Ayarlar, İlerleme): the user's data in files a person can read. One JSON backup
// (`DataArchive`, the only file the import reads) and four CSV tables for a spreadsheet
// (`DataCSV`). Nothing here leaves the phone by itself: the app writes the files to its
// temporary folder and the share sheet (`ShareLink`) sends them where the user chooses.
// Import rules: DataImport.swift. Wiring: ios/App/AppModel+DataControls.swift.

// MARK: - Backup

/// Everything the app keeps about the user's learning, as one JSON object
/// (`{"format": "lockglow-yedek", "format_version": 1, ...}`):
/// - `progress`: every word's `WordProgress` with the same keys as progress.json, plus `lemma`
///   and `meaning_tr` for people reading the file (the import goes by `word_id` only);
/// - `known_words`: the known words again, as a short list (written only; the import reads
///   them from `progress`);
/// - `custom_words`: the user's own words with `next_id`, as in custom_words.json;
/// - `review_log`: every answer (`ReviewLogEntry`, the keys of review_log.jsonl);
/// - `local_metrics`: the on-device measurements (`LocalMetrics`);
/// - `settings` and `recent_searches`: for reading only; the import leaves both alone.
///
/// Dates are ISO 8601 in UTC, whole seconds ("2026-10-23T10:15:00Z"). Keys are sorted and the
/// file is indented, so a person can read it in any text editor.
public struct DataArchive: Equatable, Sendable {
    public static let formatName = "lockglow-yedek"
    /// The `format_version` this build writes and the highest it reads.
    public static let formatVersion = 1
    /// A backup larger than this is not read (a real one is a few megabytes at most).
    public static let maxBytes = 50_000_000
    /// The `about` line at the top of the file.
    public static let aboutText = "Lockglow yedeği. Yeni telefonda Ayarlar, İlerleme, Verilerin bölümünden \"Yedek dosyası seç\" ile açılır."

    /// One word's progress and, for people reading the file, its English word and meaning.
    public struct Word: Equatable, Sendable {
        public var progress: WordProgress
        public var lemma: String?
        public var meaningTR: String?

        public init(progress: WordProgress, lemma: String? = nil, meaningTR: String? = nil) {
            self.progress = progress
            self.lemma = lemma
            self.meaningTR = meaningTR
        }
    }

    /// The choices of "Ayarlar", for reading only.
    public struct Settings: Codable, Equatable, Sendable {
        public var startLevel: String?
        public var topicIDs: [String]
        public var dailyNewWords: Int?
        public var rotationMinutes: Int?
        public var reminderEnabled: Bool?
        /// "20:00".
        public var reminderTime: String?

        public init(
            startLevel: String? = nil,
            topicIDs: [String] = [],
            dailyNewWords: Int? = nil,
            rotationMinutes: Int? = nil,
            reminderEnabled: Bool? = nil,
            reminderTime: String? = nil
        ) {
            self.startLevel = startLevel
            self.topicIDs = topicIDs
            self.dailyNewWords = dailyNewWords
            self.rotationMinutes = rotationMinutes
            self.reminderEnabled = reminderEnabled
            self.reminderTime = reminderTime
        }

        enum CodingKeys: String, CodingKey {
            case startLevel = "start_level"
            case topicIDs = "topic_ids"
            case dailyNewWords = "daily_new_words"
            case rotationMinutes = "rotation_minutes"
            case reminderEnabled = "reminder_enabled"
            case reminderTime = "reminder_time"
        }

        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            startLevel = try? c.decodeIfPresent(String.self, forKey: .startLevel)
            topicIDs = (try? c.decodeIfPresent([String].self, forKey: .topicIDs)) ?? []
            dailyNewWords = try? c.decodeIfPresent(Int.self, forKey: .dailyNewWords)
            rotationMinutes = try? c.decodeIfPresent(Int.self, forKey: .rotationMinutes)
            reminderEnabled = try? c.decodeIfPresent(Bool.self, forKey: .reminderEnabled)
            reminderTime = try? c.decodeIfPresent(String.self, forKey: .reminderTime)
        }
    }

    public var exportedAt: Date
    /// "1.0 (31)"; nil when unknown.
    public var appVersion: String?
    public var contentVersion: String?
    /// Sorted by word id.
    public var progress: [Word]
    /// Oldest first, as in custom_words.json.
    public var customWords: [CustomWord]
    public var customNextID: Int
    /// In the order written.
    public var reviewLog: [ReviewLogEntry]
    public var localMetrics: LocalMetrics
    public var settings: Settings
    public var recentSearches: [String]

    public init(
        exportedAt: Date,
        appVersion: String? = nil,
        contentVersion: String? = nil,
        progress: [Word] = [],
        customWords: [CustomWord] = [],
        customNextID: Int = CustomWordID.first,
        reviewLog: [ReviewLogEntry] = [],
        localMetrics: LocalMetrics = LocalMetrics(),
        settings: Settings = Settings(),
        recentSearches: [String] = []
    ) {
        self.exportedAt = exportedAt
        self.appVersion = appVersion
        self.contentVersion = contentVersion
        self.progress = progress.sorted { $0.progress.wordID < $1.progress.wordID }
        self.customWords = customWords
        self.customNextID = customNextID
        self.reviewLog = reviewLog
        self.localMetrics = localMetrics
        self.settings = settings
        self.recentSearches = recentSearches
    }

    /// The archive of what the app holds now. `word` names a word id's English word and meaning
    /// (cards and the user's words); a word it does not know is written without them.
    public static func make(
        progress: [Int: WordProgress],
        customWords: CustomWordList,
        reviewLog: [ReviewLogEntry],
        localMetrics: LocalMetrics,
        settings: Settings,
        recentSearches: [String],
        appVersion: String?,
        contentVersion: String?,
        now: Date,
        word: (Int) -> (lemma: String, meaningTR: String?)?
    ) -> DataArchive {
        let words = progress.values.map { record -> Word in
            let named = word(record.wordID)
            return Word(progress: record, lemma: named?.lemma, meaningTR: named?.meaningTR)
        }
        return DataArchive(
            exportedAt: now,
            appVersion: appVersion,
            contentVersion: contentVersion,
            progress: words,
            customWords: customWords.words,
            customNextID: customWords.nextID,
            reviewLog: reviewLog,
            localMetrics: localMetrics,
            settings: settings,
            recentSearches: recentSearches
        )
    }

    /// The known words (`LearningState.known`), by English word.
    public var knownWords: [Word] {
        return DataArchive.byLemma(progress.filter { $0.progress.state == .known })
    }

    /// `words` in the order of their English words (case ignored), words without one last.
    static func byLemma(_ words: [Word]) -> [Word] {
        return words.sorted { lhs, rhs in
            switch (lhs.lemma?.lowercased(), rhs.lemma?.lowercased()) {
            case let (l?, r?) where l != r:
                return l < r
            case (.some, nil):
                return true
            case (nil, .some):
                return false
            default:
                return lhs.progress.wordID < rhs.progress.wordID
            }
        }
    }

    // MARK: Reading and writing

    public func encoded() throws -> Data {
        return try DataArchive.makeEncoder().encode(Body(self))
    }

    /// Why a file cannot be imported at all. `message` is the plain Turkish sentence the screen
    /// shows; no technical names (docs/tasarim/terimler.md §1).
    public enum ReadError: Error, Equatable, Sendable {
        case tooLarge
        /// Not a JSON object, or not a Lockglow backup.
        case notBackup
        /// Made by a later build with a format this one cannot read.
        case newerVersion(Int)

        public var message: String {
            switch self {
            case .tooLarge:
                return "Dosya çok büyük. Bu bir Lockglow yedeği olamaz."
            case .notBackup:
                return "Bu dosya bir Lockglow yedeği değil. Adı lockglow-yedek ile başlayan dosyayı seç."
            case .newerVersion:
                return "Bu yedek Lockglow'un daha yeni bir sürümüyle yapıldı. Önce uygulamayı güncelle."
            }
        }
    }

    /// A backup as read, and how many of its records could not be read at all (damaged, or a
    /// shape a later build wrote). `DataImport.plan` checks the rest.
    public struct Reading: Equatable, Sendable {
        public let archive: DataArchive
        public let unreadableRecords: Int

        public init(archive: DataArchive, unreadableRecords: Int = 0) {
            self.archive = archive
            self.unreadableRecords = unreadableRecords
        }
    }

    /// Reads a backup. The whole file is refused only when it is not a Lockglow backup or is
    /// from a later format; a record that cannot be read is left out and counted.
    public static func read(_ data: Data, maxBytes: Int = DataArchive.maxBytes) throws -> Reading {
        guard data.count <= maxBytes else {
            throw ReadError.tooLarge
        }
        let decoder = makeDecoder()
        guard let header = try? decoder.decode(Header.self, from: data), header.format == formatName else {
            throw ReadError.notBackup
        }
        guard header.formatVersion >= 1 else {
            throw ReadError.notBackup
        }
        guard header.formatVersion <= formatVersion else {
            throw ReadError.newerVersion(header.formatVersion)
        }
        guard let body = try? decoder.decode(Body.self, from: data) else {
            throw ReadError.notBackup
        }
        return Reading(archive: body.archive, unreadableRecords: body.unreadable)
    }

    private struct Header: Decodable {
        let format: String
        let formatVersion: Int

        enum CodingKeys: String, CodingKey {
            case format
            case formatVersion = "format_version"
        }
    }

    // ISO 8601: a person can read the dates; whole seconds are plenty for a schedule.
    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension DataArchive.Word: Codable {
    enum ExtraKeys: String, CodingKey {
        case lemma
        case meaningTR = "meaning_tr"
    }

    /// The progress record's own keys (a field a later build adds comes along), then the two
    /// reading aids in the same JSON object.
    public func encode(to encoder: Encoder) throws {
        try progress.encode(to: encoder)
        var c = encoder.container(keyedBy: ExtraKeys.self)
        try c.encodeIfPresent(lemma, forKey: .lemma)
        try c.encodeIfPresent(meaningTR, forKey: .meaningTR)
    }

    public init(from decoder: Decoder) throws {
        progress = try WordProgress(from: decoder)
        let c = try decoder.container(keyedBy: ExtraKeys.self)
        lemma = try? c.decodeIfPresent(String.self, forKey: .lemma)
        meaningTR = try? c.decodeIfPresent(String.self, forKey: .meaningTR)
    }
}

/// The file's JSON object.
private struct Body: Codable {
    let archive: DataArchive
    /// Records of `progress`, `custom_words.words` and `review_log` that could not be read.
    let unreadable: Int

    init(_ archive: DataArchive) {
        self.archive = archive
        self.unreadable = 0
    }

    enum CodingKeys: String, CodingKey {
        case format
        case formatVersion = "format_version"
        case about
        case exportedAt = "exported_at"
        case appVersion = "app_version"
        case contentVersion = "content_version"
        case progress
        case knownWords = "known_words"
        case customWords = "custom_words"
        case reviewLog = "review_log"
        case localMetrics = "local_metrics"
        case settings
        case recentSearches = "recent_searches"
    }

    struct CustomWordsBody: Codable {
        var nextID: Int?
        var words: [Lossy<CustomWord>]

        enum CodingKeys: String, CodingKey {
            case nextID = "next_id"
            case words
        }
    }

    /// One line of `known_words`.
    struct KnownWord: Encodable {
        let word: DataArchive.Word

        enum CodingKeys: String, CodingKey {
            case wordID = "word_id"
            case lemma
            case meaningTR = "meaning_tr"
            case how
            case changedAt = "changed_at"
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(word.progress.wordID, forKey: .wordID)
            try c.encodeIfPresent(word.lemma, forKey: .lemma)
            try c.encodeIfPresent(word.meaningTR, forKey: .meaningTR)
            try c.encode(DataCSV.knownHow(word.progress), forKey: .how)
            try c.encodeIfPresent(word.progress.lastSeenAt, forKey: .changedAt)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(DataArchive.formatName, forKey: .format)
        try c.encode(DataArchive.formatVersion, forKey: .formatVersion)
        try c.encode(DataArchive.aboutText, forKey: .about)
        try c.encode(archive.exportedAt, forKey: .exportedAt)
        try c.encodeIfPresent(archive.appVersion, forKey: .appVersion)
        try c.encodeIfPresent(archive.contentVersion, forKey: .contentVersion)
        try c.encode(archive.progress, forKey: .progress)
        try c.encode(archive.knownWords.map(KnownWord.init), forKey: .knownWords)
        try c.encode(
            CustomWordsBody(nextID: archive.customNextID, words: archive.customWords.map { Lossy(value: $0) }),
            forKey: .customWords
        )
        try c.encode(archive.reviewLog, forKey: .reviewLog)
        try c.encode(archive.localMetrics, forKey: .localMetrics)
        try c.encode(archive.settings, forKey: .settings)
        try c.encode(archive.recentSearches, forKey: .recentSearches)
    }

    /// Lenient: a missing part is empty, a record that cannot be read is counted and left out.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let exportedAt = (try? c.decodeIfPresent(Date.self, forKey: .exportedAt)) ?? Date(timeIntervalSince1970: 0)
        let progress = (try? c.decodeIfPresent([Lossy<DataArchive.Word>].self, forKey: .progress)) ?? []
        let custom = (try? c.decodeIfPresent(CustomWordsBody.self, forKey: .customWords)) ?? CustomWordsBody(nextID: nil, words: [])
        let log = (try? c.decodeIfPresent([Lossy<ReviewLogEntry>].self, forKey: .reviewLog)) ?? []
        let metrics = (try? c.decodeIfPresent(LocalMetrics.self, forKey: .localMetrics)) ?? LocalMetrics()
        let settings = (try? c.decodeIfPresent(DataArchive.Settings.self, forKey: .settings)) ?? DataArchive.Settings()
        let searches = (try? c.decodeIfPresent([String].self, forKey: .recentSearches)) ?? []

        archive = DataArchive(
            exportedAt: exportedAt,
            appVersion: try? c.decodeIfPresent(String.self, forKey: .appVersion),
            contentVersion: try? c.decodeIfPresent(String.self, forKey: .contentVersion),
            progress: progress.compactMap { $0.value },
            customWords: custom.words.compactMap { $0.value },
            customNextID: custom.nextID ?? CustomWordID.first,
            reviewLog: log.compactMap { $0.value },
            localMetrics: metrics,
            settings: settings,
            recentSearches: searches
        )
        unreadable = progress.filter { $0.value == nil }.count
            + custom.words.filter { $0.value == nil }.count
            + log.filter { $0.value == nil }.count
    }
}

/// An array element that may fail to decode on its own without failing the array.
struct Lossy<Value: Codable>: Codable {
    let value: Value?

    init(value: Value?) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        value = try? Value(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

// MARK: - Files

/// One file to share: its name and bytes.
public struct DataExportFile: Equatable, Sendable {
    public let name: String
    public let data: Data

    public init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
}

extension DataArchive {
    /// "lockglow-yedek-2026-10-23.json": the backup the import reads.
    public func backupFile(calendar: Calendar) throws -> DataExportFile {
        return DataExportFile(name: "lockglow-yedek-\(fileDay(calendar)).json", data: try encoded())
    }

    /// The four tables: progress, known words, the user's words and the measurements per day.
    /// Words are named in their English alphabetical order; days oldest first.
    public func tableFiles(calendar: Calendar) -> [DataExportFile] {
        let day = fileDay(calendar)
        return [
            DataExportFile(name: "lockglow-ilerleme-\(day).csv", data: DataCSV.progressTable(self, calendar: calendar)),
            DataExportFile(name: "lockglow-bildigin-kelimeler-\(day).csv", data: DataCSV.knownTable(self, calendar: calendar)),
            DataExportFile(name: "lockglow-kendi-kelimeler-\(day).csv", data: DataCSV.customWordsTable(self, calendar: calendar)),
            DataExportFile(name: "lockglow-olcumler-\(day).csv", data: DataCSV.metricsTable(self, calendar: calendar)),
        ]
    }

    private func fileDay(_ calendar: Calendar) -> String {
        return LocalMetrics.dayKey(exportedAt, calendar: calendar)
    }
}

// MARK: - CSV

/// The tables for Numbers, Excel or Google Sheets: UTF-8 with a byte order mark (Excel reads
/// Turkish letters right only with it), fields split by ";" (Turkish Excel's list separator,
/// because "," is the decimal comma there) and CRLF line ends (RFC 4180). Turkish headers.
public enum DataCSV {
    public static let separator = ";"

    /// One field: quoted when it holds the separator, a quote, a line break or spaces at an end;
    /// a quote inside is doubled. Text starting with = + - @ or a tab gets a leading ' so a
    /// spreadsheet shows it as text instead of running it as a formula.
    public static func field(_ text: String) -> String {
        var value = text
        if let first = value.unicodeScalars.first, "=+-@\t\r".unicodeScalars.contains(first) {
            value = "'" + value
        }
        let needsQuotes = value.contains(separator) || value.contains("\"") || value.contains("\n")
            || value.contains("\r") || value.hasPrefix(" ") || value.hasSuffix(" ")
        if needsQuotes {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }

    /// A table: the header line, then one line per row.
    public static func document(header: [String], rows: [[String]]) -> Data {
        var text = "\u{FEFF}"
        for line in [header] + rows {
            text += line.map(field).joined(separator: separator) + "\r\n"
        }
        return Data(text.utf8)
    }

    /// "2026-10-23 14:05" in `calendar`'s time zone; empty for nil.
    public static func dateTime(_ date: Date?, calendar: Calendar) -> String {
        guard let date = date else {
            return ""
        }
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return LocalMetrics.dayKey(date, calendar: calendar) + " " + pad(parts.hour ?? 0) + ":" + pad(parts.minute ?? 0)
    }

    /// "Yeni kelime", "Öğreniyorsun", "Bildiğin kelime" (docs/tasarim/terimler.md §4).
    public static func stateName(_ state: LearningState) -> String {
        switch state {
        case .new:
            return "Yeni kelime"
        case .learning:
            return "Öğreniyorsun"
        case .known:
            return "Bildiğin kelime"
        }
    }

    /// How a known word became known: "Biliyorum dedin" or "Tekrar'da öğrendin".
    public static func knownHow(_ progress: WordProgress) -> String {
        return progress.knownOverride ? "Biliyorum dedin" : "Tekrar'da öğrendin"
    }

    static func progressTable(_ archive: DataArchive, calendar: Calendar) -> Data {
        let header = [
            "Kelime", "Türkçe", "Durum", "Basamak", "Sıradaki tekrar", "Cevap sayısı",
            "Bilemediğin", "Son cevap", "Widget'ta görülme", "Kelime no",
        ]
        let rows = DataArchive.byLemma(archive.progress).map { word -> [String] in
            let p = word.progress
            return [
                word.lemma ?? "",
                word.meaningTR ?? "",
                stateName(p.state),
                p.state == .learning ? String(p.box) : "",
                p.state == .new ? "" : dateTime(p.dueAt, calendar: calendar),
                String(p.reviews),
                String(p.lapses),
                dateTime(p.lastReviewedAt, calendar: calendar),
                String(p.exposures),
                String(p.wordID),
            ]
        }
        return document(header: header, rows: rows)
    }

    static func knownTable(_ archive: DataArchive, calendar: Calendar) -> Data {
        let rows = archive.knownWords.map { word -> [String] in
            return [
                word.lemma ?? "",
                word.meaningTR ?? "",
                knownHow(word.progress),
                dateTime(word.progress.lastSeenAt, calendar: calendar),
                String(word.progress.wordID),
            ]
        }
        return document(header: ["Kelime", "Türkçe", "Nasıl", "Tarih", "Kelime no"], rows: rows)
    }

    static func customWordsTable(_ archive: DataArchive, calendar: Calendar) -> Data {
        let states = Dictionary(archive.progress.map { ($0.progress.wordID, $0.progress.state) }, uniquingKeysWith: { first, _ in first })
        let rows = archive.customWords.map { word -> [String] in
            return [
                word.lemma,
                word.meaningTR,
                word.exampleEN ?? "",
                word.note ?? "",
                dateTime(word.createdAt, calendar: calendar),
                stateName(states[word.id] ?? .new),
                String(word.id),
            ]
        }
        return document(header: ["Kelime", "Türkçe", "Örnek cümle", "Not", "Eklendiği gün", "Durum", "Kelime no"], rows: rows)
    }

    /// One line per local day with a measurement or a reminder. Whole numbers only: seconds,
    /// not minutes, so no decimal comma is needed.
    static func metricsTable(_ archive: DataArchive, calendar: Calendar) -> Data {
        let header = [
            "Gün", "Tekrar", "Yeni kelime", "Şıklı soru", "İlk denemede doğru",
            "Cevap süresi toplamı (sn)", "Süresi ölçülen cevap", "Tur", "Tur süresi toplamı (sn)",
            "Bitir ile biten tur", "Tanıtılan yeni kelime", "Dokunma toplamı",
            "Biliyorum kontrolü geçti", "Biliyorum kontrolü geçmedi", "Hatırlatma", "Hatırlatma açıldı",
        ]
        let metrics = archive.localMetrics
        var reminders: [String: (fired: Int, opened: Int)] = [:]
        for record in metrics.reminders {
            let key = LocalMetrics.dayKey(record.fireDate, calendar: calendar)
            let current = reminders[key] ?? (0, 0)
            reminders[key] = (current.fired + 1, current.opened + (record.opened ? 1 : 0))
        }
        let byDay = Dictionary(metrics.days.map { ($0.day, $0) }, uniquingKeysWith: { _, last in last })
        let days = Set(byDay.keys).union(reminders.keys).sorted()
        let rows = days.map { key -> [String] in
            let day = byDay[key] ?? DayMetrics(day: key)
            let reminder = reminders[key] ?? (0, 0)
            return [
                key,
                String(day.reviews),
                String(day.newWords),
                String(day.firstTryAnswers),
                String(day.firstTryCorrect),
                String(Int(day.answerSeconds.rounded())),
                String(day.timedAnswers),
                String(day.roundSeconds.count),
                String(Int(day.roundSeconds.reduce(0, +).rounded())),
                String(day.roundsEndedEarly),
                String(day.newWordTaps.count),
                String(day.newWordTaps.reduce(0, +)),
                String(day.knownChecksPassed),
                String(day.knownChecksFailed),
                String(reminder.fired),
                String(reminder.opened),
            ]
        }
        return document(header: header, rows: rows)
    }

    private static func pad(_ value: Int) -> String {
        return value < 10 ? "0\(value)" : String(value)
    }
}
