import Foundation

public typealias InitialKnownClaims = [Int: InitialKnownClaim]

/// Receipt for one self-declaration. Kept after removal so a metadata-first interrupted save
/// can be reconciled against the primary progress, without changing its array format.
public struct InitialKnownClaim: Codable, Equatable, Sendable {
    public let previous: WordProgress?
    public let marked: WordProgress

    public init(previous: WordProgress?, marked: WordProgress) {
        self.previous = previous
        self.marked = marked
    }

    private enum CodingKeys: String, CodingKey { case previous, marked }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        previous = try container.decodeIfPresent(StrictSnapshot.self, forKey: .previous)?.value
        marked = try container.decode(StrictSnapshot.self, forKey: .marked).value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(previous, forKey: .previous)
        try container.encode(marked, forKey: .marked)
    }
}

public struct InitialKnownSelectionPlan: Equatable, Sendable {
    public let updatedProgress: [Int: WordProgress]
    public let claims: InitialKnownClaims
    public let protectedIDs: Set<Int>

    public init(updatedProgress: [Int: WordProgress], claims: InitialKnownClaims, protectedIDs: Set<Int>) {
        self.updatedProgress = updatedProgress
        self.claims = claims
        self.protectedIDs = protectedIDs
    }
}

/// Pure batch calculation. selectedIDs describes only the offered set; everything outside it
/// stays unchanged. The app must ingest widget events before supplying currentProgress.
public enum InitialKnownSelectionPlanner {
    public static func plan(
        offeredIDs: Set<Int>,
        baselineProgress: [Int: WordProgress],
        selectedIDs: Set<Int>,
        currentProgress: [Int: WordProgress],
        claims: InitialKnownClaims,
        now: Date
    ) -> InitialKnownSelectionPlan {
        var updated = currentProgress
        var receipts = claims
        var protected = Set<Int>()
        for id in offeredIDs.sorted() {
            guard id > 0, claims[id].map({ InitialKnownValidation.isValid($0, id: id) }) ?? true else {
                protected.insert(id)
                continue
            }
            let current = currentProgress[id]
            let receipt = claims[id]
            if selectedIDs.contains(id) {
                // Going back and forward, or retrying an already successful commit, never
                // moves an active claim's timestamp or three-day check.
                if let receipt = receipt, current == receipt.marked {
                    continue
                }
                let previous = current ?? WordProgress(wordID: id)
                guard current == baselineProgress[id], previous.wordID == id,
                      InitialKnownValidation.isEligible(previous),
                      now.timeIntervalSince1970.isFinite else {
                    protected.insert(id)
                    continue
                }
                let marked = Leitner.markKnown(previous, at: now)
                updated[id] = marked
                receipts[id] = InitialKnownClaim(previous: current, marked: marked)
            } else if let receipt = receipt {
                if current == receipt.marked {
                    if let previous = receipt.previous {
                        updated[id] = previous
                    } else {
                        updated.removeValue(forKey: id)
                    }
                } else if current != receipt.previous {
                    // A review, manual action or exposure changed this word. Keep it all.
                    protected.insert(id)
                }
                // Retain the receipt even when current == previous (already removed or the
                // primary write never happened). It is inactive, not a reason to mark again.
            }
        }
        return InitialKnownSelectionPlan(updatedProgress: updated, claims: receipts, protectedIDs: protected)
    }
}

public enum InitialKnownStoreError: Error, Equatable {
    case notLoaded
    case unreadable
    case corrupt
    case unsupportedVersion(Int)
    case oversized
    case changedSinceLoad
    case writeFailed
}

/// App-private, single-owner store. Load first, save these receipts atomically, then ask the
/// app to replace primary progress once. A failed primary save leaves inactive receipts safely.
/// This class does not access primary progress, defaults, widget files or the review log.
public final class InitialKnownSelectionStore {
    public static let defaultMaxBytes = 8 * 1024 * 1024
    public let fileURL: URL
    public let maxBytes: Int
    public private(set) var isReady = false
    public private(set) var claims: InitialKnownClaims?

    private var loadedData: Data?
    private let atomicWrite: (Data, URL) throws -> Void
    private struct Header: Decodable { let version: Int }
    private struct Envelope: Codable {
        let version: Int
        let claims: [InitialKnownClaim]
    }

