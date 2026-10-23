import SwiftUI
import CoreModels

/// "Neden?" of an "Akış" card (ogrenme_ilkeleri 2.2): what is behind the card's one-line warning,
/// on a sheet that opens at half height, set like the card itself (one column, hairlines, no
/// boxes). First the word, so the sheet says which card it explains; then the warning's own
/// explanation: the false friend as three aligned lines (aktüel ≠ actually / aktüel = güncel →
/// current / actually = aslında), or the whole Dikkat note; then the card's Turkish note
/// (`noteTR`), its other mistakes, its collocations one per line and its other examples. Nothing
/// here opens another sheet. VoiceOver hears the false friend lines with the same words as
/// `CardWhySheet` (Turkish and English parts each in their own voice).
struct FeedWhySheet: View {
    let word: WidgetWord
    let detail: CardDetail?
    let warning: CardWarning
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // No band: the card behind the sheet already has the word's one yellow mark.
                    // Title serif bold (28 pt at the default size); a phrase wraps, never shrinks.
                    // It stops growing at AX3 (48 pt, the old cap), so a long word rarely breaks.
                    Text(verbatim: word.lemma)
                        .font(.system(.title, design: .serif).weight(.bold))
                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .englishVoice()
                    lead
                        .padding(.top, 16)
                    ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                        FeedCardRule()
                            .padding(.vertical, 20)
                        sectionView(section)
                    }
                }
                // The HIG side margin.
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background {
                Theme.surface
                    .ignoresSafeArea()
            }
            .navigationTitle("Neden?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
        // Rule 2: no blue link color on "Kapat".
        .tint(Theme.ink)
        // Half height shows too little at accessibility sizes: the whole height at once.
        .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.medium, .large])
        // The grabber also lets VoiceOver users resize the sheet (HIG Sheets).
        .presentationDragIndicator(.visible)
        // Opaque like the cards (rule 6): the explanation is read, not glanced at.
        .presentationBackground(Theme.surface)
    }

    // MARK: Lead

    /// The warning's own explanation. A false friend card also gets its Dikkat note here, since
    /// the false friend took the card's one slot. The other lines have no "Neden?" on the card;
    /// should one open the sheet, it starts with the card's note.
    @ViewBuilder
    private var lead: some View {
        switch warning {
        case let .falseFriend(friend):
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Sahte dost")
                falseFriendLines(friend)
            }
            if let mistake = leadMistake {
                FeedCardRule()
                    .padding(.vertical, 20)
                FeedMistakeNote(mistake: mistake)
            }
        case let .mistake(mistake):
            FeedMistakeNote(mistake: mistake)
        case .sameWord, .phrasalVerb:
            EmptyView()
        }
    }

    /// aktüel ≠ actually / aktüel = güncel → current / actually = aslında, in three columns so the
    /// three words on the left line up. At accessibility sizes each line wraps on its own.
    @ViewBuilder
    private func falseFriendLines(_ friend: CardDetail.FalseFriend) -> some View {
        let lines = FeedWhySheet.falseFriendParts(friend, lemma: word.lemma, gloss: word.glossTR)
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    CardFlowLayout(itemSpacing: 6, lineSpacing: 4) {
                        ForEach(Array((line.left + [line.sign] + line.right).enumerated()), id: \.offset) { _, part in
                            CardLinePartView(part: part)
                        }
                    }
                    .accessibilityElement(children: .contain)
                }
            }
        } else {
            // Centered rows: a custom layout (`CardFlowLayout`) has no text baseline to align on.
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    GridRow {
                        CardFlowLayout(itemSpacing: 6, lineSpacing: 4) {
                            ForEach(Array(line.left.enumerated()), id: \.offset) { _, part in
                                CardLinePartView(part: part)
                            }
                        }
                        CardLinePartView(part: line.sign)
                        CardFlowLayout(itemSpacing: 6, lineSpacing: 4) {
                            ForEach(Array(line.right.enumerated()), id: \.offset) { _, part in
                                CardLinePartView(part: part)
                            }
                        }
                        .gridCellAnchor(.leading)
                    }
                }
            }
        }
    }

    /// One false friend line: the parts before the sign, the sign, the parts after it.
    struct FalseFriendLine {
        let left: [CardLinePart]
        let sign: CardLinePart
        let right: [CardLinePart]
    }

    /// The three lines of `CardWhySheet` with the same spoken words, split at their sign. The
    /// third needs the card's gloss; without it there are two.
    static func falseFriendParts(_ friend: CardDetail.FalseFriend, lemma: String, gloss: String?) -> [FalseFriendLine] {
        var lines = [
            FalseFriendLine(
                left: [.turkish(friend.trWord, spoken: "\(friend.trWord), eşit değil")],
                sign: .sign("≠"),
                right: [.english(AttributedString(lemma))]
            ),
            FalseFriendLine(
                left: [.turkish(friend.trWord, spoken: "\(friend.trWord):")],
                sign: .sign("="),
                right: [
                    .turkish(friend.trMeans, spoken: "\(friend.trMeans). İngilizcede"),
                    .sign("→"),
                    .english(AttributedString(friend.enForThat), bold: true)
                ]
            )
        ]
        if let gloss = gloss {
            lines.append(FalseFriendLine(
                left: [.english(AttributedString(lemma), bold: true)],
                sign: .sign("="),
                right: [.turkish(gloss, spoken: "Türkçede: \(gloss)")]
            ))
        }
        return lines
    }

    // MARK: Sections

    private enum Section {
        case note(String)
        case otherMistakes([CardDetail.Mistake])
        case collocations([String])
        case examples([CardDetail.Example])
    }

    /// What follows the lead, each after a hairline; empty parts are left out.
    private var sections: [Section] {
        var sections: [Section] = []
        // A user's own word: its note is the user's, shown on the whole card instead.
        if !word.isUserAdded, let note = detail?.noteTR, !note.isEmpty {
            sections.append(.note(note))
        }
        if !otherMistakes.isEmpty {
            sections.append(.otherMistakes(otherMistakes))
        }
        if let collocations = detail?.collocations, !collocations.isEmpty {
            sections.append(.collocations(collocations))
        }
        if !otherExamples.isEmpty {
            sections.append(.examples(otherExamples))
        }
        return sections
    }

    @ViewBuilder
    private func sectionView(_ section: Section) -> some View {
        switch section {
        case let .note(note):
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Not")
                Text(note)
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case let .otherMistakes(mistakes):
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(mistakes.enumerated()), id: \.offset) { _, mistake in
                    FeedMistakeNote(mistake: mistake)
                }
            }
        case let .collocations(collocations):
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Birlikte kullanılır")
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(collocations.enumerated()), id: \.offset) { _, collocation in
                        // The examples' serif size: one size for the sheet's English text.
                        Text(verbatim: collocation)
                            .exampleFont()
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                            .englishVoice()
                    }
                }
            }
        case let .examples(examples):
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Başka örnekler")
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(examples.enumerated()), id: \.offset) { _, example in
                        ExampleRow(example: example, lemma: word.lemma)
                    }
                }
            }
        }
    }

    /// A bold Callout heading in `ink2` (at least 7:1 on `surface`): the size of the sheet's
    /// Turkish lines, so the sheet keeps few text sizes (the word's Title, Body for the note and
    /// the English text, Callout).
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.callout.weight(.bold))
            .foregroundStyle(Theme.ink2)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: Content

    private var leadMistake: CardDetail.Mistake? {
        if case let .mistake(mistake) = warning {
            return mistake
        }
        if case .falseFriend = warning {
            return detail?.cardMistake(lemma: word.lemma)
        }
        return nil
    }

    private var otherMistakes: [CardDetail.Mistake] {
        let lead = leadMistake
        return (detail?.mistakes ?? []).filter { $0 != lead }
    }

    /// Every example but the one on the card (`exampleEN`, else the detail's first, as
    /// `FeedCardView` picks it).
    private var otherExamples: [CardDetail.Example] {
        let examples = detail?.examples ?? []
        let shown = examples.first { $0.en == word.exampleEN }?.en ?? examples.first?.en
        return examples.filter { $0.en != shown }
    }
}
