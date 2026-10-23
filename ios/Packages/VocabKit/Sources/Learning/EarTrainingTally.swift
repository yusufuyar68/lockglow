import Foundation

/// The local counter of "Kulak alıştırması": per sound pair (group), how many questions were
/// answered, how many were heard right, and the last few results. Kept apart from the Leitner
/// progress on purpose: telling two sounds apart is not a review of a word, so nothing here
/// changes `progress.json`, the review log or the daily goal.
///
/// The counter decides which groups a mixed round asks more (`need`) and gives the calm line under
/// each group ("Son 10 soruda 7 tanesini ayırdın."). No percentage, no streak (learning
/// principles 2.5, §3).
public struct EarTrainingTally: Codable, Equatable, Sendable {
    /// Results kept per group for `need` and the group's line.
    public static let recentLimit = 10

    public struct Record: Codable, Equatable, Sendable {
        /// Questions answered in this group, ever.
        public internal(set) var heard: Int
        /// Of those, heard right.
        public internal(set) var right: Int
        /// The last results (true: heard right), oldest first, at most `recentLimit`.
        public internal(set) var recent: [Bool]
        public internal(set) var lastAnsweredAt: Date?

        public init(heard: Int = 0, right: Int = 0, recent: [Bool] = [], lastAnsweredAt: Date? = nil) {
            self.heard = heard
            self.right = right
            self.recent = recent
            self.lastAnsweredAt = lastAnsweredAt
        }

        enum CodingKeys: String, CodingKey {
            case heard
            case right
            case recent
            case lastAnsweredAt = "last_answered_at"
        }

        /// Right answers among `recent`.
        public var recentRight: Int {
            return recent.filter { $0 }.count
        }
    }

    /// Group id → its record. Groups never answered have none.
    public private(set) var groups: [String: Record]

    public init(groups: [String: Record] = [:]) {
        self.groups = groups
    }

    public func record(for groupID: String) -> Record? {
        return groups[groupID]
    }

    public var isEmpty: Bool {
        return groups.isEmpty
    }

    /// One answered question.
    public mutating func add(groupID: String, isRight: Bool, at now: Date = Date()) {
        var record = groups[groupID] ?? Record()
        record.heard += 1
        if isRight {
            record.right += 1
        }
        record.recent.append(isRight)
        if record.recent.count > EarTrainingTally.recentLimit {
            record.recent.removeFirst(record.recent.count - EarTrainingTally.recentLimit)
        }
        record.lastAnsweredAt = now
        groups[groupID] = record
    }

    /// How much a group needs listening, the weight of a mixed round's draw: 0.75 when the last
    /// ten were all heard right, 2 before the first answer, 3.25 when all ten were mixed up. The
    /// miss rate of the recent results is smoothed toward one half, so one answer moves it little.
    public func need(groupID: String) -> Double {
        let recent = groups[groupID]?.recent ?? []
        let misses = Double(recent.filter { !$0 }.count)
        let missRate = (misses + 1) / (Double(recent.count) + 2)
        return 0.5 + 3 * missRate
    }

    /// The group's line in the list: nil before its first answer (the list says "Henüz
    /// dinlemedin." itself), otherwise "Son 10 soruda 7 tanesini ayırdın."; with none heard
    /// right only how many were heard, never a "0" (learning principles 2.5).
    public func line(for groupID: String) -> String? {
        guard let record = groups[groupID], !record.recent.isEmpty else {
            return nil
        }
        let count = record.recent.count
        let right = record.recentRight
        if right == 0 {
            return "Son \(count) soruyu dinledin."
        }
        return "Son \(count) soruda \(right) tanesini ayırdın."
    }
}

/// What a finished round says: "10 soru dinledin, 7 tanesini ayırdın." (the "Tekrar" summary's
/// pattern; no wrong count, no percentage, no "0"). Nil before the first answer.
public enum EarTrainingSummary {
    public static func line(asked: Int, right: Int) -> String? {
        guard asked > 0 else {
            return nil
        }
        if right == 0 {
            return "\(asked) soru dinledin."
        }
        return "\(asked) soru dinledin, \(right) tanesini ayırdın."
    }
}

// MARK: - File

/// App-private file of the counter: Application Support/ear_training.json,
/// `{"format": 1, "groups": {...}}`. Single writer: the app. Best effort, like the local
/// measurements: a counter is not progress.
/// - No file: an empty counter.
/// - A file that exists but cannot be read now (before the first unlock): `load` throws, and the
///   caller does not save over it.
/// - A file that cannot be decoded (damaged, a newer format): an empty counter; the next save
///   replaces it.
public struct EarTrainingStore: Sendable {
    public static let format = 1

    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Application Support/ear_training.json (created on the first save).
    public static func defaultURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appendingPathComponent("ear_training.json")
    }

    public enum LoadError: Error, Equatable {
        /// The file exists but could not be read: try again later, do not save meanwhile.
        case unreadable(String)
    }

    public func load() throws -> EarTrainingTally {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                throw LoadError.unreadable(error.localizedDescription)
            }
            return EarTrainingTally()
        }
        guard let body = try? EarTrainingStore.decoder().decode(FileBody.self, from: data),
              body.format == EarTrainingStore.format else {
            return EarTrainingTally()
        }
        return EarTrainingTally(groups: body.groups)
    }

    /// Writes the counter atomically.
    public func save(_ tally: EarTrainingTally) throws {
        let body = FileBody(format: EarTrainingStore.format, groups: tally.groups)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(body)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: [.atomic])
    }

    /// Deletes the file ("Sayaçları sıfırla"). No file is fine.
    public func remove() throws {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                throw error
            }
        }
    }

    private struct FileBody: Codable {
        let format: Int
        let groups: [String: EarTrainingTally.Record]
    }

    private static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
