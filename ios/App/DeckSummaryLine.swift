import SwiftUI
import Learning

/// What a topic choice gives: how many words, how many of them are new, and a soft warning when
/// the deck is small (no minimum is enforced). Used on the onboarding's topics page and in
/// "Ayarlar > Konular"; the numbers come from `AppModel.deckSummary(for:)`.
struct DeckSummaryLine: View {
    /// Below this many words the widget repeats the same words often.
    static let smallDeck = 30

    let summary: DeckSummary
    let dailyGoal: Int
    /// No topic chosen: every topic.
    let isEverything: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: wordLine)
                .font(.subheadline.weight(.semibold))
            Text(verbatim: newWordLine)
                .font(.footnote)
                .foregroundStyle(Palette.ink2)
            if !isEverything && summary.wordCount < DeckSummaryLine.smallDeck {
                Label {
                    Text(verbatim: "Kelime az olduğu için widget aynı kelimeleri sık gösterir.")
                } icon: {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(Palette.glowInk)
                }
                .font(.footnote)
                .foregroundStyle(Palette.ink2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var wordLine: String {
        return isEverything ? "Tüm konular: \(summary.wordCount) kelime" : "Seçili: \(summary.wordCount) kelime"
    }

    private var newWordLine: String {
        let newCount = summary.newCount
        if newCount == 0 {
            return isEverything ? "Yeni kelime kalmadı." : "Bu konularda yeni kelime kalmadı."
        }
        let place = isEverything ? "Tüm konularda" : "Bu konularda"
        if newCount < dailyGoal {
            return "\(place) \(newCount) yeni kelime kaldı."
        }
        return "\(place) \(newCount) yeni kelime var."
    }
}
