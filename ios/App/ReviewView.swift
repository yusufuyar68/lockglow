import SwiftUI
import CoreModels
import Learning

/// "Tekrar": a short round. Due words come first, each asked with its card's fill-in-the-blank
/// question (`QuizCardView`); when nothing is due the tab offers the next new words (up to the
/// daily goal) as flashcards. Front of a flashcard: the English word with the phosphor band, its
/// sound and a nudge to recall the meaning first (with an optional clue, the example sentence).
/// Tap: the Turkish meaning first (large), then the short definition, the example and the Dikkat
/// box. A flashcard is answered with one of four grades (Bilemedim, Zor, Bildim, Kolay), each
/// showing when the word comes back. During a round the tab bar is hidden, the round has its own
/// header ("Kart 3 / 10", the progress, "Bitir"), the card ends above an opaque answer bar and
/// scrolls inside itself (at accessibility sizes the answers scroll with the card). A round ends
/// with a word-by-word summary; with nothing left for today the tab lists the words met today and
/// says when the next review is due. No streaks, no scores.
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
    /// The front's clue (the example sentence) is shown.
    @State private var showsClue = false
    /// The card's text runs past the bottom of the card ("Devamı").
    @State private var cardHasMore = false
    /// Answers of the running round, in order.
    @State private var answers: [RoundAnswer] = []
    /// Answers of the round that just ended: the summary stays until "Tamam".
    @State private var summary: [RoundAnswer]?
    /// Counts flashcard answers: one light tick per answer, nothing else (no buzz for "Bilemedim").
    @State private var answerTick = 0
    /// New words studied in this tab today, for the done screen: "2026-10-22|12,45,78". AppModel
    /// only counts them (`newWordsStudiedToday`); the words themselves are kept here.
    @AppStorage("lockglow.reviewNewWordsToday") private var newWordsTodayLog = ""

    private var isInRound: Bool {
        return session != nil
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.bg)
                .navigationTitle(session == nil && summary != nil ? "Tur bitti" : "Tekrar")
                .navigationBarTitleDisplayMode(.large)
                // A round has its own header with "Bitir"; the tab bar would only invite leaving
                // half way, and the answers belong where the thumb is (README point 9).
                .toolbar(isInRound ? .hidden : .visible, for: .navigationBar)
                .toolbar(isInRound ? .hidden : .visible, for: .tabBar)
        }
        // Borderless controls are ink, never the system blue (rule 2).
        .tint(Theme.ink)
        .sensoryFeedback(.selection, trigger: answerTick)
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
            roundHeader(session: session)
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

    /// Only what the round needs: "Kart 3 / 10", the progress bar and "Bitir" (glass: the control
    /// layer, rule 6) on one line. At accessibility sizes the bar goes under the line.
    @ViewBuilder
    private func roundHeader(session: ReviewSession) -> some View {
        let total = session.words.count
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    cardCounter(total: total)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                    finishButton
                }
                RoundProgressBar(done: index, total: total)
            }
            .padding(.horizontal, 16)
        } else {
            HStack(spacing: 12) {
                cardCounter(total: total)
                    .fixedSize()
                RoundProgressBar(done: index, total: total)
                finishButton
            }
            .frame(minHeight: 52)
            .padding(.horizontal, 16)
        }
    }

    private func cardCounter(total: Int) -> some View {
        Text("Kart \(index + 1) / \(total)")
            .font(.subheadline.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(Theme.ink2)
            .lineLimit(1)
    }

    private var finishButton: some View {
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

    /// The card fills the space between the header and the bottom bar and ends above the bar.
    /// Its text scrolls inside it when it is taller (iPhone SE, large text); the card's bottom
    /// edge then fades out under "Devamı". At accessibility sizes the revealed card and its
    /// answers scroll together instead, one answer per row (rule 5): a fixed bar of four grades
    /// would leave almost no room for the card.
    private func flashcardRound(word: WidgetWord, detail: CardDetail?) -> some View {
        VStack(spacing: 0) {
            if isRevealed && dynamicTypeSize.isAccessibilitySize {
                flowingBack(word: word, detail: detail)
            } else {
                cardPanel(word: word, detail: detail)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                // Opaque (rule 6): the answers never sit on glass, and never on the card.
                flashcardActions(word: word)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity)
            }
        }
        // Every card starts at the top.
        .id(word.id)
    }

    /// The card with a fixed frame and its own scrolling (mockup `.wcard.scrolls`). The front is
    /// centered and reveals on a tap anywhere outside its buttons; the back starts at the top.
    private func cardPanel(word: WidgetWord, detail: CardDetail?) -> some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.wordCard, style: .continuous)
        let side = isRevealed
        return GeometryReader { proxy in
            let viewportHeight = proxy.size.height
            ScrollView {
                Group {
                    if side {
                        cardBack(word: word, detail: detail)
                            .frame(maxWidth: .infinity, minHeight: viewportHeight, alignment: .top)
                            // Not combined into one element: the speaker buttons stay reachable.
                            .accessibilityElement(children: .contain)
                    } else {
                        cardFront(word: word)
                            .frame(maxWidth: .infinity, minHeight: viewportHeight)
                            .contentShape(Rectangle())
                            // VoiceOver uses "Anlamı göster" in the bar; the card is not a button
                            // so that "Dinle" and "İpucu" inside it stay separate controls.
                            .onTapGesture {
                                reveal()
                            }
                    }
                }
                // Mockup markOverflow(): more below while the content's end is past the card.
                .onGeometryChange(for: Bool.self) { geometry in
                    geometry.frame(in: .named("reviewCard")).maxY - viewportHeight > 8
                } action: { hasMore in
                    // The side that is fading out during the reveal does not count.
                    if side == isRevealed {
                        cardHasMore = hasMore
                    }
                }
            }
            .coordinateSpace(.named("reviewCard"))
            .scrollBounceBehavior(.basedOnSize)
            // The back starts at its top, wherever the front was scrolled.
            .id(side)
        }
        // On the card's own bottom edge, over the faded-out end of the text: never on legible
        // text, never on the answers.
        .overlay(alignment: .bottom) {
            ZStack {
                if cardHasMore {
                    MoreBelowCue()
                        .transition(.opacity)
                }
            }
            // Only the cue fades; the card's text never moves with it.
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: cardHasMore)
        }
        .clipShape(shape)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
    }

    /// Accessibility sizes, revealed: the card at its natural height and the answers under it,
    /// in one scroll.
    private func flowingBack(word: WidgetWord, detail: CardDetail?) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                cardBack(word: word, detail: detail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardSurface(cornerRadius: Theme.Radius.wordCard)
                    .accessibilityElement(children: .contain)
                gradeAnswers(word: word, column: true)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    /// Mockup `.front`, for recall practice: the word large and centered with the band, "Dinle",
    /// and a quiet nudge to remember the meaning before turning the card. "İpucu" shows the
    /// example sentence (English only: its Turkish would give the answer away).
    private func cardFront(word: WidgetWord) -> some View {
        VStack(spacing: 14) {
            WordHeadline(lemma: word.lemma, size: 46, maxSize: 60)
            CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle")
            VStack(spacing: 10) {
                Text("Anlamını hatırlamaya çalış.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                clue(word: word)
            }
            .padding(.top, 14)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
    }

    @ViewBuilder
    private func clue(word: WidgetWord) -> some View {
        let sentence = word.exampleEN.trimmingCharacters(in: .whitespacesAndNewlines)
        if sentence.isEmpty {
            EmptyView()
        } else if showsClue {
            Text(ExampleMark.attributed(sentence, lemma: word.lemma, colorScheme: colorScheme))
                .exampleStyle()
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .englishVoice()
                .transition(.opacity)
        } else {
            Button {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    showsClue = true
                }
            } label: {
                Label("İpucu", systemImage: "lightbulb")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(ChipButtonStyle())
            .accessibilityHint("Kelimenin geçtiği bir cümleyi gösterir")
        }
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

    /// The bottom bar: "Anlamı göster" (the screen's one filled button), then the grades (at
    /// accessibility sizes the revealed card's grades scroll with it instead, see
    /// `flashcardRound`).
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
            // A quiz card has its own feedback (`QuizCardView`); only the flashcard ticks.
            answerTick += 1
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

    /// Turns the card: a short fade (none with Reduce Motion), no flip and no haptic.
    private func reveal() {
        cardHasMore = false
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            isRevealed = true
        }
    }

    private func answer(_ grade: ReviewGrade, word: WidgetWord) {
        // Same test as `AppModel.recordReview` uses to count a new word.
        let wasNew = (model.progress[word.id]?.state ?? .new) == .new
        let updated = model.recordReview(word, grade: grade)
        answers.append(RoundAnswer(word: word, grade: grade, dueAt: updated.dueAt, wasNew: wasNew))
        if wasNew {
            noteNewWordToday(word.id)
        }
        isRevealed = false
        showsClue = false
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
        showsClue = false
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
        showsClue = false
        cardHasMore = false
        answers = []
        model.finishReviewSession()
    }

    // MARK: Summary

    /// Mockup `reviewSummary`, calm: what was studied, word by word with its meaning, when each
    /// word comes back and when the next review is. No score, no streak; "Tamam" stays in reach.
    private func summaryScreen(_ answers: [RoundAnswer]) -> some View {
        let now = Date()
        let next = model.nextReviewDate(after: now)
        let hasHard = answers.contains { $0.grade == .hard }
        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(verbatim: ReviewView.summaryLine(answers))
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                if let next = next {
                    NoteRow(symbol: "clock", text: "Sıradaki tekrar: " + ReviewView.dayAndTime(next, now: now))
                        .padding(.horizontal, 4)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Bu turun kelimeleri")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.bottom, 6)
                    ForEach(Array(answers.enumerated()), id: \.offset) { offset, answer in
                        if offset > 0 {
                            RowDivider()
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
                Text(verbatim: (hasHard ? "\"Zor\" da bilinmiş sayılır. " : "")
                     + "İyi bildiğin kelime daha geç gelir. Zamanı gelince Tekrar'da seni bekler.")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button("Tamam") {
                summary = nil
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background(Theme.bg)
        }
    }

    /// "10 yeni kelimeyle tanıştın." / "8 kelimeyi tekrar ettin." / "5 kelime çalıştın."
    private static func summaryLine(_ answers: [RoundAnswer]) -> String {
        let count = answers.count
        let newCount = answers.filter { $0.wasNew }.count
        if newCount == count {
            return "\(count) yeni kelimeyle tanıştın."
        }
        if newCount == 0 {
            return "\(count) kelimeyi tekrar ettin."
        }
        return "\(count) kelime çalıştın."
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
                 : "Kelimeye bak, anlamını hatırlamaya çalış. Sonra ne kadar bildiğini seç.")
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

    /// Mockup `reviewDone`: nothing due and today's goal reached. A quiet check, today's counts,
    /// when the next review comes, the reminder, the Lock Screen, the words met today (a last
    /// look at each with its meaning), more new words for whoever wants them, and the way to the
    /// daily goal. No streak and no "come back tomorrow" pressure.
    private var doneContent: some View {
        let now = Date()
        let next = model.nextReviewDate(after: now)
        let extra = model.nextReviewSession(extraNew: true)
        let metToday = wordsMetToday(now: now)
        return VStack(spacing: 14) {
            VStack(spacing: 12) {
                DoneMark()
                Text("Bugünlük tamam")
                    .font(.title.bold())
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text("Şimdilik tekrar edecek kelime yok.")
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
            if !metToday.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Bugün tanıştığın kelimeler")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.bottom, 4)
                    ForEach(Array(metToday.enumerated()), id: \.element.id) { offset, word in
                        if offset > 0 {
                            RowDivider()
                        }
                        WordMeaningRow(word: word)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .flatCard(cornerRadius: Theme.Radius.card)
            }
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
    /// Counts only, and nothing at all before the first card of the day: a row of zeros reads as
    /// a score to catch up on.
    @ViewBuilder
    private func todayLine(withKnown: Bool) -> some View {
        if let line = todayText(withKnown: withKnown) {
            Text(verbatim: line)
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func todayText(withKnown: Bool) -> String? {
        let newToday = model.newWordsStudiedToday()
        let reviewsToday = model.reviewsDoneToday()
        var parts: [String] = []
        if newToday + reviewsToday > 0 {
            parts.append("Bugün: \(newToday) yeni kelime, \(reviewsToday) tekrar.")
        }
        if withKnown {
            let known = model.progressCounts().known
            if known > 0 {
                parts.append("Bildiğin kelime: \(known).")
            }
        }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    // MARK: Words met today

    /// The words studied for the first time in this tab today, in order. A word whose progress
    /// was reset since is left out.
    private func wordsMetToday(now: Date) -> [WidgetWord] {
        let ids = ReviewView.loggedIDs(newWordsTodayLog, on: ReviewView.dayKey(now))
        return ids.compactMap { id -> WidgetWord? in
            guard let state = model.progress[id]?.state, state != .new else {
                return nil
            }
            return model.word(id: id)
        }
    }

    private func noteNewWordToday(_ id: Int, now: Date = Date()) {
        let day = ReviewView.dayKey(now)
        var ids = ReviewView.loggedIDs(newWordsTodayLog, on: day)
        guard !ids.contains(id) else {
            return
        }
        ids.append(id)
        newWordsTodayLog = day + "|" + ids.map { String($0) }.joined(separator: ",")
    }

    /// The ids logged for `day`; none when the log is from another day.
    private static func loggedIDs(_ log: String, on day: String) -> [Int] {
        let parts = log.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2, String(parts[0]) == day else {
            return []
        }
        return parts[1].split(separator: ",").compactMap { Int($0) }
    }

    /// "2026-10-22" in the local calendar.
    private static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
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
    /// The word had never been reviewed before this answer.
    let wasNew: Bool
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

/// "Devamı" on the card's bottom edge (mockup `.wcard.scrolls.more`): the text fades into the
/// card's `surface` and the cue sits on the faded part, so it never covers a legible line. Not a
/// capsule, since it is not a control (rule 2); visual only, VoiceOver reads on by itself.
private struct MoreBelowCue: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("Devamı")
            Image(systemName: "chevron.down")
                .imageScale(.small)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Theme.ink2)
        .padding(.top, 26)
        .padding(.bottom, 9)
        .frame(maxWidth: .infinity)
        .background {
            LinearGradient(
                stops: [
                    .init(color: Theme.surface.opacity(0), location: 0),
                    .init(color: Theme.surface, location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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
/// time is legible but secondary: regular weight, footnote, `ink2` (and a softer `onPrimary` on
/// the filled answer). The icon goes at the largest text sizes, the time at accessibility sizes
/// (it stays in the VoiceOver hint).
private struct GradeLabel: View {
    let info: GradeInfo
    let when: String?
    let isDefault: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 8) {
            if dynamicTypeSize < .xxxLarge {
                Image(systemName: info.symbol)
                    .font(.body.weight(.medium))
                    .frame(width: 22)
                    .foregroundStyle(secondary)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: info.title)
                    .font(.body.weight(.semibold))
                if let when = when, !dynamicTypeSize.isAccessibilitySize {
                    Text(verbatim: when)
                        .font(.footnote)
                        .monospacedDigit()
                        .foregroundStyle(secondary)
                }
            }
            .multilineTextAlignment(.leading)
        }
    }

    private var secondary: Color {
        return isDefault ? Theme.onPrimary.opacity(0.8) : Theme.ink2
    }
}

/// Answer button (mockup `.grade`): a 56 pt capsule in `surface2` (rule 2: what can be tapped is
/// a capsule); the default answer is the screen's filled button (`primary`, glowing at night).
/// Opaque, never glass (rule 6).
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
        let shape = Capsule()
        configuration.label
            .foregroundStyle(isDefault ? Theme.onPrimary : Theme.ink)
            // The icon sits at the round end's middle, where the curve leaves the most room; the
            // text keeps the half-width tile's room for "10 dakika sonra" on an iPhone SE.
            .padding(.leading, 16)
            .padding(.trailing, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 56, maxHeight: .infinity, alignment: .leading)
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
/// yellow. Still, no motion: the day is done, not won.
private struct DoneMark: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Capsule()
                    .fill(Theme.bandGlow)
                    .frame(width: 104, height: 20)
                    .blur(radius: 8)
                    .offset(y: 22)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Theme.bandDark)
                    .frame(width: 104, height: 12)
                    .offset(y: 21)
            } else {
                PhosphorBandShape(slant: 10)
                    .fill(Theme.bandLight)
                    .frame(width: 104, height: 42)
                    .offset(y: 4)
            }
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Theme.ink)
        }
        .frame(width: 120, height: 76)
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

/// A 1 pt `line` between the rows of a list card.
private struct RowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.line)
            .frame(height: 1)
    }
}

/// A word of the round summary (mockup `.sumlist .si`): the word and its meaning, when it comes
/// back and the answer given. The answer is plain text with its icon, not a capsule (rule 2:
/// capsules are for what can be tapped). Stacked at accessibility sizes.
private struct SummaryRow: View {
    let answer: RoundAnswer
    let when: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let info = GradeInfo(answer.grade)
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let rowLayout = isLarge
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
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
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: isLarge ? .leading : .trailing, spacing: 3) {
                if let when = when {
                    Text(verbatim: when)
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(Theme.ink)
                }
                HStack(spacing: 4) {
                    Image(systemName: info.symbol)
                        .font(.caption2.weight(.semibold))
                        .accessibilityHidden(true)
                    Text(verbatim: info.title)
                }
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }
}

/// A word met today on the done screen: the word and its meaning on one line, stacked when they
/// do not fit.
private struct WordMeaningRow: View {
    let word: WidgetWord

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                lemma
                Spacer(minLength: 8)
                meaning
                    .multilineTextAlignment(.trailing)
            }
            VStack(alignment: .leading, spacing: 2) {
                lemma
                meaning
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 9)
        .accessibilityElement(children: .combine)
    }

    private var lemma: some View {
        Text(verbatim: word.lemma)
            .font(.system(.body, design: .serif).weight(.bold))
            .foregroundStyle(Theme.ink)
            .englishVoice()
    }

    @ViewBuilder
    private var meaning: some View {
        if let gloss = word.glossTR {
            Text(verbatim: gloss)
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
        }
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
