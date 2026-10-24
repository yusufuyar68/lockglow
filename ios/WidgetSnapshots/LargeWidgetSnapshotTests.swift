import Darwin
import XCTest
import SwiftUI
import UIKit
import WidgetKit
import CoreModels

/// The large widget (`LargeWordView`, LargeWordView.swift): images at real widget sizes, as
/// `WidgetSnapshotTests` renders the other families (WidgetKit's default 16 pt margins passed in,
/// the rendering mode and the paper given to the view), its pure helpers, and what VoiceOver gets
/// from it, read as `WidgetVoiceOverTests` reads the other families.
/// Images (`large-<word><look>`): on a 393 pt wide iPhone (338 x 354 pt) by day, at night
/// (`-koyu`), tinted (`-renkli`, on a dark stand-in for the tinted background) and without its
/// paper in the system styles on black (`-gece`, the look of the system's night rendering); on an
/// iPhone SE (`large-se-…`, 321 x 324 pt) by day at the default and three larger text sizes
/// (`-xxxl`, `-ax1`, `-ax3`) and at night at AX3 (`-koyu-ax3`): the meaning must stay, and no line
/// may be cut or run under the buttons. The words are `LargeSnapshotWords`.
@MainActor
final class LargeWidgetSnapshotTests: XCTestCase {
    /// The appearance an image is rendered in; `suffix` is added to the attachment name.
    private struct Look {
        let suffix: String
        let colorScheme: ColorScheme
        let renderingMode: WidgetRenderingMode
        /// False when the system removes the widget's paper.
        var showsBackground = true
        var dynamicTypeSize = DynamicTypeSize.large
    }

    /// One accessibility element: its label, its language (or its label's speech language; nil
    /// for the device's voice) and its hint.
    private struct Element {
        let label: String
        let language: String?
        let hint: String?

        var isEnglish: Bool {
            return language?.lowercased().hasPrefix("en") == true
        }

        var isTurkish: Bool {
            return language?.lowercased().hasPrefix("tr") == true
        }
    }

    // Point sizes from the HIG widget size table.
    private let large = CGSize(width: 338, height: 354)
    private let largeSE = CGSize(width: 321, height: 324)
    private let margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private let day = Look(suffix: "", colorScheme: .light, renderingMode: .fullColor)
    private let night = Look(suffix: "-koyu", colorScheme: .dark, renderingMode: .fullColor)
    private let tinted = Look(suffix: "-renkli", colorScheme: .dark, renderingMode: .accented)
    private let noPaper = Look(suffix: "-gece", colorScheme: .dark, renderingMode: .vibrant, showsBackground: false)

    func testRenderLargeWidget() {
        let seLooks = [
            day,
            Look(suffix: "-xxxl", colorScheme: .light, renderingMode: .fullColor, dynamicTypeSize: .xxxLarge),
            Look(suffix: "-ax1", colorScheme: .light, renderingMode: .fullColor, dynamicTypeSize: .accessibility1),
            Look(suffix: "-ax3", colorScheme: .light, renderingMode: .fullColor, dynamicTypeSize: .accessibility3),
            Look(suffix: "-koyu-ax3", colorScheme: .dark, renderingMode: .fullColor, dynamicTypeSize: .accessibility3),
        ]
        for word in LargeSnapshotWords.all {
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            for look in [day, night, tinted, noPaper] {
                render(entry, size: large, look: look, name: "large-\(word.lemma)\(look.suffix)")
            }
            for look in seLooks {
                render(entry, size: largeSE, look: look, name: "large-se-\(word.lemma)\(look.suffix)")
            }
        }
    }

