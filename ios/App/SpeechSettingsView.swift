import AVFoundation
import Combine
import SwiftUI
import WidgetKit
import CoreModels

/// The "Ses" group of "Ayarlar": one row to "Ses ve aksan" with the accent and the speed, and a
/// note when no natural English voice is installed. `SettingsView` shows it with one line.
struct SpeechSettingsSection: View {
    @AppStorage(SpeechSettings.Key.accent, store: SpeechSettingsStore.defaults) private var accent = SpeechAccent.american
    @AppStorage(SpeechSettings.Key.rate, store: SpeechSettingsStore.defaults) private var rate = SpeechRate.normal
    @AppStorage(SpeechSettings.Key.gender, store: SpeechSettingsStore.defaults) private var gender = SpeechVoiceGender.female
    @State private var needsBetterVoice = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Ses")
            SettingsGroup {
                NavigationLink {
                    SpeechSettingsView()
                } label: {
                    SettingsRow("Ses ve aksan", systemImage: "speaker.wave.2") {
                        Text(verbatim: "\(accent.title) · \(gender.title) · \(rate.title)")
                            // "·" may be read aloud (README, VoiceOver and "·").
                            .accessibilityLabel(Text(verbatim: "\(accent.title), \(gender.title), \(rate.title)"))
                    }
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
            if needsBetterVoice {
                Text("Daha doğal bir İngilizce ses indirebilirsin. Nasıl yapılacağı Ses ve aksan sayfasında.")
                    .settingsFootnote()
            }
        }
        .task(id: "\(accent.rawValue)|\(gender.rawValue)") {
            await refresh()
        }
        // Back from iPhone Settings, where a voice may have been downloaded.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WordSpeech.refreshVoices()
                Task {
                    await refresh()
                }
            }
        }
    }

    /// Off the main thread: the first look at the installed voices is slow.
    private func refresh() async {
        let accent = accent
        let gender = gender
        needsBetterVoice = await Task.detached {
            WordSpeech.needsBetterVoice(for: accent, gender: gender)
        }.value
    }
}

/// "Ses ve aksan": the accent (ABD or İngiltere: Dinle, the recognizer of "Söyle" and the IPA on
/// the cards and the widget follow it), the speed and "Yavaş tekrar", and the voice: the best
/// installed one unless the user picks another, with the way to download a more natural one when
/// only the standard voices are on the phone. Every choice is saved at once in the App Group
/// (`SpeechSettingsStore`), so the widget's speaker button reads with it too.
struct SpeechSettingsView: View {
    @AppStorage(SpeechSettings.Key.accent, store: SpeechSettingsStore.defaults) private var accent = SpeechAccent.american
    @AppStorage(SpeechSettings.Key.rate, store: SpeechSettingsStore.defaults) private var rate = SpeechRate.normal
    @AppStorage(SpeechSettings.Key.slowRepeat, store: SpeechSettingsStore.defaults) private var slowRepeat = true
    @AppStorage(SpeechSettings.Key.gender, store: SpeechSettingsStore.defaults) private var gender = SpeechVoiceGender.female
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    /// The voice chosen for the current accent; nil: the best installed one ("Otomatik").
    @State private var chosenVoice: String?
    /// The accent's voices, best first (`WordSpeech.offeredVoices`).
    @State private var voices: [SpeechVoiceInfo] = []
    @State private var needsBetterVoice = false

