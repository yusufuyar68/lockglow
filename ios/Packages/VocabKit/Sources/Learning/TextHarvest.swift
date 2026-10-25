import Foundation
import CoreModels

// "Metinden kelime bul" (docs/ozellik_planlari/metinden_kelime.md): the user brings an English
// text they are reading (typed, pasted, from the camera or a photo, or sent by a shortcut) and
// the app lists its words in three groups: on the cards, already among the user's own words, and
// new. Pure, so the Linux check tests it; the app gives the lookups (`AppModel.harvestWords(in:)`).
// Nothing is stored: the text lives only on the screen.

/// Reads an English text and sorts its words (`harvest`).
public enum TextHarvest {
    /// Characters read; the rest of a longer text is left out (`Result.wasCut`). About ten pages.
    public static let inputLimit = 20_000
    /// Different words read; reading stops at the next new one (`Result.wasCut`).
    public static let wordLimit = 300
    /// Words of the longest card phrase looked for ("Could you tell me the way to" has 7).
    static let phraseLimit = 7
    /// Letters of the longest token taken as a word (a pasted code or a joined-up line is not).
    static let tokenLengthLimit = 40

    // MARK: Result

    /// A card or one of the user's words that the text contains.
    public struct Match: Equatable, Sendable {
        public let word: WidgetWord
        public let state: LearningState
        /// How the text wrote it when that differs from the word ("went" for "go", "looking
        /// forward to" for "look forward to"); nil when the same.
        public let textForm: String?

        public init(word: WidgetWord, state: LearningState, textForm: String?) {
            self.word = word
            self.state = state
            self.textForm = textForm
        }
    }

    public struct Result: Equatable, Sendable {
        /// Words on the cards, in the text's order (a phrase where it starts).
        public let cards: [Match]
        /// The user's own words ("Kendi kelimelerin") in the text.
        public let ownWords: [Match]
        /// Words on neither, as the text wrote them (an inflected form folded into its base when
        /// both are here: "cats" and "cat" give "cat"). No function words ("the", "would") and no
        /// likely names.
        public let newWords: [String]
        /// The text was longer than `inputLimit` or had more than `wordLimit` different words.
        public let wasCut: Bool
        /// Not one English word was read: empty, only numbers and links, or another language.
        public let readNoWords: Bool

        /// Nothing to list (the words were all function words or names, or there were none).
        public var isEmpty: Bool {
            return cards.isEmpty && ownWords.isEmpty && newWords.isEmpty
        }
    }

