import SwiftUI
import CoreModels
import Learning

/// "Ayarlar": start level and topics, widget rotation interval, daily new words, progress counts
/// (and the known words), help (widget guide, onboarding again), progress reset, and a notice
/// when the progress file had to be recovered.
struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openURL) private var openURL
    @State private var showResetConfirmation = false
    /// Notification permission was refused (now or earlier in iOS Settings).
    @State private var notificationsDenied = false

    var body: some View {
        NavigationStack {
            Form {
                recoverySection
                deckSection
                rotationSection
                goalSection
                reminderSection
                progressSection
                helpSection
                resetSection
                diagnosticsSection
            }
            .navigationTitle("Ayarlar")
            .confirmationDialog(
                "İlerleme sıfırlansın mı?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("İlerlemeyi sıfırla", role: .destructive) {
                    model.resetProgress()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Bildiğin ve öğrendiğin tüm kelimelerin kaydı silinir. Bu işlem geri alınamaz.")
            }
            .task {
                notificationsDenied = await ReminderScheduler.isDenied()
            }
        }
    }

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
        } else {
            model.setReminderEnabled(false)
        }
        await ReminderScheduler.replace(with: model.reminderPlan())
    }

    private var reminderSection: some View {
        Section {
            Toggle("Günlük hatırlatma", isOn: reminderBinding)
            if model.reminderEnabled {
                DatePicker("Saat", selection: reminderTimeBinding, displayedComponents: .hourAndMinute)
            }
            if notificationsDenied {
                Button("Bildirim iznini aç") {
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        openURL(url)
                    }
                }
            }
        } header: {
            Text("Hatırlatma")
        } footer: {
            if notificationsDenied {
                Text("Bildirimlere izin verilmemiş. iPhone Ayarları'nda Lockglow için bildirimleri aç.")
            } else {
                Text("Seçtiğin saatte, o gün kaç kelimenin tekrar beklediğini söyleyen bir bildirim gelir. O günün tekrarını ve yeni kelimelerini bitirdiysen gelmez.")
            }
        }
    }

    private var rotationBinding: Binding<Int> {
        return Binding(
            get: { model.rotationMinutes },
            set: { model.setRotationMinutes($0) }
        )
    }

    private var dailyBinding: Binding<Int> {
        return Binding(
            get: { model.dailyNewWords },
            set: { model.setDailyNewWords($0) }
        )
    }

    private var levelBinding: Binding<Level> {
        return Binding(
            get: { model.deckChoice.startLevel ?? .a1 },
            set: { model.setStartLevel($0) }
        )
    }

    private var topicSummary: String {
        let count = model.activeTopicIDs.count
        return count == 0 ? "Tümü" : "\(count) konu"
    }

    private var deckSection: some View {
        Section {
            Picker("Başlangıç seviyesi", selection: levelBinding) {
                ForEach(AppPreferences.startLevelChoices, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            if !model.choosableTopics.isEmpty {
                NavigationLink {
                    TopicPickerView()
                } label: {
                    LabeledContent("Konular", value: topicSummary)
                }
            }
        } header: {
            Text("Öğrenme")
        } footer: {
            Text("Yeni kelimeler bu seviyeden başlar. Widget'ta, Akış'ta ve yeni kelimelerde yalnız seçtiğin konular döner (şu an \(model.feedWords.count) kelime). Değiştirince widget'taki kelime bir sonraki değişime kadar aynı kalır.")
        }
    }

    private var helpSection: some View {
        Section("Yardım") {
            NavigationLink("Widget nasıl eklenir?") {
                WidgetGuideScreen()
            }
            Button("Açılış ekranlarını yeniden göster") {
                model.showOnboarding()
            }
        }
    }

    private var rotationSection: some View {
        Section {
            Picker("Kelime değişim sıklığı", selection: rotationBinding) {
                ForEach(AppPreferences.rotationMinuteChoices, id: \.self) { minutes in
                    Text(intervalLabel(minutes)).tag(minutes)
                }
            }
        } header: {
            Text("Widget")
        } footer: {
            Text("Widget'taki kelime bu sıklıkla değişir. Değiştirince şu an görünen kelime aynı kalır.")
        }
    }

    private var goalSection: some View {
        Section {
            Picker("Günlük yeni kelime", selection: dailyBinding) {
                ForEach(AppPreferences.dailyNewWordChoices, id: \.self) { count in
                    Text("\(count)").tag(count)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Günlük hedef")
        } footer: {
            Text("Tekrar sekmesi günde bu kadar yeni kelime önerir.")
        }
    }

    private var progressSection: some View {
        let counts = model.progressCounts()
        return Section("İlerleme") {
            NavigationLink {
                KnownWordsView()
            } label: {
                LabeledContent("Bildiğim kelime", value: "\(counts.known)")
            }
            LabeledContent("Öğrenmekte olduğum", value: "\(counts.learning)")
            LabeledContent("Bugün tekrar edilecek", value: "\(counts.dueToday)")
        }
    }

    private var resetSection: some View {
        Section {
            Button("İlerlemeyi sıfırla", role: .destructive) {
                showResetConfirmation = true
            }
        }
    }

    private var diagnosticsSection: some View {
        Section("Tanılama") {
            NavigationLink("Widget sağlığı") {
                WidgetHealthView()
            }
        }
    }

    @ViewBuilder
    private var recoverySection: some View {
        if let outcome = model.progressRecovery {
            Section {
                Label {
                    Text(recoveryMessage(outcome))
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
                Button("Anladım") {
                    model.dismissProgressRecovery()
                }
            } header: {
                Text("İlerleme dosyası")
            }
        }
    }

    private func recoveryMessage(_ outcome: ProgressStore.LoadOutcome) -> String {
        switch outcome {
        case let .restoredFromBackup(_, backupDate):
            if let date = backupDate {
                return "İlerleme dosyası okunamadı, \(date.formatted(date: .long, time: .shortened)) tarihli yedekten geri yüklendi. Ondan sonraki değişiklikler kaybolmuş olabilir."
            }
            return "İlerleme dosyası okunamadı, yedekten geri yüklendi. Son değişiklikler kaybolmuş olabilir."
        case .startedOver:
            return "İlerleme dosyası okunamadı ve yedek yoktu, ilerleme sıfırdan başladı. Eski dosya silinmedi; sonraki bir sürüm onu kurtarabilir."
        case .fresh, .loaded:
            return ""
        }
    }

    private func intervalLabel(_ minutes: Int) -> String {
        if minutes >= 60 && minutes % 60 == 0 {
            return "\(minutes / 60) saat"
        }
        return "\(minutes) dakika"
    }
}
