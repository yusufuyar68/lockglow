import Foundation
import CoreModels

/// New (cursorOffset, cursorAnchor) pair written to `widget_state.json` after a tap.
public struct RotationCursor: Equatable, Sendable {
    public var offset: Int
    public var anchor: Date

    public init(offset: Int, anchor: Date) {
        self.offset = offset
        self.anchor = anchor
    }
}

extension TimelinePlanner {
    /// "Next" on `shownWordID` at `now`: the rotation continues at the word after it, and the
    /// following change happens at the next interval boundary.
    public static func cursorAfterNext(
        shownWordID: Int,
        input: RotationInput,
        now: Date,
        alignmentOffset: TimeInterval = 0
    ) -> RotationCursor {
        let anchor = roundedDownToWholeSecond(now)
        let count = input.queue.count
        if count == 0 {
            return RotationCursor(offset: input.cursorOffset, anchor: anchor)
        }
        let index = tappedIndex(
            shownWordID: shownWordID,
            input: input,
            now: now,
            alignmentOffset: alignmentOffset
        ) ?? input.cursorOffset
        // The fallback is the stored offset, any integer up to Int.max: wrap it before adding 1.
        return RotationCursor(offset: (positiveModulo(index, count) + 1) % count, anchor: anchor)
    }

    /// "Know" on `shownWordID` at `now`: the cursor moves onto that word. The caller adds the id
    /// to the known set, so the lap starting there skips it and shows the next unknown word.
    public static func cursorAfterKnow(
        shownWordID: Int,
        input: RotationInput,
        now: Date,
        alignmentOffset: TimeInterval = 0
    ) -> RotationCursor {
        let anchor = roundedDownToWholeSecond(now)
        let count = input.queue.count
        if count == 0 {
            return RotationCursor(offset: input.cursorOffset, anchor: anchor)
        }
        let index = tappedIndex(
            shownWordID: shownWordID,
            input: input,
            now: now,
            alignmentOffset: alignmentOffset
        ) ?? input.cursorOffset
        return RotationCursor(offset: positiveModulo(index, count), anchor: anchor)
    }

    /// Queue index of the tapped word. If it is not in the queue (stale widget content), the
    /// index of the word the rotation shows at `now` is used instead.
    private static func tappedIndex(
        shownWordID: Int,
        input: RotationInput,
        now: Date,
        alignmentOffset: TimeInterval
    ) -> Int? {
        if let index = input.queue.firstIndex(where: { $0.id == shownWordID }) {
            return index
        }
        let current = wordAt(
            now,
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            interval: input.interval,
            alignmentOffset: alignmentOffset
        )
        guard let currentWord = current else {
            return nil
        }
        return input.queue.firstIndex(where: { $0.id == currentWord.id })
    }
}
