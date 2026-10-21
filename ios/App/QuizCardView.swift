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
        // A light haptic on a right answer only (mockup "Hareket"); a wrong pick stays silent.
        .sensoryFeedback(.success, trigger: picked) { oldValue, newValue in
            oldValue == nil && newValue == quiz.answer
        }
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
            VStack(spacing: 9) {
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

    /// The sentence with its blank; after the answer the whole sentence with the answer in bold
    /// (mockup `.filled`, no yellow mark), which can then be heard (before, the speaker would give
    /// the answer away). Read with an English voice.
    private var sentenceCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            Group {
                if picked == nil {
                    Text(verbatim: quiz.cloze)
                        .accessibilityLabel(QuizCardView.spokenCloze(quiz.cloze))
                } else {
                    Text(ExampleMark.attributed(
                        quiz.filledSentence,
                        lemma: quiz.answer,
                        colorScheme: colorScheme,
                        highlighted: false
                    ))
                }
            }
            .font(.system(.title2, design: .serif))
            .foregroundStyle(Theme.ink)
            .englishVoice()
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            if picked != nil {
                HStack {
                    Spacer(minLength: 0)
                    ReviewSpeakerButton(text: quiz.filledSentence, accessibilityName: "Cümleyi dinle")
                }
                // The 44 pt target reaches into the card's padding instead of making it taller.
                .padding(.trailing, -6)
                .padding(.bottom, -8)
            }
        }
        .padding(.horizontal, picked == nil ? 18 : 16)
        .padding(.vertical, picked == nil ? 18 : 12)
        .cardSurface(cornerRadius: Theme.Radius.card)
    }

    /// VoiceOver reads the blank as a word instead of a row of underscores.
    private static func spokenCloze(_ cloze: String) -> String {
        return cloze.replacingOccurrences(of: "_{3,}", with: "boşluk", options: .regularExpression)
    }

    // MARK: Options

    private func optionButton(_ option: String) -> some View {
        let optionMark = mark(for: option)
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
                    // Only the English option: the mark next to it keeps the Turkish voice.
                    .englishVoice()
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
        UIAccessibility.post(notification: .announcement, argument: verdict)
    }

    // MARK: Feedback

    /// Mockup `.fb`: the verdict, the word with its meaning, and on a wrong pick what the picked
    /// word means and, when the card explains it, why.
    @ViewBuilder
    private func feedback(picked: String) -> some View {
        let isRight = picked == quiz.answer
        VStack(alignment: .leading, spacing: 10) {
            verdict(isRight: isRight)
            wordLine
            if !isRight {
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
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    /// "Doğru!" with a check in `good`, or "Doğrusu: borrow" with a light bulb: the word, never
    /// the color alone, says how it went (rule 4).
    @ViewBuilder
    private func verdict(isRight: Bool) -> some View {
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
    }

    /// Mockup `.fb .m`: "borrow = ödünç almak", the word in bold serif, the meaning in the UI face.
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
                .accessibilityLabel(word.lemma + ", Türkçesi: " + gloss)
        } else {
            headword
                .foregroundStyle(Theme.ink)
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

/// The round speaker of the "Tekrar" tab (mockup `.spk`): a 34 pt `surface2` circle in a 44 pt
/// target that reads `text` aloud; a second tap stops it. The speaker waves while it reads,
/// unless Reduce Motion is on. Lives here because the snapshot bundle compiles this file (and
/// Speaker.swift) but not the card pieces; `ReviewView` uses it too.
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
