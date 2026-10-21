import SwiftUI
import CoreModels
import Learning

/// Vertical paging feed: one full-page card per word of the user's deck (iOS 17 scroll APIs).
/// At accessibility text sizes there are no pages: each card is as tall as its content and
/// scrolls with the feed, never on its own (README rule 5). No counter, no page dots.
struct FeedView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var scrolledWordID: Int?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The whole card, opened from a shortened card's "Dikkat" or "Kartın devamı" row.
    @State private var detailWord: WidgetWord?

    var body: some View {
        VStack(spacing: 0) {
            header
            if model.feedWords.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                pager
            }
        }
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .sheet(item: $detailWord) { word in
            NavigationStack {
                WordDetailView(word: word)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") {
                                detailWord = nil
                            }
                        }
                    }
            }
            .environmentObject(model)
        }
    }

    /// Mockup `.hdr`: the screen's name, small, so the card keeps the room.
    private var header: some View {
        Text("Akış")
            .font(.headline.weight(.bold))
            .foregroundStyle(Theme.ink)
            .accessibilityAddTraits(.isHeader)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.horizontal, 20)
    }

    private var pager: some View {
        let isPaged = !dynamicTypeSize.isAccessibilitySize
        return ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(model.feedWords) { word in
                    card(for: word, isPaged: isPaged)
                        .containerRelativeFrame(isPaged ? [.horizontal, .vertical] : [.horizontal])
                }
            }
            .scrollTargetLayout()
        }
        .modifier(FeedPagingModifier(isEnabled: isPaged))
        .scrollPosition(id: $scrolledWordID)
        .scrollIndicators(isPaged ? .hidden : .automatic)
    }

    private func card(for word: WidgetWord, isPaged: Bool) -> some View {
        let words = model.feedWords
        return WordCardView(
            word: word,
            detail: model.detail(for: word),
            fillsPage: true,
            known: knownControl(for: word),
            showsSwipeHint: words.count > 1 && word.id == words.first?.id,
            openDetail: {
                detailWord = word
            },
            outerPadding: EdgeInsets(top: 4, leading: 14, bottom: isPaged ? 12 : 16, trailing: 14)
        )
    }

    /// "Biliyorum" under the card: the same change as the widget button and the "Sözlük" card.
    private func knownControl(for word: WidgetWord) -> WordCardView.KnownControl {
        let animation: Animation? = reduceMotion ? nil : .easeOut(duration: 0.2)
        return WordCardView.KnownControl(
            isKnown: model.learningState(of: word) == .known,
            markKnown: {
                withAnimation(animation) {
                    model.markKnown(word)
                }
            },
            undoKnown: {
                withAnimation(animation) {
                    model.undoKnown(word)
                }
            }
        )
    }

    @ViewBuilder
    private var emptyState: some View {
        switch model.contentSource {
        case .loading:
            ProgressView()
        default:
            ContentUnavailableView(
                "İçerik bulunamadı",
                systemImage: "tray",
                description: Text("content.sqlite ve seed_words.json pakete eklenmemiş.")
            )
        }
    }
}

/// Page-by-page scrolling, off at accessibility text sizes (README point 7).
private struct FeedPagingModifier: ViewModifier {
    let isEnabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content.scrollTargetBehavior(.paging)
        } else {
            content
        }
    }
}

