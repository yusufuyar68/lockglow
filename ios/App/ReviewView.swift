import SwiftUI
import CoreModels
import Learning

/// "Tekrar": a short round. Due words come first, each asked with its card's fill-in-the-blank
/// question (`QuizCardView`); when nothing is due the tab offers the next new words (up to the
/// daily goal) as flashcards. Front of a flashcard: the English word with the phosphor band. Tap:
/// the Turkish meaning first (large), then the short definition, the example and the Dikkat box.
/// A flashcard is answered with one of four grades (Bilemedim, Zor, Bildim, Kolay), each showing
/// when the word comes back. During a round the tab bar is hidden, the round has its own header
/// with "Bitir", and the answers sit in an opaque bar at the bottom (at accessibility sizes they
/// scroll with the card). A round ends with a word-by-word summary; with nothing left for today
/// the tab says when the next review is due.
struct ReviewView: View {
    /// Switches to "Ayarlar" (the shortcut to the daily goal on the done screen).
    var openSettings: () -> Void = {}

    @EnvironmentObject private var model: AppModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The running round; nil while the start screen or the summary is shown.
    @State private var session: ReviewSession?
    @State private var index = 0
    @State private var isRevealed = false
    /// The flashcard runs past the bottom of its scroll view ("Devamı ↓").
    @State private var cardHasMore = false
    /// Answers of the running round, in order.
    @State private var answers: [RoundAnswer] = []
    /// Answers of the round that just ended: the summary stays until "Tamam".
    @State private var summary: [RoundAnswer]?

