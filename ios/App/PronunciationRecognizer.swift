import AVFoundation
import Speech
import SwiftUI
import Pronunciation

/// Listens to one take of the learner saying a word or a sentence and checks it with
/// `PronunciationCheck`. Recognition runs only on the device, never on a server:
/// - iOS 26+: SpeechAnalyzer with a DictationTranscriber. The app downloads the English model
///   itself the first time (AssetInventory), so no English keyboard or dictation setup is needed.
/// - iOS 17–25: an SFSpeechRecognizer request with `requiresOnDeviceRecognition`. It works only
///   if the phone already has on-device US English recognition; there is no server fallback.
/// Audio is kept in memory for the take only: never written to a file, never sent anywhere.
@MainActor
final class PronunciationRecognizer: ObservableObject {
    enum Problem: Equatable {
        case microphoneDenied
        case speechDenied
        case speechRestricted
        /// iOS 26+: the English model is not supported here or could not be downloaded.
        case modelUnavailable
        /// iOS 17–25: no on-device US English recognition on this phone.
        case onDeviceUnavailable
        case audioFailed
        /// Recognition did not run this time (the error code is in "Söyle tanılama").
        case recognitionFailed
    }

    enum Phase: Equatable {
        case idle
        /// Downloading the English model (first use on iOS 26+).
        case preparing
        case listening
        case checking
        case finished(PronunciationFeedback)
        case failed(Problem)
    }

    static let locale = Locale(identifier: "en-US")

    @Published private(set) var phase: Phase = .idle

    private let engine = AVAudioEngine()
    private var tapInstalled = false
    private var backend: SpeechBackend?
    private var target: PronunciationTarget?
    private var work: Task<Void, Never>?
    private var deadline: Task<Void, Never>?
    /// Bumped by every start and cancel, so late callbacks of an older take do nothing.
    private var generation = 0
    /// The take in progress as "Söyle tanılama" sees it (never what was said).
    private var take: SayDiagnostics.Attempt?
    private var listeningSince: Date?
    private var downloadSince: Date?

    /// iOS 17–25: failed takes in a row, for the set-up instructions (`RecognitionFailures`).
    private static var failureStreak = RecognitionFailureStreak()

