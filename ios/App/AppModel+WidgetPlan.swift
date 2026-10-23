import Foundation
import CoreModels
import SharedState
import Learning

// The widget plan rewrite (`AppModel.refreshWidgetPlan`) runs off the main thread
// (`WidgetPlanWriter`); this is the copy of the model it works from. Compiled into the Linux check
// of the app's logic too (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// Everything a plan rewrite at `time` reads from the model, copied now: later changes (the
    /// next answer, a new setting) ask for a rewrite of their own.
    func widgetPlanRequest(store: AppGroupStore, usesDatabase: Bool, at time: Date) -> WidgetPlanWriter.Request {
        let input = WidgetPlanBuilder.Input(
            deck: feedWords,
            fallbackFeed: allTopicsFeed,
            progress: progress,
            rotationMinutes: rotationMinutes,
            dailyNewWords: dailyNewWords,
            limit: AppModel.queueLimit,
            horizon: AppModel.queueHorizon,
            // The first word of an id wins, as in `CustomWordLibrary.word(id:)`.
            customWords: Dictionary(
                customWordLibrary.widgetWords.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
        )
        // `detail(for:)` of a user's word, which lives on the main thread (`CustomWordLibrary`).
        var customDetails: [Int: CardDetail] = [:]
        for word in customWordLibrary.widgetWords where customDetails[word.id] == nil {
            customDetails[word.id] = customWordLibrary.word(id: word.id)?.cardDetail
        }
        return WidgetPlanWriter.Request(
            store: store,
            input: input,
            time: time,
            usesDatabase: usesDatabase,
            customDetails: customDetails
        )
    }
}
