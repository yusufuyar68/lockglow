import SwiftUI
import CoreModels
import Learning

/// "İlerleme": what the user has learned, counted in words, never in a run of days
/// (docs/tasarim/alternatifler/sakin_ilerleme.md; ogrenme_ilkeleri.md 1.11 and 2.5). From the top:
/// the week's calm sentence, two counts, the words met this week as cards that turn over to their
/// example, the library's shelves (Yerleşti on top, Raf 1 at the bottom) with the self-marked words
/// apart, "Raflar nasıl çalışır?" and the topics. No streak, no percentage, no ranking, no praise,
/// no zero: an empty part is left out or says "boş".
///
/// How to call it
///
///     // From the "Tekrar" start screen or "Ayarlar": push it onto the NavigationStack.
///     NavigationLink {
///         ProgressOverviewView(
///             summary: model.progressSummary(),
///             words: model.wordsByID,
///             onRecapShown: { model.markProgressRecapShown(weekStart: $0) }
///         )
///     } label: {
///         SettingsRow("İlerleme")
///     }
///
/// Parameters (plain values: the file needs no `AppModel` or environment object and previews on
/// its own):
/// - `summary`: `ProgressSummary.make(...)` (Learning) for the moment the screen opens.
/// - `words`: the loaded words by id, for headwords, meanings and examples. Pass the same words
///   as `make`'s `wordIDs`; an id without a word is counted but not listed.
/// - `onRecapShown`: called when the screen goes away after showing Monday's recap of last week,
///   with that week's Monday (`summary.note.weekStart`). Save it and pass it back to `make` as
///   `recapShownForWeek`, so the recap shows once.
/// - `onStartReview`: "Tekrar'a git" on the empty library; nil hides the button.
struct ProgressOverviewView: View {
    let summary: ProgressSummary
    let words: [Int: WidgetWord]
    var onRecapShown: (Date) -> Void = { _ in }
    var onStartReview: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The shelf whose words are listed (one at a time).
    @State private var openShelf: ProgressSummary.Shelf?
    @State private var showsHowItWorks = false
    /// The word whose sheet is open.
    @State private var openedWord: WidgetWord?
    @ScaledMetric(relativeTo: .body) private var cardWidth: CGFloat = 220

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if summary.note.kind != .emptyLibrary {
                    NoteCard(note: summary.note)
                }
                if summary.libraryCount == 0 {
                    emptyLibrary
                } else {
                    counts
                    metSection
                    librarySection
                    topicsSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .navigationTitle("İlerleme")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $openedWord) { word in
            ShelfWordSheet(word: word, shelf: shelf(of: word.id))
        }
        .onDisappear {
            if summary.note.kind == .lastWeek {
                onRecapShown(summary.note.weekStart)
            }
        }
    }

    // MARK: Counts

    /// "86 kelime kitaplığında" and, once there are any, "22 kelime üst raflarda".
    private var counts: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 8))
        let longTerm = summary.longTermWordIDs.count
        return layout {
            CountTile(
                value: summary.libraryCount,
                caption: "kelime kitaplığında",
                voiceLabel: "Kitaplığında \(summary.libraryCount) kelime var."
            )
            if longTerm > 0 {
                CountTile(
                    value: longTerm,
                    caption: "kelime üst raflarda",
                    voiceLabel: "\(longTerm) kelime üst raflarda: Raf 4, Raf 5 ya da Yerleşti."
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Words met this week

    /// The week the note speaks about: last week on Monday's recap, this week otherwise.
    private var shownWeek: ProgressSummary.Week {
        return summary.note.kind == .lastWeek ? summary.lastWeek : summary.thisWeek
    }

    @ViewBuilder
    private var metSection: some View {
        let met = shownWeek.metWordIDs.compactMap { words[$0] }
        if !met.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeading(
                    title: "\(summary.note.kind == .lastWeek ? "Geçen hafta" : "Bu hafta") tanıştığın \(met.count) kelime",
                    subtitle: "Karta dokun: örnek cümle görünür."
                )
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 12) {
                        ForEach(met) { word in
                            MetWordCard(word: word, shelf: shelf(of: word.id))
                        }
                    }
                } else {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(met) { word in
                                MetWordCard(word: word, shelf: shelf(of: word.id))
                                    .frame(maxHeight: .infinity, alignment: .top)
                                    .containerRelativeFrame(.horizontal) { length, _ in
                                        min(cardWidth, length * 0.8)
                                    }
                            }
                        }
                        // Every card as tall as the tallest one.
                        .fixedSize(horizontal: false, vertical: true)
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                    .padding(.horizontal, -16)
                }
            }
        }
    }

    // MARK: Library

    private var librarySection: some View {
        let shelves: [ProgressSummary.Shelf] = [.settled, .box5, .box4, .box3, .box2, .box1]
        let selfMarked = summary.words(on: .selfMarked)
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeading(
                title: "Kitaplığın",
                subtitle: "Her doğru cevapta kelime bir üst rafa çıkar. Ara versen de raflar boşalmaz."
            )
            VStack(spacing: 0) {
                ForEach(Array(shelves.enumerated()), id: \.element) { index, shelf in
                    if index > 0 {
                        Rectangle()
                            .fill(Theme.line)
                            .frame(height: 1)
                            .padding(.leading, 14)
                            .accessibilityHidden(true)
                    }
                    ShelfRow(
                        shelf: shelf,
                        words: listedWords(summary.words(on: shelf)),
                        count: summary.words(on: shelf).count,
                        isOpen: openShelf == shelf,
                        toggle: { toggle(shelf) },
                        open: { openedWord = $0 }
                    )
                }
            }
            .cardSurface()
            if !selfMarked.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ShelfRow(
                        shelf: .selfMarked,
                        words: listedWords(selfMarked),
                        count: selfMarked.count,
                        isOpen: openShelf == .selfMarked,
                        toggle: { toggle(.selfMarked) },
                        open: { openedWord = $0 }
                    )
                    Text("Widget'ta ya da Akış'ta “Biliyorum” dediğin kelimeler. Henüz sorulmadılar. Bir kez sorulurlar; bilirsen Yerleşti rafına geçerler.")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 14)
                }
                // Dashed: these words were never tested (sakin_ilerleme.md, Koriat and Bjork 2005).
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                        .strokeBorder(Theme.lineStrong, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                }
            }
            howItWorks
        }
    }

    /// "Raflar nasıl çalışır?": the answers' rules and the waits, from `Leitner`.
    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    showsHowItWorks.toggle()
                }
            } label: {
                Label(
                    showsHowItWorks ? "Kapat" : "Raflar nasıl çalışır?",
                    systemImage: showsHowItWorks ? "chevron.up" : "questionmark.circle"
                )
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
            .accessibilityLabel(Text(verbatim: "Raflar nasıl çalışır?"))
            .accessibilityValue(Text(verbatim: showsHowItWorks ? "açık" : "kapalı"))
            if showsHowItWorks {
                HowShelvesWork()
                    .transition(.opacity)
            }
        }
    }

    // MARK: Topics

    @ViewBuilder
    private var topicsSection: some View {
        let topics = summary.topics.filter { $0.total > 0 }
        if !topics.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeading(title: "Konuların", subtitle: nil)
                VStack(spacing: 0) {
                    ForEach(Array(topics.enumerated()), id: \.element.id) { index, topic in
                        if index > 0 {
                            Rectangle()
                                .fill(Theme.line)
                                .frame(height: 1)
                                .padding(.leading, 14)
                                .accessibilityHidden(true)
                        }
                        TopicRow(topic: topic)
                    }
                }
                .cardSurface()
            }
        }
    }

    // MARK: Empty library

    private var emptyLibrary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "books.vertical")
                .font(.largeTitle)
                .foregroundStyle(Theme.ink3)
                .accessibilityHidden(true)
            Text("Kitaplığın henüz boş")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("İlk tekrar turunda tanıştığın kelimeler en alt rafa gelir. Her doğru cevapta bir üst rafa çıkarlar.")
                .font(.body)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
            if let onStartReview {
                Button("Tekrar'a git", action: onStartReview)
                    .buttonStyle(PrimaryCapsuleButtonStyle())
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    // MARK: Helpers

    private func shelf(of id: Int) -> ProgressSummary.Shelf? {
        return summary.shelves.first { $0.wordIDs.contains(id) }?.shelf
    }

    /// The loaded words of `ids`, alphabetically.
    private func listedWords(_ ids: [Int]) -> [WidgetWord] {
        return ids.compactMap { words[$0] }.sorted {
            $0.lemma.localizedCaseInsensitiveCompare($1.lemma) == .orderedAscending
        }
    }

    private func toggle(_ shelf: ProgressSummary.Shelf) {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            openShelf = openShelf == shelf ? nil : shelf
        }
    }
}

