import Foundation
import CoreModels
import Learning

// "Metinden kelime bul" (docs/ozellik_planlari/metinden_kelime.md): the app's side of
// `TextHarvest`. The cards come from the lemma index (`card(lemma:)`, the loaded free cards
// only), the user's own words from their library, the states from the progress. Nothing is
// stored. Compiled into the Linux check of the app's logic too (ios/Tools/linux_check_prepare.py
// `APP_LOGIC_FILES`).

extension AppModel {
    /// The words of `text`: on the cards, among the user's own words, and new. At most
    /// `TextHarvest.inputLimit` characters and `TextHarvest.wordLimit` different words are read.
    func harvestWords(in text: String) -> TextHarvest.Result {
        var ownByLemma: [String: WidgetWord] = [:]
        for word in customWordLibrary.words {
            let key = word.lemma.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if ownByLemma[key] == nil {
                ownByLemma[key] = word.widgetWord
            }
        }
        return TextHarvest.harvest(
            text,
            card: { card(lemma: $0) },
            ownWord: { ownByLemma[$0] },
            state: { learningState(of: $0) }
        )
    }
}
