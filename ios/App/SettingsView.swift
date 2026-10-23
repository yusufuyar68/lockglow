import SwiftUI
import CoreModels
import Learning

/// "Ayarlar": the widget (its health and how often the word changes), learning (start level,
/// topics, new words a day), the reminder, progress (and the known words), help (widget guide,
/// onboarding again, version), progress reset at the very bottom, and a notice when the progress
/// file had to be recovered.
///
/// Plain groups on the page background (mockup `#ayarlar`) instead of a `Form`: every option is
/// an always-visible 46 pt segment (`SegmentButtons`) under a question ("Günde kaç yeni
/// kelime?") with a short, concrete footnote ("bir ayda yaklaşık 300 kelime"), never a menu or a
/// 32 pt segmented picker, and every row exists without scrolling a lazy list (the UI tests look
/// rows up by label).
struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    /// "Tekrar'a git" on the empty library ("Kitaplığın ve bu hafta"): RootView opens "Tekrar".
    var openReview: (() -> Void)? = nil
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showResetConfirmation = false
    /// Notification permission was refused (now or earlier in iOS Settings).
    @State private var notificationsDenied = false
    /// The user picked the daily goal; until then the start level decides it. A state, not a
    /// read of UserDefaults, so a tap on the number already selected (`SegmentButtons` sets the
    /// binding on every tap) also redraws the footnote.
    @State private var isDailyGoalChosen = AppPreferences.chosenDailyNewWords != nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    recoverySection
                    widgetSection
                    learningSection
                    reminderSection
                    progressSection
                    helpSection
                    resetSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                // Room above the tab bar (floating glass on iOS 26) for the last button.
                .padding(.bottom, 40)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Ayarlar")
            .confirmationDialog(
                "İlerleme sıfırlansın mı?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("İlerlemeyi sıfırla", role: .destructive) {
                    resetProgress()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                // Everything `resetProgress()` clears, and the one thing it keeps.
                Text("Bildiğin ve öğrendiğin kelimelerin kaydı, kullanım ölçümleri, son aramalar ve Akış geçmişi silinir. Kendi eklediğin kelimeler kalır ama baştan başlar. Bu işlem geri alınamaz.")
            }
            .task {
                await refreshStatus()
            }
            // Back from iOS Settings (notification permission) or from placing a widget.
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task {
                        await refreshStatus()
                    }
                }
            }
        }
    }

    /// The progress, today's counts, the local measurements, the feed's first encounters,
    /// Sözlük's recent searches and the words "Tekrar" listed as today's new words (they are new
    /// again): all in `AppModel.resetProgress`. The user's own words stay; their progress goes
    /// with the rest. VoiceOver hears that it is done: the dialog just closes.
    private func resetProgress() {
        model.resetProgress()
        AccessibilityNotification.Announcement(AttributedString("İlerleme sıfırlandı.")).post()
    }

    private func refreshStatus() async {
        notificationsDenied = await ReminderScheduler.isDenied()
        await model.refreshHealth()
    }

    // MARK: Widget

    private var rotationBinding: Binding<Int> {
        return Binding(
            get: { model.rotationMinutes },
            set: { model.setRotationMinutes($0) }
        )
    }

    /// The widget's state first (the details are one tap away), then how often the word changes.
    private var widgetSection: some View {
        let status = WidgetHealthStatus(of: model)
        return VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Widget")
            SettingsGroup {
                widgetStatusRow(status)
            }
            if status == .notUpdating {
                Text("Yukarıdaki satıra dokun, sonra Widget'ları yenile düğmesine dokun. Düzelmezse widget'ı kaldırıp yeniden ekle.")
                    .settingsFootnote()
            }
            SettingsQuestion("Kelime ne sıklıkla değişsin?")
            SegmentButtons(
                options: AppPreferences.rotationMinuteChoices.map { minutes in
                    SegmentOption(value: minutes, title: intervalLabel(minutes), spokenTitle: spokenIntervalLabel(minutes))
                },
                selection: rotationBinding
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Kelime değişim sıklığı")
            rotationFootnote
        }
    }

    /// No widget: a calm row to the widget guide ("Widget ekli değil · Nasıl eklenir?"), never a
    /// warning. Otherwise "Widget sağlığı" with its verdict, to the details.
    @ViewBuilder
    private func widgetStatusRow(_ status: WidgetHealthStatus) -> some View {
        if status == .notAdded {
            NavigationLink {
                WidgetGuideScreen(word: model.widgetGuideWord)
            } label: {
                SettingsRow("Widget ekli değil", systemImage: "plus.circle") {
                    Text("Nasıl eklenir?")
                }
            }
            .buttonStyle(SettingsRowButtonStyle())
        } else {
            NavigationLink {
                WidgetHealthView()
            } label: {
                SettingsRow("Widget sağlığı", systemImage: "waveform.path.ecg") {
                    WidgetHealthBadge(status: status)
                }
            }
            .buttonStyle(SettingsRowButtonStyle())
        }
    }

    /// "30 dk", "1 saat", "4 saat": short enough for four segments side by side.
    private func intervalLabel(_ minutes: Int) -> String {
        if minutes >= 60 && minutes % 60 == 0 {
            return "\(minutes / 60) saat"
        }
        return "\(minutes) dk"
    }

    /// `intervalLabel` for VoiceOver, the unit in full: "30 dakika", "1 saat" (audit V12).
    private func spokenIntervalLabel(_ minutes: Int) -> String {
        if minutes >= 60 && minutes % 60 == 0 {
            return "\(minutes / 60) saat"
        }
        return "\(minutes) dakika"
    }

    /// What the choice means in a day ("Kelime günde 24 kez değişir."), and the honest note that
    /// iOS may delay a change to save the battery (§2.9 keeps it).
    private var rotationFootnote: some View {
        let changesPerDay = 24 * 60 / max(1, model.rotationMinutes)
        return Text("Kelime günde **\(changesPerDay)** kez değişir. Değiştirince şu an görünen kelime aynı kalır. iPhone, pili korumak için yenilemeyi biraz geciktirebilir.")
            .settingsFootnote()
    }

    // MARK: Learning

    private var startLevel: Level {
        return model.deckChoice.startLevel ?? .a1
    }

    /// A goal the user never chose follows the new level (A1–A2: 5, B1: 10); `AppModel` keeps its
    /// own copy of the goal, so it is handed the level's number (`AppPreferences.dailyNewWords`).
    /// Keep the order: the level is saved first, so the goal's setter sees the new level and does
    /// not save its number as the user's choice.
    private var levelBinding: Binding<Level> {
        return Binding(
            get: { startLevel },
            set: { level in
                model.setStartLevel(level)
                model.setDailyNewWords(AppPreferences.dailyNewWords)
            }
        )
    }

    private var topicSummary: String {
        let count = model.activeTopicIDs.count
        return count == 0 ? "Tümü" : "\(count) konu"
    }

    /// A tap is the user's own choice, also on the number already selected: it stays whatever
    /// the level (`chooseDailyNewWords`).
    private var dailyBinding: Binding<Int> {
        return Binding(
            get: { model.dailyNewWords },
            set: { count in
                AppPreferences.chooseDailyNewWords(count)
                isDailyGoalChosen = true
                model.setDailyNewWords(count)
            }
        )
    }

    /// The start level and topics, then the daily goal. Each footnote says what the choice
    /// means: what the level covers, and what the goal costs as well as what it brings (§2.9).
    /// The level footnote sits under "Konular" (mockup), which keeps that row high enough on an
    /// iPhone SE for the UI test to tap it above the tab bar.
    private var learningSection: some View {
        let code = startLevel.rawValue
        let summary = levelSummary(startLevel)
        return VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Öğrenme")
            SettingsQuestion("Hangi seviyeden başlayalım?")
            SegmentButtons(
                options: AppPreferences.startLevelChoices.map { level in
                    SegmentOption(value: level, title: level.rawValue)
                },
                selection: levelBinding
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Başlangıç seviyesi")
            if !model.choosableTopics.isEmpty {
                SettingsGroup {
                    NavigationLink {
                        TopicPickerView()
                    } label: {
                        SettingsRow("Konular") {
                            Text(verbatim: topicSummary)
                        }
                    }
                    .buttonStyle(SettingsRowButtonStyle())
                }
                .padding(.top, 4)
            }
            Group {
                if model.newWordsComeFromAllTopics {
                    Text("**\(code)** · \(summary) Yeni kelimeler bu seviyeden başlar.\nSeçtiğin konuların yeni kelimeleri bitti; yeni kelimeler diğer konulardan geliyor.")
                } else {
                    Text("**\(code)** · \(summary) Yeni kelimeler bu seviyeden başlar.")
                }
            }
            .settingsFootnote()

            SettingsQuestion("Günde kaç yeni kelime?")
                .padding(.top, 12)
            SegmentButtons(
                options: AppPreferences.dailyNewWordChoices.map { count in
                    SegmentOption(value: count, title: "\(count)")
                },
                selection: dailyBinding
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Günlük yeni kelime")
            dailyGoalFootnote
        }
    }

    /// The cost of the goal before its gain (§2.9): "Günde en az 7 dakika, tekrarlar dahil. Bir
    /// ayda yaklaşık 150 kelime." The minutes are a floor (`SettingsRules.minimumMinutesPerDay`),
    /// hence "en az" until they are measured on a device. Then tomorrow's share of the load:
    /// "Bildim" puts a new word in Leitner box 1, back the next day ("Kolay" waits two days, a
    /// widget glance is no review), hence "çoğu". A goal nobody chose says where it came from,
    /// so a jump after a level change is not a surprise.
    private var dailyGoalFootnote: some View {
        let goal = model.dailyNewWords
        let minutes = SettingsRules.minimumMinutesPerDay(dailyNewWords: goal)
        return VStack(alignment: .leading, spacing: 4) {
            Text("Günde en az **\(minutes) dakika**, tekrarlar dahil. Bir ayda yaklaşık **\(goal * 30)** kelime.")
            Text("Bugün öğrendiğin kelimelerin çoğu yarın tekrar sorulur.")
            if !isDailyGoalChosen {
                Text("Bu sayı seviyene göre seçildi: A1 ve A2 için 5, B1 için 10.")
            }
        }
        .settingsFootnote()
    }

    /// What a start level covers, in the words of the onboarding's level page.
    private func levelSummary(_ level: Level) -> String {
        switch level {
        case .a1: return "Ev, yemek, aile gibi en temel kelimeler."
        case .a2: return "Alışveriş, yol, randevu: günlük hayat."
        case .b1: return "İş, seyahat, duygular; daha uzun cümleler."
        default: return ""
        }
    }

    // MARK: Reminder

    private var reminderBinding: Binding<Bool> {
        return Binding(
            get: { model.reminderEnabled },
            set: { isOn in
                Task {
                    await setReminder(isOn)
                }
            }
        )
    }

    /// Today at the reminder time; only the hour and minute are used.
    private var reminderTimeBinding: Binding<Date> {
        return Binding(
            get: {
                let minute = model.reminderMinuteOfDay
                return Calendar.current.date(
                    bySettingHour: minute / 60,
                    minute: minute % 60,
                    second: 0,
                    of: Date()
                ) ?? Date()
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                model.setReminderMinuteOfDay((parts.hour ?? 20) * 60 + (parts.minute ?? 0))
                let reminders = model.reminderPlan()
                Task {
                    await ReminderScheduler.replace(with: reminders)
                }
            }
        )
    }

    /// Turning it on asks for notification permission; if that is refused the switch stays off.
    private func setReminder(_ isOn: Bool) async {
        if isOn {
            let granted = await ReminderScheduler.requestPermission()
            notificationsDenied = !granted
            model.setReminderEnabled(granted)
            if !granted {
                AccessibilityNotification.Announcement(AttributedString("Bildirim izni yok. Hatırlatma kapalı kaldı.")).post()
            }
        } else {
            model.setReminderEnabled(false)
        }
        await ReminderScheduler.replace(with: model.reminderPlan())
    }

    /// A week of ignored reminders turned them off at an opening (`ReminderLog.pause`, RootView);
    /// the note stays until they are on again (turning them on clears the pause).
    private var isReminderPaused: Bool {
        return ReminderLog.pausedAt() != nil && !model.reminderEnabled
    }

    /// The feature is "hatırlatma" (terimler §5); iOS's permission keeps its own name, "bildirim".
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Hatırlatma")
            SettingsQuestion("Ne zaman hatırlatalım?")
            SettingsGroup {
                Toggle(isOn: reminderBinding) {
                    Text("Her gün hatırlat")
                        .settingsRowTitle()
                }
                // A switch is on in `good` green, as in iOS (never yellow, never ink).
                .tint(Theme.good)
                .settingsRowPadding()
                if model.reminderEnabled {
                    SettingsDivider()
                    DatePicker(selection: reminderTimeBinding, displayedComponents: .hourAndMinute) {
                        Text("Saat")
                            .settingsRowTitle()
                    }
                    // 24-hour "20:00" like the app's other times (clockTime, README point 13), whatever the region.
                    .environment(\.locale, Locale(identifier: "tr_TR"))
                    .settingsRowPadding()
                }
                if isReminderPaused && !notificationsDenied {
                    SettingsDivider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bir hafta bakılmadığı için hatırlatmaları duraklattık.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            Task {
                                await setReminder(true)
                            }
                        } label: {
                            Label("Hatırlatmayı yeniden aç", systemImage: "bell")
                        }
                        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                    }
                    .padding(14)
                }
                if notificationsDenied {
                    SettingsDivider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bildirimlere izin verilmemiş. iPhone Ayarları'nda Lockglow için bildirimleri aç.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                                openURL(url)
                            }
                        } label: {
                            Label("Bildirim iznini aç", systemImage: "bell")
                        }
                        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, tonal: true))
                    }
                    .padding(14)
                }
            }
            // The reminder carries a word, not counts (`Learning/ReminderText`). The week-long
            // pause is said in its own row above, when it happens.
            Text("Seçtiğin saatte bir kelimeyle kısa bir hatırlatma gelir. O günün işini bitirdiysen gelmez.")
                .settingsFootnote()
        }
    }

    // MARK: Progress

    private var progressSection: some View {
        let counts = model.progressCounts()
        let tileLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 8))
        let levels = levelProgress
        return VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("İlerleme")
            VStack(spacing: 16) {
                tileLayout {
                    ProgressTile(value: counts.known, caption: "bildiğin kelime", isStacked: dynamicTypeSize.isAccessibilitySize)
                    ProgressTile(value: counts.learning, caption: "öğrenme listende", isStacked: dynamicTypeSize.isAccessibilitySize)
                    ProgressTile(value: counts.dueToday, caption: "bugün tekrar edilecek", isStacked: dynamicTypeSize.isAccessibilitySize)
                }
                .fixedSize(horizontal: false, vertical: true)
                if !levels.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(levels) { item in
                            LevelProgressRow(item: item)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 2)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .settingsGroupBackground()
            SettingsGroup {
                NavigationLink {
                    ProgressScreen(onStartReview: openReview)
                } label: {
                    SettingsRow("Kitaplığın ve bu hafta")
                }
                .buttonStyle(SettingsRowButtonStyle())
                SettingsDivider()
                NavigationLink {
                    KnownWordsView()
                } label: {
                    SettingsRow("Bildiğin kelimeler") {
                        Text(verbatim: "\(counts.known)")
                            .monospacedDigit()
                    }
                }
                .buttonStyle(SettingsRowButtonStyle())
                SettingsDivider()
                // Words the user heard and added; they rotate with the cards (CustomWordsView).
                NavigationLink {
                    CustomWordsView(library: model.customWordLibrary, cardMeaning: model.lookup(lemma:))
                } label: {
                    SettingsRow("Kendi kelimelerin") {
                        Text(verbatim: "\(model.customWordLibrary.words.count)")
                            .monospacedDigit()
                    }
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
            .padding(.top, 4)
        }
    }

    /// Known words of each offered level out of all its words; levels without words are left out.
    private var levelProgress: [LevelProgress] {
        var totals: [Level: Int] = [:]
        var known: [Level: Int] = [:]
        for word in model.words {
            guard let level = word.levelValue else {
                continue
            }
            totals[level, default: 0] += 1
            if model.progress[word.id]?.state == .known {
                known[level, default: 0] += 1
            }
        }
        return AppPreferences.startLevelChoices.compactMap { level in
            guard let total = totals[level], total > 0 else {
                return nil
            }
            return LevelProgress(level: level, known: known[level] ?? 0, total: total)
        }
    }

    // MARK: Help and reset

    private var helpSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Yardım")
            SettingsGroup {
                NavigationLink {
                    LearningGuideView(dailyNewWords: model.dailyNewWords, rotationMinutes: model.rotationMinutes)
                } label: {
                    SettingsRow("Nasıl öğrenirim?")
                }
                .buttonStyle(SettingsRowButtonStyle())
                SettingsDivider()
                NavigationLink {
                    WidgetGuideScreen(word: model.widgetGuideWord)
                } label: {
                    SettingsRow("Widget nasıl eklenir?")
                }
                .buttonStyle(SettingsRowButtonStyle())
                SettingsDivider()
                Button {
                    model.showOnboarding()
                } label: {
                    SettingsRow("Açılış ekranlarını yeniden göster")
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
            versionLine
        }
    }

    /// The only dangerous action, last on the page and apart from the rest: a calm bordered
    /// capsule with `bad` text (the word says it, the color repeats it), never a filled red
    /// button. It only opens the confirmation; nothing is deleted without "İlerlemeyi sıfırla".
    private var resetSection: some View {
        Button(role: .destructive) {
            showResetConfirmation = true
        } label: {
            Label("İlerlemeyi sıfırla", systemImage: "arrow.counterclockwise")
                .foregroundStyle(Theme.bad)
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
        .padding(.top, 8)
    }

    /// "Lockglow 1.0 · içerik 2026.10.21 (933 kelime)".
    private var versionLine: some View {
        var text = "Lockglow"
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            text += " \(version)"
        }
        if let content = model.contentVersion {
            text += " · içerik \(content)"
        }
        if model.cardCount > 0 {
            text += " (\(model.cardCount) kelime)"
        }
        return Text(verbatim: text)
            .settingsFootnote()
    }

    // MARK: Recovery

    /// The progress file had to be recovered (mockup `.banner`): above everything until "Anladım".
    @ViewBuilder
    private var recoverySection: some View {
        if let outcome = model.progressRecovery {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.caution)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: SystemCardSheet.recoveryTitle)
                            .font(.subheadline.weight(.semibold))
                        Text(verbatim: SystemCardSheet.recoveryMessage(outcome))
                            .font(.subheadline)
                    }
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityElement(children: .combine)
                    Button("Anladım") {
                        model.dismissProgressRecovery()
                    }
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
    }
}

