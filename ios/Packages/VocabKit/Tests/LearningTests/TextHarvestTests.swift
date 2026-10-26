import XCTest
import CoreModels
@testable import Learning

final class TextHarvestTests: XCTestCase {
    private func card(_ id: Int, _ lemma: String, pos: String = "v") -> WidgetWord {
        return WidgetWord(id: id, lemma: lemma, pos: pos, level: "A1", defMicro: "", defShort: "", exampleEN: "", glossTR: "anlam")
    }

    /// A user's own word (`CustomWordID`), as `CustomWord.widgetWord` makes it.
    private func ownWord(_ offset: Int, _ lemma: String) -> WidgetWord {
        return WidgetWord(id: CustomWordID.first + offset, lemma: lemma, pos: "", level: "", defMicro: "", defShort: "", exampleEN: "", glossTR: "anlam")
    }

    /// Looks words up as AppModel does: by the lowercased headword, the first word with it wins.
    private func harvest(
        _ text: String,
        cards: [WidgetWord],
        own: [WidgetWord] = [],
        states: [Int: LearningState] = [:]
    ) -> TextHarvest.Result {
        let byLemma = Dictionary(cards.map { ($0.lemma.lowercased(), $0) }, uniquingKeysWith: { first, _ in first })
        let ownByLemma = Dictionary(own.map { ($0.lemma.lowercased(), $0) }, uniquingKeysWith: { first, _ in first })
        return TextHarvest.harvest(
            text,
            card: { byLemma[$0] },
            ownWord: { ownByLemma[$0] },
            state: { states[$0.id] ?? .new }
        )
    }

    private func lemmas(_ matches: [TextHarvest.Match]) -> [String] {
        return matches.map { $0.word.lemma }
    }

    private func textForms(_ matches: [TextHarvest.Match]) -> [String?] {
        return matches.map { $0.textForm }
    }

    // MARK: Word forms

    func testLemmaCandidatesUndoSimpleInflection() {
        let table: [(String, String)] = [
            // Irregular verbs, nouns and comparatives.
            ("went", "go"), ("children", "child"), ("better", "good"), ("knives", "knife"),
            // Plurals and the "-s" form.
            ("cats", "cat"), ("boxes", "box"), ("watches", "watch"), ("dishes", "dish"),
            ("goes", "go"), ("studies", "study"), ("stories", "story"), ("teachers", "teacher"),
            // "-ing": a doubled letter, a lost "e", a base that ends in a double letter.
            ("running", "run"), ("planning", "plan"), ("shopping", "shop"), ("making", "make"),
            ("hoping", "hope"), ("calling", "call"), ("opening", "open"), ("flying", "fly"), ("lying", "lie"),
            // "-ed".
            ("stopped", "stop"), ("tried", "try"), ("cried", "cry"), ("liked", "like"),
            ("played", "play"), ("visited", "visit"),
            // "-er" and "-est".
            ("bigger", "big"), ("biggest", "big"), ("nicer", "nice"), ("tallest", "tall"), ("happiest", "happy"),
        ]
        for (form, base) in table {
            XCTAssertEqual(TextHarvest.lemmaCandidates(of: form).first, base, form)
        }
        XCTAssertTrue(TextHarvest.lemmaCandidates(of: "larger").contains("large"))
        XCTAssertTrue(TextHarvest.lemmaCandidates(of: "used").contains("use"))
        XCTAssertTrue(TextHarvest.lemmaCandidates(of: "agreed").contains("agree"))
        XCTAssertTrue(TextHarvest.lemmaCandidates(of: "leaves").contains("leaf"))
        XCTAssertTrue(TextHarvest.lemmaCandidates(of: "leaves").contains("leave"))
    }

    func testLemmaCandidatesNeverRepeatTheWordOrBreakAWholeWord() {
        for form in ["running", "cats", "went", "boxes", "go", "a", "news", "always"] {
            XCTAssertFalse(TextHarvest.lemmaCandidates(of: form).contains(form), form)
        }
        XCTAssertEqual(TextHarvest.lemmaCandidates(of: "news"), [], "news is not new + s")
        XCTAssertEqual(TextHarvest.lemmaCandidates(of: "bus"), [])
        XCTAssertEqual(TextHarvest.lemmaCandidates(of: "glass"), [])
        XCTAssertEqual(TextHarvest.lemmaCandidates(of: "Went").first, "go", "case does not matter")
    }

    func testLemmaCandidatesWithoutComparatives() {
        XCTAssertEqual(TextHarvest.lemmaCandidates(of: "teacher", comparatives: false), [])
        XCTAssertEqual(TextHarvest.lemmaCandidates(of: "biggest", comparatives: false), [])
        XCTAssertEqual(TextHarvest.lemmaCandidates(of: "better", comparatives: false).first, "good", "irregular forms stay")
        XCTAssertEqual(TextHarvest.lemmaCandidates(of: "running", comparatives: false).first, "run")
    }

