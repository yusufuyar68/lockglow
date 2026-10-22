import Foundation

/// One answer in the review log (`ReviewLog`; docs/ozellik_planlari/fsrs.md 4.1).
public struct ReviewLogEntry: Codable, Equatable, Sendable {
    public enum Source: String, Codable, Sendable {
        /// "Tekrar": a question, the recall screen, a "Hatırla" result or the "Biliyorum" check.
        case review
        /// "Bilmiyorum" on the widget (`ProgressIngest`).
        case widget
    }

    /// The word's schedule just before an answer whose earlier answers are not in the log: they
    /// came before the log existed. `FSRS.seededCard` estimates the word's memory from it.
    public struct Seed: Codable, Equatable, Sendable {
        public let state: LearningState
        public let box: Int
        public let lapses: Int
        public let dueAt: Date?
        public let knownOverride: Bool

        public init(state: LearningState, box: Int, lapses: Int, dueAt: Date?, knownOverride: Bool) {
            self.state = state
            self.box = box
            self.lapses = lapses
            self.dueAt = dueAt
            self.knownOverride = knownOverride
        }

        public init(_ progress: WordProgress) {
            self.init(
                state: progress.state,
                box: progress.box,
                lapses: progress.lapses,
                dueAt: progress.dueAt,
                knownOverride: progress.knownOverride
            )
        }

        enum CodingKeys: String, CodingKey {
            case state
            case box
            case lapses
            case dueAt = "due_at"
            case knownOverride = "known_override"
        }
    }

    public let wordID: Int
    public let at: Date
    public let grade: ReviewGrade
    public let source: Source
    /// `WordProgress.reviews` after this answer: 1 is the word's first answer ever.
    public let reviews: Int
    /// True when the answer was the one check after "Biliyorum"; nil (left out of the file)
    /// otherwise.
    public let knownCheck: Bool?
    /// Only on a word's first answer after the log began, when it had answers before.
    public let seed: Seed?

    public init(
        wordID: Int,
        at: Date,
        grade: ReviewGrade,
        source: Source,
        reviews: Int,
        knownCheck: Bool? = nil,
        seed: Seed? = nil
    ) {
        self.wordID = wordID
        self.at = at
        self.grade = grade
        self.source = source
        self.reviews = reviews
        self.knownCheck = knownCheck
        self.seed = seed
    }

    /// The entry of the answer that turned `before` into `after` (`Leitner.review`); nil when
    /// `after` is not exactly one answer later.
    public init?(before: WordProgress, after: WordProgress, source: Source) {
        guard before.wordID == after.wordID, after.reviews == before.reviews + 1,
              let at = after.lastReviewedAt, let grade = after.lastGrade else {
            return nil
        }
        // The log and `lastReviewedAt` came with the same build: a word answered before without
        // a recorded answer time has answers the log never saw.
        let unlogged = before.reviews > 0 && before.lastReviewedAt == nil
        self.init(
            wordID: after.wordID,
            at: at,
            grade: grade,
            source: source,
            reviews: after.reviews,
            knownCheck: before.awaitsKnownCheck ? true : nil,
            seed: unlogged ? Seed(before) : nil
        )
    }

    enum CodingKeys: String, CodingKey {
        case wordID = "word_id"
        case at
        case grade
        case source
        case reviews
        case knownCheck = "known_check"
        case seed
    }
}

/// The review log: every answer, one JSON object per line (`review_log.jsonl` next to
/// `progress.json`, app-private). `progress.json` keeps only each word's last answer; FSRS needs
/// them all (fsrs.md 4.1). It rebuilds each word's memory from them exactly (`FSRS.replay`),
/// fits personal parameters to them later, and starts over from them when the parameters change.
/// Leitner never reads the log: for now it is only written.
///
/// Appending never rewrites earlier lines. A line that cannot be read (cut short by a crash, or
/// in a shape a later build wrote) is skipped, never the whole log. Above `maxBytes` the oldest
/// lines go, down to `trimmedBytes`; at about 90 bytes an answer, 8 MB is some 90,000 answers,
/// years of daily study. A word whose first answers went with them gets no replay
/// (`FSRSReplay.incomplete`).
public struct ReviewLog: Sendable {
    public let fileURL: URL
    public let maxBytes: Int
    public let trimmedBytes: Int

