import SwiftUI
import Learning

/// "Nasıl öğrenirim?": a short, calm guide to learning with Lockglow in plain A2 Turkish. A
/// "Kısaca" box, then seven cards of two or three sentences each: how the app works, spaced
/// repetition and the four answers, trying to remember first (with a real word to try), how many
/// words a day, the widget, "Söyle", tips for Turkish speakers (false friends, the Dikkat box).
///
/// How to call it
///
///     // Ayarlar > Yardım: push it onto the settings NavigationStack.
///     NavigationLink {
///         LearningGuideView(dailyNewWords: model.dailyNewWords, rotationMinutes: model.rotationMinutes)
///     } label: {
///         SettingsRow("Nasıl öğrenirim?")
///     }
///     .buttonStyle(SettingsRowButtonStyle())
///
///     // As a sheet (onboarding, a "?" button): give it a NavigationStack and a "Kapat", like the
///     // WordDetailView sheets in RootView.
///     .sheet(isPresented: $showsGuide) {
///         NavigationStack {
///             LearningGuideView(dailyNewWords: model.dailyNewWords, rotationMinutes: model.rotationMinutes)
///                 .toolbar {
///                     ToolbarItem(placement: .cancellationAction) {
///                         Button("Kapat") { showsGuide = false }
///                     }
///                 }
///         }
///         .tint(Theme.ink)
///     }
///
///     // Inside a page that already scrolls (an onboarding page): the cards only, no scroll view,
///     // background or title.
///     LearningGuideContent(dailyNewWords: model.dailyNewWords, rotationMinutes: model.rotationMinutes)
///
/// Parameters (plain values: the file needs no `AppModel` or environment object and previews on
/// its own):
/// - `dailyNewWords`: the daily new-word goal (`AppModel.dailyNewWords`; Ayarlar offers 5, 10,
///   15, 20). "Günde kaç kelime yeter?" multiplies it by 30 days.
/// - `rotationMinutes`: how often the widget word changes (`AppModel.rotationMinutes`; 5 to 120),
///   quoted in "Widget'ı iyi kullan".
///
/// Every wait in the text ("10 dakika sonra", "1 gün, 2 gün, 4 gün…", "30 günde bir") comes from
/// `Leitner`, so the guide follows the real schedule when the intervals change. Design system
/// only (`Theme`, `SecondaryCapsuleButtonStyle`, `ExampleMark`, `MistakeDiff`); the page has one
/// phosphor band (the word to try) and one marked example sentence (rule 1).
struct LearningGuideView: View {
    let dailyNewWords: Int
    let rotationMinutes: Int

