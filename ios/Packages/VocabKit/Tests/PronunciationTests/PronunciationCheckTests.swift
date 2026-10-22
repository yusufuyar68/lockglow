import XCTest
import Pronunciation

final class PronunciationCheckTests: XCTestCase {
    private func check(_ text: String, ipa: String? = nil, heard: [String]) -> PronunciationFeedback {
        return PronunciationCheck.evaluate(
            target: PronunciationTarget(text: text, ipa: ipa),
            hypotheses: heard.map { Hypothesis(text: $0) }
        )
    }

    // MARK: - Normalization

    func testNormalizeDropsCasePunctuationAndAccents() {
        let vectors: [(input: String, expected: String)] = [
            ("Can I have a spoon, please?", "can i have a spoon please"),
            ("  Turn ON. ", "turn on"),
            ("\u{201C}Hello!\u{201D} she said.", "hello she said"),
            ("Ay\u{015F}e\u{2019}s caf\u{00E9}", "ayses cafe"),
            ("Ca\u{0301}fe\u{0301}", "cafe"),
            ("", ""),
            ("?!", ""),
        ]
        for vector in vectors {
            XCTAssertEqual(PronunciationCheck.normalize(vector.input), vector.expected, "input: \(vector.input)")
        }
    }

    func testNormalizeApostrophesAndHyphens() {
        XCTAssertEqual(PronunciationCheck.normalize("o'clock"), "oclock")
        XCTAssertEqual(PronunciationCheck.normalize("o\u{2019}clock"), "oclock")
        XCTAssertEqual(PronunciationCheck.normalize("second-hand"), "second hand")
    }

    func testNormalizeSpellsOutSmallNumbers() {
        XCTAssertEqual(PronunciationCheck.normalize("The train leaves from platform 4."), "the train leaves from platform four")
        XCTAssertEqual(PronunciationCheck.normalize("at 7:30"), "at seven thirty")
        XCTAssertEqual(PronunciationCheck.normalize("21 days"), "twenty one days")
        XCTAssertEqual(PronunciationCheck.normalize("100 people"), "100 people")
    }

    // MARK: - Correct

    func testExactWordIsCorrect() {
        let feedback = check("think", ipa: "/θɪŋk/", heard: ["Think."])
        XCTAssertEqual(feedback.verdict, .correct)
        XCTAssertNil(feedback.tip)
        XCTAssertEqual(feedback.heard, "Think.")
        XCTAssertEqual(feedback.title, "Anlaşıldı!")
        XCTAssertEqual(feedback.message, "Telefon seni anladı.")
    }

    func testCompoundsMatchWrittenTogetherOrApart() {
        XCTAssertEqual(check("second-hand", heard: ["secondhand"]).verdict, .correct)
        XCTAssertEqual(check("log in", heard: ["login"]).verdict, .correct)
        XCTAssertEqual(check("o'clock", heard: ["o clock"]).verdict, .correct)
    }

    func testHomophonesAndNumberWordsMatch() {
        XCTAssertEqual(check("write down", heard: ["Right down"]).verdict, .correct)
        XCTAssertEqual(check("platform 4", heard: ["platform for"]).verdict, .correct)
        XCTAssertEqual(
            check("The train to Ankara leaves from platform 4.", heard: ["the train to Ankara leaves from platform four"]).verdict,
            .correct
        )
    }

    func testExtraWordsAroundTheTargetAreAllowed() {
        XCTAssertEqual(check("spoon", heard: ["a spoon"]).verdict, .correct)
    }

    func testHighConfidenceMatchIsCorrect() {
        let feedback = PronunciationCheck.evaluate(
            target: PronunciationTarget(text: "spoon"),
            hypotheses: [Hypothesis(text: "spoon", confidence: 0.9)]
        )
        XCTAssertEqual(feedback.verdict, .correct)
    }

    // MARK: - Almost

    func testLowConfidenceMatchIsAlmost() {
        let feedback = PronunciationCheck.evaluate(
            target: PronunciationTarget(text: "spoon"),
            hypotheses: [Hypothesis(text: "spoon", confidence: 0.3)]
        )
        XCTAssertEqual(feedback.verdict, .almost)
        XCTAssertEqual(feedback.missedWords, [])
        XCTAssertEqual(feedback.message, "Anlaşıldı ama tam net değildi. Bir kez daha söyle.")
    }

    func testTargetOnlyInAnAlternativeIsAlmost() {
        let feedback = check("think", ipa: "/θɪŋk/", heard: ["sink", "think"])
        XCTAssertEqual(feedback.verdict, .almost)
        XCTAssertNil(feedback.tip)
    }

    func testSentenceWithOneWordMissingIsAlmost() {
        let feedback = check("Can I have a spoon, please?", heard: ["can I have a spoon"])
        XCTAssertEqual(feedback.verdict, .almost)
        XCTAssertEqual(feedback.missedWords, ["please"])
        XCTAssertEqual(feedback.message, "Şunlar duyulmadı: please. Bir daha dene.")
        XCTAssertEqual(feedback.messageRuns, [.turkish("Şunlar duyulmadı: "), .english("please"), .turkish(". Bir daha dene.")])
    }

