import SwiftUI
import WidgetKit
import AppIntents
import CoreModels

// The large Home Screen widget (`systemLarge`; docs/tasarim/README.md "Widget'lar",
// docs/tasarim/ogrenme_ilkeleri.md 2.1 and 2.2): the medium widget's reading order with room to
// teach. The word large with the phosphor band and its level, the pronunciation, the Turkish
// meaning, the short English definition, two examples with the word in bold, the card's one
// warning (a false friend or the Dikkat mistake, written as the app's card writes it) and the next
// change. Paper and ink as on the other home widgets (`WidgetColors`); English text serif,
// Turkish and UI text SF Pro; the band is the only yellow mark, so the examples mark the word in
// bold. The second example and the warning come with the plan (`WidgetWord.secondExampleEN`,
// `warning`; CoreModels/WidgetWarning.swift); a seed word or the user's own word simply has fewer
// lines.
// The family is 338 x 354 pt on a 393 pt wide iPhone and 321 x 324 pt on an iPhone SE, so about
// 306 x 322 and 289 x 292 pt inside the 16 pt margins.
// Buttons (WidgetButtons.swift's intents): Know, speaker and Next in a row at the bottom, each a
// 34 pt circle with its short name under it (ogrenme_ilkeleri 2.1: "simgelerin altında kısa
// yazıyla"; docs/tasarim/terimler.md §3). Next sits in the easy corner (bottom right), Know the
// farthest from it (bottom left). The row reaches only a little into the side and bottom margins
// (`largeButtonSideOverflow`, `largeButtonBottomOverflow`): the outer circles and their names line
// up with the text at 16 pt from the sides, and the names end 12 pt above the bottom edge (with
// the small widget's 11 pt the names, wider than the circles, ran into Apple's margin); the text
// column keeps the full 16 pt margins and never runs under the row, which takes its own height.
// Type: four sizes (HIG: hierarchy by size and weight): the word at Title 28 (smaller steps when
// it does not fit), the meaning Title 3 bold, the definition and the examples Subheadline serif,
// and Footnote for the pronunciation, the level, the warning, the next change and the button
// names.
// Layout, as on the medium widget: a vertical ViewThatFits over variants, fullest first; every
// line is shown whole or not at all, never cut with "…" and never broken inside a word. The card
// shortens from its end (README rule 5): the next change gives way first, then the examples drop
// to one line, the second example goes, then the pronunciation, the first example, the warning and
// the definition. The warning takes one line when it fits and two otherwise; it stays longer than
// the examples, as the card's warning slot comes before its further examples (ogrenme_ilkeleri
// 2.2). Then the whole meaning gets smaller, with the definition and an example kept beside it,
// and only then does the meaning shorten (`WidgetGloss`), again with the definition first, so the
// meaning does not change with the text size while the whole one fits (ogrenme_ilkeleri 2.2:
// nothing hides the meaning before the definition). When the word
// and the meaning do not fit at the person's text size they are tried again at AX1, at xxxLarge
// and at the default size, as on the medium widget, so the meaning stays at every text size; the
// word alone is the last resort.

/// How far the button row reaches into the side margins: with the 5 pt between a circle and its
/// hit area, the outer circles and names sit 16 - 5 + 5 = 16 pt from the sides, in line with the
/// text.
private let largeButtonSideOverflow: CGFloat = 5
/// How far the button row reaches into the bottom margin: the names end 16 - 4 = 12 pt above the
/// bottom edge.
private let largeButtonBottomOverflow: CGFloat = 4
/// Space under the word: the night band hangs about 5 pt below a 28 pt word's frame (LockglowTheme,
/// "Phosphor band"; `headerGap` is 6 pt for the medium widget's 20 pt word).
private let largeHeaderGap: CGFloat = 7

struct LargeWordView: View {
    let entry: WordEntry
    /// The widget's content margins (`widgetContentMargins`); WidgetKit's default for home widgets.
    var margins = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    /// Replaces the environment's `showsWidgetContainerBackground` (snapshot tests only).
    var showsBackground: Bool? = nil
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    @Environment(\.showsWidgetContainerBackground) private var environmentShowsBackground
    private var word: WidgetWord { entry.word }
    private var mode: WidgetRenderingMode { renderingMode ?? environmentRenderingMode }
    private var paper: Bool { showsBackground ?? environmentShowsBackground }
    private var colors: WidgetColors { WidgetColors.forMode(mode, showsBackground: paper) }
    /// Full color on the widget's paper (`WidgetColors.tokens`): the warning's symbols keep the
    /// theme's caution, bad and good colors; tinted, they take the quiet text style.
    private var isFullColor: Bool { mode == .fullColor && paper }

