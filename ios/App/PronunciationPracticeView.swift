import AVFoundation
import Speech
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        // Voice Control: "Söyle'ye dokun" works as well as the spoken name.
        .accessibilityInputLabels([Text("Söyle"), Text("Söyle: telaffuzunu dene")])
        .sheet(isPresented: $isPresented) {
            PronunciationPracticeView(word: word, example: example)
                .presentationDetents(sheetDetents)
                // The page scrolls before the sheet grows: the result is scrolled into view.
                .presentationContentInteraction(.scrolls)
                // Opaque like the cards (rule 6): the result panels are tinted over `surface`.
                .presentationBackground(Theme.surface)
        }
    }

    /// Not `.medium`: half of an iPhone SE cut the instructions under the bottom button. The
    /// accessibility sizes get the whole height at once.
    private var sheetDetents: Set<PresentationDetent> {
        if dynamicTypeSize.isAccessibilitySize {
            return [.large]
        }
        return [.custom(SaySheetDetent.self), .large]
    }
}

/// The Söyle sheet's first height: the word, a result with a tip and the bottom button without
/// scrolling on most phones, the card still showing above it. Inactive (nil) on short screens
/// (iPhone SE), which keep only `.large`, the whole height.
private struct SaySheetDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        if context.maxDetentValue < 700 {
            return nil
        }
        return 600
    }
}

/// The learner says the word (or the example sentence); the phone checks it on the device and
/// answers in Turkish ("Anlaşıldı!", "Bir daha dene" with a tip), what it heard in its own row.
/// Mockup `.saysheet`, in three steps: Dinle → Söyle → Sonuç. Each step has one filled button in
/// the bottom bar (listen, then speak, then speak again); the speaker stays next to it as a tonal
/// capsule once listening is no longer the main action. A step bar and one short line say where
/// the learner is.
struct PronunciationPracticeView: View {
    let word: WidgetWord
    let example: String