    /// The Dikkat line shows the part of the pair that differs, as the app's card does: one
    /// shared word on each side within the same sentence, the changed words marked, a missing
    /// word kept between its neighbours, the final punctuation and a Turkish note left out.
    func testMistakeSnippetKeepsThePartThatDiffers() {
        let spoon = LargeMistakeSnippet(wrong: "I have two spoon.", right: "I have two spoons.")
        XCTAssertEqual(spoon.wrong.map(\.text), ["two", "spoon"])
        XCTAssertEqual(spoon.wrong.map(\.isChanged), [false, true])
        XCTAssertEqual(spoon.right.map(\.text), ["two", "spoons"])
        XCTAssertEqual(spoon.right.map(\.isChanged), [false, true])

        let listen = LargeMistakeSnippet(wrong: "I listen music every day.", right: "I listen to music every day.")
        XCTAssertEqual(listen.wrongSpoken, "listen music")
        XCTAssertEqual(listen.rightSpoken, "listen to music")
        XCTAssertEqual(listen.wrong.map(\.isChanged), [false, false])
        XCTAssertEqual(listen.right.map(\.isChanged), [false, true, false])

        let actually = LargeMistakeSnippet(wrong: "Actually I'm studying English. (= şu anda)", right: "I'm currently studying English.")
        XCTAssertEqual(actually.wrongSpoken, "Actually I'm studying")
        XCTAssertEqual(actually.rightSpoken, "I'm currently studying")

        let endedUp = LargeMistakeSnippet(wrong: "We ended up to eat at home.", right: "We ended up eating at home.")
        XCTAssertEqual(endedUp.wrongSpoken, "up to eat at")
        XCTAssertEqual(endedUp.rightSpoken, "up eating at")

        // Only the first right option is compared.
        let options = LargeMistakeSnippet(wrong: "I am agree.", right: "I agree. / I am in agreement.")
        XCTAssertEqual(options.wrongSpoken, "I am agree")
        XCTAssertEqual(options.rightSpoken, "I agree")

        // Never into a neighbouring sentence (the 2026-10-24 images: "stop to talk. The"); the
        // whole sentence is there for when it fits.
        let talk = LargeMistakeSnippet(wrong: "I stopped to talk. The teacher came.", right: "I stopped talking. The teacher came.")
        XCTAssertEqual(talk.wrongSpoken, "stopped to talk")
        XCTAssertEqual(talk.rightSpoken, "stopped talking")
        XCTAssertEqual(talk.wrongSentenceSpoken, "I stopped to talk")
        XCTAssertEqual(talk.rightSentenceSpoken, "I stopped talking")
        let late = LargeMistakeSnippet(wrong: "It's late. Go home.", right: "It's late. Let's go home.")
        XCTAssertEqual(late.wrongSpoken, "Go")
        XCTAssertEqual(late.rightSpoken, "Let's go")
        XCTAssertEqual(spoon.wrongSentenceSpoken, "I have two spoon")
        XCTAssertEqual(spoon.rightSentenceSpoken, "I have two spoons")
    }

    /// An example is whole on one line or in balanced lines, the word bold across a line break;
    /// an irregular form is not marked.
    func testExampleCandidatesMarkTheWord() {
        let sentence = "I'm looking forward to the weekend."
        let candidates = LargeExampleText.candidates(sentence, lemma: "look forward to", lines: [1, 2])
        XCTAssertEqual(candidates.count, 2)
        XCTAssertEqual(candidates.first.map { lines in lines.map { plain($0) } }, [sentence])
        XCTAssertEqual(candidates.last.map { lines in lines.map { plain($0) } }, ["I'm looking forward", "to the weekend."])
        XCTAssertEqual(candidates.last.map { lines in lines.map { boldParts($0) } }, [["looking", "forward"], ["to"]])

        let fedUp = LargeExampleText.candidates("I'm fed up with this rain.", lemma: "be fed up with", lines: [1])
        XCTAssertEqual(fedUp.first.map { lines in lines.map { boldParts($0) } }, [["fed", "up", "with"]])
        let breakfast = LargeExampleText.candidates("Breakfast is ready.", lemma: "breakfast", lines: [1])
        XCTAssertEqual(breakfast.first.map { lines in lines.map { boldParts($0) } }, [["Breakfast"]])
        let teeth = LargeExampleText.candidates("I brush my teeth twice a day.", lemma: "tooth", lines: [1, 2])
        XCTAssertTrue(teeth.allSatisfy { lines in lines.allSatisfy { boldParts($0).isEmpty } })
        XCTAssertEqual(LargeExampleText.candidates(" ", lemma: "tooth", lines: [1, 2]).count, 0)
    }

    /// The plan's example and the second one, never an empty line; the definition only when the
    /// word has one (a user's word has none).
    func testLinesAWordDoesNotHaveAreLeftOut() throws {
        let awkward = try XCTUnwrap(LargeSnapshotWords.all.first { $0.lemma == "awkward" })
        XCTAssertEqual(LargeWordView.examples(of: awkward), [])
        XCTAssertEqual(LargeWordView.definitionCandidates(of: awkward, lines: [1, 2]), [])
        let breakfast = try XCTUnwrap(LargeSnapshotWords.all.first { $0.lemma == "breakfast" })
        XCTAssertEqual(
            LargeWordView.examples(of: breakfast),
            ["I usually have breakfast at seven.", "Ayşe made breakfast for the whole family."]
        )
        XCTAssertEqual(LargeWordView.definitionCandidates(of: breakfast, lines: []), [])
        XCTAssertEqual(
            LargeWordView.definitionCandidates(of: breakfast, lines: [1]),
            [["the first meal of the day, eaten in the morning"], ["first meal of the day"]]
        )
    }

