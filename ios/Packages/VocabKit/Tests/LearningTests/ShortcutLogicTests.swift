import XCTest
import CoreModels
import Learning

final class ShortcutLogicTests: XCTestCase {
    private func word(
        _ id: Int,
        _ lemma: String,
        gloss: String? = nil,
        short: String? = nil,
        defShort: String = "definition",
        sensitivity: Int? = nil
    ) -> WidgetWord {
        return WidgetWord(
            id: id,
            lemma: lemma,
            pos: "n",
            level: "A1",
            defMicro: "m",
            defShort: defShort,
            exampleEN: "e",
            glossTR: gloss,
            glossShortTR: short,
            sensitivity: sensitivity
        )
    }

    /// A user's own word (`CustomWordID`): no level, no definition.
    private func userWord(_ offset: Int, _ lemma: String, meaning: String) -> WidgetWord {
        return WidgetWord(id: CustomWordID.first + offset, lemma: lemma, pos: "", level: "", defMicro: "", defShort: "", exampleEN: "", glossTR: meaning)
    }

    /// TextFold's rules that matter here (the package's LearningTests cannot import TextFold):
    /// Turkish letters to ASCII, lowercase, whitespace runs to one space, trimmed.
    private func fold(_ text: String) -> String {
        let map: [Character: Character] = ["ı": "i", "İ": "i", "I": "i", "ç": "c", "Ç": "c", "ğ": "g", "Ğ": "g", "ö": "o", "Ö": "o", "ş": "s", "Ş": "s", "ü": "u", "Ü": "u"]
        let mapped = String(text.map { map[$0] ?? $0 }).lowercased()
        return mapped.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    private func ids(_ words: [WidgetWord]) -> [Int] {
        return words.map { $0.id }
    }

    // MARK: Today's word

    func testTodayWordIsTheWidgetWordButNeverAPersonalTopicCard() {
        let apple = word(1, "apple", gloss: "elma")
        XCTAssertEqual(TodayWord.pick(apple), apple)
        XCTAssertNil(TodayWord.pick(nil))
        XCTAssertNil(TodayWord.pick(word(2, "divorce", gloss: "boşanmak", sensitivity: 1)))
        XCTAssertEqual(TodayWord.pick(word(3, "lunch", sensitivity: 0))?.id, 3, "sensitivity 0 is an everyday card")
        XCTAssertNil(TodayWord.pick(word(4, "  ")), "no word to say")
        let mine = userWord(1, "awkward", meaning: "garip")
        XCTAssertEqual(TodayWord.pick(mine), mine, "the user's own word on the widget is told too")
    }

    func testTodayWordDialogPutsTheWordAndMeaningAfterAColon() {
        XCTAssertEqual(TodayWord.dialog(for: word(1, "apple", gloss: "elma")), "Bugünün kelimesi: apple. Türkçesi: elma.")
        XCTAssertEqual(TodayWord.dialog(for: word(1, " apple ", gloss: " elma ")), "Bugünün kelimesi: apple. Türkçesi: elma.")
        XCTAssertEqual(TodayWord.dialog(for: word(1, "apple")), "Bugünün kelimesi: apple.", "no meaning, no Türkçesi")
        XCTAssertEqual(TodayWord.dialog(for: word(1, "apple", gloss: "  ")), "Bugünün kelimesi: apple.")
        XCTAssertEqual(
            TodayWord.dialog(for: word(1, "How are you?", gloss: "Nasılsın?")),
            "Bugünün kelimesi: How are you? Türkçesi: Nasılsın?",
            "no full stop after a question mark"
        )
        XCTAssertEqual(TodayWord.dialog(for: word(1, "Bless you", gloss: "Çok yaşa.")), "Bugünün kelimesi: Bless you. Türkçesi: Çok yaşa.")
        XCTAssertEqual(TodayWord.dialog(for: nil), TodayWord.noWord)
    }

    func testMeaningIsTheTrimmedTurkishGloss() {
        XCTAssertEqual(TodayWord.meaning(of: word(1, "borrow", gloss: " ödünç almak ")), "ödünç almak")
        XCTAssertNil(TodayWord.meaning(of: word(1, "borrow")))
        XCTAssertNil(TodayWord.meaning(of: word(1, "borrow", gloss: "")))
    }

    // MARK: Spotlight identifiers

    func testSpotlightIdentifierRoundTrips() {
        XCTAssertEqual(SpotlightCatalog.identifier(forWordID: 42), "word.42")
        XCTAssertEqual(SpotlightCatalog.wordID(fromIdentifier: "word.42"), 42)
        XCTAssertEqual(SpotlightCatalog.wordID(fromIdentifier: SpotlightCatalog.identifier(forWordID: 1_000_123)), 1_000_123)
    }

    func testSpotlightIdentifierRejectsAnythingElse() {
        for identifier in ["", "word.", "word.0", "word.-1", "word.+5", "word. 5", "word.4a", "word.٣", "other.42", "42", "Word.42", "word.99999999999999999999"] {
            XCTAssertNil(SpotlightCatalog.wordID(fromIdentifier: identifier), identifier)
        }
    }

    // MARK: Spotlight entries

    func testSpotlightLeavesOutPersonalTopicCardsAndTheUsersOwnWords() {
        let words = [
            userWord(1, "awkward", meaning: "garip"),
            word(1, "apple", gloss: "elma"),
            word(2, "divorce", gloss: "boşanmak", sensitivity: 1),
            word(3, "crush", gloss: "hoşlanılan kişi", sensitivity: 2),
            word(4, "bread", gloss: "ekmek", sensitivity: 0),
        ]
        let entries = SpotlightCatalog.entries(from: words, fold: fold)
        XCTAssertEqual(entries.map { $0.wordID }, [1, 4])
        XCTAssertEqual(entries.first?.identifier, "word.1")
        XCTAssertEqual(entries.first?.title, "apple")
        XCTAssertEqual(entries.first?.summary, "elma")
    }

    func testSpotlightEntrySkipsEmptyWordsAndRepeatedIDsAndFallsBackToTheDefinition() {
        let words = [
            word(1, "  ", gloss: "boş"),
            word(2, " spoon ", defShort: " a tool for eating soup "),
            word(2, "spoon again", gloss: "kaşık"),
        ]
        let entries = SpotlightCatalog.entries(from: words, fold: fold)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.title, "spoon")
        XCTAssertEqual(entries.first?.summary, "a tool for eating soup", "no Turkish meaning: the English definition")
        XCTAssertEqual(entries.first?.keywords, [])
    }

