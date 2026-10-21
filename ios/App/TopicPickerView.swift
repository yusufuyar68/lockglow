import SwiftUI
import CoreModels

/// "Ayarlar > Konular": the same choice as the onboarding's second page, with the summary line.
/// The selection is applied when the screen closes or the app stops being active (no debounce;
/// applying the same choice twice does nothing), so the widget plan is not rewritten per tap.
struct TopicPickerView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selection: Set<String> = []
    @State private var hasLoaded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "\(TopicPickerView.intro) Öğrendiğin kelimelerin tekrarı her konuda sürer.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                if model.choosableTopics.isEmpty {
                    Text("Konu listesi yok (içerik veritabanı yüklenmedi). Bütün kelimeler gösteriliyor.")
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                } else {
                    // Largest text sizes: no pinned bar, the summary leads the list.
                    if dynamicTypeSize.isAccessibilitySize {
                        summaryLine
                            .padding(.horizontal, 4)
                    }
                    TopicChoiceList(
                        topics: model.choosableTopics,
                        totalWordCount: model.words.count,
                        selection: $selection
                    )
                    Text("Bir kelime birden çok konuda yer alabilir. Toplam her kelimeyi bir kez sayar.")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        // The summary stays in sight while the list scrolls (as on the onboarding's topics page):
        // an opaque strip of page background with a hairline, not a material (rule 6).
        .safeAreaInset(edge: .bottom) {
            if !model.choosableTopics.isEmpty && !dynamicTypeSize.isAccessibilitySize {
                summaryLine
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                    .background(Theme.bg)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Theme.line)
                            .frame(height: 1)
                    }
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Konular")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasLoaded {
                selection = model.deckChoice.topicIDs
                hasLoaded = true
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                apply()
            }
        }
        .onDisappear {
            apply()
        }
    }

    /// The first three sentences are also the onboarding's topics page text.
    static let intro = "Widget'ta, Akış'ta ve Tekrar'ın yeni kelimelerinde seçtiğin konular döner. Hiç seçmezsen hepsi gelir. Seçtiğin konuların yeni kelimeleri bitince diğer konulardan devam edilir."

    private var summaryLine: some View {
        DeckSummaryLine(
            summary: model.deckSummary(for: selection),
            dailyGoal: model.dailyNewWords,
            isEverything: selection.isDisjoint(with: model.topics.map { $0.id })
        )
    }

    private func apply() {
        if hasLoaded {
            model.setSelectedTopics(selection)
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
        // Mockup `.choices`: 8 pt between rows, the group titles (`.grp-t`) 12 pt above their rows.
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
                    .foregroundStyle(Theme.ink2)
                    .padding(.top, 12)
                    .padding(.leading, 4)
                    .accessibilityAddTraits(.isHeader)
                ForEach(group.topics) { topic in
                    ChoiceRow(isSelected: selection.contains(topic.id)) {
                        toggle(topic.id)
                    } label: {
                        TopicRowLabel(title: topic.displayName, detail: "\(topic.cardCount) kelime")
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
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(verbatim: detail)
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
        }
    }
}

extension ContentTopic {
    /// The name shown in the app. Two category names are heavy for an A2 learner; the content
    /// (`category.name_tr`) stays as it is.
    var displayName: String {
        switch id {
        case "phrasal_verbs": return "İki kelimeli fiiller"
        case "confusing_words": return "Karıştırılan kelimeler"
        default: return nameTR
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
