import Foundation

/// Where a card's headword occurs in a sentence: each of its words as a whole word, plus any
/// ending ("borrow" finds "borrowed", "look forward to" finds "looking forward to"), ignoring
/// case. Irregular forms ("tooth" → "teeth") are not found; a phrase that starts with "be" is
/// also found without it ("be fed up with" finds "fed up with"). Shared by the app's and the
/// widget's example mark (`ExampleMark`) and by the widget plan's example choice.
public enum LemmaMatch {
    /// The first place where `lemma` occurs in `sentence`; nil when it does not. When a phrase
    /// that starts with "be" is not found whole, the place of the rest of the phrase.
    public static func range(of lemma: String, in sentence: String) -> Range<String.Index>? {
        if let found = firstMatch(of: lemma, in: sentence) {
            return found
        }
        // "be fed up with" in "I'm fed up with this rain.": "be" takes other forms ('m, is,
        // was), so the rest of the phrase is marked.
        let words = lemma.split(separator: " ")
        guard words.count > 1, words[0].lowercased() == "be" else {
            return nil
        }
        return firstMatch(of: words.dropFirst().joined(separator: " "), in: sentence)
    }

    /// The first place where every word of `lemma` occurs in a row in `sentence`, each with any
    /// ending; nil when it does not.
    private static func firstMatch(of lemma: String, in sentence: String) -> Range<String.Index>? {
        let parts = lemma.split(separator: " ").map { NSRegularExpression.escapedPattern(for: String($0)) + "\\w*" }
        guard !parts.isEmpty,
              let regex = try? NSRegularExpression(
                  pattern: "\\b" + parts.joined(separator: "\\s+") + "\\b",
                  options: [.caseInsensitive]
              ) else {
            return nil
        }
        let whole = NSRange(sentence.startIndex..<sentence.endIndex, in: sentence)
        guard let match = regex.firstMatch(in: sentence, options: [], range: whole) else {
            return nil
        }
        return Range(match.range, in: sentence)
    }
}

extension CardDetail {
    /// The shortest English example that contains `lemma` (`LemmaMatch`), for the medium widget
    /// (docs/tasarim/README.md "Widget'lar"). Of two equally short sentences the earlier one wins.
    /// Nil when no example contains the word.
    public func shortestExample(containing lemma: String) -> String? {
        return examples
            .map(\.en)
            .filter { LemmaMatch.range(of: lemma, in: $0) != nil }
            .min { $0.count < $1.count }
    }
}
