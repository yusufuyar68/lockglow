import SwiftUI
import CoreModels
import Learning

// The word page of "Sözlük" (mockup A4, docs/tasarim: Sözlük redesign, option A "Sözlük
// maddesi"): one column read top to bottom, the most needed first. The word on its band with
// pronunciation, part of speech, level and status, "Dinle" and "Söyle"; the Turkish meaning, the
// other meanings and the definition; "Başka anlamı" and "Karıştırma" (the confusable words, each
// page linked to the other: borrow ↔ lend); every example; the Dikkat boxes, the false friend,
// the note and the memory hook; the word partners; last "Durum" with its one button
// (ogrenme_ilkeleri 2.6). Opened from Sözlük, "Bildiğin kelimeler" and the feed (in a sheet).

/// The whole card as a word page. A linked word ("Karıştırma", "Başka anlamı") opens on the same
/// navigation stack; the link back to the page that opened this one goes back instead of
/// stacking the pair again and again.
struct WordDetailView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.sozlukLinkOrigin) private var origin
    /// A linked word opened from this page.
    @State private var linkedWord: WidgetWord?
    /// The top safe area of the scroll view: the bar's lower edge in its "wordPage" space (0 when
    /// the scroll view itself starts below the bar).
    @State private var barEdge: CGFloat = 0
    /// The headline has scrolled up under the bar: the bar then names the word (akis-5).
    @State private var headlineIsUnderBar = false
    let word: WidgetWord

    var body: some View {
        let detail = model.detail(for: word)
        let state = model.learningState(of: word)
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header(state: state)
                meaning(alternatives: detail?.glossAlternatives ?? [])
                links
                if !(detail?.examples ?? []).isEmpty || !word.exampleEN.isEmpty {
                    examplesSection(detail?.examples ?? [])
                }
                cautionSection(detail)
                if let collocations = detail?.collocations, !collocations.isEmpty {
                    collocationsSection(collocations)
                }
                SozlukStatusSection(word: word)
            }
            // The HIG side margin.
            .padding(.horizontal, 16)
            .padding(.top, 8)
            // The scroll view already keeps clear of the tab bar; this is the page's own margin
            // under the last button.
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // The headline is measured in this space (`header`): both values move with the page, not
        // with a sheet or a push sliding in.
        .coordinateSpace(.named("wordPage"))
        .onGeometryChange(for: CGFloat.self) { geometry in
            geometry.safeAreaInsets.top
        } action: { newEdge in
            barEdge = newEdge
        }
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        // akis-5: a scrolled page still says which word it is, in the inline bar. Empty while the
        // band shows the word (the band is the page's large title), so it is never said twice.
        // Not a principal toolbar item: the system title keeps its own size and Dynamic Type.
        .navigationTitle(headlineIsUnderBar ? word.lemma : "")
        .navigationBarTitleDisplayMode(.inline)
        .hardTopScrollEdge()
        .tint(Theme.ink)
        .navigationDestination(item: $linkedWord) { linked in
            WordDetailView(word: linked)
                .environment(\.sozlukLinkOrigin, word.id)
        }
    }

    /// Opens a linked word; the page this one was opened from is one step back, not one more.
    private func follow(_ target: WidgetWord) {
        if target.id == origin {
            dismiss()
        } else {
            linkedWord = target
        }
    }

    /// The word on its band (the night band hangs below it: the spacing leaves it room), its
    /// facts, then "Dinle" and "Söyle", one under the other when a line cannot hold both (the
    /// largest text sizes).
    private func header(state: LearningState) -> some View {
        // Read here: the measuring closure keeps only the number.
        let edge = barEdge
        return VStack(alignment: .leading, spacing: 12) {
            WordDetailHeadline(lemma: word.lemma)
                // Under the bar once its last line has scrolled past the bar's lower edge.
                .onGeometryChange(for: Bool.self) { geometry in
                    geometry.frame(in: .named("wordPage")).maxY <= edge
                } action: { isUnderBar in
                    headlineIsUnderBar = isUnderBar
                }
            SozlukWordFacts(word: word, state: state)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 6) {
                    actions
                }
                VStack(alignment: .leading, spacing: 4) {
                    actions
                }
            }
        }
    }

    /// "Dinle" in Callout, the page's one secondary size.
    @ViewBuilder
    private var actions: some View {
        CardListenCapsule(text: word.lemma, accessibilityName: "Kelimeyi dinle", font: .callout.weight(.semibold))
        SayButton(word: word, example: word.exampleEN)
    }

    /// The Turkish meaning, the other Turkish meanings ("Ayrıca") and the English definition (a
    /// user's word has none). The definition is set as the examples are (Body serif): the page
    /// keeps four sizes, the word, the meaning, Body and Callout.
    private func meaning(alternatives: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let gloss = word.glossTR {
                Text(gloss)
                    .meaningStyle()
                    .accessibilityLabel(Text(verbatim: "Türkçesi: " + gloss))
            }
            // "Ayrıca" only under a meaning it adds to.
            if word.glossTR != nil && !alternatives.isEmpty {
                Text("Ayrıca: " + alternatives.joined(separator: ", "))
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
            }
            if !word.defShort.isEmpty {
                Text(word.defShort)
                    .exampleStyle()
                    .lineSpacing(2)
                    .cardEnglishVoice()
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// "Başka anlamı" (the other cards of the headword, with their part of speech) and
    /// "Karıştırma" (the confusable words). Right under the meaning: they change how it is read.
    @ViewBuilder
    private var links: some View {
        let senses = model.otherSenses(of: word)
        let partners = model.confusablePartners(of: word)
        if !senses.isEmpty {
            SozlukLinkSection(
                title: "Başka anlamı",
                systemImage: "square.on.square",
                caption: nil,
                words: senses,
                showsPartOfSpeech: true,
                open: follow
            )
        }
        if !partners.isEmpty {
            SozlukLinkSection(
                title: "Karıştırma",
                systemImage: "arrow.left.arrow.right",
                caption: "Bu kelimeyle sık karışır.",
                words: partners,
                showsPartOfSpeech: false,
                open: follow
            )
        }
    }

    /// Every example with its Turkish in one card, the word bold but not yellow: the band is the
    /// screen's one yellow mark. Without card details, the word's own example.
    private func examplesSection(_ examples: [CardDetail.Example]) -> some View {
        let shown = examples.isEmpty ? [CardDetail.Example(en: word.exampleEN)] : examples
        return SozlukPageSection(title: "Örnekler") {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(shown.enumerated()), id: \.offset) { index, example in
                    if index > 0 {
                        DictionaryRule()
                    }
                    ExampleRow(example: example, lemma: word.lemma)
                        .padding(.leading, 16)
                        .padding(.trailing, 8)
                        .padding(.vertical, 12)
                }
            }
            .sozlukCard()
        }
    }

    /// The typical mistakes, each in its own "Dikkat" box with the difference marked (README
    /// point 5), the false friend, then the note and the memory hook in one card. No section
    /// title: every box names itself.
    @ViewBuilder
    private func cautionSection(_ detail: CardDetail?) -> some View {
        let mistakes = detail?.mistakes ?? []
        let note = WordDetailView.nonEmpty(detail?.noteTR)
        let mnemonic = WordDetailView.nonEmpty(detail?.mnemonicTR)
        let falseFriend = detail?.falseFriend
        if !mistakes.isEmpty || falseFriend != nil || note != nil || mnemonic != nil {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(mistakes.enumerated()), id: \.offset) { _, mistake in
                    MistakeBox(mistake: mistake)
                }
                if let falseFriend = falseFriend {
                    SozlukFalseFriendBox(friend: falseFriend, lemma: word.lemma)
                }
                if note != nil || mnemonic != nil {
                    VStack(alignment: .leading, spacing: 0) {
                        if let note = note {
                            SozlukInfoRow(systemImage: "info.circle", title: "Not", text: note)
                        }
                        if note != nil && mnemonic != nil {
                            DictionaryRule()
                        }
                        if let mnemonic = mnemonic {
                            SozlukInfoRow(systemImage: "lightbulb", title: "Hafıza ipucu", text: mnemonic)
                        }
                    }
                    .sozlukCard()
                }
            }
        }
    }

    /// Word partners as capsules that wrap onto more lines (rule 2: a capsule is tappable; a tap
    /// reads the phrase aloud).
    private func collocationsSection(_ collocations: [String]) -> some View {
        SozlukPageSection(title: "Birlikte kullanılır") {
            // No line spacing: the chips already reach 44 pt with transparent margins.
            DictionaryFlowLayout(itemSpacing: 8, lineSpacing: 0) {
                ForEach(Array(collocations.enumerated()), id: \.offset) { _, phrase in
                    WordDetailCollocationCapsule(phrase: phrase)
                }
            }
        }
    }

    private static func nonEmpty(_ text: String?) -> String? {
        guard let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return text
    }
}

