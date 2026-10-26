import Foundation
import CoreModels

// Siri, Kestirmeler (the Shortcuts app) and Spotlight (ios/App/Intents): where they send the app,
// what Siri says and which words Spotlight may show. Pure, so the Linux check tests it; the App
// Intents and CoreSpotlight code stays in the app.

/// Where a shortcut or a tapped Spotlight result takes the app. RootView does it once the words
/// have loaded and nothing covers the screen (`shortcutRoutes`, ios/App/Intents/ShortcutRouter.swift).
public enum ShortcutRoute: Equatable, Sendable {
    /// The word's whole card, in a sheet.
    case word(id: Int)
    /// The "Tekrar" tab.
    case review
    /// The "Kendi kelimeni ekle" form; `lemma` fills the word field (empty: nothing typed yet).
    case addWord(lemma: String)
    /// "Metinden kelime bul" with `text` in its field (empty: nothing sent). Made by
    /// `findingWords(in:)`, which cuts the text to what the screen reads.
    case findWords(text: String)
}

extension ShortcutRoute {
    /// "Metinden kelime bul" for a text from Kestirmeler (an earlier action or the Share sheet):
    /// the ends trimmed, and at most `TextHarvest.inputLimit` characters, so a whole web page
    /// does not fill the field with text the screen would not read anyway.
    public static func findingWords(in text: String) -> ShortcutRoute {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return .findWords(text: String(trimmed.prefix(TextHarvest.inputLimit)))
    }
}

// MARK: - Today's word

/// "Lockglow'da bugünün kelimesi ne?": the word the widget shows now, said and shown by Siri.
/// Nothing is recorded: hearing a word is not a review (ogrenme_ilkeleri 2.1).
public enum TodayWord {
    /// Said when there is no word to tell (no plan and no seed words).
    public static let noWord = "Şu an gösterecek kelime yok. Lockglow'u bir kez açınca gelir."

    /// The widget's word, never a personal-topic card: the widget queue has none
    /// (`QueueComposer`), and Siri says the word aloud, so it is checked again here.
    public static func pick(_ onWidget: WidgetWord?) -> WidgetWord? {
        guard let word = onWidget, !word.isSensitive, !trimmed(word.lemma).isEmpty else {
            return nil
        }
        return word
    }

    /// The Turkish meaning Siri says, or nil when the word has none.
    public static func meaning(of word: WidgetWord) -> String? {
        guard let gloss = word.glossTR.map(trimmed), !gloss.isEmpty else {
            return nil
        }
        return gloss
    }

    /// What Siri says: "Bugünün kelimesi: apple. Türkçesi: elma." The word and the meaning stand
    /// after a colon, never with a suffix (docs/tasarim/terimler.md §1).
    public static func dialog(for word: WidgetWord?) -> String {
        guard let word = word else {
            return noWord
        }
        var text = "Bugünün kelimesi: " + sentence(trimmed(word.lemma))
        if let meaning = meaning(of: word) {
            text += " Türkçesi: " + sentence(meaning)
        }
        return text
    }

    /// `text` with a full stop, unless it already ends a sentence ("How are you?").
    static func sentence(_ text: String) -> String {
        guard let last = text.last else {
            return text
        }
        return ".?!…".contains(last) ? text : text + "."
    }