// MARK: - Shelf names

private extension ProgressSummary.Shelf {
    /// The shelf's own name ("Güçleniyor").
    var name: String {
        switch self {
        case .box1: return "Yeni"
        case .box2: return "Tanıdık"
        case .box3: return "Güçleniyor"
        case .box4: return "Sağlam"
        case .box5: return "Çok sağlam"
        case .settled: return "Yerleşti"
        case .selfMarked: return "Kendin işaretlediklerin"
        }
    }

    /// "Raf 3 · Güçleniyor", "Yerleşti".
    var title: String {
        if let box {
            return "Raf \(box) · \(name)"
        }
        return name
    }

    /// For VoiceOver: "Raf 3, Güçleniyor".
    var voiceTitle: String {
        if let box {
            return "Raf \(box), \(name)"
        }
        return name
    }

    /// How often its words come back, from `Leitner` ("4 günde bir").
    var rhythm: String {
        if let box {
            let days = Int(Leitner.intervalDays[min(max(box, 1), Leitner.intervalDays.count) - 1].rounded())
            return days == 1 ? "her gün" : "\(days) günde bir"
        }
        switch self {
        case .settled:
            let days = Int((Leitner.refresherDelay / 86_400).rounded())
            return (28...31).contains(days) ? "ayda bir kısa tazeleme" : "\(days) günde bir kısa tazeleme"
        default:
            return "bir kez sorulur"
        }
    }

