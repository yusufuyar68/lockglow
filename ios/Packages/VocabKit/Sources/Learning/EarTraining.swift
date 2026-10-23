import CoreModels
import Foundation

// "Kulak alıştırması": minimal pairs that Turkish learners find hard to hear apart (ship / sheep,
// three / tree, vine / wine …). The phone reads one word of a pair aloud, the learner picks which
// of the two they heard, then a short Turkish note says how the mouth and tongue make each sound.
// Rounds of 10 questions. The results feed a local counter per sound pair (`EarTrainingTally`),
// never the Leitner progress: hearing a contrast is not a review of a word.
//
// Content: ios/App/Resources/minimal_pairs.json, built from content/kulak/ by
// content/kulak/derle.py (never from content.sqlite).

// MARK: - Content

/// The whole minimal-pair file (`minimal_pairs.json`).
public struct EarTrainingContent: Codable, Equatable, Sendable {
    /// The `format` this build reads.
    public static let format = 1

    public let format: Int
    /// "2026.10.23-kulak-1": changes with every rebuild of the file.
    public let version: String
    /// In display order (the builder's file order).
    public let groups: [EarTrainingGroup]

    public init(format: Int = EarTrainingContent.format, version: String, groups: [EarTrainingGroup]) {
        self.format = format
        self.version = version
        self.groups = groups
    }

    public enum DecodeError: Error, Equatable {
        /// A file of another format (a newer build wrote it).
        case unsupportedFormat(Int)
    }

    /// Decodes the file. Groups that cannot be asked (not exactly two sounds, no pair, the two
    /// words of a pair the same) are left out, so one bad group never empties the mode.
    public static func decode(_ data: Data) throws -> EarTrainingContent {
        let raw = try JSONDecoder().decode(EarTrainingContent.self, from: data)
        guard raw.format == EarTrainingContent.format else {
            throw DecodeError.unsupportedFormat(raw.format)
        }
        let usable = raw.groups.compactMap { $0.usable() }
        return EarTrainingContent(format: raw.format, version: raw.version, groups: usable)
    }

    public func group(id: String) -> EarTrainingGroup? {
        return groups.first { $0.id == id }
    }
}

/// One contrast, such as short and long i: two sounds and the word pairs that differ only there.
public struct EarTrainingGroup: Codable, Equatable, Identifiable, Sendable {
    /// Stable key of the counter ("ih-ee"); never reused for another contrast.
    public let id: String
    /// The best-known pair, "ship / sheep".
    public let title: String
    /// "Kısa i ve uzun i".
    public let nameTR: String
    /// Exactly two: `sounds[0]` is in every pair's `a` word, `sounds[1]` in every `b` word.
    public let sounds: [EarTrainingSound]
    /// The typical Turkish learner's difficulty, one sentence; optional.
    public let tipTR: String?
    public let pairs: [EarTrainingPair]

    public init(id: String, title: String, nameTR: String, sounds: [EarTrainingSound], tipTR: String? = nil, pairs: [EarTrainingPair]) {
        self.id = id
        self.title = title
        self.nameTR = nameTR
        self.sounds = sounds
        self.tipTR = tipTR
        self.pairs = pairs
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case nameTR = "name_tr"
        case sounds
        case tipTR = "tip_tr"
        case pairs
    }

    /// The sound of one side of every pair.
    public func sound(_ side: EarTrainingSide) -> EarTrainingSound {
        return sounds[side.rawValue]
    }

    /// This group without its unusable pairs, or nil when nothing can be asked.
    func usable() -> EarTrainingGroup? {
        guard sounds.count == 2 else {
            return nil
        }
        let good = pairs.filter { pair in
            let a = EarTrainingWord.key(pair.a.word)
            let b = EarTrainingWord.key(pair.b.word)
            return !a.isEmpty && !b.isEmpty && a != b
        }
        guard !good.isEmpty else {
            return nil
        }
        return EarTrainingGroup(id: id, title: title, nameTR: nameTR, sounds: sounds, tipTR: tipTR, pairs: good)
    }
}

/// One of the two sounds of a group, with the note shown after the answer.
public struct EarTrainingSound: Codable, Equatable, Sendable {
    /// "ɪ", "θ", "d / t", "∅" (a word without the ending); nil when the file gives none.
    public let ipa: String?
    /// "kısa i".
    public let nameTR: String
    /// Where the tongue, lips and jaw are: one or two short Turkish sentences.
    public let howTR: String

    public init(ipa: String?, nameTR: String, howTR: String) {
        self.ipa = ipa
        self.nameTR = nameTR
        self.howTR = howTR
    }

    enum CodingKeys: String, CodingKey {
        case ipa
        case nameTR = "name_tr"
        case howTR = "how_tr"
    }
}

/// The side of a pair: `.a` has the group's first sound, `.b` the second.
public enum EarTrainingSide: Int, CaseIterable, Codable, Sendable {
    case a = 0
    case b = 1

    public var other: EarTrainingSide {
        return self == .a ? .b : .a
    }
}