    static let meaningFont = Font.title3.weight(.bold)
    /// The smaller meaning, tried before the meaning is left out.
    static let smallMeaningFont = Font.body.weight(.bold)
    static let definitionFont = Font.system(.subheadline, design: .serif)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // The retries are groups: a modifier on a Group applies to each of its views, and
            // ViewThatFits tries them one by one, as if they were listed here.
            ViewThatFits(in: .vertical) {
                Group {
                    column(shortens: false, pronunciation: true, definition: [1, 2], examples: 2, warning: [1, 2], nextChange: true)
                    column(shortens: false, pronunciation: true, definition: [1, 2], examples: 2, warning: [1, 2])
                    column(shortens: false, pronunciation: true, definition: [1, 2], examples: 2, exampleLines: [1], warning: [1, 2])
                    column(shortens: false, pronunciation: true, definition: [1, 2], examples: 1, exampleLines: [1, 2, 3], warning: [1, 2])
                    column(shortens: false, definition: [1, 2], examples: 1, exampleLines: [1, 2, 3], warning: [1, 2])
                    column(shortens: false, definition: [1, 2], warning: [1, 2])
                    column(shortens: false, definition: [1, 2])
                }
                // The whole meaning smaller before its shorter form, so the meaning does not
                // change with the text size while the whole one fits; the definition and an
                // example stay beside either before the meaning stands alone (at AX3 the meaning
                // alone left half the widget empty).
                Group {
                    column(meaning: LargeWordView.smallMeaningFont, shortens: false, definition: [1, 2], examples: 1, exampleLines: [1, 2, 3])
                    column(meaning: LargeWordView.smallMeaningFont, shortens: false, definition: [1, 2])
                    column(shortens: false)
                    column(meaning: LargeWordView.smallMeaningFont, shortens: false)
                    column(definition: [1, 2], examples: 1, exampleLines: [1, 2, 3])
                    column(definition: [1, 2])
                    column(meaning: LargeWordView.smallMeaningFont, definition: [1, 2])
                    column()
                    column(meaning: LargeWordView.smallMeaningFont)
                }
                // Above AX1: one step smaller first, so a larger size never shows smaller text
                // than AX1.
                retryVariants()
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                retryVariants()
                    .dynamicTypeSize(...WidgetText.largestStandardSize)
                // The text area does not grow with the text size: at the default size this draws
                // the default layout, which has the meaning.
                Group {
                    column(meaning: LargeWordView.smallMeaningFont, shortens: false)
                    column(meaning: LargeWordView.smallMeaningFont)
                }
                .dynamicTypeSize(...DynamicTypeSize.large)
                wordRow(lastResort: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, margins.top)
            .padding(.leading, margins.leading)
            .padding(.trailing, margins.trailing)
            LargeWidgetButtonRow(word: word, colors: colors)
                .padding(.leading, max(margins.leading - largeButtonSideOverflow, 0))
                .padding(.trailing, max(margins.trailing - largeButtonSideOverflow, 0))
                .padding(.bottom, max(margins.bottom - largeButtonBottomOverflow, 0))
        }
        .widgetTurkishVoice()
    }

    /// The variants tried again at a smaller text size: the whole meaning, then its shorter form,
    /// each with the definition first.
    private func retryVariants() -> some View {
        Group {
            column(shortens: false, definition: [1, 2])
            column(shortens: false)
            column(meaning: LargeWordView.smallMeaningFont, shortens: false, definition: [1, 2])
            column(meaning: LargeWordView.smallMeaningFont, shortens: false)
            column(definition: [1, 2])
            column()
            column(meaning: LargeWordView.smallMeaningFont)
        }
    }

    /// The word row: the word at the first of its size steps that fits whole, and the level code.
    /// With `lastResort` the word is never passed over and may drop to an unscaled 15 pt
    /// (`WidgetWordStep.mediumWidget`); beside a meaning it grows with the text size.
    private func wordRow(lastResort: Bool = false) -> some View {
        WidgetWordRow(
            lemma: word.lemma,
            steps: lastResort ? WidgetWordStep.mediumWidget : WidgetWordStep.largeWidgetScaled,
            lastResort: lastResort,
            // A user's own word has no level.
            level: word.level.isEmpty ? nil : word.level,
            colors: colors,
            renderingMode: renderingMode
        )
    }

    /// One layout variant: the meaning on one or two lines, whole (`shortens` false) or in its
    /// shorter forms too, and the optional lines that follow it: the pronunciation under the word,
    /// the definition on the first of `definition` line counts that fits, `examples` examples each
    /// on the first of `exampleLines`, the warning on the first of `warning` and the next change
    /// at the bottom. A line that is asked for and does not fit makes the variant too tall to be
    /// chosen (`WidgetFit.reject`); a line the word does not have is simply left out.
    private func column(
        meaning typeface: Font = LargeWordView.meaningFont,
        shortens: Bool = true,
        pronunciation: Bool = false,
        definition: [Int] = [],
        examples count: Int = 0,
        exampleLines: [Int] = [1, 2],
        warning warningLines: [Int] = [],
        nextChange: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            wordRow()
            let ipa = pronunciation ? (word.ipaUS ?? "") : ""
            if !ipa.isEmpty {
                WidgetIPA(ipa: ipa, color: colors.ink2)
                    .padding(.top, largeHeaderGap)
            }
            VStack(alignment: .leading, spacing: 4) {
                let forms = WidgetGloss.forms(of: word)
                if !forms.isEmpty {
                    WidgetMeaning(
                        forms: shortens ? forms : Array(forms.prefix(1)),
                        typeface: typeface,
                        lines: [1, 2],
                        color: colors.ink
                    )
                }
                // A user's own word has no definition: no empty line.
                let definitions = LargeWordView.definitionCandidates(of: word, lines: definition)
                if !definitions.isEmpty {
                    WidgetFittingText(candidates: definitions, typeface: LargeWordView.definitionFont, color: colors.ink2)
                        .englishVoice()
                }
            }
            .padding(.top, ipa.isEmpty ? largeHeaderGap : 4)
            let sentences = Array(LargeWordView.examples(of: word).prefix(count))
            if !sentences.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(sentences.enumerated()), id: \.offset) { _, sentence in
                        LargeExampleText(sentence: sentence, lemma: word.lemma, lines: exampleLines, color: colors.ink)
                    }
                }
                .padding(.top, 10)
            }
            if !warningLines.isEmpty, let warning = word.warning {
                LargeWarningLine(
                    warning: warning,
                    lemma: word.lemma,
                    lines: warningLines,
                    colors: colors,
                    isFullColor: isFullColor
                )
                .padding(.top, 8)
            }
            Spacer(minLength: 0)
            if nextChange, let next = entry.nextChange {
                // "Yeni kelime: 09:00" as on the medium widget: no Turkish suffix after the time
                // (README point 13); VoiceOver says "Sonraki değişim: 09:00".
                let clock = WidgetTime.clock(next)
                WidgetFittingText(
                    candidates: [["Yeni kelime: \(clock)"]],
                    typeface: .footnote.weight(.medium),
                    color: colors.ink2
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "Sonraki değişim: \(clock)"))
                .padding(.top, 4)
            }
        }
    }

    /// The definition's candidates: the short definition on each of `lines` line counts, then the
    /// micro one; empty when no line count is asked for or the word has neither (a user's word).
    static func definitionCandidates(of word: WidgetWord, lines: [Int]) -> [[String]] {
        guard !lines.isEmpty else {
            return []
        }
        return WidgetText.candidates([word.defShort], lines: lines) + WidgetText.candidates([word.defMicro], lines: lines)
    }

    /// The plan's example (the medium widget's) and the second one, without empty ones.
    static func examples(of word: WidgetWord) -> [String] {
        return [word.exampleEN, word.secondExampleEN ?? ""].filter { sentence in
            !sentence.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
}

extension WidgetWordStep {
    /// The large widget beside a meaning: 28, 22, 20 pt on one line (Title, Title 2, Title 3
    /// sizes), a phrase on two lines at 22 or 20 pt, then 17 pt on one line ("misunderstanding" at
    /// large text sizes), all scaled with Dynamic Type.
    static let largeWidgetScaled = [
        WidgetWordStep(size: 28),
        WidgetWordStep(size: 22),
        WidgetWordStep(size: 20),
        WidgetWordStep(size: 22, lines: 2),
        WidgetWordStep(size: 20, lines: 2),
        WidgetWordStep(size: 17),
    ]
}

/// An English example on the large widget, whole on the first of `lines` line counts whose every
/// line fits the width (balanced lines, `WidgetText.balancedLines`), never cut. The word is bold
/// wherever `LemmaMatch` finds it, across a line break too ("looking forward / to the weekend");
/// the band stays the widget's only yellow mark (as on the medium widget, `ExampleMark` without
/// the highlight). An irregular form is not found and stays plain. When no line count fits, the
/// variant around it is passed over (`WidgetFit.reject`). VoiceOver reads the whole sentence once,
/// with an English voice.
struct LargeExampleText: View {
    let sentence: String
    let lemma: String
    /// The line counts to try, in order.
    var lines = [1, 2]
    let color: AnyShapeStyle

    static let font = Font.system(.subheadline, design: .serif)

    var body: some View {
        let slots = WidgetFit.slots(LargeExampleText.candidates(sentence, lemma: lemma, lines: lines))
        if slots.isEmpty {
            WidgetFit.reject
        } else {
            ViewThatFits(in: .horizontal) {
                text(slots[0])
                text(slots[1])
                text(slots[2])
                text(slots[3])
                text(slots[4])
                text(slots[5])
                WidgetFit.reject
            }
        }
    }

    private func text(_ lines: [AttributedString]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(LargeExampleText.font)
                    .foregroundStyle(color)
                    .lineLimit(1)
            }
        }
        // An explicit label, not `.combine`: a combined element loses the English voice.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: sentence))
        .englishVoice()
    }

    /// For each line count in turn, the sentence in that many balanced lines with the word bold,
    /// without repeats (a short sentence is one line for every count). Empty for an empty
    /// sentence.
    static func candidates(_ sentence: String, lemma: String, lines counts: [Int]) -> [[AttributedString]] {
        guard !sentence.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        // Substrings share the sentence's indices, as `LemmaMatch`'s range does.
        let words = sentence.split(separator: " ")
        let match = LemmaMatch.range(of: lemma, in: sentence)
        var result: [[AttributedString]] = []
        for count in counts {
            var next = 0
            var candidate: [AttributedString] = []
            // `balancedLines` breaks between the same words, so each line takes the next run.
            for line in WidgetText.balancedLines(sentence, count: count) {
                let end = min(next + line.split(separator: " ").count, words.count)
                var text = AttributedString()
                for (index, word) in words[min(next, end)..<end].enumerated() {
                    if index > 0 {
                        text.append(AttributedString(" "))
                    }
                    text.append(marked(word, in: sentence, match: match))
                }
                candidate.append(text)
                next = end
            }
            if !result.contains(candidate) {
                result.append(candidate)
            }
        }
        return result
    }

    /// `word` with the part that lies in `match` bold.
    private static func marked(_ word: Substring, in sentence: String, match: Range<String.Index>?) -> AttributedString {
        guard let match = match, match.overlaps(word.startIndex..<word.endIndex) else {
            return AttributedString(String(word))
        }
        let start = max(match.lowerBound, word.startIndex)
        let end = min(match.upperBound, word.endIndex)
        var bold = AttributedString(String(sentence[start..<end]))
        bold.inlinePresentationIntent = .stronglyEmphasized
        var result = AttributedString(String(sentence[word.startIndex..<start]))
        result.append(bold)
        result.append(AttributedString(String(sentence[end..<word.endIndex])))
        return result
    }
}

