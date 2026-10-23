import SwiftUI
import WidgetKit
import CoreModels
import SharedState
import Scheduler

/// The quiz widget (Home Screen, medium and large): "Bu kelime ne demek?", an English word and
/// three Turkish options chosen with buttons (iOS 17 `Button(intent:)`). The first choice marks
/// the right option at once, a wrong pick too, and "Devam" brings the next question. Nothing moves
/// by itself (ogrenme_ilkeleri 2.4, WCAG 2.2.1).
///
/// Learning rules (docs/tasarim/ogrenme_ilkeleri.md): the answer shows at once, so the tap is
/// seeing, not a review: it is recorded as an exposure only (`WidgetEventType.quiz`) and never
/// moves a word in "Tekrar". The questions come from the app with the widget plan
/// (`widget_quiz.json`, App/AppModel+QuizWidget.swift): words the learner has met, from the word
/// widget's queue, never one "Tekrar" asks soon (each question's `askUntil`), options without
/// confusable partners. Calm like the other widgets: no score, no count, no red (a wrong pick is a
/// cross in a quiet color).
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
    /// Why there is no question on screen.
    enum Empty: Equatable {
        /// The app has written no questions yet (a new install not opened yet).
        case notPrepared
        /// The file has no question: the learner has met no word that may be asked.
        case noWords
        /// "Devam" after the last question, or every question left is passed over for now.
        case finished
    }

    let date: Date
    /// Nil when there is no question (`empty` says why).
    let screen: WidgetQuizScreen?
    var empty = Empty.notPrepared

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
/// moment the screen changes within the word widget's timeline (48 hours): when the word widget
/// moves to the word of the waiting question (that question is then passed over) or away from it,
/// and when a waiting question may no longer be asked (`askUntil`). Words marked "Biliyorum" on the
/// word widget are passed over too. The word widget's buttons reload this timeline
/// (`WordActions`).
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
        guard let plan = plan else {
            return ([QuizEntry(date: now, screen: nil, empty: .notPrepared)], now.addingTimeInterval(emptyRecheck))
        }
        guard !WidgetQuizRotation.questions(of: plan).isEmpty else {
            return ([QuizEntry(date: now, screen: nil, empty: .noWords)], now.addingTimeInterval(emptyRecheck))
        }
        // The word widget's timeline, exactly as `WordProvider` makes it.
        let wordEntries = WordProvider.makeEntries(input: input, now: now)
        let end = max(wordEntries.last?.date ?? now, now.addingTimeInterval(emptyRecheck))
        var dates = [now] + wordEntries.map { $0.date }.filter { $0 > now }
        dates += WidgetQuizRotation.changeDates(of: plan, after: now, until: end)
        dates = Array(Set(dates)).sorted()

        var entries: [QuizEntry] = []
        for date in dates {
            // The word on the word widget at `date` (its last entry at or before it) and the words
            // marked "Biliyorum" there.
            var skipped = input.knownIDs
            if let shown = wordEntries.last(where: { $0.date <= date })?.word.id {
                skipped.insert(shown)
            }
            let screen = WidgetQuizRotation.screen(plan: plan, state: state, at: date, skipping: skipped)
            let entry = QuizEntry(date: date, screen: screen, empty: .finished)
            if let last = entries.last, last.screen == entry.screen {
                continue
            }
            entries.append(entry)
        }
        return (entries, max(dates.last ?? now, now.addingTimeInterval(3600)))
    }
}

/// Picks the layout for the family. The paper is the design's `surface`, as on the word widget;
/// the system removes or tints it in tinted and clear Home Screen modes (`QuizColors`). After the
/// answer a tap outside a button opens the app on the word (`widgetURL`); before it, the app
/// opens without the word, so a stray tap between the options never shows the answer.
struct QuizWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuizEntry

    var body: some View {
        content
            .widgetURL(entry.screen.flatMap { $0.isAnswered ? DeepLink.wordURL(id: $0.item.wordID) : nil })
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
