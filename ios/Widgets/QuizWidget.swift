import SwiftUI
import WidgetKit
import CoreModels
import SharedState
import Scheduler

/// The quiz widget (Home Screen, medium and large): "Bu kelime ne demek?", an English word and
/// three Turkish options chosen with buttons (iOS 17 `Button(intent:)`). The first choice marks
/// the right option at once, a wrong pick too, and "Devam" brings the next question; after the
/// word widget's change interval the next question also comes by itself.
///
/// Learning rules (docs/tasarim/ogrenme_ilkeleri.md): the answer shows at once, so the tap is
/// seeing, not a review: it is recorded as an exposure only (`WidgetEventType.quiz`) and never
/// moves a word in "Tekrar". The questions come from the app with the widget plan
/// (`widget_quiz.json`, App/AppModel+QuizWidget.swift): the same words as the word widget, never
/// one "Tekrar" asks soon, options without confusable partners. Calm like the other widgets: no
/// score, no count, no red (a wrong pick is a cross in a quiet color).
/// The widget keeps the system's content margins: it has no buttons in the corners to reach into
/// them (unlike `WordWidget`).
struct LockglowQuizWidget: Widget {
    static let kind = "LockglowQuizWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: LockglowQuizWidget.kind, provider: QuizProvider()) { entry in
            QuizWidgetView(entry: entry)
        }
        .configurationDisplayName("Kelime sorusu")
        .description("Kelimenin anlamını üç şıktan seç. Doğrusu hemen görünür.")
        .supportedFamilies([
            .systemMedium,
            .systemLarge,
        ])
    }
}

struct QuizEntry: TimelineEntry {
    let date: Date
    /// Nil until the app has written questions (a new install not opened yet).
    let screen: WidgetQuizScreen?

    /// The gallery's and the placeholder's question; no file access.
    static func sample(at date: Date = Date()) -> QuizEntry {
        return QuizEntry(date: date, screen: WidgetQuizScreen(item: sampleItem, choice: nil))
    }

    /// "borrow" (a seed word) with two verbs of the same level as the wrong options; its
    /// confusable partner "lend" is never one.
    static let sampleItem = WidgetQuizItem(
        wordID: 52,
        lemma: "borrow",
        ipaUS: "/ˈbɑːroʊ/",
        exampleEN: "Can I borrow your pen?",
        options: ["izin vermek", "ödünç almak", "cevaplamak"],
        answerIndex: 1,
        optionWords: ["allow", "borrow", "answer"]
    )
}

/// Reads the two quiz files and the word widget's rotation; the timeline has an entry at every
/// moment the screen changes within the next 48 hours: when an answer gives way to the next
/// question, and when the word widget moves to the word of the question on screen (that question
/// is then passed over, `WidgetQuizRotation`).
struct QuizProvider: TimelineProvider {
    typealias Entry = QuizEntry

    /// Without questions the widget looks again after this long (the app writes them on launch).
    static let emptyRecheck: TimeInterval = 6 * 3600

    // Placeholder and snapshot are instant and static: no file access.
    func placeholder(in context: Context) -> QuizEntry {
        return QuizEntry.sample()
    }

    func getSnapshot(in context: Context, completion: @escaping (QuizEntry) -> Void) {
        completion(QuizEntry.sample())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuizEntry>) -> Void) {
        let now = Date()
        let store = WordDataSource.makeStore()
        let made = QuizProvider.makeEntries(
            plan: store?.readQuizPlan(),
            state: store?.readQuizState(),
            words: WordDataSource.load(store: store),
            now: now
        )
        completion(Timeline(entries: made.entries, policy: .after(made.reload)))
    }

    /// The entries from `now` and the date to read the files again. Pure (unit-tested in
    /// LockglowWidgetSnapshots). `words` is the word widget's rotation (`WordDataSource.load`).
    /// Entries whose screen does not change are left out; the reload comes after the last moment
    /// looked at, at least an hour on, so a single entry never asks for an immediate reload.
    static func makeEntries(
        plan: WidgetQuizPlan?,
        state: WidgetQuizState?,
        words input: RotationInput,
        now: Date
    ) -> (entries: [QuizEntry], reload: Date) {
        guard !WidgetQuizRotation.questions(of: plan).isEmpty else {
            return ([QuizEntry(date: now, screen: nil)], now.addingTimeInterval(emptyRecheck))
        }
        // The word widget's timeline, exactly as `WordProvider` makes it.
        let wordEntries = WordProvider.makeEntries(input: input, now: now)
        var dates = [now] + wordEntries.map { $0.date }.filter { $0 > now }
        if let expiry = WidgetQuizRotation.answerExpiry(plan: plan, state: state), expiry > now {
            dates.append(expiry)
        }
        dates = Array(Set(dates)).sorted()

        var entries: [QuizEntry] = []
        for date in dates {
            // The word on the word widget at `date`: its last entry at or before it.
            let shownWord = wordEntries.last(where: { $0.date <= date })?.word.id
            let screen = WidgetQuizRotation.screen(plan: plan, state: state, at: date, avoiding: shownWord)
            if let last = entries.last, last.screen == screen {
                continue
            }
            entries.append(QuizEntry(date: date, screen: screen))
        }
        let lastLooked = dates.last ?? now
        return (entries, max(lastLooked, now.addingTimeInterval(3600)))
    }
}

/// Picks the layout for the family. The paper is the design's `surface`, as on the word widget;
/// the system removes or tints it in tinted and clear Home Screen modes (`QuizColors`). Tapping
/// outside a button opens the app on the word (`widgetURL`).
struct QuizWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuizEntry

    var body: some View {
        content
            .widgetURL(entry.screen.flatMap { DeepLink.wordURL(id: $0.item.wordID) })
            .containerBackground(for: .widget) {
                Theme.surface
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemLarge:
            QuizLargeView(entry: entry)
        default:
            QuizMediumView(entry: entry)
        }
    }
}
