import SwiftUI
import UIKit
import CoreModels

// MARK: - Wide screens (iPad, Mac)

/// The iPad and Mac ("Designed for iPad") layout, decided by the window's width, never by the
/// device: an iPad window can be as narrow as an iPhone (Slide Over, Split View), and a Mac
/// window can be resized. An iPhone never reaches these rules: its screen is narrower than
/// `readableWidth`, and it is never in a regular-width size class in portrait.
///
/// - Every tab sits in a readable column, at most `readableWidth` wide and centered, with the
///   page's paper on both sides (`readableColumn()`).
/// - "Sözlük" shows its list and the chosen word side by side from `splitMinWidth` on
///   (`SozlukSplitLayout`).
/// - ⌘F opens Sözlük's search from any tab (`sozlukSearchShortcut`); in Tekrar, 1–4 answer and
///   Space is the card's main button (`AnswerKeys`).
enum WideLayout {
    /// The widest a screen's content grows: the cards, rows and buttons stay at a readable
    /// width in the middle of an iPad or Mac window.
    static let readableWidth: CGFloat = 600
    /// Sözlük splits from this width on: an iPad mini in portrait (744 pt) splits; Split View
    /// half and half on a 13" iPad (about 680 pt) keeps one column.
    static let splitMinWidth: CGFloat = 700

    /// The list column of the split Sözlük: about two fifths of the window, 320–400 pt (the word
    /// page keeps at least 380 pt).
    static func listWidth(in width: CGFloat) -> CGFloat {
        return min(400, max(320, (width * 0.38).rounded()))
    }

    /// A sheet, an alert or the onboarding is open in the key window. Shortcuts of the screens
    /// below it stay registered (the presented screen's next responder is the presenting one),
    /// so a shortcut that changes the tab asks this first.
    @MainActor
    static var isShowingPresentation: Bool {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        return windows.contains { window in
            window.isKeyWindow && window.rootViewController?.presentedViewController != nil
        }
    }
}

extension View {
    /// The screen at most `WideLayout.readableWidth` wide and centered; `background` fills the
    /// sides and the area under the bars, so the window reads as one page. No effect on an
    /// iPhone: its screen is narrower.
    func readableColumn(background: Color = Theme.bg) -> some View {
        frame(maxWidth: WideLayout.readableWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                background
                    .ignoresSafeArea()
            }
    }

    /// ⌘F anywhere in the tabs: `openSozluk` shows Sözlük, and its search field takes the
    /// keyboard (iOS 18 and later; on iOS 17 the tab opens). Holding ⌘ on an iPad lists it as
    /// "Sözlük'te ara". Nothing happens while a sheet is open.
    func sozlukSearchShortcut(openSozluk: @escaping () -> Void) -> some View {
        modifier(SozlukSearchShortcut(openSozluk: openSozluk))
    }

    /// Sözlük's search field takes the keyboard when ⌘F asked for it; `backToSearch` first
    /// closes what was pushed over the search (a topic, a word), where the field is. Comes right
    /// after `.searchable`.
    func sozlukSearchFocus(backToSearch: @escaping () -> Void) -> some View {
        modifier(SozlukSearchFocus(backToSearch: backToSearch))
    }
}

// MARK: - ⌘F

private struct SozlukSearchShortcut: ViewModifier {
    let openSozluk: () -> Void
    /// Set by ⌘F, taken (set back to false) by Sözlük's search field.
    @State private var searchRequested = false

    func body(content: Content) -> some View {
        content
            .environment(\.sozlukSearchRequest, $searchRequested)
            .background {
                // Invisible: only its shortcut is used. A sheet's own shortcuts come first, but
                // this one stays registered under a sheet, so it asks before changing the tab.
                Button("Sözlük'te ara") {
                    guard !WideLayout.isShowingPresentation else {
                        return
                    }
                    openSozluk()
                    searchRequested = true
                }
                .keyboardShortcut("f", modifiers: .command)
                .opacity(0)
                .accessibilityHidden(true)
            }
    }
}

