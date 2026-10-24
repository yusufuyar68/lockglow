import SwiftUI
import UIKit
import CoreModels
import Learning

// Pieces shared by Sözlük's lists (SearchView, SozlukTopicView, SozlukRecentSearches) and the word
// page (SozlukWordPage): the status filter, the status mark, the word row with its two VoiceOver
// parts (also the page's "Karıştırma" and "Başka anlamı" rows), the row group, the flow layout of
// the capsules.

// MARK: - Learning status

/// Where a word stands, as Sözlük shows it (rule 4: an icon and a word, never color alone). The
/// same icons on the filter chips, the rows, the word page's "Durum" and the "Akış" card's meta
/// line (`FeedStateLine`): one symbol per state in the app.
enum SozlukStatus {
    static func title(_ state: LearningState) -> String {
        switch state {
        case .new:
            return "Yeni kelime"
        case .learning:
            return "Öğreniyorsun"
        case .known:
            return "Bildiğin kelime"
        }
    }

    static func symbol(_ state: LearningState) -> String {
        switch state {
        case .new:
            return "circle.dashed"
        case .learning:
            return "circle.lefthalf.filled"
        case .known:
            return "checkmark.circle.fill"
        }
    }

    static func color(_ state: LearningState) -> Color {
        switch state {
        case .new:
            return Theme.ink3
        case .learning:
            return Theme.ink2
        case .known:
            return Theme.good
        }
    }
}

extension FeedStateLine.Status {
    /// The same state as Sözlük names it, for `SozlukStatus.symbol` (FeedCardView.swift does not
    /// import Learning).
    var learningState: LearningState {
        switch self {
        case .new:
            return .new
        case .learning:
            return .learning
        case .known:
            return .known
        }
    }
}

/// The status filter of the result list and the topic page. Not saved: Sözlük opens on "Tümü",
/// so a forgotten filter never hides the word being looked up.
enum SozlukFilter: String, CaseIterable, Identifiable {
    case all
    case new
    case learning
    case known

    var id: String {
        return rawValue
    }

    /// The status names of the rows (`SozlukStatus`, docs/tasarim/terimler.md §4), so the chips
    /// also name the marks.
    var title: String {
        guard let state = state else {
            return "Tümü"
        }
        return SozlukStatus.title(state)
    }

    /// The learning state it keeps; nil for "Tümü".
    var state: LearningState? {
        switch self {
        case .all:
            return nil
        case .new:
            return .new
        case .learning:
            return .learning
        case .known:
            return .known
        }
    }

    func includes(_ state: LearningState) -> Bool {
        return self.state.map { $0 == state } ?? true
    }

    /// The empty list's title and sentence when this filter leaves nothing.
    var emptyTitle: String {
        switch self {
        case .all:
            return "Kelime yok"
        case .new:
            return "Yeni kelime kalmadı"
        case .learning:
            return "Öğrenmekte olduğun kelime yok"
        case .known:
            return "Bildiğin kelime yok"
        }
    }

    var emptyMessage: String {
        switch self {
        case .all:
            return "Burada henüz kelime yok."
        case .new:
            return "Bunların hepsine başladın: Tekrar'da ya da bildiğin kelimelerde."
        case .learning:
            return "Tekrar'da çalıştığın kelimeler burada görünür."
        case .known:
            return "Widget'ta ya da kartta \"Biliyorum\" dediğin kelimeler burada görünür."
        }
    }
}

/// The four filter chips; the selected one has the `tint` border (never yellow). Each chip but
/// "Tümü" carries its state's icon, so the chips also explain the marks on the rows. The chips
/// wrap onto more lines on a narrow screen and at large text sizes.
struct SozlukFilterBar: View {
    @Binding var selection: SozlukFilter
    /// Words per filter (the topic page); nil shows no numbers (search results are capped).
    var counts: [SozlukFilter: Int]? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // No line spacing: the chips already reach 44 pt with transparent margins.
        DictionaryFlowLayout(itemSpacing: 8, lineSpacing: 0) {
            ForEach(SozlukFilter.allCases) { filter in
                Button {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                        selection = filter
                    }
                } label: {
                    chipLabel(filter)
                }
                .buttonStyle(ChipButtonStyle(isSelected: filter == selection))
                .accessibilityLabel(Text(verbatim: accessibilityName(filter)))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Süzgeç")
    }