/// The card's one warning on the large widget, written as the app's card writes it
/// (`CardWarningLine`, ogrenme_ilkeleri 2.2): a false friend "⚠ aktüel ≠ actually · aktüel =
/// current", a mistake "✕ two spoon → ✓ two spoons" (the part that differs,
/// `LargeMistakeSnippet`). On one line, else on two (the halves around the "·" or the "→"); when
/// neither fits, the variant around it is passed over. Shapes, not color alone, carry the meaning
/// (README rule 4): the symbols have the theme's caution, bad and good colors only in full color.
/// VoiceOver reads each part in its own language and the symbols and signs in Turkish words, as on
/// the card: "Sahte dost: aktüel, eşit değil", "actually", "aktüel, İngilizcede", "current"; or
/// "Dikkat. Yanlış:", "two spoon", "Doğru:", "two spoons".
struct LargeWarningLine: View {
    /// A piece of the line.
    enum Piece {
        /// An SF Symbol in `tint` (full color only), read as `spoken`; nil hides it from VoiceOver.
        case symbol(String, tint: Color, spoken: String?)
        /// Turkish text in SF; VoiceOver reads `spoken` with the Turkish voice.
        case turkish(String, spoken: String)
        /// English text in serif; VoiceOver reads `spoken` with an English voice.
        case english(AttributedString, spoken: String, bold: Bool)
        /// "≠", "=", "→", "·": VoiceOver skips them; the Turkish words around say them.
        case sign(String)
    }

