import Foundation
import CoreModels

/// Composes the widget queue from the curriculum and the user's progress (architecture report 3.2,
/// `docs/tasarim/ogrenme_ilkeleri.md` 2.1 "Ne zaman, ne sıklıkla").
///
/// **The widget never gives an answer before "Tekrar" asks for it.** A word "Tekrar" will ask
/// within `hiddenBeforeDue` (a learning word whose review, or a known word whose refresher, is due
/// by then, overdue ones included) is left out until it is answered. A word answered today may
/// show again as reinforcement, even when it comes back soon (a wrong answer brings it back in
/// `Leitner.relearnDelay`).
///
/// **Slot budget.** Every 10 slots (`pattern`): 3 new words, 5 learning words (answered today
/// first, then the ones due after `hiddenBeforeDue`), 1 refresher and 1 free slot (words missed
/// today first). The order makes every day-long run from the pattern's start match the design
/// note's table (16 waking hours): 30 min → 32 slots: 10 new, 16 learning, 3 refreshers, 3 free;
/// 1 h → 16: 5, 8, 2, 1; 2 h → 8: 2, 4, 1, 1; 4 h → 4: 1, 2, and a refresher or a free slot.
///
/// When a slot's own list is empty, the next list in that slot's preference order is used. When
/// every list is empty, the queue is topped up first with learning words due after the horizon
/// (soonest first), then with new words beyond `maxNew`, so the widget never loops over a
/// handful of words. Known words appear only as refreshers, and not while a "Biliyorum" claim
/// (`knownOverride`) waits for its check. Everything is deterministic.
public enum QueueComposer {
    public enum Slot: Sendable {
        case new
        case learning
        case refresher
        /// Words missed today first, then the other lists.
        case free
    }

    public static let pattern: [Slot] = [.new, .learning, .refresher, .learning, .new, .learning, .free, .learning, .new, .learning]

    /// A word "Tekrar" asks within this time stays off the widget until it is answered.
    public static let hiddenBeforeDue: TimeInterval = 6 * 3600

    /// Waking hours the slot table assumes.
    public static let wakingHours: TimeInterval = 16 * 3600

    /// Widget slots in a waking day for a rotation interval: 30 min → 32, 1 h → 16, 2 h → 8, 4 h → 4.
    public static func slotsPerDay(rotation: TimeInterval) -> Int {
        guard rotation >= 1, rotation.isFinite else {
            return 0
        }
        return Int((wakingHours / rotation).rounded(.down))
    }

