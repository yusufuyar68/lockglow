import SwiftUI
import UIKit
import CoreModels
import Learning

// The two questions of "Cümle kur" (SentencePracticeView): put the words in order
// (`SentenceBuildCard`) and "Hangisi birlikte kullanılır?" (`CollocationChoiceCard`). Each reports
// only whether it was right; nothing here grades a word.

// MARK: - Put the words in order

/// "Cümleyi kur": the sentence's Turkish, the learner's sentence and the mixed word tiles. A tap
/// on a tile puts it at the end of the sentence, a tap on a placed tile takes it back; with
/// VoiceOver this is the whole interaction ("dokunarak sıraya koy"), and after each tap VoiceOver
/// reads the sentence so far in an English voice and moves on to the next free tile (a new card
/// starts on its "Cümleyi kur" line, "Kontrol et" moves on to "Devam"). Without
/// VoiceOver a placed tile can also be dragged to another place, or a free one dropped between
/// two placed ones. "Kontrol et" compares by folded keys (`SentenceTiles.check`); the feedback
/// shows the sentence as written, the word marked, with "Dinle", and on a miss the tiles whose
/// place differs, marked with an icon (never color alone). Give each question its own identity
/// (`.id`) so the state resets.
struct SentenceBuildCard: View {
    let tiles: SentenceTiles
    /// The sentence's Turkish: the prompt. Nil for a sentence without one (a user's own word).
    let translation: String?
    /// The practiced word, marked in the checked sentence.
    let lemma: String?
    let onContinue: (Bool) -> Void

    /// The tiles in their mixed order; a placed tile leaves an empty place here.
    @State private var bank: [SentenceTiles.Tile]
    @State private var placed: [SentenceTiles.Tile] = []
    @State private var check: SentenceTiles.Check?
    @AccessibilityFocusState private var focus: BuildFocus?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    private enum BuildFocus: Hashable {
        case header
        case bank(Int)
        case checkButton
        case continueButton
    }

    init(tiles: SentenceTiles, translation: String?, lemma: String?, seed: Int, attempt: Int, onContinue: @escaping (Bool) -> Void) {
        self.tiles = tiles
        self.translation = translation
        self.lemma = lemma
        self.onContinue = onContinue
        _bank = State(initialValue: tiles.shuffled(seed: seed, attempt: attempt))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cümleyi kur")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($focus, equals: .header)
                PracticePrompt(translation: translation, fallback: "Kelimeleri doğru sıraya koy.")
                answerArea
                if let check = check {
                    feedback(check)
                } else {
                    bankArea
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
        .scrollBounceBehavior(.basedOnSize)
        // Opaque (rule 6): the main button never sits on glass.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomButton
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background(Theme.bg)
        }
        // A light haptic on a right sentence only; a miss stays silent (learning principles 2.4).
        .sensoryFeedback(.success, trigger: check?.isCorrect == true)
        // The button that brought this card is gone: VoiceOver starts on its first line.
        .onAppear {
            moveFocus(to: .header)
        }
    }

    // MARK: Areas