    private static func trimmed(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Spotlight

/// The words Spotlight finds ("breakfast", "kahvaltı" or "kahvalti" → the card). The app puts
/// them into the index (ios/App/Intents/SpotlightIndex.swift); a tapped result opens the card.
public enum SpotlightCatalog {
    /// Every item of the app's index is in this domain; indexing again deletes it first.
    public static let domain = "lockglow.words"
    /// Indexed again after this long even without a change: the system may drop items (for
    /// example after a restore), and the app has no index extension the system could ask.
    public static let refreshInterval: TimeInterval = 7 * 86_400
    /// Part of the signature: a change in what an entry holds indexes every phone once again.
    static let format = 1
    private static let identifierPrefix = "word."

    public struct Entry: Equatable, Sendable {
        public let wordID: Int
        /// The item's unique identifier, `identifier(forWordID:)`.
        public let identifier: String
        /// The English word: the result's title.
        public let title: String
        /// The Turkish meaning under the title (the English definition when there is none).
        public let summary: String
        /// What else finds it: the meaning's parts, also without Turkish letters ("kahvalti").
        public let keywords: [String]
    }

    public static func identifier(forWordID id: Int) -> String {
        return identifierPrefix + String(id)
    }

    /// The word id of a tapped result; nil for anything this catalog did not index.
    public static func wordID(fromIdentifier identifier: String) -> Int? {
        guard identifier.hasPrefix(identifierPrefix) else {
            return nil
        }
        let digits = identifier.dropFirst(identifierPrefix.count)
        guard !digits.isEmpty, digits.allSatisfy({ ("0"..."9").contains($0) }), let id = Int(digits), id > 0 else {
            return nil
        }
        return id
    }

    /// The cards Spotlight may show, in the given order. Never a personal-topic card
    /// (`isSensitive`): Spotlight shows its results to whoever holds the phone. Never the user's
    /// own words either: they are private notes and change often. `fold` is `TextFold.fold`.
    public static func entries(from words: [WidgetWord], fold: (String) -> String) -> [Entry] {
        var seen = Set<Int>()
        var result: [Entry] = []
        for word in words where !word.isSensitive && !word.isUserAdded {
            let title = word.lemma.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty, seen.insert(word.id).inserted else {
                continue
            }
            let meaning = TodayWord.meaning(of: word)
            let summary = meaning ?? word.defShort.trimmingCharacters(in: .whitespacesAndNewlines)
            result.append(Entry(
                wordID: word.id,
                identifier: identifier(forWordID: word.id),
                title: title,
                summary: summary,
                keywords: keywords(meaning: meaning, short: word.glossShortTR, fold: fold)
            ))
        }
        return result
    }

    /// The meaning's parts and the short meaning, each also folded when that differs; no repeats.
    static func keywords(meaning: String?, short: String?, fold: (String) -> String) -> [String] {
        let parts = [meaning, short].compactMap { $0 }.flatMap(meaningParts)
        var seen = Set<String>()
        var result: [String] = []
        for part in parts {
            for keyword in [part, fold(part)] where !keyword.isEmpty && seen.insert(keyword).inserted {
                result.append(keyword)
            }
        }
        return result
    }

    /// A fingerprint of `entries` that stays the same across launches (unlike `hashValue`):
    /// 64-bit FNV-1a over every field, with the format and the count in front.
    public static func signature(of entries: [Entry]) -> String {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        func add(_ text: String) {
            for byte in text.utf8 {
                hash ^= UInt64(byte)
                hash = hash &* 0x0000_0100_0000_01b3
            }
            // A separator byte UTF-8 never contains: "ab"+"c" and "a"+"bc" differ.
            hash ^= 0xff
            hash = hash &* 0x0000_0100_0000_01b3
        }
        for entry in entries {
            add(entry.identifier)
            add(entry.title)
            add(entry.summary)
            add(entry.keywords.joined(separator: "\u{1f}"))
        }
        return "\(format)-\(entries.count)-" + String(hash, radix: 16)
    }

    /// Whether to index again: never indexed, the entries changed, `refreshInterval` has passed,
    /// or the clock went back past the last indexing.
    public static func needsIndexing(signature: String, indexedSignature: String?, indexedAt: Date?, now: Date) -> Bool {
        guard let indexedSignature = indexedSignature, let indexedAt = indexedAt, indexedSignature == signature else {
            return true
        }
        let age = now.timeIntervalSince(indexedAt)
        return age < 0 || age >= refreshInterval
    }
}

// MARK: - Word search for Siri

/// Siri's "Hangi kelimeyi arayalım?" and the word picker of Kestirmeler (`WordEntity`).
public enum ShortcutWordSearch {
    /// Siri reads a short list; more would not help a spoken choice.
    public static let limit = 10
    /// The picker's list before anything is typed.
    public static let suggestionLimit = 20
    private static let wordSeparators = CharacterSet(charactersIn: " ,;/()-'")

    /// Words for what was said or typed, best first: the English word itself, one of its Turkish
    /// meanings itself, an English word starting with it, then any word of the English word or
    /// the meaning starting with it. Within a group the given order stays (the user's own words
    /// first, then the cards, easiest first). `fold` is `TextFold.fold` (case, accents, Turkish
    /// letters); spaces and the punctuation Siri adds around a word ("Kahvaltı.") are ignored.
    /// A personal-topic card comes only when the user named it (the first two groups): Siri may
    /// read the list aloud, and "b" or "boş" must not bring such cards up.
    public static func matches(_ query: String, in words: [WidgetWord], fold: (String) -> String, limit: Int = ShortcutWordSearch.limit) -> [WidgetWord] {
        let needle = fold(query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)))
        guard !needle.isEmpty, limit > 0 else {
            return []
        }
        var groups: [[WidgetWord]] = [[], [], [], []]
        var seen = Set<Int>()
        for word in words where !seen.contains(word.id) {
            let lemma = fold(word.lemma)
            let meaning = word.glossTR.map(fold) ?? ""
            let group: Int
            if lemma == needle {
                group = 0
            } else if meaningParts(meaning).contains(needle) {
                group = 1
            } else if lemma.hasPrefix(needle) {
                group = 2
            } else if hasWord(startingWith: needle, in: lemma) || hasWord(startingWith: needle, in: meaning) {
                group = 3
            } else {
                continue
            }
            if group > 1 && word.isSensitive {
                continue
            }
            seen.insert(word.id)
            groups[group].append(word)
        }
        return Array(groups.joined().prefix(limit))
    }