/// The word card. Reading order for an A2 learner: the English word on its phosphor band, the
/// pronunciation, part of speech and level with "Dinle" (and "Söyle"), the Turkish meaning
/// (large, no box), the simple English definition, the example with its Turkish translation,
/// then one typical mistake ("Dikkat"). `detail` is nil for seed words: the card then shows the
/// example without a translation and no "Dikkat".
///
/// In the feed (`fillsPage`) the card fills its page and, where there is room, adds the word's
/// further examples at the end. Where there is not, it shortens itself from the end (rule 5,
/// "kart sondan kısalır"): first smaller text without the Lock Screen label and "Ayrıca", then
/// no Dikkat explanation, then Dikkat as one row, then the example in that row too; the rows open
/// the whole card (`openDetail`). At accessibility text sizes it always shows everything at its
/// natural height. Elsewhere (the onboarding) it is as tall as its content.
/// `showsSay: false` hides the microphone (a card shown where no permission prompt may appear).
struct WordCardView: View {
    /// "Biliyorum" at the bottom of a feed card: whether the word is known, and the two changes.
    struct KnownControl {
        let isKnown: Bool
        let markKnown: () -> Void
        let undoKnown: () -> Void
    }

    let word: WidgetWord
    let detail: CardDetail?
    var showsSay = true
    var fillsPage = false
    /// "Şu an kilitli ekranda" above the word: only for the word the Lock Screen widget shows
    /// (README "Akış").
    var isOnLockScreen = false
    /// nil: no "Biliyorum" row (the onboarding).
    var known: KnownControl? = nil
    /// "Yukarı kaydır" next to "Biliyorum" (the feed's first card).
    var showsSwipeHint = false
    /// Opens the whole card; the last two shortening steps need it.
    var openDetail: (() -> Void)? = nil
    /// Around the card; the onboarding cancels the horizontal 16 pt with its own padding.
    var outerPadding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let maxHeight: CGFloat? = isPaged ? .infinity : nil
        VStack(alignment: .leading, spacing: 0) {
            content
            if let known = known {
                footer(known)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: maxHeight, alignment: .topLeading)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
        // Borderless controls inside (the "Söyle" microphone) take ink, never the blue default.
        .tint(Theme.ink)
        .padding(outerPadding)
        // Not combined into one element: the buttons must stay reachable on their own.
        .accessibilityElement(children: .contain)
    }

    /// Sized to its page, with the shortening steps. Never at accessibility text sizes.
    private var isPaged: Bool {
        return fillsPage && !dynamicTypeSize.isAccessibilitySize
    }

    private var mistake: CardDetail.Mistake? {
        return detail?.mistakes.first
    }

    /// The widget's example (`example_en` is the card's first example) with its translation.
    private var firstExample: CardDetail.Example {
        return CardDetail.Example(en: word.exampleEN, tr: detail?.examples.first?.tr)
    }

    /// Further examples for a card with room to spare: at most two.
    private var moreExamples: [CardDetail.Example] {
        return Array((detail?.examples ?? []).dropFirst().prefix(2))
    }

    private var alternatives: [String] {
        return detail?.glossAlternatives ?? []
    }

    // MARK: Shortening (rule 5)

    private enum FitStep: Int {
        /// Everything.
        case full
        /// 1. Smaller meaning and definition, tighter spacing; no Lock Screen label, no "Ayrıca".
        case smaller
        /// 2. Without the Dikkat explanation.
        case noWhy
        /// 3. Dikkat as one row.
        case mistakeRow
        /// 4. The example in that row too ("Kartın devamı").
        case exampleRow

        var isSmaller: Bool {
            return self != .full
        }
    }

