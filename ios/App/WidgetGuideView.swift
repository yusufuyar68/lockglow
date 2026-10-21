import SwiftUI
import WidgetKit

/// "Widget nasıl eklenir": steps for the Lock Screen and the Home Screen on iOS 26. Button names
/// are the ones in Apple's Turkish iPhone User Guide for iOS 26, where a widget is called
/// "araç takımı" ("Düzenle", "Araç Takımı Ekle", "Özelleştir", "Bitti"). Shown in the onboarding
/// and under "Ayarlar > Yardım". A small drawing shows where the widget goes (mockup `.gprev`).
struct WidgetGuideContent: View {
    enum Place: Hashable {
        case lockScreen
        case homeScreen
    }

    @State private var place: Place = .lockScreen

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
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
            // Mockup `.info`.
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
                Text(note)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(.callout)
            .padding(.horizontal, 2)
        }
    }

    /// Markdown (bold button names), read through `LocalizedStringKey`.
    private var steps: [String] {
        switch place {
        case .lockScreen:
            return [
                "Yan düğmeye bas ve kilitli ekranı aç. Telefonun kilidi Face ID ya da parolayla açılmış olmalı.",
                "Kilitli ekranda boş bir yeri basılı tut. Parola sorarsa gir.",
                "Alttaki **Özelleştir**'e (Customize) dokun. Seçmeni isterse kilitli ekranı seç.",
                "**Araç Takımı Ekle**'ye (Add Widgets) dokun.",
                "Listede **Lockglow**'u bul ve dikdörtgen widget'a dokun. Tek satırlık widget için bunun yerine saatin üstündeki tarih satırına dokun.",
                "**Bitti**'ye (Done) dokun.",
            ]
        case .homeScreen:
            return [
                "Ana ekranda boş bir yeri basılı tut. Uygulamalar titremeye başlar.",
                "Ekranın üstündeki **Düzenle**'ye (Edit), sonra **Araç Takımı Ekle**'ye (Add Widget) dokun.",
                "Arama kutusuna **Lockglow** yaz ve ona dokun.",
                "Boyutlar arasında kaydır (küçük ya da orta). İstediğin boyutta **Araç Takımı Ekle**'ye dokun.",
                "Widget'ı istediğin yere taşı, sonra **Bitti**'ye (Done) dokun.",
            ]
        }
    }

    private var note: String {
        switch place {
        case .lockScreen:
            return "iPhone'da widget'ın adı \"araç takımı\". Telefonun dili İngilizceyse parantezdeki adlara bak. Kilitli ekrandaki widget'ta düğme yok; kelime kendiliğinden değişir."
        case .homeScreen:
            return "iPhone'da widget'ın adı \"araç takımı\". Telefonun dili İngilizceyse parantezdeki adlara bak. Küçük ve orta boyda \"Sonraki\", \"Biliyorum\" ve hoparlör düğmeleri var."
        }
    }
}

/// A numbered step (mockup `.step`): an ink circle with the number, then the sentence.
private struct StepRow: View {
    let number: Int
    let text: String
    @ScaledMetric(relativeTo: .body) private var circleSize: CGFloat = 28

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
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
/// outlined in yellow dashes. A picture with a fixed size and fixed colors (it shows the phone,
/// whatever the app's appearance); VoiceOver reads one sentence instead.
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
        .frame(maxWidth: .infinity, minHeight: 168)
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
        VStack(spacing: 8) {
            Text(verbatim: "9:41")
                .font(.system(size: 50, weight: .bold))
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
            .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(PreviewOutline(cornerRadius: 13))
            .padding(.top, 2)
            HStack(spacing: 4) {
                Image(systemName: "chevron.up")
                Text(verbatim: "Lockglow burada")
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color(guideHex: 0xF1EA6A))
            .padding(.top, 4)
        }
        // The Lock Screen is dark: the band's thin line takes the white of the text.
        .environment(\.colorScheme, .dark)
    }

    // MARK: Home Screen

    private var homeScreen: some View {
        HStack(spacing: 18) {
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
            .frame(width: 112, height: 112, alignment: .topLeading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(PreviewOutline(cornerRadius: 22))
            .environment(\.colorScheme, .light)
            VStack(spacing: 10) {
                appRow([0xE58A7E, 0xE9C46A, 0x7FB3D5, 0x86C29F])
                appRow([0x9AA0A6, 0xD98FA8, 0x6E9BD1, 0xE9D27A])
            }
        }
    }

    private func appRow(_ colors: [UInt32]) -> some View {
        HStack(spacing: 10) {
            ForEach(colors, id: \.self) { color in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(guideHex: color).opacity(0.9))
                    .frame(width: 30, height: 30)
            }
        }
    }

    // MARK: Wallpaper

    @ViewBuilder
    private var wallpaper: some View {
        switch place {
        case .lockScreen:
            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: Color(guideHex: 0x1D2630), location: 0),
                        .init(color: Color(guideHex: 0x0C1014), location: 0.8),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                RadialGradient(
                    colors: [Theme.bandDark.opacity(0.26), Color.clear],
                    center: UnitPoint(x: 0.3, y: 0),
                    startRadius: 0,
                    endRadius: 190
                )
            }
        case .homeScreen:
            LinearGradient(
                stops: [
                    .init(color: Color(guideHex: 0xA7C7D9), location: 0),
                    .init(color: Color(guideHex: 0x5E7E96), location: 0.6),
                    .init(color: Color(guideHex: 0x2D3D4C), location: 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

/// The dashed yellow outline 4 pt around the drawn widget (mockup `outline: 2px dashed`).
private struct PreviewOutline: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius + 6, style: .continuous)
            .strokeBorder(Theme.bandDark, style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
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
