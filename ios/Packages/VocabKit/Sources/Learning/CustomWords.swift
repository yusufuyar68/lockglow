import Foundation
import CoreModels

// "Kendi kelimeni ekle": a word the user heard during the day, typed in with its Turkish meaning.
// It rotates on the widget and comes up in "Tekrar" like a card (`CustomWord.widgetWord`), and its
// progress lives in progress.json under its id like any card's. Wiring into the app:
// docs/ozellik_planlari/kendi_kelime.md.

// MARK: - Word

/// One word the user added. Ids come from `CustomWordList` (from `CustomWordID.first` up) and are
/// never reused. App-private: stored by `CustomWordStore`; the widget only sees `widgetWord`
/// through the widget plan.
public struct CustomWord: Codable, Equatable, Identifiable, Sendable {
    public let id: Int
    /// The English word or phrase, normalized and checked by `CustomWordDraft` (speakable, so
    /// "Söyle" and the speaker can read it).
    public var lemma: String
    public var meaningTR: String
    /// An English sentence with the word; nil when the user gave none.
    public var exampleEN: String?
    /// The user's own note (where they heard it, a hint); nil when none.
    public var note: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: Int,
        lemma: String,
        meaningTR: String,
        exampleEN: String? = nil,
        note: String? = nil,
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.lemma = lemma
        self.meaningTR = meaningTR
        self.exampleEN = exampleEN
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case lemma
        case meaningTR = "meaning_tr"
        case exampleEN = "example_en"
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension CustomWord {
    /// What the widget, "Akış" and "Tekrar" show. A card's fields this word does not have stay
    /// empty: `pos`, `level`, `defMicro`, `defShort`, and `exampleEN` when there is no example
    /// (`WidgetWord.isUserAdded` tells screens to leave them out).
    public var widgetWord: WidgetWord {
        return WidgetWord(
            id: id,
            lemma: lemma,
            pos: "",
            level: "",
            ipaUS: nil,
            defMicro: "",
            defShort: "",
            exampleEN: exampleEN ?? "",
            glossTR: meaningTR
        )
    }

    /// The word's "card detail" for the screens that show one (`AppModel.detail(for:)`): the
    /// example without a translation and the note as the Turkish note. No quiz, so "Tekrar"
    /// always asks it as a flashcard.
    public var cardDetail: CardDetail {
        return CardDetail(
            examples: exampleEN.map { [CardDetail.Example(en: $0)] } ?? [],
            noteTR: note
        )
    }
}

// MARK: - Text rules

/// How the form's text is cleaned before it is checked and saved.
public enum CustomWordText {
    /// The lemma as saved: apostrophe look-alikes (’ ‘ ʼ ´ `, typed by smart punctuation) become
    /// ', dash look-alikes (‐ ‑ ‒ – —; "--" turns into — on the keyboard) become -, every run of
    /// spaces becomes one space, and the ends are trimmed. Letters and case stay as typed.
    public static func lemma(_ text: String) -> String {
        var replaced = ""
        for character in text {
            switch character {
            case "\u{2019}", "\u{2018}", "\u{02BC}", "\u{00B4}", "`":
                replaced.append("'")
            case "\u{2010}", "\u{2011}", "\u{2012}", "\u{2013}", "\u{2014}":
                replaced.append("-")
            default:
                replaced.append(character)
            }
        }
        return singleLine(replaced)
    }

    /// Every run of whitespace (line breaks too) as one space, both ends trimmed.
    public static func singleLine(_ text: String) -> String {
        var result = ""
        var pendingSpace = false
        for character in text {
            if character.isWhitespace {
                pendingSpace = !result.isEmpty
                continue
            }
            if pendingSpace {
                result.append(" ")
                pendingSpace = false
            }
            result.append(character)
        }
        return result
    }

    /// The pipeline's `SPEAKABLE_LEMMA` (content-pipeline/vocabpipe/validate.py):
    /// `[A-Za-z]+(?:[ '\-][A-Za-z]+)*`. Letters a–z and A–Z only, with one space, ' or - between
    /// them, never at an end: the speech recognizer of "Söyle" is compared with it.
    public static func isSpeakable(_ lemma: String) -> Bool {
        var afterLetter = false
        for scalar in lemma.unicodeScalars {
            if scalar.isASCII && scalar.properties.isAlphabetic {
                afterLetter = true
            } else if scalar == " " || scalar == "'" || scalar == "-" {
                guard afterLetter else {
                    return false
                }
                afterLetter = false
            } else {
                return false
            }
        }
        return afterLetter
    }

