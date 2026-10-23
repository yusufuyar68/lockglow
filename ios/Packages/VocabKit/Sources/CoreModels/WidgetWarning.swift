/// The one warning the large widget shows under its examples, from the card's warning slot in its
/// order (docs/tasarim/ogrenme_ilkeleri.md 2.2): a Turkish look-alike word first, else a typical
/// mistake. The widget writes it in one line as the app's card does, "aktüel ≠ actually · aktüel =
/// current" or "✕ two spoon → ✓ two spoons" (LargeWordView.swift). Part of the widget plan
/// (`WidgetWord.warning`, contract section 6): `{"false_friend":{"tr_word":…,"en_for_that":…}}`
/// or `{"mistake":{"wrong":…,"right":…}}`.
public enum WidgetWarning: Codable, Hashable, Sendable {
    /// `CardDetail.FalseFriend`: the Turkish word ("aktüel") and the English for what it means
    /// ("current / currently").
    case falseFriend(turkish: String, english: String)
    /// `CardDetail.Mistake`, both sentences whole; the widget shows the part that differs.
    case mistake(wrong: String, right: String)

    enum CodingKeys: String, CodingKey {
        case falseFriend = "false_friend"
        case mistake
    }

    enum FalseFriendCodingKeys: String, CodingKey {
        case turkish = "tr_word"
        case english = "en_for_that"
    }

    enum MistakeCodingKeys: String, CodingKey {
        case wrong
        case right
    }
}

extension CardDetail {
    /// The large widget's warning: the false friend, else the Dikkat mistake, the first whose
    /// wrong or right sentence has the card's word in it (`LemmaMatch`, as the app's card picks
    /// it; "actually" otherwise warns about "actual"), else the first. Nil when the card has
    /// neither.
    public func widgetWarning(lemma: String) -> WidgetWarning? {
        if let friend = falseFriend, !friend.trWord.isEmpty, !friend.enForThat.isEmpty {
            return .falseFriend(turkish: friend.trWord, english: friend.enForThat)
        }
        let usable = mistakes.filter { !$0.wrong.isEmpty && !$0.right.isEmpty }
        let about = usable.first { mistake in
            LemmaMatch.range(of: lemma, in: mistake.right) != nil || LemmaMatch.range(of: lemma, in: mistake.wrong) != nil
        }
        guard let mistake = about ?? usable.first else {
            return nil
        }
        return .mistake(wrong: mistake.wrong, right: mistake.right)
    }

    /// The large widget's second example, besides `first` (the plan's example, which the medium
    /// widget shows): the shortest other example that contains `lemma` (`LemmaMatch`, so the
    /// widget can mark the word), else the first other one ("teeth" is not found for "tooth").
    /// Of two equally short sentences the earlier one wins. Nil when the card has no other
    /// example.
    public func secondExample(besides first: String, containing lemma: String) -> String? {
        let others = examples.map(\.en).filter { !$0.isEmpty && $0 != first }
        let containing = others.filter { LemmaMatch.range(of: lemma, in: $0) != nil }
        return containing.min { $0.count < $1.count } ?? others.first
    }
}

extension WidgetWord {
    /// A copy with the large widget's second example and warning from the card's `detail`
    /// (`AppModel.refreshWidgetPlan`); the word unchanged without a detail (a seed word).
    public func addingLargeWidgetDetails(from detail: CardDetail?) -> WidgetWord {
        guard let detail = detail else {
            return self
        }
        var word = self
        word.secondExampleEN = detail.secondExample(besides: exampleEN, containing: lemma)
        word.warning = detail.widgetWarning(lemma: lemma)
        return word
    }
}
