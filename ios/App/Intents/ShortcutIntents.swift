import AppIntents
import SwiftUI
import CoreModels
import Learning

// The actions Siri, Kestirmeler (the Shortcuts app) and Spotlight offer (`LockglowShortcuts`).
// Titles and Siri's sentences follow docs/tasarim/terimler.md. Only "Bugünün kelimesi" answers
// without opening the app; the others open it (`openAppWhenRun`) and leave the work to RootView
// through `ShortcutRouter`, which waits until the words have loaded and nothing covers the screen.
// None of them changes progress: hearing or opening a word is not a review (ogrenme_ilkeleri 2.1).

/// "Lockglow'da bugünün kelimesi ne?": Siri says and shows the word the widget shows now, with its
/// Turkish meaning. The card has the "Dinle" button, which reads the word with the English voice.
struct TodayWordIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Bugünün kelimesi"
    }

    static var description: IntentDescription? {
        IntentDescription("Widget'taki kelimeyi ve Türkçesini söyler. Uygulama açılmaz.")
    }

    /// On the main actor because it builds a view; the two files it reads are small.
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let word = TodayWord.pick(AppModel.widgetWordNow())
        return .result(dialog: "\(TodayWord.dialog(for: word))", view: TodayWordSnippet(word: word))
    }
}

/// "Lockglow'da tekrar başlat": opens "Tekrar", where the round starts with "Başla".
struct StartReviewIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Tekrar'ı aç"
    }

    static var description: IntentDescription? {
        IntentDescription("Lockglow'u Tekrar'da açar.")
    }

    static var openAppWhenRun: Bool {
        true
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        ShortcutRouter.shared.open(.review)
        return .result()
    }
}

/// "Lockglow'a kelime ekle": opens the "Kendi kelimeni ekle" form. In Kestirmeler the English
/// word can come from an earlier action; it fills the word field, and the user saves.
struct AddWordIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Kelime ekle"
    }

    static var description: IntentDescription? {
        IntentDescription("Kendi kelimeni eklemek için formu açar.")
    }

    static var openAppWhenRun: Bool {
        true
    }

    @Parameter(title: "İngilizce kelime")
    var lemma: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Kelime ekle: \(\.$lemma)")
    }

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        ShortcutRouter.shared.open(.addWord(lemma: CustomWordText.lemma(lemma ?? "")))
        return .result()
    }
}

/// "Bu kelimeyi Lockglow'da ara": Siri asks for the word (English or Turkish), offers the matches
/// (`WordEntityQuery`) and opens the chosen word's whole card.
struct OpenWordIntent: OpenIntent {
    static var title: LocalizedStringResource {
        "Kelime ara"
    }

    static var description: IntentDescription? {
        IntentDescription("Kelimeyi İngilizce ya da Türkçe bulur ve kartını açar.")
    }

    static var openAppWhenRun: Bool {
        true
    }

    @Parameter(title: "Kelime", requestValueDialog: "Hangi kelimeyi arayalım?")
    var target: WordEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Kartı aç: \(\.$target)")
    }

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        ShortcutRouter.shared.open(.word(id: target.id))
        return .result()
    }
}

// MARK: - Snippet

/// Siri's card for "Bugünün kelimesi": the English word, its Turkish meaning, the example and the
/// "Dinle" button. Siri draws it on its own background, so the colors are the system's primary
/// and secondary; the button is ink (`.primary`), never system blue (README rule 2).
struct TodayWordSnippet: View {
    let word: WidgetWord?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let word = word {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(verbatim: word.lemma)
                        .font(.system(.title, design: .serif).weight(.bold))
                        .foregroundStyle(.primary)
                        .englishVoice()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // As the widget's speaker button (WidgetButtons.swift), in the app's process.
                    Button(intent: SpeakWordIntent(text: word.lemma)) {
                        Label("Dinle", systemImage: "speaker.wave.2")
                            .labelStyle(.iconOnly)
                            .font(.title3)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                    .accessibilityLabel(Text("Kelimeyi dinle"))
                    .accessibilityInputLabels([Text("Kelimeyi dinle"), Text("Dinle")])
                    .accessibilityAddTraits(.startsMediaSession)
                }
                if let meaning = TodayWord.meaning(of: word) {
                    Text(verbatim: meaning)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                let example = word.exampleEN.trimmingCharacters(in: .whitespacesAndNewlines)
                if !example.isEmpty {
                    Text(verbatim: example)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(.secondary)
                        .englishVoice()
                }
            } else {
                Text(verbatim: TodayWord.noWord)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

// MARK: - App Shortcuts

/// The phrases Siri knows without any setup, also offered in Spotlight and Kestirmeler. The code
/// holds the English phrases (the project's development language is English); the Turkish ones
/// are in Intents/tr.lproj/AppShortcuts.strings, one for each English phrase, keyed by it
/// (`${applicationName}` there is `\(.applicationName)` here). Change both together.
struct LockglowShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TodayWordIntent(),
            phrases: [
                "What's today's word in \(.applicationName)",
                "\(.applicationName) word of the day",
                "Tell me today's word in \(.applicationName)",
            ],
            shortTitle: "Bugünün kelimesi",
            systemImageName: "text.book.closed"
        )
        AppShortcut(
            intent: StartReviewIntent(),
            phrases: [
                "Start a review in \(.applicationName)",
                "\(.applicationName) start review",
                "Open review in \(.applicationName)",
            ],
            shortTitle: "Tekrar'ı aç",
            systemImageName: "arrow.triangle.2.circlepath"
        )
        AppShortcut(
            intent: AddWordIntent(),
            phrases: [
                "Add a word to \(.applicationName)",
                "\(.applicationName) add word",
                "Add a new word to \(.applicationName)",
            ],
            shortTitle: "Kelime ekle",
            systemImageName: "plus.circle"
        )
        AppShortcut(
            intent: OpenWordIntent(),
            phrases: [
                "Look up this word in \(.applicationName)",
                "\(.applicationName) look up a word",
                "Search for a word in \(.applicationName)",
            ],
            shortTitle: "Kelime ara",
            systemImageName: "magnifyingglass"
        )
    }
}
