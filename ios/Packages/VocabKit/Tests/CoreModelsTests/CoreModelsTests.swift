import XCTest
import CoreModels

final class CoreModelsTests: XCTestCase {
    func testLevelRanksMatchTheContract() {
        XCTAssertEqual(Level.a1.rank, 1)
        XCTAssertEqual(Level.c2.rank, 6)
        XCTAssertEqual(Level.s.rank, 7)
        XCTAssertEqual(Level.allCases.map { $0.rank }, [1, 2, 3, 4, 5, 6, 7])
    }

    func testLevelInitFromRankAndRawValue() {
        XCTAssertEqual(Level(rank: 3), .b1)
        XCTAssertNil(Level(rank: 0))
        XCTAssertNil(Level(rank: 8))
        XCTAssertEqual(Level(rawValue: "C1"), .c1)
        XCTAssertNil(Level(rawValue: "c1"))
    }

    /// Level marks have four dots: B2 fills them all, a harder level never more.
    func testLevelDotsGoUpToB2() {
        XCTAssertEqual(Level.dotCount, 4)
        XCTAssertEqual([Level.a1, .a2, .b1, .b2].map { $0.dots }, [1, 2, 3, 4])
        XCTAssertEqual([Level.c1, .c2, .s].map { $0.dots }, [4, 4, 4])
        XCTAssertNotEqual(Level.b1.dots, Level.b2.dots)
    }

    func testDeepLinkRoundTrip() throws {
        let url = try XCTUnwrap(DeepLink.wordURL(id: 42))
        XCTAssertEqual(url.absoluteString, "vocabwidget://word/42")
        XCTAssertEqual(DeepLink.wordID(from: url), 42)
    }

    func testDeepLinkRejectsOtherURLs() throws {
        let urls = ["https://word/42", "vocabwidget://card/42", "vocabwidget://word/", "vocabwidget://word/abc"]
        for string in urls {
            let url = try XCTUnwrap(URL(string: string))
            XCTAssertNil(DeepLink.wordID(from: url), string)
        }
    }

    func testLevelOrdering() {
        XCTAssertTrue(Level.a2 < Level.b1)
        XCTAssertTrue(Level.c2 < Level.s)
        XCTAssertEqual(Level.allCases.sorted(), Level.allCases)
    }

    func testWidgetWordUsesSnakeCaseKeys() throws {
        let json = """
        {"id":101,"lemma":"resilient","pos":"adj","level":"C1","ipa_us":"/rɪˈzɪliənt/",
         "def_micro":"quick to recover","def_short":"able to recover quickly",
         "example_en":"Children are resilient.","gloss_tr":"dirençli"}
        """
        let word = try JSONDecoder().decode(WidgetWord.self, from: Data(json.utf8))
        XCTAssertEqual(word.id, 101)
        XCTAssertEqual(word.ipaUS, "/rɪˈzɪliənt/")
        XCTAssertEqual(word.defMicro, "quick to recover")
        XCTAssertEqual(word.glossTR, "dirençli")
        XCTAssertEqual(word.levelValue, .c1)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let encoded = try encoder.encode(word)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        for key in ["id", "lemma", "pos", "level", "ipa_us", "def_micro", "def_short", "example_en", "gloss_tr"] {
            XCTAssertNotNil(object[key], "missing key \(key)")
        }
    }

    func testOptionalFieldsMayBeMissingOrNull() throws {
        let json = """
        {"id":7,"lemma":"look up to","pos":"phv","level":"B2","ipa_us":null,
         "def_micro":"admire","def_short":"to admire someone","example_en":"I look up to her."}
        """
        let word = try JSONDecoder().decode(WidgetWord.self, from: Data(json.utf8))
        XCTAssertNil(word.ipaUS)
        XCTAssertNil(word.glossTR)
    }

    func testSeedFileFromTheContractDecodes() throws {
        let json = """
        {
          "schema_version": 1,
          "content_version": "2026.10.11-1",
          "words": [
            {
              "id": 101,
              "lemma": "resilient",
              "pos": "adj",
              "level": "C1",
              "ipa_us": "/rɪˈzɪliənt/",
              "def_micro": "quick to recover",
              "def_short": "able to recover quickly after something difficult",
              "example_en": "Children are often more resilient than adults.",
              "gloss_tr": "dirençli, çabuk toparlanan"
            }
          ]
        }
        """
        let file = try SeedWords.decode(Data(json.utf8))
        XCTAssertEqual(file.schemaVersion, 1)
        XCTAssertEqual(file.contentVersion, "2026.10.11-1")
        XCTAssertEqual(file.words.count, 1)
        XCTAssertEqual(file.words[0].lemma, "resilient")
    }

    func testEventEnumsUseContractRawValues() {
        XCTAssertEqual(WidgetEventType.next.rawValue, "next")
        XCTAssertEqual(WidgetEventType.known.rawValue, "known")
        XCTAssertEqual(WidgetEventType.unknown.rawValue, "unknown")
        XCTAssertEqual(WidgetEventType.reveal.rawValue, "reveal")
        XCTAssertEqual(WidgetEventSource.systemSmall.rawValue, "system_small")
        XCTAssertEqual(WidgetEventSource.systemMedium.rawValue, "system_medium")
        XCTAssertEqual(WidgetEventSource.accessoryRectangular.rawValue, "accessory_rectangular")
        XCTAssertEqual(WidgetEventSource.accessoryInline.rawValue, "accessory_inline")
    }
}
