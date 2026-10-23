import Foundation
import TextFold

/// "Cümle kur": an example sentence cut into word tiles that the learner puts back in order.
///
/// Splitting, on whitespace:
/// - The punctuation around a word is not part of its tile: "Yes," → "Yes", "please?" →
///   "please". Inside a word it stays: "don't", "well-known", "6:30", "2,000". A plural
///   possessive keeps its apostrophe ("parents'") and an abbreviation its dot ("Dr.", "a.m.").
/// - Capitals stay as written. Many sentences start with a name ("Ayşe"), which must not turn
///   into "ayşe"; the capital also shows the first word, a small help at A2.
/// - The sentence's final mark ("." "?" "!" "…") is no tile: it stands after the tiles.
/// - A word that is only punctuation ("—") gets no tile.
///
/// Not used (the initializer fails): fewer than `minTiles` or more than `maxTiles` tiles, two
/// sentences in one ("The bus is full. We have to wait.": either half could come first), quoted
/// speech or words (“…”, "…", '…'), brackets, a ";" or ":" after a word, and a sentence whose
/// words are all the same. The learner then sees only sentences with one right order.
///
/// Checking compares `TextFold.fold` keys (with ’ read as '), not the tiles themselves: two tiles
/// with the same word ("the", "The") may swap places. The two single words around an "and" or
/// "or" may swap too ("red and itchy", "itchy and red"): both orders are right English, and the
/// feedback then shows the sentence as written. Other orders that are also right (a time word
/// put first) are not recognized; the capital of the first tile makes them rarer.
public struct SentenceTiles: Equatable, Sendable {
    public struct Tile: Identifiable, Hashable, Sendable {
        /// The tile's place in the sentence, from 0.
        public let id: Int
        /// What the tile shows.
        public let text: String
        /// `text` folded, for checking.
        public let key: String

        public init(id: Int, text: String) {
            self.id = id
            self.text = text
            self.key = SentenceTiles.key(text)
        }
    }

    /// How a placed order compares with the sentence.
    public struct Check: Equatable, Sendable {
        public let isCorrect: Bool
        /// Places in the placed order (from 0) whose tile is not where the sentence has it: the
        /// tiles off the longest run the two orders share, so one tile put first marks one tile,
        /// not the whole row.
        public let misplaced: Set<Int>
    }

    public static let minTiles = 3
    /// Ten tiles fit a phone's width in three or four rows at the default text size.
    public static let maxTiles = 10

    /// The sentence as written: shown and read aloud once it is checked.
    public let sentence: String
    /// The tiles in the sentence's order.
    public let tiles: [Tile]
    /// The sentence's final mark, shown after the tiles; empty when it has none.
    public let ending: String

    public init?(_ sentence: String, minTiles: Int = SentenceTiles.minTiles, maxTiles: Int = SentenceTiles.maxTiles) {
        let words = sentence.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        var texts: [String] = []
        var ending = ""
        for (index, word) in words.enumerated() {
            guard let piece = SentenceTiles.piece(of: word, isLast: index == words.count - 1) else {
                return nil
            }
            if let text = piece.text {
                texts.append(text)
            }
            if index == words.count - 1 {
                ending = piece.ending
            }
        }
        guard texts.count >= max(minTiles, 2), texts.count <= maxTiles else {
            return nil
        }
        let tiles = texts.enumerated().map { Tile(id: $0.offset, text: $0.element) }
        // Every order of one repeated word is right: nothing to put in order.
        guard Set(tiles.map(\.key)).count >= 2 else {
            return nil
        }
        self.sentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        self.tiles = tiles
        self.ending = ending
    }

    /// The tiles in a mixed order, never in the sentence's own order (compared by key). The same
    /// seed and attempt give the same order on every device and launch, so a question keeps its
    /// order while it is on screen; another attempt mixes the tiles anew.
    public func shuffled(seed: Int, attempt: Int = 0) -> [Tile] {
        var generator = PracticeRandom(seed: seed, salt: attempt)
        var order = generator.shuffled(tiles)
        let accepted = acceptedOrders
        // Turned on until it is no accepted order. The turns of an order differ from each other
        // unless every key is the same (never: `init`), so this ends long before `count` turns.
        var turns = 0
        while accepted.contains(order.map(\.key)) && turns < order.count {
            order.append(order.removeFirst())
            turns += 1
        }
        return order
    }

    /// Compares a placed order with the sentence. An order that leaves tiles out, or holds a tile
    /// of another sentence, is not correct.
    public func check(_ placed: [Tile]) -> Check {
        let placedKeys = placed.map(\.key)
        let sameTiles = placed.count == tiles.count && Set(placed.map(\.id)) == Set(tiles.map(\.id))
        if sameTiles && acceptedOrders.contains(placedKeys) {
            return Check(isCorrect: true, misplaced: [])
        }
        let kept = SentenceTiles.commonPlaces(placedKeys, tiles.map(\.key))
        return Check(isCorrect: false, misplaced: Set(placed.indices).subtracting(kept))
    }

    /// The sentence's order (as keys), then the same with the single words on both sides of an
    /// "and" or "or" swapped: "Mix the eggs and flour" / "Mix the flour and eggs".
    var acceptedOrders: [[String]] {
        let keys = tiles.map(\.key)
        let joiners: Set<String> = ["and", "or"]
        var orders = [keys]
        for place in keys.indices.dropFirst().dropLast() where joiners.contains(keys[place]) {
            let left = keys[place - 1]
            let right = keys[place + 1]
            guard left != right, !joiners.contains(left), !joiners.contains(right) else {
                continue
            }
            var swapped = keys
            swapped.swapAt(place - 1, place + 1)
            orders.append(swapped)
        }
        return orders
    }

