import SwiftUI
import UIKit
import CoreModels
import Learning

/// "İngilizcesini yaz" (boxes 2–3, every other question; docs/tasarim/ogrenme_ilkeleri.md 2.4,
/// "Dinle ve seç, Yaz"): the Turkish meaning ("ödünç almak → ?"), a field for the English word and
/// "Kontrol et" at the bottom, where the keyboard pushes it. The field neither corrects nor
/// capitalizes (a Turkish keyboard would turn "i" into "İ" and English words into Turkish ones),
/// and `TypeQuestion.check` folds what is left: case, İ and ı, apostrophes and hyphens never count.
///
/// - "Bir harf göster" shows the next letter of the word ("bo____"), up to half of its letters;
///   a right answer after a hint counts as "Zor".
/// - "Bilemedim" shows the word, as a wrong answer.
/// - A small spelling mistake is "Neredeyse doğru" and counts as "Zor"; another card's word is
///   wrong, with what that word means ("Senin yazdığın: lend = ödünç vermek"). A word with the same
///   meaning ("tell" for "söylemek" on the card "say") is not graded: the card says so and the
///   learner tries again.
///
/// The buttons after the answer are the quiz's (`ReviewAnswerActions`); nothing moves on by itself.
/// Give each word its own identity (`.id(word.id)`).
struct TypeQuestionView: View {
    let word: WidgetWord
    let question: TypeQuestion
    /// When the word comes back after each outcome (`ReviewView.quizReturnTimes`).
    let returnTimes: [QuizOutcome: String]
    let onContinue: (QuizOutcome) -> Void

    /// How the answer went, once it is final.
    private enum Verdict: Equatable {
        case right
        /// Right, after "Bir harf göster".
        case rightWithHint
        case almost
        case otherWord(String, meaning: String?)
        case wrong
        /// "Bilemedim".
        case gaveUp

        var actions: ReviewAnswerActions.Verdict {
            switch self {
            case .right:
                return .right
            case .rightWithHint, .almost:
                return .hard
            case .otherWord, .wrong, .gaveUp:
                return .wrong
            }
        }
    }

