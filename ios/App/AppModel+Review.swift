import Foundation
import CoreModels
import Learning

// "Tekrar" questions that need the model's progress (ReviewView).
extension AppModel {
    /// Wrong options a fill-in-the-blank question needs: with the answer, four options.
    static let clozeWrongOptionCount = 3

    /// The fill-in-the-blank question of a due word (boxes 1–3) without its confusable partners
    /// the user has not settled yet (`unsettledConfusables`): a partner that is new or still in
    /// box 1 is never an option, where the pair would only teach the mix-up (ogrenme_ilkeleri 2.4
    /// "Çeldirici kuralı"; content-pipeline/vocabpipe/validate.py). "Hatırla" follows the same
    /// rule (`introQuestion`). A distractor counts as the partner when it is the partner's
    /// headword (case and surrounding spaces ignored); another form of it ("lent") is not caught.
    /// Nil without a question, or when leaving the partners out leaves fewer than
    /// `clozeWrongOptionCount` distractors: the word is then asked with the recall screen.
    func clozeQuiz(for word: WidgetWord) -> CardDetail.Quiz? {
        guard let quiz = detail(for: word)?.quiz else {
            return nil
        }
        let partners = Set(unsettledConfusables(of: word).compactMap { self.word(id: $0) }.map { AppModel.optionKey($0.lemma) })
        if partners.isEmpty {
            return quiz
        }
        let kept = quiz.distractors.filter { !partners.contains(AppModel.optionKey($0)) }
        if kept.count == quiz.distractors.count {
            return quiz
        }
        guard kept.count >= AppModel.clozeWrongOptionCount else {
            return nil
        }
        return CardDetail.Quiz(cloze: quiz.cloze, answer: quiz.answer, distractors: kept)
    }

    /// An option as compared with a headword: trimmed and lowercased.
    private static func optionKey(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
