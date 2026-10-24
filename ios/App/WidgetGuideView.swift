import SwiftUI
import WidgetKit
import CoreModels

/// "Widget nasıl eklenir": steps for the Lock Screen and the Home Screen on iOS 26. Button names
/// are the ones in Apple's Turkish iPhone User Guide for iOS 26 ("Özel bir iPhone kilitli ekranı
/// yaratma", "Araç takımlarını ekleme, düzenleme ve silme"), where a widget is called "araç
/// takımı": "Özelleştir", "Araç Takımı Ekle", "Düzenle", "Bitti". The English names follow in one
/// line, for a phone set to English. Shown in the onboarding and under "Ayarlar > Yardım". A small
/// drawing shows where the widget goes (mockup `.gprev`), with the user's own word on it (§2.8).
struct WidgetGuideContent: View {
    enum Place: Hashable {
        case lockScreen
        case homeScreen
    }

    /// The word on the drawn widget: in the onboarding the first word of the chosen level and
    /// topics, later the word the widget shows now. Nil (no words loaded): "breakfast".
    var word: WidgetWord? = nil

    @State private var place: Place = .lockScreen
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // The UI test taps "Ana ekran" by its label (XCUITest lists the segments of a
            // segmented control as buttons too).
            if dynamicTypeSize.isAccessibilitySize {
                // At the largest text sizes the native control would cut "Kilitli ekran" with
                // "…": the buttons stack vertically instead.
                SegmentButtons(
                    options: [
                        SegmentOption(value: Place.lockScreen, title: "Kilitli ekran"),
                        SegmentOption(value: Place.homeScreen, title: "Ana ekran"),
                    ],
                    selection: $place
                )
                // Named like the option groups of "Ayarlar"; the two buttons keep their own names.
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Nereye ekleyeceksin?")
            } else {
                // The standard iOS segmented control (HIG: standard controls).
                Picker("Nereye ekleyeceksin?", selection: $place) {
                    Text("Kilitli ekran").tag(Place.lockScreen)
                    Text("Ana ekran").tag(Place.homeScreen)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            WidgetPlacePreview(place: place, sample: WidgetPreviewSample(word: word))
            // Mockup `.steps`: one white group, numbered rows 16 pt apart.
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    StepRow(number: index + 1, text: step)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous)
                    .strokeBorder(Theme.line, lineWidth: 1)
            )
            // Mockup `.info`: what iPhone calls a widget, the one-line Lock Screen widget
            // (`accessoryInline`, in the date line), and the English button names.
            VStack(alignment: .leading, spacing: 8) {
                GuideNote(systemImage: "info.circle") {
                    Text(verbatim: "iPhone widget'a “araç takımı” der.")
                        .foregroundStyle(Theme.ink)
                }
                if place == .lockScreen {
                    GuideNote(systemImage: "text.alignleft") {
                        Text(verbatim: "Tek satırlık widget için 3. adımda saatin üstündeki tarihe dokun.")
                            .foregroundStyle(Theme.ink)
                    }
                }
                GuideNote(systemImage: "globe") {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: "Telefonun dili İngilizceyse:")
                            .foregroundStyle(Theme.ink2)
                        // English is serif (rule 3) and read with the English voice.
                        Text(verbatim: englishNames.joined(separator: ", "))
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(Theme.ink)
                            .englishVoice()
                    }
                }
            }
            .padding(.horizontal, 2)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: place)
    }

    /// Markdown (bold button names), read through `LocalizedStringKey`.
    private var steps: [String] {
        switch place {
        case .lockScreen:
            return [
                "Kilitli ekranda boş bir yeri **basılı tut**. Parola sorarsa gir.",
                "Alttaki **Özelleştir**'e dokun. Sorarsa kilitli ekranı seç.",
                "**Araç Takımı Ekle**'ye dokun.",
                "Listeden **Lockglow**'u seç ve widget'a dokun.",
                "**Bitti**'ye dokun.",
            ]
        case .homeScreen:
            return [
                "Ana ekranda boş bir yeri **basılı tut**. Uygulamalar titrer.",
                "Üstteki **Düzenle**'ye, sonra **Araç Takımı Ekle**'ye dokun.",
                "**Lockglow**'u ara ve ona dokun.",
                "Küçük ya da orta boyu seç. **Araç Takımı Ekle**'ye dokun.",
                "Widget'ı yerine taşı, **Bitti**'ye dokun.",
            ]
        }
    }

    /// The same buttons on a phone set to English, in the order of the steps.
    private var englishNames: [String] {
        switch place {
        case .lockScreen:
            return ["Customize", "Add Widgets", "Done"]
        case .homeScreen:
            return ["Edit", "Add Widget", "Done"]
        }
    }
}