    func testSpotlightKeywordsAreTheMeaningsPartsAlsoWithoutTurkishLetters() {
        let entry = SpotlightCatalog.entries(
            from: [word(1, "borrow", gloss: "ödünç almak, borç almak; (para) almak", short: "ödünç almak")],
            fold: fold
        ).first
        XCTAssertEqual(entry?.keywords, ["ödünç almak", "odunc almak", "borç almak", "borc almak", "para", "almak"])
        let plain = SpotlightCatalog.entries(from: [word(2, "tea", gloss: "çay / Çay")], fold: fold).first
        XCTAssertEqual(plain?.keywords, ["çay", "cay", "Çay"], "each text once")
    }

    // MARK: Spotlight signature

    func testSignatureIsStableAndFollowsEveryField() {
        let words = [word(1, "apple", gloss: "elma"), word(2, "bread", gloss: "ekmek")]
        let entries = SpotlightCatalog.entries(from: words, fold: fold)
        let signature = SpotlightCatalog.signature(of: entries)
        XCTAssertEqual(signature, SpotlightCatalog.signature(of: SpotlightCatalog.entries(from: words, fold: fold)))
        XCTAssertTrue(signature.hasPrefix("1-2-"), signature)

        let changedMeaning = SpotlightCatalog.entries(from: [word(1, "apple", gloss: "elmalar"), word(2, "bread", gloss: "ekmek")], fold: fold)
        XCTAssertNotEqual(SpotlightCatalog.signature(of: changedMeaning), signature)
        let reordered = SpotlightCatalog.entries(from: words.reversed(), fold: fold)
        XCTAssertNotEqual(SpotlightCatalog.signature(of: reordered), signature)
        let fewer = SpotlightCatalog.entries(from: [words[0]], fold: fold)
        XCTAssertNotEqual(SpotlightCatalog.signature(of: fewer), signature)
    }

    func testSignatureDoesNotRunFieldsTogether() {
        let first = SpotlightCatalog.entries(from: [word(1, "ab", gloss: "c")], fold: fold)
        let second = SpotlightCatalog.entries(from: [word(1, "a", gloss: "bc")], fold: fold)
        XCTAssertNotEqual(SpotlightCatalog.signature(of: first), SpotlightCatalog.signature(of: second))
    }

    func testSignatureOfNothingIsTheFNVOffsetBasis() {
        // Fixed across launches and platforms (Swift's hashValue is not): 64-bit FNV-1a, no input.
        XCTAssertEqual(SpotlightCatalog.signature(of: []), "1-0-cbf29ce484222325")
    }

    // MARK: When to index

