import SwiftUI
import CoreModels
import Learning

/// First-launch onboarding: level, topics, daily goal, optional known words, the widget guide
/// and the first word. It opens by itself once; "Ayarlar > Yardım" opens it again. "Atla" ends it
/// on any page (the last one too) and keeps what was chosen so far.
///
/// One question and one filled button per page, short sentences for an A2 reader, no pressure.
/// An untouched daily goal follows the level: 5 from A1 and A2, 10 from B1. An explicit choice,
/// including an earlier choice in "Ayarlar", stays. The first word starts
/// with its meaning hidden, so the move of "Tekrar" (guess, then look) is learned by doing it.
///
/// The model saves the known-word checkpoint before the widget guide (and on "Atla"). Only a
/// successful save applies the choices, so a widget added on the next page uses the chosen deck.
struct OnboardingView: View {
    private enum Page: Int, CaseIterable {
        case level
        case topics
        case daily
        case known
        case widget
        case firstWord
    }

    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var page: Page = .level
    @State private var level: Level?
    @State private var topicIDs: Set<String> = []
    @State private var explicitDailyChoice: Int?
    @State private var knownSession: OnboardingKnownSession?
    @State private var selectedKnownIDs: Set<Int> = []
    @State private var isSaving = false
    @State private var showsSaveError = false
    @State private var hasAppliedChoices = false
    @State private var hasLoadedChoice = false
    /// The first word whose meaning was shown; another first word (a new level or topic) starts
    /// hidden again.
    @State private var shownMeaningWordID: Int?
    /// VoiceOver's focus on the page title: a new page starts there, not on the button that
    /// stayed (audit V7).
    @AccessibilityFocusState private var isTitleFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                pageContent
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .id(page)
            .transition(.opacity)
            .disabled(isSaving)
            bottomBar
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: page)
        .background(Theme.bg.ignoresSafeArea())
        // A full-screen cover starts its own hierarchy: no blue anywhere inside.
        .tint(Theme.ink)
        .onAppear(perform: loadChoice)
        .onChange(of: level) {
            invalidateKnownSession()
        }
        .onChange(of: topicIDs) {
            invalidateKnownSession()
        }
    }

    // MARK: Bars

    /// Mockup `.ob-top`: "geri" and "Atla" are control-layer capsules (glass on iOS 26, rule 6);
    /// the step bar between them is ink, never yellow, also at night. The bar stops growing at
    /// the first accessibility text size, so the step bar keeps room between the two capsules
    /// on an iPhone SE.
    private var topBar: some View {
        HStack(spacing: 8) {
            if page == .level {
                Color.clear
                    .frame(width: 44, height: 44)
            } else {
                Button {
                    go(to: Page(rawValue: page.rawValue - 1) ?? .level)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .frame(minWidth: 20, minHeight: 30)
                }
                .glassControl()
                .accessibilityLabel("Geri")
                .accessibilityIdentifier("onboarding.back")
                .disabled(isSaving)
            }
            progressBar
            Button {
                finish()
            } label: {
                Text("Atla")
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                    .frame(minHeight: 30)
            }
            .glassControl()
            .accessibilityIdentifier("onboarding.skip")
            .disabled(isSaving)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .frame(minHeight: 52)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(Page.allCases, id: \.self) { item in
                Capsule()
                    .fill(item.rawValue <= page.rawValue ? Theme.tint : Theme.surface3)
                    // The steps ahead get a 1 pt `lineStrong` edge: `surface3` alone is under 3:1
                    // against the page (audit K2), as the theme's gray capsules.
                    .overlay {
                        if item.rawValue > page.rawValue {
                            Capsule().strokeBorder(Theme.lineStrong, lineWidth: 1)
                        }
                    }
                    .frame(height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        // "/" would be read as "bölü" (terimler §1).
        .accessibilityLabel("Adım \(page.rawValue + 1), toplam \(Page.allCases.count)")
    }

    /// Mockup `.ob-foot`: on the topics page the deck summary (always there, so the bar does
    /// not jump at the first tap) over the one filled button of the page. At the largest text
    /// sizes the summary leads the list instead and the button stops growing, so the list keeps
    /// most of an iPhone SE screen.
    private var bottomBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsSaveError {
                Text(model.onboardingChoiceError ?? "Seçimlerin kaydedilemedi. Tekrar dene.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("onboarding.error")
            } else if hasAppliedChoices, let notice = model.onboardingChoiceNotice {
                Text(verbatim: notice)
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if showsTopicSummary && !dynamicTypeSize.isAccessibilitySize {
                topicSummary
                    .padding(.horizontal, 4)
            }
            Button(primaryTitle) {
                advance()
            }
            .buttonStyle(GlowButtonStyle())
            .disabled(isNextDisabled || isSaving)
            .accessibilityIdentifier(page == .firstWord ? "onboarding.start" : "onboarding.next")
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        }
        .padding(.horizontal, 16)
        .padding(.top, showsTopicSummary ? 12 : 8)
        .padding(.bottom, 8)
        .background(Theme.bg)
        // The topic list and the widget steps scroll under the bar: a hairline, as in
        // "Ayarlar > Konular", never a hard cut.
        .overlay(alignment: .top) {
            if showsTopicSummary || page == .known || page == .widget {
                Rectangle()
                    .fill(Theme.line)
                    .frame(height: 1)
            }
        }
    }

    private var showsTopicSummary: Bool {
        return page == .topics && model.contentSource != .loading && !model.choosableTopics.isEmpty
    }

    private var topicSummary: some View {
        // "Tümü" is selected when no listed topic is (as in `TopicChoiceList`).
        DeckSummaryLine(
            summary: model.deckSummary(for: chosenTopicCount == 0 ? [] : topicIDs),
            dailyGoal: dailyGoal,
            isEverything: chosenTopicCount == 0
        )
    }

    /// Showing the level's default does not turn it into an explicit saved choice.
    private var dailyGoal: Int {
        return SettingsRules.dailyNewWords(stored: explicitDailyChoice, startLevel: level)
    }

    /// Topics still loading: leaving the page would apply the choice before there are words,
    /// and no plan would be written ("Atla" still works).
    private var isNextDisabled: Bool {
        switch page {
        case .level:
            return level == nil
        case .topics, .known:
            return model.contentSource == .loading
        case .daily, .widget, .firstWord:
            return false
        }
    }

    private var chosenTopicCount: Int {
        return model.choosableTopics.filter { topicIDs.contains($0.id) }.count
    }

    /// While the topics load the page says so above the list; the dimmed button only says
    /// "Devam" (audit K3: a disabled button is too faint to carry a status).
    private var primaryTitle: String {
        switch page {
        case .level, .daily, .known, .widget:
            return "Devam"
        case .topics:
            if model.contentSource == .loading {
                return "Devam"
            }
            return chosenTopicCount == 0 ? "Tüm konularla devam" : "\(chosenTopicCount) konuyla devam"
        case .firstWord:
            return "Başla"
        }
    }

    // MARK: Pages

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case .level:
            levelPage
        case .topics:
            topicsPage
        case .daily:
            dailyPage
        case .known:
            knownPage
        case .widget:
            widgetPage
        case .firstWord:
            firstWordPage
        }
    }

    private var levelPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageTitle(
                title: "İngilizcen hangi seviyede?",
                subtitle: "Yeni kelimeler bu seviyeden başlar. Sonra Ayarlar'dan değiştirebilirsin.",
                focus: $isTitleFocused
            )
            VStack(spacing: 8) {
                ForEach(AppPreferences.startLevelChoices, id: \.self) { choice in
                    ChoiceRow(isSelected: level == choice) {
                        level = choice
                    } label: {
                        LevelOptionLabel(level: choice, wordCount: wordCount(at: choice))
                    }
                    .accessibilityIdentifier("onboarding.level.\(choice.rawValue)")
                }
            }
            // is5-seviye: "Seviyeni bilmiyor musun?" (PlacementTestView.swift) picks the level here.
            PlacementTestButton { level = $0 }
        }
    }

    private var dailyPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageTitle(
                title: "Günde kaç yeni kelime?",
                subtitle: "Sana uygun bir başlangıç seç. Sonra Ayarlar'dan değiştirebilirsin.",
                focus: $isTitleFocused
            )
            VStack(spacing: 8) {
                ForEach(AppPreferences.dailyNewWordChoices, id: \.self) { count in
                    ChoiceRow(isSelected: dailyGoal == count) {
                        // Tapping even the already selected default is an explicit choice.
                        explicitDailyChoice = count
                        showsSaveError = false
                    } label: {
                        Text("\(count) yeni kelime")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityIdentifier("onboarding.daily.\(count)")
                }
            }
            Text("Tekrarlarla birlikte günde en az \(SettingsRules.minimumMinutesPerDay(dailyNewWords: dailyGoal)) dakika ayır.")
                .font(.callout)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
            if explicitDailyChoice == nil {
                Text("Bu sayı seviyene göre seçildi: A1 ve A2 için 5, B1 için 10.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }
        }
    }

    private var knownPage: some View {
        let words = knownSession?.words ?? []
        return VStack(alignment: .leading, spacing: 12) {
            PageTitle(
                title: "Bildiğin kelimeler var mı?",
                subtitle: "İstersen anlamını bildiklerini seç. Emin olmadıklarını boş bırakabilirsin.",
                focus: $isTitleFocused
            )
            if model.contentSource == .loading {
                ProgressView("Kelimeler hazırlanıyor…")
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else if words.isEmpty {
                Text(model.onboardingChoiceError == nil
                     ? "Bu seçimde eleyebileceğin yeni kelime kalmadı. Devam edebilirsin."
                     : "Kelime seçimi şu an hazırlanamadı. Seçmeden devam edebilirsin.")
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Başlangıç için \(words.count) kelimeye göz at.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                VStack(spacing: 8) {
                    ForEach(words) { word in
                        ChoiceRow(isSelected: selectedKnownIDs.contains(word.id)) {
                            if selectedKnownIDs.contains(word.id) {
                                selectedKnownIDs.remove(word.id)
                            } else {
                                selectedKnownIDs.insert(word.id)
                            }
                            showsSaveError = false
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(verbatim: word.lemma)
                                    .font(.system(.body, design: .serif).weight(.semibold))
                                    .foregroundStyle(Theme.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .cardEnglishVoice()
                                if let gloss = word.glossTR, !gloss.isEmpty {
                                    Text(verbatim: gloss)
                                        .font(.callout)
                                        .foregroundStyle(Theme.ink2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .accessibilityIdentifier("onboarding.known.\(word.id)")
                    }
                }
                Text("\(selectedKnownIDs.count) kelime seçili. Hiç seçmeden de devam edebilirsin.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                Text("Yeni işaretlediğin kelimeleri üç gün sonra bir kez sorarız.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }
        }
    }

    @ViewBuilder
    private var topicsPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageTitle(
                title: "Hangi konular ilgini çekiyor?",
                subtitle: "İstediğin kadar seç. Hiç seçmezsen hepsi gelir.",
                focus: $isTitleFocused
            )
            if model.contentSource == .loading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Konular hazırlanıyor…")
                        .font(.body)
                        .foregroundStyle(Theme.ink2)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .accessibilityElement(children: .combine)
            } else if model.choosableTopics.isEmpty {
                // The same words as "Ayarlar"'s topic list.
                Text("Konu listesi yüklenemedi. Şimdilik bütün kelimeler gelir.")
                    .font(.body)
                    .foregroundStyle(Theme.ink)
            } else {
                if dynamicTypeSize.isAccessibilitySize {
                    topicSummary
                        .padding(.horizontal, 4)
                }
                TopicChoiceList(
                    topics: model.choosableTopics,
                    totalWordCount: model.words.count,
                    selection: $topicIDs
                )
            }
        }
    }

    private var widgetPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageTitle(
                title: "Widget'ı ekle",
                subtitle: "Kelimeler kilitli ekranında kendiliğinden değişir. Uygulamayı açman gerekmez.",
                focus: $isTitleFocused
            )
            // The drawn widget shows the first word of the level and topics just chosen (§2.8).
            WidgetGuideContent(word: model.firstDeckWord())
            // No ">" path: VoiceOver may read it as "büyüktür" (terimler §1).
            Text("Bu rehber Ayarlar'da da var: Yardım bölümünde.")
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
        }
    }

    /// The last page is interactive (§2.8, "Teach through interactivity"): the word and
    /// "Dinle" first, the meaning one tap away; then the whole card and how learning goes on.
    @ViewBuilder
    private var firstWordPage: some View {
        let word = model.firstDeckWord()
        let isMeaningShown = word != nil && word?.id == shownMeaningWordID
        VStack(alignment: .leading, spacing: 4) {
            PageTitle(
                title: "İlk kelimen",
                subtitle: isMeaningShown
                    ? "Kelimeyi önce widget'ta görürsün. Sonra Tekrar'da hatırlamaya çalışırsın."
                    : "Anlamını tahmin et, sonra dokun.",
                focus: $isTitleFocused
            )
            if let word = word {
                // No "Söyle" button here: the onboarding never asks for the microphone.
                if isMeaningShown {
                    WordCardView(word: word, detail: model.detail(for: word), showsSay: false)
                        .padding(.horizontal, -16)
                        .transition(.opacity)
                } else {
                    GuessWordCard(word: word) {
                        showMeaning(of: word)
                    }
                    .transition(.opacity)
                }
            } else if model.contentSource == .loading {
                Text("Kelimeler yükleniyor…")
                    .font(.body)
                    .foregroundStyle(Theme.ink2)
            } else {
                // The old "Tanılama" section is the "Widget sağlığı" row of Ayarlar now.
                Text("Kelimeler yüklenemedi. Uygulamayı kapatıp yeniden aç. Sorun sürerse Ayarlar'da Widget sağlığı ekranına bak.")
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Actions

    private func loadChoice() {
        if hasLoadedChoice {
            return
        }
        hasLoadedChoice = true
        level = model.deckChoice.startLevel
        topicIDs = model.deckChoice.topicIDs
        explicitDailyChoice = AppPreferences.chosenDailyNewWords
    }

    private func wordCount(at level: Level) -> Int {
        return model.words.filter { $0.levelValue == level }.count
    }

    /// VoiceOver moves to the new page's title once the page has changed; without it the focus
    /// would stay on "Devam", and a second double tap would skip a page unread.
    private func go(to target: Page) {
        if target == .known && knownSession == nil {
            let session = model.onboardingKnownSession(for: draftChoice)
            knownSession = session
            selectedKnownIDs = session.selectedIDs
        }
        page = target
        showsSaveError = false
        // From false, so the change is seen even when the old title still had the focus.
        isTitleFocused = false
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 100 : 350))
            isTitleFocused = true
        }
    }

    private func advance() {
        guard !isSaving else { return }
        switch page {
        case .level:
            go(to: .topics)
        case .topics:
            go(to: .daily)
        case .daily:
            go(to: .known)
        case .known:
            if applyChoice() {
                go(to: .widget)
            }
        case .widget:
            go(to: .firstWord)
        case .firstWord:
            finish()
        }
    }

    /// The button goes away with the hidden card, so VoiceOver also says the meaning that came
    /// out (a high-priority announcement is not cut off by the focus moving on).
    private func showMeaning(of word: WidgetWord) {
        if reduceMotion {
            shownMeaningWordID = word.id
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                shownMeaningWordID = word.id
            }
        }
        if let gloss = word.glossTR {
            var announcement = AttributedString("Türkçesi: " + gloss)
            announcement.accessibilitySpeechAnnouncementPriority = .high
            AccessibilityNotification.Announcement(announcement).post()
        }
    }

    private var draftChoice: DeckChoice {
        return DeckChoice(topicIDs: topicIDs, startLevel: level)
    }

    private var scopedKnownSelection: Set<Int>? {
        guard let session = knownSession else { return nil }
        // An unavailable/empty optional sample has nothing to apply. A nonempty sample still
        // sends [] when all boxes are cleared, so the model can restore its earlier claims.
        return session.candidateIDs.isEmpty && selectedKnownIDs.isEmpty ? nil : selectedKnownIDs
    }

    private func invalidateKnownSession() {
        knownSession = nil
        selectedKnownIDs = []
        shownMeaningWordID = nil
        showsSaveError = false
        hasAppliedChoices = false
    }

    /// The stable session also lets the model conditionally restore a claim when someone goes
    /// back from the widget guide and deselects it. Other sessions' selections are left alone.
    private func applyChoice() -> Bool {
        guard !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }
        let saved = model.applyOnboardingChoices(
            choice: draftChoice,
            explicitDailyChoice: explicitDailyChoice,
            knownSelection: scopedKnownSelection,
            session: knownSession
        )
        showsSaveError = !saved
        if saved {
            hasAppliedChoices = true
        } else {
            AccessibilityNotification.Announcement(AttributedString(model.onboardingChoiceError ?? "Seçimlerin kaydedilemedi. Tekrar dene.")).post()
        }
        return saved
    }

    private func finish() {
        guard applyChoice() else { return }
        model.finishOnboarding()
    }
}

