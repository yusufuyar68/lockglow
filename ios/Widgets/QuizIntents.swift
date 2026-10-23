import AppIntents
import Foundation

// The quiz widget's buttons. Ordinary `AppIntent`s: they run in the widget extension
// (`QuizActions`), and the system reloads the quiz widget's timeline right after `perform()`
// returns. Not offered in Shortcuts, Spotlight or Siri: outside the widget they mean nothing.

/// One of the three options of the question on screen.
struct QuizAnswerIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Şıkkı seç"
    }

    static var isDiscoverable: Bool {
        false
    }

    @Parameter(title: "Kelime kimliği")
    var wordID: Int

    @Parameter(title: "Şık")
    var choice: Int

    @Parameter(title: "Kaynak")
    var source: String

    init() {}

    init(wordID: Int, choice: Int, source: String) {
        self.wordID = wordID
        self.choice = choice
        self.source = source
    }

    func perform() async throws -> some IntentResult {
        QuizActions.answer(wordID: wordID, choice: choice, source: source)
        return .result()
    }
}

/// "Devam" after an answer: the next question (docs/tasarim/terimler.md §3, "Devam" moves on in
/// a quiz).
struct QuizNextIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Devam"
    }

    static var isDiscoverable: Bool {
        false
    }

    @Parameter(title: "Kelime kimliği")
    var wordID: Int

    @Parameter(title: "Kaynak")
    var source: String

    init() {}

    init(wordID: Int, source: String) {
        self.wordID = wordID
        self.source = source
    }

    func perform() async throws -> some IntentResult {
        QuizActions.next(wordID: wordID, source: source)
        return .result()
    }
}
