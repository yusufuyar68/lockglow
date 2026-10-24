import SwiftUI
import UIKit
import CoreModels
import Learning

/// Vertical paging feed: one full-page card per word of the user's deck (iOS 17 scroll APIs),
/// `FeedCardView` (FeedCardView.swift). At accessibility text sizes there are no pages: each card
/// is as tall as its content and scrolls with the feed, never on its own (README rule 5). No
/// counter, no page dots. A card moving off its page fades and settles back a little
/// (`FeedPageTransition`; only the fade with Reduce Motion). Once the day's new cards reach the
/// daily goal, the end-of-day card is the next page (`considerDayEnd`, `FeedDayEndView`).
struct FeedView: View {
    @EnvironmentObject private var model: AppModel
    /// One system card per opening (RootView): the end-of-day card asks it first.
    @EnvironmentObject private var systemCards: SystemCardQueue
    @Binding var scrolledWordID: Int?
    /// "Tekrar'a geç" on the end-of-day card. Nil: through the reminder route, which opens
    /// "Tekrar" when it asks for no word (`RootView.openReviewIfRequested`).
    var openReview: (() -> Void)? = nil
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The whole card, opened from a shortened card's "Örnek cümle" row.
    @State private var detailWord: WidgetWord? = nil
    /// "Yukarı kaydır" is retired for good once the user has moved through a few cards.
    @AppStorage("lockglow.feedHintSeen") private var feedHintSeen = false
    /// Card changes in this session, up to `hintCardChanges`.
    @State private var cardChanges = 0
    /// Which cards the user has met before (read once, a `StateObject` so not on every redraw).
    @StateObject private var encounters = FeedEncounterStore()
    /// "Tamam … Geri al" after "Biliyorum", while it is on screen.
    @State private var knownNotice: FeedKnownNotice?
    /// VoiceOver is on the notice's "Geri al": the notice stays.
    @AccessibilityFocusState private var noticeHasFocus: Bool
    /// The end-of-day card stands after this word (today, once claimed; `considerDayEnd`).
    @State private var dayEndAfterID: Int?
    /// The feed tab is on screen: only then may it take the opening's system card.
    @State private var isOnScreen = false

    /// After this many card changes the user knows how the feed moves.
    private static let hintCardChanges = 3
    /// Below a paged card, above the tab bar; the tab bar veil fades in over it.
    private static let pageBottomGap: CGFloat = 12
    /// Left and right of a card: the 16 pt side margin of the HIG, the same as the title's. The
    /// card's 20 pt inner margin keeps the text where it was (36 pt from the screen's edge).
    private static let pageSideGap: CGFloat = 16
    /// Above the title's row: the empty 44 pt row of a navigation bar and 8 pt more, so "Akış"
    /// stands where the large titles of "Tekrar", "Sözlük" and "Ayarlar" stand (their baseline is
    /// 90 pt below the safe area at the default text size, on SE and Pro alike) and does not jump
    /// when the tab changes.
    private static let titleTopGap: CGFloat = 52

