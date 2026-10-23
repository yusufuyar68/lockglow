import SwiftUI
import UIKit
import CoreModels
import Learning
import TextFold

/// "Sözlük": look a word up in English or Turkish (prefix search, Turkish letters folded), or
/// browse a topic, then open the whole card (mockup `#sozluk`). An empty field offers the "Dene"
/// examples, the recent searches and the topics as capsules; a topic opens its words by level
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
    @State private var showsAllTopics = false
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
    /// Topics shown before "Tüm konular".
    private static let collapsedTopicCount = 8

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

    /// The empty field: "Dene", the recent searches, the topics and the Turkish-letters tip. With
    /// neither recent searches nor topics (seed words only), the "Kelime ara" explanation instead.
    private var startPage: some View {
        let recent = SozlukRecentSearches.list(recentSearchLog)
        let topics = browseTopics
        return VStack(alignment: .leading, spacing: 0) {
            tryRow(SearchView.tryQueries)
            if !recent.isEmpty {
                SozlukRecentSearchesSection(
                    searches: recent,
                    select: { query = $0 },
                    remove: { forget($0) },
                    clear: { forgetAll() }
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            if !topics.isEmpty {
                topicSection(topics)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
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

    /// "Konuya göre göz at": a capsule per topic with its word count; a tap opens the topic's
    /// words. The first few at once, the rest behind "Tüm konular".
    private func topicSection(_ topics: [ContentTopic]) -> some View {
        let isCollapsible = topics.count > SearchView.collapsedTopicCount
        let shown = showsAllTopics || !isCollapsible ? topics : Array(topics.prefix(SearchView.collapsedTopicCount))
        let toggleTitle = showsAllTopics ? "Daha az göster" : "Tüm konular (\(topics.count))"
        return VStack(alignment: .leading, spacing: 6) {
            SozlukSectionTitle(title: "Konuya göre göz at")
            // No line spacing: the chips already reach 44 pt with transparent margins.
            DictionaryFlowLayout(itemSpacing: 8, lineSpacing: 0) {
                ForEach(shown) { topic in
                    NavigationLink(value: topic) {
                        HStack(spacing: 6) {
                            Text(topic.displayName)
                            Text(verbatim: "\(topic.cardCount)")
                                .foregroundStyle(Theme.ink2)
                                .monospacedDigit()
                        }
                    }
                    .buttonStyle(ChipButtonStyle())
                    .accessibilityLabel(Text(verbatim: "\(topic.displayName), \(topic.cardCount) kelime"))
                    .accessibilityHint("Bu konunun kelimelerini açar")
                }
                if isCollapsible {
                    Button {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                            showsAllTopics.toggle()
                        }
                    } label: {
                        Label(toggleTitle, systemImage: showsAllTopics ? "chevron.up" : "chevron.down")
                        .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(ChipButtonStyle())
                }
            }
        }
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

// MARK: - The whole card

/// The whole card as a word page (mockup `sz-detail`), read top to bottom: the word on its band
/// with pronunciation, part of speech, level, "Dinle" and "Söyle"; the Turkish meaning (and
/// "Ayrıca"); the definition; every example with its Turkish; the "Dikkat" boxes with the note
/// and memory hook; the word partners as capsules that read themselves aloud; last the learning
/// status with the one button that changes it. Few, quiet section titles: the Dikkat boxes carry
/// their own. Opened from "Sözlük", "Bildiğin kelimeler" and the feed (in a sheet).
struct WordDetailView: View {
    @EnvironmentObject private var model: AppModel
    let word: WidgetWord

    var body: some View {
        let detail = model.detail(for: word)
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // The night band hangs below the word: the 12 pt spacing leaves it room.
                WordDetailHeadline(lemma: word.lemma)
                WordDetailMetaRow(word: word)
                meaning(alternatives: detail?.glossAlternatives ?? [])
                // A user's word has no English definition (and maybe no example).
                if !word.defShort.isEmpty {
                    Text(word.defShort)
                        .definitionStyle()
                        .lineSpacing(2)
                        .cardEnglishVoice()
                }
                if !(detail?.examples ?? []).isEmpty || !word.exampleEN.isEmpty {
                    examplesSection(detail?.examples ?? [])
                }
                cautionSection(detail)
                if let collocations = detail?.collocations, !collocations.isEmpty {
                    collocationsSection(collocations)
                }
                WordDetailStatusSection(word: word)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            // The scroll view already keeps clear of the tab bar; this is the page's own margin
            // under the last button.
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
        .hardTopScrollEdge()
        .tint(Theme.ink)
    }

    @ViewBuilder
    private func meaning(alternatives: [String]) -> some View {
        if let gloss = word.glossTR {
            VStack(alignment: .leading, spacing: 2) {
                Text(gloss)
                    .meaningStyle()
                    .accessibilityLabel(Text(verbatim: "Türkçesi: " + gloss))
                if !alternatives.isEmpty {
                    Text("Ayrıca: " + alternatives.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                }
            }
            .padding(.top, 4)
        }
    }

    /// Every example (mockup `.exrow`) with its Turkish, the word bold but not yellow: the band
    /// is the screen's one yellow mark. Without card details, the word's own example.
    private func examplesSection(_ examples: [CardDetail.Example]) -> some View {
        let shown = examples.isEmpty ? [CardDetail.Example(en: word.exampleEN)] : examples
        return WordDetailSection(title: "Örnekler") {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(shown.enumerated()), id: \.offset) { index, example in
                    if index > 0 {
                        DictionaryRule()
                    }
                    ExampleRow(example: example, lemma: word.lemma)
                        .padding(.vertical, 8)
                }
            }
        }
    }

    /// The typical mistakes, each in its own "Dikkat" box with the difference marked (README
    /// point 5), then the note and the memory hook (mockup `.info`). No section title: every box
    /// is titled "Dikkat" itself.
    @ViewBuilder
    private func cautionSection(_ detail: CardDetail?) -> some View {
        let mistakes = detail?.mistakes ?? []
        let note = WordDetailView.nonEmpty(detail?.noteTR)
        let mnemonic = WordDetailView.nonEmpty(detail?.mnemonicTR)
        if !mistakes.isEmpty || note != nil || mnemonic != nil {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(mistakes.enumerated()), id: \.offset) { _, mistake in
                    MistakeBox(mistake: mistake)
                }
                if let note = note {
                    WordDetailInfoRow(systemImage: "info.circle", text: note)
                }
                if let mnemonic = mnemonic {
                    WordDetailInfoRow(systemImage: "lightbulb", title: "Hafıza ipucu", text: mnemonic)
                }
            }
            .padding(.top, 12)
        }
    }

    /// Word partners as capsules that wrap onto more lines (rule 2: a capsule is tappable; a tap
    /// reads the phrase aloud).
    private func collocationsSection(_ collocations: [String]) -> some View {
        WordDetailSection(title: "Birlikte kullanılır") {
            // No line spacing: the chips already reach 44 pt with transparent margins.
            DictionaryFlowLayout(itemSpacing: 8, lineSpacing: 0) {
                ForEach(Array(collocations.enumerated()), id: \.offset) { _, phrase in
                    WordDetailCollocationCapsule(phrase: phrase)
                }
            }
        }
    }

    private static func nonEmpty(_ text: String?) -> String? {
        guard let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return text
    }
}

/// The English word on its phosphor band. A phrase too long for one line at the full size first
/// tries a smaller size, then breaks into two balanced lines, each on its own band; a single long
/// word shrinks instead. VoiceOver reads it once, as a heading, with an English voice.
private struct WordDetailHeadline: View {
    let lemma: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            line(lemma, size: 40)
            line(lemma, size: 32)
            if let lines = WordDetailHeadline.balancedLines(lemma) {
                VStack(alignment: .leading, spacing: 12) {
                    line(lines.first, size: 34)
                    line(lines.second, size: 34)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: lemma))
        .accessibilityAddTraits(.isHeader)
        .cardEnglishVoice()
    }

    private func line(_ text: String, size: CGFloat) -> some View {
        Text(text)
            .englishWordStyle(size: size, maxSize: size * 1.4)
            .phosphorBand()
    }

    /// `phrase` cut at the space that makes the longer line shortest; nil for a single word.
    static func balancedLines(_ phrase: String) -> (first: String, second: String)? {
        let words = phrase.split(separator: " ").map(String.init)
        guard words.count > 1 else {
            return nil
        }
        var best: (first: String, second: String)?
        var bestLength = Int.max
        for cut in 1..<words.count {
            let first = words[..<cut].joined(separator: " ")
            let second = words[cut...].joined(separator: " ")
            let longer = max(first.count, second.count)
            // On a tie the later cut: a longer first line reads more naturally.
            if longer <= bestLength {
                bestLength = longer
                best = (first, second)
            }
        }
        return best
    }
}

/// Pronunciation, part of speech and level, then "Dinle" and "Söyle" on the trailing edge
/// (mockup `.wmeta`). When the line is too narrow the buttons move to their own line, and at the
/// largest sizes the pronunciation too.
private struct WordDetailMetaRow: View {
    let word: WidgetWord

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                ipa
                partOfSpeech
                level
                Spacer(minLength: 4)
                actions
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    ipa
                    partOfSpeech
                    level
                }
                actions
            }
            VStack(alignment: .leading, spacing: 4) {
                ipa
                HStack(spacing: 8) {
                    partOfSpeech
                    level
                }
                actions
            }
        }
    }

    /// Visual only: VoiceOver says the word itself, and "Dinle" plays it.
    @ViewBuilder
    private var ipa: some View {
        if let ipa = word.ipaUS {
            Text(ipa)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
        }
    }

    /// A user's word: "Senin kelimen" in place of the part of speech, and no level.
    @ViewBuilder
    private var partOfSpeech: some View {
        if word.isUserAdded {
            CustomWordTag()
        } else {
            Text(CardPartOfSpeech.turkish(word.pos))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.ink2)
        }
    }

    @ViewBuilder
    private var level: some View {
        if !word.isUserAdded {
            LevelBadge(code: word.level)
                .fixedSize()
        }
    }

    private var actions: some View {
        HStack(spacing: 2) {
            CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle")
            SayButton(word: word, example: word.exampleEN)
        }
    }
}

