import SwiftUI
import WidgetKit

// How a widget shows its next word (docs/tasarim/ogrenme_ilkeleri.md 2.1 and 1, "titreşim ve
// hareket azdır"): on the Home Screen the old word fades out and the new one fades in, in
// 0.35 s, and nothing moves; on the Lock Screen, and anywhere with Reduce Motion, the new word
// simply appears. WidgetKit animates a new timeline entry by itself (a spring, blurred text);
// Apple's way to turn that off is an identity transition and a nil animation ("Animating data
// updates in widgets and Live Activities"): `Transaction` is not available to widgets.

/// The word change of one widget view.
enum WidgetWordChange: Equatable {
    /// The old word fades out and the new one fades in.
    case fade(seconds: Double)
    /// The new word appears at once.
    case still

    /// ogrenme_ilkeleri 2.1: "en çok 0,35 sn".
    static let fadeSeconds = 0.35

    /// No motion on the Lock Screen (the Always-On display does not animate either) nor with
    /// Reduce Motion; a fade on the Home Screen and in StandBy.
    static func of(lockScreen: Bool, reduceMotion: Bool) -> WidgetWordChange {
        return lockScreen || reduceMotion ? .still : .fade(seconds: fadeSeconds)
    }
}

extension View {
    /// Shows the view's next word (`id`, the word's id) as `WidgetWordChange` says. Put it on the
    /// part that changes with the word (the text column), not on the buttons, which stay still.
    func widgetWordChange(id: Int, lockScreen: Bool = false) -> some View {
        modifier(WidgetWordChangeModifier(id: id, lockScreen: lockScreen))
    }
}

private struct WidgetWordChangeModifier: ViewModifier {
    let id: Int
    let lockScreen: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let fades: Bool
        let seconds: Double
        switch WidgetWordChange.of(lockScreen: lockScreen, reduceMotion: reduceMotion) {
        case .fade(let duration):
            fades = true
            seconds = duration
        case .still:
            fades = false
            seconds = 0
        }
        // A new id makes the old column leave and the new one arrive (the transition, with this
        // animation). A text that changes under the same word (only the next change's time, when
        // the queue has one word) gets WidgetKit's own animation with this content transition.
        return content
            .contentTransition(fades ? ContentTransition.opacity : ContentTransition.identity)
            .id(id)
            .transition(fades ? AnyTransition.opacity : AnyTransition.identity)
            .animation(fades ? Animation.easeInOut(duration: seconds) : nil, value: id)
    }
}