    /// The first Turkish letter English does not have (ç ğ ı İ ö ş ü), for a clearer message.
    public static func firstTurkishLetter(in text: String) -> Character? {
        return text.first { "çğıöşüÇĞİÖŞÜ".contains($0) }
    }

    /// Two lemmas are the same word when they differ only in case.
    static func duplicateKey(_ lemma: String) -> String {
        return lemma.lowercased()
    }

    static func nonEmpty(_ text: String) -> String? {
        return text.isEmpty ? nil : text
    }
}

// MARK: - Form

/// Which form field a problem belongs to.
public enum CustomWordField: Sendable {
    case lemma
    case meaning
    case example
    case note
}

/// Why a draft cannot be saved yet. `message` is the plain Turkish sentence the form shows under
/// the field.
public enum CustomWordProblem: Equatable, Sendable {
    case lemmaMissing
    case lemmaTooLong
    case lemmaHasTurkishLetter(Character)
    case lemmaNotSpeakable
    /// The user already added this word (case is ignored); `id` is that word.
    case lemmaAlreadyAdded(id: Int)
    case meaningMissing
    case meaningTooLong
    case exampleTooLong
    case noteTooLong

    public var field: CustomWordField {
        switch self {
        case .lemmaMissing, .lemmaTooLong, .lemmaHasTurkishLetter, .lemmaNotSpeakable, .lemmaAlreadyAdded:
            return .lemma
        case .meaningMissing, .meaningTooLong:
            return .meaning
        case .exampleTooLong:
            return .example
        case .noteTooLong:
            return .note
        }
    }

    /// A required field is still empty. The form shows these only after "Kaydet", not while
    /// the user is still typing.
    public var isMissingField: Bool {
        return self == .lemmaMissing || self == .meaningMissing
    }

    public var message: String {
        switch self {
        case .lemmaMissing:
            return "İngilizce kelimeyi yaz."
        case .lemmaTooLong:
            return "Çok uzun. Widget'a sığması için en çok \(CustomWordDraft.lemmaLimit) harf olabilir (boşluklar da sayılır)."
        case let .lemmaHasTurkishLetter(letter):
            return "Türkçe harf var: \(letter). Kelimeyi İngilizce harflerle (a–z) yaz."
        case .lemmaNotSpeakable:
            return "Yalnızca harf (a–z), boşluk, tire (-) ve kesme (') kullan. Rakam ya da başka işaret olmasın."
        case .lemmaAlreadyAdded:
            return "Bu kelimeyi zaten ekledin."
        case .meaningMissing:
            return "Türkçe anlamını yaz."
        case .meaningTooLong:
            return "Çok uzun. Widget'a sığması için en çok \(CustomWordDraft.meaningLimit) harf olabilir (boşluklar da sayılır)."
        case .exampleTooLong:
            return "Cümle çok uzun. En çok \(CustomWordDraft.exampleLimit) harf olabilir."
        case .noteTooLong:
            return "Not çok uzun. En çok \(CustomWordDraft.noteLimit) harf olabilir."
        }
    }
}

/// What the add and edit form holds, as typed. `problems` checks it; `CustomWordList.add` and
/// `update` save its normalized fields.
public struct CustomWordDraft: Equatable, Sendable {
    // Grapheme limits of the content (validate.py `LIMITS`); the widget layouts are built for them.
    /// "lemma".
    public static let lemmaLimit = 28
    /// "tr.gloss".
    public static let meaningLimit = 28
    /// "example.en".
    public static let exampleLimit = 110
    /// "tr.note".
    public static let noteLimit = 220

    public var lemma: String
    public var meaningTR: String
    public var exampleEN: String
    public var note: String

    public init(lemma: String = "", meaningTR: String = "", exampleEN: String = "", note: String = "") {
        self.lemma = lemma
        self.meaningTR = meaningTR
        self.exampleEN = exampleEN
        self.note = note
    }

    /// The saved word's fields, for editing it.
    public init(_ word: CustomWord) {
        self.init(lemma: word.lemma, meaningTR: word.meaningTR, exampleEN: word.exampleEN ?? "", note: word.note ?? "")
    }

    public var normalizedLemma: String {
        return CustomWordText.lemma(lemma)
    }