    /// Ink strength of the book spines: pale on Raf 1, full ink on Yerleşti.
    var tone: Double {
        switch self {
        case .box1: return 0.22
        case .box2: return 0.34
        case .box3: return 0.48
        case .box4: return 0.62
        case .box5: return 0.78
        case .settled: return 1
        case .selfMarked: return 0.5
        }
    }

    /// Filled steps of the five-step meter: Yerleşti fills it, a self-marked word fills none.
    var meterSteps: Int {
        switch self {
        case .settled: return Leitner.maxBox
        case .selfMarked: return 0
        default: return box ?? 0
        }
    }
}

// MARK: - Pieces

/// A section title (a VoiceOver heading) with an optional line under it.
private struct SectionHeading: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(verbatim: subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// The week's sentence (`ProgressSummary.WeeklyNote`) under "Bu hafta · 26 Ekim – 1 Kasım".
private struct NoteCard: View {
    let note: ProgressSummary.WeeklyNote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: heading)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
            Text(verbatim: note.text)
                .font(.title3)
                .foregroundStyle(Theme.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(voiceHeading). \(note.text)"))
    }

    private var title: String {
        return note.kind == .lastWeek ? "Geçen hafta" : "Bu hafta"
    }

    private var end: Date {
        return Calendar.current.date(byAdding: .day, value: 6, to: note.weekStart) ?? note.weekStart
    }

    /// "Bu hafta · 19–25 Ekim", "Bu hafta · 26 Ekim – 1 Kasım".
    private var heading: String {
        let calendar = Calendar.current
        let start = note.weekStart
        if calendar.component(.month, from: start) == calendar.component(.month, from: end) {
            return "\(title) · \(NoteCard.dayFormatter.string(from: start))–\(NoteCard.dayMonthFormatter.string(from: end))"
        }
        return "\(title) · \(NoteCard.dayMonthFormatter.string(from: start)) – \(NoteCard.dayMonthFormatter.string(from: end))"
    }

    /// The dash read out: "Bu hafta, 26 Ekim ile 1 Kasım arası".
    private var voiceHeading: String {
        let start = NoteCard.dayMonthFormatter.string(from: note.weekStart)
        return "\(title), \(start) ile \(NoteCard.dayMonthFormatter.string(from: end)) arası"
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d"
        return formatter
    }()

    private static let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
}