    private func chipLabel(_ filter: SozlukFilter) -> some View {
        HStack(spacing: 6) {
            if let state = filter.state {
                Image(systemName: SozlukStatus.symbol(state))
                    .foregroundStyle(SozlukStatus.color(state))
                    .accessibilityHidden(true)
            }
            Text(filter.title)
            if let count = counts?[filter] {
                Text(verbatim: "\(count)")
                    .foregroundStyle(Theme.ink2)
                    .monospacedDigit()
            }
        }
    }

    private func accessibilityName(_ filter: SozlukFilter) -> String {
        guard let count = counts?[filter] else {
            return filter.title
        }
        return "\(filter.title): \(count)"
    }
}

/// A row's status (rule 4: an icon and a word). New words carry none: most words are new, and a
/// mark on every row would say nothing.
struct SozlukStatusMark: View {
    let state: LearningState
    /// Footnote, the level badge's size, on the rows; the word page's facts pass Callout.
    var textStyle: Font.TextStyle = .footnote

    var body: some View {
        Label {
            Text(SozlukStatus.title(state))
        } icon: {
            Image(systemName: SozlukStatus.symbol(state))
        }
        .labelStyle(.titleAndIcon)
        // The level badge's size: one small size on the rows and on the word page.
        .font(.system(textStyle, design: .default).weight(.semibold))
        .foregroundStyle(SozlukStatus.color(state))
    }
}

// MARK: - VoiceOver language

/// VoiceOver labels and announcements with their language (README point 14; audit V5 and V6), the
/// same way as the Söyle page: every run carries `accessibilitySpeechLanguage`. For what cannot be
/// two elements: an announcement, a button whose name holds the word ("Geri al: breakfast").
/// Whether a label keeps the runs is still to be heard on the phone (V6); where the English word
/// can stand alone it is its own element with `englishVoice()` (`SozlukRowSpeech`). Main
/// actor: it posts to UIKit's accessibility.
@MainActor
enum SozlukSpeech {
    enum Run {
        case turkish(String)
        case english(String)
    }

    static func label(_ runs: [Run]) -> Text {
        return Text(AttributedString(attributed(runs)))
    }

    /// Spoken after what VoiceOver is saying now, not over it.
    static func announce(_ runs: [Run]) {
        let text = NSMutableAttributedString(attributedString: attributed(runs))
        text.addAttribute(
            .accessibilitySpeechQueueAnnouncement,
            value: true,
            range: NSRange(location: 0, length: text.length)
        )
        UIAccessibility.post(notification: .announcement, argument: text)
    }

    private static func attributed(_ runs: [Run]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for run in runs {
            switch run {
            case .turkish(let text):
                result.append(NSAttributedString(string: text, attributes: [.accessibilitySpeechLanguage: "tr-TR"]))
            case .english(let text):
                result.append(NSAttributedString(string: text, attributes: [.accessibilitySpeechLanguage: "en-US"]))
            }
        }
        return result
    }
}

// MARK: - Word rows

/// A word that opens its whole card (`open`: SearchView pushes it on Sözlük's stack). VoiceOver
/// hears it as two parts (`SozlukRowSpeech`): the English word alone in an English voice, then
/// "Türkçesi: …" with the level, status and "Ayrıca" line in Turkish. The marked texts of a
/// search result replace the plain ones.
struct SozlukWordLink: View {
    @EnvironmentObject private var model: AppModel
    let word: WidgetWord
    var lemma: AttributedString? = nil
    var gloss: AttributedString? = nil
    /// A line under the meaning ("Ayrıca: …" when the search matched another meaning).
    var note: AttributedString? = nil
    /// False on the topic page, where the words stand under their level's heading.
    var showsLevel = true
    /// The word page's link rows (`SozlukWordRow.compact`).
    var compact = false
    let open: (WidgetWord) -> Void

