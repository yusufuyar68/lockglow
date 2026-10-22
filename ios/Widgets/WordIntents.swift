import AppIntents
import Foundation

/// Widget button: show the next word. Runs in the widget extension process; the system
/// reloads the timeline right after `perform()` returns.
struct NextWordIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Sonraki kelime"
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
        WordActions.next(wordID: wordID, source: source)
        return .result()
    }
}

/// Widget button: mark the word as known. It leaves the widget; the app asks it once 3 days
/// later (`ProgressIngest`, `Leitner.markKnown`). The title is the button's name
/// (docs/tasarim/terimler.md §3).
struct KnowWordIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Biliyorum"
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
        WordActions.know(wordID: wordID, source: source)
        return .result()
    }
}
