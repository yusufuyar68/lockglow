import SwiftUI
import CoreModels
import Learning

/// "Cümle kur": a short practice round with the example sentences of the words being learned or
/// known (`AppModel.sentencePracticeRound`, `SentencePractice`). Mostly "put the words in order"
/// (`SentenceBuildCard`), now and then "Hangisi birlikte kullanılır?" (`CollocationChoiceCard`).
/// A wrong question comes once more two questions later.
///
/// Practice only (ogrenme_ilkeleri 3): no grade, no box, no due date; the summary says so. The
/// one record is a count of its own (`AppModel.countSentencePractice`). No streak, no score: the
/// summary says how many sentences were practiced, nothing about right or wrong.
///
/// Opened from "Biraz daha pratik" on Tekrar's done screen (`SentencePracticeLink`) and from
/// "Cümle kur" in Ayarlar' İlerleme group (`SentencePracticeSettingsRow`); pushed on their
/// navigation stack, so the back button leaves it. The tab bar is hidden while it is open: the
/// main button sits at the bottom, where the thumb is.
struct SentencePracticeView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    /// Nil until the screen first appears.
    @State private var round: SentencePractice.Round?
    /// Mixes words, sentences and tiles; each "Bir tur daha" takes the next one.
    @State private var seed = Int.random(in: 0..<1_000_000_000)
    @AccessibilityFocusState private var focusesTitle: Bool

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Cümle kur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            // Borderless controls are ink, never the system blue (rule 2).
            .tint(Theme.ink)
            .onAppear {
                if round == nil {
                    startRound()
                }
            }
            .onDisappear {
                Speaker.shared.stop()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let round = round {
            if let step = round.current {
                VStack(spacing: 8) {
                    header(round)
                    stepView(step)
                        .id(round.index)
                }
            } else if round.questionCount > 0 {
                summary(round)
            } else {
                emptyState
            }
        } else {
            Color.clear
        }
    }

    // MARK: Round

    /// "Cümle 2 / 5" and the progress (a second try adds one), as in "Tekrar"'s header.
    private func header(_ round: SentencePractice.Round) -> some View {
        let progress = round.progress
        let counter = Text(verbatim: "Cümle \(progress.done + 1) / \(progress.total)")
            .font(.subheadline.weight(.semibold).monospacedDigit())
            .foregroundStyle(Theme.ink2)
            // VoiceOver reads "/" as "bölü" (terimler 1).
            .accessibilityLabel(Text(verbatim: "Cümle \(progress.done + 1), toplam \(progress.total)"))
        let bar = PracticeProgressBar(done: progress.done, total: progress.total)
        return Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    counter
                    bar
                }
            } else {
                HStack(spacing: 12) {
                    counter
                        .fixedSize()
                    bar
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func stepView(_ step: SentencePractice.Round.Step) -> some View {
        let lemma = model.word(id: step.item.wordID)?.lemma
        // Another order on the second try, and another per word.
        let mix = seed &+ step.item.wordID
        switch step.item {
        case let .build(_, tiles, translation):
            SentenceBuildCard(tiles: tiles, translation: translation, lemma: lemma, seed: mix, attempt: step.attempt) { isRight in
                answer(isRight: isRight)
            }
        case let .collocation(_, choice, translation):
            CollocationChoiceCard(choice: choice, translation: translation, seed: mix, attempt: step.attempt) { isRight in
                answer(isRight: isRight)
            }
        }
    }

    private func startRound() {
        Speaker.shared.stop()
        round = SentencePractice.Round(items: model.sentencePracticeRound(seed: seed))
    }

    private func answer(isRight: Bool) {
        Speaker.shared.stop()
        // A second try is the same question: counted once.
        if round?.current?.attempt == 0 {
            AppModel.countSentencePractice()
        }
        round?.answer(isRight: isRight)
        if round?.isFinished == true {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 150_000_000)
                focusesTitle = true
            }
        }
    }

    // MARK: Summary

    /// "Pratik bitti": how many sentences, today's count when this was not the first round, and
    /// what practice does not do. One filled button ("Bir tur daha"), and "Tamam".
    private func summary(_ round: SentencePractice.Round) -> some View {
        let today = AppModel.sentencePracticeTally().todayCount(now: Date())
        return ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 64, height: 64)
                        .background(Theme.surface2, in: Circle())
                        .accessibilityHidden(true)
                    Text("Pratik bitti")
                        .font(.title.bold())
                        .foregroundStyle(Theme.ink)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityFocused($focusesTitle)
                    Text(verbatim: "\(round.questionCount) cümle çalıştın.")
                        .font(.callout)
                        .foregroundStyle(Theme.ink2)
                        .multilineTextAlignment(.center)
                    // Today's count includes this round.
                    if today > round.questionCount {
                        Text(verbatim: "Bugün: \(today) cümle.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink2)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 22)
                .frame(maxWidth: .infinity)
                .cardSurface(cornerRadius: Theme.Radius.wordCard)
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 36, height: 36)
                        .background(Theme.surface2, in: Circle())
                        .accessibilityHidden(true)
                    Text("Pratik, tekrar sayılmaz. Kelimelerin basamakları değişmez.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardSurface(cornerRadius: Theme.Radius.card)
                Button("Bir tur daha") {
                    seed &+= 1
                    startRound()
                }
                .buttonStyle(PrimaryCapsuleButtonStyle(minHeight: 54))
                Button("Tamam") {
                    dismiss()
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    // MARK: Nothing to practice

    /// No word can be used now: none learned yet, or every one is about to be asked in "Tekrar".
    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: "text.book.closed")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
                Text("Şimdilik cümle yok")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text("Tekrar'da öğrendiğin kelimelerin cümleleri burada gelir. Birazdan sorulacak kelimeler tekrardan sonra gelir.")
                    .font(.callout)
                    .foregroundStyle(Theme.ink2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Tamam") {
                    dismiss()
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                .padding(.top, 6)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity)
            .cardSurface(cornerRadius: Theme.Radius.wordCard)
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

/// The round's progress: a `surface3` track with a `tint` fill, as in "Tekrar". Hidden from
/// VoiceOver: the counter says it.
private struct PracticeProgressBar: View {
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
            .accessibilityHidden(true)
    }
}

// MARK: - Ways in

/// "Biraz daha pratik" on Tekrar's done screen (ReviewView `doneContent`): only when some word can
/// be practiced now. Tonal, as the screen's filled button is another.
struct SentencePracticeLink: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        if model.hasSentencePractice {
            NavigationLink {
                SentencePracticeView()
            } label: {
                Label("Biraz daha pratik", systemImage: "puzzlepiece")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
            .accessibilityHint(Text("Öğrendiğin kelimelerle cümle kur."))
        }
    }
}

/// "Cümle kur" in Ayarlar' İlerleme group (SettingsView `progressSection`), always there: without
/// a word to practice the screen says how to get one.
struct SentencePracticeSettingsRow: View {
    var body: some View {
        NavigationLink {
            SentencePracticeView()
        } label: {
            SettingsRow("Cümle kur")
        }
        .buttonStyle(SettingsRowButtonStyle())
    }
}