    private static var engine: SayDiagnostics.Engine {
        if #available(iOS 26.0, *) {
            return .analyzer
        }
        return .recognizer
    }

    var isBusy: Bool {
        switch phase {
        case .preparing, .listening, .checking:
            return true
        case .idle, .finished, .failed:
            return false
        }
    }

    /// Starts a take. It ends by itself after the learner stops talking (or at `maxSeconds`), or
    /// when `finish()` is called.
    func start(_ target: PronunciationTarget, maxSeconds: Double) {
        cancel()
        self.target = target
        let current = generation
        take = SayDiagnostics.Attempt(
            date: Date(),
            engine: Self.engine,
            targetWords: target.text.split(separator: " ").count
        )
        work = Task {
            if let problem = await self.prepare(generation: current) {
                if current == self.generation {
                    self.backend = nil
                    self.phase = .failed(problem)
                    self.logTake(.failed(problem))
                }
                return
            }
            guard current == self.generation, let backend = self.backend else {
                return
            }
            do {
                try await backend.start()
                guard current == self.generation else {
                    return
                }
                try self.startAudio(feeding: backend, maxSeconds: maxSeconds, generation: current)
                self.phase = .listening
                self.listeningSince = Date()
                self.deadline = Task {
                    try? await Task.sleep(for: .seconds(maxSeconds + 2))
                    if current == self.generation {
                        self.finish()
                    }
                }
            } catch {
                guard current == self.generation else {
                    return
                }
                self.stopAudio()
                backend.cancel()
                self.backend = nil
                self.take?.errorCode = SayDiagnostics.code(of: error)
                self.phase = .failed(.audioFailed)
                self.logTake(.failed(.audioFailed))
            }
        }
    }

    /// Ends the take ("Bitti") and checks what was heard.
    func finish() {
        guard phase == .listening, let backend, let target else {
            return
        }
        phase = .checking
        stopAudio()
        if let since = listeningSince {
            take?.listeningSeconds = Date().timeIntervalSince(since)
        }
        let current = generation
        work = Task {
            var outcome: Phase
            var hypotheses: [Hypothesis] = []
            var failure: Error?
            do {
                hypotheses = try await backend.finish()
                outcome = .finished(PronunciationCheck.evaluate(target: target, hypotheses: hypotheses))
            } catch {
                failure = error
                outcome = .failed(.recognitionFailed)
            }
            guard current == self.generation else {
                return
            }
            // iOS 17–25 (README "Söyle: bilinen belirsizlikler" 8): failed takes in a row mean that
            // on-device English recognition is not set up; the page then says how to set it up.
            if Self.engine == .recognizer {
                if failure != nil {
                    if Self.failureStreak.recordFailure() {
                        outcome = .failed(.onDeviceUnavailable)
                    }
                } else if !hypotheses.isEmpty {
                    Self.failureStreak.recordHeard()
                }
            }
            self.backend = nil
            self.phase = outcome
            self.take?.candidates = hypotheses.count
            self.take?.confidence = hypotheses.first?.confidence
            // The recognizer's own code first: on iOS 17–25 the error thrown only says "failed".
            if let code = backend.failureCode {
                self.take?.errorCode = code
            } else if let failure {
                self.take?.errorCode = SayDiagnostics.code(of: failure)
            }
            switch outcome {
            case .finished(let feedback):
                self.logTake(.verdict(feedback.verdict))
            case .failed(let problem):
                self.logTake(.failed(problem))
            default:
                break
            }
        }
    }

    /// Stops everything without a result (sheet closed, other mode chosen).
    func cancel() {
        if isBusy {
            logTake(.cancelled)
        }
        take = nil
        listeningSince = nil
        downloadSince = nil
        generation += 1
        work?.cancel()
        work = nil
        stopAudio()
        backend?.cancel()
        backend = nil
        phase = .idle
    }

    /// Hands the take to "Söyle tanılama" and forgets it.
    private func logTake(_ outcome: SayDiagnostics.Outcome) {
        guard var attempt = take else {
            return
        }
        take = nil
        attempt.outcome = outcome
        SayDiagnostics.shared.add(attempt)
    }

    // MARK: - Permissions and model

    /// Asks for what is missing, just in time, and sets up the backend. Nil when ready.
    /// `current`: the take's generation, so a late answer never fills in a newer take.
    private func prepare(generation current: Int) async -> Problem? {
        // The speakers and the microphone share the audio session: stop anything being read,
        // the widget's speaker button included.
        Speaker.stopAll()
        switch AVAudioApplication.shared.recordPermission {
        case .denied:
            return .microphoneDenied
        case .undetermined:
            guard await AVAudioApplication.requestRecordPermission() else {
                return .microphoneDenied
            }
        default:
            break
        }
        if #available(iOS 26.0, *) {
            // Apple: SpeechAnalyzer modules never send audio to Apple's servers, so only the
            // microphone permission is asked here.
            do {
                backend = try await AnalyzerBackend.make(locale: Self.locale) { [weak self] in
                    guard let self, self.generation == current else {
                        return
                    }
                    self.phase = .preparing
                    self.downloadSince = Date()
                }
                noteDownloadTime(generation: current)
            } catch {
                noteDownloadTime(generation: current)
                if current == generation {
                    take?.errorCode = SayDiagnostics.code(of: error)
                }
                return .modelUnavailable
            }
        } else {
            switch await Self.speechAuthorization() {
            case .authorized:
                break
            case .restricted:
                return .speechRestricted
            default:
                return .speechDenied
            }
            guard let recognizer = SFSpeechRecognizer(locale: Self.locale), recognizer.supportsOnDeviceRecognition else {
                return .onDeviceUnavailable
            }
            backend = RecognizerBackend(recognizer: recognizer)
        }
        return nil
    }

    /// How long the English model took to download (first use only).
    private func noteDownloadTime(generation current: Int) {
        guard current == generation, let since = downloadSince else {
            return
        }
        take?.modelDownloadSeconds = Date().timeIntervalSince(since)
    }

    private static func speechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        let status = SFSpeechRecognizer.authorizationStatus()
        guard status == .notDetermined else {
            return status
        }
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
    }

    // MARK: - Audio

    private func startAudio(feeding backend: SpeechBackend, maxSeconds: Double, generation current: Int) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            throw RecognizerError.noMicrophone
        }
        let monitor = TakeMonitor(maxSeconds: maxSeconds)
        let tap = Self.makeTap(backend: backend, monitor: monitor) { [weak self] in
            guard let self, self.generation == current else {
                return
            }
            self.finish()
        }
        input.installTap(onBus: 0, bufferSize: 2048, format: format, block: tap)
        tapInstalled = true
        engine.prepare()
        try engine.start()
    }

    /// Built outside the main actor: the tap runs on the audio thread.
    private nonisolated static func makeTap(
        backend: SpeechBackend,
        monitor: TakeMonitor,
        onTakeOver: @escaping @MainActor () -> Void
    ) -> AVAudioNodeTapBlock {
        return { buffer, _ in
            backend.append(buffer)
            if monitor.isTakeOver(after: buffer) {
                Task { @MainActor in
                    onTakeOver()
                }
            }
        }
    }

    private func stopAudio() {
        deadline?.cancel()
        deadline = nil
        if engine.isRunning {
            engine.stop()
        }
        if tapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

enum RecognizerError: Error {
    case noMicrophone
    case modelMissing
    /// iOS 17–25: the recognizer answered with an error other than "no speech", or not at all.
    case recognitionFailed
}

/// Decides on the audio thread when a take is over: once the learner has spoken and then been
/// quiet for a moment, after a few seconds with no speech at all, or at the time limit.
/// The levels are a first guess; tune them on the phone.
final class TakeMonitor {
    static let speechLevel: Float = 0.02
    static let quietAfterSpeech = 0.9
    static let waitForSpeech = 5.0

    private let maxSeconds: Double
    private var elapsed = 0.0
    private var quiet = 0.0
    private var heardSpeech = false
    private var over = false

    init(maxSeconds: Double) {
        self.maxSeconds = maxSeconds
    }

    /// True once, for the buffer that ends the take.
    func isTakeOver(after buffer: AVAudioPCMBuffer) -> Bool {
        guard !over, buffer.format.sampleRate > 0 else {
            return false
        }
        let seconds = Double(buffer.frameLength) / buffer.format.sampleRate
        elapsed += seconds
        if Self.level(of: buffer) >= Self.speechLevel {
            heardSpeech = true
            quiet = 0
        } else {
            quiet += seconds
        }
        over = (heardSpeech && quiet >= Self.quietAfterSpeech)
            || (!heardSpeech && elapsed >= Self.waitForSpeech)
            || elapsed >= maxSeconds
        return over
    }

    /// Root mean square of the first channel (0...1).
    private static func level(of buffer: AVAudioPCMBuffer) -> Float {
        guard let samples = buffer.floatChannelData?[0], buffer.frameLength > 0 else {
            return 0
        }
        let count = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<count {
            sum += samples[i] * samples[i]
        }
        return (sum / Float(count)).squareRoot()
    }
}

// MARK: - Backends

/// One recognition pass. `append` is called on the audio thread; the rest on the main actor.
protocol SpeechBackend: AnyObject {
    func start() async throws
    func append(_ buffer: AVAudioPCMBuffer)
    /// Ends the audio and returns the transcriptions, best first (empty when nothing was heard).
    /// Throws when recognition did not run.
    func finish() async throws -> [Hypothesis]
    func cancel()
    /// The recognizer's error behind the last `finish()`, as "domain code" ("Söyle tanılama"),
    /// whether it came back empty or threw; nil when there was none or the backend does not keep it.
    var failureCode: String? { get }
}

extension SpeechBackend {
    var failureCode: String? {
        return nil
    }
}

/// iOS 26+: SpeechAnalyzer with a DictationTranscriber (same on-device model as system dictation)
/// in the short-phrase preset, with alternatives and confidence.
@available(iOS 26.0, *)
final class AnalyzerBackend: SpeechBackend {
    /// One finalized result, reduced to plain values.
    private struct Phrase: Sendable {
        let text: String
        let alternatives: [String]
        let confidence: Double?
    }

    private let transcriber: DictationTranscriber
    private let analyzer: SpeechAnalyzer
    private let format: AVAudioFormat
    private let inputs: AsyncStream<AnalyzerInput>
    private let inputBuilder: AsyncStream<AnalyzerInput>.Continuation
    /// Audio thread only.
    private var converter: AVAudioConverter?
    private var phrases: Task<[Phrase], Error>?

    /// Makes sure the English model is on the phone (downloading it the first time, after calling
    /// `downloading`) and sets up the analyzer.
    static func make(locale: Locale, downloading: @escaping @MainActor () -> Void) async throws -> AnalyzerBackend {
        let preset = DictationTranscriber.Preset.phrase
        let transcriber = DictationTranscriber(
            locale: locale,
            contentHints: preset.contentHints,
            transcriptionOptions: preset.transcriptionOptions,
            reportingOptions: preset.reportingOptions.union([.alternativeTranscriptions]),
            attributeOptions: preset.attributeOptions.union([.transcriptionConfidence])
        )
        if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            await downloading()
            try await request.downloadAndInstall()
        }
        guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
            throw RecognizerError.modelMissing
        }
        return AnalyzerBackend(transcriber: transcriber, format: format)
    }

    private init(transcriber: DictationTranscriber, format: AVAudioFormat) {
        self.transcriber = transcriber
        self.format = format
        analyzer = SpeechAnalyzer(modules: [transcriber])
        let (stream, builder) = AsyncStream.makeStream(of: AnalyzerInput.self)
        inputs = stream
        inputBuilder = builder
    }

    func start() async throws {
        let transcriber = self.transcriber
        phrases = Task {
            var collected: [Phrase] = []
            for try await result in transcriber.results where result.isFinal {
                collected.append(AnalyzerBackend.phrase(from: result))
            }
            return collected
        }
        try await analyzer.start(inputSequence: inputs)
    }

    func append(_ buffer: AVAudioPCMBuffer) {
        guard let converted = convert(buffer) else {
            return
        }
        inputBuilder.yield(AnalyzerInput(buffer: converted))
    }

    func finish() async throws -> [Hypothesis] {
        inputBuilder.finish()
        try await analyzer.finalizeAndFinishThroughEndOfInput()
        var collected: [Phrase] = []
        if let phrases {
            collected = try await phrases.value
        }
        let heard = collected.filter { !$0.text.isEmpty }
        guard !heard.isEmpty else {
            return []
        }
        let confidences = heard.compactMap(\.confidence)
        let confidence = confidences.isEmpty ? nil : confidences.reduce(0, +) / Double(confidences.count)
        var hypotheses = [Hypothesis(text: heard.map(\.text).joined(separator: " "), confidence: confidence)]
        if heard.count == 1 {
            hypotheses += heard[0].alternatives.map { Hypothesis(text: $0) }
        }
        return hypotheses
    }

    /// Ending the input ends the analysis; the analyzer needs no explicit cancel before release.
    func cancel() {
        inputBuilder.finish()
        phrases?.cancel()
    }

    private static func phrase(from result: DictationTranscriber.Result) -> Phrase {
        var sum = 0.0
        var count = 0
        for run in result.text.runs {
            if let confidence = run[AttributeScopes.SpeechAttributes.ConfidenceAttribute.self] {
                sum += Double(confidence)
                count += 1
            }
        }
        return Phrase(
            text: String(result.text.characters),
            alternatives: result.alternatives.dropFirst().map { String($0.characters) },
            confidence: count > 0 ? sum / Double(count) : nil
        )
    }

    /// The analyzer does not convert audio itself: microphone buffers are converted to its format.
    private func convert(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        if buffer.format == format {
            return buffer
        }
        if converter == nil {
            converter = AVAudioConverter(from: buffer.format, to: format)
            converter?.primeMethod = AVAudioConverterPrimeMethod.none
        }
        guard let converter else {
            return nil
        }
        let ratio = format.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up)) + 1
        guard let output = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else {
            return nil
        }
        var supplied = false
        var error: NSError?
        let status = converter.convert(to: output, error: &error) { _, inputStatus in
            if supplied {
                inputStatus.pointee = .noDataNow
                return nil
            }
            supplied = true
            inputStatus.pointee = .haveData
            return buffer
        }
        guard status != .error, error == nil, output.frameLength > 0 else {
            return nil
        }
        return output
    }
}

