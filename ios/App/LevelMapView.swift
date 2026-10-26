import SwiftUI
import CoreModels
import Learning

/// "Yol haritası": A1, A2, B1 and B2 as calm stops on one path (B2 once it has words), each with
/// its words, the words met and the topics that come next. Nothing is locked and nothing is scored (ogrenme_ilkeleri.md
/// "Kaçınılacaklar": no mascot, no locked level, no points): every level's words are open at any
/// time, the map only says where new words come from now. Opened from "İlerleme"
/// (`LevelMapLinkLabel`).
struct LevelMapView: View {
    let map: LevelMap
    /// A topic id's name on screen.
    let topicName: @MainActor (String) -> String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Seviyeler kilitli değil. Harita, yeni kelimelerin hangi seviyeden geldiğini gösterir.")
                    .font(.body)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 24)
                ForEach(Array(map.stops.enumerated()), id: \.element.id) { index, stop in
                    if index > 0 {
                        PathConnector()
                    }
                    LevelStopCard(
                        stop: stop,
                        isStart: stop.level == map.startLevel,
                        isCurrent: stop.level == map.currentLevel,
                        topicNames: stop.nextTopicIDs.compactMap(topicName)
                    )
                }
                // Four sizes on the page (title, level code, body, subheadline): no footnote.
                Text("Başlangıç seviyeni Ayarlar'dan değiştirebilirsin.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Theme.bg
                .ignoresSafeArea()
        }
        .navigationTitle("Yol haritası")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// The map as the app opens it: made from `AppModel` when it is pushed.
struct LevelMapScreen: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        LevelMapView(map: model.levelMap(), topicName: { model.topicDisplayName($0) })
    }
}

/// The row on "İlerleme" that opens the map.
struct LevelMapLinkLabel: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "map")
                .font(.title3)
                .foregroundStyle(Theme.ink2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Yol haritası")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text("Seviyeler ve sıradaki konular")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink3)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .contentShape(Rectangle())
        .cardSurface()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("progress.levelMap")
    }
}

/// One level: code and dots, its name, "Yeni kelimeler buradan" on the level new words come from
/// now, the counts with a two-part bar, and the next topics. A zero is never written: an unmet
/// level says "Henüz tanışmadın".
private struct LevelStopCard: View {
    let stop: LevelMap.Stop
    let isStart: Bool
    let isCurrent: Bool
    let topicNames: [String]
    @ScaledMetric(relativeTo: .body) private var dotSize: CGFloat = 6
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: countText)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if stop.total > 0 {
                    MetBar(met: stop.met, total: stop.total)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: countText.replacingOccurrences(of: " · ", with: ". ")))
            if stop.everyWordMet {
                Text("Bu seviyenin tüm kelimeleriyle tanıştın. Tekrarlar sürüyor.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            } else if !topicNames.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isCurrent ? "Sırada" : "Bu seviyenin konuları")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink2)
                    Text(verbatim: topicNames.joined(separator: ", "))
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: (isCurrent ? "Sırada: " : "Bu seviyenin konuları: ") + topicNames.joined(separator: ", ")))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .overlay {
            if isCurrent {
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .strokeBorder(Theme.tint, lineWidth: 2)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 12))
        return layout {
            VStack(spacing: 4) {
                Text(verbatim: stop.level.rawValue)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.ink)
                LevelDots(dots: stop.level.dots, size: LevelDots.cappedSize(dotSize, base: 6), spacing: 3)
            }
            .frame(minWidth: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: PlacementResultText.title(stop.level))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if isCurrent || isStart {
                    Text(verbatim: badgeText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(Capsule().strokeBorder(Theme.lineStrong, lineWidth: 1.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: headerVoice))
        .accessibilityAddTraits(.isHeader)
    }

    private var badgeText: String {
        switch (isCurrent, isStart) {
        case (true, true): return "Başlangıç seviyen · Yeni kelimeler buradan"
        case (true, false): return "Yeni kelimeler buradan"
        default: return "Başlangıç seviyen"
        }
    }

    private var headerVoice: String {
        var text = "\(stop.level.rawValue), \(PlacementResultText.title(stop.level))"
        if isCurrent || isStart {
            text += ". " + badgeText.replacingOccurrences(of: " · ", with: ". ")
        }
        return text
    }

    /// "418 kelime · 96 kelimeyle tanıştın", "418 kelime · Henüz tanışmadın".
    private var countText: String {
        if stop.met > 0 {
            return "\(stop.total) kelime · \(stop.met) kelimeyle tanıştın"
        }
        return "\(stop.total) kelime · Henüz tanışmadın"
    }
}

/// Met words over all words of the level: `tint` on a `surface3` track with an edge (audit K2).
/// Decorative: the count above says it.
private struct MetBar: View {
    let met: Int
    let total: Int

    var body: some View {
        let fraction = total > 0 ? min(1, CGFloat(met) / CGFloat(total)) : 0
        Capsule()
            .fill(Theme.surface3)
            .overlay(Capsule().strokeBorder(Theme.lineStrong, lineWidth: 1))
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Theme.tint)
                        .frame(width: met > 0 ? max(6, proxy.size.width * fraction) : 0)
                }
            }
            .frame(height: 8)
            .accessibilityHidden(true)
    }
}

/// The short line between two stops: the path, nothing more.
private struct PathConnector: View {
    var body: some View {
        Rectangle()
            .fill(Theme.lineStrong)
            .frame(width: 2, height: 22)
            .padding(.leading, 38)
            .accessibilityHidden(true)
    }
}
