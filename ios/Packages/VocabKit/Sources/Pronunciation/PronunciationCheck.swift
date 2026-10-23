import Foundation

/// What the learner is asked to say: a card's word (with its US IPA) or a short example sentence.
public struct PronunciationTarget: Equatable, Sendable {
    public let text: String
    /// US IPA of `text`, e.g. "/θɪŋk/". Only used for a one-word target; a sentence has none.
    public let ipa: String?

    public init(text: String, ipa: String? = nil) {
        self.text = text
        self.ipa = ipa
    }
}

/// One transcription from the speech recognizer. The app passes the best one first, then the
/// alternatives.
public struct Hypothesis: Equatable, Sendable {
    public let text: String
    /// 0...1 as reported by the recognizer; nil when it gave none.
    public let confidence: Double?

    public init(text: String, confidence: Double? = nil) {
        self.text = text
        self.confidence = confidence
    }
}

/// Checks what the on-device speech recognizer heard against the target, for the "Söyle" practice.
/// Pure: no Speech framework and no audio. The app passes in the hypotheses and shows the feedback.
///
/// A speech recognizer is not a pronunciation scorer: it writes the most likely English words. So
/// the check is lenient (case, punctuation, hyphens, apostrophes, digits vs number words, a few
/// homophones and extra words around the target do not count), and a sound-specific tip is given
/// only when every difference with a tip is the same known Turkish-speaker pattern. Anything else
/// gets general feedback rather than a wrong diagnosis.
///
/// A sentence (the card's example, said after hearing it: shadowing) is checked word by word, and
/// the result says for each written word whether the phone understood it (`TargetPiece`). The same
/// leniency holds inside a sentence, plus what a sentence needs: a contraction and its long form
/// are the same ("I'm" / "I am", "don't" / "do not", "let's" / "let us"), and so are words written
/// together or apart anywhere in it ("check-up" / "checkup", "6 p.m." / "6 PM").
public enum PronunciationCheck {
    /// Below this, a match counts as "almost": understood, but not clearly. Tune on the device.
    public static let lowConfidence = 0.5
    /// A sentence of three or more words with at least this share heard is "almost".
    public static let sentenceAlmostRatio = 0.75

    public static func evaluate(target: PronunciationTarget, hypotheses: [Hypothesis]) -> PronunciationFeedback {
        let written = segments(target.text)
        let targetTokens = tokens(of: written)
        let heardList = hypotheses
            .map { (hypothesis: $0, tokens: tokens($0.text)) }
            .filter { !$0.tokens.isEmpty }
        guard !targetTokens.isEmpty, let best = heardList.first else {
            return PronunciationFeedback(verdict: .notHeard)
        }
        let heard = best.hypothesis.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let steps = align(targetTokens, best.tokens)
        let sameWhenRunTogether = compact(targetTokens) == compact(best.tokens)

        if sameWhenRunTogether || covers(steps) {
            let pieces = targetPieces(written, tokens: targetTokens, statuses: Array(repeating: .heard, count: targetTokens.count))
            if let confidence = best.hypothesis.confidence, confidence < lowConfidence {
                return PronunciationFeedback(verdict: .almost, heard: heard, pieces: pieces)
            }
            return PronunciationFeedback(verdict: .correct, heard: heard, pieces: pieces)
        }
        let inAlternative = heardList.dropFirst().contains { other in
            compact(targetTokens) == compact(other.tokens) || covers(align(targetTokens, other.tokens))
        }
        if inAlternative {
            // Understood, if not clearly: no word is marked, as the line says.
            let pieces = targetPieces(written, tokens: targetTokens, statuses: Array(repeating: .heard, count: targetTokens.count))
            return PronunciationFeedback(verdict: .almost, heard: heard, pieces: pieces)
        }
        let statuses = tokenStatuses(count: targetTokens.count, steps: steps)
        let pieces = targetPieces(written, tokens: targetTokens, statuses: statuses)

        var substituted = 0
        var missedIndexes: [Int] = []
        for step in steps {
            switch step {
            case .substitute(let i, _):
                substituted += 1
                missedIndexes.append(i)
            case .missing(let i):
                missedIndexes.append(i)
            case .match, .extra, .joined:
                break
            }
        }
        // Each written word once, in the order of the target ("at 21": "21", not "twenty, one").
        var missedWords: [String] = []
        for piece in pieces where piece.status == .different || piece.status == .missing {
            if !missedWords.contains(where: { $0.lowercased() == piece.text.lowercased() }) {
                missedWords.append(piece.text)
            }
        }
        let tip = findTip(target: target, targetTokens: targetTokens, heardTokens: best.tokens, steps: steps)
        // "get up" heard as "get": one word of a phrase not heard, nothing heard wrong. A wrong
        // particle ("turn off" for "turn on") is a substitution and stays "try again".
        let onlyOneWordMissing = targetTokens.count >= 2 && substituted == 0 && missedIndexes.count == 1
        let heardShare = Double(targetTokens.count - missedIndexes.count) / Double(targetTokens.count)
        // By length, not by the page's mode: a three-word phrase ("look forward to") also gets
        // the words named, which helps there as well.
        let isSentence = targetTokens.count >= 3
        if onlyOneWordMissing || (isSentence && heardShare >= sentenceAlmostRatio) {
            return PronunciationFeedback(verdict: .almost, tip: tip, heard: heard, missedWords: missedWords, pieces: pieces)
        }
        return PronunciationFeedback(
            verdict: .tryAgain, tip: tip, heard: heard, missedWords: missedWords, pieces: pieces,
            namesMissedWords: isSentence
        )
    }

