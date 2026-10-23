import SwiftUI
import Accessibility
import CoreModels

// Pieces of a card's detail (from `CardDetail`) shared by the feed, the "Tekrar" cards and the
// "Sözlük" card, in the design of docs/tasarim/README.md (tokens in Shared/LockglowTheme.swift).
// Card text is shown verbatim (String, not LocalizedStringKey): no lookup, no Markdown.
// English text is serif and never italic; Turkish text is SF Pro (rule 3).

/// An English example with its Turkish translation under it (mockup `.exrow`), and a round
/// speaker that reads the English sentence aloud. With `lemma`, the learned word is bold in the
/// sentence; `marksWord` adds the yellow mark, for a card's first example only (rule 1: a card
/// shows at most one marked example). At accessibility text sizes the speaker goes under the
/// translation, so the sentence keeps the full width.
struct ExampleRow: View {
    let example: CardDetail.Example
    var lemma: String? = nil
    var marksWord = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 4) {
                texts
                speaker
            }
        } else {
            HStack(alignment: .top, spacing: 4) {
                texts
                // The 44 pt target reaches past the row's top and bottom instead of making it taller.
                speaker
                    .padding(.vertical, -7)
            }
        }
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: 2) {
            sentence
                .exampleStyle()
                // About 1.45 line height (ogrenme_ilkeleri 2.2).
                .lineSpacing(4)
                .cardEnglishVoice()
            if let tr = example.tr {
                Text(tr)
                    .exampleTranslationStyle()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var speaker: some View {
        CardSentenceSpeaker(text: example.en, accessibilityName: "Cümleyi dinle")
    }

    private var sentence: Text {
        guard let lemma = lemma else {
            return Text(example.en)
        }
        return Text(ExampleMark.attributed(example.en, lemma: lemma, colorScheme: colorScheme, highlighted: marksWord))
    }
}

/// "Dikkat" box (mockup `.mist`): a mistake Turkish speakers typically make with this word, the
/// right form, and why. The words that differ are underlined (dotted in the wrong sentence, solid
/// and bold in the right one, README point 5). Labelled in words with an icon ("Yanlış",
/// "Doğru"), so the meaning never depends on color (rule 4); VoiceOver hears the underline as
/// "Fark: did yerine had" after the heading (audit V12). `showsWhy: false` hides the
/// explanation (the feed card's second shortening step). Everything on the box's `surface2` is
/// `ink`: `ink2` there stays under 7:1 (ogrenme_ilkeleri 2.2, contrast). Two text sizes: Callout
/// for the Turkish lines (heading, labels, reason), the example's serif size for the sentences.
struct MistakeBox: View {
    let mistake: CardDetail.Mistake
    var showsWhy = true
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let diff = MistakeDiff(mistake)
        VStack(alignment: .leading, spacing: 8) {
            heading(difference: MistakeBox.difference(mistake))
            if dynamicTypeSize.isAccessibilitySize {
                // No room for a label column: each label above its sentence.
                VStack(alignment: .leading, spacing: 4) {
                    tag(isRight: false)
                    wrongSentence(diff)
                    tag(isRight: true)
                        .padding(.top, 4)
                    rightSentence(diff)
                }
            } else {
                Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow {
                        tag(isRight: false)
                        wrongSentence(diff)
                    }
                    GridRow {
                        tag(isRight: true)
                        rightSentence(diff)
                    }
                }
            }
            if showsWhy {
                // 16 pt ink, not 15 pt ink2 (ogrenme_ilkeleri 2.2, type table).
                Text(mistake.why)
                    .font(.callout)
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
    }

    @ViewBuilder
    private func heading(difference: String?) -> some View {
        let title = HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.caution)
                .accessibilityHidden(true)
            Text("Dikkat")
                .font(.callout.weight(.bold))
                .foregroundStyle(Theme.ink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        if let difference = difference {
            title
                .accessibilityCustomContent(Text("Fark"), Text(verbatim: difference), importance: .high)
        } else {
            title
        }
    }

    /// The underlined words in a sentence: "did yerine had"; "Eklenen: to" when the right sentence
    /// only adds words, "Çıkan: the" when it only drops them. Nil when nothing is marked. The
    /// words stand alone, with no Turkish suffix (terimler.md).
    static func difference(_ mistake: CardDetail.Mistake) -> String? {
        let snippet = MistakeSnippet(mistake)
        let wrong = snippet.wrong.filter { $0.isChanged }.map { $0.text }.joined(separator: " ")
        let right = snippet.right.filter { $0.isChanged }.map { $0.text }.joined(separator: " ")
        switch (wrong.isEmpty, right.isEmpty) {
        case (false, false):
            return "\(wrong) yerine \(right)"
        case (true, false):
            return "Eklenen: \(right)"
        case (false, true):
            return "Çıkan: \(wrong)"
        case (true, true):
            return nil
        }
    }

    private func tag(isRight: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isRight ? "checkmark" : "xmark")
                .imageScale(.small)
                .fontWeight(.black)
                .accessibilityHidden(true)
            Text(isRight ? "Doğru" : "Yanlış")
        }
        .font(.callout.weight(.bold))
        .foregroundStyle(isRight ? Theme.good : Theme.bad)
        .fixedSize()
    }

    // The example's size (Body serif, `exampleFont`), not Callout (ogrenme_ilkeleri 2.2, type table).
    private func wrongSentence(_ diff: MistakeDiff) -> some View {
        Text(diff.wrongText())
            .exampleFont()
            .foregroundStyle(Theme.ink)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardEnglishVoice()
    }

    private func rightSentence(_ diff: MistakeDiff) -> some View {
        Text(diff.rightText())
            .exampleFont(bold: true)
            .foregroundStyle(Theme.ink)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardEnglishVoice()
    }
}