// MARK: - Progress parts

/// Known words of one level for the "İlerleme" bars.
private struct LevelProgress: Identifiable {
    let level: Level
    let known: Int
    let total: Int

    var id: Level { level }
}

/// One count of "İlerleme" (mockup `.tile`): a large number over a short caption.
private struct ProgressTile: View {
    let value: Int
    let caption: String
    /// The tiles stand one under another (accessibility text sizes).
    var isStacked = false
    @ScaledMetric(relativeTo: .title) private var numberSize: CGFloat = 26

    var body: some View {
        VStack(spacing: 3) {
            Text(verbatim: "\(value)")
                // Grows with the text size, but not past 34 pt while three tiles share one row;
                // stacked, it keeps growing, so it is never smaller than its caption (audit D10).
                .font(.system(size: isStacked ? numberSize : min(numberSize, 34), weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(verbatim: caption)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.ink2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(caption): \(value)"))
    }
}

/// "A2 ▬▬▬──── 34 / 418" (mockup `.lvb`): known words of one level, the bar in `tint`. At the
/// accessibility text sizes the code and the count share a line over a full-width bar, so the
/// bar keeps its length (audit D9).
private struct LevelProgressRow: View {
    let item: LevelProgress
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        code
                        Spacer(minLength: 0)
                        count
                    }
                    bar
                }
            } else {
                HStack(spacing: 10) {
                    code
                    bar
                    count
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(item.level.rawValue): \(item.total) kelimeden \(item.known) kelimeyi biliyorsun"))
    }

    private var code: some View {
        Text(verbatim: item.level.rawValue)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Theme.ink)
            .frame(minWidth: 30, alignment: .leading)
    }