/// Mockup `.ob-title` / `.ob-sub`: a large SF Pro title (no rounded design, README point 3) over
/// a calm `ink2` sentence. The title stops growing at the first accessibility size (as large
/// titles in navigation bars do), so its words still fit a line on an iPhone SE; the sentence
/// keeps growing.
private struct PageTitle: View {
    let title: String
    let subtitle: String
    /// Where VoiceOver goes when the page changes.
    let focus: AccessibilityFocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused(focus)
            Text(verbatim: subtitle)
                .font(.body)
                .foregroundStyle(Theme.ink2)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
        .padding(.bottom, 6)
    }
}

/// The first word with its meaning hidden (§2.8): the word as on the card (the same headline,
/// serif with the band under it) and "Dinle", then one button that turns it into the whole card.
/// Same corners, padding and place as `WordCardView`, so nothing jumps when the meaning appears.
/// "Başla" works either way.
private struct GuessWordCard: View {
    let word: WidgetWord
    let showMeaning: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headline
            CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle")
            Button(action: showMeaning) {
                Label("Anlamını göster", systemImage: "eye")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
            .accessibilityIdentifier("onboarding.reveal")
        }
        .padding(.top, 18)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
        .tint(Theme.ink)
        .padding(.vertical, 16)
    }

    /// The card's own headline (`WordCardHeadline`, FeedView.swift): the theme's word style at
    /// the Large Title size (34 pt, scaled with Dynamic Type), a long phrase in two balanced
    /// lines, each on its band. A heading with the English voice.
    private var headline: some View {
        WordCardHeadline(lemma: word.lemma)
    }
}

