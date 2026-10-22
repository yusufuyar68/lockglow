import SwiftUI
import CoreModels
import SharedState
import Learning

struct RootView: View {
    enum AppTab: Hashable {
        case feed
        case review
        case search
        case settings
    }

    @EnvironmentObject private var model: AppModel
    @ObservedObject private var notifications = NotificationRouter.shared
    @StateObject private var systemCards = SystemCardQueue()
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .feed
    @State private var scrolledWordID: Int?
    /// Deep link received before the words finished loading.
    @State private var pendingWordID: Int?
    /// A widget word that is not in the deck, shown as its full card in a sheet.
    @State private var detailWord: WidgetWord?
    /// A word card asked for while the system card was closing: shown once it has closed.
    @State private var detailAfterCard: WidgetWord?
    /// What the system card asked for, done once its sheet has closed.
    @State private var afterCard: SystemCardSheet.FollowUp?
    @State private var showsWidgetGuide = false
    /// The progress-recovery card was shown in this run (it then stays only in "Ayarlar").
    @State private var recoveryCardShown = false
    /// This opening came from a tapped reminder.
    @State private var openedFromReminder = false

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(scrolledWordID: $scrolledWordID)
                .tabItem { Label("Akış", systemImage: "rectangle.stack") }
                .tag(AppTab.feed)
            // "Günlük hedefi değiştir" on the done screen opens Ayarlar.
            ReviewView(openSettings: { selectedTab = .settings })
                .tabItem { Label("Tekrar", systemImage: "arrow.triangle.2.circlepath") }
                .tag(AppTab.review)
            SearchView()
                .tabItem { Label("Sözlük", systemImage: "magnifyingglass") }
                .tag(AppTab.search)
            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gearshape") }
                .badge(model.progressRecovery == nil ? 0 : 1)
                .tag(AppTab.settings)
        }
        // The selected tab is ink, never yellow and never the blue default (README `tint`);
        // the tint also reaches every control below. The iOS 26 tab bar is glass by itself.
        .tint(Theme.tint)
        // Screens with a system card of their own ask the queue first (`claim`).
        .environmentObject(systemCards)
        .task {
            await model.start()
            await startOpening()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                model.sceneDidEnterBackground()
                ReminderLog.recordUse()
                systemCards.endOpening()
                openedFromReminder = false
                // After the widget events were applied: the reminder words use the latest progress.
                let reminders = model.reminderPlan()
                Task {
                    await ReminderScheduler.replace(with: reminders)
                }
            case .active:
                model.sceneDidBecomeActive()
                // At launch `task` starts the opening once the content has loaded.
                if model.contentSource != .loading {
                    Task {
                        await startOpening()
                    }
                }
            default:
                break
            }
        }
        // Turned on again in "Ayarlar": the pause is over.
        .onChange(of: model.reminderEnabled) { _, isOn in
            if isOn {
                ReminderLog.clearPause()
            }
        }
        .onChange(of: model.feedWords) { _, newWords in
            applyPendingWord(in: newWords)
            openReviewIfRequested()
        }
        .fullScreenCover(isPresented: onboardingBinding) {
            OnboardingView()
                .environmentObject(model)
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
            // A sheet starts its own hierarchy: "Kapat" and the card's controls stay ink.
            .tint(Theme.ink)
            .environmentObject(model)
        }
        .sheet(item: $systemCards.presented, onDismiss: systemCardClosed) { card in
            SystemCardSheet(card: card) { followUp in
                afterCard = followUp
                systemCards.presented = nil
            }
            .tint(Theme.ink)
            .environmentObject(model)
        }
        .sheet(isPresented: $showsWidgetGuide) {
            NavigationStack {
                WidgetGuideScreen()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") {
                                showsWidgetGuide = false
                            }
                        }
                    }
            }
            .tint(Theme.ink)
        }
        .onOpenURL { url in
            handle(url)
        }
        .onAppear {
            openReviewIfRequested()
        }
        .onChange(of: notifications.reviewRequested) { _, _ in
            openReviewIfRequested()
        }
    }

    /// Shown on first launch and from "Ayarlar"; the onboarding closes itself through the model.
    private var onboardingBinding: Binding<Bool> {
        return Binding(
            get: { model.showsOnboarding },
            set: { isShown in
                if !isShown && model.showsOnboarding {
                    model.finishOnboarding()
                }
            }
        )
    }

    // MARK: System cards

    /// An opening (the app came to the foreground): measures the ignored reminders, counts this
    /// opening as a use, then shows at most one system card. In priority order: the progress
    /// file was recovered > reminders paused > the reminder time question > the widget tip. The
    /// screens' own cards ("Ara verdin", the end-of-day card) come after these (`claim`).
    private func startOpening() async {
        guard systemCards.beginOpening() else {
            return
        }
        let now = Date()
        let widgetUse = AppGroupLocator.containerURL().flatMap { AppGroupStore(containerURL: $0).readState()?.updatedAt }
        // Before anything is awaited: the opening counts as a use from here on.
        let reminderWasOn = model.reminderEnabled
        let followUp = ReminderLog.openingFollowUp(isActive: reminderWasOn, widgetUse: widgetUse, now: now)
        let authorized = await ReminderScheduler.isAuthorized()

        var candidates: Set<SystemCardQueue.Card> = []
        if model.progressRecovery != nil && !recoveryCardShown {
            candidates.insert(.progressRecovered)
        }
        let action: ReminderBackoff.Action = authorized && reminderWasOn ? followUp : .nothing
        switch action {
        case .pause:
            // A week of ignored reminders: off, and the next free opening says so (2.10).
            ReminderLog.pause(at: now)
            model.setReminderEnabled(false)
            await ReminderScheduler.replace(with: [])
        case .askForTime:
            // Not when a reminder tap opened the app: that time worked.
            if !notifications.reviewRequested && !openedFromReminder {
                candidates.insert(.reminderTime)
            }
        case .nothing:
            break
        }
        if ReminderLog.pauseNotePending() {
            candidates.insert(.remindersPaused)
        }
        await model.refreshHealth()
        if WidgetTip.isDue(status: WidgetHealthStatus(of: model), now: now) {
            candidates.insert(.widgetTip)
        }
        // Never over the onboarding or a card opened from the widget.
        if model.showsOnboarding || detailWord != nil {
            candidates = []
        }
        let shown = systemCards.decide(from: candidates)
        switch shown {
        case .progressRecovered?:
            recoveryCardShown = true
        case .remindersPaused?:
            ReminderLog.pauseNoteShown()
        case .widgetTip?:
            WidgetTip.noteShown(at: now)
        default:
            break
        }
    }

    /// The system card's sheet has closed: do what it asked for.
    private func systemCardClosed() {
        if let word = detailAfterCard {
            detailAfterCard = nil
            detailWord = word
            return
        }
        switch afterCard {
        case .openSettings?:
            selectedTab = .settings
        case .widgetGuide?:
            showsWidgetGuide = true
        case nil:
            break
        }
        afterCard = nil
    }

    // MARK: Reminder tap

    /// A tapped reminder opens "Tekrar"; when "Tekrar" has nothing to ask, the reminder's word.
    /// Waits for the words when the tap launched the app.
    private func openReviewIfRequested() {
        guard notifications.reviewRequested else {
            return
        }
        openedFromReminder = true
        if model.contentSource == .loading {
            selectedTab = .review
            return
        }
        let wordID = notifications.requestedWordID
        notifications.reviewRequested = false
        notifications.requestedWordID = nil
        if model.nextReviewSession() == nil, let wordID = wordID {
            open(wordID, in: model.feedWords)
        } else {
            selectedTab = .review
        }
    }

    // MARK: Widget deep link

    /// `vocabwidget://word/<id>`, opened by tapping a widget. A word of the deck: "Akış" scrolls
    /// to it. A word outside the deck (the one kept on screen right after a topic change, or one
    /// from the every-topic fallback): its card opens in a sheet.
    private func handle(_ url: URL) {
        guard let wordID = DeepLink.wordID(from: url) else {
            return
        }
        if model.contentSource == .loading {
            selectedTab = .feed
            pendingWordID = wordID
        } else {
            open(wordID, in: model.feedWords)
        }
    }

    /// The words arrived: open the pending word, then forget it.
    private func applyPendingWord(in words: [WidgetWord]) {
        guard let wordID = pendingWordID, !words.isEmpty else {
            return
        }
        pendingWordID = nil
        open(wordID, in: words)
    }

    private func open(_ wordID: Int, in feed: [WidgetWord]) {
        if feed.contains(where: { $0.id == wordID }) {
            selectedTab = .feed
            scrolledWordID = wordID
            return
        }
        // Not over the onboarding: two presentations at once do not work.
        guard !model.showsOnboarding, let word = model.word(id: wordID) else {
            selectedTab = .feed
            return
        }
        if systemCards.presented != nil {
            // The word goes first: the card closes and the word's sheet follows.
            detailAfterCard = word
            afterCard = nil
            systemCards.presented = nil
        } else {
            detailWord = word
        }
    }
}