    func testWordFormTakesOffEndingsAndDropsWhatIsNotAWord() {
        XCTAssertNil(TextHarvest.wordForm("don't"))
        XCTAssertNil(TextHarvest.wordForm("can't"))
        XCTAssertEqual(TextHarvest.wordForm("mother's"), "mother")
        XCTAssertEqual(TextHarvest.wordForm("it's"), "it")
        XCTAssertEqual(TextHarvest.wordForm("we've"), "we")
        XCTAssertEqual(TextHarvest.wordForm("they'll"), "they")
        XCTAssertNil(TextHarvest.wordForm("i'd"), "one letter left")
        XCTAssertEqual(TextHarvest.wordForm("o'clock"), "o'clock")
        XCTAssertEqual(TextHarvest.wordForm("well-known"), "well-known")
        XCTAssertNil(TextHarvest.wordForm("a"))
        XCTAssertNil(TextHarvest.wordForm("çok"), "a Turkish letter")
        XCTAssertNil(TextHarvest.wordForm("кошка"), "another alphabet")
    }

    // MARK: Reading

    func testReadingKeepsTheFirstPlaceOfEachWordOnce() {
        let reading = TextHarvest.read("Hello, hello WORLD! New-York’s well-known o’clock.")
        XCTAssertEqual(reading.words.map(\.form), ["hello", "world", "new-york", "well-known", "o'clock"])
        XCTAssertEqual(reading.words.map(\.position), [0, 2, 3, 4, 5])
        XCTAssertFalse(reading.wasCut)
        // A comma and the full stops end runs: "hello" and "hello world" are apart.
        XCTAssertEqual(reading.runs.map { $0.map(\.raw) }, [["hello"], ["hello", "world"], ["new-york's", "well-known", "o'clock"]])
    }

    func testCurlyApostrophesCountAsStraightOnes() {
        let result = harvest("I can’t wait. It’s my mother’s car.", cards: [card(1, "I can't wait")])
        XCTAssertEqual(lemmas(result.cards), ["I can't wait"])
        XCTAssertEqual(textForms(result.cards), [nil], "written as the card writes it")
        XCTAssertEqual(result.newWords, ["mother", "car"])
    }

    // MARK: Matching

    func testInflectedFormsFindTheirCardAndSayHowTheTextWroteThem() {
        let cards = [card(1, "go"), card(2, "child"), card(3, "have"), card(4, "breakfast")]
        let result = harvest("We went home. The children had breakfast.", cards: cards)
        XCTAssertEqual(lemmas(result.cards), ["go", "child", "have", "breakfast"])
        XCTAssertEqual(textForms(result.cards), ["went", "children", "had", nil])
        XCTAssertEqual(result.newWords, ["home"])
        XCTAssertEqual(result.ownWords, [])
        XCTAssertFalse(result.isEmpty)
    }

    func testTheWordAsWrittenComesBeforeAGuess() {
        let cards = [card(1, "find"), card(2, "found"), card(3, "leave"), card(4, "left")]
        let result = harvest("We found it on the left. They left.", cards: cards)
        XCTAssertEqual(lemmas(result.cards), ["found", "left"])
        XCTAssertEqual(textForms(result.cards), [nil, nil])
    }

    func testEachCardIsListedOnceAtItsFirstPlace() {
        let result = harvest("Cats sleep. My cat sleeps. Cat!", cards: [card(1, "cat"), card(2, "sleep")])
        XCTAssertEqual(lemmas(result.cards), ["cat", "sleep"])
        XCTAssertEqual(textForms(result.cards), ["cats", nil], "the first form found")
    }

    func testAPhraseIsFoundWithItsFirstWordInflectedAndCoversItsWords() {
        let cards = [
            card(1, "wake up"), card(2, "tired"), card(3, "borrow"), card(4, "have"), card(5, "breakfast"),
            card(6, "look forward to"), card(7, "look"), card(8, "forward"), card(9, "weekend"),
        ]
        let text = "On Saturday morning Mehmet woke up tired. He borrowed his sister's bike and we had breakfast by the river. I am looking forward to the weekend. What a lovely serendipity!"
        let result = harvest(text, cards: cards)
        XCTAssertEqual(lemmas(result.cards), ["wake up", "tired", "borrow", "have", "breakfast", "look forward to", "weekend"])
        XCTAssertEqual(textForms(result.cards), ["woke up", nil, "borrowed", "had", nil, "looking forward to", nil])
        // "woke", "look" and "forward" stand only inside a phrase found; "Mehmet" and "Saturday"
        // are names; "he", "his", "and", "the", "what", "a" are function words.
        XCTAssertEqual(result.newWords, ["morning", "sister", "bike", "river", "lovely", "serendipity"])
    }

