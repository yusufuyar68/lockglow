import SwiftUI

/// The end-of-day card (ogrenme_ilkeleri 2.2 and 2.10): not a window but the feed's next page,
/// as large as a word card and set like one (option A "Sayfa"): a quiet sun, the sentence and the
/// promise of new words at the top of the page, the two buttons at its foot, where the thumb is.
/// Calm: no count of what is left, no list, no score, no blame, and going on is always free.
/// "Tekrar'a geç (N kelime)" is the main button while "Tekrar" has a round (N: its words, as on
/// "Tekrar"'s "Başla"); "Devam et" goes to the next card, the main button when "Tekrar" has none.
struct FeedDayEndView: View {
    let goal: Int
    /// "Yarın kilitli ekranında…" only with a Lock Screen widget.
    let hasLockScreenWidget: Bool
    /// Words of "Tekrar"'s next round; nil when it has none.
    let reviewCount: Int?
    /// As tall as its page (the paged feed); natural height at accessibility text sizes.
    let fillsPage: Bool
    let openReview: () -> Void
    /// Nil on the feed's last page.
    let continueFeed: (() -> Void)?

    /// Two text sizes (Title, Body) plus the buttons' Headline; 20 pt inside, as the word card,
    /// spacing on the 8 pt grid.
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "sun.max")
                .font(.title)
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            Text(verbatim: "Bugünlük \(goal) yeni kelime yeter.")
                .font(.title.weight(.bold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 16)
            Text(hasLockScreenWidget ? "Yarın kilitli ekranında yenileri olacak." : "Yarın yenileri gelecek.")
                .font(.body)
                .foregroundStyle(Theme.ink2)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
            Spacer(minLength: 32)
            buttons
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: fillsPage ? .infinity : nil, alignment: .topLeading)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
        .tint(Theme.ink)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var buttons: some View {
        VStack(spacing: 8) {
            if let count = reviewCount {
                Button(action: openReview) {
                    Text(verbatim: "Tekrar'a geç (\(count) kelime)")
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
            }
            if let continueFeed = continueFeed {
                if reviewCount == nil {
                    Button("Devam et", action: continueFeed)
                        .buttonStyle(PrimaryCapsuleButtonStyle())
                        .accessibilityHint("Sıradaki karta geçer.")
                } else {
                    Button("Devam et", action: continueFeed)
                        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                        .accessibilityHint("Sıradaki karta geçer.")
                }
            }
        }
    }
}
