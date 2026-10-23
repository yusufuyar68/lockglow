import Foundation
import CoreModels
import Learning

// "Cümle kur" (SentencePracticeView): what the practice asks of the model. Practice only: it
// never calls `recordReview`, so no grade, box, due date or review-log line comes from it
// (`SentencePractice`). Compiled into the Linux check of the app's logic too
// (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// The practice count (`PracticeTally`) is kept on this phone under this UserDefaults key.
    nonisolated static let sentencePracticeTallyKey = "lockglow.sentencePracticeTally"

    /// Some word can be practiced now: one being learned or known that "Tekrar" will not ask soon,
    /// with a sentence to build or a pair to pick. Stops at the first such word, usually the
    /// first one; the cards it reads stay cached (`detail(for:)`). For "Biraz daha pratik".
    var hasSentencePractice: Bool {
        let ids = SentencePractice.wordIDs(progress: progress, now: Date())
        return ids.prefix(SentencePractice.maxScannedWords).contains { id in
            guard let word = word(id: id), let detail = detail(for: word) else {
                return false
            }
            return !SentencePractice.round(wordIDs: [id], seed: 0, size: 1) { _ in
                SentencePractice.Source(wordID: id, examples: detail.examples, collocations: detail.collocations)
            }.isEmpty
        }
    }

    /// A practice round: the example sentences of words being learned or known
    /// (`SentencePractice.round`). A new `seed` gives other words and sentences. Reads at most
    /// `SentencePractice.maxScannedWords` cards. Empty when no word can be used.
    func sentencePracticeRound(seed: Int, now: Date = Date()) -> [SentencePractice.Item] {
        let loaded = Set(words.map(\.id))
        let ids = SentencePractice.wordIDs(progress: progress, now: now).filter { loaded.contains($0) }
        return SentencePractice.round(wordIDs: ids, seed: seed) { id in
            guard let word = self.word(id: id), let detail = self.detail(for: word) else {
                return nil
            }
            return SentencePractice.Source(wordID: id, examples: detail.examples, collocations: detail.collocations)
        }
    }

    /// The practice count so far; empty when nothing was practiced or the record is unreadable.
    static func sentencePracticeTally() -> PracticeTally {
        guard let data = UserDefaults.standard.data(forKey: sentencePracticeTallyKey),
              let tally = try? JSONDecoder().decode(PracticeTally.self, from: data) else {
            return .empty
        }
        return tally
    }

    /// One more practice question answered, right or wrong (its second try is not counted again).
    static func countSentencePractice(_ count: Int = 1, now: Date = Date()) {
        let tally = sentencePracticeTally().adding(count, now: now)
        if let data = try? JSONEncoder().encode(tally) {
            UserDefaults.standard.set(data, forKey: sentencePracticeTallyKey)
        }
    }

    /// "İlerlemeyi sıfırla" forgets the practice count too.
    static func clearSentencePracticeTally() {
        UserDefaults.standard.removeObject(forKey: sentencePracticeTallyKey)
    }
}