    func testIndexingRunsWhenNeverDoneOrChangedOrAWeekOld() {
        let now = Date(timeIntervalSince1970: 1_760_000_000)
        let day: TimeInterval = 86_400
        XCTAssertTrue(SpotlightCatalog.needsIndexing(signature: "s", indexedSignature: nil, indexedAt: nil, now: now))
        XCTAssertTrue(SpotlightCatalog.needsIndexing(signature: "s", indexedSignature: "s", indexedAt: nil, now: now))
        XCTAssertTrue(SpotlightCatalog.needsIndexing(signature: "s", indexedSignature: "t", indexedAt: now, now: now))
        XCTAssertFalse(SpotlightCatalog.needsIndexing(signature: "s", indexedSignature: "s", indexedAt: now, now: now))
        XCTAssertFalse(SpotlightCatalog.needsIndexing(signature: "s", indexedSignature: "s", indexedAt: now - 6 * day, now: now))
        XCTAssertTrue(SpotlightCatalog.needsIndexing(signature: "s", indexedSignature: "s", indexedAt: now - 7 * day, now: now))
        XCTAssertTrue(SpotlightCatalog.needsIndexing(signature: "s", indexedSignature: "s", indexedAt: now + 60, now: now), "the clock went back")
    }

    // MARK: Word search

    func testSearchRanksTheWordItselfThenTheMeaningThenPrefixesThenWordStarts() {
        let words = [
            word(1, "breakfast time", gloss: "kahvaltı saati"),
            word(2, "have breakfast", gloss: "kahvaltı yapmak"),
            word(3, "breakfasts", gloss: "kahvaltılar"),
            word(4, "breakfast", gloss: "kahvaltı"),
            word(5, "morning meal", gloss: "sabah yemeği, breakfast"),
        ]
        XCTAssertEqual(ids(ShortcutWordSearch.matches("breakfast", in: words, fold: fold)), [4, 5, 1, 3, 2])
    }

    func testSearchFindsTurkishMeaningsWithOrWithoutTurkishLetters() {
        let words = [word(1, "breakfast", gloss: "kahvaltı"), word(2, "borrow", gloss: "ödünç almak, borç almak"), word(3, "lend", gloss: "ödünç vermek")]
        XCTAssertEqual(ids(ShortcutWordSearch.matches("kahvaltı", in: words, fold: fold)), [1])
        XCTAssertEqual(ids(ShortcutWordSearch.matches("KAHVALTI", in: words, fold: fold)), [1])
        XCTAssertEqual(ids(ShortcutWordSearch.matches("kahvalti", in: words, fold: fold)), [1])
        XCTAssertEqual(ids(ShortcutWordSearch.matches("borç almak", in: words, fold: fold)), [2], "one part of the meaning is a whole meaning")
        XCTAssertEqual(ids(ShortcutWordSearch.matches("ödünç", in: words, fold: fold)), [2, 3])
        XCTAssertEqual(ids(ShortcutWordSearch.matches("almak", in: words, fold: fold)), [2], "a later word of the meaning")
    }

    func testSearchIgnoresSiriPunctuationAndSpaces() {
        let words = [word(1, "breakfast", gloss: "kahvaltı"), word(2, "look up", gloss: "sözlükte aramak")]
        XCTAssertEqual(ids(ShortcutWordSearch.matches("Kahvaltı.", in: words, fold: fold)), [1])
        XCTAssertEqual(ids(ShortcutWordSearch.matches("  breakfast?  ", in: words, fold: fold)), [1])
        XCTAssertEqual(ids(ShortcutWordSearch.matches("look   up", in: words, fold: fold)), [2])
        XCTAssertEqual(ids(ShortcutWordSearch.matches("look u", in: words, fold: fold)), [2])
        XCTAssertEqual(ids(ShortcutWordSearch.matches("up", in: words, fold: fold)), [2], "a later English word")
        XCTAssertEqual(ShortcutWordSearch.matches("akfast", in: words, fold: fold), [], "never the middle of a word")
        XCTAssertEqual(ShortcutWordSearch.matches(" . ", in: words, fold: fold), [])
        XCTAssertEqual(ShortcutWordSearch.matches("", in: words, fold: fold), [])
    }

    func testSearchKeepsTheGivenOrderWithinAGroupAndStopsAtTheLimit() {
        let mine = userWord(1, "brunch", meaning: "geç kahvaltı")
        let words = [mine] + (1...15).map { word($0, "b\($0)", gloss: "anlam") }
        XCTAssertEqual(ids(ShortcutWordSearch.matches("b", in: words, fold: fold)), [mine.id] + Array(1...9))
        XCTAssertEqual(ShortcutWordSearch.matches("b", in: words, fold: fold, limit: 3).count, 3)
        XCTAssertEqual(ShortcutWordSearch.matches("b", in: words, fold: fold, limit: 0), [])
    }