    /// Read after every choice, so the user hears what changed. A card sentence (s0 "breakfast").
    static let sample = "I usually have breakfast at seven."

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                accentSection
                genderSection
                rateSection
                voiceSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Ses ve aksan")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: "\(accent.rawValue)|\(gender.rawValue)") {
            await reloadVoices()
        }
        .onChange(of: accent) { _, _ in
            // The medium widget shows the IPA of the accent: draw it again now. A reload asked
            // while the app is in front does not count against the widget's refresh budget.
            WidgetCenter.shared.reloadAllTimelines()
            playSample()
        }
        .onChange(of: gender) { _, _ in
            // The character picks the voice: a voice chosen by name (of either accent) gives way.
            chosenVoice = nil
            SpeechSettingsStore.update { settings in
                settings.voiceIdentifiers = [:]
            }
            playSample()
        }
        .onChange(of: rate) { _, _ in
            playSample()
        }
        // Back from iPhone Settings with a new voice, or iOS reports a change in the voices.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WordSpeech.refreshVoices()
                Task {
                    await reloadVoices()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: AVSpeechSynthesizer.availableVoicesDidChangeNotification).receive(on: RunLoop.main)) { _ in
            WordSpeech.refreshVoices()
            Task {
                await reloadVoices()
            }
        }
        .onDisappear {
            speaker.stop()
        }
    }

    // MARK: Accent

    private var accentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Aksan")
            SettingsQuestion("Hangi İngilizceyi duymak istersin?")
            SegmentButtons(
                options: SpeechAccent.allCases.map { accent in
                    SegmentOption(value: accent, title: accent.title, spokenTitle: accent.spokenTitle)
                },
                selection: $accent
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Aksan")
            Text("Dinle bu aksanla okur, Söyle de bu aksanı bekler. Kartlardaki okunuş yazısı da buna göre değişir.")
                .settingsFootnote()
        }
    }

    // MARK: Voice character

    private var genderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Ses karakteri")
            SettingsQuestion("Kim okusun?")
            SegmentButtons(
                options: SpeechVoiceGender.allCases.map { gender in
                    SegmentOption(value: gender, title: gender.title, spokenTitle: gender.spokenTitle)
                },
                selection: $gender
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Ses karakteri")
            Text("Hazır kaydı olan kelime ve cümleler bu sesle okunur. Diğerlerini telefonun bu karakterdeki en iyi sesi okur.")
                .settingsFootnote()
        }
    }

    // MARK: Speed

    private var rateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Hız")
            SettingsQuestion("Ne hızda okusun?")
            SegmentButtons(
                options: SpeechRate.allCases.map { rate in
                    SegmentOption(value: rate, title: rate.title)
                },
                selection: $rate
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Okuma hızı")
            Text(verbatim: rate.footnote)
                .settingsFootnote()
            SettingsGroup {
                Toggle(isOn: $slowRepeat) {
                    Text("Yavaş tekrar")
                        .settingsRowTitle()
                }
                // A switch is on in `good` green, as in iOS (never yellow, never ink).
                .tint(Theme.good)
                .settingsRowPadding()
            }
            .padding(.top, 8)
            // While it reads, a second tap stops it (`Speaker.toggle`): the repeat comes after.
            Text("Okuma bitince aynı kelimeye ya da cümleye yine dokunursan daha yavaş okur. Önce normal, sonra yavaş duyarsın.")
                .settingsFootnote()
            sampleRow
                .padding(.top, 8)
        }
    }

    /// The sample sentence with its own "Dinle": a tap after the first reading has ended is the
    /// slow repeat. At the accessibility text sizes the button stands under the sentence.
    private var sampleRow: some View {
        let isSpeaking = speaker.speakingText == Self.sample
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 12))
        return SettingsGroup {
            layout {
                Text(verbatim: Self.sample)
                    .font(Theme.Fonts.example)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .englishVoice()
                Button {
                    speaker.toggle(Self.sample)
                } label: {
                    Label(isSpeaking ? "Durdur" : "Dinle", systemImage: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
                .accessibilityLabel(isSpeaking ? "Durdur" : "Örnek cümleyi dinle")
                .accessibilityInputLabels([Text(isSpeaking ? "Durdur" : "Dinle")])
            }
            .padding(16)
        }
    }

    // MARK: Voice

    private var voiceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Ses")
            if needsBetterVoice {
                VoiceDownloadGuide(accent: accent, gender: gender, isCard: true)
                    .padding(.bottom, 8)
            }
            SettingsGroup {
                voiceRow(nil)
                ForEach(voices, id: \.identifier) { voice in
                    SettingsDivider()
                    voiceRow(voice)
                }
            }
            Text("Bir sese dokununca örnek cümleyi o sesle okur.")
                .settingsFootnote()
            if !needsBetterVoice {
                SettingsGroup {
                    NavigationLink {
                        VoiceDownloadGuideScreen(accent: accent, gender: gender)
                    } label: {
                        SettingsRow("Başka bir ses indir", systemImage: "arrow.down.circle")
                    }
                    .buttonStyle(SettingsRowButtonStyle())
                }
                .padding(.top, 8)
            }
        }
    }

    /// One voice ("Ava", "Premium"), or "Otomatik" (nil) with the voice it picks now. A tap picks
    /// it and reads the sample with it.
    private func voiceRow(_ voice: SpeechVoiceInfo?) -> some View {
        let isSelected = voice?.identifier == chosenVoice
        let title = voice?.displayName ?? "Otomatik"
        let detail = voiceDetail(voice)
        let spokenDetail = voiceDetail(voice, spoken: true)
        return Button {
            choose(voice)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: title)
                        .settingsRowTitle()
                    Text(verbatim: detail)
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                // The selected voice's check in the one tint, as in an iOS list.
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.tint)
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: Theme.minHitSize, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(title), \(spokenDetail)"))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    /// "Premium · Kadın"; `spoken`: with a comma, "·" may be read aloud.
    private func voiceDetail(_ voice: SpeechVoiceInfo?, spoken: Bool = false) -> String {
        if let voice {
            guard let gender = voice.gender else {
                return voice.quality.title
            }
            return voice.quality.title + (spoken ? ", " : " · ") + gender.title
        }
        var automatic = SpeechSettingsStore.current
        automatic.voiceIdentifiers = [:]
        if WordSpeech.hasRecordedVoice(for: automatic) {
            return "Hazır kayıt; kaydı olmayanı telefonun sesi okur"
        }
        guard let best = SpeechVoiceChoice.best(of: voices, gender: gender) else {
            return "Telefonun İngilizce sesi"
        }
        return "Şimdi: \(best.displayName), \(best.quality.title)"
    }

    private func choose(_ voice: SpeechVoiceInfo?) {
        chosenVoice = voice?.identifier
        let accent = accent
        SpeechSettingsStore.update { settings in
            settings.voiceIdentifiers[accent] = voice?.identifier
        }
        playSample()
    }

    /// Reads the sample with the new choice; replaces a reading in progress (a plain `toggle`
    /// would stop it instead). Not while VoiceOver runs: it would talk over VoiceOver's own
    /// reading of the choice (the sample's Dinle is there for that).
    private func playSample() {
        guard !UIAccessibility.isVoiceOverRunning else {
            return
        }
        speaker.stop()
        speaker.toggle(Self.sample)
    }

    /// Off the main thread: the first look at the installed voices is slow. A chosen voice that
    /// was deleted reads as "Otomatik".
    private func reloadVoices() async {
        let accent = accent
        let gender = gender
        let (offered, needsBetter) = await Task.detached {
            (WordSpeech.offeredVoices(for: accent), WordSpeech.needsBetterVoice(for: accent, gender: gender))
        }.value
        voices = offered
        needsBetterVoice = needsBetter
        let chosen = SpeechSettingsStore.current.voiceIdentifiers[accent]
        chosenVoice = offered.contains { $0.identifier == chosen } ? chosen : nil
    }
}