    private var count: some View {
        Text(verbatim: "\(item.known) / \(item.total)")
            .font(.caption.weight(.medium))
            .monospacedDigit()
            .foregroundStyle(Theme.ink2)
    }

    private var bar: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(Theme.surface2)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Theme.tint)
                        .frame(width: filledWidth(in: proxy.size.width))
                }
        }
        .frame(height: 8)
    }

    /// At least a dot once one word is known, so a small start still shows.
    private func filledWidth(in width: CGFloat) -> CGFloat {
        guard item.total > 0, item.known > 0 else {
            return 0
        }
        let fraction = min(1, CGFloat(item.known) / CGFloat(item.total))
        return max(8, width * fraction)
    }
}

// MARK: - Settings components (also used by "Widget sağlığı")

/// A group heading (mockup `.sgroup > h3`): sentence case, never upper-cased, a VoiceOver heading.
struct SettingsSectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(verbatim: title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.ink2)
            .textCase(nil)
            .padding(.horizontal, 4)
            .accessibilityAddTraits(.isHeader)
    }
}

/// The question above a row of options (mockup `.swrap .lab`): "Kelime ne sıklıkla değişsin?".
struct SettingsQuestion: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(verbatim: title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .textCase(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 4)
            .padding(.top, 6)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A white group of rows (mockup `.group`): `surface`, 20 pt corners, a `line` border. Rows are
/// separated with `SettingsDivider()`.
struct SettingsGroup<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .settingsGroupBackground()
    }
}

