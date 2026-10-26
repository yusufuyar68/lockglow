import Foundation
import CoreModels
import Learning
#if canImport(FoundationModels)
import FoundationModels
#endif

// "Kendi cümleni yaz": the on-device language model's suggestion (Apple Intelligence, iOS 26).
// The sentence goes to the model on the phone only (FoundationModels runs on the device); it is
// never sent anywhere and never stored. Without the model (an older iPhone or iOS, Apple
// Intelligence off, the model still downloading, an older SDK) there is simply no suggestion:
// the fixed rules (`OwnSentenceCheck`) always run. Every error, a refusal, a too long context, an
// unsupported language or a cancellation gives no suggestion either, silently. App target only:
// not in the Linux check's `APP_LOGIC_FILES` (FoundationModels is Apple-only); its pure part,
// `OwnSentenceAdvice`, is tested there.

/// The page's way to the model, on every iOS version.
enum OwnSentenceAssistant {
    /// The model can answer now.
    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return OwnSentenceAI.isAvailable
        }
        #endif
        return false
    }

    /// The model's suggestion on `sentence`, written with `word`; nil without the model, on any
    /// error, or after `OwnSentenceAI.timeout`.
    static func advice(sentence: String, word: WidgetWord) async -> OwnSentenceAdvice? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await OwnSentenceAI.advice(sentence: sentence, word: word)
        }
        #endif
        return nil
    }
}

#if canImport(FoundationModels)

/// What the model is asked to judge. The cases match `OwnSentenceAdvice.Kind`.
@available(iOS 26.0, *)
@Generable
enum OwnSentenceAIKind {
    case fine
    case wordMeaning
    case grammar
    case wordForm
    case spelling
    case unnatural
}

/// The model's answer, generated in this shape (guided generation). Plain strings, empty when
/// there is nothing to say: `OwnSentenceAdvice` drops empty and unusable ones.
@available(iOS 26.0, *)
@Generable
struct OwnSentenceAIResult {
    @Guide(description: "The main problem of the learner's sentence. fine: the target word is used with the given meaning and the sentence is grammatical. wordMeaning: the target word is used with a different meaning. grammar: a grammar mistake. wordForm: the target word needs another form, such as a plural or a past tense. spelling: a spelling mistake. unnatural: correct, but a native speaker would say it differently.")
    var kind: OwnSentenceAIKind

    @Guide(description: "The learner's sentence with only its mistakes fixed, in English. Keep the learner's words and idea. It must contain the target word. Write an empty string when kind is fine, unnatural or wordMeaning, or when only capital letters or punctuation would change.")
    var correctedSentence: String

    @Guide(description: "One short, more natural English sentence with the same idea and the target word. Write an empty string when the sentence is already natural.")
    var naturalAlternative: String
}

@available(iOS 26.0, *)
enum OwnSentenceAI {
    /// The page never waits longer than this for a suggestion.
    static let timeout: UInt64 = 15_000_000_000

    static let instructions = """
        You are a patient English teacher for a Turkish learner at level A2. \
        The learner wrote one English sentence with a target word. \
        Check only: whether the target word is used with the given meaning, grammar, the form of the target word, and spelling. \
        Do not judge whether the content is true, polite or interesting. \
        Keep the learner's idea and words, and always keep the target word. Never add new content, facts or extra sentences. \
        Ignore a missing capital letter or a missing full stop. \
        Write only in English. Keep every sentence short and simple.
        """

    static var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available:
            return true
        default:
            return false
        }
    }

    /// The suggestion, or nil: no model, any error, or no answer within `timeout`. The model
    /// request is cancelled after a timeout and when the caller's task is cancelled (the page
    /// closes, or a newer check starts), so requests do not pile up on the model.
    static func advice(sentence: String, word: WidgetWord) async -> OwnSentenceAdvice? {
        guard isAvailable else {
            return nil
        }
        let text = OwnSentenceAI.prompt(sentence: sentence, word: word)
        let lemma = word.lemma
        // Unstructured: the caller's cancellation reaches it through `onCancel` below.
        let request = Task<OwnSentenceAdvice?, Never> {
            await OwnSentenceAI.ask(prompt: text, original: sentence, lemma: lemma)
        }
        return await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<OwnSentenceAdvice?, Never>) in
                let once = ResumeOnce()
                let timer = Task {
                    try? await Task.sleep(nanoseconds: OwnSentenceAI.timeout)
                    if once.claim() {
                        request.cancel()
                        continuation.resume(returning: nil)
                    }
                }
                Task {
                    // A cancelled request ends with nil (`ask`); the timer covers a model that
                    // ignores the cancellation.
                    let advice = await request.value
                    timer.cancel()
                    if once.claim() {
                        continuation.resume(returning: advice)
                    }
                }
            }
        } onCancel: {
            request.cancel()
        }
    }

    /// The word, its part of speech, the card's Turkish meaning and English definition (so the
    /// model knows which sense is meant), then the sentence.
    static func prompt(sentence: String, word: WidgetWord) -> String {
        var lines = [
            "Target word: \(word.lemma)",
            "Part of speech: \(word.pos)",
        ]
        if let meaning = word.glossTR, !meaning.isEmpty {
            lines.append("Meaning in Turkish: \(meaning)")
        }
        if !word.defShort.isEmpty {
            lines.append("Meaning in English: \(word.defShort)")
        }
        lines.append("Learner's sentence: \(OwnSentenceCheck.limited(sentence))")
        return lines.joined(separator: "\n")
    }

    private static func ask(prompt: String, original: String, lemma: String) async -> OwnSentenceAdvice? {
        do {
            let session = LanguageModelSession(instructions: OwnSentenceAI.instructions)
            let response = try await session.respond(to: prompt, generating: OwnSentenceAIResult.self)
            if Task.isCancelled {
                return nil
            }
            let result = response.content
            return OwnSentenceAdvice(
                kind: kind(of: result.kind),
                correctedSentence: result.correctedSentence,
                naturalAlternative: result.naturalAlternative,
                original: original,
                lemma: lemma
            )
        } catch {
            // Guardrails, the context window, an unsupported language, a cancellation, a model
            // that is not ready: no suggestion, no message (the rules' panel is enough).
            return nil
        }
    }

    private static func kind(of kind: OwnSentenceAIKind) -> OwnSentenceAdvice.Kind {
        switch kind {
        case .fine:
            return .fine
        case .wordMeaning:
            return .wordMeaning
        case .grammar:
            return .grammar
        case .wordForm:
            return .wordForm
        case .spelling:
            return .spelling
        case .unnatural:
            return .unnatural
        }
    }
}

/// Lets the first of the request and the timer resume the continuation, never both.
private final class ResumeOnce: @unchecked Sendable {
    private let lock = NSLock()
    private var isClaimed = false

    func claim() -> Bool {
        lock.lock()
        defer {
            lock.unlock()
        }
        if isClaimed {
            return false
        }
        isClaimed = true
        return true
    }
}

#endif
