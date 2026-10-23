import Foundation
import os
import CoreModels
import SharedState
import Learning

// The quiz widget's questions ("Bu kelime ne demek?", Widgets/QuizWidget.swift), written with every
// widget plan from the same queue (`refreshWidgetPlan`). The widget only draws them: the options
// need the cards, the topics and the progress, which only the app has. An answer comes back as a
// `quiz` event, an exposure and never a grade (`ProgressIngest`), so "Tekrar" keeps its schedule.
extension AppModel {
    private static let quizLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "QuizWidget"
    )

    /// Writes `widget_quiz.json` for the widget queue just written (`queue`, its first word on the
    /// word widget now), at `date`, the new plan's `updated_at`. Up to `QuizWidgetQuestions.limit`
    /// questions (`QuizWidgetQuestions`). The question on the quiz widget stays first while it is
    /// still asked, the very same item, so a rewrite never changes it under the finger and an
    /// answer on screen stays (`WidgetQuizRotation.keepingShown`). Every question carries the
    /// moment "Tekrar" will soon ask its word (`QuizWidgetQuestions.askUntil`); the widget stops
    /// asking it then, even when the app is not opened. With no question the file is written empty
    /// and the widget says where questions come from. Best effort: a failed write keeps the old
    /// questions.
    func writeQuizWidgetPlan(from queue: [WidgetWord], at date: Date) {
        guard let container = AppGroupLocator.containerURL() else {
            return
        }
        let store = AppGroupStore(containerURL: container)
        let asked = QuizWidgetQuestions.words(from: queue, progress: progress, now: date)
        // `introCandidates` rebuilds the cards for a user's own word without their sensitivity:
        // personal-topic cards are left out by id, so they never become an option on the Home Screen.
        let personalIDs = Set(words.filter { $0.isSensitive }.map { $0.id })
        var items: [WidgetQuizItem] = []
        for word in asked where items.count < QuizWidgetQuestions.limit {
            guard let choice = QuizWidgetQuestions.question(
                for: word,
                attempt: (progress[word.id]?.exposures ?? 0) + 1,
                candidates: introCandidates(for: word).filter { !personalIDs.contains($0.id) },
                topicsOf: topicsOf
            ) else {
                continue
            }
            items.append(WidgetQuizItem(
                wordID: word.id,
                lemma: word.lemma,
                ipaUS: word.ipaUS,
                exampleEN: word.exampleEN.isEmpty ? nil : word.exampleEN,
                options: choice.options,
                answerIndex: choice.answerIndex,
                shortOptions: choice.shortOptions,
                optionWords: choice.optionWords.map { $0.isEmpty ? nil : $0 },
                askUntil: progress[word.id].flatMap { QuizWidgetQuestions.askUntil(of: $0, now: date) }
            ))
        }
        // What the quiz widget shows now; the word widget shows the queue's first word.
        let shown = WidgetQuizRotation.screen(
            plan: store.readQuizPlan(),
            state: store.readQuizState(),
            at: date,
            skipping: Set(queue.prefix(1).map { $0.id })
        )?.item
        let plan = WidgetQuizPlan(
            quizID: UUID().uuidString,
            items: WidgetQuizRotation.keepingShown(
                shown,
                before: items,
                askedIDs: Set(asked.map { $0.id }),
                limit: QuizWidgetQuestions.limit
            ),
            updatedAt: date
        )
        do {
            try store.writeQuizPlan(plan)
        } catch {
            AppModel.quizLogger.error("could not write the quiz questions: \(error.localizedDescription, privacy: .public)")
        }
    }
}
