import SwiftUI

/// The end-of-day card (ogrenme_ilkeleri 2.2 and 2.10): not a window but the feed's next page,
/// as large as a word card and set like one (option A "Sayfa"): a quiet sun, the sentence, the
/// next new words' promise, and under a hairline the words met today, as one serif line. The list
/// closes the day without asking anything: no count of what is left, no score, no blame, and
/// going on is always free. "Tekrar'a geç (N kelime)" is the main button while "Tekrar" has a
/// round (N: its words, as on "Tekrar"'s "Başla"); "Devam et" goes to the next card, the main
/// button when "Tekrar" has none. On a page too short for the list the list is left out.
struct FeedDayEndView: View {
    let goal: Int
    /// "Yarın kilitli ekranında…" only with a Lock Screen widget.
    let hasLockScreenWidget: Bool
    /// Words of "Tekrar"'s next round; nil when it has none.
    let reviewCount: Int?
    /// The new words met in the feed today, in the feed's order.
    var metWords: [String] = []
    /// As tall as its page (the paged feed); natural height at accessibility text sizes.
    let fillsPage: Bool
    let openReview: () -> Void
    /// Nil on the feed's last page.
    let continueFeed: (() -> Void)?

    var body: some View {
        Group {
            if fillsPage {
                ViewThatFits(in: .vertical) {
                    content(showsWords: true)
                    content(showsWords: false)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            } else {
                content(showsWords: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: fillsPage ? .infinity : nil, alignment: .topLeading)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
        .tint(Theme.ink)
        .accessibilityElement(children: .contain)
    }

    private func content(showsWords: Bool) -> some View {
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
                .padding(.top, 14)
            Text(hasLockScreenWidget ? "Yarın kilitli ekranında yenileri olacak." : "Yarın yenileri gelecek.")
                .font(.body)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
            if showsWords && !metWords.isEmpty {
                FeedCardRule()
                    .padding(.top, 26)
                Text("Bugünün yeni kelimeleri")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 14)
                // One line of English words: read with the English voice, commas as pauses.
                Text(verbatim: metWords.joined(separator: ", "))
                    .font(Theme.Fonts.definition)
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 6)
                    .englishVoice()
            }
            Spacer(minLength: 28)
            buttons
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: fillsPage ? .infinity : nil, alignment: .topLeading)
    }

    @ViewBuilder
    private var buttons: some View {
        VStack(spacing: 10) {
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