    let warning: WidgetWarning
    let lemma: String
    /// The line counts to try, in order (1 and 2).
    var lines = [1, 2]
    let colors: WidgetColors
    /// Full color on the widget's paper.
    let isFullColor: Bool

    static let turkishFont = Font.footnote
    static let englishFont = Font.system(.footnote, design: .serif)

    var body: some View {
        // A mistake's whole sentences when they fit, else the part that differs: on one line
        // first, then on two.
        ViewThatFits(in: .horizontal) {
            oneLine(halves(whole: true))
            oneLine(halves(whole: false))
            twoLines(halves(whole: true))
            twoLines(halves(whole: false))
            WidgetFit.reject
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func oneLine(_ halves: (first: [Piece], joint: Piece, second: [Piece])) -> some View {
        if lines.contains(1) {
            row(halves.first + [halves.joint] + halves.second)
        } else {
            WidgetFit.reject
        }
    }

    @ViewBuilder
    private func twoLines(_ halves: (first: [Piece], joint: Piece, second: [Piece])) -> some View {
        if lines.contains(2) {
            VStack(alignment: .leading, spacing: 2) {
                row(halves.first)
                row(halves.second)
            }
        } else {
            WidgetFit.reject
        }
    }

    /// The line's two halves and the sign between them on one line; with `whole` a mistake's
    /// whole sentences (`LargeMistakeSnippet.wrongSentence`), else the part that differs.
    private func halves(whole: Bool) -> (first: [Piece], joint: Piece, second: [Piece]) {
        switch warning {
        case let .falseFriend(turkish, english):
            return (
                first: [
                    .symbol("exclamationmark.triangle", tint: Theme.caution, spoken: nil),
                    .turkish(turkish, spoken: "Sahte dost: \(turkish), eşit değil"),
                    .sign("≠"),
                    .english(AttributedString(lemma), spoken: lemma, bold: false),
                ],
                joint: .sign("·"),
                second: [
                    .turkish(turkish, spoken: "\(turkish), İngilizcede"),
                    .sign("="),
                    .english(AttributedString(english), spoken: english, bold: false),
                ]
            )
        case let .mistake(wrong, right):
            let snippet = LargeMistakeSnippet(wrong: wrong, right: right)
            return (
                first: [
                    .symbol("xmark", tint: Theme.bad, spoken: "Dikkat. Yanlış:"),
                    .english(snippet.wrongText(color: isFullColor ? Theme.bad : nil, whole: whole), spoken: whole ? snippet.wrongSentenceSpoken : snippet.wrongSpoken, bold: false),
                ],
                joint: .sign("→"),
                second: [
                    .symbol("checkmark", tint: Theme.good, spoken: "Doğru:"),
                    .english(snippet.rightText(whole: whole), spoken: whole ? snippet.rightSentenceSpoken : snippet.rightSpoken, bold: true),
                ]
            )
        }
    }

    private func row(_ pieces: [Piece]) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            ForEach(Array(pieces.enumerated()), id: \.offset) { _, piece in
                view(of: piece)
            }
        }
    }

