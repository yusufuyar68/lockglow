import Foundation
import CoreModels

/// What the user chose to study: the topics that rotate on the widget and in "Akış", and the
/// level new words start from. No topic means every topic; no level keeps the curriculum
/// order (A1 first).
public struct DeckChoice: Equatable, Sendable {
    /// `category.id` values (the categories a card belongs to, `card_category`).
    public var topicIDs: Set<String>
    public var startLevel: Level?

    public init(topicIDs: Set<String> = [], startLevel: Level? = nil) {
        self.topicIDs = topicIDs
        self.startLevel = startLevel
    }
}

/// How many words a topic choice gives, and how many of them were never studied.
public struct DeckSummary: Equatable, Sendable {
    public var wordCount: Int
    public var newCount: Int

    public init(wordCount: Int, newCount: Int) {
        self.wordCount = wordCount
        self.newCount = newCount
    }
}

/// Turns the curriculum (every free card, A1 first) into the user's feed. Pure and deterministic.
///
/// The feed decides which words the widget queue, "Akış" and the new words of "Tekrar" use.
/// Words already being learned keep their reviews whatever the choice: "Tekrar" asks every due
/// word, and the progress counts cover every word.
public enum DeckFilter {
    /// The user's feed: `filtered` by topic, then `ordered` by level.
    public static func feed(_ words: [WidgetWord], topicsOf: [Int: Set<String>], choice: DeckChoice) -> [WidgetWord] {
        return ordered(filtered(words, topicsOf: topicsOf, topicIDs: choice.topicIDs), startingAt: choice.startLevel)
    }

    /// Words in at least one chosen topic (a card can belong to several), each once, in their
    /// original order. Every word when no topic is chosen, and also when the choice matches no
    /// word (topics that left the content, or seed words, which have no topic): a topic choice
    /// never empties the feed.
    public static func filtered(_ words: [WidgetWord], topicsOf: [Int: Set<String>], topicIDs: Set<String>) -> [WidgetWord] {
        if topicIDs.isEmpty {
            return words
        }
        let kept = words.filter { word in
            guard let topics = topicsOf[word.id] else {
                return false
            }
            return !topics.isDisjoint(with: topicIDs)
        }
        return kept.isEmpty ? words : kept
    }

    /// Stable reorder by level: `start` first, then the levels above it (easiest first), then the
    /// levels below it (closest first), then words whose level is unknown. An A2 learner gets A2,
    /// B1, ... and the A1 words last; nothing is dropped. Nil keeps the order as it is.
    public static func ordered(_ words: [WidgetWord], startingAt start: Level?) -> [WidgetWord] {
        guard let start = start else {
            return words
        }
        func band(_ word: WidgetWord) -> Int {
            guard let level = word.levelValue else {
                return Int.max
            }
            if level.rank >= start.rank {
                return level.rank - start.rank
            }
            return 100 + (start.rank - level.rank)
        }
        return words.enumerated().sorted { a, b in
            let left = band(a.element)
            let right = band(b.element)
            return left != right ? left < right : a.offset < b.offset
        }.map { $0.element }
    }

    /// The words "Akış" would get for this choice (`filtered`, so an empty or unmatched choice
    /// counts every word) and how many of them are new. The one count behind every summary line.
    public static func summary(
        _ words: [WidgetWord],
        topicsOf: [Int: Set<String>],
        topicIDs: Set<String>,
        progress: [Int: WordProgress]
    ) -> DeckSummary {
        let deck = filtered(words, topicsOf: topicsOf, topicIDs: topicIDs)
        let newCount = deck.filter { isNew($0, progress: progress) }.count
        return DeckSummary(wordCount: deck.count, newCount: newCount)
    }

    /// True when at least one word of the deck was never studied (the same rule as
    /// `ReviewPlanner.newWords`: a word only seen on the widget is still new).
    public static func hasNewWords(_ deck: [WidgetWord], progress: [Int: WordProgress]) -> Bool {
        return deck.contains { isNew($0, progress: progress) }
    }

    /// Where new words come from in "Tekrar" and the reminder: the deck while it has new words,
    /// then `fallback` (every topic), so finishing the chosen topics does not stop the daily goal.
    public static func newWordFeed(deck: [WidgetWord], fallback: [WidgetWord], progress: [Int: WordProgress]) -> [WidgetWord] {
        return hasNewWords(deck, progress: progress) ? deck : fallback
    }

    private static func isNew(_ word: WidgetWord, progress: [Int: WordProgress]) -> Bool {
        return (progress[word.id]?.state ?? .new) == .new
    }
}
