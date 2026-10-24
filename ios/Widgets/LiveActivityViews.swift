import SwiftUI
import WidgetKit

// The "Tekrar" round's Live Activity views (`ReviewLiveActivityWidget`). Calm, like the rest of
// the app (docs/tasarim/ogrenme_ilkeleri.md §1 point 11): the round's card counter and "Devam
// et", nothing else. No timer, no count of what is left, no word (the Lock Screen would answer
// the card on screen, and anyone can see it there), no yellow (the band is the English word's
// alone), no animation of their own.
// Stale, 30 minutes after the user left the round (`ReviewActivityTracker.timeout`): no counter
// and no button, only "Cevapların kaydedildi." (every answer is saved at once); the app closes the
// activity when it comes back.
// Turkish text is verbatim, read with a Turkish voice (`widgetTurkishVoice()`); "Kart 4 / 10" is
// read "Kart 4, toplam 10" (docs/tasarim/terimler.md §1).
// The Lock Screen uses the app's tokens on `Theme.bg` (paper by day, black at night). The
// Dynamic Island is always black: its views take the night tokens (`islandColors()`).

/// The Lock Screen presentation (also the banner on iPhones without the Dynamic Island and, twice
/// as large, StandBy): the Tekrar symbol, "Tekrar", "Kart 4 / 10" and "Devam et" on one line;
/// when that does not fit (larger text sizes), "Devam et" goes under it, full width. The whole
/// activity opens "Tekrar" (`widgetURL`).
struct ReviewActivityLockScreenView: View {
    let state: ReviewActivityAttributes.ContentState
    let isStale: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                summary
                Spacer(minLength: 0)
                if !isStale {
                    ReviewActivityContinueFace()
                        .fixedSize()
                }
            }
            VStack(alignment: .leading, spacing: 12) {
                summary
                if !isStale {
                    ReviewActivityContinueFace(fullWidth: true)
                }
            }
        }
        // HIG's standard margin of a Live Activity.
        .padding(14)
        // The activity is at most 160 pt tall.
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .widgetTurkishVoice()
    }

    private var summary: some View {
        HStack(spacing: 12) {
            ReviewActivitySymbol(font: .title3.weight(.semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Tekrar")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text(verbatim: isStale ? ReviewActivityText.saved : ReviewActivityText.counter(state))
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(Theme.ink2)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: isStale
            ? "Tekrar. \(ReviewActivityText.saved)"
            : "Tekrar, \(ReviewActivityText.spokenCounter(state))"))
    }
}

/// "Devam et" (goes back to the round; not the quiz's "Devam"), drawn like the app's main button
/// (`PrimaryCapsuleButtonStyle`): `.headline` on a filled ink capsule, black by day, white at
/// night and in the always black Dynamic Island. Not a button of its own: a tap anywhere on
/// the activity opens "Tekrar" (`widgetURL`); in the expanded Dynamic Island it is inside a `Link`
/// (`inLink`), the one place Apple documents links in a Live Activity for.
struct ReviewActivityContinueFace: View {
    var fullWidth = false
    /// Inside a `Link`, which already reads as one: no button trait on top.
    var inLink = false

    var body: some View {
        Text(verbatim: "Devam et")
            .font(.headline)
            .lineLimit(1)
            .foregroundStyle(Theme.onPrimary)
            .padding(.horizontal, 20)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: Theme.minHitSize)
            .background {
                Capsule()
                    .fill(Theme.primary)
            }
            .accessibilityAddTraits(inLink ? [] : .isButton)
    }
}

/// The Tekrar tab's symbol: the activity's mark, without a container (HIG Live Activities).
struct ReviewActivitySymbol: View {
    var font: Font = .subheadline.weight(.semibold)

    var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .font(font)
            .foregroundStyle(Theme.ink)
            .accessibilityHidden(true)
    }
}

// MARK: - Dynamic Island

/// Expanded, leading: the symbol and "Tekrar".
struct ReviewActivityIslandTitle: View {
    var body: some View {
        HStack(spacing: 8) {
            ReviewActivitySymbol(font: .headline)
            Text(verbatim: "Tekrar")
                .font(.headline)
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
        }
        .padding(.leading, 4)
        .accessibilityElement(children: .combine)
        .islandColors()
    }
}

/// Expanded, trailing ("Kart 4 / 10") and compact, trailing (`short`: "4/10", without the spaces
/// of terimler's "2 / 5": the compact side is about 52 pt, 28 pt when the island is narrow). It
/// says where the user is, never what is left. When stale: nothing in the expanded island (its
/// bottom says "Cevapların kaydedildi."), and a small check in the compact one, so the island
/// keeps its two sides instead of looking lopsided.
struct ReviewActivityIslandCounter: View {
    let state: ReviewActivityAttributes.ContentState
    let isStale: Bool
    var short = false

    var body: some View {
        if !isStale {
            Text(verbatim: short ? ReviewActivityText.shortCounter(state) : ReviewActivityText.counter(state))
                .font(short ? .subheadline.weight(.semibold) : .headline)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(short ? Theme.ink : Theme.ink2)
                .padding(.trailing, short ? 0 : 4)
                .accessibilityLabel(Text(verbatim: ReviewActivityText.spokenCounter(state)))
                .islandColors()
        } else if short {
            Image(systemName: "checkmark")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .accessibilityLabel(Text(verbatim: ReviewActivityText.saved))
                .islandColors()
        }
    }
}

/// Expanded, bottom: "Devam et" across the island, or "Cevapların kaydedildi." when stale.
struct ReviewActivityIslandBottom: View {
    let isStale: Bool

    var body: some View {
        Group {
            if isStale {
                Text(verbatim: ReviewActivityText.saved)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.ink2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            } else if let url = ReviewActivityAttributes.continueURL {
                Link(destination: url) {
                    ReviewActivityContinueFace(fullWidth: true, inLink: true)
                }
            } else {
                ReviewActivityContinueFace(fullWidth: true)
            }
        }
        .padding(.top, 4)
        .islandColors()
    }
}

/// Compact, leading, and minimal: the symbol.
struct ReviewActivityIslandSymbol: View {
    var body: some View {
        ReviewActivitySymbol()
            .islandColors()
    }
}

/// The activity's Turkish texts, in one place.
enum ReviewActivityText {
    /// Every answer is saved as soon as it is given (ReviewView): leaving loses nothing.
    static let saved = "Cevapların kaydedildi."

    /// "Kart 4 / 10": "/" only in the visible counter (terimler §1).
    static func counter(_ state: ReviewActivityAttributes.ContentState) -> String {
        return "Kart \(state.card) / \(state.total)"
    }

    /// "4/10" for the narrow compact Dynamic Island.
    static func shortCounter(_ state: ReviewActivityAttributes.ContentState) -> String {
        return "\(state.card)/\(state.total)"
    }

    /// VoiceOver reads "/" as "bölü": "Kart 4, toplam 10".
    static func spokenCounter(_ state: ReviewActivityAttributes.ContentState) -> String {
        return "Kart \(state.card), toplam \(state.total)"
    }
}

extension View {
    /// The Dynamic Island is always black: the night tokens and a Turkish voice.
    func islandColors() -> some View {
        environment(\.colorScheme, .dark)
            .widgetTurkishVoice()
    }
}
