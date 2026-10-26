import SwiftUI
import CoreModels

/// The word's picture next to a word page's headline (feed card, Sözlük page;
/// docs/ozellik_planlari/kelime_gorselleri.md): Title 2, secondary ink (never yellow), hidden
/// from VoiceOver.
struct WordSymbolMark: View {
    /// A name `WordSymbol.systemName` has checked.
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.title2)
            .foregroundStyle(Theme.ink2)
            .accessibilityHidden(true)
    }
}

/// `headline` with the word's picture at the trailing edge when both fit on one line at the
/// headline's own size; otherwise the headline alone, so the picture never makes the word smaller
/// or cut (iPhone SE, AX5). Without a picture (none, `showsSymbol` false, or one this iOS does
/// not draw) it is the headline unchanged.
///
/// Only for surfaces that already show the meaning. Never use it on a question card.
struct HeadlineWithSymbol<Headline: View>: View {
    let word: WidgetWord
    var showsSymbol = true
    @ViewBuilder let headline: () -> Headline

    var body: some View {
        if showsSymbol, let name = WordSymbol.systemName(for: word) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 12) {
                    // Measured at its natural (first-choice, unshrunk) width.
                    headline()
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer(minLength: 0)
                    WordSymbolMark(systemName: name)
                }
                headline()
            }
        } else {
            headline()
        }
    }
}
