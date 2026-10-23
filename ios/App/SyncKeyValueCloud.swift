import Foundation

/// The iCloud copy in iCloud's key-value store (`NSUbiquitousKeyValueStore`): one key holding the
/// zlib-packed JSON of `SyncSnapshot`. Chosen over an iCloud Drive document and CloudKit as the
/// smallest reliable way (docs/ozellik_planlari/icloud_esitleme.md): no container, no schema, works
/// with iCloud Drive turned off, and iCloud itself keeps a first download from being overwritten.
///
/// Needs the iCloud key-value entitlement (`com.apple.developer.ubiquity-kvstore-identifier`) and
/// the iCloud capability on the App ID. Without them `synchronize()` returns false, so
/// `isAvailable` is false and nothing is read or written: the switch stays off, quietly.
///
/// Apple's limit is 1 MB for the whole store. Packed, a word with progress takes some tens of
/// bytes; `byteLimit` leaves room and a larger copy is not written (`SyncCloudError.tooLarge`).
final class SyncKeyValueCloud: SyncCloud {
    /// The one key. A different packing or layout would come under a new key.
    static let key = "lockglow.sync.1"
    static let byteLimit = 900_000

    var onChange: ((SyncCloudChange) -> Void)?
    private let store = NSUbiquitousKeyValueStore.default
    private var observer: NSObjectProtocol?

    /// Asked only when needed (the iCloud screen, or sync is on): `synchronize()` talks to
    /// iCloud's store. Apple: false "if an app was not built with the proper entitlement requests".
    private(set) lazy var isAvailable: Bool = {
        let available = store.synchronize()
        if available {
            startObserving()
        }
        return available
    }()

    private func startObserving() {
        observer = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { [weak self] note in
            guard let self, let change = SyncKeyValueCloud.change(from: note) else {
                return
            }
            self.onChange?(change)
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func read() throws -> Data? {
        guard isAvailable, let packed = store.data(forKey: SyncKeyValueCloud.key) else {
            return nil
        }
        do {
            return try (packed as NSData).decompressed(using: .zlib) as Data
        } catch {
            throw SyncCloudError.unreadable
        }
    }

    func write(_ json: Data) throws {
        guard isAvailable else {
            return
        }
        let packed = try (json as NSData).compressed(using: .zlib) as Data
        guard packed.count <= SyncKeyValueCloud.byteLimit else {
            throw SyncCloudError.tooLarge(bytes: packed.count)
        }
        store.set(packed, forKey: SyncKeyValueCloud.key)
        store.synchronize()
    }

    func remove() {
        guard isAvailable else {
            return
        }
        store.removeObject(forKey: SyncKeyValueCloud.key)
        store.synchronize()
    }

    func accountMarker() -> Data? {
        guard let token = FileManager.default.ubiquityIdentityToken else {
            return nil
        }
        return try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false)
    }

    func isSameAccount(_ stored: Data, _ current: Data) -> Bool? {
        if stored == current {
            return true
        }
        guard let old = SyncKeyValueCloud.token(from: stored), let new = SyncKeyValueCloud.token(from: current) else {
            return nil
        }
        // Apple: identity tokens are compared with isEqual.
        return old.isEqual(new)
    }

    private static func token(from data: Data) -> NSObject? {
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else {
            return nil
        }
        unarchiver.requiresSecureCoding = false
        defer {
            unarchiver.finishDecoding()
        }
        return unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? NSObject
    }

    /// What a change notification means for the copy; nil for other keys.
    private static func change(from note: Notification) -> SyncCloudChange? {
        guard let reason = note.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return nil
        }
        switch reason {
        case NSUbiquitousKeyValueStoreServerChange:
            let keys = note.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
            return keys.contains(key) ? .otherDevice : nil
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            return .firstDownload
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            return .quotaExceeded
        case NSUbiquitousKeyValueStoreAccountChange:
            return .accountChanged
        default:
            return nil
        }
    }
}
