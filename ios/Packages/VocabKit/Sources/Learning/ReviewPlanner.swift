import Foundation
import CoreModels

/// Word counts shown on the settings screen.
public struct ProgressCounts: Equatable, Sendable {
    public var known: Int
    public var learning: Int
    public var dueToday: Int

    public init(known: Int = 0, learning: Int = 0, dueToday: Int = 0) {
        self.known = known
        self.learning = learning
        self.dueToday = dueToday
    }
}

/// Picks the words for a flashcard round and counts progress. Pure and deterministic; all
/// functions only look at words that are in `feed` (each id once, first occurrence wins).
public enum ReviewPlanner {
    /// Words whose review is due at `now`, most overdue first (ties keep feed order).
    /// Includes known words whose refresher is due.
    public static func dueWords(
        feed: [WidgetWord],
        progress: [Int: WordProgress],
        now: Date,
        limit: Int
    ) -> [WidgetWord] {
        guard limit > 0 else {
            return []
        }
        var due: [(word: WidgetWord, at: Date, order: Int)] = []
        var seen = Set<Int>()
        for (order, word) in feed.enumerated() {
            if !seen.insert(word.id).inserted {
                continue
            }
            guard let p = progress[word.id], let dueAt = p.dueAt, p.isDue(at: now) else {
                continue
            }
            due.append((word, dueAt, order))
        }
        due.sort { a, b in
            if a.at != b.at {
                return a.at < b.at
            }
            return a.order < b.order
        }
        return due.prefix(limit).map { $0.word }
    }

    /// The first `limit` words in feed order that were never reviewed (a word that was only
    /// seen on the widget is still new).
    public static func newWords(
        feed: [WidgetWord],
        progress: [Int: WordProgress],
        limit: Int
    ) -> [WidgetWord] {
        guard limit > 0 else {
            return []
        }
        var result: [WidgetWord] = []
        var seen = Set<Int>()
        for word in feed {
            if !seen.insert(word.id).inserted {
                continue
            }
            let state = progress[word.id]?.state ?? .new
            if state == .new {
                result.append(word)
                if result.count == limit {
                    break
                }
            }
        }
        return result
    }

    /// `dueToday` counts reviews and refreshers due at or before `dueBy` (pass the end of the local day).
    public static func counts(
        feed: [WidgetWord],
        progress: [Int: WordProgress],
        dueBy: Date
    ) -> ProgressCounts {
        var counts = ProgressCounts()
        var seen = Set<Int>()
        for word in feed {
            if !seen.insert(word.id).inserted {
                continue
            }
            guard let p = progress[word.id] else {
                continue
            }
            switch p.state {
            case .known:
                counts.known += 1
            case .learning:
                counts.learning += 1
            case .new:
                break
            }
            if p.isDue(at: dueBy) {
                counts.dueToday += 1
            }
        }
        return counts
    }
}
