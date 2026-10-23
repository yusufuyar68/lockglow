import Foundation
import CoreModels

// "iCloud ile eşitle" (docs/ozellik_planlari/icloud_esitleme.md): the copy of the progress and of
// the user's words kept in iCloud (`SyncSnapshot`), and what this device remembers about its last
// sync (`SyncState`, `SyncStateStore`). Pure values and one small file; the merge is `SyncMerge`,
// the iCloud key-value store and the screen are in the app (ios/App/Sync*.swift).

// MARK: - Snapshot

/// What iCloud holds: one JSON value (`encoded`), written whole by the device that synced last.
///
/// Cards are keyed by card id, the same on every device. A user's word is keyed by a random
/// `uuid` instead: every device numbers its own words from `CustomWordID.first`, so two devices
/// give the same id to different words. Each device keeps its own ids and maps them to uuids
/// (`SyncState.uuids`); nothing on a device is renumbered.
///
/// Every record carries the time its version reached iCloud (`changedAt`, `deletedAt`; see
/// `SyncMerge`'s clock). It tells a newer change from an older copy that won a race in iCloud
/// (two devices wrote at once and iCloud kept the older one).
public struct SyncSnapshot: Codable, Equatable, Sendable {
    /// The `format` this build writes and reads. A copy with a newer one is never overwritten
    /// (`decode` throws `newerFormat`). Raise it when `WordProgress` or `CustomWord` gains a field
    /// (SyncSnapshotTests fails as a reminder): an older build would drop the field from every
    /// record it writes back. 2: `WordProgress.fsrs` (is5-fsrs).
    public static let currentFormat = 2

    public var format: Int
    /// "İlerlemeyi sıfırla" on a syncing device at this time: progress from before it is gone on
    /// every device that syncs (`SyncMerge`). Nil: never reset.
    public var resetAt: Date?
    /// Progress of cards (ids below `CustomWordID.first`), by id.
    public var cards: [SyncCard]
    /// The user's words with their progress, by uuid.
    public var words: [SyncWord]
    /// Deleted user words, by uuid: a device that still has one deletes it too.
    public var deleted: [SyncDeletion]

    public init(resetAt: Date? = nil, cards: [SyncCard] = [], words: [SyncWord] = [], deleted: [SyncDeletion] = []) {
        self.format = SyncSnapshot.currentFormat
        self.resetAt = resetAt
        self.cards = cards
        self.words = words
        self.deleted = deleted
        normalize()
    }

    public var isEmpty: Bool {
        return resetAt == nil && cards.isEmpty && words.isEmpty && deleted.isEmpty
    }

    /// The latest time any record of this copy reached iCloud.
    var latestChange: Date? {
        let times = cards.map { $0.changedAt }
            + words.flatMap { [$0.changedAt, $0.progressChangedAt].compactMap { $0 } }
            + deleted.map { $0.deletedAt }
        return times.max()
    }

    /// One record per id and uuid (the first one wins; for deletions the latest), sorted, so
    /// equal snapshots encode equally: cards outside the card range are dropped, word progress
    /// gets `wordID` 0, and a uuid that is both a word and deleted stays a word (nothing is lost
    /// on a damaged copy).
    mutating func normalize() {
        format = SyncSnapshot.currentFormat
        var seenCards = Set<Int>()
        cards = cards
            .filter { !CustomWordID.contains($0.progress.wordID) && seenCards.insert($0.progress.wordID).inserted }
            .sorted { $0.progress.wordID < $1.progress.wordID }
        var seenWords = Set<String>()
        words = words
            .filter { !$0.uuid.isEmpty && seenWords.insert($0.uuid).inserted }
            .map { word in
                var copy = word
                copy.progress = word.progress.map { $0.reidentified(0) }
                if copy.progress == nil {
                    copy.progressChangedAt = nil
                } else if copy.progressChangedAt == nil {
                    copy.progressChangedAt = copy.changedAt
                }
                return copy
            }
            .sorted { $0.uuid < $1.uuid }
        var latest: [String: Date] = [:]
        for deletion in deleted where !deletion.uuid.isEmpty && !seenWords.contains(deletion.uuid) {
            latest[deletion.uuid] = max(latest[deletion.uuid] ?? deletion.deletedAt, deletion.deletedAt)
        }
        deleted = latest.map { SyncDeletion(uuid: $0.key, deletedAt: $0.value) }.sorted { $0.uuid < $1.uuid }
    }

    enum CodingKeys: String, CodingKey {
        case format
        case resetAt = "reset_at"
        case cards
        case words
        case deleted
    }
}