/// Two words that differ only by the group's contrast.
public struct EarTrainingPair: Codable, Equatable, Sendable {
    public let a: EarTrainingWord
    public let b: EarTrainingWord

    public init(a: EarTrainingWord, b: EarTrainingWord) {
        self.a = a
        self.b = b
    }

    public subscript(side: EarTrainingSide) -> EarTrainingWord {
        return side == .a ? a : b
    }
}

public struct EarTrainingWord: Codable, Equatable, Hashable, Sendable {
    /// The English word as it is read aloud and shown.
    public let word: String
    public let ipa: IPA
    /// Short Turkish meaning of this form ("koyun", "sordu").
    public let tr: String
    /// CEFR level of the (base) word, "A1" … "B1".
    public let level: String?

    public struct IPA: Codable, Equatable, Hashable, Sendable {
        /// "/ʃiːp/": General American.
        public let us: String
        /// Standard British; nil when the file has none.
        public let uk: String?

        public init(us: String, uk: String? = nil) {
            self.us = us
            self.uk = uk
        }

        /// The transcription in the accent of "Ses ve aksan" (the voice reads in that accent);
        /// the American one when the file has no British one.
        public func text(for accent: SpeechAccent) -> String {
            switch accent {
            case .american:
                return us
            case .british:
                return uk ?? us
            }
        }
    }

    public init(word: String, ipa: IPA, tr: String, level: String? = nil) {
        self.word = word
        self.ipa = ipa
        self.tr = tr
        self.level = level
    }

