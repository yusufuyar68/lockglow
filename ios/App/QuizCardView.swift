import SwiftUI
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
/// and four options (serif: they are English). After a tap only the right option ("Doğru cevap")
/// and a wrong pick ("Yanlış") stay, marked with icons and words, never color alone; the feedback
/// below says what the word means, on a wrong pick also what the picked word means ("Senin
/// seçtiğin: lend = ödünç vermek") and, when the card's Dikkat sentences use the picked word,
/// why ("Neden?"). `onContinue` reports how it went: after a right pick the learner can also say
/// it was hard or easy, otherwise "Devam" is a plain right answer.
/// Give each word its own identity (`.id(word.id)`) so the pick resets between cards.
///
/// Uses only `Theme` and the Shared types (no `Palette`): the snapshot bundle compiles it too.
struct QuizCardView: View {
    /// `.scrolling` (the "Tekrar" tab): the question scrolls and the buttons sit in an opaque bar
    /// at the bottom (`safeAreaInset`); after the answer the feedback is scrolled into view.
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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// `initialPick` is for snapshot tests: renders the answered state directly.
    init(
        word: WidgetWord,
        quiz: CardDetail.Quiz,
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
    }

    private static let feedbackID = "quiz.feedback"

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
                        question
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 16)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        if let picked = picked {
                            actions(isRight: picked == quiz.answer)
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                                .padding(.bottom, 8)
                                .frame(maxWidth: .infinity)
                                .background(Theme.bg)
                        }
                    }
                    .onChange(of: picked) { _, newValue in
                        guard newValue != nil else {
                            return
                        }
                        // On the next turn of the main actor, once the options collapsed and the
                        // feedback was laid out.
                        let animation: Animation? = reduceMotion ? nil : .easeInOut(duration: 0.3)
                        Task { @MainActor in
                            withAnimation(animation) {
                                proxy.scrollTo(QuizCardView.feedbackID, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        // The speaker buttons are borderless: ink, never the system blue (rule 2).
        .tint(Theme.ink)
    }

    // MARK: Question

    private var question: some View {
        VStack(alignment: .leading, spacing: 12) {
            if picked == nil {
                Text("Boşluğa hangisi gelir?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
            }
            sentenceCard
            VStack(spacing: 10) {
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

    /// Before the answer every option; after it only the right one and a wrong pick.
    private var shownOptions: [String] {
        let options = quiz.options(seed: word.id)
        guard let picked = picked else {
            return options
        }
        return options.filter { $0 == quiz.answer || $0 == picked }
    }

    /// The sentence with its blank; after the answer the whole sentence with the answer marked
    /// like the word in an example (rule 1), which can then be heard (before, the speaker would
    /// give the answer away).
    private var sentenceCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            Group {
                if picked == nil {
                    Text(verbatim: quiz.cloze)
                        .accessibilityLabel(QuizCardView.spokenCloze(quiz.cloze))
                } else {
                    Text(ExampleMark.attributed(quiz.filledSentence, lemma: quiz.answer, colorScheme: colorScheme))
                }
            }
            .font(.system(.title2, design: .serif))
            .foregroundStyle(Theme.ink)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            if picked != nil {
                HStack {
                    Spacer(minLength: 0)
                    SpeakButton(text: quiz.filledSentence, accessibilityName: "Cümleyi dinle")
                }
                .padding(.trailing, -10)
                .padding(.bottom, -8)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, picked == nil ? 20 : 14)
        .cardSurface(cornerRadius: Theme.Radius.card)
    }

    /// VoiceOver reads the blank as a word instead of a row of underscores.
    private static func spokenCloze(_ cloze: String) -> String {
        return cloze.replacingOccurrences(of: "_{3,}", with: "boşluk", options: .regularExpression)
    }

    // MARK: Options

    private func optionButton(_ option: String) -> some View {
        let optionMark = self.mark(for: option)
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
        // At accessibility sizes the mark goes under the option instead of squeezing it.
        let rowLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(spacing: 12))
        return Button {
            choose(option)
        } label: {
            rowLayout {
                Text(verbatim: option)
                    .font(Theme.Fonts.definition)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let optionMark = optionMark {
                    HStack(spacing: 4) {
                        Image(systemName: optionMark.symbol)
                            .font(.body.weight(.semibold))
                        Text(optionMark.text)
                            .font(.footnote.weight(.bold))
                    }
                    .foregroundStyle(optionMark.color)
                    .fixedSize()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(optionMark?.fill ?? Theme.surface, in: shape)
            .overlay {
                shape.strokeBorder(optionMark?.color ?? Theme.lineStrong, lineWidth: optionMark == nil ? 1.5 : 2)
            }
            .contentShape(shape)
        }
        .buttonStyle(QuizOptionButtonStyle())
        // Not `.disabled`: that would dim the options exactly when the answer is shown.
        .allowsHitTesting(picked == nil)
    }

    private struct Mark: Equatable {
        let text: String
        let symbol: String
        let color: Color
        let fill: Color
    }

    private func mark(for option: String) -> Mark? {
        guard let picked = picked else {
            return nil
        }
        if option == quiz.answer {
            return Mark(text: "Doğru cevap", symbol: "checkmark.circle.fill", color: Theme.good, fill: Theme.goodTint)
        }
        if option == picked {
            return Mark(text: "Yanlış", symbol: "xmark.circle.fill", color: Theme.bad, fill: Theme.badTint)
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
        let verdict = option == quiz.answer ? "Doğru!" : "Doğrusu: " + quiz.answer
        AccessibilityNotification.Announcement(verdict).post()
    }

    // MARK: Feedback

    @ViewBuilder
    private func feedback(picked: String) -> some View {
        let isRight = picked == quiz.answer
        VStack(alignment: .leading, spacing: 10) {
            if isRight {
                Label {
                    Text("Doğru!")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.good)
                }
                .font(.body.weight(.bold))
                .foregroundStyle(Theme.ink)
            } else {
                Label {
                    Text("Doğrusu: \(Text(verbatim: quiz.answer).font(.system(.body, design: .serif).weight(.bold)))")
                } icon: {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(Theme.ink2)
                }
                .font(.body.weight(.bold))
                .foregroundStyle(Theme.ink)
            }
            wordLine
            if !isRight {
                pickedLine(picked)
                if let reason = reason(for: picked) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Neden?")
                            .font(.subheadline.weight(.bold))
                        Text(verbatim: reason.why)
                            .font(.subheadline)
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
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    /// The learned word with the phosphor band (the one band on the screen) and its meaning.
    /// Side by side when they fit, otherwise the meaning goes under the word.
    @ViewBuilder
    private var wordLine: some View {
        let headword = Text(verbatim: word.lemma)
            .englishWordStyle(size: 24, maxSize: 34)
            .phosphorBand()
        if let gloss = word.glossTR {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    headword
                    Text(verbatim: "= " + gloss)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                        .fixedSize()
                }
                VStack(alignment: .leading, spacing: 10) {
                    headword
                    Text(verbatim: gloss)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom, 6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(word.lemma + ", Türkçesi: " + gloss)
        } else {
            headword
                .padding(.bottom, 6)
        }
    }

    /// "Senin seçtiğin: lend = ödünç vermek"; only the word when no card has it.
    private func pickedLine(_ picked: String) -> some View {
        let pickedWord: Text = Text(verbatim: picked)
            .font(.system(.subheadline, design: .serif).weight(.bold))
            .foregroundStyle(Theme.ink)
        return Group {
            if let meaning = optionMeanings[picked] {
                Text("Senin seçtiğin: \(pickedWord) = \(meaning)")
            } else {
                Text("Senin seçtiğin: \(pickedWord)")
            }
        }
        .font(.subheadline)
        .foregroundStyle(Theme.ink2)
        .fixedSize(horizontal: false, vertical: true)
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
            VStack(spacing: 8) {
                Button("Devam") {
                    onContinue(.right)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                .accessibilityHint(hint(for: .right, fallback: ""))
                Text("Ya da bu soru nasıl geldi?")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.ink2)
                    .padding(.top, 2)
                HStack(spacing: 8) {
                    Button {
                        onContinue(.hard)
                    } label: {
                        Label("Zordu", systemImage: "tortoise")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                    .accessibilityHint(hint(for: .hard, fallback: "Kelime daha erken tekrar gelir"))
                    Button {
                        onContinue(.easy)
                    } label: {
                        Label("Kolaydı", systemImage: "hare")
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

    /// "Kelime 2 gün sonra yeniden gelir" from the caller's times; `fallback` without one.
    private func hint(for outcome: QuizOutcome, fallback: String) -> String {
        guard let time = returnTimes[outcome] else {
            return fallback
        }
        return "Kelime \(time) yeniden gelir"
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