    /// The words of `text` as they are compared: lowercased, accents and punctuation dropped,
    /// apostrophes removed ("o'clock" → "oclock"), hyphens split ("one-way" → "one way"),
    /// numbers 0–999 spelled out ("4" → "four", "7:30" → "seven thirty", "200" → "two hundred").
    public static func normalize(_ text: String) -> String {
        return tokens(text).map(\.key).joined(separator: " ")
    }

    // MARK: - Tokens

    struct Token: Equatable {
        /// Normalized form, compared through `canonical`.
        let key: String
        /// As written in the text (for "these words were not heard").
        let display: String
        /// The written word this token comes from: "21" is one word and two tokens.
        let word: Int
    }

    /// A stretch of the text as written: a word (letters and digits, apostrophes inside it) with
    /// its folded `key`, or what lies between two words (`key` nil).
    struct Segment: Equatable {
        let text: String
        let key: String?
    }

    private static let apostrophes: Set<Character> = ["'", "\u{2019}", "\u{2018}", "\u{02BC}"]

    static func tokens(_ text: String) -> [Token] {
        return tokens(of: segments(text))
    }

    private static func tokens(of segments: [Segment]) -> [Token] {
        var result: [Token] = []
        var word = 0
        for segment in segments {
            guard let key = segment.key else {
                continue
            }
            for spoken in spokenWords(key) {
                result.append(Token(key: spoken, display: segment.text, word: word))
            }
            word += 1
        }
        return result
    }

    /// The whole text in order, cut into words and the spaces and punctuation between them.
    static func segments(_ text: String) -> [Segment] {
        var result: [Segment] = []
        var key = ""
        var word = ""
        var between = ""
        func endWord() {
            if !key.isEmpty {
                result.append(Segment(text: word, key: key))
            }
            key = ""
            word = ""
        }
        func endBetween() {
            if !between.isEmpty {
                result.append(Segment(text: between, key: nil))
            }
            between = ""
        }
        for character in text.precomposedStringWithCanonicalMapping {
            if apostrophes.contains(character) {
                if key.isEmpty {
                    between.append(character)
                } else {
                    word.append(character)
                }
                continue
            }
            let folded = fold(character)
            if !folded.isEmpty, folded.unicodeScalars.allSatisfy({ CharacterSet.alphanumerics.contains($0) }) {
                endBetween()
                key += folded
                word.append(character)
            } else {
                endWord()
                between.append(character)
            }
        }
        endWord()
        endBetween()
        return result
    }