    func testSentenceAlmostKeepsTheTip() {
        let feedback = check("I think you are right.", heard: ["I sink you are right"])
        XCTAssertEqual(feedback.verdict, .almost)
        XCTAssertEqual(feedback.tip?.kind, .th)
        XCTAssertEqual(feedback.missedWords, ["think"])
        XCTAssertEqual(feedback.message, "Şunlar duyulmadı: think. Bir daha dene.")
    }

    func testOneWordOfAPhraseMissingIsAlmost() {
        let vectors: [(target: String, heard: String, missed: String)] = [
            ("get up", "get", "up"),
            ("run out of", "run out", "of"),
            ("look forward to", "forward to", "look"),
            ("get along with", "get along", "with"),
        ]
        for vector in vectors {
            let feedback = check(vector.target, heard: [vector.heard])
            XCTAssertEqual(feedback.verdict, .almost, "target: \(vector.target)")
            XCTAssertEqual(feedback.missedWords, [vector.missed], "target: \(vector.target)")
        }
        XCTAssertEqual(check("get up", heard: ["get"]).message, "Şunlar duyulmadı: up. Bir daha dene.")
    }

    func testWrongParticleIsTryAgain() {
        let pairs: [(target: String, heard: String)] = [
            ("turn on", "turn off"), ("get in", "get on"), ("put on", "put off"), ("take off", "take out"),
            ("check in", "check out"), ("look for", "look after"), ("go out", "go on"),
            ("get along with", "get on with"),
        ]
        for pair in pairs {
            XCTAssertEqual(check(pair.target, heard: [pair.heard]).verdict, .tryAgain, "target: \(pair.target)")
        }
    }

    func testDeckHomophonesAreCorrect() {
        XCTAssertEqual(check("do", heard: ["due"]).verdict, .correct)
        XCTAssertEqual(check("bored", heard: ["board"]).verdict, .correct)
        XCTAssertEqual(check("need", heard: ["knead"]).verdict, .correct)
        XCTAssertEqual(check("bag", heard: ["bug"]).verdict, .tryAgain)
    }

    func testHomophoneGroupsAreLowercaseAndDisjoint() {
        var seen = Set<String>()
        for group in PronunciationCheck.homophoneGroups {
            XCTAssertGreaterThanOrEqual(group.count, 2)
            for word in group {
                XCTAssertEqual(word, word.lowercased())
                XCTAssertTrue(seen.insert(word).inserted, "in two groups: \(word)")
            }
        }
    }

    // MARK: - Tips

    func testThSaidAsAnotherSound() {
        let think = check("think", ipa: "/θɪŋk/", heard: ["sink"])
        XCTAssertEqual(think.verdict, .tryAgain)
        XCTAssertEqual(think.tip?.kind, .th)
        XCTAssertEqual(think.tip?.expected, "think")
        XCTAssertEqual(think.tip?.heard, "sink")
        XCTAssertEqual(think.message, "Telefon farklı bir şey anladı.")
        XCTAssertTrue(think.tip?.advice.hasPrefix("'th' sesine dikkat") ?? false)

        XCTAssertEqual(check("three", ipa: "/θriː/", heard: ["tree"]).tip?.kind, .th)
    }

    func testThTipComparesEverythingHeardRunTogether() {
        let feedback = check("birthday", ipa: "/ˈbɜːrθdeɪ/", heard: ["bird day"])
        XCTAssertEqual(feedback.tip?.kind, .th)
        XCTAssertEqual(feedback.tip?.heard, "bird day")
    }

    func testThTipFindsTheWordHeardInPlaceOfTheTarget() {
        let feedback = check("think", ipa: "/θɪŋk/", heard: ["I sink"])
        XCTAssertEqual(feedback.verdict, .tryAgain)
        XCTAssertEqual(feedback.tip?.kind, .th)
        XCTAssertEqual(feedback.tip?.heard, "sink")
    }

    func testNoThTipWhenTheIPAHasNoThSound() {
        XCTAssertNil(check("Thomas", ipa: "/ˈtɑːməs/", heard: ["Tomas"]).tip)
    }

    func testWAndVSwapped() {
        let wine = check("wine", ipa: "/waɪn/", heard: ["vine"])
        XCTAssertEqual(wine.tip?.kind, .wv)
        XCTAssertTrue(wine.tip?.advice.hasPrefix("'w' sesine") ?? false)

        let vest = check("vest", ipa: "/vɛst/", heard: ["west"])
        XCTAssertEqual(vest.tip?.kind, .wv)
        XCTAssertTrue(vest.tip?.advice.hasPrefix("'v' sesine") ?? false)
    }

    func testNoWVTipForASilentW() {
        XCTAssertNil(check("write", ipa: "/raɪt/", heard: ["vrite"]).tip)
    }

