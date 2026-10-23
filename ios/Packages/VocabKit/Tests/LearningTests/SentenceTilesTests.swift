import XCTest
import Learning

final class SentenceTilesTests: XCTestCase {
    private func texts(_ sentence: String) -> [String]? {
        return SentenceTiles(sentence)?.tiles.map(\.text)
    }

    // MARK: Splitting

    func testPunctuationAroundWordsIsNoTileAndTheFinalMarkStandsApart() throws {
        let tiles = try XCTUnwrap(SentenceTiles("Can I have a spoon, please?"))
        XCTAssertEqual(tiles.tiles.map(\.text), ["Can", "I", "have", "a", "spoon", "please"])
        XCTAssertEqual(tiles.tiles.map(\.id), [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(tiles.ending, "?")
        XCTAssertEqual(tiles.sentence, "Can I have a spoon, please?")
    }

    func testPunctuationInsideAWordStays() {
        XCTAssertEqual(
            texts("I don't know the well-known café at 6:30."),
            ["I", "don't", "know", "the", "well-known", "café", "at", "6:30"]
        )
        XCTAssertEqual(texts("The tickets cost 2,000 lira!"), ["The", "tickets", "cost", "2,000", "lira"])
        XCTAssertEqual(SentenceTiles("The tickets cost 2,000 lira!")?.ending, "!")
    }

    /// "parents'" keeps its apostrophe; "Dr." and "a.m." keep their dot and do not end the sentence.
    func testPossessivesAndAbbreviationsKeepTheirMarks() throws {
        let tiles = try XCTUnwrap(SentenceTiles("Dr. Kaya visits my parents' house at 8 a.m."))
        XCTAssertEqual(tiles.tiles.map(\.text), ["Dr.", "Kaya", "visits", "my", "parents'", "house", "at", "8", "a.m."])
        XCTAssertEqual(tiles.ending, "")
        XCTAssertEqual(texts("We met Mr. Chen at the station."), ["We", "met", "Mr.", "Chen", "at", "the", "station"])
    }

    /// Names keep their capital: "Ayşe" must not become "ayşe".
    func testCapitalsStayAsWritten() {
        XCTAssertEqual(texts("Ayşe likes İstanbul in May."), ["Ayşe", "likes", "İstanbul", "in", "May"])
    }

    func testPunctuationAloneHasNoTile() throws {
        let dash = try XCTUnwrap(SentenceTiles("I was tired — very tired."))
        XCTAssertEqual(dash.tiles.map(\.text), ["I", "was", "tired", "very", "tired"])
        XCTAssertEqual(dash.ending, ".")
        XCTAssertEqual(SentenceTiles("I don't know what to say …")?.ending, "…")
        XCTAssertEqual(SentenceTiles("Wait for me...")?.ending, "...")
        XCTAssertEqual(SentenceTiles("Is it ready?!")?.ending, "?!")
    }

    /// Only sentences with one right order: no second sentence, no quotes or brackets, no ";" or ":".
    func testSentencesWithMoreThanOneOrderAreNotUsed() {
        XCTAssertNil(SentenceTiles("The bus is full. We have to wait."))
        XCTAssertNil(SentenceTiles("Look outside! It's pouring with rain."))
        XCTAssertNil(SentenceTiles("I like tea . What about you?"))
        XCTAssertNil(SentenceTiles("She said “hello” to everyone."))
        XCTAssertNil(SentenceTiles("He said \"thanks\" and left."))
        XCTAssertNil(SentenceTiles("In Turkish we say 'merhaba' to everyone."))
        XCTAssertNil(SentenceTiles("I like tea (with milk) a lot."))
        XCTAssertNil(SentenceTiles("I was tired; I went to bed."))
        XCTAssertNil(SentenceTiles("Remember this: practice every day."))
    }

    func testTileCountLimits() {
        XCTAssertEqual(SentenceTiles("Thanks a lot.")?.tiles.count, 3, "three tiles is the least")
        XCTAssertNil(SentenceTiles("Hello there."))
        let ten = "one two three four five six seven eight nine ten."
        XCTAssertEqual(SentenceTiles(ten)?.tiles.count, 10)
        XCTAssertNil(SentenceTiles("one two three four five six seven eight nine ten eleven."))
        XCTAssertNotNil(SentenceTiles("Hello there.", minTiles: 2))
        XCTAssertNil(SentenceTiles("I like tea.", maxTiles: 2))
        XCTAssertNil(SentenceTiles(""))
    }

    /// Every order of one repeated word would be right: nothing to put in order.
    func testOneRepeatedWordIsNotUsed() {
        XCTAssertNil(SentenceTiles("Very very very!"))
        XCTAssertNil(SentenceTiles("No, no, NO."))
    }

    /// Keys are folded: capitals, Turkish letters and the typographic apostrophe do not matter.
    func testKeysAreFolded() {
        XCTAssertEqual(SentenceTiles.Tile(id: 0, text: "Don’t").key, SentenceTiles.Tile(id: 0, text: "don't").key)
        XCTAssertEqual(SentenceTiles.Tile(id: 0, text: "İstanbul").key, "istanbul")
        XCTAssertEqual(SentenceTiles.Tile(id: 0, text: "The").key, SentenceTiles.Tile(id: 0, text: "the").key)
        XCTAssertEqual(SentenceTiles.Tile(id: 0, text: "Café").key, "cafe")
    }

    // MARK: Mixing

    func testShuffleKeepsEveryTileOnceAndIsTheSameForTheSameSeed() throws {
        let tiles = try XCTUnwrap(SentenceTiles("Maria stirred her coffee with a spoon."))
        let first = tiles.shuffled(seed: 42)
        XCTAssertEqual(first, tiles.shuffled(seed: 42))
        XCTAssertEqual(first, tiles.shuffled(seed: 42, attempt: 0))
        XCTAssertEqual(first.map(\.id).sorted(), tiles.tiles.map(\.id))
        XCTAssertEqual(Set(first), Set(tiles.tiles))
    }

    /// Never the sentence itself, even with three tiles and many seeds.
    func testShuffleIsNeverTheSentencesOrder() throws {
        for sentence in ["I like tea.", "The cat saw the dog.", "Can I have a spoon, please?"] {
            let tiles = try XCTUnwrap(SentenceTiles(sentence))
            let right = tiles.tiles.map(\.key)
            for seed in -50..<250 {
                for attempt in 0..<3 {
                    XCTAssertNotEqual(tiles.shuffled(seed: seed, attempt: attempt).map(\.key), right, "\(sentence) \(seed) \(attempt)")
                }
            }
        }
    }

    func testAnotherAttemptOrSeedMixesAnew() throws {
        let tiles = try XCTUnwrap(SentenceTiles("Kenji ate his soup with a big spoon."))
        let orders = Set((0..<6).map { tiles.shuffled(seed: 7, attempt: $0).map(\.id) })
        XCTAssertGreaterThan(orders.count, 3)
        let seeds = Set((0..<6).map { tiles.shuffled(seed: $0).map(\.id) })
        XCTAssertGreaterThan(seeds.count, 3)
    }

    // MARK: Checking

    func testTheSentencesOrderIsCorrect() throws {
        let tiles = try XCTUnwrap(SentenceTiles("Can I have a spoon, please?"))
        let check = tiles.check(tiles.tiles)
        XCTAssertTrue(check.isCorrect)
        XCTAssertEqual(check.misplaced, [])
    }

    /// "the" and "The" may swap places: the words read the same.
    func testTilesWithTheSameWordMaySwap() throws {
        let tiles = try XCTUnwrap(SentenceTiles("The cat saw the dog."))
        let t = tiles.tiles
        XCTAssertTrue(tiles.check([t[3], t[1], t[2], t[0], t[4]]).isCorrect)
    }

    /// One tile put first marks one tile, not the whole row.
    func testOnlyMisplacedTilesAreMarked() throws {
        let tiles = try XCTUnwrap(SentenceTiles("Can I have a spoon, please?"))
        let t = tiles.tiles
        let check = tiles.check([t[1], t[0], t[2], t[3], t[4], t[5]])
        XCTAssertFalse(check.isCorrect)
        XCTAssertEqual(check.misplaced.count, 1)
        let moved = tiles.check([t[5], t[0], t[1], t[2], t[3], t[4]])
        XCTAssertEqual(moved.misplaced, [0])
    }

    func testMissingOrForeignTilesAreNotCorrect() throws {
        let tiles = try XCTUnwrap(SentenceTiles("I like tea."))
        XCTAssertFalse(tiles.check(Array(tiles.tiles.prefix(2))).isCorrect)
        XCTAssertFalse(tiles.check([]).isCorrect)
        XCTAssertFalse(tiles.check(tiles.tiles + [tiles.tiles[0]]).isCorrect)
        let foreign = [tiles.tiles[0], tiles.tiles[1], SentenceTiles.Tile(id: 9, text: "tea")]
        XCTAssertFalse(tiles.check(foreign).isCorrect)
    }

    /// What VoiceOver reads back: the placed words, with the final mark once all are placed.
    func testLineReadsThePlacedWords() throws {
        let tiles = try XCTUnwrap(SentenceTiles("Can I have a spoon, please?"))
        XCTAssertEqual(tiles.line(tiles.tiles), "Can I have a spoon please?")
        XCTAssertEqual(tiles.line(Array(tiles.tiles.prefix(3))), "Can I have")
        XCTAssertEqual(tiles.line([]), "")
    }

    /// The single words around "and" or "or" may swap: "itchy and red" is right English too.
    func testWordsAroundAndOrMaySwap() throws {
        let arm = try XCTUnwrap(SentenceTiles("My arm is red and itchy."))
        let t = arm.tiles
        let swapped = arm.check([t[0], t[1], t[2], t[5], t[4], t[3]])
        XCTAssertTrue(swapped.isCorrect)
        XCTAssertEqual(swapped.misplaced, [])
        XCTAssertFalse(arm.check([t[0], t[1], t[5], t[2], t[4], t[3]]).isCorrect)
        let bowl = try XCTUnwrap(SentenceTiles("Mix the eggs and flour in a large bowl."))
        let b = bowl.tiles
        XCTAssertTrue(bowl.check([b[0], b[1], b[4], b[3], b[2]] + b[5...]).isCorrect)
        let spicy = try XCTUnwrap(SentenceTiles("Would you like it mild or spicy?"))
        let s = spicy.tiles
        XCTAssertTrue(spicy.check(Array(s[..<4]) + [s[6], s[5], s[4]]).isCorrect)
    }

    /// The mixed order is never one of the right orders either.
    func testShuffleIsNeverAnotherRightOrder() throws {
        let tiles = try XCTUnwrap(SentenceTiles("Salt and pepper."))
        for seed in 0..<300 {
            XCTAssertFalse(tiles.check(tiles.shuffled(seed: seed)).isCorrect, "seed \(seed)")
        }
    }
}