/// One count (mockup `.tile`): a large number over a short caption.
private struct CountTile: View {
    let value: Int
    let caption: String
    let voiceLabel: String
    @ScaledMetric(relativeTo: .title) private var numberSize: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: "\(value)")
                // Grows with the text size, but not past 40 pt: two tiles share one row.
                .font(.system(size: min(numberSize, 40), weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(verbatim: caption)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: voiceLabel))
    }
}

/// A word met this week (mockup "Tanıştığın 12 kelime"): headword, meaning and the five-step
/// shelf meter; a tap turns it over to the example sentence. No yellow band here: several cards
/// are on screen at once, the band stays on the one word of the sheet.
private struct MetWordCard: View {
    let word: WidgetWord
    let shelf: ProgressSummary.Shelf?
    @State private var showsExample = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .title2) private var lemmaSize: CGFloat = 24

    var body: some View {
        Button {
            withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .easeInOut(duration: 0.35)) {
                showsExample.toggle()
            }
        } label: {
            // Both faces are laid out, so the card keeps its height when it turns.
            ZStack(alignment: .topLeading) {
                front
                    .opacity(showsExample ? 0 : 1)
                    .accessibilityHidden(showsExample)
                back
                    .opacity(showsExample ? 1 : 0)
                    .rotation3DEffect(.degrees(reduceMotion ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                    .accessibilityHidden(!showsExample)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .cardSurface()
            .rotation3DEffect(.degrees(showsExample && !reduceMotion ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text(verbatim: showsExample ? "Kelimeye döner." : "Örnek cümleyi gösterir."))
    }

    private var front: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: word.lemma)
                .font(Theme.Fonts.englishWord(size: lemmaSize))
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .fixedSize(horizontal: false, vertical: true)
                .englishVoice()
            if let gloss = word.glossTR, !gloss.isEmpty {
                Text(verbatim: gloss)
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            if let shelf {
                VStack(alignment: .leading, spacing: 6) {
                    ShelfMeter(shelf: shelf)
                    Text(verbatim: shelf.title)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(Text(verbatim: shelf.voiceTitle))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var back: some View {
        VStack(alignment: .leading, spacing: 8) {
            if word.exampleEN.isEmpty {
                Text(verbatim: word.defShort)
                    .definitionStyle()
                    .fixedSize(horizontal: false, vertical: true)
                    .englishVoice()
            } else {
                Text(ExampleMark.attributed(word.exampleEN, lemma: word.lemma, colorScheme: colorScheme, highlighted: false))
                    .exampleStyle()
                    .fixedSize(horizontal: false, vertical: true)
                    .englishVoice()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Five short bars, filled up to the word's shelf (decorative: the shelf is also written).
private struct ShelfMeter: View {
    let shelf: ProgressSummary.Shelf
    @ScaledMetric(relativeTo: .footnote) private var height: CGFloat = 6
    @ScaledMetric(relativeTo: .footnote) private var width: CGFloat = 16

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...Leitner.maxBox, id: \.self) { step in
                Capsule()
                    .fill(step <= shelf.meterSteps ? Theme.tint : Theme.surface3)
                    .frame(width: width, height: height)
            }
        }
        .accessibilityHidden(true)
    }
}

/// One shelf of the library: name, rhythm and count; the book spines; a tap lists the words.
private struct ShelfRow: View {
    let shelf: ProgressSummary.Shelf
    /// The shelf's loaded words, alphabetically.
    let words: [WidgetWord]
    let count: Int
    let isOpen: Bool
    let toggle: () -> Void
    let open: (WidgetWord) -> Void
    @State private var showsAllWords = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Words listed before "+N kelime daha".
    private static let firstWords = 40
    /// Spines drawn before "+N" (fits an iPhone SE row).
    private static let maxSpines = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: toggle) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: shelf.title)
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(verbatim: shelf.rhythm)
                            .font(.footnote)
                            .foregroundStyle(Theme.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    if count > 0 {
                        Text(verbatim: "\(count)")
                            .font(.title3.weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(Theme.ink)
                        Image(systemName: "chevron.down")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.ink3)
                            .rotationEffect(.degrees(isOpen ? 180 : 0))
                    } else {
                        Text("boş")
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink3)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: Theme.minHitSize, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(count == 0)
            .accessibilityLabel(Text(verbatim: voiceLabel))
            .accessibilityHint(Text(verbatim: count == 0 ? "" : (isOpen ? "Kelimeleri gizler." : "Kelimeleri gösterir.")))

            if count > 0 && !dynamicTypeSize.isAccessibilitySize {
                BookSpines(
                    ids: words.prefix(ShelfRow.maxSpines).map { $0.id },
                    extra: max(0, count - ShelfRow.maxSpines),
                    tone: shelf.tone,
                    dashed: shelf == .selfMarked
                )
            }

            if isOpen && count > 0 {
                wordChips
                    .transition(.opacity)
            }
        }
        .padding(14)
    }

    private var voiceLabel: String {
        if count == 0 {
            return "\(shelf.voiceTitle): boş."
        }
        return "\(shelf.voiceTitle): \(count) kelime. \(shelf.rhythm.prefix(1).uppercased() + shelf.rhythm.dropFirst()) sorulur."
    }

    private var wordChips: some View {
        let shown = showsAllWords ? words : Array(words.prefix(ShelfRow.firstWords))
        let hidden = words.count - shown.count
        return ChipFlow(spacing: 8) {
            ForEach(shown) { word in
                Button {
                    open(word)
                } label: {
                    Text(verbatim: word.lemma)
                        .englishVoice()
                }
                .buttonStyle(ChipButtonStyle())
                .accessibilityHint(Text(verbatim: "Anlamını ve örneğini gösterir."))
            }
            if hidden > 0 {
                Button {
                    showsAllWords = true
                } label: {
                    Text(verbatim: "+\(hidden) kelime daha")
                }
                .buttonStyle(ChipButtonStyle())
            }
        }
    }
}

/// The shelf drawn as book spines on a board (decorative, hidden from VoiceOver). Heights vary
/// by word, always the same for the same word.
private struct BookSpines: View {
    let ids: [Int]
    let extra: Int
    let tone: Double
    let dashed: Bool
    @ScaledMetric(relativeTo: .body) private var height: CGFloat = 26

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(ids, id: \.self) { id in
                    spine(id)
                }
                if extra > 0 {
                    Text(verbatim: "+\(extra)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.ink2)
                        .padding(.leading, 4)
                }
            }
            Rectangle()
                .fill(Theme.lineStrong)
                .frame(maxWidth: .infinity)
                .frame(height: 2)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func spine(_ id: Int) -> some View {
        let variation = CGFloat(abs(id &* 37) % 10) / 10
        let shape = RoundedRectangle(cornerRadius: 1.5, style: .continuous)
        Group {
            if dashed {
                shape.strokeBorder(Theme.ink.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
            } else {
                shape.fill(Theme.ink.opacity(tone))
            }
        }
        .frame(width: 6, height: height * (0.65 + 0.35 * variation))
    }
}

/// "Raflar nasıl çalışır?": what each answer does, the waits and why the top shelf is not called
/// "kalıcı". Every number comes from `Leitner`.
private struct HowShelvesWork: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("**Bildim:** bir üst raf.")
                Text("**Kolay:** iki üst raf.")
                Text("**Zor:** aynı raf, ara yarıya iner.")
                Text("**Bilemedim:** kelime aşağı bir rafa iner ve kısa süre sonra yine gelir.")
            }
            .font(.subheadline)
            .foregroundStyle(Theme.ink)
            Text(verbatim: "Aralar her rafta iki katına çıkar: \(waits) gün. \(Leitner.maxBox). raftan sonra, \(lastWait) gün aradan sonra da hatırladığın kelime Yerleşti rafına geçer.")
                .font(.subheadline)
                .foregroundStyle(Theme.ink)
            VStack(alignment: .leading, spacing: 4) {
                Text("Neden “kalıcı” demiyoruz?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("Unutma hiç tamamen durmaz. Bu yüzden yerleşen kelimeler de ayda bir kısa bir tazelemeyle sorulur.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
            }
            Text("Unuttuğun kelime aşağı rafa iner. Bu bir ceza değil: bir kelimeyi ikinci kez öğrenmek ilkinden kısa sürer.")
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    /// "1, 2, 4, 8, 16".
    private var waits: String {
        return Leitner.intervalDays.map { String(Int($0.rounded())) }.joined(separator: ", ")
    }

    private var lastWait: Int {
        return Int((Leitner.intervalDays.last ?? 16).rounded())
    }
}

/// One topic: its name, word count, a three-part bar (known, learning, not met) and the numbers
/// in words. No percentage and no order by score.
private struct TopicRow: View {
    let topic: ProgressSummary.GroupProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: topic.title)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Text(verbatim: "\(topic.total) kelime")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(Theme.ink2)
            }
            ThreePartBar(known: topic.known, learning: topic.learning, total: topic.total)
            Text(verbatim: caption)
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(topic.title): \(topic.total) kelime. \(caption)"))
    }

    /// "7 bildiğin · 11 öğreniliyor · 40 yeni"; parts with nothing are left out.
    private var caption: String {
        if topic.everyWordMet {
            return "Bu konunun bütün kelimeleriyle tanıştın. Tekrarlar sürüyor; yeni kelimeler diğer konulardan gelir."
        }
        var parts: [String] = []
        if topic.known > 0 {
            parts.append("\(topic.known) bildiğin")
        }
        if topic.learning > 0 {
            parts.append("\(topic.learning) öğreniliyor")
        }
        if topic.notStarted > 0 {
            parts.append("\(topic.notStarted) yeni")
        }
        return parts.joined(separator: " · ")
    }
}

