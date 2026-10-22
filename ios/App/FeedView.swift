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
    /// The whole card, opened from a shortened card's "Dikkat" or "Örnek cümle" row.
    @State private var detailWord: WidgetWord? = nil
    /// "Yukarı kaydır" is retired for good once the user has moved through a few cards.
    @AppStorage("lockglow.feedHintSeen") private var feedHintSeen = false
    /// Card changes in this session, up to `hintCardChanges`.
    @State private var cardChanges = 0

    /// After this many card changes the user knows how the feed moves.
    private static let hintCardChanges = 3
    /// Below a paged card, above the tab bar; the tab bar veil fades in over it.
    private static let pageBottomGap: CGFloat = 12

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
        .overlay {
            tabBarVeil
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
            // Rule 2: no blue link color on "Kapat" or the card's buttons.
            .tint(Theme.ink)
            .environmentObject(model)
        }
    }

    /// Mockup `.hdr`: the screen's name, small, so the card keeps the room (same height and
    /// margin as the "Tekrar" header).
    private var header: some View {
        Text("Akış")
            .font(.headline.weight(.bold))
            .foregroundStyle(Theme.ink)
            .accessibilityAddTraits(.isHeader)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 16)
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
        .onChange(of: scrolledWordID) { oldID, newID in
            noteCardChange(from: oldID, to: newID)
        }
    }

    /// The glass tab bar floats over the feed, and the next card's top (its yellow band) would
    /// show through it. Under the bar lies the page's paper instead; its top edge fades over the
    /// gap below the card, so a card coming up appears softly rather than at a hard line.
    private var tabBarVeil: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                LinearGradient(colors: [Theme.bg.opacity(0), Theme.bg], startPoint: .top, endPoint: .bottom)
                    .frame(height: FeedView.pageBottomGap)
                Theme.bg
                    .frame(height: proxy.safeAreaInsets.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea(edges: .bottom)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func card(for word: WidgetWord, isPaged: Bool) -> some View {
        let words = model.feedWords
        return WordCardView(
            word: word,
            detail: model.detail(for: word),
            fillsPage: true,
            // Only while a Lockglow widget is on the Lock Screen (last health check).
            isOnLockScreen: model.hasLockScreenWidget && word.id == model.lockScreenWordID,
            known: knownControl(for: word),
            // Until the user has swiped a few times; never on the last card.
            showsSwipeHint: !feedHintSeen && word.id != words.last?.id,
            openDetail: {
                detailWord = word
            },
            outerPadding: EdgeInsets(top: 4, leading: 14, bottom: isPaged ? FeedView.pageBottomGap : 16, trailing: 14)
        )
    }

    /// Counts the cards the user moves to; after `hintCardChanges` of them the hint is gone.
    private func noteCardChange(from oldID: Int?, to newID: Int?) {
        guard !feedHintSeen, newID != nil, newID != oldID else {
            return
        }
        cardChanges += 1
        if cardChanges >= FeedView.hintCardChanges {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                feedHintSeen = true
            }
        }
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
/// example without a translation and no "Dikkat". Few labels: a rule sets the example apart, and
/// "Dikkat" is the only part with a name.
///
/// In the feed (`fillsPage`) the card fills its page. A tall page first gets the card's second
/// example; what room is left widens the gaps between the parts a little (`extraGap`), so the
/// card does not end in one empty block above "Biliyorum". Where the page is too short, the
/// card shortens itself from the end (rule 5, "kart sondan kısalır"): first no second example,
/// then smaller text without the Lock Screen label and "Ayrıca", then no Dikkat explanation,
/// then Dikkat as one row, then the example in that row too; the rows open the whole card
/// (`openDetail`). At accessibility text sizes it always shows everything (one example) at its
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
    /// right now (README "Akış", `AppModel.lockScreenWordID`).
    var isOnLockScreen = false
    /// nil: no "Biliyorum" row (the onboarding).
    var known: KnownControl? = nil
    /// "Yukarı kaydır" next to "Biliyorum" (the feed's first few cards).
    var showsSwipeHint = false
    /// Opens the whole card; the last two shortening steps need it.
    var openDetail: (() -> Void)? = nil
    /// Around the card; the onboarding cancels the horizontal 16 pt with its own padding.
    var outerPadding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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

    /// The card's first example (`example_en`) with its translation.
    private var firstExample: CardDetail.Example {
        return CardDetail.Example(en: word.exampleEN, tr: detail?.examples.first?.tr)
    }

    /// The card's next example, for a page with room to spare; nil for seed words and cards with
    /// one example.
    private var secondExample: CardDetail.Example? {
        return detail?.examples.dropFirst().first { $0.en != word.exampleEN }
    }

    private var alternatives: [String] {
        return detail?.glossAlternatives ?? []
    }

    // MARK: Fitting the page (rule 5)

    private enum FitStep: Int {
        /// Everything and a second example: only where the page has room for it.
        case roomy
        /// Everything.
        case full
        /// 1. Smaller meaning and definition, tighter spacing; no Lock Screen label, no "Ayrıca".
        case smaller
        /// 2. Without the Dikkat explanation.
        case noWhy
        /// 3. Dikkat as one row.
        case mistakeRow
        /// 4. The example in that row too.
        case exampleRow

        var isSmaller: Bool {
            return rawValue >= FitStep.smaller.rawValue
        }
    }

    /// The most a gap between the card's parts grows on a page with room left.
    private static let extraGap: CGFloat = 20

    @ViewBuilder
    private var content: some View {
        if isPaged {
            // The first step whose height fits the page wins; the last one is used regardless.
            ViewThatFits(in: .vertical) {
                if secondExample != nil {
                    cardContent(.roomy)
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
            // Only if even the last step is too tall (very small screen, largest non-accessibility
            // size): the text ends at the card's edge instead of running under "Biliyorum".
            .clipped()
        } else {
            cardContent(.full)
        }
    }

    private func cardContent(_ step: FitStep) -> some View {
        let spacing: CGFloat = step.isSmaller ? 8 : 12
        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: spacing) {
                if isOnLockScreen && !step.isSmaller {
                    WordCardLockScreenNote()
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
            }
            partGap(spacing)
            if step == .exampleRow {
                detailRow(title: mistake == nil ? "Örnek cümle" : "Örnek cümle ve Dikkat", showsCaution: false)
            } else {
                exampleBlock(step)
                if let mistake = mistake {
                    partGap(spacing)
                    if step == .mistakeRow {
                        detailRow(title: "Dikkat: sık yapılan hata", showsCaution: true)
                    } else {
                        MistakeBox(mistake: mistake, showsWhy: step.rawValue < FitStep.noWhy.rawValue)
                    }
                }
            }
        }
        // Mockup `.inner`: 18 / 20 / 12 above the footer ("Biliyorum"), 20 without one.
        .padding(.top, 18)
        .padding(.horizontal, 20)
        .padding(.bottom, known == nil ? 20 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Between the word's part, the example and Dikkat: `minimum`, and on a page with room left up
    /// to `extraGap` more (the rest stays above "Biliyorum"). Its ideal height is `minimum`, so it
    /// never changes which step fits; the low priority lets the text take its room first.
    private func partGap(_ minimum: CGFloat) -> some View {
        Color.clear
            .frame(minHeight: minimum, idealHeight: minimum, maxHeight: minimum + (isPaged ? WordCardView.extraGap : 0))
            .layoutPriority(-1)
    }

    // MARK: Parts

    /// Pronunciation, part of speech and level, then "Dinle" and "Söyle" (mockup `.wmeta`): the
    /// facts wrap when the line is full; the buttons always keep to the trailing edge.
    private var metaRow: some View {
        WordCardMetaLayout(itemSpacing: 8, lineSpacing: 4) {
            ipa
            partOfSpeech
            LevelBadge(code: word.level)
            actions
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

    /// Mockup `.exblock` without its "Örnek" label (the rule and the sentence say it): the
    /// sentence with the learned word marked (the band's yellow, rule 1), its Turkish translation
    /// and its speaker. On a roomy page a second example follows, the word bold but not yellow.
    private func exampleBlock(_ step: FitStep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            WordCardRule()
            ExampleRow(example: firstExample, lemma: word.lemma, marksWord: true)
            if step == .roomy, let second = secondExample {
                ExampleRow(example: second, lemma: word.lemma)
            }
        }
    }

    /// One capsule in place of a part that no longer fits (mockup `.mrow`; tappable, so a
    /// capsule, rule 2); opens the whole card.
    private func detailRow(title: String, showsCaution: Bool) -> some View {
        Button {
            openDetail?()
        } label: {
            HStack(spacing: 8) {
                if showsCaution {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(Theme.caution)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                    .accessibilityHidden(true)
            }
            .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 48, tonal: true))
        .accessibilityHint("Kartın tamamını açar")
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
                    // The largest text sizes on a narrow phone: a little smaller, never broken
                    // inside the word.
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
        }
    }

    /// The first few cards show where the next one is. Visual only: VoiceOver moves on by itself.
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

/// Mockup `.wmeta` (`flex-wrap: wrap`, the buttons with `margin-left: auto`): subviews flow from
/// the leading edge and wrap to a new line when the line is full; the last subview (the buttons)
/// keeps to the trailing edge of its line. Each subview is centered on its line's height.
private struct WordCardMetaLayout: Layout {
    /// Between two subviews on a line.
    var itemSpacing: CGFloat
    /// Between two lines.
    var lineSpacing: CGFloat

    private struct Line {
        var items: [(index: Int, size: CGSize)] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let lines = arrange(subviews, maxWidth: proposal.width ?? .infinity)
        let gaps = lineSpacing * CGFloat(max(lines.count - 1, 0))
        let height = lines.reduce(CGFloat(0)) { $0 + $1.height } + gaps
        let usedWidth = lines.reduce(CGFloat(0)) { max($0, $1.width) }
        // The row spans the card (the buttons sit on its trailing edge).
        if let width = proposal.width, width.isFinite {
            return CGSize(width: max(width, 0), height: height)
        }
        return CGSize(width: usedWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let lines = arrange(subviews, maxWidth: bounds.width)
        let trailingIndex = subviews.count > 1 ? subviews.count - 1 : -1
        var y = bounds.minY
        for line in lines {
            var x = bounds.minX
            for item in line.items {
                let itemX = item.index == trailingIndex ? max(x, bounds.maxX - item.size.width) : x
                subviews[item.index].place(
                    at: CGPoint(x: itemX, y: y + (line.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                x = itemX + item.size.width + itemSpacing
            }
            y += line.height + lineSpacing
        }
    }

    private func arrange(_ subviews: Subviews, maxWidth: CGFloat) -> [Line] {
        var lines: [Line] = []
        var line = Line()
        for index in subviews.indices {
            var size = subviews[index].sizeThatFits(.unspecified)
            if size.width > maxWidth {
                // A long pronunciation wraps inside the card instead of running off it.
                size = subviews[index].sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            }
            if !line.items.isEmpty && line.width + itemSpacing + size.width > maxWidth {
                lines.append(line)
                line = Line()
            }
            line.width += (line.items.isEmpty ? 0 : itemSpacing) + size.width
            line.height = max(line.height, size.height)
            line.items.append((index: index, size: size))
        }
        if !line.items.isEmpty {
            lines.append(line)
        }
        return lines
    }
}

/// "Şu an kilitli ekranda" (mockup `.now-chip`): a quiet line, not a capsule, since it cannot be
/// tapped (rule 2).
private struct WordCardLockScreenNote: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock")
                .imageScale(.small)
                .accessibilityHidden(true)
            Text("Şu an kilitli ekranda")
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Theme.ink2)
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
