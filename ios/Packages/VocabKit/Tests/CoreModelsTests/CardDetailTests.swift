import XCTest
import CoreModels

final class CardDetailTests: XCTestCase {
    private func decode(_ json: String) throws -> CardDetail {
        return try JSONDecoder().decode(CardDetail.self, from: Data(json.utf8))
    }

    func testFullCardJSONDecodesTheFieldsTheAppShows() throws {
        // Trimmed copy of a real card as build_db stores it in `card.json` (unused fields kept
        // to make sure they are ignored).
        let json = """
        {"id":"en.breakfast.n.1","lemma":"breakfast","type":"word","pos":"n","sense_no":1,
         "def":{"micro":"first meal of the day","short":"the first meal of the day","long":"The first meal."},
         "examples":[
           {"en":"I usually have breakfast at seven.","tr":"Genellikle yedide kahvaltı yaparım.","register":"neutral","focus":"breakfast"},
           {"en":"Breakfast is included.","tr":null,"register":"neutral","focus":"Breakfast"}],
         "collocations":["have breakfast","skip breakfast"],
         "etymology":{"text":"break + fast","origin":"English","confidence":"high"},
         "l1":{"tr":{"gloss":"kahvaltı","alt":["sabah kahvaltısı"],"equivalence":"full","false_friend":null,
           "note":"Öğün adlarından önce 'the' gelmez.",
           "mistakes":[{"wrong":"I did breakfast.","right":"I had breakfast.","why":"'have breakfast' denir."}],
           "mnemonic":"Break + fast"}},
         "meta":{"status":"draft","qa_flags":[]}}
        """
        let detail = try decode(json)
        XCTAssertEqual(detail.examples, [
            CardDetail.Example(en: "I usually have breakfast at seven.", tr: "Genellikle yedide kahvaltı yaparım."),
            CardDetail.Example(en: "Breakfast is included.", tr: nil),
        ])
        XCTAssertEqual(detail.collocations, ["have breakfast", "skip breakfast"])
        XCTAssertEqual(detail.glossAlternatives, ["sabah kahvaltısı"])
        XCTAssertEqual(detail.noteTR, "Öğün adlarından önce 'the' gelmez.")
        XCTAssertEqual(detail.mistakes, [CardDetail.Mistake(wrong: "I did breakfast.", right: "I had breakfast.", why: "'have breakfast' denir.")])
        XCTAssertNil(detail.falseFriend)
        XCTAssertEqual(detail.mnemonicTR, "Break + fast")
    }

    func testFalseFriendUsesSnakeCaseKeys() throws {
        let json = """
        {"l1":{"tr":{"false_friend":{"tr_word":"aktüel","tr_means":"güncel","en_for_that":"current"}}}}
        """
        let detail = try decode(json)
        XCTAssertEqual(detail.falseFriend, CardDetail.FalseFriend(trWord: "aktüel", trMeans: "güncel", enForThat: "current"))
    }

    func testQuizDecodesAndMixesOptionsStably() throws {
        let json = """
        {"quiz":{"cloze":"I eat soup with a ______, not with a fork.","answer":"spoon","distractors":["knife","plate","cup"]}}
        """
        let quiz = try XCTUnwrap(try decode(json).quiz)
        XCTAssertEqual(quiz.answer, "spoon")
        XCTAssertEqual(quiz.distractors, ["knife", "plate", "cup"])

        let options = quiz.options(seed: 2)
        XCTAssertEqual(Set(options), ["spoon", "knife", "plate", "cup"])
        XCTAssertEqual(quiz.options(seed: 2), options, "same seed, same order")
        // Across many seeds the answer must not sit in one fixed position.
        let positions = Set((1...40).map { quiz.options(seed: $0).firstIndex(of: "spoon") ?? -1 })
        XCTAssertGreaterThan(positions.count, 2)
    }

    func testQuizOptionsDropDuplicates() {
        let quiz = CardDetail.Quiz(cloze: "a ______", answer: "x", distractors: ["y", "x", "y"])
        XCTAssertEqual(Set(quiz.options(seed: 7)), ["x", "y"])
        XCTAssertEqual(quiz.options(seed: 7).count, 2)
    }

    func testFilledSentencePutsTheAnswerInTheBlank() {
        let middle = CardDetail.Quiz(cloze: "We usually eat ______ at 7 a.m.", answer: "breakfast", distractors: ["x"])
        XCTAssertEqual(middle.filledSentence, "We usually eat breakfast at 7 a.m.")
        let start = CardDetail.Quiz(cloze: "___ is my favourite meal.", answer: "breakfast", distractors: ["x"])
        XCTAssertEqual(start.filledSentence, "Breakfast is my favourite meal.")
        let noBlank = CardDetail.Quiz(cloze: "No blank here.", answer: "x", distractors: ["y"])
        XCTAssertEqual(noBlank.filledSentence, "No blank here.")
    }

    func testMissingFieldsDecodeAsEmpty() throws {
        XCTAssertEqual(try decode("{}"), CardDetail())
        XCTAssertEqual(try decode(#"{"l1":{"en":{"alt":["x"]}}}"#), CardDetail())
    }
}