    var body: some View {
        VStack(spacing: 0) {
            // Over the pager, whose cards draw past its top edge (`titleVeil`).
            header
                .zIndex(1)
            if model.feedWords.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                pager
            }
        }
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .overlay {
            tabBarVeil
        }
        .overlay(alignment: .bottom) {
            knownNoticeBar
        }
        .task(id: knownNotice?.token) {
            await hideKnownNoticeLater()
        }
        .onAppear {
            isOnScreen = true
            noteCurrentCard()
        }
        .onDisappear {
            isOnScreen = false
        }
        .onChange(of: model.feedWords.first?.id) {
            noteCurrentCard()
        }
        // A new opening was decided (RootView): a card waiting since the last one may come now.
        .onChange(of: systemCards.isDecided) { _, isDecided in
            if isDecided {
                openingDecided()
            }
        }
        // The end-of-day card went away under the user (a new day, "İlerlemeyi sıfırla", another
        // deck): the scroll position moves to a word, so the feed goes on noting cards.
        .onChange(of: showsDayEnd) { _, shows in
            if !shows && scrolledWordID == FeedItem.dayEndID {
                scrolledWordID = nextWordID(afterDayEnd: dayEndAfterID) ?? model.feedWords.first?.id
            }
        }
        .sheet(item: $detailWord) { word in
            NavigationStack {
                WordDetailView(word: word)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") {
                                detailWord = nil
                            }
                        }
                    }
            }
            // Rule 2: no blue link color on "Kapat" or the card's buttons.
            .tint(Theme.ink)
            .environmentObject(model)
        }
    }

    /// The tab's name as a large title (34 pt bold, HIG: tab roots have large titles), like the
    /// navigation titles of "Tekrar", "Sözlük" and "Ayarlar", and at the same height
    /// (`titleTopGap`). Not a navigation bar: a collapsing bar would change the page height while
    /// the feed pages. Up to xxxLarge the title fits the 52 pt row, so a paged card keeps its room
    /// (the card shortens itself on a short page); from the accessibility sizes on (no pages) it
    /// stops growing at AX1.
    private var header: some View {
        Text("Akış")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(Theme.ink)
            .accessibilityAddTraits(.isHeader)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, FeedView.titleTopGap)
            .background {
                titleVeil
            }
    }

    /// The pager does not clip its cards (`scrollClipDisabled`), so their light-mode shadow
    /// (cardSurface: 14 pt radius, 10 pt down) is not cut flat 4 pt above the card (finding
    /// tekrar-akis-3). Behind the title lies the page's paper instead, over the page above; its
    /// last `pageBottomGap` (where the card above stops) fades out down to the pager's top edge,
    /// so the shadows there end softly rather than at a hard line. Wider than the title for the
    /// iPad's readable column, where the card above's side shadow reaches past the column.
    private var titleVeil: some View {
        VStack(spacing: 0) {
            Theme.bg
            LinearGradient(colors: [Theme.bg, Theme.bg.opacity(0)], startPoint: .top, endPoint: .bottom)
                .frame(height: FeedView.pageBottomGap)
        }
        .padding(.horizontal, -48)
        .ignoresSafeArea(edges: .top)
        .accessibilityHidden(true)
    }

    private var pager: some View {
        let isPaged = !dynamicTypeSize.isAccessibilitySize
        return ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    page(item, isPaged: isPaged)
                        .containerRelativeFrame(isPaged ? [.horizontal, .vertical] : [.horizontal])
                        .modifier(FeedPageTransition(isEnabled: isPaged, reduceMotion: reduceMotion))
                }
            }
            .scrollTargetLayout()
        }
        .modifier(FeedPagingModifier(isEnabled: isPaged))
        .scrollPosition(id: $scrolledWordID)
        .scrollIndicators(isPaged ? .hidden : .automatic)
        // The cards' shadow reaches past the page; `titleVeil` hides what is above the pager.
        .scrollClipDisabled()
        .onChange(of: scrolledWordID) { oldID, newID in
            noteCardChange(from: oldID, to: newID)
            noteCurrentCard()
        }
    }

    /// The glass tab bar floats over the feed, and the next card's top (its yellow band) would
    /// show through it. Under the bar lies the page's paper instead; its top edge fades over the
    /// gap below the card, so a card coming up appears softly rather than at a hard line.
    private var tabBarVeil: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                LinearGradient(colors: [Theme.bg.opacity(0), Theme.bg], startPoint: .top, endPoint: .bottom)
                    .frame(height: FeedView.pageBottomGap)
                Theme.bg
                    .frame(height: proxy.safeAreaInsets.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea(edges: .bottom)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// The deck's words, and the end-of-day card after `dayEndAfterID` while it is today's.
    private var items: [FeedItem] {
        var items = model.feedWords.map { FeedItem.word($0) }
        if showsDayEnd, let index = items.firstIndex(where: { $0.id == dayEndAfterID }) {
            items.insert(.dayEnd, at: index + 1)
        }
        return items
    }

    /// The end-of-day card is a page now: shown today, and its word is still in the deck.
    private var showsDayEnd: Bool {
        guard let after = dayEndAfterID, encounters.isDayEndShown() else {
            return false
        }
        return model.feedWords.contains { $0.id == after }
    }

    @ViewBuilder
    private func page(_ item: FeedItem, isPaged: Bool) -> some View {
        switch item {
        case .word(let word):
            card(for: word, isPaged: isPaged)
        case .dayEnd:
            dayEndCard(isPaged: isPaged)
        }
    }

    private func card(for word: WidgetWord, isPaged: Bool) -> some View {
        let words = model.feedWords
        return FeedCardView(
            word: word,
            detail: model.detail(for: word),
            isFirstEncounter: encounters.isFirstEncounter(word.id, progress: model.progress[word.id]),
            isLearning: model.learningState(of: word) == .learning,
            // Only while a Lockglow widget is on the Lock Screen (last health check).
            isOnLockScreen: model.hasLockScreenWidget && word.id == model.lockScreenWordID,
            known: knownControl(for: word),
            // Until the user has swiped a few times; never on the last card.
            showsSwipeHint: !feedHintSeen && word.id != words.last?.id,
            openDetail: {
                detailWord = word
            },
            fillsPage: true,
            outerPadding: EdgeInsets(
                top: 4,
                leading: FeedView.pageSideGap,
                bottom: isPaged ? FeedView.pageBottomGap : 16,
                trailing: FeedView.pageSideGap
            )
        )
    }

    /// Counts the cards the user moves to; after `hintCardChanges` of them the hint is gone.
    private func noteCardChange(from oldID: Int?, to newID: Int?) {
        guard !feedHintSeen, newID != nil, newID != oldID else {
            return
        }
        cardChanges += 1
        if cardChanges >= FeedView.hintCardChanges {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                feedHintSeen = true
            }
        }
    }

    /// The word card on screen (the first card until the feed is scrolled); nil on the end-of-day
    /// card.
    private var currentWordID: Int? {
        let id = scrolledWordID ?? model.feedWords.first?.id
        return id == FeedItem.dayEndID ? nil : id
    }

    /// The card on screen is met today; the end-of-day card may follow it.
    private func noteCurrentCard() {
        guard let id = currentWordID else {
            return
        }
        encounters.noteSeen(id, progress: model.progress[id])
        considerDayEnd()
    }

    // MARK: End of the day

    /// The end-of-day card (ogrenme_ilkeleri 2.2 and 2.10). Once the new cards met today reach the
    /// daily goal, it becomes the page after the card on screen: at most once a day, only while
    /// the feed is on screen, and only as this opening's one system card
    /// (`SystemCardQueue.claim`). When another card came first it waits for the next opening.
    private func considerDayEnd(now: Date = Date()) {
        guard isOnScreen,
              systemCards.isDecided,
              !encounters.isDayEndShown(on: now),
              encounters.newCardsSeen(on: now) >= model.dailyNewWords,
              let current = currentWordID,
              systemCards.claim(.dayEnd)
        else {
            return
        }
        encounters.noteDayEndShown(at: now)
        dayEndAfterID = current
    }

    /// A new opening: the card on screen is this opening's card again; otherwise a waiting one
    /// may come now.
    private func openingDecided() {
        guard isOnScreen else {
            return
        }
        if scrolledWordID == FeedItem.dayEndID {
            _ = systemCards.claim(.dayEnd)
        } else {
            considerDayEnd()
        }
    }

    private func dayEndCard(isPaged: Bool) -> some View {
        var continueFeed: (() -> Void)? = nil
        if let next = nextWordID(afterDayEnd: dayEndAfterID) {
            continueFeed = {
                withAnimation(changeAnimation) {
                    scrolledWordID = next
                }
            }
        }
        return FeedDayEndView(
            goal: model.dailyNewWords,
            hasLockScreenWidget: model.hasLockScreenWidget,
            reviewCount: model.nextReviewSession()?.words.count,
            fillsPage: isPaged,
            openReview: openReviewTab,
            continueFeed: continueFeed
        )
        .padding(EdgeInsets(
            top: 4,
            leading: FeedView.pageSideGap,
            bottom: isPaged ? FeedView.pageBottomGap : 16,
            trailing: FeedView.pageSideGap
        ))
    }

    /// The word after the end-of-day card; nil when it is the last page.
    private func nextWordID(afterDayEnd after: Int?) -> Int? {
        let words = model.feedWords
        guard let after = after, let index = words.firstIndex(where: { $0.id == after }), index + 1 < words.count else {
            return nil
        }
        return words[index + 1].id
    }

    /// "Tekrar'a geç". Without `openReview` the reminder route also marks this opening as one a
    /// reminder opened; that only matters before the opening's card is chosen, which is done by now.
    private func openReviewTab() {
        if let openReview = openReview {
            openReview()
            return
        }
        NotificationRouter.shared.requestedWordID = nil
        NotificationRouter.shared.reviewRequested = true
    }

    // MARK: "Biliyorum"

    /// "Biliyorum" in the card's button row: the same change as the widget button and the
    /// "Sözlük" card. A known word's button undoes it.
    private func knownControl(for word: WidgetWord) -> WordCardView.KnownControl {
        return WordCardView.KnownControl(
            isKnown: model.learningState(of: word) == .known,
            markKnown: {
                markKnown(word)
            },
            undoKnown: {
                undoKnown(word)
            }
        )
    }

    private var changeAnimation: Animation? {
        return reduceMotion ? nil : .easeOut(duration: 0.2)
    }

    /// Marks the word known, then shows "Tamam" with "Geri al" for 5 seconds and tells VoiceOver
    /// what happened (audit V7): the button stays where it was, now selected.
    private func markKnown(_ word: WidgetWord) {
        // "Geri al" restores the word exactly as long as the notice stays.
        let isAssisted = UIAccessibility.isVoiceOverRunning || UIAccessibility.isSwitchControlRunning
        withAnimation(changeAnimation) {
            model.markKnown(word, undoWindow: isAssisted ? 10 : KnownUndo.window)
        }
        guard model.learningState(of: word) == .known else {
            // Not saved: nothing changed on screen either.
            return
        }
        let check = FeedView.checkLine(due: model.progress[word.id]?.dueAt)
        withAnimation(changeAnimation) {
            knownNotice = FeedKnownNotice(word: word, message: ["Tamam.", check].compactMap { $0 }.joined(separator: " "))
        }
        announce(["Biliyorum olarak işaretlendi.", check].compactMap { $0 }.joined(separator: " "))
    }

    /// "Geri al" on the notice, or the known word's "Biliyorum" on the card.
    private func undoKnown(_ word: WidgetWord) {
        withAnimation(changeAnimation) {
            model.undoKnown(word)
            if knownNotice?.word.id == word.id {
                knownNotice = nil
            }
        }
        if model.learningState(of: word) != .known {
            // terimler.md: "Öğrenmeye döndü".
            announce("Öğrenmeye döndü.")
        }
    }

    /// "3 gün sonra bir kez soracağız." from when the word comes back (ogrenme_ilkeleri 2.2):
    /// the days follow the progress, so the line stays true whatever `markKnown` schedules.
    static func checkLine(due: Date?, now: Date = Date()) -> String? {
        guard let due = due else {
            return nil
        }
        let days = Int((due.timeIntervalSince(now) / 86_400).rounded())
        guard days >= 1 else {
            return nil
        }
        return "\(days) gün sonra bir kez soracağız."
    }

    /// Queued after what VoiceOver says about the tapped button, so neither cuts the other off.
    private func announce(_ message: String) {
        let text = NSAttributedString(string: message, attributes: [.accessibilitySpeechQueueAnnouncement: true])
        UIAccessibility.post(notification: .announcement, argument: text)
    }

    /// Mockup `.toast`: an ink bar above the tab bar with the result and "Geri al", in the card's
    /// secondary size (callout). At accessibility text sizes "Geri al" goes under the message.
    /// Inverted tokens only: `bg` text on `ink` (16:1 and more); the button is a faint `bg` tint
    /// with a `bg` edge (5:1 and more against the bar, as a `lineStrong` edge on a card).
    @ViewBuilder
    private var knownNoticeBar: some View {
        if let notice = knownNotice {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                : AnyLayout(HStackLayout(spacing: 8))
            layout {
                Label {
                    Text(notice.message)
                } icon: {
                    Image(systemName: "checkmark")
                        .accessibilityHidden(true)
                }
                .font(.callout.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    undoKnown(notice.word)
                } label: {
                    Text("Geri al")
                        .font(.callout.weight(.bold))
                        .padding(.horizontal, 16)
                        .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
                        .background(Theme.bg.opacity(0.18), in: Capsule())
                        .overlay(Capsule().strokeBorder(Theme.bg.opacity(0.6), lineWidth: 1))
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Kelime öğrenme listene döner.")
                .accessibilityFocused($noticeHasFocus)
            }
            .foregroundStyle(Theme.bg)
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(Theme.ink, in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: Theme.shadowFar, radius: 16, x: 0, y: 8)
            .accessibilityElement(children: .contain)
            .padding(.horizontal, 16)
            .padding(.bottom, FeedView.pageBottomGap + 8)
            .transition(reduceMotion ? AnyTransition.opacity : AnyTransition.move(edge: .bottom).combined(with: .opacity))
        }
    }

    /// The notice leaves after 5 seconds (ogrenme_ilkeleri 2.2). With VoiceOver or Switch Control
    /// it stays 10 seconds, and never leaves while VoiceOver is on it (WCAG 2.2.1). While it is on
    /// screen its "Geri al" restores the word exactly: the model's undo window is kept a little
    /// ahead of it (`AppModel.extendKnownUndo`). The card's "Biliyorum" undoes the word at any
    /// time anyway.
    private func hideKnownNoticeLater() async {
        guard let word = knownNotice?.word else {
            return
        }
        let isAssisted = UIAccessibility.isVoiceOverRunning || UIAccessibility.isSwitchControlRunning
        let end = Date().addingTimeInterval(isAssisted ? 10 : 5)
        while !Task.isCancelled && (Date() < end || noticeHasFocus) {
            model.extendKnownUndo(of: word, until: Date().addingTimeInterval(2))
            let remaining = end.timeIntervalSinceNow
            try? await Task.sleep(for: .seconds(remaining > 0 ? min(1, remaining) : 1))
        }
        guard !Task.isCancelled else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            knownNotice = nil
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        switch model.contentSource {
        case .loading:
            ProgressView()
        default:
            // No file names here (terimler.md: technical names only under "Teknik bilgiler").
            ContentUnavailableView(
                "Kelimeler yüklenemedi",
                systemImage: "tray",
                description: Text("Uygulamayı kapatıp yeniden aç.")
            )
        }
    }
}