    @State private var text = ""
    @State private var hints = 0
    @State private var verdict: Verdict?
    /// What was checked last, for "Senin yazdığın".
    @State private var checked = ""
    /// The last word typed that has the same meaning but is another card's ("tell").
    @State private var sameMeaning: String?
    @FocusState private var isFieldFocused: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let feedbackID = "type.feedback"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("İngilizcesini yaz")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink2)
                        .accessibilityAddTraits(.isHeader)
                    promptCard
                    if let verdict = verdict {
                        feedback(verdict)
                            .id(TypeQuestionView.feedbackID)
                            .transition(.opacity)
                        if dynamicTypeSize.isAccessibilitySize {
                            actions(verdict)
                        }
                    } else {
                        field
                        if let other = sameMeaning {
                            sameMeaningNote(other)
                        }
                        helpButtons
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            // Opaque (rule 6), and above the keyboard while it is up.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Group {
                    if let verdict = verdict {
                        if !dynamicTypeSize.isAccessibilitySize {
                            actions(verdict)
                        }
                    } else {
                        Button("Kontrol et") {
                            check()
                        }
                        .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                        .disabled(isEmpty)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background(Theme.bg)
            }
            .onChange(of: verdict) { _, newValue in
                guard newValue != nil else {
                    return
                }
                let animation: Animation? = reduceMotion ? nil : .easeInOut(duration: 0.2)
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 60_000_000)
                    withAnimation(animation) {
                        proxy.scrollTo(TypeQuestionView.feedbackID, anchor: .bottom)
                    }
                }
            }
        }
        .tint(Theme.ink)
        // A light haptic on a right answer only (2.4): never on a wrong one.
        .sensoryFeedback(.success, trigger: verdict) { oldValue, newValue in
            oldValue == nil && (newValue == .right || newValue == .rightWithHint)
        }
        // The keyboard comes with the card: typing is the question.
        .task(id: question.wordID) {
            try? await Task.sleep(nanoseconds: 350_000_000)
            if !Task.isCancelled, verdict == nil {
                isFieldFocused = true
            }
        }
    }

    private var isEmpty: Bool {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Question

    /// The Turkish meaning with "→ ?", as on the recall screen; when another card has the same
    /// meaning, the Turkish example tells them apart; after a hint, the letters given so far.
    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(Text(verbatim: question.prompt)) \(Text(verbatim: "→ ?").foregroundStyle(Theme.ink3))")
                .font(Theme.Fonts.meaning)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Türkçesi: \(question.prompt). İngilizcesi ne?")
            if let context = question.context {
                Text(verbatim: "Örnekte: " + context)
                    .exampleTranslationStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
            if hints > 0 {
                hintLine
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
    }

    /// "bo____" with a little room between the letters, so each blank reads as one letter.
    private var hintLine: some View {
        let pattern = question.hint(letters: hints)
        let spaced = pattern.map { $0 == " " ? "   " : String($0) }.joined(separator: "\u{2009}")
        let given = pattern.filter { $0.isLetter }.map { String($0) }.joined(separator: ", ")
        return VStack(alignment: .leading, spacing: 2) {
            Text("İpucu")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink2)
            Text(verbatim: spaced)
                .font(.system(.title3, design: .serif).weight(.semibold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("İpucu: \(given). Toplam \(question.letterCount) harf.")
    }

    /// The answer field: English serif, no correction, no capitals, "Kontrol et" on the return key.
    private var field: some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
        return TextField("İngilizcesini buraya yaz", text: $text)
            .font(Theme.Fonts.definition)
            .foregroundStyle(Theme.ink)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .keyboardType(.default)
            .submitLabel(.done)
            .focused($isFieldFocused)
            .onSubmit {
                check()
            }
            .onChange(of: text) { _, _ in
                // A new word: the note about the last one no longer applies.
                sameMeaning = nil
            }
            .padding(.horizontal, 18)
            .frame(minHeight: 56)
            .background(Theme.surface, in: shape)
            .overlay {
                shape.strokeBorder(isFieldFocused ? Theme.ink : Theme.lineStrong, lineWidth: isFieldFocused ? 2 : 1.5)
            }
            .accessibilityLabel("İngilizcesi")
    }

    /// "Bu da aynı anlama gelir: tell." Not a verdict: the learner tries again.
    private func sameMeaningNote(_ other: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            ReviewWordLine(lead: "Bu da aynı anlama gelir:", lemma: other, meaning: nil)
            Text("Aradığımız kelime başka. Bir daha dene.")
                .font(.callout)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
    }

    /// "Bir harf göster" (while letters are left) and "Bilemedim", side by side, stacked at
    /// accessibility sizes.
    private var helpButtons: some View {
        let rowLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(spacing: 8))
        return rowLayout {
            if question.maxHints > 0 {
                Button {
                    showLetter()
                } label: {
                    Label("Bir harf göster", systemImage: "character.cursor.ibeam")
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                .disabled(hints >= question.maxHints)
                .accessibilityValue(hints >= question.maxHints ? "İpucu bitti" : "")
            }
            Button("Bilemedim") {
                finish(.gaveUp)
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func showLetter() {
        guard hints < question.maxHints else {
            return
        }
        hints += 1
        let pattern = question.hint(letters: hints)
        let given = pattern.filter { $0.isLetter }.map { String($0) }.joined(separator: ", ")
        ReviewAnnouncement.post(lead: "İpucu: \(given)", english: nil, meaning: nil)
    }

    private func check() {
        let typed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard verdict == nil, !typed.isEmpty else {
            return
        }
        switch question.check(typed) {
        case .right:
            finish(hints > 0 ? .rightWithHint : .right, typed: typed)
        case .almost:
            finish(.almost, typed: typed)
        case let .otherWord(lemma, meaning):
            finish(.otherWord(lemma, meaning: meaning), typed: typed)
        case .wrong:
            finish(.wrong, typed: typed)
        case let .sameMeaning(other):
            sameMeaning = other
            ReviewAnnouncement.post(lead: "Bu da aynı anlama gelir: ", english: other, meaning: nil)
            isFieldFocused = true
        }
    }

    private func finish(_ result: Verdict, typed: String = "") {
        checked = typed
        isFieldFocused = false
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            verdict = result
        }
        let lead: String
        switch result {
        case .right, .rightWithHint:
            lead = "Doğru. "
        case .almost:
            lead = "Neredeyse doğru. Doğru yazılışı: "
        case .otherWord, .wrong, .gaveUp:
            lead = "Doğrusu: "
        }
        ReviewAnnouncement.post(lead: lead, english: question.answer, meaning: word.glossTR)
    }

    // MARK: Feedback

    /// About the answer, never the learner (rule 12). Right: "Doğru." and "borrow = ödünç almak".
    /// Almost: "Neredeyse doğru.", the right spelling and what was typed. Wrong: "Doğrusu: …" and,
    /// when something was typed, "Senin yazdığın: …". "Zor" answers say why they count as "Zor".
    /// Always a "Dinle" for the word.
    private func feedback(_ verdict: Verdict) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            switch verdict {
            case .right, .rightWithHint:
                ReviewVerdictLine(text: "Doğru.", symbol: "checkmark.circle.fill", symbolColor: Theme.good)
                ReviewWordLine(lemma: question.answer, meaning: word.glossTR)
                if verdict == .rightWithHint {
                    hardNote("Harf ipucu aldın. Bu cevap Zor sayılır.")
                }
            case .almost:
                ReviewVerdictLine(text: "Neredeyse doğru.", symbol: "checkmark.circle", symbolColor: Theme.ink2)
                ReviewWordLine(lead: "Doğru yazılışı:", lemma: question.answer, meaning: word.glossTR)
                ReviewWordLine(lead: "Senin yazdığın:", lemma: checked, meaning: nil, isSecondary: true)
                hardNote("Küçük bir yazım farkı var. Bu cevap Zor sayılır.")
            case let .otherWord(lemma, meaning):
                ReviewWordLine(lead: "Doğrusu:", lemma: question.answer, meaning: word.glossTR, isVerdict: true)
                ReviewWordLine(lead: "Senin yazdığın:", lemma: lemma, meaning: meaning, isSecondary: true)
            case .wrong:
                ReviewWordLine(lead: "Doğrusu:", lemma: question.answer, meaning: word.glossTR, isVerdict: true)
                ReviewWordLine(lead: "Senin yazdığın:", lemma: checked, meaning: nil, isSecondary: true)
            case .gaveUp:
                ReviewWordLine(lead: "Doğrusu:", lemma: question.answer, meaning: word.glossTR, isVerdict: true)
            }
            CardListenCapsule(text: question.answer, accessibilityName: "Kelimeyi dinle")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        // Not `.combine`: the English words need their own voice (audit V3, `FeedbackSpeech`).
        .accessibilityElement(children: .contain)
    }

    private func hardNote(_ text: String) -> some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: "tortoise")
                .accessibilityHidden(true)
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(Theme.ink2)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func actions(_ verdict: Verdict) -> some View {
        ReviewAnswerActions(verdict: verdict.actions, returnTimes: returnTimes, onContinue: onContinue)
    }
}
