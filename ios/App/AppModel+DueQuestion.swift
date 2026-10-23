import Foundation
import CoreModels
import Learning

/// What the card of a due word asks in "Tekrar" (`AppModel.dueQuestion`).
enum DueQuestion: Equatable {
    /// The fill-in-the-blank question, without the confusable partners not settled yet.
    case cloze(CardDetail.Quiz)
    /// "Dinle ve seç" (ListenQuestionView).
    case listen(ListenQuestion)
    /// "İngilizcesini yaz" (TypeQuestionView).
    case typing(TypeQuestion)
    /// "İngilizcesini hatırla" (the recall screen).
    case recall

    var kind: QuestionKind {
        switch self {
        case .cloze:
            return .cloze
        case .listen:
            return .listen
        case .typing:
            return .typing
        case .recall:
            return .recall
        }
    }
}

// "Dinle ve seç" and "İngilizcesini yaz" in "Tekrar" (ReviewView; docs/tasarim/ogrenme_ilkeleri.md
// 2.4, "Dinle ve seç, Yaz").
extension AppModel {
    /// The question of a due word, by `ReviewPlanner.questionKind`: boxes 2–3 take turns between
    /// the fill-in-the-blank question and "Dinle ve seç" or "İngilizcesini yaz". `canListen`: the
    /// phone can read the word aloud now (`ListenAvailability`: sound on, VoiceOver off).
    ///
    /// The question stays the same while the word is on screen: it is kept until the word is
    /// answered (its `reviews`, box or state change), so a later redraw never swaps the card under
    /// the learner, not even when the sound is turned down after the word was heard. `canListen`
    /// counts only when a word's question is chosen.
    func dueQuestion(for word: WidgetWord, canListen: Bool) -> DueQuestion {
        let stamp = DueQuestionStamp(progress[word.id])
        if let kept = AppModel.dueQuestions[word.id], kept.stamp == stamp {
            return kept.question
        }
        let question = makeDueQuestion(for: word, canListen: canListen)
        if AppModel.dueQuestions.count >= AppModel.dueQuestionsKept {
            AppModel.dueQuestions.removeAll()
        }
        AppModel.dueQuestions[word.id] = (stamp, question)
        return question
    }

    /// "Dinle ve seç" for `word` (`ReviewPlanner.listenQuestion`): options among every loaded
    /// card, its confusable partners first once they are settled (`unsettledConfusables`).
    func listenQuestion(for word: WidgetWord) -> ListenQuestion? {
        return ReviewPlanner.listenQuestion(
            for: word,
            attempt: progress[word.id]?.reviews ?? 0,
            candidates: words,
            excludedIDs: unsettledConfusables(of: word)
        )
    }

    /// "İngilizcesini yaz" for `word` (`ReviewPlanner.typeQuestion`), compared with every loaded
    /// card's headword so that another word is not taken for a spelling mistake.
    func typeQuestion(for word: WidgetWord) -> TypeQuestion? {
        return ReviewPlanner.typeQuestion(
            for: word,
            candidates: words,
            exampleTranslation: detail(for: word)?.examples.first?.tr
        )
    }

    private func makeDueQuestion(for word: WidgetWord, canListen: Bool) -> DueQuestion {
        let current = progress[word.id]
        let cloze = clozeQuiz(for: word)
        // Only boxes 2–3 ask the new kinds. Their options look at every card, so a kind is built
        // only when its turn comes; one that cannot be built is left out and the rule asked again.
        let mixed = current.map { $0.state == .learning && ReviewPlanner.mixedQuestionBoxes.contains($0.box) } ?? false
        var listenPossible = mixed && canListen
        var typingPossible = mixed
        while true {
            let kind = ReviewPlanner.questionKind(
                for: current,
                hasCloze: cloze != nil,
                canListen: listenPossible,
                canType: typingPossible
            )
            switch kind {
            case .cloze:
                return cloze.map { DueQuestion.cloze($0) } ?? .recall
            case .listen:
                if let question = listenQuestion(for: word) {
                    return .listen(question)
                }
                listenPossible = false
            case .typing:
                if let question = typeQuestion(for: word) {
                    return .typing(question)
                }
                typingPossible = false
            case .recall:
                return .recall
            }
        }
    }

    /// Questions chosen for the cards on screen, by word id. A handful at a time; emptied when it
    /// grows past `dueQuestionsKept` (answered words are never asked again with the same stamp).
    private static var dueQuestions: [Int: (stamp: DueQuestionStamp, question: DueQuestion)] = [:]
    private static let dueQuestionsKept = 200
}

/// The parts of a word's progress that change with an answer or a "Biliyorum": a kept question is
/// used only while they stay the same.
private struct DueQuestionStamp: Equatable {
    let reviews: Int
    let box: Int
    let state: LearningState?

    init(_ progress: WordProgress?) {
        reviews = progress?.reviews ?? 0
        box = progress?.box ?? 0
        state = progress?.state
    }
}