/// One page of "Akış": a word card, or the end-of-day card.
private enum FeedItem: Identifiable {
    /// The end-of-day card's id in the scroll position (word ids are positive).
    static let dayEndID = -1

    case word(WidgetWord)
    case dayEnd

    var id: Int {
        switch self {
        case .word(let word):
            return word.id
        case .dayEnd:
            return FeedItem.dayEndID
        }
    }
}

/// The "Geri al" notice of one "Biliyorum" tap; `token` restarts its timer on every tap.
private struct FeedKnownNotice {
    let token = UUID()
    let word: WidgetWord
    let message: String
}

/// Which feed cards the user has met before (ogrenme_ilkeleri 2.2: the card opens up from the
/// second encounter). A word met in "Tekrar" or through a widget button has it in its progress
/// (`reviews`, `exposures`). The feed is not in `WordProgress`, so the first day each card was on
/// screen is kept here: UserDefaults `lockglow.feedFirstSeen`, word id → the start of that day
/// (seconds since 1970). A card first seen today stays a first encounter all day, so it never
/// changes while the user looks at it. Only new cards are kept: the ones met today are the feed's
/// part of the daily goal (`newCardsSeen`). The day the end-of-day card was shown is kept too
/// (`lockglow.feedDayEndShown`); after it no card is kept that day (ogrenme_ilkeleri 2.2: the cards
/// after it are not that day's new words), so they stay first encounters. "İlerlemeyi sıfırla"
/// clears both (`AppPreferences.clearFeedFirstSeen`).
final class FeedEncounterStore: ObservableObject {
    static let defaultsKey = AppPreferences.feedFirstSeenKey
    static let dayEndKey = "lockglow.feedDayEndShown"