    private var isInRound: Bool {
        return session != nil
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.bg)
                .navigationTitle(session == nil && summary != nil ? "Güzel iş!" : "Tekrar")
                .navigationBarTitleDisplayMode(.large)
                // A round has its own header with "Bitir"; the tab bar would only invite leaving
                // half way, and the answers belong where the thumb is (README point 9).
                .toolbar(isInRound ? .hidden : .visible, for: .navigationBar)
                .toolbar(isInRound ? .hidden : .visible, for: .tabBar)
        }
        // Borderless controls are ink, never the system blue (rule 2).
        .tint(Theme.ink)
    }

    @ViewBuilder
    private var content: some View {
        if let session = session, session.words.indices.contains(index) {
            roundScreen(session: session, word: session.words[index])
        } else if let summary = summary {
            summaryScreen(summary)
        } else {
            startScreen
        }
    }

    // MARK: Round

    private func roundScreen(session: ReviewSession, word: WidgetWord) -> some View {
        let detail = model.detail(for: word)
        let quiz = ReviewView.quiz(in: session, detail: detail)
        return VStack(spacing: 8) {
            roundHeader(session: session, isQuiz: quiz != nil)
            if let quiz = quiz {
                QuizCardView(
                    word: word,
                    quiz: quiz,
                    layout: .scrolling,
                    mistakes: detail?.mistakes ?? [],
                    optionMeanings: optionMeanings(for: quiz, word: word),
                    returnTimes: quizReturnTimes(for: word)
                ) { outcome in
                    answer(ReviewView.grade(for: outcome), word: word)
                }
                .id(word.id)
            } else {
                flashcardRound(word: word, detail: detail)
            }
        }
    }

    /// A word that was already studied is tested with its fill-in-the-blank question (recall); a
    /// new word, or a due word whose card has no usable question, is shown as a flashcard.
    private static func quiz(in session: ReviewSession, detail: CardDetail?) -> CardDetail.Quiz? {
        guard session.kind == .due, let quiz = detail?.quiz, !quiz.distractors.isEmpty else {
            return nil
        }
        return quiz
    }

    /// Mockup `.rv .top`: the mode, "Kart 3 / 10", "Bitir" (glass: the control layer, rule 6)
    /// and the progress bar.
    private func roundHeader(session: ReviewSession, isQuiz: Bool) -> some View {
        let total = session.words.count
        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                if !dynamicTypeSize.isAccessibilitySize {
                    modeChip(kind: session.kind, isQuiz: isQuiz)
                }
                Spacer(minLength: 0)
                Text("Kart \(index + 1) / \(total)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.ink2)
                    .lineLimit(1)
                Button {
                    finishRound()
                } label: {
                    Text("Bitir")
                        .font(.body.weight(.semibold))
                        // With the style's own padding the capsule reaches the 44 pt target.
                        .frame(minHeight: 30)
                }
                .glassControl()
            }
            .frame(minHeight: 52)
            RoundProgressBar(done: index, total: total)
        }
        .padding(.horizontal, 16)
    }

    private func modeChip(kind: ReviewKind, isQuiz: Bool) -> some View {
        let title: String
        let symbol: String
        if kind == .new {
            title = "Yeni kelime"
            symbol = "sparkles"
        } else {
            title = isQuiz ? "Tekrar sorusu" : "Tekrar kartı"
            symbol = "arrow.triangle.2.circlepath"
        }
        return Label(title, systemImage: symbol)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.ink2)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.surface2, in: Capsule())
    }

    /// The card fills the space between the header and the answers, with the content centered;
    /// it scrolls on its own when the revealed side is taller (iPhone SE, large text), with a
    /// "Devamı ↓" cue until its end is reached, and the answers below stay visible and tappable.
    /// At accessibility sizes the revealed card's answers scroll with it instead, one per row
    /// (rule 5): a fixed bar of grades would leave almost no room for the card.
    private func flashcardRound(word: WidgetWord, detail: CardDetail?) -> some View {
        let answersInline = isRevealed && dynamicTypeSize.isAccessibilitySize
        return GeometryReader { proxy in
            let viewportHeight = proxy.size.height
            ScrollView {
                VStack(spacing: 16) {
                    flashcard(word: word, detail: detail, minHeight: answersInline ? 0 : max(0, viewportHeight - 16))
                    if answersInline {
                        gradeAnswers(word: word, column: true)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)
                // Mockup markOverflow(): more below while the content's end is past the visible
                // area (the front is exactly as tall as the area, so it never counts).
                .onGeometryChange(for: Bool.self) { geometry in
                    geometry.frame(in: .named("reviewCard")).maxY - viewportHeight > 4
                } action: { hasMore in
                    cardHasMore = hasMore
                }
            }
            .coordinateSpace(.named("reviewCard"))
            .scrollBounceBehavior(.basedOnSize)
        }
        // Mockup `.wcard.scrolls.more`: a cue that more of the card waits below. Above the
        // answers' bar, never on it; visual only (VoiceOver reads on by itself).
        .overlay(alignment: .bottom) {
            if isRevealed && cardHasMore {
                Text("Devamı ↓")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Theme.surface2, in: Capsule())
                    .padding(.bottom, 8)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        // Every card starts at the top.
        .id(word.id)
        // Opaque (rule 6): the answers never sit on glass.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !answersInline {
                flashcardActions(word: word)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity)
                    .background(Theme.bg)
            }
        }
    }

    @ViewBuilder
    private func flashcard(word: WidgetWord, detail: CardDetail?, minHeight: CGFloat) -> some View {
        if isRevealed {
            cardBack(word: word, detail: detail)
                .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .top)
                .cardSurface(cornerRadius: Theme.Radius.wordCard)
                // Not combined into one element: the speaker buttons stay reachable on their own.
                .accessibilityElement(children: .contain)
        } else {
            Button {
                reveal()
            } label: {
                cardFront(word: word)
                    .frame(maxWidth: .infinity, minHeight: minHeight)
                    .cardSurface(cornerRadius: Theme.Radius.wordCard)
                    .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.wordCard, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(word.lemma)
            // Between the label and the hint: the word is English, the hint keeps the Turkish voice.
            .englishVoice()
            .accessibilityHint("Anlamını göstermek için çift dokun")
            // On top of the card, not inside it: a button inside the reveal button's label
            // would also reveal the card.
            .overlay(alignment: .topTrailing) {
                ReviewSpeakerButton(text: word.lemma, accessibilityName: "Kelimeyi dinle")
                    .padding(10)
            }
        }
    }

    /// Mockup `.front`: the word large and centered with the band, its pronunciation, part of
    /// speech and level, and a hint.
    private func cardFront(word: WidgetWord) -> some View {
        VStack(spacing: 12) {
            WordHeadline(lemma: word.lemma, size: 46, maxSize: 60)
            wordMeta(word, alignment: .center)
            VStack(spacing: 6) {
                Image(systemName: "hand.tap")
                    .font(.title3)
                    .accessibilityHidden(true)
                Text("Anlamını görmek için dokun")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Theme.ink2)
            .padding(.top, 14)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
        .padding(.vertical, 36)
    }

    /// Reading order for an A2 learner (mockup `cardInner`): the word, the Turkish meaning (large,
    /// no box), the simple English definition, the example with its translation, one typical
    /// mistake.
    private func cardBack(word: WidgetWord, detail: CardDetail?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            WordHeadline(lemma: word.lemma, size: 40, maxSize: 56)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    metaItems(word)
                    Spacer(minLength: 8)
                    CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle")
                }
                VStack(alignment: .leading, spacing: 8) {
                    wordMeta(word, alignment: .leading)
                    CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle")
                }
            }
            if let gloss = word.glossTR {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: gloss)
                        .meaningStyle()
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Türkçesi: " + gloss)
                    if let alternatives = detail?.glossAlternatives, !alternatives.isEmpty {
                        Text(verbatim: "Ayrıca: " + alternatives.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            Text(verbatim: word.defShort)
                .definitionStyle()
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .englishVoice()
            exampleBlock(word: word, translation: detail?.examples.first?.tr)
            if let mistake = detail?.mistakes.first {
                MistakeBox(mistake: mistake)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 20)
    }

    /// IPA, part of speech and level on one line, or stacked when they do not fit.
    private func wordMeta(_ word: WidgetWord, alignment: HorizontalAlignment) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                metaItems(word)
            }
            VStack(alignment: alignment, spacing: 6) {
                metaItems(word)
            }
        }
    }

    @ViewBuilder
    private func metaItems(_ word: WidgetWord) -> some View {
        if let ipa = word.ipaUS {
            Text(verbatim: ipa)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
        }
        Text(verbatim: CardPartOfSpeech.turkish(word.pos))
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.ink2)
        LevelBadge(code: word.level)
    }

    /// Mockup `.exblock`: "Örnek" with a speaker, the sentence with the learned word marked
    /// (rule 1), its Turkish.
    private func exampleBlock(word: WidgetWord, translation: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("Örnek")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                ReviewSpeakerButton(text: word.exampleEN, accessibilityName: "Cümleyi dinle")
                    // The circle lines up with the card's text edge; the target overhangs.
                    .padding(.trailing, -5)
            }
            // The 44 pt target reaches past the row instead of making it taller.
            .padding(.vertical, -6)
            Text(ExampleMark.attributed(word.exampleEN, lemma: word.lemma, colorScheme: colorScheme))
                .exampleStyle()
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .englishVoice()
            if let translation = translation {
                Text(verbatim: translation)
                    .exampleTranslationStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 10)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.line)
                .frame(height: 1)
        }
    }

    /// The bottom bar: "Anlamı göster", then the grades (at accessibility sizes the revealed
    /// card's grades scroll with it instead, see `flashcardRound`).
    @ViewBuilder
    private func flashcardActions(word: WidgetWord) -> some View {
        if isRevealed {
            gradeAnswers(word: word, column: false)
        } else {
            Button("Anlamı göster") {
                reveal()
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
        }
    }

    /// The question and the four answers: in the bar a 2 x 2 grid; with `column` (accessibility
    /// sizes, under the card) one full-width answer per row, where "Bilemedim" keeps to one line.
    private func gradeAnswers(word: WidgetWord, column: Bool) -> some View {
        VStack(spacing: 8) {
            Text("Bu kelimeyi ne kadar bildin?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if column {
                gradeColumn(word: word)
            } else {
                gradeGrid(word: word)
            }
        }
    }

    /// The four answers stacked, worst to best (accessibility sizes): half an iPhone SE's width
    /// would break "Bilemedim" in the middle of the word.
    private func gradeColumn(word: WidgetWord) -> some View {
        let now = Date()
        return VStack(spacing: 8) {
            gradeButton(.again, word: word, now: now)
                .fixedSize(horizontal: false, vertical: true)
            gradeButton(.hard, word: word, now: now)
                .fixedSize(horizontal: false, vertical: true)
            gradeButton(.good, word: word, now: now)
                .fixedSize(horizontal: false, vertical: true)
            gradeButton(.easy, word: word, now: now)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Four answers in two rows of two (mockup `.grades`) in the bottom bar: four across would
    /// not fit an iPhone SE at larger text sizes (at accessibility sizes `gradeColumn` under the
    /// card). Reading order is worst to best; "Bildim" is the one filled button.
    /// Each says when the word comes back, from the same schedule the answer will write (README
    /// point 8): for a new word "10 dakika sonra", "12 saat sonra", "yarın", "2 gün sonra".
    private func gradeGrid(word: WidgetWord) -> some View {
        let now = Date()
        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                gradeButton(.again, word: word, now: now)
                gradeButton(.hard, word: word, now: now)
            }
            .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                gradeButton(.good, word: word, now: now)
                gradeButton(.easy, word: word, now: now)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func gradeButton(_ grade: ReviewGrade, word: WidgetWord, now: Date) -> some View {
        let info = GradeInfo(grade)
        let when = model.dueDate(ifAnswering: grade, for: word, now: now)
            .map { ReviewView.returnText(until: $0, from: now) }
        let isDefault = grade == .good
        return Button {
            answer(grade, word: word)
        } label: {
            GradeLabel(info: info, when: when, isDefault: isDefault)
        }
        .buttonStyle(GradeButtonStyle(isDefault: isDefault))
        .accessibilityLabel(info.title)
        // The time is hidden at accessibility sizes; VoiceOver always hears it.
        .accessibilityHint(when.map { "Kelime \($0) yeniden gelir" } ?? "")
    }

    // MARK: Quiz

    /// Meanings of the options that are headwords of other cards ("lend" → "ödünç vermek").
    private func optionMeanings(for quiz: CardDetail.Quiz, word: WidgetWord) -> [String: String] {
        var meanings: [String: String] = [:]
        for option in quiz.options(seed: word.id) where option != quiz.answer {
            if let meaning = model.lookup(lemma: option) {
                meanings[option] = meaning
            }
        }
        return meanings
    }

    /// When the word comes back after each quiz outcome, from the schedule.
    private func quizReturnTimes(for word: WidgetWord) -> [QuizOutcome: String] {
        let now = Date()
        var times: [QuizOutcome: String] = [:]
        for outcome in [QuizOutcome.wrong, .hard, .right, .easy] {
            if let due = model.dueDate(ifAnswering: ReviewView.grade(for: outcome), for: word, now: now) {
                times[outcome] = ReviewView.returnText(until: due, from: now)
            }
        }
        return times
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

    // MARK: Round flow

    private func reveal() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            isRevealed = true
        }
    }

    private func answer(_ grade: ReviewGrade, word: WidgetWord) {
        let updated = model.recordReview(word, grade: grade)
        answers.append(RoundAnswer(word: word, grade: grade, dueAt: updated.dueAt))
        isRevealed = false
        // The next card measures itself again.
        cardHasMore = false
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
        cardHasMore = false
        answers = []
        summary = nil
    }

    /// Ends the round (all cards done, or "Bitir"): the widget queue is rebuilt from the new
    /// progress, and the summary follows when anything was answered.
    private func finishRound() {
        summary = answers.isEmpty ? nil : answers
        session = nil
        index = 0
        isRevealed = false
        answers = []
        model.finishReviewSession()
    }

    // MARK: Summary

    /// Mockup `reviewSummary`: word by word, the answer given and when the word comes back.
    private func summaryScreen(_ answers: [RoundAnswer]) -> some View {
        let now = Date()
        let known = answers.filter { $0.grade != .again }.count
        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(answers.count) kelime çalıştın, \(known) tanesini bildin.")
                    .font(.body)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Kelimeler ne zaman dönecek?")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.bottom, 6)
                    ForEach(Array(answers.enumerated()), id: \.offset) { offset, answer in
                        if offset > 0 {
                            Rectangle()
                                .fill(Theme.line)
                                .frame(height: 1)
                        }
                        SummaryRow(
                            answer: answer,
                            when: answer.dueAt.map { ReviewView.returnText(until: $0, from: now) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .flatCard(cornerRadius: Theme.Radius.card)
                Text("\"Zor\" da bilinmiş sayılır. Zamanı gelen kelime Tekrar'da seni bekler.")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
                Button("Tamam") {
                    summary = nil
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 32)
        }
        .scrollBounceBehavior(.basedOnSize)
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
                VStack(spacing: 14) {
                    if let offer = offer {
                        offerCard(offer)
                        todayLine(withKnown: true)
                            .padding(.horizontal, 6)
                    } else {
                        doneContent
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    /// Mockup `.hero`. Due words: how many wait. New words: the ring of today's goal (only here,
    /// README "Tekrar").
    private func offerCard(_ offer: ReviewSession) -> some View {
        let isDue = offer.kind == .due
        return VStack(spacing: 12) {
            if isDue {
                CountBadge(count: offer.totalCount)
            } else {
                GoalRing(done: model.newWordsStudiedToday(), goal: model.dailyNewWords)
            }
            Text(isDue
                 ? "\(offer.totalCount) kelime tekrar bekliyor"
                 : "Bugünün yeni kelimeleri: \(offer.totalCount)")
                .font(.title.bold())
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(isDue
                 ? "Önce öğrendiğin kelimeleri pekiştirelim."
                 : "Her kelimeye bak, anlamını gör, sonra ne kadar bildiğini seç.")
                .font(.callout)
                .foregroundStyle(Theme.ink2)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                startRound(offer)
            } label: {
                Text("Başla (\(offer.words.count) kart)")
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            .padding(.top, 6)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
    }

    /// Mockup `reviewDone`: nothing due and today's goal reached. Today's counts, when the next
    /// review comes, the reminder, the Lock Screen, more new words for whoever wants them, and
    /// the way to the daily goal.
    private var doneContent: some View {
        let now = Date()
        let next = model.nextReviewDate(after: now)
        let extra = model.nextReviewSession(extraNew: true)
        return VStack(spacing: 14) {
            VStack(spacing: 12) {
                DoneMark()
                Text("Harikasın, bugünlük tamam!")
                    .font(.title.bold())
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text("Şimdilik tekrar edecek kelime kalmadı. Zamanı gelen kelimeler burada seni bekleyecek.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                todayLine(withKnown: false)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity)
            .cardSurface(cornerRadius: Theme.Radius.wordCard)
            VStack(alignment: .leading, spacing: 12) {
                if let next = next {
                    NoteRow(symbol: "clock", text: "Sıradaki tekrar: " + ReviewView.dayAndTime(next, now: now))
                }
                NoteRow(
                    symbol: "bell",
                    text: model.reminderEnabled
                        ? "Hatırlatma: " + ReviewView.clockTime(minuteOfDay: model.reminderMinuteOfDay)
                        : "Hatırlatma kapalı."
                )
                // Only when a Lockglow widget is on the Lock Screen (last health check).
                if model.hasLockScreenWidget {
                    NoteRow(symbol: "lock", text: "Kilitli ekranın yeni kelimeleri göstermeye devam ediyor.")
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .flatCard(cornerRadius: Theme.Radius.card)
            if let extra = extra {
                Button {
                    startRound(extra)
                } label: {
                    Label("\(extra.words.count) yeni kelime daha öğren", systemImage: "sparkles")
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 54, tonal: true))
            }
            // The short way to the goal (mockup "goto-goal"): smaller, centered, chevron after.
            Button(action: openSettings) {
                HStack(spacing: 4) {
                    Text("Günlük hedefi değiştir")
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
        }
    }

    /// Mockup `.t-sub` "Bugün: 3 yeni kelime, 12 tekrar." (start screen: also the known words).
    private func todayLine(withKnown: Bool) -> some View {
        var line = "Bugün: \(model.newWordsStudiedToday()) yeni kelime, \(model.reviewsDoneToday()) tekrar."
        if withKnown {
            line += " Bildiğin kelime: \(model.progressCounts().known)."
        }
        return Text(verbatim: line)
            .font(.subheadline)
            .foregroundStyle(Theme.ink2)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Text

    /// When a word comes back, in words (README "Tekrar"): "10 dakika sonra", "12 saat sonra",
    /// "yarın", "2 gün sonra", "1 ay sonra". Under a day it is counted in hours; after that in
    /// calendar days, so a word due tomorrow evening is "yarın".
    private static func returnText(until due: Date, from now: Date, calendar: Calendar = .current) -> String {
        let seconds = max(0, due.timeIntervalSince(now))
        let minutes = Int((seconds / 60).rounded())
        if minutes < 1 {
            return "şimdi"
        }
        if minutes < 60 {
            return "\(minutes) dakika sonra"
        }
        let hours = Int((seconds / 3600).rounded())
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: due)
        ).day ?? Int((seconds / 86_400).rounded())
        if hours < 24 || days < 1 {
            return "\(hours) saat sonra"
        }
        if days == 1 {
            return "yarın"
        }
        if days < 30 {
            return "\(days) gün sonra"
        }
        return "\(days / 30) ay sonra"
    }

    /// "bugün 21:40", "yarın 09:15", otherwise "24 Ekim 09:00" (no Turkish suffix after the
    /// time, README point 13).
    private static func dayAndTime(_ date: Date, now: Date, calendar: Calendar = .current) -> String {
        let time = clockFormatter.string(from: date)
        if calendar.isDate(date, inSameDayAs: now) {
            return "bugün " + time
        }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now), calendar.isDate(date, inSameDayAs: tomorrow) {
            return "yarın " + time
        }
        return dayFormatter.string(from: date) + " " + time
    }

    /// "20:00" for minutes after midnight.
    private static func clockTime(minuteOfDay: Int) -> String {
        return String(format: "%02d:%02d", minuteOfDay / 60, minuteOfDay % 60)
    }

    private static let clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
}

// MARK: - Pieces

/// One answer of a round, for the summary.
private struct RoundAnswer {
    let word: WidgetWord
    let grade: ReviewGrade
    /// When the word comes back (`WordProgress.dueAt` right after the answer).
    let dueAt: Date?
}

/// Title and SF Symbol of an answer, worst to best.
private struct GradeInfo {
    let title: String
    let symbol: String

    init(_ grade: ReviewGrade) {
        switch grade {
        case .again:
            title = "Bilemedim"
            symbol = "xmark"
        case .hard:
            title = "Zor"
            symbol = "tortoise"
        case .good:
            title = "Bildim"
            symbol = "checkmark"
        case .easy:
            title = "Kolay"
            symbol = "hare"
        }
    }
}

/// The English word with the phosphor band (rule 1): one line at `size`; a long phrase that does
/// not fit drops to a smaller size first, then shrinks with `englishWordStyle`'s scale factor.
/// VoiceOver reads it with an English voice.
private struct WordHeadline: View {
    let lemma: String
    let size: CGFloat
    let maxSize: CGFloat

    var body: some View {
        ViewThatFits(in: .horizontal) {
            word(size: size, maxSize: maxSize)
            word(size: size * 0.7, maxSize: maxSize * 0.7)
        }
        .accessibilityAddTraits(.isHeader)
        .englishVoice()
    }

    private func word(size: CGFloat, maxSize: CGFloat) -> some View {
        Text(verbatim: lemma)
            .englishWordStyle(size: size, maxSize: maxSize)
            .phosphorBand()
    }
}

/// Mockup `.prog`: a 6 pt `surface3` track filled with `tint` (ink, never yellow).
private struct RoundProgressBar: View {
    let done: Int
    let total: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let fraction = total > 0 ? min(1, max(0, CGFloat(done) / CGFloat(total))) : 0
        Capsule()
            .fill(Theme.surface3)
            .frame(height: 6)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Theme.tint)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: fraction)
            .accessibilityElement()
            .accessibilityLabel("Tur ilerlemesi")
            .accessibilityValue("\(done) / \(total)")
    }
}

/// The text of an answer button (mockup `.grade`): icon, grade and when the word comes back. The
/// icon goes at the largest text sizes, the time at accessibility sizes (it stays in the
/// VoiceOver hint).
private struct GradeLabel: View {
    let info: GradeInfo
    let when: String?
    let isDefault: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 10) {
            if dynamicTypeSize < .xxxLarge {
                Image(systemName: info.symbol)
                    .font(.title3.weight(.semibold))
                    .frame(width: 24)
                    .foregroundStyle(secondary)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: info.title)
                    .font(.body.weight(.semibold))
                if let when = when, !dynamicTypeSize.isAccessibilitySize {
                    Text(verbatim: when)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(secondary)
                }
            }
            .multilineTextAlignment(.leading)
        }
    }

    private var secondary: Color {
        return isDefault ? Theme.onPrimary.opacity(0.92) : Theme.ink2
    }
}

/// Answer button (mockup `.grade`): a 60 pt rounded tile in `surface2`; the default answer is
/// the screen's filled button (`primary`, glowing at night). Opaque, never glass (rule 6).
private struct GradeButtonStyle: ButtonStyle {
    let isDefault: Bool

    func makeBody(configuration: Configuration) -> some View {
        GradeButtonBody(configuration: configuration, isDefault: isDefault)
    }
}

private struct GradeButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let isDefault: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous)
        configuration.label
            .foregroundStyle(isDefault ? Theme.onPrimary : Theme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: .infinity, alignment: .leading)
            .background {
                shape
                    .fill(isDefault ? Theme.primary : Theme.surface2)
                    .shadow(color: isDefault && colorScheme == .dark ? Theme.primaryGlow : .clear, radius: 10)
            }
            .contentShape(shape)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// How many due words wait (mockup `.count-badge`): a number in a thin ring, no color.
private struct CountBadge: View {
    let count: Int
    @ScaledMetric(relativeTo: .title) private var diameter: CGFloat = 96

    var body: some View {
        let size = min(diameter, 124)
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(size: size * 0.35, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text("kelime")
                .font(.system(size: size * 0.125, weight: .medium))
                .foregroundStyle(Theme.ink2)
        }
        .padding(10)
        .frame(width: size, height: size)
        .overlay {
            Circle()
                .strokeBorder(Theme.lineStrong, lineWidth: 2)
        }
        // The title under it says the same number.
        .accessibilityHidden(true)
    }
}

/// Today's new-word goal (mockup `.pring`): a `surface3` track and a `tint` arc (never yellow).
private struct GoalRing: View {
    let done: Int
    let goal: Int
    @ScaledMetric(relativeTo: .title) private var diameter: CGFloat = 132

    var body: some View {
        let size = min(diameter, 172)
        let lineWidth = size / 12
        let fraction = goal > 0 ? min(1, CGFloat(done) / CGFloat(goal)) : 0
        ZStack {
            Circle()
                .inset(by: lineWidth / 2)
                .stroke(Theme.surface3, lineWidth: lineWidth)
            if fraction > 0 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 0, to: fraction)
                    .stroke(Theme.tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            VStack(spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(done)")
                        .foregroundStyle(Theme.ink)
                    Text("/\(goal)")
                        .foregroundStyle(Theme.ink3)
                }
                .font(.system(size: size * 0.24, weight: .bold))
                .monospacedDigit()
                Text("bugünkü hedef")
                    .font(.system(size: size * 0.1, weight: .medium))
                    .foregroundStyle(Theme.ink2)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(lineWidth * 1.5)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Bugünkü hedef: \(done) / \(goal) yeni kelime")
    }
}

/// The done screen's check on a phosphor stroke (mockup `.bandcheck`): by day the check sits on
/// the highlighter, at night the band is a glowing line under it, so the check never stands on
/// yellow.
private struct DoneMark: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Capsule()
                    .fill(Theme.bandGlow)
                    .frame(width: 116, height: 22)
                    .blur(radius: 8)
                    .offset(y: 24)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Theme.bandDark)
                    .frame(width: 116, height: 14)
                    .offset(y: 23)
            } else {
                PhosphorBandShape(slant: 10)
                    .fill(Theme.bandLight)
                    .frame(width: 116, height: 48)
                    .offset(y: 4)
            }
            Image(systemName: "checkmark")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(Theme.ink)
        }
        .frame(width: 132, height: 84)
        .accessibilityHidden(true)
    }
}

