import Foundation
import CoreModels

/// "Yol haritası": the levels from A1 to B2, how many words each has, how many the user met, and
/// which topics come next in each. Pure and deterministic.
///
/// A calm map (docs/tasarim/ogrenme_ilkeleri.md 2.5 and "Kaçınılacaklar"): no lock, no points, no
/// rank and no percentage. Every level's words are open at any time; the map only says where new
/// words come from now.
public struct LevelMap: Equatable, Sendable {
    /// One level on the map.
    public struct Stop: Equatable, Identifiable, Sendable {
        public let level: Level
        /// The level's words (the user's own words are not on the map).
        public let total: Int
        /// Words met: answered at least once or marked "Biliyorum" (everything on İlerleme's
        /// shelves).
        public let met: Int
        /// The topics of the level's next new words, in the order those words come, at most
        /// `topicLimit`. Empty when every word was met.
        public let nextTopicIDs: [String]

        public var id: Level {
            return level
        }

        public var everyWordMet: Bool {
            return total > 0 && met >= total
        }
    }

    public let stops: [Stop]
    /// The start level the user chose (or the test gave); nil when never chosen.
    public let startLevel: Level?
    /// The level of the next new word; nil when no new word is left.
    public let currentLevel: Level?

    /// Topics named per level.
    public static let topicLimit = 3

    /// - Parameters:
    ///   - levels: the levels to show, easiest first.
    ///   - words: every loaded word; the user's own words are left out.
    ///   - upcoming: the words new words come from, in the order "Tekrar" takes them (the deck,
    ///     then every topic). Words met already are skipped.
    ///   - topicsOf: every topic of each word.
    ///   - topicOrder: the shown topics by id with their display order; a topic not in it is not
    ///     named.
    ///   - preferredTopicIDs: the chosen topics; a word in one of them is named by it.
    ///   - hidingEmptyLevelsAbove: a level harder than this one is left off the map while it has
    ///     no words (e.g. B2 in a content DB without B2 cards); nil keeps every level.
    public static func make(
        levels: [Level],
        words: [WidgetWord],
        upcoming: [WidgetWord],
        progress: [Int: WordProgress],
        topicsOf: [Int: Set<String>],
        topicOrder: [String: Int],
        preferredTopicIDs: Set<String> = [],
        startLevel: Level?,
        hidingEmptyLevelsAbove: Level? = nil
    ) -> LevelMap {
        func isMet(_ id: Int) -> Bool {
            return (progress[id]?.state ?? .new) != .new
        }
        var totals: [Level: Int] = [:]
        var met: [Level: Int] = [:]
        var seen = Set<Int>()
        for word in words where !word.isUserAdded && seen.insert(word.id).inserted {
            guard let level = word.levelValue else {
                continue
            }
            totals[level, default: 0] += 1
            if isMet(word.id) {
                met[level, default: 0] += 1
            }
        }

        var next: [Level: [String]] = [:]
        var currentLevel: Level?
        var asked = Set<Int>()
        for word in upcoming where !word.isUserAdded && asked.insert(word.id).inserted && !isMet(word.id) {
            guard let level = word.levelValue, levels.contains(level) else {
                continue
            }
            if currentLevel == nil {
                currentLevel = level
            }
            guard (next[level]?.count ?? 0) < topicLimit,
                  let topic = shownTopic(of: word.id, topicsOf: topicsOf, order: topicOrder, preferred: preferredTopicIDs),
                  !(next[level]?.contains(topic) ?? false) else {
                continue
            }
            next[level, default: []].append(topic)
        }

        let stops = levels.compactMap { level -> Stop? in
            let total = totals[level] ?? 0
            if let limit = hidingEmptyLevelsAbove, level > limit, total == 0 {
                return nil
            }
            return Stop(level: level, total: total, met: met[level] ?? 0, nextTopicIDs: next[level] ?? [])
        }
        return LevelMap(stops: stops, startLevel: startLevel, currentLevel: currentLevel)
    }

    /// The topic a word is named by: a chosen one first, then the first in display order (so a
    /// concrete topic such as "Hava ve mevsimler" comes before "Kelime ikilileri").
    static func shownTopic(of id: Int, topicsOf: [Int: Set<String>], order: [String: Int], preferred: Set<String>) -> String? {
        let topics = (topicsOf[id] ?? []).filter { order[$0] != nil }
        let pool = topics.intersection(preferred).isEmpty ? topics : topics.intersection(preferred)
        return pool.min { a, b in
            let left = order[a] ?? Int.max
            let right = order[b] ?? Int.max
            return left != right ? left < right : a < b
        }
    }
}