    private let defaults: UserDefaults
    private var firstSeen: [Int: Date]
    /// The start of the day the end-of-day card was shown.
    private var dayEndShown: Date?
    private var clearObserver: NSObjectProtocol?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.dictionary(forKey: FeedEncounterStore.defaultsKey) as? [String: Double] ?? [:]
        var days: [Int: Date] = [:]
        for (key, seconds) in stored {
            if let id = Int(key) {
                days[id] = Date(timeIntervalSince1970: seconds)
            }
        }
        firstSeen = days
        dayEndShown = (defaults.object(forKey: FeedEncounterStore.dayEndKey) as? Double).map(Date.init(timeIntervalSince1970:))
        clearObserver = NotificationCenter.default.addObserver(
            forName: AppPreferences.feedFirstSeenCleared,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.objectWillChange.send()
            self?.firstSeen = [:]
            self?.dayEndShown = nil
            self?.defaults.removeObject(forKey: FeedEncounterStore.dayEndKey)
        }
    }

    deinit {
        if let observer = clearObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// The card is on screen at `now`: a new card keeps its first day, unless the end-of-day card
    /// was shown today.
    func noteSeen(_ id: Int, progress: WordProgress?, now: Date = Date()) {
        guard firstSeen[id] == nil, !FeedEncounterStore.wasMet(progress), !isDayEndShown(on: now) else {
            return
        }
        firstSeen[id] = Calendar.current.startOfDay(for: now)
        var stored: [String: Double] = [:]
        for (key, day) in firstSeen {
            stored[String(key)] = day.timeIntervalSince1970
        }
        defaults.set(stored, forKey: FeedEncounterStore.defaultsKey)
    }

    /// Not reviewed, no widget button, and not in the feed before today.
    func isFirstEncounter(_ id: Int, progress: WordProgress?, now: Date = Date()) -> Bool {
        if FeedEncounterStore.wasMet(progress) {
            return false
        }
        guard let day = firstSeen[id] else {
            return true
        }
        return day >= Calendar.current.startOfDay(for: now)
    }

    /// New cards first seen on `now`'s day.
    func newCardsSeen(on now: Date = Date()) -> Int {
        let today = Calendar.current.startOfDay(for: now)
        return firstSeen.values.filter { $0 == today }.count
    }

    func isDayEndShown(on now: Date = Date()) -> Bool {
        return dayEndShown == Calendar.current.startOfDay(for: now)
    }

    func noteDayEndShown(at now: Date = Date()) {
        let day = Calendar.current.startOfDay(for: now)
        dayEndShown = day
        defaults.set(day.timeIntervalSince1970, forKey: FeedEncounterStore.dayEndKey)
    }

    /// Met in "Tekrar" or through a widget button.
    private static func wasMet(_ progress: WordProgress?) -> Bool {
        guard let progress = progress else {
            return false
        }
        return progress.reviews > 0 || progress.exposures > 0
    }
}

