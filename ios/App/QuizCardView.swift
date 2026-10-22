import SwiftUI
import UIKit
import CoreModels

/// How a quiz question went, as reported by `QuizCardView.onContinue`. `ReviewView` turns it into
/// a `ReviewGrade` (this file is also compiled into the snapshot bundle, which does not link
/// Learning, so it cannot use that type itself).
enum QuizOutcome: Hashable {
    /// A wrong pick.
    case wrong
    /// A right pick that was hard ("Zordu").
    case hard
    /// A right pick ("Devam").
    case right
    /// A right pick that was easy ("Kolaydı").
    case easy
}

/// "Tekrar" question for a word that was already studied: the card's fill-in-the-blank sentence
/// (large serif, the blank a marked slot) and four equal option capsules (serif: they are
/// English), two by two when every option fits its half, one per row otherwise, in a new order
/// on each attempt (`CardDetail.Quiz.options(seed:attempt:)`). After a tap only the right
/// option ("Doğru cevap") and a wrong pick ("Yanlış") stay, marked with icons and words, never
/// color alone; a wrong pick stays on calm paper, no red and no haptic. The sentence then reads
/// in full with the word marked and a "Dinle" capsule, and the feedback below says what the word
/// means ("Doğrusu: spoon = kaşık"), on a wrong pick also what the picked word means ("Senin
/// seçtiğin: knife = bıçak") and, when the card's Dikkat sentences use the picked word, why
/// ("Neden?"). The feedback is about the answer, never the learner (learning principles 2.4).
/// `onContinue` reports how it went: after a right pick the learner can also say it was hard or
/// easy, otherwise "Devam" is a plain right answer.
/// Give each word its own identity (`.id(word.id)`) so the pick resets between cards.
///
/// Uses only `Theme` and the Shared types (no `Palette`): the snapshot bundle compiles it too.
struct QuizCardView: View {
    /// `.scrolling` (the "Tekrar" tab): the question scrolls and the buttons sit in an opaque bar
    /// at the bottom (`safeAreaInset`), or at accessibility sizes under the feedback, scrolling
    /// with it; after the answer the feedback is scrolled into view.
    /// `.stacked` (snapshot tests, which cannot render a scroll view): everything in one column.
    enum Layout {
        case stacked
        case scrolling
    }

    let word: WidgetWord
    let quiz: CardDetail.Quiz
    let layout: Layout
    /// The card's Dikkat entries: the source of "Neden?".
    let mistakes: [CardDetail.Mistake]
    /// Turkish meanings of the options that are headwords of other cards (`AppModel.lookup`).
    let optionMeanings: [String: String]
    /// When the word comes back after each outcome ("10 dakika sonra"), computed by the caller
    /// from the schedule; an outcome without a time shows no time.
    let returnTimes: [QuizOutcome: String]
    let onContinue: (QuizOutcome) -> Void
    @State private var picked: String?
    /// The options in this attempt's order, taken once: the order stays while the card is on
    /// screen, even if the caller's attempt changes meanwhile.
    @State private var optionOrder: [String]
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// `attempt` is how many times the word was answered before (`WordProgress.reviews`): every
    /// next attempt puts the answer in another place (learning principles 2.4); without it the
    /// options keep one order per word. `initialPick` is for snapshot tests: renders the
    /// answered state directly.
    init(
        word: WidgetWord,
        quiz: CardDetail.Quiz,
        attempt: Int = 0,
        initialPick: String? = nil,
        layout: Layout = .stacked,
        mistakes: [CardDetail.Mistake] = [],
        optionMeanings: [String: String] = [:],
        returnTimes: [QuizOutcome: String] = [:],
        onContinue: @escaping (QuizOutcome) -> Void
    ) {
        self.word = word
        self.quiz = quiz
        self.layout = layout
        self.mistakes = mistakes
        self.optionMeanings = optionMeanings
        self.returnTimes = returnTimes
        self.onContinue = onContinue
        _picked = State(initialValue: initialPick)
        _optionOrder = State(initialValue: quiz.options(seed: word.id, attempt: attempt))
    }

