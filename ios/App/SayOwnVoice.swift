import AVFoundation
import Combine
import SwiftUI

/// "Kendi sesini dinle" on the Söyle page: the learner's last take ("Kendi sesin"), then the right
/// reading of the same word or sentence in the app's voice ("Doğrusu"), one after the other, so
/// that the two can be compared by ear. The take comes from `PronunciationRecognizer.ownVoice`:
/// memory only, never a file, gone when the page closes. Nothing here records or keeps anything.
@MainActor
final class OwnVoicePlayer: ObservableObject {
    enum Part: Equatable {
        case ownVoice
        /// From the end of the learner's voice (the short pause included) to the end of the reading.
        case correct
    }

    /// What is playing; nil when silent.
    @Published private(set) var part: Part?

    /// Silence between the learner's voice and the right reading (seconds).
    static let pause = 0.4

    private var engine: AVAudioEngine?
    /// The audio session was activated here and not yet handed to `Speaker`.
    private var ownsSession = false
    /// Bumped by every play and stop, so late callbacks of an older playback do nothing.
    private var generation = 0
    private var target: String?
    /// Watches `Speaker` while it reads the right version.
    private var reading: AnyCancellable?

    func play(_ voice: AVAudioPCMBuffer, then target: String) {
        stop()
        Speaker.stopAll()
        let current = generation
        guard WordSpeech.activateSession() else {
            return
        }
        ownsSession = true
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: voice.format)
        do {
            try engine.start()
        } catch {
            ownsSession = false
            WordSpeech.deactivateSession()
            return
        }
        self.engine = engine
        self.target = target
        part = .ownVoice
        let ended = Self.whenPlayedBack { [weak self] in
            self?.ownVoiceEnded(generation: current)
        }
        player.scheduleBuffer(voice, at: nil, options: [], completionCallbackType: .dataPlayedBack, completionHandler: ended)
        player.play()
    }

    /// Stops whichever part is playing.
    func stop() {
        generation += 1
        let readingTarget = reading != nil ? target : nil
        reading = nil
        target = nil
        part = nil
        if let engine {
            engine.stop()
            self.engine = nil
        }
        if ownsSession {
            ownsSession = false
            WordSpeech.deactivateSession()
        }
        if let readingTarget, Speaker.shared.speakingText == readingTarget {
            Speaker.shared.stop()
        }
    }

    /// Built outside the main actor: the player calls it on an audio thread.
    private nonisolated static func whenPlayedBack(_ done: @escaping @MainActor () -> Void) -> AVAudioPlayerNodeCompletionHandler {
        return { _ in
            Task { @MainActor in
                done()
            }
        }
    }

    private func ownVoiceEnded(generation current: Int) {
        guard current == generation, let target else {
            return
        }
        engine?.stop()
        engine = nil
        part = .correct
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(OwnVoicePlayer.pause))
            guard let self, current == self.generation else {
                return
            }
            self.readRight(target, generation: current)
        }
    }

    /// `Speaker` takes the audio session over and releases it when it is done.
    private func readRight(_ target: String, generation current: Int) {
        ownsSession = false
        let speaker = Speaker.shared
        speaker.toggle(target)
        reading = speaker.$speakingText
            .dropFirst()
            .sink { [weak self] text in
                guard let self, current == self.generation, text != target else {
                    return
                }
                self.reading = nil
                self.target = nil
                self.part = nil
            }
    }
}

/// Under the result: "Kendi sesini dinle" (a secondary capsule; the bottom bar keeps the step's
/// one main action) and the order of the two parts, the one playing in bold with a speaker.
/// Shape and weight mark the part, not color alone (rule 4).
struct OwnVoiceControls: View {
    let voice: AVAudioPCMBuffer
    /// The word or sentence, for "Doğrusu".
    let target: String
    @ObservedObject var player: OwnVoicePlayer
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let isPlaying = player.part != nil
        VStack(alignment: .leading, spacing: 8) {
            Button {
                if isPlaying {
                    player.stop()
                } else {
                    player.play(voice, then: target)
                }
            } label: {
                Label(isPlaying ? "Durdur" : "Kendi sesini dinle", systemImage: isPlaying ? "stop.fill" : "person.wave.2")
            }
            .buttonStyle(SecondaryCapsuleButtonStyle(fullWidth: true, minHeight: 50))
            .accessibilityHint(isPlaying ? "" : OwnVoiceControls.order)
            .accessibilityInputLabels(isPlaying ? [Text("Durdur")] : [Text("Kendi sesini dinle"), Text("Sesimi dinle")])
            HStack(spacing: 8) {
                partLabel("Kendi sesin", playing: player.part == .ownVoice)
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.ink3)
                partLabel("Doğrusu", playing: player.part == .correct)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenOrder)
        }
    }

    /// The hint and, before playing, the line's VoiceOver label.
    static let order = "Önce kendi sesin, sonra doğrusu çalar."

    private var spokenOrder: String {
        switch player.part {
        case .ownVoice:
            return "Kendi sesin çalıyor."
        case .correct:
            return "Doğrusu çalıyor."
        case nil:
            return OwnVoiceControls.order
        }
    }

    private func partLabel(_ title: String, playing: Bool) -> some View {
        HStack(spacing: 4) {
            if playing {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.caption.weight(.semibold))
                    .symbolEffect(.variableColor.iterative, isActive: !reduceMotion)
            }
            Text(title)
                .font(.footnote.weight(playing ? .bold : .regular))
        }
        .foregroundStyle(playing ? Theme.ink : Theme.ink2)
        .fixedSize(horizontal: false, vertical: true)
    }
}