// MARK: - System card queue

/// System cards (ogrenme_ilkeleri 2.10): notes at an opening that teach no word. At most one per
/// opening; an opening lasts from coming to the foreground until going to the background.
///
/// RootView offers its cards when an opening starts and shows the first by priority as a sheet.
/// A screen with a card of its own ("Ara verdin" in "Tekrar", the end-of-day card in "Akış")
/// calls `claim(_:)` once `isDecided` is true: it gets true only if no other card came first.
/// Otherwise the screen shows its plain version ("Başla (10 kart)" without the two lines) or
/// keeps its card for the next opening.
@MainActor
final class SystemCardQueue: ObservableObject {
    /// In priority order, the most important first.
    enum Card: Int, Comparable, Identifiable {
        /// The progress file was damaged and recovered (`AppModel.progressRecovery`).
        case progressRecovered
        /// "Hatırlatmaları duraklattık." after a week of ignored reminders.
        case remindersPaused
        /// "Hatırlatma saatini değiştirelim mi?" after three days of ignored reminders.
        case reminderTime
        /// No widget yet: how to add one.
        case widgetTip
        /// "Ara verdin, sorun değil." (Tekrar's start after a break; shown by ReviewView).
        case breakStart
        /// "Bugünlük 10 yeni kelime yeter." (Akış; shown by FeedView).
        case dayEnd