/// Known (ink), learning (light ink) and not met (track) on one capsule; decorative.
private struct ThreePartBar: View {
    let known: Int
    let learning: Int
    let total: Int

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Theme.tint)
                    .frame(width: width(known, of: proxy.size.width))
                Rectangle()
                    .fill(Theme.tint.opacity(0.35))
                    .frame(width: width(learning, of: proxy.size.width))
                Spacer(minLength: 0)
            }
            .background(Theme.surface3)
            .clipShape(Capsule())
        }
        .frame(height: 8)
        .accessibilityHidden(true)
    }

    /// At least a sliver for a part that has words, so a small start still shows.
    private func width(_ part: Int, of full: CGFloat) -> CGFloat {
        guard total > 0, part > 0 else {
            return 0
        }
        return max(6, full * min(1, CGFloat(part) / CGFloat(total)))
    }
}

/// Lays chips out in rows, left to right, wrapping when a row is full. A chip wider than the row
/// gets the row's width.
private struct ChipFlow: Layout {
    var spacing: CGFloat = 8

    private struct Row {
        var items: [(index: Int, x: CGFloat, size: CGSize)] = []
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews, width: proposal.width ?? .infinity)
        let height = rows.last.map { $0.y + $0.height } ?? 0
        let width = rows.map { $0.width }.max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for row in arrange(subviews, width: bounds.width) {
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + row.y),
                    proposal: ProposedViewSize(item.size)
                )
            }
        }
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            var size = subviews[index].sizeThatFits(.unspecified)
            if size.width > width {
                size = subviews[index].sizeThatFits(ProposedViewSize(width: width, height: nil))
            }
            if !current.items.isEmpty && current.width + spacing + size.width > width {
                rows.append(current)
                current = Row(y: current.y + current.height + spacing)
            }
            let x = current.items.isEmpty ? 0 : current.width + spacing
            current.items.append((index, x, size))
            current.width = x + size.width
            current.height = max(current.height, size.height)
        }
        if !current.items.isEmpty {
            rows.append(current)
        }
        return rows
    }
}

