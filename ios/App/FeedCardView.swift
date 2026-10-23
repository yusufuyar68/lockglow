import SwiftUI
import CoreModels

/// The "Akış" word card, laid out as a short page of a book (option A "Sayfa" of the is5 feed
/// redesign; mockup: claude.ai/artifact/HqYnrK6ewAxk4AuJqxR9Uy). The reading order and the blocks
/// are those of ogrenme_ilkeleri 2.2 and `WordCardView`: the English word on its phosphor band; one
/// quiet meta line (pronunciation, part of speech, level, and how the user met the word); one row
/// of buttons ("Dinle", "Söyle", "Biliyorum"); the Turkish meaning; a simple English definition; one
/// example with its translation; one warning slot. What changed is the type and the rhythm:
/// - one text column with a 24 pt margin and no boxes; groups are set apart by space and one
///   hairline, the example is marked by a hanging quotation mark instead of a label;
/// - the warning slot is the page's footnote, under a hairline at the foot of the card, so the
///   eye always finds it in the same place;
/// - the meta line says "Yeni kelime" on the first encounter and "Daha önce gördün" afterwards
///   (`isFirstEncounter`); later encounters also get the short definition, a second example and
///   the whole Dikkat note, so the two look different at a glance;
/// - nothing that cannot be tapped is a capsule (rule 2): the level is plain text with dots.
///
/// The first encounter shows at most the 8 blocks and one warning slot of ogrenme_ilkeleri 2.2.
/// In the paged feed (`fillsPage`) the card fills its page and shortens itself from the end when
/// the page is too short (rule 5), with the steps of `WordCardView`. At accessibility text sizes
/// it shows everything (one example) at its natural height, and the buttons stack at full width.
/// VoiceOver hears the same elements, labels and hints as on `WordCardView`, plus the encounter
/// line after the level.
struct FeedCardView: View {
    let word: WidgetWord
    let detail: CardDetail?
    var isFirstEncounter = true
    /// "Şu an kilitli ekranda" in the meta line (`AppModel.lockScreenWordID`).
    var isOnLockScreen = false
    /// nil: no "Biliyorum".
    var known: WordCardView.KnownControl? = nil
    /// "Yukarı kaydır" at the foot of the card (the feed's first few cards).
    var showsSwipeHint = false
    /// Opens the whole card; the last two shortening steps need it.
    var openDetail: (() -> Void)? = nil
    /// As tall as its page (the paged feed); natural height at accessibility text sizes.
    var fillsPage = true
    var outerPadding = EdgeInsets(top: 4, leading: 12, bottom: 12, trailing: 12)

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    /// The "Neden?" sheet is open.
    @State private var showsWhy = false
    /// The warning the sheet explains: kept after it closes, so the sheet does not go blank
    /// while it slides down.
    @State private var explained: CardWarning? = nil
    /// The Turkish meaning: 30 pt on the first encounter, 27 pt afterwards (28 pt before).
    @ScaledMetric(relativeTo: .title) private var firstMeaningSize: CGFloat = 30
    @ScaledMetric(relativeTo: .title) private var laterMeaningSize: CGFloat = 27

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: isPaged ? .infinity : nil, alignment: .topLeading)
            .cardSurface(cornerRadius: Theme.Radius.wordCard)
            // Borderless controls inside take ink, never the blue default.
            .tint(Theme.ink)
            .padding(outerPadding)
            // Not combined into one element: the buttons must stay reachable on their own.
            .accessibilityElement(children: .contain)
            .sheet(isPresented: $showsWhy) {
                if let warning = explained {
                    FeedWhySheet(word: word, detail: detail, warning: warning)
                }
            }
    }

    private var isPaged: Bool {
        return fillsPage && !dynamicTypeSize.isAccessibilitySize
    }

    private var warnings: [CardWarning] {
        return CardWarning.all(for: word, detail: detail)
    }

    /// The card's own example (`example_en`) with its translation, as `WordCardView` picks it.
    private var firstExample: CardDetail.Example {
        let examples = detail?.examples ?? []
        return examples.first { $0.en == word.exampleEN } ?? examples.first ?? CardDetail.Example(en: word.exampleEN)
    }

    private var secondExample: CardDetail.Example? {
        let first = firstExample.en
        return detail?.examples.first { $0.en != first }
    }

    /// The micro definition on the first encounter of an A1–A2 card, otherwise the short one.
    private var definition: String {
        if isFirstEncounter, let level = word.levelValue, level <= .a2, !word.defMicro.isEmpty {
            return word.defMicro
        }
        return word.defShort
    }

    // MARK: Fitting the page (rule 5)

    /// The steps of `WordCardView.FitStep`, in the same order.
    private enum FitStep: Int {
        /// Met before, a page with room for it: a second example.
        case roomy
        /// Everything for this encounter.
        case full
        /// 1. Smaller meaning and definition, tighter spacing; no Lock Screen label.
        case smaller
        /// 2. Met before: the Dikkat note without its explanation.
        case noWhy
        /// 3. Met before: only the slot's one line, as on the first encounter.
        case slotOnly
        /// 4. The example as a row.
        case exampleRow
        /// 5. The example and the warning in that one row.
        case allRow

        var isSmaller: Bool {
            return rawValue >= FitStep.smaller.rawValue
        }
    }

    @ViewBuilder
    private var content: some View {
        if isPaged {
            let warnings = self.warnings
            let hasMistake = warnings.contains { if case .mistake = $0 { return true } else { return false } }
            let metBefore = !isFirstEncounter
            // The first step whose height fits the page wins; the last one is used regardless.
            ViewThatFits(in: .vertical) {
                if metBefore && secondExample != nil {
                    page(.roomy, warnings: warnings)
                }
                page(.full, warnings: warnings)
                page(.smaller, warnings: warnings)
                if metBefore && hasMistake {
                    page(.noWhy, warnings: warnings)
                }
                if metBefore && (hasMistake || warnings.count > 1) {
                    page(.slotOnly, warnings: warnings)
                }
                if openDetail != nil {
                    page(.exampleRow, warnings: warnings)
                }
                if openDetail != nil && !warnings.isEmpty {
                    page(.allRow, warnings: warnings)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            // Only if even the last step is too tall: the text ends at the card's edge.
            .clipped()
        } else {
            page(.full, warnings: warnings)
        }
    }

    /// One way to set the card. Between the groups are gaps that grow a little on a page with
    /// room left (`gap`); what is left after that goes above the footnote, which stays at the
    /// foot of the page. Ideal heights are the minimums, so the gaps never change which step
    /// fits.
    private func page(_ step: FitStep, warnings: [CardWarning]) -> some View {
        let tight = step.isSmaller
        return VStack(alignment: .leading, spacing: 0) {
            FeedCardHeadline(lemma: word.lemma)
            // The night band hangs below the word: at least 8 pt before the next row.
            metaRow(showsLockScreen: isOnLockScreen && !tight)
                .padding(.top, tight ? 8 : 10)
            tools
                .padding(.top, tight ? 10 : 14)
            gap(tight ? 14 : 22, extra: 18)
            meaning(step)
            // A user's word has no English definition (and maybe no example).
            if !definition.isEmpty {
                Text(definition)
                    .font(tight ? Theme.Fonts.example : Theme.Fonts.definition)
                    .foregroundStyle(Theme.ink)
                    // About 1.45 line height (ogrenme_ilkeleri 2.2), tighter on a short page.
                    .lineSpacing(tight ? 2 : 5)
                    .lineLimit(step.rawValue >= FitStep.exampleRow.rawValue ? 3 : nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, tight ? 4 : 8)
                    .englishVoice()
            }
            examplePart(step, warnings: warnings)
            Spacer(minLength: 0)
                .layoutPriority(-2)
            if step != .allRow && !warnings.isEmpty {
                footnote(step, warnings: warnings)
                    .padding(.top, tight ? 12 : 18)
            }
            if showsSwipeHint {
                swipeHint
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 10)
            }
        }
        .padding(.top, 22)
        .padding(.leading, 24)
        .padding(.trailing, 22)
        .padding(.bottom, showsSwipeHint ? 14 : 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// `minimum` tall, up to `extra` more on a page with room left. Its low priority lets the text
    /// take its room first.
    private func gap(_ minimum: CGFloat, extra: CGFloat) -> some View {
        Color.clear
            .frame(minHeight: minimum, idealHeight: minimum, maxHeight: minimum + (isPaged ? extra : 0))
            .layoutPriority(-1)
            .accessibilityHidden(true)
    }

    // MARK: Parts

    /// Pronunciation, part of speech, level, the Lock Screen label and how the user met the word;
    /// the facts wrap when the line is full, the encounter line keeps to the trailing edge.
    private func metaRow(showsLockScreen: Bool) -> some View {
        CardFlowLayout(itemSpacing: 12, lineSpacing: 4, pinsLastToTrailingEdge: true) {
            if let ipa = word.ipaUS {
                // Visual only: VoiceOver says the word itself, and "Dinle" plays it.
                Text(ipa)
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
            }
            if word.isUserAdded {
                CustomWordTag()
            } else {
                Text(CardPartOfSpeech.turkish(word.pos))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.ink2)
                FeedLevelMark(code: word.level)
            }
            if showsLockScreen {
                WordCardLockScreenNote()
            }
            FeedEncounterLine(kind: encounter)
        }
    }

    private var encounter: FeedEncounterLine.Kind {
        if known?.isKnown == true {
            return .known
        }
        return isFirstEncounter ? .first : .metBefore
    }

    /// "Dinle", "Söyle" and "Biliyorum" on one row, one block (ogrenme_ilkeleri 2.2); "Biliyorum"
    /// keeps to the trailing edge and wraps under the others when the row is full. At
    /// accessibility sizes they stack at full width, "Söyle" with its name.
    @ViewBuilder
    private var tools: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 10) {
                FeedListenButton(text: word.lemma, fullWidth: true)
                FeedSayButton(word: word, example: word.exampleEN, showsName: true)
                if let known = known {
                    knownButton(known, fullWidth: true)
                }
            }
        } else {
            CardFlowLayout(itemSpacing: 8, lineSpacing: 8, pinsLastToTrailingEdge: known != nil) {
                FeedListenButton(text: word.lemma)
                FeedSayButton(word: word, example: word.exampleEN)
                if let known = known {
                    knownButton(known)
                }
            }
        }
    }

    /// "Biliyorum"; a known word's is selected (a check in `good`, an ink border) and undoes it.
    /// It never leaves the row, so VoiceOver keeps its place (audit V7).
    private func knownButton(_ known: WordCardView.KnownControl, fullWidth: Bool = false) -> some View {
        Button {
            if known.isKnown {
                known.undoKnown()
            } else {
                known.markKnown()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: known.isKnown ? "checkmark.circle.fill" : "checkmark")
                    .foregroundStyle(known.isKnown ? Theme.good : Theme.ink)
                    .accessibilityHidden(true)
                Text("Biliyorum")
            }
        }
        .buttonStyle(FeedToolButtonStyle(isSelected: known.isKnown, fullWidth: fullWidth))
        .accessibilityLabel("Biliyorum")
        .accessibilityAddTraits(known.isKnown ? .isSelected : [])
        .accessibilityHint(Text(known.isKnown ? "Kelime öğrenme listene döner." : ""))
    }

    /// The Turkish meaning only: other meanings ("Ayrıca") are on the whole card in "Sözlük".
    @ViewBuilder
    private func meaning(_ step: FitStep) -> some View {
        if let gloss = word.glossTR {
            Text(gloss)
                .font(step.isSmaller
                      ? Font.title2.weight(.bold)
                      : Font.system(size: isFirstEncounter ? firstMeaningSize : laterMeaningSize, weight: .bold))
                .foregroundStyle(Theme.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(Text(verbatim: "Türkçesi: " + gloss))
        }
    }

    /// A hairline, then the example (the learned word marked, rule 1) under a hanging quotation
    /// mark; on a roomy page a second example, the word bold but not yellow. The last two steps
    /// turn it into a row that opens the whole card.
    @ViewBuilder
    private func examplePart(_ step: FitStep, warnings: [CardWarning]) -> some View {
        let hasExample = !firstExample.en.isEmpty
        if step == .allRow {
            gap(step.isSmaller ? 14 : 18, extra: 22)
            detailRow(title: WordCardView.rowTitle(for: warnings.first, hasExample: hasExample))
        } else if hasExample {
            gap(step.isSmaller ? 14 : 18, extra: 22)
            FeedCardRule()
            gap(step.isSmaller ? 12 : 16, extra: 12)
            if step == .exampleRow {
                detailRow(title: "Örnek cümle")
            } else {
                FeedExample(example: firstExample, lemma: word.lemma, marksWord: true)
                if step == .roomy, let second = secondExample {
                    ExampleRow(example: second, lemma: word.lemma)
                        .padding(.top, 14)
                }
            }
        }
    }

    /// The page's footnote: a hairline, then the warning slot. The first encounter (and a short
    /// page) shows the slot's one line; met before, every warning, the mistake as the whole
    /// Dikkat note.
    private func footnote(_ step: FitStep, warnings: [CardWarning]) -> some View {
        let isSlotOnly = isFirstEncounter || step.rawValue >= FitStep.slotOnly.rawValue
        let shown = isSlotOnly ? Array(warnings.prefix(1)) : warnings
        return VStack(alignment: .leading, spacing: 12) {
            FeedCardRule()
            ForEach(Array(shown.enumerated()), id: \.offset) { _, warning in
                if !isSlotOnly, case let .mistake(mistake) = warning {
                    FeedMistakeNote(
                        mistake: mistake,
                        showsWhy: step.rawValue < FitStep.noWhy.rawValue,
                        explain: explainAction(for: warning)
                    )
                } else {
                    CardWarningLine(warning: warning, lemma: word.lemma, explain: explainAction(for: warning))
                }
            }
        }
    }

    /// "Neden?" for the false friend and the mistake, and for the other lines when the card has a
    /// Turkish note that explains them (`noteTR`; not for the user's own words, whose note is
    /// their own).
    private func explainAction(for warning: CardWarning) -> (() -> Void)? {
        let hasNote = !word.isUserAdded && !(detail?.noteTR ?? "").isEmpty
        guard warning.hasExplanation || hasNote else {
            return nil
        }
        return {
            explained = warning
            showsWhy = true
        }
    }

    /// One capsule in place of a part that no longer fits (rule 2); opens the whole card.
    private func detailRow(title: String) -> some View {
        Button {
            openDetail?()
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // An icon, so `ink3` (never text on `surface2`/`surface3`, ogrenme_ilkeleri 2.2).
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

/// The English word on its phosphor band, 44 pt at the default text size and at most 60 pt
/// (ogrenme_ilkeleri 2.2). A phrase too long for one line first tries 80 %, then breaks into two
/// balanced lines, each on its own band; only as the last step does a line shrink, to 75 % at
/// least (never below, never cut, no tighter letter spacing). VoiceOver reads it once, as a
/// heading, with an English voice.
private struct FeedCardHeadline: View {
    let lemma: String
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 44

    var body: some View {
        let full = min(size, 60)
        ViewThatFits(in: .horizontal) {
            line(lemma, size: full)
            line(lemma, size: full * 0.8)
            if let lines = WordCardHeadline.balancedLines(lemma) {
                VStack(alignment: .leading, spacing: 10) {
                    line(lines.first, size: full * 0.8)
                    line(lines.second, size: full * 0.8)
                }
            }
            line(lemma, size: full * 0.8, shrinks: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: lemma))
        .accessibilityAddTraits(.isHeader)
        .englishVoice()
    }

    private func line(_ text: String, size: CGFloat, shrinks: Bool = false) -> some View {
        Text(verbatim: text)
            .font(Theme.Fonts.englishWord(size: size))
            .foregroundStyle(Theme.ink)
            .lineLimit(1)
            .minimumScaleFactor(shrinks ? 0.75 : 1)
            .phosphorBand()
    }
}

/// "A2 ●●○" without a capsule: it cannot be tapped (rule 2), so it is plain text with the
/// level's dots (rule 4: never color alone). VoiceOver reads "Seviye A2", as `LevelBadge`.
struct FeedLevelMark: View {
    let code: String
    @ScaledMetric(relativeTo: .footnote) private var dotSize: CGFloat = 5

    var body: some View {
        let dots = Level(rawValue: code).map { min(3, max(0, $0.rank)) } ?? 0
        HStack(spacing: 5) {
            Text(verbatim: code)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Theme.ink)
            if dots > 0 {
                HStack(spacing: 2) {
                    ForEach(1...3, id: \.self) { dot in
                        if dot <= dots {
                            Circle()
                                .fill(Theme.ink)
                                .frame(width: dotSize, height: dotSize)
                        } else {
                            // A 1 pt ink3 ring (audit K2: a pale fill was 1.6:1).
                            Circle()
                                .strokeBorder(Theme.ink3, lineWidth: 1)
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Seviye \(code)"))
    }
}

/// How the user met the word, at the end of the meta line: "Yeni kelime" (a filled dot) on the
/// first encounter, "Daha önce gördün" (a ring) afterwards, "Bildiğin kelime" (a check) once it is
/// known. The words carry the meaning; the mark only repeats it.
struct FeedEncounterLine: View {
    enum Kind {
        case first
        case metBefore
        case known
    }

    let kind: Kind
    @ScaledMetric(relativeTo: .footnote) private var dotSize: CGFloat = 6

    var body: some View {
        HStack(spacing: 6) {
            mark
                .accessibilityHidden(true)
            Text(title)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Theme.ink2)
        .lineLimit(1)
    }

    private var title: String {
        switch kind {
        case .first:
            return "Yeni kelime"
        case .metBefore:
            return "Daha önce gördün"
        case .known:
            return "Bildiğin kelime"
        }
    }

    @ViewBuilder
    private var mark: some View {
        switch kind {
        case .first:
            Circle()
                .fill(Theme.ink)
                .frame(width: dotSize, height: dotSize)
        case .metBefore:
            Circle()
                .strokeBorder(Theme.ink2, lineWidth: 1.5)
                .frame(width: dotSize, height: dotSize)
        case .known:
            Image(systemName: "checkmark")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Theme.good)
        }
    }
}

/// The card's first example: `ExampleRow` (the shared row with its speaker) under a hanging
/// quotation mark in the left margin, which marks it as an example instead of a label. The mark
/// is visual only, and left out at accessibility sizes, where the margin is needed for the text.
private struct FeedExample: View {
    let example: CardDetail.Example
    let lemma: String
    var marksWord = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var quoteSize: CGFloat = 34

    var body: some View {
        ExampleRow(example: example, lemma: lemma, marksWord: marksWord)
            .overlay(alignment: .topLeading) {
                if !dynamicTypeSize.isAccessibilitySize {
                    // A glyph, not reading text: ink3 is allowed (17 pt and above).
                    Text(verbatim: "\u{201C}")
                        .font(.system(size: quoteSize, weight: .regular, design: .serif))
                        .foregroundStyle(Theme.ink3)
                        .offset(x: -quoteSize * 0.48, y: -quoteSize * 0.16)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
    }
}

/// The whole Dikkat note of a card met before, as the page's footnote: no box (the hairline
/// above sets it apart), the heading with the Dikkat triangle, the wrong and the right sentence
/// with their labels ("Yanlış", "Doğru", rule 4) and the reason. VoiceOver hears it as
/// `MistakeBox`: the heading with "Fark: did yerine had" (audit V12), then each label and
/// sentence, the sentences with an English voice. `explain` adds "Neden?" to the heading row, for
/// the explanation sheet with the card's other mistakes.
struct FeedMistakeNote: View {
    let mistake: CardDetail.Mistake
    var showsWhy = true
    var explain: (() -> Void)? = nil
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let diff = MistakeDiff(mistake)
        VStack(alignment: .leading, spacing: 8) {
            CardFlowLayout(itemSpacing: 8, lineSpacing: 4, pinsLastToTrailingEdge: explain != nil) {
                heading(difference: MistakeBox.difference(mistake))
                if let explain = explain {
                    Button("Neden?", action: explain)
                        .buttonStyle(ChipButtonStyle())
                        .accessibilityHint("Açıklamayı açar")
                }
            }
            if dynamicTypeSize.isAccessibilitySize {
                // No room for a label column: each label above its sentence.
                VStack(alignment: .leading, spacing: 4) {
                    tag(isRight: false)
                    sentence(diff.wrongText(), bold: false)
                    tag(isRight: true)
                        .padding(.top, 4)
                    sentence(diff.rightText(), bold: true)
                }
            } else {
                Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 10, verticalSpacing: 6) {
                    GridRow {
                        tag(isRight: false)
                        sentence(diff.wrongText(), bold: false)
                    }
                    GridRow {
                        tag(isRight: true)
                        sentence(diff.rightText(), bold: true)
                    }
                }
            }
            if showsWhy {
                // 16 pt ink, not 15 pt ink2 (ogrenme_ilkeleri 2.2, type table).
                Text(mistake.why)
                    .font(.callout)
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func heading(difference: String?) -> some View {
        let title = HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.caution)
                .accessibilityHidden(true)
            Text("Dikkat")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.ink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        if let difference = difference {
            title
                .accessibilityCustomContent(Text("Fark"), Text(verbatim: difference), importance: .high)
        } else {
            title
        }
    }

    private func tag(isRight: Bool) -> some View {
        HStack(spacing: 3) {
            Image(systemName: isRight ? "checkmark" : "xmark")
                .font(.caption2.weight(.black))
                .accessibilityHidden(true)
            Text(isRight ? "Doğru" : "Yanlış")
        }
        .font(.footnote.weight(.bold))
        .foregroundStyle(isRight ? Theme.good : Theme.bad)
        .fixedSize()
    }

    /// 18 pt serif (`exampleFont`), as the example (ogrenme_ilkeleri 2.2, type table).
    private func sentence(_ text: AttributedString, bold: Bool) -> some View {
        Text(text)
            .exampleFont(bold: bold)
            .foregroundStyle(Theme.ink)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .englishVoice()
    }
}

/// A 1 pt `line` hairline between the card's groups (decoration only).
struct FeedCardRule: View {
    var body: some View {
        Rectangle()
            .fill(Theme.line)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

// MARK: - The card's buttons

/// A button of the card's row: a `surface2` capsule with a 1 pt `lineStrong` edge (1.5 pt with
/// Increase Contrast or Button Shapes, audit K1), 44 pt high, subheadline. `isSelected` (a known
/// word's "Biliyorum"): `surface` with a 1.5 pt `tint` border. `fullWidth` (accessibility sizes)
/// spans the card with its label at the leading edge; `isRound` is the 44 pt circle of "Söyle".
struct FeedToolButtonStyle: ButtonStyle {
    var isSelected = false
    var fullWidth = false
    var isRound = false

    func makeBody(configuration: Configuration) -> some View {
        FeedToolButtonBody(configuration: configuration, isSelected: isSelected, fullWidth: fullWidth, isRound: isRound)
    }
}

private struct FeedToolButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let isSelected: Bool
    let fullWidth: Bool
    let isRound: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityShowButtonShapes) private var showsButtonShapes

    var body: some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .lineLimit(fullWidth ? 2 : 1)
            .foregroundStyle(Theme.ink)
            .padding(.leading, isRound ? 0 : (fullWidth ? 18 : 12))
            .padding(.trailing, isRound ? 0 : 15)
            .padding(.vertical, fullWidth ? 8 : 0)
            .frame(
                minWidth: Theme.minHitSize,
                maxWidth: fullWidth ? .infinity : nil,
                minHeight: Theme.minHitSize,
                alignment: fullWidth ? .leading : .center
            )
            .background(isSelected ? Theme.surface : Theme.surface2, in: Capsule())
            .overlay {
                if isSelected {
                    Capsule().strokeBorder(Theme.tint, lineWidth: 1.5)
                } else {
                    Capsule().strokeBorder(Theme.lineStrong, lineWidth: contrast == .increased || showsButtonShapes ? 1.5 : 1)
                }
            }
            .contentShape(Capsule())
            .fixedSize(horizontal: !fullWidth, vertical: true)
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// "Dinle": reads the word aloud; a second tap stops it. While it reads, the speaker is filled
/// and the label says "Durdur"; nothing moves next to the text (ogrenme_ilkeleri 2.2). Same
/// VoiceOver and Voice Control names as `CardListenCapsule`.
struct FeedListenButton: View {
    @ObservedObject private var speaker = Speaker.shared
    let text: String
    var fullWidth = false

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                Text(isSpeaking ? "Durdur" : "Dinle")
            }
        }
        .buttonStyle(FeedToolButtonStyle(fullWidth: fullWidth))
        .accessibilityLabel(isSpeaking ? "Durdur" : "Kelimeyi dinle")
        // Voice Control: "Dinle'ye dokun" works as well as the spoken name.
        .accessibilityInputLabels([Text(isSpeaking ? "Durdur" : "Dinle"), Text(isSpeaking ? "Durdur" : "Kelimeyi dinle")])
    }
}

/// "Söyle" as a capsule (rule 2), a 44 pt circle with the microphone in the row, with its name
/// at accessibility sizes. Opens the pronunciation practice as `SayButton` does, with the same
/// sheet heights and the same VoiceOver and Voice Control names.
struct FeedSayButton: View {
    let word: WidgetWord
    let example: String
    var showsName = false
    @State private var isPresented = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button {
            isPresented = true
        } label: {
            if showsName {
                HStack(spacing: 6) {
                    Image(systemName: "mic")
                    Text("Söyle")
                }
            } else {
                Image(systemName: "mic")
            }
        }
        .buttonStyle(FeedToolButtonStyle(fullWidth: showsName, isRound: !showsName))
        .accessibilityLabel("Söyle: telaffuzunu dene")
        .accessibilityInputLabels([Text("Söyle"), Text("Söyle: telaffuzunu dene")])
        .sheet(isPresented: $isPresented) {
            PronunciationPracticeView(word: word, example: example)
                .presentationDetents(sheetDetents)
                // The page scrolls before the sheet grows: the result is scrolled into view.
                .presentationContentInteraction(.scrolls)
                // Opaque like the cards (rule 6).
                .presentationBackground(Theme.surface)
        }
    }

    /// As `SayButton`: not `.medium` (half of an iPhone SE cut the instructions), the whole
    /// height at accessibility sizes.
    private var sheetDetents: Set<PresentationDetent> {
        if dynamicTypeSize.isAccessibilitySize {
            return [.large]
        }
        return [.custom(FeedSaySheetDetent.self), .large]
    }
}

/// `SaySheetDetent` (PronunciationPracticeView.swift) for the feed's "Söyle": 600 pt, inactive on
/// short screens (iPhone SE), which keep only `.large`.
private struct FeedSaySheetDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        if context.maxDetentValue < 700 {
            return nil
        }
        return 600
    }
}
