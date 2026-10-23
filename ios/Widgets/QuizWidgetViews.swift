import SwiftUI
import WidgetKit
import CoreModels
import SharedState

// The quiz widget's layouts (`LockglowQuizWidget`). Same paper, ink and type as the word widget
// (HomeWordViews.swift): the English word in serif with the phosphor band, Turkish and UI text in
// SF Pro, nothing below 11 pt, every line whole or not at all (never "…", never broken inside a
// word). The system applies the content margins.
// Medium (289 x 116 pt of content on an iPhone SE): the question line and the word on top, beside
// the speaker (and the round "Devam" after the answer); the three options side by side below, each
// a 44 pt or taller button. Large (289 x 292 pt on an SE): the same top with the pronunciation and
// a "Devam" capsule, the options as full-width rows, and after a wrong pick what it means ("Senin
// seçtiğin: allow = izin vermek") and the example sentence.
// After the answer the options are no longer buttons: the right one has a check and a `good` box,
// a wrong pick a cross in a quiet color and the paper's box, the third one is quiet; the line on
// top says it in words ("Doğru." / "Doğrusu: ödünç almak"), so the meaning never rests on color
// (rule 4). No red anywhere: the widget's tone never changes (ogrenme_ilkeleri 2.1).
// Larger text sizes: the layouts are vertical ViewThatFits variants, fullest first, like the word
// widget's: the options at 15 pt, then 13 pt on more lines, then the same at the largest standard
// size, then at the default size, where the last variant may shrink a long word to 11 pt rather
// than cut it.

/// The quiz widget's colors for its rendering mode, on top of the word widget's.
struct QuizColors {
    /// Ink, ink2 and the button wash of the word widget (`WidgetColors`).
    let base: WidgetColors
    /// The edge of an option before the answer: a control's edge, at least 3:1 (WCAG 1.4.11).
    let optionEdge: AnyShapeStyle
    /// The right option after the answer: its box, edge and check.
    let rightFill: AnyShapeStyle
    let rightInk: AnyShapeStyle
    /// The edge of an option that is no longer a button and not marked.
    let quietEdge: AnyShapeStyle
    /// Behind a mark that sits on an option's edge; nil when the system draws the background.
    let paper: AnyShapeStyle?

    /// Full color on the widget's own paper uses the design tokens. Tinted (accented, clear Home
    /// Screen) or without the paper the system's hierarchical styles keep the levels; the icons
    /// and the right option's thicker edge carry the meaning there.
    static func forMode(_ mode: WidgetRenderingMode, showsBackground: Bool = true) -> QuizColors {
        if mode == .fullColor && showsBackground {
            return QuizColors(
                base: .tokens,
                optionEdge: AnyShapeStyle(Theme.lineStrong),
                rightFill: AnyShapeStyle(Theme.goodTint),
                rightInk: AnyShapeStyle(Theme.good),
                quietEdge: AnyShapeStyle(Theme.line),
                paper: AnyShapeStyle(Theme.surface)
            )
        }
        return QuizColors(
            base: .system,
            optionEdge: AnyShapeStyle(HierarchicalShapeStyle.secondary),
            rightFill: AnyShapeStyle(HierarchicalShapeStyle.quaternary),
            rightInk: AnyShapeStyle(HierarchicalShapeStyle.primary),
            quietEdge: AnyShapeStyle(HierarchicalShapeStyle.tertiary),
            paper: nil
        )
    }
}

/// Texts and sizes of the quiz widget (docs/tasarim/terimler.md: "Devam" moves on in a quiz,
/// "Yanlış" only as an option's small mark, no exclamation, no praise).
enum QuizText {
    static let question = "Bu kelime ne demek?"
    static let right = "Doğru."
    static let markedFallback = "Doğrusu işaretli."
    static let rightMark = "Doğru cevap"
    static let wrongMark = "Yanlış"
    static let next = "Devam"
    static let nextHint = "Yeni bir soru gelir."
    /// The last variant's smallest scale: 11 pt (Apple's floor) for 13 and 15 pt text.
    static let floorScale13: CGFloat = 11.0 / 13.0
    static let floorScale15: CGFloat = 11.0 / 15.0

