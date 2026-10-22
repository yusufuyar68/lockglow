import SwiftUI
import CoreModels
import Learning

/// First-launch onboarding, four pages and no paywall: level, topics, how to add the widget,
/// the first word. It opens by itself once; "Ayarlar > Yardım" opens it again. "Atla" ends it
/// on any page (the last one too) and keeps what was chosen so far.
///
/// One question and one filled button per page, short sentences for an A2 reader, no pressure.
/// The level also sets the daily goal without a page of its own (§2.8): 5 new words from A1 and
/// A2, 10 from B1, unless the user already chose a number in "Ayarlar". The first word starts
/// with its meaning hidden, so the move of "Tekrar" (guess, then look) is learned by doing it.
///
/// The choice is applied when the topics page is left (and on "Atla"): on a fresh install that
/// writes the first widget plan, so a widget added on the next page already rotates the chosen
/// words (see `AppModel.start`).
struct OnboardingView: View {
    private enum Page: Int, CaseIterable {
        case level
        case topics
        case widget
        case firstWord
    }

    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var page: Page = .level
    @State private var level: Level?
    @State private var topicIDs: Set<String> = []
    @State private var hasLoadedChoice = false
    /// The first word whose meaning was shown; another first word (a new level or topic) starts
    /// hidden again.
    @State private var shownMeaningWordID: Int?

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                pageContent
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .id(page)
            .transition(.opacity)
            bottomBar
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: page)
        .background(Theme.bg.ignoresSafeArea())
        // A full-screen cover starts its own hierarchy: no blue anywhere inside.
        .tint(Theme.ink)
        .onAppear(perform: loadChoice)
    }

    // MARK: Bars

    /// Mockup `.ob-top`: "geri" and "Atla" are control-layer capsules (glass on iOS 26, rule 6);
    /// the step bar between them is ink, never yellow, also at night. The bar stops growing at
    /// the first accessibility text size, so the step bar keeps room between the two capsules
    /// on an iPhone SE.
    private var topBar: some View {
        HStack(spacing: 10) {
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
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .frame(minHeight: 52)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(Page.allCases, id: \.self) { item in
                Capsule()
                    .fill(item.rawValue <= page.rawValue ? Theme.tint : Theme.surface3)
                    .frame(height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Adım \(page.rawValue + 1) / \(Page.allCases.count)")
    }

    /// Mockup `.ob-foot`: on the topics page the deck summary (always there, so the bar does
    /// not jump at the first tap) over the one filled button of the page. At the largest text
    /// sizes the summary leads the list instead and the button stops growing, so the list keeps
    /// most of an iPhone SE screen.
    private var bottomBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showsTopicSummary && !dynamicTypeSize.isAccessibilitySize {
                topicSummary
                    .padding(.horizontal, 4)
            }
            Button(primaryTitle) {
                advance()
            }
            .buttonStyle(GlowButtonStyle())
            .disabled(isNextDisabled)
            .accessibilityIdentifier(page == .firstWord ? "onboarding.start" : "onboarding.next")
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        }
        .padding(.horizontal, 20)
        .padding(.top, showsTopicSummary ? 12 : 8)
        .padding(.bottom, 10)
        .background(Theme.bg)
        // The topic list scrolls under the bar: a hairline, as in "Ayarlar > Konular".
        .overlay(alignment: .top) {
            if showsTopicSummary {
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

    /// The goal the level on screen gives (not saved until the topics page is left).
    private var dailyGoal: Int {
        return AppPreferences.dailyNewWords(startLevel: level)
    }

    /// Topics still loading: leaving the page would apply the choice before there are words,
    /// and no plan would be written ("Atla" still works).
    private var isNextDisabled: Bool {
        switch page {
        case .level:
            return level == nil
        case .topics:
            return model.contentSource == .loading
        case .widget, .firstWord:
            return false
        }
    }

    private var chosenTopicCount: Int {
        return model.choosableTopics.filter { topicIDs.contains($0.id) }.count
    }

    private var primaryTitle: String {
        switch page {
        case .level, .widget:
            return "Devam"
        case .topics:
            if model.contentSource == .loading {
                return "Konular hazırlanıyor…"
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
        case .widget:
            widgetPage
        case .firstWord:
            firstWordPage
        }
    }

    private var levelPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageTitle(
                title: "İngilizcen ne düzeyde?",
                subtitle: "Yeni kelimeler bu seviyeden başlar. Sonra Ayarlar'dan değiştirebilirsin."
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
            // The daily goal comes with the level (§2.8), said once a level is chosen.
            if level != nil {
                Text("Günde **\(dailyGoal)** yeni kelimeyle başlarsın. Bu sayıyı da sonra değiştirebilirsin.")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private var topicsPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageTitle(
                title: "Hangi konular ilgini çekiyor?",
                subtitle: "İstediğin kadar seç. Hiç seçmezsen hepsi gelir."
            )
            if model.contentSource == .loading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else if model.choosableTopics.isEmpty {
                Text("Konu listesi yok. Şimdilik bütün kelimeler gösterilecek.")
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
                subtitle: "Kelimeler kilitli ekranında kendiliğinden değişir. Uygulamayı açman gerekmez."
            )
            WidgetGuideContent()
            Text("Sonra da ekleyebilirsin: Ayarlar > Yardım.")
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
        }
    }

    /// Mockup `.ob` page 4, interactive (§2.8, "Teach through interactivity"): the word and
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
                    : "Anlamını tahmin et, sonra dokun."
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
                Text("Kelimeler yüklenemedi. Uygulamayı kapatıp yeniden aç. Sorun sürerse Ayarlar > Widget sağlığı ekranına bak.")
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
    }

    private func wordCount(at level: Level) -> Int {
        return model.words.filter { $0.levelValue == level }.count
    }

    private func go(to target: Page) {
        page = target
    }

    private func advance() {
        switch page {
        case .level:
            go(to: .topics)
        case .topics:
            applyChoice()
            go(to: .widget)
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

    /// The deck, then the daily goal of the level when the user never chose one: `AppModel` keeps
    /// its own copy of the goal, so it is handed the level's number (`AppPreferences.dailyNewWords`
    /// does not save it as a choice). A goal the user chose stays. Keep the order: the level is
    /// saved first, so the goal's setter compares with the new level's number.
    private func applyChoice() {
        model.setDeckChoice(DeckChoice(topicIDs: topicIDs, startLevel: level))
        model.setDailyNewWords(AppPreferences.dailyNewWords)
    }

    private func finish() {
        applyChoice()
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .accessibilityAddTraits(.isHeader)
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

/// The first word with its meaning hidden (§2.8): the word as on the card (serif, the band under
/// it) and "Dinle", then one button that turns it into the whole card. Same corners, padding and
/// place as `WordCardView`, so nothing jumps when the meaning appears. "Başla" works either way.
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

    /// One line at 40 or 32 pt, as the card's headline; a long phrase wraps at 28 pt instead.
    private var headline: some View {
        ViewThatFits(in: .horizontal) {
            line(size: 40)
            line(size: 32)
            Text(word.lemma)
                .font(Theme.Fonts.englishWord(size: 28))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: word.lemma))
        .accessibilityAddTraits(.isHeader)
        .cardEnglishVoice()
    }

    private func line(size: CGFloat) -> some View {
        Text(word.lemma)
            .englishWordStyle(size: size, maxSize: size * 1.4)
            .phosphorBand()
    }
}

/// "A2 ●●○  Temel konuşabiliyorum" with what the level covers and how many words it has.
/// Mockup `.lvc`: the code over its dots (rule 4: never color alone), ink on, `surface3` off.
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
                        Circle()
                            .fill(dot <= level.rank ? Theme.ink : Theme.surface3)
                            .frame(width: dotSize, height: dotSize)
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