    var body: some View {
        ScrollView {
            LearningGuideContent(dailyNewWords: dailyNewWords, rotationMinutes: rotationMinutes)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Nasıl öğrenirim?")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// The guide's cards without a scroll view, background or title (see `LearningGuideView`).
struct LearningGuideContent: View {
    let dailyNewWords: Int
    let rotationMinutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GuideSummary()
            howItWorks
            spacedRepetition
            recallFirst
            dailyAmount
            widgetTips
            pronunciation
            turkishTips
        }
    }

    // MARK: 1. How Lockglow works

    private var howItWorks: some View {
        GuideSection(title: "Lockglow nasıl çalışır?", systemImage: "map") {
            GuideParagraph("Kelimeyi önce kilitli ekranda görürsün. Sonra Tekrar'da anlamını hatırlamaya çalışırsın. Görmek tek başına yetmez; kelime, hatırladıkça yerleşir.")
            GuideLoop()
        }
    }

    // MARK: 2. Spaced repetition

    private var spacedRepetition: some View {
        GuideSection(title: "Aralıklı tekrar", systemImage: "clock.arrow.circlepath") {
            GuideParagraph("Bilemediğin bir kelime \(GuideText.newWordWait(.again)) sonra yine gelir. Bildiğin bir kelime ise en az \(GuideText.newWordWait(.good)) sonra gelir. Neden? Unutmaya başladığın bir kelimeyi hatırlamak, onu daha kalıcı yapar.")
            GuideParagraph("Her doğru cevapta kelime bir basamak çıkar ve ara uzar:")
            GuideIntervalLadder(waits: GuideText.boxWaits)
            GuideNote("Son basamakta da bilirsen kelime öğrenilmiş sayılır. Sonra yalnızca \(GuideText.refresherInterval) sorulur.", systemImage: "checkmark.seal")
            GuideSubheading("Tekrar'daki dört düğme ne demek?")
            // Symbols and names of the answer buttons (ReviewView), worst to best.
            VStack(alignment: .leading, spacing: 12) {
                GuideIconRow(
                    systemImage: "xmark",
                    title: "Bilemedim",
                    detail: "Sorun değil. Kelime ilk basamağa döner.",
                    trailing: GuideText.newWordWait(.again) + " sonra"
                )
                GuideIconRow(
                    systemImage: "tortoise",
                    title: "Zor",
                    detail: "Hatırladın ama zorlandın. Kelime aynı basamakta kalır.",
                    trailing: GuideText.newWordWait(.hard) + " sonra"
                )
                GuideIconRow(
                    systemImage: "checkmark",
                    title: "Bildim",
                    detail: "Kelime bir basamak çıkar.",
                    trailing: GuideText.newWordWait(.good) + " sonra"
                )
                GuideIconRow(
                    systemImage: "hare",
                    title: "Kolay",
                    detail: "Hiç düşünmeden bildin. Kelime iki basamak çıkar.",
                    trailing: GuideText.newWordWait(.easy) + " sonra"
                )
            }
            GuideNote("Bu süreler yeni bir kelime için. Basamak yükseldikçe süreler uzar.")
        }
    }

    // MARK: 3. Trying to remember teaches

    private var recallFirst: some View {
        GuideSection(title: "Önce hatırlamaya çalış", systemImage: "brain.head.profile") {
            GuideParagraph("Cevaba hemen bakma. Önce birkaç saniye düşün: “Bu ne demekti?”")
            GuideParagraph("Hatırlamaya çalışmak, cevabı okumaktan daha iyi öğretir. Bilemesen bile bu çaba işe yarar. Buna “sınama etkisi” (testing effect) denir.")
            GuideRecallDemo()
            GuideNote("Tekrar'da da böyle yap: önce düşün, sonra karta dokun.", systemImage: "hand.tap")
        }
    }

    // MARK: 4. How many words a day

    private var dailyAmount: some View {
        GuideSection(title: "Günde kaç kelime yeter?", systemImage: "calendar") {
            GuideParagraph("Günde 5–10 yeni kelime çoğu kişi için yeter. Asıl önemli olan düzen: her gün kısa çalışmak, bir günde uzun çalışmaktan daha kalıcıdır.")
            GuideMonthMath(dailyNewWords: dailyNewWords)
            if dailyNewWords > 10 {
                GuideNote("Hedefin yüksek. Her yeni kelime sonraki günlerde tekrar olarak geri gelir. Yorulursan Ayarlar'dan azaltabilirsin.")
            } else {
                GuideNote("Bir gün atlarsan dert etme. Ertesi gün kaldığın yerden devam et.")
            }
        }
    }

    // MARK: 5. The widget

    private var widgetTips: some View {
        GuideSection(title: "Widget'ı iyi kullan", systemImage: "iphone") {
            GuideParagraph("Widget'ı kilitli ekrana ekle. Telefona her baktığında kelimeyi görürsün; bu, gün içinde birçok kısa hatırlatma demek.")
            GuideNote("Kelime şu an \(GuideText.rotation(minutes: rotationMinutes)) değişir. Bunu Ayarlar'dan değiştirebilirsin; kelimeyi rahatça okumak için 30 dakika ya da 1 saat iyidir.", systemImage: "clock")
            GuideSubheading("Ana ekran widget'ındaki düğmeler")
            // Symbols and order of the widget's buttons (Widgets/WidgetButtons.swift).
            VStack(alignment: .leading, spacing: 12) {
                GuideIconRow(
                    systemImage: "checkmark",
                    title: "Biliyorum",
                    detail: "Kelimeyi zaten iyi biliyorsan bas. Kelime sıradan çıkar ve yalnızca \(GuideText.refresherInterval) sorulur. Emin değilsen basma."
                )
                GuideIconRow(
                    systemImage: "speaker.wave.2",
                    title: "Dinle",
                    detail: "Kelimeyi sesli okur."
                )
                GuideIconRow(
                    systemImage: "forward.fill",
                    title: "Sonraki kelime",
                    detail: "Sıradaki kelimeye geçer. Kelimenin tekrar zamanı değişmez."
                )
            }
            GuideNote("Kilitli ekrandaki widget'ta düğme yok; kelime kendiliğinden değişir.")
        }
    }

    // MARK: 6. Söyle

    private var pronunciation: some View {
        GuideSection(title: "Söyle ile telaffuz", systemImage: "mic") {
            GuideParagraph("Akış'taki ve Sözlük'teki kartlarda kelimenin yanında bir mikrofon var. Ona dokun, önce dinle, sonra **Söyle**'ye bas ve kelimeyi yüksek sesle söyle.")
            GuideVerdictSamples()
            GuideParagraph("Telefon seni dinler ve Türkçe cevap verir. Sesli söylemek kelimeyi akılda da tutar. Söyle ilerlemeni değiştirmez; rahatça dene.")
        }
    }

    // MARK: 7. Tips for Turkish speakers

    private var turkishTips: some View {
        GuideSection(title: "Türkçe konuşanlara ipuçları", systemImage: "text.bubble") {
            GuideParagraph("Bazı İngilizce kelimeler Türkçe bir kelimeye benzer ama anlamı başkadır. Bunlara “sahte dost” denir:")
            GuideFalseFriends()
            GuideParagraph("Kartlardaki **Dikkat** kutusu, Türkçe konuşanların sık yaptığı bir hatayı gösterir. Yanlış cümleyle doğrusuna bak; değişen kelimenin altı çizili.")
            GuideMistakeExample()
        }
    }
}

// MARK: - Text

/// Waits and intervals in words, from the real schedule (`Leitner`).
private enum GuideText {
    /// How long a new word waits after `grade`: "10 dakika", "12 saat", "1 gün", "2 gün".
    static func newWordWait(_ grade: ReviewGrade) -> String {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let next = Leitner.review(WordProgress(wordID: 0), grade: grade, at: start)
        return duration(next.dueAt?.timeIntervalSince(start) ?? 0)
    }