/// A line of the done screen (mockup `.lock-note`): an icon in a `surface2` circle and a sentence.
private struct NoteRow: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.ink)
                .frame(width: 36, height: 36)
                .background(Theme.surface2, in: Circle())
                .accessibilityHidden(true)
            Text(verbatim: text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}

/// A word of the round summary (mockup `.sumlist .si`): the word and its meaning, the answer
/// given and when the word comes back. Stacked at accessibility sizes.
private struct SummaryRow: View {
    let answer: RoundAnswer
    let when: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let info = GradeInfo(answer.grade)
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let rowLayout = isLarge
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 10))
        rowLayout {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: answer.word.lemma)
                    .font(.system(.body, design: .serif).weight(.bold))
                    .foregroundStyle(Theme.ink)
                    // Only the word: the meaning under it keeps the Turkish voice.
                    .englishVoice()
                if let gloss = answer.word.glossTR {
                    Text(verbatim: gloss)
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: isLarge ? .leading : .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: info.symbol)
                        .font(.caption.weight(.bold))
                    Text(verbatim: info.title)
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 10)
                .frame(minHeight: 28)
                .background(Theme.surface2, in: Capsule())
                if let when = when {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2.weight(.semibold))
                        Text(verbatim: when)
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.ink2)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }
}

private extension View {
    /// A flat card (mockup `.card`): `surface` with a `line` border and no shadow, so it sits
    /// below the raised word card in the hierarchy.
    func flatCard(cornerRadius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return background(Theme.surface, in: shape)
            .overlay {
                shape.strokeBorder(Theme.line, lineWidth: 1)
            }
    }
}