    @ViewBuilder
    private func view(of piece: Piece) -> some View {
        switch piece {
        case let .symbol(name, tint, spoken):
            let image = Image(systemName: name)
                .font(LargeWarningLine.turkishFont.weight(.semibold))
                .foregroundStyle(isFullColor ? AnyShapeStyle(tint) : colors.ink2)
            if let spoken = spoken {
                image
                    .accessibilityLabel(Text(verbatim: spoken))
            } else {
                image
                    .accessibilityHidden(true)
            }
        case let .turkish(text, spoken):
            Text(verbatim: text)
                .font(LargeWarningLine.turkishFont)
                .foregroundStyle(colors.ink)
                .lineLimit(1)
                .accessibilityLabel(Text(verbatim: spoken))
        case let .english(text, spoken, bold):
            Text(text)
                .font(bold ? LargeWarningLine.englishFont.weight(.bold) : LargeWarningLine.englishFont)
                .foregroundStyle(colors.ink)
                .lineLimit(1)
                .accessibilityLabel(Text(verbatim: spoken))
                .englishVoice()
        case let .sign(text):
            Text(verbatim: text)
                .font(LargeWarningLine.turkishFont)
                .foregroundStyle(colors.ink2)
                .accessibilityHidden(true)
        }
    }
}

/// The part of a Dikkat pair that differs, with one shared word on each side, as the app's card
/// shows it (`MistakeSnippet` in CardDetailViews.swift, which the widget does not compile): "I
/// have two spoon." / "I have two spoons." gives "two spoon" / "two spoons"; a missing word keeps
/// the words around its place ("listen music" / "listen to music"). The words are compared by the
/// shared `MistakeDiff` (the first right option, ignoring case and punctuation) and keep its marks.
/// The part never reaches into a neighbouring sentence: a shared word beyond a sentence's end
/// (".", "!", "?") is left out ("stop to talk", not "stop to talk. The"). The whole sentences
/// around the part (`wrongSentence`, `rightSentence`) are shown instead when they fit. A Turkish
/// note in the sentence ("(= şu anda)") is left out, and a part that reaches the end of its
/// sentence drops the final punctuation.
struct LargeMistakeSnippet: Equatable {
    struct Word: Equatable {
        let text: String
        /// Not in the other sentence: marked as `MistakeDiff` marks it.
        let isChanged: Bool
    }