    var body: some View {
        let state = model.learningState(of: word)
        Button {
            open(word)
        } label: {
            SozlukWordRow(
                lemma: lemma ?? AttributedString(word.lemma),
                gloss: gloss ?? word.glossTR.map { AttributedString($0) },
                note: note,
                // A user's word has no level.
                level: showsLevel && !word.isUserAdded ? word.level : nil,
                state: state,
                compact: compact
            )
        }
        .buttonStyle(SozlukRowButtonStyle())
        .accessibilityRepresentation {
            SozlukRowSpeech(lemma: word.lemma, details: spokenDetails(state)) {
                open(word)
            }
        }
    }

    /// The Turkish part: "Türkçesi: kahvaltı, Seviye A1, Bildiğin kelime, Ayrıca: …".
    private func spokenDetails(_ state: LearningState) -> String {
        var parts: [String] = []
        if let gloss = word.glossTR {
            parts.append("Türkçesi: " + gloss)
        }
        if word.isUserAdded {
            parts.append("Senin kelimen")
        } else if showsLevel {
            parts.append("Seviye " + word.level)
        }
        if state != .new {
            parts.append(SozlukStatus.title(state))
        }
        if let note = note {
            parts.append(String(note.characters))
        }
        return parts.joined(separator: ", ")
    }
}

/// What VoiceOver hears for a word row that opens a card: the row button's
/// `accessibilityRepresentation`, so the visible row stays one button (README point 14, is3-tema:
/// a merged label loses the English voice). Two elements: the English word alone in an English
/// voice (`englishVoice()`; no Turkish label, hint or trait on it), then the Turkish rest
/// ("Türkçesi: kahvaltı, Seviye A1, …") as a button that says it opens the card. Both open it.
struct SozlukRowSpeech: View {
    let lemma: String
    /// Empty: the second element only says "Kartı aç".
    let details: String
    let open: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: lemma)
                .accessibilityAction {
                    open()
                }
                .englishVoice()
            Text(verbatim: details.isEmpty ? "Kartı aç" : details)
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(Text(verbatim: details.isEmpty ? "" : "Kartı açar"))
                .accessibilityAction {
                    open()
                }
        }
    }
}

/// One word in Sözlük's lists (mockup `.rrow`): the serif English word, then its level and status,
/// the Turkish meaning in ink under it, an optional note, a chevron. The level and status follow
/// the word while they fit on its line and go under it otherwise (a long phrase on an SE,
/// accessibility text sizes); there they wrap themselves when even a line of their own is short.
struct SozlukWordRow: View {
    let lemma: AttributedString
    let gloss: AttributedString?
    var note: AttributedString? = nil
    var level: String? = nil
    let state: LearningState
    /// The word page's "Başka anlamı" and "Karıştırma" rows: the word at Body serif and the note,
    /// level and status at Callout, the page's own sizes (Sözlük's lists keep Title 3 and
    /// Footnote).
    var compact = false

    /// The note's, the level's and the status's size.
    private var smallStyle: Font.TextStyle {
        return compact ? .callout : .footnote
    }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        word
                        meta
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        word
                        meta
                    }
                }
                if let gloss = gloss {
                    Text(gloss)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                }
                if let note = note {
                    Text(note)
                        .font(.system(smallStyle, design: .default).weight(.medium))
                        .foregroundStyle(Theme.ink2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink3)
                .accessibilityHidden(true)
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .padding(.vertical, 10)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
    }

    private var word: some View {
        Text(lemma)
            .font(.system(compact ? Font.TextStyle.body : Font.TextStyle.title3, design: .serif).weight(.bold))
            .foregroundStyle(Theme.ink)
            .cardEnglishVoice()
    }

    @ViewBuilder
    private var meta: some View {
        if level != nil || state != .new {
            DictionaryFlowLayout(itemSpacing: 8, lineSpacing: 4) {
                if let level = level {
                    LevelBadge(code: level, textStyle: smallStyle)
                        .fixedSize()
                }
                if state != .new {
                    SozlukStatusMark(state: state, textStyle: smallStyle)
                }
            }
        }
    }
}

