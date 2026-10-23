import XCTest
import CoreModels

final class SpeechSettingsTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "SpeechSettingsTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    // MARK: Stored settings

    func testNothingStoredReadsAsTheDefaults() {
        let settings = SpeechSettings(defaults: defaults)
        XCTAssertEqual(settings, SpeechSettings.standard)
        XCTAssertEqual(settings.accent, .american)
        XCTAssertEqual(settings.rate, .normal)
        XCTAssertTrue(settings.slowRepeat)
        XCTAssertNil(settings.voiceIdentifier)
    }

    func testSettingsRoundTrip() {
        let saved = SpeechSettings(
            accent: .british,
            rate: .slow,
            slowRepeat: false,
            voiceIdentifiers: [.british: "com.apple.voice.premium.en-GB.Serena", .american: "com.apple.voice.enhanced.en-US.Evan"]
        )
        saved.save(to: defaults)
        let read = SpeechSettings(defaults: defaults)
        XCTAssertEqual(read, saved)
        XCTAssertEqual(read.voiceIdentifier, "com.apple.voice.premium.en-GB.Serena")
    }

    func testClearingAVoiceRemovesItsKey() {
        var settings = SpeechSettings.standard
        settings.voiceIdentifiers[.american] = "voice.a"
        settings.save(to: defaults)
        settings.voiceIdentifiers[.american] = nil
        settings.save(to: defaults)
        XCTAssertNil(defaults.object(forKey: SpeechSettings.Key.voice(.american)))
        XCTAssertNil(SpeechSettings(defaults: defaults).voiceIdentifier)
    }

    /// `@AppStorage` stores the enums' raw values and a Bool under the same keys.
    func testReadsWhatAppStorageWrites() {
        defaults.set("uk", forKey: SpeechSettings.Key.accent)
        defaults.set("fast", forKey: SpeechSettings.Key.rate)
        defaults.set(false, forKey: SpeechSettings.Key.slowRepeat)
        let settings = SpeechSettings(defaults: defaults)
        XCTAssertEqual(settings.accent, .british)
        XCTAssertEqual(settings.rate, .fast)
        XCTAssertFalse(settings.slowRepeat)
    }

    func testUnknownStoredValuesReadAsTheDefaults() {
        defaults.set("au", forKey: SpeechSettings.Key.accent)
        defaults.set("turbo", forKey: SpeechSettings.Key.rate)
        defaults.set("", forKey: SpeechSettings.Key.voice(.american))
        let settings = SpeechSettings(defaults: defaults)
        XCTAssertEqual(settings.accent, .american)
        XCTAssertEqual(settings.rate, .normal)
        XCTAssertNil(settings.voiceIdentifier)
    }

    func testAccentLanguageCodes() {
        XCTAssertEqual(SpeechAccent.american.languageCode, "en-US")
        XCTAssertEqual(SpeechAccent.british.languageCode, "en-GB")
        XCTAssertEqual(SpeechAccent(rawValue: "us"), .american)
        XCTAssertEqual(SpeechAccent(rawValue: "uk"), .british)
    }

    // MARK: Speed

    func testNormalKeepsTheEarlierRate() {
        XCTAssertEqual(SpeechRate.normal.defaultRateMultiplier, 0.9, accuracy: 0.0001)
        XCTAssertLessThan(SpeechRate.slow.defaultRateMultiplier, SpeechRate.normal.defaultRateMultiplier)
        XCTAssertLessThan(SpeechRate.normal.defaultRateMultiplier, SpeechRate.fast.defaultRateMultiplier)
        XCTAssertLessThanOrEqual(SpeechRate.fast.defaultRateMultiplier, 1.0)
    }

    func testARepeatIsSlowerOnlyWithSlowRepeat() {
        let first = SpeechRules.rateMultiplier(.normal, isRepeat: false, slowRepeat: true)
        let again = SpeechRules.rateMultiplier(.normal, isRepeat: true, slowRepeat: true)
        let againOff = SpeechRules.rateMultiplier(.normal, isRepeat: true, slowRepeat: false)
        XCTAssertEqual(first, 0.9, accuracy: 0.0001)
        XCTAssertEqual(again, 0.72, accuracy: 0.0001)
        XCTAssertEqual(againOff, first, accuracy: 0.0001)
    }

    func testARepeatIsNeverSlowerThanTheFloor() {
        for rate in SpeechRate.allCases {
            let again = SpeechRules.rateMultiplier(rate, isRepeat: true, slowRepeat: true)
            XCTAssertGreaterThanOrEqual(again, SpeechRules.slowestMultiplier)
            XCTAssertLessThan(again, rate.defaultRateMultiplier)
        }
    }

    // MARK: Repeats

    func testTheSameTextAgainSoonIsARepeat() {
        var tracker = SpeechRepeatTracker()
        let key = SpeechRepeatTracker.key(text: "breakfast", voiceIdentifier: "v", rate: .normal)
        let start = Date(timeIntervalSince1970: 1_000)
        XCTAssertFalse(tracker.register(key, at: start))
        XCTAssertTrue(tracker.register(key, at: start.addingTimeInterval(3)))
        // A third tap is slow too: every start renews the window.
        XCTAssertTrue(tracker.register(key, at: start.addingTimeInterval(3 + SpeechRules.repeatWindow - 1)))
    }

    func testLaterOrOtherTextIsAFirstHearing() {
        var tracker = SpeechRepeatTracker()
        let word = SpeechRepeatTracker.key(text: "breakfast", voiceIdentifier: "v", rate: .normal)
        let other = SpeechRepeatTracker.key(text: "lunch", voiceIdentifier: "v", rate: .normal)
        let start = Date(timeIntervalSince1970: 1_000)
        XCTAssertFalse(tracker.register(word, at: start))
        XCTAssertFalse(tracker.register(word, at: start.addingTimeInterval(SpeechRules.repeatWindow + 1)))
        XCTAssertFalse(tracker.register(other, at: start.addingTimeInterval(SpeechRules.repeatWindow + 2)))
        // Back to the first word right after another one: not a repeat either.
        XCTAssertFalse(tracker.register(word, at: start.addingTimeInterval(SpeechRules.repeatWindow + 3)))
    }

    /// Picking another voice or speed and hearing the same sample is not a repeat.
    func testAnotherVoiceOrSpeedIsNotARepeat() {
        var tracker = SpeechRepeatTracker()
        let start = Date(timeIntervalSince1970: 1_000)
        XCTAssertFalse(tracker.register(SpeechRepeatTracker.key(text: "hi", voiceIdentifier: "a", rate: .normal), at: start))
        XCTAssertFalse(tracker.register(SpeechRepeatTracker.key(text: "hi", voiceIdentifier: "b", rate: .normal), at: start.addingTimeInterval(1)))
        XCTAssertFalse(tracker.register(SpeechRepeatTracker.key(text: "hi", voiceIdentifier: "b", rate: .slow), at: start.addingTimeInterval(2)))
        XCTAssertTrue(tracker.register(SpeechRepeatTracker.key(text: "hi", voiceIdentifier: "b", rate: .slow), at: start.addingTimeInterval(3)))
    }

    func testAClockGoingBackIsNotARepeat() {
        var tracker = SpeechRepeatTracker()
        let start = Date(timeIntervalSince1970: 1_000)
        XCTAssertFalse(tracker.register("k", at: start))
        XCTAssertFalse(tracker.register("k", at: start.addingTimeInterval(-5)))
    }

    // MARK: IPA

    func testIPAFollowsTheAccent() {
        let word = WidgetWord(id: 1, lemma: "corner", pos: "n", level: "A1", ipaUS: "/ˈkɔːrnər/", ipaUK: "/ˈkɔːnə/", defMicro: "", defShort: "", exampleEN: "")
        XCTAssertEqual(word.ipa(for: .american), "/ˈkɔːrnər/")
        XCTAssertEqual(word.ipa(for: .british), "/ˈkɔːnə/")
    }

    func testIPAFallsBackToTheOtherAccent() {
        let seed = WidgetWord(id: 1, lemma: "corner", pos: "n", level: "A1", ipaUS: "/ˈkɔːrnər/", defMicro: "", defShort: "", exampleEN: "")
        XCTAssertEqual(seed.ipa(for: .british), "/ˈkɔːrnər/")
        let britishOnly = WidgetWord(id: 2, lemma: "x", pos: "n", level: "A1", ipaUK: "/x/", defMicro: "", defShort: "", exampleEN: "")
        XCTAssertEqual(britishOnly.ipa(for: .american), "/x/")
        let custom = WidgetWord(id: 3, lemma: "awkward", pos: "", level: "", defMicro: "", defShort: "", exampleEN: "")
        XCTAssertNil(custom.ipa(for: .american))
        XCTAssertNil(custom.ipa(for: .british))
    }

    func testWidgetWordCarriesTheBritishIPA() throws {
        let json = """
        {"id":12,"lemma":"corner","pos":"n","level":"A1","ipa_us":"/ˈkɔːrnər/","ipa_uk":"/ˈkɔːnə/",
         "def_micro":"m","def_short":"s","example_en":"e"}
        """
        let word = try JSONDecoder().decode(WidgetWord.self, from: Data(json.utf8))
        XCTAssertEqual(word.ipaUK, "/ˈkɔːnə/")
        let encoded = try JSONEncoder().encode(word)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        XCTAssertEqual(object["ipa_uk"] as? String, "/ˈkɔːnə/")
        // Older plans and the seed have no "ipa_uk".
        let old = """
        {"id":12,"lemma":"corner","pos":"n","level":"A1","ipa_us":"/ˈkɔːrnər/","def_micro":"m","def_short":"s","example_en":"e"}
        """
        XCTAssertNil(try JSONDecoder().decode(WidgetWord.self, from: Data(old.utf8)).ipaUK)
    }
}

