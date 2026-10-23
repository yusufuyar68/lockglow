/// "Kendi sesini dinle": the learner's own take, played back before the right reading. The app
/// keeps the microphone samples of the last take in memory only, while the Söyle page is open
/// (never in a file), and plays only the part with speech in it, a little louder when it is quiet:
/// the microphone is open without automatic gain while listening. Pure, so that the cut and the
/// gain are tested on Linux; the app passes in the samples of the first channel.
public enum VoiceClip {
    /// Loudness is measured in windows of this length (seconds).
    public static let window = 0.02
    /// Kept before the first loud window, so that a soft first sound is not cut (seconds).
    public static let lead = 0.15
    /// Kept after the last loud window, for a soft last sound ("-s", "-t") (seconds).
    public static let tail = 0.3
    /// The loudest sample after the gain.
    public static let peak: Float = 0.9
    /// A quiet take is made at most this much louder, so that a near-silent one stays quiet.
    public static let maxGain: Float = 8

    /// The samples worth playing back: from `lead` before the first window whose root mean
    /// square is at least `threshold` to `tail` after the last one; nil when no window is.
    public static func speechRange(_ samples: [Float], sampleRate: Double, threshold: Float) -> Range<Int>? {
        guard sampleRate > 0, !samples.isEmpty else {
            return nil
        }
        let size = max(1, Int((sampleRate * window).rounded()))
        var first: Int?
        var last: Int?
        var start = 0
        while start < samples.count {
            let end = min(start + size, samples.count)
            var sum: Float = 0
            for k in start..<end {
                sum += samples[k] * samples[k]
            }
            if (sum / Float(end - start)).squareRoot() >= threshold {
                if first == nil {
                    first = start
                }
                last = end
            }
            start = end
        }
        guard let first, let last else {
            return nil
        }
        let from = max(0, first - Int((sampleRate * lead).rounded()))
        let to = min(samples.count, last + Int((sampleRate * tail).rounded()))
        return from..<to
    }

    /// The gain that brings the loudest sample to `peak`: between 1 and `maxGain`, so a take is
    /// made louder, never quieter. 1 for silence.
    public static func gain(_ samples: ArraySlice<Float>) -> Float {
        var loudest: Float = 0
        for sample in samples {
            loudest = max(loudest, abs(sample))
        }
        guard loudest > 0 else {
            return 1
        }
        return min(maxGain, max(1, peak / loudest))
    }
}
