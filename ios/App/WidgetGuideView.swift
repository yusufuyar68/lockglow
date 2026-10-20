import SwiftUI

/// "Widget nasıl eklenir": steps for the Lock Screen and the Home Screen on iOS 26. Button names
/// are the ones in Apple's Turkish iPhone User Guide for iOS 26, where a widget is called
/// "araç takımı" ("Düzenle", "Araç Takımı Ekle", "Özelleştir", "Bitti"). Shown in the onboarding
/// and under "Ayarlar > Yardım".
struct WidgetGuideContent: View {
    enum Place: Hashable {
        case lockScreen
        case homeScreen
    }

    @State private var place: Place = .lockScreen

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SegmentButtons(
                options: [
                    SegmentOption(value: Place.lockScreen, title: "Kilitli ekran"),
                    SegmentOption(value: Place.homeScreen, title: "Ana ekran"),
                ],
                selection: $place
            )
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    StepRow(number: index + 1, text: step)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )
            Label {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(Palette.ink2)
            } icon: {
                Image(systemName: "info.circle")
                    .foregroundStyle(Palette.glowInk)
            }
        }
    }

    /// Markdown (bold button names), read through `LocalizedStringKey`.
    private var steps: [String] {
        switch place {
        case .lockScreen:
            return [
                "Yan düğmeye bas ve kilitli ekranı aç. Telefonun kilidi Face ID ya da parolayla açılmış olmalı.",
                "Kilitli ekranda boş bir yeri basılı tut. Parola sorarsa gir.",
                "Alttaki **Özelleştir**'e dokun. Seçmeni isterse kilitli ekranı seç.",
                "**Araç Takımı Ekle**'ye dokun.",
                "Listede **Lockglow**'u bul ve bir widget'a dokun.",
                "**Bitti**'ye dokun.",
            ]
        case .homeScreen:
            return [
                "Ana ekranda boş bir yeri basılı tut. Uygulamalar titremeye başlar.",
                "Ekranın üstündeki **Düzenle**'ye, sonra **Araç Takımı Ekle**'ye dokun.",
                "Arama kutusuna **Lockglow** yaz ve ona dokun.",
                "Boyutlar arasında kaydır. İstediğin boyutta **Araç Takımı Ekle**'ye dokun.",
                "Widget'ı istediğin yere taşı, sonra **Bitti**'ye dokun.",
            ]
        }
    }

    private var note: String {
        switch place {
        case .lockScreen:
            return "iPhone'da widget'ın adı \"araç takımı\". Kilitli ekrandaki widget'ta düğme yok; kelime kendiliğinden değişir."
        case .homeScreen:
            return "iPhone'da widget'ın adı \"araç takımı\". Küçük ve orta boyda \"Sonraki\" ve \"Biliyorum\" düğmeleri var."
        }
    }
}

private struct StepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(number)")
                .font(.subheadline.weight(.heavy))
                .fontDesign(.rounded)
                .foregroundStyle(Palette.onGlow)
                .frame(minWidth: 28, minHeight: 28)
                .background(Circle().fill(Palette.glow))
                .accessibilityHidden(true)
            Text(LocalizedStringKey(text))
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Adım \(number): ") + Text(LocalizedStringKey(text)))
    }
}

/// "Ayarlar > Yardım > Widget nasıl eklenir?"
struct WidgetGuideScreen: View {
    var body: some View {
        ScrollView {
            WidgetGuideContent()
                .padding(16)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Widget ekleme")
        .navigationBarTitleDisplayMode(.inline)
    }
}
