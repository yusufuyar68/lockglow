import XCTest
import CoreModels
import SharedState

final class WidgetSpeechRequestTests: XCTestCase {
    private func word(_ id: Int, _ lemma: String, sensitivity: Int? = nil) -> WidgetWord {
        return WidgetWord(
            id: id, lemma: lemma, pos: "n", level: "A1",
            defMicro: "m", defShort: "s", exampleEN: "e", sensitivity: sensitivity
        )
    }

    private func quiz(version: Int = 2) -> WidgetQuizPlan {
        return WidgetQuizPlan(
            version: version, quizID: "speech",
            items: [WidgetQuizItem(
                wordID: 52, lemma: "borrow", options: ["izin vermek", "ödünç almak"], answerIndex: 1
            )],
            updatedAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
    }

    func testCurrentPlanAndSeedResolveOnlyNonSensitiveSourceLemmas() throws {
        let plan = [
            word(1, "breakfast"),
            word(2, "personal1", sensitivity: 1),
            word(3, "personal2", sensitivity: 2),
        ]
        let seed = [
            word(4, "borrow", sensitivity: 0),
            word(5, "personal1", sensitivity: 1),
            word(6, "personal2", sensitivity: 2),
        ]
        for source in [(lemma: "breakfast", words: plan), (lemma: "borrow", words: seed)] {
            XCTAssertEqual(WidgetSpeechRequest.resolve(source.lemma, words: source.words), source.lemma)
            XCTAssertNil(WidgetSpeechRequest.resolve("personal1", words: source.words))
            XCTAssertNil(WidgetSpeechRequest.resolve("personal2", words: source.words))
        }
        XCTAssertEqual(
            WidgetSpeechRequest.resolve(WidgetWord.sample.lemma, words: [WidgetWord.sample]),
            WidgetWord.sample.lemma
        )

        // Equal Unicode spellings can have different bytes: return the trusted source's bytes.
        let source = word(7, "café")
        let request = "cafe\u{301}"
        let spoken = try XCTUnwrap(WidgetSpeechRequest.resolve(request, words: [source]))
        XCTAssertEqual(Array(spoken.utf8), Array(source.lemma.utf8))
        XCTAssertNotEqual(Array(spoken.utf8), Array(request.utf8))
    }

    func testEmptyAndUnresolvedRequestsAreRejected() {
        for request in ["", " ", "\t", "missing", "BREAKFAST"] {
            XCTAssertNil(WidgetSpeechRequest.resolve(request, words: [word(1, "breakfast")]))
        }
        XCTAssertNil(WidgetSpeechRequest.resolve("breakfast", words: []))
    }

    func testCurrentQuizAuthorizesSpeechButLegacyAndFuturePlansDoNot() {
        XCTAssertEqual(WidgetSpeechRequest.resolve("borrow", words: [], quizPlan: quiz()), "borrow")
        for version in [1, 999] {
            XCTAssertNil(WidgetSpeechRequest.resolve("borrow", words: [], quizPlan: quiz(version: version)))
        }
    }

    func testUnusableQuizQuestionCannotAuthorizeSpeech() {
        var plan = quiz()
        plan.items[0].options[0] = " "
        XCTAssertNil(WidgetSpeechRequest.resolve("borrow", words: [], quizPlan: plan))
        plan.items = []
        XCTAssertNil(WidgetSpeechRequest.resolve("borrow", words: [], quizPlan: plan))
    }

    func testExtraTextAndNewlinesCannotBypassAValidSourceLemma() {
        let words = [word(1, "breakfast"), word(2, "breakfast\nextra")]
        for request in [
            " breakfast", "breakfast ", "breakfast extra", "breakfast\n",
            "breakfast\r\n", "breakfast\nextra", "breakfast\t",
            "borrow extra", "borrow\n", "borrow\nextra",
        ] {
            XCTAssertNil(WidgetSpeechRequest.resolve(request, words: words, quizPlan: quiz()))
        }
    }
}