    let wrong: [Word]
    let right: [Word]
    /// The whole sentences that hold `wrong` and `right`.
    let wrongSentence: [Word]
    let rightSentence: [Word]

    init(wrong: String, right: String) {
        let diff = MistakeDiff(wrong: LargeMistakeSnippet.withoutNotes(wrong), right: LargeMistakeSnippet.withoutNotes(right))
        let wrongWords = LargeMistakeSnippet.words(diff.wrong)
        let rightWords = LargeMistakeSnippet.words(diff.right)
        // MistakeDiff marks every word with letters that is not on the longest common
        // subsequence, so the unmarked words with letters are that subsequence, in the same order
        // in both sentences.
        let wrongShared = wrongWords.indices.filter { LargeMistakeSnippet.isShared(wrongWords[$0]) }
        let rightShared = rightWords.indices.filter { LargeMistakeSnippet.isShared(rightWords[$0]) }
        var wrongRange = 0..<wrongWords.count
        var rightRange = 0..<rightWords.count
        if !wrongWords.isEmpty, !rightWords.isEmpty, wrongShared.count == rightShared.count {
            // The shared words, with one before the start and one after the end: a gap between
            // two neighbours is a difference.
            let pairs = zip(wrongShared, rightShared).map { pair in (wrong: pair.0, right: pair.1) }
            let anchors: [(wrong: Int, right: Int)] = [(wrong: -1, right: -1)] + pairs + [(wrong: wrongWords.count, right: rightWords.count)]
            var firstGap: Int?
            var lastGap = 0
            for index in 0..<(anchors.count - 1) {
                let here = anchors[index]
                let next = anchors[index + 1]
                if next.wrong - here.wrong > 1 || next.right - here.right > 1 {
                    firstGap = firstGap ?? index
                    lastGap = index
                }
            }
            if let firstGap = firstGap {
                let start = anchors[firstGap]
                let end = anchors[lastGap + 1]
                wrongRange = LargeMistakeSnippet.withinSentence(from: start.wrong, to: end.wrong, in: wrongWords)
                rightRange = LargeMistakeSnippet.withinSentence(from: start.right, to: end.right, in: rightWords)
            }
        }
        self.wrong = LargeMistakeSnippet.trimmed(wrongWords, in: wrongRange)
        self.right = LargeMistakeSnippet.trimmed(rightWords, in: rightRange)
        self.wrongSentence = LargeMistakeSnippet.trimmed(wrongWords, in: LargeMistakeSnippet.sentences(around: wrongRange, in: wrongWords))
        self.rightSentence = LargeMistakeSnippet.trimmed(rightWords, in: LargeMistakeSnippet.sentences(around: rightRange, in: rightWords))
    }

