import Foundation
import CoreModels
import SharedState
import Scheduler

/// The `widget_plan.json` a plan rewrite writes (`AppModel.refreshWidgetPlan`). Pure and built
/// from values only, so the app builds it on a background queue (`WidgetPlanWriter`) and the
/// tests check it on any machine.
///
/// The new queue STARTS AT the word the old plan shows at the rewrite's instant, so the visible
/// word does not change and the rotation carries on from it. "Shows" is computed by the same pure
/// function the widget uses, from the old plan and the widget's state.
public enum WidgetPlanBuilder {
    /// What a rewrite reads from the app, copied when the rewrite is asked for.
    public struct Input: Sendable {
        /// The user's deck (`DeckFilter.feed`): the queue's words come from it first.
        public var deck: [WidgetWord]
        /// Every word in the chosen level order: used when the deck has nothing left to rotate.
        public var fallbackFeed: [WidgetWord]
        public var progress: [Int: WordProgress]
        /// Minutes between word changes, global for every widget (`interval_seconds`).
        public var rotationMinutes: Int
        /// The daily goal of new words; the queue holds at most twice as many (48 h horizon).
        public var dailyNewWords: Int
        public var limit: Int
        public var horizon: TimeInterval
        /// The user's own words as they are now, by id: the word on the widget is pinned with
        /// its edited text, and not at all once it was deleted.
        public var customWords: [Int: WidgetWord]

        public init(
            deck: [WidgetWord],
            fallbackFeed: [WidgetWord],
            progress: [Int: WordProgress],
            rotationMinutes: Int,
            dailyNewWords: Int,
            limit: Int,
            horizon: TimeInterval,
            customWords: [Int: WidgetWord] = [:]
        ) {
            self.deck = deck
            self.fallbackFeed = fallbackFeed
            self.progress = progress
            self.rotationMinutes = rotationMinutes
            self.dailyNewWords = dailyNewWords
            self.limit = limit
            self.horizon = horizon
            self.customWords = customWords
        }
    }

    /// The word the old plan (or the seedless default) shows at `time`, as the widget computes it.
    public static func visibleWord(at time: Date, plan: WidgetPlan?, state: WidgetState?) -> WidgetWord? {
        let rotation = RotationInput.resolve(plan: plan, state: state, seedWords: [])
        return TimelinePlanner.wordAt(
            time,
            queue: rotation.queue,
            knownIDs: rotation.knownIDs,
            cursorOffset: rotation.cursorOffset,
            cursorAnchor: rotation.cursorAnchor,
            interval: rotation.interval,
            alignmentOffset: TimelinePlanner.localAlignmentOffset(for: time)
        )
    }

    /// The word on the widget while the plan is rewritten, as the new plan pins it: a user's word
    /// with its edited text, nil when it was just deleted (it must not stay on the widget until
    /// the next change). Cards stay as they are.
    public static func pinnedWord(_ current: WidgetWord?, customWords: [Int: WidgetWord]) -> WidgetWord? {
        guard let current = current, current.isUserAdded else {
            return current
        }
        return customWords[current.id]
    }

    /// The plan to write at `time`, or nil when no word can be queued (the widget then keeps its
    /// current data or the bundled seed).
    ///
    /// - Parameters:
    ///   - time: The rewrite's instant in whole seconds: it becomes the plan's `updated_at` (the new
    ///     rotation anchor) and is the instant the visible word is read from the old plan.
    ///   - previousPlan: The plan on disk now; `state`: the widget's state on disk now.
    ///   - planDetail: The details of a queued word (`AppModel.detail(for:)`: the card's from
    ///     content.sqlite, a user's word's own); nil for seed words and unreadable cards.
    public static func makePlan(
        _ input: Input,
        at time: Date,
        previousPlan: WidgetPlan?,
        state: WidgetState?,
        planID: String = UUID().uuidString,
        planDetail: (WidgetWord) -> CardDetail?
    ) -> WidgetPlan? {
        let currentWord = visibleWord(at: time, plan: previousPlan, state: state)

        // The deck first; if it has nothing left to rotate, every topic (same level order).
        let queue = QueueComposer.compose(
            deck: input.deck,
            fallbackFeed: input.fallbackFeed,
            progress: input.progress,
            now: time,
            horizon: input.horizon,
            maxNew: input.dailyNewWords * 2,
            limit: input.limit,
            pinFirst: pinnedWord(currentWord, customWords: input.customWords),
            // The slot pattern is tied to the clock (boundaries since 1970), so a rewrite on every
            // trip to the background does not start it again; +1: the slot after the pinned word.
            patternOffset: TimelinePlanner.elapsedBoundaries(
                from: Date(timeIntervalSince1970: 0),
                to: time,
                interval: TimeInterval(input.rotationMinutes * 60),
                alignmentOffset: TimelinePlanner.localAlignmentOffset(for: time)
            ) + 1
        )
        if queue.isEmpty {
            return nil
        }

        // The medium widget's example is the card's shortest example that contains the word
        // (docs/tasarim/README.md "Widget'lar"), not always its first. Only the text changes: the
        // queue and the pinned word stay id-based. Seed words have no detail and keep theirs.
        let planQueue = queue.map { word -> WidgetWord in
            let detail = planDetail(word)
            return withShortestExample(word, detail: detail)
                // is5-w-buyuk: the large widget's second example and warning (CoreModels/WidgetWarning.swift).
                .addingLargeWidgetDetails(from: detail)
        }

        // The interval is global (all widget instances). The app owns it; changing it keeps the
        // visible word, because `currentWord` above was computed with the OLD plan's interval.
        return WidgetPlan(
            planID: planID,
            isPremium: false,
            intervalSeconds: input.rotationMinutes * 60,
            queue: planQueue,
            updatedAt: time
        )
    }

    /// The medium widget's example: the card's shortest example that contains the word, when it
    /// is not already the word's own.
    private static func withShortestExample(_ word: WidgetWord, detail: CardDetail?) -> WidgetWord {
        guard let shortest = detail?.shortestExample(containing: word.lemma),
              shortest != word.exampleEN else {
            return word
        }
        return WidgetWord(
            id: word.id,
            lemma: word.lemma,
            pos: word.pos,
            level: word.level,
            ipaUS: word.ipaUS,
            ipaUK: word.ipaUK, // is5-ses: the widget's IPA follows "Ses ve aksan"
            defMicro: word.defMicro,
            defShort: word.defShort,
            exampleEN: shortest,
            glossTR: word.glossTR,
            glossShortTR: word.glossShortTR,
            sensitivity: word.sensitivity,
            confusableIDs: word.confusableIDs,
            symbol: word.symbol
        )
    }
}