    public var normalizedMeaning: String {
        return CustomWordText.singleLine(meaningTR)
    }

    /// Nil when empty.
    public var normalizedExample: String? {
        return CustomWordText.nonEmpty(CustomWordText.singleLine(exampleEN))
    }

    /// Nil when empty. Line breaks inside the note stay.
    public var normalizedNote: String? {
        return CustomWordText.nonEmpty(note.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    /// Every problem in form order (word, meaning, example, note); at most one per field. Lengths
    /// count graphemes of the normalized text, as the pipeline does. `existing` are the user's
    /// words; `editing` is the one being edited, whose own lemma is not a duplicate.
    public func problems(existing: [CustomWord] = [], editing editedID: Int? = nil) -> [CustomWordProblem] {
        var found: [CustomWordProblem] = []

        let lemma = normalizedLemma
        if lemma.isEmpty {
            found.append(.lemmaMissing)
        } else if let letter = CustomWordText.firstTurkishLetter(in: lemma) {
            found.append(.lemmaHasTurkishLetter(letter))
        } else if !CustomWordText.isSpeakable(lemma) {
            found.append(.lemmaNotSpeakable)
        } else if lemma.count > CustomWordDraft.lemmaLimit {
            found.append(.lemmaTooLong)
        } else {
            let key = CustomWordText.duplicateKey(lemma)
            if let twin = existing.first(where: { $0.id != editedID && CustomWordText.duplicateKey($0.lemma) == key }) {
                found.append(.lemmaAlreadyAdded(id: twin.id))
            }
        }

        let meaning = normalizedMeaning
        if meaning.isEmpty {
            found.append(.meaningMissing)
        } else if meaning.count > CustomWordDraft.meaningLimit {
            found.append(.meaningTooLong)
        }

        if let example = normalizedExample, example.count > CustomWordDraft.exampleLimit {
            found.append(.exampleTooLong)
        }
        if let note = normalizedNote, note.count > CustomWordDraft.noteLimit {
            found.append(.noteTooLong)
        }
        return found
    }
}

// MARK: - List

/// The user's words and the next id to give. Pure value; `CustomWordStore` saves it.
///
/// Ids are never reused: progress, the widget plan and widget events refer to a word by id, so
/// what is left of a deleted word must never attach to a new one. A deleted word can come back
/// with its id (`restore`, the "Vazgeç" after deleting) and finds its progress again.
public struct CustomWordList: Equatable, Sendable {
    public enum ChangeError: Error, Equatable {
        /// The draft has problems; nothing changed.
        case invalid([CustomWordProblem])
        case notFound(id: Int)
        /// `restore` of a word whose id is in use or was never given out.
        case idUnavailable(id: Int)
    }

    /// Oldest first: the order they were added (ids grow with every add).
    public private(set) var words: [CustomWord]
    /// The id the next added word gets. Only grows.
    public private(set) var nextID: Int

    /// Words outside the id range and repeated ids are dropped (first one wins); `nextID` is
    /// raised above every id.
    public init(words: [CustomWord] = [], nextID: Int = CustomWordID.first) {
        var seen = Set<Int>()
        let kept = words.filter { CustomWordID.contains($0.id) && seen.insert($0.id).inserted }
        self.words = kept.sorted { $0.id < $1.id }
        self.nextID = max(nextID, CustomWordID.first, (kept.map { $0.id }.max() ?? 0) + 1)
    }

    public var isEmpty: Bool {
        return words.isEmpty
    }

    /// Every word as the widget, "Akış" and "Tekrar" show it, oldest first.
    public var widgetWords: [WidgetWord] {
        return words.map { $0.widgetWord }
    }

    public func word(id: Int) -> CustomWord? {
        return words.first { $0.id == id }
    }

    public func problems(for draft: CustomWordDraft, editing id: Int? = nil) -> [CustomWordProblem] {
        return draft.problems(existing: words, editing: id)
    }

    /// Adds the draft's normalized fields under a new id.
    @discardableResult
    public mutating func add(_ draft: CustomWordDraft, now: Date = Date()) throws -> CustomWord {
        let found = problems(for: draft)
        guard found.isEmpty else {
            throw ChangeError.invalid(found)
        }
        let word = CustomWord(
            id: nextID,
            lemma: draft.normalizedLemma,
            meaningTR: draft.normalizedMeaning,
            exampleEN: draft.normalizedExample,
            note: draft.normalizedNote,
            createdAt: now
        )
        words.append(word)
        nextID += 1
        return word
    }

    /// Replaces the word's fields; its id (and with it its progress) stays.
    @discardableResult
    public mutating func update(id: Int, with draft: CustomWordDraft, now: Date = Date()) throws -> CustomWord {
        guard let index = words.firstIndex(where: { $0.id == id }) else {
            throw ChangeError.notFound(id: id)
        }
        let found = problems(for: draft, editing: id)
        guard found.isEmpty else {
            throw ChangeError.invalid(found)
        }
        var word = words[index]
        word.lemma = draft.normalizedLemma
        word.meaningTR = draft.normalizedMeaning
        word.exampleEN = draft.normalizedExample
        word.note = draft.normalizedNote
        word.updatedAt = now
        words[index] = word
        return word
    }

    /// The removed word, or nil when there was none with that id.
    @discardableResult
    public mutating func remove(id: Int) -> CustomWord? {
        guard let index = words.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return words.remove(at: index)
    }

    /// Puts a removed word back with its id and fields, in its old place. Fails when the id is
    /// in use or was never given out, or when the user has added the same lemma since.
    public mutating func restore(_ word: CustomWord) throws {
        guard CustomWordID.contains(word.id), word.id < nextID, self.word(id: word.id) == nil else {
            throw ChangeError.idUnavailable(id: word.id)
        }
        let found = problems(for: CustomWordDraft(word))
        guard found.isEmpty else {
            throw ChangeError.invalid(found)
        }
        let index = words.firstIndex { $0.id > word.id } ?? words.count
        words.insert(word, at: index)
    }

    /// Keeps `nextID` above every user-word id in `ids` (for example the ids in progress.json).
    /// After a damaged file was replaced by an older backup, words added since that backup are
    /// gone but their progress is not; their ids must not be given to new words.
    public mutating func reserveIDs<S: Sequence>(_ ids: S) where S.Element == Int {
        for id in ids where CustomWordID.contains(id) && id >= nextID {
            nextID = id + 1
        }
    }
}

// MARK: - Deck

extension DeckFilter {
    /// The user's words (`CustomWordList.widgetWords`) before `feed`, each id once. They belong
    /// to every deck whatever the topics and levels, and come first, so a word added today is
    /// among the next new words of "Tekrar" and of the widget queue.
    public static func prepending(_ custom: [WidgetWord], to feed: [WidgetWord]) -> [WidgetWord] {
        if custom.isEmpty {
            return feed
        }
        var seen = Set<Int>()
        let mine = custom.filter { seen.insert($0.id).inserted }
        return mine + feed.filter { !seen.contains($0.id) }
    }
}

// MARK: - File

/// App-private file of the user's words: Application Support/custom_words.json, a JSON object
/// `{"format": 1, "next_id": …, "words": [...]}`. Single writer: the app. Same safety rules as
/// `ProgressStore`, because these are words the user typed and cannot get back from the content:
/// - a file that exists but cannot be read (for example while the device is locked) is left
///   alone and `load` throws, so the caller does not save over it;
/// - a file that cannot be decoded (damaged, or a newer `format`) is moved aside under a new
///   name, never overwritten, and the daily backup is used instead;
/// - `save` copies the file to the backup once per day before overwriting it.
public struct CustomWordStore: Sendable {
    /// The `format` this build writes and reads.
    public static let format = 1

    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Default location: Application Support/custom_words.json (created on first save).
    public static func defaultURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appendingPathComponent("custom_words.json")
    }

    /// The file as it was at the first save of the current day (custom_words.backup.json).
    public var backupURL: URL {
        return fileURL.deletingPathExtension().appendingPathExtension("backup.json")
    }

    public enum LoadOutcome: Equatable, Sendable {
        /// No file yet: the user has not added a word.
        case fresh
        case loaded
        /// The file could not be decoded (it was moved to `setAside`; nil when it was missing) and
        /// the backup taken on `backupDate` was used: changes made after that are lost.
        case restoredFromBackup(setAside: URL?, backupDate: Date?)
        /// The file could not be decoded and there is no usable backup: the list starts empty.
        /// The file was moved to `setAside`, so a later build can still read it.
        case startedOver(setAside: URL)
    }

    public struct LoadResult: Sendable {
        public let list: CustomWordList
        public let outcome: LoadOutcome
    }

    public enum LoadError: Error, Equatable {
        /// The file exists but could not be read, or a damaged file could not be moved aside.
        /// Nothing was changed: try again later and do not save in the meantime.
        case unreadable(String)
    }

    /// Reads the words, falling back to the backup when the file is damaged (see the type
    /// comment). `now` names the file a damaged one is moved to.
    public func load(now: Date = Date()) throws -> LoadResult {
        let fileManager = FileManager.default
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            if fileManager.fileExists(atPath: fileURL.path) {
                throw LoadError.unreadable(error.localizedDescription)
            }
            // No file: the backup, if there is one, is the newest copy left.
            if let backup = readBackup() {
                return LoadResult(list: backup.list, outcome: .restoredFromBackup(setAside: nil, backupDate: backup.date))
            }
            return LoadResult(list: CustomWordList(), outcome: .fresh)
        }

        if let list = CustomWordStore.decode(data) {
            return LoadResult(list: list, outcome: .loaded)
        }

        let setAside = setAsideURL(now: now)
        do {
            try fileManager.moveItem(at: fileURL, to: setAside)
        } catch {
            throw LoadError.unreadable("damaged custom words file could not be moved aside: \(error.localizedDescription)")
        }
        if let backup = readBackup() {
            return LoadResult(list: backup.list, outcome: .restoredFromBackup(setAside: setAside, backupDate: backup.date))
        }
        return LoadResult(list: CustomWordList(), outcome: .startedOver(setAside: setAside))
    }

