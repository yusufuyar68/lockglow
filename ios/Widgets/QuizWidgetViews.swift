import SwiftUI
import WidgetKit
import CoreModels
import SharedState

// The quiz widget's layouts (`LockglowQuizWidget`). Same paper, ink and type as the word widget
// (HomeWordViews.swift): the English word in serif with the phosphor band, Turkish and UI text in
// SF Pro, nothing below 11 pt, every line whole or not at all (never "…", never broken inside a
// word). The system applies the content margins.
// Medium (289 x 116 pt of content on an iPhone SE): the question line and the word on top, beside
// the speaker (and "Devam" after the answer); the three options side by side below, each a 44 pt
// or taller button. Large (289 x 292 pt on an SE): the same top, the options as full-width rows,
// and after the answer what the wrong pick means ("Senin seçtiğin: izin vermek = allow") and the
// example sentence.
// After the answer the options are no longer buttons (a tap opens the app on the word): the right
// one has a check and a `good` box, a wrong pick a cross in a quiet color and the paper's box, the
// third one is quiet; the line on top says it in words ("Doğru." / "Doğrusu: ödünç almak"), so
// the meaning never rests on color (rule 4). No red anywhere: the widget's tone never changes
// (ogrenme_ilkeleri 2.1).
// Larger text sizes: the layouts are vertical ViewThatFits variants, fullest first, like the word
// widget's: the options at 15 pt, then 13 pt on more lines, then the same at the largest standard
// size, then at the default size, where the last variant may shrink a long word a little rather
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
    /// carry the meaning there.
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

/// Texts and sizes of the quiz widget.
enum QuizText {
    static let question = "Bu kelime ne demek?"
    static let right = "Doğru."
    static let markedFallback = "Doğrusu işaretli."
    static let rightMark = "Doğru cevap"
    static let wrongMark = "Yanlış"
    static let next = "Devam"
    static let nextHint = "Yeni bir soru gelir."
    static let empty = "Soruları hazırlamak için uygulamayı bir kez aç."

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
    /// and a larger set on the large widget (24 pt first).
    static let mediumWord = WidgetWordStep.mediumWidgetScaled
    static let largeWord = [
        WidgetWordStep(size: 24),
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
                        layout(screen, option: .footnote.weight(.semibold), lines: [1, 2, 3], lastResort: true)
                    }
                    .dynamicTypeSize(...DynamicTypeSize.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                QuizEmptyView(colors: colors)
            }
        }
        .widgetTurkishVoice()
    }

    /// One layout variant: the top row, then the options at `option` on the first of `lines` line
    /// counts that fits. With `lastResort` nothing is passed over (the last variant).
    private func layout(_ screen: WidgetQuizScreen, option: Font, lines: [Int], lastResort: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            QuizTopRow(
                screen: screen,
                steps: lastResort ? WidgetWordStep.mediumWidget : QuizText.mediumWord,
                showsIPA: false,
                status: .footnote.weight(.semibold),
                lastResort: lastResort,
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
                        lastResort: lastResort,
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
                        layout(screen, option: .subheadline.weight(.semibold), lines: [1, 2, 3], lastResort: true)
                    }
                    .dynamicTypeSize(...DynamicTypeSize.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                QuizEmptyView(colors: colors)
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
                        lastResort: lastResort,
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
/// the speaker and, after the answer, "Devam".
private struct QuizTopRow: View {
    let screen: WidgetQuizScreen
    let steps: [WidgetWordStep]
    let showsIPA: Bool
    let status: Font
    let lastResort: Bool
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
                    lastResort: lastResort
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
                    QuizNextButton(wordID: screen.item.wordID, source: source, colors: colors.base)
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            // The 34 pt faces line up with the first line; the 44 pt hit areas reach a little up.
            .padding(.top, -5)
        }
    }
}

