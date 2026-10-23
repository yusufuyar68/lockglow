import SwiftUI
import UIKit
import CoreModels
import Learning
import TextFold

/// "Sözlük": look a word up in English or Turkish (prefix search, Turkish letters folded), or
/// browse a topic, then open the word page (`WordDetailView`, SozlukWordPage.swift; mockup A1-A4
/// of the Sözlük redesign). An empty field offers the recent searches (the "Dene" examples
/// before the first one) and the topics as tiles; a topic opens its words by level
/// (`SozlukTopicView`). In the results the typed part is bold and underlined, never yellow (rule
/// 1), and a filter keeps the new, learning or known words only; a search that finds nothing says
/// what to try and offers a shorter search. No main button: nothing here is filled (rule of one
/// main action per screen).
struct SearchView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    /// Back to "Tümü" whenever the field is emptied (`SozlukFilter`).
    @State private var filter: SozlukFilter = .all
    @AppStorage(SozlukRecentSearches.storageKey) private var recentSearchLog = ""
    /// Sözlük's stack: topics and word cards (`open`).
    @State private var path = NavigationPath()
    /// "Kendin ekle" after a search that found nothing (`CustomWordEditor`).
    @State private var customWordEditor: CustomWordEditor.Mode?

    /// "Dene" examples (mockup `.try`): a Turkish start, the same kind without Turkish letters,
    /// a Turkish word and an English start.
    private static let tryQueries = [
        SearchTryExample(text: "kahv"),
        SearchTryExample(text: "odunc"),
        SearchTryExample(text: "randevu"),
        SearchTryExample(text: "break", isEnglish: true),
    ]
    /// Results of one search; a filter other than "Tümü" looks further, so that it has words to keep.
    private static let resultLimit = 50
    private static let filteredResultLimit = 200

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Theme.bg
                    .ignoresSafeArea()
            }
            .navigationTitle("Sözlük")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "İngilizce ya da Türkçe kelime")
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onSubmit(of: .search) {
                remember(query)
            }
            .sheet(item: $customWordEditor) { mode in
                CustomWordEditor(library: model.customWordLibrary, mode: mode, cardMeaning: model.lookup(lemma:))
            }
            .navigationDestination(for: WidgetWord.self) { word in
                // A card opened from the results makes its search a recent one; from a topic
                // the field is empty and nothing is kept.
                WordDetailView(word: word)
                    .onAppear {
                        remember(query)
                    }
            }
            .navigationDestination(for: ContentTopic.self) { topic in
                SozlukTopicView(topic: topic, open: open)
            }
        }
        // Rule 2: no blue link color on the search field, its cancel button or the back button.
        .tint(Theme.ink)
        .task(id: query) {
            await announceResults(of: query)
        }
        .onChange(of: query) { _, newQuery in
            if newQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                filter = .all
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            startPage
        } else {
            let found = search(trimmed)
            if found.isEmpty {
                noResults(for: trimmed)
            } else {
                resultList(found, terms: SearchHighlight.terms(of: trimmed))
            }
        }
    }

    /// A row's word: its whole card on Sözlük's stack.
    private func open(_ word: WidgetWord) {
        path.append(word)
    }

    private func search(_ text: String) -> [WidgetWord] {
        return model.search(text, limit: filter == .all ? SearchView.resultLimit : SearchView.filteredResultLimit)
    }

    private func shownResults(_ found: [WidgetWord]) -> [WidgetWord] {
        return found.filter { filter.includes(model.learningState(of: $0)) }
    }

    // MARK: Start page

    /// The empty field: the recent searches (before the first one, the "Dene" examples that show
    /// what can be typed), the topics and the Turkish-letters tip. With neither recent searches
    /// nor topics (seed words only), the "Kelime ara" explanation instead.
    private var startPage: some View {
        let recent = SozlukRecentSearches.list(recentSearchLog)
        let topics = browseTopics
        return VStack(alignment: .leading, spacing: 0) {
            if recent.isEmpty {
                tryRow(SearchView.tryQueries)
            } else {
                SozlukRecentSearchesSection(
                    searches: recent,
                    select: { query = $0 },
                    remove: { forget($0) },
                    clear: { forgetAll() }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            if !topics.isEmpty {
                SozlukTopicGrid(topics: topics, putsChosenFirst: !model.activeTopicIDs.isEmpty)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
            }
            if recent.isEmpty && topics.isEmpty {
                WordListEmptyState(
                    systemImage: "character.book.closed",
                    title: "Kelime ara",
                    message: AttributedString("İngilizce bir kelime ya da Türkçe anlamını yaz."),
                    tip: SearchView.turkishLettersTip
                )
            } else {
                tip
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
        }
    }

    /// The topics to browse: the user's own topics first, then the others, each part in the
    /// content's order. Topics with only a handful of words are left out, as in the topic choice.
    private var browseTopics: [ContentTopic] {
        let topics = model.choosableTopics
        let chosen = model.activeTopicIDs
        return topics.filter { chosen.contains($0.id) } + topics.filter { !chosen.contains($0.id) }
    }

    /// "Türkçe harfleri yazmasan da bulur" (README "Sözlük"), with its example in bold.
    private static let turkishLettersTip = WordListEmptyState.message(
        "Türkçe harfleri yazmasan da bulur: ", "odunc", " yazınca ", "ödünç", " çıkar."
    )

    /// "Dene:" and the example capsules; at large text sizes they wrap onto more lines instead of
    /// running off the screen.
    private func tryRow(_ examples: [SearchTryExample]) -> some View {
        // No line spacing: the chips already reach 44 pt with transparent margins.
        DictionaryFlowLayout(itemSpacing: 8, lineSpacing: 0) {
            Text("Dene:")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink2)
            ForEach(examples, id: \.self) { example in
                Button {
                    query = example.text
                } label: {
                    Text(verbatim: example.text)
                }
                .buttonStyle(ChipButtonStyle())
                .modifier(SearchTryExampleVoice(example: example))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: Recent searches

    private func remember(_ text: String) {
        let updated = SozlukRecentSearches.adding(text, to: recentSearchLog)
        if updated != recentSearchLog {
            recentSearchLog = updated
        }
    }

    private func forget(_ search: String) {
        withAnimation(reduceMotion ? nil : .default) {
            recentSearchLog = SozlukRecentSearches.removing(search, from: recentSearchLog)
        }
        SozlukSpeech.announce([.turkish("Silindi")])
    }

    private func forgetAll() {
        withAnimation(reduceMotion ? nil : .default) {
            recentSearchLog = ""
        }
        SozlukSpeech.announce([.turkish("Son aramalar silindi")])
    }

    // MARK: Results

    /// Nothing found: what to try, and as "Dene" a shorter search that does find something (a
    /// misspelled word usually starts right: "brekfast" → "bre"), or the usual examples.
    private func noResults(for query: String) -> some View {
        let shorter = shorterQuery(for: query)
        let message = shorter.map { start in
            WordListEmptyState.message("Yazım hatası olabilir. Daha kısa yazmayı dene: ", start, ".")
        } ?? WordListEmptyState.message(
            "Kelimenin başını yazmayı dene. Türkçe harf gerekmez: ", "odunc", " yazınca ", "ödünç", " çıkar."
        )
        return VStack(alignment: .leading, spacing: 0) {
            tryRow(shorter.map { [SearchTryExample(text: $0)] } ?? SearchView.tryQueries)
            WordListEmptyState(
                systemImage: "magnifyingglass",
                title: "\"\(query)\" bulunamadı",
                message: message
            )
            addOwnWordButton(for: query)
        }
    }

    /// A search that reads as an English word (the rule of the user's words) can become one:
    /// "Kendi kelimeni ekle" with the word filled in. A bordered capsule: the screen has no filled
    /// button.
    @ViewBuilder
    private func addOwnWordButton(for query: String) -> some View {
        let lemma = CustomWordText.lemma(query)
        if CustomWordText.isSpeakable(lemma) && lemma.count <= CustomWordDraft.lemmaLimit {
            Button {
                customWordEditor = .add(lemma: lemma)
            } label: {
                Label("\"\(lemma)\" kelimesini kendin ekle", systemImage: "plus")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle())
            .accessibilityHint("Kelimeyi Türkçe anlamıyla kendi kelimelerine ekler; widget'ta ve Tekrar'da karşına çıkar.")
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
    }

    /// The query's first word (when the query has more) or its first three letters, whichever
    /// comes first that finds a word; nil when neither does.
    private func shorterQuery(for query: String) -> String? {
        guard let firstWord = query.split(whereSeparator: { $0.isWhitespace }).first else {
            return nil
        }
        let candidates = [String(firstWord), String(firstWord.prefix(3))]
        return candidates.first { candidate in
            candidate.count < query.count && !model.search(candidate, limit: 1).isEmpty
        }
    }

    /// Mockup `.res`: the filter, the count, the rows in one rounded group, the Turkish-letters
    /// tip under it. A filter that keeps nothing says so and offers every result again.
    private func resultList(_ found: [WidgetWord], terms: [String]) -> some View {
        let results = shownResults(found)
        return VStack(alignment: .leading, spacing: 0) {
            SozlukFilterBar(selection: $filter)
            if results.isEmpty {
                SozlukFilteredOut(
                    filter: filter,
                    message: "Bu aramada \(found.count) kelime var; hiçbiri bu süzgece uymuyor."
                ) {
                    filter = .all
                }
            } else {
                Text(verbatim: "\(results.count) sonuç")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .padding(.bottom, 6)
                SozlukRowGroup {
                    ForEach(Array(results.enumerated()), id: \.element.id) { index, word in
                        if index > 0 {
                            DictionaryRule()
                                .padding(.leading, 16)
                        }
                        SearchResultLink(word: word, terms: terms, open: open)
                    }
                }
            }
            tip
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    /// VoiceOver hears how many words the search found, once typing pauses (`task(id:)` cancels
    /// the wait at every letter).
    @MainActor
    private func announceResults(of text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, UIAccessibility.isVoiceOverRunning else {
            return
        }
        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else {
            return
        }
        let count = shownResults(search(trimmed)).count
        SozlukSpeech.announce([.turkish(count == 0 ? "Sonuç yok" : "\(count) sonuç")])
    }

    /// Mockup `.tip`.
    private var tip: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "lightbulb")
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            Text(SearchView.turkishLettersTip)
                .foregroundStyle(Theme.ink2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.footnote)
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
    }
}

/// A "Dene" example: what it types into the field, and whether VoiceOver reads it in English.
private struct SearchTryExample: Hashable {
    let text: String
    var isEnglish = false
}

/// An English "Dene" example is read in an English voice (audit V5): the whole button gets
/// `englishVoice()`, so it has no Turkish hint, which would be read in English too (is3-tema). A
/// Turkish one says what it does.
private struct SearchTryExampleVoice: ViewModifier {
    let example: SearchTryExample

    @ViewBuilder
    func body(content: Content) -> some View {
        if example.isEnglish {
            content
                .accessibilityLabel(Text(verbatim: example.text))
                .englishVoice()
        } else {
            content
                .accessibilityHint("Aramaya yazar")
        }
    }
}

/// One result as a `SozlukWordLink`: the typed part of the word or of its Turkish meaning is bold
/// and underlined; when the search matched neither but one of the other Turkish meanings,
/// "Ayrıca: …" under the meaning shows where.
private struct SearchResultLink: View {
    @EnvironmentObject private var model: AppModel
    let word: WidgetWord
    let terms: [String]
    let open: (WidgetWord) -> Void

    var body: some View {
        let lemmaMatch = SearchHighlight.matches(of: terms, in: word.lemma)
        let glossMatch = word.glossTR.map { SearchHighlight.matches(of: terms, in: $0) }
        // The mark goes where the whole query matched: the word first, then its meaning; a query
        // split between the two fields marks what it found in each.
        let marksLemma = lemmaMatch.coversAll || !(glossMatch?.coversAll ?? false)
        let marksGloss = !lemmaMatch.coversAll
        let alternatives = lemmaMatch.isEmpty && (glossMatch?.isEmpty ?? true) ? matchedAlternatives : nil
        SozlukWordLink(
            word: word,
            lemma: SearchHighlight.attributed(
                word.lemma,
                marking: marksLemma ? lemmaMatch.ranges : [],
                hitFont: Font.system(.title3, design: .serif).weight(.heavy)
            ),
            gloss: word.glossTR.map { gloss in
                SearchHighlight.attributed(
                    gloss,
                    marking: marksGloss ? (glossMatch?.ranges ?? []) : [],
                    hitFont: Font.body.weight(.heavy)
                )
            },
            note: alternatives,
            open: open
        )
    }

    /// "Ayrıca: …" with the match marked, when the query found neither the word nor its meaning
    /// (it found one of the other Turkish meanings, which the index also holds). Reads the card
    /// only for such rows.
    private var matchedAlternatives: AttributedString? {
        guard let alternatives = model.detail(for: word)?.glossAlternatives, !alternatives.isEmpty else {
            return nil
        }
        let joined = alternatives.joined(separator: ", ")
        let match = SearchHighlight.matches(of: terms, in: joined)
        guard !match.isEmpty else {
            return nil
        }
        var line = AttributedString("Ayrıca: ")
        line.append(SearchHighlight.attributed(joined, marking: match.ranges, hitFont: Font.caption.weight(.heavy)))
        return line
    }
}

/// Where the typed text matches a result, for the bold, underlined mark (README point 12).
/// The search folds Turkish letters and accents (`TextFold`: "odunc" finds "ödünç"), and
/// `TextFold.fold` also decomposes and collapses spaces, so a position in a folded string is not
/// a position in the shown text. Each character is therefore folded on its own and remembers
/// which character of the original it came from.
enum SearchHighlight {
    struct Match {
        /// Ranges of the shown text, sorted, not overlapping.
        let ranges: [Range<String.Index>]
        /// Every query word was found in this text.
        let coversAll: Bool

        var isEmpty: Bool {
            return ranges.isEmpty
        }
    }

    /// The query's words as the full-text index sees them: folded and split at anything that is
    /// not a letter or a digit ("Ödünç al" → ["odunc", "al"]).
    static func terms(of query: String) -> [String] {
        var terms: [String] = []
        for piece in TextFold.fold(query).split(whereSeparator: { !isWordCharacter($0) }) {
            let term = String(piece)
            if !terms.contains(term) {
                terms.append(term)
            }
        }
        return terms
    }

    /// For each term, the first word of `text` that starts with it once folded (the index matches
    /// word prefixes, so "fast" does not mark "breakfast").
    static func matches(of terms: [String], in text: String) -> Match {
        let folded = FoldedText(text)
        var found: [Range<String.Index>] = []
        var coversAll = !terms.isEmpty
        for term in terms {
            let needle = Array(term)
            guard let start = folded.firstWordStart(matching: needle) else {
                coversAll = false
                continue
            }
            found.append(folded.sources[start].lowerBound..<folded.sources[start + needle.count - 1].upperBound)
        }
        return Match(ranges: merged(found), coversAll: coversAll)
    }

    /// `text` with `ranges` underlined and in `hitFont` (a heavier weight of the line's font).
    static func attributed(_ text: String, marking ranges: [Range<String.Index>], hitFont: Font) -> AttributedString {
        var result = AttributedString()
        var cursor = text.startIndex
        for range in ranges where range.lowerBound >= cursor {
            result.append(AttributedString(String(text[cursor..<range.lowerBound])))
            var hit = AttributedString(String(text[range]))
            hit.font = hitFont
            hit.underlineStyle = Text.LineStyle(pattern: .solid)
            result.append(hit)
            cursor = range.upperBound
        }
        result.append(AttributedString(String(text[cursor...])))
        return result
    }

    fileprivate static func isWordCharacter(_ character: Character) -> Bool {
        return character.isLetter || character.isNumber
    }

    private static func merged(_ ranges: [Range<String.Index>]) -> [Range<String.Index>] {
        var result: [Range<String.Index>] = []
        for range in ranges.sorted(by: { $0.lowerBound < $1.lowerBound }) {
            if let last = result.last, range.lowerBound <= last.upperBound {
                result[result.count - 1] = last.lowerBound..<max(last.upperBound, range.upperBound)
            } else {
                result.append(range)
            }
        }
        return result
    }
}

/// `text` folded one character at a time: `characters[i]` came from `sources[i]` of the original
/// (a character can fold to none, one or several characters, e.g. "ﬁ" → "fi").
private struct FoldedText {
    private(set) var characters: [Character] = []
    private(set) var sources: [Range<String.Index>] = []

    init(_ text: String) {
        var index = text.startIndex
        while index < text.endIndex {
            let next = text.index(after: index)
            let character = text[index]
            // TextFold trims a lone space to nothing; a space must stay a word boundary.
            let folded = character.isWhitespace ? " " : TextFold.fold(String(character))
            for piece in folded {
                characters.append(piece)
                sources.append(index..<next)
            }
            index = next
        }
    }

    /// The first position where a word starts with `needle`.
    func firstWordStart(matching needle: [Character]) -> Int? {
        guard !needle.isEmpty, needle.count <= characters.count else {
            return nil
        }
        for start in 0...(characters.count - needle.count) {
            let startsWord = SearchHighlight.isWordCharacter(characters[start])
                && (start == 0 || !SearchHighlight.isWordCharacter(characters[start - 1]))
            if startsWord && characters[start..<(start + needle.count)].elementsEqual(needle) {
                return start
            }
        }
        return nil
    }
}

/// An empty list (mockup `.empty`): an icon in a soft circle, a title, a sentence whose examples
/// are bold, and optionally a tip after a light bulb. Used by "Sözlük" and "Bildiğin kelimeler".
struct WordListEmptyState: View {
    let systemImage: String
    let title: String
    let message: AttributedString
    /// A hint under the message (Sözlük: "Türkçe harfleri yazmasan da bulur").
    var tip: AttributedString? = nil
    @ScaledMetric(relativeTo: .title2) private var circleSize: CGFloat = 76

    var body: some View {
        let circle = min(circleSize, 120)
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: circle * 0.45))
                .foregroundStyle(Theme.ink2)
                .frame(width: circle, height: circle)
                .background(Theme.surface2, in: Circle())
                .accessibilityHidden(true)
                .padding(.bottom, 4)
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(.callout)
                .foregroundStyle(Theme.ink2)
                .lineSpacing(2)
            if let tip = tip {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Image(systemName: "lightbulb")
                        .accessibilityHidden(true)
                    Text(tip)
                }
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
                .padding(.top, 8)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity)
    }

    /// `pieces` alternate plain and emphasized text: ("a ", "b", " c") reads "a b c" with "b"
    /// bold in ink (the examples in an otherwise ink2 sentence).
    static func message(_ pieces: String...) -> AttributedString {
        var result = AttributedString()
        for (index, piece) in pieces.enumerated() {
            var part = AttributedString(piece)
            if index % 2 == 1 {
                part.inlinePresentationIntent = .stronglyEmphasized
                part.foregroundColor = Theme.ink
            }
            result.append(part)
        }
        return result
    }
}
