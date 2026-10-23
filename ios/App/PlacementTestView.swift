import SwiftUI
import CoreModels
import Learning

/// "Seviyeni bilmiyor musun?" on the onboarding's level page: opens the test and hands its result
/// to the page (which saves the level when the page is left, as a level tapped by hand). Hidden
/// when the content is too small for a test (seed words only).
struct PlacementTestButton: View {
    let onResult: (Level) -> Void
    @EnvironmentObject private var model: AppModel
    @State private var isPresented = false

    /// The sheet hangs on the `Group`, outside the `if`: content that turns out too small while
    /// the test is open must not close it mid-test.
    var body: some View {
        Group {
            if model.canOfferPlacementTest {
                button
            }
        }
        .sheet(isPresented: $isPresented) {
            PlacementTestSheet(onResult: onResult)
                .environmentObject(model)
        }
    }

    private var button: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title3)
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Seviyeni bilmiyor musun?")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text("Yaklaşık 2 dakikalık kısa bir testle bulalım.")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                }
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(Theme.surface2, in: shape)
            .overlay(shape.strokeBorder(Theme.lineStrong, lineWidth: 1))
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Seviyeni bilmiyor musun? Seviye testi, yaklaşık 2 dakika")
        .accessibilityIdentifier("placement.open")
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
    }
}

/// The row in "Ayarlar" (Öğrenme, under the level): the same test; its result is saved at once.
struct PlacementTestSettingsRow: View {
    @EnvironmentObject private var model: AppModel
    @State private var isPresented = false

    var body: some View {
        Group {
            if model.canOfferPlacementTest {
                row
            }
        }
        .sheet(isPresented: $isPresented) {
            PlacementTestSheet { level in
                model.applyPlacementResult(level)
            }
            .environmentObject(model)
        }
    }

    private var row: some View {
        SettingsGroup {
            Button {
                isPresented = true
            } label: {
                SettingsRow("Seviye testi", systemImage: "list.bullet.clipboard") {
                    Text("Yaklaşık 2 dakika")
                }
            }
            .buttonStyle(SettingsRowButtonStyle())
            .accessibilityIdentifier("settings.placement")
        }
    }
}

/// The test itself: a short intro, the words one by one, then the level with a short Turkish
/// explanation. A tap on a meaning goes on to the next word (the test shows no right or wrong:
/// it only looks for the level, so it stays short and calm). "Kapat" before the end changes
/// nothing; the result is handed over as soon as it is shown.
struct PlacementTestSheet: View {
    let onResult: (Level) -> Void

