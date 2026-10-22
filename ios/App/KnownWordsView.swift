import SwiftUI
import UIKit
import CoreModels
import Learning

/// "Bildiğin kelimeler" (docs/tasarim/terimler.md): every known word, the most recent first
/// (mockup `st-known`). A word marked known by mistake (for example the widget's "Biliyorum" tapped
/// by accident) goes back to learning with the row's "Geri al" or a swipe; a short notice at the
/// bottom offers "Vazgeç", which puts the word's progress back exactly. What "Geri al" does is
/// said once, above the list, where a long list does not hide it.
struct KnownWordsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The word whose whole card is open.
    @State private var openedWord: WidgetWord?
    /// The word just taken back to learning, while its notice is on screen.
    @State private var undone: KnownWordsUndone?
    /// VoiceOver is on the notice's "Vazgeç": the notice stays.
    @AccessibilityFocusState private var noticeHasFocus: Bool

    var body: some View {
        let known = model.knownWords()
        Group {
            if known.isEmpty {
                ScrollView {
                    WordListEmptyState(
                        systemImage: "checkmark.circle",
                        title: "Henüz bildiğin kelime yok",
                        message: AttributedString("\"Biliyorum\" dediğin ya da Tekrar'da öğrendiğin kelimeler burada görünür.")
                    )
                    .padding(.top, 12)
                }
            } else {
                list(known)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .overlay(alignment: .bottom) {
            undoNotice
        }
        .navigationTitle("Bildiğin kelimeler")
        .navigationBarTitleDisplayMode(.large)
        // Outside the list's rows: the open card stays when its row leaves the list (after
        // "Öğrenmeye geri al" on the card).
        .navigationDestination(item: $openedWord) { word in
            WordDetailView(word: word)
        }
        .task(id: undone?.word.id) {
            await hideNoticeLater()
        }
    }

    private func list(_ known: [WidgetWord]) -> some View {
        List {
            Section {
                ForEach(known) { word in
                    KnownWordRow(word: word, open: { openedWord = word }, undo: { undo(word) })
                        .listRowBackground(Theme.surface)
                        .listRowSeparatorTint(Theme.line)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Geri al") {
                                undo(word)
                            }
                            .tint(swipeTint)
                        }
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: "\(known.count) kelime")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text("Geri al: kelime yine Tekrar'a ve widget'a gelir.")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                }
                .textCase(nil)
                .padding(.bottom, 4)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    /// The swipe action's fill under its white title: ink by day; at night, when ink is light, a
    /// dark gray.
    private var swipeTint: Color {
        return colorScheme == .dark ? Theme.surface3 : Theme.ink
    }

    @ViewBuilder
    private var undoNotice: some View {
        if let undone = undone {
            let transition: AnyTransition = reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity)
            KnownWordsUndoNotice(lemma: undone.word.lemma, undoHasFocus: $noticeHasFocus) {
                redo(undone)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .transition(transition)
        }
    }

    /// "Geri al": the word returns to the widget and to "Tekrar".
    private func undo(_ word: WidgetWord) {
        let before = model.progress[word.id]
        withAnimation(reduceMotion ? nil : .default) {
            model.undoKnown(word)
            undone = KnownWordsUndone(word: word, before: before, after: model.progress[word.id])
        }
        SozlukSpeech.announce(KnownWordsUndoNotice.message(lemma: word.lemma))
    }

    /// "Vazgeç": the word's progress as it was before "Geri al" (`AppModel.restoreProgress`), so a
    /// learned word stays learned and keeps its place in the list. Only when the word changed in
    /// between, a plain "Biliyorum".
    private func redo(_ undone: KnownWordsUndone) {
        withAnimation(reduceMotion ? nil : .default) {
            var restored = false
            if let before = undone.before, let after = undone.after {
                restored = model.restoreProgress(of: undone.word, to: before, ifStill: after)
            }
            if !restored {
                model.markKnown(undone.word)
            }
            self.undone = nil
        }
    }

    /// The notice leaves on its own after a few seconds; with VoiceOver or Switch Control it
    /// stays longer, so "Vazgeç" can still be reached, and never while VoiceOver is on it (WCAG
    /// 2.2.1, as the feed's notice).
    private func hideNoticeLater() async {
        guard undone != nil else {
            return
        }
        let seconds = UIAccessibility.isVoiceOverRunning || UIAccessibility.isSwitchControlRunning ? 10 : 4
        try? await Task.sleep(for: .seconds(seconds))
        while !Task.isCancelled && noticeHasFocus {
            try? await Task.sleep(for: .seconds(1))
        }
        guard !Task.isCancelled else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            undone = nil
        }
    }
}

