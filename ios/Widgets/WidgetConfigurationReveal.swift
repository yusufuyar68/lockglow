import SwiftUI
import AppIntents
import WidgetKit
import os

// "Anlamı gizle" (WidgetConfigurationOptions.swift): the meaning's place shows "Göster"; a tap opens
// the meaning of the word on screen until that word leaves the widget (ogrenme_ilkeleri 2.1, "Önce
// tahmin et"). The tap is kept in a small file in the widget extension's own container, not in the
// App Group: no event reaches the app, so it is never a review and changes no box. Next and the
// rotation are untouched: the next word comes hidden again.
// - One file for all widgets: every widget shows the same word, so a tap opens its meaning on every
//   widget with "Anlamı gizle" (at once, or at that widget's next reload). WidgetKit gives a
//   provider no id of the widget instance to keep them apart.
// - Where the tap would not work the meaning is never hidden: the Lock Screen (no choices there)
//   and StandBy (the phone is locked; `WidgetDisplayOptions.forContainer`).
// - A layout with no room for the 44 pt button shows the meaning instead of leaving the word alone
//   (the small widget's last variants, `widgetMeaningShown()`): a phrase on two lines.
// - While the meaning is hidden the layout has the button's 44 pt instead of the meaning's line, so
//   it may change on "Göster": the small widget's word may be a size step smaller (iPhone SE), the
//   medium widget may leave out the definition or the example until the meaning is open, and the
//   large widget may show a line more or less (LargeWordView.swift) and gets its picture back.

/// "Göster" was tapped for one word: its meaning stays open until `until`, the moment that word
/// leaves the widget (the entry's next change).
struct WidgetMeaningReveal: Codable, Equatable {
    let wordID: Int
    let until: Date

    /// When the entry had no next change (the last entry of a timeline): the longest word change
    /// interval the app offers (4 hours).
    static let fallbackDuration: TimeInterval = 4 * 3600

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "lockglow.widgets",
        category: "reveal"
    )

    /// True when `entry` shows the revealed word before it changed: the entry on screen, never a
    /// later turn of the same word.
    func covers(_ entry: WordEntry) -> Bool {
        return entry.word.id == wordID && entry.date < until
    }

    /// The widget extension's own file (Application Support); nil when the system gives none.
    static var defaultURL: URL? {
        guard let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return directory.appendingPathComponent("widget_meaning_reveal.json")
    }

    /// The last reveal, nil when there is none or the file cannot be read.
    static func load(from url: URL? = WidgetMeaningReveal.defaultURL) -> WidgetMeaningReveal? {
        guard let url, let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetMeaningReveal.self, from: data)
    }

    /// Replaces the last reveal. Written before the intent returns, so the timeline the system
    /// reloads right after it already shows the meaning. Errors are logged and swallowed.
    func save(to url: URL? = WidgetMeaningReveal.defaultURL) {
        guard let url else {
            WidgetMeaningReveal.logger.error("no Application Support directory; reveal not kept")
            return
        }
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try JSONEncoder().encode(self).write(to: url, options: .atomic)
        } catch {
            WidgetMeaningReveal.logger.error("reveal write failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}

/// The "Göster" button. Runs in the widget extension; the system reloads the timeline right after
/// `perform()` returns.
struct ShowMeaningIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Anlamını göster"
    }

    /// Only the widget's own button runs it: not offered in Shortcuts or Spotlight.
    static var isDiscoverable: Bool {
        false
    }

    @Parameter(title: "Kelime kimliği")
    var wordID: Int

    /// When the word leaves the widget, in whole seconds since 1970; 0 when the entry had no next
    /// change.
    @Parameter(title: "Kelime değişimi")
    var untilSeconds: Int

    init() {}

    init(wordID: Int, until: Date?) {
        self.wordID = wordID
        self.untilSeconds = until.map { Int($0.timeIntervalSince1970) } ?? 0
    }

    func perform() async throws -> some IntentResult {
        ShowMeaningIntent.reveal(wordID: wordID, untilSeconds: untilSeconds, now: Date()).save()
        return .result()
    }

    /// The reveal a tap records; without a next change the meaning stays open for
    /// `WidgetMeaningReveal.fallbackDuration`.
    static func reveal(wordID: Int, untilSeconds: Int, now: Date) -> WidgetMeaningReveal {
        let until = untilSeconds > 0
            ? Date(timeIntervalSince1970: TimeInterval(untilSeconds))
            : now.addingTimeInterval(WidgetMeaningReveal.fallbackDuration)
        return WidgetMeaningReveal(wordID: wordID, until: until)
    }
}