    @StateObject private var recognizer = PronunciationRecognizer()
    @ObservedObject private var speaker = Speaker.shared
    @State private var mode = Mode.word
    /// Targets read aloud on this page: once a target has been heard, "Söyle" is the main action.
    @State private var listened: Set<String> = []
    /// A permission that is off in Settings, read when the page opens and when the app comes
    /// back: the calm explanation shows before any attempt.
    @State private var blockedBy: PronunciationRecognizer.Problem?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(word: WidgetWord, example: String) {
        self.word = word
        self.example = example
        // Read before the first frame: a permission that is already off when the page opens is
        // shown, not announced (only later changes are).
        _blockedBy = State(initialValue: PronunciationPracticeView.currentPermissionProblem())
    }

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
    private static let preparingText = "İngilizce konuşma modeli iniyor. Bu yalnız ilk seferde olur."
    /// Short: listening starts once it has been said (`PronunciationRecognizer.downloadAnnouncementSeconds`).
    private static let preparingAnnouncement = "İngilizce konuşma modeli iniyor."

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if !example.isEmpty {
                            // Always-visible 46 pt options, not a 32 pt segmented picker.
                            SegmentButtons(
                                options: Mode.allCases.map { SegmentOption(value: $0, title: $0.rawValue) },
                                selection: $mode
                            )
                            .disabled(recognizer.isBusy)
                            .opacity(recognizer.isBusy ? 0.4 : 1)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Ne söyleyeceksin?")
                        }
                        targetView
                        VStack(alignment: .leading, spacing: 12) {
                            if shownProblem == nil {
                                PracticeStepBar(current: step)
                            }
                            statusView
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(PronunciationPracticeView.statusID)
                        Text("Ses telefondan çıkmaz ve kaydedilmez.")
                            .font(.footnote)
                            .foregroundStyle(Theme.ink2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                // Outside the scroll view: the step's one action is always reachable.
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    actionBar
                }
                .onChange(of: recognizer.phase) { _, phase in
                    switch phase {
                    case .finished, .failed:
                        // The result may start below the fold: scroll it into view a moment later,
                        // once the panel has been laid out. Its bottom edge when it fits (the word
                        // stays in view as far as possible); its top at the accessibility sizes,
                        // where a tall panel must show its verdict first.
                        let animation: Animation? = reduceMotion ? nil : .easeOut(duration: 0.25)
                        let anchor: UnitPoint = dynamicTypeSize.isAccessibilitySize ? .top : .bottom
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 60_000_000)
                            withAnimation(animation) {
                                proxy.scrollTo(PronunciationPracticeView.statusID, anchor: anchor)
                            }
                        }
                    default:
                        break
                    }
                    if phase == .preparing {
                        announce([.turkish(PronunciationPracticeView.preparingAnnouncement)], while: .phase(phase))
                    }
                }
                // The result, or why the take could not run (audit V7).
                .onChange(of: recognizer.endedTakes) {
                    announceEndOfTake()
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
        .onAppear {
            refreshPermission()
        }
        .onChange(of: mode) {
            recognizer.cancel()
        }
        // A permission turned off or back on in iPhone Settings (audit V7).
        .onChange(of: blockedBy) { old, new in
            if let new {
                announce(ProblemPanel.spoken(new), while: .permission(new))
            } else if old != nil {
                announce([.turkish("İzin açık. Söyle artık çalışır.")], while: .permission(nil))
            }
        }
        // Step 1 is done once the target has been read aloud (to the end, or stopped).
        .onChange(of: speaker.speakingText) { old, new in
            if let old, old != new {
                listened.insert(old)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                // Back from Settings: the permission may be on now.
                refreshPermission()
            } else if recognizer.isBusy {
                // Never listen in the background (the app has the audio background mode for the
                // widget).
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

    // MARK: - Target

    /// English is serif (rule 3), never italic. The word: bold, with its phosphor band (rule 1),
    /// and the IPA under it (visual only; VoiceOver users play the word instead). The sentence: at
    /// the definition size, the word in it marked as on the cards. VoiceOver reads either in an
    /// English voice (audit V2), the word as the page's heading.
    private var targetView: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch mode {
            case .word:
                Text(word.lemma)
                    .englishWordStyle(size: 34, maxSize: 48)
                    .phosphorBand()
                    .accessibilityLabel(SpeechLanguage.english(word.lemma))
                    .accessibilityAddTraits(.isHeader)
                    .englishVoice()
                if let ipa = word.ipaUS {
                    Text(ipa)
                        .font(.body)
                        .foregroundStyle(Theme.ink2)
                        .accessibilityHidden(true)
                }
            case .sentence:
                Text(ExampleMark.attributed(example, lemma: word.lemma, colorScheme: colorScheme))
                    .font(Theme.Fonts.definition)
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(SpeechLanguage.english(example))
                    .englishVoice()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Steps and status

    private var step: PracticeStep {
        switch recognizer.phase {
        case .idle:
            return listened.contains(target.text) ? .say : .listen
        case .preparing, .listening, .checking:
            return .say
        case .finished, .failed:
            return .result
        }
    }

    /// The permission that is off, or why the last attempt could not run.
    private var shownProblem: PronunciationRecognizer.Problem? {
        if let blockedBy {
            return blockedBy
        }
        if case .failed(let problem) = recognizer.phase {
            return problem
        }
        return nil
    }

    /// One line at a time under the step bar (mockup `sayStatus`), or the result.
    @ViewBuilder
    private var statusView: some View {
        if let problem = shownProblem {
            ProblemPanel(problem: problem)
        } else {
            switch recognizer.phase {
            case .idle:
                statusLine(step == .listen
                    ? "Önce nasıl okunduğunu dinle."
                    : (mode == .word ? "Şimdi kelimeyi yüksek sesle söyle." : "Şimdi cümleyi yüksek sesle söyle."))
            case .preparing:
                HStack(spacing: 10) {
                    ProgressView()
                    statusLine(PronunciationPracticeView.preparingText)
                }
                .frame(minHeight: 44)
            case .listening:
                Label("Dinliyorum… Bitirince bekle ya da Bitti'ye dokun.", systemImage: "waveform")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .symbolEffect(.variableColor.iterative, isActive: !reduceMotion)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 44)
            case .checking:
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Kontrol ediliyor")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink2)
                }
                .frame(minHeight: 44)
            case .finished(let feedback):
                FeedbackPanel(feedback: feedback, target: target.text)
            case .failed:
                // Shown by `ProblemPanel` above.
                EmptyView()
            }
        }
    }

    private func statusLine(_ text: String) -> some View {
        Text(text)
            .font(.callout)
            .foregroundStyle(Theme.ink2)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Bottom bar

    /// The step's one action, always the filled button (mockup `.bigmic`, 64 pt).
    private enum MainAction: Equatable {
        case openSettings
        case listen
        case say
        case finish
        case wait
        case sayAgain
        case retry
    }

    private var mainAction: MainAction {
        if let problem = shownProblem {
            return PronunciationPracticeView.opensSettings(problem) ? .openSettings : .retry
        }
        switch recognizer.phase {
        case .idle:
            return step == .listen ? .listen : .say
        case .preparing, .checking:
            return .wait
        case .listening:
            return .finish
        case .finished:
            return .sayAgain
        case .failed:
            return .retry
        }
    }

    /// The main button, with the speaker beside it as a tonal capsule once listening is no longer
    /// the main action (to listen again after a result). Hidden while the microphone is in use.
    private var actionBar: some View {
        let action = mainAction
        return HStack(spacing: 10) {
            if action != .listen && !recognizer.isBusy {
                listenAgainButton
                    .transition(.opacity)
            }
            mainButton(action)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Theme.surface)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: action)
    }

    private func mainButton(_ action: MainAction) -> some View {
        let isSpeaking = speaker.speakingText == target.text
        // "Durdur" on screen too, so Voice Control finds the name VoiceOver reads.
        let visible = action == .listen && isSpeaking ? "Durdur" : title(of: action)
        // Dinle's VoiceOver name says what is read (terimler §3); Voice Control also takes "Dinle".
        let spoken = action == .listen && !isSpeaking ? listenName : visible
        return Button {
            perform(action)
        } label: {
            Label {
                Text(visible)
            } icon: {
                Image(systemName: symbol(of: action, speaking: isSpeaking))
                    .symbolEffect(.variableColor.iterative, isActive: action == .listen && isSpeaking && !reduceMotion)
            }
        }
        .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 64))
        .disabled(action == .wait)
        .accessibilityLabel(spoken)
        .accessibilityInputLabels(visible == spoken ? [Text(visible)] : [Text(visible), Text(spoken)])
    }

    private var listenAgainButton: some View {
        let isSpeaking = speaker.speakingText == target.text
        return Button {
            speaker.toggle(target.text)
        } label: {
            Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.title3.weight(.semibold))
                .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(minHeight: 64, tonal: true))
        .accessibilityLabel(isSpeaking ? "Durdur" : listenName)
        .accessibilityInputLabels([Text(isSpeaking ? "Durdur" : "Dinle"), Text(isSpeaking ? "Durdur" : listenName)])
    }

    /// Dinle's VoiceOver name (terimler §3).
    private var listenName: String {
        return mode == .word ? "Kelimeyi dinle" : "Cümleyi dinle"
    }

    private func title(of action: MainAction) -> String {
        switch action {
        case .openSettings:
            // iPhone Settings, not the app's Ayarlar tab (terimler §2): named after what to turn on.
            return shownProblem == .speechDenied ? "Tanıma iznini aç" : "Mikrofon iznini aç"
        case .listen:
            return "Dinle"
        case .say:
            return "Söyle"
        case .wait:
            // Not a dimmed "Söyle", which VoiceOver reads as "speak now" (metin denetimi #14).
            return "Bekle"
        case .finish:
            return "Bitti"
        case .sayAgain:
            return "Bir daha söyle"
        case .retry:
            return "Bir daha dene"
        }
    }

    private func symbol(of action: MainAction, speaking: Bool) -> String {
        switch action {
        case .openSettings:
            return "gearshape"
        case .listen:
            return speaking ? "speaker.wave.2.fill" : "speaker.wave.2"
        case .finish:
            return "stop.fill"
        case .wait:
            return "hourglass"
        case .say, .sayAgain, .retry:
            return "mic.fill"
        }
    }

    private func perform(_ action: MainAction) {
        switch action {
        case .openSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        case .listen:
            // A second tap stops the reading; either way step 1 is done.
            speaker.toggle(target.text)
        case .finish:
            recognizer.finish()
        case .wait:
            break
        case .say, .sayAgain, .retry:
            // A light tap tells a VoiceOver user that listening starts; it comes before the
            // recording session is active (haptics are muted while recording).
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            recognizer.start(target, maxSeconds: mode == .word ? 5 : 10)
        }
    }

    // MARK: - Permissions

    private static func opensSettings(_ problem: PronunciationRecognizer.Problem) -> Bool {
        return problem == .microphoneDenied || problem == .speechDenied
    }

    /// Reads (never asks for) the permissions the recognizer needs. The system asks only on the
    /// first "Söyle"; once a permission is off, only Settings can turn it on. When it is on
    /// again, a "permission off" result is dropped so that "Söyle" is the main action again.
    private func refreshPermission() {
        let blocked = PronunciationPracticeView.currentPermissionProblem()
        blockedBy = blocked
        if blocked == nil, case .failed(let problem) = recognizer.phase, PronunciationPracticeView.opensSettings(problem) {
            recognizer.cancel()
        }
    }

    private static func currentPermissionProblem() -> PronunciationRecognizer.Problem? {
        if AVAudioApplication.shared.recordPermission == .denied {
            return .microphoneDenied
        }
        // iOS 26+ (SpeechAnalyzer) needs only the microphone.
        if #available(iOS 26.0, *) {
            return nil
        }
        return SFSpeechRecognizer.authorizationStatus() == .denied ? .speechDenied : nil
    }

    // MARK: - VoiceOver announcements

    /// What must still be true when an announcement goes out, a moment after it was made.
    private enum StillTrue {
        /// No other take has started or ended.
        case phase(PronunciationRecognizer.Phase)
        /// The permission is still off (nil: still on), and no take has just failed for it: that
        /// take's own announcement says it already (the first "no" to the system's question).
        case permission(PronunciationRecognizer.Problem?)
    }

    /// The take's result, or why it could not run: a permission that is off first, as on the page.
    private func announceEndOfTake() {
        let phase = recognizer.phase
        switch phase {
        case .finished(let feedback):
            announce(FeedbackPanel.spokenResult(feedback), while: .phase(phase))
        case .failed(let problem):
            announce(ProblemPanel.spoken(blockedBy ?? problem), while: .phase(phase))
        case .idle, .preparing, .listening, .checking:
            break
        }
    }

    /// Says what just changed, so that a VoiceOver user does not have to look for it (audit V7):
    /// what happened and what to do. Never when listening starts: the microphone would hear it (a
    /// light tap says that instead). Posted a moment later, once the page has scrolled, so that
    /// VoiceOver does not drop it, and only if `still` holds then. Default priority, never
    /// `.high`: an announcement that cannot be cut off would still be speaking when the learner
    /// taps "Bir daha söyle", and the microphone would hear it.
    private func announce(_ runs: [FeedbackRun], while still: StillTrue) {
        let recognizer = self.recognizer
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            switch still {
            case .phase(let phase):
                guard recognizer.phase == phase else {
                    return
                }
            case .permission(let problem):
                guard PronunciationPracticeView.currentPermissionProblem() == problem else {
                    return
                }
                if let problem, recognizer.phase == .failed(problem) {
                    return
                }
            }
            UIAccessibility.post(notification: .announcement, argument: SpeechLanguage.attributed(runs))
        }
    }
}