    /// Lowercase, compatibility-decomposed, combining marks dropped ("É" → "e", "ş" → "s").
    private static func fold(_ character: Character) -> String {
        var scalars = String.UnicodeScalarView()
        for scalar in String(character).decomposedStringWithCompatibilityMapping.lowercased().unicodeScalars
            where scalar.properties.canonicalCombiningClass.rawValue == 0 {
            scalars.append(scalar)
        }
        return String(scalars)
    }

    private static let units = [
        "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
        "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen",
    ]
    private static let tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]

    /// A number of one or two digits, or of three without a leading zero ("200 lira" in a card's
    /// example), as words: the recognizer may write either form. Any other key unchanged.
    private static func spokenWords(_ key: String) -> [String] {
        guard key.count <= 3, key.allSatisfy({ $0.isASCII && $0.isNumber }), let value = Int(key) else {
            return [key]
        }
        if key.count == 3 {
            guard value >= 100 else {
                return [key]
            }
            let rest = value % 100
            return [units[value / 100], "hundred"] + (rest == 0 ? [] : belowHundred(rest))
        }
        return belowHundred(value)
    }

    private static func belowHundred(_ value: Int) -> [String] {
        if value < 20 {
            return [units[value]]
        }
        let ten = tens[value / 10]
        return value % 10 == 0 ? [ten] : [ten, units[value % 10]]
    }

    // MARK: - Comparison

    /// Words a recognizer writes interchangeably for the same sound (the same in General American).
    /// The first one of each group stands for the group. Lowercase, apostrophes dropped, and no
    /// word in two groups.
    public static let homophoneGroups: [[String]] = [
        ["write", "right", "rite"], ["see", "sea"], ["two", "to", "too"], ["four", "for"],
        ["hear", "here"], ["know", "no"], ["knew", "new"], ["buy", "by", "bye"],
        ["their", "there", "theyre"], ["your", "youre"], ["whose", "whos"], ["weather", "whether"],
        ["week", "weak"], ["meet", "meat"], ["son", "sun"], ["hour", "our"], ["wear", "where"],
        ["one", "won"], ["eight", "ate"], ["flower", "flour"], ["mail", "male"], ["plane", "plain"],
        ["road", "rode"], ["sale", "sail"], ["tale", "tail"], ["wait", "weight"], ["way", "weigh"],
        ["whole", "hole"], ["peace", "piece"], ["break", "brake"], ["dear", "deer"], ["fair", "fare"],
        ["pair", "pear"], ["steal", "steel"], ["stair", "stare"], ["blue", "blew"], ["night", "knight"],
        ["not", "knot"], ["would", "wood"], ["aloud", "allowed"], ["sell", "cell"], ["sent", "cent", "scent"],
        ["okay", "ok"],
        ["do", "due", "dew"], ["board", "bored"], ["key", "quay"], ["need", "knead", "kneed"],
        ["leak", "leek"], ["lesson", "lessen"], ["peel", "peal"], ["rest", "wrest"], ["slow", "sloe"],
        ["sore", "soar"], ["flu", "flew", "flue"], ["guest", "guessed"], ["browse", "brows"],
        ["cash", "cache"], ["check", "cheque"], ["choose", "chews"], ["find", "fined"], ["hair", "hare"],
        ["mind", "mined"], ["pain", "pane"], ["rain", "reign", "rein"], ["seem", "seam"], ["bread", "bred"],
    ]

    private static let canonicalSpelling: [String: String] = {
        var map: [String: String] = [:]
        for group in homophoneGroups {
            for word in group {
                map[word] = group[0]
            }
        }
        return map
    }()

    private static func canonical(_ key: String) -> String {
        return canonicalSpelling[key] ?? key
    }

    private static func isSame(_ a: Token, _ b: Token) -> Bool {
        return canonical(a.key) == canonical(b.key) || !forms(of: [a]).isDisjoint(with: forms(of: [b]))
    }

    /// The words run together, so "second-hand", "second hand" and "secondhand" compare equal.
    private static func compact(_ tokens: [Token]) -> String {
        return tokens.map { canonical($0.key) }.joined()
    }

    /// Every target word was heard, in order (extra words around them are allowed).
    private static func covers(_ steps: [Step]) -> Bool {
        return !steps.contains { step in
            switch step {
            case .substitute, .missing:
                return true
            case .match, .extra, .joined:
                return false
            }
        }
    }

    // MARK: - Contractions and words written together

    /// Words before "'s" that make "is" or "has" ("it's", "what's"); after any other word "'s"
    /// is a possessive ("Emre's") and stays one word.
    private static let pronounsBeforeS: Set<String> = [
        "it", "he", "she", "that", "there", "here", "what", "where", "who", "how", "when", "why",
        "this", "everyone", "everything", "everybody", "someone", "something", "somebody",
        "nobody", "nothing",
    ]

    /// The long forms of a written contraction, word by word: "don't" → [do, not], "I'd" →
    /// [i, would] or [i, had], "can't" → [can, not] or [cannot]. Empty for any other word,
    /// possessives ("Emre's") and "o'clock" included.
    static func expansions(of token: Token) -> [[String]] {
        guard let mark = token.display.lastIndex(where: { apostrophes.contains($0) }) else {
            return []
        }
        let base = token.display[..<mark].map { fold($0) }.joined()
        let ending = token.display[token.display.index(after: mark)...].map { fold($0) }.joined()
        guard !base.isEmpty else {
            return []
        }
        switch ending {
        case "t" where base.hasSuffix("n"):
            switch base {
            case "can":
                return [["can", "not"], ["cannot"]]
            case "won":
                return [["will", "not"]]
            case "shan":
                return [["shall", "not"]]
            case "ain":
                return []
            default:
                return [[String(base.dropLast()), "not"]]
            }
        case "m":
            return [[base, "am"]]
        case "re":
            return [[base, "are"]]
        case "ve":
            return [[base, "have"]]
        case "ll":
            return [[base, "will"]]
        case "d":
            return [[base, "would"], [base, "had"]]
        case "s" where base == "let":
            return [["let", "us"]]
        case "s" where pronounsBeforeS.contains(base):
            return [[base, "is"], [base, "has"]]
        default:
            return []
        }
    }

    /// What one or two tokens can stand for, each written as one run of letters: the words run
    /// together and, for a contraction, each of its long forms run together.
    private static func forms(of tokens: [Token]) -> Set<String> {
        var result: Set<String> = [compact(tokens)]
        if tokens.count == 1, let only = tokens.first {
            for expansion in expansions(of: only) {
                result.insert(expansion.map { canonical($0) }.joined())
            }
        }
        return result
    }

    /// One target word and two heard words, or two and one, that say the same thing written
    /// differently: "I'm" / "I am", "log in" / "login", "p m" / "pm".
    private static func joins(_ target: ArraySlice<Token>, _ heard: ArraySlice<Token>) -> Bool {
        return !forms(of: Array(target)).isDisjoint(with: forms(of: Array(heard)))
    }

    enum Step: Equatable {
        /// target[i] heard as heard[j].
        case match(Int, Int)
        /// target[i] heard as a different word heard[j].
        case substitute(Int, Int)
        /// target[i] not heard.
        case missing(Int)
        /// heard[j] is not in the target.
        case extra(Int)
        /// These target tokens heard as these heard tokens, written differently (one and two, or
        /// two and one): "don't" as "do not", "check up" as "checkup".
        case joined(Range<Int>, Range<Int>)
    }

    /// Word-level edit alignment (Levenshtein) of the target against what was heard. A
    /// contraction against its long form, or two words against the same written as one, cost
    /// nothing (`joined`).
    static func align(_ target: [Token], _ heard: [Token]) -> [Step] {
        let n = target.count
        let m = heard.count
        func joinsTwoTarget(_ i: Int, _ j: Int) -> Bool {
            return i > 1 && j > 0 && joins(target[(i - 2)..<i], heard[(j - 1)..<j])
        }
        func joinsTwoHeard(_ i: Int, _ j: Int) -> Bool {
            return i > 0 && j > 1 && joins(target[(i - 1)..<i], heard[(j - 2)..<j])
        }
        var cost = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 0...n {
            cost[i][0] = i
        }
        for j in 0...m {
            cost[0][j] = j
        }
        if n > 0, m > 0 {
            for i in 1...n {
                for j in 1...m {
                    let diagonal = cost[i - 1][j - 1] + (isSame(target[i - 1], heard[j - 1]) ? 0 : 1)
                    var best = min(diagonal, cost[i - 1][j] + 1, cost[i][j - 1] + 1)
                    if joinsTwoTarget(i, j) {
                        best = min(best, cost[i - 2][j - 1])
                    }
                    if joinsTwoHeard(i, j) {
                        best = min(best, cost[i - 1][j - 2])
                    }
                    cost[i][j] = best
                }
            }
        }
        var steps: [Step] = []
        var i = n
        var j = m
        while i > 0 || j > 0 {
            if joinsTwoTarget(i, j), cost[i][j] == cost[i - 2][j - 1] {
                steps.append(.joined((i - 2)..<i, (j - 1)..<j))
                i -= 2
                j -= 1
                continue
            }
            if joinsTwoHeard(i, j), cost[i][j] == cost[i - 1][j - 2] {
                steps.append(.joined((i - 1)..<i, (j - 2)..<j))
                i -= 1
                j -= 2
                continue
            }
            if i > 0, j > 0 {
                let same = isSame(target[i - 1], heard[j - 1])
                if cost[i][j] == cost[i - 1][j - 1] + (same ? 0 : 1) {
                    steps.append(same ? .match(i - 1, j - 1) : .substitute(i - 1, j - 1))
                    i -= 1
                    j -= 1
                    continue
                }
            }
            if i > 0, cost[i][j] == cost[i - 1][j] + 1 {
                steps.append(.missing(i - 1))
                i -= 1
            } else {
                steps.append(.extra(j - 1))
                j -= 1
            }
        }
        return steps.reversed()
    }

    // MARK: - Word by word

    /// Each target token: heard (as itself or written differently), heard as another word, or
    /// not heard.
    private static func tokenStatuses(count: Int, steps: [Step]) -> [WordStatus] {
        var statuses = Array(repeating: WordStatus.missing, count: count)
        for step in steps {
            switch step {
            case .match(let i, _):
                statuses[i] = .heard
            case .joined(let targetRange, _):
                for i in targetRange {
                    statuses[i] = .heard
                }
            case .substitute(let i, _):
                statuses[i] = .different
            case .missing, .extra:
                break
            }
        }
        return statuses
    }

    /// The target as written, its words marked: a word is heard when all its tokens were, missing
    /// when none of them was heard at all, otherwise different ("21" heard as "twenty").
    private static func targetPieces(_ segments: [Segment], tokens: [Token], statuses: [WordStatus]) -> [TargetPiece] {
        var pieces: [TargetPiece] = []
        var word = 0
        for segment in segments {
            guard segment.key != nil else {
                pieces.append(TargetPiece(text: segment.text, status: nil))
                continue
            }
            let own = tokens.indices.filter { tokens[$0].word == word }.map { statuses[$0] }
            word += 1
            let status: WordStatus
            if own.allSatisfy({ $0 == .heard }) {
                status = .heard
            } else if own.allSatisfy({ $0 == .missing }) {
                status = .missing
            } else {
                status = .different
            }
            pieces.append(TargetPiece(text: segment.text, status: status))
        }
        return pieces
    }

    // MARK: - Tips

    /// The tip for the wrongly heard words, or nil unless they all point at one pattern. A one-word
    /// target is first compared with everything heard run together ("birthday" heard as "bird day"),
    /// then with the word heard in its place ("think" in "I sink").
    private static func findTip(
        target: PronunciationTarget,
        targetTokens: [Token],
        heardTokens: [Token],
        steps: [Step]
    ) -> PronunciationTip? {
        var tips: [PronunciationTip] = []
        let oneWord = targetTokens.count == 1
        let heardDisplay = heardTokens.map(\.display).joined(separator: " ")
        if oneWord, let whole = makeTip(expected: targetTokens[0], heardKey: compact(heardTokens), heardDisplay: heardDisplay, ipa: target.ipa) {
            tips.append(whole)
        } else {
            for step in steps {
                guard case .substitute(let i, let j) = step else {
                    continue
                }
                let heard = heardTokens[j]
                if let found = makeTip(expected: targetTokens[i], heardKey: heard.key, heardDisplay: heard.display, ipa: oneWord ? target.ipa : nil) {
                    tips.append(found)
                }
            }
        }
        guard let first = tips.first, tips.allSatisfy({ $0.kind == first.kind }) else {
            return nil
        }
        return first
    }

    /// The single pattern that turns `expected` into what was heard; nil if none or more than one.
    private static func makeTip(expected: Token, heardKey: String, heardDisplay: String, ipa: String?) -> PronunciationTip? {
        let word = expected.key
        let candidates = [
            thTip(word, heardKey, ipa),
            wvTip(word, heardKey, ipa),
            finalVoicingTip(word, heardKey, ipa),
            finalDroppedTip(word, heardKey, ipa),
        ].compactMap { $0 }
        guard candidates.count == 1, let found = candidates.first else {
            return nil
        }
        return PronunciationTip(kind: found.kind, expected: expected.display, heard: heardDisplay, advice: found.advice)
    }

    private struct Found {
        let kind: PronunciationTip.Kind
        let advice: String
    }

    /// "think" → "sink", "three" → "tree", "this" → "dis": one "th" said as t, d, s, z, f or v.
    private static func thTip(_ expected: String, _ heard: String, _ ipa: String?) -> Found? {
        if let ipa, !ipa.contains("θ"), !ipa.contains("ð") {
            return nil
        }
        let letters = Array(expected)
        guard letters.count >= 2 else {
            return nil
        }
        for k in 0..<(letters.count - 1) where letters[k] == "t" && letters[k + 1] == "h" {
            for replacement in ["t", "d", "s", "z", "f", "v"] {
                var changed = letters
                changed.replaceSubrange(k...(k + 1), with: Array(replacement))
                if String(changed) == heard {
                    return Found(kind: .th, advice: "'th' sesine dikkat: dilinin ucunu üst dişlerine hafifçe değdir ve üfle. 't', 'd' ya da 's' gibi söyleme.")
                }
            }
        }
        return nil
    }

    /// "wine" → "vine", "vest" → "west": one w said as v or the other way round.
    private static func wvTip(_ expected: String, _ heard: String, _ ipa: String?) -> Found? {
        let letters = Array(expected)
        for k in letters.indices where letters[k] == "w" || letters[k] == "v" {
            let fromW = letters[k] == "w"
            let sound: Character = fromW ? "w" : "v"
            if let ipa, !ipa.contains(sound) {
                continue
            }
            var changed = letters
            changed[k] = fromW ? "v" : "w"
            if String(changed) == heard {
                let advice = fromW
                    ? "'w' sesine dikkat: dudaklarını yuvarla, dişlerin dudağına değmesin. 'v' gibi söyleme."
                    : "'v' sesine dikkat: üst dişlerin alt dudağına değsin. 'w' gibi söyleme."
                return Found(kind: .wv, advice: advice)
            }
        }
        return nil
    }

    /// Spelling of a voiced final sound, the spelling of its voiceless pair, and both sounds as
    /// Turkish letters ("c" and "ç" are exactly /dʒ/ and /tʃ/).
    private static let voicingRules: [(voiced: String, voiceless: String, soft: String, hard: String)] = [
        ("d", "t", "d", "t"), ("de", "te", "d", "t"),
        ("b", "p", "b", "p"), ("be", "pe", "b", "p"),
        ("g", "k", "g", "k"), ("g", "ck", "g", "k"),
        ("dge", "tch", "c", "ç"), ("ge", "ch", "c", "ç"),
        ("v", "f", "v", "f"), ("ve", "f", "v", "f"), ("ve", "fe", "v", "f"),
        ("z", "s", "z", "s"), ("ze", "ce", "z", "s"), ("se", "ce", "z", "s"), ("s", "ss", "z", "s"),
    ]

    /// "bad" → "bat", "dog" → "dock", "bridge" → "britch": a voiced final sound made voiceless,
    /// as Turkish does at the end of a word ("kitab" → "kitap").
    private static func finalVoicingTip(_ expected: String, _ heard: String, _ ipa: String?) -> Found? {
        if let ipa, let last = lastPhoneme(ipa), !"bdɡgvzʒ".unicodeScalars.contains(last) {
            return nil
        }
        for rule in voicingRules where expected.hasSuffix(rule.voiced) {
            if String(expected.dropLast(rule.voiced.count)) + rule.voiceless == heard {
                return Found(kind: .finalVoicing, advice: "Son sese dikkat: sondaki '\(rule.soft)' sesini '\(rule.hard)' gibi sertleştirme.")
            }
        }
        return nil
    }

    /// "asked" → "ask", "card" → "car": the last one or two consonant letters (or "-ed", "-es")
    /// not heard.
    private static func finalDroppedTip(_ expected: String, _ heard: String, _ ipa: String?) -> Found? {
        if let ipa, let last = lastPhoneme(ipa), "aeiouæɑɔəɛɜɪʊʌ".unicodeScalars.contains(last) {
            return nil
        }
        let dropped = expected.count - heard.count
        guard (1...2).contains(dropped), heard.count >= 2, expected.hasPrefix(heard) else {
            return nil
        }
        let tail = String(expected.suffix(dropped))
        let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
        guard tail == "ed" || tail == "es" || tail.allSatisfy({ $0.isLetter && !vowels.contains($0) }) else {
            return nil
        }
        return Found(kind: .finalDropped, advice: "Son sese dikkat: kelimenin sonunu yutma, sonuna kadar söyle.")
    }

    /// The last sound symbol of an IPA string, skipping slashes, stress and length marks.
    private static func lastPhoneme(_ ipa: String) -> Unicode.Scalar? {
        let marks = "/[]ˈˌː .()".unicodeScalars
        return ipa.unicodeScalars.reversed().first { !marks.contains($0) && !$0.properties.isWhitespace }
    }
}