/// A small icon in `ink2` before a short note (mockup `.info`), `.subheadline` (15 pt: with the
/// 17 pt steps and the system's segmented control the page keeps few sizes; the drawing is a picture).
private struct GuideNote<Content: View>: View {
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            content()
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        // Not combined: the English names keep their English voice.
        .font(.subheadline)
    }
}

/// A numbered step (mockup `.step`): an ink circle with the number, then the sentence. At the
/// largest text sizes the number stands above the sentence, so the sentence keeps the width.
private struct StepRow: View {
    let number: Int
    let text: String
    @ScaledMetric(relativeTo: .body) private var circleSize: CGFloat = 28
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
        layout {
            Text(verbatim: "\(number)")
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Theme.bg)
                .frame(minWidth: circleSize, minHeight: circleSize)
                .background(Circle().fill(Theme.ink))
                .accessibilityHidden(true)
            Text(LocalizedStringKey(text))
                .font(.body)
                .foregroundStyle(Theme.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Adım \(number): ") + Text(LocalizedStringKey(text)))
    }
}

/// What the drawn widget shows, as the real Lock Screen and small widgets do: the word and its
/// Turkish meaning, nothing else (ogrenme_ilkeleri 2.1). The short form of a long meaning fits the
/// small drawing best. A sensitive word never reaches the widget (`QueueComposer`), so the drawing
/// shows "breakfast" instead.
private struct WidgetPreviewSample {
    let lemma: String
    let meaning: String?

    init(word: WidgetWord?) {
        guard let word = word, !word.lemma.isEmpty, !word.isSensitive else {
            lemma = "breakfast"
            meaning = "kahvaltı"
            return
        }
        lemma = word.lemma
        meaning = [word.glossShortTR, word.glossTR]
            .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty }
    }
}

/// Where the widget goes (mockup `.gprev`): a drawn Lock Screen or Home Screen with the widget
/// outlined in white dashes. Calm, muted colors: the only yellow is the band of the English word
/// (rule 1). A picture with a fixed size and fixed colors (it shows the phone, whatever the app's
/// appearance and text size): its text uses the Dynamic Type styles (`.largeTitle` clock,
/// `.subheadline` word, `.caption` meaning, `.caption2` pointer) at the default text size
/// (`dynamicTypeSize(.large)`), so the drawing keeps its proportions; VoiceOver reads one
/// sentence instead. A long word or meaning
/// shrinks to fit the drawing ("Could you tell me the way to" fits); only a very long word of the
/// user's own may still be cut.
private struct WidgetPlacePreview: View {
    let place: WidgetGuideContent.Place
    let sample: WidgetPreviewSample

