import SwiftUI
import CoreModels

/// How a quiz question went, as reported by `QuizCardView.onContinue`. `ReviewView` turns it into
/// a `ReviewGrade` (this file is also compiled into the snapshot bundle, which does not link
/// Learning, so it cannot use that type itself).
enum QuizOutcome: Equatable {
    /// A wrong pick.
    case wrong
    /// A right pick that was hard ("Zordu").
    case hard
    /// A right pick ("Devam").
    case right
    /// A right pick that was easy ("Kolaydı").
    case easy
}

/// "Tekrar" question for a word that was already studied: the card's fill-in-the-blank sentence
/// and four options. After a tap the right option is marked "Doğru cevap" and a wrong pick
/// "Yanlış" (icons and words, never color alone); `onContinue` reports how it went. After a right
/// pick the learner can also say it was hard or easy, otherwise "Devam" is a plain right answer.
/// Give each word its own identity (`.id(word.id)`) so the pick resets between cards.
struct QuizCardView: View {
    let word: WidgetWord
    let quiz: CardDetail.Quiz
    let onContinue: (QuizOutcome) -> Void
    @State private var picked: String?

    /// `initialPick` is for snapshot tests: renders the answered state directly.
    init(word: WidgetWord, quiz: CardDetail.Quiz, initialPick: String? = nil, onContinue: @escaping (QuizOutcome) -> Void) {
        self.word = word
        self.quiz = quiz
        self.onContinue = onContinue
        _picked = State(initialValue: initialPick)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Boşluğa hangisi gelir?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            // After the answer: the whole sentence, which can then be heard (before, the speaker
            // would give the answer away).
            VStack(spacing: 4) {
                Text(picked == nil ? quiz.cloze : quiz.filledSentence)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                if picked != nil {
                    SpeakButton(text: quiz.filledSentence, accessibilityName: "Cümleyi dinle")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            VStack(spacing: 10) {
                ForEach(quiz.options(seed: word.id), id: \.self) { option in
                    optionButton(option)
                }
            }
            if let picked = picked {
                let isRight = picked == quiz.answer
                feedback(isRight: isRight)
                Button {
                    onContinue(isRight ? .right : .wrong)
                } label: {
                    Text("Devam")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                if isRight {
                    difficultyButtons
                }
            }
        }
    }

    /// Only after a right pick: the word comes back sooner ("Zordu") or later ("Kolaydı").
    private var difficultyButtons: some View {
        VStack(spacing: 8) {
            Text("Ya da bu soru nasıl geldi?")
                .font(.footnote)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Button {
                    onContinue(.hard)
                } label: {
                    Text("Zordu")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityHint("Kelime daha erken tekrar gelir")
                Button {
                    onContinue(.easy)
                } label: {
                    Text("Kolaydı")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityHint("Kelime daha geç tekrar gelir")
            }
        }
    }

    private func optionButton(_ option: String) -> some View {
        Button {
            if picked == nil {
                picked = option
            }
        } label: {
            HStack(spacing: 8) {
                Text(option)
                    .font(.body.weight(.medium))
                Spacer(minLength: 0)
                if let mark = mark(for: option) {
                    Label(mark.text, systemImage: mark.symbol)
                        .font(.footnote.weight(.semibold))
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(fill(for: option), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        // Not `.disabled`: that would dim the options exactly when the answer is shown.
        .allowsHitTesting(picked == nil)
    }

    private func mark(for option: String) -> (text: String, symbol: String)? {
        guard let picked = picked else {
            return nil
        }
        if option == quiz.answer {
            return ("Doğru cevap", "checkmark.circle.fill")
        }
        if option == picked {
            return ("Yanlış", "xmark.circle.fill")
        }
        return nil
    }

    private func fill(for option: String) -> Color {
        guard let picked = picked else {
            return Color.secondary.opacity(0.12)
        }
        if option == quiz.answer {
            return Color.green.opacity(0.25)
        }
        if option == picked {
            return Color.red.opacity(0.18)
        }
        return Color.secondary.opacity(0.08)
    }

    @ViewBuilder
    private func feedback(isRight: Bool) -> some View {
        VStack(spacing: 4) {
            if isRight {
                Label("Doğru!", systemImage: "checkmark.seal.fill")
                    .font(.headline)
            } else {
                Label("Doğrusu: " + quiz.answer, systemImage: "lightbulb")
                    .font(.headline)
            }
            if let gloss = word.glossTR {
                Text(word.lemma + " = " + gloss)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
    }
}