/// Page-by-page scrolling, off at accessibility text sizes (README point 7).
private struct FeedPagingModifier: ViewModifier {
    let isEnabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content.scrollTargetBehavior(.paging)
        } else {
            content
        }
    }
}

/// How a page moves while the feed scrolls (paged feed only): the card leaving or arriving fades
/// a little (to 70 %) and settles back to 97 %, so the eye follows one card, not two edges. It follows
/// the finger (`.interactive`) and stops with it: no motion of its own, nothing to wait for (HIG
/// Motion). With Reduce Motion only the fade is left. Off at accessibility sizes, where a card
/// taller than the screen is never fully on it and would stay faded while read. A card counts as
/// at rest from 90 % on screen, so a page a hair short of its frame never stays faded. The
/// modifier is always applied (only its values change), so a change of text size keeps each
/// card's state, an open sheet included.
private struct FeedPageTransition: ViewModifier {
    let isEnabled: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        // Copies for the `@Sendable` closure, which then captures two Bools, not the modifier.
        let isEnabled = self.isEnabled
        let reduceMotion = self.reduceMotion
        return content.scrollTransition(.interactive.threshold(.visible(0.9)), axis: .vertical) { effect, phase in
            effect
                .opacity(isEnabled ? 1 - min(abs(phase.value), 1) * 0.3 : 1)
                .scaleEffect(isEnabled && !reduceMotion ? 1 - CGFloat(min(abs(phase.value), 1)) * 0.03 : 1)
        }
    }
}

/// The word card. Reading order for an A2 learner (ogrenme_ilkeleri 2.2): the English word on
/// its phosphor band; one line with the pronunciation, part of speech and level; one row of
/// buttons ("Dinle", "Söyle", "Biliyorum"); the Turkish meaning (large, no box); a simple English
/// definition; one example with its Turkish translation; one warning line. `detail` is nil for
/// seed words: the card then shows the example without a translation and no warning. Few labels:
/// a rule sets the example apart.
///
/// The first encounter (`isFirstEncounter`) shows at most these 8 blocks: the micro definition of
/// an A1–A2 card and one warning slot, filled by priority (`CardWarning`: false friend > Dikkat >
/// two meanings > phrasal verb) as a single line whose "Neden?" opens the explanation sheet. From
/// the second encounter on the card shows the short definition, the whole Dikkat box and every
/// warning line.
///
/// In the feed (`fillsPage`) the card fills its page. A tall page of a card met before first gets
/// the card's second example; what room is left widens the gaps between the parts a little
/// (`extraGap`). Where the page is too short, the card shortens itself from the end (rule 5, "kart
/// sondan kısalır"): smaller text without the Lock Screen label, then no Dikkat explanation, then
/// only the slot's one line, then the example as a row, then the warning in that row too; the rows
/// open the whole card (`openDetail`). At accessibility text sizes it always shows everything (one
/// example) at its natural height. Elsewhere (the onboarding) it is as tall as its content.
/// `showsSay: false` hides the microphone (a card shown where no permission prompt may appear).
struct WordCardView: View {
    /// "Biliyorum" in the button row: whether the word is known, and the two changes.
    struct KnownControl {
        let isKnown: Bool
        let markKnown: () -> Void
        let undoKnown: () -> Void
    }