    func testPhrasesAfterAContractedBeAndWithAnyPossessive() {
        let cards = [card(1, "be fed up with"), card(2, "change your mind"), card(3, "I can't wait"), card(4, "it's up to you")]
        let result = harvest("I'm fed up with this rain. She changed her mind. I can't wait! It's up to you.", cards: cards)
        XCTAssertEqual(lemmas(result.cards), ["be fed up with", "change your mind", "I can't wait", "it's up to you"])
        XCTAssertEqual(textForms(result.cards), ["fed up with", "changed her mind", nil, nil])
        XCTAssertEqual(result.newWords, ["rain"])
    }

    func testBeIntoAndMakeYourselfAtHome() {
        let cards = [card(1, "be into"), card(2, "make yourself at home")]
        XCTAssertEqual(lemmas(harvest("I'm into jazz.", cards: cards).cards), ["be into"])
        XCTAssertEqual(lemmas(harvest("Please make yourself at home.", cards: cards).cards), ["make yourself at home"])
        XCTAssertEqual(lemmas(harvest("I made myself at home.", cards: cards).cards), ["make yourself at home"])
        XCTAssertEqual(lemmas(harvest("Go into the room.", cards: cards).cards), [], "into without be")
    }

    func testAnErFormFindsOnlyAnAdjectiveOrAdverbCard() {
        let cards = [card(1, "teach"), card(2, "drive"), card(3, "cheap", pos: "adj"), card(4, "big", pos: "adj")]
        let result = harvest("My teacher is a good driver. It is cheaper and bigger.", cards: cards)
        XCTAssertEqual(lemmas(result.cards), ["cheap", "big"])
        XCTAssertEqual(textForms(result.cards), ["cheaper", "bigger"])
        XCTAssertEqual(result.newWords, ["teacher", "good", "driver"])
    }

    func testAnErNounDoesNotJoinItsVerbAmongNewWords() {
        XCTAssertEqual(harvest("I want to teach. My teacher is kind.", cards: []).newWords, ["want", "teach", "teacher", "kind"])
    }

    func testOfTwoOverlappingPhrasesTheOneWrittenAsTheCardStays() {
        let cards = [card(1, "go on"), card(2, "on foot")]
        let went = harvest("We went on foot.", cards: cards)
        XCTAssertEqual(lemmas(went.cards), ["on foot"], "on is used once; went on is not go on here")
        XCTAssertEqual(went.newWords, ["went"])
        XCTAssertEqual(lemmas(harvest("We go on foot.", cards: cards).cards), ["go on"], "both as written: the earlier one")
        // A phrase inside a longer one found first is not listed.
        let inside = harvest("I am looking forward to it.", cards: [card(3, "look forward to"), card(4, "forward to")])
        XCTAssertEqual(lemmas(inside.cards), ["look forward to"])
    }

    func testTheLongestPhraseWins() {
        let cards = [card(1, "get back"), card(2, "get back to"), card(3, "get")]
        let result = harvest("I will get back to you.", cards: cards)
        XCTAssertEqual(lemmas(result.cards), ["get back to"])
    }

    func testAPhraseNeverSpansPunctuation() {
        let result = harvest("Look, forward to it.", cards: [card(1, "look forward to")])
        XCTAssertEqual(result.cards, [])
        XCTAssertEqual(result.newWords, ["look", "forward"])
    }

    func testTheUsersOwnWordsComeFirstAndCanBePhrases() {
        let result = harvest(
            "An awkward moment. I look up words.",
            cards: [card(1, "awkward"), card(2, "look")],
            own: [ownWord(1, "awkward"), ownWord(2, "look up")]
        )
        XCTAssertEqual(lemmas(result.ownWords), ["awkward", "look up"])
        XCTAssertEqual(result.cards, [], "awkward is the user's; look stands only in look up")
        XCTAssertEqual(result.newWords, ["moment", "words"])
    }

    func testTheStateComesFromTheGivenClosure() {
        let apple = card(1, "apple")
        let bread = card(2, "bread")
        let mine = ownWord(1, "brunch")
        let result = harvest(
            "Apple, bread and brunch.",
            cards: [apple, bread],
            own: [mine],
            states: [apple.id: .known, mine.id: .learning]
        )
        XCTAssertEqual(result.cards.map(\.state), [.known, .new])
        XCTAssertEqual(result.ownWords.map(\.state), [.learning])
    }

    // MARK: New words