/// A sound-specific hint: which word was heard as which, and what to do (Turkish).
public struct PronunciationTip: Equatable, Sendable {
    public enum Kind: String, CaseIterable, Sendable {
        /// "th" said as t, d, s, z, f or v.
        case th
        /// w and v swapped.
        case wv
        /// A voiced final sound made voiceless (bad → bat).
        case finalVoicing
        /// The end of the word not heard (asked → ask).
        case finalDropped
    }

    public let kind: Kind
    /// The target word as written in the card.
    public let expected: String
    /// What was heard instead.
    public let heard: String
    public let advice: String
}

/// Whether the phone understood one written word of the target.
public enum WordStatus: String, Equatable, Sendable {
    /// Understood: as written, as a homophone, as a contraction's long form, or written together.
    case heard
    /// Another word was understood in its place.
    case different
    /// Nothing was understood in its place.
    case missing
}

/// A stretch of the target as written: a word with its status, or the spaces and punctuation
/// between words (`status` nil). All pieces in order give back the target text.
public struct TargetPiece: Equatable, Sendable {
    public let text: String
    public let status: WordStatus?

    public init(text: String, status: WordStatus?) {
        self.text = text
        self.status = status
    }
}

/// A piece of a line shown and read to the learner: Turkish words, or English words (from the card
/// or from what was heard) that VoiceOver should read in an English voice.
public enum FeedbackRun: Equatable, Sendable {
    case turkish(String)
    case english(String)