// MARK: - The card's warning slot (ogrenme_ilkeleri 2.2)

/// What may fill a card's one warning slot, in priority order (ogrenme_ilkeleri 2.2): a false
/// friend, the Dikkat mistake, two Turkish words for one English word, a phrasal verb that is
/// one verb in Turkish. Pronunciation labels belong between the mistake and the two meanings
/// once the content has them.
enum CardWarning: Equatable {
    /// "aktüel ≠ actually · aktüel = current".
    case falseFriend(CardDetail.FalseFriend)
    /// "✕ two spoon → ✓ two spoons".
    case mistake(CardDetail.Mistake)
    /// "amca / dayı": "İngilizcede ikisi de: uncle". `count` Turkish words.
    case sameWord(count: Int)
    /// "Türkçede tek fiil: kalkmak → İngilizcede iki parça: get up".
    case phrasalVerb(turkishVerb: String, parts: Int)

    /// Every warning the card has, the slot's first.
    static func all(for word: WidgetWord, detail: CardDetail?) -> [CardWarning] {
        var warnings: [CardWarning] = []
        if let falseFriend = detail?.falseFriend {
            warnings.append(.falseFriend(falseFriend))
        }
        if let mistake = detail?.cardMistake(lemma: word.lemma) {
            warnings.append(.mistake(mistake))
        }
        let firstMeaning = CardWarning.firstMeaning(word.glossTR)
        let equivalents = firstMeaning.components(separatedBy: " / ").filter { !$0.isEmpty }
        if equivalents.count > 1 {
            warnings.append(.sameWord(count: equivalents.count))
        }
        let parts = word.lemma.split(separator: " ").count
        if word.pos == "phv", parts > 1, let verb = equivalents.first, !verb.contains(" "),
           verb.hasSuffix("mak") || verb.hasSuffix("mek") {
            warnings.append(.phrasalVerb(turkishVerb: verb, parts: parts))
        }
        return warnings
    }

    /// The gloss up to its first comma: synonyms after a comma are not a second meaning, the
    /// " / " pairs are ("amca / dayı").
    private static func firstMeaning(_ gloss: String?) -> String {
        let meaning = gloss?.components(separatedBy: ",").first ?? ""
        return meaning.trimmingCharacters(in: .whitespaces)
    }

    /// The false friend and the mistake have more to say on the "Neden?" sheet.
    var hasExplanation: Bool {
        switch self {
        case .falseFriend, .mistake:
            return true
        case .sameWord, .phrasalVerb:
            return false
        }
    }
}

extension CardDetail {
    /// The card's Dikkat: the first mistake whose wrong or right sentence has the card's word
    /// in it ("actually" otherwise shows a mistake about "actual"), else the first one.
    func cardMistake(lemma: String) -> Mistake? {
        let about = mistakes.first { mistake in
            LemmaMatch.range(of: lemma, in: mistake.right) != nil || LemmaMatch.range(of: lemma, in: mistake.wrong) != nil
        }
        return about ?? mistakes.first
    }
}