    public convenience init(fileURL: URL, maxBytes: Int = InitialKnownSelectionStore.defaultMaxBytes) {
        self.init(fileURL: fileURL, maxBytes: maxBytes) { data, url in
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: [.atomic])
        }
    }

    // Deterministic file-write failure seam for package tests; not part of the app API.
    init(fileURL: URL, maxBytes: Int, atomicWrite: @escaping (Data, URL) throws -> Void) {
        precondition(maxBytes > 0 && maxBytes < Int.max)
        self.fileURL = fileURL
        self.maxBytes = maxBytes
        self.atomicWrite = atomicWrite
    }

    @discardableResult
    public func load() throws -> InitialKnownClaims {
        isReady = false
        claims = nil
        loadedData = nil
        let data = try readData()
        let decoded = try data.map(decode) ?? [:]
        loadedData = data
        claims = decoded
        isReady = true
        return decoded
    }

    public func saveBeforeProgress(_ updated: InitialKnownClaims) throws {
        guard isReady else { throw InitialKnownStoreError.notLoaded }
        // A second owner or damaged file must not be silently overwritten after an old load.
        guard try readData() == loadedData else { throw InitialKnownStoreError.changedSinceLoad }
        guard updated.allSatisfy({ InitialKnownValidation.isValid($0.value, id: $0.key) }) else {
            throw InitialKnownStoreError.corrupt
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        let data: Data
        do {
            data = try encoder.encode(Envelope(version: 1, claims: updated.keys.sorted().compactMap { updated[$0] }))
        } catch {
            throw InitialKnownStoreError.corrupt
        }
        guard data.count <= maxBytes else { throw InitialKnownStoreError.oversized }
        do {
            try atomicWrite(data, fileURL)
        } catch {
            throw InitialKnownStoreError.writeFailed
        }
        loadedData = data
        // Keep the exact live values, rather than a lossy Date encode/decode round trip.
        claims = updated
    }

    /// Explicit user reset may remove a corrupt file without loading it. A directory at this
    /// path is an error, never a recursive delete. Primary progress is unaffected.
    public func clear() throws {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
            throw InitialKnownStoreError.writeFailed
        }
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            guard Self.isMissing(error) else { throw InitialKnownStoreError.writeFailed }
        }
        loadedData = nil
        claims = [:]
        isReady = true
    }

    private func readData() throws -> Data? {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
            throw InitialKnownStoreError.unreadable
        }
        let handle: FileHandle
        do {
            handle = try FileHandle(forReadingFrom: fileURL)
        } catch {
            if Self.isMissing(error), !FileManager.default.fileExists(atPath: fileURL.path) { return nil }
            throw InitialKnownStoreError.unreadable
        }
        defer { try? handle.close() }
        var data = Data()
        do {
            while data.count <= maxBytes {
                let chunk = try handle.read(upToCount: maxBytes + 1 - data.count) ?? Data()
                if chunk.isEmpty { break }
                data.append(chunk)
            }
        } catch {
            throw InitialKnownStoreError.unreadable
        }
        guard data.count <= maxBytes else { throw InitialKnownStoreError.oversized }
        return data
    }

    private func decode(_ data: Data) throws -> InitialKnownClaims {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        do {
            let header = try decoder.decode(Header.self, from: data)
            guard header.version == 1 else { throw InitialKnownStoreError.unsupportedVersion(header.version) }
            let envelope = try decoder.decode(Envelope.self, from: data)
            var result: InitialKnownClaims = [:]
            for receipt in envelope.claims {
                let id = receipt.marked.wordID
                guard result[id] == nil, InitialKnownValidation.isValid(receipt, id: id) else {
                    throw InitialKnownStoreError.corrupt
                }
                result[id] = receipt
            }
            return result
        } catch let error as InitialKnownStoreError {
            throw error
        } catch {
            throw InitialKnownStoreError.corrupt
        }
    }

    private static func isMissing(_ error: Error) -> Bool {
        let error = error as NSError
        return (error.domain == NSCocoaErrorDomain &&
                [CocoaError.Code.fileReadNoSuchFile.rawValue, CocoaError.Code.fileNoSuchFile.rawValue].contains(error.code))
            || (error.domain == NSPOSIXErrorDomain && error.code == Int(POSIXErrorCode.ENOENT.rawValue))
    }
}

private enum InitialKnownValidation {
    static func isEligible(_ p: WordProgress) -> Bool {
        return p.state == .new && p.box == 0 && p.reviews == 0 && p.lapses == 0
            && !p.knownOverride && p.dueAt == nil && p.lastReviewedAt == nil && p.lastGrade == nil
            && p.firstReviewedAt == nil && p.refresherStep == nil && p.fsrs == nil
            && p.exposures >= 0 && (p.lastSeenAt?.timeIntervalSince1970.isFinite ?? true)
    }

    static func isValid(_ receipt: InitialKnownClaim, id: Int) -> Bool {
        let previous = receipt.previous ?? WordProgress(wordID: id)
        guard id > 0, receipt.marked.wordID == id, previous.wordID == id, isEligible(previous),
              let at = receipt.marked.lastSeenAt, at.timeIntervalSince1970.isFinite else {
            return false
        }
        return receipt.marked == Leitner.markKnown(previous, at: at)
    }
}

/// Primary WordProgress accepts malformed later optional fields for compatibility. A rollback
/// receipt needs strict decoding of those fields instead of silently losing their provenance.
private struct StrictSnapshot: Decodable {
    let value: WordProgress

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WordProgress.CodingKeys.self)
        _ = try container.decodeIfPresent(Date.self, forKey: .lastReviewedAt)
        _ = try container.decodeIfPresent(ReviewGrade.self, forKey: .lastGrade)
        _ = try container.decodeIfPresent(Date.self, forKey: .firstReviewedAt)
        _ = try container.decodeIfPresent(Int.self, forKey: .refresherStep)
        _ = try container.decodeIfPresent(FSRSState.self, forKey: .fsrs)
        value = try WordProgress(from: decoder)
    }
}
