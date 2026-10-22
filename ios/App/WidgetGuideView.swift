import SwiftUI
import WidgetKit

/// "Widget nasıl eklenir": steps for the Lock Screen and the Home Screen on iOS 26. Button names
/// are the ones in Apple's Turkish iPhone User Guide for iOS 26 ("Özel bir iPhone kilitli ekranı
/// yaratma", "Araç takımlarını ekleme, düzenleme ve silme"), where a widget is called "araç
/// takımı": "Özelleştir", "Araç Takımı Ekle", "Düzenle", "Bitti". The English names follow in one
/// line, for a phone set to English. Shown in the onboarding and under "Ayarlar > Yardım". A small
/// drawing shows where the widget goes (mockup `.gprev`).
struct WidgetGuideContent: View {
    enum Place: Hashable {
        case lockScreen
        case homeScreen
    }

    @State private var place: Place = .lockScreen
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // The UI test taps "Ana ekran" by its label.
            SegmentButtons(
                options: [
                    SegmentOption(value: Place.lockScreen, title: "Kilitli ekran"),
                    SegmentOption(value: Place.homeScreen, title: "Ana ekran"),
                ],
                selection: $place
            )
            WidgetPlacePreview(place: place)
            // Mockup `.steps`: one white group, numbered rows 14 pt apart.
            VStack(alignment: .leading, spacing: 14) {
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
            VStack(alignment: .leading, spacing: 10) {
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
                            .font(.system(.callout, design: .serif))
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

/// A small icon in `ink2` before a short note (mockup `.info`).
private struct GuideNote<Content: View>: View {
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            content()
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        // Not combined: the English names keep their English voice.
        .font(.callout)
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
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
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

/// Where the widget goes (mockup `.gprev`): a drawn Lock Screen or Home Screen with the widget
/// outlined in white dashes. Calm, muted colors: the only yellow is the band of the English word
/// (rule 1). A picture with a fixed size and fixed colors (it shows the phone, whatever the app's
/// appearance and text size); VoiceOver reads one sentence instead.
private struct WidgetPlacePreview: View {
    let place: WidgetGuideContent.Place

    var body: some View {
        ZStack {
            switch place {
            case .lockScreen:
                lockScreen
            case .homeScreen:
                homeScreen
            }
        }
        .padding(14)
        // Both drawings (about 174 and 157 pt) are this tall, so switching does not move the
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
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.92))
            // The rectangular Lock Screen widget: the word on the thin band of a vibrant widget.
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "breakfast")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .phosphorBand(.widget, renderingMode: .vibrant)
                    .padding(.bottom, 3)
                Text(verbatim: "kahvaltı")
                    .font(.system(size: 12.5, weight: .semibold))
                // English is serif (rule 3), as on the real widget.
                Text(verbatim: "first meal of the day")
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .opacity(0.8)
            }
            .lineLimit(1)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
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
                // The small Home Screen widget in full color: the word on its day band.
                VStack(alignment: .leading, spacing: 1) {
                    Text(verbatim: "breakfast")
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .phosphorBand(.widget)
                    Text(verbatim: "kahvaltı")
                        .font(.system(size: 12.5, weight: .bold))
                        .padding(.top, 2)
                    Text(verbatim: "first meal of the day")
                        .font(.system(size: 11, weight: .regular, design: .serif))
                        .foregroundStyle(Color(guideHex: 0x4E555B))
                        .lineLimit(2)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color(guideHex: 0x15181B))
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
        .font(.system(size: 11, weight: .semibold))
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

/// "Ayarlar > Yardım > Widget nasıl eklenir?"
struct WidgetGuideScreen: View {
    var body: some View {
        ScrollView {
            WidgetGuideContent()
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Widget ekleme")
        .navigationBarTitleDisplayMode(.inline)
    }
}