        var id: Int {
            return rawValue
        }

        static func < (lhs: Card, rhs: Card) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    /// The card RootView shows as a sheet; nil when closed.
    @Published var presented: Card?
    /// RootView has picked this opening's card (or none): screens may `claim` from now on.
    @Published private(set) var isDecided = false
    /// This opening's card, shown by RootView or claimed by a screen.
    private(set) var current: Card?
    private var hasBegun = false

    /// Starts an opening; false when one is already running (the launch and the first activation
    /// both start it) or a card from before the background is still open (it is this opening's).
    func beginOpening() -> Bool {
        if hasBegun {
            return false
        }
        hasBegun = true
        if let open = presented {
            current = open
            isDecided = true
            return false
        }
        current = nil
        isDecided = false
        return true
    }

    func endOpening() {
        hasBegun = false
        isDecided = false
        current = nil
    }

    /// RootView's cards for this opening: the first by priority is shown and returned.
    @discardableResult
    func decide(from candidates: Set<Card>) -> Card? {
        defer {
            isDecided = true
        }
        guard current == nil, let first = candidates.min() else {
            return nil
        }
        current = first
        presented = first
        return first
    }

    /// A screen's own card: true when it is this opening's card (it was free or already this
    /// card's), false while RootView has not decided or another card came first.
    func claim(_ card: Card) -> Bool {
        guard isDecided else {
            return false
        }
        if current == nil {
            current = card
        }
        return current == card
    }
}

// MARK: - Widget tip

/// When the "add a widget" card may come: no widget placed (only a verdict iOS can be trusted
/// on), not before the day after the first opening (the onboarding has its own widget page), at
/// most twice, a week apart.
private enum WidgetTip {
    static let maxShows = 2
    static let firstAfter: TimeInterval = 86_400
    static let gap: TimeInterval = 7 * 86_400