    /// The picker's list before anything is typed: the given words in order (the user's own words
    /// first), never a personal-topic card.
    public static func suggestions(from words: [WidgetWord], limit: Int = ShortcutWordSearch.suggestionLimit) -> [WidgetWord] {
        var seen = Set<Int>()
        return Array(words.filter { !$0.isSensitive && seen.insert($0.id).inserted }.prefix(max(0, limit)))
    }

    /// The words with these ids, in the order asked; unknown ids are left out.
    public static func words(withIDs ids: [Int], in words: [WidgetWord]) -> [WidgetWord] {
        var byID: [Int: WidgetWord] = [:]
        for word in words where byID[word.id] == nil {
            byID[word.id] = word
        }
        return ids.compactMap { byID[$0] }
    }

    /// Whether the folded `text` has a word where `needle` starts ("up" and "look u" in "look up").
    private static func hasWord(startingWith needle: String, in text: String) -> Bool {
        var atWordStart = true
        var index = text.startIndex
        while index < text.endIndex {
            let isSeparator = text[index].unicodeScalars.allSatisfy { wordSeparators.contains($0) }
            if atWordStart && !isSeparator && text[index...].hasPrefix(needle) {
                return true
            }
            atWordStart = isSeparator
            index = text.index(after: index)
        }
        return false
    }
}

// MARK: - The user's words for Siri

extension CustomWordStore {
    /// The saved words as they are on disk, for a reader outside the app's own library (Siri may
    /// run before the app has a screen). Unlike `load` it never moves, restores or writes
    /// anything: a damaged file is left for the app, whose own `load` then tells the user. Nil
    /// when the file is missing, unreadable now (a locked phone) or in a format this build does
    /// not read. Same file format as `save` (the tests read a saved file back).
    public func peek() -> CustomWordList? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard let body = try? decoder.decode(PeekedFile.self, from: data),
              (1...CustomWordStore.format).contains(body.format)
        else {
            return nil
        }
        return CustomWordList(words: body.words, nextID: body.nextID)
    }
}

/// What `peek` reads of custom_words.json: `CustomWordStore`'s file body.
private struct PeekedFile: Decodable {
    let format: Int
    let nextID: Int
    let words: [CustomWord]

    enum CodingKeys: String, CodingKey {
        case format
        case nextID = "next_id"
        case words
    }
}

/// The parts of a Turkish meaning ("ödünç almak, borç almak"), trimmed, empty ones left out.
private func meaningParts(_ meaning: String) -> [String] {
    return meaning.components(separatedBy: CharacterSet(charactersIn: ",;/()"))
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}
