import Foundation
import os
import CoreModels
import SharedState
import Scheduler

/// Persistence behind the quiz widget's buttons, like `WordActions`: everything is written
/// synchronously, before an intent's `perform()` returns; errors are logged and swallowed. The
/// rules live in `WidgetQuizRotation` (SharedState, unit-tested); this type reads the files and
/// writes `widget_quiz_state.json`, plus one event file per answer.
enum QuizActions {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow.widgets",
        category: "quiz"
    )

    /// Option `choice` of the question about `wordID`. The first answer marks the options and
    /// tells the app the word was seen (`WidgetEventType.quiz`: an exposure, never a grade). A
    /// second tap while that answer is on screen changes nothing and records nothing.
    static func answer(wordID: Int, choice: Int, source: String) {
        guard let store = WordDataSource.makeStore() else {
            logger.error("App Group container unavailable; quiz answer not recorded")
            return
        }
        // Whole seconds: the answer time is stored in ISO 8601 and the hold is measured from it.
        let now = TimelinePlanner.roundedDownToWholeSecond(Date())
        guard let state = WidgetQuizRotation.stateAfterAnswer(
            wordID: wordID,
            choice: choice,
            plan: store.readQuizPlan(),
            state: store.readQuizState(),
            at: now
        ) else {
            logger.info("quiz answer ignored for word \(wordID)")
            return
        }
        do {
            try store.writeQuizState(state)
        } catch {
            logger.error("quiz state write failed: \(error.localizedDescription, privacy: .public)")
        }
        let event = WidgetEvent(
            type: .quiz,
            wordID: wordID,
            at: now,
            source: WidgetEventSource(rawValue: source) ?? .systemMedium
        )
        do {
            try store.eventMailbox.append(event)
        } catch {
            logger.error("event write failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// "Devam" on the question about `wordID`: the next question, not answered yet. Records no
    /// event (the answer already did). `source` is the family, for the log only.
    static func next(wordID: Int, source: String) {
        guard let store = WordDataSource.makeStore() else {
            logger.error("App Group container unavailable; quiz next not recorded")
            return
        }
        let now = TimelinePlanner.roundedDownToWholeSecond(Date())
        guard let state = WidgetQuizRotation.stateAfterNext(
            wordID: wordID,
            plan: store.readQuizPlan(),
            state: store.readQuizState(),
            at: now
        ) else {
            logger.info("quiz next ignored (no questions), source \(source, privacy: .public)")
            return
        }
        do {
            try store.writeQuizState(state)
        } catch {
            logger.error("quiz state write failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