// MARK: - Links between pages

private struct SozlukLinkOriginKey: EnvironmentKey {
    static let defaultValue: Int? = nil
}

extension EnvironmentValues {
    /// The word whose page opened this word page through a link (`WordDetailView.follow`).
    var sozlukLinkOrigin: Int? {
        get { self[SozlukLinkOriginKey.self] }
        set { self[SozlukLinkOriginKey.self] = newValue }
    }
}

/// "Karıştırma" or "Başka anlamı": a titled group of word rows (`SozlukWordLink`, the rows of
/// Sözlük's lists, with their two VoiceOver parts) in one of the page's cards, black at night
/// like the others; a row opens that word's page. The other senses say their part of speech
/// under the meaning ("isim"), which is what tells them apart.
private struct SozlukLinkSection: View {
    let title: String
    let systemImage: String
    let caption: String?
    let words: [WidgetWord]
    let showsPartOfSpeech: Bool
    let open: (WidgetWord) -> Void

    var body: some View {
        SozlukPageSection(title: title, systemImage: systemImage, caption: caption) {
            VStack(spacing: 0) {
                ForEach(Array(words.enumerated()), id: \.element.id) { index, linked in
                    if index > 0 {
                        DictionaryRule()
                            .padding(.leading, 16)
                    }
                    // The page's sizes (Body, Callout), not the Sözlük lists' larger word.
                    SozlukWordLink(word: linked, note: note(for: linked), compact: true, open: open)
                }
            }
            // The pressed row's fill keeps to the rounded corners.
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous))
            .sozlukCard()
        }
    }

    private func note(for linked: WidgetWord) -> AttributedString? {
        guard showsPartOfSpeech else {
            return nil
        }
        return AttributedString(linked.isUserAdded ? "Senin kelimen" : CardPartOfSpeech.turkish(linked.pos))
    }
}

