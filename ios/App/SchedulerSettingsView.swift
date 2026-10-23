import SwiftUI
import Learning

/// "Yeni zamanlama (deneme)" (docs/ozellik_planlari/fsrs.md): the switch to FSRS and back, what
/// changes (the cost first, §2.9), what stays the same, how to undo it, and whether the waits are
/// fitted to the user's own answers yet. Calm text only: no praise, no streaks, no percentages.
struct SchedulerSettingsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var isOn = false
    @State private var hasLoaded = false
    /// The last switch could not be saved; the old order goes on.
    @State private var saveFailed = false
    /// `model.fsrsFitSummary`, read on appear and after every switch (it lives in UserDefaults).
    @State private var fitSummary: (answers: Int, isPersonal: Bool)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                switchSection
                infoSection("Nasıl çalışır?", lines: [
                    "Tekrarlar arasındaki bekleme senin cevaplarından hesaplanır. Bunu FSRS adlı bir model yapar.",
                    "İyi bildiğin kelimeler daha seyrek gelir. Zorlandığın kelimeler daha erken gelir."
                ])
                infoSection("Ne değişir?", lines: [
                    "Yeni bir kelimede “Zor” dersen, kelime yaklaşık 15 dakika sonra yine gelir.",
                    "Yeni bir kelimede ilk “Bildim” 1 gün değil, 2 gün bekler.",
                    "İyi bildiğin bir kelime en çok bir yıl bekleyebilir."
                ])
                infoSection("Ne aynı kalır?", lines: [
                    "Basamak 1–5 ve “Yerleşti” aynı kalır. Basamak, kelimenin ne kadar beklediğini gösterir. Örneğin basamak 3 yaklaşık 4–8 gün demek.",
                    "“Biliyorum” dediğin kelime 3 gün sonra bir kez sorulur.",
                    "Açtığın gün kelimelerin ve tekrar tarihleri değişmez."
                ])
                infoSection("Geri dönmek", lines: [
                    "İstediğin zaman kapatabilirsin. Kapatınca kelimeler bulundukları basamaktan eski düzenle devam eder. İlerlemen kaybolmaz."
                ])
                fitSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Yeni zamanlama")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasLoaded {
                isOn = model.usesFSRS
                hasLoaded = true
            }
            fitSummary = model.fsrsFitSummary
        }
    }

    // MARK: Switch

    private var switchBinding: Binding<Bool> {
        return Binding(
            get: { isOn },
            set: { setEnabled($0) }
        )
    }

    /// A failed save puts the switch back and says so; VoiceOver hears the result either way.
    private func setEnabled(_ enabled: Bool) {
        isOn = enabled
        let saved = model.setFSRSEnabled(enabled)
        let message: String
        if saved {
            saveFailed = false
            message = enabled ? "Yeni zamanlama açık." : "Yeni zamanlama kapalı. Eski düzen devam ediyor."
        } else {
            isOn = model.usesFSRS
            saveFailed = true
            message = "Ayar kaydedilemedi. Eski düzen devam ediyor."
        }
        fitSummary = model.fsrsFitSummary
        AccessibilityNotification.Announcement(AttributedString(message)).post()
    }

    /// "deneme" said once, then the switch (off by default) and the calm line after a failed save.
    private var switchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bu zamanlama deneniyor. İleride değişebilir.")
                .font(.subheadline)
                .foregroundStyle(Theme.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
            SettingsGroup {
                Toggle(isOn: switchBinding) {
                    Text("Yeni zamanlamayı kullan")
                        .settingsRowTitle()
                        .fixedSize(horizontal: false, vertical: true)
                }
                // A switch is on in `good` green, as in iOS (as "Her gün hatırlat").
                .tint(Theme.good)
                .settingsRowPadding()
            }
            if saveFailed {
                Text("Ayar kaydedilemedi. Eski düzen devam ediyor.")
                    .settingsFootnote()
            }
        }
    }

    // MARK: Text

    /// A heading over a group of short sentences.
    private func infoSection(_ title: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader(title)
            SettingsGroup {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(lines, id: \.self) { line in
                        Text(verbatim: line)
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(14)
            }
        }
    }

    /// Whether the waits come from the user's own answers yet (`FSRSParameterFit`), in counts.
    private var fitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Senin cevapların")
            SettingsGroup {
                Text(verbatim: fitText)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
            }
        }
    }

    private var fitText: String {
        let minimum = FSRSParameterFit.minimumAnswers
        guard let summary = fitSummary else {
            return "Aralıklar önce herkes için hazırlanmış ayarlarla başlar. \(minimum) cevaptan sonra senin cevaplarına göre ayarlanır."
        }
        if summary.isPersonal {
            return "Aralıklar senin \(summary.answers) cevabına göre ayarlandı."
        }
        return "\(minimum) cevaptan sonra aralıklar senin cevaplarına göre ayarlanır. Şimdiye kadar \(summary.answers) cevap var."
    }
}
