import XCTest
import CoreModels

final class SpeechTextTests: XCTestCase {
    private typealias Piece = SpeechText.Piece

    func testAPlainWordIsOnePiece() {
        XCTAssertEqual(SpeechText.pieces("breakfast"), [Piece(text: "breakfast")])
        XCTAssertEqual(SpeechText.pieces("look forward to"), [Piece(text: "look forward to")])
    }

    func testAPlainSentenceStaysWhole() {
        let sentence = "I usually have breakfast at seven."
        XCTAssertEqual(SpeechText.pieces(sentence), [Piece(text: sentence)])
        // Numbers, times and abbreviations are the voice's own job.
        for text in ["I set my alarm for 6:30.", "We spent 2,000 lira on the holiday.", "Dr. Kaya has thirty patients.", "We did a 500-piece puzzle."] {
            XCTAssertEqual(SpeechText.pieces(text), [Piece(text: text)], text)
        }
    }

    func testTurkishNamesGetTheirPronunciation() {
        XCTAssertEqual(SpeechText.pieces("Ayşe made breakfast for the whole family."), [
            Piece(text: "Ayşe", ipa: "ɑjʃɛ"),
            Piece(text: " made breakfast for the whole family."),
        ])
        XCTAssertEqual(SpeechText.pieces("I met Gül and Oğuz in İzmir."), [
            Piece(text: "I met "),
            Piece(text: "Gül", ipa: "ɡjul"),
            Piece(text: " and "),
            Piece(text: "Oğuz", ipa: "oʊuz"),
            Piece(text: " in "),
            Piece(text: "İzmir", ipa: "izmiɹ"),
            Piece(text: "."),
        ])
        XCTAssertEqual(SpeechText.pieces("Nazlı's flat")[0], Piece(text: "Nazlı", ipa: "nɑzlə"))
    }

    func testTheVowelÖFollowsTheAccent() {
        XCTAssertEqual(SpeechText.pieces("Kadıköy", accent: .american), [Piece(text: "Kadıköy", ipa: "kɑdəkɝj")])
        XCTAssertEqual(SpeechText.pieces("Kadıköy", accent: .british), [Piece(text: "Kadıköy", ipa: "kɑdəkɜːj")])
    }

    func testNamesWithATurkishC() {
        XCTAssertEqual(SpeechText.pieces("Cem and Ece are late."), [
            Piece(text: "Cem", ipa: "dʒɛm"),
            Piece(text: " and "),
            Piece(text: "Ece", ipa: "ɛdʒɛ"),
            Piece(text: " are late."),
        ])
    }

    /// "Can" is the name in the middle of a sentence, the verb at the start of one.
    func testCanIsANameOnlyInTheMiddleOfASentence() {
        XCTAssertEqual(SpeechText.pieces("With delivery, the total came to 320 lira, so Can paid by card."), [
            Piece(text: "With delivery, the total came to 320 lira, so "),
            Piece(text: "Can", ipa: "dʒɑn"),
            Piece(text: " paid by card."),
        ])
        XCTAssertEqual(SpeechText.pieces("Hi, Can.")[1], Piece(text: "Can", ipa: "dʒɑn"))
        for text in ["Can you help me?", "“Can I sit here?”", "Sorry. Can we talk later?", "Mehmet asked: Can I go?"] {
            XCTAssertEqual(SpeechText.pieces(text), [Piece(text: text)], text)
        }
        // Lower case is always the verb.
        let verb = "Ayşe can swim."
        XCTAssertEqual(SpeechText.pieces(verb)[1], Piece(text: " can swim."))
    }

    func testLowerCaseWordsWithTurkishLettersAreLeftAlone() {
        XCTAssertEqual(SpeechText.pieces("über"), [Piece(text: "über")])
    }

    func testScoresAndShortRangesAreSaidWithTo() {
        XCTAssertEqual(SpeechText.normalized("Our team won the match 2-1."), "Our team won the match 2 to 1.")
        XCTAssertEqual(SpeechText.normalized("It takes 3-4 days."), "It takes 3 to 4 days.")
        // Not a phone number, a long number or a chain.
        XCTAssertEqual(SpeechText.normalized("Call 555-1234."), "Call 555-1234.")
        XCTAssertEqual(SpeechText.normalized("Score 1-2-3."), "Score 1-2-3.")
        XCTAssertEqual(SpeechText.normalized("From 2020-2021."), "From 2020-2021.")
    }

    func testSpacingDotsAndDialogue() {
        XCTAssertEqual(SpeechText.normalized("  Wait...   what?  "), "Wait… what?")
        XCTAssertEqual(SpeechText.normalized("“It's 300 lira.”“OK, I'll take it.”"), "“It's 300 lira.” “OK, I'll take it.”")
        XCTAssertEqual(SpeechText.normalized("First line\nsecond line"), "First line. second line")
        XCTAssertEqual(SpeechText.normalized("Hello,\n\nworld"), "Hello, world")
        XCTAssertEqual(SpeechText.normalized(""), "")
    }

    func testPiecesRebuildTheNormalizedText() {
        let text = "“Will the bakery still be open at nine?” “I hope so, Ayşe.” Can came at 9-10."
        let rebuilt = SpeechText.pieces(text).map(\.text).joined()
        XCTAssertEqual(rebuilt, SpeechText.normalized(text))
    }
}