/// The part of a Dikkat pair that differs, with one shared word on each side, for the card's
/// one-line Dikkat: "I have two spoon." / "I have two spoons." gives "two spoon" / "two spoons";
/// a missing word keeps the words around its place ("listen music" / "listen to music"). Words
/// are compared as in `MistakeDiff` (the first right option, ignoring case and punctuation).
/// A snippet that reaches the end of its sentence drops the final punctuation.
struct MistakeSnippet: Equatable {
    struct Word: Equatable {
        let text: String
        /// Not in the other sentence: marked as `MistakeDiff` marks it.
        let isChanged: Bool
    }

    let wrong: [Word]
    let right: [Word]

    init(_ mistake: CardDetail.Mistake) {
        self.init(wrong: mistake.wrong, right: mistake.right)
    }

    init(wrong: String, right: String) {
        let rightOption = right.components(separatedBy: " / ").first ?? right
        let wrongTokens = MistakeSnippet.tokens(MistakeSnippet.withoutNotes(wrong))
        let rightTokens = MistakeSnippet.tokens(MistakeSnippet.withoutNotes(rightOption))
        guard !wrongTokens.isEmpty, !rightTokens.isEmpty else {
            self.wrong = wrongTokens.map { Word(text: $0, isChanged: false) }
            self.right = rightTokens.map { Word(text: $0, isChanged: false) }
            return
        }
        let pairs = MistakeSnippet.matchedPairs(wrongTokens, rightTokens)
        // The matched words, with one before the start and one after the end: a gap between
        // two neighbours is a difference.
        let anchors: [(wrong: Int, right: Int)] = [(wrong: -1, right: -1)] + pairs + [(wrong: wrongTokens.count, right: rightTokens.count)]
        var firstGap: Int?
        var lastGap = 0
        for index in 0..<(anchors.count - 1) {
            let here = anchors[index]
            let next = anchors[index + 1]
            if next.wrong - here.wrong > 1 || next.right - here.right > 1 {
                firstGap = firstGap ?? index
                lastGap = index
            }
        }
        var wrongRange = 0...(wrongTokens.count - 1)
        var rightRange = 0...(rightTokens.count - 1)
        if let firstGap = firstGap {
            let start = anchors[firstGap]
            let end = anchors[lastGap + 1]
            wrongRange = max(start.wrong, 0)...min(end.wrong, wrongTokens.count - 1)
            rightRange = max(start.right, 0)...min(end.right, rightTokens.count - 1)
        }
        let keptWrong = Set(pairs.map { $0.wrong })
        let keptRight = Set(pairs.map { $0.right })
        self.wrong = MistakeSnippet.words(wrongTokens, in: wrongRange, keeping: keptWrong)
        self.right = MistakeSnippet.words(rightTokens, in: rightRange, keeping: keptRight)
    }

    /// The wrong words, the changed ones underlined with dots in `color`.
    func wrongText(color: Color = Theme.bad) -> AttributedString {
        return MistakeSnippet.attributed(wrong) { piece in
            piece.underlineStyle = Text.LineStyle(pattern: .dot, color: color)
        }
    }

    /// The right words, the changed ones underlined (in the text color).
    func rightText() -> AttributedString {
        return MistakeSnippet.attributed(right) { piece in
            piece.underlineStyle = Text.LineStyle(pattern: .solid)
        }
    }

    private static func tokens(_ sentence: String) -> [String] {
        return sentence.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    }

