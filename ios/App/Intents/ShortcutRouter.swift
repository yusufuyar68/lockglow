import CoreSpotlight
import SwiftUI
import UIKit
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
    /// of the intents, the add form and the Spotlight index. A route waits until the words have
    /// loaded and the onboarding is closed, then:
    /// - a word opens as its whole card (`openWord`) once no sheet is up, or in place of the word
    ///   card RootView shows (`wordCardShown`);
    /// - "Tekrar" (`openReview`) opens at once; RootView closes its word card first;
    /// - the add form opens as this modifier's own sheet once no sheet is up.
    /// `otherSheetShown`: another sheet of RootView is up or about to be (a system card, the
    /// widget guide). Sheets of the tabs (a card in Akış, the form in Sözlük) are seen on the
    /// window, since they tell RootView nothing.
    func shortcutRoutes(
        wordCardShown: Bool,
        otherSheetShown: Bool,
        openWord: @escaping (Int) -> Void,
        openReview: @escaping () -> Void
    ) -> some View {
        modifier(ShortcutRoutes(
            wordCardShown: wordCardShown,
            otherSheetShown: otherSheetShown,
            openWord: openWord,
            openReview: openReview
        ))
    }
}

private struct ShortcutRoutes: ViewModifier {
    let wordCardShown: Bool
    let otherSheetShown: Bool
    let openWord: (Int) -> Void
    let openReview: () -> Void

    @EnvironmentObject private var model: AppModel
    @ObservedObject private var router = ShortcutRouter.shared
    @Environment(\.scenePhase) private var scenePhase
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
            // Tried at once, then a few times a second while the route waits: a tab's sheet
            // closing tells RootView nothing.
            .task(id: router.pending) {
                while router.pending != nil && !Task.isCancelled {
                    deliver()
                    try? await Task.sleep(nanoseconds: 300_000_000)
                }
            }
            // A request belongs to the visit it was made in: one still waiting is dropped, so
            // it never pops up hours later.
            .onChange(of: scenePhase) { _, phase in
                if phase == .background {
                    _ = router.take()
                }
            }
            .task(id: model.contentSource) {
                guard model.contentSource != .loading else {
                    return
                }
                await SpotlightIndex.update(with: model.words)
            }
    }

    /// Does the waiting route when nothing is in its way; otherwise the loop above tries again.
    private func deliver() {
        guard let route = router.pending, model.contentSource != .loading, !model.showsOnboarding else {
            return
        }
        let depth = ShortcutRoutes.sheetDepth()
        switch route {
        case .review:
            break
        case .word:
            // Nothing up, or only RootView's word card, which the new word replaces.
            guard !otherSheetShown, router.editor == nil, depth == 0 || (depth == 1 && wordCardShown) else {
                return
            }
        case .addWord:
            guard !otherSheetShown, !wordCardShown, router.editor == nil, depth == 0 else {
                return
            }
        }
        switch router.take() {
        case let .word(id)?:
            openWord(id)
        case .review?:
            openReview()
        case let .addWord(lemma)?:
            router.editor = .add(lemma: lemma)
        case nil:
            break
        }
    }

    /// How many sheets, covers and alerts are stacked on the app's windows now (0: none).
    private static func sheetDepth() -> Int {
        let roots = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .compactMap { $0.rootViewController }
        var deepest = 0
        for root in roots {
            var depth = 0
            var presented = root.presentedViewController
            while let next = presented {
                depth += 1
                presented = next.presentedViewController
            }
            deepest = max(deepest, depth)
        }
        return deepest
    }
}
