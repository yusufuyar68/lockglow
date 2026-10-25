import SwiftUI
import UIKit
import PhotosUI
import CoreModels
import Learning

/// "Metinden kelime bul" (docs/ozellik_planlari/metinden_kelime.md): the user brings an English
/// text they are reading (typed, "Yapıştır", "Kamerayla tara", "Fotoğraftan al", or sent by a
/// shortcut) and "Kelimeleri bul" lists its words in three groups (`TextHarvest`): "Kartlarda var"
/// (meaning and state; a tap opens the word page), "Kendi kelimelerin", and "Yeni kelimeler" (a tap
/// opens "Kelime ekle" with the word filled in; the Turkish meaning is the user's, so nothing is
/// added without it). "Bildiklerimi gizle" hides the known words. Calm: no score, no counts to
/// beat (ogrenme_ilkeleri 11, 12). The text and the photo stay on the phone; nothing is stored.
///
/// A page: push it on a NavigationStack (Sözlük, Ayarlar), or put it in one inside a sheet (a
/// shortcut, ShortcutRouter.swift). Its one main button stays above the keyboard.
struct TextHarvestView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var text: String
    /// The words of the text as it was when "Kelimeleri bul" was tapped; nil before, and again
    /// once the text changes.
    @State private var result: TextHarvest.Result?
    @AppStorage("lockglow.textHarvest.hidesKnown") private var hidesKnown = false
    /// "Kelime ekle" for a new word.
    @State private var editor: CustomWordEditor.Mode?
    /// A card or a user's word opened from the list.
    @State private var openedWord: WidgetWord?
    @State private var showsScanner = false
    @State private var photoItem: PhotosPickerItem?
    @State private var readsPhoto = false
    /// A line under the sources: a photo without text, the camera permission, a text cut short.
    @State private var sourceNote: String?
    /// Counts the added words, for the success tap.
    @State private var addedCount = 0
    @FocusState private var isEditing: Bool
    @ScaledMetric(relativeTo: .body) private var editorHeight: CGFloat = 150

    private static let resultsAnchor = "textHarvest.results"

    init(text: String = "") {
        _text = State(initialValue: text)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    input
                    if let result = result {
                        results(result)
                            .id(TextHarvestView.resultsAnchor)
                    }
                    Label("Metin ve fotoğraf telefondan çıkmaz.", systemImage: "lock")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                // The HIG side margin.
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Theme.bg
                    .ignoresSafeArea()
            }
            // As "Kelimeyi ekle" in the add form: the main button stays above the keyboard.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                findBar(proxy: proxy)
            }
        }
        // Inline: "Metinden kelime bul" as a large title does not fit an iPhone SE's width.
        .navigationTitle("Metinden kelime bul")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $openedWord) { word in
            WordDetailView(word: word)
        }
        .sheet(item: $editor) { mode in
            CustomWordEditor(library: model.customWordLibrary, mode: mode, cardMeaning: model.lookup(lemma:)) { outcome in
                finished(outcome)
            }
            // A sheet starts its own hierarchy: its controls stay ink (README rule 2).
            .tint(Theme.ink)
        }
        .fullScreenCover(isPresented: $showsScanner) {
            TextScannerSheet { scanned in
                append(scanned)
            }
        }
        .sensoryFeedback(.success, trigger: addedCount)
        .onChange(of: text) { _, _ in
            // The list belongs to the text it was found in.
            if result != nil {
                result = nil
            }
        }
        .onChange(of: photoItem) { _, item in
            guard let item = item else {
                return
            }
            Task {
                await readPhoto(item)
            }
        }
    }

    private var trimmedText: String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: Input

    private var input: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Okuduğun İngilizce bir metni buraya yapıştır. Kartlarda olan kelimeleri ve yeni kelimeleri ayrı ayrı gösteririz.")
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
            editorBox
            sources
            if let note = sourceNote {
                Label(note, systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// The text field: English text in the serif face, an ASCII keyboard, no autocorrection (it
    /// would "fix" the very words the user does not know yet).
    private var editorBox: some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous)
        let height = min(editorHeight, 260)
        return ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Theme.ink)
                .scrollContentBackground(.hidden)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled()
                .focused($isEditing)
                .frame(minHeight: height, maxHeight: height * 1.6)
                .accessibilityLabel("İngilizce metin")
                .accessibilityIdentifier("textHarvest.text")
            if text.isEmpty {
                // TextEditor has no prompt: this one sits where its first line starts.
                Text("Metni buraya yapıştır ya da yaz")
                    .font(.body)
                    .foregroundStyle(Theme.ink3)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .padding(8)
        .background(Theme.surface, in: shape)
        .overlay(shape.strokeBorder(isEditing ? Theme.lineStrong : Theme.line, lineWidth: 1))
    }

    /// Where the text can come from besides the keyboard, all as chips. "Yapıştır" reads the
    /// clipboard (iOS asks once whether Lockglow may paste; the system PasteButton would not ask,
    /// but it draws an ink capsule that is white on white in dark mode and ignores the chip
    /// style). The camera only where the phone can read text live.
    private var sources: some View {
        DictionaryFlowLayout(itemSpacing: 8, lineSpacing: 0) {
            Button {
                paste()
            } label: {
                Label("Yapıştır", systemImage: "doc.on.clipboard")
            }
            .buttonStyle(ChipButtonStyle())
            .accessibilityIdentifier("textHarvest.paste")
            if TextScannerSheet.canScan {
                Button {
                    openScanner()
                } label: {
                    Label("Kamerayla tara", systemImage: "camera.viewfinder")
                }
                .buttonStyle(ChipButtonStyle())
            }
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label(readsPhoto ? "Fotoğraf okunuyor" : "Fotoğraftan al", systemImage: "photo")
            }
            .buttonStyle(ChipButtonStyle())
            .disabled(readsPhoto)
            if !text.isEmpty {
                Button {
                    text = ""
                    sourceNote = nil
                    isEditing = true
                } label: {
                    Label("Temizle", systemImage: "xmark.circle")
                }
                .buttonStyle(ChipButtonStyle())
            }
        }
    }

    private func findBar(proxy: ScrollViewProxy) -> some View {
        Button("Kelimeleri bul") {
            find(scrollingWith: proxy)
        }
        .buttonStyle(GlowButtonStyle())
        .disabled(trimmedText.isEmpty)
        .accessibilityIdentifier("textHarvest.find")
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
    }

    // MARK: Results

    @ViewBuilder
    private func results(_ result: TextHarvest.Result) -> some View {
        if result.readNoWords {
            WordListEmptyState(
                systemImage: "text.magnifyingglass",
                title: "İngilizce kelime yok",
                message: AttributedString("Bu metinde İngilizce bir kelime bulamadık. Başka bir metin dene.")
            )
            .accessibilityIdentifier("textHarvest.nothing")
        } else if result.isEmpty {
            WordListEmptyState(
                systemImage: "text.magnifyingglass",
                title: "Gösterecek kelime yok",
                message: AttributedString("Metinde yalnız \"the\", \"and\" gibi küçük kelimeler ve kişi ya da yer adları var. Daha uzun bir metin dene.")
            )
            .accessibilityIdentifier("textHarvest.nothing")
        } else {
            VStack(alignment: .leading, spacing: 24) {
                if result.wasCut {
                    Label("Metin uzun; yalnız ilk bölümüne baktık.", systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if (result.cards + result.ownWords).contains(where: { $0.state == .known }) {
                    SettingsGroup {
                        Toggle(isOn: $hidesKnown) {
                            Text("Bildiklerimi gizle")
                                .settingsRowTitle()
                        }
                        // A switch is on in `good` green, as in iOS (never yellow, never ink).
                        .tint(Theme.good)
                        .settingsRowPadding()
                        .accessibilityIdentifier("textHarvest.hideKnown")
                    }
                }
                if !result.cards.isEmpty {
                    matchSection(
                        title: "Kartlarda var",
                        identifier: "textHarvest.cards",
                        footnote: "Kelimeye dokununca sayfası açılır.",
                        matches: result.cards
                    )
                }
                if !result.ownWords.isEmpty {
                    matchSection(
                        title: "Kendi kelimelerin",
                        identifier: "textHarvest.own",
                        footnote: nil,
                        matches: result.ownWords
                    )
                }
                if !result.newWords.isEmpty {
                    newSection(result.newWords)
                }
            }
        }
    }

    /// Cards or the user's words: Sözlük's rows (meaning, state), with how the text wrote the word
    /// when that differs ("Metinde: went"). The known ones leave while "Bildiklerimi gizle" is on.
    private func matchSection(title: String, identifier: String, footnote: String?, matches: [TextHarvest.Match]) -> some View {
        let shown = hidesKnown ? matches.filter { $0.state != .known } : matches
        let hidden = matches.count - shown.count
        return TextHarvestSection(title: title, count: shown.count, identifier: identifier, footnote: footnote) {
            if !shown.isEmpty {
                SozlukRowGroup {
                    ForEach(Array(shown.enumerated()), id: \.element.word.id) { index, match in
                        if index > 0 {
                            DictionaryRule()
                                .padding(.leading, 16)
                        }
                        SozlukWordLink(word: match.word, note: writtenNote(match), open: { word in
                            openedWord = word
                        })
                    }
                }
            }
            if hidden > 0 {
                Text(verbatim: "Bildiğin \(hidden) kelime gizli.")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
            }
        }
    }

    private func writtenNote(_ match: TextHarvest.Match) -> AttributedString? {
        guard let written = match.textForm else {
            return nil
        }
        return AttributedString("Metinde: " + written)
    }

    private func newSection(_ words: [String]) -> some View {
        TextHarvestSection(
            title: "Yeni kelimeler",
            count: words.count,
            identifier: "textHarvest.new",
            footnote: "Eklemek istediğine dokun ve Türkçe anlamını yaz. Sonra widget'ta ve Tekrar'da karşına çıkar."
        ) {
            SozlukRowGroup {
                ForEach(Array(words.enumerated()), id: \.element) { index, lemma in
                    if index > 0 {
                        DictionaryRule()
                            .padding(.leading, 16)
                    }
                    TextHarvestNewWordRow(lemma: lemma) {
                        editor = .add(lemma: lemma)
                    }
                }
            }
        }
    }

    // MARK: Actions

    private func find(scrollingWith proxy: ScrollViewProxy) {
        isEditing = false
        let found = model.harvestWords(in: text)
        result = found
        announce(found)
        // After the keyboard has gone down: the list starts at the top of the screen.
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                proxy.scrollTo(TextHarvestView.resultsAnchor, anchor: .top)
            }
        }
    }

    /// VoiceOver hears what was found, in plain counts (no score).
    private func announce(_ found: TextHarvest.Result) {
        guard UIAccessibility.isVoiceOverRunning else {
            return
        }
        let line = found.isEmpty
            ? "Gösterecek kelime yok"
            : "Kartlarda \(found.cards.count), kendi kelimelerinde \(found.ownWords.count), yeni \(found.newWords.count) kelime"
        SozlukSpeech.announce([.turkish(line)])
    }

    /// A word was added from "Yeni kelimeler": it moves to "Kendi kelimelerin" at once.
    private func finished(_ outcome: CustomWordEditor.Outcome) {
        guard case let .added(word) = outcome else {
            return
        }
        addedCount += 1
        SozlukSpeech.announce([.english(word.lemma), .turkish(" eklendi. Widget'ta ve Tekrar'da karşına çıkacak.")])
        if result != nil {
            result = model.harvestWords(in: text)
        }
    }

    /// Text from the paste button, the camera or a photo: after what is already in the field (on
    /// a new paragraph), or in the empty field. The field keeps at most what "Kelimeleri bul"
    /// reads (`TextHarvest.inputLimit`).
    private func append(_ incoming: String) {
        let addition = incoming.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !addition.isEmpty else {
            return
        }
        let current = trimmedText
        let combined = current.isEmpty ? addition : current + "\n\n" + addition
        if combined.count > TextHarvest.inputLimit {
            text = String(combined.prefix(TextHarvest.inputLimit))
            sourceNote = "Metin uzundu; ilk bölümü alındı."
        } else {
            text = combined
            sourceNote = nil
        }
    }

    /// "Yapıştır": the clipboard's text, or a line saying there is none.
    private func paste() {
        guard let pasted = UIPasteboard.general.string,
              !pasted.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            sourceNote = "Panoda metin yok. Önce bir metni kopyala."
            return
        }
        append(pasted)
    }

    private func openScanner() {
        sourceNote = nil
        Task { @MainActor in
            if await TextScannerSheet.requestCamera() {
                showsScanner = true
            } else {
                sourceNote = "Kamera izni kapalı. Ayarlar > Lockglow > Kamera'dan açabilirsin."
            }
        }
    }

    /// "Fotoğraftan al": the chosen photo's text, read on the phone (`TextPhotoReader`).
    private func readPhoto(_ item: PhotosPickerItem) async {
        readsPhoto = true
        sourceNote = nil
        defer {
            readsPhoto = false
            photoItem = nil
        }
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            sourceNote = "Fotoğraf açılamadı. Başka bir fotoğraf dene."
            return
        }
        let lines = await Task.detached(priority: .userInitiated) {
            TextPhotoReader.lines(in: data)
        }.value
        let found = TextHarvest.joiningLines(lines)
        if found.isEmpty {
            sourceNote = "Bu fotoğrafta okunacak yazı bulamadık."
        } else {
            append(found)
        }
    }
}

