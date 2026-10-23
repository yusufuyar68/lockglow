import Foundation
import CoreModels

// "Yedek dosyası seç" (Ayarlar, İlerleme, Verilerin): a backup (`DataArchive`) joins what this
// phone already has. Nothing on the phone is deleted. Pure and tested on Linux
// (Tests/LearningTests/DataImportTests.swift); the app saves the result
// (ios/App/AppModel+DataControls.swift).
//
// Rules:
// 1. Checks. A record that breaks a rule below is left out and counted (`skipped`); the rest is
//    still imported. A file that is not a backup, or is from a later format, is refused whole
//    (`DataArchive.read`).
// 2. A word in the file only: its record is added.
// 3. A word on both sides: the record with more answers stays whole (`prefersIncoming`); with
//    as many answers, the one answered last; never answered on either side, a "Biliyorum" before
//    a new word, then the one seen last; a full tie keeps the phone's record. Fields are never
//    mixed from two records.
// 4. The user's own words: one with the same English word as a word on the phone (case ignored)
//    is that word; the phone's text stays and the two progress records follow rule 3. Any other
//    keeps its number when the phone never gave it out, otherwise gets the next free one; its
//    progress and answers move with it. Progress or answers of an own word the file no longer
//    has (deleted on the other phone) are left out.
// 5. Answers (`review_log`): each word keeps the answers of the side whose record stayed, so
//    the log and the progress tell the same story (FSRS replays them per word).
// 6. Local measurements, settings and recent searches are not imported: they describe the other
//    phone. The phone keeps its own.
// Importing the same file twice changes nothing the second time.

public enum DataImport {
    /// Dates after this much past the import are refused (the other phone's clock may run a
    /// little ahead).
    public static let clockAllowance: TimeInterval = 86_400
    /// The next review may lie this far ahead at most (the longest Leitner wait is 120 days).
    public static let maxDueAhead: TimeInterval = 2 * 365 * 86_400
    /// Dates before this are refused (Lockglow did not exist).
    public static let earliestDate = Date(timeIntervalSince1970: 1_577_836_800) // 2020-01-01

    // MARK: Checks

    /// Whether a progress record can be imported as it is.
    public static func isValid(_ p: WordProgress, now: Date) -> Bool {
        guard p.wordID > 0, (0...Leitner.maxBox).contains(p.box),
              p.reviews >= 0, p.lapses >= 0, p.lapses <= p.reviews, p.exposures >= 0 else {
            return false
        }
        if p.state == .learning && p.box < 1 {
            return false
        }
        if let step = p.refresherStep, step < 0 {
            return false
        }
        let past = [p.lastSeenAt, p.lastReviewedAt, p.firstReviewedAt].compactMap { $0 }
        if past.contains(where: { !isPlausiblePast($0, now: now) }) {
            return false
        }
        if let due = p.dueAt, due < earliestDate || due > now.addingTimeInterval(maxDueAhead) {
            return false
        }
        return true
    }

    /// The word with its text cleaned as the form would save it; nil when the form would refuse
    /// it (`CustomWordDraft.problems`, the duplicate check aside) or its number or dates are off.
    public static func checkedCustomWord(_ word: CustomWord, now: Date) -> CustomWord? {
        let draft = CustomWordDraft(word)
        guard CustomWordID.contains(word.id), draft.problems().isEmpty,
              isPlausiblePast(word.createdAt, now: now), isPlausiblePast(word.updatedAt, now: now) else {
            return nil
        }
        return CustomWord(
            id: word.id,
            lemma: draft.normalizedLemma,
            meaningTR: draft.normalizedMeaning,
            exampleEN: draft.normalizedExample,
            note: draft.normalizedNote,
            createdAt: word.createdAt,
            updatedAt: max(word.updatedAt, word.createdAt)
        )
    }

    public static func isValid(_ entry: ReviewLogEntry, now: Date) -> Bool {
        return entry.wordID > 0 && entry.reviews >= 1 && isPlausiblePast(entry.at, now: now)
    }

