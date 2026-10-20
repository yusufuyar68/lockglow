import SwiftUI
import CoreModels

/// "Ayarlar > Konular": the same choice as the onboarding's second page. The selection is
/// applied when the screen closes, so the widget plan is rewritten once, not on every tap.
struct TopicPickerView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selection: Set<String> = []
    @State private var hasLoaded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Widget'ta, Akış'ta ve Tekrar'ın yeni kelimelerinde yalnız seçtiğin konular döner. Öğrenmeye başladığın kelimelerin tekrarı her konuda sürer.")
                    .font(.subheadline)
                    .foregroundStyle(Palette.ink2)
                if model.choosableTopics.isEmpty {
                    Text("Konu listesi yok (içerik veritabanı yüklenmedi). Bütün kelimeler gösteriliyor.")
                        .font(.body)
                } else {
                    TopicChoiceList(
                        topics: model.choosableTopics,
                        totalWordCount: model.words.count,
                        selection: $selection
                    )
                }
            }
            .padding(16)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Konular")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasLoaded {
                selection = model.deckChoice.topicIDs
                hasLoaded = true
            }
        }
        .onDisappear {
            if hasLoaded {
                model.setSelectedTopics(selection)
            }
        }
    }
}

/// The topic choice of the onboarding and "Ayarlar > Konular": "Tümü" first (no topic chosen
/// means every topic), then the topics under their group titles, each with its word count.
struct TopicChoiceList: View {
    let topics: [ContentTopic]
    let totalWordCount: Int
    @Binding var selection: Set<String>

    var body: some View {
        // "Tümü" also when only topics that are no longer listed are in the selection.
        let isEverything = !topics.contains { selection.contains($0.id) }
        LazyVStack(alignment: .leading, spacing: 8) {
            ChoiceRow(isSelected: isEverything) {
                selection = []
            } label: {
                TopicRowLabel(title: "Tümü", detail: "Bütün konular, \(totalWordCount) kelime")
            }
            .accessibilityIdentifier("topics.all")
            ForEach(TopicGroup.groups(of: topics)) { group in
                Text(group.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Palette.ink2)
                    .padding(.top, 12)
                    .padding(.leading, 4)
                    .accessibilityAddTraits(.isHeader)
                ForEach(group.topics) { topic in
                    ChoiceRow(isSelected: selection.contains(topic.id)) {
                        toggle(topic.id)
                    } label: {
                        TopicRowLabel(title: topic.nameTR, detail: "\(topic.cardCount) kelime")
                    }
                    .accessibilityIdentifier("topics.\(topic.id)")
                }
            }
        }
    }

    private func toggle(_ id: String) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }
}

private struct TopicRowLabel: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: title)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.primary)
            Text(verbatim: detail)
                .font(.footnote)
                .foregroundStyle(Palette.ink2)
        }
    }
}

/// Topics under the Turkish title of their `category.grp`, in the order the topics come
/// (`category.sort`).
struct TopicGroup: Identifiable {
    let id: String
    let title: String
    let topics: [ContentTopic]

    static func groups(of topics: [ContentTopic]) -> [TopicGroup] {
        var order: [String] = []
        var byGroup: [String: [ContentTopic]] = [:]
        for topic in topics {
            if byGroup[topic.group] == nil {
                order.append(topic.group)
            }
            byGroup[topic.group, default: []].append(topic)
        }
        return order.map { group in
            TopicGroup(id: group, title: title(of: group), topics: byGroup[group] ?? [])
        }
    }

    private static func title(of group: String) -> String {
        switch group {
        case "A": return "Günlük hayat"
        case "B": return "Seyahat ve kültür"
        case "C": return "İnsanlar ve duygular"
        case "D": return "İş hayatı"
        case "E": return "Bilim ve teknoloji"
        case "F": return "Sanat ve eğlence"
        case "G": return "Dil kalıpları"
        case "H": return "Zengin kelimeler"
        case "I": return "Sınavlar"
        default: return "Diğer"
        }
    }
}