    let word: WidgetWord
    let detail: CardDetail?
    var showsSay = true
    var fillsPage = false
    /// The first time the user meets the word (`FeedEncounterStore`); the onboarding's first word
    /// is one too.
    var isFirstEncounter = true
    /// "Şu an kilitli ekranda" in the meta line: only for the word the Lock Screen widget shows
    /// right now (README "Akış", `AppModel.lockScreenWordID`).
    var isOnLockScreen = false
    /// nil: no "Biliyorum" (the onboarding).
    var known: KnownControl? = nil
    /// "Yukarı kaydır" under the card's text (the feed's first few cards).
    var showsSwipeHint = false
    /// Opens the whole card; the last two shortening steps need it.
    var openDetail: (() -> Void)? = nil
    /// Around the card; the onboarding cancels the horizontal 16 pt with its own padding.
    var outerPadding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    /// The warning whose "Neden?" sheet is open.
    @State private var explained: CardWarning? = nil

    var body: some View {
        let maxHeight: CGFloat? = isPaged ? .infinity : nil
        VStack(alignment: .leading, spacing: 0) {
            content
            if showsSwipeHint {
                swipeHint
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: maxHeight, alignment: .topLeading)
        .cardSurface(cornerRadius: Theme.Radius.wordCard)
        // Borderless controls inside (the "Söyle" microphone) take ink, never the blue default.
        .tint(Theme.ink)
        .padding(outerPadding)
        // Not combined into one element: the buttons must stay reachable on their own.
        .accessibilityElement(children: .contain)
        .sheet(isPresented: whySheetShown) {
            if let warning = explained {
                CardWhySheet(word: word, detail: detail, warning: warning)
            }
        }
    }

    private var whySheetShown: Binding<Bool> {
        return Binding(
            get: { explained != nil },
            set: { isShown in
                if !isShown {
                    explained = nil
                }
            }
        )
    }

    /// Sized to its page, with the shortening steps. Never at accessibility text sizes.
    private var isPaged: Bool {
        return fillsPage && !dynamicTypeSize.isAccessibilitySize
    }

    /// The card's warnings, the slot's first (`CardWarning`).
    private var warnings: [CardWarning] {
        return CardWarning.all(for: word, detail: detail)
    }

    /// The card's own example (`example_en`) with its translation; the detail's first example
    /// if the word's example is not among them.
    private var firstExample: CardDetail.Example {
        let examples = detail?.examples ?? []
        return examples.first { $0.en == word.exampleEN } ?? examples.first ?? CardDetail.Example(en: word.exampleEN)
    }

    /// The card's next example, for a page with room to spare; nil for seed words and cards with
    /// one example.
    private var secondExample: CardDetail.Example? {
        let first = firstExample.en
        return detail?.examples.first { $0.en != first }
    }

    /// The micro definition on the first encounter of an A1–A2 card, otherwise the short one
    /// (ogrenme_ilkeleri 2.2).
    private var definition: String {
        if isFirstEncounter, let level = word.levelValue, level <= .a2, !word.defMicro.isEmpty {
            return word.defMicro
        }
        return word.defShort
    }

    // MARK: Fitting the page (rule 5)

    private enum FitStep: Int {
        /// Met before, a page with room for it: a second example.
        case roomy
        /// Everything for this encounter.
        case full
        /// 1. Smaller meaning (Title 2), tighter spacing; no Lock Screen label.
        case smaller
        /// 2. Met before: the Dikkat box without its explanation.
        case noWhy
        /// 3. Met before: only the slot's one line, as on the first encounter.
        case slotOnly
        /// 4. The example as a row.
        case exampleRow
        /// 5. The example and the warning in that one row.
        case allRow

        var isSmaller: Bool {
            return rawValue >= FitStep.smaller.rawValue
        }
    }

    /// The most a gap between the card's parts grows on a page with room left.
    private static let extraGap: CGFloat = 20

    @ViewBuilder
    private var content: some View {
        if isPaged {
            let warnings = self.warnings
            let hasMistake = warnings.contains { if case .mistake = $0 { return true } else { return false } }
            let metBefore = !isFirstEncounter
            // The first step whose height fits the page wins; the last one is used regardless.
            ViewThatFits(in: .vertical) {
                if metBefore && secondExample != nil {
                    cardContent(.roomy, warnings: warnings)
                }
                cardContent(.full, warnings: warnings)
                cardContent(.smaller, warnings: warnings)
                if metBefore && hasMistake {
                    cardContent(.noWhy, warnings: warnings)
                }
                if metBefore && (hasMistake || warnings.count > 1) {
                    cardContent(.slotOnly, warnings: warnings)
                }
                if openDetail != nil {
                    cardContent(.exampleRow, warnings: warnings)
                }
                if openDetail != nil && !warnings.isEmpty {
                    cardContent(.allRow, warnings: warnings)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            // Only if even the last step is too tall (very small screen, largest non-accessibility
            // size): the text ends at the card's edge instead of running off it.
            .clipped()
        } else {
            cardContent(.full, warnings: warnings)
        }
    }

    private func cardContent(_ step: FitStep, warnings: [CardWarning]) -> some View {
        let spacing: CGFloat = step.isSmaller ? 8 : 12
        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: spacing) {
                // The night band hangs below the word: at least 8 pt before the next row.
                WordCardHeadline(lemma: word.lemma)
                    .padding(.bottom, step.isSmaller ? 2 : 0)
                metaRow(showsLockScreen: isOnLockScreen && !step.isSmaller)
                actionRow
                meaning(step)
                // A user's word has no English definition (and maybe no example). The serif
                // body size of the example (`exampleFont`): the card keeps four sizes (word,
                // meaning, English text, Turkish secondary text).
                if !definition.isEmpty {
                    Text(definition)
                        .exampleFont()
                        .foregroundStyle(Theme.ink)
                        // About 1.45 line height (ogrenme_ilkeleri 2.2), tighter on a short page.
                        .lineSpacing(step.isSmaller ? 2 : 5)
                        .lineLimit(step.rawValue >= FitStep.exampleRow.rawValue ? 3 : nil)
                        .cardEnglishVoice()
                }
            }
            partGap(spacing)
            if step == .allRow {
                detailRow(
                    title: WordCardView.rowTitle(for: warnings.first, hasExample: !firstExample.en.isEmpty),
                    showsCaution: false
                )
            } else {
                // A user's word without an example has nothing here.
                if !firstExample.en.isEmpty {
                    if step == .exampleRow {
                        detailRow(title: "Örnek cümle", showsCaution: false)
                    } else {
                        exampleBlock(step)
                    }
                }
                if !warnings.isEmpty {
                    partGap(spacing)
                    warningBlock(step, warnings: warnings)
                }
            }
        }
        // Mockup `.inner`: 18 / 20 / 20, less above "Yukarı kaydır".
        .padding(.top, 18)
        .padding(.horizontal, 20)
        .padding(.bottom, showsSwipeHint ? 10 : 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Between the word's part, the example and the warnings: `minimum`, and on a page with room
    /// left up to `extraGap` more (the rest stays at the bottom). Its ideal height is `minimum`, so
    /// it never changes which step fits; the low priority lets the text take its room first.
    private func partGap(_ minimum: CGFloat) -> some View {
        Color.clear
            .frame(minHeight: minimum, idealHeight: minimum, maxHeight: minimum + (isPaged ? WordCardView.extraGap : 0))
            .layoutPriority(-1)
    }

    // MARK: Parts

    /// One quiet line: pronunciation, part of speech, level (and the Lock Screen label); the
    /// facts wrap when the line is full.
    private func metaRow(showsLockScreen: Bool) -> some View {
        CardFlowLayout(itemSpacing: 8, lineSpacing: 4) {
            ipa
            if word.isUserAdded {
                CustomWordTag()
            } else {
                partOfSpeech
                LevelBadge(code: word.level)
            }
            if showsLockScreen {
                WordCardLockScreenNote()
            }
        }
    }

    /// Visual only: VoiceOver says the word itself, and "Dinle" plays it.
    @ViewBuilder
    private var ipa: some View {
        AccentIPA(word) { ipa in
            Text(ipa)
                .font(.system(.callout, design: .serif))
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
        }
    }

    private var partOfSpeech: some View {
        Text(CardPartOfSpeech.turkish(word.pos))
            .font(.callout.weight(.medium))
            .foregroundStyle(Theme.ink2)
    }

    /// "Dinle", "Söyle" and "Biliyorum" on one row, one block (ogrenme_ilkeleri 2.2):
    /// "Biliyorum" keeps to the trailing edge and wraps under the others when the row is full.
    /// The feed card's buttons (`FeedToolButtonStyle`, callout), with the same names.
    private var actionRow: some View {
        CardFlowLayout(itemSpacing: 8, lineSpacing: 8, pinsLastToTrailingEdge: known != nil) {
            FeedListenButton(text: word.lemma)
            if showsSay {
                FeedSayButton(word: word, example: word.exampleEN)
            }
            if let known = known {
                knownButton(known)
            }
        }
    }

    /// "Biliyorum"; a known word's is selected (a check in `good`, a `tint` border) and undoes it.
    /// It never leaves the row, so VoiceOver keeps its place (audit V7).
    private func knownButton(_ known: KnownControl) -> some View {
        Button {
            if known.isKnown {
                known.undoKnown()
            } else {
                known.markKnown()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: known.isKnown ? "checkmark.circle.fill" : "checkmark")
                    .foregroundStyle(known.isKnown ? Theme.good : Theme.ink)
                    .accessibilityHidden(true)
                Text("Biliyorum")
            }
        }
        .buttonStyle(FeedToolButtonStyle(isSelected: known.isKnown))
        .accessibilityLabel("Biliyorum")
        .accessibilityAddTraits(known.isKnown ? .isSelected : [])
        .accessibilityHint(Text(known.isKnown ? "Kelime öğrenme listene döner." : ""))
    }

    /// The Turkish meaning only: other meanings ("Ayrıca") are on the whole card in "Sözlük".
    @ViewBuilder
    private func meaning(_ step: FitStep) -> some View {
        if let gloss = word.glossTR {
            Text(gloss)
                .font(step.isSmaller ? Font.title2.weight(.bold) : Theme.Fonts.meaning)
                .foregroundStyle(Theme.ink)
                .accessibilityLabel(Text(verbatim: "Türkçesi: " + gloss))
        }
    }

    /// Mockup `.exblock` without its "Örnek" label (the rule and the sentence say it): the
    /// sentence with the learned word marked (the band's yellow, rule 1), its Turkish translation
    /// and its speaker. On a roomy page a second example follows, the word bold but not yellow.
    private func exampleBlock(_ step: FitStep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            WordCardRule()
            ExampleRow(example: firstExample, lemma: word.lemma, marksWord: true)
            if step == .roomy, let second = secondExample {
                ExampleRow(example: second, lemma: word.lemma)
            }
        }
    }

    /// The first encounter (and a short page): the slot's one line. Met before: every warning,
    /// the mistake as the whole Dikkat box.
    private func warningBlock(_ step: FitStep, warnings: [CardWarning]) -> some View {
        let isSlotOnly = isFirstEncounter || step.rawValue >= FitStep.slotOnly.rawValue
        let shown = isSlotOnly ? Array(warnings.prefix(1)) : warnings
        return VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(shown.enumerated()), id: \.offset) { _, warning in
                if !isSlotOnly, case let .mistake(mistake) = warning {
                    MistakeBox(mistake: mistake, showsWhy: step.rawValue < FitStep.noWhy.rawValue)
                } else {
                    CardWarningLine(warning: warning, lemma: word.lemma, explain: explainAction(for: warning))
                }
            }
        }
    }

    private func explainAction(for warning: CardWarning) -> (() -> Void)? {
        guard warning.hasExplanation else {
            return nil
        }
        return {
            explained = warning
        }
    }

    /// The last step's row: what it opens. A user's word may have no example.
    static func rowTitle(for warning: CardWarning?, hasExample: Bool) -> String {
        switch warning {
        case .falseFriend?:
            return hasExample ? "Örnek cümle ve sahte dost" : "Sahte dost"
        case .mistake?:
            return hasExample ? "Örnek cümle ve Dikkat" : "Dikkat"
        case .sameWord?, .phrasalVerb?:
            return hasExample ? "Örnek cümle ve not" : "Not"
        case nil:
            return "Örnek cümle"
        }
    }

    /// One capsule in place of a part that no longer fits (mockup `.mrow`; tappable, so a
    /// capsule, rule 2); opens the whole card.
    private func detailRow(title: String, showsCaution: Bool) -> some View {
        Button {
            openDetail?()
        } label: {
            HStack(spacing: 8) {
                if showsCaution {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(Theme.caution)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // An icon, so `ink3` (never text on `surface2`/`surface3`, ogrenme_ilkeleri 2.2).
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                    .accessibilityHidden(true)
            }
            .font(.callout.weight(.semibold))
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 48, tonal: true))
        .accessibilityHint("Kartın tamamını açar")
    }

    /// The first few cards show where the next one is. Visual only: VoiceOver moves on by itself.
    /// It wraps instead of being cut at large text sizes.
    private var swipeHint: some View {
        HStack(spacing: 4) {
            Image(systemName: "chevron.up")
            Text("Yukarı kaydır")
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.callout.weight(.semibold))
        .foregroundStyle(Theme.ink2)
        .accessibilityHidden(true)
    }
}