/// iOS 17–25: an on-device-only SFSpeechRecognizer request. "No speech" (and a cancel) ends the take
/// with nothing heard; any other error, or no answer at all, makes `finish()` throw
/// (`RecognitionFailures`).
final class RecognizerBackend: SpeechBackend {
    /// What the recognizer answered; `failed`: it did not run (see `RecognitionFailures`).
    private struct Outcome {
        let hypotheses: [Hypothesis]
        let code: String?
        let failed: Bool
    }

    private let recognizer: SFSpeechRecognizer
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var task: SFSpeechRecognitionTask?
    private let lock = NSLock()
    private var outcome: Outcome?
    private var waiter: CheckedContinuation<Outcome, Never>?

    var failureCode: String? {
        lock.lock()
        defer { lock.unlock() }
        return outcome?.code
    }

    init(recognizer: SFSpeechRecognizer) {
        self.recognizer = recognizer
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false
        request.addsPunctuation = false
    }

    func start() async throws {
        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            if let result, result.isFinal {
                let best = result.bestTranscription
                let others = result.transcriptions.filter { $0.formattedString != best.formattedString }
                let hypotheses = ([best] + others).map {
                    Hypothesis(text: $0.formattedString, confidence: RecognizerBackend.confidence(of: $0))
                }
                self?.deliver(hypotheses)
            } else if let error {
                let nsError = error as NSError
                let failed = RecognitionFailures.isFailure(domain: nsError.domain, code: nsError.code)
                self?.deliver([], failureCode: SayDiagnostics.code(of: error), failed: failed)
            }
        }
    }

    func append(_ buffer: AVAudioPCMBuffer) {
        request.append(buffer)
    }

    func finish() async throws -> [Hypothesis] {
        request.endAudio()
        // Safety net in case the recognizer never reports back.
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(4))
            self?.deliver([], failureCode: "timeout", failed: true)
        }
        let answer: Outcome = await withCheckedContinuation { continuation in
            lock.lock()
            if let outcome {
                lock.unlock()
                continuation.resume(returning: outcome)
                return
            }
            waiter = continuation
            lock.unlock()
        }
        if answer.failed {
            throw RecognizerError.recognitionFailed
        }
        return answer.hypotheses
    }

    func cancel() {
        task?.cancel()
        request.endAudio()
        deliver([])
    }

    /// The first outcome wins; a waiting `finish()` gets it.
    private func deliver(_ hypotheses: [Hypothesis], failureCode: String? = nil, failed: Bool = false) {
        lock.lock()
        guard outcome == nil else {
            lock.unlock()
            return
        }
        let delivered = Outcome(hypotheses: hypotheses, code: failureCode, failed: failed)
        outcome = delivered
        let waiting = waiter
        waiter = nil
        lock.unlock()
        waiting?.resume(returning: delivered)
    }

    /// Mean segment confidence; nil when the recognizer gave none (0 means "none" here).
    private static func confidence(of transcription: SFTranscription) -> Double? {
        let values = transcription.segments.map { Double($0.confidence) }.filter { $0 > 0 }
        return values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
    }
}