/// One "Geri al" on "Bildiğin kelimeler": the word and its progress before and right after it.
private struct KnownWordsUndone {
    let word: WidgetWord
    let before: WordProgress?
    let after: WordProgress?
}

/// Mockup `.kw`: the serif word and its meaning open the whole card; "Geri al" sits on the row
/// in plain sight. At accessibility text sizes the button goes under the word. VoiceOver reads the
/// word alone in an English voice, then "Türkçesi: …" (audit V5, is3-tema: one merged label loses
/// the English voice); both open the card. "Geri al" says which word it takes back ("Geri al:
/// breakfast", V11), and hints say what the buttons do.
private struct KnownWordRow: View {
    let word: WidgetWord
    let open: () -> Void
    let undo: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(spacing: 8))
        layout {
            Button(action: open) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: word.lemma)
                        .font(.system(.body, design: .serif).weight(.bold))
                        .foregroundStyle(Theme.ink)
                    if let gloss = word.glossTR {
                        Text(gloss)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.ink2)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .contentShape(Rectangle())
            }
            // Not the list's default button style: the row must not also fire "Geri al".
            .buttonStyle(KnownWordOpenButtonStyle())
            // Two VoiceOver parts, as in Sözlük. LockglowScreenshotTests opens the card through the
            // first element whose label contains the word: the English part, before "Geri al".
            .accessibilityRepresentation {
                SozlukRowSpeech(lemma: word.lemma, details: word.glossTR.map { "Türkçesi: " + $0 } ?? "", open: open)
            }
            Button(action: undo) {
                Label("Geri al", systemImage: "arrow.uturn.backward")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
            // The word in its English run (a button has one name; `SozlukSpeech`).
            .accessibilityLabel(SozlukSpeech.label([.turkish("Geri al: "), .english(word.lemma)]))
            // Voice Control: the visible name.
            .accessibilityInputLabels([Text("Geri al")])
            .accessibilityHint("Kelime yine Tekrar'a ve widget'a gelir.")
        }
        .padding(.vertical, 2)
    }
}

/// The word's press feedback: it dims, like a plain button.
private struct KnownWordOpenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

/// Mockup `.toast`: an ink bar over the list with the result ("Öğrenmeye döndü: breakfast",
/// docs/tasarim/terimler.md; the word its own element in an English voice) and "Vazgeç". At
/// accessibility text sizes "Vazgeç" goes under the message.
private struct KnownWordsUndoNotice: View {
    let lemma: String
    /// VoiceOver on "Vazgeç" keeps the notice (`KnownWordsView.hideNoticeLater`).
    var undoHasFocus: AccessibilityFocusState<Bool>.Binding
    let undo: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(spacing: 10))
        layout {
            CardFlowLayout(itemSpacing: 5, lineSpacing: 2) {
                Text(KnownWordsUndoNotice.prefix)
                Text(verbatim: lemma)
                    .englishVoice()
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: undo) {
                Text("Vazgeç")
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 14)
                    .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
                    .background(Color(white: 0.5, opacity: 0.25), in: Capsule())
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityFocused(undoHasFocus)
        }
        .foregroundStyle(Theme.bg)
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(Theme.ink, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .accessibilityElement(children: .contain)
    }

    private static let prefix = "Öğrenmeye döndü:"

    /// What VoiceOver announces after "Geri al".
    static func message(lemma: String) -> [SozlukSpeech.Run] {
        return [.turkish(prefix + " "), .english(lemma)]
    }
}