    public var text: String {
        switch self {
        case .turkish(let text), .english(let text):
            return text
        }
    }
}

/// The result shown after the learner speaks: a verdict, a Turkish title and the line under it.
/// The phone is the one that hears, so the lines say what it understood, never that the learner
/// was right ("Anlaşıldı!", not "Doğru!"; ilkeler 2.7, terimler §1). The line does not repeat what
/// was heard: the page shows that in its own English row ("Duyulan"), which VoiceOver reads in an
/// English voice (audit V2, V5). The tip, when there is one, says what to do.
public struct PronunciationFeedback: Equatable, Sendable {
    public enum Verdict: String, Equatable, Sendable {
        case correct
        /// Understood but not clearly, heard only as an alternative, one word of a phrase missing,
        /// or most of a sentence.
        case almost
        case tryAgain
        /// Nothing usable was heard.
        case notHeard
    }

    public let verdict: Verdict
    public let tip: PronunciationTip?
    /// The best transcription as the recognizer wrote it; empty when nothing was heard.
    public let heard: String
    /// Target words that were not heard, as written in the target, each once.
    public let missedWords: [String]
    /// The target word by word, as compared with the best transcription (the page marks a
    /// sentence with it); empty when nothing was heard.
    public let pieces: [TargetPiece]
    public let title: String
    /// The line under the title, in pieces: the words not heard are English.
    public let messageRuns: [FeedbackRun]