// MARK: - Step bar

/// The three steps of the page.
private enum PracticeStep: Int, CaseIterable {
    case listen = 1
    case say
    case result

    var title: String {
        switch self {
        case .listen:
            return "Dinle"
        case .say:
            return "Söyle"
        case .result:
            return "Sonuç"
        }
    }
}

/// Dinle → Söyle → Sonuç. The current step is a filled `tint` dot with its number and a bold
/// label, the steps before it a `tint` dot with a check, the next ones an outlined dot: shape and
/// weight carry the state, not color alone (rule 4). `tint` stays ink at night, never yellow. At
/// the largest text sizes, one line: "Adım 2/3: Söyle". Not tappable, so no capsules (rule 2).
private struct PracticeStepBar: View {
    let current: PracticeStep
    @ScaledMetric(relativeTo: .footnote) private var dotSize: CGFloat = 22

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) {
                ForEach(PracticeStep.allCases, id: \.self) { step in
                    if step != .listen {
                        Capsule()
                            .fill(step.rawValue <= current.rawValue ? Theme.tint : Theme.surface3)
                            .frame(width: 16, height: 2)
                    }
                    item(step)
                }
            }
            Text(verbatim: "Adım \(current.rawValue)/3: \(current.title)")
                .font(.footnote.weight(.bold))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(current.rawValue). adım: \(current.title)"))
    }

    private func item(_ step: PracticeStep) -> some View {
        let isCurrent = step == current
        let isDone = step.rawValue < current.rawValue
        return HStack(spacing: 6) {
            ZStack {
                if isDone || isCurrent {
                    Circle()
                        .fill(Theme.tint)
                } else {
                    Circle()
                        .strokeBorder(Theme.lineStrong, lineWidth: 1.5)
                }
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.surface)
                } else {
                    Text(verbatim: "\(step.rawValue)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isCurrent ? Theme.surface : Theme.ink3)
                }
            }
            .frame(width: dotSize, height: dotSize)
            Text(step.title)
                .font(.footnote.weight(isCurrent ? .bold : .regular))
                .foregroundStyle(isCurrent ? Theme.ink : Theme.ink2)
                .lineLimit(1)
                .fixedSize()
        }
    }
}

