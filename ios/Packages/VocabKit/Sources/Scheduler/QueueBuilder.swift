import CoreModels

/// Builds the queue the app hands to the widget through `widget_plan.json`.
public enum QueueBuilder {
    /// - Parameters:
    ///   - feed: Candidate words in preferred order (for now: the free cards).
    ///   - knownIDs: Words the user already knows; never queued.
    ///   - startAt: Id of the word the widget shows right now. The queue starts there (that word
    ///     first) and wraps around the feed, so a plan rewrite does not change the visible word.
    ///     If that word is in the feed but now known, the queue starts right after it. If it is
    ///     not in the feed (or nil), the feed order is used as is.
    ///   - limit: Maximum queue length.
    public static func build(
        feed: [WidgetWord],
        excluding knownIDs: Set<Int>,
        startAt: Int?,
        limit: Int
    ) -> [WidgetWord] {
        guard limit > 0 else {
            return []
        }
        var ordered = feed
        if let startID = startAt,
           let index = feed.firstIndex(where: { $0.id == startID }) {
            let pivot = knownIDs.contains(startID) ? index + 1 : index
            ordered = Array(feed[pivot...]) + Array(feed[..<pivot])
        }
        var result: [WidgetWord] = []
        for word in ordered where !knownIDs.contains(word.id) {
            result.append(word)
            if result.count == limit {
                break
            }
        }
        return result
    }
}