    /// Writes the list atomically. If the backup is missing or was taken on an earlier day (by
    /// `calendar`), the file on disk is first copied to it, provided it decodes.
    public func save(_ list: CustomWordList, now: Date = Date(), calendar: Calendar = .current) throws {
        let body = FileBody(format: CustomWordStore.format, nextID: list.nextID, words: list.words)
        let data = try CustomWordStore.makeEncoder().encode(body)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        refreshBackupIfNeeded(now: now, calendar: calendar)
        try data.write(to: fileURL, options: [.atomic])
    }

    private struct FileBody: Codable {
        let format: Int
        let nextID: Int
        let words: [CustomWord]

        enum CodingKeys: String, CodingKey {
            case format
            case nextID = "next_id"
            case words
        }
    }

    /// Best effort: a failed backup never blocks the save itself.
    private func refreshBackupIfNeeded(now: Date, calendar: Calendar) {
        let fileManager = FileManager.default
        if let taken = CustomWordStore.modificationDate(of: backupURL), calendar.isDate(taken, inSameDayAs: now) {
            return
        }
        guard let current = try? Data(contentsOf: fileURL), CustomWordStore.decode(current) != nil else {
            return
        }
        do {
            try current.write(to: backupURL, options: [.atomic])
            // The backup's date is the caller's clock, so "taken today" follows the same clock.
            try fileManager.setAttributes([.modificationDate: now], ofItemAtPath: backupURL.path)
        } catch {
            return
        }
    }