/// A titled part of the word page (mockup `.sect`), kept quiet: a small ink2 title in sentence
/// case, a heading for VoiceOver, more room above than below.
private struct WordDetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A note with its icon (mockup `.info`), optionally under a bold title.
private struct WordDetailInfoRow: View {
    let systemImage: String
    var title: String? = nil
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                if let title = title {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                }
                Text(text)
                    .lineSpacing(2)
            }
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.callout)
        .accessibilityElement(children: .combine)
    }
}

/// A word partner ("have breakfast"): a chip in serif (English) with a small speaker; a tap reads
/// the phrase aloud, a second tap stops it. The speaker waves while it reads, unless Reduce
/// Motion is on. VoiceOver name "Dinle: have breakfast" (the phrase in its English run), "Durdur"
/// while it reads; no hint, as on every speaker button.
private struct WordDetailCollocationCapsule: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let phrase: String

    var body: some View {
        let isSpeaking = speaker.speakingText == phrase
        Button {
            speaker.toggle(phrase)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
                    .accessibilityHidden(true)
                Text(verbatim: phrase)
                    .font(.system(.subheadline, design: .serif).weight(.semibold))
            }
        }
        .buttonStyle(ChipButtonStyle())
        .accessibilityLabel(isSpeaking ? Text("Durdur") : SozlukSpeech.label([.turkish("Dinle: "), .english(phrase)]))
        // Voice Control: "Dinle'ye dokun", as on the other speaker buttons.
        .accessibilityInputLabels([Text(isSpeaking ? "Durdur" : "Dinle")])
    }
}

