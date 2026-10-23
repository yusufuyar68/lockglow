import Foundation
import CoreModels
import SharedState

/// The Apple Watch's word rotation (is5-watch): the plan the phone sent (`WatchSync`) and the
/// watch's own `widget_state.json`, one word per hour whatever the phone widget's interval. The
/// watch app and its complications both use it, so the app and the watch face show the same word.
/// The same pure functions as the phone widget (`TimelinePlanner`) do the work.
public enum WatchRotation {
    /// The word on the watch face changes every hour, on the hour (local time).
    public static let interval: TimeInterval = 3600
    /// How far ahead the complication timeline reaches.
    public static let horizon: TimeInterval = 48 * 3600

    /// `RotationInput.resolve` with the watch's interval. Without a plan the bundled seed words
    /// rotate, as on the phone widget.
    public static func input(plan: WidgetPlan?, state: WidgetState?, seedWords: [WidgetWord]) -> RotationInput {
        let base = RotationInput.resolve(plan: plan, state: state, seedWords: seedWords)
        return RotationInput(
            planID: base.planID,
            queue: base.queue,
            knownIDs: base.knownIDs,
            cursorOffset: base.cursorOffset,
            cursorAnchor: base.cursorAnchor,
            interval: interval,
            isSeed: base.isSeed
        )
    }

    /// The word shown at `date`. When every queued word is marked known, the rotation goes on
    /// without the known set (as the phone widget does) rather than showing nothing. Nil only for an
    /// empty queue.
    public static func word(at date: Date, input: RotationInput, alignmentOffset: TimeInterval) -> WidgetWord? {
        let current = TimelinePlanner.wordAt(
            date,
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            interval: input.interval,
            alignmentOffset: alignmentOffset
        )
        if let current = current {
            return current
        }
        return TimelinePlanner.wordAt(
            date,
            queue: input.queue,
            knownIDs: [],
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            interval: input.interval,
            alignmentOffset: alignmentOffset
        )
    }

    /// The complication timeline: the word at `now`, then one entry per hour up to `horizon`. Each
    /// entry's word is `word(at:)` for its date. Empty only for an empty queue.
    public static func entries(
        input: RotationInput,
        now: Date,
        alignmentOffset: TimeInterval
    ) -> [TimelinePlanner.PlannedEntry] {
        let planned = TimelinePlanner.plan(
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            now: now,
            interval: input.interval,
            horizon: horizon,
            alignmentOffset: alignmentOffset
        )
        if !planned.isEmpty {
            return planned
        }
        return TimelinePlanner.plan(
            queue: input.queue,
            knownIDs: [],
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            now: now,
            interval: input.interval,
            horizon: horizon,
            alignmentOffset: alignmentOffset
        )
    }

    /// The watch's new state after "Sonraki kelime" on `shownWordID` at `now`: the rotation goes on
    /// at the word after it.
    public static func stateAfterNext(
        shownWordID: Int,
        input: RotationInput,
        now: Date,
        alignmentOffset: TimeInterval
    ) -> WidgetState {
        let cursor = TimelinePlanner.cursorAfterNext(
            shownWordID: shownWordID,
            input: input,
            now: now,
            alignmentOffset: alignmentOffset
        )
        return makeState(input: input, cursor: cursor, knownIDs: input.knownIDs, now: now)
    }

    /// The watch's new state after "Biliyorum" on `shownWordID` at `now`: the word joins the known
    /// set and the rotation shows the next unknown word. When that leaves no unknown word, the
    /// cursor moves past the word as for "Sonraki kelime", so the rotation without the known set
    /// (`word(at:)`) does not show the same word again.
    public static func stateAfterKnow(
        shownWordID: Int,
        input: RotationInput,
        now: Date,
        alignmentOffset: TimeInterval
    ) -> WidgetState {
        var known = input.knownIDs
        known.insert(shownWordID)
        let everyWordKnown = input.queue.allSatisfy { known.contains($0.id) }
        let cursor: RotationCursor
        if everyWordKnown {
            cursor = TimelinePlanner.cursorAfterNext(
                shownWordID: shownWordID,
                input: input,
                now: now,
                alignmentOffset: alignmentOffset
            )
        } else {
            cursor = TimelinePlanner.cursorAfterKnow(
                shownWordID: shownWordID,
                input: input,
                now: now,
                alignmentOffset: alignmentOffset
            )
        }
        return makeState(input: input, cursor: cursor, knownIDs: known, now: now)
    }

    /// The watch's state for a new plan from the phone, keeping the word on screen: the rotation
    /// continues from that word when the new plan has it (as the phone keeps its visible word on a
    /// plan rewrite), so a plan rewrite does not take back a "Sonraki kelime" or jump within the
    /// hour. Nil when the word is not in the new plan (then the rotation starts at the plan's first
    /// word, at `plan.updatedAt`).
    public static func stateKeepingWord(
        from old: RotationInput,
        newPlan: WidgetPlan,
        now: Date,
        alignmentOffset: TimeInterval
    ) -> WidgetState? {
        guard newPlan.planID != old.planID,
              let shown = word(at: now, input: old, alignmentOffset: alignmentOffset),
              let index = newPlan.queue.firstIndex(where: { $0.id == shown.id })
        else {
            return nil
        }
        let cursor = RotationCursor(offset: index, anchor: TimelinePlanner.roundedDownToWholeSecond(now))
        return WidgetState(
            planID: newPlan.planID,
            cursorOffset: cursor.offset,
            cursorAnchor: cursor.anchor,
            knownIDs: [],
            updatedAt: cursor.anchor
        )
    }

    private static func makeState(
        input: RotationInput,
        cursor: RotationCursor,
        knownIDs: Set<Int>,
        now: Date
    ) -> WidgetState {
        return WidgetState(
            planID: input.planID,
            cursorOffset: cursor.offset,
            cursorAnchor: cursor.anchor,
            knownIDs: knownIDs.sorted(),
            updatedAt: TimelinePlanner.roundedDownToWholeSecond(now)
        )
    }
}