    @ViewBuilder
    private var content: some View {
        if isPaged {
            // The first step whose height fits the page wins; the last one is used regardless.
            ViewThatFits(in: .vertical) {
                if moreExamples.count > 1 {
                    cardContent(.full, extraExamples: 2)
                }
                if !moreExamples.isEmpty {
                    cardContent(.full, extraExamples: 1)
                }
                cardContent(.full)
                cardContent(.smaller)
                if mistake != nil {
                    cardContent(.noWhy)
                }
                if mistake != nil && openDetail != nil {
                    cardContent(.mistakeRow)
                }
                if openDetail != nil {
                    cardContent(.exampleRow)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        } else {
            cardContent(.full)
        }
    }

    private func cardContent(_ step: FitStep, extraExamples: Int = 0) -> some View {
        VStack(alignment: .leading, spacing: step.isSmaller ? 8 : 12) {
            if isOnLockScreen && !step.isSmaller {
                WordCardLockScreenChip()
            }
            // The night band hangs below the word: at least 8 pt before the next row.
            WordCardHeadline(lemma: word.lemma)
                .padding(.bottom, step.isSmaller ? 2 : 0)
            metaRow
            meaning(step)
            Text(word.defShort)
                .font(step.isSmaller ? Theme.Fonts.example : Theme.Fonts.definition)
                .foregroundStyle(Theme.ink)
                .lineSpacing(step.isSmaller ? 1 : 2)
                .lineLimit(step == .exampleRow ? 3 : nil)
                .cardEnglishVoice()
            if step == .exampleRow {
                detailRow(
                    systemImage: "book",
                    iconColor: Theme.ink2,
                    title: "Kartın devamı",
                    subtitle: mistake == nil ? "Örnek cümle" : "Örnek cümle ve Dikkat notu"
                )
            } else {
                exampleBlock
                if let mistake = mistake {
                    if step == .mistakeRow {
                        detailRow(
                            systemImage: "exclamationmark.triangle",
                            iconColor: Theme.caution,
                            title: "Dikkat",
                            subtitle: "Sık yapılan hatayı gör"
                        )
                    } else {
                        MistakeBox(mistake: mistake, showsWhy: step.rawValue < FitStep.noWhy.rawValue)
                    }
                }
                if extraExamples > 0 {
                    moreExamplesBlock(Array(moreExamples.prefix(extraExamples)))
                }
            }
        }
        .padding(.top, 18)
        .padding(.horizontal, 20)
        .padding(.bottom, known == nil ? 20 : 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Parts

    /// Pronunciation, part of speech and level, then "Dinle" and "Söyle" (mockup `.wmeta`). When
    /// they do not fit on one line the buttons move to a second line, then the facts break up too.
    private var metaRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                ipa
                partOfSpeech
                LevelBadge(code: word.level)
                Spacer(minLength: 4)
                actions
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    ipa
                    partOfSpeech
                    LevelBadge(code: word.level)
                }
                actions
            }
            VStack(alignment: .leading, spacing: 6) {
                ipa
                HStack(spacing: 8) {
                    partOfSpeech
                    LevelBadge(code: word.level)
                }
                actions
            }
        }
    }

    /// Visual only: VoiceOver says the word itself, and "Dinle" plays it.
    @ViewBuilder
    private var ipa: some View {
        if let ipa = word.ipaUS {
            Text(ipa)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
        }
    }