    private func readBackup() -> (list: CustomWordList, date: Date?)? {
        guard let data = try? Data(contentsOf: backupURL), let list = CustomWordStore.decode(data) else {
            return nil
        }
        return (list, CustomWordStore.modificationDate(of: backupURL))
    }

    /// custom_words-unreadable-<seconds since 1970>.json next to the file; a suffix keeps it unique.
    private func setAsideURL(now: Date) -> URL {
        let folder = fileURL.deletingLastPathComponent()
        let base = fileURL.deletingPathExtension().lastPathComponent
        let stamp = Int(now.timeIntervalSince1970)
        var candidate = folder.appendingPathComponent("\(base)-unreadable-\(stamp).json")
        var suffix = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = folder.appendingPathComponent("\(base)-unreadable-\(stamp)-\(suffix).json")
            suffix += 1
        }
        return candidate
    }

    /// Nil for anything this build cannot read whole, including a newer `format`.
    private static func decode(_ data: Data) -> CustomWordList? {
        guard let body = try? makeDecoder().decode(FileBody.self, from: data),
              body.format >= 1, body.format <= CustomWordStore.format else {
            return nil
        }
        return CustomWordList(words: body.words, nextID: body.nextID)
    }

    private static func modificationDate(of url: URL) -> Date? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.modificationDate] as? Date
    }

    // Seconds since 1970 as a Double, as in progress.json (exact round trip).
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
