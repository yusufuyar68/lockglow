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

    private func item(_ id: Int, answer: Int = 0, askUntil: Date? = nil) -> WidgetQuizItem {
        return WidgetQuizItem(
            wordID: id,
            lemma: "word\(id)",
            options: ["a\(id)", "b\(id)", "c\(id)"],
            answerIndex: answer,
            shortOptions: [nil, "kısa\(id)", nil],
            optionWords: ["word\(id)", "other\(id)", nil],
            askUntil: askUntil
        )
    }

    private func plan(_ ids: [Int], quizID: String = "q1") -> WidgetQuizPlan {
        return WidgetQuizPlan(quizID: quizID, items: ids.map { item($0) }, updatedAt: start)
    }

    private func waiting(_ wordID: Int?, quizID: String = "q1") -> WidgetQuizState {
        return WidgetQuizState(quizID: quizID, wordID: wordID, updatedAt: start)
    }

    private func answered(_ wordID: Int, choice: Int, at date: Date? = nil, quizID: String = "q1") -> WidgetQuizState {
        let at = date ?? start
        return WidgetQuizState(quizID: quizID, wordID: wordID, answer: WidgetQuizAnswer(choice: choice, at: at), updatedAt: at)
    }

    // MARK: Files and JSON

    /// A real old-format payload with a still-usable question and a future ask limit. Rejection
    /// must come from the plan version, not a malformed item, an expired date or a skipped word.
    private func legacyPlanData(version: Int) -> Data {
        let json = """
        {"version":\(version),"quiz_id":"legacy-plan","items":[{"word_id":7,"lemma":"borrow","options":["public meaning","legacy-private-option"],"answer_index":0,"ask_until":"2027-01-15T09:00:00Z"}],"updated_at":"2027-01-15T08:00:00Z"}
        """
        return Data(json.utf8)
    }

    private func legacyStateData() -> [Data] {
        return [
            #"{"version":1,"quiz_id":"legacy-plan","word_id":7,"updated_at":"2027-01-15T08:00:00Z"}"#,
            #"{"version":1,"quiz_id":"legacy-plan","word_id":7,"answer":{"choice":1,"at":"2027-01-15T08:00:00Z"},"updated_at":"2027-01-15T08:00:00Z"}"#
        ].map { Data($0.utf8) }
    }

    func testLegacyAndFuturePlanJSONCannotProduceScreensActionsOrChangeDates() throws {
        let store = AppGroupStore(containerURL: directory)
        for version in [1, WidgetQuizPlan.currentVersion + 1] {
            let bytes = legacyPlanData(version: version)
            let decoded = try JSONCoding.makeDecoder().decode(WidgetQuizPlan.self, from: bytes)
            XCTAssertEqual(decoded.version, version)
            XCTAssertTrue(try XCTUnwrap(decoded.items.first).isUsable)
            XCTAssertEqual(decoded.items.first?.askUntil, start.addingTimeInterval(3600))
            // Decoding compatibility is distinct from permission to present cached content.
            XCTAssertEqual(decoded.items.first?.options, ["public meaning", "legacy-private-option"])
            XCTAssertTrue(WidgetQuizRotation.questions(of: decoded).isEmpty)
            XCTAssertTrue(WidgetQuizRotation.changeDates(
                of: decoded, after: start, until: start.addingTimeInterval(7200)
            ).isEmpty)
            try bytes.write(to: store.quizPlanURL)
            XCTAssertNil(store.readQuizPlan(), "Both legacy and unknown future files must be refused")
            XCTAssertEqual(try Data(contentsOf: store.quizPlanURL), bytes, "A reader must not rewrite the cache")

            for stateBytes in legacyStateData() {
                try stateBytes.write(to: store.quizStateURL)
                let state = try JSONCoding.makeDecoder().decode(WidgetQuizState.self, from: stateBytes)
                XCTAssertNil(store.readQuizState(), "A v1 answer file still decodes but is not current state")
                XCTAssertEqual(state.wordID, 7)
                // The answered case must also fail: skipping does not normally hide an answer.
                XCTAssertNil(WidgetQuizRotation.screen(plan: decoded, state: state, at: start))
                XCTAssertNil(WidgetQuizRotation.screen(plan: decoded, state: state, at: start, skipping: [7]))
                XCTAssertNil(WidgetQuizRotation.screen(plan: store.readQuizPlan(), state: state, at: start))
                XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(
                    wordID: 7, option: "public meaning", plan: decoded, state: state, at: start
                ))
                XCTAssertNil(WidgetQuizRotation.stateAfterNext(
                    wordID: 7, plan: decoded, state: state, at: start
                ))
                XCTAssertEqual(try Data(contentsOf: store.quizStateURL), stateBytes)
                XCTAssertEqual(try Data(contentsOf: store.quizPlanURL), bytes)
                var future = state
                future.version = WidgetQuizState.currentVersion + 1
                let futureBytes = try JSONCoding.makeEncoder().encode(future)
                try futureBytes.write(to: store.quizStateURL)
                XCTAssertEqual(try JSONCoding.makeDecoder().decode(WidgetQuizState.self, from: futureBytes), future)
                XCTAssertNil(store.readQuizState(), "An unknown future state must be refused too")
                XCTAssertEqual(try Data(contentsOf: store.quizStateURL), futureBytes)
            }
        }
    }

    func testCurrentPlanJSONWithoutOptionalFieldsStillDrivesQuiz() throws {
        XCTAssertEqual(WidgetQuizPlan.currentVersion, 2)
        XCTAssertEqual(plan([7, 8]).version, 2, "The app's normal constructor must emit the new cache version")
        let json = """
        {"version":2,"quiz_id":"current-plan","items":[{"word_id":7,"lemma":"borrow","options":["ödünç almak","izin vermek"],"answer_index":0,"ask_until":"2027-01-15T09:00:00Z"},{"word_id":8,"lemma":"allow","options":["ödünç almak","izin vermek"],"answer_index":1}],"updated_at":"2027-01-15T08:00:00Z"}
        """
        let bytes = Data(json.utf8)
        let store = AppGroupStore(containerURL: directory)
        try bytes.write(to: store.quizPlanURL)
        let current = try XCTUnwrap(store.readQuizPlan())
        XCTAssertEqual(WidgetQuizRotation.questions(of: current).map { $0.wordID }, [7, 8])
        XCTAssertNil(current.items[0].shortOptions)
        XCTAssertNil(current.items[0].optionWords)
        XCTAssertNil(current.items[0].ipaUS)
        XCTAssertNil(current.items[0].exampleEN)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: current, state: nil, at: start)?.item.wordID, 7)
        XCTAssertNil(WidgetQuizRotation.screen(plan: current, state: nil, at: start)?.choice)
        let answer = try XCTUnwrap(WidgetQuizRotation.stateAfterAnswer(
            wordID: 7, option: "ödünç almak", plan: current, state: nil, at: start
        ))
        XCTAssertEqual(answer.version, 2)
        XCTAssertEqual(answer.answer?.choice, 0)
        let rewritten = WidgetQuizPlan(quizID: "current-plan-rewritten", items: current.items, updatedAt: start)
        let kept = try XCTUnwrap(WidgetQuizRotation.screen(plan: rewritten, state: answer, at: start))
        XCTAssertEqual(kept.choice, 0, "A v2-to-v2 rewrite of the same first question must retain its answer")
        XCTAssertTrue(kept.isRight)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: current, state: answer, at: start)?.isRight, true)
        let next = try XCTUnwrap(WidgetQuizRotation.stateAfterNext(
            wordID: 7, plan: current, state: answer, at: start
        ))
        XCTAssertEqual(next.wordID, 8)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: current, state: next, at: start)?.item.wordID, 8)
        XCTAssertEqual(WidgetQuizRotation.changeDates(
            of: current, after: start, until: start.addingTimeInterval(7200)
        ), [start.addingTimeInterval(3600)])
        try store.writeQuizState(answer)
        XCTAssertEqual(store.readQuizState(), answer)
        XCTAssertEqual(try Data(contentsOf: store.quizPlanURL), bytes)
    }

    func testLegacyShownOptionsAndAnswerCannotCarryIntoCurrentPlan() throws {
        let store = AppGroupStore(containerURL: directory)
        // Same lemma and correct meaning: without a version boundary keepingShown would retain
        // the old distractor and its option order instead of this freshly built question.
        let fresh = WidgetQuizItem(
            wordID: 7, lemma: "borrow", options: ["public meaning", "fresh public option"], answerIndex: 0
        )
        for stateBytes in legacyStateData() {
            try legacyPlanData(version: 1).write(to: store.quizPlanURL)
            try stateBytes.write(to: store.quizStateURL)
            let oldState = try JSONCoding.makeDecoder().decode(WidgetQuizState.self, from: stateBytes)
            XCTAssertNil(store.readQuizState())
            // This is AppModel.writeQuizWidgetPlan's real reader -> screen -> keepingShown path.
            let shown = WidgetQuizRotation.screen(
                plan: store.readQuizPlan(), state: store.readQuizState(), at: start
            )?.item
            XCTAssertNil(shown)
            let rebuilt = WidgetQuizRotation.keepingShown(
                shown, before: [fresh], askedIDs: [7], limit: 24
            )
            XCTAssertEqual(rebuilt, [fresh])
            XCTAssertFalse(rebuilt.flatMap { $0.options }.contains("legacy-private-option"))
            let written = WidgetQuizPlan(quizID: "renewed-plan", items: rebuilt, updatedAt: start)
            XCTAssertEqual(written.version, 2)
            try store.writeQuizPlan(written)
            let current = try XCTUnwrap(store.readQuizPlan())
            XCTAssertEqual(current, written)
            let migrated = try XCTUnwrap(WidgetQuizRotation.screen(plan: current, state: oldState, at: start))
            XCTAssertEqual(migrated.item, fresh)
            XCTAssertNil(migrated.choice, "The same word ID must not attach the v1 choice to changed v2 options")
            XCTAssertFalse(migrated.isAnswered)
            var futureState = oldState
            futureState.version = WidgetQuizState.currentVersion + 1
            let futureScreen = try XCTUnwrap(WidgetQuizRotation.screen(plan: current, state: futureState, at: start))
            XCTAssertEqual(futureScreen.item, fresh)
            XCTAssertNil(futureScreen.choice)
            let newAnswer = try XCTUnwrap(WidgetQuizRotation.stateAfterAnswer(
                wordID: 7, option: "public meaning", plan: current, state: oldState, at: start
            ))
            XCTAssertEqual(newAnswer.version, 2)
            XCTAssertEqual(newAnswer.answer?.choice, 0, "A stale answered file must not block the new question's first answer")
            XCTAssertEqual(try Data(contentsOf: store.quizStateURL), stateBytes,
                           "Reading/regenerating questions must leave the stale state bytes untouched")
        }
    }

    func testFilesRoundTripWithSnakeCaseKeys() throws {
        let store = AppGroupStore(containerURL: directory)
        XCTAssertNil(store.readQuizPlan())
        XCTAssertNil(store.readQuizState())

        var written = plan([1, 2])
        written.items[0].askUntil = start.addingTimeInterval(3600)
        try store.writeQuizPlan(written)
        XCTAssertEqual(store.readQuizPlan(), written)
        let state = answered(2, choice: 1)
        try store.writeQuizState(state)
        XCTAssertEqual(store.readQuizState(), state)
        let done = waiting(nil)
        try store.writeQuizState(done)
        XCTAssertEqual(store.readQuizState(), done)

        let planJSON = try XCTUnwrap(String(data: Data(contentsOf: store.quizPlanURL), encoding: .utf8))
        for key in ["\"quiz_id\"", "\"items\"", "\"updated_at\"", "\"word_id\"", "\"answer_index\"",
                    "\"short_options\"", "\"option_words\"", "\"options\"", "\"ask_until\":\"2027-01-15T09:00:00Z\""] {
            XCTAssertTrue(planJSON.contains(key), key)
        }
        try store.writeQuizState(state)
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
        XCTAssertNil(decoded.askUntil)
        XCTAssertNil(decoded.shortOption(at: 0))
        XCTAssertNil(decoded.optionWord(at: 1))
        XCTAssertTrue(decoded.isUsable)
        XCTAssertTrue(decoded.isAsked(at: .distantFuture))
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
        let quiz = WidgetQuizPlan(quizID: "q", items: [noAnswer, emptyOption, oneOption, noWord, item(5)])
        XCTAssertEqual(WidgetQuizRotation.questions(of: quiz).map { $0.wordID }, [5])
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: nil, at: start)?.item.wordID, 5)
        let empty = WidgetQuizPlan(quizID: "q", items: [noAnswer])
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

    // MARK: Nothing moves by itself

    func testAQuestionAndAnAnswerWaitForever() throws {
        let quiz = plan([1, 2, 3])
        let waits: [TimeInterval] = [0, 1, 30, 216]
        for hours in waits {
            let screen = WidgetQuizRotation.screen(plan: quiz, state: nil, at: start.addingTimeInterval(hours * 3600))
            XCTAssertEqual(screen?.item.wordID, 1)
            XCTAssertEqual(screen?.isAnswered, false)
        }
        let state = try XCTUnwrap(WidgetQuizRotation.stateAfterAnswer(wordID: 1, option: "c1", plan: quiz, state: nil, at: start))
        XCTAssertEqual(state, answered(1, choice: 2))
        for hours in waits {
            let screen = try XCTUnwrap(WidgetQuizRotation.screen(plan: quiz, state: state, at: start.addingTimeInterval(hours * 3600)))
            XCTAssertEqual(screen.item.wordID, 1)
            XCTAssertEqual(screen.choice, 2)
            XCTAssertTrue(screen.isAnswered)
            XCTAssertFalse(screen.isRight)
        }
    }

    func testTheFirstAnswerStands() throws {
        let quiz = plan([1, 2])
        let first = try XCTUnwrap(WidgetQuizRotation.stateAfterAnswer(wordID: 1, option: "a1", plan: quiz, state: nil, at: start))
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: first, at: start)?.isRight, true)
        // A second tap on another option, or the same one, changes nothing (and records nothing).
        let later = start.addingTimeInterval(5 * 86_400)
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, option: "b1", plan: quiz, state: first, at: later))
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, option: "a1", plan: quiz, state: first, at: later))
    }

    func testAnswersArePickedByTheirText() {
        let quiz = plan([1, 2])
        XCTAssertEqual(WidgetQuizRotation.stateAfterAnswer(wordID: 2, option: "b2", plan: quiz, state: nil, at: start)?.answer?.choice, 1)
        // An option the question does not have (drawn from an older file), a word not asked.
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, option: "b2", plan: quiz, state: nil, at: start))
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 9, option: "a9", plan: quiz, state: nil, at: start))
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, option: "a1", plan: nil, state: nil, at: start))
    }

    func testDevamGoesForwardAndNeverRoundAgain() throws {
        let quiz = plan([1, 2, 3])
        let after2 = try XCTUnwrap(WidgetQuizRotation.stateAfterNext(wordID: 2, plan: quiz, state: answered(2, choice: 0), at: start))
        XCTAssertEqual(after2, waiting(3))
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: after2, at: start)?.item.wordID, 3)
        // After the last question: none left in this file.
        let done = try XCTUnwrap(WidgetQuizRotation.stateAfterNext(wordID: 3, plan: quiz, state: after2, at: start))
        XCTAssertEqual(done, waiting(nil))
        XCTAssertNil(WidgetQuizRotation.screen(plan: quiz, state: done, at: start))
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 3, plan: quiz, state: done, at: start), waiting(nil))
        // A newer file starts again.
        XCTAssertEqual(WidgetQuizRotation.screen(plan: plan([4, 5], quizID: "q2"), state: done, at: start)?.item.wordID, 4)
        // A word that is no longer in the file: the question after the one the state points at.
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 99, plan: quiz, state: waiting(1), at: start)?.wordID, 2)
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 99, plan: quiz, state: nil, at: start)?.wordID, 2)
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 99, plan: quiz, state: done, at: start), waiting(nil))
        // One question: Devam ends it.
        XCTAssertEqual(WidgetQuizRotation.stateAfterNext(wordID: 1, plan: plan([1]), state: nil, at: start), waiting(nil))
    }

    // MARK: Passed over

    func testTheWordWidgetsWordAndKnownWordsArePassedOver() {
        let quiz = plan([1, 2, 3])
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: waiting(2), at: start, skipping: [2])?.item.wordID, 3)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: waiting(2), at: start, skipping: [3])?.item.wordID, 2)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: nil, at: start, skipping: [1, 2])?.item.wordID, 3)
        // Forward only: nothing after the last question.
        XCTAssertNil(WidgetQuizRotation.screen(plan: quiz, state: waiting(3), at: start, skipping: [3]))
        XCTAssertNil(WidgetQuizRotation.screen(plan: plan([1]), state: nil, at: start, skipping: [1]))
        // An answer on screen is never passed over: the meaning is already shown.
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: answered(2, choice: 1), at: start, skipping: [2])?.item.wordID, 2)
    }

    func testAQuestionIsNotAskedOnceTekrarAsksItSoon() throws {
        let soon = start.addingTimeInterval(3600)
        let quiz = WidgetQuizPlan(quizID: "q1", items: [item(1, askUntil: soon), item(2), item(3, askUntil: soon.addingTimeInterval(60))])
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: nil, at: start)?.item.wordID, 1)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: nil, at: soon)?.item.wordID, 2)
        XCTAssertNil(WidgetQuizRotation.screen(plan: quiz, state: waiting(3), at: soon.addingTimeInterval(60)))
        // It can no longer be answered either.
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 1, option: "a1", plan: quiz, state: nil, at: soon))
        // An answer given before stays: it already showed the meaning.
        let given = try XCTUnwrap(WidgetQuizRotation.stateAfterAnswer(wordID: 1, option: "a1", plan: quiz, state: nil, at: start))
        XCTAssertEqual(WidgetQuizRotation.screen(plan: quiz, state: given, at: soon.addingTimeInterval(86_400))?.choice, 0)
        // The timeline gets an entry at each limit within its span.
        XCTAssertEqual(WidgetQuizRotation.changeDates(of: quiz, after: start, until: soon), [soon])
        XCTAssertEqual(WidgetQuizRotation.changeDates(of: quiz, after: soon, until: soon.addingTimeInterval(3600)), [soon.addingTimeInterval(60)])
    }

    // MARK: A newer file

    func testAStateOfAnOlderFileCountsOnlyForTheFirstQuestion() {
        let newer = plan([2, 1, 3], quizID: "q2")
        // The app kept the question on screen (2) first: it and its answer stay.
        let onScreen = answered(2, choice: 1)
        let kept = WidgetQuizRotation.screen(plan: newer, state: onScreen, at: start.addingTimeInterval(60))
        XCTAssertEqual(kept?.item.wordID, 2)
        XCTAssertEqual(kept?.choice, 1)
        XCTAssertNil(WidgetQuizRotation.stateAfterAnswer(wordID: 2, option: "a2", plan: newer, state: onScreen, at: start))
        // A word further down the newer file: the state is stale, the first question shows.
        let elsewhere = answered(1, choice: 0)
        XCTAssertEqual(WidgetQuizRotation.screen(plan: newer, state: elsewhere, at: start)?.item.wordID, 2)
        XCTAssertNil(WidgetQuizRotation.screen(plan: newer, state: elsewhere, at: start)?.choice)
        // In its own file the same state counts wherever the word is.
        XCTAssertEqual(WidgetQuizRotation.screen(plan: plan([2, 1, 3]), state: elsewhere, at: start)?.item.wordID, 1)
        // An answer whose option does not exist is dropped.
        XCTAssertNil(WidgetQuizRotation.screen(plan: newer, state: answered(2, choice: 7), at: start)?.choice)
    }

    func testANewFileKeepsTheQuestionOnScreenFirst() {
        let shown = item(2, answer: 1)
        let limit = start.addingTimeInterval(7200)
        let fresh = [item(1), WidgetQuizItem(wordID: 2, lemma: "word2", options: ["x", "b2", "y"], answerIndex: 1, askUntil: limit), item(3)]
        let kept = WidgetQuizRotation.keepingShown(shown, before: fresh, askedIDs: [1, 2, 3], limit: 24)
        // The very same item (its options and their order stay) with the new limit, then the
        // others without it.
        XCTAssertEqual(kept.map { $0.wordID }, [2, 1, 3])
        XCTAssertEqual(kept[0].options, shown.options)
        XCTAssertEqual(kept[0].askUntil, limit)
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
