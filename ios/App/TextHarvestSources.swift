import SwiftUI
import UIKit
import AVFoundation
import ImageIO
import Vision
import VisionKit
import Learning

// Where "Metinden kelime bul" (TextHarvestView) gets text besides the keyboard: the live camera
// (VisionKit's DataScannerViewController) and a chosen photo (Vision's text recognition). Both
// read English on the phone; nothing is saved or sent (NSCameraUsageDescription, project.yml).
// The photo picker runs outside the app and hands over only the chosen photo, so it needs no
// photo library permission.

// MARK: - Camera

/// "Kamerayla tara": the camera with the English text it sees marked; "Bu metni al" takes the
/// lines on screen, top to bottom.
struct TextScannerSheet: View {
    /// Called with the taken text (`TextHarvest.joiningLines`) before the cover closes.
    let onTake: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var lines: [String] = []

    /// The phone can read text live (a recent iPhone, not a simulator) and the camera is allowed,
    /// or not asked yet (the first tap asks, `requestCamera`).
    @MainActor
    static var canScan: Bool {
        guard DataScannerViewController.isSupported else {
            return false
        }
        return DataScannerViewController.isAvailable
            || AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }

    /// Whether the camera may be used; asks the first time (the system question with
    /// NSCameraUsageDescription).
    @MainActor
    static func requestCamera() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    var body: some View {
        NavigationStack {
            TextScannerView { found in
                lines = found
            }
            .ignoresSafeArea(edges: .bottom)
            .overlay(alignment: .top) {
                Text("Kamerayı İngilizce yazıya tut. İşaretli satırlar alınır.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.box, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button(lines.isEmpty ? "Yazı aranıyor" : "Bu metni al") {
                    onTake(TextHarvest.joiningLines(lines))
                    dismiss()
                }
                .buttonStyle(GlowButtonStyle())
                .disabled(lines.isEmpty)
                .accessibilityIdentifier("textScanner.take")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Theme.bg
                        .ignoresSafeArea()
                }
            }
            .navigationTitle("Kamerayla tara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                }
            }
        }
        // A cover starts its own hierarchy: "Vazgeç" stays ink (README rule 2).
        .tint(Theme.ink)
    }
}

/// VisionKit's live text scanner, English only, with the found lines marked. Reports the text
/// items on screen in reading order (top to bottom, then left to right) whenever they change.
private struct TextScannerView: UIViewControllerRepresentable {
    let onChange: ([String]) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(onChange: onChange)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(languages: ["en-US"])],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        context.coordinator.onChange = onChange
        // Started once the view is on screen; a failure (the camera taken away) leaves the
        // button at "Yazı aranıyor", and "Vazgeç" still closes.
        if !scanner.isScanning {
            try? scanner.startScanning()
        }
    }

    static func dismantleUIViewController(_ scanner: DataScannerViewController, coordinator: Coordinator) {
        scanner.stopScanning()
    }

    @MainActor
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var onChange: ([String]) -> Void

        init(onChange: @escaping ([String]) -> Void) {
            self.onChange = onChange
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            report(allItems)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            report(allItems)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            report(allItems)
        }

        private func report(_ items: [RecognizedItem]) {
            var found: [(text: String, top: CGFloat, left: CGFloat)] = []
            for item in items {
                if case let .text(text) = item {
                    found.append((text.transcript, item.bounds.topLeft.y, item.bounds.topLeft.x))
                }
            }
            found.sort { lhs, rhs in
                lhs.top != rhs.top ? lhs.top < rhs.top : lhs.left < rhs.left
            }
            onChange(found.map { $0.text })
        }
    }
}

// MARK: - Photo

/// "Fotoğraftan al": the English lines of a photo, read by Vision on the phone (text recognition
/// never leaves the device). Runs off the main thread (`Task.detached` in TextHarvestView).
enum TextPhotoReader {
    /// The recognized lines in Vision's reading order; empty when the data is not an image or
    /// holds no text.
    static func lines(in data: Data) -> [String] {
        guard let image = UIImage(data: data), let cgImage = image.cgImage else {
            return []
        }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation(of: image), options: [:])
        do {
            try handler.perform([request])
        } catch {
            return []
        }
        return (request.results ?? []).compactMap { observation in
            observation.topCandidates(1).first?.string
        }
    }

    /// A photo from the camera is stored sideways with a flag; Vision reads it upright this way.
    private static func orientation(of image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }
}