    public init(fileURL: URL, maxBytes: Int = 8_000_000, trimmedBytes: Int = 6_000_000) {
        self.fileURL = fileURL
        self.maxBytes = maxBytes
        self.trimmedBytes = min(trimmedBytes, maxBytes)
    }

    /// Application Support/review_log.jsonl, beside `ProgressStore.defaultURL()`.
    public static func defaultURL() throws -> URL {
        return try ProgressStore.defaultURL().deletingLastPathComponent().appendingPathComponent("review_log.jsonl")
    }

    /// Adds `entries` at the end, in order.
    public func append(_ entries: [ReviewLogEntry]) throws {
        guard !entries.isEmpty else {
            return
        }
        var data = Data()
        for entry in entries {
            data.append(try ReviewLog.line(entry))
            data.append(ReviewLog.newline)
        }
        if try write(data) > maxBytes {
            try trim()
        }
    }

    /// Adds the answer that turned `before` into `after`; nothing when it was not one answer
    /// (`ReviewLogEntry(before:after:source:)`).
    public func append(before: WordProgress, after: WordProgress, source: ReviewLogEntry.Source) throws {
        guard let entry = ReviewLogEntry(before: before, after: after, source: source) else {
            return
        }
        try append([entry])
    }

    /// Every readable entry, in the order written. Empty when there is no log yet.
    public func entries() throws -> [ReviewLogEntry] {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                return []
            }
            throw error
        }
        return ReviewLog.decode(data)
    }

    /// "İlerlemeyi sıfırla": the answers go with the progress.
    public func removeAll() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        try FileManager.default.removeItem(at: fileURL)
    }

    /// One entry as its line, without the line break.
    public static func line(_ entry: ReviewLogEntry) throws -> Data {
        return try makeEncoder().encode(entry)
    }

    /// The entries in a log's bytes; lines that cannot be read are skipped.
    public static func decode(_ data: Data) -> [ReviewLogEntry] {
        let decoder = makeDecoder()
        return data.split(separator: newline).compactMap { line in
            try? decoder.decode(ReviewLogEntry.self, from: Data(line))
        }
    }

    private static let newline: UInt8 = 0x0A

    /// Appends `data` (creating the file) and returns the file's new size. A last line that a
    /// crash cut short first gets its line break, so it does not swallow the new ones.
    private func write(_ data: Data) throws -> Int {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            try data.write(to: fileURL, options: [.atomic])
            return data.count
        }
        let handle = try FileHandle(forUpdating: fileURL)
        defer {
            try? handle.close()
        }
        let end = try handle.seekToEnd()
        var bytes = data
        if end > 0 {
            try handle.seek(toOffset: end - 1)
            if try handle.read(upToCount: 1) != Data([ReviewLog.newline]) {
                bytes.insert(ReviewLog.newline, at: 0)
            }
            try handle.seek(toOffset: end)
        }
        try handle.write(contentsOf: bytes)
        return Int(end) + bytes.count
    }

    /// Keeps the newest whole lines that fit in `trimmedBytes`.
    private func trim() throws {
        let lines = try Data(contentsOf: fileURL).split(separator: ReviewLog.newline)
        var kept: [Data] = []
        var size = 0
        for line in lines.reversed() {
            if size + line.count + 1 > trimmedBytes {
                break
            }
            kept.append(Data(line))
            size += line.count + 1
        }
        var data = Data(capacity: size)
        for line in kept.reversed() {
            data.append(line)
            data.append(ReviewLog.newline)
        }
        try data.write(to: fileURL, options: [.atomic])
    }

    // The same date form as progress.json: seconds since 1970, an exact round trip.
    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
}
