import SwiftUI
import UIKit
import CoreModels
import Learning

/// is5-haftalik: the picture "Paylaş" shares from "Geçen hafta" (WeeklyRecapView): last week's
/// words on paper, 1080 × 1920 px (a phone story). Only words and their meanings
/// (`WeeklyRecap.shareWords`: no personal-topic card, no word the user added); no name, date,
/// day count or any other number. The day look always, whatever the phone's appearance, with the
/// yellow band on the first word only (rule 1); the colors are fixed, so the picture is the same
/// on every phone.
struct WeeklyRecapShareCard: View {
    let words: [WidgetWord]

    /// Points; drawn at scale 3, the picture is 1080 × 1920 px.
    static let size = CGSize(width: 360, height: 640)

    // The day tokens of LockglowTheme (bg, ink, ink2, ink3) as fixed colors: the card is drawn
    // off screen, where a dynamic color could take the phone's night value.
    private static let paper = Color(.sRGB, red: 0xF3 / 255, green: 0xF3 / 255, blue: 0xEE / 255)
    private static let ink = Color(.sRGB, red: 0x15 / 255, green: 0x18 / 255, blue: 0x1B / 255)
    private static let ink2 = Color(.sRGB, red: 0x47 / 255, green: 0x4E / 255, blue: 0x54 / 255)
    private static let ink3 = Color(.sRGB, red: 0x62 / 255, green: 0x6A / 255, blue: 0x71 / 255)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: "Geçen haftanın kelimeleri")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WeeklyRecapShareCard.ink2)
            Spacer(minLength: 24)
            VStack(alignment: .leading, spacing: 18) {
                ForEach(Array(words.prefix(WeeklyRecap.shareWordLimit).enumerated()), id: \.element.id) { index, word in
                    VStack(alignment: .leading, spacing: 4) {
                        lemma(word.lemma, banded: index == 0)
                        if let gloss = word.glossTR, !gloss.isEmpty {
                            Text(verbatim: gloss)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(WeeklyRecapShareCard.ink2)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
            }
            Spacer(minLength: 24)
            Text(verbatim: "Lockglow")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(WeeklyRecapShareCard.ink3)
        }
        // Story apps cover about 250 px at the top and the bottom: the text stays clear of them.
        .padding(.horizontal, 32)
        .padding(.vertical, 72)
        .frame(width: WeeklyRecapShareCard.size.width, height: WeeklyRecapShareCard.size.height, alignment: .topLeading)
        .background(WeeklyRecapShareCard.paper)
    }

    @ViewBuilder
    private func lemma(_ text: String, banded: Bool) -> some View {
        let word = Text(verbatim: text)
            .font(Theme.Fonts.englishWord(size: 30))
            .foregroundStyle(WeeklyRecapShareCard.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        if banded {
            // The band is measured from the text's own frame: right after the font modifiers.
            word.phosphorBand()
        } else {
            word
        }
    }

    /// The card as a picture, or nil without a word to show. Main thread (`ImageRenderer`).
    @MainActor
    static func render(words: [WidgetWord]) -> UIImage? {
        guard !words.isEmpty else {
            return nil
        }
        let card = WeeklyRecapShareCard(words: words)
            // Day look and the default text size: the same picture on every phone.
            .environment(\.colorScheme, .light)
            .environment(\.dynamicTypeSize, .large)
        let renderer = ImageRenderer(content: card)
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = 3
        renderer.isOpaque = true
        return renderer.uiImage
    }
}

#Preview("Paylaşım kartı") {
    WeeklyRecapShareCard(words: WeeklyRecapPreview.recap.shareWords(from: WeeklyRecapPreview.words))
}
