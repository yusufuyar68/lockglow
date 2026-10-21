import Foundation
import os
import CoreModels
import ContentStore

enum ContentSource: Equatable, Sendable {
    case loading
    case database
    case seed
    case empty
}

struct LoadedContent: Sendable {
    let words: [WidgetWord]
    let source: ContentSource
    let cardCount: Int
    let contentVersion: String?
    /// Topics the user can choose and every topic of each card; empty for seed words.
    let topics: [ContentTopic]
    let topicsOf: [Int: Set<String>]
}

/// Reads the feed words: the bundled `content.sqlite` (opened read-only, straight from the app
/// bundle) if present and usable, otherwise `seed_words.json`, otherwise nothing.
/// Blocking work; call it off the main thread.
enum ContentLoader {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "content"
    )

    /// The bundled `content.sqlite`, opened read-only; nil if it is missing or unusable.
    static func openStore() -> ContentStore? {
        guard let databaseURL = Bundle.main.url(forResource: "content", withExtension: "sqlite") else {
            return nil
        }
        do {
            return try ContentStore(path: databaseURL.path)
        } catch {
            logger.error("content.sqlite unusable: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    static func load(feedLimit: Int) -> LoadedContent {
        if let store = openStore() {
            do {
                let words = try store.freeCards(maxLevelRank: 7, limit: feedLimit)
                let count = try store.cardCount()
                let version = try store.meta("content_version")
                if !words.isEmpty {
                    let topics = loadTopics(from: store)
                    return LoadedContent(
                        words: words,
                        source: .database,
                        cardCount: count,
                        contentVersion: version,
                        topics: topics.topics,
                        topicsOf: topics.topicsOf
                    )
                }
                logger.error("content.sqlite has no free cards; using seed words")
            } catch {
                logger.error("content.sqlite unusable: \(error.localizedDescription, privacy: .public)")
            }
        }

        let seed = SeedWords.load()
        if seed.isEmpty {
            return LoadedContent(words: [], source: .empty, cardCount: 0, contentVersion: nil, topics: [], topicsOf: [:])
        }
        return LoadedContent(words: seed, source: .seed, cardCount: seed.count, contentVersion: nil, topics: [], topicsOf: [:])
    }

    /// The topic choice is optional: if the topics cannot be read, every word stays in the feed.
    private static func loadTopics(from store: ContentStore) -> (topics: [ContentTopic], topicsOf: [Int: Set<String>]) {
        do {
            let topics = try store.topics()
            let topicsOf = try store.topicsByCard()
            return (topics, topicsOf)
        } catch {
            logger.error("topics unreadable: \(error.localizedDescription, privacy: .public)")
            return ([], [:])
        }
    }
}
