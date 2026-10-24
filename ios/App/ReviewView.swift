import SwiftUI
import UIKit
import CoreModels
import Learning

/// "Tekrar": a short round. Due words come first, each asked by its box (`AppModel.questionKind`,
/// docs/tasarim/ogrenme_ilkeleri.md 2.4): in boxes 1–3 with the card's fill-in-the-blank question
/// (`QuizCardView`, without a confusable partner not learned yet: `AppModel.clozeQuiz`), in
/// boxes 2–3 taking turns with "Dinle ve seç" and "İngilizcesini yaz" (`AppModel.dueQuestion`,
/// `ListenQuestionView`, `TypeQuestionView`); in
/// boxes 4–5, for refreshers and for the check 3 days after "Biliyorum" with the recall screen
/// ("İngilizcesini hatırla": the Turkish meaning, "Göster", then "Göstermeden önce aklına geldi
/// mi?" and two equal answers, "Bulamadım" and "Buldum").
///
/// When nothing is due the tab offers new words in rounds of five, "Tanış + Hatırla"
/// (`IntroRound`, 2.3). "Tanış": the word with its band and sound, the meaning hidden; one bottom
/// button that stays in place and turns from "Anlamını göster" into "Sonraki"; above it a plain
/// "Bunu zaten biliyorum", which takes the word out (checked once in 3 days, with a 5-second "Geri
/// al"). "Hatırla": each word once with four options, "Anlamını seç" or "İngilizcesini seç"; a
/// wrong answer gets one more try a few cards later. The grade comes from the answers, never from
/// a self-rating.
///
/// During a round the tab bar is hidden, the round has its own header ("Kart 3 / 10", the
/// progress, "Bitir") and the buttons sit at the bottom, where the thumb is. A round ends with a
/// word-by-word summary; with nothing left for today the tab lists the words met today and says
/// when the next review is due. No streaks, no scores.
struct ReviewView: View {
    /// Switches to "Ayarlar" (the shortcut to the daily goal on the done screen).
    var openSettings: () -> Void = {}

    @EnvironmentObject private var model: AppModel
    /// "Ara verdin" is a system card: at most one per opening (`SystemCardQueue`, RootView).
    @EnvironmentObject private var systemCards: SystemCardQueue
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The running round; nil while the start screen or the summary is shown.
    @State private var session: ReviewSession?
    /// The card of a due round.
    @State private var index = 0
    /// The "Tanış + Hatırla" steps of a new-word round.
    @State private var intro: IntroRound?
    /// A "Tanış" card shows its meaning; a recall card shows the English word.
    @State private var isRevealed = false
    /// The option picked on a "Hatırla" question, until "Devam".
    @State private var picked: String?
    /// The card's text runs past the bottom of the card ("Devamı").
    @State private var cardHasMore = false
    /// The height of "Devamı" with its padding: under it the card's text is fully faded.
    @State private var cueHeight: CGFloat = 0
    /// Answers of the running round, in order.
    @State private var answers: [RoundAnswer] = []
    /// Answers of the round that just ended: the summary stays until "Tamam".
    @State private var summary: [RoundAnswer]?
    /// That round ended with "Bitir" before its last card: the summary says the rest is waiting.
    @State private var summaryEndedEarly = false
    /// Counts "Bulamadım / Buldum" answers: one light tick each, nothing else.
    @State private var answerTick = 0
    /// When the card on screen came (the answer time in the local metrics).
    @State private var cardShownAt = Date()
    /// Taps on each new word's cards in this round, until its "Hatırla" is decided (local metrics).
    @State private var newWordTaps: [Int: Int] = [:]
    /// The word this tab took out with "Bunu zaten biliyorum"; its "Geri al" shows while
    /// `AppModel.knownUndo` still holds it.
    @State private var skippedWordID: Int?
    /// New words studied in this tab today, for the done screen: "2026-10-22|12,45,78". AppModel
    /// only counts them (`newWordsStudiedToday`); the words themselves are kept here.
    @AppStorage("lockglow.reviewNewWordsToday") private var newWordsTodayLog = ""
    /// Where VoiceOver goes when the card turns, the next card comes or the round ends: the
    /// pressed button is gone by then, and the focus would be left nowhere (audit V1).
    @AccessibilityFocusState private var focus: ReviewFocus?
    /// The tab is on screen (TabView keeps it alive in the background).
    @State private var isOnScreen = false
    /// "Kitaplığın" is pushed over the start card.
    @State private var isLibraryOpen = false
    /// The start card says "Ara verdin, sorun değil." in this opening (`updateBreakLines`).
    @State private var showsBreakLines = false
    /// A round started in this opening: "Ara verdin" is over until the next opening.
    @State private var startedThisOpening = false
    /// The one word of a "Tanış" round whose card invites to say it aloud (2.3: one card in five).
    @State private var sayInviteWordID: Int?
    /// The reminder question after a round (`ReminderOfferSheet`, 2.8).
    @State private var showsReminderOffer = false
    /// The reminder question came once: it never comes again, whatever the answer (2.8).
    @AppStorage("lockglow.reminderOfferShown") private var reminderOfferShown = false

    private var isInRound: Bool {
        return session != nil
    }

    /// is5-canli: the running round's counter for its Live Activity; nil without a round.
    private var liveActivityProgress: ReviewActivityTracker.Progress? {
        guard let session = session else {
            return nil
        }
        let progress = roundProgress(session)
        return ReviewActivityTracker.Progress(done: progress.done, total: progress.total)
    }