/// A hairline between the rows of a group, inset like iOS lists.
struct SettingsDivider: View {
    var inset: CGFloat = 14

    var body: some View {
        Rectangle()
            .fill(Theme.line)
            .frame(height: 1)
            .padding(.leading, inset)
            .accessibilityHidden(true)
    }
}

/// One row of a group (mockup `.row`): at least 52 pt, a title (with an optional icon), a value
/// in `ink2` and a chevron. Title and value share one line while both fit on it; otherwise (an
/// iPhone SE with a long value, large and accessibility text sizes) the value moves under the
/// title instead of squeezing the title into two lines.
struct SettingsRow<Value: View>: View {
    let title: String
    let systemImage: String?
    let showsChevron: Bool
    let value: Value
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        _ title: String,
        systemImage: String? = nil,
        showsChevron: Bool = true,
        @ViewBuilder value: () -> Value
    ) {
        self.title = title
        self.systemImage = systemImage
        self.showsChevron = showsChevron
        self.value = value()
    }

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    stacked
                } else {
                    ViewThatFits(in: .horizontal) {
                        sideBySide
                        stacked
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var sideBySide: some View {
        HStack(spacing: 12) {
            titleLabel
            Spacer(minLength: 0)
            styledValue
        }
    }

    private var stacked: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleLabel
            styledValue
        }
    }

    private var styledValue: some View {
        value
            .font(.body)
            .foregroundStyle(Theme.ink2)
    }

    private var titleLabel: some View {
        HStack(spacing: 10) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.body)
                    .foregroundStyle(Theme.ink2)
                    .frame(minWidth: 22)
                    .accessibilityHidden(true)
            }
            Text(verbatim: title)
                .settingsRowTitle()
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension SettingsRow where Value == EmptyView {
    init(_ title: String, systemImage: String? = nil, showsChevron: Bool = true) {
        self.init(title, systemImage: systemImage, showsChevron: showsChevron) {
            EmptyView()
        }
    }
}

