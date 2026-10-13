import CoreModels

/// What a "Tekrar" round is made of.
enum ReviewKind: Equatable {
    /// Words whose review (or refresher) is due.
    case due
    /// Never-reviewed words, taken in feed order.
    case new
}

/// One flashcard round offered by `AppModel.nextReviewSession`.
struct ReviewSession: Equatable {
    let kind: ReviewKind
    let words: [WidgetWord]
    /// Cards waiting in total. A due round is capped at `AppModel.reviewSessionLimit` cards,
    /// so this can be larger than `words.count`.
    let totalCount: Int
}