    /// The text's words sorted into the three groups.
    /// - Parameters:
    ///   - card: The card whose headword is this lowercased key ("go", "look forward to"); nil
    ///     when none (`AppModel` looks it up in its lemma index).
    ///   - ownWord: The same for the user's own words, as their `widgetWord`. Asked first: a word
    ///     the user added is theirs even when a card has it too.
    ///   - state: The word's learning state, shown next to it.
    public static func harvest(
        _ text: String,
        card: (String) -> WidgetWord?,
        ownWord: (String) -> WidgetWord?,
        state: (WidgetWord) -> LearningState
    ) -> Result {
        let reading = read(text)

        // Every hit with the place it starts in the text; sorted and made unique below. The words of
        // a phrase found are covered by it: "woke" in "woke up" is neither "wake" nor a new word.
        var phrases: [Hit] = []
        for run in reading.runs {
            for start in run.indices {
                if let hit = phraseHit(in: run, at: start, card: card, ownWord: ownWord) {
                    phrases.append(hit)
                }
            }
        }
        var hits = withoutOverlaps(phrases)
        var covered = Set<Int>()
        for hit in hits {
            covered.formUnion(hit.position..<(hit.position + hit.length))
        }
        // Where each word first stands outside every phrase found; a word only ever inside one
        // is left out.
        var firstFreePosition: [String: Int] = [:]
        for run in reading.runs {
            for token in run where !covered.contains(token.position) {
                if let form = token.form, firstFreePosition[form] == nil {
                    firstFreePosition[form] = token.position
                }
            }
        }
        var unmatched: [Word] = []
        for word in reading.words {
            guard let position = firstFreePosition[word.form] else {
                continue
            }
            // An "-er"/"-est" guess only for an adjective or an adverb card: "cheaper" is "cheap",
            // but "teacher" and "driver" are not "teach" and "drive".
            let plain = Set(forms(of: word.form, comparatives: false))
            var hit: Found?
            for form in forms(of: word.form) {
                guard let found = lookup(form, card: card, ownWord: ownWord) else {
                    continue
                }
                if !plain.contains(form) && !comparablePOS.contains(found.word.pos) {
                    continue
                }
                hit = found
                break
            }
            if let found = hit {
                let lemma = found.word.lemma.lowercased()
                hits.append(Hit(
                    position: position,
                    length: 1,
                    isPhrase: false,
                    isInflected: false,
                    word: found.word,
                    isOwn: found.isOwn,
                    textForm: word.form == lemma ? nil : word.form
                ))
            } else {
                unmatched.append(word)
            }
        }

        // The text's order; a phrase before the single word at the same place ("look forward to"
        // before "look"). A word met again in another form keeps its first place.
        hits.sort { lhs, rhs in
            lhs.position != rhs.position ? lhs.position < rhs.position : (lhs.isPhrase && !rhs.isPhrase)
        }
        var seenIDs = Set<Int>()
        var cards: [Match] = []
        var ownWords: [Match] = []
        for hit in hits where seenIDs.insert(hit.word.id).inserted {
            let match = Match(word: hit.word, state: state(hit.word), textForm: hit.textForm)
            if hit.isOwn {
                ownWords.append(match)
            } else {
                cards.append(match)
            }
        }

        return Result(
            cards: cards,
            ownWords: ownWords,
            newWords: newWords(from: unmatched),
            wasCut: reading.wasCut,
            readNoWords: reading.words.isEmpty
        )
    }

    /// A word for a key: the user's own word first, then the card.
    private struct Found {
        let word: WidgetWord
        let isOwn: Bool
    }

    private static func lookup(
        _ key: String,
        card: (String) -> WidgetWord?,
        ownWord: (String) -> WidgetWord?
    ) -> Found? {
        if let own = ownWord(key) {
            return Found(word: own, isOwn: true)
        }
        if let found = card(key) {
            return Found(word: found, isOwn: false)
        }
        return nil
    }

    private struct Hit {
        let position: Int
        /// Tokens of the text it covers.
        let length: Int
        let isPhrase: Bool
        /// A phrase found only with its first word in another form ("went on" → "go on") or
        /// after a contracted "be": a weaker match than one written as the card writes it.
        let isInflected: Bool
        let word: WidgetWord
        let isOwn: Bool
        let textForm: String?
    }

    /// Card words of an "-er"/"-est" form (`lemmaCandidates(of:comparatives:)`).
    private static let comparablePOS: Set<String> = ["adj", "adv"]

    /// The phrases found (in the text's order) with no word used twice. Of two that overlap, the
    /// one written as the card writes it stays ("We went on foot": "on foot", not "go on"); when
    /// both or neither are, the earlier one. A phrase inside a longer one found first is dropped.
    private static func withoutOverlaps(_ phrases: [Hit]) -> [Hit] {
        var kept: [Hit] = []
        for hit in phrases {
            guard let last = kept.last, hit.position < last.position + last.length else {
                kept.append(hit)
                continue
            }
            let extendsPast = hit.position + hit.length > last.position + last.length
            if extendsPast && last.isInflected && !hit.isInflected {
                kept[kept.count - 1] = hit
            }
        }
        return kept
    }