// MARK: - Diagnostics

/// "Söyle tanılama" (Ayarlar > Widget sağlığı): the last 20 takes, to see on the phone what README
/// "Söyle: bilinen belirsizlikler" 1 and 4 leave open: does a confidence come and on what scale,
/// how many alternatives, how long the model download takes, which error codes.
/// Never what was said: only the engine, counts, durations and error codes. In memory only, gone
/// when the app quits. Off (nothing recorded) when `DiagnosticsSwitch.isOn` is false.
@MainActor
final class SayDiagnostics: ObservableObject {
    static let shared = SayDiagnostics()
    static let capacity = 20

    enum Engine: String {
        /// iOS 26+.
        case analyzer = "SpeechAnalyzer"
        /// iOS 17–25.
        case recognizer = "SFSpeechRecognizer"
    }

    enum Outcome: Equatable {
        case verdict(PronunciationFeedback.Verdict)
        case failed(PronunciationRecognizer.Problem)
        /// Stopped before a result: page closed, mode changed, app in the background, a call.
        case cancelled
    }

    struct Attempt: Identifiable, Equatable {
        let id = UUID()
        let date: Date
        let engine: Engine
        /// Words in what was to be said (the card's word or example), not in what was heard.
        let targetWords: Int
        /// First use on iOS 26+: how long the English model took to download.
        var modelDownloadSeconds: Double?
        var listeningSeconds: Double?
        /// Transcriptions handed to the check: the best one and its alternatives.
        var candidates = 0
        /// The best transcription's confidence (0...1); nil when the engine gave none.
        var confidence: Double?
        /// "domain code" of the error, when there was one ("timeout": the recognizer never answered).
        var errorCode: String?
        var outcome = Outcome.cancelled
    }

    /// Newest first, at most `capacity`.
    @Published private(set) var attempts: [Attempt] = []

    func add(_ attempt: Attempt) {
        guard DiagnosticsSwitch.isOn else {
            return
        }
        attempts.insert(attempt, at: 0)
        if attempts.count > SayDiagnostics.capacity {
            attempts.removeLast(attempts.count - SayDiagnostics.capacity)
        }
    }

    func clear() {
        attempts.removeAll()
    }

    /// "kAFAssistantErrorDomain 1110": enough to look the error up, nothing the learner said.
    nonisolated static func code(of error: Error) -> String {
        let nsError = error as NSError
        return "\(nsError.domain) \(nsError.code)"
    }
}
