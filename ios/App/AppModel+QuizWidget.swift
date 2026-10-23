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
    /// answer on screen stays (`WidgetQuizRotation.keepingShown`). With no question left the file
    /// is written empty and the widget says to open the app. Best effort: a failed write keeps the
    /// old questions.
    func writeQuizWidgetPlan(from queue: [WidgetWord], at date: Date) {
        guard let container = AppGroupLocator.containerURL() else {
            return
        }
        let store = AppGroupStore(containerURL: container)
        let asked = QuizWidgetQuestions.words(from: queue, progress: progress, now: date)
        var items: [WidgetQuizItem] = []
        for word in asked where items.count < QuizWidgetQuestions.limit {
            guard let choice = QuizWidgetQuestions.question(
                for: word,
                attempt: (progress[word.id]?.exposures ?? 0) + 1,
                candidates: introCandidates(for: word),
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
                optionWords: choice.optionWords.map { $0.isEmpty ? nil : $0 }
            ))
        }
        // What the quiz widget shows now; the word widget shows the queue's first word.
        let shown = WidgetQuizRotation.screen(
            plan: store.readQuizPlan(),
            state: store.readQuizState(),
            at: date,
            avoiding: queue.first?.id
        )?.item
        let plan = WidgetQuizPlan(
            quizID: UUID().uuidString,
            intervalSeconds: rotationMinutes * 60,
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
