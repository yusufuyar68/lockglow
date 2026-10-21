import Foundation

/// Where a card's headword occurs in a sentence: each of its words as a whole word, plus any
/// ending ("borrow" finds "borrowed", "look forward to" finds "looking forward to"), ignoring
/// case. Irregular forms ("tooth" → "teeth") are not found. Shared by the app's and the widget's
/// example mark (`ExampleMark`) and by the widget plan's example choice.
public enum LemmaMatch {
    /// The first place where `lemma` occurs in `sentence`; nil when it does not.
    public static func range(of lemma: String, in sentence: String) -> Range<String.Index>? {
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
