import SwiftUI
import TextFold

/// "Son aramalar": the searches that opened a card or were sent with the keyboard's search key,
/// newest first, at most eight. Kept on this phone only, as one `@AppStorage` text with a search
/// per line. A search made again moves to the top instead of appearing twice ("odunc" and
/// "ödünç" count as the same search, as they find the same words). "İlerlemeyi sıfırla" deletes
/// them (`AppModel.clearRecentSearches`).
enum SozlukRecentSearches {
    static let storageKey = AppModel.recentSearchesKey
    static let limit = 8
    /// A pasted sentence is cut: the row shows a search, not a paragraph.
    static let maxLength = 60

    static func list(_ stored: String) -> [String] {
        return Array(stored.split(separator: "\n").map(String.init).prefix(limit))
    }

    /// `stored` with `query` first; unchanged for an empty query.
    static func adding(_ query: String, to stored: String) -> String {
        let search = cleaned(query)
        if search.isEmpty {
            return stored
        }
        let key = TextFold.fold(search)
        var searches = list(stored).filter { TextFold.fold($0) != key }
        searches.insert(search, at: 0)
        return searches.prefix(limit).joined(separator: "\n")
    }

    static func removing(_ search: String, from stored: String) -> String {
        return list(stored).filter { $0 != search }.joined(separator: "\n")
    }

    /// Spaces and line breaks collapsed to single spaces (a line break would split the entry).
    static func cleaned(_ query: String) -> String {
        let words = query.split(whereSeparator: { $0.isWhitespace })
        return String(words.joined(separator: " ").prefix(maxLength))
    }
}

/// The recent searches on Sözlük's start page: a title with "Temizle", then one row per search (a
/// clock and the search; a tap searches it again) with its own round "Sil" button.
struct SozlukRecentSearchesSection: View {
    let searches: [String]
    let select: (String) -> Void
    let remove: (String) -> Void
    let clear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    SozlukSectionTitle(title: "Son aramalar")
                    Spacer(minLength: 8)
                    clearButton
                }
                VStack(alignment: .leading, spacing: 0) {
                    SozlukSectionTitle(title: "Son aramalar")
                    clearButton
                }
            }
            SozlukRowGroup {
                ForEach(Array(searches.enumerated()), id: \.element) { index, search in
                    if index > 0 {
                        DictionaryRule()
                            .padding(.leading, 16)
                    }
                    row(search)
                }
            }
        }
    }

    private var clearButton: some View {
        Button("Temizle", action: clear)
            .buttonStyle(ChipButtonStyle())
            // The visible "Temizle" stays in the name (Voice Control).
            .accessibilityLabel("Son aramaları temizle")
    }

    private func row(_ search: String) -> some View {
        HStack(spacing: 4) {
            Button {
                select(search)
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(Theme.ink2)
                        .accessibilityHidden(true)
                    Text(verbatim: search)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 16)
                .padding(.vertical, 10)
                .frame(minHeight: 48)
                .contentShape(Rectangle())
            }
            .buttonStyle(SozlukRowButtonStyle())
            .accessibilityHint("Yeniden arar")
            Button {
                remove(search)
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.bold))
            }
            .buttonStyle(ChipButtonStyle())
            .accessibilityLabel(Text(verbatim: "Sil: " + search))
            .padding(.trailing, 8)
        }
    }
}
