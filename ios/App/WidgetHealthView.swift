import SwiftUI

/// "Widget Sağlığı": what the widget can see right now. Meant for the widget spike tests.
/// Pushed from "Ayarlar" (it has no NavigationStack of its own).
struct WidgetHealthView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        List {
            widgetsSection
            planSection
            contentSection
            actionsSection
        }
        .navigationTitle("Widget Sağlığı")
        .refreshable {
            await model.refreshHealth()
        }
        .task {
            await model.refreshHealth()
        }
    }

    private var health: WidgetHealthSnapshot {
        return model.health
    }

    private var widgetsSection: some View {
        Section("Yerleştirilmiş widget'lar") {
            LabeledContent("Sayı", value: "\(health.instances.count)")
            ForEach(health.instances.indices, id: \.self) { index in
                HStack {
                    Text(health.instances[index].kind)
                    Spacer()
                    Text(health.instances[index].family)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var planSection: some View {
        Section("Plan ve durum") {
            LabeledContent("App Group", value: health.appGroupAvailable ? "Erişilebilir" : "Erişilemiyor")
            LabeledContent("Plan kimliği", value: health.planID.map { String($0.prefix(8)) } ?? "yok")
            LabeledContent("Plan güncellendi", value: format(health.planUpdatedAt))
            LabeledContent("Kuyruk boyutu", value: "\(health.queueSize)")
            LabeledContent("Widget imleci", value: health.cursorOffset.map { String($0) } ?? "yok")
            LabeledContent("Widget'ta bilinen", value: health.knownCount.map { String($0) } ?? "yok")
            LabeledContent("Bekleyen olay", value: "\(health.pendingEventCount)")
            LabeledContent("Son yenileme isteği", value: format(health.lastReloadRequestedAt))
        }
    }

    private var contentSection: some View {
        Section("İçerik") {
            LabeledContent("Kaynak", value: sourceDescription)
            LabeledContent("Kart sayısı", value: "\(model.cardCount)")
            LabeledContent("İçerik sürümü", value: model.contentVersion ?? "yok")
        }
    }

    private var actionsSection: some View {
        Section("Eylemler") {
            Button("Planı yeniden yaz ve widget'ları yenile") {
                model.refreshWidgetPlan()
                Task {
                    await model.refreshHealth()
                }
            }
            Button("Yalnızca zaman çizelgelerini yenile") {
                model.reloadWidgets()
                Task {
                    await model.refreshHealth()
                }
            }
            Button("Durumu yenile") {
                Task {
                    await model.refreshHealth()
                }
            }
        }
    }

    private var sourceDescription: String {
        switch model.contentSource {
        case .loading: return "Yükleniyor"
        case .database: return "content.sqlite"
        case .seed: return "seed_words.json (yedek)"
        case .empty: return "İçerik yok"
        }
    }

    private func format(_ date: Date?) -> String {
        guard let date = date else {
            return "yok"
        }
        return date.formatted(date: .abbreviated, time: .standard)
    }
}
