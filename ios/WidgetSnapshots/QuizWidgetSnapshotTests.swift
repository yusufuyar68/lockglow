import XCTest
import SwiftUI
import UIKit
import WidgetKit
import CoreModels
import SharedState
import Scheduler

/// The quiz widget (Widgets/QuizWidget*.swift, compiled into this bundle): its layouts rendered at
/// real widget sizes in its three states (question, right answer, wrong pick) for CI review, and
/// its timeline logic. Like `WidgetSnapshotTests`, an approximation: WidgetKit's chrome and tinting
/// are not reproduced; the system's 16 pt content margins are added here, as WidgetKit adds them
/// (the quiz widget keeps them). The 393 pt sizes are rendered by day, at night and tinted; the
/// iPhone SE sizes by day and at three larger text sizes (`-xxxl`, `-ax1`, `-ax3`): an option must
/// never be cut, run under another or out of the widget.
/// Attachment names: `quiz-<family>-<word>-<state><look>`, state `soru`, `dogru`, `yanlis`.
@MainActor
final class QuizWidgetSnapshotTests: XCTestCase {
    private enum Kind {
        case medium
        case large
    }

    private struct Family {
        let name: String
        let kind: Kind
        let size: CGSize
        let allLooks: Bool
    }

    private struct Look {
        let suffix: String
        let colorScheme: ColorScheme
        let renderingMode: WidgetRenderingMode
        var dynamicTypeSize = DynamicTypeSize.large
    }

    // HIG widget sizes: a 393 pt wide iPhone and the 375 x 667 pt iPhone SE.
    private let families = [
        Family(name: "medium", kind: .medium, size: CGSize(width: 338, height: 158), allLooks: true),
        Family(name: "medium-se", kind: .medium, size: CGSize(width: 321, height: 148), allLooks: false),
        Family(name: "large", kind: .large, size: CGSize(width: 338, height: 354), allLooks: true),
        Family(name: "large-se", kind: .large, size: CGSize(width: 321, height: 324), allLooks: false),
    ]
    private let margin: CGFloat = 16

    private var looks393: [Look] {
        [
            Look(suffix: "", colorScheme: .light, renderingMode: .fullColor),
            Look(suffix: "-koyu", colorScheme: .dark, renderingMode: .fullColor),
            Look(suffix: "-renkli", colorScheme: .dark, renderingMode: .accented),
        ]
    }

    private var looksSE: [Look] {
        [
            Look(suffix: "", colorScheme: .light, renderingMode: .fullColor),
            Look(suffix: "-xxxl", colorScheme: .light, renderingMode: .fullColor, dynamicTypeSize: .xxxLarge),
            Look(suffix: "-ax1", colorScheme: .light, renderingMode: .fullColor, dynamicTypeSize: .accessibility1),
            Look(suffix: "-ax3", colorScheme: .light, renderingMode: .fullColor, dynamicTypeSize: .accessibility3),
        ]
    }

    /// The gallery's "borrow" and real cards that stress the layout: the longest single word, the
    /// longest phrase with long options (short forms on hand), a meaning without a comma.
    private let items: [(name: String, item: WidgetQuizItem)] = [
        ("borrow", QuizEntry.sampleItem),
        ("misunderstanding", WidgetQuizItem(
            wordID: 899, lemma: "misunderstanding", ipaUS: "/ˌmɪsˌʌndərˈstændɪŋ/",
            exampleEN: "It was just a misunderstanding. I'm sorry.",
            options: ["yanlış anlaşılma", "romantik buluşma", "kayıp eşya bürosu"], answerIndex: 0,
            shortOptions: [nil, nil, "kayıp eşya"], optionWords: ["misunderstanding", "date", "lost and found"]
        )),
        ("could-you-tell", WidgetQuizItem(
            wordID: 807, lemma: "Could you tell me the way to", ipaUS: "/kʊdju ˌtɛl mi ðə ˈweɪ tə/",
            exampleEN: "Could you tell me the way to the museum, please?",
            options: ["kendini pek iyi hissetmemek", "… yolunu tarif eder misiniz?", "sonunda kendini ... bulmak"],
            answerIndex: 1,
            shortOptions: ["biraz rahatsız", "Nasıl gidilir?", "sonunda … olmak"],
            optionWords: ["under the weather", "Could you tell me the way to", "end up"]
        )),
        ("disagree", WidgetQuizItem(
            wordID: 801, lemma: "disagree", ipaUS: "/ˌdɪsəˈɡriː/",
            exampleEN: "I'm sorry, but I disagree.",
            options: ["durmak, durdurmak", "aynı fikirde olmamak", "dört gözle beklemek"], answerIndex: 1,
            shortOptions: ["durmak/durdurmak", "hemfikir olmamak", "iple çekmek"],
            optionWords: ["stop", "disagree", "look forward to"]
        )),
    ]