/// A card's progress in iCloud.
public struct SyncCard: Codable, Equatable, Sendable {
    public var progress: WordProgress
    /// When this version reached iCloud.
    public var changedAt: Date

    public init(progress: WordProgress, changedAt: Date) {
        self.progress = progress
        self.changedAt = changedAt
    }

    enum CodingKeys: String, CodingKey {
        case progress
        case changedAt = "changed_at"
    }
}

/// A deleted user word in iCloud.
public struct SyncDeletion: Codable, Equatable, Sendable {
    public var uuid: String
    /// When the deletion reached iCloud.
    public var deletedAt: Date

    public init(uuid: String, deletedAt: Date) {
        self.uuid = uuid
        self.deletedAt = deletedAt
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case deletedAt = "deleted_at"
    }
}

/// A user's word as iCloud keeps it: `CustomWord`'s fields under a uuid, with its progress.
public struct SyncWord: Codable, Equatable, Sendable {
    public var uuid: String
    public var lemma: String
    public var meaningTR: String
    public var exampleEN: String?
    public var note: String?
    public var createdAt: Date
    public var updatedAt: Date
    /// When this version of the text (or the word's return after a deletion) reached iCloud.
    public var changedAt: Date
    /// The word's progress with `wordID` 0: each device keeps it under its own id.
    public var progress: WordProgress?
    /// When this version of the progress reached iCloud; nil exactly when `progress` is.
    public var progressChangedAt: Date?

    public init(uuid: String, word: CustomWord, changedAt: Date, progress: WordProgress? = nil, progressChangedAt: Date? = nil) {
        self.uuid = uuid
        self.lemma = word.lemma
        self.meaningTR = word.meaningTR
        self.exampleEN = word.exampleEN
        self.note = word.note
        self.createdAt = word.createdAt
        self.updatedAt = word.updatedAt
        self.changedAt = changedAt
        self.progress = progress.map { $0.reidentified(0) }
        self.progressChangedAt = progress == nil ? nil : (progressChangedAt ?? changedAt)
    }

