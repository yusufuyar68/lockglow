import XCTest
import CoreModels
@testable import SharedState

/// The quiz widget's files (`widget_quiz.json`, `widget_quiz_state.json`), its `quiz` event and
/// the pure rotation both sides use (`WidgetQuizRotation`).
final class WidgetQuizTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)
    private var directory: URL!

    override func setUpWithError() throws {
        directory = try makeTemporaryDirectory("WidgetQuizTests")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func item(_ id: Int, answer: Int = 0) -> WidgetQuizItem {
        return WidgetQuizItem(
            wordID: id,
            lemma: "word\(id)",
            options: ["a\(id)", "b\(id)", "c\(id)"],
            answerIndex: answer,
            shortOptions: [nil, "kısa\(id)", nil],
            optionWords: ["word\(id)", "other\(id)", nil]
        )
    }

    private func plan(_ ids: [Int], quizID: String = "q1", interval: Int = 3600) -> WidgetQuizPlan {
        return WidgetQuizPlan(quizID: quizID, intervalSeconds: interval, items: ids.map { item($0) }, updatedAt: start)
    }

    private func answered(_ wordID: Int, choice: Int, at date: Date, quizID: String = "q1") -> WidgetQuizState {
        return WidgetQuizState(quizID: quizID, wordID: wordID, answer: WidgetQuizAnswer(choice: choice, at: date), updatedAt: date)
    }

    // MARK: Files and JSON

    func testFilesRoundTripWithSnakeCaseKeys() throws {
        let store = AppGroupStore(containerURL: directory)
        XCTAssertNil(store.readQuizPlan())
        XCTAssertNil(store.readQuizState())

        let written = plan([1, 2])
        try store.writeQuizPlan(written)
        XCTAssertEqual(store.readQuizPlan(), written)
        let state = answered(2, choice: 1, at: start)
        try store.writeQuizState(state)
        XCTAssertEqual(store.readQuizState(), state)

        let planJSON = try XCTUnwrap(String(data: Data(contentsOf: store.quizPlanURL), encoding: .utf8))
        for key in ["\"quiz_id\"", "\"interval_seconds\"", "\"items\"", "\"updated_at\"", "\"word_id\"",
                    "\"answer_index\"", "\"short_options\"", "\"option_words\"", "\"options\""] {
            XCTAssertTrue(planJSON.contains(key), key)
        }
        let stateJSON = try XCTUnwrap(String(data: Data(contentsOf: store.quizStateURL), encoding: .utf8))
        XCTAssertTrue(stateJSON.contains("\"answer\":{\"at\":\"2027-01-15T08:00:00Z\",\"choice\":1}"), stateJSON)
        // The word widget's files are other files.
        XCTAssertNotEqual(store.quizPlanURL, store.planURL)
        XCTAssertNotEqual(store.quizStateURL, store.stateURL)
    }

    func testAQuestionWithoutTheOptionalFieldsDecodes() throws {
        let json = #"{"word_id":7,"lemma":"borrow","options":["izin vermek","ödünç almak"],"answer_index":1}"#
        let decoded = try JSONCoding.makeDecoder().decode(WidgetQuizItem.self, from: Data(json.utf8))
        XCTAssertEqual(decoded.options, ["izin vermek", "ödünç almak"])
        XCTAssertNil(decoded.shortOptions)
        XCTAssertNil(decoded.shortOption(at: 0))
        XCTAssertNil(decoded.optionWord(at: 1))
        XCTAssertTrue(decoded.isUsable)
        XCTAssertEqual(decoded.answer, "ödünç almak")
    }

    func testDamagedFilesReadAsMissing() throws {
        let store = AppGroupStore(containerURL: directory)
        try Data("{".utf8).write(to: store.quizPlanURL)
        try Data("[]".utf8).write(to: store.quizStateURL)
        XCTAssertNil(store.readQuizPlan())
        XCTAssertNil(store.readQuizState())
    }

    func testShortFormsAndWordsOfOptions() {
        let question = item(5)
        XCTAssertNil(question.shortOption(at: 0))
        XCTAssertEqual(question.shortOption(at: 1), "kısa5")
        XCTAssertNil(question.shortOption(at: 9))
        XCTAssertEqual(question.optionWord(at: 1), "other5")
        XCTAssertNil(question.optionWord(at: 2))
        // A short form equal to the whole option is no short form.
        var same = question
        same.shortOptions = ["a5", nil, nil]
        XCTAssertNil(same.shortOption(at: 0))
    }

    func testDamagedQuestionsAreNotAsked() {
        var noAnswer = item(1)
        noAnswer.answerIndex = 3
        var emptyOption = item(2)
        emptyOption.options[1] = "  "
        var oneOption = item(3)
        oneOption.options = ["a3"]
        var noWord = item(4)
        noWord.lemma = " "
        let quiz = WidgetQuizPlan(quizID: "q", intervalSeconds: 3600, items: [noAnswer, emptyOption, oneOption, noWord, item(5)])
        XCTAssertEqual(WidgetQuizRotation.questions(of: quiz).map { $0.wordID }, [5])
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: nil, at: start)?.item.wordID, 5)
        let empty = WidgetQuizPlan(quizID: "q", intervalSeconds: 3600, items: [noAnswer])
        XCTAssertNil(WidgetQuizRotation.screen(plan: empty, state: nil, at: start))
        XCTAssertNil(WidgetQuizRotation.screen(plan: nil, state: nil, at: start))
        XCTAssertNil(WidgetQuizRotation.stateAfterNext(wordID: 1, plan: empty, state: nil, at: start))
    }

    // MARK: The quiz event

    func testQuizEventGoesThroughTheMailbox() throws {
        let mailbox = AppGroupStore(containerURL: directory).eventMailbox
        let event = WidgetEvent(type: .quiz, wordID: 52, at: start, source: .systemLarge)
        try mailbox.append(event)
        try mailbox.append(WidgetEvent(type: .next, wordID: 1, at: start.addingTimeInterval(1), source: .systemMedium))
        let listed = try mailbox.list().map { $0.event }
        XCTAssertEqual(listed.first, event)
        XCTAssertEqual(listed.count, 2)
        let data = try JSONCoding.makeEncoder().encode(event)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(json.contains("\"type\":\"quiz\""), json)
        XCTAssertTrue(json.contains("\"source\":\"system_large\""), json)
        XCTAssertEqual(mailbox.deleteUndecodableFiles(), 0)
    }

    // MARK: Rotation

    func testWithoutAStateTheFirstQuestionWaits() {
        let quiz = plan([1, 2, 3])
        // Time alone never changes an unanswered question.
        for hours in [0.0, 1, 30, 24 * 9] {
            let screen = WidgetQuizRotation.screen(plan: quiz, state: nil, at: start.addingTimeInterval(hours * 3600))
            XCTAssertEqual(screen?.item.wordID, 1)
            XCTAssertEqual(screen?.isAnswered, false)
        }
        XCTAssertNil(WidgetQuizRotation.answerExpiry(plan: quiz, state: nil))
    }

    func testAnAnswerStaysForTheIntervalThenTheNextQuestionComes() throws {
        let quiz = plan([1, 2, 3], interval: 1800)
        let at = start.addingTimeInterval(100)
        let state = try XCTUnwrap(WidgetQuizRotation.stateAfterAnswer(wordID: 1, choice: 2, plan: quiz, state: nil, at: at))
        XCTAssertEqual(state, answered(1, choice: 2, at: at))

        let shown = try XCTUnwrap(WidgetQuizRotation.screen(plan: quiz, state: state, at: at.addingTimeInterval(1799)))
        XCTAssertEqual(shown.item.wordID, 1)
        XCTAssertEqual(shown.choice, 2)
        XCTAssertTrue(shown.isAnswered)
        XCTAssertFalse(shown.isRight)
        XCTAssertEqual(WidgetQuizRotation.answerExpiry(plan: quiz, state: state), at.addingTimeInterval(1800))

        let later = try XCTUnwrap(WidgetQuizRotation.screen(plan: quiz, state: state, at: at.addingTimeInterval(1800)))
        XCTAssertEqual(later.item.wordID, 2)
        XCTAssertNil(later.choice)
        // And it waits there.
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: state, at: at.addingTimeInterval(86_400))?.item.wordID, 2)
    }

    func testTheHoldIsNeverShorterThanFiveMinutes() {
        let quiz = plan([1, 2], interval: 0)
        XCTAssertEqual(WidgetQuizRotation.holdSeconds(of: quiz), 300)
        let state = answered(1, choice: 0, at: start)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: state, at: start.addingTimeInterval(299))?.choice, 0)
        XCTAssertNil(WidgetQuizRotation.screen(plan: quiz, state: state, at: start.addingTimeInterval(300))?.choice)
    }

    func testAClockSetBackEndsTheAnswer() {
        let quiz = plan([1, 2])
        let state = answered(1, choice: 0, at: start)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: state, at: start.addingTimeInterval(-60))?.choice, 0)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: state, at: start.addingTimeInterval(-3600))?.item.wordID, 2)
    }

    func testTheFirstAnswerStands() throws {
        let quiz = plan([1, 2])
        let first = try XCTUnwrap(WidgetQuizRotation.stateAfterAnswer(wordID: 1, choice: 0, plan: quiz, state: nil, at: start))
        // A second tap on another option, or the same one, changes nothing (and records nothing).
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, choice: 1, plan: quiz, state: first, at: start.addingTimeInterval(5)))
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, choice: 0, plan: quiz, state: first, at: start.addingTimeInterval(5)))
        // Once the answer gave way, the question that came by itself can be answered.
        let next = WidgetQuizRotation.stateAfterAnswer(wordID: 2, choice: 1, plan: quiz, state: first, at: start.addingTimeInterval(4000))
        XCTAssertEqual(next, answered(2, choice: 1, at: start.addingTimeInterval(4000)))
    }

    func testAnswersForMissingWordsOrOptionsChangeNothing() {
        let quiz = plan([1, 2])
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 9, choice: 0, plan: quiz, state: nil, at: start))
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, choice: 3, plan: quiz, state: nil, at: start))
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, choice: -1, plan: quiz, state: nil, at: start))
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, choice: 0, plan: nil, state: nil, at: start))
    }

    func testDevamMovesToTheNextQuestionAndWraps() throws {
        let quiz = plan([1, 2, 3])
        let after2 = try XCTUnwrap(WidgetQuizRotation.stateAfterNext(wordID: 2, plan: quiz, state: answered(2, choice: 0, at: start), at: start))
        XCTAssertEqual(after2, WidgetQuizState(quizID: "q1", wordID: 3, answer: nil, updatedAt: start))
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: after2, at: start)?.item.wordID, 3)
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 3, plan: quiz, state: after2, at: start)?.wordID, 1)
        // A word that is no longer asked: the question after the one the state points at.
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 99, plan: quiz, state: after2, at: start)?.wordID, 1)
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 99, plan: quiz, state: nil, at: start)?.wordID, 2)
        // One question: Devam asks it again.
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 1, plan: plan([1]), state: nil, at: start)?.wordID, 1)
    }

    func testTheWordWidgetsWordIsPassedOverUntilItMoves() {
        let quiz = plan([1, 2, 3])
        let waiting = WidgetQuizState(quizID: "q1", wordID: 2, updatedAt: start)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: waiting, at: start, avoiding: 2)?.item.wordID, 3)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: waiting, at: start, avoiding: 3)?.item.wordID, 2)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: nil, at: start, avoiding: 1)?.item.wordID, 2)
        // The last question wraps to the first.
        let last = WidgetQuizState(quizID: "q1", wordID: 3, updatedAt: start)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: last, at: start, avoiding: 3)?.item.wordID, 1)
        // One question: shown anyway.
        XCTAssertEqual(WidgetQuizRotation.screen(plan: plan([1]), state: nil, at: start, avoiding: 1)?.item.wordID, 1)
        // An answer on screen is never passed over: the meaning is already shown.
        let answer = answered(2, choice: 1, at: start)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: answer, at: start, avoiding: 2)?.item.wordID, 2)
        // After its hold the next question; passed over too when it is the word widget's word.
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: answer, at: start.addingTimeInterval(3600), avoiding: 3)?.item.wordID, 1)
    }

    func testAStateOfAnOlderFileCountsOnlyForTheFirstQuestion() {
        let newer = plan([2, 1, 3], quizID: "q2")
        // The app kept the question on screen (2) first: it and its answer stay.
        let onScreen = answered(2, choice: 1, at: start)
        let kept = WidgetQuizRotation.screen(plan: newer, state: onScreen, at: start.addingTimeInterval(60))
        XCTAssertEqual(kept?.item.wordID, 2)
        XCTAssertEqual(kept?.choice, 1)
        XCTAssertEqual(WidgetQuizRotation.answerExpiry(plan: newer, state: onScreen), start.addingTimeInterval(3600))
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 2, choice: 0, plan: newer, state: onScreen, at: start.addingTimeInterval(60)))
        // A word further down the newer file: the state is stale, the first question shows.
        let elsewhere = answered(1, choice: 0, at: start)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: newer, state: elsewhere, at: start)?.item.wordID, 2)
        XCTAssertNil(WidgetQuizRotation.screen(plan: newer, state: elsewhere, at: start)?.choice)
        XCTAssertNil(WidgetQuizRotation.answerExpiry(plan: newer, state: elsewhere))
        // In its own file the same state counts wherever the word is.
        XCTAssertEqual(WidgetQuizRotation.screen(plan: plan([2, 1, 3]), state: elsewhere, at: start)?.item.wordID, 1)
        // An answer whose option does not exist is dropped.
        let broken = answered(2, choice: 7, at: start)
        XCTAssertNil(WidgetQuizRotation.screen(plan: newer, state: broken, at: start)?.choice)
    }

    func testANewFileKeepsTheQuestionOnScreenFirst() {
        let shown = item(2, answer: 1)
        let fresh = [item(1), WidgetQuizItem(wordID: 2, lemma: "word2", options: ["x", "b2", "y"], answerIndex: 1), item(3)]
        let kept = WidgetQuizRotation.keepingShown(shown, before: fresh, askedIDs: [1, 2, 3], limit: 24)
        // The very same item (its options and their order stay), then the others without it.
        XCTAssertEqual(kept.map { $0.wordID }, [2, 1, 3])
        XCTAssertEqual(kept[0], shown)
        // No longer asked (due soon in "Tekrar", or known): not kept.
        XCTAssertEqual(WidgetQuizRotation.keepingShown(shown, before: fresh, askedIDs: [1, 3], limit: 24).map { $0.wordID }, [1, 2, 3])
        // The user changed the word's meaning: the new question about it goes first.
        let edited = [WidgetQuizItem(wordID: 2, lemma: "word2", options: ["x", "yeni", "y"], answerIndex: 1), item(1)]
        let replaced = WidgetQuizRotation.keepingShown(shown, before: edited, askedIDs: [1, 2], limit: 24)
        XCTAssertEqual(replaced.first, edited[0])
        XCTAssertEqual(replaced.count, 2)
        // The limit counts the kept question.
        XCTAssertEqual(WidgetQuizRotation.keepingShown(shown, before: fresh, askedIDs: [1, 2, 3], limit: 2).map { $0.wordID }, [2, 1])
        XCTAssertEqual(WidgetQuizRotation.keepingShown(nil, before: fresh, askedIDs: [], limit: 24).map { $0.wordID }, [1, 2, 3])
        XCTAssertEqual(WidgetQuizRotation.keepingShown(shown, before: fresh, askedIDs: [2], limit: 0), [])
    }
}