    /// Without a Turkish note in the English sentence ("… English. (= şu anda)", a few cards): it
    /// is not part of the difference and would stretch the line to the sentence's end.
    private static func withoutNotes(_ sentence: String) -> String {
        return sentence.replacingOccurrences(of: #"\s*\(=[^)]*\)"#, with: "", options: .regularExpression)
    }

    /// Index pairs of the longest common subsequence, in order. A token without letters ("—")
    /// matches only the same token.
    private static func matchedPairs(_ a: [String], _ b: [String]) -> [(wrong: Int, right: Int)] {
        let na = a.map { MistakeDiff.normalized($0) }
        let nb = b.map { MistakeDiff.normalized($0) }
        func same(_ i: Int, _ j: Int) -> Bool {
            return na[i] == nb[j] && (!na[i].isEmpty || a[i] == b[j])
        }
        var lengths = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in stride(from: a.count - 1, through: 0, by: -1) {
            for j in stride(from: b.count - 1, through: 0, by: -1) {
                lengths[i][j] = same(i, j) ? lengths[i + 1][j + 1] + 1 : max(lengths[i + 1][j], lengths[i][j + 1])
            }
        }
        var pairs: [(wrong: Int, right: Int)] = []
        var i = 0
        var j = 0
        while i < a.count && j < b.count {
            if same(i, j) {
                pairs.append((wrong: i, right: j))
                i += 1
                j += 1
            } else if lengths[i + 1][j] >= lengths[i][j + 1] {
                i += 1
            } else {
                j += 1
            }
        }
        return pairs
    }

    private static func words(_ tokens: [String], in range: ClosedRange<Int>, keeping kept: Set<Int>) -> [Word] {
        return range.map { index -> Word in
            var text = tokens[index]
            if index == tokens.count - 1 {
                while let last = text.last, ".!?;:,…".contains(last) {
                    text.removeLast()
                }
            }
            let isChanged = !kept.contains(index) && !MistakeDiff.normalized(text).isEmpty
            return Word(text: text, isChanged: isChanged)
        }
    }

    /// The words joined by spaces; only the letters of a changed word are marked, not the
    /// punctuation around it.
    private static func attributed(_ words: [Word], marking mark: (inout AttributedString) -> Void) -> AttributedString {
        var result = AttributedString()
        for (index, word) in words.enumerated() {
            if index > 0 {
                result.append(AttributedString(" "))
            }
            let text = word.text
            guard word.isChanged,
                  let first = text.firstIndex(where: { $0.isLetter || $0.isNumber }),
                  let last = text.lastIndex(where: { $0.isLetter || $0.isNumber }) else {
                result.append(AttributedString(text))
                continue
            }
            let end = text.index(after: last)
            result.append(AttributedString(String(text[..<first])))
            var core = AttributedString(String(text[first..<end]))
            mark(&core)
            result.append(core)
            result.append(AttributedString(String(text[end...])))
        }
        return result
    }
}

/// One warning as one line (the card's warning slot, ogrenme_ilkeleri 2.2), with "Neden?" for
/// the false friend and the mistake. The parts wrap like words when the line is full; "Neden?"
/// keeps to the trailing edge. Meaning never rests on color alone (rule 4): "✕", "✓", "≠" and
/// "=" are shapes, and VoiceOver reads them as words. English parts are read with an English
/// voice, Turkish parts with the Turkish one, so the line is a few VoiceOver elements.
struct CardWarningLine: View {
    let warning: CardWarning
    let lemma: String
    /// "Neden?": opens the explanation; nil leaves the button out.
    var explain: (() -> Void)? = nil

    var body: some View {
        CardFlowLayout(itemSpacing: 6, lineSpacing: 4, pinsLastToTrailingEdge: explain != nil) {
            if showsIcon {
                icon
            }
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                CardLinePartView(part: part)
            }
            if let explain = explain {
                CardWhyChip(action: explain)
            }
        }
        .accessibilityElement(children: .contain)
    }

    /// The mistake's "✕" and "✓" already say what the line is.
    private var showsIcon: Bool {
        if case .mistake = warning {
            return false
        }
        return true
    }

    private var icon: some View {
        let isCaution = warning.hasExplanation
        return Image(systemName: isCaution ? "exclamationmark.triangle" : "lightbulb")
            .font(.callout.weight(.semibold))
            .foregroundStyle(isCaution ? Theme.caution : Theme.ink2)
            .accessibilityHidden(true)
    }

