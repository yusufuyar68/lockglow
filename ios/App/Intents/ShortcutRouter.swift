import CoreSpotlight
import SwiftUI
import CoreModels
import Learning

/// What Siri, Kestirmeler or a tapped Spotlight result asked the app to open (`ShortcutRoute`).
/// An intent's `perform()` runs once the app is in front, often before the words have loaded, so
/// the route waits here and RootView's `shortcutRoutes` does it when it can.
@MainActor
final class ShortcutRouter: ObservableObject {
    static let shared = ShortcutRouter()

    /// Asked for and not done yet; a newer request replaces it.
    @Published private(set) var pending: ShortcutRoute?
    /// The "Kendi kelimeni ekle" form a shortcut opened; nil when closed.
    @Published var editor: CustomWordEditor.Mode?

    /// A route waits or its form is open: RootView shows no system card now (`startOpening`).
    var isActive: Bool {
        return pending != nil || editor != nil
    }

    func open(_ route: ShortcutRoute) {
        pending = route
    }

    /// The waiting route, which is forgotten.
    fileprivate func take() -> ShortcutRoute? {
        let route = pending
        pending = nil
        return route
    }
}

extension View {
    /// RootView's side of Siri, Kestirmeler and Spotlight: a tapped Spotlight result, the routes
    /// of the intents, the add form and the Spotlight index. A route is done once the words have
    /// loaded, the onboarding is closed and `canOpen` is true (no sheet of RootView is up):
    /// `openWord` opens a word's whole card, `openReview` the "Tekrar" tab, and the add form is a
    /// sheet of its own here.
    func shortcutRoutes(canOpen: Bool, openWord: @escaping (Int) -> Void, openReview: @escaping () -> Void) -> some View {
        modifier(ShortcutRoutes(canOpen: canOpen, openWord: openWord, openReview: openReview))
    }
}

private struct ShortcutRoutes: ViewModifier {
    let canOpen: Bool
    let openWord: (Int) -> Void
    let openReview: () -> Void

    @EnvironmentObject private var model: AppModel
    @ObservedObject private var router = ShortcutRouter.shared
    /// Counts the words added from a shortcut (the success feedback).
    @State private var addedCount = 0

    func body(content: Content) -> some View {
        content
            .onContinueUserActivity(CSSearchableItemActionType) { activity in
                guard let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                      let wordID = SpotlightCatalog.wordID(fromIdentifier: identifier)
                else {
                    return
                }
                router.open(.word(id: wordID))
            }
            .sheet(item: $router.editor) { mode in
                CustomWordEditor(library: model.customWordLibrary, mode: mode, cardMeaning: model.lookup(lemma:)) { outcome in
                    // The form closes itself; VoiceOver says what "Kendi kelimelerin" says.
                    if case let .added(word) = outcome {
                        addedCount += 1
                        SozlukSpeech.announce([.english(word.lemma), .turkish(" eklendi. Widget'ta ve Tekrar'da karşına çıkacak.")])
                    }
                }
                // A sheet starts its own hierarchy: its controls stay ink (README rule 2).
                .tint(Theme.ink)
            }
            .sensoryFeedback(.success, trigger: addedCount)
            .onAppear(perform: deliver)
            .onChange(of: router.pending) { _, _ in deliver() }
            .onChange(of: router.editor) { _, _ in deliver() }
            .onChange(of: canOpen) { _, _ in deliver() }
            .onChange(of: model.contentSource) { _, _ in deliver() }
            .onChange(of: model.showsOnboarding) { _, _ in deliver() }
            .task(id: model.contentSource) {
                guard model.contentSource != .loading else {
                    return
                }
                await SpotlightIndex.update(with: model.words)
            }
    }

    /// Does the waiting route when nothing is in the way; otherwise one of the changes above
    /// calls this again.
    private func deliver() {
        guard router.pending != nil,
              canOpen,
              router.editor == nil,
              model.contentSource != .loading,
              !model.showsOnboarding,
              let route = router.take()
        else {
            return
        }
        switch route {
        case let .word(id):
            openWord(id)
        case .review:
            openReview()
        case let .addWord(lemma):
            router.editor = .add(lemma: lemma)
        }
    }
}