    private static func isPlausiblePast(_ date: Date, now: Date) -> Bool {
        return date >= earliestDate && date <= now.addingTimeInterval(clockAllowance)
    }

    // MARK: Conflicts

    /// Rule 3: whether the file's record replaces the phone's for the same word.
    public static func prefersIncoming(_ incoming: WordProgress, over device: WordProgress) -> Bool {
        if incoming.reviews != device.reviews {
            return incoming.reviews > device.reviews
        }
        let past = Date.distantPast
        let answered = (incoming.lastReviewedAt ?? past, device.lastReviewedAt ?? past)
        if answered.0 != answered.1 {
            return answered.0 > answered.1
        }
        if rank(incoming.state) != rank(device.state) {
            return rank(incoming.state) > rank(device.state)
        }
        return (incoming.lastSeenAt ?? past) > (device.lastSeenAt ?? past)
    }

    private static func rank(_ state: LearningState) -> Int {
        switch state {
        case .new:
            return 0
        case .learning:
            return 1
        case .known:
            return 2
        }
    }

    /// Rules 2 and 3 over whole dictionaries: the phone's records with the file's added or
    /// preferred ones. `incoming` must already use the phone's ids (`Plan.incomingProgress`).
    public static func mergedProgress(device: [Int: WordProgress], incoming: [Int: WordProgress]) -> [Int: WordProgress] {
        var merged = device
        for (id, record) in incoming {
            if let current = device[id], !prefersIncoming(record, over: current) {
                continue
            }
            merged[id] = record
        }
        return merged
    }

    /// Rule 5: the phone's answers, except for the words whose record now comes from the file
    /// (their answers come from the file instead, after the phone's, in the file's order).
    public static func mergedLog(
        device: [ReviewLogEntry],
        incoming: [Int: [ReviewLogEntry]],
        deviceProgress: [Int: WordProgress],
        incomingProgress: [Int: WordProgress]
    ) -> [ReviewLogEntry] {
        let fromFile = Set(incomingProgress.compactMap { id, record -> Int? in
            if let current = deviceProgress[id], !prefersIncoming(record, over: current) {
                return nil
            }
            return id
        })
        let kept = device.filter { !fromFile.contains($0.wordID) }
        let added = incoming.keys.sorted().filter { fromFile.contains($0) }.flatMap { incoming[$0] ?? [] }
        return kept + added
    }

    // MARK: Plan

    /// What the import would change, in plain Turkish lines (`lines`). Numbers are given after a
    /// colon, never with a suffix (docs/tasarim/terimler.md §1).
    public struct Summary: Equatable, Sendable {
        /// Valid progress records in the file (own words included), and how many are known words.
        public var wordsInFile = 0
        public var knownInFile = 0
        /// Valid own words in the file.
        public var customWordsInFile = 0
        /// Words the phone has no record of.
        public var wordsAdded = 0
        /// Words on both sides whose record comes from the file.
        public var wordsReplaced = 0
        /// Words on both sides whose phone record stays (same records included).
        public var wordsKept = 0
        /// Own words added to the phone's list, and own words the phone already had.
        public var customWordsAdded = 0
        public var customWordsMatched = 0
        /// Records left out: unreadable, or breaking a rule.
        public var skipped = 0
        public var exportedAt: Date?

        public init() {}

        /// The file has nothing to import.
        public var isEmpty: Bool {
            return wordsInFile == 0 && customWordsInFile == 0
        }

        /// The import would change nothing (an empty file, or one already imported).
        public var changesNothing: Bool {
            return wordsAdded == 0 && wordsReplaced == 0 && customWordsAdded == 0
        }