    private var parts: [CardLinePart] {
        switch warning {
        case let .falseFriend(friend):
            return [
                .turkish(friend.trWord, spoken: "Sahte dost: \(friend.trWord), eşit değil"),
                .sign("≠"),
                .english(AttributedString(lemma)),
                .sign("·"),
                .turkish(friend.trWord, spoken: "\(friend.trWord), İngilizcede"),
                .sign("="),
                .english(AttributedString(friend.enForThat))
            ]
        case let .mistake(mistake):
            let snippet = MistakeSnippet(mistake)
            return [
                .symbol("xmark", color: Theme.bad, spoken: "Dikkat. Yanlış:"),
                .english(snippet.wrongText()),
                .sign("→"),
                .symbol("checkmark", color: Theme.good, spoken: "Doğru:"),
                .english(snippet.rightText(), bold: true)
            ]
        case let .sameWord(count):
            return [
                .turkish("İngilizcede \(CardWarningLine.allOf(count)):"),
                .english(AttributedString(lemma), bold: true)
            ]
        case let .phrasalVerb(verb, count):
            return [
                .turkish("Türkçede tek fiil: \(verb)"),
                .sign("→"),
                .turkish("İngilizcede \(CardWarningLine.number(count)) parça:"),
                .english(AttributedString(lemma), bold: true)
            ]
        }
    }

    /// "ikisi de", "üçü de", "hepsi".
    private static func allOf(_ count: Int) -> String {
        switch count {
        case 2:
            return "ikisi de"
        case 3:
            return "üçü de"
        default:
            return "hepsi"
        }
    }

    private static func number(_ count: Int) -> String {
        switch count {
        case 2:
            return "iki"
        case 3:
            return "üç"
        case 4:
            return "dört"
        default:
            return "\(count)"
        }
    }
}

/// "Neden?" at the end of a warning line or of the Dikkat heading: a chip (`ChipButtonStyle`)
/// that opens the explanation sheet. Its label is set in Callout, the size of the Turkish line it
/// ends, so the card keeps one secondary size.
struct CardWhyChip: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Neden?")
                .font(.callout.weight(.semibold))
        }
        .buttonStyle(ChipButtonStyle())
        .accessibilityHint("Açıklamayı açar")
    }
}

/// A piece of a warning line or of the "Neden?" sheet's false friend lines.
enum CardLinePart {
    /// Turkish text; `spoken` replaces it for VoiceOver.
    case turkish(String, spoken: String? = nil)
    /// English text (serif, English voice).
    case english(AttributedString, bold: Bool = false)
    /// "≠", "=", "→", "·": shapes between the words. VoiceOver skips them: the Turkish part
    /// before says them in words.
    case sign(String)
    /// "✕", "✓" as symbols, read as `spoken`.
    case symbol(String, color: Color, spoken: String)
}

/// One `CardLinePart`: Callout Turkish, Body serif English (`exampleFont`), all in `ink` (the
/// signs `ink2`).
struct CardLinePartView: View {
    let part: CardLinePart