    /// The word under this device's id.
    public func customWord(id: Int) -> CustomWord {
        return CustomWord(
            id: id,
            lemma: lemma,
            meaningTR: meaningTR,
            exampleEN: exampleEN,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Same text and dates; the progress and the iCloud times are not compared.
    func hasSameContent(as other: SyncWord) -> Bool {
        return lemma == other.lemma
            && meaningTR == other.meaningTR
            && exampleEN == other.exampleEN
            && note == other.note
            && createdAt == other.createdAt
            && updatedAt == other.updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case lemma
        case meaningTR = "meaning_tr"
        case exampleEN = "example_en"
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case changedAt = "changed_at"
        case progress
        case progressChangedAt = "progress_changed_at"
    }
}

// MARK: - Encoding

extension SyncSnapshot {
    public enum DecodeError: Error, Equatable {
        /// Written by a newer build. Never overwritten: this build asks for an update instead.
        case newerFormat(Int)
        /// Not a snapshot this build can read. Not overwritten either (it may hold the only copy
        /// of another device's words); the user can delete it on the iCloud screen.
        case unreadable
    }

    /// Sorted keys and seconds since 1970, like progress.json: equal snapshots give equal bytes.
    public func encoded() throws -> Data {
        return try SyncCoding.encoder().encode(self)
    }

    /// The snapshot in `data`, normalized (`normalize`). Throws `DecodeError`.
    public static func decode(_ data: Data) throws -> SyncSnapshot {
        let decoder = SyncCoding.decoder()
        guard let probe = try? decoder.decode(FormatProbe.self, from: data), probe.format >= 1 else {
            throw DecodeError.unreadable
        }
        guard probe.format <= SyncSnapshot.currentFormat else {
            throw DecodeError.newerFormat(probe.format)
        }
        guard var snapshot = try? decoder.decode(SyncSnapshot.self, from: data) else {
            throw DecodeError.unreadable
        }
        snapshot.normalize()
        return snapshot
    }

    private struct FormatProbe: Decodable {
        let format: Int
    }
}

/// The JSON coders of everything iCloud sync writes. Also used to round dates the way a JSON
/// round trip does (`canonical`): a `Date` made by `Date()` comes back from seconds since 1970 a
/// tiny bit different, and the merge must not take that for a change.
enum SyncCoding {
    static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    /// `value` after one JSON round trip (a fixed point: a second round trip changes nothing).
    /// `value` itself when it cannot be encoded.
    static func canonical<T: Codable>(_ value: T) -> T {
        guard let data = try? encoder().encode(value),
              let decoded = try? decoder().decode(T.self, from: data) else {
            return value
        }
        return decoded
    }
}

// MARK: - Progress records

extension WordProgress {
    /// The same record under another word id (`wordID` is a `let`). Copies every field: when
    /// `WordProgress` gains one, add it here (SyncSnapshotTests counts the fields).
    public func reidentified(_ id: Int) -> WordProgress {
        var copy = WordProgress(wordID: id)
        copy.state = state
        copy.box = box
        copy.dueAt = dueAt
        copy.exposures = exposures
        copy.lastSeenAt = lastSeenAt
        copy.reviews = reviews
        copy.lapses = lapses
        copy.knownOverride = knownOverride
        copy.saved = saved
        copy.lastReviewedAt = lastReviewedAt
        copy.lastGrade = lastGrade
        copy.firstReviewedAt = firstReviewedAt
        copy.refresherStep = refresherStep
        copy.fsrs = fsrs
        return copy
    }

    /// The last time anything dated happened to the word: an answer, a widget tap or
    /// "Biliyorum". Nil for a record without any date (it carries nothing a reset must keep).
    var lastChange: Date? {
        return [lastReviewedAt, lastSeenAt, firstReviewedAt].compactMap { $0 }.max()
    }
}

// MARK: - This device

/// What this device remembers between syncs (Application Support/sync_state.json,
/// `SyncStateStore`). Losing it loses nothing: the next sync then works like turning sync on
/// (`joined` false), and unchanged words find their uuids again by their text (`SyncMerge`).
public struct SyncState: Codable, Equatable, Sendable {
    public static let currentFormat = 1

    public var format: Int
    /// This device has met iCloud's copy since sync was turned on. False before that (and after
    /// sync was turned off, iCloud's account changed or iCloud's first download came): that first
    /// meeting only adds, so turning sync on never deletes or resets anything on this device.
    public var joined: Bool
    /// The reset this device's progress belongs to (`SyncSnapshot.resetAt`); set by "İlerlemeyi
    /// sıfırla" while sync is on, until iCloud has it.
    public var resetAt: Date?
    /// The user's words: this device's id → uuid. An id is never forgotten (ids are never reused).
    public var uuids: [Int: String]
    /// iCloud's copy after the last sync that reached this device and was sent to iCloud. It tells
    /// which side changed a word since (`SyncMerge`). Nil before the first such sync.
    public var base: SyncSnapshot?

    public init(joined: Bool = false, resetAt: Date? = nil, uuids: [Int: String] = [:], base: SyncSnapshot? = nil) {
        self.format = SyncState.currentFormat
        self.joined = joined
        self.resetAt = resetAt
        self.uuids = uuids
        self.base = base
    }

    /// Sync was turned off, or iCloud's account changed: the next sync starts again like the first
    /// one, and no copy of the words stays here. Only the uuids stay (no text in them).
    public func leaving() -> SyncState {
        return SyncState(uuids: uuids)
    }

    /// iCloud's first download on this device came: what this device wrote before may have been
    /// dropped, so the next sync starts like the first one. A reset not yet in iCloud stays.
    public func rejoining() -> SyncState {
        return SyncState(resetAt: resetAt, uuids: uuids)
    }

    /// "İlerlemeyi sıfırla" at `date` while sync is on: the next sync removes older progress from
    /// iCloud and from the other devices.
    public func resetting(at date: Date) -> SyncState {
        var copy = self
        copy.resetAt = date
        return copy
    }

    enum CodingKeys: String, CodingKey {
        case format
        case joined
        case resetAt = "reset_at"
        case uuids
        case base
    }
}

/// Reads and writes `SyncState` (Application Support/sync_state.json). A file that exists but
/// cannot be read (a locked device) throws, so no sync runs on a state that is not this device's.
/// A file that cannot be decoded (damaged, or a newer build's) gives a fresh state: safe, see
/// `SyncState`.
public struct SyncStateStore: Sendable {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Default location: Application Support/sync_state.json (created on first save).
    public static func defaultURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appendingPathComponent("sync_state.json")
    }

    public enum LoadError: Error, Equatable {
        case unreadable(String)
    }

    public func load() throws -> SyncState {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                throw LoadError.unreadable(error.localizedDescription)
            }
            return SyncState()
        }
        guard let state = try? SyncCoding.decoder().decode(SyncState.self, from: data),
              state.format >= 1, state.format <= SyncState.currentFormat else {
            return SyncState()
        }
        return state
    }

    public func save(_ state: SyncState) throws {
        var copy = state
        copy.format = SyncState.currentFormat
        let data = try SyncCoding.encoder().encode(copy)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: [.atomic])
    }
}
