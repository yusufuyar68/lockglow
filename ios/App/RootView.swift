import SwiftUI
import CoreModels
import Learning

struct RootView: View {
    enum AppTab: Hashable {
        case feed
        case review
        case search
        case settings
    }

    @EnvironmentObject private var model: AppModel
    @ObservedObject private var notifications = NotificationRouter.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .feed
    @State private var scrolledWordID: Int?
    /// Deep link received before the words finished loading.
    @State private var pendingWordID: Int?
    /// A widget word that is not in the deck, shown as its full card in a sheet.
    @State private var detailWord: WidgetWord?

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(scrolledWordID: $scrolledWordID)
                .tabItem { Label("Akış", systemImage: "rectangle.stack") }
                .tag(AppTab.feed)
            // "Günlük hedefi değiştir" on the done screen opens Ayarlar.
            ReviewView(openSettings: { selectedTab = .settings })
                .tabItem { Label("Tekrar", systemImage: "arrow.triangle.2.circlepath") }
                .tag(AppTab.review)
            SearchView()
                .tabItem { Label("Sözlük", systemImage: "magnifyingglass") }
                .tag(AppTab.search)
            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gearshape") }
                .badge(model.progressRecovery == nil ? 0 : 1)
                .tag(AppTab.settings)
        }
        // The selected tab is ink, never yellow and never the blue default (README `tint`);
        // the tint also reaches every control below. The iOS 26 tab bar is glass by itself.
        .tint(Theme.tint)
        .task {
            await model.start()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                model.sceneDidEnterBackground()
                // After the widget events were applied: the reminder counts use the latest progress.
                let reminders = model.reminderPlan()
                Task {
                    await ReminderScheduler.replace(with: reminders)
                }
            case .active:
                model.sceneDidBecomeActive()
            default:
                break
            }
        }
        .onChange(of: model.feedWords) { _, newWords in
            applyPendingWord(in: newWords)
        }
        .fullScreenCover(isPresented: onboardingBinding) {
            OnboardingView()
                .environmentObject(model)
        }
        .sheet(item: $detailWord) { word in
            NavigationStack {
                WordDetailView(word: word)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") {
                                detailWord = nil
                            }
                        }
                    }
            }
            // A sheet starts its own hierarchy: "Kapat" and the card's controls stay ink.
            .tint(Theme.ink)
            .environmentObject(model)
        }
        .onOpenURL { url in
            handle(url)
        }
        .onAppear {
            openReviewIfRequested()
        }
        .onChange(of: notifications.reviewRequested) { _, _ in
            openReviewIfRequested()
        }
    }

    /// Shown on first launch and from "Ayarlar"; the onboarding closes itself through the model.
    private var onboardingBinding: Binding<Bool> {
        return Binding(
            get: { model.showsOnboarding },
            set: { isShown in
                if !isShown && model.showsOnboarding {
                    model.finishOnboarding()
                }
            }
        )
    }

    /// A tapped reminder opens "Tekrar".
    private func openReviewIfRequested() {
        guard notifications.reviewRequested else {
            return
        }
        selectedTab = .review
        notifications.reviewRequested = false
    }

    /// `vocabwidget://word/<id>`, opened by tapping a widget. A word of the deck: "Akış" scrolls
    /// to it. A word outside the deck (the one kept on screen right after a topic change, or one
    /// from the every-topic fallback): its card opens in a sheet.
    private func handle(_ url: URL) {
        guard let wordID = DeepLink.wordID(from: url) else {
            return
        }
        if model.contentSource == .loading {
            selectedTab = .feed
            pendingWordID = wordID
        } else {
            open(wordID, in: model.feedWords)
        }
    }

    /// The words arrived: open the pending word, then forget it.
    private func applyPendingWord(in words: [WidgetWord]) {
        guard let wordID = pendingWordID, !words.isEmpty else {
            return
        }
        pendingWordID = nil
        open(wordID, in: words)
    }

    private func open(_ wordID: Int, in feed: [WidgetWord]) {
        if feed.contains(where: { $0.id == wordID }) {
            selectedTab = .feed
            scrolledWordID = wordID
            return
        }
        // Not over the onboarding: two presentations at once do not work.
        guard !model.showsOnboarding, let word = model.word(id: wordID) else {
            selectedTab = .feed
            return
        }
        detailWord = word
    }
}
