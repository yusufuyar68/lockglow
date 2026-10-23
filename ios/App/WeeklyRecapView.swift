import SwiftUI
import UIKit
import CoreModels
import Learning

/// is5-haftalik: Monday's "Geçen hafta" (docs/tasarim/ogrenme_ilkeleri.md 2.5; the recap itself is
/// `WeeklyRecap`, Learning). A calm sheet, once, at an opening on Monday: the week's dates and
/// study days, the words met, the words that moved up a step, the (at most three) hardest words
/// and this week's suggestion. "Tamam" closes it; "Paylaş" shares a picture of the week's words
/// (WeeklyRecapShareCard.swift). No streak, no comparison, no percentage, no praise, no zero.
///
/// How it comes (RootView, one line, after `.environmentObject(systemCards)`):
///
///     .weeklyRecapAtOpening(systemCards, blocked: model.showsOnboarding || ...)
///
/// It waits until RootView has decided the opening's sheet, then claims `.weeklyRecap` like the
/// screens' own cards (`SystemCardQueue.claim`): only in an opening that no other system card
/// has, so never with another one (2.10). Not over the onboarding, a card opened from the widget
/// or an opening from a reminder (`blocked`), not over any other sheet, and not when the app
/// comes back after less than 30 minutes (a "Tekrar" round may be under way): a later opening on
/// Monday may show it. Known gap: a widget tap on a word of the deck only scrolls "Akış", and
/// the recap can open over that word (closing it shows the word).
extension View {
    func weeklyRecapAtOpening(_ systemCards: SystemCardQueue, blocked: Bool) -> some View {
        modifier(WeeklyRecapPresenter(systemCards: systemCards, isBlocked: blocked))
    }
}

/// The recap on screen as a sheet item, with the words it lists.
private struct ShownWeeklyRecap: Identifiable {
    let recap: WeeklyRecap
    let words: [Int: WidgetWord]

    var id: Date {
        return recap.weekStart
    }
}

private struct WeeklyRecapPresenter: ViewModifier {
    @ObservedObject var systemCards: SystemCardQueue
    let isBlocked: Bool

    /// Back after a shorter time away, the app is still in the middle of what it was doing (a
    /// "Tekrar" round, say): such an opening gets no recap.
    private static let freshOpeningAfter: TimeInterval = 30 * 60

    @EnvironmentObject private var model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var shown: ShownWeeklyRecap?
    /// `isBlocked` as of now, also for the check that ends after the review log was read.
    @State private var blockedNow = false
    @State private var isPreparing = false
    /// A week whose recap had no word to show: the log is not read again for it in this run.
    @State private var emptyWeek: Date?
    /// When the app last went to the background in this run; nil since the launch.
    @State private var leftAt: Date?

    func body(content: Content) -> some View {
        content
            .onChange(of: isBlocked, initial: true) { _, blocked in
                blockedNow = blocked
            }
            .onAppear {
                consider()
            }
            .onChange(of: systemCards.isDecided) { _, isDecided in
                if isDecided {
                    consider()
                }
            }
            .onChange(of: scenePhase) { _, phase in
                // The next opening decides its own card and may show a sheet: two sheets at once
                // do not work, so the recap closes when the app leaves. It was seen; it does not
                // come back.
                if phase == .background {
                    shown = nil
                    leftAt = Date()
                }
            }
            .sheet(item: $shown) { item in
                NavigationStack {
                    WeeklyRecapView(recap: item.recap, words: item.words) {
                        shown = nil
                    }
                }
                .tint(Theme.ink)
                .environmentObject(model)
                .onAppear {
                    model.markWeeklyRecapShown(item.recap)
                }
            }
    }

    /// The opening is decided: the recap comes when it is due, has a word to show and the
    /// opening is still free. Not when the app comes back after a short time away, nor while any
    /// sheet is up (a screen's own, as in "Ayarlar"): the recap could not open over it, yet its
    /// claim would take the opening. The claim comes last, right before the sheet.
    private func consider() {
        guard systemCards.isDecided, !blockedNow, shown == nil, !isPreparing, isFreshOpening,
              !WeeklyRecapPresenter.isSheetUp(),
              let summary = model.weeklyRecapSummary(), summary.lastWeek.start != emptyWeek else {
            return
        }
        isPreparing = true
        Task { @MainActor in
            let recap = await model.weeklyRecap(for: summary)
            isPreparing = false
            guard let recap = recap else {
                emptyWeek = summary.lastWeek.start
                return
            }
            // Again after the await: the app may have left, a sheet may be up, or another card
            // came first.
            guard systemCards.isDecided, !blockedNow, shown == nil, !WeeklyRecapPresenter.isSheetUp(),
                  systemCards.claim(.weeklyRecap) else {
                return
            }
            shown = ShownWeeklyRecap(recap: recap, words: model.wordsByID)
        }
    }

    /// The launch, or back after at least `freshOpeningAfter` away.
    private var isFreshOpening: Bool {
        guard let leftAt = leftAt else {
            return true
        }
        return Date().timeIntervalSince(leftAt) >= WeeklyRecapPresenter.freshOpeningAfter
    }

