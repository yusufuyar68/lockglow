import Foundation
import CoreModels

/// A "Dinle ve seç" question (`ReviewPlanner.listenQuestion`): the word is read aloud, and the
/// learner picks what was heard from English words (docs/tasarim/ogrenme_ilkeleri.md 2.4,
/// "Dinle ve seç, Yaz").
public struct ListenQuestion: Equatable, Sendable {
    public let wordID: Int
    /// The headword: what is read aloud, and the right option.
    public let answer: String
    /// The answer and the wrong options, mixed.
    public let options: [String]
    /// The Turkish meaning of each wrong option, for "Senin seçtiğin: lend = ödünç vermek".
    public let meanings: [String: String]

    public init(wordID: Int, answer: String, options: [String], meanings: [String: String]) {
        self.wordID = wordID
        self.answer = answer
        self.options = options
        self.meanings = meanings
    }
}

extension ReviewPlanner {
    /// A wrong option that sounds this close to the answer (edits between the two IPA spellings)
    /// comes only when nothing else is left: "ship" against "sheep" tests the ear on one vowel,
    /// which is a pronunciation exercise of its own, not a review of the word.
    public static let listenCloseSound = 1

    /// The "Dinle ve seç" question of `word`, or nil when it has no pronunciation (`ipaUS`; a
    /// user's own word) or fewer than `minimumChoiceCount` options can be found. Wrong options:
    /// - first its confusable partners (`WidgetWord.confusableIDs`, borrow → lend), but never one
    ///   in `excludedIDs`: a partner the user has not settled yet (`unsettledConfusables`) would
    ///   only teach the mix-up (2.4 "Çeldirici kuralı");
    /// - then the cards that sound closest to it (fewest edits between the IPA spellings, ties
    ///   in a stable mixed order), those within `listenCloseSound` last;
    /// - never a word that sounds the same as the answer or another option (meet and meat: the
    ///   same IPA once stress and length marks are dropped), nor a card without IPA, whose sound
    ///   cannot be compared, nor another sense of the same headword.
    /// `attempt` (the word's `reviews`) puts the answer in another place each time.
    public static func listenQuestion(
        for word: WidgetWord,
        attempt: Int,
        candidates: [WidgetWord],
        excludedIDs: Set<Int> = []
    ) -> ListenQuestion? {
        let answer = word.lemma.trimmingCharacters(in: .whitespacesAndNewlines)
        let sound = soundKey(word.ipaUS)
        guard !answer.isEmpty, !sound.isEmpty else {
            return nil
        }
        var usedWords: Set<String> = [foldKey(answer)]
        var usedSounds: Set<String> = [sound]
        var wrong: [String] = []
        var meanings: [String: String] = [:]
        func take(_ candidate: WidgetWord) {
            let text = candidate.lemma.trimmingCharacters(in: .whitespacesAndNewlines)
            let candidateSound = soundKey(candidate.ipaUS)
            guard wrong.count < choiceCount - 1,
                  candidate.id != word.id,
                  !excludedIDs.contains(candidate.id),
                  !text.isEmpty,
                  !candidateSound.isEmpty,
                  !usedSounds.contains(candidateSound),
                  !usedWords.contains(foldKey(text)) else {
                return
            }
            usedWords.insert(foldKey(text))
            usedSounds.insert(candidateSound)
            wrong.append(text)
            if let gloss = candidate.glossTR?.trimmingCharacters(in: .whitespacesAndNewlines), !gloss.isEmpty {
                meanings[text] = gloss
            }
        }

        var byID: [Int: WidgetWord] = [:]
        for candidate in candidates where byID[candidate.id] == nil {
            byID[candidate.id] = candidate
        }
        for id in word.confusableIDs ?? [] {
            if let partner = byID[id] {
                take(partner)
            }
        }
        let target = Array(sound.unicodeScalars)
        let ranked = candidates
            .compactMap { candidate -> (word: WidgetWord, rank: Int, key: UInt64)? in
                let candidateSound = soundKey(candidate.ipaUS)
                guard candidate.id != word.id, !candidateSound.isEmpty else {
                    return nil
                }
                let distance = EditDistance.between(Array(candidateSound.unicodeScalars), target)
                let rank = distance <= listenCloseSound ? 10_000 + distance : distance
                return (candidate, rank, StableMix.key(word.id, String(candidate.id)))
            }
            .sorted { a, b in
                if a.rank != b.rank {
                    return a.rank < b.rank
                }
                return a.key != b.key ? a.key < b.key : a.word.id < b.word.id
            }
        for entry in ranked {
            if wrong.count == choiceCount - 1 {
                break
            }
            take(entry.word)
        }
        guard wrong.count + 1 >= minimumChoiceCount else {
            return nil
        }
        return ListenQuestion(
            wordID: word.id,
            answer: answer,
            options: mixedOptions([answer] + wrong, answer: answer, seed: word.id, attempt: attempt),
            meanings: meanings
        )
    }

    /// An IPA spelling as compared for sound: without the slashes or brackets around it, stress
    /// and length marks, syllable dots, spaces and parentheses ("/ˈbɔːrd/" and "/bɔrd/" are the
    /// same). Empty for nil.
    static func soundKey(_ ipa: String?) -> String {
        guard let ipa = ipa else {
            return ""
        }
        let dropped: Set<Unicode.Scalar> = ["/", "[", "]", "(", ")", "ˈ", "ˌ", "ː", "ˑ", ".", "‿", "-", "'"]
        var scalars = String.UnicodeScalarView()
        for scalar in ipa.precomposedStringWithCanonicalMapping.unicodeScalars
        where !dropped.contains(scalar) && !scalar.properties.isWhitespace {
            scalars.append(scalar)
        }
        return String(scalars)
    }
}

/// Edits between two sequences: insertions, deletions, substitutions and swaps of two neighbours
/// (optimal string alignment, the restricted Damerau-Levenshtein distance). Typing mistakes are
/// mostly one of these four.
enum EditDistance {
    static func between<T: Equatable>(_ a: [T], _ b: [T]) -> Int {
        if a.isEmpty {
            return b.count
        }
        if b.isEmpty {
            return a.count
        }
        // Three rows: the one before the previous one is needed for a swap.
        var older = [Int](repeating: 0, count: b.count + 1)
        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            current[0] = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                var best = min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
                if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                    best = min(best, older[j - 2] + 1)
                }
                current[j] = best
            }
            (older, previous, current) = (previous, current, older)
        }
        return previous[b.count]
    }
}
