import SwiftUI
import CoreModels
import Learning

// "Kendi cümleni yaz" (docs/ozellik_planlari/kendi_cumlen.md): the learner writes an English
// sentence with a word and taps "Kontrol et". The fixed rules answer at once
// (`OwnSentenceCheck`: the word, Turkish letters, the capital letter, the end mark); then, only
// when the phone has Apple Intelligence, a second panel "Öneri · cihazda" shows the on-device
// model's suggestion (`OwnSentenceAssistant`). Practice only (ogrenme_ilkeleri 3): no grade, no
// box, no due date, no score; each new English sentence with the word adds one to the practice
// count (`AppModel.countSentencePractice`). The sentence never leaves the phone and is not stored.

/// "Cümle yaz" on the Sözlük word page, next to "Dinle" and "Söyle": opens the page for `word`.
struct OwnSentenceButton: View {
    let word: WidgetWord
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "pencil")
                Text("Cümle yaz")
            }
        }
        // The page's capsule, in Callout like "Dinle" next to it.
        .buttonStyle(CardCapsuleButtonStyle(font: .callout.weight(.semibold)))
        .accessibilityLabel("Cümle yaz")
        .accessibilityHint(Text("Bu kelimeyle kendi cümleni yaz."))
        .accessibilityIdentifier("sozluk.ownSentence")
        .sheet(isPresented: $isPresented) {
            OwnSentenceView(word: word)
        }
    }
}

/// The page, in a sheet at full height (the keyboard needs the room).
struct OwnSentenceView: View {
    let word: WidgetWord

    @State private var text = ""
    /// The last check; a new id on every tap of "Kontrol et" (haptics, announcement, scrolling).
    @State private var result: CheckResult?
    @State private var advice = AdviceState.hidden
    @State private var adviceTask: Task<Void, Never>?
    /// Sentences already counted on this page (`AppModel.countSentencePractice`).
    @State private var counted: Set<String> = []
    @FocusState private var isEditing: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    struct CheckResult: Equatable {
        let id: Int
        let feedback: OwnSentenceFeedback
    }

    enum AdviceState: Equatable {
        /// No model, a note the model cannot help with, or no answer: no panel.
        case hidden
        case waiting
        case ready(OwnSentenceAdvice)
    }

    private static let resultID = "ownSentence.result"
    /// Notes that make a suggestion pointless: first write an English sentence with the word.
    private static let notesBeforeAdvice: Set<OwnSentenceFeedback.Issue> = [.empty, .tooShort, .missingWord, .turkishLetters]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        field
                        if let result {
                            OwnSentenceRulePanel(feedback: result.feedback)
                                .id(OwnSentenceView.resultID)
                        }
                        if advice != .hidden {
                            OwnSentenceAdvicePanel(state: advice)
                        }
                        Text("Cümlen telefondan çıkmaz.")
                            .font(.footnote)
                            .foregroundStyle(Theme.ink2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                    }
                    // iOS side margins (16 pt), as on the app's other pages.
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .scrollDismissesKeyboard(.interactively)
                // Outside the scroll view: "Kontrol et" is always reachable, above the keyboard too.
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    actionBar
                }
                .onChange(of: result) {
                    // Once the keyboard has gone down: the verdict's top in view.
                    let animation: Animation? = reduceMotion ? nil : .easeOut(duration: 0.25)
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 350_000_000)
                        withAnimation(animation) {
                            proxy.scrollTo(OwnSentenceView.resultID, anchor: .top)
                        }
                    }
                }
                .navigationTitle("Kendi cümleni yaz")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Kapat") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .tint(Theme.ink)
        .presentationDetents([.large])
        // Opaque like the cards (rule 6): the result panels are tinted over `surface`.
        .presentationBackground(Theme.surface)
        .onDisappear {
            adviceTask?.cancel()
        }
        // Like Söyle: success for a good sentence, a warning for notes, never an error buzz.
        .sensoryFeedback(trigger: result) { _, new in
            guard let new else {
                return nil
            }
            let haptic: SensoryFeedback = new.feedback.verdict == .good ? .success : .warning
            return haptic
        }
    }

    // MARK: - Parts

    /// The word in serif (English), its Turkish meaning, and what to do.
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: word.lemma)
                .font(.system(.title2, design: .serif).weight(.bold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .englishVoice()
            if let gloss = word.glossTR, !gloss.isEmpty {
                Text(gloss)
                    .font(.body)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(Text(verbatim: "Türkçesi: " + gloss))
            }
            Text("Bu kelimeyle İngilizce bir cümle yaz.")
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// English in the examples' serif. No autocorrect (the learner's own spelling is checked),
    /// a capital letter at the start of a sentence, an ASCII keyboard (no Turkish letters).
    /// Return checks the sentence.
    private var field: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Cümleni buraya yaz", text: $text, axis: .vertical)
                .font(Theme.Fonts.example)
                .foregroundStyle(Theme.ink)
                .lineLimit(3...)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
                .focused($isEditing)
                .padding(12)
                .frame(minHeight: Theme.minHitSize)
                .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous)
                        .strokeBorder(Theme.lineStrong, lineWidth: 1)
                }
                .accessibilityLabel("Cümlen")
                .accessibilityIdentifier("ownSentence.field")
                .onChange(of: text) { _, new in
                    // A vertical field takes Return as a new line: here it means "check".
                    if new.contains("\n") {
                        let sentence = new.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)
                        text = sentence
                        check(sentence)
                    } else if new.count > OwnSentenceCheck.maxLength {
                        text = OwnSentenceCheck.limited(new)
                    }
                }
            if text.count >= OwnSentenceCheck.maxLength {
                Text(verbatim: "En çok \(OwnSentenceCheck.maxLength) harf yazabilirsin.")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var actionBar: some View {
        Button("Kontrol et") {
            check()
        }
        .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
        .accessibilityIdentifier("ownSentence.check")
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Theme.surface)
    }

    // MARK: - Checking

    /// `typed`: the field's text when it was just changed (Return); else the field is read.
    private func check(_ typed: String? = nil) {
        isEditing = false
        let sentence = OwnSentenceCheck.limited(typed ?? text)
        let feedback = OwnSentenceCheck.check(sentence, lemma: word.lemma)
        let id = (result?.id ?? 0) + 1
        result = CheckResult(id: id, feedback: feedback)
        count(sentence, feedback: feedback)
        announce(OwnSentenceView.spoken(feedback), forCheck: id)
        askModel(sentence, feedback: feedback, id: id)
    }

    /// One practice per new sentence (a second tap on the same sentence is not counted again).
    /// Only an English sentence with the word counts: the tally reads "Bugün: N cümle" on the
    /// Cümle kur summary, so an empty field, a word or two, a sentence without the word or one in
    /// Turkish is no practice yet (the same notes that hold back the suggestion).
    private func count(_ sentence: String, feedback: OwnSentenceFeedback) {
        guard feedback.issues.allSatisfy({ !OwnSentenceView.notesBeforeAdvice.contains($0) }) else {
            return
        }
        let key = sentence.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if counted.insert(key).inserted {
            AppModel.countSentencePractice()
        }
    }

    /// The model's suggestion when the phone has one and the sentence is an English sentence with
    /// the word. A later check cancels an earlier one's request (`OwnSentenceAI.advice`).
    private func askModel(_ sentence: String, feedback: OwnSentenceFeedback, id: Int) {
        adviceTask?.cancel()
        guard feedback.issues.allSatisfy({ !OwnSentenceView.notesBeforeAdvice.contains($0) }),
              OwnSentenceAssistant.isAvailable else {
            advice = .hidden
            return
        }
        advice = .waiting
        let target = self.word
        adviceTask = Task { @MainActor in
            let answer = await OwnSentenceAssistant.advice(sentence: sentence, word: target)
            guard !Task.isCancelled, result?.id == id else {
                return
            }
            if let answer {
                advice = .ready(answer)
                announce("Öneri: " + answer.title + ". " + answer.message, forCheck: id)
            } else {
                advice = .hidden
            }
        }
    }

    /// The verdict and the notes' titles, for VoiceOver.
    static func spoken(_ feedback: OwnSentenceFeedback) -> String {
        if feedback.issues.isEmpty {
            return feedback.title + ". " + feedback.message
        }
        return feedback.title + ": " + feedback.issues.map(\.title).joined(separator: ", ") + "."
    }

    /// Posted a moment later, once the keyboard is down and the page has scrolled, so that
    /// VoiceOver does not drop it (as in Söyle), and only while check `id` is still the last one.
    private func announce(_ text: String, forCheck id: Int) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard result?.id == id else {
                return
            }
            AccessibilityNotification.Announcement(AttributedString(text)).post()
        }
    }
}

