import SwiftUI
import WidgetKit
import CoreModels
import Scheduler

// Watch face complications (is5-watch). Static text only, like the phone's Lock Screen families
// (ogrenme_ilkeleri 2.1): the word and its Turkish meaning, never cut; a form that does not fit is
// left out (the meaning first tries its shorter form). The word changes on the hour (`WatchRotation`),
// the same word as in the watch app. Tapping a complication opens the watch app.

@main
struct LockglowWatchWidgetsBundle: WidgetBundle {
    var body: some Widget {
        WatchWordComplication()
    }
}

struct WatchWordComplication: Widget {
    static let kind = "WatchWordComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WatchWordComplication.kind, provider: WatchWordProvider()) { entry in
            WatchComplicationView(entry: entry)
        }
        .configurationDisplayName("Kelime")
        .description("Kadranda her saat yeni bir kelime.")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
            .accessoryCorner,
        ])
    }
}

struct WatchWordEntry: TimelineEntry {
    let date: Date
    let word: WidgetWord
}

/// One entry per hour for two days, from the watch's two small JSON files (or the seed words).
/// Placeholder and snapshot are instant and static: no file access.
struct WatchWordProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchWordEntry {
        return WatchWordEntry(date: Date(), word: WidgetWord.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchWordEntry) -> Void) {
        completion(WatchWordEntry(date: Date(), word: WidgetWord.sample))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchWordEntry>) -> Void) {
        let now = Date()
        let input = WatchStore.loadInput(store: WatchStore.sharedStore())
        let planned = WatchRotation.entries(input: input, now: now, alignmentOffset: WatchStore.alignmentOffset(for: now))
        if planned.isEmpty {
            // No plan and no seed file: the static sample, and another look in an hour.
            let fallback = Timeline(
                entries: [WatchWordEntry(date: now, word: WidgetWord.sample)],
                policy: TimelineReloadPolicy.after(now.addingTimeInterval(WatchRotation.interval))
            )
            completion(fallback)
            return
        }
        let entries = planned.map { WatchWordEntry(date: $0.date, word: $0.word) }
        completion(Timeline(entries: entries, policy: TimelineReloadPolicy.atEnd))
    }
}

struct WatchComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchWordEntry

    var body: some View {
        content
            .containerBackground(for: .widget) {
                WatchTheme.surface
            }
            .watchTurkishVoice()
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryInline:
            WatchInlineWordView(word: entry.word)
        case .accessoryCircular:
            WatchCircularWordView(word: entry.word)
        case .accessoryCorner:
            WatchCornerWordView(word: entry.word)
        default:
            WatchRectangularWordView(word: entry.word)
        }
    }
}

/// What VoiceOver reads for a complication: two elements, so each keeps its own voice (as on the
/// phone's Lock Screen widget): the word with an English voice, then "Türkçesi: …" with a Turkish
/// one. The "·" is not read.
private struct WatchSpokenWord: View {
    let word: WidgetWord

    var body: some View {
        HStack {
            Text(verbatim: word.lemma)
                .watchEnglishVoice()
            if let meaning = WatchGloss.forms(of: word).first {
                Text(verbatim: "Türkçesi: \(meaning)")
                    .watchTurkishVoice()
            }
        }
    }
}

/// Two rows: the word in serif bold and the Turkish meaning under it (its full form, else the
/// shorter one, else none). A word too long for one line wraps instead of being cut; no step
/// shrinks text to fit.
private struct WatchRectangularWordView: View {
    let word: WidgetWord
    @Environment(\.widgetRenderingMode) private var renderingMode

    /// The meaning's color: the watch's secondary label token in full color; on a tinted face the
    /// system flattens colors, so the system's secondary level keeps the word above the meaning.
    private var meaningStyle: AnyShapeStyle {
        if renderingMode == .fullColor {
            return AnyShapeStyle(WatchTheme.ink2)
        }
        return AnyShapeStyle(HierarchicalShapeStyle.secondary)
    }

    var body: some View {
        let forms = WatchGloss.forms(of: word)
        ViewThatFits(in: .vertical) {
            if let full = forms.first {
                rows(meaning: full)
            }
            if forms.count > 1, let short = forms.last {
                rows(meaning: short)
            }
            rows(meaning: nil)
            // A very long phrase: the smaller Footnote style (13 pt, above Apple's 11 pt floor),
            // never a shrunken or cut word; when even that does not fit, the book symbol.
            Text(verbatim: word.lemma)
                .font(.system(.footnote, design: .serif).weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
                .widgetAccentable()
            Image(systemName: "book.closed")
                .font(.title3)
                .widgetAccentable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityRepresentation {
            WatchSpokenWord(word: word)
        }
    }

    private func rows(meaning: String?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(verbatim: word.lemma)
                .font(.system(.headline, design: .serif).weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
                .widgetAccentable()
            if let meaning = meaning {
                Text(verbatim: meaning)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(meaningStyle)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// One line of system text: "word · meaning", then "word · short meaning", then the word alone.
private struct WatchInlineWordView: View {
    let word: WidgetWord

    var body: some View {
        let forms = WatchGloss.forms(of: word)
        ViewThatFits(in: .horizontal) {
            if let full = forms.first {
                Text(verbatim: "\(word.lemma) · \(full)")
            }
            if forms.count > 1, let short = forms.last {
                Text(verbatim: "\(word.lemma) · \(short)")
            }
            Text(verbatim: word.lemma)
        }
        .widgetAccentable()
        .accessibilityRepresentation {
            WatchSpokenWord(word: word)
        }
    }
}

/// The word alone in the circle, at the larger of two text styles it fits whole (Headline, then
/// Footnote, the watch's smallest style; no fixed point sizes); a phrase may take two lines. A word
/// that fits at neither shows the book symbol instead of a cut word.
private struct WatchCircularWordView: View {
    let word: WidgetWord

    private var twoLines: String? {
        let parts = word.lemma.split(separator: " ").map(String.init)
        guard parts.count > 1 else {
            return nil
        }
        // The break that makes the longer line shortest.
        var best: (lines: String, longest: Int)?
        for split in 1..<parts.count {
            let first = parts[..<split].joined(separator: " ")
            let second = parts[split...].joined(separator: " ")
            let longest = max(first.count, second.count)
            if best == nil || longest < best!.longest {
                best = (lines: "\(first)\n\(second)", longest: longest)
            }
        }
        return best?.lines
    }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            ViewThatFits(in: [.horizontal, .vertical]) {
                wordText(word.lemma, style: .headline)
                wordText(word.lemma, style: .footnote)
                if let lines = twoLines {
                    wordText(lines, style: .footnote)
                }
                Image(systemName: "book.closed")
                    .font(.title3)
                    .widgetAccentable()
            }
            .padding(4)
        }
        .accessibilityRepresentation {
            WatchSpokenWord(word: word)
        }
    }

    private func wordText(_ text: String, style: Font.TextStyle) -> some View {
        Text(verbatim: text)
            .font(.system(style, design: .serif).weight(.bold))
            .multilineTextAlignment(.center)
            .fixedSize()
            .widgetAccentable()
    }
}

/// The corner: the book symbol in the small circle and the word along the bezel. The bezel text
/// is the word alone: the system would cut a longer label.
private struct WatchCornerWordView: View {
    let word: WidgetWord

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: "book.closed")
                .font(.title3)
                .widgetAccentable()
        }
        .widgetLabel {
            Text(verbatim: word.lemma)
        }
        .accessibilityRepresentation {
            WatchSpokenWord(word: word)
        }
    }
}
