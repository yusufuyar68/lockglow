import XCTest
import Learning

/// "Kendi cümleni yaz": the fixed rules (`OwnSentenceCheck`) and the clean-up of the on-device
/// model's suggestion (`OwnSentenceAdvice`).
final class OwnSentenceCheckTests: XCTestCase {
    private func issues(_ sentence: String, _ lemma: String) -> [OwnSentenceFeedback.Issue] {
        return OwnSentenceCheck.check(sentence, lemma: lemma).issues
    }

    // MARK: The rules

    /// The UI test's first sentence: the word is there, the capital letter and the end mark are not.
    func testLowercaseStartAndNoEndMark() {
        let feedback = OwnSentenceCheck.check("i forgot my umbrella at home", lemma: "umbrella")
        XCTAssertEqual(feedback.issues, [.noCapital, .noEndPunctuation])
        XCTAssertEqual(feedback.verdict, .caution)
        XCTAssertEqual(feedback.title, "Birkaç not var")
    }

    func testGoodSentence() {
        let feedback = OwnSentenceCheck.check("I forgot my umbrella at home.", lemma: "umbrella")
        XCTAssertEqual(feedback.issues, [])
        XCTAssertEqual(feedback.verdict, .good)
        XCTAssertEqual(feedback.title, "Kelimeyi kullandın")
        XCTAssertEqual(OwnSentenceCheck.check("Where is my umbrella?", lemma: "umbrella").issues, [])
        XCTAssertEqual(OwnSentenceCheck.check("Take your umbrella!", lemma: "umbrella").issues, [])
    }

    func testOneNoteHasItsOwnTitle() {
        let feedback = OwnSentenceCheck.check("I forgot my umbrella at home", lemma: "umbrella")
        XCTAssertEqual(feedback.issues, [.noEndPunctuation])
        XCTAssertEqual(feedback.title, "Bir not var")
    }

    func testEmptyIsTheOnlyNote() {
        XCTAssertEqual(issues("", "umbrella"), [.empty])
        XCTAssertEqual(OwnSentenceCheck.check("", lemma: "umbrella").message, "Yazınca Kontrol et'e dokun.")
        XCTAssertEqual(issues("  \n\t ", "umbrella"), [.empty])
        XCTAssertEqual(issues("?!.", "umbrella"), [.empty])
    }

    /// A word or two is not a sentence yet: no notes on its capital letter or end mark.
    func testTooShortLeavesOutTheFormNotes() {
        XCTAssertEqual(issues("umbrella", "umbrella"), [.tooShort])
        XCTAssertEqual(issues("my umbrella", "umbrella"), [.tooShort])
        XCTAssertEqual(issues("my coat", "umbrella"), [.tooShort, .missingWord])
    }

    func testMissingWord() {
        XCTAssertEqual(issues("I bought a new coat.", "umbrella"), [.missingWord])
    }

    func testNotesKeepTheirOrder() {
        XCTAssertEqual(issues("şu", "umbrella"), [.tooShort, .missingWord, .turkishLetters])
        XCTAssertEqual(issues("ben şemsiyemi evde unuttum", "umbrella"), [.missingWord, .turkishLetters, .noCapital, .noEndPunctuation])
        XCTAssertEqual(issues("Ben şemsiyemi evde unuttum.", "umbrella"), [.missingWord, .turkishLetters])
    }

    /// Endings and phrases, as on the cards (`LemmaMatch`).
    func testInflectedFormsAndPhrases() {
        XCTAssertEqual(issues("She borrowed my pen yesterday.", "borrow"), [])
        XCTAssertEqual(issues("I'm looking forward to the trip.", "look forward to"), [])
        XCTAssertEqual(issues("I'm fed up with this rain.", "be fed up with"), [])
        XCTAssertEqual(issues("They are good at chess.", "be good at"), [])
    }

    /// Irregular forms (`TextHarvest.irregularForms`), also as the first word of a phrase.
    func testIrregularForms() {
        XCTAssertEqual(issues("I forgot my keys again.", "forget"), [])
        XCTAssertEqual(issues("The baby has two teeth now.", "tooth"), [])
        XCTAssertEqual(issues("She gave up smoking last year.", "give up"), [])
        XCTAssertEqual(issues("The car broke down on the road.", "break down"), [])
    }

