import SwiftUI
import UIKit
import CoreModels
import Learning

/// A round of "Kulak alıştırması": 10 questions, then the summary.
///
/// A question: the phone reads one word of a pair (on its own a moment after the question
/// appears, unless VoiceOver is on; "Bir daha dinle" repeats it), the learner taps one of two
/// equal serif capsules. After the tap both words stay, the heard one marked "Doğru cevap" and a
/// wrong pick "Yanlış" (icon and word, never color alone; no red, no haptic on a wrong pick),
/// each with its IPA, its Turkish meaning and its own speaker, so the two can be compared. Below,
/// how the mouth and tongue make each of the two sounds, and on a wrong pick the group's tip.
/// "Devam" waits at the bottom; nothing moves on by itself (learning principles 2.4).
///
/// Every answer goes to the local counter right away (`EarTrainingModel.record`), never to the
/// Leitner progress. The summary says "10 soru dinledin, 7 tanesini ayırdın." and lists the sound
/// pairs that were mixed up, each a round of its own; "Bir tur daha" starts a new round of the
/// same kind.
struct EarTrainingRoundView: View {
    @ObservedObject var model: EarTrainingModel
    @ObservedObject private var speaker = Speaker.shared
    /// The kind of round: nil mixed, otherwise one sound pair (it changes when the summary
    /// starts a round of a mixed-up pair).
    @State private var focus: String?
    @State private var questions: [EarTrainingQuestion] = []
    /// The first round is made once, on appear: `init` runs again on every redraw of the list
    /// behind (each answer updates the counter it shows).
    @State private var started = false
    @State private var index = 0
    @State private var picked: EarTrainingSide?
    /// The word was read aloud for this question (the button then says "Bir daha dinle").
    @State private var hasPlayed = false
    @State private var answered = 0
    @State private var right = 0
    /// Groups with a mixed-up answer in this round, in the order they came.
    @State private var missedGroups: [String] = []
    /// "Ses ve aksan": the voice reads in this accent (`WordSpeech`), so the IPA shown follows it.
    @AppStorage(SpeechSettings.Key.accent, store: SpeechSettingsStore.defaults) private var accent = SpeechAccent.american
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static let feedbackID = "ear.feedback"

    init(model: EarTrainingModel, focus: String?) {
        self.model = model
        _focus = State(initialValue: focus)
    }

