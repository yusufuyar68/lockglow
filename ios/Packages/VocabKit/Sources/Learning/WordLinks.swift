import Foundation
import CoreModels

/// The words a Sözlük word page links to: the cards often mixed up with it ("Karıştırma: lend",
/// `WidgetWord.confusableIDs`) and the other senses of its headword ("break": mola, kırmak). Pure,
/// so the choice is tested without the app.
public enum WordLinks {
    /// `word`'s confusable partners among `words`, sorted by headword (then id, for a stable
    /// order). The content links a partner by its headword, so a headword with several senses
    /// brings every one of them ("wear" → "put on": giymek and açmak). Of those senses the ones
    /// whose Turkish meaning shares a word with `word`'s are kept, else the ones of the same part of
    /// speech, else all of them. Partners that are not loaded, and `word` itself, are left out.
    public static func confusables(of word: WidgetWord, in words: [Int: WidgetWord]) -> [WidgetWord] {
        var seen = Set<Int>()
        var byHeadword: [String: [WidgetWord]] = [:]
        for id in word.confusableIDs ?? [] where id != word.id && seen.insert(id).inserted {
            if let partner = words[id] {
                byHeadword[headwordKey(partner.lemma), default: []].append(partner)
            }
        }
        let ownMeaning = meaningWords(word.glossTR)
        var result: [WidgetWord] = []
        for senses in byHeadword.values {
            result += closestSenses(senses, meaning: ownMeaning, pos: word.pos)
        }
        return result.sorted { lhs, rhs in
            let left = headwordKey(lhs.lemma)
            let right = headwordKey(rhs.lemma)
            return left != right ? left < right : lhs.id < rhs.id
        }
    }

    /// The other cards with `word`'s headword (case and surrounding spaces ignored), in the order
    /// of `words`.
    public static func otherSenses(of word: WidgetWord, in words: [WidgetWord]) -> [WidgetWord] {
        let key = headwordKey(word.lemma)
        return words.filter { $0.id != word.id && headwordKey($0.lemma) == key }
    }

    /// The headword as the links compare it: "Put On " and "put on" are one headword.
    static func headwordKey(_ lemma: String) -> String {
        return lemma.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// The words of a Turkish meaning ("iyi kalpli, nazik" → iyi, kalpli, nazik), in Turkish
    /// lower case, without the helper verbs and small words that many meanings share ("yardım
    /// etmek" and "kontrol etmek" do not mean the same thing).
    static func meaningWords(_ gloss: String?) -> Set<String> {
        guard let gloss = gloss else {
            return []
        }
        // Turkish casing by hand ("I" → "ı", "İ" → "i"): the same on Apple platforms and Linux.
        let lower = gloss.replacingOccurrences(of: "I", with: "ı")
            .replacingOccurrences(of: "İ", with: "i")
            .lowercased()
        let words = lower
            .split(whereSeparator: { !$0.isLetter })
            .map(String.init)
            .filter { !sharedWords.contains($0) }
        return Set(words)
    }

    /// Words too common in meanings to tell two senses apart.
    static let sharedWords: Set<String> = [
        "etmek", "olmak", "yapmak", "almak", "vermek", "bir", "ve", "ile", "için", "bu", "şey",
    ]

    private static func closestSenses(_ senses: [WidgetWord], meaning: Set<String>, pos: String) -> [WidgetWord] {
        guard senses.count > 1 else {
            return senses
        }
        let sharingMeaning = senses.filter { !meaningWords($0.glossTR).isDisjoint(with: meaning) }
        if !sharingMeaning.isEmpty {
            return sharingMeaning
        }
        let samePartOfSpeech = senses.filter { $0.pos == pos }
        return samePartOfSpeech.isEmpty ? senses : samePartOfSpeech
    }
}