/// A word from the shelves: headword with the band, meaning, level, shelf and example.
private struct ShelfWordSheet: View {
    let word: WidgetWord
    let shelf: ProgressSummary.Shelf?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(verbatim: word.lemma)
                        .englishWordStyle()
                        .phosphorBand()
                        .englishVoice()
                        .padding(.bottom, 8)
                    if let gloss = word.glossTR, !gloss.isEmpty {
                        Text(verbatim: gloss)
                            .meaningStyle()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    LevelBadge(code: word.level)
                    if let shelf {
                        VStack(alignment: .leading, spacing: 6) {
                            ShelfMeter(shelf: shelf)
                            Text(verbatim: "\(shelf.title) · \(shelf.rhythm)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(verbatim: "\(shelf.voiceTitle). \(shelf.rhythm)."))
                    }
                    if !word.exampleEN.isEmpty {
                        Text(ExampleMark.attributed(word.exampleEN, lemma: word.lemma, colorScheme: colorScheme))
                            .exampleStyle()
                            .fixedSize(horizontal: false, vertical: true)
                            .englishVoice()
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background {
                Theme.bg
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
        .tint(Theme.ink)
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Previews

/// Sample data for the previews: real-looking words, answered with the real `Leitner` rules.
private enum ProgressOverviewPreview {
    static let wordList: [WidgetWord] = [
        ("breakfast", "kahvaltı", "I have breakfast at seven."),
        ("bread", "ekmek", "We need some bread."),
        ("weekend", "hafta sonu", "See you at the weekend."),
        ("borrow", "ödünç almak", "Can I borrow your pen?"),
        ("lend", "ödünç vermek", "Can you lend me some money?"),
        ("actually", "aslında", "Actually, I don't like tea."),
        ("fresh", "taze", "The fish is fresh."),
        ("snack", "atıştırmalık", "I eat a snack after school."),
        ("spoon", "kaşık", "I eat soup with a spoon."),
        ("appointment", "randevu", "I have a doctor's appointment."),
        ("quiet", "sessiz", "The library is quiet."),
        ("early", "erken", "I get up early."),
    ].enumerated().map { index, entry in
        WidgetWord(
            id: index + 1,
            lemma: entry.0,
            pos: "n",
            level: index % 3 == 0 ? "A1" : "A2",
            defMicro: entry.1,
            defShort: entry.1,
            exampleEN: entry.2,
            glossTR: entry.1
        )
    }

    static var words: [Int: WidgetWord] {
        return Dictionary(uniqueKeysWithValues: wordList.map { ($0.id, $0) })
    }

    static func summary(now: Date = Date()) -> ProgressSummary {
        let day: TimeInterval = 86_400
        var progress: [Int: WordProgress] = [:]
        func answer(_ id: Int, _ answers: [(ReviewGrade, TimeInterval)]) {
            progress[id] = answers.reduce(WordProgress(wordID: id)) { p, item in
                Leitner.review(p, grade: item.0, at: now.addingTimeInterval(-item.1 * day))
            }
        }
        // Climbing for weeks.
        answer(1, [(.good, 40), (.good, 39), (.good, 37), (.good, 33), (.good, 25), (.good, 9)])
        answer(2, [(.good, 30), (.good, 29), (.good, 27), (.good, 23), (.good, 15)])
        answer(3, [(.good, 20), (.good, 19), (.good, 17), (.good, 13)])
        answer(4, [(.good, 9), (.good, 8), (.good, 6)])
        // Met this week.
        answer(5, [(.good, 1)])
        answer(6, [(.good, 2), (.good, 1)])
        answer(7, [(.easy, 1)])
        answer(8, [(.hard, 0.2)])
        // Seen on the widget only.
        progress[9] = Leitner.markExposure(WordProgress(wordID: 9), at: now)
        progress[10] = Leitner.markKnown(WordProgress(wordID: 10), at: now.addingTimeInterval(-3 * day))
        let topics = [
            ProgressSummary.WordGroup(id: "food", title: "Yiyecek & İçecek", wordIDs: [1, 2, 7, 8, 9]),
            ProgressSummary.WordGroup(id: "daily", title: "Günlük Hayat", wordIDs: [3, 4, 5, 6, 10, 11, 12]),
        ]
        return ProgressSummary.make(progress: progress, now: now, topics: topics)
    }
}

#Preview("Bu hafta") {
    NavigationStack {
        ProgressOverviewView(summary: ProgressOverviewPreview.summary(), words: ProgressOverviewPreview.words)
    }
}

#Preview("Gece, büyük yazı") {
    NavigationStack {
        ProgressOverviewView(summary: ProgressOverviewPreview.summary(), words: ProgressOverviewPreview.words)
    }
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility3)
}

#Preview("Boş kitaplık") {
    NavigationStack {
        ProgressOverviewView(
            summary: ProgressSummary.make(progress: [:], now: Date()),
            words: [:],
            onStartReview: {}
        )
    }
}