// MARK: - Panels

/// The rules' result, in the style of Söyle's result (PronunciationPracticeView `FeedbackPanel`):
/// the verdict as icon, word and color together (rule 4) on its tint, then each note in a box
/// with what to do.
private struct OwnSentenceRulePanel: View {
    let feedback: OwnSentenceFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Label(feedback.title, systemImage: symbol)
                    .font(.headline)
                    .foregroundStyle(color)
                    .fixedSize(horizontal: false, vertical: true)
                Text(feedback.message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("ownSentence.verdict.\(feedback.verdict.rawValue)")
            ForEach(feedback.issues, id: \.self) { issue in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "lightbulb")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink2)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(issue.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                        Text(issue.message)
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("ownSentence.issue.\(issue.rawValue)")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panel, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var symbol: String {
        switch feedback.verdict {
        case .good:
            return "checkmark.circle.fill"
        case .caution:
            return "exclamationmark.circle.fill"
        }
    }

    private var color: Color {
        switch feedback.verdict {
        case .good:
            return Theme.good
        case .caution:
            return Theme.caution
        }
    }

    private var panel: Color {
        switch feedback.verdict {
        case .good:
            return Theme.goodTint
        case .caution:
            return Theme.cautionTint
        }
    }
}

/// "Öneri · cihazda": the on-device model's suggestion, plainly marked as one. A small spinner
/// while it comes; then the Turkish line for its kind, and the English sentences (serif,
/// selectable, read in an English voice). Neutral colors: a suggestion is not a verdict.
private struct OwnSentenceAdvicePanel: View {
    let state: OwnSentenceView.AdviceState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Öneri · cihazda", systemImage: "sparkles")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
            switch state {
            case .hidden:
                EmptyView()
            case .waiting:
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Öneri hazırlanıyor")
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minHeight: Theme.minHitSize)
                .accessibilityElement(children: .combine)
            case .ready(let advice):
                VStack(alignment: .leading, spacing: 4) {
                    Text(advice.title)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text(advice.message)
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink)
                }
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .combine)
                if let corrected = advice.correctedSentence {
                    englishRow(label: "Düzeltilmiş hâli", sentence: corrected)
                }
                if let alternative = advice.naturalAlternative {
                    englishRow(label: "Daha doğal", sentence: alternative)
                }
                Text("Öneriyi telefondaki yapay zekâ yazar. Yanılabilir.")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ownSentence.advice")
    }

    /// A Turkish label over an English sentence; the sentence its own element, so VoiceOver
    /// reads it in an English voice.
    private func englishRow(label: String, sentence: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink2)
            Text(verbatim: sentence)
                .font(Theme.Fonts.example)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
                .englishVoice()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
