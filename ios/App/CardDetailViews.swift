import SwiftUI
import CoreModels

// Pieces of a card's detail (from `CardDetail`) shared by the feed, the "Tekrar" cards and the
// "Sözlük" card, in the design of docs/tasarim/README.md (tokens in Shared/LockglowTheme.swift).
// Card text is shown verbatim (String, not LocalizedStringKey): no lookup, no Markdown.
// English text is serif and never italic; Turkish text is SF Pro (rule 3).

/// An English example with its Turkish translation under it (mockup `.exrow`), and a round
/// speaker that reads the English sentence aloud. With `lemma`, the learned word is bold in the
/// sentence, without the yellow mark: a card shows at most one marked example (rule 1).
struct ExampleRow: View {
    let example: CardDetail.Example
    var lemma: String? = nil
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                sentence
                    .exampleStyle()
                    .lineSpacing(2)
                    .cardEnglishVoice()
                if let tr = example.tr {
                    Text(tr)
                        .exampleTranslationStyle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // The 44 pt target reaches past the row's top and bottom instead of making it taller.
            CardSentenceSpeaker(text: example.en, accessibilityName: "Cümleyi dinle")
                .padding(.vertical, -7)
        }
    }

    private var sentence: Text {
        guard let lemma = lemma else {
            return Text(example.en)
        }
        return Text(ExampleMark.attributed(example.en, lemma: lemma, colorScheme: colorScheme, highlighted: false))
    }
}

/// "Dikkat" box (mockup `.mist`): a mistake Turkish speakers typically make with this word, the
/// right form, and why. The words that differ are underlined (dotted in the wrong sentence, solid
/// and bold in the right one, README point 5). Labelled in words with an icon ("Yanlış",
/// "Doğru"), so the meaning never depends on color (rule 4). `showsWhy: false` hides the
/// explanation (the feed card's second shortening step).
struct MistakeBox: View {
    let mistake: CardDetail.Mistake
    var showsWhy = true
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let diff = MistakeDiff(mistake)
        VStack(alignment: .leading, spacing: 8) {
            heading
            if dynamicTypeSize.isAccessibilitySize {
                // No room for a label column: each label above its sentence.
                VStack(alignment: .leading, spacing: 4) {
                    tag(isRight: false)
                    wrongSentence(diff)
                    tag(isRight: true)
                        .padding(.top, 4)
                    rightSentence(diff)
                }
            } else {
                Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 10, verticalSpacing: 6) {
                    GridRow {
                        tag(isRight: false)
                        wrongSentence(diff)
                    }
                    GridRow {
                        tag(isRight: true)
                        rightSentence(diff)
                    }
                }
            }
            if showsWhy {
                Text(mistake.why)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink2)
                    .lineSpacing(1)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
    }

    private var heading: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.caution)
                .accessibilityHidden(true)
            Text("Dikkat")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.ink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func tag(isRight: Bool) -> some View {
        HStack(spacing: 3) {
            Image(systemName: isRight ? "checkmark" : "xmark")
                .font(.caption2.weight(.black))
                .accessibilityHidden(true)
            Text(isRight ? "Doğru" : "Yanlış")
        }
        .font(.footnote.weight(.bold))
        .foregroundStyle(isRight ? Theme.good : Theme.bad)
        .fixedSize()
    }

    private func wrongSentence(_ diff: MistakeDiff) -> some View {
        Text(diff.wrongText())
            .font(.system(.callout, design: .serif))
            .foregroundStyle(Theme.ink)
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardEnglishVoice()
    }

    private func rightSentence(_ diff: MistakeDiff) -> some View {
        Text(diff.rightText())
            .font(.system(.callout, design: .serif).weight(.bold))
            .foregroundStyle(Theme.ink)
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardEnglishVoice()
    }
}

/// "Dinle" (mockup `.pill-btn`): a `surface2` capsule with a speaker and a label that reads `text`
/// aloud; a second tap stops it. Replaces the bare speaker icon next to the word (README "Akış").
/// The speaker waves while it reads, unless Reduce Motion is on.
struct CardListenCapsule: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let text: String
    var accessibilityName = "Kelimeyi dinle"

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
                Text("Dinle")
            }
        }
        .buttonStyle(CardListenCapsuleStyle())
        .accessibilityLabel(isSpeaking ? "Durdur" : accessibilityName)
    }
}

/// The capsule of `CardListenCapsule`: 44 pt high, the press feedback of the theme's capsule buttons.
private struct CardListenCapsuleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        CardListenCapsuleBody(configuration: configuration)
    }
}

private struct CardListenCapsuleBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .foregroundStyle(Theme.ink)
            .padding(.leading, 11)
            .padding(.trailing, 14)
            .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
            .background(Theme.surface2, in: Capsule())
            .contentShape(Capsule())
            .fixedSize()
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// A round speaker for a sentence (mockup `.spk`): a 34 pt `surface2` circle in a 44 pt target.
/// Reads `text` aloud; a second tap stops it.
struct CardSentenceSpeaker: View {
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .subheadline) private var circleSize: CGFloat = 34
    let text: String
    var accessibilityName = "Cümleyi dinle"

    var body: some View {
        let isSpeaking = speaker.speakingText == text
        Button {
            speaker.toggle(text)
        } label: {
            Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.subheadline.weight(.semibold))
                .symbolEffect(.variableColor.iterative, isActive: isSpeaking && !reduceMotion)
                .foregroundStyle(Theme.ink)
                .frame(width: circleSize, height: circleSize)
                .background(Theme.surface2, in: Circle())
                .frame(minWidth: Theme.minHitSize, minHeight: Theme.minHitSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSpeaking ? "Durdur" : accessibilityName)
    }
}

/// Turkish names of the part-of-speech codes in `WidgetWord.pos` (mockup `POS`, plus the codes
/// the content also uses); an unknown code is shown as it is.
enum CardPartOfSpeech {
    static func turkish(_ code: String) -> String {
        switch code {
        case "n":
            return "isim"
        case "v":
            return "fiil"
        case "adj":
            return "sıfat"
        case "adv":
            return "zarf"
        case "phv":
            return "iki kelimeli fiil"
        case "phr":
            return "kalıp"
        case "idm":
            return "deyim"
        case "det":
            return "belirleyici"
        default:
            return code
        }
    }
}

extension View {
    /// English card text (README point 14, `accessibilitySpeechLanguage = "en-US"`). SwiftUI has
    /// no speech-language modifier; VoiceOver takes a text's language from the environment's
    /// locale. Apply it to English text only: a Turkish translation must keep the Turkish voice.
    func cardEnglishVoice() -> some View {
        environment(\.locale, Locale(identifier: "en_US"))
    }
}
