import Foundation
import CoreModels

// "Sözlük" (SearchView, SozlukTopicView, SozlukRecentSearches): what the dictionary asks of the
// model. Compiled into the Linux check of the app's logic too (ios/Tools/linux_check_prepare.py
// `APP_LOGIC_FILES`).

extension AppModel {
    /// "Son aramalar" (`SozlukRecentSearches`) are kept on this phone under this UserDefaults key.
    nonisolated static let recentSearchesKey = "lockglow.recentSearches"

    /// "İlerlemeyi sıfırla" forgets the recent searches too; Sözlük's `@AppStorage` follows.
    static func clearRecentSearches() {
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }

    /// The loaded words of a topic (`card_category`, every topic of a card, main or not), in the
    /// loaded order. Empty for a topic without cards and with seed words only; the user's own
    /// words have no topic.
    func words(inTopic topicID: String) -> [WidgetWord] {
        return words.filter { topicsOf[$0.id]?.contains(topicID) ?? false }
    }
}