// MARK: - Parts of the page

/// A titled part of the word page (mockup `h2`): a bold `headline` title in ink, optionally after
/// an icon and over a short ink2 caption, a heading for VoiceOver.
private struct SozlukPageSection<Content: View>: View {
    let title: String
    var systemImage: String? = nil
    var caption: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if let systemImage = systemImage {
                        Image(systemName: systemImage)
                            .accessibilityHidden(true)
                    }
                    Text(title)
                        .accessibilityAddTraits(.isHeader)
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(Theme.ink)
                if let caption = caption {
                    // Callout: the page's one secondary size (the examples' translations, the
                    // Dikkat boxes).
                    Text(caption)
                        .font(.callout)
                        .foregroundStyle(Theme.ink2)
                }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Pronunciation, part of speech, level and (for a word already started) its status, wrapping
/// onto more lines when the line is full (a long phrase, the largest text sizes). The IPA is
/// visual only: VoiceOver says the word itself, and "Dinle" plays it.
private struct SozlukWordFacts: View {
    let word: WidgetWord
    let state: LearningState

    var body: some View {
        DictionaryFlowLayout(itemSpacing: 10, lineSpacing: 6) {
            // In the accent of "Ses ve aksan" (is5-ses); a word without IPA adds no item.
            if word.ipaUS != nil {
                AccentIPA(word) { ipa in
                    Text(ipa)
                        .font(.system(.callout, design: .serif))
                        .foregroundStyle(Theme.ink2)
                        .accessibilityHidden(true)
                }
            }
            // A user's word: "Senin kelimen" in place of the part of speech, and no level.
            if word.isUserAdded {
                CustomWordTag()
            } else {
                Text(CardPartOfSpeech.turkish(word.pos))
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Theme.ink2)
                // Callout like the pronunciation and the part of speech beside them.
                LevelBadge(code: word.level, textStyle: .callout)
                    .fixedSize()
            }
            // As on the rows: a new word carries no mark (most words are new).
            if state != .new {
                SozlukStatusMark(state: state, textStyle: .callout)
            }
        }
    }
}

