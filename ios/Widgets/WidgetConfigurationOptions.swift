import SwiftUI
import AppIntents
import WidgetKit

// "Widget'ı Düzenle" (iOS 17 `AppIntentConfiguration`, WordWidget.swift): three choices for each
// Home Screen widget. Every default draws the widget as it was before the choices existed, so the
// widgets already on a screen look the same after the update (they get the defaults).
// - "Anlamı gizle": the meaning waits behind a "Göster" button (WidgetConfigurationReveal.swift)
//   on the small, medium and large widgets alike. Only the Turkish meaning hides, with the large
//   widget's picture of the word (it would answer the guess) until "Göster"; the English word,
//   definition, examples and the large widget's warning stay. Tapping it changes only what the
//   widget shows; it is never a review (`Leitner` sees nothing,
//   ogrenme_ilkeleri 2.1: seeing is not reviewing). The text audit found "kendini sınamak" heavy
//   for an A2 reader (docs/denetim/metin_denetimi_2026-10-22.md), hence the plain name.
// - "Vurgu rengi": the band under the English word, phosphor yellow or one of two highlighter
//   colors whose contrast is measured (`WidgetAccent.tones`, WidgetConfigurationTests).
// - "Örnek cümle": the medium widget's example line (the large widget keeps its examples: they
//   are its point, and it has room).
// The Lock Screen families show none of them: their meaning is never hidden (ogrenme_ilkeleri
// 2.1, ŞART), the system draws their band in its own color, and they have no example. The small
// widget has no example either. The widget plan stays one queue for every widget.
// "Anlamı gizle" hides the meaning of every word, a new one too (then it is a guess, ogrenme_ilkeleri
// 2.1 (b)); 2.1's "Önce tahmin et" keeps new words open, which needs a new/learning mark in the
// widget plan that `WidgetWord` does not have yet. On the small widget "Göster" is a third button,
// in its own row above Dinle and Sonraki with at least 8 pt between the hit areas: 2.1 allows two
// because three do not fit side by side; the coordinator decides on this exception (is5-w-ayar note).

/// The configuration intent of the word widget. The parameter names and the enum's raw values are
/// stored with each placed widget: renaming them resets that choice to its default.
struct WordWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource {
        "Kelime"
    }

    static var description: IntentDescription? {
        IntentDescription("Anlamı gizlersen önce kendin hatırlamaya çalışırsın. Göster'e dokunmak tekrar sayılmaz.")
    }

    @Parameter(title: "Anlamı gizle", default: false)
    var hidesMeaning: Bool

    @Parameter(title: "Vurgu rengi", default: .yellow)
    var accent: WidgetAccent

    @Parameter(title: "Örnek cümle", default: true)
    var showsExample: Bool

    static var parameterSummary: some ParameterSummary {
        When(widgetFamily: .equalTo, .systemSmall) {
            Summary {
                \.$hidesMeaning
                \.$accent
            }
        } otherwise: {
            // The circle is not a family of this widget today: listed so that a later Lock Screen
            // family gets no choices either.
            When(widgetFamily: .oneOf, [.accessoryRectangular, .accessoryInline, .accessoryCircular]) {
                Summary()
            } otherwise: {
                Summary {
                    \.$hidesMeaning
                    \.$accent
                    \.$showsExample
                }
            }
        }
    }
}

/// The band's color on a Home Screen widget. Yellow is the brand's phosphor band; green and pink
/// are highlighter colors in the same light tones, so the word reads the same on all three.
enum WidgetAccent: String, AppEnum {
    case yellow
    case green
    case pink

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Vurgu rengi"
    }

    static var caseDisplayRepresentations: [WidgetAccent: DisplayRepresentation] {
        [
            .yellow: "Sarı",
            .green: "Yeşil",
            .pink: "Pembe",
        ]
    }

    /// sRGB values: `day` behind the lower half of the letters (ink on it, WCAG 2.2), `night` a
    /// line under the word on the night widget and on StandBy's black (non-text, 3:1). Measured
    /// with the WCAG formula (WidgetConfigurationTests; table in the is5-w-ayar note):
    ///   yellow #F5E829 ink 14.0:1, #E9E040 on night surface 12.4:1, on black 15.2:1
    ///   green  #A6F2B4 ink 13.6:1, #7AE6A0 on night surface 11.1:1, on black 13.7:1
    ///   pink   #FFC2E2 ink 11.9:1, #FF9ED3 on night surface 9.0:1, on black 11.1:1
    /// Yellow is `Theme.bandLight` / `bandDark`.
    var tones: (day: UInt32, night: UInt32) {
        switch self {
        case .yellow:
            return (day: 0xF5E829, night: 0xE9E040)
        case .green:
            return (day: 0xA6F2B4, night: 0x7AE6A0)
        case .pink:
            return (day: 0xFFC2E2, night: 0xFF9ED3)
        }
    }

    var bandColors: PhosphorBandColors {
        if self == .yellow {
            return .phosphor
        }
        return PhosphorBandColors(day: tones.day, night: tones.night)
    }
}

/// What one Home Screen widget shows: the person's choices (`WordWidgetConfigurationIntent`) and
/// whether the meaning of the word on screen was opened with "Göster". The views take it as one
/// parameter; `standard` is the widget without choices.
struct WidgetDisplayOptions: Equatable, Sendable {
    /// "Anlamı gizle": the meaning's place shows "Göster" until it is tapped.
    var hidesMeaning = false
    var accent = WidgetAccent.yellow
    /// "Örnek cümle": the medium widget's example line.
    var showsExample = true
    /// "Göster" was tapped for this entry's word (`WidgetMeaningReveal`).
    var meaningRevealed = false

    /// Meaning shown, phosphor yellow, example on: every widget before "Widget'ı Düzenle".
    static let standard = WidgetDisplayOptions()

    /// The meaning's place shows the "Göster" button.
    var meaningIsHidden: Bool {
        return hidesMeaning && !meaningRevealed
    }

    /// The options for a widget with or without its paper (`showsWidgetContainerBackground`).
    /// Without it (StandBy) the phone is locked and a widget button asks for Face ID first, as on
    /// the Lock Screen: the meaning is not hidden there (ogrenme_ilkeleri 2.1, ŞART).
    func forContainer(showsBackground: Bool) -> WidgetDisplayOptions {
        var options = self
        if !showsBackground {
            options.hidesMeaning = false
        }
        return options
    }
}

extension WidgetDisplayOptions {
    init(_ configuration: WordWidgetConfigurationIntent) {
        self.init(
            hidesMeaning: configuration.hidesMeaning,
            accent: configuration.accent,
            showsExample: configuration.showsExample
        )
    }
}

extension View {
    /// The band in the widget's accent (`WidgetAccent`): sets the environment the phosphor band
    /// reads (`phosphorBandColors`).
    func widgetAccent(_ accent: WidgetAccent) -> some View {
        environment(\.phosphorBandColors, accent.bandColors)
    }
}
