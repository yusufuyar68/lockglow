import SwiftUI
import CoreModels

// Pieces of a card's detail (from `CardDetail`) shared by the feed and the "Tekrar" cards.
// Card text is shown verbatim (String, not LocalizedStringKey): no lookup, no Markdown.

/// An English example with its Turkish translation under it, and a speaker button that reads
/// the English sentence aloud.
struct ExampleRow: View {
    let example: CardDetail.Example

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                Text(example.en)
                    .font(.body)
                    .italic()
                if let tr = example.tr {
                    Text(tr)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            SpeakButton(text: example.en, accessibilityName: "Cümleyi dinle")
        }
    }
}

/// "Dikkat" box: a mistake Turkish speakers typically make with this word, and the right form.
/// Labelled in words ("Yanlış", "Doğru"), so the meaning never depends on color.
struct MistakeBox: View {
    let mistake: CardDetail.Mistake

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Dikkat", systemImage: "exclamationmark.triangle")
                .font(.subheadline.weight(.semibold))
            Text("Yanlış: " + mistake.wrong)
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("Doğru: " + mistake.right)
                .font(.callout.weight(.semibold))
            Text(mistake.why)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
