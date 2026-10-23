import SwiftUI
import CoreModels

/// The watch app's one screen (is5-watch): the word the watch face shows now, then its Turkish
/// meaning and an example (the app's reading order, ogrenme_ilkeleri 2.1), "Dinle" in the corner
/// and the two buttons. The word changes on the hour, like the face; the minute timeline keeps the
/// screen in step when it stays open.
struct WatchWordView: View {
    @EnvironmentObject private var model: WatchModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            TimelineView(.everyMinute) { context in
                if let word = model.word(at: context.date) {
                    WatchWordPage(word: word, speaker: model.speaker)
                } else {
                    WatchEmptyPage()
                }
            }
        }
        .watchTurkishVoice()
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.reload()
                WatchSession.shared.flushOutbox()
            } else {
                model.speaker.stop()
            }
        }
    }
}

/// One word. Every line is shown whole: the screen scrolls instead of cutting text.
private struct WatchWordPage: View {
    let word: WidgetWord
    @ObservedObject var speaker: WatchSpeaker
    @EnvironmentObject private var model: WatchModel

    private var meaning: String? {
        return WatchGloss.forms(of: word).first
    }

    private var example: String {
        return word.exampleEN.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if model.showsKnownNotice {
                    Text(verbatim: "Tamam. 3 gün sonra bir kez soracağız.")
                        .font(WatchTheme.Fonts.helper)
                        .foregroundStyle(WatchTheme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 2) {
                    // The phosphor band of the night look, as a line under the word (rule 1).
                    Text(verbatim: word.lemma)
                        .font(WatchTheme.Fonts.word)
                        .underline(true, color: WatchTheme.band)
                        .foregroundStyle(WatchTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .watchEnglishVoice()
                        .accessibilityAddTraits(.isHeader)
                    if let ipa = word.ipaUS, !ipa.isEmpty {
                        Text(verbatim: ipa)
                            .font(.caption2)
                            .foregroundStyle(WatchTheme.ink3)
                            .accessibilityHidden(true)
                    }
                }

                if let meaning = meaning {
                    Text(verbatim: meaning)
                        .font(WatchTheme.Fonts.meaning)
                        .foregroundStyle(WatchTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(Text(verbatim: "Türkçesi: \(meaning)"))
                }

                if !example.isEmpty {
                    Text(verbatim: example)
                        .font(WatchTheme.Fonts.example)
                        .foregroundStyle(WatchTheme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                        .watchEnglishVoice()
                }

                // "Sonraki kelime" first; "Biliyorum", which takes the word away without a test,
                // further down (the phone widget keeps them apart the same way).
                VStack(spacing: 6) {
                    Button {
                        model.next(word)
                    } label: {
                        Label {
                            Text(verbatim: "Sonraki kelime")
                        } icon: {
                            Image(systemName: "forward.fill")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .accessibilityInputLabels([Text(verbatim: "Sonraki kelime"), Text(verbatim: "Sonraki")])

                    Button {
                        model.know(word)
                    } label: {
                        Label {
                            Text(verbatim: "Biliyorum")
                        } icon: {
                            Image(systemName: "checkmark")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .accessibilityHint(Text(verbatim: "Kelime izleden çıkar. 3 gün sonra telefonda bir kez sorarız."))
                }
                .padding(.top, 4)

                if model.input.isSeed {
                    Text(verbatim: "Bunlar örnek kelimeler. Telefonda Lockglow'u açınca senin kelimelerin gelir.")
                        .font(WatchTheme.Fonts.helper)
                        .foregroundStyle(WatchTheme.ink3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WatchSpeakButton(text: word.lemma, speaker: speaker)
            }
        }
    }
}

/// "Dinle" (docs/tasarim/terimler.md §3): reads the word aloud; "Durdur" while it plays.
private struct WatchSpeakButton: View {
    let text: String
    @ObservedObject var speaker: WatchSpeaker

    var body: some View {
        Button {
            if speaker.isSpeaking {
                speaker.stop()
            } else {
                speaker.speak(text)
            }
        } label: {
            Label {
                Text(verbatim: speaker.isSpeaking ? "Durdur" : "Kelimeyi dinle")
            } icon: {
                Image(systemName: speaker.isSpeaking ? "stop.fill" : "speaker.wave.2")
            }
            .labelStyle(.iconOnly)
        }
        .accessibilityInputLabels(
            speaker.isSpeaking
                ? [Text(verbatim: "Durdur")]
                : [Text(verbatim: "Kelimeyi dinle"), Text(verbatim: "Dinle")]
        )
        // VoiceOver stays quiet while the word is being read.
        .accessibilityAddTraits(.startsMediaSession)
    }
}

/// No plan and no seed words (the bundled file is missing): nothing to show yet.
private struct WatchEmptyPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: "Henüz kelime yok")
                    .font(.headline)
                    .foregroundStyle(WatchTheme.ink)
                Text(verbatim: "Telefonda Lockglow'u aç. Kelimeler oradan gelir.")
                    .font(WatchTheme.Fonts.helper)
                    .foregroundStyle(WatchTheme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