/// A card on the word page (the examples, the note, the status): `surface` with a `line` border
/// and a faint shadow by day; at night the page's black with the `line` border alone (no lit
/// card area, gece_oled.md step 1).
private struct SozlukCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous)
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                shape
                    .fill(colorScheme == .dark ? Theme.bg : Theme.surface)
                    .shadow(color: colorScheme == .dark ? .clear : Theme.shadowNear, radius: 1, x: 0, y: 1)
            }
            .overlay {
                shape.strokeBorder(Theme.line, lineWidth: 1)
            }
    }
}

private extension View {
    func sozlukCard() -> some View {
        modifier(SozlukCardModifier())
    }

    /// iOS 26: a solid edge effect under the bar on a scrolled page (10-geri-alindi), so the
    /// status bar and the back button do not stand on the text that scrolled under them.
    /// iOS 17–25 keep the system's own bar.
    @ViewBuilder func hardTopScrollEdge() -> some View {
        if #available(iOS 26.0, *) {
            scrollEdgeEffectStyle(.hard, for: .top)
        } else {
            self
        }
    }
}

/// "Sahte dost" (docs/tasarim/terimler.md): the card's one-line warning ("aktüel ≠ actually ·
/// aktüel = current", `CardWarningLine`, read part by part in the right voice) under its name,
/// then what the Turkish word means, in a `surface2` box like the Dikkat boxes.
private struct SozlukFalseFriendBox: View {
    let friend: CardDetail.FalseFriend
    let lemma: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // As the Dikkat box's heading (`MistakeBox`).
            Text("Sahte dost")
                .font(.callout.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            CardWarningLine(warning: .falseFriend(friend), lemma: lemma)
            if !friend.trMeans.isEmpty {
                // No suffix on the word (terimler.md): "aktüel Türkçede: güncel".
                Text(verbatim: "\(friend.trWord) Türkçede: \(friend.trMeans)")
                    .font(.callout)
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(3)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
    }
}

/// A note with its icon and bold title ("Not", "Hafıza ipucu"), one row of the notes card.
private struct SozlukInfoRow: View {
    let systemImage: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.bold))
                Text(text)
                    .lineSpacing(3)
            }
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.callout)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

/// The English word on its phosphor band, at the Large Title size (34 pt, scaled with Dynamic
/// Type: the page's title, the bar above it stays inline). A phrase too long for one line first
/// tries the Title 1 size (28 pt), then breaks into two balanced lines, each on its own band; a
/// single long word shrinks instead. VoiceOver reads it once, as a heading, with an English voice.
private struct WordDetailHeadline: View {
    let lemma: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            line(lemma, size: 34)
            line(lemma, size: 28)
            if let lines = WordDetailHeadline.balancedLines(lemma) {
                VStack(alignment: .leading, spacing: 12) {
                    line(lines.first, size: 34)
                    line(lines.second, size: 34)
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

/// A word partner ("have breakfast"): a chip in serif (English) with a small speaker; a tap reads
/// the phrase aloud, a second tap stops it. The speaker waves while it reads, unless Reduce
/// Motion is on. VoiceOver name "Dinle: have breakfast" (the phrase in its English run), "Durdur"
/// while it reads; no hint, as on every speaker button.
private struct WordDetailCollocationCapsule: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let phrase: String

    var body: some View {
        let isSpeaking = speaker.speakingText == phrase
        Button {
            speaker.toggle(phrase)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
                    .accessibilityHidden(true)
                // Callout, as the card's "Neden?" chip (`CardWhyChip`): the page's secondary size.
                Text(verbatim: phrase)
                    .font(.system(.callout, design: .serif).weight(.semibold))
            }
        }
        .buttonStyle(ChipButtonStyle())
        .accessibilityLabel(isSpeaking ? Text("Durdur") : SozlukSpeech.label([.turkish("Dinle: "), .english(phrase)]))
        // Voice Control: "Dinle'ye dokun", as on the other speaker buttons.
        .accessibilityInputLabels([Text(isSpeaking ? "Durdur" : "Dinle")])
    }
}

// MARK: - Durum

/// "Durum", last on the page (ogrenme_ilkeleri 2.6): a card with where the word stands (an icon
/// and a word, rule 4; the same icons as the marks and filters of Sözlük's lists) and one short
/// sentence, then the one outlined button that changes it, full width. Not a segment: nothing
/// looks selected. The button is replaced by the other one; VoiceOver hears what changed and its
/// focus moves to the new button (audit V7).
private struct SozlukStatusSection: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// On the status button: kept there when it is replaced by the other one.
    @AccessibilityFocusState private var buttonHasFocus: Bool
    let word: WidgetWord