private struct SozlukSearchFocus: ViewModifier {
    let backToSearch: () -> Void
    @Environment(\.sozlukSearchRequest) private var request
    @FocusState private var fieldFocused: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .searchFocused($fieldFocused)
                .onAppear {
                    takeRequest()
                }
                .onChange(of: request.wrappedValue) { _, _ in
                    takeRequest()
                }
        } else {
            // No way to focus the field: ⌘F opens the tab and its search page only.
            content
                .onAppear {
                    takeRequest()
                }
                .onChange(of: request.wrappedValue) { _, _ in
                    takeRequest()
                }
        }
    }

    private func takeRequest() {
        guard request.wrappedValue else {
            return
        }
        request.wrappedValue = false
        backToSearch()
        guard #available(iOS 18.0, *) else {
            return
        }
        // A moment later, and once more: on the first ⌘F the tab and its field are still being
        // built, and a page pushed over the search is still leaving.
        Task { @MainActor in
            for delay: UInt64 in [150_000_000, 450_000_000] {
                try? await Task.sleep(nanoseconds: delay)
                if !fieldFocused {
                    fieldFocused = true
                }
            }
        }
    }
}

private struct SozlukSearchRequestKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

private struct SozlukShowWordKey: EnvironmentKey {
    static let defaultValue: SozlukShowWord? = nil
}

extension EnvironmentValues {
    /// ⌘F asked for Sözlük's search field (`sozlukSearchShortcut`).
    fileprivate var sozlukSearchRequest: Binding<Bool> {
        get { self[SozlukSearchRequestKey.self] }
        set { self[SozlukSearchRequestKey.self] = newValue }
    }

    /// The split Sözlük shows a word in its right column; nil (iPhone, narrow window): Sözlük
    /// pushes the word on its own stack.
    var sozlukShowWord: SozlukShowWord? {
        get { self[SozlukShowWordKey.self] }
        set { self[SozlukShowWordKey.self] = newValue }
    }
}

// MARK: - Sözlük in two columns

/// Shows a word in the right column of the split Sözlük (`SearchView.open`).
struct SozlukShowWord {
    let show: (WidgetWord) -> Void

    func callAsFunction(_ word: WidgetWord) {
        show(word)
    }
}

/// "Sözlük" in a wide window: the search, its results and the topics on the left, the chosen
/// word's page on the right (`SearchView` hands the word over through `sozlukShowWord` instead
/// of pushing it; a topic still opens in the left column). In a narrow window (iPhone, Slide
/// Over, Split View half and half) the plain `SearchView` with its own stack, in a readable
/// column. The same `SearchView` stays in place when the window changes size, only its frame
/// and the environment change, so the search and the open topic are kept. The word on the
/// right is kept too and comes back when the window widens again.
struct SozlukSplitLayout: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var width: CGFloat = 0
    @State private var shownWord: WidgetWord?

    var body: some View {
        let split = sizeClass == .regular && width >= WideLayout.splitMinWidth
        HStack(spacing: 0) {
            SearchView()
                .frame(width: split ? WideLayout.listWidth(in: width) : nil)
                .frame(maxWidth: split ? nil : WideLayout.readableWidth)
                .environment(\.sozlukShowWord, split ? SozlukShowWord(show: { shownWord = $0 }) : nil)
            if split {
                Rectangle()
                    .fill(Theme.line)
                    .frame(width: 1)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
                SozlukWordColumn(word: shownWord)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .onGeometryChange(for: CGFloat.self) { geometry in
            geometry.size.width
        } action: { newWidth in
            width = newWidth
        }
    }
}

/// The right column of the split Sözlük: the chosen word's whole card (as pushed on iPhone), in
/// a readable column; before the first word a short note says where it will open.
private struct SozlukWordColumn: View {
    let word: WidgetWord?

    var body: some View {
        NavigationStack {
            Group {
                if let word = word {
                    WordDetailView(word: word)
                        // Each word starts at the top of its page.
                        .id(word.id)
                } else {
                    WordListEmptyState(
                        systemImage: "character.book.closed",
                        title: "Bir kelime seç",
                        message: WordListEmptyState.message(
                            "Soldan bir kelime ara ya da bir konuya göz at. Kelimeye dokununca kartı burada açılır."
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: WideLayout.readableWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Theme.bg
                    .ignoresSafeArea()
            }
        }
        // Rule 2: no blue link color in the column's bar.
        .tint(Theme.ink)
    }
}
