import CoreModels

/// What a "Tekrar" round is made of.
enum ReviewKind: Equatable {
    /// Words whose review, refresher or "Biliyorum" check is due, each asked by its box
    /// (`AppModel.questionKind`).
    case due
    /// A "Tanış + Hatırla" round (`IntroRound`): words sent back by a failed "Biliyorum" check
    /// first, then never-reviewed words in feed order.
    case new
}

/// One round offered by `AppModel.nextReviewSession`.
struct ReviewSession: Equatable {
    let kind: ReviewKind
    let words: [WidgetWord]
    /// Cards waiting in total (a due round), or new words left for today (a new round). A round
    /// is capped at `AppModel.reviewSessionLimit` or `AppModel.introRoundLimit` words, so this
    /// can be larger than `words.count`.
    let totalCount: Int
}
