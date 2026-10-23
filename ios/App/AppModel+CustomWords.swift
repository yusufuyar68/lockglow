import Foundation
import CoreModels
import Learning
import TextFold

// "Kendi kelimeni ekle" (docs/ozellik_planlari/kendi_kelime.md): the user's own words join every
// deck in front of the cards, the widget queue, "Tekrar" and the dictionary. AppModel.swift keeps
// the few lines that change its state (`customWordsDidChange`); the rest is here. Compiled into
// the Linux check of the app's logic too (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// `cards` with the user's words in front (`DeckFilter.prepending`): every deck, every level.
    func withCustomWords(_ cards: [WidgetWord]) -> [WidgetWord] {
        return DeckFilter.prepending(customWordLibrary.widgetWords, to: cards)
    }

    /// The user's words whose English word or Turkish meaning has a word starting with `query`,
    /// the newest first. Folded like the dictionary's index (`TextFold`: case, accents and the
    /// Turkish letters), so "garıp" and "GARIP" both find "garip".
    func customWordMatches(_ query: String, limit: Int) -> [WidgetWord] {
        let needle = TextFold.fold(query)
        guard !needle.isEmpty, limit > 0 else {
            return []
        }
        let found = customWordLibrary.newestFirst.filter { word in
            AppModel.hasWord(startingWith: needle, in: word.lemma)
                || AppModel.hasWord(startingWith: needle, in: word.meaningTR)
        }
        return found.prefix(limit).map { $0.widgetWord }
    }

    /// Whether a word of `text` (split at spaces and the usual separators) starts with `needle`,
    /// or the whole text does ("look u" finds "look up").
    private static func hasWord(startingWith needle: String, in text: String) -> Bool {
        let folded = TextFold.fold(text)
        if folded.hasPrefix(needle) {
            return true
        }
        let separators = CharacterSet(charactersIn: " ,;/()-'")
        return folded.components(separatedBy: separators).contains { $0.hasPrefix(needle) }
    }

    /// The words "Hatırla" takes wrong options from (`ReviewPlanner.introQuestion`). The option
    /// pool keeps to the asked word's part of speech and level, which a user's word does not have:
    /// for one, every other word counts as its kind, so its question gets options from the cards
    /// (Turkish meanings and English headwords) instead of falling back to the recall screen.
    func introCandidates(for word: WidgetWord) -> [WidgetWord] {
        guard word.isUserAdded else {
            return words
        }
        return words.map { candidate in
            if candidate.pos == word.pos && candidate.level == word.level {
                return candidate
            }
            return WidgetWord(
                id: candidate.id,
                lemma: candidate.lemma,
                pos: word.pos,
                level: word.level,
                defMicro: candidate.defMicro,
                defShort: candidate.defShort,
                exampleEN: candidate.exampleEN,
                glossTR: candidate.glossTR
            )
        }
    }
}