    var body: some View {
        let state = model.learningState(of: word)
        SozlukPageSection(title: "Durum") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: SozlukStatus.symbol(state))
                        .font(.title3)
                        .foregroundStyle(state == .known ? Theme.good : Theme.ink)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(SozlukStatus.title(state))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(state == .known ? Theme.good : Theme.ink)
                        Text(explanation(state))
                            .font(.callout)
                            .foregroundStyle(Theme.ink2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
                button(state)
            }
            .padding(16)
            .sozlukCard()
        }
    }

    @ViewBuilder
    private func button(_ state: LearningState) -> some View {
        if state == .known {
            Button {
                change {
                    model.undoKnown(word)
                }
                if model.learningState(of: word) != .known {
                    // terimler.md: "Öğrenmeye döndü: breakfast" (no suffix on the word).
                    SozlukSpeech.announce([.turkish("Öğrenmeye döndü: "), .english(word.lemma)])
                }
            } label: {
                Label("Öğrenmeye geri al", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 50))
            .accessibilityLabel("Öğrenmeye geri al")
            .accessibilityHint("Kelime yine widget'a ve Tekrar'a gelir.")
            .accessibilityFocused($buttonHasFocus)
        } else {
            Button {
                change {
                    model.markKnown(word)
                }
                if model.learningState(of: word) == .known {
                    // As the feed's "Tamam. 3 gün sonra bir kez soracağız." (`KnownUndo`).
                    var runs: [SozlukSpeech.Run] = [.turkish("Biliyorum olarak işaretlendi: "), .english(word.lemma)]
                    if let check = checkLine {
                        runs.append(.turkish(". " + check))
                    }
                    SozlukSpeech.announce(runs)
                }
            } label: {
                Label("Biliyorum olarak işaretle", systemImage: "checkmark")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 50))
            .accessibilityLabel("Biliyorum olarak işaretle")
            // `Leitner.markKnown`: one check question later (ogrenme_ilkeleri 2.2).
            .accessibilityHint(Text(verbatim: "Kelime widget'tan çıkar. \(SozlukStatusSection.checkDays) gün sonra bir kez soracağız."))
            .accessibilityFocused($buttonHasFocus)
            // LockglowScreenshotTests looks this button up as "Biliyorum".
            .accessibilityIdentifier("Biliyorum")
        }
    }

    /// One short sentence under the status (terimler.md: "sen" for the user, "biz" for the app;
    /// no promise of a time that may not hold).
    private func explanation(_ state: LearningState) -> String {
        switch state {
        case .new:
            return "Henüz çalışmaya başlamadın."
        case .learning:
            return "Bu kelimeyi Tekrar'da çalışıyorsun."
        case .known:
            // A "Biliyorum" still waiting for its one check question (ogrenme_ilkeleri 2.2).
            return checkLine ?? "Arada bir yine soracağız."
        }
    }

    /// Days until the check question of a new "Biliyorum" (`Leitner.knownCheckDelay`).
    private static let checkDays = Int((Leitner.knownCheckDelay / 86_400).rounded())

    /// "3 gün sonra bir kez soracağız." while the word waits for its check, from its due date
    /// (`FeedView.checkLine`); nil for a word learned in "Tekrar".
    private var checkLine: String? {
        guard let progress = model.progress[word.id], progress.awaitsKnownCheck else {
            return nil
        }
        return FeedView.checkLine(due: progress.dueAt)
    }

    /// The change, then VoiceOver's focus on the button that replaced the tapped one, once it is
    /// on screen.
    private func change(_ update: () -> Void) {
        let hadFocus = buttonHasFocus
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            update()
        }
        guard hadFocus else {
            return
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            buttonHasFocus = true
        }
    }
}
