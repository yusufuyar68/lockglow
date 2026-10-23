import Foundation
import CoreModels
import SharedState
import Scheduler
import Learning
import TextFold

// Siri, Kestirmeler and Spotlight (ios/App/Intents): what they read from the app's data. An
// intent may run with no screen and no AppModel (the system starts the app in the background for
// it), so the readers are static and read the files themselves. Compiled into the Linux check of
// the app's logic too (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// The most cards a shortcut reads, as `feedLimit` (every card of the content today).
    nonisolated static let shortcutWordLimit = 5000

    /// The word every widget shows now, worked out from the plan and the widget's state on disk
    /// as the widget does (`WordDataSource`, `WordProvider`): the bundled seed words before the
    /// first plan, and every queued word when all of them are marked known (the widget keeps
    /// showing words then). Nil when there is no word at all.
    nonisolated static func widgetWordNow(_ now: Date = Date()) -> WidgetWord? {
        let store = AppGroupLocator.containerURL().map { AppGroupStore(containerURL: $0) }
        let plan = store?.readPlan()
        let hasPlan = !(plan?.queue.isEmpty ?? true)
        let rotation = RotationInput.resolve(
            plan: plan,
            state: store?.readState(),
            seedWords: hasPlan ? [] : SeedWords.load()
        )
        func word(skipping knownIDs: Set<Int>) -> WidgetWord? {
            return TimelinePlanner.wordAt(
                now,
                queue: rotation.queue,
                knownIDs: knownIDs,
                cursorOffset: rotation.cursorOffset,
                cursorAnchor: rotation.cursorAnchor,
                interval: rotation.interval,
                alignmentOffset: TimelinePlanner.localAlignmentOffset(for: now)
            )
        }
        return word(skipping: rotation.knownIDs) ?? word(skipping: [])
    }

    /// Every word a shortcut can name, as the app loads them (`ContentLoader`: content.sqlite,
    /// otherwise the seed words) with the user's own words in front. Blocking: call it off the
    /// main thread.
    nonisolated static func shortcutWords() -> [WidgetWord] {
        let cards = ContentLoader.load(feedLimit: shortcutWordLimit).words
        return DeckFilter.prepending(savedCustomWords(), to: cards)
    }

    /// The user's own words saved on this phone; empty when there are none or the file cannot be
    /// read now (for example on a locked phone). `peek`, never `load`: a damaged file stays where
    /// it is, so the app's own load finds it and shows its notice.
    nonisolated static func savedCustomWords() -> [WidgetWord] {
        guard let url = try? CustomWordStore.defaultURL(),
              let list = CustomWordStore(fileURL: url).peek()
        else {
            return []
        }
        return list.widgetWords
    }

    /// What Spotlight may show (`SpotlightCatalog.entries`): the loaded cards without the user's
    /// own words and without personal-topic cards, with folded keywords ("kahvalti").
    nonisolated static func spotlightEntries(from words: [WidgetWord]) -> [SpotlightCatalog.Entry] {
        return SpotlightCatalog.entries(from: words, fold: TextFold.fold)
    }
}