    var body: some View {
        // One child whose identity never changes: the modifiers below stay on it, so `onAppear`
        // and `onDisappear` do not fire again when the stack inside is replaced.
        ZStack {
            NavigationStack {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.bg)
                    .navigationTitle(session == nil && summary != nil ? "Tur bitti" : "Tekrar")
                    .navigationBarTitleDisplayMode(.large)
                    // A round has its own header with "Bitir"; the tab bar would only invite
                    // leaving half way, and the answers belong where the thumb is (README point 9).
                    .toolbar(isInRound ? .hidden : .visible, for: .navigationBar)
                    .toolbar(isInRound ? .hidden : .visible, for: .tabBar)
            }
            // The summary is often scrolled and its bar collapses: a fresh stack after "Tamam"
            // (and at the round's end) brings the tab root back with its large "Tekrar" title,
            // as on the tab's first opening (2026-10-24 images). Nothing is ever pushed on the
            // summary, so no page is lost; all state belongs to this view, outside the stack.
            .id(summary == nil ? "tekrar" : "tur-bitti")
        }
        // Borderless controls are ink, never the system blue (rule 2).
        .tint(Theme.ink)
        .sensoryFeedback(.selection, trigger: answerTick)
        .onAppear {
            isOnScreen = true
            updateBreakLines()
        }
        .onDisappear {
            isOnScreen = false
        }
        // is5-canli: the round's Live Activity starts with the round, follows "Kart 3 / 10" and
        // closes when the round ends (ReviewLiveActivity).
        .onChange(of: liveActivityProgress) { _, progress in
            ReviewLiveActivity.shared.roundChanged(to: progress)
        }
        .onChange(of: systemCards.isDecided) { _, isDecided in
            if isDecided {
                if isOnScreen {
                    updateBreakLines()
                }
            } else {
                // The opening ended (background). What is on screen stays until the next opening
                // has decided: it claims again, or the plain card comes back. A hidden tab drops
                // its lines now, so they never flash when it comes back.
                startedThisOpening = false
                if !isOnScreen {
                    showsBreakLines = false
                }
            }
        }
        .sheet(isPresented: $showsReminderOffer) {
            ReminderOfferSheet(initialMinute: model.reminderMinuteOfDay) { minute in
                acceptReminder(at: minute)
            }
            .tint(Theme.ink)
        }
    }

    @ViewBuilder
    private var content: some View {
        if let session = session, let card = currentCard(in: session) {
            roundScreen(session: session, card: card)
        } else if let summary = summary {
            summaryScreen(summary)
        } else {
            startScreen
        }
    }

    // MARK: Round

    /// What the current step of the round shows.
    private enum RoundCard {
        /// Boxes 1–3: the card's fill-in-the-blank question.
        case cloze(WidgetWord, CardDetail.Quiz)
        /// Boxes 4–5, refreshers, the "Biliyorum" check.
        case recall(WidgetWord)
        /// "Tanış".
        case meet(WidgetWord)
        /// "Hatırla".
        case choice(WidgetWord, attempt: Int, direction: IntroRound.Direction)
        /// Boxes 2–3, every other question: "Dinle ve seç" (ListenQuestionView).
        case listen(WidgetWord, ListenQuestion)
        /// Boxes 2–3, every other question: "İngilizcesini yaz" (TypeQuestionView).
        case typing(WidgetWord, TypeQuestion)

        var word: WidgetWord {
            switch self {
            case let .cloze(word, _), let .recall(word), let .meet(word), let .choice(word, _, _),
                 let .listen(word, _), let .typing(word, _):
                return word
            }
        }
    }

    private func currentCard(in session: ReviewSession) -> RoundCard? {
        switch session.kind {
        case .due:
            guard session.words.indices.contains(index) else {
                return nil
            }
            let word = session.words[index]
            // By the box (`AppModel.dueQuestion`, kept while the card is on screen): boxes 2–3 take
            // turns with "Dinle ve seç" and "İngilizcesini yaz"; listening only with sound on and
            // VoiceOver off.
            switch model.dueQuestion(for: word, canListen: ListenAvailability.isAvailable) {
            case let .cloze(quiz):
                return .cloze(word, quiz)
            case let .listen(question):
                return .listen(word, question)
            case let .typing(question):
                return .typing(word, question)
            case .recall:
                return .recall(word)
            }
        case .new:
            guard let round = intro, let step = round.current,
                  let word = session.words.first(where: { $0.id == step.wordID }) else {
                return nil
            }
            switch step {
            case .meet:
                return .meet(word)
            case let .recall(_, attempt):
                return .choice(word, attempt: attempt, direction: round.directions[word.id] ?? .pickMeaning)
            }
        }
    }

    private func roundScreen(session: ReviewSession, card: RoundCard) -> some View {
        let detail = model.detail(for: card.word)
        return VStack(spacing: 8) {
            roundHeader(session: session, counterFont: ReviewView.counterFont(for: card))
            switch card {
            case let .cloze(word, quiz):
                QuizCardView(
                    word: word,
                    quiz: quiz,
                    // Each attempt puts the answer in another place (2.4): the answers so far.
                    attempt: model.progress[word.id]?.reviews ?? 0,
                    layout: .scrolling,
                    mistakes: detail?.mistakes ?? [],
                    optionMeanings: optionMeanings(for: quiz, word: word),
                    returnTimes: quizReturnTimes(for: word)
                ) { outcome in
                    let grade = ReviewView.grade(for: outcome)
                    answerDue(word: word, grade: grade, label: AnswerLabel(grade))
                }
                .id(word.id)
            case let .recall(word):
                recallRound(word: word, detail: detail, times: recallReturnTimes(for: word)) { found in
                    answerRecall(word: word, found: found)
                }
            case let .listen(word, question):
                ListenQuestionView(word: word, question: question, returnTimes: quizReturnTimes(for: word)) { outcome in
                    let grade = ReviewView.grade(for: outcome)
                    answerDue(word: word, grade: grade, label: AnswerLabel(grade))
                }
                .id(word.id)
            case let .typing(word, question):
                TypeQuestionView(word: word, question: question, returnTimes: quizReturnTimes(for: word)) { outcome in
                    let grade = ReviewView.grade(for: outcome)
                    answerDue(word: word, grade: grade, label: AnswerLabel(grade))
                }
                .id(word.id)
            case let .meet(word):
                meetRound(word: word, detail: detail)
            case let .choice(word, attempt, direction):
                if let question = model.introQuestion(for: word, direction: direction, attempt: attempt) {
                    choiceRound(word: word, question: question, attempt: attempt, detail: detail)
                } else {
                    // Too few cards for options (seed words): the same word is recalled instead.
                    recallRound(word: word, detail: detail, times: nil) { found in
                        continueIntro(word: word, right: found)
                    }
                }
            }
        }
    }

    /// Only what the round needs: "Kart 3 / 10", the progress bar and "Bitir" (glass: the control
    /// layer, rule 6) on one line. At accessibility sizes the bar goes under the line, and when
    /// "Kart 10 / 20" and "Bitir" do not fit side by side the count goes under "Bitir" rather
    /// than being cut (audit D3). In "Tanış + Hatırla" every card counts, and a second try adds one.
    @ViewBuilder
    private func roundHeader(session: ReviewSession, counterFont: Font) -> some View {
        let progress = roundProgress(session)
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 10) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        cardCounter(done: progress.done, total: progress.total, font: counterFont)
                            .fixedSize()
                        Spacer(minLength: 0)
                        finishButton
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        finishButton
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        cardCounter(done: progress.done, total: progress.total, font: counterFont)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                RoundProgressBar(done: progress.done, total: progress.total)
            }
            .padding(.horizontal, 16)
        } else {
            HStack(spacing: 12) {
                cardCounter(done: progress.done, total: progress.total, font: counterFont)
                    .fixedSize()
                RoundProgressBar(done: progress.done, total: progress.total)
                finishButton
            }
            .frame(minHeight: 52)
            .padding(.horizontal, 16)
        }
    }

    /// The counter takes the small size of the screen under it, so the header adds no size: the
    /// "Tanış" card's small lines are Callout (IPA, translation, Dikkat, "Dinle"), the question
    /// screens' are Subheadline.
    private static func counterFont(for card: RoundCard) -> Font {
        if case .meet = card {
            return .callout.weight(.semibold)
        }
        return .subheadline.weight(.semibold)
    }

    private func roundProgress(_ session: ReviewSession) -> (done: Int, total: Int) {
        if session.kind == .new, let round = intro {
            return (round.position, round.steps.count)
        }
        return (index, session.words.count)
    }

    /// The round's heading for VoiceOver (audit V10): "Kart 3, toplam 10", not "3 bölü 10".
    private func cardCounter(done: Int, total: Int, font: Font) -> some View {
        let current = min(done + 1, max(total, 1))
        return Text("Kart \(current) / \(total)")
            .font(font)
            .monospacedDigit()
            .foregroundStyle(Theme.ink2)
            .accessibilityLabel("Kart \(current), toplam \(total)")
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused($focus, equals: .counter)
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

    // MARK: Tanış

    /// "Tanış": the card fills the space between the header and the bottom bar and ends above
    /// the bar. Its text scrolls inside it when it is taller (iPhone SE, large text); the card's
    /// bottom edge then fades out under "Devamı".
    private func meetRound(word: WidgetWord, detail: CardDetail?) -> some View {
        VStack(spacing: 0) {
            cardPanel(word: word, detail: detail)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)
            // Opaque (rule 6): the buttons never sit on glass, and never on the card.
            meetActions(word: word)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
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
                            // VoiceOver uses "Anlamını göster" in the bar; the card is not a
                            // button so that "Dinle" inside it stays a separate control.
                            .onTapGesture {
                                reveal(word)
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
            // While more text is below, its last lines fade out into the card itself: a mask, not
            // a colored gradient, so it matches the card in every theme. The fade ends above the
            // cue's text, and under the cue the text is fully faded (2026-10-24 SE images:
            // "Devamı" stood on a half-faded line).
            .mask {
                VStack(spacing: 0) {
                    Rectangle()
                    if cardHasMore {
                        LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                            .frame(height: 32)
                        // The cue's text and bottom padding, with 4 pt to spare.
                        Color.clear
                            .frame(height: max(cueHeight - MoreBelowCue.topPadding + 4, 0))
                    }
                }
            }
            // The back starts at its top, wherever the front was scrolled.
            .id(side)
        }
        // On the card's own bottom edge, over the faded-out end of the text: never on legible
        // text, never on the buttons.
        .overlay(alignment: .bottom) {
            ZStack {
                // Measures the cue for the mask, also before it shows (its height grows with
                // the text size).
                MoreBelowCue()
                    .hidden()
                if cardHasMore {
                    MoreBelowCue()
                        .transition(.opacity)
                }
            }
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.size.height
            } action: { newHeight in
                cueHeight = newHeight
            }
            // Only the cue fades; the card's text never moves with it.
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: cardHasMore)
        }
        .clipShape(shape)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
    }

    /// Mockup `.front`: the word centered with the band at the Large Title size (2026-10-24:
    /// Apple's type scale, no larger hero size), "Dinle", and a quiet nudge to guess the meaning
    /// before turning the card. The spacing carries the hierarchy: the word and "Dinle" as one
    /// group (24 pt, room for the night band), the nudge set apart (32 pt). A word already seen
    /// on the widget is a real recall attempt: "Widget'ta gördün. Hatırlıyor musun?" (2.1, rule b).
    private func cardFront(word: WidgetWord) -> some View {
        VStack(spacing: 24) {
            WordHeadline(lemma: word.lemma, alignment: .center)
                .accessibilityFocused($focus, equals: .word)
            // Callout, the card's one small size, as on its back and in the header's counter.
            CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle", font: .callout.weight(.semibold))
            Text(model.wasSeenOnWidget(word) ? "Widget'ta gördün. Hatırlıyor musun?" : "Ne demek olabilir? Tahmin et.")
                .font(.callout)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
        .padding(.vertical, 32)
    }

    /// Reading order for an A2 learner (mockup `cardInner`): the word, the Turkish meaning (large,
    /// no box), the simple English definition, the example with its translation, one typical
    /// mistake. 16 pt between the rows: the night band under the word needs 8 pt before the next.
    private func cardBack(word: WidgetWord, detail: CardDetail?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            WordHeadline(lemma: word.lemma, alignment: .leading)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    metaItems(word)
                    Spacer(minLength: 8)
                    listenAndSay(word)
                }
                VStack(alignment: .leading, spacing: 8) {
                    wordMeta(word, alignment: .leading)
                    listenAndSay(word)
                }
            }
            if let gloss = word.glossTR {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: gloss)
                        .meaningStyle()
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Türkçesi: " + gloss)
                        // The card turned: VoiceOver reads the answer first.
                        .accessibilityFocused($focus, equals: .meaning)
                    if let alternatives = detail?.glossAlternatives, !alternatives.isEmpty {
                        Text(verbatim: "Ayrıca: " + alternatives.joined(separator: ", "))
                            .font(.callout)
                            .foregroundStyle(Theme.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            // A user's word has no English definition (and maybe no example). Body serif like the
            // example (2026-10-24: one size fewer on the back; the rule above the example and its
            // marked word still set the example apart).
            if !word.defShort.isEmpty {
                Text(verbatim: word.defShort)
                    .exampleStyle()
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .englishVoice()
                    // A card without a Turkish meaning: the definition is the answer.
                    .accessibilityFocused($focus, equals: .definition)
            }
            if word.id == sayInviteWordID {
                // Saying the word aloud helps when only some words are said (MacLeod and others
                // 2010): one card in a round, the microphone optional (2.3).
                Label("Bir kez sesli söyle. Mikrofon isteğe bağlı.", systemImage: "mic")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !word.exampleEN.isEmpty {
                exampleBlock(word: word, translation: detail?.examples.first?.tr)
            }
            if word.isUserAdded, let note = detail?.noteTR {
                NoteRow(symbol: "note.text", text: note)
            }
            // The card's own Dikkat, as in Akış: the first mistake about this word.
            if let mistake = detail?.cardMistake(lemma: word.lemma) {
                MistakeBox(mistake: mistake)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 20)
    }

    /// "Dinle" and the "Söyle" microphone, on every "Tanış" card (2.3). Callout, as the IPA and
    /// the part of speech beside them.
    private func listenAndSay(_ word: WidgetWord) -> some View {
        HStack(spacing: 4) {
            CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle", font: .callout.weight(.semibold))
            SayButton(word: word, example: word.exampleEN)
        }
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

    /// Callout, as on the Akış card and like the example's translation on this card (one size
    /// fewer on the back).
    @ViewBuilder
    private func metaItems(_ word: WidgetWord) -> some View {
        AccentIPA(word) { ipa in
            Text(verbatim: ipa)
                .font(.system(.callout, design: .serif))
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
        }
        if word.isUserAdded {
            CustomWordTag()
        } else {
            Text(verbatim: CardPartOfSpeech.turkish(word.pos))
                .font(.callout.weight(.medium))
                .foregroundStyle(Theme.ink2)
            // Callout like the IPA and the part of speech beside it (the Sözlük page's facts
            // too): Footnote here was the back's fifth size.
            LevelBadge(code: word.level, textStyle: .callout)
        }
    }

    /// The example as in the feed (`ExampleRow`): the sentence with the learned word marked
    /// (rule 1) and its Turkish, the speaker beside it; no "Örnek" label (less to read). At
    /// accessibility sizes the speaker goes under the translation and the sentence keeps the width.
    private func exampleBlock(word: WidgetWord, translation: String?) -> some View {
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let rowLayout = isLarge
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 4))
        return rowLayout {
            VStack(alignment: .leading, spacing: 4) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            ReviewSpeakerButton(text: word.exampleEN, accessibilityName: "Cümleyi dinle")
                // The circle lines up with the card's text edge; the 44 pt target overhangs
                // instead of making the row taller.
                .padding(.vertical, -7)
                .padding(isLarge ? .leading : .trailing, -5)
        }
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.line)
                .frame(height: 1)
        }
    }

    /// The bottom bar of "Tanış": one filled button that never moves (the thumb stays put) and
    /// turns from "Anlamını göster" into "Sonraki"; above it, on the front only, the plain
    /// "Bunu zaten biliyorum", and the "Geri al" note after it was tapped.
    private func meetActions(word: WidgetWord) -> some View {
        VStack(spacing: 8) {
            if let undo = knownUndoToShow {
                KnownUndoNotice(message: KnownUndo.message) {
                    undoSkip(undo)
                }
                .transition(.opacity)
            }
            if !isRevealed {
                Button("Bunu zaten biliyorum") {
                    skipKnown(word)
                }
                .buttonStyle(QuietButtonStyle())
                .accessibilityHint("3 gün sonra bir kez sorulur")
            }
            Button {
                if isRevealed {
                    nextMeet()
                } else {
                    reveal(word)
                }
            } label: {
                Text(isRevealed ? "Sonraki" : "Anlamını göster")
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            .keyboardShortcut(AnswerKeys.main)
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: knownUndoToShow?.word.id)
    }

    // MARK: Hatırla

    /// "Hatırla": "Şimdi hatırla" on top, the question ("Anlamını seç": the English word with its
    /// sound; "İngilizcesini seç": the Turkish meaning) and four equal options, one per row (a
    /// Turkish meaning can be long). After a tap only the right option ("Doğru cevap") and a wrong
    /// pick ("Yanlış") stay, marked with icons and words, never color alone; the feedback below
    /// says what the word means and, after a wrong pick, what the picked option means. "Devam"
    /// then waits at the bottom: nothing moves on by itself (WCAG 2.2.1).
    private func choiceRound(word: WidgetWord, question: ChoiceQuestion, attempt: Int, detail: CardDetail?) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let undo = knownUndoToShow {
                        KnownUndoNotice(message: KnownUndo.message) {
                            undoSkip(undo)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Şimdi hatırla")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink2)
                            .accessibilityAddTraits(.isHeader)
                        if picked == nil {
                            Text("Şimdi hatırlıyor musun, bakalım.")
                                .font(.subheadline)
                                .foregroundStyle(Theme.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    choicePrompt(question)
                    VStack(spacing: 10) {
                        ForEach(shownOptions(question), id: \.self) { option in
                            choiceOption(option, question: question)
                                .transition(.opacity)
                        }
                    }
                    if let picked = picked {
                        choiceFeedback(word: word, question: question, picked: picked, attempt: attempt, detail: detail)
                            .id(ReviewView.feedbackID)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            .scrollBounceBehavior(.basedOnSize)
            // Opaque (rule 6): "Devam" never sits on glass.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let picked = picked {
                    Button("Devam") {
                        continueIntro(word: word, right: picked == question.answer)
                    }
                    .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                    .keyboardShortcut(AnswerKeys.main)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity)
                    .background(Theme.bg)
                    .transition(.opacity)
                }
            }
            .onChange(of: picked) { _, newValue in
                guard newValue != nil else {
                    return
                }
                // Once the options have collapsed and "Devam" is laid out: the feedback must never
                // stay hidden under the bar (README point 6).
                let animation: Animation? = reduceMotion ? nil : .easeInOut(duration: 0.3)
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 60_000_000)
                    withAnimation(animation) {
                        proxy.scrollTo(ReviewView.feedbackID, anchor: .bottom)
                    }
                }
            }
        }
        // A light haptic on a right answer only; a wrong pick stays silent.
        .sensoryFeedback(.success, trigger: picked) { oldValue, newValue in
            oldValue == nil && newValue == question.answer
        }
        .id("\(word.id)-\(attempt)")
    }

    private static let feedbackID = "review.choice.feedback"

    /// The question on a card: its kind as a heading, then the word or the meaning to answer.
    /// 16 pt between the rows: the night band under the word needs 8 pt before "Dinle".
    private func choicePrompt(_ question: ChoiceQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.direction == .pickMeaning ? "Anlamını seç" : "İngilizcesini seç")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($focus, equals: .question)
            switch question.direction {
            case .pickMeaning:
                WordHeadline(lemma: question.prompt, alignment: .leading)
                CardListenCapsule(text: question.prompt, accessibilityName: "Kelimeyi dinle")
            case .pickEnglish:
                // The meaning only: its sound would give the answer away.
                Text(verbatim: question.prompt)
                    .meaningStyle()
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Türkçesi: " + question.prompt)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: Theme.Radius.card)
    }

    /// Before the answer every option; after it the right one first, then a wrong pick.
    private func shownOptions(_ question: ChoiceQuestion) -> [String] {
        guard let picked = picked else {
            return question.options
        }
        return picked == question.answer ? [question.answer] : [question.answer, picked]
    }

    /// A calm option (rule 2): `surface` with a `lineStrong` border, as tall as a quiz option
    /// (56 pt). English options are serif with an English voice, Turkish ones SF.
    private func choiceOption(_ option: String, question: ChoiceQuestion) -> some View {
        let mark = choiceMark(for: option, question: question)
        let isEnglish = question.direction == .pickEnglish
        let rowLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(spacing: 12))
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        return Button {
            choose(option, question: question)
        } label: {
            rowLayout {
                Group {
                    if isEnglish {
                        Text(verbatim: option)
                            .font(Theme.Fonts.definition)
                            .englishVoice()
                    } else {
                        Text(verbatim: option)
                            .font(.title3.weight(.medium))
                    }
                }
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                if let mark = mark {
                    HStack(spacing: 4) {
                        Image(systemName: mark.symbol)
                            .font(.body.weight(.semibold))
                            .accessibilityHidden(true)
                        // Subheadline like the screen's other small lines (one size fewer).
                        Text(mark.text)
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(mark.color)
                    .fixedSize()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(mark?.fill ?? Theme.surface, in: shape)
            .overlay {
                shape.strokeBorder(mark?.border ?? Theme.lineStrong, lineWidth: mark?.lineWidth ?? 1.5)
            }
            .contentShape(shape)
        }
        .buttonStyle(PressFadeButtonStyle())
        .keyboardShortcut(picked == nil ? AnswerKeys.answer(question.options.firstIndex(of: option)) : nil)
        // Not `.disabled`: that would dim the options exactly when the answer is shown.
        .allowsHitTesting(picked == nil)
        // As in the quiz (`QuizCardView.optionButton`): a button's label merges its texts and an
        // English option would lose its voice next to the Turkish mark. Before the answer the
        // button with the option alone; after it only the result, not a button.
        .accessibilityRepresentation {
            if picked == nil {
                Button {
                    choose(option, question: question)
                } label: {
                    if isEnglish {
                        Text(verbatim: option)
                            .englishVoice()
                    } else {
                        Text(verbatim: option)
                    }
                }
            } else {
                if isEnglish {
                    Text(verbatim: option)
                        .englishVoice()
                } else {
                    Text(verbatim: option)
                }
                if let mark = mark {
                    Text(mark.text)
                }
            }
        }
    }

    private struct ChoiceMark {
        let text: String
        let symbol: String
        let color: Color
        let fill: Color
        let border: Color
        let lineWidth: CGFloat
    }

    /// The right option in `good` with a check; a wrong pick stays on paper with a cross in ink2:
    /// the word and the icon say it, not a red box (rule 4).
    private func choiceMark(for option: String, question: ChoiceQuestion) -> ChoiceMark? {
        guard let picked = picked else {
            return nil
        }
        if option == question.answer {
            return ChoiceMark(
                text: "Doğru cevap",
                symbol: "checkmark.circle.fill",
                color: Theme.good,
                fill: Theme.goodTint,
                border: Theme.good,
                lineWidth: 2
            )
        }
        if option == picked {
            return ChoiceMark(
                text: "Yanlış",
                symbol: "xmark.circle",
                color: Theme.ink2,
                fill: Theme.surface,
                border: Theme.lineStrong,
                lineWidth: 1.5
            )
        }
        return nil
    }

    /// About the task, never the person (rule 12): "borrow = ödünç almak"; after a wrong pick
    /// "Doğrusu: …" and what the picked option means, then when the word comes back. After the
    /// second wrong pick the card's example closes the word's round. VoiceOver reads each line in
    /// parts, the English word in an English voice (`FeedbackSpeech`; one element has one voice).
    private func choiceFeedback(
        word: WidgetWord,
        question: ChoiceQuestion,
        picked: String,
        attempt: Int,
        detail: CardDetail?
    ) -> some View {
        let isRight = picked == question.answer
        let headword: Text = Text(verbatim: word.lemma).bold()
        let meaning = word.glossTR ?? word.defShort
        let lead = isRight ? "Doğru:" : "Doğrusu:"
        return VStack(alignment: .leading, spacing: 10) {
            Group {
                if meaning.isEmpty {
                    Text("\(lead) \(headword)")
                } else {
                    Text("\(lead) \(headword) = \(meaning)")
                }
            }
            .font(.body)
            .foregroundStyle(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityRepresentation {
                // A seed word without a Turkish meaning: its English definition, in English.
                FeedbackSpeech(
                    lead: lead,
                    english: word.lemma,
                    meaning: meaning.isEmpty ? nil : meaning,
                    meaningIsEnglish: word.glossTR == nil
                )
            }
            if !isRight {
                pickedFeedback(picked, question: question)
                Label(ReviewView.retryNote(attempt: attempt), systemImage: "arrow.uturn.forward")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                if attempt >= IntroRound.maxAttempts && !word.exampleEN.isEmpty {
                    exampleBlock(word: word, translation: detail?.examples.first?.tr)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .flatCard(cornerRadius: Theme.Radius.card)
    }

    /// After a wrong pick: the first try comes back a few cards later, the second in the next round.
    private static func retryNote(attempt: Int) -> String {
        return attempt < IntroRound.maxAttempts
            ? "Birazdan bir kez daha soracağız."
            : "Bu kelimeyi bir sonraki turda yine soracağız."
    }

    /// "Senin seçtiğin: lend = ödünç vermek", English first for an English option ("lend") and for
    /// a Turkish one ("ödünç vermek") alike; only the option when no card has it. VoiceOver: the
    /// Turkish part, then the English word in an English voice.
    private func pickedFeedback(_ picked: String, question: ChoiceQuestion) -> some View {
        let other = question.counterparts[picked]
        let isEnglishOption = question.direction == .pickEnglish
        // English = Turkish, as "Doğrusu: cry = ağlamak" above: "hope = ummak" for either option.
        let pair = other.map { isEnglishOption ? "\(picked) = \($0)" : "\($0) = \(picked)" } ?? picked
        return Text(verbatim: "Senin seçtiğin: " + pair)
            .font(.subheadline)
            .foregroundStyle(Theme.ink2)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityRepresentation {
                if isEnglishOption {
                    FeedbackSpeech(lead: "Senin seçtiğin:", english: picked, meaning: other)
                } else if let english = other {
                    FeedbackSpeech(lead: "Senin seçtiğin: \(picked). İngilizcesi:", english: english, meaning: nil)
                } else {
                    Text(verbatim: "Senin seçtiğin: " + picked)
                }
            }
    }

    private func choose(_ option: String, question: ChoiceQuestion) {
        guard picked == nil else {
            return
        }
        if let running = session, let word = currentCard(in: running)?.word {
            noteNewWordTap(word)
        }
        let isRight = option == question.answer
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            picked = option
        }
        let english = question.direction == .pickEnglish ? question.answer : question.prompt
        let turkish = question.direction == .pickEnglish ? question.prompt : question.answer
        ReviewView.announce([
            (isRight ? "Doğru. " : "Doğrusu: ", false),
            (english, true),
            (", Türkçesi: " + turkish, false),
        ])
    }

    // MARK: Recall

    /// "İngilizcesini hatırla" (boxes 4–5, refreshers, the "Biliyorum" check): the Turkish
    /// meaning ("ödünç almak → ?"), the English word only after "Göster", large with its sound.
    /// The question above the answers asks about the moment before the word was shown, when the
    /// learner did not see it yet (Dunlosky and Rawson 2012).
    private func recallRound(
        word: WidgetWord,
        detail: CardDetail?,
        times: (notFound: String?, found: String?)?,
        onAnswer: @escaping (Bool) -> Void
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let undo = knownUndoToShow {
                    KnownUndoNotice(message: KnownUndo.message) {
                        undoSkip(undo)
                    }
                }
                Text("İngilizcesini hatırla")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($focus, equals: .question)
                recallCard(word: word, detail: detail)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
        .scrollBounceBehavior(.basedOnSize)
        // Opaque (rule 6): the answers never sit on glass, and never on the card.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            recallActions(word: word, times: times, onAnswer: onAnswer)
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background(Theme.bg)
        }
        .id(word.id)
    }

    /// 16 pt between the rows: the night band under the word needs 8 pt before "Dinle".
    private func recallCard(word: WidgetWord, detail: CardDetail?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let gloss = word.glossTR {
                Text("\(Text(verbatim: gloss)) \(Text(verbatim: "→ ?").foregroundStyle(Theme.ink3))")
                    .font(Theme.Fonts.meaning)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Türkçesi: \(gloss). İngilizcesi ne?")
            } else {
                // A seed word without a Turkish meaning: its English definition is the clue.
                Text(verbatim: word.defShort)
                    .definitionStyle()
                    .fixedSize(horizontal: false, vertical: true)
                    .englishVoice()
            }
            if isRevealed {
                Rectangle()
                    .fill(Theme.line)
                    .frame(height: 1)
                WordHeadline(lemma: word.lemma, alignment: .leading)
                    .accessibilityFocused($focus, equals: .word)
                CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle")
                if !word.exampleEN.isEmpty {
                    exampleBlock(word: word, translation: detail?.examples.first?.tr)
                }
            } else {
                Text("İngilizcesini aklından bulmaya çalış. Sonra Göster'e dokun.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
    }

    /// "Göster" (the screen's one filled button), then the question and two equal answers,
    /// failure first: no filled default (1b), as tall as the quiz options. Each says when the
    /// word comes back, from the same schedule the answer will write. At accessibility sizes
    /// one answer per row.
    @ViewBuilder
    private func recallActions(
        word: WidgetWord,
        times: (notFound: String?, found: String?)?,
        onAnswer: @escaping (Bool) -> Void
    ) -> some View {
        if isRevealed {
            let rowLayout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(spacing: 8))
                : AnyLayout(HStackLayout(spacing: 8))
            VStack(spacing: 8) {
                Text("Göstermeden önce aklına geldi mi?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                rowLayout {
                    recallButton(found: false, when: times?.notFound, onAnswer: onAnswer)
                    recallButton(found: true, when: times?.found, onAnswer: onAnswer)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            Button("Göster") {
                // A tap on the word in a new-word round (its recall fallback); none in a due round.
                noteNewWordTap(word)
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    isRevealed = true
                }
                moveFocus(to: .word)
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            .keyboardShortcut(AnswerKeys.main)
        }
    }

    private func recallButton(found: Bool, when: String?, onAnswer: @escaping (Bool) -> Void) -> some View {
        let info = AnswerLabel(found: found)
        return Button {
            answerTick += 1
            onAnswer(found)
        } label: {
            GradeLabel(title: info.title, symbol: info.symbol, when: when)
        }
        .buttonStyle(GradeButtonStyle())
        .keyboardShortcut(AnswerKeys.answer(found ? 1 : 0))
        .accessibilityLabel(info.title)
        // A value, not a hint: hints come late and many people turn them off (audit V9).
        .accessibilityValue(when.map { $0 == ReviewView.backToIntroText ? $0 : "\($0) yine gelir" } ?? "")
    }

    /// When the word comes back after "Bulamadım" and "Buldum". A word waiting for its
    /// "Biliyorum" check goes back to "Tanış" instead of a date.
    private func recallReturnTimes(for word: WidgetWord) -> (notFound: String?, found: String?) {
        let now = Date()
        let awaitsCheck = model.progress[word.id]?.awaitsKnownCheck ?? false
        let notFound = awaitsCheck
            ? ReviewView.backToIntroText
            : model.dueDate(ifAnswering: .again, for: word, now: now).map { ReviewView.againText(until: $0, from: now) }
        let found = model.dueDate(ifAnswering: .good, for: word, now: now).map { ReviewView.returnText(until: $0, from: now) }
        return (notFound, found)
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

    /// When the word comes back after each quiz outcome, from the schedule. A wrong answer
    /// comes back in the next round: "Bu kelime bir sonraki turda yine gelir." (a time in minutes
    /// would be a promise nothing keeps, 2.3).
    private func quizReturnTimes(for word: WidgetWord) -> [QuizOutcome: String] {
        let now = Date()
        var times: [QuizOutcome: String] = [:]
        for outcome in [QuizOutcome.wrong, .hard, .right, .easy] {
            let grade = ReviewView.grade(for: outcome)
            if let due = model.dueDate(ifAnswering: grade, for: word, now: now) {
                times[outcome] = grade == .again
                    ? ReviewView.againText(until: due, from: now)
                    : ReviewView.returnText(until: due, from: now)
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

    /// Turns a "Tanış" card: a short fade (none with Reduce Motion), no flip and no haptic.
    /// VoiceOver goes to the Turkish meaning.
    private func reveal(_ word: WidgetWord) {
        noteNewWordTap(word)
        cardHasMore = false
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            isRevealed = true
        }
        moveFocus(to: word.glossTR == nil ? .definition : .meaning)
    }

    /// Moves VoiceOver once the new view is on screen: in the update that creates it, the target
    /// does not exist yet. Without VoiceOver nothing happens.
    private func moveFocus(to target: ReviewFocus) {
        // Cleared first: setting the value it already holds would not move VoiceOver again.
        focus = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            focus = target
        }
    }

    private func resetCard() {
        isRevealed = false
        picked = nil
        // The next card measures itself again.
        cardHasMore = false
    }

    /// A due word answered (quiz or recall): saved at once, then the next card.
    private func answerDue(word: WidgetWord, grade: ReviewGrade, label: AnswerLabel) {
        let wasNew = (model.progress[word.id]?.state ?? .new) == .new
        let updated = model.recordReview(word, grade: grade, seconds: secondsOnCard)
        answers.append(RoundAnswer(word: word, grade: grade, dueAt: updated.dueAt, wasNew: wasNew, label: label))
        nextDueCard()
    }

    private func answerRecall(word: WidgetWord, found: Bool) {
        let updated = model.recordRecall(word, found: found, seconds: secondsOnCard)
        var answer = RoundAnswer(
            word: word,
            grade: found ? .good : .again,
            dueAt: updated.dueAt,
            wasNew: false,
            label: AnswerLabel(found: found)
        )
        answer.returnsToIntro = updated.returnsToIntro
        answers.append(answer)
        if updated.returnsToIntro {
            ReviewView.announce([("Bu kelime öğrenme listene döndü.", false)])
        }
        nextDueCard()
    }

    private func nextDueCard() {
        resetCard()
        if let session = session, index + 1 < session.words.count {
            index += 1
            focusCurrentCard()
        } else {
            finishRound()
        }
    }

    /// "Sonraki" on a "Tanış" card.
    private func nextMeet() {
        if let running = session, let word = currentCard(in: running)?.word {
            noteNewWordTap(word)
        }
        intro?.next()
        afterIntroStep()
    }

    /// "Bunu zaten biliyorum": the word leaves the round without a question and is checked once
    /// in 3 days; "Geri al" can take it back (longer with VoiceOver, so it can be reached).
    private func skipKnown(_ word: WidgetWord) {
        let window = UIAccessibility.isVoiceOverRunning ? 15 : KnownUndo.window
        model.markKnown(word, undoWindow: window)
        skippedWordID = word.id
        intro?.skipCurrent()
        // Only when "Geri al" is there (a word known already, e.g. by a widget tap, has none).
        if model.knownUndo?.word.id == word.id {
            ReviewView.announce([(KnownUndo.message, false)])
        }
        afterIntroStep()
    }

    /// The "Geri al" note of this tab: only for the word skipped here, while the model holds it.
    private var knownUndoToShow: KnownUndo? {
        guard let undo = model.knownUndo, undo.word.id == skippedWordID else {
            return nil
        }
        return undo
    }

    /// "Geri al": the word is restored exactly; in a running round its "Tanış" card comes back,
    /// now when the card on screen was not touched yet, otherwise right after it.
    private func undoSkip(_ undo: KnownUndo) {
        model.undoKnown(undo.word)
        skippedWordID = nil
        guard session?.kind == .new, intro?.skipped.contains(undo.word.id) == true else {
            return
        }
        let showNow = !isRevealed && picked == nil
        intro?.restore(undo.word.id, showNow: showNow)
        if showNow {
            resetCard()
            focusCurrentCard()
        }
    }

    /// "Devam" on a "Hatırla" question (or an answer on its recall fallback). A decided word is
    /// saved at once; a first wrong answer comes back a few cards later.
    private func continueIntro(word: WidgetWord, right: Bool) {
        noteNewWordTap(word)
        if let result = intro?.answer(right: right) {
            recordIntro(result, word: word, seconds: secondsOnCard)
            recordNewWordTaps(word)
        }
        afterIntroStep()
    }

    private func recordIntro(_ result: IntroRound.Result, word: WidgetWord, seconds: TimeInterval? = nil) {
        let updated = model.recordReview(
            word,
            grade: result.grade,
            firstTryCorrect: result == .firstTry,
            seconds: seconds
        )
        answers.append(RoundAnswer(
            word: word,
            grade: result.grade,
            dueAt: updated.dueAt,
            wasNew: true,
            label: AnswerLabel(result)
        ))
        noteNewWordToday(word.id)
    }

    private func afterIntroStep() {
        resetCard()
        if intro?.isFinished ?? true {
            finishRound()
        } else {
            focusCurrentCard()
        }
    }

    /// A "Tanış" card starts at its word; a question at its heading.
    private func focusCurrentCard() {
        guard let session = session, let card = currentCard(in: session) else {
            return
        }
        cardShownAt = Date()
        switch card {
        case .meet:
            moveFocus(to: .word)
        case .cloze, .listen, .typing:
            moveFocus(to: .counter)
        case .recall, .choice:
            moveFocus(to: .question)
        }
    }

    private func startRound(_ next: ReviewSession) {
        session = next
        index = 0
        intro = next.kind == .new
            ? IntroRound(wordIDs: next.words.map { $0.id }, seed: Int(Date().timeIntervalSince1970))
            : nil
        sayInviteWordID = next.kind == .new ? next.words.randomElement()?.id : nil
        startedThisOpening = true
        showsBreakLines = false
        resetCard()
        answers = []
        summary = nil
        newWordTaps = [:]
        LocalMetricsRecorder.shared.startRound()
        // "Başla" is gone with the start screen.
        focusCurrentCard()
    }

    /// Seconds since the card on screen came.
    private var secondsOnCard: TimeInterval {
        return Date().timeIntervalSince(cardShownAt)
    }

    /// The taps a decided new word took, from its first card to its decision, go to the local
    /// metrics (the touch budget of 2.3, at most 4).
    private func recordNewWordTaps(_ word: WidgetWord) {
        LocalMetricsRecorder.shared.recordNewWord(taps: newWordTaps[word.id] ?? 0)
        newWordTaps[word.id] = nil
    }

    /// One tap on a new word's card ("Anlamını göster", "Sonraki", an option, "Devam", "Göster");
    /// the local metrics keep the taps it took to learn each new word (ogrenme_ilkeleri 2.13).
    private func noteNewWordTap(_ word: WidgetWord) {
        guard session?.kind == .new else {
            return
        }
        newWordTaps[word.id, default: 0] += 1
    }

    /// Ends the round (all cards done, or "Bitir"): every answer is already saved; a "Hatırla"
    /// pick still waiting for "Devam" counts, and a word whose second try has not come yet counts
    /// as missed. The widget queue is rebuilt from the new progress, and the summary follows when
    /// anything was answered.
    private func finishRound() {
        // A "Hatırla" pick waiting for "Devam" counts as if "Devam" was tapped: "Bitir" took its
        // place, also as the word's last tap.
        if let running = session, running.kind == .new, let pick = picked,
           let card = currentCard(in: running), case let .choice(word, attempt, direction) = card,
           let question = model.introQuestion(for: word, direction: direction, attempt: attempt) {
            noteNewWordTap(word)
            if let result = intro?.answer(right: pick == question.answer) {
                recordIntro(result, word: word, seconds: secondsOnCard)
                recordNewWordTaps(word)
            }
        }
        // "Bitir" before the last card: a due word left unanswered, or a new word not decided.
        // After the waiting pick, so that "Bitir" instead of "Devam" on the last question is not
        // an early end.
        let endedEarly: Bool
        switch session?.kind {
        case .new?:
            endedEarly = !(intro?.isFinished ?? true)
        case .due?:
            endedEarly = answers.count < (session?.words.count ?? 0)
        case nil:
            endedEarly = false
        }
        // A word whose second try had not come yet is missed. Its taps are not recorded: its flow
        // was cut before the second try, so the count would be lower than what a new word really
        // takes, and the metric is the cost of a whole flow (2.13).
        if let running = session, running.kind == .new {
            for id in intro?.awaitingRetry ?? [] {
                if let word = running.words.first(where: { $0.id == id }) {
                    recordIntro(.missed, word: word)
                }
            }
        }
        summary = answers.isEmpty ? nil : answers
        summaryEndedEarly = endedEarly
        session = nil
        intro = nil
        index = 0
        resetCard()
        answers = []
        newWordTaps = [:]
        model.finishReviewSession(endedEarly: endedEarly)
        // "Bitir" is gone with the round: the summary, or the start screen when nothing was
        // answered.
        moveFocus(to: summary != nil ? .summary : .start)
    }

    // MARK: Summary

    /// Mockup `reviewSummary`, calm: what was studied, which words come back in the next round,
    /// word by word with its meaning and when each word comes back, and when the next review is.
    /// No score, no streak; "Tamam" stays in reach, "Bir tur daha" above it when more is waiting.
    private func summaryScreen(_ answers: [RoundAnswer]) -> some View {
        let now = Date()
        let next = model.nextReviewDate(after: now)
        let hasHard = answers.contains { $0.grade == .hard }
        let another = model.nextReviewSession()
        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: ReviewView.summaryLine(answers))
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityFocused($focus, equals: .summary)
                    // "Bitir" before the end: nothing is lost, the rest waits here (2.3).
                    if summaryEndedEarly && another != nil {
                        Text("Kalanlar burada seni bekliyor.")
                            .font(.body)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let again = ReviewView.againLine(answers) {
                        Text(verbatim: again)
                            .font(.body)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let returned = ReviewView.returnedLine(answers) {
                        Text(verbatim: returned)
                            .font(.body)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                // The lines, the time and the footnote share the 16 pt edge of the title and the
                // card: one left edge in the column (finding tekrar-7).
                if let next = next {
                    NoteRow(symbol: "clock", text: "Sıradaki tekrar: " + ReviewView.dayAndTime(next, now: now))
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
                        SummaryRow(answer: answer, when: summaryWhen(answer, now: now))
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
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 10) {
                if let undo = knownUndoToShow {
                    KnownUndoNotice(message: KnownUndo.message) {
                        undoSkip(undo)
                    }
                }
                if let another = another {
                    Button {
                        startRound(another)
                    } label: {
                        // "kelime", never "kart": a card is not a unit to count (text audit, terms 4).
                        Text("Bir tur daha (\(another.words.count) kelime)")
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 54, tonal: true))
                }
                Button("Tamam") {
                    summary = nil
                    moveFocus(to: .start)
                    updateBreakLines()
                    offerReminderIfFirstTime()
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background(Theme.bg)
        }
    }

    private func summaryWhen(_ answer: RoundAnswer, now: Date) -> String? {
        if answer.returnsToIntro {
            return ReviewView.backToIntroText
        }
        guard let due = answer.dueAt else {
            return nil
        }
        return answer.grade == .again
            ? ReviewView.againText(until: due, from: now)
            : ReviewView.returnText(until: due, from: now)
    }

    /// "10 kelime çalıştın, 7 tanesini bildin." (no suffix after the number, README point 13; no
    /// wrong count, no percentage, 1b). Without a known word only the first half.
    private static func summaryLine(_ answers: [RoundAnswer]) -> String {
        let count = answers.count
        let known = answers.filter { $0.grade != .again }.count
        if known == 0 {
            return "\(count) kelime çalıştın."
        }
        return "\(count) kelime çalıştın, \(known) tanesini bildin."
    }

    /// "Bir sonraki turda yine soracağız: borrow, date." (2.5)
    private static func againLine(_ answers: [RoundAnswer]) -> String? {
        let words = lemmas(answers.filter { $0.grade == .again && !$0.returnsToIntro })
        return words.isEmpty ? nil : "Bir sonraki turda yine soracağız: " + words + "."
    }

    /// "Öğrenme listene döndü: borrow." A failed "Biliyorum" check (2.2).
    private static func returnedLine(_ answers: [RoundAnswer]) -> String? {
        let words = lemmas(answers.filter { $0.returnsToIntro })
        return words.isEmpty ? nil : "Öğrenme listene döndü: " + words + "."
    }

    private static func lemmas(_ answers: [RoundAnswer]) -> String {
        var seen = Set<Int>()
        return answers.filter { seen.insert($0.word.id).inserted }.map { $0.word.lemma }.joined(separator: ", ")
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
                    description: Text("Kelimeler yüklenemedi. Uygulamayı kapatıp yeniden aç.")
                )
            }
        } else {
            let offer = model.nextReviewSession()
            ScrollView {
                VStack(spacing: 14) {
                    if let offer = offer {
                        offerCard(offer)
                        if isBreak(offer) {
                            // Not as a barrier (2.3): new words wait while the reviews pile up.
                            Text("Yeni kelimeler, tekrarlar azalınca geri geliyor.")
                                .font(.subheadline)
                                .foregroundStyle(Theme.ink2)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 6)
                        }
                        todayLine(withKnown: true)
                            .padding(.horizontal, 6)
                        libraryLink
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
            // A "Bunu zaten biliyorum" on the round's last card can still be taken back here.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let undo = knownUndoToShow {
                    KnownUndoNotice(message: KnownUndo.message) {
                        undoSkip(undo)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                }
            }
        }
    }

    /// Mockup `.hero`. Due words: the round's words, never the whole pile (a large number after a
    /// break reads as a debt, text audit #6). After a break (`isBreak`): "Ara verdin, sorun değil."
    /// with a calm sun instead of the number. New words: the ring of today's goal (only here,
    /// README "Tekrar"), what is left of it, and the round of at most five.
    private func offerCard(_ offer: ReviewSession) -> some View {
        let isDue = offer.kind == .due
        let afterBreak = isBreak(offer)
        return VStack(spacing: 12) {
            if afterBreak {
                // About 44 pt: the Large Title glyph at its large scale, which stops growing at
                // xxxLarge so it stays in its 76 pt row.
                Image(systemName: "sun.max")
                    .font(.largeTitle)
                    .imageScale(.large)
                    .foregroundStyle(Theme.ink2)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .frame(height: 76)
                    .accessibilityHidden(true)
            } else if isDue {
                CountBadge(count: offer.words.count)
            } else {
                GoalRing(done: model.newWordsStudiedToday(), goal: model.dailyNewWords)
                // The ring's text stops growing at its largest size: at accessibility sizes the
                // goal is also said in plain text (audit D7).
                if dynamicTypeSize.isAccessibilitySize {
                    Text(verbatim: "Günlük hedef: \(model.newWordsStudiedToday()) / \(model.dailyNewWords) yeni kelime")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.ink2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        // The ring already says it to VoiceOver.
                        .accessibilityHidden(true)
                }
            }
            Text(isDue
                 ? (afterBreak ? "Ara verdin, sorun değil." : "Tekrar zamanı")
                 : "Bugünün yeni kelimeleri: \(offer.totalCount)")
                .font(.title.bold())
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($focus, equals: .start)
            Text(isDue
                 ? (afterBreak
                    ? "Unutulmaya en yakın \(offer.words.count) kelimeyle başlayalım."
                    : "Önce öğrendiğin kelimeleri hatırlayalım.")
                 : "Önce tanış, sonra hemen bir kez hatırla.")
                // Body, as the button under it (Callout was a fifth size on this screen).
                .font(.body)
                .foregroundStyle(Theme.ink2)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                startRound(offer)
            } label: {
                Text("Başla (\(offer.words.count) kelime)")
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
                    .accessibilityFocused($focus, equals: .start)
                Text("Tekrar edecek kelime kalmadı. Şimdi kapatabilirsin.")
                    .font(.body)
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
            libraryLink
            SentencePracticeLink(isOpen: $isLibraryOpen) // "Biraz daha pratik" (SentencePracticeView.swift)
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
                    NoteRow(symbol: "lock", text: "Kilitli ekranda yeni kelimeler görünmeye devam eder.")
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

    /// "Kitaplığın" under today's line: the progress screen (`ProgressScreen`, sakin_ilerleme.md:
    /// opened from "Tekrar"). Tonal, as "Başla" is the screen's one filled button; only once a
    /// word is on the shelves.
    @ViewBuilder
    private var libraryLink: some View {
        if model.hasLibrary {
            NavigationLink {
                ProgressScreen()
                    .onAppear {
                        isLibraryOpen = true
                    }
                    // An opening decided meanwhile leaves the plain start card (no claim under
                    // the push, `updateBreakLines`).
                    .onDisappear {
                        isLibraryOpen = false
                    }
            } label: {
                Label("Kitaplığın", systemImage: "books.vertical")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
            .accessibilityHint(Text("Öğrendiğin kelimeleri, basamaklarını ve bu haftayı gösterir."))
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

    // MARK: After a break

    /// More due words than this: the start card is "Ara verdin, sorun değil." (2.3).
    private static let breakBacklog = 20

    /// The start card says "Ara verdin" for `offer`: a pile of more than `breakBacklog` due
    /// words, and this opening's system card is "Tekrar"'s (`updateBreakLines`).
    private func isBreak(_ offer: ReviewSession) -> Bool {
        return showsBreakLines && offer.kind == .due && offer.totalCount > ReviewView.breakBacklog
    }

    /// "Ara verdin" is a system card (2.10): only once RootView has picked this opening's card
    /// and none came first (`SystemCardQueue.claim`), only while the start card is on screen (a
    /// hidden tab, or one under "Kitaplığın", must not take the opening's card from "Akış") and
    /// only until a round of this opening has started. Otherwise the plain start card stays:
    /// "Tekrar zamanı", "Başla (10 kelime)".
    private func updateBreakLines() {
        guard systemCards.isDecided, isOnScreen, !isLibraryOpen, !startedThisOpening, session == nil, summary == nil,
              let offer = model.nextReviewSession(), offer.kind == .due,
              offer.totalCount > ReviewView.breakBacklog else {
            showsBreakLines = false
            return
        }
        showsBreakLines = systemCards.claim(.breakStart)
    }

    // MARK: Reminder question

    /// After a round, once (2.8: never at the opening, when the feature is first used): "Her
    /// gün 1 hatırlatma gönderelim mi?". Only while the reminder is off and iOS has never asked
    /// (a "no" in iOS, or a switch turned off in "Ayarlar", is an answer), and not after another
    /// system card of this opening (2.10). Whatever the answer, it never comes again.
    private func offerReminderIfFirstTime() {
        guard canOfferReminder else {
            return
        }
        Task { @MainActor in
            let isAuthorized = await ReminderScheduler.isAuthorized()
            let isDenied = await ReminderScheduler.isDenied()
            // Again after the awaits: RootView may have shown its card meanwhile.
            guard !isAuthorized, !isDenied, canOfferReminder, session == nil else {
                return
            }
            reminderOfferShown = true
            showsReminderOffer = true
        }
    }

    /// Not asked yet, the reminder off, no onboarding, and RootView has decided this opening
    /// with no sheet of its own (two sheets at once: one would not open).
    private var canOfferReminder: Bool {
        guard !reminderOfferShown, !model.reminderEnabled, !model.showsOnboarding,
              systemCards.isDecided, systemCards.presented == nil else {
            return false
        }
        if let card = systemCards.current, card != .breakStart {
            return false
        }
        return true
    }

    /// "Evet, gönder": iOS asks for permission now. With it the daily reminder is on at the
    /// chosen time and the week's reminders are planned; without it nothing changes ("Ayarlar"
    /// then says how to allow notifications).
    private func acceptReminder(at minute: Int) {
        Task { @MainActor in
            guard await ReminderScheduler.requestPermission() else {
                return
            }
            model.setReminderMinuteOfDay(minute)
            model.setReminderEnabled(true)
            await ReminderScheduler.replace(with: model.reminderPlan())
        }
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

    /// VoiceOver hears `pieces` after the tap's own speech, so it is not cut off; the English
    /// pieces in an English voice (WCAG 3.1.2).
    private static func announce(_ pieces: [(text: String, english: Bool)]) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            let text = NSMutableAttributedString()
            for piece in pieces {
                text.append(NSAttributedString(
                    string: piece.text,
                    attributes: [.accessibilitySpeechLanguage: piece.english ? "en-US" : "tr-TR"]
                ))
            }
            text.addAttribute(
                .accessibilitySpeechQueueAnnouncement,
                value: true,
                range: NSRange(location: 0, length: text.length)
            )
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }

    /// When a wrong answer comes back: within the hour it is "bir sonraki turda" (the app sends
    /// one reminder a day and a round ends after its cards; a time in minutes is a promise nothing
    /// keeps, 2.3), otherwise the time as in `returnText`.
    private static func againText(until due: Date, from now: Date) -> String {
        return due.timeIntervalSince(now) <= 3600 ? QuizCardView.nextRoundTime : returnText(until: due, from: now)
    }

    /// Instead of a time: a failed "Biliyorum" check sends the word back to "Tanış" (2.2).
    private static let backToIntroText = "yeniden tanışacaksın"

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

/// Where VoiceOver is sent in a round (`ReviewView.focus`).
private enum ReviewFocus: Hashable {
    /// "Kart 3, toplam 10": the start of a quiz card.
    case counter
    /// The heading of a "Hatırla" or recall card: "Anlamını seç", "İngilizcesini hatırla".
    case question
    /// The English word on a "Tanış" card's front, or on a recall card after "Göster".
    case word
    /// The Turkish meaning on the back.
    case meaning
    /// The English definition on the back of a card without a Turkish meaning.
    case definition
    /// The first line of the round summary.
    case summary
    /// The heading of the start or done screen, after "Tamam" or an empty "Bitir".
    case start
}

/// How an answer is named in the summary, with its icon, worst to best.
private struct AnswerLabel {
    let title: String
    let symbol: String

    /// A quiz answer.
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

    /// The recall screen.
    init(found: Bool) {
        title = found ? "Buldum" : "Bulamadım"
        symbol = found ? "checkmark" : "xmark"
    }

    /// "Hatırla".
    init(_ result: IntroRound.Result) {
        switch result {
        case .firstTry:
            title = "Bildim"
            symbol = "checkmark"
        case .secondTry:
            // Right after a wrong answer: "Zor" (2.3), back in 12 hours.
            title = "Zor"
            symbol = "tortoise"
        case .missed:
            title = "Bilemedim"
            symbol = "xmark"
        }
    }
}

/// One answer of a round, for the summary.
private struct RoundAnswer {
    let word: WidgetWord
    let grade: ReviewGrade
    /// When the word comes back (`WordProgress.dueAt` right after the answer).
    let dueAt: Date?
    /// The word had never been reviewed before this answer.
    let wasNew: Bool
    let label: AnswerLabel
    /// A failed "Biliyorum" check sent the word back to "Tanış".
    var returnsToIntro = false
}

/// The English word with the phosphor band (rule 1): one line at the Large Title size
/// (`englishWordStyle()`, 34 pt, the same on every Tekrar card); a long phrase that does not fit
/// drops to the Title 1 size (28 pt) first, then breaks into two balanced lines at that size,
/// each on its own band, as in the feed and the dictionary (audit D1: "Could you tell me the way
/// to" must not end in "…"). A single long word shrinks with `englishWordStyle`'s scale factor
/// instead. VoiceOver reads it once, as a heading, with an English voice.
private struct WordHeadline: View {
    let lemma: String
    let alignment: HorizontalAlignment

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Text(verbatim: lemma)
                .englishWordStyle()
                .phosphorBand()
            smallLine(lemma)
            if let lines = WordHeadline.balancedLines(lemma) {
                // 16 pt: the night band under the first line needs 8 pt before the second.
                VStack(alignment: alignment, spacing: 16) {
                    smallLine(lines.first)
                    smallLine(lines.second)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: lemma))
        .accessibilityAddTraits(.isHeader)
        .englishVoice()
    }

    /// The Title 1 step (28 pt), scaled like the word up to 46 pt.
    private func smallLine(_ text: String) -> some View {
        Text(verbatim: text)
            .englishWordStyle(size: 28, maxSize: 46)
            .phosphorBand()
    }

    /// `phrase` cut at the space that makes the longer line shortest; nil for a single word
    /// (same rule as the feed's `WordCardHeadline`).
    static func balancedLines(_ phrase: String) -> (first: String, second: String)? {
        let words = phrase.split(separator: " ").map(String.init)
        guard words.count > 1 else {
            return nil
        }
        var best: (first: String, second: String)?
        var bestLength = Int.max
        for cut in 1..<words.count {
            let first = words[..<cut].joined(separator: " ")
            let second = words[cut...].joined(separator: " ")
            let longer = max(first.count, second.count)
            // On a tie the later cut: a longer first line reads more naturally.
            if longer <= bestLength {
                bestLength = longer
                best = (first, second)
            }
        }
        return best
    }
}

/// "Devamı" on the card's bottom edge (mockup `.wcard.scrolls.more`): the text fades out above it
/// and is fully faded under it (`cardPanel`'s mask), so it never covers a legible line. Not a
/// capsule, since it is not a control (rule 2); visual only, VoiceOver reads on by itself.
private struct MoreBelowCue: View {
    /// Above the text: the mask's fade ends just under it.
    static let topPadding: CGFloat = 26

    var body: some View {
        HStack(spacing: 4) {
            Text("Devamı")
            Image(systemName: "chevron.down")
                .imageScale(.small)
        }
        // Callout like the card's other small lines and the round's header on this card.
        .font(.callout.weight(.semibold))
        .foregroundStyle(Theme.ink2)
        .padding(.top, MoreBelowCue.topPadding)
        .padding(.bottom, 9)
        .frame(maxWidth: .infinity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Mockup `.prog`: a 6 pt `surface3` track filled with `tint` (ink, never yellow). With Increase
/// Contrast the empty track gets an edge (audit K2). Hidden from VoiceOver: the heading "Kart 3,
/// toplam 10" says where the round is, and a second count one card behind only confuses (V12).
private struct RoundProgressBar: View {
    let done: Int
    let total: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        let fraction = total > 0 ? min(1, max(0, CGFloat(done) / CGFloat(total))) : 0
        Capsule()
            .fill(Theme.surface3)
            .frame(height: 6)
            .overlay {
                if contrast == .increased {
                    Capsule().strokeBorder(Theme.lineStrong, lineWidth: 1)
                }
            }
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Theme.tint)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: fraction)
            .accessibilityHidden(true)
    }
}

/// The text of an answer button (mockup `.grade`): icon, answer and when the word comes back.
/// The time is legible but secondary: regular weight, footnote, `ink2`, and it stays at every
/// text size (audit D2). The icon goes as soon as title and time no longer fit beside it, so
/// "Bulamadım" never breaks mid-word (audit D8).
private struct GradeLabel: View {
    let title: String
    let symbol: String
    let when: String?
    /// The icon's column grows with the text, so a large icon never runs into the title.
    @ScaledMetric(relativeTo: .body) private var iconWidth: CGFloat = 22

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.body.weight(.medium))
                    .frame(width: iconWidth)
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
                texts
            }
            texts
        }
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(verbatim: title)
                .font(.body.weight(.semibold))
                // Even without the icon: shrink a little rather than break "Bulamadım".
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            if let when = when {
                Text(verbatim: when)
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(Theme.ink2)
            }
        }
        .multilineTextAlignment(.leading)
    }
}

/// Answer button (mockup `.grade`): a 56 pt capsule in `surface2` with a `lineStrong` edge, like
/// the theme's other tonal capsules (rule 2: what can be tapped is a capsule). "Bulamadım" and
/// "Buldum" are equal: no filled default (1b). Opaque, never glass (rule 6).
private struct GradeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GradeButtonBody(configuration: configuration)
    }
}

private struct GradeButtonBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityShowButtonShapes) private var showsButtonShapes

    var body: some View {
        let shape = Capsule()
        configuration.label
            .foregroundStyle(Theme.ink)
            // The icon sits at the round end's middle, where the curve leaves the most room; the
            // text keeps the half-width tile's room for "10 dakika sonra" on an iPhone SE.
            .padding(.leading, 16)
            .padding(.trailing, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 56, maxHeight: .infinity, alignment: .leading)
            .background(Theme.surface2, in: shape)
            // `surface2` barely stands out from the page: always an edge, stronger with Increase
            // Contrast or Button Shapes (audit K1).
            .overlay {
                shape.strokeBorder(Theme.lineStrong, lineWidth: contrast == .increased || showsButtonShapes ? 1.5 : 1)
            }
            .contentShape(shape)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// "Bunu zaten biliyorum" (2.3): a plain text button, ink, a 44 pt target; with Button Shapes an
/// underline says it can be tapped.
private struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QuietButtonBody(configuration: configuration)
    }
}

private struct QuietButtonBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityShowButtonShapes) private var showsButtonShapes

    var body: some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .underline(showsButtonShapes)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

/// A "Hatırla" option only fades while pressed; its look is drawn by the label.
private struct PressFadeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Mockup `.toast`: an ink bar with "Tamam. 3 gün sonra bir kez soracağız." and "Geri al", where
/// "Bunu zaten biliyorum" was tapped. At accessibility text sizes "Geri al" goes under the
/// message.
private struct KnownUndoNotice: View {
    let message: String
    let undo: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(spacing: 10))
        layout {
            Text(verbatim: message)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: undo) {
                Text("Geri al")
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 14)
                    .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
                    // A faint wash of the page color on the ink bar (a token, not a raw gray).
                    .background(Theme.bg.opacity(0.2), in: Capsule())
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Theme.bg)
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(Theme.ink, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

/// The reminder question after the first round (ogrenme_ilkeleri 2.8), as a short sheet like the
/// system cards: a "when" plan ("Ne zaman bakarsın?", four usual moments; the chosen time is filled
/// in and can be changed) and two answers of the same size. "Şimdi değil" blames no one; swiping
/// the sheet away is "Şimdi değil" too. iOS asks for permission only after "Evet, gönder".
private struct ReminderOfferSheet: View {
    /// "Evet, gönder" with the chosen minute after midnight; the sheet closes itself.
    let accept: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var minute: Int
    @State private var height: CGFloat = 0
    /// The pinned answers' strip (not at accessibility sizes, where the whole page scrolls).
    @State private var footerHeight: CGFloat = 0

    private struct Moment {
        let title: String
        /// Minutes after midnight.
        let minute: Int
    }

    private static let moments = [
        Moment(title: "Sabah kahvesiyle", minute: 8 * 60),
        Moment(title: "İşe giderken", minute: 8 * 60 + 30),
        Moment(title: "Akşam", minute: 20 * 60),
        Moment(title: "Yatmadan önce", minute: 22 * 60 + 30),
    ]

    /// `initialMinute`: what the "when" plan starts with, the reminder time already saved (20:00
    /// by default).
    init(initialMinute: Int, accept: @escaping (Int) -> Void) {
        self.accept = accept
        _minute = State(initialValue: initialMinute)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 12) {
                    // Stops growing at xxxLarge, so it stays in its 32 pt column.
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundStyle(Theme.ink)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .frame(width: 32)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Her gün 1 hatırlatma gönderelim mi?")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                            .accessibilityAddTraits(.isHeader)
                        Text("Bildirim bir kelimeyi anlamıyla gösterir. O günün işini bitirdiysen gelmez.")
                            .font(.body)
                            .foregroundStyle(Theme.ink2)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ne zaman bakarsın?")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(ReminderOfferSheet.moments, id: \.minute) { moment in
                        ChoiceRow(isSelected: minute == moment.minute) {
                            minute = moment.minute
                        } label: {
                            Text(verbatim: "\(moment.title) (\(ReminderOfferSheet.clockTime(moment.minute)))")
                                .font(.body.weight(.medium))
                                .foregroundStyle(Theme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    DatePicker(selection: timeBinding, displayedComponents: .hourAndMinute) {
                        Text("Saat")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Theme.ink)
                    }
                    // 24-hour "20:00" like the choices and clockTime (README point 13), whatever the region.
                    .environment(\.locale, Locale(identifier: "tr_TR"))
                    .padding(.horizontal, 4)
                    .padding(.top, 2)
                }
                VStack(spacing: 10) {
                    Text("iPhone bir kez izin soracak. Ayarlar'dan her zaman değiştirebilirsin.")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // At accessibility sizes the answers scroll with the page: a pinned strip
                    // that tall would take over an SE's screen.
                    if dynamicTypeSize.isAccessibilitySize {
                        answers
                    }
                }
            }
            // The 16 pt side margins of every screen.
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 16)
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.size.height
            } action: { newHeight in
                height = newHeight
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        // Shows once that the moments scroll when the sheet is taller than the screen (SE).
        .scrollIndicatorsFlash(onAppear: true)
        // Both answers always in sight (2026-10-24 SE image: "Şimdi değil" was cut by the screen's
        // edge), on an opaque strip like the Tekrar screens' answers, so nothing shows through.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !dynamicTypeSize.isAccessibilitySize {
                answers
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity)
                    .background(Theme.sheetBg)
                    .onGeometryChange(for: CGFloat.self) { geometry in
                        geometry.size.height
                    } action: { newHeight in
                        footerHeight = newHeight
                    }
            }
        }
        .presentationDetents(detents)
        .presentationDragIndicator(.visible)
        // Elevated at night (`sheetBg`): the sheet's edge stands out from the black page.
        .presentationBackground(Theme.sheetBg)
    }

    /// The two answers, the same height (2.8): "Şimdi değil" is never the smaller one.
    private var answers: some View {
        VStack(spacing: 10) {
            Button("Evet, gönder") {
                accept(minute)
                dismiss()
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 50))
            Button("Şimdi değil") {
                dismiss()
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 50))
        }
    }

    /// As tall as the content, the pinned answers and the home indicator's strip (like
    /// `SystemCardSheet`); on a short screen it is the large detent and the moments scroll.
    private var detents: Set<PresentationDetent> {
        if height > 0 {
            let footer = dynamicTypeSize.isAccessibilitySize ? 0 : footerHeight
            return [.height(height + footer + 34)]
        }
        return [.large]
    }

    /// The picker edits the chosen minute; a moment row then shows as chosen again only when the
    /// time is its own.
    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: minute / 60, minute: minute % 60, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                minute = (parts.hour ?? 20) * 60 + (parts.minute ?? 0)
            }
        )
    }

    /// "08:30", never followed by a suffix (README point 13).
    private static func clockTime(_ minuteOfDay: Int) -> String {
        return String(format: "%02d:%02d", minuteOfDay / 60, minuteOfDay % 60)
    }
}