    /// The wait of each box: "1 gün", "2 gün", "4 gün", "8 gün", "16 gün".
    static var boxWaits: [String] {
        return Leitner.intervalDays.map { duration($0 * 86_400) }
    }

    /// How often a learned word (or one marked "Biliyorum") comes back: "30 günde bir". A
    /// correct refresher sets the same wait again.
    static var refresherInterval: String {
        let wait = amount(Leitner.refresherDelay)
        switch wait.unit {
        case .minutes:
            return "\(wait.value) dakikada bir"
        case .hours:
            return "\(wait.value) saatte bir"
        case .days:
            return "\(wait.value) günde bir"
        }
    }

    /// A wait in its largest whole unit: "10 dakika", "12 saat", "16 gün".
    static func duration(_ seconds: TimeInterval) -> String {
        let wait = amount(seconds)
        switch wait.unit {
        case .minutes:
            return "\(wait.value) dakika"
        case .hours:
            return "\(wait.value) saat"
        case .days:
            return "\(wait.value) gün"
        }
    }

    private enum Unit {
        case minutes
        case hours
        case days
    }

    /// Minutes under an hour, hours under a day, otherwise days (rounded).
    private static func amount(_ seconds: TimeInterval) -> (value: Int, unit: Unit) {
        let minutes = Int((seconds / 60).rounded())
        if minutes < 60 {
            return (max(minutes, 1), .minutes)
        }
        let hours = Int((seconds / 3600).rounded())
        if hours < 24 {
            return (hours, .hours)
        }
        return (Int((seconds / 86_400).rounded()), .days)
    }

