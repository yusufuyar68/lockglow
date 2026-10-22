import Foundation
import CoreModels

/// Composes the widget queue from the curriculum and the user's progress (architecture report 3.2).
///
/// Slots follow a fixed 10-slot pattern: 6 reviews, 3 new words, 1 refresher. When a slot's own
/// list is empty, the next list in that slot's preference order is used. When all three are empty,
/// the queue is topped up first with learning words that are not due yet (soonest first), then
/// with new words beyond `maxNew`, so the widget never loops over a handful of words.
/// Known words appear only as due refreshers. Everything is deterministic.
public enum QueueComposer {
    public enum Slot: Sendable {
        case review
        case new
        case refresher
    }

    public static let pattern: [Slot] = [.review, .new, .review, .review, .new, .review, .review, .new, .review, .refresher]

    /// - Parameters:
    ///   - feed: Allowed words in curriculum order (level, topic and access already filtered).
    ///   - progress: The user's progress by word id. Missing ids are new words.
    ///   - now: Evaluation time.
    ///   - horizon: Reviews due before `now + horizon` count as due (the queue covers the next hours).
    ///   - maxNew: Cap on new words in the regular new-word slots (the daily goal over the horizon).
    ///   - limit: Maximum queue length.
    ///   - pinFirst: The word on screen right now; it stays first so a plan rewrite keeps it visible.
    ///     Ignored if that word is known.
    public static func compose(
        feed: [WidgetWord],
        progress: [Int: WordProgress],
        now: Date,
        horizon: TimeInterval,
        maxNew: Int,
        limit: Int,
        pinFirst: WidgetWord? = nil
    ) -> [WidgetWord] {
        guard limit > 0 else {
            return []
        }
        let deadline = now.addingTimeInterval(max(horizon, 0))

        var result: [WidgetWord] = []
        var used = Set<Int>()
        if let pinned = pinFirst, progress[pinned.id]?.state != .known {
            result.append(pinned)
            used.insert(pinned.id)
        }

        var reviews: [(word: WidgetWord, due: Date, order: Int)] = []
        var refreshers: [(word: WidgetWord, due: Date, order: Int)] = []
        var notYetDue: [(word: WidgetWord, due: Date, order: Int)] = []
        var newWords: [WidgetWord] = []
        var seenInFeed = Set<Int>()

        for (order, word) in feed.enumerated() {
            if used.contains(word.id) || seenInFeed.contains(word.id) {
                continue
            }
            seenInFeed.insert(word.id)
            guard let p = progress[word.id] else {
                newWords.append(word)
                continue
            }
            switch p.state {
            case .new:
                newWords.append(word)
            case .learning:
                let due = p.dueAt ?? now
                if due <= deadline {
                    reviews.append((word, due, order))
                } else {
                    notYetDue.append((word, due, order))
                }
            case .known:
                if let due = p.dueAt, due <= deadline {
                    refreshers.append((word, due, order))
                }
            }
        }

        let byDue: ((word: WidgetWord, due: Date, order: Int), (word: WidgetWord, due: Date, order: Int)) -> Bool = { a, b in
            if a.due != b.due {
                return a.due < b.due
            }
            return a.order < b.order
        }
        var reviewList = reviews.sorted(by: byDue).map { $0.word }
        var refresherList = refreshers.sorted(by: byDue).map { $0.word }
        var reinforcementList = notYetDue.sorted(by: byDue).map { $0.word }
        let cap = max(maxNew, 0)
        var newList = Array(newWords.prefix(cap))
        var extraNewList = Array(newWords.dropFirst(cap))

        func takeFirst(_ list: inout [WidgetWord]) -> WidgetWord? {
            if list.isEmpty {
                return nil
            }
            return list.removeFirst()
        }

        func next(for slot: Slot) -> WidgetWord? {
            switch slot {
            case .review:
                if let w = takeFirst(&reviewList) { return w }
                if let w = takeFirst(&newList) { return w }
                if let w = takeFirst(&refresherList) { return w }
            case .new:
                if let w = takeFirst(&newList) { return w }
                if let w = takeFirst(&reviewList) { return w }
                if let w = takeFirst(&refresherList) { return w }
            case .refresher:
                if let w = takeFirst(&refresherList) { return w }
                if let w = takeFirst(&reviewList) { return w }
                if let w = takeFirst(&newList) { return w }
            }
            if let w = takeFirst(&reinforcementList) { return w }
            return takeFirst(&extraNewList)
        }

        var slotIndex = 0
        while result.count < limit {
            guard let word = next(for: pattern[slotIndex % pattern.count]) else {
                break
            }
            result.append(word)
            slotIndex += 1
        }
        return result
    }

    /// `compose` over the user's deck (`DeckFilter.feed`). When the deck has no new word left, new
    /// words come from `fallbackFeed` (every topic) after the deck's own words, the same rule as
    /// "Tekrar" and the reminder (`DeckFilter.newWordFeed`); otherwise a finished deck would rotate
    /// only its few learning words on the widget. When the deck adds no word of its own at all
    /// (every chosen word is known and not due), the queue comes from `fallbackFeed` alone, so a
    /// topic choice never leaves the widget without words.
    ///
    /// `pinFirst` stays first either way, even when it is outside the deck: changing the topics
    /// rewrites the plan like any setting, and the word on screen must not change. The deck's
    /// words follow from the next boundary on.
    public static func compose(
        deck: [WidgetWord],
        fallbackFeed: [WidgetWord],
        progress: [Int: WordProgress],
        now: Date,
        horizon: TimeInterval,
        maxNew: Int,
        limit: Int,
        pinFirst: WidgetWord? = nil
    ) -> [WidgetWord] {
        let deckHasNew = DeckFilter.hasNewWords(deck, progress: progress)
        let queue = compose(
            feed: deckHasNew || fallbackFeed.isEmpty ? deck : deck + fallbackFeed,
            progress: progress,
            now: now,
            horizon: horizon,
            maxNew: maxNew,
            limit: limit,
            pinFirst: pinFirst
        )
        // The same condition `compose(feed:...)` uses for the pin.
        let isPinned = pinFirst.map { progress[$0.id]?.state != .known } ?? false
        let deckWordCount = queue.count - (isPinned && !queue.isEmpty ? 1 : 0)
        if deckWordCount > 0 || fallbackFeed.isEmpty {
            return queue
        }
        return compose(
            feed: fallbackFeed,
            progress: progress,
            now: now,
            horizon: horizon,
            maxNew: maxNew,
            limit: limit,
            pinFirst: pinFirst
        )
    }
}
