import SwiftUI
import CoreModels
import Learning
import TextFold

/// "Sözlük": look a word up in English or Turkish (prefix search, Turkish letters folded), then
/// open the whole card (mockup `#sozluk`). An empty field offers "Dene" examples; in the results
/// the typed part is bold and underlined, never yellow (rule 1).
struct SearchView: View {
    @EnvironmentObject private var model: AppModel
    @State private var query = ""

    /// "Dene" examples (mockup `.try`): a Turkish start, the same kind without Turkish letters,
    /// a Turkish word and an English start.
    private static let tryQueries = ["kahv", "odunc", "randevu", "break"]

    var body: some View {
        NavigationStack {
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
            .navigationDestination(for: WidgetWord.self) { word in
                WordDetailView(word: word)
            }
        }
        // Rule 2: no blue link color on the search field, its cancel button or the back button.
        .tint(Theme.ink)
    }

    @ViewBuilder
    private var content: some View {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                tryRow
                WordListEmptyState(
                    systemImage: "character.book.closed",
                    title: "Kelime ara",
                    message: WordListEmptyState.message(
                        "İngilizce bir kelime ya da Türkçe anlamını yaz. ", "kahv", " yazınca ", "breakfast", " çıkar."
                    )
                )
            }
        } else {
            let results = model.search(trimmed)
            if results.isEmpty {
                WordListEmptyState(
                    systemImage: "magnifyingglass",
                    title: "\"\(trimmed)\" bulunamadı",
                    message: WordListEmptyState.message(
                        "Kelimenin başını yazmayı dene. Türkçe harfler gerekmez: ", "odunc", " da ", "ödünç", " bulur."
                    )
                )
            } else {
                resultList(results, terms: SearchHighlight.terms(of: trimmed))
            }
        }
    }

    /// "Dene:" and the example chips, in one line that scrolls sideways at large text sizes.
    private var tryRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Text("Dene:")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                ForEach(SearchView.tryQueries, id: \.self) { example in
                    Button {
                        query = example
                    } label: {
                        Text(verbatim: example)
                    }
                    .buttonStyle(ChipButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .padding(.top, 4)
    }

    /// Mockup `.res`: the count, the rows in one rounded group, the Turkish-letters tip under it.
    private func resultList(_ results: [WidgetWord], terms: [String]) -> some View {
        let group = RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous)
        return VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: "\(results.count) sonuç")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
            LazyVStack(spacing: 0) {
                ForEach(Array(results.enumerated()), id: \.element.id) { index, word in
                    if index > 0 {
                        DictionaryRule()
                            .padding(.leading, 16)
                    }
                    NavigationLink(value: word) {
                        SearchResultRow(word: word, terms: terms)
                    }
                    .buttonStyle(SearchResultButtonStyle())
                }
            }
            .background(Theme.surface)
            .clipShape(group)
            .overlay {
                group.strokeBorder(Theme.line, lineWidth: 1)
            }
            tip
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    /// Mockup `.tip`.
    private var tip: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "lightbulb")
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            Text(WordListEmptyState.message("Türkçe harfleri yazmasan da bulur: ", "odunc", " yazınca ", "ödünç", " çıkar."))
                .foregroundStyle(Theme.ink2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.footnote)
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
    }
}

/// One result (mockup `.rrow`): the serif word with its level (and a check when it is known),
/// the Turkish meaning in ink, then the short English definition, or the other Turkish meanings
/// when the search matched one of those.
private struct SearchResultRow: View {
    @EnvironmentObject private var model: AppModel
    let word: WidgetWord
    let terms: [String]

    var body: some View {
        let lemmaMatch = SearchHighlight.matches(of: terms, in: word.lemma)
        let glossMatch = word.glossTR.map { SearchHighlight.matches(of: terms, in: $0) }
        // The mark goes where the whole query matched: the word first, then its meaning; a query
        // split between the two fields marks what it found in each.
        let marksLemma = lemmaMatch.coversAll || !(glossMatch?.coversAll ?? false)
        let marksGloss = !lemmaMatch.coversAll
        let alternatives = lemmaMatch.isEmpty && (glossMatch?.isEmpty ?? true) ? matchedAlternatives : nil

        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(SearchHighlight.attributed(
                        word.lemma,
                        marking: marksLemma ? lemmaMatch.ranges : [],
                        hitFont: Font.system(.title3, design: .serif).weight(.heavy)
                    ))
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .cardEnglishVoice()
                    LevelBadge(code: word.level)
                        .fixedSize()
                    if model.learningState(of: word) == .known {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(Theme.good)
                            .accessibilityLabel("Biliyorsun")
                    }
                }
                if let gloss = word.glossTR, let glossMatch = glossMatch {
                    Text(SearchHighlight.attributed(
                        gloss,
                        marking: marksGloss ? glossMatch.ranges : [],
                        hitFont: Font.body.weight(.heavy)
                    ))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                }
                if let alternatives = alternatives {
                    Text(alternatives)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.ink2)
                } else {
                    Text(word.defMicro)
                        .font(.system(.footnote, design: .serif))
                        .foregroundStyle(Theme.ink2)
                        .cardEnglishVoice()
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
        .frame(minHeight: 68)
        .contentShape(Rectangle())
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

/// A result row's press feedback: the row darkens like a list cell.
private struct SearchResultButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Theme.surface2 : Color.clear)
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

