import SwiftUI
import CoreModels

/// "Bildiğim kelimeler": every known word, the most recent first. A word marked known by mistake
/// (for example the widget's "Biliyorum" tapped by accident) goes back to learning from here.
struct KnownWordsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let known = model.knownWords()
        Group {
            if known.isEmpty {
                ContentUnavailableView(
                    "Henüz bildiğin kelime yok",
                    systemImage: "checkmark.circle",
                    description: Text("Widget'ta \"Biliyorum\" dediğin ya da tekrarda öğrendiğin kelimeler burada görünür.")
                )
            } else {
                List {
                    Section {
                        ForEach(known) { word in
                            NavigationLink {
                                WordDetailView(word: word)
                            } label: {
                                KnownWordRow(word: word)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Geri al") {
                                    withAnimation {
                                        model.undoKnown(word)
                                    }
                                }
                                .tint(.orange)
                            }
                        }
                    } footer: {
                        Text("Yanlışlıkla \"Biliyorum\" dediysen kelimeyi aç ve \"Öğrenmeye geri al\"a dokun ya da satırı sola kaydır. Kelime widget'a ve tekrara geri döner.")
                    }
                }
            }
        }
        .navigationTitle("Bildiğim kelimeler")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct KnownWordRow: View {
    let word: WidgetWord

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(word.lemma)
                .font(.headline)
            if let gloss = word.glossTR {
                Text(gloss)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