    /// "Senin cümlen": the placed tiles, then the sentence's final mark once every tile is in.
    /// Also where a free tile is dropped (at the end) and a placed one dropped on another (before it).
    private var answerArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Senin cümlen")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .accessibilityAddTraits(.isHeader)
            Group {
                if placed.isEmpty {
                    Text("Kelimelere sırayla dokun.")
                        .font(.callout)
                        .foregroundStyle(Theme.ink3)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                } else {
                    TileFlow(spacing: 8, lineSpacing: 8) {
                        ForEach(Array(placed.enumerated()), id: \.element.id) { place, tile in
                            if place == tiles.tiles.count - 1 && !tiles.ending.isEmpty {
                                // The final mark stays with the last tile, never alone on a row.
                                HStack(spacing: 3) {
                                    placedTile(tile, at: place)
                                    Text(verbatim: tiles.ending)
                                        .font(Theme.Fonts.definition)
                                        .foregroundStyle(Theme.ink)
                                        .accessibilityHidden(true)
                                }
                            } else {
                                placedTile(tile, at: place)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .cardSurface(cornerRadius: Theme.Radius.box)
            .contentShape(Rectangle())
            .dropDestination(for: String.self) { items, _ in
                guard let dropped = tile(in: items) else {
                    return false
                }
                place(dropped, before: nil)
                return true
            }
            if check == nil && !placed.isEmpty {
                Text("Çıkarmak için kelimeye dokun.")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
            }
        }
    }

    /// The free tiles in their mixed order. A placed tile leaves its outline, so the others never
    /// move under the finger. A placed tile dropped here comes back.
    private var bankArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kelimeler")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .accessibilityAddTraits(.isHeader)
            TileFlow(spacing: 8, lineSpacing: 10) {
                ForEach(bank) { tile in
                    if isPlaced(tile) {
                        TileFace(text: tile.text)
                            .hidden()
                            .overlay {
                                Capsule()
                                    .strokeBorder(Theme.line, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            }
                            .accessibilityHidden(true)
                    } else {
                        Button {
                            place(tile, before: nil)
                        } label: {
                            TileFace(text: tile.text)
                        }
                        .buttonStyle(TileButtonStyle())
                        .accessibilityLabel(Text(verbatim: tile.text))
                        .englishVoice()
                        .accessibilityFocused($focus, equals: .bank(tile.id))
                        .accessibilityIdentifier("practice.tile")
                        .draggable(String(tile.id)) {
                            TileFace(text: tile.text)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .topLeading)
            .contentShape(Rectangle())
            .dropDestination(for: String.self) { items, _ in
                guard let dropped = tile(in: items), isPlaced(dropped) else {
                    return false
                }
                remove(dropped)
                return true
            }
        }
    }

    /// A placed tile: a tap takes it back; dragged, it moves; a tile dropped on it goes before it.
    /// After "Kontrol et" it is plain text, a tile whose place differs marked with an icon.
    @ViewBuilder
    private func placedTile(_ tile: SentenceTiles.Tile, at place: Int) -> some View {
        if let check = check {
            let isMisplaced = check.misplaced.contains(place)
            TileFace(text: tile.text, mark: isMisplaced ? TileFace.Mark.misplaced : (check.isCorrect ? TileFace.Mark.right : nil))
                .accessibilityRepresentation {
                    Text(verbatim: tile.text)
                        .englishVoice()
                    if isMisplaced {
                        Text("yeri farklı")
                    }
                }
        } else {
            Button {
                remove(tile)
            } label: {
                TileFace(text: tile.text)
            }
            .buttonStyle(TileButtonStyle())
            .accessibilityLabel(Text(verbatim: tile.text))
            .englishVoice()
            .draggable(String(tile.id)) {
                TileFace(text: tile.text)
            }
            .dropDestination(for: String.self) { items, _ in
                guard let dropped = self.tile(in: items) else {
                    return false
                }
                self.place(dropped, before: tile)
                return true
            }
        }
    }

    @ViewBuilder
    private var bottomButton: some View {
        if let check = check {
            Button("Devam") {
                onContinue(check.isCorrect)
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            .accessibilityFocused($focus, equals: .continueButton)
        } else {
            Button("Kontrol et") {
                checkSentence()
            }
            .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
            .disabled(placed.count < tiles.tiles.count)
            .accessibilityFocused($focus, equals: .checkButton)
        }
    }

    // MARK: Feedback

    /// Mockup `.fb`: "Doğru." or "Doğrusu:", the sentence as written with the word marked, its
    /// Turkish and "Dinle". On a miss also how to read the marks. About the sentence, never the
    /// learner (learning principles 1 item 12).
    private func feedback(_ check: SentenceTiles.Check) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(check.isCorrect ? "Doğru." : "Doğrusu:")
            } icon: {
                Image(systemName: check.isCorrect ? "checkmark.circle.fill" : "lightbulb")
                    .foregroundStyle(check.isCorrect ? Theme.good : Theme.ink2)
                    .accessibilityHidden(true)
            }
            .font(.body.weight(.bold))
            .foregroundStyle(Theme.ink)
            PracticeSentence(sentence: tiles.sentence, lemma: lemma)
            if let translation = translation {
                Text(verbatim: "Türkçesi: " + translation)
                    .exampleTranslationStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !check.isCorrect && !check.misplaced.isEmpty {
                Label {
                    Text("Yeri farklı olan kelimeler işaretli.")
                } icon: {
                    Image(systemName: "arrow.left.arrow.right")
                        .accessibilityHidden(true)
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.ink2)
            }
            PracticeListenButton(text: tiles.sentence)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        // Not `.combine`: one element is read in one voice, and the sentence needs its own.
        .accessibilityElement(children: .contain)
    }

    // MARK: Actions

    private func isPlaced(_ tile: SentenceTiles.Tile) -> Bool {
        return placed.contains { $0.id == tile.id }
    }

    /// The tile a drag carries: its id as text. Anything else (text dragged from elsewhere) is not.
    private func tile(in items: [String]) -> SentenceTiles.Tile? {
        guard check == nil, let first = items.first, let id = Int(first) else {
            return nil
        }
        return tiles.tiles.first { $0.id == id }
    }

    /// Puts `tile` before `target`, or at the end; a placed tile moves.
    private func place(_ tile: SentenceTiles.Tile, before target: SentenceTiles.Tile?) {
        guard check == nil, tile.id != target?.id else {
            return
        }
        let wasPlaced = isPlaced(tile)
        var next = placed.filter { $0.id != tile.id }
        if let target = target, let at = next.firstIndex(where: { $0.id == target.id }) {
            next.insert(tile, at: at)
        } else {
            next.append(tile)
        }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
            placed = next
        }
        if !wasPlaced {
            afterPlacing(tile)
        } else {
            readBack()
        }
    }

    private func remove(_ tile: SentenceTiles.Tile) {
        guard check == nil else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
            placed.removeAll { $0.id == tile.id }
        }
        readBack()
        // The tile is free again, in its old place: VoiceOver goes there.
        moveFocus(to: .bank(tile.id))
    }

    /// VoiceOver goes on to the next free tile in the mixed order, or to "Kontrol et" when all
    /// are placed: the tapped tile is gone, and the focus would be left nowhere (audit V1).
    private func afterPlacing(_ tile: SentenceTiles.Tile) {
        readBack()
        guard voiceOverEnabled else {
            return
        }
        let start = bank.firstIndex(where: { $0.id == tile.id }) ?? 0
        let rotated = Array(bank[start...]) + Array(bank[..<start])
        if let next = rotated.first(where: { !isPlaced($0) }) {
            moveFocus(to: .bank(next.id))
        } else {
            moveFocus(to: .checkButton)
        }
    }

    private func checkSentence() {
        guard placed.count == tiles.tiles.count else {
            return
        }
        let result = tiles.check(placed)
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            check = result
        }
        // The announcement says how it went and reads the sentence; the focus waits on "Devam"
        // ("Kontrol et" is gone), so the feedback is not read twice.
        announce(isCorrect: result.isCorrect)
        moveFocus(to: .continueButton)
    }

    private func moveFocus(to target: BuildFocus) {
        guard voiceOverEnabled else {
            return
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            focus = target
        }
    }

    /// VoiceOver hears the sentence so far, in an English voice, after the tap's own speech.
    private func readBack() {
        guard voiceOverEnabled else {
            return
        }
        let line = tiles.line(placed)
        let text = line.isEmpty
            ? NSMutableAttributedString(string: "Cümle boş.", attributes: [.accessibilitySpeechLanguage: "tr-TR"])
            : NSMutableAttributedString(string: line, attributes: [.accessibilitySpeechLanguage: "en-US"])
        PracticeAnnouncement.post(text)
    }

    /// "Doğru. Can I have a spoon, please?" or "Doğrusu: …", the sentence in an English voice.
    private func announce(isCorrect: Bool) {
        let text = NSMutableAttributedString(
            string: isCorrect ? "Doğru. " : "Doğrusu: ",
            attributes: [.accessibilitySpeechLanguage: "tr-TR"]
        )
        text.append(NSAttributedString(string: tiles.sentence, attributes: [.accessibilitySpeechLanguage: "en-US"]))
        PracticeAnnouncement.post(text)
    }
}

// MARK: - Which verb goes with it

/// "Hangisi birlikte kullanılır?": the sentence (or a card's collocation) with its verb left out
/// as a marked slot, the Turkish under it, and two equal option capsules ("made" / "did") in an
/// order mixed by seed and attempt. After a tap only the right option ("Doğru cevap") and a wrong
/// pick ("Yanlış") stay, marked with icons and words; the sentence reads in full with the verb
/// bold and "Dinle", and the feedback names the pair ("Birlikte kullanılır: make a mistake"). On a
/// miss, when Turkish says both with one verb (`CollocationChoice.sharesTurkishVerb`), one line
/// says so.
struct CollocationChoiceCard: View {
    let choice: CollocationChoice
    let translation: String?
    let onContinue: (Bool) -> Void

    @State private var picked: String?
    @State private var options: [String]
    @AccessibilityFocusState private var focusesHeader: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    init(choice: CollocationChoice, translation: String?, seed: Int, attempt: Int, onContinue: @escaping (Bool) -> Void) {
        self.choice = choice
        self.translation = translation
        self.onContinue = onContinue
        _options = State(initialValue: choice.options(seed: seed, attempt: attempt))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hangisi birlikte kullanılır?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($focusesHeader)
                sentenceCard
                optionRow
                if let picked = picked {
                    feedback(isRight: picked == choice.answer)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let picked = picked {
                Button("Devam") {
                    onContinue(picked == choice.answer)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background(Theme.bg)
                .transition(.opacity)
            }
        }
        .sensoryFeedback(.success, trigger: picked) { oldValue, newValue in
            oldValue == nil && newValue == choice.answer
        }
        // The button that brought this card is gone: VoiceOver starts on its first line.
        .onAppear {
            guard voiceOverEnabled else {
                return
            }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 150_000_000)
                focusesHeader = true
            }
        }
    }

    /// The text with its slot (before the answer) or with the verb bold (after it), read with an
    /// English voice; the Turkish under it in the Turkish voice.
    private var sentenceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                if picked == nil {
                    Text(blankText)
                        .accessibilityLabel(Text(verbatim: choice.before + "blank" + choice.after))
                } else {
                    Text(filledText)
                }
            }
            .font(.system(.title2, design: .serif))
            .foregroundStyle(Theme.ink)
            .englishVoice()
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            if let translation = translation {
                Text(verbatim: "Türkçesi: " + translation)
                    .exampleTranslationStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
            if picked != nil {
                PracticeListenButton(text: choice.filled)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .cardSurface(cornerRadius: Theme.Radius.card)
    }

    /// The slot: a bold line on a `surface2` field, as in the quiz's blank.
    private var blankText: AttributedString {
        var slot = AttributedString(String(repeating: "_", count: 7))
        slot.inlinePresentationIntent = .stronglyEmphasized
        slot.backgroundColor = Theme.surface2
        var result = AttributedString(choice.before)
        result.append(slot)
        result.append(AttributedString(choice.after))
        return result
    }

    private var filledText: AttributedString {
        var verb = AttributedString(choice.answer)
        verb.inlinePresentationIntent = .stronglyEmphasized
        verb.underlineStyle = Text.LineStyle(pattern: .solid)
        var result = AttributedString(choice.before)
        result.append(verb)
        result.append(AttributedString(choice.after))
        return result
    }

    /// Two equal capsules side by side, stacked at accessibility sizes. After the answer only the
    /// right one and a wrong pick stay.
    private var optionRow: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 10))
            : AnyLayout(HStackLayout(spacing: 10))
        let shown = picked.map { $0 == choice.answer ? [choice.answer] : options } ?? options
        return layout {
            ForEach(shown, id: \.self) { option in
                optionButton(option)
            }
        }
    }

    private func optionButton(_ option: String) -> some View {
        let mark = optionMark(option)
        return Button {
            pick(option)
        } label: {
            HStack(spacing: 8) {
                Text(verbatim: option)
                    .font(Theme.Fonts.definition)
                    .foregroundStyle(Theme.ink)
                    .englishVoice()
                if let mark = mark {
                    Label {
                        Text(mark.text)
                    } icon: {
                        Image(systemName: mark.symbol)
                            .accessibilityHidden(true)
                    }
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(mark.color)
                    .fixedSize()
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(mark?.fill ?? Theme.surface, in: Capsule())
            .overlay {
                Capsule().strokeBorder(mark?.border ?? Theme.lineStrong, lineWidth: mark == nil ? 1.5 : 2)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(TileButtonStyle())
        // Not `.disabled`: that would dim the options exactly when the answer is shown.
        .allowsHitTesting(picked == nil)
        // One element has one voice: the English option alone, then (after the answer) its mark.
        .accessibilityRepresentation {
            if picked == nil {
                Button {
                    pick(option)
                } label: {
                    Text(verbatim: option)
                        .englishVoice()
                }
                .accessibilityIdentifier("practice.option")
            } else {
                Text(verbatim: option)
                    .englishVoice()
                if let mark = mark {
                    Text(mark.text)
                }
            }
        }
    }

    private struct OptionMark: Equatable {
        let text: String
        let symbol: String
        let color: Color
        let fill: Color
        let border: Color
    }

    /// The right option in `good` with a check; a wrong pick on paper with a cross in ink2.
    private func optionMark(_ option: String) -> OptionMark? {
        guard let picked = picked else {
            return nil
        }
        if option == choice.answer {
            return OptionMark(text: "Doğru cevap", symbol: "checkmark.circle.fill", color: Theme.good, fill: Theme.goodTint, border: Theme.good)
        }
        if option == picked {
            return OptionMark(text: "Yanlış", symbol: "xmark.circle", color: Theme.ink2, fill: Theme.surface, border: Theme.lineStrong)
        }
        return nil
    }

    private func feedback(isRight: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                if isRight {
                    Text("Doğru.")
                } else {
                    Text("Doğrusu: \(Text(verbatim: choice.answer).font(.system(.body, design: .serif).weight(.bold)))")
                }
            } icon: {
                Image(systemName: isRight ? "checkmark.circle.fill" : "lightbulb")
                    .foregroundStyle(isRight ? Theme.good : Theme.ink2)
                    .accessibilityHidden(true)
            }
            .font(.body.weight(.bold))
            .foregroundStyle(Theme.ink)
            .accessibilityRepresentation {
                if isRight {
                    Text("Doğru.")
                } else {
                    FeedbackSpeech(lead: "Doğrusu:", english: choice.answer, meaning: nil)
                }
            }
            Text("Birlikte kullanılır: \(Text(verbatim: choice.phrase).font(.system(.callout, design: .serif).weight(.bold)))")
                .font(.callout)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityRepresentation {
                    FeedbackSpeech(lead: "Birlikte kullanılır:", english: choice.phrase, meaning: nil)
                }
            // Only where it is true: "make friends" is "arkadaş edinmek", not "yapmak".
            if !isRight && choice.sharesTurkishVerb {
                Text(choice.pair == .makeDo
                     ? "Türkçede ikisine de çoğu zaman “yapmak” deriz."
                     : "Türkçede ikisine de çoğu zaman “söylemek” deriz.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func pick(_ option: String) {
        guard picked == nil else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            picked = option
        }
        let text = NSMutableAttributedString(
            string: option == choice.answer ? "Doğru. " : "Doğrusu: ",
            attributes: [.accessibilitySpeechLanguage: "tr-TR"]
        )
        text.append(NSAttributedString(string: choice.answer, attributes: [.accessibilitySpeechLanguage: "en-US"]))
        // The tapped option stays (as text), so the focus stays with it: only the announcement.
        PracticeAnnouncement.post(text)
    }
}

// MARK: - Pieces

/// The Turkish prompt of a question in a card: "Türkçesi" over the sentence's Turkish, or a plain
/// instruction when there is no Turkish.
struct PracticePrompt: View {
    let translation: String?
    let fallback: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let translation = translation {
                Text("Türkçesi")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                Text(verbatim: translation)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(verbatim: fallback)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: Theme.Radius.card)
        .accessibilityElement(children: .combine)
    }
}

/// The checked sentence as written, the practiced word marked like in an example (rule 1), read
/// with an English voice.
struct PracticeSentence: View {
    let sentence: String
    let lemma: String?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if let lemma = lemma {
                Text(ExampleMark.attributed(sentence, lemma: lemma, colorScheme: colorScheme))
            } else {
                Text(verbatim: sentence)
            }
        }
        .font(.system(.title3, design: .serif))
        .foregroundStyle(Theme.ink)
        .lineSpacing(4)
        .fixedSize(horizontal: false, vertical: true)
        .englishVoice()
    }
}

