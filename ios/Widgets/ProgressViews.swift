import SwiftUI
import WidgetKit
import SharedState

// The progress widget's Lock Screen families (ogrenme_ilkeleri 2.1): information only, no buttons
// (they would not work while the device is locked) and the same calm tone whatever the numbers.
// As on the word widget, the system draws the background and the views bring only opaque grays
// (`WidgetColors.lockScreen`): white for what matters, a darker gray for the rest, never opacity.
// Text is shown whole or not at all (no "…"), and every view is one VoiceOver element with a
// whole Turkish sentence (`ProgressText`).

/// Today's new-word goal as a ring (the "Tekrar" start screen's `GoalRing`): a dark gray track and
/// a white arc for the words recalled today. In the middle a book; once a word is done, a small
/// book over the counter "3/5" (the done words white, "/5" gray, as in the app); a check once the
/// goal is met. No "0": before the first word the ring is the track and the book. The family is
/// 72 x 72 pt (68 x 68 on an iPhone SE). Its type is Apple's text styles (the counter `.callout`
/// bold, 16 pt; the small book `.caption`, the symbol alone `.title2`): they follow smaller text
/// sizes and stop growing at the default size, where the ring's middle still holds the widest
/// counter ("19/20").
struct ProgressCircularView: View {
    let entry: ProgressEntry
    private var colors: WidgetColors { WidgetColors.lockScreen }

    static let lineWidth: CGFloat = 6

    var body: some View {
        let fraction = entry.status?.goalFraction ?? 0
        ZStack {
            Circle()
                .inset(by: ProgressCircularView.lineWidth / 2)
                .stroke(colors.buttonFill, lineWidth: ProgressCircularView.lineWidth)
            if fraction > 0 {
                Circle()
                    .inset(by: ProgressCircularView.lineWidth / 2)
                    .trim(from: 0, to: fraction)
                    .stroke(colors.ink, style: StrokeStyle(lineWidth: ProgressCircularView.lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .widgetAccentable()
            }
            if let counter = ProgressText.goalCounter(entry.status) {
                VStack(spacing: 1) {
                    Image(systemName: "character.book.closed")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(colors.ink2)
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(verbatim: counter.done)
                            .foregroundStyle(colors.ink)
                            .widgetAccentable()
                        Text(verbatim: counter.goal)
                            .foregroundStyle(colors.ink2)
                    }
                    .font(.callout.weight(.bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize()
                }
            } else {
                Image(systemName: ProgressText.goalSymbol(entry.status))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(colors.ink)
                    .widgetAccentable()
            }
        }
        // The ring does not grow with the text size: its middle holds "19/20" at the default size.
        .dynamicTypeSize(...DynamicTypeSize.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: ProgressText.goalSpoken(entry.status)))
        .widgetTurkishVoice()
    }
}

/// "Sıradaki": two rows, never a third (ogrenme_ilkeleri 2.1). First, in white: when the next
/// review is ("Sıradaki tekrar: bugün 21:40", "… şimdi"); second, in the darker gray: how many
/// words are in line today ("Bugün 6 kelime sırada", at most "10+"). The family is 160 x 72 pt
/// (153 x 68 on an iPhone SE). Each row shortens step by step ("Tekrar: 21:40"); at the largest
/// text sizes, when the rows no longer fit, they are shown at the default size, and as a last
/// resort the first row's shortest form alone.
struct ProgressRectangularView: View {
    let entry: ProgressEntry
    var calendar = Calendar.current
    private var colors: WidgetColors { WidgetColors.lockScreen }

    var body: some View {
        let rows = ProgressText.rectangular(entry.status, calendar: calendar)
        ViewThatFits(in: .vertical) {
            variant(rows, first: .headline, second: .subheadline.weight(.semibold))
            variant(rows, first: .subheadline.weight(.semibold), second: .subheadline.weight(.semibold))
            variant(rows, first: .subheadline.weight(.semibold), second: .footnote.weight(.semibold))
            variant(rows, first: .headline, second: .subheadline.weight(.semibold))
                .dynamicTypeSize(...DynamicTypeSize.large)
            variant(rows, first: .subheadline.weight(.semibold), second: .footnote.weight(.semibold))
                .dynamicTypeSize(...DynamicTypeSize.large)
            // Every first row has a short last form ("Tekrar: 21:40", "Tekrar: yarın", "Lockglow").
            Text(verbatim: rows.first.last ?? "")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colors.ink)
                .lineLimit(1)
                .widgetAccentable()
                .dynamicTypeSize(...DynamicTypeSize.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: rows.spoken))
        .widgetTurkishVoice()
    }

    /// Both rows in these typefaces, each the first of its versions that fits whole; the variant
    /// is passed over when a row fits in none (`WidgetFittingText`).
    private func variant(_ rows: ProgressText.Rows, first: Font, second: Font) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            WidgetFittingText(candidates: rows.first.map { [$0] }, typeface: first, color: colors.ink)
                .widgetAccentable()
            if !rows.second.isEmpty {
                WidgetFittingText(candidates: rows.second.map { [$0] }, typeface: second, color: colors.ink2)
            }
        }
    }
}

/// One line of system text (the family ignores fonts): the rectangular family's first row
/// ("Sıradaki tekrar: bugün 21:40" → "Tekrar: 21:40"), or the daily goal for a new user.
struct ProgressInlineView: View {
    let entry: ProgressEntry
    var calendar = Calendar.current

    var body: some View {
        let line = ProgressText.inline(entry.status, calendar: calendar)
        let slots = WidgetFit.slots(line.versions)
        ViewThatFits(in: .horizontal) {
            Text(verbatim: slots[0])
            Text(verbatim: slots[1])
            Text(verbatim: slots[2])
            Text(verbatim: slots[3])
            Text(verbatim: slots[4])
            Text(verbatim: slots[5])
        }
        // The inline line is one system row of fixed height; like the ring it does not grow past
        // the default size (ViewThatFits only measures the width, so a taller line would be cut).
        .dynamicTypeSize(...DynamicTypeSize.large)
        .widgetAccentable()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: line.spoken))
        .widgetTurkishVoice()
    }
}
