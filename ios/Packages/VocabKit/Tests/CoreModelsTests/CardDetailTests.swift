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

    func testMissingFieldsDecodeAsEmpty() throws {
        XCTAssertEqual(try decode("{}"), CardDetail())
        XCTAssertEqual(try decode(#"{"l1":{"en":{"alt":["x"]}}}"#), CardDetail())
    }
}