    /// The word for comparisons: lowercased, trimmed.
    static func key(_ word: String) -> String {
        return word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

// MARK: - Questions

/// One question: the word read aloud and the two words shown.
public struct EarTrainingQuestion: Equatable, Sendable {
    public let groupID: String
    /// The pair's index in its group.
    public let pairIndex: Int
    public let pair: EarTrainingPair
    /// The side read aloud.
    public let answerSide: EarTrainingSide
    /// The two sides in the order shown (first on top / on the left).
    public let shownOrder: [EarTrainingSide]

    public init(groupID: String, pairIndex: Int, pair: EarTrainingPair, answerSide: EarTrainingSide, shownOrder: [EarTrainingSide]) {
        self.groupID = groupID
        self.pairIndex = pairIndex
        self.pair = pair
        self.answerSide = answerSide
        self.shownOrder = shownOrder
    }

    /// The word read aloud.
    public var answer: EarTrainingWord {
        return pair[answerSide]
    }

    /// The two words in the order shown.
    public var options: [EarTrainingWord] {
        return shownOrder.map { pair[$0] }
    }

    public func isRight(_ picked: EarTrainingSide) -> Bool {
        return picked == answerSide
    }
}

/// Builds a round of questions. Pure; the caller passes the random source (the app the system
/// one, tests a seeded one).
///
/// - **Mixed round** (`focus` nil): up to `groupsPerMixedRound` groups, two questions each, chosen
///   at random but weighted by need (`EarTrainingTally.need`): a pair of sounds the learner
///   often mixes up, or has not heard yet, comes more often than one they always hear apart.
///   The questions take turns between the groups, so one contrast never comes twice in a row.
/// - **Focus round** (`focus` a group id): every question from that group. Each pair comes once
///   before any comes again, never twice in a row, and a pair that comes again is read from its
///   other side, so both of its words are heard.
/// - In both, half the questions read the `a` word and half the `b` word (one more of either
///   when the count is odd), and the two words are shown in a random order, so neither the
///   side nor the place gives the answer away. A word is in at most one question of a round
///   while the content allows it (a word can belong to two groups).
public enum EarTrainingRound {
    /// Questions in a round.
    public static let questionCount = 10
    /// Groups in a mixed round: two questions each.
    public static let groupsPerMixedRound = 5

    public static func make<G: RandomNumberGenerator>(
        content: EarTrainingContent,
        tally: EarTrainingTally,
        focus: String? = nil,
        count: Int = EarTrainingRound.questionCount,
        using rng: inout G
    ) -> [EarTrainingQuestion] {
        guard count > 0 else {
            return []
        }
        let groups: [EarTrainingGroup]
        if let focus = focus {
            guard let group = content.group(id: focus) else {
                return []
            }
            groups = [group]
        } else {
            groups = weightedSample(
                content.groups,
                count: min(groupsPerMixedRound, content.groups.count),
                weight: { tally.need(groupID: $0.id) },
                using: &rng
            )
        }
        guard !groups.isEmpty else {
            return []
        }

        // As even as possible; the extra questions go to the groups picked first (the neediest
        // groups are the likeliest to be picked first).
        let base = count / groups.count
        let extra = count % groups.count
        var usedWords = Set<String>()
        var perGroup: [[Int]] = []
        for (index, group) in groups.enumerated() {
            let share = base + (index < extra ? 1 : 0)
            perGroup.append(pickPairs(in: group, count: share, avoiding: &usedWords, using: &rng))
        }

        // Turns between the groups: the first question of each group, then the second of each …
        var slots: [(group: EarTrainingGroup, pairIndex: Int)] = []
        let longest = perGroup.map(\.count).max() ?? 0
        for turn in 0..<longest {
            for (index, picks) in perGroup.enumerated() where turn < picks.count {
                slots.append((groups[index], picks[turn]))
            }
        }

        let sides = assignSides(to: slots.map { "\($0.group.id)#\($0.pairIndex)" }, using: &rng)
        return zip(slots, sides).map { slot, side in
            let order: [EarTrainingSide] = Bool.random(using: &rng) ? [.a, .b] : [.b, .a]
            return EarTrainingQuestion(
                groupID: slot.group.id,
                pairIndex: slot.pairIndex,
                pair: slot.group.pairs[slot.pairIndex],
                answerSide: side,
                shownOrder: order
            )
        }
    }

    /// `count` pair indices of `group`: every pair once, in a random order, before any comes
    /// again, and never the same pair twice in a row. In each pass, pairs with a word already in
    /// this round (`usedWords`, from other groups or the pass before) come last.
    static func pickPairs<G: RandomNumberGenerator>(
        in group: EarTrainingGroup,
        count: Int,
        avoiding usedWords: inout Set<String>,
        using rng: inout G
    ) -> [Int] {
        guard !group.pairs.isEmpty else {
            return []
        }
        var result: [Int] = []
        while result.count < count {
            let shuffled = Array(group.pairs.indices).shuffled(using: &rng)
            let fresh = shuffled.filter { !isUsed(group.pairs[$0], usedWords) }
            let stale = shuffled.filter { isUsed(group.pairs[$0], usedWords) }
            var order = fresh + stale
            if order.count > 1, order.first == result.last {
                order.append(order.removeFirst())
            }
            for index in order where result.count < count {
                result.append(index)
                usedWords.insert(EarTrainingWord.key(group.pairs[index].a.word))
                usedWords.insert(EarTrainingWord.key(group.pairs[index].b.word))
            }
        }
        return result
    }

    private static func isUsed(_ pair: EarTrainingPair, _ usedWords: Set<String>) -> Bool {
        return usedWords.contains(EarTrainingWord.key(pair.a.word))
            || usedWords.contains(EarTrainingWord.key(pair.b.word))
    }

    /// The side read aloud for each slot (`keys` name the pair of each slot). Half the slots get
    /// `.a` and half `.b`; for an odd count the extra side is random. A pair that comes more than
    /// once alternates its sides, so both of its words are heard.
    static func assignSides<G: RandomNumberGenerator>(
        to keys: [String],
        using rng: inout G
    ) -> [EarTrainingSide] {
        var need: [EarTrainingSide: Int] = [.a: keys.count / 2, .b: keys.count / 2]
        if keys.count % 2 == 1 {
            need[Bool.random(using: &rng) ? .a : .b, default: 0] += 1
        }
        var sides = [EarTrainingSide?](repeating: nil, count: keys.count)
        var slotsByKey: [String: [Int]] = [:]
        var keyOrder: [String] = []
        for (slot, key) in keys.enumerated() {
            if slotsByKey[key] == nil {
                keyOrder.append(key)
            }
            slotsByKey[key, default: []].append(slot)
        }

        // Repeated pairs first: each starts on the side needed more, then alternates.
        for key in keyOrder {
            guard let slots = slotsByKey[key], slots.count > 1 else {
                continue
            }
            let needA = need[.a] ?? 0
            let needB = need[.b] ?? 0
            var side: EarTrainingSide = needA == needB
                ? (Bool.random(using: &rng) ? .a : .b)
                : (needA > needB ? .a : .b)
            for slot in slots {
                if (need[side] ?? 0) == 0 {
                    side = side.other
                }
                sides[slot] = side
                need[side, default: 0] -= 1
                side = side.other
            }
        }

        // The other slots share what is left, in a random order.
        var pool: [EarTrainingSide] = Array(repeating: .a, count: max(0, need[.a] ?? 0))
            + Array(repeating: .b, count: max(0, need[.b] ?? 0))
        pool.shuffle(using: &rng)
        for slot in sides.indices where sides[slot] == nil {
            sides[slot] = pool.popLast() ?? (Bool.random(using: &rng) ? .a : .b)
        }
        return sides.map { $0 ?? .a }
    }

    /// Weighted random sample without replacement (Efraimidis and Spirakis 2006): each item gets
    /// the key u^(1/weight) for a uniform u in (0, 1); the largest keys win, in key order.
    static func weightedSample<T, G: RandomNumberGenerator>(
        _ items: [T],
        count: Int,
        weight: (T) -> Double,
        using rng: inout G
    ) -> [T] {
        let keyed = items.map { item -> (key: Double, item: T) in
            let w = max(weight(item), 0.0001)
            let u = Double.random(in: Double.ulpOfOne..<1, using: &rng)
            return (pow(u, 1 / w), item)
        }
        return keyed.sorted { $0.key > $1.key }.prefix(max(0, count)).map(\.item)
    }
}