/// Rows that are buttons or navigation links: ink text (never the blue default) and a soft
/// highlight while pressed.
struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Theme.ink)
            .background(configuration.isPressed ? Theme.tintSoft : Color.clear)
    }
}

/// The verdict after "Widget sağlığı": "✓ Çalışıyor" in `good`, "⚠ Güncellemiyor" in `bad` (a
/// placed widget that gets no words), otherwise a calm word in `ink2`. Icon and word together,
/// the color only repeats them (rule 4). The row without a widget is "Widget ekli değil" instead.
struct WidgetHealthBadge: View {
    let status: WidgetHealthStatus

    var body: some View {
        switch status {
        case .checking:
            EmptyView()
        case .working:
            badge("Çalışıyor", systemImage: "checkmark.circle.fill", color: Theme.good)
        case .notUpdating:
            badge("Güncellemiyor", systemImage: "exclamationmark.triangle.fill", color: Theme.bad)
        case .notAdded:
            Text("Ekli değil")
                .foregroundStyle(Theme.ink2)
        case .unknown:
            Text("Bilinmiyor")
                .foregroundStyle(Theme.ink2)
        }
    }

    private func badge(_ title: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .accessibilityHidden(true)
            Text(verbatim: title)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
    }
}

extension View {
    /// The `surface` card of a settings group: 20 pt continuous corners and a `line` border.
    func settingsGroupBackground() -> some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.group, style: .continuous)
        return background(Theme.surface, in: shape)
            .clipShape(shape)
            .overlay(shape.strokeBorder(Theme.line, lineWidth: 1))
    }

    /// The title of a settings row: `.body` medium, ink.
    func settingsRowTitle() -> some View {
        font(.body.weight(.medium))
            .foregroundStyle(Theme.ink)
    }

    /// Padding of a row that is a control itself (a switch, a time picker): 52 pt high.
    func settingsRowPadding() -> some View {
        padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
    }

    /// The explanation under a group (mockup `.foot-t`): footnote, `ink2`.
    func settingsFootnote() -> some View {
        font(.footnote)
            .foregroundStyle(Theme.ink2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
