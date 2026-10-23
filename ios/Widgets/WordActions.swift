import Foundation
import os
import WidgetKit
import CoreModels
import SharedState
import Scheduler

/// Persistence behind the widget buttons. Everything is written synchronously so it is on
/// disk before an intent's `perform()` returns. Errors are logged and swallowed.
///
/// The cursor math lives in `Scheduler` (pure, unit-tested); this type only reads the inputs
/// and writes `widget_state.json` plus one event file.
enum WordActions {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow.widgets",
        category: "actions"
    )

    /// "Next" on the word that was on screen: rotation continues at the word after it.
    static func next(wordID: Int, source: String) {
        guard let store = WordDataSource.makeStore() else {
            logger.error("App Group container unavailable; next not recorded")
            return
        }
        let now = Date()
        let input = WordDataSource.load(store: store)
        let cursor = TimelinePlanner.cursorAfterNext(
            shownWordID: wordID,
            input: input,
            now: now,
            alignmentOffset: TimelinePlanner.localAlignmentOffset(for: now)
        )
        commit(
            store: store,
            input: input,
            cursor: cursor,
            known: input.knownIDs,
            event: makeEvent(.next, wordID: wordID, source: source, at: now)
        )
    }

    /// "Know": the word joins the known set and the widget skips it. The event tells the app,
    /// which asks the word once 3 days later (`ProgressIngest`).
    static func know(wordID: Int, source: String) {
        guard let store = WordDataSource.makeStore() else {
            logger.error("App Group container unavailable; known not recorded")
            return
        }
        let now = Date()
        let input = WordDataSource.load(store: store)
        let cursor = TimelinePlanner.cursorAfterKnow(
            shownWordID: wordID,
            input: input,
            now: now,
            alignmentOffset: TimelinePlanner.localAlignmentOffset(for: now)
        )
        var known = input.knownIDs
        known.insert(wordID)
        commit(
            store: store,
            input: input,
            cursor: cursor,
            known: known,
            event: makeEvent(.known, wordID: wordID, source: source, at: now)
        )
    }

    private static func makeEvent(
        _ type: WidgetEventType,
        wordID: Int,
        source: String,
        at date: Date
    ) -> WidgetEvent {
        let eventSource = WidgetEventSource(rawValue: source) ?? .systemSmall
        return WidgetEvent(type: type, wordID: wordID, at: date, source: eventSource)
    }

    private static func commit(
        store: AppGroupStore,
        input: RotationInput,
        cursor: RotationCursor,
        known: Set<Int>,
        event: WidgetEvent
    ) {
        let state = WidgetState(
            planID: input.planID,
            cursorOffset: cursor.offset,
            cursorAnchor: cursor.anchor,
            knownIDs: known.sorted(),
            updatedAt: Date()
        )
        do {
            try store.writeState(state)
        } catch {
            logger.error("state write failed: \(error.localizedDescription, privacy: .public)")
        }
        do {
            try store.eventMailbox.append(event)
        } catch {
            logger.error("event write failed: \(error.localizedDescription, privacy: .public)")
        }
        // is5-w-quiz: the quiz widget passes over the word shown here; it follows the new cursor.
        WidgetCenter.shared.reloadTimelines(ofKind: LockglowQuizWidget.kind)
    }
}