    /// Any sheet or full-screen cover of the app is on screen: every SwiftUI presentation is a
    /// view controller presented over its window's root.
    @MainActor
    private static func isSheetUp() -> Bool {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else {
                continue
            }
            if windowScene.windows.contains(where: { $0.rootViewController?.presentedViewController != nil }) {
                return true
            }
        }
        return false
    }
}

// MARK: - Screen

/// The "Geçen hafta" page. Plain values, so it previews on its own; inside a `NavigationStack`
/// (a word opens its card, `WordDetailView`, which reads `AppModel` from the environment).
struct WeeklyRecapView: View {
    let recap: WeeklyRecap
    /// The loaded words by id (`AppModel.wordsByID`); an id without a word is not listed.
    let words: [Int: WidgetWord]
    let close: () -> Void

    /// The share card, drawn once the page is on screen; nil while there is nothing to share.
    @State private var shareImage: Image?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                WeekCard(recap: recap)
                let met = listed(recap.metWordIDs)
                if !met.isEmpty {
                    WordChipSection(title: "Tanıştığın \(met.count) kelime", subtitle: nil, words: met)
                }
                let movedUp = listed(recap.movedUpWordIDs)
                if !movedUp.isEmpty {
                    WordChipSection(
                        title: "Bir basamak çıkan \(movedUp.count) kelime",
                        subtitle: "Bu kelimeler artık daha seyrek sorulur.",
                        words: movedUp
                    )
                }
                let hard = listed(recap.hardWordIDs)
                if !hard.isEmpty {
                    HardWordsSection(words: hard)
                }
                SuggestionCard(suggestion: recap.suggestion)
                buttons
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .navigationTitle("Geçen hafta")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Kapat", action: close)
            }
        }
        .navigationDestination(for: WidgetWord.self) { word in
            WordDetailView(word: word)
        }
        .task {
            if shareImage == nil, let image = WeeklyRecapShareCard.render(words: recap.shareWords(from: words)) {
                shareImage = Image(uiImage: image)
            }
        }
    }

    private func listed(_ ids: [Int]) -> [WidgetWord] {
        return ids.compactMap { words[$0] }
    }

    /// One filled button ("Tamam"); "Paylaş" under it once the card is drawn, with what the card
    /// holds.
    private var buttons: some View {
        VStack(spacing: 10) {
            Button("Tamam", action: close)
                .buttonStyle(PrimaryCapsuleButtonStyle())
            if let shareImage {
                ShareLink(
                    item: shareImage,
                    preview: SharePreview("Geçen haftanın kelimeleri", image: shareImage)
                ) {
                    Label("Paylaş", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                .accessibilityHint(Text(verbatim: "Kelimelerle bir resim hazırlar."))
                Text(verbatim: "Resimde yalnız kelimeler ve anlamları var.")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Pieces

/// "19–25 Ekim" over "Geçen hafta 4 gün çalıştın.".
private struct WeekCard: View {
    let recap: WeeklyRecap

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: WeeklyRecapDates.range(from: recap.weekStart))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
            Text(verbatim: recap.sentence)
                .font(.title3)
                .foregroundStyle(Theme.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(WeeklyRecapDates.spokenRange(from: recap.weekStart)). \(recap.sentence)"))
    }
}

/// A section title (a VoiceOver heading) with an optional line under it.
private struct RecapHeading: View {
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

/// Headwords as chips; a chip opens the word's card.
private struct WordChipSection: View {
    let title: String
    let subtitle: String?
    let words: [WidgetWord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RecapHeading(title: title, subtitle: subtitle)
            RecapChipFlow(spacing: 8) {
                ForEach(words) { word in
                    NavigationLink(value: word) {
                        Text(verbatim: word.lemma)
                            .font(.system(.subheadline, design: .serif).weight(.semibold))
                    }
                    .buttonStyle(ChipButtonStyle())
                    // The word in an English voice through the label's language, so the Turkish
                    // hint keeps the Turkish voice (an English locale would switch the whole button).
                    .accessibilityLabel(SozlukSpeech.label([.english(word.lemma)]))
                    .accessibilityHint(Text(verbatim: "Kartını açar."))
                }
            }
        }
    }
}

/// "En çok zorlandığın kelimeler": a row each, with the meaning; a row opens the card, where the
/// example can be heard and said (the suggestion reads it aloud).
private struct HardWordsSection: View {
    let words: [WidgetWord]
    @ScaledMetric(relativeTo: .title2) private var lemmaSize: CGFloat = 22

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RecapHeading(
                title: words.count == 1 ? "En çok zorlandığın kelime" : "En çok zorlandığın kelimeler",
                subtitle: words.count == 1 ? "Tekrar'da yine karşına çıkacak." : "Tekrar'da yine karşına çıkacaklar."
            )
            VStack(spacing: 0) {
                ForEach(Array(words.enumerated()), id: \.element.id) { index, word in
                    if index > 0 {
                        Rectangle()
                            .fill(Theme.line)
                            .frame(height: 1)
                            .padding(.leading, 16)
                    }
                    NavigationLink(value: word) {
                        row(word)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(SozlukSpeech.label(runs(word)))
                    .accessibilityHint(Text(verbatim: "Kartını açar."))
                }
            }
            .cardSurface(cornerRadius: Theme.Radius.group)
        }
    }

    private func row(_ word: WidgetWord) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: word.lemma)
                    .font(Theme.Fonts.englishWord(size: min(lemmaSize, 34)))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                if let gloss = word.glossTR, !gloss.isEmpty {
                    Text(verbatim: gloss)
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink3)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: Theme.minHitSize, alignment: .leading)
        .contentShape(Rectangle())
    }

    /// "borrow" in English, then "Türkçesi: ödünç almak" in Turkish.
    private func runs(_ word: WidgetWord) -> [SozlukSpeech.Run] {
        var runs: [SozlukSpeech.Run] = [.english(word.lemma)]
        if let gloss = word.glossTR, !gloss.isEmpty {
            runs.append(.turkish(", Türkçesi: " + gloss))
        }
        return runs
    }
}