    /// A phrasal verb split by its object: "ask her out", "pick it up".
    func testSplitPhrase() {
        XCTAssertEqual(issues("He asked her out last week.", "ask out"), [])
        XCTAssertEqual(issues("Can you pick it up for me?", "pick up"), [])
        // Too far apart is not the phrase.
        XCTAssertEqual(issues("Ask the man in the shop about it, then go out.", "ask out"), [.missingWord])
    }

    /// The keyboard's smart punctuation: curly apostrophes and quotes.
    /// The cards' stand-ins: "your", "yourself", "someone" take the words the learner uses.
    func testStandInWords() {
        XCTAssertEqual(issues("I changed my mind.", "change your mind"), [])
        XCTAssertEqual(issues("He lost his temper.", "lose your temper"), [])
        XCTAssertEqual(issues("She gave me a hand.", "give someone a hand"), [])
        XCTAssertEqual(issues("I locked myself out.", "lock yourself out"), [])
        XCTAssertEqual(issues("She gave my little brother a hand.", "give someone a hand"), [])
        // Only inside a phrase: a stand-in alone is still a word of its own.
        XCTAssertEqual(issues("I bought a new coat.", "something"), [.missingWord])
        XCTAssertEqual(issues("I changed my plans.", "change your mind"), [.missingWord])
    }

    func testTypographicMarks() {
        XCTAssertEqual(issues("I can’t wait to see you!", "I can't wait"), [])
        XCTAssertEqual(issues("He said, “Take your umbrella.”", "umbrella"), [])
        XCTAssertEqual(issues("He said, \"Take your umbrella.\"", "umbrella"), [])
    }

    func testStartsAfterQuoteOrNumber() {
        XCTAssertEqual(issues("\"My umbrella is red,\" she said.", "umbrella"), [])
        XCTAssertEqual(issues("2 umbrellas are in the car.", "umbrella"), [])
    }

    func testLengthLimit() {
        let long = String(repeating: "a", count: 250)
        XCTAssertEqual(OwnSentenceCheck.limited(long).count, OwnSentenceCheck.maxLength)
        XCTAssertEqual(OwnSentenceCheck.limited("Short."), "Short.")
        // Only the first `maxLength` characters are read: the word after them is not found.
        let sentence = "I " + String(repeating: "x", count: 210) + " umbrella."
        XCTAssertTrue(issues(sentence, "umbrella").contains(.missingWord))
    }

    func testEveryNoteHasShortTurkishText() {
        for issue in OwnSentenceFeedback.Issue.allCases {
            XCTAssertFalse(issue.title.isEmpty)
            XCTAssertFalse(issue.message.isEmpty)
            XCTAssertLessThanOrEqual(issue.title.count, 30, issue.rawValue)
            XCTAssertLessThanOrEqual(issue.message.count, 80, issue.rawValue)
            XCTAssertFalse(issue.message.contains("…"), issue.rawValue)
        }
        XCTAssertEqual(Set(OwnSentenceFeedback.Issue.allCases.map(\.title)).count, OwnSentenceFeedback.Issue.allCases.count)
    }

    // MARK: The model's suggestion

    func testEveryKindHasItsOwnTurkishText() {
        let kinds = OwnSentenceAdvice.Kind.allCases
        XCTAssertEqual(kinds.count, 6)
        XCTAssertEqual(Set(kinds.map(OwnSentenceAdvice.title(for:))).count, kinds.count)
        for kind in kinds {
            XCTAssertFalse(OwnSentenceAdvice.message(for: kind).isEmpty)
            XCTAssertLessThanOrEqual(OwnSentenceAdvice.message(for: kind).count, 90, kind.rawValue)
        }
        XCTAssertEqual(OwnSentenceAdvice.title(for: .wordMeaning), "Anlam farklı olabilir")
        let advice = OwnSentenceAdvice(kind: .grammar, correctedSentence: nil, naturalAlternative: nil, original: "x", lemma: "umbrella")
        XCTAssertEqual(advice.title, OwnSentenceAdvice.title(for: .grammar))
        XCTAssertEqual(advice.message, OwnSentenceAdvice.message(for: .grammar))
    }

