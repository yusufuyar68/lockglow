import SwiftUI
import UIKit
import CoreModels
import Learning

/// is5-haftalik: the picture "Paylaş" shares from "Geçen hafta" (WeeklyRecapView): last week's
/// words on the light page background (`Theme.bg` by day), 1080 × 1920 px (a phone story). Only
/// words and their meanings (`WeeklyRecap.shareWords`: no personal-topic card, no word the user
/// added); no name, date, day count or any other number. The day look always, whatever the
/// phone's appearance, with the yellow band on the first word only (rule 1); the colors are
/// fixed, so the picture is the same on every phone.
struct WeeklyRecapShareCard: View {
    let words: [WidgetWord]

    /// Points; drawn at scale 3, the picture is 1080 × 1920 px.
    static let size = CGSize(width: 360, height: 640)

    // The day tokens of LockglowTheme (bg, ink, ink2, ink3) as fixed colors: the card is drawn
    // off screen, where a dynamic color could take the phone's night value.
    private static let pageColor = Color(.sRGB, red: 0xF2 / 255, green: 0xF2 / 255, blue: 0xF7 / 255)
    private static let ink = Color(.sRGB, red: 0, green: 0, blue: 0)
    private static let ink2 = Color(.sRGB, red: 0x3C / 255, green: 0x3C / 255, blue: 0x43 / 255)
    private static let ink3 = Color(.sRGB, red: 0x63 / 255, green: 0x63 / 255, blue: 0x66 / 255)

    // Text styles at the default text size (`render` fixes it at `.large`): Title 28 for the
    // words, Headline 17 for the title, Callout 16 for the meanings and the name.
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: "Geçen haftanın kelimeleri")
                .font(.headline)
                .foregroundStyle(WeeklyRecapShareCard.ink2)
            Spacer(minLength: 24)
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(words.prefix(WeeklyRecap.shareWordLimit).enumerated()), id: \.element.id) { index, word in
                    VStack(alignment: .leading, spacing: 4) {
                        lemma(word.lemma, banded: index == 0)
                        if let gloss = word.glossTR, !gloss.isEmpty {
                            Text(verbatim: gloss)
                                .font(.callout.weight(.medium))
                                .foregroundStyle(WeeklyRecapShareCard.ink2)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
            }
            Spacer(minLength: 24)
            Text(verbatim: "Lockglow")
                .font(.callout.weight(.semibold))
                .foregroundStyle(WeeklyRecapShareCard.ink3)
        }
        // Story apps cover about 250 px at the top and the bottom: the text stays clear of them.
        .padding(.horizontal, 32)
        .padding(.vertical, 72)
        .frame(width: WeeklyRecapShareCard.size.width, height: WeeklyRecapShareCard.size.height, alignment: .topLeading)
        .background(WeeklyRecapShareCard.pageColor)
    }

    @ViewBuilder
    private func lemma(_ text: String, banded: Bool) -> some View {
        let word = Text(verbatim: text)
            .font(.system(.title, design: .serif).weight(.bold))
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