    var body: some View {
        Group {
            if !started {
                Color.clear
            } else if questions.isEmpty {
                Text("Bu ses çifti için soru yok.")
                    .font(.body)
                    .foregroundStyle(Theme.ink2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if index < questions.count {
                questionScreen(questions[index])
            } else {
                summary
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        // The speaker buttons are ink, never the system blue (rule 2).
        .tint(Theme.ink)
        .onAppear {
            if !started {
                questions = model.makeRound(focus: focus)
                started = true
            }
        }
        .onDisappear {
            Speaker.shared.stop()
        }
    }

    /// Turkish, so VoiceOver reads it in one voice: the pair's Turkish name or "Karışık tur".
    private var title: String {
        if let focus = focus, let group = model.group(id: focus) {
            return group.nameTR
        }
        return "Karışık tur"
    }

    // MARK: Question

    private func questionScreen(_ question: EarTrainingQuestion) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    listenButton(question)
                    VStack(spacing: 12) {
                        ForEach(question.shownOrder, id: \.self) { side in
                            option(side, of: question)
                        }
                    }
                    if let picked = picked {
                        feedback(question, picked: picked)
                            .id(EarTrainingRoundView.feedbackID)
                            .transition(.opacity)
                        // At accessibility sizes a fixed bar would leave little room: the
                        // button scrolls with the feedback instead (QuizCardView does the same).
                        if dynamicTypeSize.isAccessibilitySize {
                            continueButton
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            // A new question starts at the top.
            .id(index)
            .scrollBounceBehavior(.basedOnSize)
            // Opaque (rule 6): the button never sits on glass.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if picked != nil && !dynamicTypeSize.isAccessibilitySize {
                    continueButton
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
                // Once the feedback and the bar are laid out; at most 200 ms (principles 2.4).
                let animation: Animation? = reduceMotion ? nil : .easeInOut(duration: 0.2)
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 60_000_000)
                    withAnimation(animation) {
                        proxy.scrollTo(EarTrainingRoundView.feedbackID, anchor: .bottom)
                    }
                }
            }
        }
        // The word is read on its own when the question appears. Not with VoiceOver: it would
        // talk over the screen's own speech; "Dinle" is the first button there.
        .task(id: index) {
            guard !voiceOverEnabled else {
                return
            }
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled, picked == nil, index < questions.count else {
                return
            }
            play(questions[index].answer.word)
        }
        // A light haptic on a right answer only; a wrong pick stays silent (principles 2.4).
        .sensoryFeedback(.success, trigger: picked) { oldValue, newValue in
            oldValue == nil && newValue == question.answerSide
        }
    }

    /// "Soru 3 / 10" (VoiceOver: "Soru 3, toplam 10") and the question.
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: "Soru \(index + 1) / \(questions.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .monospacedDigit()
                .accessibilityLabel(Text(verbatim: "Soru \(index + 1), toplam \(questions.count)"))
            Text("Hangisini duydun?")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
        }
    }

    /// The large "Dinle" capsule: reads the word again from the start on every tap (a word is
    /// too short for a "Durdur"). Its label never names the word.
    private func listenButton(_ question: EarTrainingQuestion) -> some View {
        let isSpeaking = speaker.speakingText == question.answer.word
        return Button {
            play(question.answer.word)
        } label: {
            Label {
                Text(hasPlayed ? "Bir daha dinle" : "Dinle")
            } icon: {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
            }
            .font(.headline)
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 56, tonal: true))
        .accessibilityLabel(hasPlayed ? "Kelimeyi bir daha dinle" : "Kelimeyi dinle")
        // Voice Control: "Dinle'ye dokun" works as well as the spoken name (audit V12).
        .accessibilityInputLabels([Text("Dinle"), Text("Bir daha dinle"), Text("Kelimeyi dinle")])
    }

    // MARK: Options

    @ViewBuilder
    private func option(_ side: EarTrainingSide, of question: EarTrainingQuestion) -> some View {
        let word = question.pair[side]
        if picked == nil {
            Button {
                choose(side, in: question)
            } label: {
                Text(verbatim: word.word)
                    .font(.system(.title, design: .serif).weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .englishVoice()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(Theme.surface, in: optionShape)
                    .overlay(optionShape.strokeBorder(Theme.lineStrong, lineWidth: 1.5))
                    .contentShape(optionShape)
            }
            .buttonStyle(EarOptionButtonStyle())
        } else {
            answeredOption(word, mark: mark(for: side, in: question))
        }
    }

    private var optionShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
    }

    private struct Mark {
        let text: String
        let symbol: String
        let color: Color
        let fill: Color
        let border: Color
        let lineWidth: CGFloat
    }

    /// The heard word in `good` with a check; a wrong pick stays on paper with a cross in ink2.
    private func mark(for side: EarTrainingSide, in question: EarTrainingQuestion) -> Mark? {
        if side == question.answerSide {
            return Mark(
                text: "Doğru cevap",
                symbol: "checkmark.circle.fill",
                color: Theme.good,
                fill: Theme.goodTint,
                border: Theme.good,
                lineWidth: 2
            )
        }
        if side == picked {
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

    /// After the answer: the word (serif, English voice), its IPA (hidden from VoiceOver, which
    /// cannot read it), its Turkish meaning, the mark, and a speaker to hear this word alone.
    private func answeredOption(_ word: EarTrainingWord, mark: Mark?) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: word.word)
                    .font(.system(.title2, design: .serif).weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .englishVoice()
                Text(verbatim: word.ipa.text(for: accent))
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
                Text(verbatim: word.tr)
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .accessibilityLabel(Text(verbatim: "Türkçesi: \(word.tr)"))
                if let mark = mark {
                    HStack(spacing: 4) {
                        Image(systemName: mark.symbol)
                            .font(.body.weight(.semibold))
                            .accessibilityHidden(true)
                        Text(mark.text)
                            .font(.footnote.weight(.bold))
                    }
                    .foregroundStyle(mark.color)
                    .padding(.top, 2)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            ReviewSpeakerButton(text: word.word, accessibilityName: "Bu kelimeyi dinle")
        }
        .padding(.leading, 18)
        .padding(.trailing, 10)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .background(mark?.fill ?? Theme.surface, in: optionShape)
        .overlay(optionShape.strokeBorder(mark?.border ?? Theme.lineStrong, lineWidth: mark?.lineWidth ?? 1.5))
        .accessibilityElement(children: .contain)
    }

    // MARK: Feedback

    /// "Doğru." or "Doğrusu: sheep", then how each sound is made, the heard word first; on a wrong
    /// pick also the group's tip. About the sounds, never the learner (principles 2.4).
    @ViewBuilder
    private func feedback(_ question: EarTrainingQuestion, picked: EarTrainingSide) -> some View {
        let isRight = question.isRight(picked)
        let group = model.group(id: question.groupID)
        VStack(alignment: .leading, spacing: 14) {
            if isRight {
                Label {
                    Text("Doğru.")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.good)
                        .accessibilityHidden(true)
                }
                .font(.headline)
                .foregroundStyle(Theme.ink)
            } else {
                // On screen one line; for VoiceOver the English word is an element of its own.
                Text("Doğrusu: \(Text(verbatim: question.answer.word).bold())")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                    .accessibilityRepresentation {
                        FeedbackSpeech(lead: "Doğrusu:", english: question.answer.word, meaning: nil)
                    }
            }
            if let group = group {
                ForEach([question.answerSide, question.answerSide.other], id: \.self) { side in
                    soundNote(word: question.pair[side].word, sound: group.sound(side))
                }
                if !isRight, let tip = group.tipTR {
                    Label {
                        Text(verbatim: tip)
                    } icon: {
                        Image(systemName: "lightbulb")
                            .accessibilityHidden(true)
                    }
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            Text("İki kelimeyi de dinle, farkı duy.")
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: Theme.Radius.card)
    }

    /// "sheep · uzun i · iː", then the note on the mouth and tongue.
    private func soundNote(word: String, sound: EarTrainingSound) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(verbatim: word)
                    .font(.system(.body, design: .serif).weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .englishVoice()
                Text(verbatim: "· \(sound.nameTR)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityLabel(Text(verbatim: sound.nameTR))
                if let ipa = sound.ipa {
                    Text(verbatim: "· \(ipa)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                        .accessibilityHidden(true)
                }
            }
            Text(verbatim: sound.howTR)
                .font(.callout)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var continueButton: some View {
        Button("Devam") {
            advance()
        }
        .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
    }

    // MARK: Summary

    /// "Tur bitti", "10 soru dinledin, 7 tanesini ayırdın.", the mixed-up pairs (each opens a
    /// round of its own), then "Bir tur daha" and "Tamam" at the bottom.
    private var summary: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tur bitti")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
                if let line = EarTrainingSummary.line(asked: answered, right: right) {
                    Text(verbatim: line)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                }
                let groups = missedGroups.compactMap { model.group(id: $0) }
                if !groups.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsSectionHeader("Bu sesleri bir daha dinle")
                        SettingsGroup {
                            ForEach(Array(groups.enumerated()), id: \.element.id) { offset, group in
                                if offset > 0 {
                                    SettingsDivider()
                                }
                                missedRow(group)
                            }
                        }
                        Text("Bir çifte dokununca yalnız o seslerden \(EarTrainingRound.questionCount) soru gelir.")
                            .settingsFootnote()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 10) {
                Button("Bir tur daha") {
                    restart(focus: focus)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                Button("Tamam") {
                    dismiss()
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(Theme.bg)
        }
    }

    private func missedRow(_ group: EarTrainingGroup) -> some View {
        Button {
            restart(focus: group.id)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    // English: serif, as in the list of pairs.
                    Text(verbatim: group.title)
                        .font(Theme.Fonts.definition.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text(verbatim: group.nameTR)
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityRepresentation {
            Button {
                restart(focus: group.id)
            } label: {
                Text(verbatim: group.title)
                    .englishVoice()
            }
            Text(verbatim: group.nameTR)
        }
    }

    // MARK: Actions

    private func play(_ text: String) {
        // `toggle` would stop a word still being read; a tap here always reads it again.
        Speaker.shared.stop()
        Speaker.shared.toggle(text)
        hasPlayed = true
    }

    private func choose(_ side: EarTrainingSide, in question: EarTrainingQuestion) {
        guard picked == nil else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            picked = side
        }
        let isRight = question.isRight(side)
        answered += 1
        if isRight {
            right += 1
        } else if !missedGroups.contains(question.groupID) {
            missedGroups.append(question.groupID)
        }
        model.record(question, isRight: isRight)
        announce(isRight: isRight, word: question.answer.word)
    }

    private func advance() {
        Speaker.shared.stop()
        picked = nil
        hasPlayed = false
        index += 1
    }

    private func restart(focus newFocus: String?) {
        Speaker.shared.stop()
        focus = newFocus
        questions = model.makeRound(focus: newFocus)
        index = 0
        picked = nil
        hasPlayed = false
        answered = 0
        right = 0
        missedGroups = []
    }

    /// VoiceOver hears how it went, queued after the tap's own speech: "Doğru. ship" or
    /// "Doğrusu: sheep", the English word in an English voice (as `QuizCardView.announce`).
    private func announce(isRight: Bool, word: String) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            let turkish: [NSAttributedString.Key: Any] = [.accessibilitySpeechLanguage: "tr-TR"]
            let english: [NSAttributedString.Key: Any] = [.accessibilitySpeechLanguage: "en-US"]
            let text = NSMutableAttributedString(string: isRight ? "Doğru. " : "Doğrusu: ", attributes: turkish)
            text.append(NSAttributedString(string: word, attributes: english))
            let whole = NSRange(location: 0, length: text.length)
            text.addAttribute(.accessibilitySpeechQueueAnnouncement, value: true, range: whole)
            text.addAttribute(.accessibilitySpeechAnnouncementPriority, value: UIAccessibilityPriority.high, range: whole)
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }
}

/// Pressed state of an answer capsule: a light dip, no scaling under Reduce Motion.
private struct EarOptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        EarOptionPressBody(configuration: configuration)
    }
}

private struct EarOptionPressBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
