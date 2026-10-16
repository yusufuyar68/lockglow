import SwiftUI
import Learning

/// "Ayarlar": widget rotation interval, daily new words, progress counts (and the known words),
/// progress reset, and a notice when the progress file had to be recovered.
struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                recoverySection
                rotationSection
                goalSection
                progressSection
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