/// The English word on its phosphor band, in the theme's word style (`englishWordStyle()`: serif
/// bold at the Large Title size, scaled with Dynamic Type). A phrase too long for one line breaks
/// into two balanced lines, each on its own band; a word (or a half of a phrase) still too wide
/// shrinks with the style's `minimumScaleFactor`. Never a hyphen, no tighter letter spacing.
/// VoiceOver reads it once, as a heading, with an English voice. The feed card and the
/// onboarding's card both use it.
struct WordCardHeadline: View {
    let lemma: String

    var body: some View {
        Group {
            if let lines = WordCardHeadline.balancedLines(lemma) {
                // Each choice is measured unshrunk: one line if it fits, else the two lines (the
                // last choice, used regardless, so its lines shrink when they must).
                ViewThatFits(in: .horizontal) {
                    line(lemma)
                    // The night band hangs below the first line: 8 pt before the second.
                    VStack(alignment: .leading, spacing: 8) {
                        line(lines.first)
                        line(lines.second)
                    }
                }
            } else {
                line(lemma)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: lemma))
        .accessibilityAddTraits(.isHeader)
        .cardEnglishVoice()
    }

    private func line(_ text: String) -> some View {
        Text(verbatim: text)
            .englishWordStyle()
            .phosphorBand()
    }

