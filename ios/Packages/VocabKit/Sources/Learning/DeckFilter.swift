import Foundation
import CoreModels

/// What the user chose to study: the topics that rotate on the widget and in "Akış", and the
/// level new words start from. No topic means every topic; no level keeps the curriculum
/// order (A1 first).
public struct DeckChoice: Equatable, Sendable {
    /// `category.id` values (the cards' `primary_topic`).
    public var topicIDs: Set<String>
    public var startLevel: Level?

    public init(topicIDs: Set<String> = [], startLevel: Level? = nil) {
        self.topicIDs = topicIDs
        self.startLevel = startLevel
    }
}

/// Turns the curriculum (every free card, A1 first) into the user's feed. Pure and deterministic.
///
/// The feed decides which words the widget queue, "Akış" and the new words of "Tekrar" use.
/// Words already being learned keep their reviews whatever the choice: "Tekrar" asks every due
/// word, and the progress counts cover every word.
public enum DeckFilter {
    /// The user's feed: `filtered` by topic, then `ordered` by level.
    public static func feed(_ words: [WidgetWord], topicOf: [Int: String], choice: DeckChoice) -> [WidgetWord] {
        return ordered(filtered(words, topicOf: topicOf, topicIDs: choice.topicIDs), startingAt: choice.startLevel)
    }

    /// Words whose primary topic is chosen, in their original order. Every word when no topic is
    /// chosen, and also when the choice matches no word (topics that left the content, or seed
    /// words, which have no topic): a topic choice never empties the feed.
    public static func filtered(_ words: [WidgetWord], topicOf: [Int: String], topicIDs: Set<String>) -> [WidgetWord] {
        if topicIDs.isEmpty {
            return words
        }
        let kept = words.filter { word in
            guard let topic = topicOf[word.id] else {
                return false
            }
            return topicIDs.contains(topic)
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
}
