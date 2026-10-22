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
}