    /// VoiceOver (ios/README.md point 14): the word once and the definition, the examples and the
    /// warning's English parts in an English voice; the meaning, the warning's Turkish parts, the
    /// next change and the buttons in a Turkish voice; "Biliyorum" with the 3-day hint; no empty
    /// element and no sign read aloud. Every element found is attached ("buyuk-widget-sesler").
    func testLargeWidgetVoices() throws {
        try XCTSkipUnless(LargeWidgetSnapshotTests.accessibilityEnabled, "accessibility automation is not available")
        RunLoop.main.run(until: Date().addingTimeInterval(1))
        var report = ["iOS \(UIDevice.current.systemVersion), preferred \(Locale.preferredLanguages)"]
        // Words whose fullest layout fits the 393 pt widget at the default size (a mistake, a
        // missing word, a false friend, a user's word), so every line asked about is shown.
        for id in [1, 240, 384, 1_000_001] {
            let word = try XCTUnwrap(LargeSnapshotWords.all.first { $0.id == id })
            let entry = WordEntry(date: now, word: word, nextChange: now.addingTimeInterval(3600))
            let found = elements(
                of: LargeWordView(entry: entry, margins: margins, renderingMode: .fullColor, showsBackground: true),
                size: large
            )
            report.append("== large \(word.lemma)")
            report.append(contentsOf: found.map { element in
                "  label=\(element.label) lang=\(element.language ?? "nil") hint=\(element.hint ?? "nil")"
            })
            check(found, of: word)
        }
        for line in report {
            print("BUYUKSES \(line)")
        }
        let attachment = XCTAttachment(string: report.joined(separator: "\n"))
        attachment.name = "buyuk-widget-sesler"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func check(_ elements: [Element], of word: WidgetWord) {
        let context = "large \(word.lemma): " + elements.map { "\($0.label) [\($0.language ?? "nil")]" }.joined(separator: " | ")
        var isFalseFriend = false
        if case .falseFriend? = word.warning {
            isFalseFriend = true
        }
        // The word once; a false friend's line says it once more ("aktüel ≠ actually").
        let headwords = elements.filter { $0.label == word.lemma }
        XCTAssertEqual(headwords.count, isFalseFriend ? 2 : 1, context)
        XCTAssertTrue(headwords.allSatisfy { $0.isEnglish }, context)
        let meanings = elements.filter { $0.label == "Türkçesi: \(word.glossTR ?? "")" }
        XCTAssertEqual(meanings.count, 1, context)
        XCTAssertTrue(meanings.allSatisfy { $0.isTurkish }, context)
        XCTAssertFalse(elements.contains { $0.label.trimmingCharacters(in: .whitespaces).isEmpty }, context)
        for sign in ["·", "≠", "=", "→"] {
            XCTAssertFalse(elements.contains { $0.label == sign }, context)
        }
        let know = elements.filter { $0.label == "Biliyorum" }
        XCTAssertEqual(know.count, 1, context)
        XCTAssertEqual(know.first?.hint, KnowWordButton.hint, context)
        XCTAssertTrue(know.allSatisfy { $0.isTurkish }, context)
        XCTAssertTrue(elements.contains { $0.label == "Kelimeyi dinle" && $0.isTurkish }, context)
        XCTAssertTrue(elements.contains { $0.label == "Sonraki kelime" && $0.isTurkish }, context)
        if word.level.isEmpty {
            XCTAssertFalse(elements.contains { $0.label.hasPrefix("Seviye") }, context)
        } else {
            XCTAssertTrue(elements.contains { $0.label == "Seviye \(word.level)" && $0.isTurkish }, context)
        }
        if !word.isUserAdded {
            XCTAssertTrue(
                elements.contains { ($0.label == word.defShort || $0.label == word.defMicro) && $0.isEnglish },
                context
            )
            XCTAssertTrue(elements.contains { $0.label == word.exampleEN && $0.isEnglish }, context)
        }
        switch word.warning {
        case let .falseFriend(turkish, english)?:
            XCTAssertTrue(elements.contains { $0.label == "Sahte dost: \(turkish), eşit değil" && $0.isTurkish }, context)
            XCTAssertTrue(elements.contains { $0.label == english && $0.isEnglish }, context)
        case .mistake?:
            XCTAssertTrue(elements.contains { $0.label == "Dikkat. Yanlış:" && $0.isTurkish }, context)
            XCTAssertTrue(elements.contains { $0.label == "Doğru:" && $0.isTurkish }, context)
        case nil:
            XCTAssertFalse(elements.contains { $0.label.hasPrefix("Dikkat") || $0.label.hasPrefix("Sahte dost") }, context)
        }
        // "Yeni kelime: 09:00" on screen, "Sonraki değişim: 09:00" for VoiceOver (the 393 pt
        // widget has room for it at the default size).
        XCTAssertTrue(elements.contains { $0.label.hasPrefix("Sonraki değişim: ") && $0.isTurkish }, context)
    }

    // MARK: - Rendering

    /// What WidgetKit would draw behind the view: the widget's `surface` in full color, black
    /// without the paper, a dark tinted panel otherwise.
    @ViewBuilder
    private func backdrop(for look: Look) -> some View {
        if look.renderingMode == .fullColor && look.showsBackground {
            Theme.surface
        } else if !look.showsBackground {
            Color.black
        } else {
            Color(red: 0.09, green: 0.10, blue: 0.12)
        }
    }

    private func render(_ entry: WordEntry, size: CGSize, look: Look, name: String) {
        let content = LargeWordView(
            entry: entry,
            margins: margins,
            renderingMode: look.renderingMode,
            showsBackground: look.showsBackground
        )
        .frame(width: size.width, height: size.height)
        .background {
            self.backdrop(for: look)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .environment(\.colorScheme, look.colorScheme)
        .environment(\.dynamicTypeSize, look.dynamicTypeSize)
        let renderer = ImageRenderer(content: content)
        // 2x, not the other families' 3x: 180 images of this size.
        renderer.scale = 2
        guard let image = renderer.uiImage else {
            XCTFail("could not render \(name)")
            return
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func plain(_ text: AttributedString) -> String {
        return String(text.characters)
    }

    /// The bold runs of `text`, in order.
    private func boldParts(_ text: AttributedString) -> [String] {
        return text.runs.compactMap { run -> String? in
            guard run.inlinePresentationIntent == .stronglyEmphasized else {
                return nil
            }
            return String(text[run.range].characters)
        }
    }

    // MARK: - Reading the accessibility elements (as WidgetVoiceOverTests reads them)

    /// SwiftUI builds its accessibility tree only while an assistive client is active: the
    /// automation client is turned on in this process (KIF's approach, as in is3-tema's probe).
    private static let accessibilityEnabled: Bool = {
        guard let handle = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW),
              let symbol = dlsym(handle, "_AXSSetAutomationEnabled") else {
            return false
        }
        typealias SetEnabled = @convention(c) (Int32) -> Void
        unsafeBitCast(symbol, to: SetEnabled.self)(1)
        return true
    }()

    private func elements<V: View>(of view: V, size: CGSize) -> [Element] {
        let host = UIHostingController(rootView: view.frame(width: size.width, height: size.height))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.8))
        _ = host.view.accessibilityElements
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
        var found: [Element] = []
        walk(host.view, depth: 0, into: &found)
        window.isHidden = true
        return found
    }

    private func walk(_ node: NSObject, depth: Int, into found: inout [Element]) {
        guard depth < 12 else {
            return
        }
        if node.isAccessibilityElement {
            found.append(Element(
                label: node.accessibilityLabel ?? "",
                language: language(of: node),
                hint: node.accessibilityHint
            ))
        }
        var children: [NSObject] = []
        if let elements = node.accessibilityElements as? [NSObject], !elements.isEmpty {
            children = elements
        } else {
            let count = node.accessibilityElementCount()
            if count != NSNotFound && count > 0 {
                for index in 0..<count {
                    if let child = node.accessibilityElement(at: index) as? NSObject {
                        children.append(child)
                    }
                }
            }
        }
        if children.isEmpty, let view = node as? UIView {
            children = view.subviews
        }
        for child in children {
            walk(child, depth: depth + 1, into: &found)
        }
    }

    /// The element's language, else the speech-language attribute of its label.
    private func language(of node: NSObject) -> String? {
        if let language = node.accessibilityLanguage, !language.isEmpty {
            return language
        }
        guard let attributed = node.accessibilityAttributedLabel, attributed.length > 0 else {
            return nil
        }
        var speech: String?
        attributed.enumerateAttributes(in: NSRange(location: 0, length: attributed.length)) { values, _, _ in
            for (key, value) in values where speech == nil && key.rawValue.hasSuffix("Language") {
                speech = "\(value)"
            }
        }
        return speech
    }
}

/// The snapshot words (`SnapshotWords`) with their large widget details as the app writes them
/// into the plan (`addingLargeWidgetDetails(from:)`), taken once from content.sqlite
/// (2026.10.22-kisisel-9; refresh by hand if the texts change): each card's second example
/// (besides the example in `SnapshotWords`) and its warning. Three more cards show the warnings:
/// a false friend that also has a mistake ("fabric"), a missing word ("listen") and an irregular
/// plural in the Dikkat pair ("tooth"). The user's own words have neither.
enum LargeSnapshotWords {
    static let all: [WidgetWord] = SnapshotWords.all.map { word -> WidgetWord in
        var large = word
        large.secondExampleEN = secondExamples[word.id]
        large.warning = warnings[word.id]
        return large
    } + extra

