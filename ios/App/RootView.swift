import SwiftUI
import CoreModels

struct RootView: View {
    enum AppTab: Hashable {
        case feed
        case review
        case settings
        case health
    }

    @EnvironmentObject private var model: AppModel
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
            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gearshape") }
                .tag(AppTab.settings)
            WidgetHealthView()
                .tabItem { Label("Widget Sağlığı", systemImage: "waveform.path.ecg") }
                .tag(AppTab.health)
        }
        .task {
            await model.start()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                model.sceneDidEnterBackground()
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
