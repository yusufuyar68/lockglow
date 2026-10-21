import AVFoundation
import SwiftUI
import CoreModels
import Pronunciation

/// Microphone icon next to a word (44 pt target, like the card's speakers): opens the "Söyle"
/// pronunciation practice for that word and its example. An icon, not a label, so long phrases
/// ("look forward to") keep their room on an iPhone SE. Ink, never the blue default (mockup
/// `.say-ic`).
struct SayButton: View {
    let word: WidgetWord
    let example: String
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "mic.circle")
                .font(.title2)
                .foregroundStyle(Theme.ink)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel("Söyle: telaffuzunu dene")
        .sheet(isPresented: $isPresented) {
            PronunciationPracticeView(word: word, example: example)
                .presentationDetents([.medium, .large])
                // Opaque like the cards (rule 6): the result panels are tinted over `surface`.
                .presentationBackground(Theme.surface)
        }
    }
}

/// The learner says the word (or the example sentence); the phone checks it on the device and
/// answers in Turkish ("Doğru!", "Bir daha dene: 'th' sesine dikkat...").
/// Mockup `.saysheet`: the two options, the target with its speaker, one status line and the
/// privacy note, then the large microphone button in the bottom bar.
struct PronunciationPracticeView: View {
    let word: WidgetWord
    let example: String

    @StateObject private var recognizer = PronunciationRecognizer()
    @State private var mode = Mode.word
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Mode: String, CaseIterable, Identifiable {
        case word = "Kelime"
        case sentence = "Örnek cümle"

        var id: Self { self }
    }

    private var target: PronunciationTarget {
        switch mode {
        case .word:
            return PronunciationTarget(text: word.lemma, ipa: word.ipaUS)
        case .sentence:
            return PronunciationTarget(text: example)
        }
    }