    private static let firstOpeningKey = "lockglow.firstOpeningAt"
    private static let shownCountKey = "lockglow.widgetTip.shownCount"
    private static let lastShownKey = "lockglow.widgetTip.lastShownAt"

    static func isDue(status: WidgetHealthStatus, now: Date) -> Bool {
        let defaults = UserDefaults.standard
        guard let first = defaults.object(forKey: firstOpeningKey) as? Double else {
            defaults.set(now.timeIntervalSince1970, forKey: firstOpeningKey)
            return false
        }
        guard status == .notAdded,
              now.timeIntervalSince1970 - first >= firstAfter,
              defaults.integer(forKey: shownCountKey) < maxShows
        else {
            return false
        }
        if let last = defaults.object(forKey: lastShownKey) as? Double, now.timeIntervalSince1970 - last < gap {
            return false
        }
        return true
    }

    static func noteShown(at date: Date) {
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: shownCountKey) + 1, forKey: shownCountKey)
        defaults.set(date.timeIntervalSince1970, forKey: lastShownKey)
    }
}

// MARK: - System card sheet

/// One system card as a short sheet: a symbol, a title, one or two sentences and at most two
/// buttons. Calm (2.10): no red, no count, no blame. Swiping it away answers nothing.
struct SystemCardSheet: View {
    /// What RootView does once the sheet has closed.
    enum FollowUp {
        case openSettings
        case widgetGuide
    }

    let card: SystemCardQueue.Card
    /// Closes the sheet; the follow-up runs after it has closed.
    let close: (FollowUp?) -> Void