final class SpeechVoiceChoiceTests: XCTestCase {
    private func voice(_ id: String, _ name: String, _ language: String = "en-US", _ quality: SpeechVoiceInfo.Quality = .standard, novelty: Bool = false, personal: Bool = false) -> SpeechVoiceInfo {
        return SpeechVoiceInfo(identifier: id, name: name, language: language, quality: quality, isNovelty: novelty, isPersonal: personal)
    }

    private var installed: [SpeechVoiceInfo] {
        return [
            voice("com.apple.voice.compact.en-US.Samantha", "Samantha"),
            voice("com.apple.voice.compact.en-US.Aaron", "Aaron"),
            voice("com.apple.voice.enhanced.en-US.Evan", "Evan (Enhanced)", "en-US", .enhanced),
            voice("com.apple.voice.premium.en-US.Ava", "Ava (Premium)", "en-US", .premium),
            voice("com.apple.voice.compact.en-GB.Daniel", "Daniel", "en-GB"),
            voice("com.apple.voice.compact.en-AU.Karen", "Karen", "en-AU"),
            voice("com.apple.speech.synthesis.voice.Bells", "Bells", "en-US", novelty: true),
            voice("com.apple.speech.synthesis.voice.Fred", "Fred"),
            voice("com.apple.eloquence.en-US.Reed", "Reed"),
            voice("personal.1", "My Voice", "en-US", .premium, personal: true),
        ]
    }