    private static let statusID = "say.status"

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Always-visible 46 pt options, not a 32 pt segmented picker.
                        SegmentButtons(
                            options: Mode.allCases.map { SegmentOption(value: $0, title: $0.rawValue) },
                            selection: $mode
                        )
                        .disabled(recognizer.isBusy)
                        .opacity(recognizer.isBusy ? 0.4 : 1)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Ne söyleyeceksin?")
                        targetView
                        statusView
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(PronunciationPracticeView.statusID)
                        // In the scroll view, not the bottom bar: at the medium height of an iPhone
                        // SE the bar must leave room for the result.
                        Text("Ses telefondan çıkmaz ve kaydedilmez.")
                            .font(.footnote)
                            .foregroundStyle(Theme.ink2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                // Outside the scroll view: reachable without scrolling at the medium height.
                .safeAreaInset(edge: .bottom) {
                    micButton
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 12)
                        .background(Theme.surface)
                }
                .onChange(of: recognizer.phase) { _, phase in
                    switch phase {
                    case .finished, .failed:
                        // The result may start below the fold: scroll its top into view (`.top`: a
                        // tall panel shows its verdict; a short one stops at the end of the content),
                        // a moment later, once the panel has been laid out.
                        let animation: Animation? = reduceMotion ? nil : .easeOut(duration: 0.25)
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 60_000_000)
                            withAnimation(animation) {
                                proxy.scrollTo(PronunciationPracticeView.statusID, anchor: .top)
                            }
                        }
                    default:
                        break
                    }
                    // VoiceOver hears the verdict without having to find the panel.
                    if case .finished(let feedback) = phase {
                        UIAccessibility.post(notification: .announcement, argument: feedback.title)
                    }
                }
                .navigationTitle("Söyle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // A control-layer button: glass on iOS 26 by itself, ink text before that.
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Kapat") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .tint(Theme.ink)
        .onChange(of: mode) {
            recognizer.cancel()
        }
        // Never listen in the background (the app has the audio background mode for the widget).
        .onChange(of: scenePhase) {
            if scenePhase != .active, recognizer.isBusy {
                recognizer.cancel()
            }
        }
        // A call, Siri or an alarm takes the audio session: drop the take.
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { _ in
            if recognizer.isBusy {
                recognizer.cancel()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.mediaServicesWereResetNotification)) { _ in
            recognizer.cancel()
        }
        .onDisappear {
            recognizer.cancel()
        }
        .sensoryFeedback(trigger: recognizer.phase) { _, phase in
            guard case .finished(let feedback) = phase else {
                return nil
            }
            let haptic: SensoryFeedback = feedback.verdict == .correct ? .success : .warning
            return haptic
        }
    }

    /// English is serif (rule 3), never italic: the word bold and large, the sentence at the
    /// definition size. The IPA is visual only; VoiceOver users play the word instead.
    private var targetView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 8) {
                Text(target.text)
                    .font(mode == .word ? Font.system(.largeTitle, design: .serif, weight: .bold) : Theme.Fonts.definition)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                // Mockup `.spk`: the round `surface2` speaker of the cards (rule 2).
                CardSentenceSpeaker(text: target.text, accessibilityName: mode == .word ? "Kelimeyi dinle" : "Cümleyi dinle")
                    .disabled(recognizer.isBusy)
                    .opacity(recognizer.isBusy ? 0.4 : 1)
            }
            if mode == .word, let ipa = word.ipaUS {
                Text(ipa)
                    .font(.body)
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// One status line at a time (mockup `sayStatus`).
    @ViewBuilder
    private var statusView: some View {
        switch recognizer.phase {
        case .idle:
            Text(mode == .word
                ? "Önce dinle. Sonra Söyle'ye bas ve kelimeyi yüksek sesle söyle."
                : "Önce dinle. Sonra Söyle'ye bas ve cümleyi yüksek sesle söyle.")
                .font(.callout)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
        case .preparing:
            HStack(spacing: 10) {
                ProgressView()
                Text("İngilizce konuşma modeli iniyor. Bu yalnız ilk seferde olur.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minHeight: 44)
        case .listening:
            Label("Dinliyorum... Bitince sus ya da Bitti'ye bas.", systemImage: "waveform")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .symbolEffect(.variableColor.iterative, isActive: !reduceMotion)
                .frame(maxWidth: .infinity, minHeight: 44)
        case .checking:
            HStack(spacing: 10) {
                ProgressView()
                Text("Kontrol ediliyor")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
        case .finished(let feedback):
            FeedbackPanel(feedback: feedback)
        case .failed(let problem):
            ProblemPanel(problem: problem)
        }
    }

    /// The one filled button of the sheet (mockup `.bigmic`, 64 pt).
    private var micButton: some View {
        let listening = recognizer.phase == .listening
        return Button {
            if listening {
                recognizer.finish()
            } else {
                // A light tap tells a VoiceOver user that listening starts; it comes before the
                // recording session is active (haptics are muted while recording).
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                recognizer.start(target, maxSeconds: mode == .word ? 5 : 10)
            }
        } label: {
            Label(micTitle, systemImage: listening ? "stop.fill" : "mic.fill")
        }
        .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 64))
        .disabled(recognizer.phase == .preparing || recognizer.phase == .checking)
    }

    private var micTitle: String {
        switch recognizer.phase {
        case .listening:
            return "Bitti"
        case .finished, .failed:
            return "Bir daha söyle"
        case .idle, .preparing, .checking:
            return "Söyle"
        }
    }
}

/// The verdict in words (the color only repeats it, rule 4), the Turkish message and what was
/// heard. README point 15: `good` / `caution` / `bad` on a `goodTint` / 14 % caution / `badTint`
/// panel (mockup `.verdict`).
private struct FeedbackPanel: View {
    let feedback: PronunciationFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(feedback.title, systemImage: symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            Text(feedback.message)
                .font(.subheadline)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            // A general "Bir daha dene" message already quotes what was heard.
            if !feedback.heard.isEmpty, feedback.verdict != .tryAgain || feedback.tip != nil {
                Text("Duyulan: " + feedback.heard)
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panel, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var symbol: String {
        switch feedback.verdict {
        case .correct:
            return "checkmark.circle.fill"
        case .almost:
            return "exclamationmark.circle.fill"
        case .tryAgain:
            return "arrow.counterclockwise.circle.fill"
        case .notHeard:
            return "ear"
        }
    }

    private var color: Color {
        switch feedback.verdict {
        case .correct:
            return Theme.good
        case .almost:
            return Theme.caution
        case .tryAgain, .notHeard:
            return Theme.bad
        }
    }

    private var panel: Color {
        switch feedback.verdict {
        case .correct:
            return Theme.goodTint
        case .almost:
            return Theme.cautionTint
        case .tryAgain, .notHeard:
            return Theme.badTint
        }
    }
}

/// Why "Söyle" cannot run right now, in Turkish, with a way to Settings when that can fix it.
/// Mockup `.problem`: a bordered panel, the button a bordered capsule.
private struct ProblemPanel: View {
    let problem: PronunciationRecognizer.Problem
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Söyle şu an çalışmıyor", systemImage: "mic.slash")
                .font(.headline)
                .foregroundStyle(Theme.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if opensSettings {
                Button("Ayarları aç") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(SecondaryCapsuleButtonStyle())
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
                .strokeBorder(Theme.lineStrong, lineWidth: 1.5)
        )
    }

    private var opensSettings: Bool {
        return problem == .microphoneDenied || problem == .speechDenied
    }

    private var message: String {
        switch problem {
        case .microphoneDenied:
            return "Mikrofon izni kapalı. Ayarlar'dan Lockglow'a mikrofon izni verirsen Söyle çalışır. Dinle ve kartlar izinsiz de çalışır."
        case .speechDenied:
            return "Konuşma tanıma izni kapalı. Ayarlar'dan Lockglow'a izin verirsen Söyle çalışır."
        case .speechRestricted:
            return "Konuşma tanıma bu telefonda kısıtlı (Ekran Süresi ya da kurum ayarı)."
        case .modelUnavailable:
            return "İngilizce konuşma modeli indirilemedi. İnternete bağlanıp bir daha dene. Model bir kez iner, sonra internet gerekmez."
        case .onDeviceUnavailable:
            return "Bu telefonda cihaz içi İngilizce tanıma kurulu değil. Ayarlar > Genel > Klavye bölümünde İngilizce (ABD) klavyeyi ekleyip Dikte'yi açınca çalışır."
        case .audioFailed:
            return "Mikrofon başlatılamadı. Başka bir uygulama mikrofonu kullanıyor olabilir. Bir daha dene."
        case .recognitionFailed(let detail):
            return "Konuşma tanıma bu sefer çalışmadı. Bir daha dene. (\(detail))"
        }
    }
}