// MARK: - Download guide

/// "Daha doğal ses indir" as its own page (from "Başka bir ses indir").
struct VoiceDownloadGuideScreen: View {
    let accent: SpeechAccent
    let gender: SpeechVoiceGender

    var body: some View {
        ScrollView {
            VoiceDownloadGuide(accent: accent, gender: gender, isCard: false)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Daha doğal ses indir")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// How to download a premium or enhanced English voice in iPhone Settings, step by step. Menu
/// names as in Apple's Turkish iPhone User Guide ("iPhone'un ekranı, seçilen metni ve yazma geri
/// bildirimini seslendirmesini sağlama"): iOS 26 calls the page "Oku ve Seslendir", iOS 17 and 18
/// "Seslendirilen İçerik"; both have "Sesler". Apple offers no link that opens that page (only
/// the app's own settings page), so the steps are words. No ">" between the names: VoiceOver may
/// read it (terimler §1). `isCard`: inside "Ses ve aksan", under a title, on a white card.
struct VoiceDownloadGuide: View {
    let accent: SpeechAccent
    let gender: SpeechVoiceGender
    var isCard = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isCard {
                Text("Daha doğal ses indir")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
            }
            Text(verbatim: intro)
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    VoiceGuideStep(number: index + 1, text: step)
                }
            }
            Text("Bir ses birkaç yüz MB tutabilir. Wi-Fi'deyken indir.")
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        )
    }

    /// The card says why it is there: this accent has only standard voices.
    private var intro: String {
        let download = "iPhone'da daha doğal İngilizce sesler ücretsiz indirilir. Sonra internetsiz de çalışır."
        return isCard ? "Bu aksan için telefonunda yalnız standart sesler var. " + download : download
    }

    private var steps: [String] {
        let page: String
        if #available(iOS 26, *) {
            page = "**Oku ve Seslendir**'e dokun."
        } else {
            page = "**Seslendirilen İçerik**'e dokun."
        }
        // Apple's natural voices: Ava, Zoe (woman), Evan, Nathan (man) in the US; Serena, Kate
        // (woman), Jamie, Daniel (man) in the UK.
        let names: String
        switch (accent, gender) {
        case (.american, .female):
            names = "**Ava** ya da **Zoe**"
        case (.american, .male):
            names = "**Evan** ya da **Nathan**"
        case (.british, .female):
            names = "**Serena** ya da **Kate**"
        case (.british, .male):
            names = "**Jamie** ya da **Daniel**"
        }
        let voices: String
        switch accent {
        case .american:
            voices = "ABD seslerinden birine dokun, örneğin \(names)."
        case .british:
            voices = "iPhone İngiltere seslerine **Birleşik Krallık** der. Bu seslerden birine dokun, örneğin \(names)."
        }
        return [
            "**iPhone Ayarları**'nı aç.",
            "**Erişilebilirlik**'e dokun.",
            page,
            "**Sesler**'e dokun, sonra **İngilizce**'ye dokun.",
            voices,
            "Boyutu en büyük olanı seç; en doğal ses odur. Yanındaki indirme simgesine dokun.",
            "İndirme bitince Lockglow'a dön. Yeni ses burada listede görünür.",
        ]
    }
}

