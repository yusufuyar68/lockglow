import SwiftUI
import CoreModels
import Learning

/// A topic's words, opened from "Konuya göre göz at": the loaded words of the topic by level, A1
/// first, and within a level in the content's order (the most frequent first), under one small
/// heading per level. The filter on top says how many words each state has; a word opens its
/// whole card. No main button (one main action per screen: here there is none).
struct SozlukTopicView: View {
    @EnvironmentObject private var model: AppModel
    let topic: ContentTopic
    /// A word's whole card (SearchView's stack).
    let open: (WidgetWord) -> Void
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
        // HIG: the topic's name once, as a large title that folds into the bar when the list
        // scrolls (sozluk-4: an inline title over a page heading said it twice).
        .navigationTitle(topic.displayName)
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private var content: some View {
        let words = topicWords
        if words.isEmpty {
            // Only when the content changed under an open page: the topic list hides empty topics.
            WordListEmptyState(
                systemImage: "square.stack.3d.up.slash",
                title: "Bu konuda kelime yok",
                message: AttributedString("Kelimeleri Sözlük'te arayabilirsin.")
            )
        } else {
            list(words)
        }
    }

    /// The topic's loaded words (`AppModel.words(inTopic:)`) by level (unknown codes last), each
    /// level in the loaded order.
    private var topicWords: [WidgetWord] {
        let words = model.words(inTopic: topic.id).enumerated()
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
            header(count: words.count)
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

    /// How many words the topic has and in which order (mockup A3), under the large title: the
    /// name itself is the navigation title.
    private func header(count: Int) -> some View {
        Text(verbatim: "\(count) kelime · kolaydan zora")
            .font(.subheadline)
            .foregroundStyle(Theme.ink2)
            // VoiceOver would read the dot aloud.
            .accessibilityLabel(Text(verbatim: "\(count) kelime, kolaydan zora sıralı"))
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
                    SozlukWordLink(word: word, showsLevel: false, open: open)
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