    var body: some View {
        switch part {
        case let .turkish(text, spoken):
            Text(verbatim: text)
                .font(.callout.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .accessibilityLabel(Text(verbatim: spoken ?? text))
        case let .english(text, bold):
            Text(text)
                .exampleFont(bold: bold)
                .foregroundStyle(Theme.ink)
                .cardEnglishVoice()
        case let .sign(text):
            Text(verbatim: text)
                .font(.callout.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
        case let .symbol(name, color, spoken):
            Image(systemName: name)
                .font(.footnote.weight(.black))
                .foregroundStyle(color)
                .accessibilityLabel(Text(verbatim: spoken))
                .accessibilityRemoveTraits(.isImage)
        }
    }
}

/// "Neden?" (ogrenme_ilkeleri 2.2): what is behind a card's one-line warning, on a sheet that
/// opens at half height. First the false friend in three lines, or the Dikkat box with its
/// reason; then the card's other mistakes, its collocations and its other examples. Nothing here
/// opens another sheet.
struct CardWhySheet: View {
    let word: WidgetWord
    let detail: CardDetail?
    let warning: CardWarning
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    lead
                    ForEach(Array(otherMistakes.enumerated()), id: \.offset) { _, mistake in
                        MistakeBox(mistake: mistake)
                    }
                    if let collocations = detail?.collocations, !collocations.isEmpty {
                        section("Birlikte kullanılır") {
                            // The examples' serif size: one size for the sheet's English text.
                            Text(verbatim: collocations.joined(separator: " · "))
                                .exampleFont()
                                .foregroundStyle(Theme.ink)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                                .cardEnglishVoice()
                        }
                    }
                    if !otherExamples.isEmpty {
                        section("Başka örnekler") {
                            VStack(alignment: .leading, spacing: 14) {
                                ForEach(Array(otherExamples.enumerated()), id: \.offset) { _, example in
                                    ExampleRow(example: example, lemma: word.lemma)
                                }
                            }
                        }
                    }
                }
                // The HIG side margin.
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background {
                Theme.surface
                    .ignoresSafeArea()
            }
            .navigationTitle("Neden?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
        // Rule 2: no blue link color on "Kapat".
        .tint(Theme.ink)
        .presentationDetents([.medium, .large])
        .presentationBackground(Theme.surface)
    }

    /// The warning's own explanation; a false friend card also gets its Dikkat box here, since
    /// the false friend took the card's one slot.
    @ViewBuilder
    private var lead: some View {
        switch warning {
        case let .falseFriend(friend):
            section("Sahte dost") {
                VStack(alignment: .leading, spacing: 10) {
                    falseFriendLine([
                        .turkish(friend.trWord, spoken: "\(friend.trWord), eşit değil"),
                        .sign("≠"),
                        .english(AttributedString(word.lemma))
                    ])
                    falseFriendLine([
                        .turkish("\(friend.trWord) = \(friend.trMeans)", spoken: "\(friend.trWord): \(friend.trMeans). İngilizcede"),
                        .sign("→"),
                        .english(AttributedString(friend.enForThat), bold: true)
                    ])
                    if let gloss = word.glossTR {
                        falseFriendLine([
                            .english(AttributedString(word.lemma), bold: true),
                            .sign("="),
                            .turkish(gloss, spoken: "Türkçede: \(gloss)")
                        ])
                    }
                }
            }
            if let mistake = leadMistake {
                MistakeBox(mistake: mistake)
            }
        case .mistake:
            if let mistake = leadMistake {
                MistakeBox(mistake: mistake)
            }
        case .sameWord, .phrasalVerb:
            EmptyView()
        }
    }

    private func falseFriendLine(_ parts: [CardLinePart]) -> some View {
        CardFlowLayout(itemSpacing: 6, lineSpacing: 4) {
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                CardLinePartView(part: part)
            }
        }
        .accessibilityElement(children: .contain)
    }

    /// A section with a bold Callout heading: the size of the sheet's Turkish lines, so the sheet
    /// keeps three text sizes (with the serif English and the navigation title).
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.callout.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }

    private var leadMistake: CardDetail.Mistake? {
        if case let .mistake(mistake) = warning {
            return mistake
        }
        return detail?.cardMistake(lemma: word.lemma)
    }

    private var otherMistakes: [CardDetail.Mistake] {
        let lead = leadMistake
        return (detail?.mistakes ?? []).filter { $0 != lead }
    }

    /// Every example but the one on the card (`exampleEN`, else the detail's first, as
    /// `WordCardView` picks it).
    private var otherExamples: [CardDetail.Example] {
        let examples = detail?.examples ?? []
        let shown = examples.first { $0.en == word.exampleEN }?.en ?? examples.first?.en
        return examples.filter { $0.en != shown }
    }
}

// MARK: - Layout

