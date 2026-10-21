import SwiftUI
import Learning

/// What a topic choice gives: how many words, how many of them are still new, and a soft
/// warning when the deck is small (no minimum is enforced). Used on the onboarding's topics page
/// and in "Ayarlar > Konular"; the numbers come from `AppModel.deckSummary(for:)`.
struct DeckSummaryLine: View {
    /// Below this many words the widget repeats the same words often.
    static let smallDeck = 30

    let summary: DeckSummary
    let dailyGoal: Int
    /// No topic chosen: every topic.
    let isEverything: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Mockup `.deck-sum`: the count in ink (it rolls to the new number as topics are tapped),
    /// the new words in `ink2` only when some words were already studied, the warning with a
    /// `caution` icon (the sentence says it; the color only repeats it).
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: wordLine)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .contentTransition(.numericText())
            if let newWordLine = newWordLine {
                Text(verbatim: newWordLine)
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if isSmall {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Theme.caution)
                        .accessibilityHidden(true)
                    Text(verbatim: "Kelime az; widget aynı kelimeleri sık gösterir. Bir konu daha seçebilirsin.")
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(.footnote)
                .padding(.top, 2)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: summary)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: isEverything)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var isSmall: Bool {
        return !isEverything && summary.wordCount < DeckSummaryLine.smallDeck
    }

    private var wordLine: String {
        return isEverything ? "Tüm konular: \(summary.wordCount) kelime" : "Seçili: \(summary.wordCount) kelime"
    }

    /// Nil while every word is new (a fresh install): the count above already says it all.
    private var newWordLine: String? {
        let newCount = summary.newCount
        if newCount >= summary.wordCount {
            return nil
        }
        if newCount == 0 {
            return isEverything
                ? "Yeni kelime kalmadı."
                : "Bu konularda yeni kelime kalmadı. Yeni kelimeler diğer konulardan gelir."
        }
        let place = isEverything ? "Tüm konularda" : "Bu konularda"
        if newCount < dailyGoal {
            return "\(place) \(newCount) yeni kelime kaldı."
        }
        return "\(place) \(newCount) yeni kelime var."
    }
}