    /// The wrong words as plain text (VoiceOver).
    var wrongSpoken: String {
        return wrong.map(\.text).joined(separator: " ")
    }

    /// The right words as plain text (VoiceOver).
    var rightSpoken: String {
        return right.map(\.text).joined(separator: " ")
    }

    /// The wrong sentence as plain text (VoiceOver).
    var wrongSentenceSpoken: String {
        return wrongSentence.map(\.text).joined(separator: " ")
    }

    /// The right sentence as plain text (VoiceOver).
    var rightSentenceSpoken: String {
        return rightSentence.map(\.text).joined(separator: " ")
    }

    /// The wrong words (with `whole` the whole sentence), the changed ones underlined with dots in
    /// `color` (the text's color when nil).
    func wrongText(color: Color?, whole: Bool = false) -> AttributedString {
        return LargeMistakeSnippet.attributed(whole ? wrongSentence : wrong) { piece in
            piece.underlineStyle = Text.LineStyle(pattern: .dot, color: color)
        }
    }

    /// The right words (with `whole` the whole sentence), the changed ones underlined in the
    /// text's color.
    func rightText(whole: Bool = false) -> AttributedString {
        return LargeMistakeSnippet.attributed(whole ? rightSentence : right) { piece in
            piece.underlineStyle = Text.LineStyle(pattern: .solid)
        }
    }

    private static func withoutNotes(_ sentence: String) -> String {
        return sentence.replacingOccurrences(of: #"\s*\(=[^)]*\)"#, with: "", options: .regularExpression)
    }

    /// `MistakeDiff`'s segments as words: a word is everything between two of its spaces.
    private static func words(_ segments: [MistakeDiff.Segment]) -> [Word] {
        var result: [Word] = []
        var text = ""
        var isChanged = false
        for segment in segments {
            if segment.text == " " && !segment.isChanged {
                result.append(Word(text: text, isChanged: isChanged))
                text = ""
                isChanged = false
            } else {
                text += segment.text
                isChanged = isChanged || segment.isChanged
            }
        }
        if !text.isEmpty {
            result.append(Word(text: text, isChanged: isChanged))
        }
        return result
    }

    private static func isShared(_ word: Word) -> Bool {
        return !word.isChanged && !MistakeDiff.normalized(word.text).isEmpty
    }

    /// The difference from the shared word `start` to the shared word `end` (-1 and the word
    /// count when there is none), with those two neighbours, as long as they belong to the
    /// difference's sentence: the word before is left out when it ends a sentence, the word after
    /// when the word before it ends one.
    private static func withinSentence(from start: Int, to end: Int, in words: [Word]) -> Range<Int> {
        var lower = max(start, 0)
        var upper = min(end, words.count - 1) + 1
        if start >= 0 && endsSentence(words[start].text) && lower + 1 < upper {
            lower += 1
        }
        if end < words.count && upper - 2 >= lower && endsSentence(words[upper - 2].text) {
            upper -= 1
        }
        return lower..<upper
    }

    /// The whole sentences that hold the words in `range`: back to the word after a sentence's
    /// end, on to the next word that ends one.
    private static func sentences(around range: Range<Int>, in words: [Word]) -> Range<Int> {
        guard !range.isEmpty else {
            return range
        }
        var lower = range.lowerBound
        var upper = range.upperBound
        while lower > 0 && !endsSentence(words[lower - 1].text) {
            lower -= 1
        }
        while upper < words.count && !endsSentence(words[upper - 1].text) {
            upper += 1
        }
        return lower..<upper
    }

    /// Whether `text` ends a sentence: ".", "!" or "?", also before a closing quote or bracket.
    private static func endsSentence(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: CharacterSet(charactersIn: "\"”’')"))
        guard let last = trimmed.last else {
            return false
        }
        if last == "." && WidgetSentenceEnd.isAbbreviation(trimmed.dropLast()) {
            return false
        }
        return ".!?".contains(last)
    }

