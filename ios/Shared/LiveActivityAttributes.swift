import ActivityKit
import Foundation
import CoreModels

/// The "Tekrar" round's Live Activity (Lock Screen and Dynamic Island). Compiled into the app,
/// which starts, updates and ends it (App/ReviewLiveActivity.swift), and into the widget
/// extension, which draws it (Widgets/LiveActivityWidget.swift, LiveActivityViews.swift).
/// It carries the card counter only, never a word: the Lock Screen would give away the answer of
/// the card on screen, and anyone can see it there.
struct ReviewActivityAttributes: ActivityAttributes {
    /// "Kart 4 / 10".
    struct ContentState: Codable, Hashable {
        /// The card on screen, from 1.
        var card: Int
        /// The round's cards ("Tanış + Hatırla": a second try adds one).
        var total: Int
    }

    /// "Devam et" and every tap on the activity: `vocabwidget://review` opens "Tekrar", where the
    /// round waits (RootView). Same scheme as the widget's word links (`DeepLink`).
    static let continueURL = URL(string: "\(DeepLink.scheme)://review")

    static func isContinueURL(_ url: URL) -> Bool {
        return url.scheme?.lowercased() == DeepLink.scheme && url.host == "review"
    }
}
