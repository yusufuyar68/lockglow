import AppIntents
import Foundation
import CoreModels
import Learning
import TextFold

/// A Lockglow word for Siri and Kestirmeler: what "Bu kelimeyi Lockglow'da ara" asks for and opens
/// (`OpenWordIntent`). Siri shows the English word with its Turkish meaning under it.
struct WordEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Kelime"
    }

    static var defaultQuery: WordEntityQuery {
        WordEntityQuery()
    }

    /// The word id: a card's (id_registry.json) or the user's own word's (`CustomWordID`).
    let id: Int
    let lemma: String
    let meaning: String?

    init(_ word: WidgetWord) {
        id = word.id
        lemma = word.lemma
        meaning = TodayWord.meaning(of: word)
    }

    var displayRepresentation: DisplayRepresentation {
        if let meaning = meaning {
            return DisplayRepresentation(title: "\(lemma)", subtitle: "\(meaning)")
        }
        return DisplayRepresentation(title: "\(lemma)")
    }
}

/// Finds words for Siri ("Hangi kelimeyi arayalım?") and the picker of Kestirmeler. It runs
/// before the app has a screen, so it reads the words itself (`AppModel.shortcutWords`) instead
/// of asking the model; nothing is cached, so a word added a moment ago is found.
struct WordEntityQuery: EntityStringQuery {
    func entities(for identifiers: [Int]) async throws -> [WordEntity] {
        let words = await WordEntityQuery.loadWords()
        return ShortcutWordSearch.words(withIDs: identifiers, in: words).map(WordEntity.init)
    }

    func entities(matching string: String) async throws -> [WordEntity] {
        let words = await WordEntityQuery.loadWords()
        return ShortcutWordSearch.matches(string, in: words, fold: TextFold.fold).map(WordEntity.init)
    }

    func suggestedEntities() async throws -> [WordEntity] {
        let words = await WordEntityQuery.loadWords()
        return ShortcutWordSearch.suggestions(from: words).map(WordEntity.init)
    }

    /// Off the caller's thread: the database read blocks.
    private static func loadWords() async -> [WidgetWord] {
        return await Task.detached(priority: .userInitiated) {
            AppModel.shortcutWords()
        }.value
    }
}
