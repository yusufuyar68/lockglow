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
/// Attachment names: `quiz-<family>-<word>-<state><look>`, state `soru`, `dogru`, `yanlis`;
/// without a question `quiz-<family>-bos-<reason><look>`.
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
        let empties: [(String, QuizEntry.Empty)] = [("hazir-degil", .notPrepared), ("kelime-yok", .noWords), ("bitti", .finished)]
        for (name, reason) in empties {
            for family in families {
                let looks = family.allLooks ? [looks393[0]] : [looksSE[0], looksSE[3]]
                for look in looks {
                    render(entry: QuizEntry(date: now, screen: nil, empty: reason), family: family, look: look, name: "quiz-\(family.name)-bos-\(name)\(look.suffix)")
                }
            }
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
        // One form of the right meaning per layout, shared by the line on top and the marked
        // option (the 2026-10-24 images: "Doğrusu: hemfikir olmamak" over "aynı fikirde olmamak").
        let wrongPick = WidgetQuizScreen(item: item, choice: 0)
        XCTAssertEqual(QuizText.answerFormCount(of: wrongPick), 2)
        XCTAssertEqual(QuizText.status(of: wrongPick, form: 1), [["Doğrusu: hemfikir olmamak"], ["Doğrusu işaretli."]])
        XCTAssertEqual(QuizText.forms(of: wrongPick, at: 1, form: 1), ["hemfikir olmamak"])
        XCTAssertEqual(QuizText.forms(of: wrongPick, at: 1, form: 0), ["aynı fikirde olmamak"])
        // Other options, and the right option after a right pick, keep all their forms.
        XCTAssertEqual(QuizText.forms(of: wrongPick, at: 0, form: 1), ["durmak, durdurmak", "durmak/durdurmak"])
        XCTAssertEqual(QuizText.answerFormCount(of: WidgetQuizScreen(item: item, choice: 1)), 1)
        XCTAssertEqual(QuizText.forms(of: WidgetQuizScreen(item: item, choice: 1), at: 1, form: 0), ["aynı fikirde olmamak", "hemfikir olmamak"])
        XCTAssertEqual(QuizText.spokenResult(of: WidgetQuizScreen(item: item, choice: 0), at: 1), "aynı fikirde olmamak, Doğru cevap")
        XCTAssertEqual(QuizText.spokenResult(of: WidgetQuizScreen(item: item, choice: 0), at: 0), "durmak, durdurmak, Yanlış")
        XCTAssertEqual(QuizText.spokenResult(of: WidgetQuizScreen(item: item, choice: 0), at: 2), "dört gözle beklemek")
        // VoiceOver hears the whole right meaning, also when the line shows only "Doğrusu işaretli.".
        XCTAssertEqual(QuizText.spokenStatus(of: WidgetQuizScreen(item: item, choice: 0)), "Doğrusu: aynı fikirde olmamak")
        XCTAssertNil(QuizText.spokenStatus(of: WidgetQuizScreen(item: item, choice: 1)))
        XCTAssertNil(QuizText.spokenStatus(of: WidgetQuizScreen(item: item, choice: nil)))
        for text in [QuizText.empty(.notPrepared), QuizText.empty(.noWords), QuizText.empty(.finished)] {
            XCTAssertFalse(text.contains("!"), text)
        }
        // The option's shorter form is the card's short meaning (`WidgetGloss`).
        XCTAssertEqual(QuizText.forms(of: item, at: 0), ["durmak, durdurmak", "durmak/durdurmak"])
        XCTAssertEqual(QuizText.forms(of: QuizEntry.sampleItem, at: 1), ["ödünç almak"])
    }

    // MARK: Timeline

    private func word(_ id: Int) -> WidgetWord {
        return WidgetWord(id: id, lemma: "word\(id)", pos: "n", level: "A1", defMicro: "m", defShort: "s", exampleEN: "e", glossTR: "tr\(id)")
    }

    private func quizItem(_ id: Int, askUntil: Date? = nil) -> WidgetQuizItem {
        return WidgetQuizItem(wordID: id, lemma: "word\(id)", options: ["tr\(id)", "x\(id)", "y\(id)"], answerIndex: 0, askUntil: askUntil)
    }

    /// The word widget rotating words 1, 2, 3 every hour from `anchor`.
    private func rotation(anchor: Date, known: Set<Int> = []) -> RotationInput {
        return RotationInput(
            planID: "p", queue: [word(1), word(2), word(3)], knownIDs: known, cursorOffset: 0,
            cursorAnchor: anchor, interval: 3600, isSeed: false
        )
    }

    func testTheQuizNeverAsksTheWordTheWordWidgetShows() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let quiz = WidgetQuizPlan(quizID: "q", items: [quizItem(1), quizItem(2), quizItem(3)], updatedAt: now)
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

    func testAnAnswerStaysAndAQuestionLeavesWhenTekrarAsksItSoon() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let soon = now.addingTimeInterval(1800)
        let quiz = WidgetQuizPlan(quizID: "q", items: [quizItem(4, askUntil: soon), quizItem(5), quizItem(6)], updatedAt: now)
        // Waiting: question 4 until its limit, then 5.
        let waiting = QuizProvider.makeEntries(plan: quiz, state: nil, words: rotation(anchor: now), now: now)
        XCTAssertEqual(waiting.entries.first?.screen?.item.wordID, 4)
        let after = try XCTUnwrap(waiting.entries.first(where: { $0.date == soon }))
        XCTAssertEqual(after.screen?.item.wordID, 5)
        // Answered: the answer stays in every entry, past the limit too (nothing moves by itself).
        let state = WidgetQuizState(quizID: "q", wordID: 4, answer: WidgetQuizAnswer(choice: 1, at: now), updatedAt: now)
        let answered = QuizProvider.makeEntries(plan: quiz, state: state, words: rotation(anchor: now), now: now)
        XCTAssertEqual(answered.entries.count, 1)
        XCTAssertEqual(answered.entries.first?.screen?.choice, 1)
        XCTAssertEqual(answered.entries.first?.screen?.item.wordID, 4)
    }

    func testWordsMarkedKnownOnTheWordWidgetAreNotAsked() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let quiz = WidgetQuizPlan(quizID: "q", items: [quizItem(2), quizItem(7)], updatedAt: now)
        let made = QuizProvider.makeEntries(plan: quiz, state: nil, words: rotation(anchor: now, known: [2]), now: now)
        XCTAssertFalse(made.entries.isEmpty)
        XCTAssertTrue(made.entries.allSatisfy { $0.screen?.item.wordID == 7 })
    }

    func testWithoutQuestionsTheWidgetSaysWhy() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let cases: [(WidgetQuizPlan?, QuizEntry.Empty)] = [
            (nil, .notPrepared),
            (WidgetQuizPlan(quizID: "q", items: [], updatedAt: now), .noWords),
        ]
        for (quiz, reason) in cases {
            let made = QuizProvider.makeEntries(plan: quiz, state: nil, words: rotation(anchor: now), now: now)
            XCTAssertEqual(made.entries.count, 1)
            XCTAssertNil(made.entries.first?.screen)
            XCTAssertEqual(made.entries.first?.empty, reason)
            XCTAssertEqual(made.reload, now.addingTimeInterval(QuizProvider.emptyRecheck))
        }
        // "Devam" after the last question.
        let quiz = WidgetQuizPlan(quizID: "q", items: [quizItem(7)], updatedAt: now)
        let done = WidgetQuizState(quizID: "q", wordID: nil, updatedAt: now)
        let made = QuizProvider.makeEntries(plan: quiz, state: done, words: rotation(anchor: now), now: now)
        XCTAssertEqual(made.entries.count, 1)
        XCTAssertNil(made.entries.first?.screen)
        XCTAssertEqual(made.entries.first?.empty, .finished)
        XCTAssertGreaterThanOrEqual(made.reload, now.addingTimeInterval(3600))
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
