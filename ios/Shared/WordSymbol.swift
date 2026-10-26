import UIKit
import CoreModels

/// The word's picture: an SF Symbol for a concrete word (`WidgetWord.symbol`,
/// docs/ozellik_planlari/kelime_gorselleri.md). Compiled into the app, the widget extension and
/// the widget snapshot bundle.
///
/// Rules every caller keeps:
/// - decorative only: hidden from VoiceOver (the word itself is read), never yellow (yellow stays
///   on the word), secondary ink;
/// - only where the meaning is already shown: the feed card, the Sözlük page, the large widget
///   with its meaning open. Never on a question (Tekrar before the answer, the quiz widget,
///   listen and type questions, the placement test, sentence practice): the picture would give
///   the answer away;
/// - dropped first when space is short; it never makes the word smaller or cut.
enum WordSymbol {
    /// `name` when this system draws it, nil otherwise (no name, an empty one, or a symbol this iOS
    /// does not have): then nothing is shown.
    static func systemName(_ name: String?) -> String? {
        guard let name = name, !name.isEmpty, UIImage(systemName: name) != nil else {
            return nil
        }
        return name
    }

    /// The picture of `word`, if it has one this system draws.
    static func systemName(for word: WidgetWord) -> String? {
        return systemName(word.symbol)
    }
}
