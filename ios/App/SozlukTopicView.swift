import SwiftUI
import CoreModels
import Learning
import ContentStore

/// Which cards belong to each topic (`card_category`, every topic of a card, main or not), read
/// once from content.sqlite off the main thread with `ContentStore.topicsByCard()`, the query the
/// deck filter is built from. Unavailable with seed words only (no database).
@MainActor
final class SozlukTopicIndex: ObservableObject {
    enum Status {
        case loading
        case ready
        case unavailable
    }

    @Published private(set) var status: Status = .loading
    private var cardsByTopic: [String: Set<Int>] = [:]
    private var hasStarted = false

    func load() async {
        if hasStarted {
            return
        }
        hasStarted = true
        let byCard = await Task.detached(priority: .utility) { () -> [Int: Set<String>]? in
            guard let store = ContentLoader.openStore() else {
                return nil
            }
            return try? store.topicsByCard()
        }.value
        guard let byCard = byCard, !byCard.isEmpty else {
            status = .unavailable
            return
        }
        var byTopic: [String: Set<Int>] = [:]
        for (card, topics) in byCard {
            for topic in topics {
                byTopic[topic, default: []].insert(card)
            }
        }
        cardsByTopic = byTopic
        status = .ready
    }

    func cards(of topicID: String) -> Set<Int> {
        return cardsByTopic[topicID] ?? []
    }
}

/// A topic's words, opened from "Konuya göre göz at": the loaded words of the topic by level, A1
/// first, and within a level in the content's order (the most frequent first), under one small
/// heading per level. The filter on top says how many words each state has; a word opens its
/// whole card. No main button (one main action per screen: here there is none).
struct SozlukTopicView: View {
    @EnvironmentObject private var model: AppModel
    @ObservedObject var index: SozlukTopicIndex
    let topic: ContentTopic
    @State private var filter: SozlukFilter = .all

    private struct LevelGroup {
        let level: String
        var words: [WidgetWord]
    }

    var body: some View {
        ScrollView {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        // Inline: a long topic name would be cut in a large title; the page heading wraps.
        .navigationTitle(topic.nameTR)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch index.status {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        case .unavailable:
            WordListEmptyState(
                systemImage: "square.stack.3d.up.slash",
                title: "Konu açılamadı",
                message: AttributedString("Bu konunun kelimeleri şu an okunamadı. Arama yine çalışır.")
            )
        case .ready:
            list(topicWords)
        }
    }

    /// The topic's loaded words by level (unknown codes last), each level in the loaded order.
    private var topicWords: [WidgetWord] {
        let members = index.cards(of: topic.id)
        let words = model.words.enumerated().filter { members.contains($0.element.id) }
        return words.sorted { lhs, rhs in
            let left = SozlukTopicView.rank(lhs.element)
            let right = SozlukTopicView.rank(rhs.element)
            return left != right ? left < right : lhs.offset < rhs.offset
        }.map { $0.element }
    }

    private static func rank(_ word: WidgetWord) -> Int {
        return word.levelValue?.rank ?? Int.max
    }

    private func list(_ words: [WidgetWord]) -> some View {
        let states = words.map { model.learningState(of: $0) }
        let shown = zip(words, states).filter { filter.includes($0.1) }.map { $0.0 }
        return VStack(alignment: .leading, spacing: 0) {
            header
            SozlukFilterBar(selection: $filter, counts: SozlukTopicView.counts(states))
                .padding(.top, 10)
            if shown.isEmpty {
                SozlukFilteredOut(filter: filter, message: filter.emptyMessage) {
                    filter = .all
                }
            } else {
                ForEach(Array(SozlukTopicView.levelGroups(shown).enumerated()), id: \.offset) { _, group in
                    levelSection(group)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(topic.nameTR)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("Kelimeler kolaydan zora sıralı.")
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
        }
        .padding(.top, 8)
    }

    /// One level: its badge and word count as a heading, then its words in one group.
    private func levelSection(_ group: LevelGroup) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                LevelBadge(code: group.level)
                    .fixedSize()
                Text(verbatim: "\(group.words.count) kelime")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            SozlukRowGroup {
                ForEach(Array(group.words.enumerated()), id: \.element.id) { index, word in
                    if index > 0 {
                        DictionaryRule()
                            .padding(.leading, 16)
                    }
                    SozlukWordLink(word: word, showsLevel: false)
                }
            }
        }
        .padding(.top, 18)
    }

    /// Consecutive words of the same level (the words are already in level order).
    private static func levelGroups(_ words: [WidgetWord]) -> [LevelGroup] {
        var groups: [LevelGroup] = []
        for word in words {
            if let last = groups.last, last.level == word.level {
                groups[groups.count - 1].words.append(word)
            } else {
                groups.append(LevelGroup(level: word.level, words: [word]))
            }
        }
        return groups
    }

    private static func counts(_ states: [LearningState]) -> [SozlukFilter: Int] {
        var result: [SozlukFilter: Int] = [:]
        for filter in SozlukFilter.allCases {
            result[filter] = states.filter { filter.includes($0) }.count
        }
        return result
    }
}