/// How many words the due round has (mockup `.count-badge`), never the whole pile: a number in a
/// thin ring, no color. Text styles (Large Title, Subheadline) that stop growing at xxxLarge, as
/// the ring stops at 124 pt; "Başla (10 kelime)" under it says the number at every size.
private struct CountBadge: View {
    let count: Int
    @ScaledMetric(relativeTo: .title) private var diameter: CGFloat = 96

    var body: some View {
        let size = min(diameter, 124)
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.largeTitle.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text("kelime")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.ink2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .padding(10)
        .frame(width: size, height: size)
        .overlay {
            Circle()
                .strokeBorder(Theme.lineStrong, lineWidth: 2)
        }
        // "Başla (10 kelime)" under it says the same number.
        .accessibilityHidden(true)
    }
}

/// Today's new-word goal (mockup `.pring`): a `surface3` track and a `tint` arc (never yellow);
/// with Increase Contrast the empty track gets edges (audit K2). Only words recalled in "Hatırla"
/// count (2.3). VoiceOver hears words, not "2 / 5" ("bölü", text audit #9).
private struct GoalRing: View {
    let done: Int
    let goal: Int
    /// 144 pt: "günlük hedef" fits whole inside the ring with room to the track (at 132 pt its
    /// descender nearly touched the ring, 2026-10-24 images).
    @ScaledMetric(relativeTo: .title) private var diameter: CGFloat = 144
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        let size = min(diameter, 172)
        let lineWidth = size / 12
        let fraction = goal > 0 ? min(1, CGFloat(done) / CGFloat(goal)) : 0
        ZStack {
            Circle()
                .inset(by: lineWidth / 2)
                .stroke(Theme.surface3, lineWidth: lineWidth)
            if contrast == .increased {
                Circle()
                    .strokeBorder(Theme.lineStrong, lineWidth: 1)
                Circle()
                    .inset(by: lineWidth)
                    .strokeBorder(Theme.lineStrong, lineWidth: 1)
            }
            if fraction > 0 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 0, to: fraction)
                    .stroke(Theme.tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            // Text styles (Large Title, Subheadline as the count badge's "kelime" and the start
            // screen's today line: no fifth size there) that stop growing at xxxLarge, as the ring
            // stops at 172 pt; at accessibility sizes the goal is also said under the ring. The
            // text is at most 80 % of the inner circle wide, so its widest line keeps clear of the
            // track; a wider line shrinks a little (at most to 70 %) rather than touch it.
            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(done)")
                        .foregroundStyle(Theme.ink)
                    Text("/\(goal)")
                        .foregroundStyle(Theme.ink3)
                }
                .font(.largeTitle.weight(.bold))
                .monospacedDigit()
                Text("günlük hedef")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.ink2)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .frame(maxWidth: (size - 2 * lineWidth) * 0.8)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: spokenGoal))
    }

    /// "Günlük hedef 5 yeni kelime. Bugün 2 tanesini çalıştın." (no "0 tanesini" before the first).
    private var spokenGoal: String {
        let goalText = "Günlük hedef \(goal) yeni kelime."
        return done > 0 ? goalText + " Bugün \(done) tanesini çalıştın." : goalText
    }
}