    public var message: String {
        return messageRuns.map(\.text).joined()
    }

    /// `namesMissedWords`: a sentence to try again says which words were not understood (the
    /// marks on the sentence are not read by VoiceOver); a word or a phrase does not need to.
    init(
        verdict: Verdict,
        tip: PronunciationTip? = nil,
        heard: String = "",
        missedWords: [String] = [],
        pieces: [TargetPiece] = [],
        namesMissedWords: Bool = false
    ) {
        self.verdict = verdict
        self.tip = tip
        self.heard = heard
        self.missedWords = missedWords
        self.pieces = pieces
        switch verdict {
        case .correct:
            title = "Anlaşıldı!"
            messageRuns = [.turkish("Telefon seni anladı.")]
        case .almost:
            title = "Neredeyse!"
            if missedWords.isEmpty {
                messageRuns = [.turkish("Anlaşıldı ama tam net değildi. Bir kez daha söyle.")]
            } else {
                messageRuns = [
                    .turkish("Şunlar duyulmadı: "),
                    .english(missedWords.joined(separator: ", ")),
                    .turkish(". Bir daha dene."),
                ]
            }
        case .tryAgain:
            title = "Bir daha dene"
            if namesMissedWords && !missedWords.isEmpty {
                // Two sentences at most (terimler §1): which words, then what to do.
                messageRuns = [
                    .turkish("Şunlar duyulmadı: "),
                    .english(missedWords.joined(separator: ", ")),
                    .turkish(tip == nil ? ". Önce Dinle'ye dokunup dinle, sonra yavaş ve net söyle." : "."),
                ]
            } else if tip == nil {
                messageRuns = [.turkish("Telefon farklı bir şey anladı. Önce Dinle'ye dokunup dinle, sonra yavaş ve net söyle.")]
            } else {
                messageRuns = [.turkish("Telefon farklı bir şey anladı.")]
            }
        case .notHeard:
            title = "Seni duyamadım"
            messageRuns = [.turkish("Mikrofona yakın, net bir sesle söyle.")]
        }
    }
}
