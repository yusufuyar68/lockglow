import Foundation
import CoreModels

/// Revalidates cached widget speech against current sources. Always returns the source lemma,
/// never the request text. Nil sensitivity retains WidgetWord.isSensitive's existing meaning.
public enum WidgetSpeechRequest {
    public static func resolve(
        _ request: String,
        words: [WidgetWord],
        quizPlan: WidgetQuizPlan? = nil
    ) -> String? {
        guard !request.isEmpty,
              request == request.trimmingCharacters(in: .whitespacesAndNewlines),
              request.rangeOfCharacter(from: .newlines) == nil else {
            return nil
        }
        if let word = words.first(where: { !$0.isSensitive && $0.lemma == request }) {
            return word.lemma
        }
        // The quiz's public reader rejects legacy/future plans and structurally unusable items.
        return WidgetQuizRotation.questions(of: quizPlan).first(where: { $0.lemma == request })?.lemma
    }
}