/// "A2 ●●○  Temel konuşabiliyorum" with what the level covers and how many words it has.
/// Mockup `.lvc`: the code over its dots (rule 4: never color alone), ink on, a 1 pt `ink3` ring
/// off (as `LevelBadge`; a `surface3` dot was under 3:1, audit K2).
/// At the largest text sizes the code stands above the text, which then keeps the row's width.
private struct LevelOptionLabel: View {
    let level: Level
    let wordCount: Int
    @ScaledMetric(relativeTo: .body) private var dotSize: CGFloat = 5
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 12))
        layout {
            VStack(spacing: 4) {
                Text(verbatim: level.rawValue)
                    .font(.body.weight(.bold))
                    .foregroundStyle(Theme.ink)
                HStack(spacing: 3) {
                    ForEach(1...3, id: \.self) { dot in
                        if dot <= level.rank {
                            Circle()
                                .fill(Theme.ink)
                                .frame(width: dotSize, height: dotSize)
                        } else {
                            Circle()
                                .strokeBorder(Theme.ink3, lineWidth: 1)
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                }
            }
            .frame(minWidth: 44)
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(verbatim: detail)
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(verbatim: "\(level.rawValue), \(title). \(detail)"))
    }

    private var title: String {
        switch level {
        case .a1: return "Yeni başlıyorum"
        case .a2: return "Temel konuşabiliyorum"
        case .b1: return "Günlük konuşmayı anlıyorum"
        default: return level.rawValue
        }
    }

    private var detail: String {
        let topics: String
        switch level {
        case .a1: topics = "Ev, yemek, aile gibi en temel kelimeler."
        case .a2: topics = "Alışveriş, yol, randevu: günlük hayat."
        case .b1: topics = "İş, seyahat, duygular; daha uzun cümleler."
        default: topics = ""
        }
        return wordCount > 0 ? "\(topics) \(wordCount) kelime." : topics
    }
}
