import SwiftUI
import CoreModels

/// "Konular" on Sözlük's start page (mockup A1): a tile per topic with its name and word count,
/// two to a row (one at the accessibility text sizes), the user's own topics first. The first few
/// at once, the rest behind "Tüm konular (N)". A tile opens the topic's words (`SozlukTopicView`,
/// through Sözlük's `navigationDestination(for: ContentTopic.self)`).
struct SozlukTopicGrid: View {
    let topics: [ContentTopic]
    /// The user chose topics: the title line says theirs come first.
    let putsChosenFirst: Bool
    @State private var showsAll = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Tiles shown before "Tüm konular": three rows of two.
    private static let collapsedCount = 6

    var body: some View {
        let isCollapsible = topics.count > SozlukTopicGrid.collapsedCount
        let shown = showsAll || !isCollapsible ? topics : Array(topics.prefix(SozlukTopicGrid.collapsedCount))
        VStack(alignment: .leading, spacing: 8) {
            header
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                ForEach(SozlukTopicGrid.rows(shown, columns: columns), id: \.first?.id) { row in
                    GridRow {
                        ForEach(row) { topic in
                            tile(topic)
                        }
                        // A last row with one tile keeps it in the first column (with a single
                        // topic, the only tile takes the whole width).
                        if row.count < columns {
                            Color.clear
                                .gridCellUnsizedAxes([.horizontal, .vertical])
                        }
                    }
                }
            }
            if isCollapsible {
                Button {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                        showsAll.toggle()
                    }
                } label: {
                    Label(
                        showsAll ? "Daha az göster" : "Tüm konular (\(topics.count))",
                        systemImage: showsAll ? "chevron.up" : "chevron.down"
                    )
                }
                .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true))
                .padding(.top, 4)
            }
        }
    }

    private var columns: Int {
        return dynamicTypeSize.isAccessibilitySize ? 1 : 2
    }

    /// "Konular", and on the same line (under it when the line is short) "Senin konuların önce".
    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                SozlukSectionTitle(title: "Konular")
                Spacer(minLength: 8)
                caption
            }
            VStack(alignment: .leading, spacing: 2) {
                SozlukSectionTitle(title: "Konular")
                caption
            }
        }
    }

    @ViewBuilder
    private var caption: some View {
        if putsChosenFirst {
            Text("Senin konuların önce")
                .font(.footnote)
                .foregroundStyle(Theme.ink2)
        }
    }

    /// The topic's name over its word count, filling its grid cell (the tiles of a row are as
    /// tall as the tallest one).
    private func tile(_ topic: ContentTopic) -> some View {
        NavigationLink(value: topic) {
            VStack(alignment: .leading, spacing: 2) {
                Text(topic.displayName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(verbatim: "\(topic.cardCount) kelime")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .monospacedDigit()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(minHeight: 66)
        }
        .buttonStyle(SozlukTileButtonStyle())
        // UI tests find the tile by this label ("Yemek ve içecek, 67 kelime").
        .accessibilityLabel(Text(verbatim: "\(topic.displayName), \(topic.cardCount) kelime"))
        .accessibilityHint("Bu konunun kelimelerini açar")
    }

    /// `topics` cut into rows of `columns`.
    static func rows(_ topics: [ContentTopic], columns: Int) -> [[ContentTopic]] {
        let size = max(1, columns)
        return stride(from: 0, to: topics.count, by: size).map { start in
            Array(topics[start..<min(start + size, topics.count)])
        }
    }
}

/// A topic tile: a `surface` card with a `line` border (at night the page's black, as the word
/// page's cards); pressed, it darkens to `surface2`.
private struct SozlukTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        SozlukTileBody(configuration: configuration)
    }
}

private struct SozlukTileBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.choice, style: .continuous)
        configuration.label
            .background {
                shape
                    .fill(configuration.isPressed ? Theme.surface2 : (colorScheme == .dark ? Theme.bg : Theme.surface))
                    .shadow(color: colorScheme == .dark ? .clear : Theme.shadowNear, radius: 1, x: 0, y: 1)
            }
            .overlay {
                shape.strokeBorder(Theme.line, lineWidth: 1)
            }
            .contentShape(shape)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