/// Rows in one rounded `surface` group with a `line` border (mockup `.res`).
struct SozlukRowGroup<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        let group = RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous)
        LazyVStack(spacing: 0) {
            content()
        }
        .background(Theme.surface)
        .clipShape(group)
        .overlay {
            group.strokeBorder(Theme.line, lineWidth: 1)
        }
    }
}

/// A row's press feedback: the row darkens like a list cell.
struct SozlukRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Theme.surface2 : Color.clear)
    }
}

/// The title over a part of Sözlük's start page ("Son aramalar", "Konular"; mockup A1): a bold
/// `headline` in ink, sentence case, a heading for VoiceOver. The word page titles its parts the
/// same way (`SozlukPageSection`).
struct SozlukSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline.weight(.bold))
            .foregroundStyle(Theme.ink)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A filter that leaves nothing: what it would show, and "Tümünü göster" back to every word.
struct SozlukFilteredOut: View {
    let filter: SozlukFilter
    let message: String
    let showAll: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            WordListEmptyState(
                systemImage: filter.state.map(SozlukStatus.symbol) ?? "line.3.horizontal.decrease.circle",
                title: filter.emptyTitle,
                message: AttributedString(message)
            )
            Button("Tümünü göster", action: showAll)
                .buttonStyle(ChipButtonStyle())
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Layout

/// A 1 pt `line` rule between rows (mockup `border-top: 1px solid var(--line)`).
struct DictionaryRule: View {
    var body: some View {
        Rectangle()
            .fill(Theme.line)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

/// Capsules from the leading edge, wrapping to a new line when the line is full (mockup
/// `flex-wrap: wrap`): the "Dene" examples, the topics, the filter chips and the word partners. A
/// capsule wider than the line gets the line's width, so its text wraps inside it. Each subview is
/// centered on its line.
struct DictionaryFlowLayout: Layout {
    /// Between two subviews on a line.
    var itemSpacing: CGFloat
    /// Between two lines.
    var lineSpacing: CGFloat

    private struct Line {
        var items: [(index: Int, size: CGSize)] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let lines = arrange(subviews, maxWidth: proposal.width ?? .infinity)
        let gaps = lineSpacing * CGFloat(max(lines.count - 1, 0))
        let height = lines.reduce(CGFloat(0)) { $0 + $1.height } + gaps
        let usedWidth = lines.reduce(CGFloat(0)) { max($0, $1.width) }
        return CGSize(width: usedWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for line in arrange(subviews, maxWidth: bounds.width) {
            var x = bounds.minX
            for item in line.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y + (line.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + itemSpacing
            }
            y += line.height + lineSpacing
        }
    }

    private func arrange(_ subviews: Subviews, maxWidth: CGFloat) -> [Line] {
        var lines: [Line] = []
        var line = Line()
        for index in subviews.indices {
            var size = subviews[index].sizeThatFits(.unspecified)
            if size.width > maxWidth {
                size = subviews[index].sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            }
            if !line.items.isEmpty && line.width + itemSpacing + size.width > maxWidth {
                lines.append(line)
                line = Line()
            }
            line.width += (line.items.isEmpty ? 0 : itemSpacing) + size.width
            line.height = max(line.height, size.height)
            line.items.append((index: index, size: size))
        }
        if !line.items.isEmpty {
            lines.append(line)
        }
        return lines
    }
}
