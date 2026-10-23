import XCTest
import Pronunciation

final class SpellingVariantsTests: XCTestCase {
    private func check(_ text: String, heard: String) -> PronunciationFeedback.Verdict {
        return PronunciationCheck.evaluate(target: PronunciationTarget(text: text), hypotheses: [Hypothesis(text: heard)]).verdict
    }

    /// The British recognizer (accent İngiltere) writes British spellings of the cards' words.
    func testBritishSpellingsOfAmericanCardsAreCorrect() {
        XCTAssertEqual(check("neighbor", heard: "neighbour"), .correct)
        XCTAssertEqual(check("pajamas", heard: "pyjamas"), .correct)
        XCTAssertEqual(check("recognize", heard: "recognise"), .correct)
        XCTAssertEqual(check("My favorite color is gray.", heard: "my favourite colour is grey"), .correct)
        XCTAssertEqual(check("The flight was canceled.", heard: "the flight was cancelled"), .correct)
        XCTAssertEqual(check("We met at the theater in the city center.", heard: "we met at the theatre in the city centre"), .correct)
        XCTAssertEqual(check("She traveled for two kilometers.", heard: "she travelled for two kilometres"), .correct)
    }

    /// The American recognizer writes the American spelling of the few British-spelled cards.
    func testAmericanSpellingsOfBritishCardsAreCorrect() {
        XCTAssertEqual(check("apologise", heard: "apologize"), .correct)
        XCTAssertEqual(check("my favourite organisation", heard: "my favorite organization"), .correct)
        XCTAssertEqual(check("cheque", heard: "check"), .correct)
    }

    /// Different words stay different.
    func testOtherWordsAreNotMerged() {
        XCTAssertEqual(SpellingVariants.americanSpelling("exercise"), "exercise")
        XCTAssertEqual(SpellingVariants.americanSpelling("surprise"), "surprise")
        XCTAssertEqual(SpellingVariants.americanSpelling("hour"), "hour")
        XCTAssertEqual(SpellingVariants.americanSpelling("four"), "four")
        XCTAssertEqual(SpellingVariants.americanSpelling("mum"), "mum")
        XCTAssertEqual(SpellingVariants.americanSpelling("acre"), "acre")
        XCTAssertEqual(SpellingVariants.americanSpelling("cancellation"), "cancellation")
    }

    func testGeneratedForms() {
        XCTAssertEqual(SpellingVariants.americanSpelling("neighbourhood"), "neighborhood")
        XCTAssertEqual(SpellingVariants.americanSpelling("colourful"), "colorful")
        XCTAssertEqual(SpellingVariants.americanSpelling("behavioural"), "behavioral")
        XCTAssertEqual(SpellingVariants.americanSpelling("realised"), "realized")
        XCTAssertEqual(SpellingVariants.americanSpelling("organisation"), "organization")
        XCTAssertEqual(SpellingVariants.americanSpelling("analysed"), "analyzed")
        XCTAssertEqual(SpellingVariants.americanSpelling("traveller"), "traveler")
        XCTAssertEqual(SpellingVariants.americanSpelling("marvellous"), "marvelous")
        XCTAssertEqual(SpellingVariants.americanSpelling("counsellor"), "counselor")
        XCTAssertEqual(SpellingVariants.americanSpelling("centred"), "centered")
        XCTAssertEqual(SpellingVariants.americanSpelling("manoeuvre"), "maneuver")
        XCTAssertEqual(SpellingVariants.americanSpelling("savoury"), "savory")
    }

    func testKeysAreLowercaseAndMapToAnotherSpelling() {
        for (british, american) in SpellingVariants.american {
            XCTAssertEqual(british, british.lowercased())
            XCTAssertEqual(american, american.lowercased())
            XCTAssertNotEqual(british, american)
            // One step: an American spelling is never itself a British key.
            XCTAssertNil(SpellingVariants.american[american], "\(british) → \(american) → \(SpellingVariants.american[american] ?? "")")
        }
    }
}