    func testNewWordsLeaveOutFunctionWordsAndNames() {
        let result = harvest("Yesterday I met Anna in London. We love London and Anna. Tom is here.", cards: [])
        // Anna and London only ever stand capitalised in mid-sentence; Tom starts a sentence.
        XCTAssertEqual(result.newWords, ["yesterday", "met", "love", "tom"])
    }

    func testCapitalsForEmphasisAreNotNames() {
        XCTAssertEqual(harvest("The mayor said the NEW PARK will open.", cards: []).newWords, ["mayor", "said", "new", "park", "open"])
        XCTAssertEqual(harvest("I watched the BBC news.", cards: []).newWords, ["watched", "bbc", "news"])
    }

    func testATitleLineSaysNothingAboutNames() {
        let result = harvest("Scientists Discover New Planet\nThe planet is far away.", cards: [])
        XCTAssertEqual(result.newWords, ["scientists", "discover", "new", "planet", "far", "away"])
    }

    func testNewWordsAreUniqueInTheTextsOrderWithABaseForTwoForms() {
        XCTAssertEqual(harvest("The the THE the. Apple apple APPLE", cards: []).newWords, ["apple"])
        XCTAssertEqual(harvest("Cats and a cat. Boxes, box.", cards: []).newWords, ["cat", "box"])
    }

    func testNumbersLinksAndAddressesAreNotWords() {
        let text = "Visit https://example.com or mail me at a@b.com, see lockglow.app and www.test.org now. 3rd place in 2024, mp3 files."
        XCTAssertEqual(harvest(text, cards: []).newWords, ["visit", "mail", "see", "place", "files"])
    }

    // MARK: Nothing to read

    func testTurkishTextAndGarbageReadNoWords() {
        for text in ["Bugün çok güzel. 12345 !!! ??? ğğğ", "#@$%^&*()", "😀 🎉", "кошка"] {
            let result = harvest(text, cards: [card(1, "cat")])
            XCTAssertTrue(result.readNoWords, text)
            XCTAssertTrue(result.isEmpty, text)
        }
    }

    func testAnEmptyTextReadsNoWords() {
        for text in ["", "   \n ", "\n\n"] {
            let result = harvest(text, cards: [])
            XCTAssertTrue(result.readNoWords)
            XCTAssertTrue(result.isEmpty)
            XCTAssertFalse(result.wasCut)
        }
    }

    func testOnlyFunctionWordsIsEmptyButReadSomething() {
        let result = harvest("It is what it is, and so on.", cards: [])
        XCTAssertFalse(result.readNoWords)
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: Text from a picture

    func testLinesFromAPictureJoinIntoOneText() {
        XCTAssertEqual(TextHarvest.joiningLines(["I woke up", "early today.", "It was cold."]), "I woke up early today. It was cold.")
        XCTAssertEqual(TextHarvest.joiningLines(["a very impor-", "tant day"]), "a very important day", "a word cut at the line end")
        XCTAssertEqual(TextHarvest.joiningLines(["well-", "Known"]), "well- Known", "a capital letter starts a new word")
        XCTAssertEqual(TextHarvest.joiningLines(["Price -", "ten pounds"]), "Price - ten pounds", "a dash after a space is not a cut word")
        XCTAssertEqual(TextHarvest.joiningLines(["  ", "", " Hello  "]), "Hello")
        XCTAssertEqual(TextHarvest.joiningLines([]), "")
    }

    // MARK: Limits

    func testALongTextIsCutAtTheInputLimit() {
        // "tea " is 4 characters: the limit ends exactly after a word.
        let text = String(repeating: "tea ", count: TextHarvest.inputLimit / 4 + 1_000)
        let result = harvest(text, cards: [])
        XCTAssertTrue(result.wasCut)
        XCTAssertEqual(result.newWords, ["tea"])
        XCTAssertFalse(harvest(String(repeating: "tea ", count: TextHarvest.inputLimit / 4), cards: []).wasCut)
    }

    func testReadingStopsAtTheWordLimit() {
        // 350 different three-letter words: "qaa", "qab", … (no ending to take off).
        let words = (0..<350).map { index -> String in
            let first = Character(UnicodeScalar(UInt8(97 + index / 26)))
            let second = Character(UnicodeScalar(UInt8(97 + index % 26)))
            return "q" + String(first) + String(second)
        }
        let result = harvest(words.joined(separator: " "), cards: [])
        XCTAssertTrue(result.wasCut)
        XCTAssertEqual(result.newWords.count, TextHarvest.wordLimit)
        XCTAssertEqual(result.newWords.first, "qaa")
        XCTAssertEqual(result.newWords.last, words[TextHarvest.wordLimit - 1])
        XCTAssertFalse(harvest(words.prefix(TextHarvest.wordLimit).joined(separator: " "), cards: []).wasCut)
    }
}
