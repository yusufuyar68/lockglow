import SwiftUI
import UIKit
import CoreModels
import Learning

/// "Kendi kelimelerin": the words the user added, the newest first, and the screen's one main
/// action, "Kelime ekle". A word opens its form (`CustomWordEditor`) to fix or delete it; a
/// swipe deletes it too, with "Vazgeç" in a short notice at the bottom.
///
/// Works on a `CustomWordLibrary` passed in, not on `AppModel`; push it inside a
/// NavigationStack (Ayarlar). Wiring: docs/ozellik_planlari/kendi_kelime.md.
struct CustomWordsView: View {
    @ObservedObject var library: CustomWordLibrary
    /// The Turkish meaning of a card with this headword (`AppModel.lookup(lemma:)`), so the form
    /// can say the word is already in the cards. Nil: no such line.
    var cardMeaning: (@MainActor (String) -> String?)? = nil

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var editor: CustomWordEditor.Mode?
    @State private var notice: CustomWordsNotice?
    /// Counts added words, for the success tap.
    @State private var addedCount = 0

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                Theme.bg
                    .ignoresSafeArea()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomBar
            }
            .navigationTitle("Kendi kelimelerin")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $editor) { mode in
                CustomWordEditor(library: library, mode: mode, cardMeaning: cardMeaning) { outcome in
                    finished(outcome)
                }
            }
            .sensoryFeedback(.success, trigger: addedCount)
            .onAppear {
                _ = library.load()
            }
            .task(id: notice?.id) {
                await hideNoticeLater()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch library.status {
        case .notLoaded:
            Color.clear
        case .unavailable:
            ScrollView {
                CustomWordsMessage(
                    systemImage: "exclamationmark.triangle",
                    iconColor: Theme.caution,
                    title: "Kelimelerin şu an açılamadı",
                    message: "Eklediğin kelimeler silinmedi. Telefonun kilidi açıkken yeniden dene."
                ) {
                    Button("Yeniden dene") {
                        _ = library.load()
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle())
                }
                // The HIG side margin, as the empty list below.
                .padding(.horizontal, 16)
            }
        case .ready:
            if library.words.isEmpty {
                ScrollView {
                    VStack(spacing: 16) {
                        recoveryBanner
                        CustomWordsMessage(
                            systemImage: "text.badge.plus",
                            iconColor: Theme.ink2,
                            title: "Duyduğun kelimeyi ekle",
                            message: "Gün içinde duyduğun bir İngilizce kelimeyi ve Türkçe anlamını yaz. Kelime, kartlar gibi widget'ta ve Tekrar'da karşına çıkar."
                        ) {
                            Button("İlk kelimeni ekle") {
                                editor = .add(lemma: "")
                            }
                            .buttonStyle(GlowButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                list
            }
        }
    }

    private var list: some View {
        List {
            if library.recovery != nil {
                Section {
                    recoveryBanner
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            Section {
                ForEach(library.newestFirst) { word in
                    CustomWordRow(word: word) {
                        editor = .edit(word)
                    }
                    .listRowBackground(Theme.surface)
                    .listRowSeparatorTint(Theme.line)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            delete(word)
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                        .tint(swipeTint)
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: "\(library.words.count) kelime")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text("Bu kelimeler widget'ta ve Tekrar'da da karşına çıkar. Düzeltmek için kelimeye dokun.")
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

    /// The swipe action's fill under its white title: `bad` by day; at night, when `bad` is a
    /// light red, a dark gray (the icon and "Sil" say what it does).
    private var swipeTint: Color {
        return colorScheme == .dark ? Theme.surface3 : Theme.bad
    }

    @ViewBuilder
    private var recoveryBanner: some View {
        if let outcome = library.recovery {
            CustomWordsRecoveryBanner(outcome: outcome) {
                library.dismissRecovery()
            }
        }
    }

    /// The notice (after a change), then the main button once there is a list. Nothing when
    /// neither shows, so the list keeps its full height.
    @ViewBuilder
    private var bottomBar: some View {
        let showsAdd = library.status == .ready && !library.words.isEmpty
        if showsAdd || notice != nil {
            VStack(spacing: 10) {
                if let notice = notice {
                    CustomWordsNoticeBar(notice: notice) {
                        if let word = notice.undo {
                            undoDelete(word)
                        }
                    }
                    // Comes in from above and leaves upward, so it never slides under "Kelime
                    // ekle" (a move from the bottom did, half under the button and, at night,
                    // seen through its tinted fill; 15d screenshots, 2026-10-24). Drawn over the
                    // button in case the two still touch while the bar changes height.
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                }
                if showsAdd {
                    Button("Kelime ekle") {
                        editor = .add(lemma: "")
                    }
                    .buttonStyle(GlowButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background {
                if showsAdd {
                    Theme.bg
                        .ignoresSafeArea()
                }
            }
        }
    }

    // MARK: Actions

    private func finished(_ outcome: CustomWordEditor.Outcome) {
        switch outcome {
        case let .added(word):
            addedCount += 1
            show(CustomWordsNotice(lemma: word.lemma, text: " eklendi. Widget'ta ve Tekrar'da karşına çıkacak."))
        case let .updated(word):
            show(CustomWordsNotice(lemma: word.lemma, text: " kaydedildi."))
        case let .removed(word):
            show(CustomWordsNotice(lemma: word.lemma, text: " silindi.", undo: word))
        }
    }

    private func delete(_ word: CustomWord) {
        do {
            let removed = try withAnimation(reduceMotion ? nil : .default) {
                try library.remove(id: word.id)
            }
            if let removed = removed {
                show(CustomWordsNotice(lemma: removed.lemma, text: " silindi.", undo: removed))
            }
        } catch {
            show(CustomWordsNotice(text: "Silinemedi. Biraz sonra yeniden dene."))
        }
    }

    /// "Vazgeç": the word comes back with its id, so its progress is kept.
    private func undoDelete(_ word: CustomWord) {
        do {
            try withAnimation(reduceMotion ? nil : .default) {
                try library.restore(word)
                notice = nil
            }
            SozlukSpeech.announce([.english(word.lemma), .turkish(" geri geldi.")])
        } catch CustomWordList.ChangeError.invalid(_) {
            // The same word was added again in the meantime.
            show(CustomWordsNotice(lemma: word.lemma, text: " listede zaten var. Silinen kelime geri gelmedi."))
        } catch {
            show(CustomWordsNotice(text: "Geri alınamadı. Biraz sonra yeniden dene."))
        }
    }

    /// Queued after what VoiceOver is saying (the closing sheet, the swipe action), the word in
    /// an English voice.
    private func show(_ next: CustomWordsNotice) {
        withAnimation(reduceMotion ? nil : .default) {
            notice = next
        }
        SozlukSpeech.announce(next.runs)
    }

    /// The notice leaves on its own after a few seconds; with VoiceOver it stays longer, so
    /// "Vazgeç" can still be reached.
    private func hideNoticeLater() async {
        guard notice != nil else {
            return
        }
        let seconds = UIAccessibility.isVoiceOverRunning ? 10 : 4
        try? await Task.sleep(for: .seconds(seconds))
        guard !Task.isCancelled else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            notice = nil
        }
    }
}

// MARK: - Form

/// The add and edit form, in a sheet with its own NavigationStack: the English word, its Turkish
/// meaning, and optionally an example and a note. The one main button is "Kelimeyi ekle" /
/// "Kaydet" at the bottom; problems show under their field (wrong letters and lengths while
/// typing, empty fields after the button). Can also be presented on its own, for example from a
/// Sözlük search with no result: `CustomWordEditor(library:mode: .add(lemma: query))`.
struct CustomWordEditor: View {
    enum Mode: Identifiable, Equatable {
        /// A new word; `lemma` fills the word field.
        case add(lemma: String)
        case edit(CustomWord)

        var id: String {
            switch self {
            case .add:
                return "add"
            case let .edit(word):
                return "edit-\(word.id)"
            }
        }
    }

    enum Outcome {
        case added(CustomWord)
        case updated(CustomWord)
        case removed(CustomWord)
    }

    @ObservedObject private var library: CustomWordLibrary
    private let mode: Mode
    private let cardMeaning: (@MainActor (String) -> String?)?
    private let onFinish: (Outcome) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: CustomWordDraft
    /// "Kaydet" was tapped once: empty required fields are shown as problems from now on.
    @State private var triedToSave = false
    @State private var confirmsDelete = false
    @State private var failure: String?
    @FocusState private var focus: CustomWordField?

    init(
        library: CustomWordLibrary,
        mode: Mode,
        cardMeaning: (@MainActor (String) -> String?)? = nil,
        onFinish: @escaping (Outcome) -> Void = { _ in }
    ) {
        _library = ObservedObject(wrappedValue: library)
        self.mode = mode
        self.cardMeaning = cardMeaning
        self.onFinish = onFinish
        _draft = State(initialValue: CustomWordEditor.initialDraft(for: mode))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    lemmaField
                    meaningField
                    exampleField
                    noteField
                    if editedWord != nil {
                        deleteButton
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Theme.bg
                    .ignoresSafeArea()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveBar
            }
            .navigationTitle(editedWord == nil ? "Kelime ekle" : "Kelimeyi düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Bu kelime silinsin mi?", isPresented: $confirmsDelete, titleVisibility: .visible) {
                Button("Sil", role: .destructive) {
                    delete()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Kelime widget'tan ve Tekrar'dan çıkar.")
            }
            .alert("Olmadı", isPresented: showsFailure) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(verbatim: failure ?? "")
            }
        }
        // A half-typed word is not lost by a swipe down; "Vazgeç" still closes the form.
        .interactiveDismissDisabled(draft != CustomWordEditor.initialDraft(for: mode))
        .task {
            await focusFirstField()
        }
    }

    // MARK: Fields

    private var lemmaField: some View {
        CustomWordFieldBox(
            title: "İngilizce kelime",
            count: draft.normalizedLemma.count,
            limit: CustomWordDraft.lemmaLimit,
            showsCount: true,
            problem: problem(for: .lemma)
        ) {
            // English only in the serif field's prompt: a Turkish "örneğin:" would be set in serif.
            TextField("İngilizce kelime", text: $draft.lemma, prompt: Text(verbatim: "awkward").foregroundStyle(Theme.ink3))
                .font(.system(.title3, design: .serif).weight(.semibold))
                .foregroundStyle(Theme.ink)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .submitLabel(.next)
                .focused($focus, equals: .lemma)
                .onSubmit {
                    focus = .meaning
                }
                .accessibilityLabel("İngilizce kelime")
                .accessibilityHint(Text(verbatim: problem(for: .lemma)?.message ?? "Yalnızca İngilizce harfler, boşluk, tire ve kesme işareti."))
                // The UI test finds the field by this (the 22 Oct run found none by its label).
                .accessibilityIdentifier("customWord.lemma")
        } footer: {
            if problem(for: .lemma) == nil, let meaning = existingCardMeaning {
                Label {
                    // "Yine de ekleyebilirsin" only while adding: an edited word is already added.
                    Text(verbatim: editedWord == nil
                        ? "Bu kelime kartlarda zaten var: \(meaning). Yine de ekleyebilirsin."
                        : "Bu kelime kartlarda da var: \(meaning).")
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "info.circle")
                }
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
            }
        }
    }

    private var meaningField: some View {
        CustomWordFieldBox(
            title: "Türkçe anlamı",
            count: draft.normalizedMeaning.count,
            limit: CustomWordDraft.meaningLimit,
            showsCount: true,
            problem: problem(for: .meaning)
        ) {
            TextField("Türkçe anlamı", text: $draft.meaningTR, prompt: Text("örneğin: garip, tuhaf").foregroundStyle(Theme.ink3))
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .textInputAutocapitalization(.never)
                .submitLabel(.next)
                .focused($focus, equals: .meaning)
                .onSubmit {
                    focus = .example
                }
                .accessibilityLabel("Türkçe anlamı")
                .accessibilityHint(Text(verbatim: problem(for: .meaning)?.message ?? ""))
                .accessibilityIdentifier("customWord.meaning")
        }
    }

    private var exampleField: some View {
        let count = draft.normalizedExample?.count ?? 0
        return CustomWordFieldBox(
            title: "Örnek cümle",
            isOptional: true,
            count: count,
            limit: CustomWordDraft.exampleLimit,
            showsCount: count > CustomWordDraft.exampleLimit - 20,
            problem: problem(for: .example)
        ) {
            TextField(
                "Örnek cümle",
                text: $draft.exampleEN,
                // English only, like the word field: this field is serif too (Theme.Fonts.example).
                prompt: Text(verbatim: "That was awkward.").foregroundStyle(Theme.ink3),
                axis: .vertical
            )
            .font(Theme.Fonts.example)
            .foregroundStyle(Theme.ink)
            .lineLimit(2...5)
            .textInputAutocapitalization(.sentences)
            .autocorrectionDisabled()
            .keyboardType(.asciiCapable)
            .focused($focus, equals: .example)
            .accessibilityLabel("Örnek cümle")
            .accessibilityHint(Text(verbatim: problem(for: .example)?.message ?? "İngilizce bir cümle. İstersen boş bırak."))
            .accessibilityIdentifier("customWord.example")
        }
    }

    private var noteField: some View {
        let count = draft.normalizedNote?.count ?? 0
        return CustomWordFieldBox(
            title: "Not",
            isOptional: true,
            count: count,
            limit: CustomWordDraft.noteLimit,
            showsCount: count > CustomWordDraft.noteLimit - 30,
            problem: problem(for: .note)
        ) {
            TextField(
                "Not",
                text: $draft.note,
                prompt: Text("Nerede duydun? Örneğin: dizide").foregroundStyle(Theme.ink3),
                axis: .vertical
            )
            .font(.body)
            .foregroundStyle(Theme.ink)
            .lineLimit(2...6)
            .focused($focus, equals: .note)
            .accessibilityLabel("Not")
            .accessibilityHint(Text(verbatim: problem(for: .note)?.message ?? "İstersen boş bırak."))
            .accessibilityIdentifier("customWord.note")
        }
    }

    /// Mockup rule for the one dangerous action: a calm bordered capsule with `bad` text and an
    /// icon, never a filled red button. It only opens the confirmation.
    private var deleteButton: some View {
        Button {
            confirmsDelete = true
        } label: {
            Label("Kelimeyi sil", systemImage: "trash")
                .foregroundStyle(Theme.bad)
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
        .padding(.top, 6)
    }

    private var saveBar: some View {
        Button(editedWord == nil ? "Kelimeyi ekle" : "Kaydet") {
            save()
        }
        .buttonStyle(GlowButtonStyle())
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
    }

    // MARK: State

    private var editedWord: CustomWord? {
        if case let .edit(word) = mode {
            return word
        }
        return nil
    }

    private static func initialDraft(for mode: Mode) -> CustomWordDraft {
        switch mode {
        case let .add(lemma):
            return CustomWordDraft(lemma: lemma)
        case let .edit(word):
            return CustomWordDraft(word)
        }
    }

    /// Problems of the current text. Empty required fields count only after "Kaydet".
    private var visibleProblems: [CustomWordProblem] {
        let all = library.problems(for: draft, editing: editedWord?.id)
        return triedToSave ? all : all.filter { !$0.isMissingField }
    }

    private func problem(for field: CustomWordField) -> CustomWordProblem? {
        return visibleProblems.first { $0.field == field }
    }

    /// The meaning of the card with the same headword, while the word field is valid.
    private var existingCardMeaning: String? {
        let lemma = draft.normalizedLemma
        guard let cardMeaning = cardMeaning, CustomWordText.isSpeakable(lemma) else {
            return nil
        }
        return cardMeaning(lemma)
    }

    private var showsFailure: Binding<Bool> {
        return Binding(
            get: { failure != nil },
            set: { isShown in
                if !isShown {
                    failure = nil
                }
            }
        )
    }

    // MARK: Actions

    /// A new word starts in the word field (after the sheet has appeared, or the keyboard may
    /// not come up); an edited one waits for a tap.
    private func focusFirstField() async {
        guard editedWord == nil else {
            return
        }
        try? await Task.sleep(for: .milliseconds(450))
        guard !Task.isCancelled else {
            return
        }
        focus = draft.lemma.isEmpty ? .lemma : .meaning
    }

    private func save() {
        triedToSave = true
        let problems = library.problems(for: draft, editing: editedWord?.id)
        if let first = problems.first {
            focus = first.field
            SozlukSpeech.announce([.turkish(first.message)])
            return
        }
        do {
            if let word = editedWord {
                let updated = try library.update(id: word.id, with: draft)
                onFinish(.updated(updated))
            } else {
                let added = try library.add(draft)
                onFinish(.added(added))
            }
            dismiss()
        } catch let CustomWordList.ChangeError.invalid(found) {
            focus = found.first?.field
            if let first = found.first {
                SozlukSpeech.announce([.turkish(first.message)])
            }
        } catch {
            failure = "Kelimen kaydedilemedi. Biraz sonra yeniden dene."
        }
    }

    private func delete() {
        guard let word = editedWord else {
            return
        }
        do {
            if let removed = try library.remove(id: word.id) {
                onFinish(.removed(removed))
            }
            dismiss()
        } catch {
            failure = "Kelime silinemedi. Biraz sonra yeniden dene."
        }
    }
}

// MARK: - Parts

/// "Senin kelimen": on a word the user added, in the place of a card's part of speech and level,
/// which it does not have. It keeps the user's words apart from the checked cards
/// (docs/tasarim/ogrenme_ilkeleri.md 2.6). Used on the "Tekrar", "Akış" and dictionary cards.
struct CustomWordTag: View {
    /// Subheadline, the small size of "İlerleme" and its word sheet; a line set in Callout (the
    /// Sözlük page's facts, the Tanış and Akış cards) can pass `.callout`, as `LevelBadge`.
    var textStyle: Font.TextStyle = .subheadline

    var body: some View {
        Label("Senin kelimen", systemImage: "person.fill")
            .labelStyle(.titleAndIcon)
            .font(.system(textStyle, design: .default).weight(.medium))
            .foregroundStyle(Theme.ink2)
            // One line where it fits; at the largest text sizes on a narrow phone it wraps
            // instead of running off the card.
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// One form field: its title (with "isteğe bağlı" and a character count), the text field in a
/// `surface` box with a `lineStrong` border, then its problem (`bad` border, icon and sentence;
/// rule 4: never color alone) or an optional footer line.
private struct CustomWordFieldBox<Field: View, Footer: View>: View {
    let title: String
    var isOptional = false
    let count: Int
    let limit: Int
    let showsCount: Bool
    let problem: CustomWordProblem?
    @ViewBuilder let field: () -> Field
    @ViewBuilder let footer: () -> Footer
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        title: String,
        isOptional: Bool = false,
        count: Int,
        limit: Int,
        showsCount: Bool,
        problem: CustomWordProblem?,
        @ViewBuilder field: @escaping () -> Field,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = title
        self.isOptional = isOptional
        self.count = count
        self.limit = limit
        self.showsCount = showsCount
        self.problem = problem
        self.field = field
        self.footer = footer
    }

    var body: some View {
        // At accessibility text sizes the title, "isteğe bağlı" and the count go under each other.
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let layout = isLarge
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 2))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 8))
        VStack(alignment: .leading, spacing: 8) {
            layout {
                Text(verbatim: title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if isOptional {
                    Text("isteğe bağlı")
                        .font(.footnote)
                        .foregroundStyle(Theme.ink3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !isLarge {
                    Spacer(minLength: 8)
                }
                if showsCount {
                    Text(verbatim: "\(count)/\(limit)")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(count > limit ? Theme.bad : Theme.ink3)
                }
            }
            // The text field carries its own label for VoiceOver.
            .accessibilityHidden(true)
            field()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .background(Theme.surface, in: boxShape)
                .overlay(
                    boxShape
                        .strokeBorder(problem == nil ? Theme.lineStrong : Theme.bad, lineWidth: problem == nil ? 1.5 : 2)
                )
            if let problem = problem {
                Label {
                    Text(verbatim: problem.message)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "exclamationmark.circle.fill")
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.bad)
                .accessibilityHidden(true)
            } else {
                footer()
            }
        }
    }

    private var boxShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
    }
}

extension CustomWordFieldBox where Footer == EmptyView {
    init(
        title: String,
        isOptional: Bool = false,
        count: Int,
        limit: Int,
        showsCount: Bool,
        problem: CustomWordProblem?,
        @ViewBuilder field: @escaping () -> Field
    ) {
        self.init(
            title: title,
            isOptional: isOptional,
            count: count,
            limit: limit,
            showsCount: showsCount,
            problem: problem,
            field: field,
            footer: { EmptyView() }
        )
    }
}

/// A row of the list: the serif word and its meaning; the whole row opens the form.
private struct CustomWordRow: View {
    let word: CustomWord
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: word.lemma)
                        .font(.system(.body, design: .serif).weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Text(verbatim: word.meaningTR)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.ink2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(CustomWordRowButtonStyle())
        // One label in two voices (as in "Bildiğin kelimeler"): an English locale inside the
        // button would read the meaning and the hint in the English voice too.
        .accessibilityLabel(SozlukSpeech.label([.english(word.lemma), .turkish(", Türkçesi: " + word.meaningTR)]))
        .accessibilityHint("Düzeltmek ya da silmek için açar")
    }
}

/// The row's press feedback: it dims, like a plain button.
private struct CustomWordRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

/// An icon, a title, a sentence and one button, centered: the empty list and the unreadable file.
private struct CustomWordsMessage<Action: View>: View {
    let systemImage: String
    let iconColor: Color
    let title: String
    let message: String
    @ViewBuilder let action: () -> Action

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)
            Text(verbatim: title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text(verbatim: message)
                .font(.body)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
            action()
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        // The caller keeps the 16 pt side margin.
        .padding(.vertical, 32)
    }
}

/// The file was damaged at load (as the progress banner in "Ayarlar"): until "Anladım".
private struct CustomWordsRecoveryBanner: View {
    let outcome: CustomWordStore.LoadOutcome
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(Theme.caution)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 10) {
                Text(verbatim: message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Anladım", action: dismiss)
                    .buttonStyle(SecondaryCapsuleButtonStyle(tonal: true))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
                .strokeBorder(Theme.caution, lineWidth: 1.5)
        )
    }

    /// Short sentences, "biz", no suffix after the date (in brackets), as
    /// `SystemCardSheet.recoveryMessage` (RootView).
    private var message: String {
        switch outcome {
        case let .restoredFromBackup(_, backupDate):
            if let date = backupDate {
                return "Kelime dosyan okunamadı. Yedekten geri yükledik (yedek: \(date.formatted(date: .long, time: .shortened))). Bu tarihten sonra eklediğin kelimeler kaybolmuş olabilir."
            }
            return "Kelime dosyan okunamadı. Yedekten geri yükledik. Son eklediğin kelimeler kaybolmuş olabilir."
        case .startedOver:
            return "Kelime dosyan okunamadı ve yedek yoktu; liste boş başladı. Eski dosyayı silmedik."
        case .fresh, .loaded:
            return ""
        }
    }
}

/// What the bottom notice says, and the deleted word "Vazgeç" brings back.
struct CustomWordsNotice: Equatable, Identifiable {
    let id = UUID()
    /// The English word the message starts with ("awkward silindi."), read in an English voice.
    var lemma: String? = nil
    /// The Turkish rest after `lemma`, or the whole message.
    let text: String
    var undo: CustomWord? = nil

    var message: String {
        return (lemma ?? "") + text
    }

    /// For VoiceOver: the word in English, the rest in Turkish.
    var runs: [SozlukSpeech.Run] {
        guard let lemma = lemma else {
            return [.turkish(text)]
        }
        return [.english(lemma), .turkish(text)]
    }
}

/// Mockup `.toast`: an ink bar with the result and, after a delete, "Vazgeç". At accessibility
/// text sizes "Vazgeç" goes under the message. Inverted tokens only, as the feed's notice: `bg`
/// text on `ink`; the button is a faint `bg` tint with a `bg` edge.
private struct CustomWordsNoticeBar: View {
    let notice: CustomWordsNotice
    let undo: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 8))
        layout {
            Text(verbatim: notice.message)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(SozlukSpeech.label(notice.runs))
            if notice.undo != nil {
                Button(action: undo) {
                    Text("Vazgeç")
                        .font(.subheadline.weight(.bold))
                        .padding(.horizontal, 16)
                        .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
                        .background(Theme.bg.opacity(0.18), in: Capsule())
                        .overlay(Capsule().strokeBorder(Theme.bg.opacity(0.6), lineWidth: 1))
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Silinen kelimeyi geri getirir")
            }
        }
        .foregroundStyle(Theme.bg)
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .frame(minHeight: 52)
        .background(Theme.ink, in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: Theme.shadowFar, radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .contain)
    }
}