    /// A "correction" that only fixes the capital letter or the end mark is dropped: the rules
    /// already say that.
    func testCorrectionThatOnlyChangesCaseOrPunctuationIsDropped() {
        let advice = OwnSentenceAdvice(
            kind: .grammar,
            correctedSentence: "I forgot my umbrella at home.",
            naturalAlternative: "i forgot my umbrella at home",
            original: "i forgot my umbrella at home",
            lemma: "umbrella"
        )
        XCTAssertNil(advice.correctedSentence)
        XCTAssertNil(advice.naturalAlternative)
        // A mistake note with nothing to look at becomes "fine".
        XCTAssertEqual(advice.kind, .fine)
        let meaning = OwnSentenceAdvice(
            kind: .wordMeaning,
            correctedSentence: "I forgot my umbrella at home.",
            naturalAlternative: nil,
            original: "i forgot my umbrella at home",
            lemma: "umbrella"
        )
        XCTAssertEqual(meaning.kind, .wordMeaning)
    }

    /// A suggestion without the learner's word is not their sentence any more.
    func testSuggestionWithoutTheWordIsDropped() {
        let advice = OwnSentenceAdvice(
            kind: .grammar,
            correctedSentence: "The sentence is correct.",
            naturalAlternative: "I forgot my coat at home.",
            original: "I forget my umbrella at home.",
            lemma: "umbrella"
        )
        XCTAssertNil(advice.correctedSentence)
        XCTAssertNil(advice.naturalAlternative)
        XCTAssertEqual(advice.kind, .grammar)
        let phrase = OwnSentenceAdvice(
            kind: .wordForm,
            correctedSentence: "He changed his mind yesterday.",
            naturalAlternative: nil,
            original: "He change his mind yesterday.",
            lemma: "change your mind"
        )
        XCTAssertEqual(phrase.correctedSentence, "He changed his mind yesterday.")
    }

    func testRealCorrectionIsKept() {
        let advice = OwnSentenceAdvice(
            kind: .wordForm,
            correctedSentence: "  I forgot my umbrella yesterday. ",
            naturalAlternative: "I left my umbrella at home yesterday.",
            original: "I forget my umbrella yesterday.",
            lemma: "umbrella"
        )
        XCTAssertEqual(advice.correctedSentence, "I forgot my umbrella yesterday.")
        XCTAssertEqual(advice.naturalAlternative, "I left my umbrella at home yesterday.")
    }

    func testFineKeepsNoCorrection() {
        let advice = OwnSentenceAdvice(
            kind: .fine,
            correctedSentence: "I forgot the umbrella at home.",
            naturalAlternative: "I left my umbrella at home.",
            original: "I forgot my umbrella at home.",
            lemma: "umbrella"
        )
        XCTAssertNil(advice.correctedSentence)
        XCTAssertEqual(advice.naturalAlternative, "I left my umbrella at home.")
    }

    func testAlternativeThatRepeatsTheCorrectionIsDropped() {
        let advice = OwnSentenceAdvice(
            kind: .grammar,
            correctedSentence: "She goes to school.",
            naturalAlternative: "she goes to school",
            original: "She go to school.",
            lemma: "go"
        )
        XCTAssertEqual(advice.correctedSentence, "She goes to school.")
        XCTAssertNil(advice.naturalAlternative)
    }

    func testNonEnglishOrJunkIsDropped() {
        func corrected(_ text: String?) -> String? {
            return OwnSentenceAdvice(kind: .grammar, correctedSentence: text, naturalAlternative: nil, original: "She go to school.", lemma: "go").correctedSentence
        }
        XCTAssertNil(corrected(nil))
        XCTAssertNil(corrected(""))
        XCTAssertNil(corrected("   "))
        XCTAssertNil(corrected("Şemsiyemi evde unuttum."))
        XCTAssertNil(corrected("I forgot my 雨伞."))
        XCTAssertNil(corrected("None"))
        XCTAssertNil(corrected("N/A"))
        XCTAssertNil(corrected("Umbrella."))
        XCTAssertNil(corrected("She goes\u{0007} to school."))
        XCTAssertNil(corrected(String(repeating: "word ", count: 50)))
    }

    func testTypographicMarksAndOuterQuotesArePlain() {
        let advice = OwnSentenceAdvice(
            kind: .spelling,
            correctedSentence: "“I can’t find it — sorry…”",
            naturalAlternative: "'I can't find it.'",
            original: "I cant fnd it.",
            lemma: "find"
        )
        XCTAssertEqual(advice.correctedSentence, "I can't find it - sorry...")
        XCTAssertEqual(advice.naturalAlternative, "I can't find it.")
    }
}
