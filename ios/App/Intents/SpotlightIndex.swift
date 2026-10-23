import CoreSpotlight
import Foundation
import os
import UniformTypeIdentifiers
import CoreModels
import Learning

/// Puts the cards into Spotlight: searching "breakfast", "kahvaltı" or "kahvalti" on the iPhone
/// finds the card, and a tap opens its whole card (`shortcutRoutes`). Which words go in is
/// `SpotlightCatalog`: never a personal-topic card, never the user's own words. Everything stays on
/// the phone (the default on-device index); the user can hide the results in iPhone Ayarları.
///
/// Runs after every launch once the words have loaded, and indexes only when the cards changed or
/// a week has passed (`SpotlightCatalog.needsIndexing`): the old items are deleted first, so a
/// card that left the content leaves Spotlight too.
enum SpotlightIndex {
    private static let signatureKey = "lockglow.spotlight.signature"
    private static let indexedAtKey = "lockglow.spotlight.indexedAt"
    /// Items per indexing call.
    private static let batchSize = 500
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow",
        category: "spotlight"
    )

    static func update(with words: [WidgetWord], now: Date = Date()) async {
        guard CSSearchableIndex.isIndexingAvailable() else {
            return
        }
        let entries = await Task.detached(priority: .utility) {
            AppModel.spotlightEntries(from: words)
        }.value
        let signature = SpotlightCatalog.signature(of: entries)
        let defaults = UserDefaults.standard
        let indexedAt = (defaults.object(forKey: indexedAtKey) as? Double).map { Date(timeIntervalSince1970: $0) }
        guard SpotlightCatalog.needsIndexing(
            signature: signature,
            indexedSignature: defaults.string(forKey: signatureKey),
            indexedAt: indexedAt,
            now: now
        ) else {
            return
        }

        let index = CSSearchableIndex.default()
        do {
            try await index.deleteSearchableItems(withDomainIdentifiers: [SpotlightCatalog.domain])
            var start = 0
            while start < entries.count {
                let batch = entries[start..<min(start + batchSize, entries.count)]
                try await index.indexSearchableItems(batch.map(item))
                start += batchSize
            }
            defaults.set(signature, forKey: signatureKey)
            defaults.set(now.timeIntervalSince1970, forKey: indexedAtKey)
            logger.info("indexed \(entries.count) words for Spotlight")
        } catch {
            // Tried again at the next launch: the signature was not saved.
            logger.error("Spotlight indexing failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func item(_ entry: SpotlightCatalog.Entry) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: .text)
        attributes.title = entry.title
        attributes.contentDescription = entry.summary
        attributes.keywords = entry.keywords
        let item = CSSearchableItem(
            uniqueIdentifier: entry.identifier,
            domainIdentifier: SpotlightCatalog.domain,
            attributeSet: attributes
        )
        // Items expire after a month by default; these stay until indexed again.
        item.expirationDate = .distantFuture
        return item
    }
}