    /// `phrase` cut at the space that makes the longer line shortest; nil for a single word.
    static func balancedLines(_ phrase: String) -> (first: String, second: String)? {
        let words = phrase.split(separator: " ").map(String.init)
        guard words.count > 1 else {
            return nil
        }
        var best: (first: String, second: String)?
        var bestLength = Int.max
        for cut in 1..<words.count {
            let first = words[..<cut].joined(separator: " ")
            let second = words[cut...].joined(separator: " ")
            let longer = max(first.count, second.count)
            // On a tie the later cut: a longer first line reads more naturally.
            if longer <= bestLength {
                bestLength = longer
                best = (first, second)
            }
        }
        return best
    }
}

/// "Şu an kilitli ekranda" (mockup `.now-chip`): a quiet item of the meta line, not a capsule,
/// since it cannot be tapped (rule 2).
struct WordCardLockScreenNote: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock")
                .imageScale(.small)
                .accessibilityHidden(true)
            Text("Şu an kilitli ekranda")
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.callout.weight(.semibold))
        .foregroundStyle(Theme.ink2)
    }
}

/// A 1 pt `line` rule (mockup `border-top: 1px solid var(--line)`).
private struct WordCardRule: View {
    var body: some View {
        Rectangle()
            .fill(Theme.line)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}