    func testVoicedFinalSoundMadeVoiceless() {
        let bad = check("bad", ipa: "/bæd/", heard: ["bat"])
        XCTAssertEqual(bad.tip?.kind, .finalVoicing)
        XCTAssertEqual(bad.tip?.advice, "Son sese dikkat: sondaki 'd' sesini 't' gibi sertleştirme.")

        XCTAssertEqual(check("dog", ipa: "/dɔːɡ/", heard: ["dock"]).tip?.advice, "Son sese dikkat: sondaki 'g' sesini 'k' gibi sertleştirme.")
        XCTAssertEqual(check("bridge", ipa: "/brɪdʒ/", heard: ["britch"]).tip?.advice, "Son sese dikkat: sondaki 'c' sesini 'ç' gibi sertleştirme.")
        XCTAssertEqual(check("rise", ipa: "/raɪz/", heard: ["rice"]).tip?.advice, "Son sese dikkat: sondaki 'z' sesini 's' gibi sertleştirme.")
    }

    func testNoVoicingTipWhenTheFinalSoundIsAlreadyVoiceless() {
        XCTAssertNil(check("bus", ipa: "/bʌs/", heard: ["buss"]).tip)
    }

    func testFinalSoundDropped() {
        XCTAssertEqual(check("asked", ipa: "/æskt/", heard: ["ask"]).tip?.kind, .finalDropped)
        XCTAssertEqual(check("card", ipa: "/kɑːrd/", heard: ["car"]).tip?.kind, .finalDropped)
        XCTAssertNil(check("cloudy", ipa: "/ˈklaʊdi/", heard: ["cloud"]).tip)
    }

    func testUnrelatedWordGetsGeneralFeedback() {
        let feedback = check("breakfast", ipa: "/ˈbrɛkfəst/", heard: ["bread"])
        XCTAssertEqual(feedback.verdict, .tryAgain)
        XCTAssertNil(feedback.tip)
        XCTAssertEqual(feedback.title, "Bir daha dene")
        XCTAssertEqual(feedback.message, "Telefon farklı bir şey anladı. Önce Dinle'ye dokunup dinle, sonra yavaş ve net söyle.")
    }

    func testSentenceTipUsesSpellingWithoutIPA() {
        let feedback = check("I think so.", heard: ["I sink so"])
        XCTAssertEqual(feedback.verdict, .tryAgain)
        XCTAssertEqual(feedback.tip?.kind, .th)
        XCTAssertEqual(feedback.missedWords, ["think"])
    }

    func testTwoDifferentPatternsGiveNoTip() {
        let feedback = check("I think it is bad", heard: ["I sink it is bat"])
        XCTAssertEqual(feedback.verdict, .tryAgain)
        XCTAssertNil(feedback.tip)
        XCTAssertEqual(feedback.missedWords, ["think", "bad"])
    }

    func testMissedNumberIsListedOnceAsWritten() {
        let feedback = check("at 21", heard: ["at"])
        XCTAssertEqual(feedback.verdict, .tryAgain)
        XCTAssertEqual(feedback.missedWords, ["21"])
    }

    // MARK: - Wording

    /// Ilkeler 2.7 and terimler §1: the phone is the one that hears ("Anlaşıldı!", never "Doğru!"),
    /// no "duydum", the button is "Dinle", and only the two state titles end in "!". English words
    /// in the line are English runs (read in an English voice).
    func testLinesSayWhatThePhoneUnderstood() {
        let results = [
            check("think", heard: ["think"]),
            PronunciationCheck.evaluate(target: PronunciationTarget(text: "spoon"), hypotheses: [Hypothesis(text: "spoon", confidence: 0.3)]),
            check("get up", heard: ["get"]),
            check("I think you are right.", heard: ["I sink you are right"]),
            check("think", ipa: "/θɪŋk/", heard: ["sink"]),
            check("breakfast", heard: ["bread"]),
            check("think", heard: []),
        ]
        XCTAssertEqual(Set(results.map(\.verdict)), [.correct, .almost, .tryAgain, .notHeard])
        for feedback in results {
            let line = feedback.message
            XCTAssertFalse(line.contains("Doğru"), line)
            XCTAssertFalse(line.contains("duydum"), line)
            XCTAssertFalse(line.contains("hoparlör"), line)
            XCTAssertFalse(line.contains("!"), line)
            XCTAssertFalse(line.contains("..."), line)
            XCTAssertNotEqual(feedback.title, "Doğru!")
            XCTAssertEqual(feedback.title.hasSuffix("!"), feedback.verdict == .correct || feedback.verdict == .almost, feedback.title)
            for run in feedback.messageRuns {
                if case .english(let words) = run {
                    XCTAssertEqual(words, feedback.missedWords.joined(separator: ", "))
                }
            }
        }
    }

    // MARK: - Nothing heard

    func testNothingHeard() {
        XCTAssertEqual(check("think", heard: []).verdict, .notHeard)
        let blank = check("think", heard: ["", " . "])
        XCTAssertEqual(blank.verdict, .notHeard)
        XCTAssertEqual(blank.heard, "")
        XCTAssertEqual(blank.title, "Seni duyamadım")
        XCTAssertEqual(blank.message, "Mikrofona yakın, net bir sesle söyle.")
    }

    func testEmptyTargetIsNotHeard() {
        XCTAssertEqual(check("", heard: ["hello"]).verdict, .notHeard)
    }
}
