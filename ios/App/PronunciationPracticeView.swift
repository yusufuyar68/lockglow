import AVFoundation
import SwiftUI
import CoreModels
import Pronunciation

/// Microphone icon next to a word (44 pt target, like `SpeakButton`): opens the "Söyle"
/// pronunciation practice for that word and its example. An icon, not a label, so long phrases
/// ("look forward to") keep their room on an iPhone SE.
struct SayButton: View {
    let word: WidgetWord
    let example: String
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "mic.circle")
                .font(.title3)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel("Söyle: telaffuzunu dene")
        .sheet(isPresented: $isPresented) {
            PronunciationPracticeView(word: word, example: example)
                .presentationDetents([.medium, .large])
        }
    }
}

/// The learner says the word (or the example sentence); the phone checks it on the device and
/// answers in Turkish ("Doğru!", "Bir daha dene: 'th' sesine dikkat...").
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Ne söyleyeceksin?", selection: $mode) {
                        ForEach(Mode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(recognizer.isBusy)
                    targetView
                    statusView
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Ses telefondan çıkmaz ve kaydedilmez.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            // Outside the scroll view: reachable without scrolling at the medium height.
            .safeAreaInset(edge: .bottom) {
                micButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.bar)
            }
            .navigationTitle("Söyle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
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

    private var targetView: some View {
        VStack(spacing: 6) {
            HStack(alignment: .center, spacing: 4) {
                Text(target.text)
                    .font(mode == .word ? Font.largeTitle.bold() : Font.title3.italic())
                    .multilineTextAlignment(.center)
                SpeakButton(text: target.text, accessibilityName: mode == .word ? "Kelimeyi dinle" : "Cümleyi dinle")
                    .disabled(recognizer.isBusy)
            }
            if mode == .word, let ipa = word.ipaUS {
                Text(ipa)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var statusView: some View {
        switch recognizer.phase {
        case .idle:
            Text(mode == .word
                ? "Önce dinle. Sonra Söyle'ye bas ve kelimeyi yüksek sesle söyle."
                : "Önce dinle. Sonra Söyle'ye bas ve cümleyi yüksek sesle söyle.")
                .font(.callout)
                .foregroundStyle(.secondary)
        case .preparing:
            HStack(spacing: 10) {
                ProgressView()
                Text("İngilizce konuşma modeli iniyor. Bu yalnız ilk seferde olur.")
                    .font(.callout)
            }
        case .listening:
            Label("Dinliyorum... Bitince sus ya da Bitti'ye bas.", systemImage: "waveform")
                .font(.callout.weight(.semibold))
                .symbolEffect(.variableColor.iterative, isActive: !reduceMotion)
        case .checking:
            HStack(spacing: 10) {
                ProgressView()
                Text("Kontrol ediliyor")
                    .font(.callout)
            }
        case .finished(let feedback):
            FeedbackPanel(feedback: feedback)
        case .failed(let problem):
            ProblemPanel(problem: problem)
        }
    }

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
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
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

/// The verdict in words (the color only repeats it), the Turkish message and what was heard.
private struct FeedbackPanel: View {
    let feedback: PronunciationFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(feedback.title, systemImage: symbol)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(feedback.message)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            // A general "Bir daha dene" message already quotes what was heard.
            if !feedback.heard.isEmpty, feedback.verdict != .tryAgain || feedback.tip != nil {
                Text("Duyulan: " + feedback.heard)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
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
            return .green
        case .almost:
            return .orange
        case .tryAgain, .notHeard:
            return .red
        }
    }
}

/// Why "Söyle" cannot run right now, in Turkish, with a way to Settings when that can fix it.
private struct ProblemPanel: View {
    let problem: PronunciationRecognizer.Problem
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Söyle şu an çalışmıyor", systemImage: "mic.slash")
                .font(.headline)
            Text(message)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            if opensSettings {
                Button("Ayarları aç") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
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