    func testRenderQuizStates() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        for (name, item) in items {
            let wrong = item.options.indices.first { $0 != item.answerIndex }
            let states: [(String, Int?)] = [("soru", nil), ("dogru", item.answerIndex), ("yanlis", wrong)]
            for (state, choice) in states {
                let entry = QuizEntry(date: now, screen: WidgetQuizScreen(item: item, choice: choice))
                for family in families {
                    for look in family.allLooks ? looks393 : looksSE {
                        render(entry: entry, family: family, look: look, name: "quiz-\(family.name)-\(name)-\(state)\(look.suffix)")
                    }
                }
            }
        }
        for family in families {
            render(entry: QuizEntry(date: now, screen: nil), family: family, look: looksSE[0], name: "quiz-\(family.name)-bos")
        }
    }

    // MARK: Texts

    func testTheLineOnTopSaysTheResultInWords() throws {
        let item = try XCTUnwrap(items.first { $0.name == "disagree" }?.item)
        XCTAssertEqual(QuizText.status(of: WidgetQuizScreen(item: item, choice: nil)), [["Bu kelime ne demek?"]])
        XCTAssertEqual(QuizText.status(of: WidgetQuizScreen(item: item, choice: 1)), [["Doğru."]])
        XCTAssertEqual(
            QuizText.status(of: WidgetQuizScreen(item: item, choice: 0)),
            [["Doğrusu: aynı fikirde olmamak"], ["Doğrusu: hemfikir olmamak"], ["Doğrusu işaretli."]]
        )
        XCTAssertEqual(QuizText.spokenResult(of: WidgetQuizScreen(item: item, choice: 0), at: 1), "aynı fikirde olmamak, Doğru cevap")
        XCTAssertEqual(QuizText.spokenResult(of: WidgetQuizScreen(item: item, choice: 0), at: 0), "durmak, durdurmak, Yanlış")
        XCTAssertEqual(QuizText.spokenResult(of: WidgetQuizScreen(item: item, choice: 0), at: 2), "dört gözle beklemek")
        // The option's shorter form is the card's short meaning (`WidgetGloss`).
        XCTAssertEqual(QuizText.forms(of: item, at: 0), ["durmak, durdurmak", "durmak/durdurmak"])
        XCTAssertEqual(QuizText.forms(of: QuizEntry.sampleItem, at: 1), ["ödünç almak"])
    }

    // MARK: Timeline

    private func word(_ id: Int) -> WidgetWord {
        return WidgetWord(id: id, lemma: "word\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e", glossTR: "tr\(id)")
    }

    private func quizItem(_ id: Int) -> WidgetQuizItem {
        return WidgetQuizItem(wordID: id, lemma: "word\(id)", options: ["tr\(id)", "x\(id)", "y\(id)"], answerIndex: 0)
    }

    /// The word widget rotating words 1, 2, 3 every hour from `anchor`.
    private func rotation(anchor: Date) -> RotationInput {
        return RotationInput(
            planID: "p", queue: [word(1), word(2), word(3)], knownIDs: [], cursorOffset: 0,
            cursorAnchor: anchor, interval: 3600, isSeed: false
        )
    }

    func testTheQuizNeverAsksTheWordTheWordWidgetShows() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let quiz = WidgetQuizPlan(quizID: "q", intervalSeconds: 3600, items: [quizItem(1), quizItem(2), quizItem(3)], updatedAt: now)
        let input = rotation(anchor: now)
        let made = QuizProvider.makeEntries(plan: quiz, state: nil, words: input, now: now)
        let wordEntries = WordProvider.makeEntries(input: input, now: now)
        XCTAssertFalse(made.entries.isEmpty)
        XCTAssertEqual(made.entries.first?.date, now)
        for entry in made.entries {
            let shown = try XCTUnwrap(wordEntries.last(where: { $0.date <= entry.date })).word.id
            XCTAssertNotEqual(entry.screen?.item.wordID, shown, "\(entry.date)")
        }
        // Word 1 on the word widget now: the quiz asks 2, then 1 once the word widget moves on.
        XCTAssertEqual(made.entries.first?.screen?.item.wordID, 2)
        XCTAssertEqual(made.entries.dropFirst().first?.screen?.item.wordID, 1)
        // Only changes are entries; the next reload is not before an hour from now.
        for (a, b) in zip(made.entries, made.entries.dropFirst()) {
            XCTAssertNotEqual(a.screen, b.screen)
            XCTAssertLessThan(a.date, b.date)
        }
        XCTAssertGreaterThanOrEqual(made.reload, now.addingTimeInterval(3600))
    }

    func testAnAnswerHasAnEntryWhenItGivesWay() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let quiz = WidgetQuizPlan(quizID: "q", intervalSeconds: 1800, items: [quizItem(4), quizItem(5)], updatedAt: now)
        let answeredAt = now.addingTimeInterval(-600)
        let state = WidgetQuizState(quizID: "q", wordID: 4, answer: WidgetQuizAnswer(choice: 1, at: answeredAt), updatedAt: answeredAt)
        let made = QuizProvider.makeEntries(plan: quiz, state: state, words: rotation(anchor: now), now: now)
        XCTAssertEqual(made.entries.first?.screen?.choice, 1)
        XCTAssertEqual(made.entries.first?.screen?.item.wordID, 4)
        let next = try XCTUnwrap(made.entries.first { $0.date == answeredAt.addingTimeInterval(1800) })
        XCTAssertEqual(next.screen?.item.wordID, 5)
        XCTAssertNil(next.screen?.choice)
    }

    func testWithoutQuestionsTheWidgetSaysToOpenTheApp() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        for quiz in [nil, WidgetQuizPlan(quizID: "q", intervalSeconds: 3600, items: [], updatedAt: now)] {
            let made = QuizProvider.makeEntries(plan: quiz, state: nil, words: rotation(anchor: now), now: now)
            XCTAssertEqual(made.entries.count, 1)
            XCTAssertNil(made.entries.first?.screen)
            XCTAssertEqual(made.reload, now.addingTimeInterval(QuizProvider.emptyRecheck))
        }
    }

    // MARK: Rendering

    @ViewBuilder
    private func view(for family: Family, look: Look, entry: QuizEntry) -> some View {
        switch family.kind {
        case .medium:
            QuizMediumView(entry: entry, renderingMode: look.renderingMode, showsBackground: true)
        case .large:
            QuizLargeView(entry: entry, renderingMode: look.renderingMode, showsBackground: true)
        }
    }

    /// The widget's `surface` in full color, a dark stand-in for the tinted Home Screen.
    @ViewBuilder
    private func backdrop(for look: Look) -> some View {
        if look.renderingMode == .fullColor {
            Theme.surface
        } else {
            Color(red: 0.09, green: 0.10, blue: 0.12)
        }
    }

    private func render(entry: QuizEntry, family: Family, look: Look, name: String) {
        let content = view(for: family, look: look, entry: entry)
            .padding(margin)
            .frame(width: family.size.width, height: family.size.height)
            .background {
                self.backdrop(for: look)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .environment(\.colorScheme, look.colorScheme)
            .environment(\.dynamicTypeSize, look.dynamicTypeSize)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        guard let image = renderer.uiImage else {
            XCTFail("could not render \(name)")
            return
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
