import SwiftUI

/// Tekrar's keys on a hardware keyboard (iPad, Mac; an iPhone with a keyboard too): `1`–`4` pick
/// the answer in reading order, Space presses the card's one main button. Plain keys without ⌘:
/// a shortcut exists only while its button is on screen, and Tekrar has no text field. Also
/// compiled into the snapshot bundle with `QuizCardView`.
///
/// - Four options (`QuizCardView`, "Hatırla"): 1–4, left to right and top to bottom, before the
///   answer only.
/// - Two answers: 1 the first ("Bulamadım", "Zor"), 2 the second ("Buldum", "Kolay").
/// - Space: "Anlamını göster" (then "Sonraki"), "Göster", "Devam".
enum AnswerKeys {
    /// Space: the card's main button.
    static let main = KeyboardShortcut(.space, modifiers: [])

    /// The key of the answer at `position` (0 is `1`); nil for none or past the fourth.
    static func answer(_ position: Int?) -> KeyboardShortcut? {
        guard let position = position, (0..<4).contains(position) else {
            return nil
        }
        return KeyboardShortcut(KeyEquivalent(Character(String(position + 1))), modifiers: [])
    }
}
