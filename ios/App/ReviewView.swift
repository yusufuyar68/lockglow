import SwiftUI
import CoreModels
import Learning

/// "Tekrar": a short flashcard round. Due words come first; when nothing is due the tab offers
/// the next new words (up to the daily goal). Front of a card: the English word. Tap: the Turkish
/// meaning first (large), then the short definition and the example. A card is answered with one
/// of four grades: Bilemedim, Zor, Bildim, Kolay.
struct ReviewView: View {
    @EnvironmentObject private var model: AppModel

    /// The running round; nil while the start screen is shown.
    @State private var session: ReviewSession?
    @State private var index = 0
    @State private var isRevealed = false
    @State private var answeredCount = 0
    /// Answers that were not "Bilemedim" (hard, good and easy all count as known).
    @State private var knownCount = 0
    /// Result of the round that just ended, shown on the start screen.
    @State private var lastRound: RoundResult?

    private struct RoundResult {
        let answered: Int
        let known: Int
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Tekrar")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var content: some View {
        if let session = session, session.words.indices.contains(index) {
            cardScreen(session: session, word: session.words[index])
        } else {
            startScreen
        }
    }

    // MARK: Round

    private func cardScreen(session: ReviewSession, word: WidgetWord) -> some View {
        VStack(spacing: 16) {
            ProgressView(value: Double(index), total: Double(session.words.count))
            Text("\(index + 1) / \(session.words.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            // A word that was already studied is tested with its fill-in-the-blank question
            // (recall); a new word is shown as a flashcard first (learning).
            if session.kind == .due, let quiz = model.detail(for: word)?.quiz, !quiz.distractors.isEmpty {
                ScrollView {
                    QuizCardView(word: word, quiz: quiz) { outcome in
                        answer(ReviewView.grade(for: outcome), word: word)
                    }
                    .id(word.id)
                }
                .scrollBounceBehavior(.basedOnSize)
            } else {
                // The card scrolls on its own when the revealed side is taller than the space left
                // (iPhone SE), so the answer buttons below always stay visible and tappable.
                GeometryReader { proxy in
                    ScrollView {
                        Button {
                            isRevealed = true
                        } label: {
                            flashcard(for: word, minHeight: proxy.size.height)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint(isRevealed ? "" : "Anlamını göstermek için çift dokun")
                        // On top of the card, not inside it: a button inside the reveal button's
                        // label would also reveal the card.
                        .overlay(alignment: .topTrailing) {
                            SpeakButton(text: word.lemma, accessibilityName: "Kelimeyi dinle")
                                .padding(8)
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
                answerArea(word: word)
            }
        }
        .padding(16)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Bitir") {
                    finishRound()
                }
            }
        }
    }

    /// At least `minHeight` tall (the visible scroll area) with the content centered; taller when
    /// the revealed side needs more room, and the scroll view then scrolls.
    private func flashcard(for word: WidgetWord, minHeight: CGFloat) -> some View {
        let detail = model.detail(for: word)
        return VStack(spacing: 12) {
            Text(word.lemma)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            if let ipa = word.ipaUS {
                Text(ipa)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            Text("\(word.pos) · \(word.level)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            if isRevealed {
                Divider()
                    .padding(.vertical, 4)
                if let gloss = word.glossTR {
                    Text(gloss)
                        .font(.title.weight(.semibold))
                        .multilineTextAlignment(.center)
                }
                Text(word.defShort)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text(word.exampleEN)
                    .font(.body)
                    .italic()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                if let exampleTR = detail?.examples.first?.tr {
                    Text(exampleTR)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                if let mistake = detail?.mistakes.first {
                    MistakeBox(mistake: mistake)
                }
            } else {
                Text("Anlamını görmek için dokun")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: minHeight)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    /// Four answers in two rows of two: four across would not fit an iPhone SE at larger text sizes.
    /// Reading order is worst to best; "Bildim" is the highlighted default.
    @ViewBuilder
    private func answerArea(word: WidgetWord) -> some View {
        if isRevealed {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    gradeButton("Bilemedim", symbol: "xmark", grade: .again, word: word)
                    gradeButton("Zor", symbol: "tortoise", grade: .hard, word: word)
                }
                HStack(spacing: 12) {
                    gradeButton("Bildim", symbol: "checkmark", grade: .good, word: word, isDefault: true)
                    gradeButton("Kolay", symbol: "hare", grade: .easy, word: word)
                }
            }
        } else {
            Button {
                isRevealed = true
            } label: {
                Text("Anlamı göster")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    @ViewBuilder
    private func gradeButton(
        _ title: String,
        symbol: String,
        grade: ReviewGrade,
        word: WidgetWord,
        isDefault: Bool = false
    ) -> some View {
        if isDefault {
            Button {
                answer(grade, word: word)
            } label: {
                Label(title, systemImage: symbol)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityHint(ReviewView.hint(for: grade))
        } else {
            Button {
                answer(grade, word: word)
            } label: {
                Label(title, systemImage: symbol)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .accessibilityHint(ReviewView.hint(for: grade))
        }
    }

    /// What the answer does to the schedule, read out by VoiceOver.
    private static func hint(for grade: ReviewGrade) -> String {
        switch grade {
        case .again:
            return "Kelime 10 dakika sonra yeniden tekrar gelir"
        case .hard:
            return "Kelime aynı kutuda kalır, daha erken tekrar gelir"
        case .good:
            return "Kelime bir kutu ilerler"
        case .easy:
            return "Kelime iki kutu ilerler, daha geç tekrar gelir"
        }
    }

    private static func grade(for outcome: QuizOutcome) -> ReviewGrade {
        switch outcome {
        case .wrong:
            return .again
        case .hard:
            return .hard
        case .right:
            return .good
        case .easy:
            return .easy
        }
    }

    private func answer(_ grade: ReviewGrade, word: WidgetWord) {
        model.recordReview(word, grade: grade)
        answeredCount += 1
        if grade != .again {
            knownCount += 1
        }
        isRevealed = false
        if let session = session, index + 1 < session.words.count {
            index += 1
        } else {
            finishRound()
        }
    }

    private func startRound(_ next: ReviewSession) {
        session = next
        index = 0
        isRevealed = false
        answeredCount = 0
        knownCount = 0
        lastRound = nil
    }

    /// Ends the round (all cards done, or "Bitir"): the widget queue is rebuilt from the new progress.
    private func finishRound() {
        lastRound = answeredCount > 0 ? RoundResult(answered: answeredCount, known: knownCount) : nil
        session = nil
        index = 0
        isRevealed = false
        answeredCount = 0
        knownCount = 0
        model.finishReviewSession()
    }

    // MARK: Start screen

    @ViewBuilder
    private var startScreen: some View {
        if model.words.isEmpty {
            if model.contentSource == .loading {
                ProgressView()
            } else {
                ContentUnavailableView(
                    "İçerik bulunamadı",
                    systemImage: "tray",
                    description: Text("content.sqlite ve seed_words.json pakete eklenmemiş.")
                )
            }
        } else {
            let offer = model.nextReviewSession()
            ScrollView {
                VStack(spacing: 20) {
                    if let round = lastRound {
                        roundSummary(round)
                    }
                    if let offer = offer {
                        offerCard(offer)
                    } else {
                        doneCard
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func roundSummary(_ round: RoundResult) -> some View {
        VStack(spacing: 4) {
            Text("Güzel iş!")
                .font(.headline)
            Text("\(round.answered) kelime çalıştın, \(round.known) tanesini bildin.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func offerCard(_ offer: ReviewSession) -> some View {
        VStack(spacing: 12) {
            Image(systemName: offer.kind == .due ? "arrow.triangle.2.circlepath" : "sparkles")
                .font(.largeTitle)
                .accessibilityHidden(true)
            Text(offer.kind == .due
                 ? "\(offer.totalCount) kelime tekrar bekliyor"
                 : "Bugünün yeni kelimeleri: \(offer.totalCount)")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text(offer.kind == .due
                 ? "Önce öğrendiğin kelimeleri pekiştirelim."
                 : "Her kelimeye bak, anlamını gör, sonra bildin mi işaretle.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                startRound(offer)
            } label: {
                Text("Başla (\(offer.words.count) kart)")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)
        }
    }

    private var doneCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .accessibilityHidden(true)
            Text("Harikasın, bugünlük tamam!")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Şimdilik tekrar edecek kelime kalmadı. Zamanı gelen kelimeler burada seni bekleyecek.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let extra = model.nextReviewSession(extraNew: true) {
                Button {
                    startRound(extra)
                } label: {
                    Text("\(extra.words.count) yeni kelime daha öğren")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.top, 8)
            }
        }
    }
}