/// A numbered step: an ink circle with the number, then the sentence (as "Widget nasıl
/// eklenir?"). At the largest text sizes the number stands above the sentence.
private struct VoiceGuideStep: View {
    let number: Int
    let text: String
    @ScaledMetric(relativeTo: .body) private var circleSize: CGFloat = 28
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
        layout {
            Text(verbatim: "\(number)")
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Theme.bg)
                .frame(minWidth: circleSize, minHeight: circleSize)
                .background(Circle().fill(Theme.ink))
                .accessibilityHidden(true)
            Text(LocalizedStringKey(text))
                .font(.body)
                .foregroundStyle(Theme.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Adım \(number): ") + Text(LocalizedStringKey(text)))
    }
}

// MARK: - IPA in the chosen accent

/// The word's IPA in the accent of "Ses ve aksan" (`ipa_uk` for İngiltere), drawn by `content`;
/// nothing for a word without IPA (the user's own words). Redraws as soon as the accent changes,
/// also on a card that stayed on screen in another tab.
struct AccentIPA<Content: View>: View {
    let word: WidgetWord
    let content: (String) -> Content
    @AppStorage(SpeechSettings.Key.accent, store: SpeechSettingsStore.defaults) private var accent = SpeechAccent.american

    init(_ word: WidgetWord, @ViewBuilder content: @escaping (String) -> Content) {
        self.word = word
        self.content = content
    }

    var body: some View {
        if let ipa = word.ipa(for: accent) {
            content(ipa)
        }
    }
}

// MARK: - Turkish names

extension SpeechAccent {
    /// "ABD", "İngiltere".
    var title: String {
        switch self {
        case .american:
            return "ABD"
        case .british:
            return "İngiltere"
        }
    }

    /// What VoiceOver says for the option.
    var spokenTitle: String {
        switch self {
        case .american:
            return "ABD İngilizcesi"
        case .british:
            return "İngiltere İngilizcesi"
        }
    }
}

extension SpeechVoiceGender {
    /// "Kadın", "Erkek".
    var title: String {
        switch self {
        case .female:
            return "Kadın"
        case .male:
            return "Erkek"
        }
    }

    /// What VoiceOver says for the option.
    var spokenTitle: String {
        switch self {
        case .female:
            return "Kadın sesi"
        case .male:
            return "Erkek sesi"
        }
    }
}

extension SpeechRate {
    var title: String {
        switch self {
        case .slow:
            return "Yavaş"
        case .normal:
            return "Normal"
        case .fast:
            return "Hızlı"
        }
    }

    /// What the speed means for the listener.
    var footnote: String {
        switch self {
        case .slow:
            return "Her ses daha net duyulur. Yeni kelimeler için iyi."
        case .normal:
            return "Günlük konuşmadan biraz yavaş."
        case .fast:
            return "Günlük konuşma hızı. Kulağını gerçek konuşmaya alıştırır."
        }
    }
}

extension SpeechVoiceInfo.Quality {
    /// Our names for the three qualities. Whether iPhone Settings writes "Premium" and "Gelişmiş"
    /// in Turkish too is not checked yet (the guide names neither).
    var title: String {
        switch self {
        case .premium:
            return "Premium"
        case .enhanced:
            return "Gelişmiş"
        case .standard:
            return "Standart"
        }
    }
}