        public var lines: [String] {
            var result: [String] = []
            result.append("Dosyadaki kelime kaydı: \(wordsInFile)")
            if knownInFile > 0 {
                result.append("Bunlardan bildiğin kelime: \(knownInFile)")
            }
            if customWordsInFile > 0 {
                result.append("Kendi kelimen: \(customWordsInFile)")
            }
            if wordsAdded > 0 {
                result.append("Bu telefona eklenecek kelime: \(wordsAdded)")
            }
            if wordsReplaced + wordsKept > 0 {
                result.append("İki yerde de olan kelime: \(wordsReplaced + wordsKept). Daha çok cevap verdiğin kayıt kalır.")
            }
            if customWordsMatched > 0 {
                result.append("Bu telefonda zaten olan kendi kelime: \(customWordsMatched)")
            }
            if skipped > 0 {
                result.append("Okunamayan kayıt: \(skipped). Bunlar alınmaz.")
            }
            return result
        }
    }

    /// Everything the app saves for an import, worked out against the phone's data.
    public struct Plan: Equatable, Sendable {
        /// The phone's own words with the file's new ones after them.
        public let customWords: CustomWordList
        /// The file's valid records with the phone's ids (own words renumbered or matched).
        public let incomingProgress: [Int: WordProgress]
        /// The file's valid answers by word, with the phone's ids.
        public let incomingLog: [Int: [ReviewLogEntry]]
        /// The progress after the import (`mergedProgress`).
        public let progress: [Int: WordProgress]
        public let summary: Summary

        /// The answers after the import (`mergedLog`); `deviceLog` is the phone's log as read now.
        public func log(device deviceLog: [ReviewLogEntry], deviceProgress: [Int: WordProgress]) -> [ReviewLogEntry] {
            return DataImport.mergedLog(
                device: deviceLog,
                incoming: incomingLog,
                deviceProgress: deviceProgress,
                incomingProgress: incomingProgress
            )
        }
    }

    /// Works out the import of `reading` into the phone's `progress` and own words.
    public static func plan(
        _ reading: DataArchive.Reading,
        progress device: [Int: WordProgress],
        customWords deviceWords: CustomWordList,
        now: Date
    ) -> Plan {
        let archive = reading.archive
        var summary = Summary()
        summary.exportedAt = archive.exportedAt
        summary.skipped = reading.unreadableRecords

        // Own words (rule 4): first the checks, then same English word, then numbers.
        var fileWords: [CustomWord] = []
        var seenIDs = Set<Int>()
        var seenLemmas = Set<String>()
        for raw in archive.customWords {
            guard let word = checkedCustomWord(raw, now: now),
                  seenIDs.insert(word.id).inserted,
                  seenLemmas.insert(CustomWordText.duplicateKey(word.lemma)).inserted else {
                summary.skipped += 1
                continue
            }
            fileWords.append(word)
        }
        summary.customWordsInFile = fileWords.count

        let deviceByLemma = Dictionary(
            deviceWords.words.map { (CustomWordText.duplicateKey($0.lemma), $0.id) },
            uniquingKeysWith: { first, _ in first }
        )
        // Numbers the phone gave out (ids below `nextID`) or holds progress for are taken.
        let floor = max(deviceWords.nextID, (device.keys.filter(CustomWordID.contains).max() ?? 0) + 1)
        var idMap: [Int: Int] = [:]
        var renumber: [CustomWord] = []
        var added: [CustomWord] = []
        for word in fileWords.sorted(by: { $0.id < $1.id }) {
            if let twin = deviceByLemma[CustomWordText.duplicateKey(word.lemma)] {
                idMap[word.id] = twin
                summary.customWordsMatched += 1
            } else if word.id >= floor {
                idMap[word.id] = word.id
                added.append(word)
            } else {
                renumber.append(word)
            }
        }
        var nextFree = max(floor, (added.map { $0.id }.max() ?? 0) + 1)
        for word in renumber {
            idMap[word.id] = nextFree
            added.append(CustomWord(
                id: nextFree,
                lemma: word.lemma,
                meaningTR: word.meaningTR,
                exampleEN: word.exampleEN,
                note: word.note,
                createdAt: word.createdAt,
                updatedAt: word.updatedAt
            ))
            nextFree += 1
        }
        summary.customWordsAdded = added.count
        let customWords = CustomWordList(
            words: deviceWords.words + added,
            nextID: max(deviceWords.nextID, nextFree)
        )

        /// The phone's id for a file id; nil for an own word the file does not have.
        func phoneID(_ id: Int) -> Int? {
            return CustomWordID.contains(id) ? idMap[id] : id
        }

        // Progress (rules 1–3).
        var incoming: [Int: WordProgress] = [:]
        for word in archive.progress {
            let record = word.progress
            guard isValid(record, now: now) else {
                summary.skipped += 1
                continue
            }
            guard let id = phoneID(record.wordID) else {
                continue
            }
            guard incoming[id] == nil else {
                summary.skipped += 1
                continue
            }
            incoming[id] = renumbered(record, to: id)
        }
        summary.wordsInFile = incoming.count
        summary.knownInFile = incoming.values.filter { $0.state == .known }.count
        for (id, record) in incoming {
            if let current = device[id] {
                if prefersIncoming(record, over: current) {
                    summary.wordsReplaced += 1
                } else {
                    summary.wordsKept += 1
                }
            } else {
                summary.wordsAdded += 1
            }
        }

        // Answers (rule 5): only of words whose record the file brings.
        var log: [Int: [ReviewLogEntry]] = [:]
        for entry in archive.reviewLog {
            guard isValid(entry, now: now) else {
                summary.skipped += 1
                continue
            }
            guard let id = phoneID(entry.wordID), incoming[id] != nil else {
                continue
            }
            log[id, default: []].append(renumbered(entry, to: id))
        }

        return Plan(
            customWords: customWords,
            incomingProgress: incoming,
            incomingLog: log,
            progress: mergedProgress(device: device, incoming: incoming),
            summary: summary
        )
    }