    private enum Phase: Equatable {
        case intro
        case asking
        case result(Level)
    }

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var phase: Phase = .intro
    @State private var test: PlacementTest?
    @State private var question: ChoiceQuestion?
    /// The option just tapped, outlined for a moment before the next word.
    @State private var picked: String?
    @AccessibilityFocusState private var isHeadingFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                content
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollBounceBehavior(.basedOnSize)
            bottomBar
        }
        .background(Theme.bg.ignoresSafeArea())
        .tint(Theme.ink)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: question?.wordID)
    }

    // MARK: Bars

    private var topBar: some View {
        HStack(spacing: 12) {
            if phase == .asking, let test = test {
                // Toward 20 words first, then toward 25: a clear result at 20 fills the bar.
                let total = test.answers.count < PlacementTest.minimumQuestions
                    ? PlacementTest.minimumQuestions
                    : PlacementTest.maximumQuestions
                PlacementProgressBar(done: test.answers.count, total: total)
            } else {
                Spacer(minLength: 0)
            }
            if !isResult {
                Button {
                    dismiss()
                } label: {
                    Text("Kapat")
                        .font(.body.weight(.semibold))
                        .frame(minHeight: 30)
                }
                .glassControl()
                .accessibilityIdentifier("placement.close")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .frame(minHeight: 56)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    @ViewBuilder
    private var bottomBar: some View {
        switch phase {
        case .intro:
            Button("Başla", action: start)
                .buttonStyle(GlowButtonStyle())
                .disabled(model.contentSource == .loading)
                .accessibilityIdentifier("placement.start")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        case .asking:
            Button {
                choose(nil)
            } label: {
                Text("Emin değilim")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 50, tonal: true))
            .disabled(picked != nil || question == nil)
            .accessibilityIdentifier("placement.unsure")
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        case .result:
            Button("Tamam") {
                dismiss()
            }
            .buttonStyle(GlowButtonStyle())
            .accessibilityIdentifier("placement.done")
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        }
    }

    private var isResult: Bool {
        if case .result = phase {
            return true
        }
        return false
    }

    // MARK: Pages

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .intro:
            intro
        case .asking:
            if let question = question {
                questionView(question)
                    .id(question.wordID)
                    .transition(.opacity)
            }
        case let .result(level):
            PlacementResultView(level: level, focus: $isHeadingFocused)
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Seviye testi")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.ink)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .accessibilityAddTraits(.isHeader)
            Text("Yaklaşık 2 dakika sürer: 20 ile 25 arası kelime.")
                .font(.body)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 12) {
                IntroLine(symbol: "hand.tap", text: "Her kelimenin anlamını seç.")
                IntroLine(symbol: "questionmark.circle", text: "Emin değilsen tahmin etme, Emin değilim düğmesine dokun.")
                IntroLine(symbol: "arrow.up.arrow.down", text: "Kelimeler cevaplarına göre zorlaşır ya da kolaylaşır.")
                IntroLine(symbol: "checkmark.seal", text: "Sonunda başlangıç seviyeni söyleriz. Testteki kelimeler bildiğin kelimelere eklenmez.")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()
            if model.contentSource == .loading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Kelimeler hazırlanıyor…")
                        .font(.body)
                        .foregroundStyle(Theme.ink2)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    /// "Anlamını seç": the word (serif, the band under it) with "Dinle", then four meanings, one
    /// per row (a Turkish meaning can be long), as in "Hatırla".
    private func questionView(_ question: ChoiceQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Anlamını seç")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityAddTraits(.isHeader)
                    // "/" would be read as "bölü" (terimler §1).
                    .accessibilityLabel("Kelime \((test?.answers.count ?? 0) + 1), en çok \(PlacementTest.maximumQuestions). Anlamını seç")
                    .accessibilityFocused($isHeadingFocused)
                PlacementHeadline(lemma: question.prompt)
                CardListenCapsule(text: question.prompt, accessibilityName: "Kelimeyi dinle")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()
            VStack(spacing: 8) {
                ForEach(question.options, id: \.self) { option in
                    optionButton(option)
                }
            }
        }
    }

    private func optionButton(_ option: String) -> some View {
        let isPicked = picked == option
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        return Button {
            choose(option)
        } label: {
            Text(verbatim: option)
                .font(.title3.weight(.medium))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Theme.surface, in: shape)
                .overlay(shape.strokeBorder(isPicked ? Theme.tint : Theme.lineStrong, lineWidth: isPicked ? 2.5 : 1.5))
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(picked == nil)
        .accessibilityAddTraits(isPicked ? .isSelected : [])
    }

    // MARK: Actions

    private func start() {
        let seed = Int(Date().timeIntervalSince1970) % 1_000_000
        test = PlacementTest(bank: model.placementBank(), seed: seed)
        phase = .asking
        loadQuestion()
    }

    /// The test's next word with a usable question (words without one are skipped), or the result.
    private func loadQuestion() {
        guard var current = test else {
            return
        }
        var next: ChoiceQuestion?
        while let item = current.current {
            if let built = model.placementQuestion(for: item.wordID) {
                next = built
                break
            }
            current.skipCurrent()
        }
        test = current
        picked = nil
        if let next = next {
            question = next
            focusHeading()
        } else {
            finish(current)
        }
    }

    /// A meaning, or nil for "Emin değilim". The pick stays outlined for a moment (none with
    /// Reduce Motion), then the next word comes.
    private func choose(_ option: String?) {
        guard picked == nil, let question = question, var current = test else {
            return
        }
        picked = option ?? ""
        current.answer(right: option == question.answer)
        test = current
        let delay: UInt64 = reduceMotion || option == nil ? 0 : 220_000_000
        Task { @MainActor in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }
            loadQuestion()
        }
    }

    private func finish(_ finished: PlacementTest) {
        let level = finished.result
        question = nil
        phase = .result(level)
        onResult(level)
        focusHeading()
    }

    /// VoiceOver moves to the new heading, not staying on the button that was tapped.
    private func focusHeading() {
        isHeadingFocused = false
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            isHeadingFocused = true
        }
    }
}