    func testOfferedVoicesAreTheAccentsBestFirst() {
        let offered = SpeechVoiceChoice.offered(installed, accent: .american, systemDefault: "com.apple.voice.compact.en-US.Samantha")
        XCTAssertEqual(offered.map(\.identifier), [
            "com.apple.voice.premium.en-US.Ava",
            "com.apple.voice.enhanced.en-US.Evan",
            // Same quality: the system's own voice first, then by name.
            "com.apple.voice.compact.en-US.Samantha",
            "com.apple.voice.compact.en-US.Aaron",
        ])
    }

    func testBritishOffersOnlyBritishVoices() {
        let offered = SpeechVoiceChoice.offered(installed, accent: .british)
        XCTAssertEqual(offered.map(\.identifier), ["com.apple.voice.compact.en-GB.Daniel"])
    }

    func testTheBestVoiceReadsUnlessOneWasChosen() {
        XCTAssertEqual(SpeechVoiceChoice.voice(chosen: nil, among: installed, accent: .american)?.identifier, "com.apple.voice.premium.en-US.Ava")
        XCTAssertEqual(
            SpeechVoiceChoice.voice(chosen: "com.apple.voice.compact.en-US.Aaron", among: installed, accent: .american)?.identifier,
            "com.apple.voice.compact.en-US.Aaron"
        )
    }

    func testADeletedOrForeignChoiceFallsBackToTheBest() {
        // Deleted in iPhone Settings.
        XCTAssertEqual(SpeechVoiceChoice.voice(chosen: "gone", among: installed, accent: .american)?.identifier, "com.apple.voice.premium.en-US.Ava")
        // A British voice saved for the American accent, and voices we never offer.
        XCTAssertEqual(
            SpeechVoiceChoice.voice(chosen: "com.apple.voice.compact.en-GB.Daniel", among: installed, accent: .american)?.identifier,
            "com.apple.voice.premium.en-US.Ava"
        )
        XCTAssertEqual(SpeechVoiceChoice.voice(chosen: "personal.1", among: installed, accent: .american)?.identifier, "com.apple.voice.premium.en-US.Ava")
        XCTAssertNil(SpeechVoiceChoice.voice(chosen: nil, among: [], accent: .british))
    }

    func testNeedsBetterVoiceWithOnlyStandardVoices() {
        XCTAssertFalse(SpeechVoiceChoice.needsBetterVoice(installed, accent: .american))
        XCTAssertTrue(SpeechVoiceChoice.needsBetterVoice(installed, accent: .british))
        XCTAssertTrue(SpeechVoiceChoice.needsBetterVoice([], accent: .american))
        // A personal premium voice does not count.
        let onlyPersonal = [voice("p", "Me", "en-GB", .premium, personal: true), voice("d", "Daniel", "en-GB")]
        XCTAssertTrue(SpeechVoiceChoice.needsBetterVoice(onlyPersonal, accent: .british))
    }

    func testDisplayNameDropsTheQualityInBrackets() {
        XCTAssertEqual(voice("a", "Ava (Premium)").displayName, "Ava")
        XCTAssertEqual(voice("e", "Evan (Enhanced)").displayName, "Evan")
        XCTAssertEqual(voice("s", "Samantha").displayName, "Samantha")
        XCTAssertEqual(voice("x", "(Premium)").displayName, "(Premium)")
    }

    func testUnknownQualityCountsAsStandard() {
        XCTAssertEqual(SpeechVoiceInfo.Quality(rawQuality: 3), .premium)
        XCTAssertEqual(SpeechVoiceInfo.Quality(rawQuality: 2), .enhanced)
        XCTAssertEqual(SpeechVoiceInfo.Quality(rawQuality: 1), .standard)
        XCTAssertEqual(SpeechVoiceInfo.Quality(rawQuality: 9), .standard)
    }
}
