import AVFoundation
import SwiftUI
import UIKit
import CoreModels
import Learning

/// Whether "Dinle ve seç" can be asked now (docs/tasarim/ogrenme_ilkeleri.md 2.4, "Dinle ve seç,
/// Yaz"). Not with VoiceOver on: it reads the options aloud, over the word, and the question would
/// be about reading. Not with the volume all the way down, nor without an English voice on the
/// phone. The silent switch does not count: the app's speech plays through it
/// (`WordSpeech.activateSession`), as on every "Dinle".
enum ListenAvailability {
    @MainActor static var isAvailable: Bool {
        guard !UIAccessibility.isVoiceOverRunning, WordSpeech.voice != nil else {
            return false
        }
        return AVAudioSession.sharedInstance().outputVolume > 0
    }
}

/// "Dinle ve seç" (boxes 2–3, every other question): the word is read aloud once when the card
/// comes, and again with "Dinle"; the learner picks what was heard from four English words, one
/// per row (serif, English voice), its confusable partners among them once settled
/// (`ReviewPlanner.listenQuestion`). After a tap only the right option ("Doğru cevap") and a wrong
/// pick ("Yanlış") stay, marked with icons and words, never color alone; the feedback says what the
/// word means and, after a wrong pick, what the picked word means, with a "Dinle" for each so the
/// two can be heard one after the other. The buttons are the quiz's (`ReviewAnswerActions`):
/// nothing moves on by itself. Give each word its own identity (`.id(word.id)`).
struct ListenQuestionView: View {
    let word: WidgetWord
    let question: ListenQuestion
    /// When the word comes back after each outcome (`ReviewView.quizReturnTimes`).
    let returnTimes: [QuizOutcome: String]
    let onContinue: (QuizOutcome) -> Void