/// The done screen's check on a phosphor stroke (mockup `.bandcheck`): by day the check sits on
/// the highlighter, at night the band is a line under it, so the check never stands on yellow;
/// its faint glow follows the band's rule (none with Increase Contrast, Reduce Transparency or
/// the dimmed Always-On display). Still, no motion: the day is done, not won.
private struct DoneMark: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                if contrast != .increased && !reduceTransparency && !isLuminanceReduced {
                    Capsule()
                        .fill(Theme.bandGlow)
                        .frame(width: 104, height: 10)
                        .blur(radius: 6)
                        .offset(y: 22)
                }
                // As thin as the word's night line (0.13 em of the 40 pt check, about 5 pt), not a
                // filled yellow bar.
                PhosphorBandShape(slant: 4)
                    .fill(Theme.bandDark)
                    .frame(width: 104, height: 5)
                    .offset(y: 21)
            } else {
                PhosphorBandShape(slant: 10)
                    .fill(Theme.bandLight)
                    .frame(width: 104, height: 42)
                    .offset(y: 4)
            }
            // A glyph sized to the drawn band under it (104 × 42 pt), not text: a fixed size.
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
            // The glyph stops growing at xxxLarge, so it stays inside its 36 pt circle.
            Image(systemName: symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.ink)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
/// back and how it was answered. The answer is plain text with its icon, not a capsule (rule 2:
/// capsules are for what can be tapped). Stacked at accessibility sizes.
private struct SummaryRow: View {
    let answer: RoundAnswer
    let when: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
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
                    Image(systemName: answer.label.symbol)
                        .font(.caption2.weight(.semibold))
                        .accessibilityHidden(true)
                    Text(verbatim: answer.label.title)
                }
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
            }
            // Stacked at accessibility sizes, "10 dakika sonra" may wrap instead of overflowing
            // the card (audit D6).
            .fixedSize(horizontal: !isLarge, vertical: false)
        }
        .padding(.vertical, 10)
        // Not `.combine`: one element has one voice, and the word needs its English one (audit
        // V5). Two stops: "borrow", then "ödünç almak, yarın, Bildim".
        .accessibilityRepresentation {
            Text(verbatim: answer.word.lemma)
                .englishVoice()
            Text(verbatim: [answer.word.glossTR, when, answer.label.title].compactMap { $0 }.joined(separator: ", "))
        }
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
        // Not `.combine`: the word keeps its English voice, the meaning its Turkish one (audit V5).
        .accessibilityElement(children: .contain)
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