    /// How often the widget word changes: "5 dakikada bir", "saatte bir", "2 saatte bir".
    static func rotation(minutes: Int) -> String {
        if minutes >= 60 && minutes % 60 == 0 {
            let hours = minutes / 60
            return hours == 1 ? "saatte bir" : "\(hours) saatte bir"
        }
        return "\(max(minutes, 1)) dakikada bir"
    }
}

// MARK: - Building blocks

/// One card: a small symbol on a soft square, the title (a VoiceOver heading), then the content.
/// At accessibility sizes the symbol goes above the title and the card's margins shrink.
private struct GuideSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: () -> Content
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var iconSize: CGFloat = 32

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            content()
        }
        .padding(dynamicTypeSize.isAccessibilitySize ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .guideCard()
    }

    @ViewBuilder
    private var header: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                icon
                titleText
            }
        } else {
            HStack(spacing: 12) {
                icon
                titleText
            }
        }
    }

    /// The symbol is sized from the capped square, so it never outgrows it at accessibility sizes.
    private var icon: some View {
        let side = min(iconSize, 48)
        return Image(systemName: systemImage)
            .font(.system(size: side * 0.5, weight: .semibold))
            .foregroundStyle(Theme.ink)
            .frame(width: side, height: side)
            .background(Theme.tintSoft, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .accessibilityHidden(true)
    }

    private var titleText: some View {
        Text(verbatim: title)
            .font(.title3.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Body text of a card (Markdown bold allowed).
private struct GuideParagraph: View {
    let text: LocalizedStringKey

    init(_ text: LocalizedStringKey) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.body)
            .foregroundStyle(Theme.ink)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A smaller side remark with a symbol (mockup `.info`).
private struct GuideNote: View {
    let text: LocalizedStringKey
    let systemImage: String

    init(_ text: LocalizedStringKey, systemImage: String = "info.circle") {
        self.text = text
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            Text(text)
                .foregroundStyle(Theme.ink2)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
    }
}

/// A heading inside a card ("Tekrar'daki dört düğme ne demek?").
private struct GuideSubheading: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(verbatim: title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 4)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A row with a button's symbol in a small circle, its name, an optional time on the right and
/// one line under it (the four answers, the widget's buttons). The time moves under the name
/// when both do not fit on one line; the symbol goes at accessibility sizes.
private struct GuideIconRow: View {
    let systemImage: String
    let title: String
    let detail: String
    var trailing: String? = nil
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 32

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: systemImage)
                    .font(.system(size: iconSize * 0.5, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: iconSize, height: iconSize)
                    .background(Theme.surface2, in: Circle())
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        titleText
                        Spacer(minLength: 0)
                        trailingText
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        titleText
                        trailingText
                    }
                }
                Text(verbatim: detail)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    /// No line limit: the stacked layout must wrap "Sonraki kelime" at accessibility sizes.
    private var titleText: some View {
        Text(verbatim: title)
            .font(.body.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var trailingText: some View {
        if let trailing {
            Text(verbatim: trailing)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension View {
    /// A flat card (mockup `.card`): `surface`, a `line` border and no shadow, so the cards of a
    /// long page stay calm.
    func guideCard() -> some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
        return background(Theme.surface, in: shape)
            .overlay {
                shape.strokeBorder(Theme.line, lineWidth: 1)
            }
    }

    /// A well inside a card (the sum, the word to try, the lists, the Dikkat box): `surface2`.
    func guideWell() -> some View {
        background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
    }
}

// MARK: - Pieces of the sections

/// "Kısaca": the three habits, for a reader who stops here.
private struct GuideSummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kısaca")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .accessibilityAddTraits(.isHeader)
            row("Her gün biraz çalış. Kısa ve düzenli çalışmak en iyisi.")
            row("Önce hatırlamaya çalış, sonra cevaba bak.")
            row("Dürüst cevap ver: “Zor” da doğru cevap sayılır.")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
    }

    private func row(_ text: LocalizedStringKey) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "checkmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityHidden(true)
            Text(text)
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// "Gör → Hatırla → Yerleşir" (section 1): three steps side by side, one under the other when
/// they do not fit (large text sizes).
private struct GuideLoop: View {
    private struct Step {
        let systemImage: String
        let title: String
        let caption: String
    }

    /// The middle step uses the Tekrar tab's symbol.
    private let steps = [
        Step(systemImage: "eye", title: "Gör", caption: "widget'ta"),
        Step(systemImage: "arrow.triangle.2.circlepath", title: "Hatırla", caption: "Tekrar'da"),
        Step(systemImage: "checkmark.seal", title: "Yerleşir", caption: "kalıcı olur"),
    ]
    @ScaledMetric(relativeTo: .body) private var circle: CGFloat = 40

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 0) {
                column(steps[0])
                arrow
                column(steps[1])
                arrow
                column(steps[2])
            }
            VStack(alignment: .leading, spacing: 10) {
                ForEach(steps.indices, id: \.self) { index in
                    row(steps[index])
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var circleSize: CGFloat {
        return min(circle, 56)
    }

    private var arrow: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 6)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(Theme.ink3)
            Spacer(minLength: 6)
        }
        .frame(height: circleSize)
        .accessibilityHidden(true)
    }

    private func icon(_ step: Step) -> some View {
        Image(systemName: step.systemImage)
            .font(.system(size: circleSize * 0.45, weight: .semibold))
            .foregroundStyle(Theme.ink)
            .frame(width: circleSize, height: circleSize)
            .background(Theme.surface2, in: Circle())
            .accessibilityHidden(true)
    }

    private func column(_ step: Step) -> some View {
        VStack(spacing: 6) {
            icon(step)
            Text(verbatim: step.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.ink)
            Text(verbatim: step.caption)
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
        }
        .lineLimit(1)
        .fixedSize()
        .accessibilityElement(children: .combine)
    }

    private func row(_ step: Step) -> some View {
        HStack(spacing: 12) {
            icon(step)
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: step.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text(verbatim: step.caption)
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The five boxes as rising bars with their waits under them ("1 gün" … "16 gün"); a plain list
/// when the labels do not fit side by side. VoiceOver reads one sentence.
private struct GuideIntervalLadder: View {
    let waits: [String]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            bars
            list
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Basamaklar: " + waits.joined(separator: ", ")))
    }

    private var bars: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(waits.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Theme.tint.opacity(barOpacity(index)))
                        .frame(height: 12 + CGFloat(index) * 10)
                    Text(verbatim: waits[index])
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                        .fixedSize()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var list: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(waits.indices, id: \.self) { index in
                Text(verbatim: "\(index + 1). basamak: \(waits[index])")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Light to full ink, so the bars read as a climb (progress is `tint`, never yellow).
    private func barOpacity(_ index: Int) -> Double {
        let last = max(waits.count - 1, 1)
        return 0.25 + 0.75 * Double(index) / Double(last)
    }
}

/// "Dene" (section 3): a real card (content.sqlite, "borrow", A2) with the meaning hidden until
/// the button. The page's only phosphor band and only marked example sentence.
private struct GuideRecallDemo: View {
    @State private var isRevealed = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let lemma = "borrow"
    private let meaning = "ödünç almak"
    private let example = "Can I borrow your pen for a minute?"
    private let translation = "Kalemini bir dakikalığına ödünç alabilir miyim?"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dene: bu kelime ne demek?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
            // The night line hangs below the text: the 12 pt spacing leaves room for it.
            Text(verbatim: lemma)
                .englishWordStyle(size: 34, maxSize: 46)
                .phosphorBand()
                .englishVoice()
            if isRevealed {
                VStack(alignment: .leading, spacing: 6) {
                    Text(verbatim: meaning)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Text(ExampleMark.attributed(example, lemma: lemma, colorScheme: colorScheme))
                        .exampleStyle()
                        .fixedSize(horizontal: false, vertical: true)
                        .englishVoice()
                    Text(verbatim: translation)
                        .exampleTranslationStyle()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity)
            } else {
                Text("Önce kendin hatırlamaya çalış. Sonra düğmeye bas.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
            Button {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    isRevealed.toggle()
                }
            } label: {
                Label(isRevealed ? "Gizle" : "Anlamını göster", systemImage: isRevealed ? "eye.slash" : "eye")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle())
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .guideWell()
    }
}

/// "10 × 30 gün ≈ 300 kelime" (section 4) with the reader's own goal.
private struct GuideMonthMath: View {
    let dailyNewWords: Int

    var body: some View {
        let perDay = max(dailyNewWords, 1)
        let perMonth = perDay * 30
        VStack(alignment: .leading, spacing: 4) {
            Text("Senin hedefin: günde \(perDay) yeni kelime")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
            Text(verbatim: "\(perDay) × 30 gün ≈ \(perMonth) kelime")
                .font(.title2.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Bir ayda yaklaşık \(perMonth) yeni kelime öğrenmeye başlarsın. Tekrarlarla kalıcı olurlar.")
                .font(.subheadline)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .guideWell()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Senin hedefin günde \(perDay) yeni kelime. 30 günde yaklaşık \(perMonth) kelime. Bir ayda yaklaşık \(perMonth) yeni kelime öğrenmeye başlarsın. Tekrarlarla kalıcı olurlar."))
    }
}

/// The three answers of "Söyle" with the colors of its feedback panel (README point 15): always
/// a symbol and a word with the color (rule 4).
private struct GuideVerdictSamples: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                samples
            }
            VStack(alignment: .leading, spacing: 8) {
                samples
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var samples: some View {
        sample("Doğru!", systemImage: "checkmark.circle.fill", color: Theme.good, fill: Theme.goodTint)
        sample("Neredeyse!", systemImage: "exclamationmark.circle.fill", color: Theme.caution, fill: Theme.cautionTint)
        sample("Bir daha dene", systemImage: "arrow.counterclockwise.circle.fill", color: Theme.bad, fill: Theme.badTint)
    }

    /// Not a button: a rounded rectangle, not a capsule (rule 2). Wraps when stacked at
    /// accessibility sizes instead of being cut.
    private func sample(_ title: String, systemImage: String, color: Color, fill: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.footnote.weight(.bold))
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(fill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

/// Three false friends from the cards' `false_friend` notes (content.sqlite). English words are
/// separate serif texts with the English voice, so the rows are not combined for VoiceOver.
private struct GuideFalseFriends: View {
    private struct Pair {
        let english: String
        let meaning: String
        /// The Turkish look-alike, with its meaning when it is not obvious.
        let lookalike: String
        /// What the look-alike is in English.
        let lookalikeEnglish: String
    }

    private let pairs = [
        Pair(english: "apartment", meaning: "daire", lookalike: "“Apartman” (bina)", lookalikeEnglish: "apartment building"),
        Pair(english: "fabric", meaning: "kumaş", lookalike: "“Fabrika”", lookalikeEnglish: "factory"),
        Pair(english: "actual", meaning: "gerçek", lookalike: "“Aktüel” (güncel)", lookalikeEnglish: "current"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(pairs.indices, id: \.self) { index in
                row(pairs[index])
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .guideWell()
    }

    private func row(_ pair: Pair) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    englishText(pair.english)
                    Text(verbatim: "=")
                        .foregroundStyle(Theme.ink3)
                        .accessibilityHidden(true)
                    meaningText(pair)
                }
                VStack(alignment: .leading, spacing: 0) {
                    englishText(pair.english)
                    meaningText(pair)
                }
            }
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    lookalikeText(pair)
                    lookalikeEnglishText(pair)
                }
                VStack(alignment: .leading, spacing: 0) {
                    lookalikeText(pair)
                    lookalikeEnglishText(pair)
                }
            }
        }
    }

    /// One line that shrinks before it is cut ("apartment" at the largest sizes on an SE).
    private func englishText(_ english: String) -> some View {
        Text(verbatim: english)
            .font(.system(.body, design: .serif).weight(.bold))
            .foregroundStyle(Theme.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .englishVoice()
    }

    private func lookalikeText(_ pair: Pair) -> some View {
        Text(verbatim: pair.lookalike + " İngilizcede:")
            .font(.subheadline)
            .foregroundStyle(Theme.ink2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func lookalikeEnglishText(_ pair: Pair) -> some View {
        Text(verbatim: pair.lookalikeEnglish)
            .font(.system(.subheadline, design: .serif).weight(.semibold))
            .foregroundStyle(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
            .englishVoice()
    }

    private func meaningText(_ pair: Pair) -> some View {
        Text(verbatim: pair.meaning)
            .font(.body.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A Dikkat box like the cards' (`MistakeBox`), drawn here from the shared `MistakeDiff` so the
/// guide does not depend on the card views. The mistake is the "fabric" card's. As in
/// `MistakeBox`, the sentences stay separate VoiceOver elements (English voice).
private struct GuideMistakeExample: View {
    private let diff = MistakeDiff(wrong: "I work in a fabric.", right: "I work in a factory.")
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.caution)
                    .accessibilityHidden(true)
                Text("Dikkat")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.ink)
            }
            .accessibilityElement(children: .combine)
            if dynamicTypeSize.isAccessibilitySize {
                // No room for a label column: each label above its sentence.
                VStack(alignment: .leading, spacing: 4) {
                    tag(isRight: false)
                    wrongSentence
                    tag(isRight: true)
                        .padding(.top, 4)
                    rightSentence
                }
            } else {
                Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 10, verticalSpacing: 6) {
                    GridRow {
                        tag(isRight: false)
                        wrongSentence
                    }
                    GridRow {
                        tag(isRight: true)
                        rightSentence
                    }
                }
            }
            Text("“Fabrika” için “factory” kullanılır. “Fabric” kumaş demektir.")
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .guideWell()
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

    private var wrongSentence: some View {
        Text(diff.wrongText())
            .font(.system(.callout, design: .serif))
            .foregroundStyle(Theme.ink)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .englishVoice()
    }

    private var rightSentence: some View {
        Text(diff.rightText())
            .font(.system(.callout, design: .serif).weight(.bold))
            .foregroundStyle(Theme.ink)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .englishVoice()
    }
}

// MARK: - Previews

#Preview("Ayarlar'dan") {
    NavigationStack {
        LearningGuideView(dailyNewWords: 10, rotationMinutes: 60)
    }
}

#Preview("Gece, en büyük yazı") {
    NavigationStack {
        LearningGuideView(dailyNewWords: 20, rotationMinutes: 15)
    }
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility5)
}