// MARK: - Result

/// The verdict in words with its icon (the color only repeats it, rule 4), one short Turkish line,
/// what the phone heard and, when it differs, the target with the differing words marked (the
/// Dikkat diff of the cards), then the sound tip (th, w/v, final sounds) when there is one.
/// README point 15: `good` / `caution` / `bad` on a `goodTint` / `cautionTint` / `badTint` panel
/// (mockup `.verdict`).
/// VoiceOver (audit V2, V5): the verdict and its line are read together; the English rows are their
/// own elements, so they keep the English voice (a combined element would read them in Turkish).
/// The same verdict, line and tip are announced when the result comes.
private struct FeedbackPanel: View {
    let feedback: PronunciationFeedback
    /// What the learner was asked to say.
    let target: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Label(feedback.title, systemImage: symbol)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(color)
                Text(feedback.message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(SpeechLanguage.mixed(FeedbackPanel.spokenVerdict(feedback)))
            if !feedback.heard.isEmpty {
                comparison
            }
            if let tip = feedback.tip {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "lightbulb")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink2)
                        .accessibilityHidden(true)
                    Text(tip.advice)
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panel, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    /// The verdict and its line for VoiceOver, the words not heard in an English voice.
    static func spokenVerdict(_ feedback: PronunciationFeedback) -> [FeedbackRun] {
        // A pause after the title ("Bir daha dene" has no mark of its own).
        let title = feedback.title.last.map { ".!?".contains($0) } == true ? feedback.title : feedback.title + "."
        return [.turkish(title + " ")] + feedback.messageRuns
    }

