import XCTest
import CoreModels

/// The large widget's details on the plan's words (`WidgetWord.secondExampleEN`, `warning`,
/// CoreModels/WidgetWarning.swift): which example and which warning are chosen, and the JSON the
/// app writes and the widget reads (contract section 6).
final class LargeWidgetDetailsTests: XCTestCase {
    private let actually = CardDetail(
        examples: [
            .init(en: "I thought the test would be hard, but it was actually quite easy."),
            .init(en: "Actually, I'd prefer tea, if that's okay."),
            .init(en: "He looks shy, but he actually loves meeting new people."),
        ],
        mistakes: [
            .init(wrong: "The actual price of petrol is very high.", right: "The current price of petrol is very high.", why: "…"),
            .init(wrong: "Actually I'm studying English. (= şu anda)", right: "I'm currently studying English.", why: "…"),
        ],
        falseFriend: .init(trWord: "aktüel", trMeans: "güncel, şu anki", enForThat: "current / currently")
    )

    private func word(lemma: String, example: String) -> WidgetWord {
        return WidgetWord(
            id: 286, lemma: lemma, pos: "adv", level: "B1", defMicro: "in fact",
            defShort: "used to say what is really true", exampleEN: example, glossTR: "aslında, gerçekte"
        )
    }

    /// The false friend comes first, as in the card's warning slot (ogrenme_ilkeleri 2.2).
    func testFalseFriendComesBeforeTheMistake() {
        XCTAssertEqual(actually.widgetWarning(lemma: "actually"), .falseFriend(turkish: "aktüel", english: "current / currently"))
    }

    /// Without a false friend: the first mistake about the card's word ("actually", not the
    /// mistake about "actual"), else the first one; nothing for a card with neither.
    func testMistakeAboutTheWordIsChosen() {
        let mistakes = CardDetail(mistakes: actually.mistakes)
        XCTAssertEqual(
            mistakes.widgetWarning(lemma: "actually"),
            .mistake(wrong: "Actually I'm studying English. (= şu anda)", right: "I'm currently studying English.")
        )
        XCTAssertEqual(
            mistakes.widgetWarning(lemma: "tea"),
            .mistake(wrong: "The actual price of petrol is very high.", right: "The current price of petrol is very high.")
        )
        XCTAssertNil(CardDetail(examples: actually.examples).widgetWarning(lemma: "actually"))
        // An empty false friend or mistake (lenient decoding) is no warning.
        let empty = CardDetail(
            mistakes: [.init(wrong: "", right: "I had breakfast.", why: "")],
            falseFriend: .init(trWord: "", trMeans: "", enForThat: "")
        )
        XCTAssertNil(empty.widgetWarning(lemma: "breakfast"))
    }

    /// The second example is the shortest other one with the word in it; an example without the
    /// word ("teeth" for "tooth") only when no other has it.
    func testSecondExampleIsTheShortestOtherOneWithTheWord() {
        XCTAssertEqual(
            actually.secondExample(besides: actually.examples[0].en, containing: "actually"),
            "Actually, I'd prefer tea, if that's okay."
        )
        XCTAssertEqual(
            actually.secondExample(besides: "Actually, I'd prefer tea, if that's okay.", containing: "actually"),
            "He looks shy, but he actually loves meeting new people."
        )
        let tooth = CardDetail(examples: [
            .init(en: "I brush my teeth twice a day."),
            .init(en: "Ali's tooth hurts, so he is going to the dentist."),
        ])
        XCTAssertEqual(
            tooth.secondExample(besides: "Ali's tooth hurts, so he is going to the dentist.", containing: "tooth"),
            "I brush my teeth twice a day."
        )
        XCTAssertNil(CardDetail(examples: [.init(en: "Only one.")]).secondExample(besides: "Only one.", containing: "one"))
    }

    func testAddingDetailsKeepsTheWordAndLeavesSeedWordsAlone() {
        let plain = word(lemma: "actually", example: actually.examples[0].en)
        let large = plain.addingLargeWidgetDetails(from: actually)
        XCTAssertEqual(large.id, plain.id)
        XCTAssertEqual(large.exampleEN, plain.exampleEN)
        XCTAssertEqual(large.secondExampleEN, "Actually, I'd prefer tea, if that's okay.")
        XCTAssertEqual(large.warning, .falseFriend(turkish: "aktüel", english: "current / currently"))
        XCTAssertEqual(plain.addingLargeWidgetDetails(from: nil), plain)
        XCTAssertNil(plain.secondExampleEN)
        XCTAssertNil(plain.warning)
    }

    /// The plan's JSON: snake_case keys, both warning kinds, and nothing written when a word has
    /// no details, so an older plan or the seed still decodes.
    func testPlanJSONRoundTripsBothWarningKinds() throws {
        let large = word(lemma: "actually", example: actually.examples[0].en).addingLargeWidgetDetails(from: actually)
        let data = try JSONEncoder().encode(large)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["second_example_en"] as? String, "Actually, I'd prefer tea, if that's okay.")
        let warning = try XCTUnwrap(object["warning"] as? [String: Any])
        let friend = try XCTUnwrap(warning["false_friend"] as? [String: Any])
        XCTAssertEqual(friend["tr_word"] as? String, "aktüel")
        XCTAssertEqual(friend["en_for_that"] as? String, "current / currently")
        XCTAssertEqual(friend.count, 2)
        XCTAssertEqual(try JSONDecoder().decode(WidgetWord.self, from: data), large)

        let json = """
        {"id":240,"lemma":"listen","pos":"v","level":"A2","def_micro":"pay attention to sounds",
         "def_short":"give your attention to a sound","example_en":"He never listens when I talk.",
         "gloss_tr":"dinlemek","second_example_en":"I listen to music on the bus every morning.",
         "warning":{"mistake":{"wrong":"I listen music every day.","right":"I listen to music every day."}}}
        """
        let listen = try JSONDecoder().decode(WidgetWord.self, from: Data(json.utf8))
        XCTAssertEqual(listen.secondExampleEN, "I listen to music on the bus every morning.")
        XCTAssertEqual(listen.warning, .mistake(wrong: "I listen music every day.", right: "I listen to music every day."))

        let plain = word(lemma: "actually", example: "Actually, no.")
        let plainObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(plain)) as? [String: Any]
        )
        XCTAssertNil(plainObject["second_example_en"])
        XCTAssertNil(plainObject["warning"])
    }

    func testLargeWidgetEventSource() {
        XCTAssertEqual(WidgetEventSource.systemLarge.rawValue, "system_large")
        XCTAssertEqual(WidgetEventSource(rawValue: "system_large"), .systemLarge)
    }
}