/// One line of the intro: an icon and a short sentence.
private struct IntroLine: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(Theme.ink2)
                .frame(minWidth: 24)
                .accessibilityHidden(true)
            Text(verbatim: text)
                .font(.body)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// The test word in the theme's word style (Large Title, 34 pt), the Title 1 size (28 pt) when it
/// does not fit; a long phrase wraps at the Title 1 size. Serif with the band under it.
private struct PlacementHeadline: View {
    let lemma: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            line(size: 34, maxSize: 56)
            line(size: 28, maxSize: 46)
            Text(verbatim: lemma)
                .font(.system(.title, design: .serif).weight(.bold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: lemma))
        .englishVoice()
    }

    private func line(size: CGFloat, maxSize: CGFloat) -> some View {
        Text(verbatim: lemma)
            .englishWordStyle(size: size, maxSize: maxSize)
            .phosphorBand()
    }
}

/// The result: the level with its dots, what it means in two short sentences, and that the
/// words were not counted as known. No score, no right/wrong count, no praise (ogrenme_ilkeleri
/// 1.12 and 2.5).
private struct PlacementResultView: View {
    let level: Level
    let focus: AccessibilityFocusState<Bool>.Binding
    @ScaledMetric(relativeTo: .title) private var dotSize: CGFloat = 9

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Başlangıç seviyen")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink2)
            HStack(alignment: .center, spacing: 16) {
                // The screen's big number: Large Title bold (Dynamic Type), default design.
                Text(verbatim: level.rawValue)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                HStack(spacing: 5) {
                    ForEach(1...3, id: \.self) { dot in
                        if dot <= level.rank {
                            Circle().fill(Theme.ink).frame(width: dotSize, height: dotSize)
                        } else {
                            Circle().strokeBorder(Theme.ink3, lineWidth: 1.5).frame(width: dotSize, height: dotSize)
                        }
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: "Başlangıç seviyen: \(level.rawValue), \(PlacementResultText.title(level))"))
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused(focus)
            Text(verbatim: PlacementResultText.title(level))
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityHidden(true)
            Text(verbatim: PlacementResultText.explanation(level))
                .font(.body)
                .foregroundStyle(Theme.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            // Subheadline like the label at the top: the page keeps four sizes.
            VStack(alignment: .leading, spacing: 8) {
                Text("Testteki kelimeler bildiğin kelimelere eklenmedi.")
                Text("Seviyeni Ayarlar'dan istediğin zaman değiştirebilirsin.")
            }
            .font(.subheadline)
            .foregroundStyle(Theme.ink2)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// The result's words: what each level holds (not the user: "Yeni başlıyorum" is the onboarding's
/// answer), and why the start is there.
enum PlacementResultText {
    static func title(_ level: Level) -> String {
        switch level {
        case .a1: return "En temel kelimeler"
        case .a2: return "Günlük hayat"
        default: return "İş, seyahat ve duygular"
        }
    }

    static func explanation(_ level: Level) -> String {
        switch level {
        case .a1:
            return "A1 kelimelerinin bir kısmı senin için yeni. En temel konularla başlıyoruz: ev, yemek, aile."
        case .a2:
            return "Testte A1 kelimelerinin çoğunu bildin. Günlük hayatla başlıyoruz: alışveriş, yol, randevu."
        default:
            return "Testte A1 ve A2 kelimelerinin çoğunu bildin. İş, seyahat ve duygularla başlıyoruz."
        }
    }
}

/// A 6 pt `surface3` track filled with `tint`, as the round's bar in "Tekrar". Hidden from
/// VoiceOver: the heading says "Kelime 3, en çok 25".
private struct PlacementProgressBar: View {
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
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}