    var body: some View {
        ZStack {
            switch place {
            case .lockScreen:
                lockScreen
            case .homeScreen:
                homeScreen
            }
        }
        // A picture: the text styles at their default sizes (34, 15, 12 and 11 pt), whatever
        // the text size of the phone.
        .dynamicTypeSize(.large)
        .padding(14)
        // Both drawings (about 167 and 157 pt) are this tall, so switching does not move the
        // steps below.
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(wallpaper)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilityText))
        .accessibilityAddTraits(.isImage)
    }

    private var accessibilityText: String {
        switch place {
        case .lockScreen:
            return "Örnek: kilitli ekranda saatin altında Lockglow widget'ı"
        case .homeScreen:
            return "Örnek: ana ekranda küçük Lockglow widget'ı"
        }
    }

    // MARK: Lock Screen

    private var lockScreen: some View {
        VStack(spacing: 6) {
            Text(verbatim: "9:41")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.white.opacity(0.92))
            // The rectangular Lock Screen widget: the word on the thin band of a vibrant widget,
            // the meaning under it. English is serif (rule 3), as on the real widget.
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: sample.lemma)
                    .font(.system(.subheadline, design: .serif).weight(.bold))
                    .minimumScaleFactor(0.45)
                    .phosphorBand(.widget, renderingMode: .vibrant)
                    .padding(.bottom, 4)
                if let meaning = sample.meaning {
                    Text(verbatim: meaning)
                        .font(.caption.weight(.semibold))
                        .minimumScaleFactor(0.7)
                        .opacity(0.85)
                }
            }
            .lineLimit(1)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .frame(width: 150, alignment: .leading)
            .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(PreviewOutline(cornerRadius: 13))
            .padding(.top, 4)
            pointer
                .padding(.top, 6)
        }
        // The Lock Screen is dark: the band's thin line takes the white of the text.
        .environment(\.colorScheme, .dark)
    }

    // MARK: Home Screen

    private var homeScreen: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 8) {
                // The small Home Screen widget in full color: the word on its day band and the
                // meaning under it.
                VStack(alignment: .leading, spacing: 1) {
                    Text(verbatim: sample.lemma)
                        .font(.system(.subheadline, design: .serif).weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.45)
                        .phosphorBand(.widget)
                    if let meaning = sample.meaning {
                        Text(verbatim: meaning)
                            .font(.caption.weight(.bold))
                            .lineLimit(3)
                            .minimumScaleFactor(0.8)
                            .padding(.top, 4)
                    }
                    Spacer(minLength: 0)
                }
                // The widget's day ink (Theme.ink by day, label black since 2026-10-24).
                .foregroundStyle(Color(guideHex: 0x000000))
                .padding(11)
                .frame(width: 104, height: 104, alignment: .topLeading)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(PreviewOutline(cornerRadius: 22))
                .environment(\.colorScheme, .light)
                pointer
                    .padding(.top, 4)
            }
            // Plain app icons: three by three, as tall as the widget.
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.white.opacity(0.26))
                                .frame(width: 28, height: 28)
                        }
                    }
                }
            }
        }
    }

    // MARK: Parts

    /// "^ Lockglow burada" under the drawn widget.
    private var pointer: some View {
        HStack(spacing: 4) {
            Image(systemName: "chevron.up")
            Text(verbatim: "Lockglow burada")
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(Color.white.opacity(0.85))
        .lineLimit(1)
        .fixedSize()
    }

    @ViewBuilder
    private var wallpaper: some View {
        switch place {
        case .lockScreen:
            LinearGradient(
                stops: [
                    .init(color: Color(guideHex: 0x2B3238), location: 0),
                    .init(color: Color(guideHex: 0x13171A), location: 0.85),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .homeScreen:
            LinearGradient(
                stops: [
                    .init(color: Color(guideHex: 0x7D8C96), location: 0),
                    .init(color: Color(guideHex: 0x4D5A63), location: 0.6),
                    .init(color: Color(guideHex: 0x2E363C), location: 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

/// The dashed white outline 6 pt around the drawn widget (mockup `outline: 2px dashed`).
private struct PreviewOutline: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius + 6, style: .continuous)
            .strokeBorder(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            .padding(-6)
    }
}

private extension Color {
    /// An sRGB color from `0xRRGGBB`, for the fixed colors of the drawn phone.
    init(guideHex hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

extension AppModel {
    /// The word the widget guide draws after the onboarding: the one the Lock Screen widget shows
    /// now, otherwise the first word of the deck.
    var widgetGuideWord: WidgetWord? {
        return lockScreenWordID.flatMap { word(id: $0) } ?? firstDeckWord()
    }
}

/// "Ayarlar > Yardım > Widget nasıl eklenir?"
struct WidgetGuideScreen: View {
    /// The word on the drawn widget (`WidgetGuideContent.word`).
    var word: WidgetWord? = nil

    var body: some View {
        ScrollView {
            WidgetGuideContent(word: word)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Widget ekleme")
        .navigationBarTitleDisplayMode(.inline)
    }
}
