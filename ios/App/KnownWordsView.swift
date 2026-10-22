import SwiftUI
import UIKit
import CoreModels

/// "Bildiğim kelimeler": every known word, the most recent first (mockup `st-known`). A word
/// marked known by mistake (for example the widget's "Biliyorum" tapped by accident) goes back
/// to learning with the row's "Geri al" or a swipe; a short notice at the bottom offers "Vazgeç".
/// What "Geri al" does is said once, above the list, where a long list does not hide it.
struct KnownWordsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The word whose whole card is open.
    @State private var openedWord: WidgetWord?
    /// The word just taken back to learning, while its notice is on screen.
    @State private var undoneWord: WidgetWord?

    var body: some View {
        let known = model.knownWords()
        Group {
            if known.isEmpty {
                ScrollView {
                    WordListEmptyState(
                        systemImage: "checkmark.circle",
                        title: "Henüz bildiğin kelime yok",
                        message: AttributedString("Widget'ta \"Biliyorum\" dediğin ya da tekrarda öğrendiğin kelimeler burada görünür.")
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
        .navigationTitle("Bildiğim kelimeler")
        .navigationBarTitleDisplayMode(.large)
        // Outside the list's rows: the open card stays when its row leaves the list (after
        // "Öğrenmeye geri al" on the card).
        .navigationDestination(item: $openedWord) { word in
            WordDetailView(word: word)
        }
        .task(id: undoneWord?.id) {
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
                    Text("\"Geri al\" kelimeyi yeniden tekrara ve widget'a getirir.")
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
        if let word = undoneWord {
            let transition: AnyTransition = reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity)
            KnownWordsUndoNotice(lemma: word.lemma) {
                redo(word)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .transition(transition)
        }
    }

    /// "Geri al": the word returns to the widget and to "Tekrar".
    private func undo(_ word: WidgetWord) {
        withAnimation(reduceMotion ? nil : .default) {
            model.undoKnown(word)
            undoneWord = word
        }
        SozlukSpeech.announce(KnownWordsUndoNotice.message(lemma: word.lemma))
    }

    /// "Vazgeç": the word is known again (back at the top of the list).
    private func redo(_ word: WidgetWord) {
        withAnimation(reduceMotion ? nil : .default) {
            model.markKnown(word)
            undoneWord = nil
        }
    }

    /// The notice leaves on its own after a few seconds; with VoiceOver or Switch Control it
    /// stays longer, so "Vazgeç" can still be reached.
    private func hideNoticeLater() async {
        guard undoneWord != nil else {
            return
        }
        let seconds = UIAccessibility.isVoiceOverRunning || UIAccessibility.isSwitchControlRunning ? 10 : 4
        try? await Task.sleep(for: .seconds(seconds))
        guard !Task.isCancelled else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            undoneWord = nil
        }
    }
}

/// Mockup `.kw`: the serif word and its meaning open the whole card; "Geri al" sits on the row
/// in plain sight. At accessibility text sizes the button goes under the word. VoiceOver reads the
/// word in an English voice and its meaning in a Turkish one (audit V5); "Geri al" says which
/// word it takes back as its value (V11), and hints say what each of the two buttons does.
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
                    Text(word.lemma)
                        .font(.system(.body, design: .serif).weight(.bold))
                        .foregroundStyle(Theme.ink)
                        .cardEnglishVoice()
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
            .accessibilityLabel(openLabel)
            .accessibilityHint("Kartı açar")
            // The label stays "Geri al" (no word in it): LockglowScreenshotTests opens the card
            // through the first element whose label contains the word.
            Button(action: undo) {
                Label("Geri al", systemImage: "arrow.uturn.backward")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
            .accessibilityValue(SozlukSpeech.english(word.lemma))
            .accessibilityHint("Kelime yeniden tekrara ve widget'a gelir.")
        }
        .padding(.vertical, 2)
    }

    private var openLabel: Text {
        var runs: [SozlukSpeech.Run] = [.english(word.lemma)]
        if let gloss = word.glossTR {
            runs.append(.turkish(", " + gloss))
        }
        return SozlukSpeech.label(runs)
    }
}

/// The word's press feedback: it dims, like a plain button.
private struct KnownWordOpenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

/// Mockup `.toast`: an ink bar over the list with the result ("breakfast geri alındı", the word
/// in an English voice) and "Vazgeç". At accessibility text sizes "Vazgeç" goes under the message.
private struct KnownWordsUndoNotice: View {
    let lemma: String
    let undo: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(spacing: 10))
        layout {
            Text(verbatim: lemma + KnownWordsUndoNotice.suffix)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(SozlukSpeech.label(KnownWordsUndoNotice.message(lemma: lemma)))
            Button(action: undo) {
                Text("Vazgeç")
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 14)
                    .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
                    .background(Color(white: 0.5, opacity: 0.25), in: Capsule())
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Theme.bg)
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(Theme.ink, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .accessibilityElement(children: .contain)
    }

    private static let suffix = " geri alındı"

    static func message(lemma: String) -> [SozlukSpeech.Run] {
        return [.english(lemma), .turkish(suffix)]
    }
}
