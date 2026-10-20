import SwiftUI
import CoreModels
import Learning

/// "Sözlük": look a word up in English or Turkish (prefix search, Turkish letters folded), then
/// open the whole card.
struct SearchView: View {
    @EnvironmentObject private var model: AppModel
    @State private var query = ""

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Sözlük")
                .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "İngilizce ya da Türkçe kelime")
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .navigationDestination(for: WidgetWord.self) { word in
                    WordDetailView(word: word)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            ContentUnavailableView(
                "Kelime ara",
                systemImage: "character.book.closed",
                description: Text("İngilizce bir kelime ya da Türkçe anlamını yaz: \"kahv\" yazınca \"breakfast\" çıkar.")
            )
        } else {
            let results = model.search(trimmed)
            if results.isEmpty {
                ContentUnavailableView.search(text: trimmed)
            } else {
                List(results) { word in
                    NavigationLink(value: word) {
                        SearchRow(word: word)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

private struct SearchRow: View {
    let word: WidgetWord

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(word.lemma)
                    .font(.headline)
                Spacer(minLength: 8)
                Text(word.level)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            if let gloss = word.glossTR {
                Text(gloss)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

/// The whole card: word, Turkish meaning (and alternatives), definition, every example with its
/// Turkish, typical mistakes, a memory hook and common word partners.
struct WordDetailView: View {
    @EnvironmentObject private var model: AppModel
    let word: WidgetWord

    var body: some View {
        let detail = model.detail(for: word)
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 4) {
                        Text(word.lemma)
                            .font(.largeTitle.bold())
                        SpeakButton(text: word.lemma, accessibilityName: "Kelimeyi dinle")
                        SayButton(word: word, example: word.exampleEN)
                    }
                    if let ipa = word.ipaUS {
                        Text(ipa)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Text("\(word.pos) · \(word.level)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                if let gloss = word.glossTR {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(gloss)
                            .font(.title.weight(.semibold))
                        if let alternatives = detail?.glossAlternatives, !alternatives.isEmpty {
                            Text("Ayrıca: " + alternatives.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Text(word.defShort)
                    .font(.title3)
                LearningStatusRow(word: word)
                Divider()
                if let examples = detail?.examples, !examples.isEmpty {
                    sectionTitle("Örnekler")
                    ForEach(Array(examples.enumerated()), id: \.offset) { _, example in
                        ExampleRow(example: example)
                    }
                } else {
                    ExampleRow(example: CardDetail.Example(en: word.exampleEN))
                }
                if let mistakes = detail?.mistakes, !mistakes.isEmpty {
                    ForEach(Array(mistakes.enumerated()), id: \.offset) { _, mistake in
                        MistakeBox(mistake: mistake)
                    }
                }
                if let note = detail?.noteTR {
                    Label(note, systemImage: "info.circle")
                        .font(.callout)
                }
                if let mnemonic = detail?.mnemonicTR {
                    Label(mnemonic, systemImage: "lightbulb")
                        .font(.callout)
                }
                if let collocations = detail?.collocations, !collocations.isEmpty {
                    sectionTitle("Birlikte kullanılır")
                    Text(collocations.joined(separator: " · "))
                        .font(.callout)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }
}

/// Where the word stands (new / learning / known) and the one action that changes it.
private struct LearningStatusRow: View {
    @EnvironmentObject private var model: AppModel
    let word: WidgetWord

    var body: some View {
        let state = model.learningState(of: word)
        HStack(spacing: 12) {
            Label(statusText(state), systemImage: state == .known ? "checkmark.circle.fill" : "circle.dashed")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(state == .known ? Color.green : Color.secondary)
            Spacer(minLength: 0)
            if state == .known {
                Button("Öğrenmeye geri al") {
                    model.undoKnown(word)
                }
                .buttonStyle(.bordered)
            } else {
                Button("Biliyorum") {
                    model.markKnown(word)
                }
                .buttonStyle(.bordered)
            }
        }
        .controlSize(.regular)
    }

    private func statusText(_ state: LearningState) -> String {
        switch state {
        case .new:
            return "Yeni kelime"
        case .learning:
            return "Öğreniyorum"
        case .known:
            return "Biliyorum"
        }
    }
}