    private static let secondExamples: [Int: String] = [
        1: "Ayşe made breakfast for the whole family.",
        311: "We're looking forward to seeing you again.",
        399: "I planned to go out, but I ended up staying home.",
        11: "Please put the cheese back in the fridge.",
        140: "How was your date with Elif?",
        286: "Actually, I'd prefer tea, if that's okay.",
        807: "Hi, could you tell me the way to the nearest pharmacy?",
        905: "Maria found her scarf at the lost and found.",
        882: "Elif stayed at home because she was under the weather.",
        899: "Most misunderstandings happen when people don't ask questions.",
        820: "Priya arrives on Friday. I can't wait to see her!",
        801: "Mehmet and his brother often disagree about music.",
        939: "I called Murat the day before yesterday, but he didn't answer.",
        541: "The bus stops in front of my house.",
        965: "The man at the market looked at me and asked, “Cash or card?”",
    ]

    private static let warnings: [Int: WidgetWarning] = [
        1: .mistake(wrong: "I did breakfast at eight.", right: "I had breakfast at eight."),
        311: .mistake(wrong: "I look forward to see you.", right: "I look forward to seeing you."),
        399: .mistake(wrong: "We ended up to eat at home.", right: "We ended up eating at home."),
        140: .mistake(wrong: "I have a date at the dentist.", right: "I have an appointment at the dentist."),
        286: .falseFriend(turkish: "aktüel", english: "current / currently"),
        807: .mistake(wrong: "Could you tell me the way to station?", right: "Could you tell me the way to the station?"),
        820: .mistake(wrong: "I can't wait for see you!", right: "I can't wait to see you!"),
        801: .mistake(wrong: "I am disagree with you.", right: "I disagree with you."),
        939: .mistake(wrong: "I saw her before yesterday.", right: "I saw her the day before yesterday."),
        541: .mistake(wrong: "Please stop to talk. The baby is sleeping.", right: "Please stop talking. The baby is sleeping."),
    ]