/// Subviews flow from the leading edge and wrap to a new line when the line is full (mockup
/// `.wmeta`, `flex-wrap: wrap`); with `pinsLastToTrailingEdge` the last subview (a button) keeps
/// to the trailing edge of its line. Each subview is centered on its line's height; one wider
/// than the whole line wraps inside it.
struct CardFlowLayout: Layout {
    /// Between two subviews on a line.
    var itemSpacing: CGFloat
    /// Between two lines.
    var lineSpacing: CGFloat
    var pinsLastToTrailingEdge = false

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
        // A row with a pinned button spans the card (the button sits on its trailing edge).
        if pinsLastToTrailingEdge, let width = proposal.width, width.isFinite {
            return CGSize(width: max(width, 0), height: height)
        }
        return CGSize(width: usedWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let lines = arrange(subviews, maxWidth: bounds.width)
        let trailingIndex = pinsLastToTrailingEdge && subviews.count > 1 ? subviews.count - 1 : -1
        var y = bounds.minY
        for line in lines {
            var x = bounds.minX
            for item in line.items {
                let itemX = item.index == trailingIndex ? max(x, bounds.maxX - item.size.width) : x
                subviews[item.index].place(
                    at: CGPoint(x: itemX, y: y + (line.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                x = itemX + item.size.width + itemSpacing
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
                // A long part (a pronunciation, a sentence) wraps inside the line instead of
                // running off it.
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

/// "Dinle" (mockup `.pill-btn`): a `surface2` capsule with a speaker and a label that reads `text`
/// aloud; a second tap stops it. Replaces the bare speaker icon next to the word (README "Akış").
/// While it reads, the speaker is filled and the label says "Durdur"; nothing moves next to the
/// text being read (ogrenme_ilkeleri 2.2).
struct CardListenCapsule: View {
    @ObservedObject private var speaker = Speaker.shared
    let text: String
    var accessibilityName = "Kelimeyi dinle"

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                Text(isSpeaking ? "Durdur" : "Dinle")
            }
        }
        .buttonStyle(CardCapsuleButtonStyle())
        .accessibilityLabel(isSpeaking ? "Durdur" : accessibilityName)
        // Voice Control: "Dinle'ye dokun" works as well as the spoken name.
        .accessibilityInputLabels([Text(isSpeaking ? "Durdur" : "Dinle"), Text(isSpeaking ? "Durdur" : accessibilityName)])
    }
}

/// The capsule of `CardListenCapsule` and the card's "Biliyorum": 44 pt high, subheadline, the
/// press feedback of the theme's capsule buttons. A `surface2` fill with a 1 pt `lineStrong` edge
/// (1.5 pt with Increase Contrast or Button Shapes; audit K1: the fill alone is 1.1-1.2:1 against
/// the card). `isSelected` (a known word's "Biliyorum"): `surface` with a 1.5 pt `tint` border, like
/// a selected chip.
struct CardCapsuleButtonStyle: ButtonStyle {
    var isSelected = false

    func makeBody(configuration: Configuration) -> some View {
        CardCapsuleButtonBody(configuration: configuration, isSelected: isSelected)
    }
}

private struct CardCapsuleButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let isSelected: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityShowButtonShapes) private var showsButtonShapes

    var body: some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .foregroundStyle(Theme.ink)
            .padding(.leading, 11)
            .padding(.trailing, 14)
            .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
            .background(isSelected ? Theme.surface : Theme.surface2, in: Capsule())
            .overlay {
                if isSelected {
                    Capsule().strokeBorder(Theme.tint, lineWidth: 1.5)
                } else {
                    Capsule().strokeBorder(Theme.lineStrong, lineWidth: contrast == .increased || showsButtonShapes ? 1.5 : 1)
                }
            }
            .contentShape(Capsule())
            .fixedSize()
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// A round speaker for a sentence (mockup `.spk`): a 34 pt `surface2` circle with a `lineStrong`
/// edge (audit K1, as `CardCapsuleButtonStyle`) in a 44 pt target. Reads `text` aloud; a second
/// tap stops it. While it reads, the speaker is filled (no motion).
struct CardSentenceSpeaker: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityShowButtonShapes) private var showsButtonShapes
    @ScaledMetric(relativeTo: .subheadline) private var circleSize: CGFloat = 34
    let text: String
    var accessibilityName = "Cümleyi dinle"

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .frame(width: circleSize, height: circleSize)
                .background(Theme.surface2, in: Circle())
                .overlay {
                    Circle().strokeBorder(Theme.lineStrong, lineWidth: contrast == .increased || showsButtonShapes ? 1.5 : 1)
                }
                .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSpeaking ? "Durdur" : accessibilityName)
    }
}

/// Turkish names of the part-of-speech codes in `WidgetWord.pos` (mockup `POS`, plus the codes
/// the content also uses); an unknown code is shown as it is.
enum CardPartOfSpeech {
    static func turkish(_ code: String) -> String {
        switch code {
        case "n":
            return "isim"
        case "v":
            return "fiil"
        case "adj":
            return "sıfat"
        case "adv":
            return "zarf"
        case "phv":
            return "kalıp fiil"
        case "phr":
            return "kalıp"
        case "idm":
            return "deyim"
        case "det":
            return "belirleyici"
        case "prep":
            return "edat"
        default:
            return code
        }
    }
}

extension View {
    /// English card text (README point 14): the theme's `englishVoice()` under its older name, so
    /// there is one implementation (audit V6). Apply it to English text only: a Turkish
    /// translation must keep the Turkish voice.
    func cardEnglishVoice() -> some View {
        englishVoice()
    }
}