/// An empty list (mockup `.empty`): an icon in a soft circle, a title, and a sentence whose
/// examples are bold. Used by "Sözlük" and "Bildiğim kelimeler".
struct WordListEmptyState: View {
    let systemImage: String
    let title: String
    let message: AttributedString
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

/// A 1 pt `line` rule between rows (mockup `border-top: 1px solid var(--line)`).
private struct DictionaryRule: View {
    var body: some View {
        Rectangle()
            .fill(Theme.line)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

// MARK: - The whole card

/// The whole card (mockup `sz-detail`): the word on its band, pronunciation, part of speech,
/// level, "Dinle" and "Söyle"; the Turkish meaning (and alternatives) and the definition; then
/// sections in sentence case: every example with its Turkish, typical mistakes, the note and
/// memory hook, common word partners, and last the learning status with the one action that
/// changes it. Opened from "Sözlük", "Bildiğim kelimeler" and the feed (in a sheet).
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
                Text(word.defShort)
                    .definitionStyle()
                    .lineSpacing(2)
                    .cardEnglishVoice()
                examplesSection(detail?.examples ?? [])
                if let mistakes = detail?.mistakes, !mistakes.isEmpty {
                    mistakesSection(mistakes)
                }
                notesSection(note: detail?.noteTR, mnemonic: detail?.mnemonicTR)
                if let collocations = detail?.collocations, !collocations.isEmpty {
                    collocationsSection(collocations)
                }
                WordDetailStatusSection(word: word)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
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
        }
    }

    /// Every example (mockup `.exrow`), the word bold but not yellow: the band is the screen's
    /// one yellow mark. Without card details, the word's own example.
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

    private func mistakesSection(_ mistakes: [CardDetail.Mistake]) -> some View {
        WordDetailSection(title: "Sık yapılan hatalar") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(mistakes.enumerated()), id: \.offset) { _, mistake in
                    MistakeBox(mistake: mistake)
                }
            }
        }
    }

    /// Mockup `.info` rows. The title names what the card has: almost every card has a note,
    /// few a memory hook.
    @ViewBuilder
    private func notesSection(note: String?, mnemonic: String?) -> some View {
        if note != nil || mnemonic != nil {
            let hasBoth = note != nil && mnemonic != nil
            WordDetailSection(title: hasBoth ? "Not ve hafıza ipucu" : (note != nil ? "Not" : "Hafıza ipucu")) {
                VStack(alignment: .leading, spacing: 12) {
                    if let note = note {
                        WordDetailInfoRow(systemImage: "info.circle", text: note)
                    }
                    if let mnemonic = mnemonic {
                        WordDetailInfoRow(systemImage: "lightbulb", title: hasBoth ? "Hafıza ipucu" : nil, text: mnemonic)
                    }
                }
            }
        }
    }

    /// Mockup `.colls`: one phrase per line in a soft box. Not capsules: they are not tappable
    /// (rule 2).
    private func collocationsSection(_ collocations: [String]) -> some View {
        WordDetailSection(title: "Birlikte kullanılır") {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(collocations.enumerated()), id: \.offset) { index, phrase in
                    if index > 0 {
                        DictionaryRule()
                    }
                    Text(phrase)
                        .font(.system(.callout, design: .serif))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardEnglishVoice()
                }
            }
            .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
        }
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

    private var partOfSpeech: some View {
        Text(CardPartOfSpeech.turkish(word.pos))
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.ink2)
    }

    private var level: some View {
        LevelBadge(code: word.level)
            .fixedSize()
    }

    private var actions: some View {
        HStack(spacing: 2) {
            CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle")
            SayButton(word: word, example: word.exampleEN)
        }
    }
}

/// A titled part of the whole card (mockup `.sect`): the title in sentence case, a heading for
/// VoiceOver, a little more room above than below.
private struct WordDetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(.top, 8)
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

/// "Durum", last on the card (README "Sözlük"): where the word stands, on a line of its own,
/// and under it the one outlined button that changes it. Not a segment: nothing looks selected.
private struct WordDetailStatusSection: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let word: WidgetWord

    var body: some View {
        let state = model.learningState(of: word)
        WordDetailSection(title: "Durum") {
            VStack(alignment: .leading, spacing: 12) {
                // Rule 4: the state is said in words and with an icon, not by color alone.
                Label {
                    Text(statusText(state))
                } icon: {
                    Image(systemName: statusSymbol(state))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(state == .known ? Theme.good : Theme.ink2)
                if state == .known {
                    Button {
                        change {
                            model.undoKnown(word)
                        }
                    } label: {
                        Label("Öğrenmeye geri al", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle())
                    .accessibilityLabel("Öğrenmeye geri al")
                } else {
                    Button {
                        change {
                            model.markKnown(word)
                        }
                    } label: {
                        Label("Biliyorum olarak işaretle", systemImage: "checkmark")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle())
                    .accessibilityLabel("Biliyorum olarak işaretle")
                    // LockglowScreenshotTests looks this button up as "Biliyorum".
                    .accessibilityIdentifier("Biliyorum")
                }
            }
        }
    }

    private func change(_ update: () -> Void) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            update()
        }
    }

    private func statusText(_ state: LearningState) -> String {
        switch state {
        case .new:
            return "Yeni kelime"
        case .learning:
            return "Öğreniyorsun"
        case .known:
            return "Biliyorsun"
        }
    }

    private func statusSymbol(_ state: LearningState) -> String {
        switch state {
        case .new:
            return "circle.dashed"
        case .learning:
            return "circle.lefthalf.filled"
        case .known:
            return "checkmark.circle.fill"
        }
    }
}
