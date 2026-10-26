import XCTest
import CoreModels

/// Fields added to `WidgetWord` after schema 1 (`gloss_short_tr`, `sensitivity`,
/// `confusable_ids`): they decode when present and older JSON without them still decodes.
final class WidgetWordTests: XCTestCase {
    func testNewOptionalFieldsDecode() throws {
        let json = """
        {"id":12,"lemma":"disagree","pos":"v","level":"A2","ipa_us":"/ˌdɪsəˈɡri/",
         "def_micro":"have another opinion","def_short":"to have a different opinion",
         "example_en":"I disagree with you.","gloss_tr":"aynı fikirde olmamak",
         "gloss_short_tr":"katılmamak","sensitivity":1,"confusable_ids":[13,40]}
        """
        let word = try JSONDecoder().decode(WidgetWord.self, from: Data(json.utf8))
        XCTAssertEqual(word.glossTR, "aynı fikirde olmamak")
        XCTAssertEqual(word.glossShortTR, "katılmamak")
        XCTAssertEqual(word.sensitivity, 1)
        XCTAssertTrue(word.isSensitive)
        XCTAssertEqual(word.confusableIDs, [13, 40])
    }

    func testOlderJSONWithoutNewFieldsStillDecodes() throws {
        let json = """
        {"id":7,"lemma":"look up to","pos":"phv","level":"B2","ipa_us":null,
         "def_micro":"admire","def_short":"to admire someone","example_en":"I look up to her.",
         "gloss_tr":"örnek almak"}
        """
        let word = try JSONDecoder().decode(WidgetWord.self, from: Data(json.utf8))
        XCTAssertNil(word.glossShortTR)
        XCTAssertNil(word.sensitivity)
        XCTAssertFalse(word.isSensitive)
        XCTAssertNil(word.confusableIDs)
    }

    func testSeedWordWithNullShortGlossDecodes() throws {
        let json = """
        {"schema_version":2,"content_version":"2026.10.22-test","words":[
          {"id":1,"lemma":"breakfast","pos":"n","level":"A1","ipa_us":"/ˈbrɛkfəst/",
           "def_micro":"first meal of the day","def_short":"the first meal of the day",
           "example_en":"I have breakfast at seven.","gloss_tr":"kahvaltı","gloss_short_tr":null}
        ]}
        """
        let file = try SeedWords.decode(Data(json.utf8))
        XCTAssertEqual(file.schemaVersion, 2)
        XCTAssertNil(file.words[0].glossShortTR)
    }

    func testRoundTripKeepsNewFieldsAndOmitsMissingOnes() throws {
        let word = WidgetWord(
            id: 3, lemma: "borrow", pos: "v", level: "A2", defMicro: "take and give back",
            defShort: "to take something and give it back later", exampleEN: "Can I borrow your pen?",
            glossTR: "ödünç almak", sensitivity: 0, confusableIDs: [4]
        )
        let data = try JSONEncoder().encode(word)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertNil(object["gloss_short_tr"])
        XCTAssertNotNil(object["sensitivity"])
        XCTAssertNotNil(object["confusable_ids"])
        let decoded = try JSONDecoder().decode(WidgetWord.self, from: data)
        XCTAssertEqual(decoded, word)
        XCTAssertEqual(decoded.confusableIDs, [4])
    }

    // MARK: symbol (docs/ozellik_planlari/kelime_gorselleri.md)

    func testSymbolDecodesWhenPresent() throws {
        let json = """
        {"id":3,"lemma":"luggage","pos":"n","level":"A2","def_micro":"bags for a trip",
         "def_short":"the bags you take on a trip","example_en":"Where is my luggage?",
         "gloss_tr":"bagaj","symbol":"suitcase.rolling"}
        """
        let word = try JSONDecoder().decode(WidgetWord.self, from: Data(json.utf8))
        XCTAssertEqual(word.symbol, "suitcase.rolling")
    }

    func testSymbolIsNilWhenMissingOrNull() throws {
        let missing = """
        {"id":7,"lemma":"actually","pos":"adv","level":"B1","def_micro":"in fact",
         "def_short":"used to say what is true","example_en":"Actually, I like it."}
        """
        XCTAssertNil(try JSONDecoder().decode(WidgetWord.self, from: Data(missing.utf8)).symbol)
        let null = missing.replacingOccurrences(of: "\"pos\":\"adv\"", with: "\"pos\":\"adv\",\"symbol\":null")
        XCTAssertNotEqual(null, missing)
        XCTAssertNil(try JSONDecoder().decode(WidgetWord.self, from: Data(null.utf8)).symbol)
    }

    /// The default init leaves it out (every older call site), and a word without one writes no
    /// `symbol` key, so the plan JSON of most words stays as before.
    func testSymbolRoundTripsAndIsOmittedWhenNil() throws {
        let plain = WidgetWord(id: 1, lemma: "borrow", pos: "v", level: "A2", defMicro: "m", defShort: "s", exampleEN: "e")
        XCTAssertNil(plain.symbol)
        let plainObject = try XCTUnwrap(JSONSerialization.jsonObject(with: try JSONEncoder().encode(plain)) as? [String: Any])
        XCTAssertNil(plainObject["symbol"])

        let word = WidgetWord(id: 2, lemma: "key", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e", symbol: "key")
        let data = try JSONEncoder().encode(word)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["symbol"] as? String, "key")
        XCTAssertEqual(try JSONDecoder().decode(WidgetWord.self, from: data), word)
    }

    func testSeedWordsCarryTheSymbolOnlyWhereGiven() throws {
        let json = """
        {"schema_version":2,"content_version":"2026.10.26-test","words":[
          {"id":1,"lemma":"breakfast","pos":"n","level":"A1","ipa_us":null,"def_micro":"first meal",
           "def_short":"the first meal of the day","example_en":"I have breakfast.","gloss_tr":"kahvaltı",
           "gloss_short_tr":null},
          {"id":11,"lemma":"fridge","pos":"n","level":"A1","ipa_us":null,"def_micro":"cold box",
           "def_short":"a machine that keeps food cold","example_en":"The milk is in the fridge.",
           "gloss_tr":"buzdolabı","gloss_short_tr":null,"symbol":"refrigerator"}
        ]}
        """
        let file = try SeedWords.decode(Data(json.utf8))
        XCTAssertNil(file.words[0].symbol)
        XCTAssertEqual(file.words[1].symbol, "refrigerator")
    }

    /// The plan's copy of a word (`addingLargeWidgetDetails(from:)`) keeps the symbol, with and
    /// without a detail.
    func testSymbolSurvivesTheLargeWidgetDetails() {
        let word = WidgetWord(
            id: 21, lemma: "umbrella", pos: "n", level: "A1", defMicro: "keeps rain off",
            defShort: "a thing you hold over your head in the rain", exampleEN: "Take an umbrella.",
            glossTR: "şemsiye", symbol: "umbrella"
        )
        let detail = CardDetail(examples: [.init(en: "Take an umbrella."), .init(en: "My umbrella is red.")])
        let detailed = word.addingLargeWidgetDetails(from: detail)
        XCTAssertEqual(detailed.secondExampleEN, "My umbrella is red.")
        XCTAssertEqual(detailed.symbol, "umbrella")
        XCTAssertEqual(word.addingLargeWidgetDetails(from: nil).symbol, "umbrella")
    }
}