    /// The longest card phrase that starts at `start`: two to `phraseLimit` words in a row, the
    /// first in any form ("woke up" → "wake up", "was running late" → "be running late"), "my",
    /// "his"… standing for the card's "your" ("changed my mind" → "change your mind"). A phrase
    /// that starts with "be" is also found after "I'm", "you're", "she's" ("I'm fed up with").
    private static func phraseHit(
        in run: [Token],
        at start: Int,
        card: (String) -> WidgetWord?,
        ownWord: (String) -> WidgetWord?
    ) -> Hit? {
        let afterContractedBe = start > 0 && ["'m", "'re", "'s"].contains { run[start - 1].raw.hasSuffix($0) }
        let longest = min(phraseLimit, run.count - start)
        guard longest >= 1 else {
            return nil
        }
        for length in stride(from: longest, through: 1, by: -1) {
            let raws = run[start..<(start + length)].map(\.raw)
            // Each key with whether the text's first word had to change for it.
            var keys: [(key: String, isInflected: Bool)] = []
            if length >= 2 {
                let rests = possessiveVariants(Array(raws.dropFirst()))
                for first in forms(of: raws[0]) {
                    for rest in rests {
                        keys.append((key: ([first] + rest).joined(separator: " "), isInflected: first != raws[0]))
                    }
                }
            }
            if afterContractedBe {
                for words in possessiveVariants(raws) {
                    keys.append((key: (["be"] + words).joined(separator: " "), isInflected: true))
                }
            }
            for (key, isInflected) in keys {
                if let found = lookup(key, card: card, ownWord: ownWord) {
                    let written = raws.joined(separator: " ")
                    return Hit(
                        position: run[start].position,
                        length: length,
                        isPhrase: true,
                        isInflected: isInflected,
                        word: found.word,
                        isOwn: found.isOwn,
                        textForm: written == found.word.lemma.lowercased() ? nil : written
                    )
                }
            }
        }
        return nil
    }

    /// `words` as written, and with "my", "his", "her"… as "your" and "myself"… as "yourself"
    /// when that differs (the cards write "change your mind", "make yourself at home").
    private static func possessiveVariants(_ words: [String]) -> [[String]] {
        let general = words.map { word -> String in
            if possessives.contains(word) {
                return "your"
            }
            if reflexives.contains(word) {
                return "yourself"
            }
            return word
        }
        return general == words ? [words] : [words, general]
    }

    private static let possessives: Set<String> = ["my", "his", "her", "our", "their", "its"]
    private static let reflexives: Set<String> = ["myself", "himself", "herself", "ourselves", "themselves", "yourselves", "itself"]

    /// The unmatched words a learner may want to add: not a function word, not a likely name,
    /// speakable and short enough for "Kendi kelimeni ekle". A form whose base is here too joins
    /// the base, at the earlier of their places.
    private static func newWords(from unmatched: [Word]) -> [String] {
        let candidates = unmatched.filter { word in
            !word.looksLikeName
                && word.form.count <= CustomWordDraft.lemmaLimit
                && CustomWordText.isSpeakable(word.form)
                && !stopwords.contains(word.form)
        }
        let present = Set(candidates.map(\.form))
        var order: [String] = []
        var seen = Set<String>()
        for word in candidates {
            // No "-er" guess: with no card to say it is an adjective, "teacher" stays apart from
            // "teach".
            let base = lemmaCandidates(of: word.form, comparatives: false).first(where: present.contains) ?? word.form
            if seen.insert(base).inserted {
                order.append(base)
            }
        }
        return order
    }

    // MARK: Text from a picture