    /// The placed tiles as one line, with the sentence's final mark once every tile is placed
    /// ("Can I have a spoon please?"): what VoiceOver reads back after each tap.
    public func line(_ placed: [Tile]) -> String {
        let words = placed.map(\.text).joined(separator: " ")
        return placed.count == tiles.count ? words + ending : words
    }

    // MARK: Splitting

    /// Marks stripped from the edges of a word. Apostrophes are not among them: a word never
    /// starts with one here (quotes are refused), and one at the end is a possessive.
    private static let edgeMarks: Set<Character> = [
        ".", ",", ";", ":", "!", "?", "\"", "\u{201C}", "\u{201D}", "\u{2018}", "(", ")", "[", "]",
        "\u{2026}", "\u{2014}", "\u{2013}", "-", "\u{00AB}", "\u{00BB}",
    ]
    /// Marks that end a sentence.
    private static let terminalMarks: Set<Character> = [".", "?", "!", "\u{2026}"]
    /// A word that starts with one of these quotes or brackets something.
    private static let openingMarks: Set<Character> = ["\"", "\u{201C}", "\u{201D}", "\u{2018}", "'", "\u{2019}", "(", "[", "\u{00AB}"]
    /// A word that ends with one of these closes a quote or a bracket, or joins two clauses.
    private static let refusedTrailingMarks: Set<Character> = ["\"", "\u{201C}", "\u{201D}", "\u{2018}", ")", "]", "\u{00BB}", ";", ":"]
    /// Titles written with a dot before a name.
    private static let titles: Set<String> = ["mr", "mrs", "ms", "dr", "st", "jr", "sr"]

    /// One whitespace-separated word: its tile text (nil for punctuation alone) and, for the last
    /// word, the sentence's final mark. Nil when the word makes the sentence unusable.
    private static func piece(of word: String, isLast: Bool) -> (text: String?, ending: String)? {
        if let first = word.first, openingMarks.contains(first) {
            return nil
        }
        guard word.contains(where: { !edgeMarks.contains($0) }) else {
            // Punctuation alone ("—", "…"): no tile. In the middle a "." or "?" would end a
            // sentence there, and at the end it is the sentence's final mark.
            let terminal = String(word.filter { terminalMarks.contains($0) })
            if isLast {
                return (nil, terminal)
            }
            return terminal.isEmpty ? (nil, "") : nil
        }
        var core = Substring(word)
        while let first = core.first, edgeMarks.contains(first) {
            core.removeFirst()
        }
        var trailing = ""
        while let last = core.last, edgeMarks.contains(last) {
            trailing.insert(last, at: trailing.startIndex)
            core.removeLast()
        }
        if trailing.contains(where: { refusedTrailingMarks.contains($0) }) {
            return nil
        }
        var text = String(core)
        // "Dr." and "a.m." keep their dot: it belongs to the word, it does not end the sentence.
        if trailing.first == ".", core.contains(".") || titles.contains(TextFold.fold(text)) {
            text += "."
            trailing.removeFirst()
        }
        if !isLast && trailing.contains(where: { terminalMarks.contains($0) }) {
            return nil
        }
        return (text, isLast ? String(trailing.filter { terminalMarks.contains($0) }) : "")
    }

    /// The checking key: folded (case, Turkish letters, accents), with the typographic apostrophe
    /// read as the plain one ("Don’t" and "don't" match).
    static func key(_ text: String) -> String {
        return TextFold.fold(text).replacingOccurrences(of: "\u{2019}", with: "'")
    }

    /// Places of `a` on a longest common subsequence of `a` and `b`.
    private static func commonPlaces(_ a: [String], _ b: [String]) -> Set<Int> {
        var lengths = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in stride(from: a.count - 1, through: 0, by: -1) {
            for j in stride(from: b.count - 1, through: 0, by: -1) {
                lengths[i][j] = a[i] == b[j] ? lengths[i + 1][j + 1] + 1 : max(lengths[i + 1][j], lengths[i][j + 1])
            }
        }
        var kept = Set<Int>()
        var i = 0
        var j = 0
        while i < a.count && j < b.count {
            if a[i] == b[j] {
                kept.insert(i)
                i += 1
                j += 1
            } else if lengths[i + 1][j] >= lengths[i][j + 1] {
                i += 1
            } else {
                j += 1
            }
        }
        return kept
    }
}

/// SplitMix64: a small deterministic generator, the same numbers on every device and Swift
/// version (unlike `Hasher` or `shuffle(using:)`, whose algorithm is not promised to stay).
struct PracticeRandom {
    private var state: UInt64

    init(seed: Int, salt: Int = 0) {
        state = UInt64(bitPattern: Int64(seed)) &* 0x9E37_79B9_7F4A_7C15 &+ UInt64(bitPattern: Int64(salt))
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// A number in `0..<bound` (`bound` > 0).
    mutating func next(below bound: Int) -> Int {
        return Int(next() % UInt64(bound))
    }

    /// Fisher–Yates with this generator.
    mutating func shuffled<T>(_ items: [T]) -> [T] {
        var result = items
        var i = result.count - 1
        while i > 0 {
            result.swapAt(i, next(below: i + 1))
            i -= 1
        }
        return result
    }
}
