import SwiftUI
import CoreModels
import Learning

/// First-launch onboarding, four pages and no paywall: level, topics, how to add the widget,
/// the first word. It opens by itself once; "Ayarlar > Yardım" opens it again. "Atla" ends it
/// on any page and keeps what was chosen so far.
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
    @State private var page: Page = .level
    @State private var level: Level?
    @State private var topicIDs: Set<String> = []
    @State private var hasLoadedChoice = false

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                pageContent
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .id(page)
            .transition(.opacity)
            bottomBar
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: page)
        .background(Palette.background.ignoresSafeArea())
        .onAppear(perform: loadChoice)
    }

    // MARK: Bars

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
                        .font(.title3.weight(.semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .tint(Palette.glowInk)
                .accessibilityLabel("Geri")
            }
            progressBar
            if page == .firstWord {
                Color.clear
                    .frame(width: 60, height: 44)
            } else {
                Button("Atla") {
                    finish()
                }
                .font(.body.weight(.semibold))
                .tint(Palette.glowInk)
                .frame(minWidth: 60, minHeight: 44)
                .accessibilityIdentifier("onboarding.skip")
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(Page.allCases, id: \.self) { item in
                Capsule()
                    .fill(item.rawValue <= page.rawValue ? Palette.glow : Palette.surface2)
                    .frame(height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Adım \(page.rawValue + 1) / \(Page.allCases.count)")
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            if page == .topics && chosenTopicCount > 0 {
                DeckSummaryLine(
                    summary: model.deckSummary(for: topicIDs),
                    dailyGoal: model.dailyNewWords,
                    isEverything: false
                )
            }
            Button(primaryTitle) {
                advance()
            }
            .buttonStyle(GlowButtonStyle())
            .disabled(isNextDisabled)
            .accessibilityIdentifier(page == .firstWord ? "onboarding.start" : "onboarding.next")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
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
                subtitle: "Yeni kelimeler bu seviyeden başlar. Daha kolay kelimeler sona kalır, hiçbiri kaybolmaz."
            )
            ForEach(AppPreferences.startLevelChoices, id: \.self) { choice in
                ChoiceRow(isSelected: level == choice) {
                    level = choice
                } label: {
                    LevelOptionLabel(level: choice, wordCount: wordCount(at: choice))
                }
                .accessibilityIdentifier("onboarding.level.\(choice.rawValue)")
            }
            Text("İstediğin zaman Ayarlar'dan değiştirebilirsin.")
                .font(.footnote)
                .foregroundStyle(Palette.ink2)
        }
    }

    @ViewBuilder
    private var topicsPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageTitle(
                title: "Hangi konuları öğrenmek istersin?",
                subtitle: TopicPickerView.intro
            )
            if model.contentSource == .loading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else if model.choosableTopics.isEmpty {
                Text("Konu listesi yok. Şimdilik bütün kelimeler gösterilecek.")
                    .font(.body)
            } else {
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
                subtitle: "Kelimeler kilitli ekranda ve ana ekranda kendiliğinden değişir. Uygulamayı açmana gerek yok."
            )
            WidgetGuideContent()
            Text("Ekledikten sonra buraya dönebilirsin. Bu rehber Ayarlar > Yardım'da da var.")
                .font(.footnote)
                .foregroundStyle(Palette.ink2)
        }
    }

    @ViewBuilder
    private var firstWordPage: some View {
        VStack(alignment: .leading, spacing: 4) {
            PageTitle(
                title: "İlk kelimen",
                subtitle: "Öğrenmeye bu kelimeyle başlıyorsun. Hoparlöre dokunup dinleyebilirsin."
            )
            if let word = model.firstDeckWord() {
                // No "Söyle" button here: the onboarding never asks for the microphone.
                WordCardView(word: word, detail: model.detail(for: word), showsSay: false)
                    .padding(.horizontal, -16)
            } else if model.contentSource == .loading {
                Text("Kelimeler yükleniyor...")
                    .font(.body)
                    .foregroundStyle(Palette.ink2)
            } else {
                Text("Kelimeler yüklenemedi. Uygulamayı kapatıp yeniden aç. Sorun sürerse Ayarlar > Tanılama'ya bak.")
                    .font(.body)
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

    private func applyChoice() {
        model.setDeckChoice(DeckChoice(topicIDs: topicIDs, startLevel: level))
    }

    private func finish() {
        applyChoice()
        model.finishOnboarding()
    }
}

private struct PageTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: title)
                .font(.largeTitle.weight(.heavy))
                .fontDesign(.rounded)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(verbatim: subtitle)
                .font(.body)
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 8)
    }
}

/// "A2 ●●○  Temel konuşabiliyorum" with what the level covers and how many words it has.
private struct LevelOptionLabel: View {
    let level: Level
    let wordCount: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(spacing: 3) {
                Text(level.rawValue)
                    .font(.headline.weight(.heavy))
                    .fontDesign(.rounded)
                HStack(spacing: 3) {
                    ForEach(1...3, id: \.self) { dot in
                        Circle()
                            .fill(dot <= level.rank ? Palette.glowInk : Palette.surface2)
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .frame(minWidth: 44)
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.primary)
                Text(verbatim: detail)
                    .font(.footnote)
                    .foregroundStyle(Palette.ink2)
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