    /// What the widget says when there is no question.
    static func empty(_ reason: QuizEntry.Empty) -> String {
        switch reason {
        case .notPrepared:
            return "Soruları hazırlamak için uygulamayı bir kez aç."
        case .noWords:
            return "Sorular tanıştığın kelimelerden gelir. Önce Tekrar'da birkaç kelimeyle tanış."
        case .finished:
            return "Şimdilik soru kalmadı. Yeni sorular uygulamayı açınca gelir."
        }
    }

    /// The line on top, fullest first, one line each: the question; after the answer "Doğru." or
    /// "Doğrusu: …" with the whole meaning, then its short form, then "Doğrusu işaretli.".
    static func status(of screen: WidgetQuizScreen) -> [[String]] {
        guard screen.isAnswered else {
            return [[question]]
        }
        if screen.isRight {
            return [[right]]
        }
        let item = screen.item
        var forms = [item.answer ?? ""]
        if let short = item.shortOption(at: item.answerIndex) {
            forms.append(short)
        }
        return WidgetText.candidates(forms.map { "Doğrusu: \($0)" }, lines: [1]) + [[markedFallback]]
    }

    /// What VoiceOver reads for the line on top: always the whole meaning after a wrong pick, also
    /// when the line shows only "Doğrusu işaretli.".
    static func spokenStatus(of screen: WidgetQuizScreen) -> String? {
        guard screen.isAnswered, !screen.isRight, let answer = screen.item.answer else {
            return nil
        }
        return "Doğrusu: \(answer)"
    }

    /// The forms of option `index`, fullest first (`WidgetGloss`): the whole meaning, then the
    /// card's short form or the first sense.
    static func forms(of item: WidgetQuizItem, at index: Int) -> [String] {
        return WidgetGloss.forms(of: item.options[index], short: item.shortOption(at: index))
    }

    /// What VoiceOver reads for option `index` after the answer: the option, then its mark.
    static func spokenResult(of screen: WidgetQuizScreen, at index: Int) -> String {
        let option = screen.item.options[index]
        if index == screen.item.answerIndex {
            return "\(option), \(rightMark)"
        }
        if index == screen.choice {
            return "\(option), \(wrongMark)"
        }
        return option
    }

    /// The headword's size steps: the medium widget's (20, 17, 15 pt, a phrase also on two lines)
    /// and a larger set on the large widget (22 pt first, the Title 2 size). The large widget then
    /// keeps four sizes: the word, the options (Body), the line on top (Subheadline) and the
    /// pronunciation, the wrong pick's line and the example (Footnote).
    static let mediumWord = WidgetWordStep.mediumWidgetScaled
    static let largeWord = [
        WidgetWordStep(size: 22),
        WidgetWordStep(size: 20),
        WidgetWordStep(size: 17),
        WidgetWordStep(size: 20, lines: 2),
        WidgetWordStep(size: 17, lines: 2),
    ]
}

/// How an option looks after the answer.
private enum QuizMark {
    case right
    case wrong
    case quiet

    init?(screen: WidgetQuizScreen, index: Int) {
        guard screen.isAnswered else {
            return nil
        }
        if index == screen.item.answerIndex {
            self = .right
        } else if index == screen.choice {
            self = .wrong
        } else {
            self = .quiet
        }
    }

    var symbol: String? {
        switch self {
        case .right:
            return "checkmark.circle.fill"
        case .wrong:
            return "xmark.circle.fill"
        case .quiet:
            return nil
        }
    }
}

// MARK: - Medium

