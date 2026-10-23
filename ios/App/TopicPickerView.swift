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
                Text(verbatim: TopicPickerView.intro)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                if model.choosableTopics.isEmpty {
                    Text("Konu listesi yüklenemedi. Şimdilik bütün kelimeler gelir.")
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
                    Text("Bir kelime birkaç konuda olabilir; bir kez sayılır. Bir konuyu kaldırsan da öğrendiğin kelimeler Tekrar'da sorulmaya devam eder.")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
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

    /// What the choice changes. The onboarding has its own shorter sentence: there the user does
    /// not know "Akış" and "Tekrar" yet.
    static let intro = "Widget, Akış ve Tekrar yeni kelimeleri seçtiğin konulardan getirir. Hiç seçmezsen hepsi gelir."

    /// "Tümü" exactly when the list shows it checked: no listed topic is in the selection.
    private var summaryLine: some View {
        let isEverything = !model.choosableTopics.contains { selection.contains($0.id) }
        return DeckSummaryLine(
            summary: model.deckSummary(for: isEverything ? [] : selection),
            dailyGoal: model.dailyNewWords,
            isEverything: isEverything
        )
    }

    private func apply() {
        if hasLoaded {
            model.setSelectedTopics(selection)
        }
    }
}

/// The topic choice of the onboarding and "Ayarlar > Konular": "Tümü" first (no topic chosen
/// means every topic), then the topics as chips under a few group titles. Chips keep the 28
/// topics within about one and a half screens on an iPhone SE, where full rows took four.
struct TopicChoiceList: View {
    let topics: [ContentTopic]
    let totalWordCount: Int
    @Binding var selection: Set<String>
    /// The drawn height of a chip (`ChipButtonStyle`: 36 pt, scaled like `.subheadline`).
    @ScaledMetric(relativeTo: .subheadline) private var chipHeight: CGFloat = 36

    /// 8 pt between chip lines: the chips' transparent margins up to 44 pt give it at the default
    /// size; at large sizes the chips are taller than 44 pt, have no margin, and the layout adds it.
    private var chipLineSpacing: CGFloat {
        return max(0, 8 - max(0, Theme.minHitSize - chipHeight))
    }

    var body: some View {
        // "Tümü" also when only topics that are no longer listed are in the selection.
        let isEverything = !topics.contains { selection.contains($0.id) }
        VStack(alignment: .leading, spacing: 0) {
            ChoiceRow(isSelected: isEverything) {
                selection = []
            } label: {
                TopicRowLabel(title: "Tümü", detail: "Tüm konular, \(totalWordCount) kelime")
            }
            .accessibilityIdentifier("topics.all")
            ForEach(TopicGroup.groups(of: topics)) { group in
                // Mockup `.grp-t`: the group title well above its topics, close to its chips.
                Text(group.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                    .padding(.leading, 4)
                    .accessibilityAddTraits(.isHeader)
                ChipFlowLayout(spacing: 8, lineSpacing: chipLineSpacing) {
                    ForEach(group.topics) { topic in
                        let isSelected = selection.contains(topic.id)
                        Button {
                            toggle(topic.id)
                        } label: {
                            TopicChipLabel(title: topic.displayName, count: topic.cardCount, isSelected: isSelected)
                        }
                        .buttonStyle(ChipButtonStyle(isSelected: isSelected))
                        .accessibilityLabel(Text(verbatim: "\(topic.displayName), \(topic.cardCount) kelime"))
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                        .accessibilityIdentifier("topics.\(topic.id)")
                    }
                }
                // Beyond this size a long word ("Karıştırılan") no longer fits a chip on an
                // iPhone SE and would break in the middle.
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
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

/// "✓ Yemek ve içecek 58": the check is there only when selected, so the state is never the
/// border alone (rule 4). The chip style sets the font and the ink color. At accessibility
/// sizes the count goes under the name, which then keeps the chip's whole width.
private struct TopicChipLabel: View {
    let title: String
    let count: Int
    let isSelected: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 6))
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .accessibilityHidden(true)
            }
            layout {
                Text(verbatim: title)
                    .fixedSize(horizontal: false, vertical: true)
                Text(verbatim: "\(count)")
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(Theme.ink3)
            }
        }
    }
}

/// Chips side by side, wrapping to the next line (left aligned). A chip wider than the line is
/// offered the line's width, so its text wraps instead of running off the screen (largest text
/// sizes). `lineSpacing` comes on top of the chips' own transparent margins.
struct ChipFlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 0

    private struct Item {
        let index: Int
        let size: CGSize
        let x: CGFloat
    }

    private struct Line {
        var items: [Item] = []
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let proposedWidth = proposal.width ?? .infinity
        let lines = arrange(subviews, maxWidth: proposedWidth)
        let height = lines.last.map { $0.y + $0.height } ?? 0
        let usedWidth = lines.map { $0.width }.max() ?? 0
        // The ideal size (nil or infinite width) is one line of every chip.
        return CGSize(width: proposedWidth.isFinite ? proposedWidth : usedWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for line in arrange(subviews, maxWidth: bounds.width) {
            for item in line.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + line.y + (line.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
            }
        }
    }

    private func arrange(_ subviews: Subviews, maxWidth: CGFloat) -> [Line] {
        var lines: [Line] = []
        var line = Line()
        for index in subviews.indices {
            var size = subviews[index].sizeThatFits(.unspecified)
            if size.width > maxWidth {
                size = subviews[index].sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
                size.width = min(size.width, maxWidth)
            }
            var x = line.items.isEmpty ? 0 : line.width + spacing
            if !line.items.isEmpty && x + size.width > maxWidth {
                let nextY = line.y + line.height + lineSpacing
                lines.append(line)
                line = Line()
                line.y = nextY
                x = 0
            }
            line.items.append(Item(index: index, size: size, x: x))
            line.width = x + size.width
            line.height = max(line.height, size.height)
        }
        if !line.items.isEmpty {
            lines.append(line)
        }
        return lines
    }
}

/// Topics under a few plain titles, in the order the topics come (`category.sort`). Groups
/// with one or two topics share a title with a neighbour (B and F, D and E), so no title
/// stands over a single chip.
struct TopicGroup: Identifiable {
    let id: String
    let title: String
    let topics: [ContentTopic]

    static func groups(of topics: [ContentTopic]) -> [TopicGroup] {
        var order: [String] = []
        var byHeading: [String: [ContentTopic]] = [:]
        for topic in topics {
            let heading = TopicGroup.heading(of: topic.group)
            if byHeading[heading] == nil {
                order.append(heading)
            }
            byHeading[heading, default: []].append(topic)
        }
        return order.map { heading in
            TopicGroup(id: heading, title: heading, topics: byHeading[heading] ?? [])
        }
    }

    /// `category.grp` → title.
    private static func heading(of group: String) -> String {
        switch group {
        case "A": return "Günlük hayat"
        case "B", "F": return "Seyahat ve kültür"
        case "C": return "İnsanlar ve duygular"
        case "D", "E": return "İş ve teknoloji"
        case "G": return "Kalıplar ve tuzaklar"
        case "H": return "Zengin kelimeler"
        case "I": return "Sınavlar"
        default: return "Diğer"
        }
    }
}