    private static let feedbackID = "quiz.feedback"
    /// A right pick, on screen and for VoiceOver: about the answer, not the learner (learning
    /// principles 1 item 12, mockup `.fb .h.ok`).
    private static let praise = "Doğru!"

    var body: some View {
        Group {
            switch layout {
            case .stacked:
                VStack(alignment: .leading, spacing: 20) {
                    question
                    if let picked = picked {
                        actions(isRight: picked == quiz.answer)
                    }
                }
            case .scrolling:
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            question
                            // At accessibility sizes a fixed bar would leave almost no room for the
                            // feedback: the buttons scroll with it instead (rule 5).
                            if dynamicTypeSize.isAccessibilitySize, let picked = picked {
                                actions(isRight: picked == quiz.answer)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 20)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    // Opaque (rule 6): the answer buttons never sit on glass.
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        if !dynamicTypeSize.isAccessibilitySize, let picked = picked {
                            actions(isRight: picked == quiz.answer)
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                                .padding(.bottom, 8)
                                .frame(maxWidth: .infinity)
                                .background(Theme.bg)
                                .transition(.opacity)
                        }
                    }
                    .onChange(of: picked) { _, newValue in
                        guard newValue != nil else {
                            return
                        }
                        // A moment later, once the options have collapsed and the feedback and the
                        // bottom bar have been laid out: the feedback must never stay hidden under
                        // the bar (README point 6).
                        let animation: Animation? = reduceMotion ? nil : .easeInOut(duration: 0.3)
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 60_000_000)
                            withAnimation(animation) {
                                proxy.scrollTo(QuizCardView.feedbackID, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        // The speaker buttons are ink, never the system blue (rule 2).
        .tint(Theme.ink)
        // A light haptic on a right answer only (mockup "Hareket"). A wrong pick stays silent: it
        // is part of learning, not an error (learning principles 1b, 2.4), so never `.error`.
        .sensoryFeedback(.success, trigger: picked) { oldValue, newValue in
            oldValue == nil && newValue == quiz.answer
        }
    }

    // MARK: Question

    private var question: some View {
        // Two by two while the options fit; one column at accessibility sizes and after the
        // answer, where the marks need the room next to the word.
        let optionGrid = QuizOptionGrid(
            columns: picked == nil && !dynamicTypeSize.isAccessibilitySize ? 2 : 1,
            spacing: 10
        )
        return VStack(alignment: .leading, spacing: 12) {
            if picked == nil {
                Text("Boşluğa hangisi gelir?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityAddTraits(.isHeader)
            }
            sentenceCard
            optionGrid {
                ForEach(shownOptions, id: \.self) { option in
                    optionButton(option)
                        .transition(.opacity)
                }
            }
            if let picked = picked {
                feedback(picked: picked)
                    .id(QuizCardView.feedbackID)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Before the answer every option; after it the right one first, then a wrong pick.
    private var shownOptions: [String] {
        guard let picked = picked else {
            return optionOrder
        }
        return picked == quiz.answer ? [quiz.answer] : [quiz.answer, picked]
    }

    /// The sentence with its blank; after the answer the whole sentence with the answer marked
    /// like the word in an example (rule 1), which can then be heard with "Dinle" (before, it
    /// would give the answer away). Read with an English voice.
    private var sentenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                if picked == nil {
                    Text(QuizCardView.clozeText(quiz.cloze))
                        .accessibilityLabel(QuizCardView.spokenCloze(quiz.cloze))
                } else {
                    Text(ExampleMark.attributed(
                        quiz.filledSentence,
                        lemma: quiz.answer,
                        colorScheme: colorScheme
                    ))
                }
            }
            .font(.system(.title2, design: .serif))
            .foregroundStyle(Theme.ink)
            .englishVoice()
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            if picked != nil {
                QuizListenButton(text: quiz.filledSentence)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, picked == nil ? 18 : 14)
        .cardSurface(cornerRadius: Theme.Radius.card)
    }

    /// The cloze with its blank (the first run of three or more underscores) as a slot of equal
    /// length: a bold ink line on a `surface2` field, so it stands out from the words around it.
    /// No-break spaces keep the slot and the punctuation after it on one line.
    private static func clozeText(_ cloze: String) -> AttributedString {
        guard let blank = cloze.range(of: "_{3,}", options: .regularExpression) else {
            return AttributedString(cloze)
        }
        var slot = AttributedString("\u{00A0}" + String(repeating: "_", count: 7) + "\u{00A0}")
        slot.inlinePresentationIntent = .stronglyEmphasized
        slot.backgroundColor = Theme.surface2
        var result = AttributedString(String(cloze[..<blank.lowerBound]))
        result.append(slot)
        result.append(AttributedString(String(cloze[blank.upperBound...])))
        return result
    }

    /// VoiceOver reads the blank as a word instead of a row of underscores: an English one, since
    /// the sentence is read in an English voice (audit V4).
    private static func spokenCloze(_ cloze: String) -> String {
        return cloze.replacingOccurrences(of: "_{3,}", with: "blank", options: .regularExpression)
    }

    // MARK: Options

    /// A calm capsule (rule 2): `surface` with a `lineStrong` border and the word in the middle;
    /// after the answer the word moves to the leading edge with its mark next to it.
    private func optionButton(_ option: String) -> some View {
        let optionMark = mark(for: option)
        let alignment: TextAlignment = picked == nil ? .center : .leading
        // At accessibility sizes the mark goes under the option instead of squeezing it.
        let rowLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: picked == nil ? .center : .leading, spacing: 4))
            : AnyLayout(HStackLayout(spacing: 12))
        return Button {
            choose(option)
        } label: {
            rowLayout {
                Text(verbatim: option)
                    .font(Theme.Fonts.definition)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(alignment)
                    // Only the English option: the mark next to it keeps the Turkish voice.
                    .englishVoice()
                    .frame(maxWidth: .infinity, alignment: picked == nil ? .center : .leading)
                if let optionMark = optionMark {
                    HStack(spacing: 4) {
                        Image(systemName: optionMark.symbol)
                            .font(.body.weight(.semibold))
                            .accessibilityHidden(true)
                        Text(optionMark.text)
                            .font(.footnote.weight(.bold))
                    }
                    .foregroundStyle(optionMark.color)
                    .fixedSize()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            // Fills its grid cell, so every option is as tall as the tallest.
            .frame(maxWidth: .infinity, minHeight: 56, maxHeight: .infinity)
            .background(optionMark?.fill ?? Theme.surface, in: QuizOptionShape())
            .overlay {
                QuizOptionShape()
                    .strokeBorder(optionMark?.border ?? Theme.lineStrong, lineWidth: optionMark?.lineWidth ?? 1.5)
            }
            .contentShape(QuizOptionShape())
        }
        .buttonStyle(QuizOptionButtonStyle())
        // Not `.disabled`: that would dim the options exactly when the answer is shown.
        .allowsHitTesting(picked == nil)
        // After the answer the options only show the result.
        .accessibilityRemoveTraits(picked == nil ? [] : .isButton)
    }

    private struct Mark {
        let text: String
        let symbol: String
        /// The icon and the word.
        let color: Color
        let fill: Color
        let border: Color
        let lineWidth: CGFloat
    }

    /// The right option in `good` with a check; a wrong pick stays on paper with a cross in ink2:
    /// the word and the icon say it, not a red box (rule 4).
    private func mark(for option: String) -> Mark? {
        guard let picked = picked else {
            return nil
        }
        if option == quiz.answer {
            return Mark(
                text: "Doğru cevap",
                symbol: "checkmark.circle.fill",
                color: Theme.good,
                fill: Theme.goodTint,
                border: Theme.good,
                lineWidth: 2
            )
        }
        if option == picked {
            return Mark(
                text: "Yanlış",
                symbol: "xmark.circle",
                color: Theme.ink2,
                fill: Theme.surface,
                border: Theme.lineStrong,
                lineWidth: 1.5
            )
        }
        return nil
    }

    private func choose(_ option: String) {
        guard picked == nil else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            picked = option
        }
        announce(isRight: option == quiz.answer)
    }

    /// VoiceOver hears how it went, queued after the tap's own speech so it is not cut off:
    /// "Doğru! spoon, Türkçesi: kaşık" or "Doğrusu: spoon, Türkçesi: kaşık", the English word in
    /// an English voice. No "Yanlış": the feedback is about the answer (learning principles 2.4).
    private func announce(isRight: Bool) {
        let answer = quiz.answer
        let gloss = word.glossTR
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            let turkish: [NSAttributedString.Key: Any] = [.accessibilitySpeechLanguage: "tr-TR"]
            let english: [NSAttributedString.Key: Any] = [.accessibilitySpeechLanguage: "en-US"]
            let text = NSMutableAttributedString(
                string: isRight ? QuizCardView.praise + " " : "Doğrusu: ",
                attributes: turkish
            )
            text.append(NSAttributedString(string: answer, attributes: english))
            if let gloss = gloss {
                text.append(NSAttributedString(string: ", Türkçesi: " + gloss, attributes: turkish))
            }
            text.addAttribute(
                .accessibilitySpeechQueueAnnouncement,
                value: true,
                range: NSRange(location: 0, length: text.length)
            )
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }

    // MARK: Feedback

    /// Mockup `.fb`: on a right pick the praise and what the word means; on a wrong pick the right
    /// word with its meaning, what the picked word means and, when the card explains it, why.
    @ViewBuilder
    private func feedback(picked: String) -> some View {
        let isRight = picked == quiz.answer
        VStack(alignment: .leading, spacing: 8) {
            if isRight {
                Label {
                    Text(QuizCardView.praise)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.good)
                        .accessibilityHidden(true)
                }
                .font(.body.weight(.bold))
                .foregroundStyle(Theme.ink)
                wordLine
            } else {
                rightAnswerLine
                if !answerIsHeadword {
                    wordLine
                }
                pickedLine(picked)
                if let reason = reason(for: picked) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Neden?")
                            .font(.subheadline.weight(.bold))
                        Text(verbatim: reason.why)
                            .font(.subheadline)
                            .lineSpacing(1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Theme.lineStrong)
                            .frame(height: 1)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        // Not `.combine`: one element is read in one voice, and the English words need their own
        // (audit V3, `FeedbackSpeech`).
        .accessibilityElement(children: .contain)
    }

    /// The answer is the card's word itself (not another form of it, "broke down" for
    /// "break down"), so its meaning can follow it on the same line.
    private var answerIsHeadword: Bool {
        return quiz.answer.caseInsensitiveCompare(word.lemma) == .orderedSame
    }

    /// "Doğrusu: spoon = kaşık" with a light bulb, in one line; only "Doğrusu: broke down" when the
    /// answer is another form of the word, whose meaning then follows on its own line.
    private var rightAnswerLine: some View {
        let answer: Text = Text(verbatim: quiz.answer)
            .font(.system(.body, design: .serif).weight(.bold))
        let gloss = answerIsHeadword ? word.glossTR : nil
        return Label {
            if let gloss = gloss {
                Text("Doğrusu: \(answer) = \(gloss)")
            } else {
                Text("Doğrusu: \(answer)")
            }
        } icon: {
            Image(systemName: "lightbulb")
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
        }
        .font(.body.weight(.bold))
        .foregroundStyle(Theme.ink)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityRepresentation {
            FeedbackSpeech(lead: "Doğrusu:", english: quiz.answer, meaning: gloss)
        }
    }

    /// Mockup `.fb .m`: "spoon = kaşık", the word in bold serif, the meaning in the UI face.
    /// One line under the verdict, never larger than it (the quiz screen has no band).
    @ViewBuilder
    private var wordLine: some View {
        let headword: Text = Text(verbatim: word.lemma)
            .font(.system(.callout, design: .serif).weight(.bold))
        if let gloss = word.glossTR {
            Text("\(headword) = \(gloss)")
                .font(.callout)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityRepresentation {
                    FeedbackSpeech(english: word.lemma, meaning: gloss)
                }
        } else {
            headword
                .foregroundStyle(Theme.ink)
                .englishVoice()
        }
    }

    /// "Senin seçtiğin: knife = bıçak"; only the word when no card has it.
    private func pickedLine(_ picked: String) -> some View {
        let pickedWord: Text = Text(verbatim: picked)
            .font(.system(.subheadline, design: .serif).weight(.bold))
            .foregroundStyle(Theme.ink)
        let meaning = optionMeanings[picked]
        return Group {
            if let meaning = meaning {
                Text("Senin seçtiğin: \(pickedWord) = \(meaning)")
            } else {
                Text("Senin seçtiğin: \(pickedWord)")
            }
        }
        .font(.subheadline)
        .foregroundStyle(Theme.ink2)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityRepresentation {
            FeedbackSpeech(lead: "Senin seçtiğin:", english: picked, meaning: meaning)
        }
    }

    /// The card's Dikkat entry whose wrong or right sentence uses the picked word as a whole
    /// word (README point 6); nil otherwise, and then no "Neden?" is shown.
    private func reason(for picked: String) -> CardDetail.Mistake? {
        return mistakes.first { mistake in
            MistakeDiff.sentence(mistake.wrong, containsWord: picked)
                || MistakeDiff.sentence(mistake.right, containsWord: picked)
        }
    }

    // MARK: Actions

    /// Right: "Devam", then "Zordu" / "Kolaydı" for a word that came back sooner or later than
    /// it should. Wrong: when the word comes back, then "Devam".
    @ViewBuilder
    private func actions(isRight: Bool) -> some View {
        if isRight {
            // Side by side, stacked at accessibility sizes (like the options): half a phone's
            // width would break "Kolaydı" in the middle of the word.
            let pairLayout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(spacing: 8))
                : AnyLayout(HStackLayout(spacing: 8))
            VStack(spacing: 8) {
                Button("Devam") {
                    onContinue(.right)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                .accessibilityHint(hint(for: .right, fallback: ""))
                Text("Ya da bu soru nasıl geldi?")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                pairLayout {
                    Button {
                        onContinue(.hard)
                    } label: {
                        gradeLabel("Zordu", symbol: "tortoise")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                    .accessibilityHint(hint(for: .hard, fallback: "Kelime daha erken tekrar gelir"))
                    Button {
                        onContinue(.easy)
                    } label: {
                        gradeLabel("Kolaydı", symbol: "hare")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                    .accessibilityHint(hint(for: .easy, fallback: "Kelime daha geç tekrar gelir"))
                }
            }
        } else {
            VStack(spacing: 10) {
                if let time = returnTimes[.wrong] {
                    Label {
                        Text(verbatim: "Bu kelime \(time) yine gelir.")
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                }
                Button("Devam") {
                    onContinue(.wrong)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            }
        }
    }

    /// The icon goes at the largest text sizes, as on the flashcard's answers (`GradeLabel`).
    @ViewBuilder
    private func gradeLabel(_ title: String, symbol: String) -> some View {
        if dynamicTypeSize < .xxxLarge {
            Label(title, systemImage: symbol)
        } else {
            Text(title)
        }
    }

    /// "Kelime 2 gün sonra yeniden gelir" from the caller's times; `fallback` without one.
    private func hint(for outcome: QuizOutcome, fallback: String) -> String {
        guard let time = returnTimes[outcome] else {
            return fallback
        }
        return "Kelime \(time) yeniden gelir"
    }
}

/// The quiz options: `columns` equal columns while every option fits its cell on one line and
/// fills the grid evenly, otherwise one column; every option as tall as the tallest, so none
/// looks more important than another.
private struct QuizOptionGrid: SwiftUI.Layout {
    var columns: Int
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width: CGFloat
        if let proposed = proposal.width, proposed.isFinite {
            width = proposed
        } else {
            width = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        }
        return CGSize(width: width, height: arrangement(width: width, subviews: subviews).height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let grid = arrangement(width: bounds.width, subviews: subviews)
        let cell = ProposedViewSize(width: grid.cellWidth, height: grid.rowHeight)
        for (index, subview) in subviews.enumerated() {
            let column = CGFloat(index % grid.columns)
            let row = CGFloat(index / grid.columns)
            subview.place(
                at: CGPoint(
                    x: bounds.minX + column * (grid.cellWidth + spacing),
                    y: bounds.minY + row * (grid.rowHeight + spacing)
                ),
                anchor: .topLeading,
                proposal: cell
            )
        }
    }

    private func arrangement(
        width: CGFloat,
        subviews: Subviews
    ) -> (columns: Int, cellWidth: CGFloat, rowHeight: CGFloat, height: CGFloat) {
        guard !subviews.isEmpty else {
            return (columns: 1, cellWidth: width, rowHeight: 0, height: 0)
        }
        var count = max(1, min(columns, subviews.count))
        if count > 1 {
            let half = cellWidth(in: width, columns: count)
            let fits = subviews.allSatisfy { $0.sizeThatFits(.unspecified).width <= half }
            if !fits || subviews.count % count != 0 {
                count = 1
            }
        }
        let cell = cellWidth(in: width, columns: count)
        let rowHeight = subviews
            .map { $0.sizeThatFits(ProposedViewSize(width: cell, height: nil)).height }
            .max() ?? 0
        let rows = (subviews.count + count - 1) / count
        let height = CGFloat(rows) * rowHeight + CGFloat(rows - 1) * spacing
        return (columns: count, cellWidth: cell, rowHeight: rowHeight, height: height)
    }

    private func cellWidth(in width: CGFloat, columns: Int) -> CGFloat {
        return max(0, (width - spacing * CGFloat(columns - 1)) / CGFloat(columns))
    }
}

/// A quiz option's outline: a capsule while the option is one line high; taller (accessibility
/// sizes, a long option) it keeps the capsule's 28 pt ends as corners, so the text never runs
/// into the curve.
private struct QuizOptionShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let box = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let radius = max(0, 28 - insetAmount)
        // The same corner style for both, so the outline does not change at the switch.
        if box.height <= radius * 2 {
            return Capsule(style: .circular).path(in: box)
        }
        return RoundedRectangle(cornerRadius: radius, style: .circular).path(in: box)
    }

    func inset(by amount: CGFloat) -> QuizOptionShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

/// Pressed state of a quiz option: a light dip, no scaling under Reduce Motion.
private struct QuizOptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QuizOptionPressBody(configuration: configuration)
    }
}

private struct QuizOptionPressBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// What VoiceOver reads for a feedback line ("Doğrusu: spoon = kaşık") instead of the line: one
/// element is read in one voice, so the English word is an element of its own in an English
/// voice (audit V3) between the Turkish parts ("Doğrusu:", "Türkçesi: kaşık"). On screen the
/// line stays one `Text` that wraps as a sentence.
private struct FeedbackSpeech: View {
    var lead: String?
    let english: String
    let meaning: String?

    var body: some View {
        if let lead = lead {
            Text(lead)
        }
        Text(verbatim: english)
            .englishVoice()
        if let meaning = meaning {
            Text("Türkçesi: " + meaning)
        }
    }
}

/// "Dinle" under the answered sentence (the labeled capsule of README "Akış", like the card's
/// `CardListenCapsule`, which the snapshot bundle does not compile): a `surface2` capsule that
/// reads the sentence aloud; a second tap stops it. The speaker waves while it reads, unless
/// Reduce Motion is on.
private struct QuizListenButton: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let text: String

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            Label {
                Text("Dinle")
            } icon: {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
            }
            .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
        .accessibilityLabel(isSpeaking ? "Durdur" : "Cümleyi dinle")
    }
}

/// The round speaker of the "Tekrar" tab (mockup `.spk`): a 34 pt `surface2` circle in a 44 pt
/// target that reads `text` aloud; a second tap stops it. The speaker waves while it reads,
/// unless Reduce Motion is on. Lives here because the snapshot bundle compiles this file (and
/// Speaker.swift) but not the card pieces; `ReviewView` uses it.
struct ReviewSpeakerButton: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .subheadline) private var circleSize: CGFloat = 34
    let text: String
    var accessibilityName = "Dinle"

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.subheadline.weight(.semibold))
                .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
                .foregroundStyle(Theme.ink)
                .frame(width: circleSize, height: circleSize)
                .background(Theme.surface2, in: Circle())
                .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSpeaking ? "Durdur" : accessibilityName)
    }
}