/// "Göster" in the meaning's place: a capsule with its title (a text button, not an icon: the
/// meaning of the tap must be clear without a symbol), 34 pt tall inside a 44 pt hit area, with
/// a 1 pt edge because the button fill alone barely stands out from the paper (LockglowTheme,
/// contrast rules: a hand-made capsule gets an edge; `WidgetColors` has no lineStrong, ink2 is
/// darker and follows the tinted modes). The round buttons have no edge: their glyphs mark them.
/// It stops growing at xxLarge, as the round buttons do (HomeWordViews.swift).
/// VoiceOver says "Anlamını göster", Tekrar's name for the same act (docs/tasarim/terimler.md §3).
struct ShowMeaningButton: View {
    let wordID: Int
    /// When the word leaves the widget (`WordEntry.nextChange`).
    let until: Date?
    /// The widget's colors for its rendering mode (HomeWordViews.swift).
    var colors = WidgetColors.tokens

    static let hint = "Önce kendin hatırlamaya çalış. Anlam, kelime değişene kadar açık kalır."

    var body: some View {
        Button(intent: ShowMeaningIntent(wordID: wordID, until: until)) {
            Text(verbatim: "Göster")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colors.ink)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 16)
                .frame(minWidth: Theme.minHitSize, minHeight: 34, maxHeight: 34)
                .background(colors.buttonFill, in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(colors.ink2, lineWidth: 1)
                }
                .frame(height: Theme.minHitSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityLabel(Text(verbatim: "Anlamını göster"))
        .accessibilityHint(Text(verbatim: ShowMeaningButton.hint))
        .accessibilityInputLabels([Text(verbatim: "Anlamını göster"), Text(verbatim: "Göster")])
    }
}

extension View {
    /// The meaning's place on a widget with "Anlamı gizle": the "Göster" button until it is
    /// tapped, then the meaning itself (the view this is applied to). Above the small widget's
    /// button row (`aboveButtonRow`) the button keeps 6 pt free under its hit area: with the
    /// column's 2 pt spacer the hit areas stay at least 8 pt apart (ogrenme_ilkeleri 2.1), and a
    /// word too large for that steps down instead (the layout variants of `SmallWordView`).
    func widgetMeaningReveal(
        _ options: WidgetDisplayOptions,
        wordID: Int,
        until: Date?,
        colors: WidgetColors,
        aboveButtonRow: Bool = false
    ) -> some View {
        modifier(MeaningRevealModifier(
            options: options,
            wordID: wordID,
            until: until,
            colors: colors,
            aboveButtonRow: aboveButtonRow
        ))
    }

    /// Layout variants that show the meaning even with "Anlamı gizle": the last resort before the
    /// word alone, when no variant has room for the "Göster" button.
    func widgetMeaningShown() -> some View {
        environment(\.widgetMeaningShownAnyway, true)
    }
}

private struct MeaningRevealModifier: ViewModifier {
    let options: WidgetDisplayOptions
    let wordID: Int
    let until: Date?
    let colors: WidgetColors
    let aboveButtonRow: Bool
    @Environment(\.widgetMeaningShownAnyway) private var shownAnyway

    @ViewBuilder
    func body(content: Content) -> some View {
        if options.meaningIsHidden && !shownAnyway {
            ShowMeaningButton(wordID: wordID, until: until, colors: colors)
                .padding(.bottom, aboveButtonRow ? 6 : 0)
        } else {
            content
        }
    }
}

private struct WidgetMeaningShownAnywayKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// True in the layout variants that show the meaning whatever "Anlamı gizle" says
    /// (`widgetMeaningShown()`).
    var widgetMeaningShownAnyway: Bool {
        get { self[WidgetMeaningShownAnywayKey.self] }
        set { self[WidgetMeaningShownAnywayKey.self] = newValue }
    }
}