/// A word tile: serif (it is English), a calm capsule with a `lineStrong` edge, at least 44 pt
/// high. After the check a tile whose place differs gets an icon and a dotted ink2 edge; in a
/// right sentence every tile gets a `good` edge.
struct TileFace: View {
    enum Mark {
        case right
        case misplaced
    }

    let text: String
    var mark: Mark?

    var body: some View {
        HStack(spacing: 6) {
            Text(verbatim: text)
                .font(Theme.Fonts.definition)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if mark == .misplaced {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
        .background(mark == .right ? Theme.goodTint : Theme.surface, in: Capsule())
        .overlay {
            switch mark {
            case .right:
                Capsule().strokeBorder(Theme.good, lineWidth: 2)
            case .misplaced:
                Capsule().strokeBorder(Theme.ink2, style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
            case nil:
                Capsule().strokeBorder(Theme.lineStrong, lineWidth: 1.5)
            }
        }
        .contentShape(Capsule())
    }
}

/// Pressed state of a tile or option: a light dip, no scaling under Reduce Motion.
struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        TilePressBody(configuration: configuration)
    }
}

private struct TilePressBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Tiles left to right, wrapping into rows like words in a line: each keeps its own width (one
/// wider than the row gets the row's width and wraps its text).
struct TileFlow: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let places = arrange(width: width, subviews: subviews)
        let height = places.map { $0.frame.maxY }.max() ?? 0
        let usedWidth = places.map { $0.frame.maxX }.max() ?? 0
        return CGSize(width: width.isFinite ? width : usedWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for place in arrange(width: bounds.width, subviews: subviews) {
            subviews[place.index].place(
                at: CGPoint(x: bounds.minX + place.frame.minX, y: bounds.minY + place.frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: place.frame.width, height: place.frame.height)
            )
        }
    }

    private struct Place {
        let index: Int
        var frame: CGRect
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Place] {
        var places: [Place] = []
        var rowStart = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for index in subviews.indices {
            var size = subviews[index].sizeThatFits(.unspecified)
            if width.isFinite && size.width > width {
                size = subviews[index].sizeThatFits(ProposedViewSize(width: width, height: nil))
                size.width = min(size.width, width)
            }
            if index > rowStart && x + spacing + size.width > width {
                y += rowHeight + lineSpacing
                x = 0
                rowHeight = 0
                rowStart = index
            }
            let originX = index == rowStart ? 0 : x + spacing
            places.append(Place(index: index, frame: CGRect(x: originX, y: y, width: size.width, height: size.height)))
            x = originX + size.width
            rowHeight = max(rowHeight, size.height)
        }
        return places
    }
}

/// "Dinle" under the checked sentence (like the quiz's): a `surface2` capsule that reads the
/// sentence aloud; a second tap stops it. The speaker waves while it reads, unless Reduce Motion
/// is on.
struct PracticeListenButton: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let text: String

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            Label {
                Text("Dinle")
            } icon: {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
            }
            .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
        .accessibilityLabel(Text(isSpeaking ? "Durdur" : "Cümleyi dinle"))
        .accessibilityInputLabels(isSpeaking ? [Text("Durdur")] : [Text("Dinle"), Text("Cümleyi dinle")])
    }
}

/// VoiceOver announcements of the practice: queued after the tap's own speech, at high priority
/// (as in the quiz, audit V8), each part in its own voice.
enum PracticeAnnouncement {
    static func post(_ text: NSMutableAttributedString) {
        let whole = NSRange(location: 0, length: text.length)
        text.addAttribute(.accessibilitySpeechQueueAnnouncement, value: true, range: whole)
        text.addAttribute(.accessibilitySpeechAnnouncementPriority, value: UIAccessibilityPriority.high, range: whole)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }
}
