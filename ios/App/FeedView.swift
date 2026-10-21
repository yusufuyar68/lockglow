import SwiftUI
import CoreModels

/// Vertical paging feed: one full-page card per word (iOS 17 scroll APIs).
struct FeedView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var scrolledWordID: Int?

    var body: some View {
        if model.words.isEmpty {
            emptyState
        } else {
            pager
        }
    }

    private var pager: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(model.words) { word in
                    WordCardView(word: word, detail: model.detail(for: word))
                        .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrolledWordID)
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var emptyState: some View {
        switch model.contentSource {
        case .loading:
            ProgressView()
        default:
            ContentUnavailableView(
                "İçerik bulunamadı",
                systemImage: "tray",
                description: Text("content.sqlite ve seed_words.json pakete eklenmemiş.")
            )
        }
    }
}

/// Reading order for an A2 learner: the word, the Turkish meaning (large), then the simple
/// English definition, then the example with its Turkish translation, then one typical mistake.
/// `detail` is nil for seed words: the card then shows the example without a translation.
/// Only the first example and the first mistake are shown so that a page never overflows.
/// `showsSay: false` hides the microphone (a card shown where no permission prompt may appear).
struct WordCardView: View {
    let word: WidgetWord
    let detail: CardDetail?
    var showsSay = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 4) {
                Text(word.lemma)
                    .font(.largeTitle.bold())
                    .layoutPriority(1)
                SpeakButton(text: word.lemma, accessibilityName: "Kelimeyi dinle")
                if showsSay {
                    SayButton(word: word, example: word.exampleEN)
                }
            }
            if let ipa = word.ipaUS {
                Text(ipa)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            Text("\(word.pos) · \(word.level)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            if let gloss = word.glossTR {
                Text(gloss)
                    .font(.title.weight(.semibold))
            }
            Divider()
            Text(word.defShort)
                .font(.title3)
            ExampleRow(example: CardDetail.Example(en: word.exampleEN, tr: detail?.examples.first?.tr))
            if let mistake = detail?.mistakes.first {
                MistakeBox(mistake: mistake)
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(16)
        // Not combined into one element: the speaker buttons must stay reachable on their own.
        .accessibilityElement(children: .contain)
    }
}
