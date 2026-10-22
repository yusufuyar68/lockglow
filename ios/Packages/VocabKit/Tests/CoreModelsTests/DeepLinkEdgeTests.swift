import XCTest
import CoreModels

/// `vocabwidget://word/<id>` (widget tap) edge cases, and damaged `seed_words.json` files.
final class DeepLinkEdgeTests: XCTestCase {
    func testRoundTripForSmallAndLargeIDs() throws {
        for id in [0, 1, 7, 12_345, Int.max] {
            let url = try XCTUnwrap(DeepLink.wordURL(id: id))
            XCTAssertEqual(url.absoluteString, "vocabwidget://word/\(id)")
            XCTAssertEqual(DeepLink.wordID(from: url), id)
        }
    }

    func testSchemeCaseQueryFragmentAndTrailingSlashAreIgnored() throws {
        let accepted = [
            "VOCABWIDGET://word/5",       // URL schemes are case-insensitive
            "VocabWidget://word/5",
            "vocabwidget://word/5?source=lock",
            "vocabwidget://word/5#top",
            "vocabwidget://word/5/",      // lastPathComponent ignores a trailing slash
        ]
        for string in accepted {
            let url = try XCTUnwrap(URL(string: string), string)
            XCTAssertEqual(DeepLink.wordID(from: url), 5, string)
        }
    }

    func testMalformedLinksAreRejected() throws {
        let rejected = [
            "vocabwidget://word",                         // no id
            "vocabwidget://words/5",                      // other host
            "vocabwidgets://word/5",                      // other scheme
            "vocabwidget:word/5",                         // no "//": no host at all
            "vocabwidget:///word/5",                      // empty host, "word" is in the path
            "vocabwidget://word/5abc",                    // not a number
            "vocabwidget://word/1.5",
            "vocabwidget://word/99999999999999999999",    // beyond Int.max (9223372036854775807)
            "file:///word/5",
        ]
        for string in rejected {
            let url = try XCTUnwrap(URL(string: string), string)
            XCTAssertNil(DeepLink.wordID(from: url), string)
        }
    }

    // MARK: seed_words.json

    func testDamagedSeedFilesThrow() {
        let valid = """
            {"schema_version":1,"content_version":"v","words":[{"id":1,"lemma":"a","pos":"n","level":"A1",\
            "def_micro":"m","def_short":"s","example_en":"e"}]}
            """
        XCTAssertNoThrow(try SeedWords.decode(Data(valid.utf8)))
        let damaged: [(name: String, json: String)] = [
            ("empty", ""),
            ("truncated", String(valid.prefix(40))),
            ("words missing", valid.replacingOccurrences(of: "\"words\"", with: "\"items\"")),
            ("schema version as a string", valid.replacingOccurrences(of: "\"schema_version\":1", with: "\"schema_version\":\"1\"")),
            ("word without def_micro", valid.replacingOccurrences(of: "\"def_micro\":\"m\",", with: "")),
        ]
        for item in damaged {
            XCTAssertNotEqual(item.json, valid, "the replacement did not apply: \(item.name)")
            XCTAssertThrowsError(try SeedWords.decode(Data(item.json.utf8)), item.name)
        }
    }

    func testMissingSeedFileLoadsAsEmpty() {
        // The test bundle has no seed_words.json: callers get [] and must handle it.
        XCTAssertEqual(SeedWords.load(bundle: Bundle(for: DeepLinkEdgeTests.self)), [])
    }
}