/// "Bu haftanın önerisi" and its one or two sentences.
private struct SuggestionCard: View {
    let suggestion: WeeklyRecap.Suggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(verbatim: "Bu haftanın önerisi")
            } icon: {
                Image(systemName: "lightbulb")
                    .accessibilityHidden(true)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.ink2)
            .accessibilityAddTraits(.isHeader)
            Text(verbatim: suggestion.text)
                .font(.body)
                .foregroundStyle(Theme.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
    }
}

/// The week's dates: "19–25 Ekim", "26 Ekim – 1 Kasım" (as "İlerleme" writes them).
enum WeeklyRecapDates {
    static func range(from start: Date, calendar: Calendar = .current) -> String {
        let end = sunday(after: start, calendar: calendar)
        if calendar.component(.month, from: start) == calendar.component(.month, from: end) {
            return "\(dayFormatter.string(from: start))–\(dayMonthFormatter.string(from: end))"
        }
        return "\(dayMonthFormatter.string(from: start)) – \(dayMonthFormatter.string(from: end))"
    }

    /// The dash read out: "19 Ekim ile 25 Ekim arası".
    static func spokenRange(from start: Date, calendar: Calendar = .current) -> String {
        let end = sunday(after: start, calendar: calendar)
        return "\(dayMonthFormatter.string(from: start)) ile \(dayMonthFormatter.string(from: end)) arası"
    }

    private static func sunday(after start: Date, calendar: Calendar) -> Date {
        return calendar.date(byAdding: .day, value: 6, to: start) ?? start
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

/// Lays chips out in rows, left to right, wrapping when a row is full ("İlerleme" has the same
/// private layout). A chip wider than the row gets the row's width.
private struct RecapChipFlow: Layout {
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

// MARK: - Previews

/// Sample data for the previews.
enum WeeklyRecapPreview {
    static let wordList: [WidgetWord] = [
        ("breakfast", "kahvaltı", "I have breakfast at seven."),
        ("borrow", "ödünç almak", "Can I borrow your pen?"),
        ("lend", "ödünç vermek", "Can you lend me some money?"),
        ("actually", "aslında", "Actually, I don't like tea."),
        ("appointment", "randevu", "I have a doctor's appointment."),
        ("fresh", "taze", "The fish is fresh."),
        ("quiet", "sessiz", "The library is quiet."),
        ("early", "erken", "I get up early."),
        ("look forward to", "dört gözle beklemek", "I look forward to the weekend."),
    ].enumerated().map { index, entry in
        WidgetWord(
            id: index + 1,
            lemma: entry.0,
            pos: "n",
            level: "A2",
            defMicro: entry.1,
            defShort: entry.1,
            exampleEN: entry.2,
            glossTR: entry.1
        )
    }

    static var words: [Int: WidgetWord] {
        return Dictionary(uniqueKeysWithValues: wordList.map { ($0.id, $0) })
    }

    static var recap: WeeklyRecap {
        let start = ProgressSummary.weekStart(containing: Date().addingTimeInterval(-7 * 86_400), calendar: .current)
        return WeeklyRecap(
            weekStart: start,
            weekEnd: start.addingTimeInterval(7 * 86_400),
            studyDays: 4,
            metWordIDs: [1, 2, 3, 9, 5],
            movedUpWordIDs: [6, 7, 8],
            hardWordIDs: [2, 3, 4],
            suggestion: .readAloud(wordCount: 3)
        )
    }
}

#Preview("Geçen hafta") {
    NavigationStack {
        WeeklyRecapView(recap: WeeklyRecapPreview.recap, words: WeeklyRecapPreview.words, close: {})
    }
}

#Preview("Gece, büyük yazı") {
    NavigationStack {
        WeeklyRecapView(recap: WeeklyRecapPreview.recap, words: WeeklyRecapPreview.words, close: {})
    }
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility3)
}
