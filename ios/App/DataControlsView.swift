import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import Learning

/// "Verilerin" (Ayarlar, İlerleme): a copy of everything to share (`ShareLink`), a backup from
/// another phone to join this one, and "Hepsini sil". The work is in AppModel+DataControls.swift;
/// the formats and rules are in Learning (DataExport, DataImport, DataErase).
struct DataControlsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    /// The files of the last export, ready for the share sheet; nil until written.
    @State private var exported: (backup: URL, tables: [URL])?
    @State private var exportFailed = false
    @State private var showsImporter = false
    /// The backup picked, read and checked, waiting for "İçe aktar".
    @State private var pending: PendingImport?
    @State private var importMessage: String?
    @State private var showsEraseConfirmation = false

    private struct PendingImport: Identifiable {
        let id = UUID()
        let reading: DataArchive.Reading
        let summary: DataImport.Summary
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Verilerin yalnızca bu telefonda durur. Buradan bir kopyasını alabilir, başka telefona taşıyabilir ya da hepsini silebilirsin.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                exportSection
                importSection
                eraseSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Verilerin")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            prepareExport()
        }
        .fileImporter(isPresented: $showsImporter, allowedContentTypes: [.json]) { result in
            picked(result)
        }
        .sheet(item: $pending) { item in
            ImportConfirmationSheet(summary: item.summary) {
                pending = nil
                runImport(item.reading)
            } cancel: {
                pending = nil
            }
        }
        .alert("Bütün veriler silinsin mi?", isPresented: $showsEraseConfirmation) {
            Button("Hepsini sil", role: .destructive) {
                eraseAll()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("İlerlemen, bildiğin kelimeler, kendi eklediğin kelimeler, ayarların, ölçümler ve yedek kopyalar bu telefondan silinir. Uygulama ilk günkü gibi açılır. Bu işlem geri alınamaz.")
        }
    }

    // MARK: Export

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Dışa aktar")
            if let files = exported {
                SettingsGroup {
                    ShareLink(item: files.backup) {
                        SettingsRow("Yedek dosyasını paylaş", systemImage: "square.and.arrow.up", showsChevron: false) {
                            EmptyView()
                        }
                    }
                    .buttonStyle(SettingsRowButtonStyle())
                    SettingsDivider()
                    ShareLink(items: files.tables) {
                        SettingsRow("Tablo dosyalarını paylaş", systemImage: "tablecells", showsChevron: false) {
                            EmptyView()
                        }
                    }
                    .buttonStyle(SettingsRowButtonStyle())
                }
            } else if exportFailed {
                Text("Dosyalar hazırlanamadı. Telefonunda yer olduğundan emin ol, sonra bu sayfayı yeniden aç.")
                    .settingsFootnote()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            Text("İlerlemen, bildiğin kelimeler, kendi kelimelerin ve ölçümler dosyaya yazılır. Dosyayı nereye göndereceğini sen seçersin. Yeni telefona taşımak için yedek dosyasını kullan. Tablo dosyaları Numbers ya da Excel'de açılır.")
                .settingsFootnote()
        }
    }

    private func prepareExport() {
        do {
            exported = try model.writeExportFiles()
            exportFailed = false
        } catch {
            exported = nil
            exportFailed = true
        }
    }

    // MARK: Import

    private var importSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("İçe aktar")
            SettingsGroup {
                Button {
                    importMessage = nil
                    showsImporter = true
                } label: {
                    SettingsRow("Yedek dosyası seç", systemImage: "square.and.arrow.down", showsChevron: false) {
                        EmptyView()
                    }
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
            if let message = importMessage {
                Text(verbatim: message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
            }
            Text("Başka telefondan aldığın yedek dosyasını seç. Bu telefondaki veriler silinmez, ikisi birleşir. Ayarlar ve ölçümler bu telefondaki gibi kalır.")
                .settingsFootnote()
        }
    }

    private func picked(_ result: Result<URL, Error>) {
        guard case let .success(url) = result else {
            return
        }
        do {
            let reading = try AppModel.readBackup(at: url)
            guard let summary = model.importSummary(reading) else {
                show(DataImportFailure.notReady.message)
                return
            }
            if summary.isEmpty {
                show("Bu yedekte alınacak bir şey yok.")
                return
            }
            pending = PendingImport(reading: reading, summary: summary)
        } catch let failure as DataImportFailure {
            show(failure.message)
        } catch {
            show(DataImportFailure.unreadable.message)
        }
    }

    private func runImport(_ reading: DataArchive.Reading) {
        switch model.importData(reading) {
        case let .success(summary):
            if summary.changesNothing {
                show("Bu yedekteki her şey bu telefonda zaten var.")
            } else {
                show("İçe aktarma bitti. Yeni ya da güncellenen kelime: \(summary.wordsAdded + summary.wordsReplaced). Yeni kendi kelime: \(summary.customWordsAdded).")
            }
            prepareExport()
        case let .failure(failure):
            show(failure.message)
        }
    }

    private func show(_ message: String) {
        importMessage = message
        AccessibilityNotification.Announcement(AttributedString(message)).post()
    }

    // MARK: Erase

    private var eraseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader("Hepsini sil")
            Text("Bu telefondaki bütün Lockglow verisini siler: ilerleme, kendi kelimelerin, ayarlar, ölçümler ve yedek kopyalar. İlerlemeyi sıfırla bunlardan yalnız ilerlemeyi siler. Silmeden önce bir kopya istersen önce yedek dosyasını paylaş.")
                .settingsFootnote()
            if model.cloudSync.isEnabled {
                Text("iCloud'daki kopya kalır. Onu iCloud ile eşitle sayfasından silebilirsin.")
                    .settingsFootnote()
            }
            Button(role: .destructive) {
                showsEraseConfirmation = true
            } label: {
                Label("Hepsini sil", systemImage: "trash")
                    .foregroundStyle(Theme.bad)
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
            .padding(.top, 8)
        }
    }

    private func eraseAll() {
        model.eraseAllLocalData()
        // Reminders already planned or on screen go too.
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        AccessibilityNotification.Announcement(AttributedString("Bütün veriler silindi.")).post()
        dismiss()
    }
}

/// What importing the picked backup would do, then "İçe aktar" or "Vazgeç".
private struct ImportConfirmationSheet: View {
    let summary: DataImport.Summary
    let confirm: () -> Void
    let cancel: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let date = summary.exportedAt {
                        Text(verbatim: "Yedeğin tarihi: \(date.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "tr_TR"))))")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                    }
                    ForEach(summary.lines, id: \.self) { line in
                        Text(verbatim: line)
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text("Bu telefondaki hiçbir şey silinmez.")
                        .settingsFootnote()
                        .padding(.top, 4)
                    Button("İçe aktar", action: confirm)
                        .buttonStyle(PrimaryCapsuleButtonStyle())
                        .padding(.top, 8)
                        .disabled(summary.changesNothing)
                    if summary.changesNothing {
                        Text("Bu yedekteki her şey bu telefonda zaten var.")
                            .settingsFootnote()
                    }
                }
                .padding(16)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Yedeği içe aktar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç", action: cancel)
                }
            }
        }
    }
}