    @EnvironmentObject private var model: AppModel
    @State private var height: CGFloat = 0
    /// "Saati değiştir" was tapped: the time picker is open in the card.
    @State private var isPickingTime = false
    @State private var pickedTime = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: symbol)
                        .font(.title2)
                        .foregroundStyle(card == .progressRecovered ? Theme.caution : Theme.ink)
                        .frame(width: 32)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                            .accessibilityAddTraits(.isHeader)
                        Text(message)
                            .font(.body)
                            .foregroundStyle(Theme.ink2)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if isPickingTime {
                    DatePicker("Hatırlatma saati", selection: $pickedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }
                buttons
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 16)
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.size.height
            } action: { newHeight in
                height = newHeight
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .presentationDetents(detents)
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.bg)
    }

    /// As tall as the card plus the home indicator's strip; it scrolls when the text is larger
    /// than the screen. Half the screen until the card has been measured.
    private var detents: Set<PresentationDetent> {
        if height > 0 {
            return [.height(height + 34)]
        }
        return [.medium]
    }

    @ViewBuilder
    private var buttons: some View {
        VStack(spacing: 10) {
            switch card {
            case .progressRecovered:
                Button("Anladım") {
                    model.dismissProgressRecovery()
                    close(nil)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
            case .remindersPaused:
                Button("Tamam") {
                    close(nil)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
                Button("Ayarlar'a git") {
                    close(.openSettings)
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
            case .reminderTime:
                if isPickingTime {
                    Button("Kaydet") {
                        saveTime()
                    }
                    .buttonStyle(PrimaryCapsuleButtonStyle())
                    Button("Vazgeç") {
                        isPickingTime = false
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                } else {
                    Button("Saati değiştir") {
                        pickedTime = SystemCardSheet.date(minuteOfDay: model.reminderMinuteOfDay)
                        isPickingTime = true
                    }
                    .buttonStyle(PrimaryCapsuleButtonStyle())
                    Button("Böyle kalsın") {
                        ReminderLog.noteTimeQuestionAnswered()
                        close(nil)
                    }
                    .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                }
            case .widgetTip:
                Button("Nasıl eklenir?") {
                    close(.widgetGuide)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
                Button("Şimdi değil") {
                    close(nil)
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
            case .breakStart, .dayEnd:
                // Shown by their screens, never as a sheet.
                Button("Tamam") {
                    close(nil)
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
            }
        }
    }

    /// The new time is saved and the week's reminders are planned again at once.
    private func saveTime() {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: pickedTime)
        model.setReminderMinuteOfDay((parts.hour ?? 20) * 60 + (parts.minute ?? 0))
        ReminderLog.noteTimeQuestionAnswered()
        let reminders = model.reminderPlan()
        Task {
            await ReminderScheduler.replace(with: reminders)
        }
        close(nil)
    }

    private var symbol: String {
        switch card {
        case .progressRecovered: return "exclamationmark.triangle.fill"
        case .remindersPaused: return "bell.slash"
        case .reminderTime: return "clock"
        case .widgetTip: return "apps.iphone"
        case .breakStart, .dayEnd: return "sun.max"
        }
    }

    private var title: String {
        switch card {
        case .progressRecovered: return "İlerleme dosyası okunamadı"
        case .remindersPaused: return "Hatırlatmaları duraklattık"
        case .reminderTime: return "Hatırlatma saatini değiştirelim mi?"
        case .widgetTip: return "Kelimeler kilit ekranında da görünsün mü?"
        case .breakStart: return "Ara verdin, sorun değil."
        case .dayEnd: return "Bugünlük yeter."
        }
    }

    private var message: String {
        switch card {
        case .progressRecovered:
            return SystemCardSheet.recoveryMessage(model.progressRecovery)
        case .remindersPaused:
            // No win-back text: the widget is enough contact with the words (2.10).
            return "İstersen Ayarlar'dan yeniden açabilirsin."
        case .reminderTime:
            let time = SystemCardSheet.clockTime(minuteOfDay: model.reminderMinuteOfDay)
            return "Şu anki saat: \(time). Başka bir saat sana daha uygun olabilir."
        case .widgetTip:
            return "Widget ekleyince telefonuna her baktığında bir kelime görürsün; uygulamayı açman gerekmez."
        case .breakStart, .dayEnd:
            return ""
        }
    }

    /// Same wording as the notice in "Ayarlar", which stays until "Anladım".
    static func recoveryMessage(_ outcome: ProgressStore.LoadOutcome?) -> String {
        switch outcome {
        case let .restoredFromBackup(_, backupDate)?:
            if let date = backupDate {
                return "İlerleme dosyası okunamadı, \(date.formatted(date: .long, time: .shortened)) tarihli yedekten geri yüklendi. Ondan sonraki değişiklikler kaybolmuş olabilir."
            }
            return "İlerleme dosyası okunamadı, yedekten geri yüklendi. Son değişiklikler kaybolmuş olabilir."
        case .startedOver?:
            return "İlerleme dosyası okunamadı ve yedek yoktu, ilerleme sıfırdan başladı. Eski dosya silinmedi; sonraki bir sürüm onu kurtarabilir."
        case .fresh?, .loaded?, nil:
            return ""
        }
    }

    /// "20:00", never followed by a suffix (README rule 13).
    static func clockTime(minuteOfDay: Int) -> String {
        return String(format: "%02d:%02d", minuteOfDay / 60, minuteOfDay % 60)
    }

    /// Today at `minuteOfDay`; only the hour and minute are used.
    static func date(minuteOfDay: Int) -> Date {
        return Calendar.current.date(
            bySettingHour: minuteOfDay / 60,
            minute: minuteOfDay % 60,
            second: 0,
            of: Date()
        ) ?? Date()
    }
}