    /// The words in `range`; the sentence's last word, and a last word that ends a sentence,
    /// without its final punctuation.
    private static func trimmed(_ words: [Word], in range: Range<Int>) -> [Word] {
        return range.compactMap { index -> Word? in
            var text = words[index].text
            if index == words.count - 1 || (index == range.upperBound - 1 && endsSentence(text)) {
                while let last = text.last, ".!?;:,…".contains(last) {
                    text.removeLast()
                }
            }
            guard !text.isEmpty else {
                return nil
            }
            return Word(text: text, isChanged: words[index].isChanged && !MistakeDiff.normalized(text).isEmpty)
        }
    }

    /// The words joined by spaces; only the letters of a changed word are marked, not the
    /// punctuation around it.
    private static func attributed(_ words: [Word], marking mark: (inout AttributedString) -> Void) -> AttributedString {
        var result = AttributedString()
        for (index, word) in words.enumerated() {
            if index > 0 {
                result.append(AttributedString(" "))
            }
            let text = word.text
            guard word.isChanged,
                  let first = text.firstIndex(where: { $0.isLetter || $0.isNumber }),
                  let last = text.lastIndex(where: { $0.isLetter || $0.isNumber }) else {
                result.append(AttributedString(text))
                continue
            }
            let end = text.index(after: last)
            result.append(AttributedString(String(text[..<first])))
            var core = AttributedString(String(text[first..<end]))
            mark(&core)
            result.append(core)
            result.append(AttributedString(String(text[end...])))
        }
        return result
    }
}

/// The large widget's buttons (the intents of WidgetButtons.swift): Know, speaker and Next, each
/// a 34 pt circle (`surface2`, a faint wash when tinted) with its short name under it, so no
/// button rests on its icon alone (ogrenme_ilkeleri 2.1). The hit areas are at least 44 x 44 pt
/// with at least 8 pt between them. The outer buttons align their circle with the row's edges,
/// in line with the text column. VoiceOver uses the other widgets' names, which contain
/// the shown ones ("Biliyorum" with the 3-day hint, "Kelimeyi dinle", "Sonraki kelime"); Voice
/// Control also takes the short names. The glyphs and names stop growing at xxLarge, as on the
/// other widgets.
struct LargeWidgetButtonRow: View {
    let word: WidgetWord
    let colors: WidgetColors

    private var source: String { WidgetEventSource.systemLarge.rawValue }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Button(intent: KnowWordIntent(wordID: word.id, source: source)) {
                LargeButtonFace(name: "Biliyorum", systemImage: "checkmark", alignment: .leading, colors: colors)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: "Biliyorum"))
            .accessibilityHint(Text(verbatim: KnowWordButton.hint))
            Spacer(minLength: 8)
            Button(intent: SpeakWordIntent(text: word.lemma)) {
                LargeButtonFace(name: "Dinle", systemImage: "speaker.wave.2", alignment: .center, colors: colors)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: "Kelimeyi dinle"))
            .accessibilityInputLabels([Text(verbatim: "Kelimeyi dinle"), Text(verbatim: "Dinle")])
            // VoiceOver stays quiet while the word is being read.
            .accessibilityAddTraits(.startsMediaSession)
            Spacer(minLength: 8)
            Button(intent: NextWordIntent(wordID: word.id, source: source)) {
                LargeButtonFace(name: "Sonraki", systemImage: "forward.fill", alignment: .trailing, colors: colors)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: "Sonraki kelime"))
            .accessibilityInputLabels([Text(verbatim: "Sonraki kelime"), Text(verbatim: "Sonraki")])
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}

/// A large widget button's look: the icon in a 34 pt circle as on the other widgets
/// (`WidgetButtonFace`), its name under it in `.footnote` semibold (the widget's smallest size;
/// it was `.caption2`, a fifth size), in a hit area of at least 44 x 44 pt that is all tappable.
private struct LargeButtonFace: View {
    let name: String
    let systemImage: String
    let alignment: HorizontalAlignment
    let colors: WidgetColors

    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                // The filled Next glyph one scale smaller, as on the other widgets.
                .imageScale(systemImage.hasSuffix(".fill") ? WidgetButtonFace.filledScale : .medium)
                .frame(width: 34, height: 34)
                .background(colors.buttonFill, in: Circle())
            Text(verbatim: name)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
                .fixedSize()
        }
        .foregroundStyle(colors.ink)
        .padding(.horizontal, 5)
        .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
        .contentShape(Rectangle())
    }
}