    func testSearchListsEachWordOnce() {
        let words = [word(1, "apple", gloss: "elma"), word(1, "apple", gloss: "elma"), word(2, "apples", gloss: "elmalar")]
        XCTAssertEqual(ids(ShortcutWordSearch.matches("apple", in: words, fold: fold)), [1, 2])
    }

    func testSearchFindsAPersonalTopicCardOnlyWhenItIsNamed() {
        let words = [
            word(1, "divorce", gloss: "boşanmak", sensitivity: 1),
            word(2, "divorced", gloss: "boşanmış", sensitivity: 1),
            word(3, "break up", gloss: "ayrılmak, bitirmek", sensitivity: 1),
            word(4, "boss", gloss: "patron"),
        ]
        XCTAssertEqual(ids(ShortcutWordSearch.matches("divorce", in: words, fold: fold)), [1], "the English word itself")
        XCTAssertEqual(ids(ShortcutWordSearch.matches("boşanmak", in: words, fold: fold)), [1], "a meaning itself")
        XCTAssertEqual(ids(ShortcutWordSearch.matches("ayrılmak", in: words, fold: fold)), [3], "one part of the meaning")
        XCTAssertEqual(ids(ShortcutWordSearch.matches("bo", in: words, fold: fold)), [4], "never from a start Siri reads out")
        XCTAssertEqual(ids(ShortcutWordSearch.matches("up", in: words, fold: fold)), [])
    }

    // MARK: The user's words for Siri

    private func temporaryStore() throws -> CustomWordStore {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ShortcutLogicTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: folder)
        }
        return CustomWordStore(fileURL: folder.appendingPathComponent("custom_words.json"))
    }

    func testPeekReadsWhatSaveWrote() throws {
        let store = try temporaryStore()
        var list = CustomWordList()
        try list.add(CustomWordDraft(lemma: "awkward", meaningTR: "garip", exampleEN: "It was an awkward moment."), now: Date(timeIntervalSince1970: 1_760_000_000))
        try list.add(CustomWordDraft(lemma: "look up", meaningTR: "sözlükte aramak"), now: Date(timeIntervalSince1970: 1_760_000_100))
        try store.save(list, now: Date(timeIntervalSince1970: 1_760_000_200))
        XCTAssertEqual(store.peek(), list)
        XCTAssertEqual(store.peek()?.widgetWords.map { $0.lemma }, ["awkward", "look up"])
    }

    func testPeekLeavesAMissingOrDamagedFileAlone() throws {
        let store = try temporaryStore()
        XCTAssertNil(store.peek(), "no file yet")

        try Data("{ not json".utf8).write(to: store.fileURL)
        XCTAssertNil(store.peek())
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.fileURL.path), "the damaged file stays for the app's own load")
        let folder = store.fileURL.deletingLastPathComponent()
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path), ["custom_words.json"], "nothing moved aside or written")

        try Data(#"{"format": 99, "next_id": 1000000, "words": []}"#.utf8).write(to: store.fileURL)
        XCTAssertNil(store.peek(), "a newer format is not read")
    }

    func testSuggestionsLeaveOutPersonalTopicCards() {
        let mine = userWord(1, "awkward", meaning: "garip")
        let words = [mine, word(1, "apple"), word(2, "divorce", sensitivity: 1), word(1, "apple again"), word(3, "bread")]
        XCTAssertEqual(ids(ShortcutWordSearch.suggestions(from: words)), [mine.id, 1, 3])
        XCTAssertEqual(ids(ShortcutWordSearch.suggestions(from: words, limit: 2)), [mine.id, 1])
        XCTAssertEqual(ShortcutWordSearch.suggestions(from: words, limit: -1), [])
    }

    func testWordsByIDKeepTheAskedOrder() {
        let words = [word(1, "apple"), word(2, "bread"), word(3, "cheese"), word(2, "bread again")]
        XCTAssertEqual(ids(ShortcutWordSearch.words(withIDs: [3, 1, 99, 2], in: words)), [3, 1, 2])
        XCTAssertEqual(ShortcutWordSearch.words(withIDs: [2], in: words).first?.lemma, "bread", "the first word with an id")
        XCTAssertEqual(ShortcutWordSearch.words(withIDs: [], in: words), [])
    }

    func testRoutesCompareByWhatTheyOpen() {
        XCTAssertEqual(ShortcutRoute.word(id: 1), .word(id: 1))
        XCTAssertNotEqual(ShortcutRoute.word(id: 1), .word(id: 2))
        XCTAssertNotEqual(ShortcutRoute.addWord(lemma: "a"), .addWord(lemma: "b"))
        XCTAssertNotEqual(ShortcutRoute.review, .addWord(lemma: ""))
    }
}