/// One option: before the answer a button (`QuizAnswerIntent`), after it a plain box with its mark.
/// `.column` (medium): the text centred in a box as tall as the tallest, the mark on its top
/// corner so it takes no width; `.row` (large): a full-width row with the mark before the text.
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
    let lastResort: Bool
    let source: WidgetEventSource
    let colors: QuizColors

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
            Button(intent: QuizAnswerIntent(wordID: screen.item.wordID, choice: index, source: source.rawValue)) {
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
                    markIcon
                        .offset(x: 5, y: -5)
                }
                .contentShape(shape)
        case .row:
            HStack(spacing: 10) {
                markIcon
                text
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .background(fill, in: shape)
            .overlay {
                shape.strokeBorder(edge, lineWidth: edgeWidth)
            }
            .contentShape(shape)
        }
    }

    @ViewBuilder
    private var markIcon: some View {
        if let symbol = mark?.symbol {
            Image(systemName: symbol)
                .font(.footnote.weight(.bold))
                .imageScale(.large)
                .foregroundStyle(mark == .right ? colors.rightInk : colors.base.ink2)
                .background {
                    if let paper = colors.paper, layout == .column {
                        Circle().fill(paper)
                    }
                }
                .widgetAccentable(mark == .right)
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

/// "Devam": the next question (`QuizNextIntent`). A capsule with its name, like the word widget's
/// round buttons: a 34 pt face in a 44 pt hit area.
private struct QuizNextButton: View {
    let wordID: Int
    let source: WidgetEventSource
    let colors: WidgetColors

    var body: some View {
        Button(intent: QuizNextIntent(wordID: wordID, source: source.rawValue)) {
            HStack(spacing: 4) {
                Text(verbatim: QuizText.next)
                Image(systemName: "arrow.right")
                    .accessibilityHidden(true)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(colors.ink)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(colors.buttonFill, in: Capsule())
            .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: QuizText.next))
        .accessibilityHint(Text(verbatim: QuizText.nextHint))
        .accessibilityInputLabels([Text(verbatim: QuizText.next), Text(verbatim: "Sonraki soru")])
    }
}

/// "Senin seçtiğin: izin vermek = allow" after a wrong pick, when the option's English word is
/// known: the Turkish part and the English word are separate elements, each in its own voice.
/// Shown whole or not at all.
private struct QuizPickedLine: View {
    let lead: String
    let english: String
    let colors: QuizColors

    init?(screen: WidgetQuizScreen, colors: QuizColors) {
        guard let choice = screen.choice, !screen.isRight, screen.item.options.indices.contains(choice),
              let english = screen.item.optionWord(at: choice) else {
            return nil
        }
        self.lead = "Senin seçtiğin: \(screen.item.options[choice]) ="
        self.english = english
        self.colors = colors
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(verbatim: lead)
                    .font(.footnote)
                    .foregroundStyle(colors.base.ink2)
                Text(verbatim: english)
                    .font(.system(.footnote, design: .serif).weight(.bold))
                    .foregroundStyle(colors.base.ink)
                    .widgetEnglishVoice()
            }
            .lineLimit(1)
            Color.clear
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        }
    }
}

/// Before the app has written questions (a new install not opened yet).
private struct QuizEmptyView: View {
    let colors: QuizColors

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: QuizText.question)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colors.base.ink)
            Text(verbatim: QuizText.empty)
                .font(.footnote)
                .foregroundStyle(colors.base.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// Quiz text shown whole or not at all, like `WidgetFittingText`, with an alignment: the first
/// candidate (a list of lines) whose every line fits on one line. When none fits the variant
/// around it is passed over (`WidgetFit.reject`); with `lastResort` the last candidate is shown
/// and may shrink to 70 % instead.
struct QuizFittingText: View {
    let candidates: [[String]]
    let typeface: Font
    let color: AnyShapeStyle
    var alignment: HorizontalAlignment = .leading
    var lastResort = false

    var body: some View {
        let slots = WidgetFit.slots(candidates)
        if slots.isEmpty {
            WidgetFit.reject
        } else {
            ViewThatFits(in: .horizontal) {
                lines(slots[0])
                lines(slots[1])
                lines(slots[2])
                lines(slots[3])
                lines(slots[4])
                lines(slots[5])
                if lastResort {
                    lines(slots[5], minimumScale: 0.7)
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
        .accessibilityLabel(Text(verbatim: lines.joined(separator: " ")))
    }
}
