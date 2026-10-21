import SwiftUI
import CoreModels
import Learning

/// "Tekrar": a short round. Due words come first, each asked with its card's fill-in-the-blank
/// question (`QuizCardView`); when nothing is due the tab offers the next new words (up to the
/// daily goal) as flashcards. Front of a flashcard: the English word with the phosphor band. Tap:
/// the Turkish meaning first (large), then the short definition, the example and the Dikkat box.
/// A flashcard is answered with one of four grades (Bilemedim, Zor, Bildim, Kolay), each showing
/// when the word comes back. During a round the tab bar is hidden, the round has its own header
/// with "Bitir", and the answers sit in an opaque bar at the bottom. A round ends with a
/// word-by-word summary; with nothing left for today the tab says when the next review is due.
struct ReviewView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The running round; nil while the start screen or the summary is shown.
    @State private var session: ReviewSession?
    @State private var index = 0
    @State private var isRevealed = false
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
                // half way, and the answers belong where the thumb is.
                .toolbar(isInRound ? .hidden : .visible, for: .navigationBar)
                .toolbar(isInRound ? .hidden : .visible, for: .tabBar)
        }
        // Borderless buttons (the speakers) are ink, never the system blue (rule 2).
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
        // A word that was already studied is tested with its fill-in-the-blank question
        // (recall); a new word is shown as a flashcard first (learning).
        var quiz: CardDetail.Quiz?
        if session.kind == .due, let candidate = detail?.quiz, !candidate.distractors.isEmpty {
            quiz = candidate
        }
        return VStack(spacing: 6) {
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

    /// Mode, "Kart 3 / 10", "Bitir" (glass: the control layer, rule 6) and the progress bar.
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
    /// it scrolls on its own when the revealed side is taller (iPhone SE, large text), so the
    /// answers below always stay visible and tappable.
    private func flashcardRound(word: WidgetWord, detail: CardDetail?) -> some View {
        GeometryReader { proxy in
            ScrollView {
                flashcard(word: word, detail: detail, minHeight: max(0, proxy.size.height - 20))
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        // Every card starts at the top.
        .id(word.id)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            flashcardActions(word: word)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background(Theme.bg)
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
            .accessibilityHint("Anlamını göstermek için çift dokun")
            // On top of the card, not inside it: a button inside the reveal button's label
            // would also reveal the card.
            .overlay(alignment: .topTrailing) {
                SpeakButton(text: word.lemma, accessibilityName: "Kelimeyi dinle")
                    .padding(10)
            }
        }
    }

    /// The word large and centered, its pronunciation, part of speech and level, and a hint.
    private func cardFront(word: WidgetWord) -> some View {
        VStack(spacing: 14) {
            WordHeadline(lemma: word.lemma, size: 46, maxSize: 60)
            wordMeta(word, alignment: .center)
            VStack(spacing: 6) {
                Image(systemName: "hand.tap")
                    .font(.title3)
                Text("Anlamını görmek için dokun")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Theme.ink2)
            .padding(.top, 14)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
        .padding(.vertical, 32)
    }

    /// Reading order for an A2 learner (README "Akış"): the word, the Turkish meaning (large, no
    /// box), the simple English definition, the example with its translation, one typical mistake.
    private func cardBack(word: WidgetWord, detail: CardDetail?) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            WordHeadline(lemma: word.lemma, size: 40, maxSize: 56)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    metaItems(word)
                    Spacer(minLength: 8)
                    ListenCapsule(text: word.lemma)
                }
                VStack(alignment: .leading, spacing: 8) {
                    wordMeta(word, alignment: .leading)
                    ListenCapsule(text: word.lemma)
                }
            }
            if let gloss = word.glossTR {
                VStack(alignment: .leading, spacing: 4) {
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
                .fixedSize(horizontal: false, vertical: true)
            exampleBlock(word: word, translation: detail?.examples.first?.tr)
            if let mistake = detail?.mistakes.first {
                MistakeBox(mistake: mistake)
            }
        }
        .padding(20)
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
        Text(verbatim: ReviewView.partOfSpeech(word.pos))
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.ink2)
        LevelBadge(code: word.level)
    }

    /// "Örnek" with a speaker, the sentence with the learned word marked (rule 1), its Turkish.
    private func exampleBlock(word: WidgetWord, translation: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("Örnek")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                SpeakButton(text: word.exampleEN, accessibilityName: "Cümleyi dinle")
                    .padding(.trailing, -10)
            }
            .padding(.vertical, -6)
            Text(ExampleMark.attributed(word.exampleEN, lemma: word.lemma, colorScheme: colorScheme))
                .exampleStyle()
                .fixedSize(horizontal: false, vertical: true)
            if let translation = translation {
                Text(verbatim: translation)
                    .exampleTranslationStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.line)
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private func flashcardActions(word: WidgetWord) -> some View {
        if isRevealed {
            VStack(spacing: 10) {
                Text("Bu kelimeyi ne kadar bildin?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                gradeGrid(word: word)
            }
        } else {
            Button("Anlamı göster") {
                reveal()
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
        }
    }

    /// Four answers in two rows of two: four across would not fit an iPhone SE at larger text
    /// sizes. Reading order is worst to best; "Bildim" is the one filled button. Each says when
    /// the word comes back, from the same schedule the answer will write (README point 8).
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

    /// Word by word: the answer given and when the word comes back.
    private func summaryScreen(_ answers: [RoundAnswer]) -> some View {
        let now = Date()
        let known = answers.filter { $0.grade != .again }.count
        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(answers.count) kelime çalıştın, \(known) tanesini bildin.")
                    .font(.body)
                    .foregroundStyle(Theme.ink2)
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
                VStack(spacing: 16) {
                    if let offer = offer {
                        offerCard(offer)
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

    /// Due words: how many wait. New words: the ring of today's goal (only here, README "Tekrar").
    private func offerCard(_ offer: ReviewSession) -> some View {
        let isDue = offer.kind == .due
        return VStack(spacing: 16) {
            if isDue {
                CountBadge(count: offer.totalCount)
            } else {
                GoalRing(done: model.newWordsStudiedToday(), goal: model.dailyNewWords)
            }
            VStack(spacing: 8) {
                Text(isDue
                     ? "\(offer.totalCount) kelime tekrar bekliyor"
                     : "Bugünün yeni kelimeleri: \(offer.totalCount)")
                    .font(.title.bold())
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(isDue
                     ? "Önce öğrendiğin kelimeleri pekiştirelim."
                     : "Her kelimeye bak, anlamını gör, sonra ne kadar bildiğini seç.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                startRound(offer)
            } label: {
                Text("Başla (\(offer.words.count) kart)")
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
    }

    /// Nothing due and today's goal reached: when the next review comes, the reminder, the Lock
    /// Screen, and more new words for whoever wants them.
    private var doneContent: some View {
        let now = Date()
        let next = model.nextReviewDate(after: now)
        let extra = model.nextReviewSession(extraNew: true)
        return VStack(spacing: 16) {
            VStack(spacing: 12) {
                DoneMark()
                Text("Harikasın, bugünlük tamam!")
                    .font(.title.bold())
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text("Şimdilik tekrar edecek kelime kalmadı. Zamanı gelen kelimeler burada seni bekleyecek.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
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
        }
    }

    // MARK: Text

    /// When a word comes back, in words (README "Tekrar"): "10 dakika sonra", "12 saat sonra",
    /// "yarın", "2 gün sonra", "1 ay sonra".
    fileprivate static func returnText(until due: Date, from now: Date, calendar: Calendar = .current) -> String {
        let seconds = due.timeIntervalSince(now)
        let minutes = Int((seconds / 60).rounded())
        if minutes < 1 {
            return "şimdi"
        }
        if minutes < 60 {
            return "\(minutes) dakika sonra"
        }
        let hours = Int((seconds / 3600).rounded())
        if hours < 24 {
            return "\(hours) saat sonra"
        }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: due)
        ).day ?? Int((seconds / 86_400).rounded())
        if days <= 1 {
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

    /// The part of speech in Turkish ("n" → "isim"); an unknown code is shown as it is.
    fileprivate static func partOfSpeech(_ code: String) -> String {
        switch code {
        case "n":
            return "isim"
        case "v":
            return "fiil"
        case "adj":
            return "sıfat"
        case "adv":
            return "zarf"
        case "phv":
            return "iki kelimeli fiil"
        case "phr":
            return "kalıp ifade"
        case "idm":
            return "deyim"
        case "det":
            return "belirleyici"
        default:
            return code
        }
    }
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
    }

    private func word(size: CGFloat, maxSize: CGFloat) -> some View {
        Text(verbatim: lemma)
            .englishWordStyle(size: size, maxSize: maxSize)
            .phosphorBand()
    }
}

/// "Dinle" (mockup `.pill-btn`): a labelled capsule that reads the word aloud, the same speaker
/// as `SpeakButton`; a second tap stops it.
private struct ListenCapsule: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let text: String

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            Label("Dinle", systemImage: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.subheadline.weight(.semibold))
                .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
                .lineLimit(1)
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
        .fixedSize()
        .accessibilityLabel(isSpeaking ? "Durdur" : "Kelimeyi dinle")
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

/// The text of an answer button: icon, grade and when the word comes back. Icons go at the
/// largest text sizes, the time at accessibility sizes (it stays in the VoiceOver hint).
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
/// the highlighter, at night the band is a glowing line under it.
private struct DoneMark: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Capsule()
                    .fill(Theme.bandGlow)
                    .frame(width: 116, height: 20)
                    .blur(radius: 8)
                    .offset(y: 24)
                PhosphorBandShape(slant: 8)
                    .fill(Theme.bandDark)
                    .frame(width: 116, height: 12)
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
                .font(.subheadline.weight(.semibold))
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
