import Foundation
import CoreModels
import Learning

// "Yol haritası" (LevelMapView.swift): what the map reads from the model. Foundation only, so it
// joins the Linux compile check (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// The map now (`LevelMap`): the offered levels, the next new words in the order "Tekrar"
    /// takes them (the deck, then every topic) and the topics the user can choose.
    func levelMap() -> LevelMap {
        let upcoming = DeckFilter.newWordFeed(deck: feedWords, fallback: allTopicsFeed, progress: progress) + allTopicsFeed
        let order = Dictionary(choosableTopics.map { ($0.id, $0.sort) }, uniquingKeysWith: { first, _ in first })
        return LevelMap.make(
            levels: AppPreferences.startLevelChoices,
            words: words,
            upcoming: upcoming,
            progress: progress,
            topicsOf: topicsOf,
            topicOrder: order,
            preferredTopicIDs: activeTopicIDs,
            startLevel: deckChoice.startLevel,
            // A level with no words (e.g. B2 in an older content DB) gets no empty "0 kelime" stop.
            hidingEmptyLevelsAbove: .b1
        )
    }

    /// A topic's name on screen ("Yemek ve içecek"); nil for an unknown id.
    func topicDisplayName(_ id: String) -> String? {
        return topics.first { $0.id == id }?.displayName
    }
}