    /// The announcement: the verdict, its line and the tip, i.e. what happened and what to do.
    static func spokenResult(_ feedback: PronunciationFeedback) -> [FeedbackRun] {
        var runs = spokenVerdict(feedback)
        if let tip = feedback.tip {
            runs.append(.turkish(" " + tip.advice))
        }
        return runs
    }

    /// "Doğrusu" only when something was not right and the words differ.
    private func showsTarget(_ marks: MistakeDiff) -> Bool {
        guard feedback.verdict == .almost || feedback.verdict == .tryAgain else {
            return false
        }
        return marks.wrong.contains { $0.isChanged } || marks.right.contains { $0.isChanged }
    }

    /// "Duyulan" and, when it differs, "Doğrusu": English in serif (rule 3). Heard words that are
    /// not in the target get a dotted underline, target words that were not heard an underline
    /// and bold (the Dikkat diff of the cards): marks, not color alone.
    @ViewBuilder
    private var comparison: some View {
        let marks = MistakeDiff(wrong: feedback.heard, right: target)
        let differs = showsTarget(marks)
        let heard = differs ? Text(marks.wrongText(color: color)) : Text(feedback.heard)
        let expected = Text(marks.rightText())
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    rowLabel("Duyulan")
                    englishRow(heard, speech: feedback.heard)
                }
                if differs {
                    VStack(alignment: .leading, spacing: 2) {
                        rowLabel("Doğrusu")
                        englishRow(expected, speech: target)
                    }
                }
            }
        } else {
            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 12, verticalSpacing: 6) {
                GridRow {
                    rowLabel("Duyulan")
                    englishRow(heard, speech: feedback.heard)
                }
                if differs {
                    GridRow {
                        rowLabel("Doğrusu")
                        englishRow(expected, speech: target)
                    }
                }
            }
        }
    }

    private func rowLabel(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.ink2)
    }

    /// `speech`: the row's plain words, read in an English voice.
    private func englishRow(_ text: Text, speech: String) -> some View {
        text
            .font(Theme.Fonts.example)
            .foregroundStyle(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(SpeechLanguage.english(speech))
            .englishVoice()
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

/// Why "Söyle" cannot run right now, calmly, in Turkish (mockup `.problem`): a bordered panel in
/// ink, never red. A permission that is off is fixed in iPhone Settings, so "Mikrofon iznini aç"
/// (which opens them) is then the page's main button (bottom bar); otherwise the main button tries
/// again. What happened, then what to do; announced to VoiceOver when it appears.
private struct ProblemPanel: View {
    typealias Problem = PronunciationRecognizer.Problem

    let problem: Problem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(ProblemPanel.title(problem), systemImage: "mic.slash")
                .font(.headline)
                .foregroundStyle(Theme.ink)
            Text(ProblemPanel.message(problem))
                .font(.subheadline)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
                .strokeBorder(Theme.lineStrong, lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
    }

    /// Title and message, for the announcement.
    static func spoken(_ problem: Problem) -> [FeedbackRun] {
        return [.turkish(title(problem) + ". " + message(problem))]
    }

    static func title(_ problem: Problem) -> String {
        switch problem {
        case .microphoneDenied:
            return "Mikrofon izni kapalı"
        case .speechDenied:
            return "Konuşma tanıma izni kapalı"
        default:
            return "Söyle şu an çalışmıyor"
        }
    }

    /// No ">" in a path (VoiceOver may read "büyüktür") and no system error text (it is English
    /// and in "Söyle tanılama" already): terimler §1, metin denetimi "Söyle".
    static func message(_ problem: Problem) -> String {
        switch problem {
        case .microphoneDenied:
            return "iPhone Ayarları'nda Lockglow için mikrofon iznini açabilirsin. Dinle ve kartlar izinsiz de çalışır."
        case .speechDenied:
            return "iPhone Ayarları'nda Lockglow için konuşma tanıma iznini açabilirsin. Dinle ve kartlar izinsiz de çalışır."
        case .speechRestricted:
            return "Konuşma tanıma bu telefonda kısıtlı. Ekran Süresi ya da telefonu yöneten kurum bunu kapatmış olabilir."
        case .modelUnavailable:
            return "İngilizce konuşma modeli indirilemedi. İnternete bağlanıp bir daha dene. Model bir kez iner, sonra internet gerekmez."
        case .onDeviceUnavailable:
            return "Bu telefonda İngilizce konuşma tanıma hazır değil. iPhone Ayarları'nda Genel, sonra Klavye bölümüne gir. İngilizce (ABD) klavyeyi ekle ve Dikte'yi aç."
        case .audioFailed:
            return "Mikrofon başlatılamadı. Başka bir uygulama mikrofonu kullanıyor olabilir. Bir daha dene."
        case .recognitionFailed:
            return "Konuşma tanıma bu sefer çalışmadı. Bir daha dene."
        }
    }
}

// MARK: - Speech language

/// VoiceOver labels and announcements with their language (README point 14; audit V2 and V6).
/// `englishVoice()` gives a view an English locale; these labels also put
/// `accessibilitySpeechLanguage` on every run ("en-US" for English, "tr-TR" for Turkish), so
/// whichever of the two this iOS honors, English is not read in a Turkish voice. Which one works in
/// a label is still to be heard on the phone (V6); announcements are UIKit attributed strings,
/// which carry the attribute themselves.
private enum SpeechLanguage {
    static func english(_ text: String) -> Text {
        return mixed([.english(text)])
    }

    static func mixed(_ runs: [FeedbackRun]) -> Text {
        return Text(AttributedString(attributed(runs)))
    }

    static func attributed(_ runs: [FeedbackRun]) -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        for run in runs {
            switch run {
            case .turkish(let text):
                result.append(NSAttributedString(string: text, attributes: [.accessibilitySpeechLanguage: "tr-TR"]))
            case .english(let text):
                result.append(NSAttributedString(string: text, attributes: [.accessibilitySpeechLanguage: "en-US"]))
            }
        }
        return result
    }
}
