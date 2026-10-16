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

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(scrolledWordID: $scrolledWordID)
                .tabItem { Label("Akış", systemImage: "rectangle.stack") }
                .tag(AppTab.feed)
            ReviewView()
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
        .onChange(of: model.words) { _, newWords in
            applyPendingWord(in: newWords)
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

    /// A tapped reminder opens "Tekrar".
    private func openReviewIfRequested() {
        guard notifications.reviewRequested else {
            return
        }
        selectedTab = .review
        notifications.reviewRequested = false
    }

    /// `vocabwidget://word/<id>`, opened by tapping a widget.
    private func handle(_ url: URL) {
        guard let wordID = DeepLink.wordID(from: url) else {
            return
        }
        selectedTab = .feed
        if model.words.contains(where: { $0.id == wordID }) {
            scrolledWordID = wordID
        } else {
            pendingWordID = wordID
        }
    }

    private func applyPendingWord(in words: [WidgetWord]) {
        guard let wordID = pendingWordID,
              words.contains(where: { $0.id == wordID })
        else {
            return
        }
        scrolledWordID = wordID
        pendingWordID = nil
    }
}