    @State private var picked: String?
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let feedbackID = "listen.feedback"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dinle ve seç")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink2)
                            .accessibilityAddTraits(.isHeader)
                        if picked == nil {
                            Text("Duyduğun kelimeyi seç.")
                                .font(.subheadline)
                                .foregroundStyle(Theme.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    listenCard
                    VStack(spacing: 10) {
                        ForEach(shownOptions, id: \.self) { option in
                            optionButton(option)
                                .transition(.opacity)
                        }
                    }
                    if let picked = picked {
                        feedback(picked: picked)
                            .id(ListenQuestionView.feedbackID)
                            .transition(.opacity)
                        // At accessibility sizes a fixed bar would leave almost no room for the
                        // feedback: the buttons scroll with it instead (as in the quiz).
                        if dynamicTypeSize.isAccessibilitySize {
                            actions(picked: picked)
                        }
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
                    actions(picked: picked)
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
                // Once the options have collapsed and the bar is laid out: the feedback must never
                // stay hidden under it (README point 6). At most 200 ms (2.4).
                let animation: Animation? = reduceMotion ? nil : .easeInOut(duration: 0.2)
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 60_000_000)
                    withAnimation(animation) {
                        proxy.scrollTo(ListenQuestionView.feedbackID, anchor: .bottom)
                    }
                }
            }
        }
        // The speaker buttons are ink, never the system blue (rule 2).
        .tint(Theme.ink)
        // A light haptic on a right answer only; a wrong pick stays silent (2.4).
        .sensoryFeedback(.success, trigger: picked) { oldValue, newValue in
            oldValue == nil && newValue == question.answer
        }
        // The word is read once when the card comes: the question starts with listening.
        .task(id: question.wordID) {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled, picked == nil, speaker.speakingText != question.answer else {
                return
            }
            speaker.toggle(question.answer)
        }
        .onDisappear {
            speaker.stop()
        }
    }

    // MARK: Question

    /// A large "Dinle" on the card: the speaker in a 64 pt circle and its name; a second tap while
    /// it reads stops it ("Durdur"). Nothing moves while it reads (2.2).
    private var listenCard: some View {
        let isSpeaking = speaker.speakingText == question.answer
        let rowLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
            : AnyLayout(HStackLayout(spacing: 16))
        return Button {
            speaker.toggle(question.answer)
        } label: {
            rowLayout {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 64, height: 64)
                    .background(Theme.surface2, in: Circle())
                    .overlay {
                        Circle().strokeBorder(Theme.lineStrong, lineWidth: 1)
                    }
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(isSpeaking ? "Durdur" : "Dinle")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Text("Bir kez daha duymak için dokun.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .cardSurface(cornerRadius: Theme.Radius.card)
        .accessibilityLabel(isSpeaking ? "Durdur" : "Kelimeyi dinle")
        .accessibilityInputLabels(isSpeaking ? [Text("Durdur")] : [Text("Dinle"), Text("Kelimeyi dinle")])
    }

    /// Before the answer every option; after it the right one first, then a wrong pick.
    private var shownOptions: [String] {
        guard let picked = picked else {
            return question.options
        }
        return picked == question.answer ? [question.answer] : [question.answer, picked]
    }

    /// A calm option (rule 2), as tall as a quiz option (56 pt): `surface` with a `lineStrong`
    /// border; after the answer the mark next to the word.
    private func optionButton(_ option: String) -> some View {
        let mark = ReviewOptionMark.mark(for: option, answer: question.answer, picked: picked)
        let rowLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(spacing: 12))
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        return Button {
            choose(option)
        } label: {
            rowLayout {
                Text(verbatim: option)
                    .font(Theme.Fonts.definition)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                    .englishVoice()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let mark = mark {
                    mark.label
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(mark?.fill ?? Theme.surface, in: shape)
            .overlay {
                shape.strokeBorder(mark?.border ?? Theme.lineStrong, lineWidth: mark?.lineWidth ?? 1.5)
            }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        // A keyboard: 1–4 in reading order, before the answer (`AnswerKeys`).
        .keyboardShortcut(picked == nil ? AnswerKeys.answer(question.options.firstIndex(of: option)) : nil)
        // Not `.disabled`: that would dim the options exactly when the answer is shown.
        .allowsHitTesting(picked == nil)
        // One element has one voice (QuizCardView.optionButton): before the answer the button with
        // the English word alone; after it the word, then the mark in Turkish.
        .accessibilityRepresentation {
            if picked == nil {
                Button {
                    choose(option)
                } label: {
                    Text(verbatim: option)
                        .englishVoice()
                }
            } else {
                Text(verbatim: option)
                    .englishVoice()
                if let mark = mark {
                    Text(mark.text)
                }
            }
        }
    }

    private func choose(_ option: String) {
        guard picked == nil else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            picked = option
        }
        ReviewAnnouncement.post(
            lead: option == question.answer ? "Doğru. " : "Doğrusu: ",
            english: question.answer,
            meaning: word.glossTR
        )
    }

    // MARK: Feedback

    /// About the answer, never the learner (rule 12): "Doğru." and "borrow = ödünç almak"; after a
    /// wrong pick "Doğrusu: …", what the picked word means and a "Dinle" for each word.
    private func feedback(picked: String) -> some View {
        let isRight = picked == question.answer
        return VStack(alignment: .leading, spacing: 10) {
            if isRight {
                ReviewVerdictLine(text: "Doğru.", symbol: "checkmark.circle.fill", symbolColor: Theme.good)
                ReviewWordLine(lemma: question.answer, meaning: word.glossTR)
                CardListenCapsule(text: question.answer, accessibilityName: "Kelimeyi dinle")
            } else {
                ReviewWordLine(lead: "Doğrusu:", lemma: question.answer, meaning: word.glossTR, isVerdict: true)
                ReviewWordLine(lead: "Senin seçtiğin:", lemma: picked, meaning: question.meanings[picked], isSecondary: true)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        listenWord(question.answer, name: "Doğru kelimeyi dinle")
                        listenWord(picked, name: "Seçtiğin kelimeyi dinle")
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        listenWord(question.answer, name: "Doğru kelimeyi dinle")
                        listenWord(picked, name: "Seçtiğin kelimeyi dinle")
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        // Not `.combine`: the English words need their own voice (audit V3, `FeedbackSpeech`).
        .accessibilityElement(children: .contain)
    }

    /// A capsule that reads `text`: the speaker and the word itself, so the two words of a wrong
    /// pick can be told apart; "Durdur" while it reads.
    private func listenWord(_ text: String, name: String) -> some View {
        let isSpeaking = speaker.speakingText == text
        return Button {
            speaker.toggle(text)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .accessibilityHidden(true)
                if isSpeaking {
                    Text("Durdur")
                } else {
                    Text(verbatim: text)
                        .font(.system(.subheadline, design: .serif).weight(.semibold))
                }
            }
        }
        .buttonStyle(CardCapsuleButtonStyle())
        // A Turkish name: an English label would read the whole button in an English voice.
        .accessibilityLabel(isSpeaking ? "Durdur" : name)
        .accessibilityValue(isSpeaking ? "" : text)
        .accessibilityInputLabels([Text(isSpeaking ? "Durdur" : name), Text(verbatim: text)])
    }

    private func actions(picked: String) -> some View {
        ReviewAnswerActions(
            verdict: picked == question.answer ? .right : .wrong,
            returnTimes: returnTimes,
            onContinue: onContinue
        )
    }
}

// MARK: - Shared with TypeQuestionView

/// The buttons under a "Dinle ve seç" or "İngilizcesini yaz" answer, as in the quiz
/// (`QuizCardView.actions`, the names of the summary and the guide). When each answer brings the
/// word back is a value, not a hint (audit V9).
/// - `right`: "Devam", then "Zor muydu, kolay mı?" with "Zor" and "Kolay".
/// - `hard` (a spelling mistake, or a letter hint was taken): when the word comes back, "Devam"
///   counts as "Zor".
/// - `wrong`: when the word comes back, "Devam".
struct ReviewAnswerActions: View {
    enum Verdict {
        case right
        case hard
        case wrong
    }

    let verdict: Verdict
    let returnTimes: [QuizOutcome: String]
    let onContinue: (QuizOutcome) -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        switch verdict {
        case .right:
            // Side by side, stacked at accessibility sizes: half a phone's width would break the
            // labels in the middle of a word.
            let pairLayout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(spacing: 8))
                : AnyLayout(HStackLayout(spacing: 8))
            VStack(spacing: 8) {
                Button("Devam") {
                    onContinue(.right)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                .keyboardShortcut(AnswerKeys.main)
                .accessibilityValue(returnValue(for: .right))
                Text("Zor muydu, kolay mı?")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                pairLayout {
                    Button {
                        onContinue(.hard)
                    } label: {
                        gradeLabel("Zor", symbol: "tortoise")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                    .keyboardShortcut(AnswerKeys.answer(0))
                    .accessibilityValue(returnValue(for: .hard))
                    .accessibilityHint(returnTimes[.hard] == nil ? "Kelime daha erken yine gelir" : "")
                    Button {
                        onContinue(.easy)
                    } label: {
                        gradeLabel("Kolay", symbol: "hare")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                    .keyboardShortcut(AnswerKeys.answer(1))
                    .accessibilityValue(returnValue(for: .easy))
                    .accessibilityHint(returnTimes[.easy] == nil ? "Kelime daha geç yine gelir" : "")
                }
            }
        case .hard:
            continueButton(.hard)
        case .wrong:
            continueButton(.wrong)
        }
    }

    private func continueButton(_ outcome: QuizOutcome) -> some View {
        VStack(spacing: 10) {
            if let time = returnTimes[outcome] {
                Label {
                    Text(verbatim: time == QuizCardView.nextRoundTime
                         ? "Bu kelimeyi bir sonraki turda yine soracağız."
                         : "Bu kelime \(time) yine gelir.")
                } icon: {
                    Image(systemName: "clock")
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.ink2)
                .multilineTextAlignment(.center)
            }
            Button("Devam") {
                onContinue(outcome)
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            .keyboardShortcut(AnswerKeys.main)
        }
    }

    /// The icon goes at the largest text sizes, as in the quiz.
    @ViewBuilder
    private func gradeLabel(_ title: String, symbol: String) -> some View {
        if dynamicTypeSize < .xxxLarge {
            Label(title, systemImage: symbol)
        } else {
            Text(title)
        }
    }

    private func returnValue(for outcome: QuizOutcome) -> String {
        return returnTimes[outcome].map { "\($0) yine gelir" } ?? ""
    }
}

/// The mark next to an option after the answer: the right option in `good` with a check; a wrong
/// pick stays on paper with a cross in ink2 (the word and the icon say it, not a red box; rule 4).
struct ReviewOptionMark {
    let text: String
    let symbol: String
    let color: Color
    let fill: Color
    let border: Color
    let lineWidth: CGFloat

    static func mark(for option: String, answer: String, picked: String?) -> ReviewOptionMark? {
        guard let picked = picked else {
            return nil
        }
        if option == answer {
            return ReviewOptionMark(
                text: "Doğru cevap",
                symbol: "checkmark.circle.fill",
                color: Theme.good,
                fill: Theme.goodTint,
                border: Theme.good,
                lineWidth: 2
            )
        }
        if option == picked {
            return ReviewOptionMark(
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

    var label: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .accessibilityHidden(true)
            Text(text)
                .font(.footnote.weight(.bold))
        }
        .foregroundStyle(color)
        .fixedSize()
    }
}

/// "Doğru." with an icon: the first line of a right answer's feedback.
struct ReviewVerdictLine: View {
    let text: String
    let symbol: String
    var symbolColor: Color = Theme.ink2

    var body: some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(symbolColor)
                .accessibilityHidden(true)
        }
        .font(.body.weight(.bold))
        .foregroundStyle(Theme.ink)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// A feedback line "lead word = meaning" ("Doğrusu: borrow = ödünç almak", "Senin seçtiğin: lend =
/// ödünç vermek"): the word in bold serif, the meaning in the UI face; only "lead word" without a
/// meaning. `isVerdict`: the bold first line with a light bulb; `isSecondary`: smaller, in ink2.
/// VoiceOver reads it in parts, the English word in an English voice (`FeedbackSpeech`).
struct ReviewWordLine: View {
    var lead: String?
    let lemma: String
    let meaning: String?
    var isVerdict = false
    var isSecondary = false

    /// The line as one `Text`, so it wraps as a sentence.
    private var line: Text {
        let textStyle: Font.TextStyle = isSecondary ? .subheadline : (isVerdict ? .body : .callout)
        let word: Text = Text(verbatim: lemma)
            .font(.system(textStyle, design: .serif).weight(.bold))
            .foregroundStyle(Theme.ink)
        let shownMeaning = (meaning?.isEmpty ?? true) ? nil : meaning
        switch (lead, shownMeaning) {
        case let (lead?, meaning?):
            return Text("\(lead) \(word) = \(meaning)")
        case let (lead?, nil):
            return Text("\(lead) \(word)")
        case let (nil, meaning?):
            return Text("\(word) = \(meaning)")
        case (nil, nil):
            return word
        }
    }

    var body: some View {
        Group {
            if isVerdict {
                Label {
                    line
                } icon: {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(Theme.ink2)
                        .accessibilityHidden(true)
                }
                .font(.body.weight(.bold))
                .foregroundStyle(Theme.ink)
            } else {
                line
                    .font(isSecondary ? .subheadline : .callout)
                    .foregroundStyle(isSecondary ? Theme.ink2 : Theme.ink)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityRepresentation {
            FeedbackSpeech(lead: lead, english: lemma, meaning: (meaning?.isEmpty ?? true) ? nil : meaning)
        }
    }
}

/// What VoiceOver hears after an answer, queued after the tap's own speech at high priority so the
/// card changing under the finger does not cut it off (as `QuizCardView.announce`): "Doğru. borrow,
/// Türkçesi: ödünç almak", the English word in an English voice.
enum ReviewAnnouncement {
    @MainActor static func post(lead: String, english: String?, meaning: String?) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            let turkish: [NSAttributedString.Key: Any] = [.accessibilitySpeechLanguage: "tr-TR"]
            let englishVoice: [NSAttributedString.Key: Any] = [.accessibilitySpeechLanguage: "en-US"]
            let text = NSMutableAttributedString(string: lead, attributes: turkish)
            if let english = english {
                text.append(NSAttributedString(string: english, attributes: englishVoice))
            }
            if let meaning = meaning, !meaning.isEmpty {
                text.append(NSAttributedString(string: ", Türkçesi: " + meaning, attributes: turkish))
            }
            let whole = NSRange(location: 0, length: text.length)
            text.addAttribute(.accessibilitySpeechQueueAnnouncement, value: true, range: whole)
            text.addAttribute(.accessibilitySpeechAnnouncementPriority, value: UIAccessibilityPriority.high, range: whole)
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }
}