struct QuizMediumView: View {
    let entry: QuizEntry
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    /// Replaces the environment's `showsWidgetContainerBackground` (snapshot tests only).
    var showsBackground: Bool? = nil
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    @Environment(\.showsWidgetContainerBackground) private var environmentShowsBackground
    private var colors: QuizColors {
        QuizColors.forMode(
            renderingMode ?? environmentRenderingMode,
            showsBackground: showsBackground ?? environmentShowsBackground
        )
    }

    var body: some View {
        Group {
            if let screen = entry.screen {
                ViewThatFits(in: .vertical) {
                    layout(screen, option: .subheadline.weight(.semibold), lines: [1, 2])
                    layout(screen, option: .footnote.weight(.semibold), lines: [1, 2, 3])
                    // The person's size leaves no room: the largest standard size.
                    Group {
                        layout(screen, option: .subheadline.weight(.semibold), lines: [1, 2])
                        layout(screen, option: .footnote.weight(.semibold), lines: [1, 2, 3])
                    }
                    .dynamicTypeSize(...WidgetText.largestStandardSize)
                    // Then the default size; the content area does not grow with the text size.
                    Group {
                        layout(screen, option: .subheadline.weight(.semibold), lines: [1, 2])
                        layout(screen, option: .footnote.weight(.semibold), lines: [1, 2], lastResort: true)
                    }
                    .dynamicTypeSize(...DynamicTypeSize.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                QuizEmptyView(reason: entry.empty, colors: colors)
            }
        }
        .widgetTurkishVoice()
    }

    /// One layout variant: the top row, then the options at `option` on the first of `lines` line
    /// counts that fits. With `lastResort` nothing is passed over (the last variant): a word or an
    /// option may then shrink to 11 pt.
    private func layout(_ screen: WidgetQuizScreen, option: Font, lines: [Int], lastResort: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            QuizTopRow(
                screen: screen,
                steps: lastResort ? WidgetWordStep.mediumWidget : QuizText.mediumWord,
                showsIPA: false,
                status: .footnote.weight(.semibold),
                lastResort: lastResort,
                compactNext: true,
                source: .systemMedium,
                colors: colors,
                renderingMode: renderingMode
            )
            HStack(spacing: 6) {
                ForEach(0..<screen.item.options.count, id: \.self) { index in
                    QuizOptionButton(
                        screen: screen,
                        index: index,
                        layout: .column,
                        typeface: option,
                        lines: lines,
                        lastResort: lastResort ? QuizText.floorScale13 : nil,
                        source: .systemMedium,
                        colors: colors
                    )
                }
            }
            // Every option as tall as the tallest.
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Large

struct QuizLargeView: View {
    let entry: QuizEntry
    /// Replaces the environment's rendering mode (snapshot tests only); nil on a device.
    var renderingMode: WidgetRenderingMode? = nil
    /// Replaces the environment's `showsWidgetContainerBackground` (snapshot tests only).
    var showsBackground: Bool? = nil
    @Environment(\.widgetRenderingMode) private var environmentRenderingMode
    @Environment(\.showsWidgetContainerBackground) private var environmentShowsBackground
    private var colors: QuizColors {
        QuizColors.forMode(
            renderingMode ?? environmentRenderingMode,
            showsBackground: showsBackground ?? environmentShowsBackground
        )
    }

    var body: some View {
        Group {
            if let screen = entry.screen {
                // After the answer the example gives way first, then the wrong pick's line.
                ViewThatFits(in: .vertical) {
                    layout(screen, option: .body.weight(.semibold), lines: [1, 2], picked: true, example: true)
                    layout(screen, option: .body.weight(.semibold), lines: [1, 2], picked: true)
                    layout(screen, option: .body.weight(.semibold), lines: [1, 2])
                    layout(screen, option: .subheadline.weight(.semibold), lines: [1, 2, 3])
                    Group {
                        layout(screen, option: .body.weight(.semibold), lines: [1, 2], picked: true)
                        layout(screen, option: .subheadline.weight(.semibold), lines: [1, 2, 3])
                    }
                    .dynamicTypeSize(...WidgetText.largestStandardSize)
                    Group {
                        layout(screen, option: .body.weight(.semibold), lines: [1, 2], picked: true, example: true)
                        layout(screen, option: .subheadline.weight(.semibold), lines: [1, 2], lastResort: true)
                    }
                    .dynamicTypeSize(...DynamicTypeSize.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                QuizEmptyView(reason: entry.empty, colors: colors)
            }
        }
        .widgetTurkishVoice()
    }

    private func layout(
        _ screen: WidgetQuizScreen,
        option: Font,
        lines: [Int],
        picked: Bool = false,
        example: Bool = false,
        lastResort: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            QuizTopRow(
                screen: screen,
                steps: lastResort ? QuizText.largeWord + [WidgetWordStep(size: 15, lines: 2, scales: false)] : QuizText.largeWord,
                showsIPA: true,
                status: .subheadline.weight(.semibold),
                lastResort: lastResort,
                compactNext: false,
                source: .systemLarge,
                colors: colors,
                renderingMode: renderingMode
            )
            VStack(spacing: 8) {
                ForEach(0..<screen.item.options.count, id: \.self) { index in
                    QuizOptionButton(
                        screen: screen,
                        index: index,
                        layout: .row,
                        typeface: option,
                        lines: lines,
                        lastResort: lastResort ? QuizText.floorScale15 : nil,
                        source: .systemLarge,
                        colors: colors
                    )
                }
            }
            .padding(.top, 12)
            if screen.isAnswered && (picked || example) {
                VStack(alignment: .leading, spacing: 4) {
                    if picked, let line = QuizPickedLine(screen: screen, colors: colors) {
                        line
                    }
                    if example, let sentence = screen.item.exampleEN, !sentence.isEmpty {
                        WidgetExampleLine(sentence: sentence, lemma: screen.item.lemma, color: colors.base.ink2)
                            .widgetEnglishVoice()
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

// MARK: - Parts

/// The top row: the question line (the result after the answer) over the word, and on the right
/// the speaker and, after the answer, "Devam" (`compactNext`: round, as the word widget's buttons,
/// so the word keeps its room on the medium widget).
private struct QuizTopRow: View {
    let screen: WidgetQuizScreen
    let steps: [WidgetWordStep]
    let showsIPA: Bool
    let status: Font
    let lastResort: Bool
    let compactNext: Bool
    let source: WidgetEventSource
    let colors: QuizColors
    let renderingMode: WidgetRenderingMode?

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                QuizFittingText(
                    candidates: QuizText.status(of: screen),
                    typeface: status,
                    color: screen.isAnswered ? colors.base.ink : colors.base.ink2,
                    lastResort: lastResort ? QuizText.floorScale13 : nil,
                    spoken: QuizText.spokenStatus(of: screen)
                )
                if showsIPA {
                    WidgetWordRow(
                        lemma: screen.item.lemma,
                        steps: steps,
                        lastResort: lastResort,
                        ipa: screen.item.ipaUS,
                        colors: colors.base,
                        renderingMode: renderingMode
                    )
                } else {
                    WidgetFittingWord(
                        lemma: screen.item.lemma,
                        steps: steps,
                        lastResort: lastResort,
                        colors: colors.base,
                        renderingMode: renderingMode
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
            HStack(spacing: 4) {
                SpeakWordButton(text: screen.item.lemma, colors: colors.base)
                if screen.isAnswered {
                    QuizNextButton(wordID: screen.item.wordID, compact: compactNext, source: source, colors: colors.base)
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            // Their whole width, always: the word column gives way (screenshots 23 Oct: without it
            // the "Devam" capsule ran over the speaker on the large widget).
            .fixedSize()
            // The 34 pt faces line up with the first line; the 44 pt hit areas reach 5 pt up into
            // the margin.
            .padding(.top, -5)
        }
    }
}

/// One option: before the answer a button (`QuizAnswerIntent`, by the option's text), after it a
/// plain box with its mark. `.column` (medium): the text centred in a box as tall as the tallest,
/// the mark a small badge on the box's top-right corner, so it takes no width; `.row`
/// (large): a full-width row whose mark place before the text is always kept, so marking never
/// moves or shortens the text.
private struct QuizOptionButton: View {
    enum Layout {
        case column
        case row
    }

    let screen: WidgetQuizScreen
    let index: Int
    let layout: Layout
    let typeface: Font
    let lines: [Int]
    /// The last variant's smallest scale (11 pt over the typeface's size); nil elsewhere.
    let lastResort: CGFloat?
    let source: WidgetEventSource
    let colors: QuizColors

    private static let badgeSize: CGFloat = 16
    private static let rowMarkWidth: CGFloat = 20

    private var mark: QuizMark? { QuizMark(screen: screen, index: index) }
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: layout == .column ? 14 : Theme.Radius.box, style: .continuous)
    }

    var body: some View {
        if screen.isAnswered {
            face
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: QuizText.spokenResult(of: screen, at: index)))
        } else {
            Button(intent: QuizAnswerIntent(wordID: screen.item.wordID, option: screen.item.options[index], source: source.rawValue)) {
                face
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: screen.item.options[index]))
        }
    }

    @ViewBuilder
    private var face: some View {
        let text = QuizFittingText(
            candidates: WidgetText.candidates(QuizText.forms(of: screen.item, at: index), lines: lines),
            typeface: typeface,
            color: mark == .quiet ? colors.base.ink2 : colors.base.ink,
            alignment: layout == .column ? .center : .leading,
            lastResort: lastResort
        )
        switch layout {
        case .column:
            text
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, minHeight: Theme.minHitSize, maxHeight: .infinity)
                .background(fill, in: shape)
                .overlay {
                    shape.strokeBorder(edge, lineWidth: edgeWidth)
                }
                .overlay(alignment: .topTrailing) {
                    // 6 pt out of the box: the gap between the options and up towards the top row.
                    markIcon(size: QuizOptionButton.badgeSize)
                        .offset(x: 6, y: -6)
                }
                .contentShape(shape)
        case .row:
            HStack(spacing: 8) {
                markIcon(size: QuizOptionButton.rowMarkWidth)
                    .frame(width: QuizOptionButton.rowMarkWidth)
                text
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 10)
            .padding(.trailing, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .background(fill, in: shape)
            .overlay {
                shape.strokeBorder(edge, lineWidth: edgeWidth)
            }
            .contentShape(shape)
        }
    }

    /// The check or the cross at `size` pt; nothing (an empty place in a row) when the option has
    /// no mark.
    @ViewBuilder
    private func markIcon(size: CGFloat) -> some View {
        if let symbol = mark?.symbol {
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundStyle(mark == .right ? colors.rightInk : colors.base.ink2)
                .background {
                    if let paper = colors.paper, layout == .column {
                        Circle().fill(paper)
                    }
                }
                .widgetAccentable(mark == .right)
                .accessibilityHidden(true)
        } else if layout == .row {
            Color.clear
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        }
    }

    private var fill: AnyShapeStyle {
        switch mark {
        case nil:
            return colors.base.buttonFill
        case .right:
            return colors.rightFill
        case .wrong, .quiet:
            return AnyShapeStyle(Color.clear)
        }
    }

    private var edge: AnyShapeStyle {
        switch mark {
        case nil, .wrong:
            return colors.optionEdge
        case .right:
            return colors.rightInk
        case .quiet:
            return colors.quietEdge
        }
    }

    private var edgeWidth: CGFloat {
        return mark == .right ? 2 : 1
    }
}

/// "Devam": the next question (`QuizNextIntent`). `compact`: a round button with an arrow, like the
/// word widget's (34 pt face in a 44 pt hit area); otherwise a capsule with its name.
private struct QuizNextButton: View {
    let wordID: Int
    let compact: Bool
    let source: WidgetEventSource
    let colors: WidgetColors

    var body: some View {
        Button(intent: QuizNextIntent(wordID: wordID, source: source.rawValue)) {
            Group {
                if compact {
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.semibold))
                        .imageScale(.medium)
                        .frame(width: 34, height: 34)
                        .background(colors.buttonFill, in: Circle())
                } else {
                    HStack(spacing: 4) {
                        Text(verbatim: QuizText.next)
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(colors.buttonFill, in: Capsule())
                }
            }
            .foregroundStyle(colors.ink)
            .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: QuizText.next))
        .accessibilityHint(Text(verbatim: QuizText.nextHint))
        .accessibilityInputLabels([Text(verbatim: QuizText.next), Text(verbatim: "Sonraki soru")])
    }
}

/// "Senin seçtiğin: allow = izin vermek" after a wrong pick, English first as in the app's
/// "Hatırla" (ReviewView), when the option's English word is known. Shown whole or not at all.
/// VoiceOver: "Senin seçtiğin: izin vermek. İngilizcesi:" in Turkish, then the word in English.
private struct QuizPickedLine: View {
    let option: String
    let english: String
    let colors: QuizColors

    init?(screen: WidgetQuizScreen, colors: QuizColors) {
        guard let choice = screen.choice, !screen.isRight, screen.item.options.indices.contains(choice),
              let english = screen.item.optionWord(at: choice) else {
            return nil
        }
        self.option = screen.item.options[choice]
        self.english = english
        self.colors = colors
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            line
            Color.clear
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        }
    }

    private var line: some View {
        let word = Text(verbatim: english)
            .font(.system(.footnote, design: .serif).weight(.bold))
            .foregroundStyle(colors.base.ink)
        return Text("Senin seçtiğin: \(word) = \(option)")
            .font(.footnote)
            .foregroundStyle(colors.base.ink2)
            .lineLimit(1)
            .accessibilityRepresentation {
                Text(verbatim: "Senin seçtiğin: \(option). İngilizcesi:")
                Text(verbatim: english)
                    .widgetEnglishVoice()
            }
    }
}

/// No question on screen: why, and what brings questions.
private struct QuizEmptyView: View {
    let reason: QuizEntry.Empty
    let colors: QuizColors

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: QuizText.question)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colors.base.ink)
            Text(verbatim: QuizText.empty(reason))
                .font(.footnote)
                .foregroundStyle(colors.base.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        // Two short sentences fit the medium widget up to the largest standard size.
        .dynamicTypeSize(...WidgetText.largestStandardSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// Quiz text shown whole or not at all, like `WidgetFittingText`, with an alignment: the first
/// candidate (a list of lines) whose every line fits on one line. When none fits the variant
/// around it is passed over (`WidgetFit.reject`); with `lastResort` (the smallest scale) the last
/// candidate is shown and may shrink, at most to that scale, instead. `spoken` replaces what
/// VoiceOver reads (the lines shown, otherwise).
struct QuizFittingText: View {
    let candidates: [[String]]
    let typeface: Font
    let color: AnyShapeStyle
    var alignment: HorizontalAlignment = .leading
    var lastResort: CGFloat? = nil
    var spoken: String? = nil

    var body: some View {
        let slots = WidgetFit.slots(candidates)
        if slots.isEmpty {
            if lastResort == nil {
                WidgetFit.reject
            } else {
                Color.clear
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            }
        } else {
            ViewThatFits(in: .horizontal) {
                lines(slots[0])
                lines(slots[1])
                lines(slots[2])
                lines(slots[3])
                lines(slots[4])
                lines(slots[5])
                if let scale = lastResort {
                    lines(slots[5], minimumScale: scale)
                } else {
                    WidgetFit.reject
                }
            }
        }
    }

    private func lines(_ lines: [String], minimumScale: CGFloat = 1) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(verbatim: line)
                    .font(typeface)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(minimumScale)
            }
        }
        .multilineTextAlignment(alignment == .center ? .center : .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: spoken ?? lines.joined(separator: " ")))
    }
}
