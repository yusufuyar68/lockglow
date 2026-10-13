# Technical Blueprint: Vocabulary Widget App (iOS-first), as of 2026-10-10

**Evidence tags.** [A] = Apple primary doc or WWDC session, fetched and read. [V] = vendor or primary non-Apple page. [S] = secondary source (blogs, forums, aggregators). [I] = my inference or general knowledge. Section 10 lists every uncertain or version-dependent item. I wrote no files into the project folder.

Context: iOS 27, Xcode 27 and Swift 6.4 shipped around 2026-09-14. App Store uploads must use the iOS 26 SDK or later since 2026-04-28, and the iOS 27 SDK is expected to be required from April 2027 (exact day unconfirmed) ([Apple upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) [A]; [Mactech](https://www.mactech.com/2026/09/10/app-store-submissions-now-open-for-the-latest-os-releases/) [S]).

---

## 0. Executive summary: key decisions

1. **Native SwiftUI + WidgetKit, iOS-first.** The widget is the product, and widgets must be native on every platform. Deployment target iOS 17.0 (interactive widgets, `AppIntentTimelineProvider`), with `#available` for iOS 18 (Controls) and iOS 26 (Liquid Glass look).
   - Apple's June 2026 figures: 79% of all compatible iPhones run iOS 26 and 14% run iOS 18 ([MacRumors/Apple data](https://www.macrumors.com/2026/02/17/how-popular-is-ios-26) [S], figures from the June 7 update via search summary). An iOS 18 floor covers about 93% of compatible devices.
2. **"New word every X hours" is a timeline-generation problem, not a refresh-budget problem.**
   - Pre-compute 24–48 h of entries in one timeline pass. A reload is spent only when the timeline is regenerated, not when entries switch.
   - Make the schedule deterministic. Reload from the app whenever it backgrounds.
   - Apple's budget is about 40–70 reloads per widget instance per day ([Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date.md) [A]).
3. **Data layering.**
   - Word content: a read-only, bundled, prebuilt SQLite DB (GRDB 7.11.x for access, FTS5 for search), with an immutable copy in the App Group.
   - User state: an app-private store (SwiftData with CloudKit, or GRDB).
   - Widget-to-app communication: tiny atomic files and an append-only event log in the App Group. The widget never writes to a live SQLite or CloudKit store, because of 0xDEAD10CC and the memory limit (section 2.2).
4. **SRS.** FSRS-6 for active reviews, using the open-spaced-repetition `swift-fsrs` package (MIT). Passive widget exposure is not a review. The interactive widget becomes a flashcard (reveal, then Knew it / Again), and those taps feed FSRS.
5. **Content.**
   - Use permissive or attribution-only sources: NGSL/NAWL (CC BY-SA 4.0), CEFR-J (free with citation), Open English WordNet (CC BY 4.0), Princeton WordNet (permissive notice), CMUdict, Wiktionary/Wiktextract (CC BY-SA 4.0 + GFDL), Tatoeba (CC BY 2.0 FR).
   - Do not ship Oxford 3000/5000, English Vocabulary Profile or COCA-derived lists without a written license.
   - Generate definitions, examples and translations at build time with Claude Haiku 5.5 (draft) and Sonnet 5.5 (judge). Roughly $20–$850 for 30k words in 10 languages. Human review is the real cost.
6. **Monetization.** StoreKit 2 with `SubscriptionStoreView`, or RevenueCat/Adapty. Paywalls live in the app only. Widgets and extensions may not host IAP or ads (Guidelines 4.4 and 2.5.18). Gate widgets through an entitlement snapshot in the App Group.
7. **Top risks.**
   - Guideline 4.3(b) in a saturated category. An app titled "Widget Vocabulary: Learn Words" (Orbit Studios, released 2026-06-24) already exists, so do not reuse that name, icon or metadata ([MWM listing](https://mwm.ai/apps/widget-vocabulary-learn-words/6775767149) [S]).
   - Widgets that silently stop updating. Reviews of the market leader already report this ([App Store: Vocabulary – Learn words daily](https://apps.apple.com/app/id1084540807) [V]).
   - License contamination from share-alike data.

---

## 1. WidgetKit deep dive

### 1.1 Families and platforms

| Surface | Family / mechanism | Notes |
|---|---|---|
| Home Screen, Today View | `systemSmall/Medium/Large` | Interactive (Button/Toggle) since iOS 17 [A] |
| iPad | `systemExtraLarge` | Buttons and toggles supported [A] |
| iPhone, iPad, Mac | `systemExtraLargePortrait` | Introduced in visionOS 26. **New in iOS/iPadOS/macOS 27** ([WWDC26 277](https://developer.apple.com/videos/play/wwdc2026/277/)) [A] |
| Lock Screen (iPhone, iPad) | `accessoryCircular/Rectangular/Inline` | Circular and Rectangular can be interactive on iPhone/iPad. Buttons are inactive while the device is locked [A] |
| StandBy | `systemSmall`, background removed | Display refresh rate in StandBy is system-defined and not budgeted. Red tint in low light [A] |
| CarPlay (iOS 26+, all cars) | `systemSmall`, full color, background removed | Buttons work only on touchscreen cars. Tap opens the app only if the app has CarPlay integration [A] |
| macOS | iPhone widgets on desktop and Notification Center, plus native Mac widgets | Interaction round-trips to the iPhone, so use `invalidatableContent()` [A] |
| visionOS 26 | Same families; mounting styles, textures, `levelOfDetail` | [WWDC25 278](https://developer.apple.com/videos/play/wwdc2025/278/) [A] |
| watchOS | `accessoryCorner/Circular/Rectangular/Inline`; Smart Stack | Smart Stack relevance via `RelevanceConfiguration` (watchOS 26) [A] |

- Rendering-mode support per family: the accessory circular, corner and inline families have no `fullColor` mode ([Preparing widgets for additional contexts](https://developer.apple.com/documentation/widgetkit/preparing-widgets-for-additional-contexts-and-appearances.md) [A]).
- `WidgetFamily.accessoryCorner` is watchOS-only. `WidgetFamily` is available from iOS 14, and visionOS from 26 ([WidgetFamily](https://developer.apple.com/documentation/widgetkit/widgetfamily.md) [A]).
- Vocab-specific advice:
  - Small: lemma plus IPA plus a one-line gloss.
  - Medium: add an example sentence and a speaker or Next button.
  - Large: 3–5 words, or the word plus a mini quiz.
  - Lock Screen inline: "lemma – gloss", very short strings.
  - Consider `disfavoredLocations` for CarPlay (distraction) ([same page](https://developer.apple.com/documentation/widgetkit/preparing-widgets-for-additional-contexts-and-appearances.md) [A]).

### 1.2 Providers and configuration

- `StaticConfiguration` plus `TimelineProvider` has a closure-based API.
- `AppIntentConfiguration` plus `AppIntentTimelineProvider` has an async API with `placeholder`, `snapshot(for:in:)` and `timeline(for:in:)` ([Making a configurable widget](https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget.md) [A]).
  - This is the right choice here, because users pick deck, CEFR level and rotation interval.
  - It requires iOS 17 or later. Before iOS 17, configuration used SiriKit Intents.
- Keep configuration to one or two parameters, with sensible defaults and support for multiple instances ([WWDC26 277](https://developer.apple.com/videos/play/wwdc2026/277/) [A]).
- `EntityQuery.suggestedEntities()` supplies deck choices. Use `defaultResult()` for the defaults.
- A widget tap passes the configured intent to the app via `NSUserActivity`. Read it with `widgetConfigurationIntent(of:)`. `WidgetCenter.getCurrentConfigurations` lists installed widget instances [A].
- Use that list to count which widget families users actually installed (an engagement metric) and to avoid pointless reloads.
- **Placeholder** must be synchronous and not touch disk (use `redacted`). **Snapshot** is shown in the gallery: instant, with sample data ([WWDC26 277](https://developer.apple.com/videos/play/wwdc2026/277/) [A]).

### 1.3 Reload policy, the budget, and a reliable "new word every X"

Facts from Apple's doc [A]:
- Policies: `.atEnd` (default), `.after(date)`, `.never`.
- The budget is **per widget instance**. It applies to a 24-hour window tuned to user habits and is not a fixed midnight reset.
- A frequently viewed widget typically gets **40–70 refreshes per day** (about every 15–60 minutes), with more reloads during a few days of "learning" after install.
- Not counted against the budget:
  - the containing app is in the foreground,
  - an active audio or navigation session,
  - the Now Playing app,
  - the widget performs an App Intent,
  - the widget animates,
  - locale or Dynamic Type changes.
- Entries should be at least about **5 minutes apart**. "Generate a timeline for as many future dates as possible… keep the interval of entries as large as possible."
- Calling `WidgetCenter.reloadTimelines` from the app is not budgeted while the app runs. The WWDC25 and WWDC26 sessions say frequent foreground reloads may be throttled, so do one final reload when the app backgrounds ([WWDC25 278](https://developer.apple.com/videos/play/wwdc2025/278/), [WWDC26 277](https://developer.apple.com/videos/play/wwdc2026/277/) [A]).

Strategy for a word-per-N-hours widget:
1. The schedule is a pure function of `(seed, deck, level, anchorDate, interval)`. Entry timestamps are aligned to interval boundaries so multiple widgets stay in sync.
2. One `timeline()` call returns about 48 hours of entries, capped at roughly 96 entries. Past reports mention instability at several hundred entries (a forum claim that more than 400 breaks and about 200 is safe) [S, anecdotal]. Apple publishes no entry cap.
   - At a 1 h interval that is 48 entries and one reload per ~2 days.
   - At 15 min it is 96 entries per 24 h, still only about 1–2 reloads a day.
3. Use `.atEnd`. Optionally use `.after(lastEntry − 4×step)` to refresh early while enough entries remain, as slack against a delayed reload.
4. The app calls `reloadAllTimelines()` on foreground exit and after any state change (a word marked known, a deck changed, entitlement changed).
5. Each entry holds only a small Codable payload (id, lemma, IPA, short gloss, example). Do not query the DB from the view.
6. Intent taps always trigger a timeline reload, which is free ([Adding interactivity](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities.md) [A]).
7. A WidgetKit push (iOS 26) is only worthwhile for server-driven content such as an editorial "word of the day" (section 1.6).
8. Test outside Xcode. Debug runs do not enforce budgets, and WidgetKit Developer Mode removes them ([WWDC26 277](https://developer.apple.com/videos/play/wwdc2026/277/) [A]; forum [S]).

```swift
// Shared payload: small, Codable, no DB handles
struct WidgetWord: Codable, Hashable { let id: Int; let lemma: String; let ipa: String?
                                       let pos: String; let gloss: String; let example: String?; let level: String }
struct WordEntry: TimelineEntry {
    let date: Date; let word: WidgetWord; let isKnown: Bool; let isPremium: Bool
    var relevance: TimelineEntryRelevance? = nil
}

struct WordProvider: AppIntentTimelineProvider {
    func placeholder(in: Context) -> WordEntry { .placeholder }
    func snapshot(for cfg: WordConfigIntent, in: Context) async -> WordEntry { .sample }   // instant, no I/O
    func timeline(for cfg: WordConfigIntent, in ctx: Context) async -> Timeline<WordEntry> {
        let plan = WidgetPlanStore.load()                        // tiny JSON in App Group, atomic
        let step = max(cfg.rotation.seconds, plan.isPremium ? 900 : 86_400)   // free tier: daily
        let n = max(1, min(Int(48 * 3600 / step), 96))           // ~48h, capped
        let words = ContentStore.shared.queue(deck: cfg.deck.id, level: cfg.level,
                                              from: plan.cursor(cfg.deck.id), count: n, seed: plan.seed)
        let anchor = Date().rounded(down: step)                  // aligned boundaries
        let entries = words.enumerated().map { i, w in
            WordEntry(date: i == 0 ? .now : anchor.addingTimeInterval(Double(i) * step),
                      word: w, isKnown: plan.known.contains(w.id), isPremium: plan.isPremium)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}
```

### 1.4 Interactivity (iOS 17+): Next, Reveal, Known, Play

- Only `Button(intent:)` and `Toggle(isOn:intent:)` work. Persist all data **before** `perform()` returns, because the system reloads the timeline immediately after ([Adding interactivity](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities.md); [WWDC23 10028](https://developer.apple.com/videos/play/wwdc2023/10028/) [A]).
- The widget's parameters are not resolved by the system; pre-populate them via a custom `init`.
- `AppIntent` runs in the extension process by default. It runs in the app process if `openAppWhenRun` is true, or for `AudioPlaybackIntent`, `LiveActivityIntent` or `ForegroundContinuableIntent`.
- Use `invalidatableContent()` for perceived latency, especially on Mac. Toggles update optimistically [A].
- Buttons do nothing while the device is locked [A].

```swift
struct NextWordIntent: AppIntent {                       // target: app + widget extension
    static var title: LocalizedStringResource = "Next word"
    @Parameter(title: "Deck") var deckID: String
    init() {}; init(deckID: String) { self.deckID = deckID }
    func perform() async throws -> some IntentResult {
        WidgetPlanStore.mutate { $0.advanceCursor(deck: deckID) }   // atomic file write, not SQLite
        WidgetEventLog.append(.skipped(deck: deckID))               // append-only file in App Group
        return .result()                                            // system reloads timeline next
    }
}
// In the view: Button(intent: NextWordIntent(deckID: entry.deckID)) { Image(systemName: "forward.fill") }
// "Known": Toggle(isOn: entry.isKnown, intent: ToggleKnownIntent(wordID: entry.word.id)) { ... }
```

**Pronunciation audio from a widget.**
- The widget cannot play sound itself. The only supported route is an `AudioPlaybackIntent`, which the system runs in the **app** process. Apple's doc lists it as available from iOS 17 ([AudioPlaybackIntent](https://developer.apple.com/documentation/appintents/audioplaybackintent.md) [A]).
- Forum reports of the iOS 18 era say cold-launch latency is several seconds, the system kills the process if `setActive(true)` is called from a non-audio intent, and only the `.playback` audio-session category reliably produces sound ([thread 761677](https://developer.apple.com/forums/thread/761677), [thread 736841](https://developer.apple.com/forums/thread/736841) [S]).
- Recommendation: offer a speaker button as a v2 nicety, built on `AudioPlaybackIntent` and tested on a device. The fallback is a tap that deep-links with `widgetURL` and autoplays in the app.
- Never rely on audio as a core widget interaction.

### 1.5 Appearance: rendering modes, iOS 18 tinting, iOS 26 Liquid Glass

- `containerBackground(for: .widget)` is mandatory in practice. The system strips or replaces the background in vibrant, StandBy, tinted and clear contexts. Opting out with `containerBackgroundRemovable(false)` excludes the widget from the gallery in contexts that need a removable background (iPad Lock Screen, StandBy) ([Displaying the right widget background](https://developer.apple.com/documentation/widgetkit/displaying-the-right-widget-background.md) [A]).
- Read `@Environment(\.widgetRenderingMode)` (`fullColor`, `accented`, `vibrant`). Group primary and accent content with `.widgetAccentable()`.
- In tinted or clear mode on iOS 26/macOS Tahoe, the system renders in **accented** mode, tints everything white, drops the background and substitutes a themed glass or tint effect ([Optimizing for accented rendering and Liquid Glass](https://developer.apple.com/documentation/widgetkit/optimizing-your-widget-for-accented-rendering-mode-and-liquid-glass.md) [A]).
  - For images use `.widgetAccentedRenderingMode(.desaturated | .accentedDesaturated)`. Reserve `.fullColor` for artwork and covers ([WWDC25 278](https://developer.apple.com/videos/play/wwdc2025/278/) [A]).
  - A vocab widget is mostly text, so it adapts well. Avoid semi-transparent gradients and color-only meaning, such as green for known words. Add icons or labels too.
- Use `isLuminanceReduced` for Always On, and `AccessoryWidgetBackground` for circular Lock Screen backgrounds [A].
- App icon: Icon Composer (Xcode 26) produces a single `.icon` file for default, dark, clear and tinted ([Apple docs](https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer.md); [Create with Swift](https://www.createwithswift.com/crafting-liquid-glass-app-icons-with-icon-composer/) [A/S]).

### 1.6 Controls, Live Activities, push, relevance

- **Controls (iOS 18, `ControlWidget`)** appear in Control Center, on the Lock Screen and on the Action button ([WWDC24 10157](https://developer.apple.com/videos/play/wwdc2024/10157/); [Creating controls](https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system.md) [A]).
  - Good fit: "Word of the day" (an `OpenIntent` deep link) and "Start 1-min quiz".
  - Reload with `ControlCenter.shared.reloadControls(ofKind:)`.
- **Live Activities.** Not appropriate for a passive word feed.
  - They fit "ephemeral content with a defined start and end", last 8 hours (plus up to 4 hours on the Lock Screen after ending), carry 4 KB of data, and must be started from the foreground or a `LiveActivityIntent` ([Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities.md) [A]; [WWDC26 277](https://developer.apple.com/videos/play/wwdc2026/277/) [A]).
  - The only plausible use is a timed study session, which is a v3 optional item. Using a Live Activity as a pseudo-widget invites review issues [I].
- **WidgetKit push (iOS 26).** Implement `WidgetPushHandler.pushTokenDidChange(_:widgets:)`, add the Push Notifications entitlement to the widget extension, and send APNs with `apns-push-type: widgets`, topic `<bundleID>.push-type.widgets`, and payload `{"aps":{"content-changed":true}}` ([Apple doc](https://developer.apple.com/tutorials/data/documentation/widgetkit/updating-widgets-with-widgetkit-push-notifications.md) [A]).
  - It reloads all push-enabled widgets. It is budgeted and opportunistic, supplements timelines and does not replace them. It cannot use broadcast channels.
  - Needed only for server-driven editorial content.
- **Relevance (Smart Stack).**
  - iPhone/iPad: `TimelineEntryRelevance(score:duration:)` per entry, plus donating `PredictableIntent`s when users open a deck. A score of 0 or less means not relevant.
  - watchOS: the `relevance()` callback, or `RelevanceConfiguration` with `RelevanceEntriesProvider`. Apple's WWDC25 session places this in watchOS 26, but one Apple doc code sample says `@available(watchOS 12, *)`, so verify before coding ([Widget suggestions](https://developer.apple.com/documentation/widgetkit/widget-suggestions-in-smart-stacks.md); [WWDC25 278](https://developer.apple.com/videos/play/wwdc2025/278/) [A]).
  - Suggestion: raise the score at the user's habitual study time (learned from your own analytics) and when the next word is due in SRS.

### 1.7 Memory, performance, protection

- The widget extension limit is about **30 MB**, reported in crash logs (EXC_RESOURCE, limit=30 MB). Apple does not publish it as a documented constant [S] ([forum 842805](https://developer.apple.com/forums/thread/842805), [forum 713561](https://developer.apple.com/forums/thread/713561)). Large archived timelines count.
- Practical rules:
  - Do not open Core Data/CloudKit, SwiftData or large stores in the widget. A reported case used 350 MB of Core Data and the extension crashed ([thread 732781](https://developer.apple.com/forums/thread/732781) [S]).
  - Read at most about 50–100 small rows through one read-only connection.
  - Downsample any images and avoid network calls in `timeline()`.
- **Data protection** [I, commonly reported]: shared files with `.complete` protection are unreadable while locked, so Lock Screen widgets go blank. Use `.completeUntilFirstUserAuthentication` (the default) or `.none` for the snapshot JSON. After a reboot and before first unlock, expect placeholder content.

### 1.8 iOS 27 notes

- The one confirmed WidgetKit change is the `systemExtraLargePortrait` family on iOS, iPadOS and macOS 27 ([WWDC26 277](https://developer.apple.com/videos/play/wwdc2026/277/) [A]).
- Apple's iOS 27 guide says widgets can be customized through App Intents and dynamic styling. It adds App Intents testing, entity schemas that feed the Spotlight semantic index, and View Annotations ([WWDC26 iOS guide](https://developer.apple.com/wwdc26/guides/ios/) [A]).
- Press claims about a 4×6 "full-page" widget, a compact Lock Screen clock and a Shortcuts "Notification" trigger are secondary and unverified ([9to5Mac](https://9to5mac.com/2026/06/08/ios-27-adds-extra-large-widgets-for-your-extra-large-needs/), [Kökdemir](https://mucahitk.com/blog/ios-27-widgets-whats-new) [S]).

---

## 2. App architecture

### 2.1 Persistence options

| Layer | Option | Verdict |
|---|---|---|
| Word content (10–50k lemmas; read-only) | **SQLite via GRDB** (FTS5, WAL not needed for an immutable DB) | **Recommended.** Deterministic, tiny memory, prebuilt and versioned. GRDB 7.11.1 (June 2026); Swift 6.1+, Xcode 16.3+ ([releases](https://github.com/groue/GRDB.swift/releases) [V]) |
| | SwiftData | Poor fit. Schema and migration overhead, and a slow first launch for bulk import. Do not seed 50k rows at runtime |
| | Core Data | Same objection |
| User state (progress, review log, settings) | SwiftData with CloudKit | Good if the schema is small. Constraints: no unique constraints, all relationships optional, additive-only production schema, requires iCloud and Background Modes ([Apple doc](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices.md) [A]) |
| | GRDB plus `CKSyncEngine` (iOS 17+) or Point-Free's SQLiteData (MIT, GRDB-based, iOS 17+) | More control and no SwiftData maturity risk. You must persist sync state and write the delegate yourself ([Apple CKSyncEngine](https://developer.apple.com/documentation/cloudkit/cksyncengine-4b4w9.md); [SQLiteData](https://github.com/structuredpath/sqlite-data) [A/S]) |

- WWDC26 SwiftData additions: `@Query(sectionBy:)`, `@Attribute(.codable)`, `ResultsObserver`, `HistoryObserver`. Nothing on widgets, app groups or CloudKit ([WWDC26 274](https://developer.apple.com/videos/play/wwdc2026/274) [A]).
- **Recommendation:** content in GRDB; user state in SwiftData + CloudKit (solo dev) or GRDB + CKSyncEngine (more control). **Never put word content in CloudKit.** Sync only user progress, keyed by stable integer `word_id`s that are never reused.

### 2.2 Shared storage between app and widget (critical)

- Apple's suggested pattern is an App Group shared container, either a shared DB or `UserDefaults` ([WWDC26 277](https://developer.apple.com/videos/play/wwdc2026/277/) [A]).
- **Do not share a live, writable SQLite between app and extension.**
  - `0xDEAD10CC` terminations happen when a process is suspended holding a file or SQLite lock. Marco Arment: "Don't keep the SQLite database in the shared container. You'll never get rid of all of those crashes" ([Michael Tsai, 2025-05-15](https://mjtsai.com/blog/2025/05/15/sqlite-databases-in-app-group-containers-dont/) [S]).
  - GRDB offers `suspendNotification` mitigation, which it labels experimental. It is a `DatabasePool`/WAL tool ([GRDB sharing guide](https://mintlify.com/groue/GRDB.swift/guides/sharing-a-database) [S]).
- Safe pattern:
  1. **Content DB:** shipped inside the app bundle, copied to the App Group container on first launch or on content-version bump, and opened read-only with `?immutable=1` (no locks, no journal).
  2. **Seed fallback:** a small seed JSON (about 300–500 top words) inside the widget extension bundle, so a widget added before the first app launch still works.
  3. **Snapshot:** the app writes `widget_plan.json` atomically. It holds the entitlement flag, per-deck cursor, seed, settings, and the known/ignored sets.
  4. **Event mailbox:** the widget and its intents append small, uniquely named event files (`skipped`, `known`, `revealed(rating)`). The app ingests them on foreground and folds them into the user store, then reloads timelines.
  5. Notify between processes with Darwin notifications (an Arment suggestion) or just rely on timeline reloads.
- GRDB build gotcha: embedding the package in extension targets can fail with "No such module 'CSQLite'" due to an Xcode bug ([GRDB README](https://github.com/groue/GRDB.swift) [V]).
- Privacy manifest: an app-group `UserDefaults` suite is a required-reason API (UserDefaults category). Reason code 1C8F.1 covers data shared only within the same App Group, including extensions ([forum 740092](https://developer.apple.com/forums/thread/740092) [S]). Each executable's bundle that uses required-reason APIs, including the widget `.appex`, needs its own privacy manifest ([Apple](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api.md) [A]).

### 2.3 Distribution of a large offline DB

- Text size estimate [I]: about 3 KB per word with 10 translation languages, so roughly 90 MB raw for 30k words (compresses well).
- Keep the base download small:
  - Ship English plus a selected set of native-language packs on demand, or default to the user's locale.
  - Apple-hosted Background Assets (iOS 26+, "managed asset packs") are the successor to On-Demand Resources ([WWDC25 325](https://developer.apple.com/videos/play/wwdc2025/325) [A]). The forum-reported limits are 200 GB and 100 asset packs. Whether the 200 GB is per app or per team is unresolved ([thread 827100](https://developer.apple.com/forums/thread/827100) [S]).
- Content updates: version the DB. Data-only updates through a CDN are fine, because they are data and not code [I].

### 2.4 Modular structure

See section 9 for the folder layout. Core rules: `CoreModels` is pure Swift; `ContentStore`, `SharedState` and `Scheduler` are linked into both the app and the widget; `UserStore`, `Entitlements` and `Analytics` link into the app only. Intents live in a shared package so both targets can include them (App Intents Packages, `AppIntentsPackage`).

### 2.5 App Intents, Siri, Spotlight, Watch

- **App Intents.** The same intents power widget buttons, Shortcuts, Siri and Spotlight. `AppShortcutsProvider` gives zero-setup phrases ("Word of the day", "Quiz me"). New in 2025/26: `supportedModes`, `@ComputedProperty`, indexing keys on entity properties, packages, and Spotlight can run intents on Mac ([WWDC25 244](https://developer.apple.com/videos/play/wwdc2025/244/) [A]).
- **Spotlight.** `IndexedEntity` with `@Property(indexingKey:)` (iOS 18+) removes the need for manual `CSSearchableItem`s. Index only the learned, favorite and "word of the day" words, not 50k entries [A/S].
- **iOS 27.** Entity schemas, view annotations and an App Intents testing framework per the WWDC26 iOS guide [A].
- **Apple Watch.** watchOS 26 widgets appear in the Smart Stack and as complications. Reuse the same provider with accessory families. Relevance via `RelevanceConfiguration` (watchOS 26) [A]. A full watch app (quiz) is v3.
- **On-device Foundation Models.**
  - Free Private Cloud Compute access exists for Small Business Program apps under 2 million total first-time downloads, per Apple's iOS 27 guide [A].
  - Turkish and several other languages were announced as Apple Intelligence additions, but the sources disagree on timing and device-language requirements ([forum 805378](https://developer.apple.com/forums/thread/805378) [S]).
  - Use it for optional "explain this word" or personalized example sentences with a graceful fallback, not for core content.

---

## 3. Learning science

### 3.1 SRS algorithms

| Algorithm | Model | Pros / cons |
|---|---|---|
| Leitner | Boxes 1–5, fixed intervals (for example 1/2/4/8/16 days), promote on success, demote to box 1 on failure | Trivial and explainable. Fine for MVP. No per-item difficulty [I] |
| SM-2 | Easiness factor ≥1.3, interval multiplied by EF, quality 0–5 | Simple but poorly calibrated for forgetting. Largely superseded [I] |
| **FSRS** | Memory model with difficulty, stability, retrievability (power-law forgetting curve), user-set desired retention (default 0.9) | Best retention per review. FSRS-6 has 21 parameters |

- **FSRS status.** FSRS-6 is the widely deployed version (Anki, RemNote, ts-fsrs, py-fsrs, fsrs-rs) ([awesome-fsrs](https://github.com/open-spaced-repetition/awesome-fsrs) [V]). FSRS-7 (34 parameters, a two-trace memory, fractional-day intervals, intervals from root-finding) exists in `fsrs-rs` and a Haskell port. Anki or official adoption is unconfirmed ([haskell-fsrs](https://hackage-content.haskell.org/package/haskell-fsrs) [S]). Use FSRS-6.
- **Swift.** `open-spaced-repetition/swift-fsrs` (MIT) implements FSRS-6 (parameters via `FSRSDefaults.defaultWv6`), supports FSRS-5 through a 19-length array, and exposes `createEmptyCard()` and `next(card:now:grade:)` ([repo](https://github.com/open-spaced-repetition/swift-fsrs) [V]). Its release and maintenance cadence is unclear. The Releases tab was empty, so pin a commit. A separate 4rays/swift-fsrs port is v5 only ([Swift Package Index](https://swiftpackageindex.com/4rays/swift-fsrs) [S]).

### 3.2 Adapting SRS to passive widget exposure

- **Principle.** Reading a word is not retrieval. Feed FSRS only on retrieval events: quiz answers and widget "reveal then self-rate". Never on a mere widget impression.
- **Exposure counter.** Store `exposure_count` and `last_exposed_at` per word.
  - Use it to prioritize the widget queue, not to schedule reviews.
  - Optionally apply a tiny familiarity prior at first review (start stability slightly higher), tuned on your own data [I].
- **Widget as a flashcard (v2).**
  - Front: word and IPA. A Reveal button runs a free intent (no timeline restart needed, but it reloads) and shows the gloss. Then two buttons, "Knew it" and "Again", write `rating` events to the mailbox (section 2.2).
  - The app ingests them as FSRS reviews with `source = widget_reveal`.
- **Widget selection policy.** A mix such as 60% due or learning words, 30% new words at the user's level, 10% recently mastered refreshers. Cap new words per day. Choose next entries deterministically from `seed` so timelines are reproducible.
- **Quiz types.**
  - Multiple choice, with distractors precomputed per word (same POS and CEFR band).
  - Cloze (fill in the blank), using a stored cloze span in each example.
  - Typing: spelling, with a Levenshtein tolerance.
  - Listening: hear a word and pick or type it. TTS-dependent.
  - Matching and "which is the synonym" for variety.
  - Ratings map 1–4 (Again/Hard/Good/Easy). Response time can down-rate a slow correct answer to Hard.
- **"Known" definition.**
  - Verified known: FSRS stability at or above 21–30 days and at least 2 successful retrievals (a config constant).
  - Self-declared known: a toggle, stored separately as `known_override`.
  - Report both in stats.
  - A known word leaves the widget rotation but stays in rare refresher slots.

### 3.3 Placement test (CEFR A1–C2)

- Build an adaptive yes/no plus multiple-choice test across frequency and CEFR bands.
  - Use pseudowords with a guessing correction.
  - Place the user at the highest band where accuracy is at or above a threshold, then confirm in the first days using actual review accuracy.
  - Offer a manual override.
- Don't copy published tests. The Vocabulary Size Test's own sheet allows research use without permission, and its journal record shows a CC BY-NC-ND licence, so commercial reuse is unclear. LexTALE is distributed via Inquisit licensing. Both are weak proxies for four-skill CEFR placement ([VST info](https://www.wgtn.ac.nz/lals/resources/paul-nations-resources/vocabulary-tests/the-vocabulary-size-test/Vocabulary-Size-Test-information-and-specifications.pdf), [LexTALE](https://www.millisecond.com/library/lextale) [S]).
- Label results "estimated vocabulary level" and not an official CEFR score [I].

---

## 4. Content pipeline

### 4.1 Source licenses (not legal advice; have counsel review before launch)

| Source | License / status | Commercial app? |
|---|---|---|
| **NGSL 1.2** (2,809 words), **NAWL, TSL, BSL** | CC BY-SA 4.0; further permissions via the authors ([NGSL](https://www.newgeneralservicelist.com/new-general-service-list) [V]) | Yes with attribution. Share-alike on adapted data; keep the list as a separable tag and publish the tag file under CC BY-SA, or get counsel's view [I] |
| **CEFR-J vocabulary 1.5** | Free for research and commercial use with citation; copyright Tono Lab, TUFS ([OLP repo](https://github.com/openlanguageprofiles/olp-en-cefrj) [V/S]). Confirm on cefr-j.org (a 1.6 exists per a 2023 talk) | Yes with citation |
| **Octanove C1/C2 profile** | CC BY-SA 4.0 [S] | Yes, share-alike |
| **Oxford 3000/5000** | © Oxford University Press. OUP licenses lists to commercial apps (for example Cookie Langs' deal for the Oxford 2000) ([License Global](https://www.licenseglobal.com/new-mediasocial/cookie-langs-collaborates-oxford-university-press-english-language-learning-app) [S]); no public reuse terms found | **No, without a license** |
| **English Vocabulary Profile** (Cambridge) | No published reuse license found; web resource | **No, without written permission** |
| **Academic Word List** (Coxhead) | No explicit official license found; republished PDFs carry CC BY-NC-ND/NC-SA terms ([TextProject](https://textproject.org/wp-content/uploads/resources/Academic-word-list.pdf) [S]) | Unclear. Prefer **NAWL** or ask the University for written permission |
| **Princeton WordNet 3.0/3.1** | Permissive: any use incl. commercial; keep copyright and disclaimer; no use of Princeton's name in publicity ([SPDX](https://spdx.org/licenses/WordNet.html), [license page](https://wordnet.princeton.edu/node/10) [S]) | Yes |
| **Open English WordNet** | CC BY 4.0 (120,068 synsets, 153,261 entries) ([en-word.net](https://en-word.net/) [V]) | Yes with attribution |
| **Wiktionary / Wiktextract / kaikki.org** | CC BY-SA 4.0 and GFDL; attribution and share-alike ([Wiktionary:Copyrights](https://en.wiktionary.org/wiki/Wiktionary:Copyrights) [V]) | Yes. Derived dictionary data must stay CC BY-SA; add an attribution screen |
| **CMUdict** | "Unrestricted" for any research or commercial purpose; credit CMU ([license file](https://mirrors.cqupt.edu.cn/kde-application/accessibility/Simon/lm/LICENSE.cmudict) [S]) | Yes. US IPA only, via ARPAbet conversion |
| **Tatoeba sentences** | CC BY 2.0 FR (some CC0); per-sentence author attribution ([downloads](https://tatoeba.org/ca/downloads) [V]) | Yes with attribution; only trust proofread sentences |
| **wordfreq** | Data CC BY-SA 4.0; code Apache; SUBTLEX included by email permission; frozen at about 2021 ([PyPI/README](https://pypi.org/project/wordfreq/1.2) [S]) | Likely. Store coarse frequency bands, not raw counts |
| **SUBTLEX-US** | OSF listing says "Other"; no clear public license | Use only via wordfreq's grant or ask Brysbaert |
| **COCA lists** | Licensed; no redistribution of derived frequency, collocate or ngram data ([English-Corpora](https://www.english-corpora.org/coca/help/download.asp) [V]) | **No** unless licensed. Frequency bands may be allowed [S] |
| **Bundled pronunciation audio** | Wikimedia Commons: per-file CC licenses ([search summary](https://commons.wikipedia.com/wiki/File:Lumbini_audio.ogg) [S]). Forvo: its CC era ended in 2019 and its license now restricts reuse ([Forvo](https://en.wikipedia.org/wiki/Forvo) [S]) | Commons per file, with attribution. Forvo needs a license |

**Dictionary APIs.** Never make a live API call from a widget or the core flow. Use them as references only.

- **Merriam-Webster API.** Free only for non-commercial use, up to 1,000 queries per day per key and 2 reference APIs. Monetized apps, whether ads or paid, need case-by-case commercial terms ([license](https://dictionaryapi.com/info/terms-of-service) [V]).
- **Oxford Dictionaries API.** A commercial license is required.
  - After the January 2025 relaunch, Lite and Growing plans start at £50 per month billed annually.
  - Enterprise is "commercial use only", from £5,000 per language per year (that page's date is unknown) ([plans](https://languages.oup.com/products/api/), [enterprise](https://developer.oxforddictionaries.com/signup-enterprise) [V/S]).
- **Wordnik.** Commercial apps beyond proof of concept need a paid plan; attribution is required; the API cannot be replicated. Tier numbers conflict across sources ([FAQ](https://developer.wordnik.com/faq) [V]).
- **Free Dictionary API (dictionaryapi.dev).** Wiktionary-derived (CC BY-SA, version uncertain) and unofficial, so unsuitable as a dependency [S].

**Etymology.** Wiktionary etymologies are CC BY-SA. Alternatively, generate a one-line original note with the LLM and verify against Wiktionary [I].

### 4.2 LLM generation at build time (Claude)

Pricing, from the [official pricing page](https://platform.claude.com/docs/en/about-claude/pricing) [V]:

| Model | ID | Input / Output per MTok | Batch (50%) |
|---|---|---|---|
| Haiku 5.5 (prompts ≤100K tokens) | `claude-haiku-5-5` | $0.10 / $0.50 | $0.05 / $0.25 |
| Sonnet 5.5 | `claude-sonnet-5-5` | $2 / $10 | $1 / $5 |
| Opus 5.5 | `claude-opus-5-5` | $4 / $20 | $2 / $10 |

- Cache reads: Haiku 5.5 $0.01, Sonnet 5.5 $0.10, Opus 5.5 $0.20 per MTok.
- Notes on Haiku 5.5: it prices requests over 100K prompt tokens higher ($0.50 / $2.50). Thinking is on by default at medium effort, so set `effort: "low"` for bulk jobs ([model reference](https://platform.claude.com/docs/en/about-claude/models) [V]).
- Batch up to about 20 words per request.

**Assumptions** for the table below. Per word, English: about 250 amortized input tokens, 300 visible output tokens, plus 50% hidden-thinking overhead. Translations, per language: 175 input, 120 output, plus 50% thinking. A judge pass: about 700 input and 40 output tokens per word.

| Scenario (30,000 words; 10 translation languages) | Standard | Batch |
|---|---|---|
| Haiku 5.5, all drafting plus a Haiku judge | about $42 | about $21 |
| **Hybrid:** Haiku 5.5 drafts English and translations, Sonnet 5.5 judges everything | about $424 | about $212 |
| Sonnet 5.5 for everything | about $849 | about $424 |
| Opus 5.5 for everything | about $1,698 | about $849 |

- For 20k words: Haiku-only about $28, hybrid about $282. For 50k words: Haiku-only about $71, hybrid about $706 (standard rates).
- Conclusion: token cost is trivial next to human review. Spend on QA, not on model tier.

**Quality-control pipeline.**
1. Seed with open data: headword, POS, CEFR/band from the open lists, and an Open English WordNet gloss. Do not feed copyrighted dictionary text as a seed, and instruct the model to write original definitions [I].
2. Generate structured JSON (schema-enforced): 1–3 senses, CEFR-appropriate definitions, 3 examples, collocations, synonyms, an optional mnemonic and a one-line etymology.
3. Deterministic checks:
   - Each example contains an inflected form of the lemma (use a lemmatizer).
   - Definition vocabulary is at or below the target level plus one band (checked against your own band lists).
   - Profanity and sensitive-topic filter.
   - Dedupe, length limits and POS consistency.
4. LLM judge on a rubric (correctness, naturalness, level fit, bias, offensive content), with Sonnet 5.5 or Opus 5.5. Auto-reject on low scores.
5. Human review:
   - Stratified spot-checks of 5–10% by level and POS.
   - 100% of the A1–A2 core (about 2k words), since beginners trust these.
   - Native-speaker review for each translation language. Turkish agglutination and vowel harmony are a known weak point [I].
6. Log provenance per record (`source`, `model`, `prompt_version`, `reviewed_state`) so you can regenerate or retract.
7. Re-run judge-only passes when you change the rubric.

**Translations.** Prefer 1–3 word translation equivalents per sense (cheap, high value) plus a translated example only for premium languages. Wiktionary translations (CC BY-SA) can seed and cross-check them.

### 4.3 TTS and audio

- **On-device `AVSpeechSynthesizer`** is free, needs no network, and is private. Premium voices must be downloaded by the user, and there is no API to detect uninstalled premium voices ([thread 758460](https://developer.apple.com/forums/thread/758460) [S]).
  - `write(_:toBufferCallback:)` can capture buffers, but one developer flags that the iOS SLA limits Personal Voice to non-commercial use. This is unanswered, so don't ship Personal Voice audio.
  - A voice-selection regression was reported in iOS 26.0/26.1 beta ([thread 804648](https://developer.apple.com/forums/thread/804648) [S]).
- **Cloud TTS to pre-generate** (30k words; character counts are my estimates):
  - Google Chirp 3 HD: $30 per million characters, first 1M free (Google's own page) ([pricing](https://cloud.google.com/text-to-speech/pricing) [V]).
  - Azure neural at about $15 per million, ElevenLabs Flash/Turbo at about $50, and ElevenLabs Multilingual v2/v3 at about $100 per million. These three are secondary figures, so verify them on the vendors' own pages ([ModelsLab](https://modelslab.com/elevenlabs-api-pricing), [SpeechActors](https://speechactors.com/article/microsoft-azure-pricing-and-plans) [S]).
  - Words only: about $4–27. Words plus 3 examples each: about $100–660.
- **Size.**
  - Word audio at about 3–5 KB per clip gives about 90–150 MB for 30k words.
  - Sentence audio (3 per word) is about 1 GB, so do not bundle it.
  - Ship the top 3–5k words (about 15–25 MB). Deliver the rest as on-demand packs (section 2.3). Use on-device TTS for sentences.
- **IPA.** Derive US IPA from CMUdict (ARPAbet to IPA) and UK IPA from Wiktionary (CC BY-SA).
- **Images.** Skip for MVP (widget memory risk, licensing). Use SF Symbols and typography.

### 4.4 Multi-language

- Make every table language-agnostic from day 1 (BCP-47 codes, per-language lemmatizer).
- **Native-language (UI/translation) packs:** Turkish, Spanish, Portuguese, German, French, Arabic, Russian, Japanese, Korean, Chinese.
- **Learning languages beyond English:** sources are mostly Wiktionary (kaikki.org per-language dumps), Tatoeba, and open frequency lists. Open CEFR-tagged lists are scarce outside English. Plan for LLM CEFR estimation plus human review.
- Foundation Models availability and quality for Turkish and other languages is unverified (see section 2.5).

---

## 5. Monetization technology

- **StoreKit 2** with `SubscriptionStoreView` and `ProductView`, `Transaction.updates`, and `Product.SubscriptionInfo.status`.
- **Offers** ([WWDC24 10110](https://developer.apple.com/videos/play/wwdc2024/10110/) [A]):
  - Intro offers (free trial or discount).
  - Promotional offers.
  - Offer codes.
  - **Win-back offers (iOS 18+).** Configure in App Store Connect with paid-duration, time-since-lapse and wait-between-offers rules. Present via the default `Message` sheet, `SubscriptionStoreView`, or custom UI using `RenewalInfo.eligibleWinBackOfferIDs` and `Product.SubscriptionInfo.winBackOffers` ([Merchandising win-back offers](https://developer.apple.com/documentation/storekit/merchandising-win-back-offers-in-your-app.md) [A]).
- **New in 2026 (WWDC26 session 210)** ([session](https://developer.apple.com/videos/play/wwdc2026/210) [A]):
  - **Monthly billing with a 12-month commitment** for one-year subscriptions. New APIs: `SubscriptionInfo.pricingTerms`, `.billingPlanType(.monthly)`, and `Transaction.commitmentInfo`. Apple's session cites both iOS 26.4 and 26.5 as the version, so verify.
  - Bundles and Suites (testable in Xcode 27).
  - `offerCodeRedemption` with `RedeemOption`.
  - `reviewSubmissions` in the App Store Connect API now covers IAP, and the standalone IAP/subscription submission resources are deprecated.
- **Family Sharing.** Enabling it per subscription in App Store Connect is **irreversible**. Check `Product.isFamilyShareable`, and handle `ownershipType == .familyShared` ([Apple](https://developer.apple.com/documentation/storekit/supporting-family-sharing-in-your-app.md) [A]).
- **Fees.** Small Business Program: 15% from the first month if you are enrolled (proceeds at or under $1M in the prior year); otherwise 30% in year 1 and 15% afterward ([Adapty guide](https://adapty.io/blog/app-store-small-business-program/) [S]).

### Paywall/subscription platforms (October 2026)

| Platform | Pricing | Notes |
|---|---|---|
| **RevenueCat** | Free to $2,500 monthly tracked revenue, then 1% of what you track. Whether the 1% applies to all revenue or only the excess is not stated on the page; a separate "Growth Tools" option charges only on conversions from tools you use ([pricing](https://www.revenuecat.com/pricing/) [V]) | Mature SDK, entitlements, webhooks, Paywalls, Experiments, Android parity |
| **Adapty** | Free under $5,000 monthly tracked revenue; 1% above. The old $99 minimum was replaced (effective 2026-02-16); add-ons are priced separately above $5k ([Adapty](https://adapty.io/blog/adapty-new-pricing-2026/) [V]) | Paywall builder, A/B tests and analytics included |
| **Superwall** | MAR-based: under $10k monthly attributed revenue free. Tiers: Indie $0, Startup $49, Scale $199, Enterprise custom. The percentage rate was not published in the FAQ ([FAQ](https://superwall.com/docs/support/faq/2801653905-how-does-superwalls-pricing-work.md) [V]); the legacy plan was 250 free conversions, then $0.20 each | Strongest paywall-placement and experiment tooling; pairs with RevenueCat or your own StoreKit |
| **Qonversion** | Official page: free to $10k monthly tracked revenue; Starter 0.6%, Growth 0.8% (A/B experiments on Growth). One tracker reports the free tier cut to $7k on 2026-09-19, unconfirmed ([pricing](https://qonversion.io/pricing), [AgentDeals](https://agentdeals.dev/vendor/qonversion) [V/S]) | Cheapest percentage |
| DIY StoreKit 2 | Free | `SubscriptionStoreView` plus win-back and offers merchandising built in |

**Recommendation.** MVP on StoreKit 2 + `SubscriptionStoreView` (no vendor risk). Add RevenueCat when you need server-side validation, Android, or experimentation. Add Superwall only once you run paid acquisition and need placement-level A/B tests.

**Gating widgets.**
- Widgets and extensions cannot carry IAP or ads. Guideline 4.4 says extensions "may not include marketing, advertising, or in-app purchases", and 2.5.18 limits display advertising to the main binary ([Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) [A]).
- Approach:
  - The app writes an `EntitlementSnapshot` to the App Group on launch and on every `Transaction.updates` event. It then calls `reloadAllTimelines()`.
  - The widget reads it and never calls StoreKit. (A secondary source suggests live StoreKit in extensions is fragile; verify on a device if you want to rely on it.)
  - A non-subscriber sees degraded but working content: free deck, level A1–B1, daily rotation, small family only. Premium unlocks faster rotation, all families, Lock Screen widgets, quiz buttons and custom decks.
  - Never show a blank widget. Show a helpful state with `widgetURL(myapp://paywall?src=widget)`.
  - If the entitlement lapses, the widget falls back to the free configuration.
- Market price points (for orientation): Monkey Taps lists yearly at $35.99–$59.99 and lifetime at $149.99 ([App Store](https://apps.apple.com/app/id1084540807) [V]). Learn on Widgets lists $9.99 per month or $39.99 lifetime ([search summary](https://apps.apple.com/gr/app/learn-on-widgets/id6664071230) [S]). The Orbit Studios app offers weekly and yearly plans ([MWM](https://mwm.ai/apps/widget-vocabulary-learn-words/6775767149) [S]).

---

## 6. Analytics, attribution, backend, privacy

| Need | Options | Notes |
|---|---|---|
| Product analytics | **TelemetryDeck** (privacy-first; new accounts get 50k free events per month since July 1, 2026, older accounts keep 100k; ([post](https://telemetrydeck.com/blog/pricing-update-2026/) [V])), **PostHog** (1M events free, feature flags), **Mixpanel** (1M events free), **Amplitude** (moved to an event-based model in July 2026, so re-check its limits) [S] | For a privacy-first widget app, TelemetryDeck or PostHog |
| Crash reporting | **Crashlytics** (free), **Sentry** (free 5,000 errors per month), **MetricKit** (first party, unsymbolicated, you analyze) [S] | Crashlytics plus MetricKit |
| Remote config | Firebase Remote Config, PostHog flags, or a CDN-hosted JSON | CDN JSON is enough for MVP |
| Attribution | **AdAttributionKit** (iOS 17.4+; re-engagement since iOS 18; overlapping re-engagement windows since iOS 18.4) and **SKAdNetwork** coexist. AppsFlyer and Adjust support both ([WWDC25 221](https://developer.apple.com/videos/play/wwdc2025/221/), [AppsFlyer](https://www.appsflyer.com/glossary/adattributionkit/) [A/V]). One source claims SKAN endpoints deprecate by late 2026, unverified | Install an MMP only when paid UA starts |
| Apple Ads attribution | The `AdServices` framework (token) needs no ATT prompt [I] | Use it for Apple Ads |
| Push | **Local notifications** for word of the day: free, and iOS keeps at most 64 pending [I]. Schedule the next 7–14 days of words and refresh on app open and background refresh. **Remote push** only for server-driven messages (win-back, editorial) | Start local only |
| ATT | Required only if you track across apps or use IDFA. Avoid it unless you need IDFA-based attribution | Skip ATT in MVP |

**Privacy manifest and labels.**
- Each target (app, widget extension, watch app) needs a `PrivacyInfo.xcprivacy` that declares required-reason API use ([Apple](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api.md) [A]). Uploads without a reason for a required-reason API are rejected (since May 1, 2024).
- Likely categories for this app:
  - UserDefaults (CA92.1 for app-only access, or 1C8F.1 for the shared app group).
  - File timestamp.
  - Disk space.
  - System boot time.
- I could not fetch the code list from Apple's per-key doc, so check each code against the table in Apple's documentation before submitting. Only the 1C8F.1 meaning is confirmed [S].
- Each third-party SDK also needs its own manifest.
- App Store Connect age-rating questionnaire: the new 13+/16+/18+ tiers went mandatory on 2026-01-31 ([Apple](https://developer.apple.com/news/upcoming-requirements/) [A]).

---

## 7. Cross-platform

- **Widgets are always native**, so UI frameworks don't change that part of the work:
  - Flutter's `home_widget` is only a data bridge (iOS `UserDefaults`, Android `SharedPreferences`). Google's own codelab says the widget UI cannot be drawn with Flutter and must use SwiftUI or Jetpack Compose ([codelab](https://codelabs.developers.google.com/flutter-home-screen-widgets) [V/S]).
  - Expo: `expo-widgets` (stable in SDK 56 per Expo's June 2026 post) builds iOS widgets and Live Activities from Expo UI components with no SwiftUI. It is limited to those components. `@bacons/apple-targets` generates a real SwiftUI WidgetKit target and wires the App Group ([Expo docs](https://docs.expo.dev/versions/latest/sdk/widgets/), [guide](https://reactnativerelay.com/article/react-native-ios-widgets-expo-apple-targets-2026) [V/S]).
- **Android: Jetpack Glance** renders to RemoteViews. Stable is 1.1.1 (1.2 was at RC and 1.3 alpha as of mid-2026). Periodic updates are best done with WorkManager, and the platform update interval is commonly cited as 30 minutes minimum ([Android docs](https://developer.android.com/jetpack/androidx/releases/glance) [V]; [I] for the 30-minute floor). GRDB 7.10 targets Android/Linux/Windows, but Swift-on-Android is early.
- **Recommendation.**
  - Phase 1–2: **native Swift on iOS only**. The depth needed (App Intents, Controls, relevance, Liquid Glass modes) is WidgetKit-specific.
  - Phase 3: a **separate native Kotlin Android app** (Compose + Glance) that reuses the content pipeline: the same SQLite schema (read by Android's SQLite), the same JSON event formats and the same FSRS-6 algorithm (ts-fsrs, FSRS-Kotlin or `fsrs-rs`).
  - Choose Expo/React Native only if the team is already JS-based and accepts `expo-widgets`' component limits.
  - Subscriptions across platforms are the strongest argument for RevenueCat.

---

## 8. App Review risks

From the [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) (page last updated 2026-06-08) [A]:

- **4.3(b) Spam.** Don't submit apps "indistinguishable from what's already widely available." A vocabulary widget app is a saturated category, so differentiate meaningfully: a unique learning mode (widget flashcards with FSRS), curated decks and quality of content.
  - Name clash: "Widget Vocabulary: Learn Words" (Orbit Studios) already exists, and "Vocabulary – Learn words daily" (Monkey Taps, 220K ratings) is the category leader. Use an original name, icon and screenshots.
  - 4.3(a): do not publish multiple bundle IDs of the same app. Use in-app purchase variants.
- **4.2 Minimum functionality.** A widget-only experience with a thin app is at risk. The app must have real functionality (quizzes, library, search, stats).
- **3.1.2 Subscriptions** (c). Before asking users to subscribe, clearly say what they get for the price. Show price, period, renewal and cancellation terms, and link Terms and Privacy ([3.1.2(a)](https://developer.apple.com/app-store/review/guidelines/): at least 7-day period, value on all devices). Make trial terms visible and include a restore button. Don't let users inadvertently subscribe to multiple variants. Avoid fake urgency, which Guideline 5.6 treats as manipulative.
- **3.1.1.** All unlocks go through IAP. No external unlock mechanisms.
- **5.1.1 / 5.1.2 data.** A privacy policy in App Store Connect and in-app. Disclose analytics SDKs and any third-party AI data sharing (5.1.2(i) now names third-party AI explicitly). Provide account deletion if you create accounts (5.1.1(v)). Paid functionality must not depend on granting data access.
- **2.3 Accurate metadata.**
  - Screenshots show the real app and real widgets.
  - Name up to 30 characters, with no keyword stuffing or pricing.
  - Answer the age rating honestly.
  - No hidden or undocumented features, so document widgets, intents and the quiz in the review notes.
- **2.5.16.** Widgets, extensions and notifications must relate to the app's content and functionality.
- **2.5.18 and 4.4.** No ads and no in-app purchases in extensions and widgets.
- **Widget-specific gotchas.**
  - Empty or blank widget when gated or before first launch. Reviewers read it as a bug, so ship the seed data and a friendly state.
  - Widget gallery snapshot must be instant and meaningful.
  - Buttons are inactive on the Lock Screen when locked.
  - Test in release configuration (budgets are not enforced in Xcode debug).
  - Add a "Widget not updating?" help page, because this is the top review complaint in the category.
- **Trademarks.** IELTS, TOEFL, GRE, SAT, "Oxford 3000" and similar. Use "for exam preparation" language with a non-affiliation note, and don't use Oxford's name without a license.
- **Age rating.** Answer the new questionnaire in App Store Connect; the deadline passed on 2026-01-31 [A].

---

## 9. Recommended stack, structure, data model, roadmap

### 9.1 Stack

| Layer | Choice |
|---|---|
| Language/UI | Swift 6.x (Xcode 27 SDK; the iOS 26 SDK is the current minimum), SwiftUI, Observation |
| Widgets | WidgetKit with `AppIntentTimelineProvider`, App Intents (shared package), Controls |
| Content DB | SQLite (immutable, read-only) via GRDB 7.11.x, FTS5 |
| User store | SwiftData + CloudKit (private DB) or GRDB + CKSyncEngine |
| SRS | `swift-fsrs` (FSRS-6), pinned |
| Subscriptions | StoreKit 2; add RevenueCat when needed |
| Analytics / crashes | TelemetryDeck or PostHog; Crashlytics + MetricKit |
| Content pipeline | Python scripts + Claude API (Haiku 5.5 draft, Sonnet 5.5 judge, Batch API) + human review tool |
| Audio | Top-N bundled; the rest as Apple-hosted Background Assets or CDN; on-device TTS for sentences |
| CI | Xcode Cloud or fastlane; TestFlight (the only realistic place to test budgets) |
| Deployment target | iOS 17.0 (iOS 18 if you prefer simplicity) |

### 9.2 Module and folder structure

```
VocabWidget.xcworkspace
├─ App/                        (iOS app target)
│   ├─ Features/ Onboarding, Placement, Learn, Quiz, Library, Search, Stats, Settings, Paywall
│   └─ AppEntry.swift          (ingests widget events, writes EntitlementSnapshot, reloads timelines)
├─ WidgetExtension/            (WidgetKit target; WidgetBundle)
│   ├─ WordWidget.swift        (home + Lock Screen families, AppIntentTimelineProvider)
│   ├─ Controls/               (ControlWidgets)
│   ├─ Resources/seed_words.json  (300–500 words, works before first app launch)
│   └─ PrivacyInfo.xcprivacy
├─ WatchApp/ (+ WatchWidgets)  (v3)
├─ Packages/
│   ├─ CoreModels/             (pure Swift: Word, Sense, Rating, CEFR)
│   ├─ ContentStore/           (GRDB read-only; queries; FTS; used by app + widget)
│   ├─ SharedState/            (App Group mailbox: WidgetPlan JSON, EventLog, cursor, EntitlementSnapshot)
│   ├─ Scheduler/              (widget queue selection; FSRS wrapper)
│   ├─ AppIntentsKit/          (AppIntent, AppEntity, queries, AppShortcuts; AppIntentsPackage)
│   ├─ UserStore/              (SwiftData or GRDB+CKSyncEngine; app only)
│   ├─ Entitlements/           (StoreKit 2 wrapper; app only)
│   ├─ Audio/                  (TTS + asset packs)
│   ├─ Design/                 (typography, glass-safe components, rendering-mode helpers)
│   └─ Analytics/              (protocol + TelemetryDeck/PostHog adapter)
├─ Tools/ContentPipeline/      (not shipped: seed builders, Claude prompts, validators, QA UI, DB packer)
└─ Docs/ licenses & attributions (generated "Acknowledgements" screen)
```

### 9.3 Data model

**Content DB (read-only, shipped):**

- `word`: id (stable int), lang, headword, headword_norm, pos_primary, ipa_us, ipa_uk, cefr, cefr_source, freq_band, tags, is_multiword, family_id, content_version.
- `sense`: id, word_id, pos, rank, definition_simple, definition_full, domain, register, cefr, source, review_state, model, prompt_version.
- `example`: id, sense_id, text, cloze_start, cloze_len, source (llm / tatoeba), attribution, audio_id, quality_score.
- `translation`: id, entity_type (word / sense / example), entity_id, lang, text, source, review_state.
- `relation`: word_id, type (synonym / antonym / collocation / family), related_word_id or text.
- `category`: id, slug, parent_id, title_key. `deck`: id, slug, kind (level / topic / exam / custom), cefr_min, cefr_max, is_premium, source_license. `deck_word`: deck_id, word_id, rank.
- `audio_asset`: id, kind (word / example), locale, voice, hash, path or pack_id, duration, license.
- `quiz_distractor`: word_id, distractor_word_ids (precomputed).
- FTS5 virtual table over headword and translations.
- `content_meta`: content_version, build date, attribution blob.

**User store (app-private, synced):**

- `Settings`: native_lang, target_lang, level, daily_goal, widget_interval, theme, tts_voice, notification_times, placement_result, schema_version.
- `UserWordProgress`: word_id (PK), state (new / learning / review / relearning / known / ignored), FSRS fields (due, stability, difficulty, last_review, reps, lapses), exposure_count, first_seen_at, last_exposed_at, known_override, favorite, note.
- `ReviewLog`: id (UUID), word_id, ts, source (app_quiz / widget_reveal / widget_known / notification / placement), quiz_type, rating (1–4), response_ms, correct, device_id.
- `ExposureDaily`: word_id, day, count, surface (widget family / lock screen / notification).
- `UserDeck`: id, title, word_ids (custom decks). `DailyStat`: date, reviews, new_learned, minutes, streak.
- `EntitlementCache`: is_premium, expires_at, ownership, last_verified.

**App Group (non-DB, atomic files):** `widget_plan.json` (per-deck cursor, seed, known set, settings, entitlement), `events/` (append-only event files), `content.sqlite` (immutable copy).

### 9.4 Roadmap (solo developer; person-weeks are rough)

| Phase | Scope | Effort |
|---|---|---|
| **MVP** (about 3 months) | English-only. Content pipeline v1 (5–10k words, NGSL/NAWL/CEFR-J seeds plus LLM enrichment, QA): 3 pw. App shell (onboarding, level pick, list/detail, search, favorites): 2 pw. Widgets (small/medium/large and Lock Screen, config intent, timeline engine, tinted/clear rendering): 3 pw. Interactive Next/Known: 0.5 pw. Basic quiz (multiple choice) plus Leitner: 1.5 pw. Paywall and gating with StoreKit 2: 1 pw. Analytics, privacy manifest, notifications, App Store assets, QA: 1.5–2 pw | **10–14 pw** |
| **v2** | FSRS-6; quiz types (typing, listening, cloze); placement test; streaks; widget flashcard (reveal + rating); iCloud sync; Controls; StandBy, iPad and Mac polish; App Intents, Shortcuts, Siri, Spotlight; 3–5 translation languages with native review; audio packs; win-back and offer merchandising; paywall experiments; content update channel | **8–12 pw** |
| **v3** | Apple Watch app and complications (Smart Stack relevance); more learning languages; exam packs (IELTS/TOEFL/SAT/GRE; check trademarks and licensing); optional Foundation Models features; Android (native Kotlin + Glance, sharing the pipeline); WidgetKit push if you add server-driven editorial content; optional study-session Live Activity | **10–16 pw** |

---

## 10. Uncertainty register (verify before committing)

1. **Entry-count ceiling** (about 200 to 400 entries) is forum anecdote. Apple publishes none ([forum 653265](https://developer.apple.com/forums/thread/653265), search result [S]). The **30 MB** memory limit comes from crash logs and forums, not an official doc.
2. **Widget budget** (40–70 per day) is Apple's "typical", with a few days of learning. The budget is dynamic. Reports of stuck widgets exist ([forum 655969](https://developer.apple.com/forums/thread/655969) [S]).
3. **`AudioPlaybackIntent`** latency and audio-session behavior is forum-reported (iOS 18 era). Re-test on iOS 26/27.
4. **Licenses.**
   - NGSL's share-alike scope for an embedded tag.
   - AWL's license (unclear).
   - EVP and Oxford: no public terms. COCA's restrictions on derived frequency data.
   - The SUBTLEX permission is an email-based grant described secondhand.
   - Wiktionary data: BY-SA 4.0 and GFDL versions. kaikki.org's own license text was not found on its pages.
   - Forvo's current license.
5. **FSRS-7** exists in `fsrs-rs`, with unconfirmed official adoption. `swift-fsrs` release and maintenance status is unclear (Releases empty).
6. **Vendor pricing.**
   - RevenueCat's 1% basis (whole vs excess) is not stated on the pricing page.
   - Qonversion's possible $7k free tier. Superwall's MAR percentage.
   - Azure and ElevenLabs prices are third-party figures. Oxford API's enterprise "£5,000 per language" is undated.
   - Amplitude's July 2026 plan changes. TelemetryDeck prices.
7. **StoreKit 12-month commitment**: Apple's session cites iOS 26.4 and 26.5, so confirm the exact version and SDK needed. Bundles/Suites and offer-code redemption APIs are Xcode 27-testable.
8. **watchOS `RelevanceConfiguration` availability**: the WWDC25 session says watchOS 26, but one Apple doc snippet says `@available(watchOS 12, *)`.
9. **iOS 27 widget claims** beyond `systemExtraLargePortrait` come from press and third-party blogs.
10. **AdAttributionKit vs SKAN deprecation** claims (late 2026) are unverified.
11. **Apple-hosted Background Assets** limits (200 GB and 100 packs; per app or per team) are forum-reported.
12. **Privacy manifest reason codes** other than 1C8F.1 were not verified against Apple's per-key doc.
13. **Apple's upcoming-requirements page** mentions an iOS minimum-version item dated Sep 9, 2026 ("iOS 13 or later"), which looks odd. Check the original before relying on it.
14. **iOS adoption** figures are Apple's June 2026 numbers via a secondary report. A newer September iOS 27 figure was not found.
15. **Foundation Models** language and device availability for Turkish is unverified.
16. **Data-protection and locked-device behavior** (section 1.7), **Low Power Mode** effects and the **64 pending local notification** limit are from experience or secondary reports, not fetched Apple docs.

---

### Key sources (Apple)

- [Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date.md)
- [Adding interactivity to widgets and Live Activities](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities.md)
- [Making a configurable widget](https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget.md)
- [Preparing widgets for additional contexts](https://developer.apple.com/documentation/widgetkit/preparing-widgets-for-additional-contexts-and-appearances.md)
- [Optimizing for accented rendering and Liquid Glass](https://developer.apple.com/documentation/widgetkit/optimizing-your-widget-for-accented-rendering-mode-and-liquid-glass.md)
- [Displaying the right widget background](https://developer.apple.com/documentation/widgetkit/displaying-the-right-widget-background.md)
- [Widget suggestions in Smart Stacks](https://developer.apple.com/documentation/widgetkit/widget-suggestions-in-smart-stacks.md)
- [Updating widgets with WidgetKit push notifications](https://developer.apple.com/tutorials/data/documentation/widgetkit/updating-widgets-with-widgetkit-push-notifications.md)
- [Creating controls](https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system.md)
- [Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities.md)
- [SwiftData sync](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices.md)
- [Required-reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api.md)
- [Win-back offers](https://developer.apple.com/documentation/storekit/merchandising-win-back-offers-in-your-app.md)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/)
- WWDC sessions: [WWDC23 10028 Bring widgets to life](https://developer.apple.com/videos/play/wwdc2023/10028/), [WWDC24 10157 Controls](https://developer.apple.com/videos/play/wwdc2024/10157/), [WWDC24 10110 App Store Offers](https://developer.apple.com/videos/play/wwdc2024/10110/), [WWDC25 278 What's new in widgets](https://developer.apple.com/videos/play/wwdc2025/278/), [WWDC25 244 App Intents](https://developer.apple.com/videos/play/wwdc2025/244/), [WWDC25 221 AdAttributionKit](https://developer.apple.com/videos/play/wwdc2025/221/), [WWDC25 325 Background Assets](https://developer.apple.com/videos/play/wwdc2025/325), [WWDC26 277 WidgetKit foundations](https://developer.apple.com/videos/play/wwdc2026/277/), [WWDC26 274 SwiftData](https://developer.apple.com/videos/play/wwdc2026/274), [WWDC26 210 In-App Purchase](https://developer.apple.com/videos/play/wwdc2026/210), [WWDC26 iOS guide](https://developer.apple.com/wwdc26/guides/ios/)
- Claude pricing: [platform.claude.com pricing](https://platform.claude.com/docs/en/about-claude/pricing)
