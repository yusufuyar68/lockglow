import XCTest
import Pronunciation

/// The example sentence said after hearing it (shadowing): word by word, with the leniency a
/// sentence needs (contractions, words written together, numbers).
final class SentenceMatchTests: XCTestCase {
    private func check(_ text: String, heard: [String]) -> PronunciationFeedback {
        return PronunciationCheck.evaluate(
            target: PronunciationTarget(text: text),
            hypotheses: heard.map { Hypothesis(text: $0) }
        )
    }

    private func statuses(_ feedback: PronunciationFeedback) -> [WordStatus] {
        return feedback.pieces.compactMap(\.status)
    }

    // MARK: - Contractions

    func testContractionAndLongFormAreTheSame() {
        let pairs: [(target: String, heard: String)] = [
            ("I'm tired.", "I am tired"),
            ("I am tired.", "I'm tired"),
            ("Don't worry.", "do not worry"),
            ("Let's go home.", "let us go home"),
            ("I can't swim.", "I cannot swim"),
            ("I can't swim.", "I can not swim"),
            ("I won't be late.", "I will not be late"),
            ("It's 30 degrees outside today.", "it is thirty degrees outside today"),
            ("I'd like a cup of tea.", "I would like a cup of tea"),
            ("We're ready.", "we are ready"),
            ("I've seen it.", "I have seen it"),
            ("You'll love it.", "you will love it"),
            ("She didn't call me.", "she did not call me"),
            ("What's your name?", "what is your name"),
            ("They're late.", "they are late"),
            ("They're late.", "there late"),
        ]
        for pair in pairs {
            let feedback = check(pair.target, heard: [pair.heard])
            XCTAssertEqual(feedback.verdict, .correct, "target: \(pair.target), heard: \(pair.heard)")
            XCTAssertEqual(Set(statuses(feedback)), [.heard], "target: \(pair.target)")
        }
    }

    func testCurlyApostropheContraction() {
        XCTAssertEqual(check("I\u{2019}m at home.", heard: ["I am at home"]).verdict, .correct)
        XCTAssertEqual(check("I am at home.", heard: ["I\u{2019}m at home"]).verdict, .correct)
    }

    func testAnotherVerbIsNotTheContraction() {
        let feedback = check("I'm tired.", heard: ["I was tired"])
        XCTAssertNotEqual(feedback.verdict, .correct)
        XCTAssertEqual(statuses(feedback), [.different, .heard])
        XCTAssertEqual(feedback.missedWords, ["I'm"])
    }

    func testPossessiveIsNotExpanded() {
        let feedback = check("Emre's car is red.", heard: ["Emre is car is red"])
        XCTAssertNotEqual(feedback.verdict, .correct)
        XCTAssertEqual(statuses(feedback).first, .different)
    }

    // MARK: - Words written together or apart

    func testWordsWrittenTogetherInsideASentence() {
        XCTAssertEqual(check("I need a check-up.", heard: ["I need a checkup please"]).verdict, .correct)
        XCTAssertEqual(check("Our arrival time is 6 p.m.", heard: ["our arrival time is 6 PM I think"]).verdict, .correct)
        XCTAssertEqual(check("Is there free wi-fi here?", heard: ["is there free WiFi here please"]).verdict, .correct)
    }

    // MARK: - Numbers

    func testThreeDigitNumbersAreSpelledOut() {
        XCTAssertEqual(PronunciationCheck.normalize("200 lira"), "two hundred lira")
        XCTAssertEqual(PronunciationCheck.normalize("120 people"), "one hundred twenty people")
        XCTAssertEqual(PronunciationCheck.normalize("1000 people"), "1000 people")
        XCTAssertEqual(PronunciationCheck.normalize("007"), "007")
        XCTAssertEqual(
            check("These shoes were only 200 lira.", heard: ["these shoes were only two hundred lira"]).verdict,
            .correct
        )
    }

    func testPartlyHeardNumberIsDifferent() {
        let feedback = check("at 21", heard: ["at twenty"])
        XCTAssertEqual(statuses(feedback), [.heard, .different])
        XCTAssertEqual(feedback.missedWords, ["21"])
    }

    // MARK: - Word by word

    func testPiecesGiveBackTheSentenceAsWritten() {
        let sentences = [
            "Can I have a spoon, please?",
            "\u{201C}Hello!\u{201D} she said.",
            "Our team won the match 2-1.",
            "I'll call you at 6:30.",
            "It's my grandmother's house.",
        ]
        for sentence in sentences {
            let feedback = check(sentence, heard: ["something else"])
            XCTAssertEqual(feedback.pieces.map(\.text).joined(), sentence.precomposedStringWithCanonicalMapping)
        }
    }

    func testEachWordIsMarked() {
        let feedback = check("Can I have a spoon, please?", heard: ["can I have a spoon"])
        XCTAssertEqual(feedback.verdict, .almost)
        XCTAssertEqual(feedback.pieces, [
            TargetPiece(text: "Can", status: .heard), TargetPiece(text: " ", status: nil),
            TargetPiece(text: "I", status: .heard), TargetPiece(text: " ", status: nil),
            TargetPiece(text: "have", status: .heard), TargetPiece(text: " ", status: nil),
            TargetPiece(text: "a", status: .heard), TargetPiece(text: " ", status: nil),
            TargetPiece(text: "spoon", status: .heard), TargetPiece(text: ", ", status: nil),
            TargetPiece(text: "please", status: .missing), TargetPiece(text: "?", status: nil),
        ])
    }

    func testWordHeardAsAnotherIsDifferent() {
        let feedback = check("I think you are right.", heard: ["I sink you are right"])
        XCTAssertEqual(statuses(feedback), [.heard, .different, .heard, .heard, .heard])
    }

    func testCorrectSentenceIsAllHeard() {
        let feedback = check("I want a coffee.", heard: ["um I want a coffee please"])
        XCTAssertEqual(feedback.verdict, .correct)
        XCTAssertEqual(statuses(feedback), [.heard, .heard, .heard, .heard])
    }

    func testRepeatedMissedWordIsListedOnce() {
        let feedback = check("The cat and the dog.", heard: ["cat and dog"])
        XCTAssertEqual(feedback.verdict, .tryAgain)
        XCTAssertEqual(feedback.missedWords, ["The"])
        XCTAssertEqual(statuses(feedback), [.missing, .heard, .heard, .missing, .heard])
    }

    func testNothingHeardHasNoPieces() {
        XCTAssertEqual(check("I'm tired.", heard: []).pieces, [])
    }
}