// MARK: - Parts

/// A group of the results: a bold title with its count (a heading for VoiceOver), an optional
/// footnote, then the rows.
private struct TextHarvestSection<Rows: View>: View {
    let title: String
    let count: Int
    let identifier: String
    let footnote: String?
    @ViewBuilder let rows: () -> Rows

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(verbatim: "\(count)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.ink2)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(identifier)
            if let footnote = footnote {
                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            rows()
        }
    }
}

/// A new word: the English word in Sözlük's row style and a plus; a tap opens "Kelime ekle" with
/// it. VoiceOver reads the word in an English voice and the hint in Turkish.
private struct TextHarvestNewWordRow: View {
    let lemma: String
    let add: () -> Void

    var body: some View {
        Button(action: add) {
            HStack(spacing: 10) {
                Text(verbatim: lemma)
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundStyle(Theme.ink2)
                    .accessibilityHidden(true)
            }
            .padding(.leading, 16)
            .padding(.trailing, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(SozlukRowButtonStyle())
        .accessibilityLabel(SozlukSpeech.label([.english(lemma)]))
        .accessibilityHint("Türkçe anlamıyla kendi kelimelerine eklemek için formu açar.")
        .accessibilityIdentifier("textHarvest.new.\(lemma)")
    }
}

/// The way in from Sözlük's start page: one row in Sözlük's rounded group, with a line that says
/// what it does.
struct TextHarvestEntryRow: View {
    let open: () -> Void

    var body: some View {
        SozlukRowGroup {
            Button(action: open) {
                HStack(spacing: 12) {
                    Image(systemName: "text.viewfinder")
                        .font(.title3)
                        .foregroundStyle(Theme.ink)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Metinden kelime bul")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text("Okuduğun İngilizce metni yapıştır; kartlarda olan ve yeni kelimeleri gör.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink3)
                        .accessibilityHidden(true)
                }
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
                .frame(minHeight: 60)
                .contentShape(Rectangle())
            }
            .buttonStyle(SozlukRowButtonStyle())
            .accessibilityIdentifier("sozluk.textHarvest")
        }
    }
}

/// Sözlük's stack value for "Metinden kelime bul" (SearchView).
struct TextHarvestPage: Hashable {}