    private var partOfSpeech: some View {
        Text(CardPartOfSpeech.turkish(word.pos))
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.ink2)
    }

    private var actions: some View {
        HStack(spacing: 2) {
            CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle")
            if showsSay {
                SayButton(word: word, example: word.exampleEN)
            }
        }
    }

    @ViewBuilder
    private func meaning(_ step: FitStep) -> some View {
        if let gloss = word.glossTR {
            VStack(alignment: .leading, spacing: 2) {
                Text(gloss)
                    .font(step.isSmaller ? Font.title2.weight(.bold) : Theme.Fonts.meaning)
                    .foregroundStyle(Theme.ink)
                    .accessibilityLabel(Text(verbatim: "Türkçesi: " + gloss))
                if !step.isSmaller && !alternatives.isEmpty {
                    Text("Ayrıca: " + alternatives.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                }
            }
        }
    }

    /// Mockup `.exblock`: a rule, "Örnek" with the sentence's speaker, the sentence with the
    /// learned word marked (the band's yellow, rule 1), its Turkish translation.
    private var exampleBlock: some View {
        let example = firstExample
        return VStack(alignment: .leading, spacing: 4) {
            WordCardRule()
            HStack(spacing: 8) {
                sectionLabel("Örnek")
                Spacer(minLength: 8)
                CardSentenceSpeaker(text: example.en, accessibilityName: "Cümleyi dinle")
                    .padding(.vertical, -6)
            }
            .frame(minHeight: 32)
            .padding(.top, 6)
            Text(ExampleMark.attributed(example.en, lemma: word.lemma, colorScheme: colorScheme))
                .exampleStyle()
                .lineSpacing(2)
                .cardEnglishVoice()
            if let tr = example.tr {
                Text(tr)
                    .exampleTranslationStyle()
            }
        }
    }

    /// The further examples (only on a card with room left): the word bold, not marked.
    private func moreExamplesBlock(_ examples: [CardDetail.Example]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            WordCardRule()
            sectionLabel("Başka örnekler")
                .frame(minHeight: 32, alignment: .leading)
                .padding(.top, 6)
            ForEach(Array(examples.enumerated()), id: \.offset) { index, example in
                if index > 0 {
                    WordCardRule()
                        .padding(.vertical, 4)
                }
                ExampleRow(example: example, lemma: word.lemma)
            }
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.ink2)
            .accessibilityAddTraits(.isHeader)
    }

    /// One row in place of a part that no longer fits (mockup `.mrow`); opens the whole card.
    private func detailRow(systemImage: String, iconColor: Color, title: String, subtitle: String) -> some View {
        Button {
            openDetail?()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(iconColor)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Text(subtitle)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.ink2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(minHeight: 52)
            .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: Footer

    /// Mockup `.foot`: "Biliyorum", or for a known word "Bildiğin kelime" with "Geri al".
    private func footer(_ known: KnownControl) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                knownControls(known)
                Spacer(minLength: 8)
                if showsSwipeHint {
                    swipeHint
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                knownControls(known)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 14)
    }

    @ViewBuilder
    private func knownControls(_ known: KnownControl) -> some View {
        if known.isKnown {
            Label("Bildiğin kelime", systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.good)
                .padding(.leading, 4)
            Button("Geri al", action: known.undoKnown)
                .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
        } else {
            Button(action: known.markKnown) {
                Label("Biliyorum", systemImage: "checkmark")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
        }
    }

    /// The first card shows where the next one is. Visual only: VoiceOver moves on by itself.
    private var swipeHint: some View {
        HStack(spacing: 4) {
            Image(systemName: "chevron.up")
            Text("Yukarı kaydır")
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Theme.ink2)
        .lineLimit(1)
        .accessibilityHidden(true)
    }
}

/// The English word on its phosphor band. A phrase too long for one line at the full size first
/// tries a smaller size, then breaks into two balanced lines, each on its own band; a single long
/// word shrinks instead. VoiceOver reads it once, as a heading, with an English voice.
private struct WordCardHeadline: View {
    let lemma: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            line(lemma, size: 40)
            line(lemma, size: 32)
            if let lines = WordCardHeadline.balancedLines(lemma) {
                VStack(alignment: .leading, spacing: 10) {
                    line(lines.first, size: 36)
                    line(lines.second, size: 36)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: lemma))
        .accessibilityAddTraits(.isHeader)
        .cardEnglishVoice()
    }

    private func line(_ text: String, size: CGFloat) -> some View {
        Text(text)
            .englishWordStyle(size: size, maxSize: size * 1.4)
            .phosphorBand()
    }

    /// `phrase` cut at the space that makes the longer line shortest; nil for a single word.
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

/// "Şu an kilitli ekranda" (mockup `.now-chip`).
private struct WordCardLockScreenChip: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock")
                .imageScale(.small)
                .accessibilityHidden(true)
            Text("Şu an kilitli ekranda")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Theme.ink2)
        .padding(.horizontal, 10)
        .frame(minHeight: 26)
        .background(Theme.surface2, in: Capsule())
    }
}

/// A 1 pt `line` rule (mockup `border-top: 1px solid var(--line)`).
private struct WordCardRule: View {
    var body: some View {
        Rectangle()
            .fill(Theme.line)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}