    /// Lines read from the camera or a photo as one text: a word cut with a hyphen at a line end
    /// ("impor-", "tant") is joined again, other lines follow with a space (a paragraph wraps;
    /// its sentences still end at their full stops). Empty lines are left out.
    public static func joiningLines(_ lines: [String]) -> String {
        var result = ""
        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else {
                continue
            }
            if result.hasSuffix("-"), result.count >= 2, let first = line.first, first.isLowercase,
               result[result.index(before: result.index(before: result.endIndex))].isLetter {
                result.removeLast()
                result += line
            } else {
                result += result.isEmpty ? line : " " + line
            }
        }
        return result
    }

    // MARK: Reading

    /// One different word of the text: lowercased, with a possessive or a short verb ending
    /// ("mother's" → "mother", "we've" → "we") taken off.
    struct Word: Equatable {
        let form: String
        /// Where it first stands (counted in tokens).
        let position: Int
        /// Only ever written with a capital letter in the middle of a sentence ("Tom", "London"),
        /// never in lower case or at a sentence start. A title line ("Scientists Find New Planet")
        /// counts for neither.
        let looksLikeName: Bool
    }

    /// One word as it stands in the text, for phrases: lowercased, apostrophes kept ("can't").
    struct Token: Equatable {
        let raw: String
        /// `wordForm(raw)`: nil for "can't" and anything that is not a word to list.
        let form: String?
        let position: Int
    }

    struct Reading: Equatable {
        /// The different words, in the order they first appear.
        let words: [Word]
        /// Words in a row with nothing but spaces between them; punctuation, a number or a link
        /// ends a run, so a phrase never spans a full stop or a comma.
        let runs: [[Token]]
        let wasCut: Bool
    }

    /// The text cut into words (`Reading`). Letters with an apostrophe or hyphen between two of
    /// them make one word ("o'clock", "well-known"); curly apostrophes count as straight ones.
    /// Numbers, words glued to a number ("3rd", "mp3"), links and e-mail addresses are left out,
    /// and so is any word with a letter outside a-z (Turkish text, another alphabet).
    static func read(_ text: String) -> Reading {
        var wasCut = text.count > inputLimit
        let limited = normalizedPunctuation(String(text.prefix(inputLimit)))

        var words: [Word] = []
        var indexOfForm: [String: Int] = [:]
        // Name evidence per form: capitalised mid-sentence, and anything else.
        var capitalisedMidSentence = Set<String>()
        var seenOtherwise = Set<String>()
        var runs: [[Token]] = []
        var run: [Token] = []
        var position = 0

        func endRun() {
            if run.count > 0 {
                runs.append(run)
            }
            run = []
        }

        reading: for line in limited.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }) {
            let items = lineItems(String(line))
            let isTitle = isTitleLine(items)
            for item in items {
                guard case let .token(raw, isCapitalised, atSentenceStart) = item else {
                    endRun()
                    continue
                }
                let lowered = raw.lowercased()
                let form = wordForm(lowered)
                // "NEW PARK" in capitals is emphasis or a heading, not a name: no evidence either way.
                let isAllCaps = raw.count > 1 && !raw.contains(where: \.isLowercase)
                if let form = form {
                    if indexOfForm[form] == nil {
                        guard words.count < wordLimit else {
                            wasCut = true
                            break reading
                        }
                        indexOfForm[form] = words.count
                        words.append(Word(form: form, position: position, looksLikeName: false))
                    }
                    if !isTitle && !isAllCaps {
                        if !atSentenceStart && isCapitalised {
                            capitalisedMidSentence.insert(form)
                        } else {
                            seenOtherwise.insert(form)
                        }
                    }
                }
                run.append(Token(raw: lowered, form: form, position: position))
                position += 1
            }
            endRun()
        }
        endRun()

        let named = words.map { word in
            Word(
                form: word.form,
                position: word.position,
                looksLikeName: capitalisedMidSentence.contains(word.form) && !seenOtherwise.contains(word.form)
            )
        }
        return Reading(words: named, runs: runs, wasCut: wasCut)
    }

    /// A line's tokens and the run breaks between them.
    private enum LineItem: Equatable {
        case token(String, isCapitalised: Bool, atSentenceStart: Bool)
        case runBreak
    }

    /// Splits a line at whitespace into chunks, and each chunk into letter tokens. Anything that
    /// is not a letter between them breaks the run; ". ! ?" also start a new sentence.
    private static func lineItems(_ line: String) -> [LineItem] {
        var items: [LineItem] = []
        var atSentenceStart = true
        for chunk in line.split(whereSeparator: { $0.isWhitespace }) {
            let characters = Array(chunk)
            if isAddress(characters) {
                items.append(.runBreak)
                continue
            }
            var index = 0
            while index < characters.count {
                let character = characters[index]
                guard character.isLetter else {
                    items.append(.runBreak)
                    if ".!?\u{2026}".contains(character) {
                        atSentenceStart = true
                    }
                    index += 1
                    continue
                }
                var end = index
                var token = ""
                while end < characters.count {
                    let next = characters[end]
                    if next.isLetter {
                        token.append(next)
                    } else if (next == "'" || next == "-") && end + 1 < characters.count && characters[end + 1].isLetter {
                        token.append(next)
                    } else {
                        break
                    }
                    end += 1
                }
                let touchesNumber = (index > 0 && characters[index - 1].isNumber)
                    || (end < characters.count && characters[end].isNumber)
                if touchesNumber || token.count > tokenLengthLimit {
                    items.append(.runBreak)
                } else {
                    let isCapitalised = token.first?.isUppercase ?? false
                    items.append(.token(token, isCapitalised: isCapitalised, atSentenceStart: atSentenceStart))
                }
                atSentenceStart = false
                index = end
            }
        }
        return items
    }

    /// A headline or a title: at least two words after the first, and every one of them that is
    /// not a small function word ("of", "the") capitalised. Its capitals say nothing about names.
    private static func isTitleLine(_ items: [LineItem]) -> Bool {
        var checked = 0
        for item in items {
            guard case let .token(raw, isCapitalised, atSentenceStart) = item, !atSentenceStart else {
                continue
            }
            if titleSmallWords.contains(raw.lowercased()) {
                continue
            }
            guard isCapitalised else {
                return false
            }
            checked += 1
        }
        return checked >= 2
    }

    private static let titleSmallWords: Set<String> = ["a", "an", "the", "and", "or", "but", "of", "in", "on", "at", "to", "for", "by", "with", "from", "as"]

    /// A link or an e-mail address ("https://…", "www.…", "a@b.com", "lockglow.app"): a chunk
    /// with "://", "@", a leading "www." or a dot between two letters or digits.
    private static func isAddress(_ characters: [Character]) -> Bool {
        let chunk = String(characters).lowercased()
        if chunk.contains("://") || chunk.contains("@") || chunk.hasPrefix("www.") {
            return true
        }
        guard characters.count >= 3 else {
            return false
        }
        for index in 1..<(characters.count - 1) where characters[index] == "." {
            let before = characters[index - 1]
            let after = characters[index + 1]
            if (before.isLetter || before.isNumber) && (after.isLetter || after.isNumber) {
                return true
            }
        }
        return false
    }

    /// Smart punctuation as typed: curly apostrophes as ', the hyphen look-alikes as -. En and
    /// em dashes stay: they stand between words, not inside one.
    private static func normalizedPunctuation(_ text: String) -> String {
        var result = ""
        result.reserveCapacity(text.utf8.count)
        for character in text {
            switch character {
            case "\u{2019}", "\u{2018}", "\u{02BC}", "\u{00B4}", "`":
                result.append("'")
            case "\u{2010}", "\u{2011}":
                result.append("-")
            default:
                result.append(character)
            }
        }
        return result
    }

    /// A lowercased token as a word: "n't" forms ("don't", "can't") are not words of their own;
    /// "'s", "'m", "'re", "'ve", "'ll" and "'d" come off ("teacher's" → "teacher", "it's" →
    /// "it"). Nil for one letter, for a letter outside a-z, and for anything too long.
    static func wordForm(_ token: String) -> String? {
        if token.hasSuffix("n't") {
            return nil
        }
        var form = token
        for ending in ["'s", "'m", "'re", "'ve", "'ll", "'d"] where form.hasSuffix(ending) {
            form = String(form.dropLast(ending.count))
            break
        }
        guard form.count >= 2, form.count <= tokenLengthLimit else {
            return nil
        }
        let isPlain = form.unicodeScalars.allSatisfy { scalar in
            (scalar.isASCII && scalar.properties.isAlphabetic) || scalar == "'" || scalar == "-"
        }
        return isPlain ? form : nil
    }

    // MARK: Word forms

    /// The forms looked up for a word, in order: the word as written, then `lemmaCandidates`.
    static func forms(of form: String, comparatives: Bool = true) -> [String] {
        return [form] + lemmaCandidates(of: form, comparatives: comparatives)
    }

    /// Guesses at the dictionary form of an inflected English word, the likeliest first, never
    /// the word itself: irregular forms ("went" → "go", "children" → "child"), plurals and "-s"
    /// ("boxes" → "box", "studies" → "study"), "-ing" and "-ed" ("running" → "run", "making" →
    /// "make", "stopped" → "stop", "tried" → "try", "liked" → "like"), "-er" and "-est" ("bigger"
    /// → "big", "happiest" → "happy"). Wrong guesses are harmless: a guess only counts when a
    /// card or a word of the text has it. Without `comparatives` the "-er" and "-est" guesses
    /// are left out (irregular ones such as "better" stay).
    public static func lemmaCandidates(of form: String, comparatives: Bool = true) -> [String] {
        let word = form.lowercased()
        var result: [String] = []
        func add(_ candidate: String) {
            if candidate.count >= 2 && candidate != word && !result.contains(candidate) {
                result.append(candidate)
            }
        }
        func drop(_ count: Int) -> String {
            return String(word.dropLast(count))
        }
        /// The base of a stem left by "-ing", "-ed", "-er" or "-est": a doubled last letter
        /// undone ("runn" → "run"), a lost "e" put back ("mak" → "make").
        func addStem(_ stem: String) {
            guard stem.count >= 2 else {
                return
            }
            let letters = Array(stem)
            let last = letters[letters.count - 1]
            if letters.count >= 3 && last == letters[letters.count - 2] && !isVowel(last) {
                let undoubled = String(stem.dropLast())
                // "calling", "missing": the base ends in the double letter itself.
                if "lsfz".contains(last) {
                    add(stem)
                    add(undoubled)
                } else {
                    add(undoubled)
                    add(stem)
                }
            } else if isShortConsonantVowelConsonant(letters) {
                add(stem + "e")
                add(stem)
            } else {
                add(stem)
                add(stem + "e")
            }
        }

        if let irregular = irregularForms[word] {
            irregular.forEach(add)
        }
        let count = word.count
        guard !keepsItsEnding.contains(word) else {
            return result
        }
        // Plurals and "he/she/it" forms.
        if word.hasSuffix("ies") && count > 4 {
            add(drop(3) + "y")
        }
        if word.hasSuffix("es") && count > 3 {
            let stem = drop(2)
            if ["s", "x", "z", "ch", "sh", "o"].contains(where: { stem.hasSuffix($0) }) {
                add(stem)
                add(drop(1))
            } else {
                add(drop(1))
                add(stem)
            }
        } else if word.hasSuffix("s") && count > 3 && !word.hasSuffix("ss") && !word.hasSuffix("us") && !word.hasSuffix("is") {
            add(drop(1))
        }
        if word.hasSuffix("ves") && count > 4 {
            add(drop(3) + "f")
            add(drop(3) + "fe")
        }
        // "-ing".
        if word.hasSuffix("ying") && count <= 5 {
            add(drop(4) + "ie")
        }
        if word.hasSuffix("ing") && count > 4 {
            addStem(drop(3))
        }
        // "-ed".
        if word.hasSuffix("ied") && count > 4 {
            add(drop(3) + "y")
        }
        if word.hasSuffix("ed") && count > 3 {
            addStem(drop(2))
            add(drop(1))
        }
        // Comparatives and superlatives.
        guard comparatives else {
            return result
        }
        if word.hasSuffix("iest") && count > 5 {
            add(drop(4) + "y")
        }
        if word.hasSuffix("ier") && count > 4 {
            add(drop(3) + "y")
        }
        if word.hasSuffix("est") && count > 4 {
            addStem(drop(3))
        }
        if word.hasSuffix("er") && count > 3 {
            addStem(drop(2))
            add(drop(1))
        }
        return result
    }

    private static func isVowel(_ character: Character) -> Bool {
        return "aeiou".contains(character)
    }

    /// One syllable ending consonant-vowel-consonant ("mak", "hop", "rid"), not in w, x or y: such
    /// a base doubles its last letter before "-ing" ("hopping" → "hop"), so a single letter means
    /// the base lost an "e" ("hoping" → "hope").
    private static func isShortConsonantVowelConsonant(_ letters: [Character]) -> Bool {
        guard letters.count >= 3 else {
            return false
        }
        let last = letters[letters.count - 1]
        let middle = letters[letters.count - 2]
        let before = letters[letters.count - 3]
        guard !isVowel(last), !"wxy".contains(last), isVowel(middle), !isVowel(before) else {
            return false
        }
        var groups = 0
        var inVowel = false
        for letter in letters {
            let vowel = isVowel(letter)
            if vowel && !inVowel {
                groups += 1
            }
            inVowel = vowel
        }
        return groups == 1
    }

    /// Words whose ending is not an inflection ("news" is not "new" + s).
    private static let keepsItsEnding: Set<String> = [
        "news", "series", "species", "means", "always", "perhaps", "towards", "afterwards",
        "physics", "maths", "politics", "clothes", "glasses", "trousers", "jeans", "thing",
        "nothing", "something", "anything", "everything", "morning", "evening", "ceiling",
        "during", "bed", "red", "need", "speed", "seed", "feed", "weed", "hundred", "sacred",
        "never", "ever", "over", "under", "after", "water", "paper", "number", "together",
        "remember", "however", "whether", "either", "neither", "other", "another", "rather",
    ]

    /// The most common irregular verbs, nouns and comparatives (the forms a learner meets first),
    /// each with its dictionary forms.
    static let irregularForms: [String: [String]] = [
        // be, have, do, go
        "am": ["be"], "is": ["be"], "are": ["be"], "was": ["be"], "were": ["be"], "been": ["be"], "being": ["be"],
        "has": ["have"], "had": ["have"], "having": ["have"],
        "does": ["do"], "did": ["do"], "done": ["do"], "doing": ["do"],
        "goes": ["go"], "went": ["go"], "gone": ["go"],
        // Verbs
        "ate": ["eat"], "eaten": ["eat"], "began": ["begin"], "begun": ["begin"],
        "bent": ["bend"], "bit": ["bite"], "bitten": ["bite"], "blew": ["blow"], "blown": ["blow"],
        "broke": ["break"], "broken": ["break"], "brought": ["bring"], "built": ["build"],
        "burnt": ["burn"], "bought": ["buy"], "caught": ["catch"], "chose": ["choose"], "chosen": ["choose"],
        "came": ["come"], "cost": ["cost"], "cut": ["cut"], "dealt": ["deal"], "drew": ["draw"], "drawn": ["draw"],
        "dreamt": ["dream"], "drank": ["drink"], "drunk": ["drink"], "drove": ["drive"], "driven": ["drive"],
        "fell": ["fall"], "fallen": ["fall"], "fed": ["feed"], "felt": ["feel"], "fought": ["fight"],
        "found": ["find"], "flew": ["fly"], "flown": ["fly"], "forgot": ["forget"], "forgotten": ["forget"],
        "forgave": ["forgive"], "forgiven": ["forgive"], "froze": ["freeze"], "frozen": ["freeze"],
        "got": ["get"], "gotten": ["get"], "gave": ["give"], "given": ["give"], "grew": ["grow"], "grown": ["grow"],
        "hung": ["hang"], "heard": ["hear"], "hid": ["hide"], "hidden": ["hide"], "hit": ["hit"],
        "held": ["hold"], "hurt": ["hurt"], "kept": ["keep"], "knew": ["know"], "known": ["know"],
        "laid": ["lay"], "led": ["lead"], "learnt": ["learn"], "left": ["leave"], "lent": ["lend"],
        "let": ["let"], "lay": ["lie"], "lain": ["lie"], "lit": ["light"], "lost": ["lose"],
        "made": ["make"], "meant": ["mean"], "met": ["meet"], "paid": ["pay"], "put": ["put"],
        "quit": ["quit"], "read": ["read"], "rode": ["ride"], "ridden": ["ride"], "rang": ["ring"], "rung": ["ring"],
        "rose": ["rise"], "risen": ["rise"], "ran": ["run"], "said": ["say"], "saw": ["see"], "seen": ["see"],
        "sought": ["seek"], "sold": ["sell"], "sent": ["send"], "set": ["set"], "shook": ["shake"], "shaken": ["shake"],
        "shone": ["shine"], "shot": ["shoot"], "showed": ["show"], "shown": ["show"], "shut": ["shut"],
        "sang": ["sing"], "sung": ["sing"], "sank": ["sink"], "sunk": ["sink"], "sat": ["sit"], "slept": ["sleep"],
        "slid": ["slide"], "spoke": ["speak"], "spoken": ["speak"], "spent": ["spend"], "spilt": ["spill"],
        "split": ["split"], "spread": ["spread"], "stood": ["stand"], "stole": ["steal"], "stolen": ["steal"],
        "stuck": ["stick"], "stung": ["sting"], "struck": ["strike"], "swept": ["sweep"], "swam": ["swim"], "swum": ["swim"],
        "took": ["take"], "taken": ["take"], "taught": ["teach"], "tore": ["tear"], "torn": ["tear"],
        "told": ["tell"], "thought": ["think"], "threw": ["throw"], "thrown": ["throw"],
        "understood": ["understand"], "woke": ["wake"], "woken": ["wake"], "wore": ["wear"], "worn": ["wear"],
        "wept": ["weep"], "won": ["win"], "wrote": ["write"], "written": ["write"],
        "lying": ["lie"], "dying": ["die"], "tying": ["tie"],
        // Nouns
        "children": ["child"], "men": ["man"], "women": ["woman"], "people": ["person"],
        "feet": ["foot"], "teeth": ["tooth"], "mice": ["mouse"], "geese": ["goose"],
        "lives": ["life", "live"], "wives": ["wife"], "knives": ["knife"], "leaves": ["leaf", "leave"],
        "halves": ["half"], "shelves": ["shelf"], "wolves": ["wolf"], "thieves": ["thief"], "loaves": ["loaf"],
        "potatoes": ["potato"], "tomatoes": ["tomato"], "heroes": ["hero"],
        // Comparatives
        "better": ["good", "well"], "best": ["good", "well"], "worse": ["bad"], "worst": ["bad"],
        "further": ["far"], "farther": ["far"], "furthest": ["far"], "farthest": ["far"],
        "less": ["little"], "least": ["little"], "more": ["much", "many"], "most": ["much", "many"],
    ]

    /// Function words: they hold a sentence together and are not words to add. Kept to the closed
    /// classes (articles, pronouns, auxiliaries, prepositions, conjunctions, determiners); a card
    /// for one of them ("have", "only") is still listed under "Kartlarda var".
    static let stopwords: Set<String> = [
        "a", "an", "the", "this", "that", "these", "those", "some", "any", "no", "every", "each",
        "all", "both", "either", "neither", "much", "many", "more", "most", "few", "little", "less",
        "other", "others", "another", "such", "own", "same",
        "i", "me", "my", "mine", "myself", "you", "your", "yours", "yourself", "yourselves",
        "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself",
        "we", "us", "our", "ours", "ourselves", "they", "them", "their", "theirs", "themselves",
        "who", "whom", "whose", "which", "what", "whatever", "whoever", "whichever",
        "someone", "somebody", "something", "anyone", "anybody", "anything", "everyone",
        "everybody", "everything", "nobody", "nothing", "one", "ones",
        "be", "am", "is", "are", "was", "were", "been", "being",
        "have", "has", "had", "having", "do", "does", "did", "done", "doing",
        "will", "would", "shall", "should", "can", "could", "may", "might", "must", "ought",
        "not", "nor", "and", "or", "but", "so", "yet", "if", "then", "than", "because", "since",
        "unless", "until", "while", "whereas", "although", "though", "whether", "as",
        "of", "in", "on", "at", "to", "for", "from", "by", "with", "without", "about", "into",
        "onto", "upon", "over", "under", "above", "below", "between", "among", "through",
        "during", "before", "after", "against", "along", "across", "around", "behind", "beyond",
        "near", "off", "out", "up", "down", "via", "per", "within", "toward", "towards",
        "here", "there", "where", "when", "why", "how", "now", "very", "too", "also",
        "just", "only", "even", "still", "already", "again", "ever", "never", "yes",
        "oh", "ok", "okay", "etc", "mr", "mrs", "ms", "dr",
    ]
}
