import Foundation
import CoreModels

extension TimelinePlanner {
    /// The word the widgets show at `now`: entry 0 of the widget's timeline
    /// (`WordProvider.makeEntries`). Like the widget, it ignores the known set when every queued
    /// word is known, so it is nil only for an empty queue.
    ///
    /// The iOS 18 controls ("Kelimeyi dinle", "Sonraki kelime") use it: a control has no timeline,
    /// so it works out the word on screen when it is tapped.
    public static func shownWord(
        input: RotationInput,
        now: Date,
        alignmentOffset: TimeInterval = 0
    ) -> WidgetWord? {
        let unknown = wordAt(
            now,
            queue: input.queue,
            knownIDs: input.knownIDs,
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            interval: input.interval,
            alignmentOffset: alignmentOffset
        )
        if let word = unknown {
            return word
        }
        // Every queued word is known: the widget keeps showing words rather than a blank widget.
        return wordAt(
            now,
            queue: input.queue,
            knownIDs: [],
            cursorOffset: input.cursorOffset,
            cursorAnchor: input.cursorAnchor,
            interval: input.interval,
            alignmentOffset: alignmentOffset
        )
    }
}