    private static var extra: [WidgetWord] {
        var fabric = WidgetWord(
            id: 384, lemma: "fabric", pos: "n", level: "B1", ipaUS: "/ˈfæbrɪk/",
            defMicro: "cloth used to make clothes", defShort: "cloth that is used to make clothes, curtains, or other things",
            exampleEN: "This dress is made of soft fabric.", glossTR: "kumaş"
        )
        fabric.secondExampleEN = "Cotton is a good fabric for hot summer days."
        fabric.warning = .falseFriend(turkish: "fabrika", english: "factory")
        var listen = WidgetWord(
            id: 240, lemma: "listen", pos: "v", level: "A2", ipaUS: "/ˈlɪsən/",
            defMicro: "pay attention to sounds", defShort: "give your attention to a sound or to someone who is speaking",
            exampleEN: "He never listens when I talk.", glossTR: "dinlemek"
        )
        listen.secondExampleEN = "I listen to music on the bus every morning."
        listen.warning = .mistake(wrong: "I listen music every day.", right: "I listen to music every day.")
        var tooth = WidgetWord(
            id: 604, lemma: "tooth", pos: "n", level: "A1", ipaUS: "/tuːθ/",
            defMicro: "hard white part in the mouth", defShort: "one of the hard white parts in your mouth that you use to bite and chew food",
            exampleEN: "Ali's tooth hurts, so he is going to the dentist.", glossTR: "diş"
        )
        tooth.secondExampleEN = "Babies get their first tooth at about six months."
        tooth.warning = .mistake(wrong: "I brush my tooths every morning.", right: "I brush my teeth every morning.")
        return [fabric, listen, tooth]
    }
}