    /// - Parameters:
    ///   - feed: Allowed words in curriculum order (level, topic and access already filtered).
    ///   - progress: The user's progress by word id. Missing ids are new words.
    ///   - now: Evaluation time.
    ///   - horizon: Learning words and refreshers due before `now + horizon` (and after
    ///     `hiddenBeforeDue`) fill their own slots; learning words due later are top-ups.
    ///   - maxNew: Cap on new words in the regular new-word slots (the daily goal over the horizon).
    ///   - limit: Maximum queue length.
    ///   - pinFirst: The word on screen right now; it stays first so a plan rewrite keeps it visible.
    ///     Ignored if that word is known. It is kept even when it is due soon: it is already on
    ///     screen, and it is gone at the next boundary.
    ///   - calendar: Where "today" starts (words answered today may show as reinforcement).
    ///   - patternOffset: Index in `pattern` of the first slot after the pinned word. 0 starts every
    ///     plan at the pattern's start; passing the rotation's boundary count keeps the budget across
    ///     plan rewrites.
    public static func compose(
        feed: [WidgetWord],
        progress: [Int: WordProgress],
        now: Date,
        horizon: TimeInterval,
        maxNew: Int,
        limit: Int,
        pinFirst: WidgetWord? = nil,
        calendar: Calendar = .current,
        patternOffset: Int = 0
    ) -> [WidgetWord] {
        guard limit > 0 else {
            return []
        }
        let hideUntil = now.addingTimeInterval(hiddenBeforeDue)
        let deadline = now.addingTimeInterval(max(horizon, 0))
        let startOfToday = calendar.startOfDay(for: now)

        var result: [WidgetWord] = []
        var used = Set<Int>()
        if let pinned = pinFirst, progress[pinned.id]?.state != .known {
            result.append(pinned)
            used.insert(pinned.id)
        }

        typealias Entry = (word: WidgetWord, at: Date, order: Int)
        var answered: [Entry] = []
        var missed: [Entry] = []
        var upcoming: [Entry] = []
        var refreshers: [Entry] = []
        var notYetDue: [Entry] = []
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
                if let answer = lastAnswer(of: p), answer.at >= startOfToday, answer.at <= now {
                    if answer.missed {
                        missed.append((word, answer.at, order))
                    } else {
                        answered.append((word, answer.at, order))
                    }
                    continue
                }
                // Never answered by `Leitner.review` with a due date: "Tekrar" never asks it either.
                let due = p.dueAt ?? .distantFuture
                if due <= hideUntil {
                    continue
                } else if due <= deadline {
                    upcoming.append((word, due, order))
                } else {
                    notYetDue.append((word, due, order))
                }
            case .known:
                // A word marked "Biliyorum" leaves the widget until its one check in "Tekrar"
                // has proven it (ogrenme_ilkeleri 2.2).
                if !p.knownOverride, let due = p.dueAt, due > hideUntil, due <= deadline {
                    refreshers.append((word, due, order))
                }
            }
        }

        let byDate: (Entry, Entry) -> Bool = { a, b in
            if a.at != b.at {
                return a.at < b.at
            }
            return a.order < b.order
        }
        var answeredList = answered.sorted(by: byDate).map { $0.word }
        var missedList = missed.sorted(by: byDate).map { $0.word }
        var upcomingList = upcoming.sorted(by: byDate).map { $0.word }
        var refresherList = refreshers.sorted(by: byDate).map { $0.word }
        var reinforcementList = notYetDue.sorted(by: byDate).map { $0.word }
        let cap = max(maxNew, 0)
        var newList = Array(newWords.prefix(cap))
        var extraNewList = Array(newWords.dropFirst(cap))

        func takeFirst(_ list: inout [WidgetWord]) -> WidgetWord? {
            if list.isEmpty {
                return nil
            }
            return list.removeFirst()
        }

        // Answered today first. Missed words come after the correct ones, so the free slot
        // still finds one when there are enough correct answers to fill the learning slots.
        func nextLearning() -> WidgetWord? {
            if let w = takeFirst(&answeredList) { return w }
            if let w = takeFirst(&missedList) { return w }
            return takeFirst(&upcomingList)
        }

        func next(for slot: Slot) -> WidgetWord? {
            switch slot {
            case .new:
                if let w = takeFirst(&newList) { return w }
                if let w = nextLearning() { return w }
                if let w = takeFirst(&refresherList) { return w }
            case .learning:
                if let w = nextLearning() { return w }
                if let w = takeFirst(&newList) { return w }
                if let w = takeFirst(&refresherList) { return w }
            case .refresher:
                if let w = takeFirst(&refresherList) { return w }
                if let w = nextLearning() { return w }
                if let w = takeFirst(&newList) { return w }
            case .free:
                if let w = takeFirst(&missedList) { return w }
                if let w = nextLearning() { return w }
                if let w = takeFirst(&newList) { return w }
                if let w = takeFirst(&refresherList) { return w }
            }
            if let w = takeFirst(&reinforcementList) { return w }
            return takeFirst(&extraNewList)
        }

        let start = ((patternOffset % pattern.count) + pattern.count) % pattern.count
        var slotIndex = start
        while result.count < limit {
            guard let word = next(for: pattern[slotIndex % pattern.count]) else {
                break
            }
            result.append(word)
            slotIndex += 1
        }
        return result
    }

    /// When a learning word was last answered, and whether the answer was wrong, read from its
    /// progress: `Leitner.review` sets `lastSeenAt` and `dueAt` from the same instant, so the gap
    /// between them is one of the delays an answer gives in the word's box. A later widget tap
    /// (`Leitner.markExposure`) moves only `lastSeenAt`; the gap then matches nothing and the
    /// answer time is unknown (nil). Unknown counts as "not answered today", which can only
    /// hide a word, never show one early.
    static func lastAnswer(of p: WordProgress) -> (at: Date, missed: Bool)? {
        guard p.state == .learning, p.reviews > 0, let due = p.dueAt, let seen = p.lastSeenAt else {
            return nil
        }
        let gap = due.timeIntervalSince(seen)
        let tolerance: TimeInterval = 1
        if abs(gap - Leitner.relearnDelay) <= tolerance {
            return (seen, true)
        }
        let box = min(max(p.box, 1), Leitner.maxBox)
        let interval = Leitner.intervalDays[box - 1] * day
        for delay in [interval, interval * Leitner.hardFactor] where abs(gap - delay) <= tolerance {
            return (seen, false)
        }
        return nil
    }

    private static let day: TimeInterval = 86_400

    /// `compose` over the user's deck (`DeckFilter.feed`). When the deck has no new word left, new
    /// words come from `fallbackFeed` (every topic) after the deck's own words, the same rule as
    /// "Tekrar" and the reminder (`DeckFilter.newWordFeed`); otherwise a finished deck would rotate
    /// only its few learning words on the widget. When the deck adds no word of its own at all
    /// (every chosen word is known and not due, or due soon in "Tekrar"), the queue comes from
    /// `fallbackFeed` alone, so a topic choice never leaves the widget without words.
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
        pinFirst: WidgetWord? = nil,
        calendar: Calendar = .current,
        patternOffset: Int = 0
    ) -> [WidgetWord] {
        let deckHasNew = DeckFilter.hasNewWords(deck, progress: progress)
        let queue = compose(
            feed: deckHasNew || fallbackFeed.isEmpty ? deck : deck + fallbackFeed,
            progress: progress,
            now: now,
            horizon: horizon,
            maxNew: maxNew,
            limit: limit,
            pinFirst: pinFirst,
            calendar: calendar,
            patternOffset: patternOffset
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
            pinFirst: pinFirst,
            calendar: calendar,
            patternOffset: patternOffset
        )
    }
}
