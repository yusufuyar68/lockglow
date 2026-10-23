import Foundation
import CoreModels
import SharedState
import Scheduler

enum WordDataSource {
    static func makeStore() -> AppGroupStore? {
        guard let url = AppGroupLocator.containerURL() else {
            return nil
        }
        return AppGroupStore(containerURL: url)
    }

    /// Reads the plan and the widget state (two small JSON files) and resolves the rotation
    /// base. Without a usable plan the bundled seed words are used. Never throws, never
    /// touches the network or SQLite.
    static func load(store: AppGroupStore?) -> RotationInput {
        let plan = store?.readPlan()
        let state = store?.readState()
        let hasPlan = !(plan?.queue.isEmpty ?? true)
        let seedWords: [WidgetWord] = hasPlan ? [] : SeedWords.load()
        return RotationInput.resolve(plan: plan, state: state, seedWords: seedWords)
    }
}