    /// `record` under another word id, every other field as it was (a later field included:
    /// the copy goes through the record's own coding).
    static func renumbered(_ record: WordProgress, to id: Int) -> WordProgress {
        if record.wordID == id {
            return record
        }
        return recoded(record, replacingWordIDWith: id) ?? {
            var copy = WordProgress(wordID: id)
            copy.state = record.state
            copy.box = record.box
            copy.dueAt = record.dueAt
            copy.exposures = record.exposures
            copy.lastSeenAt = record.lastSeenAt
            copy.reviews = record.reviews
            copy.lapses = record.lapses
            copy.knownOverride = record.knownOverride
            copy.saved = record.saved
            copy.lastReviewedAt = record.lastReviewedAt
            copy.lastGrade = record.lastGrade
            copy.firstReviewedAt = record.firstReviewedAt
            copy.refresherStep = record.refresherStep
            copy.fsrs = record.fsrs
            return copy
        }()
    }

    static func renumbered(_ entry: ReviewLogEntry, to id: Int) -> ReviewLogEntry {
        if entry.wordID == id {
            return entry
        }
        return recoded(entry, replacingWordIDWith: id) ?? ReviewLogEntry(
            wordID: id,
            at: entry.at,
            grade: entry.grade,
            source: entry.source,
            reviews: entry.reviews,
            knownCheck: entry.knownCheck,
            seed: entry.seed
        )
    }

    /// Encodes `value`, sets its top-level "word_id" and decodes it again.
    private static func recoded<T: Codable>(_ value: T, replacingWordIDWith id: Int) -> T? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard let data = try? encoder.encode(value),
              var object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            return nil
        }
        object["word_id"] = id
        guard let changed = try? JSONSerialization.data(withJSONObject: object) else {
            return nil
        }
        return try? decoder.decode(T.self, from: changed)
    }
}

extension ReviewLog {
    /// Writes `entries` as the whole log, in one atomic write (an import: `DataImport.Plan.log`).
    /// A failure leaves the old log as it was.
    public func replaceAll(with entries: [ReviewLogEntry]) throws {
        var data = Data()
        for entry in entries {
            data.append(try ReviewLog.line(entry))
            data.append(0x0A)
        }
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL, options: [.atomic])
    }
}
