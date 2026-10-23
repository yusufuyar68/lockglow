import ActivityKit
import SwiftUI
import WidgetKit

/// The "Tekrar" round's Live Activity: the Lock Screen (also the banner and StandBy) and the
/// Dynamic Island. The app starts, updates and ends it (App/ReviewLiveActivity.swift); its views
/// are in LiveActivityViews.swift. Every tap opens "Tekrar", where the round waits
/// (`ReviewActivityAttributes.continueURL`). Registered in LockglowWidgetsBundle.
struct ReviewLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReviewActivityAttributes.self) { context in
            ReviewActivityLockScreenView(state: context.state, isStale: context.isStale)
                // The app's page: paper by day, black at night (OLED pixels off).
                .activityBackgroundTint(Theme.bg)
                .activitySystemActionForegroundColor(Theme.ink)
                .widgetURL(ReviewActivityAttributes.continueURL)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ReviewActivityIslandTitle()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ReviewActivityIslandCounter(state: context.state, isStale: context.isStale)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ReviewActivityIslandBottom(isStale: context.isStale)
                }
            } compactLeading: {
                ReviewActivityIslandSymbol()
            } compactTrailing: {
                ReviewActivityIslandCounter(state: context.state, isStale: context.isStale, short: true)
            } minimal: {
                // Calm: the mark, not a counter.
                ReviewActivityIslandSymbol()
            }
            .widgetURL(ReviewActivityAttributes.continueURL)
        }
    }
}

#Preview("Kilitli ekran", as: .content, using: ReviewActivityAttributes()) {
    ReviewLiveActivityWidget()
} contentStates: {
    ReviewActivityAttributes.ContentState(card: 4, total: 10)
    ReviewActivityAttributes.ContentState(card: 11, total: 12)
}

#Preview("Ada, geniş", as: .dynamicIsland(.expanded), using: ReviewActivityAttributes()) {
    ReviewLiveActivityWidget()
} contentStates: {
    ReviewActivityAttributes.ContentState(card: 4, total: 10)
}

#Preview("Ada, kompakt", as: .dynamicIsland(.compact), using: ReviewActivityAttributes()) {
    ReviewLiveActivityWidget()
} contentStates: {
    ReviewActivityAttributes.ContentState(card: 4, total: 10)
}

#Preview("Ada, en küçük", as: .dynamicIsland(.minimal), using: ReviewActivityAttributes()) {
    ReviewLiveActivityWidget()
} contentStates: {
    ReviewActivityAttributes.ContentState(card: 4, total: 10)
}