/// "Durum", last on the card (README "Sözlük"): where the word stands, on a line of its own,
/// and under it the one outlined button that changes it. Not a segment: nothing looks selected.
/// The button is replaced by the other one; VoiceOver hears what changed and its focus moves to
/// the new button (audit V7).
private struct WordDetailStatusSection: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// On the status button: kept there when it is replaced by the other one.
    @AccessibilityFocusState private var buttonHasFocus: Bool
    let word: WidgetWord

    var body: some View {
        let state = model.learningState(of: word)
        WordDetailSection(title: "Durum") {
            VStack(alignment: .leading, spacing: 12) {
                // Rule 4: the state is said in words and with an icon, not by color alone; the
                // same icons as the marks and filters of Sözlük's lists.
                Label {
                    Text(SozlukStatus.title(state))
                } icon: {
                    Image(systemName: SozlukStatus.symbol(state))
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(state == .known ? Theme.good : Theme.ink)
                // A "Biliyorum" still waiting for its one check question (ogrenme_ilkeleri 2.2).
                if state == .known, let check = checkLine {
                    Text(check)
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                }
                if state == .known {
                    Button {
                        change {
                            model.undoKnown(word)
                        }
                        if model.learningState(of: word) != .known {
                            // terimler.md: "Öğrenmeye döndü: breakfast" (no suffix on the word).
                            SozlukSpeech.announce([.turkish("Öğrenmeye döndü: "), .english(word.lemma)])
                        }
                    } label: {
                        Label("Öğrenmeye geri al", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle())
                    .accessibilityLabel("Öğrenmeye geri al")
                    .accessibilityHint("Kelime yine widget'a ve Tekrar'a gelir.")
                    .accessibilityFocused($buttonHasFocus)
                } else {
                    Button {
                        change {
                            model.markKnown(word)
                        }
                        if model.learningState(of: word) == .known {
                            // As the feed's "Tamam. 3 gün sonra bir kez soracağız." (`KnownUndo`).
                            var runs: [SozlukSpeech.Run] = [.turkish("Biliyorum olarak işaretlendi: "), .english(word.lemma)]
                            if let check = checkLine {
                                runs.append(.turkish(". " + check))
                            }
                            SozlukSpeech.announce(runs)
                        }
                    } label: {
                        Label("Biliyorum olarak işaretle", systemImage: "checkmark")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle())
                    .accessibilityLabel("Biliyorum olarak işaretle")
                    // `Leitner.markKnown`: one check question later (ogrenme_ilkeleri 2.2).
                    .accessibilityHint(Text(verbatim: "Kelime widget'tan çıkar. \(WordDetailStatusSection.checkDays) gün sonra bir kez soracağız."))
                    .accessibilityFocused($buttonHasFocus)
                    // LockglowScreenshotTests looks this button up as "Biliyorum".
                    .accessibilityIdentifier("Biliyorum")
                }
            }
        }
    }

    /// Days until the check question of a new "Biliyorum" (`Leitner.knownCheckDelay`).
    private static let checkDays = Int((Leitner.knownCheckDelay / 86_400).rounded())

    /// "3 gün sonra bir kez soracağız." while the word waits for its check, from its due date
    /// (`FeedView.checkLine`); nil for a word learned in "Tekrar".
    private var checkLine: String? {
        guard let progress = model.progress[word.id], progress.awaitsKnownCheck else {
            return nil
        }
        return FeedView.checkLine(due: progress.dueAt)
    }

    /// The change, then VoiceOver's focus on the button that replaced the tapped one, once it is
    /// on screen.
    private func change(_ update: () -> Void) {
        let hadFocus = buttonHasFocus
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            update()
        }
        guard hadFocus else {
            return
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            buttonHasFocus = true
        }
    }
}

private extension View {
    /// iOS 26: a solid edge effect under the bar on a scrolled page (10-geri-alindi), so the
    /// status bar and the back button do not stand on the text that scrolled under them.
    /// iOS 17–25 keep the system's own bar.
    @ViewBuilder func hardTopScrollEdge() -> some View {
        if #available(iOS 26.0, *) {
            scrollEdgeEffectStyle(.hard, for: .top)
        } else {
            self
        }
    }
}
