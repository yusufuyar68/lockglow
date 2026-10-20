import XCTest
import CoreModels
import Learning

final class DeckFilterTests: XCTestCase {
    private func word(_ id: Int, _ level: String) -> WidgetWord {
        return WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: level, defMicro: "m", defShort: "s", exampleEN: "e")
    }

    /// Curriculum order as `ContentStore.freeCards` returns it (A1, A2, B1).
    private var curriculum: [WidgetWord] {
        return [word(1, "A1"), word(2, "A1"), word(3, "A2"), word(4, "A2"), word(5, "A2"), word(6, "B1"), word(7, "B1")]
    }

    private let topicOf: [Int: String] = [
        1: "food_drink",
        2: "travel_tourism",
        3: "food_drink",
        4: "travel_tourism",
        5: "workplace_office",
        6: "travel_tourism",
        7: "food_drink",
    ]

    private func ids(_ list: [WidgetWord]) -> [Int] {
        return list.map { $0.id }
    }

    func testNoChoiceKeepsEveryWordInOrder() {
        let feed = DeckFilter.feed(curriculum, topicOf: topicOf, choice: DeckChoice())
        XCTAssertEqual(ids(feed), [1, 2, 3, 4, 5, 6, 7])
    }

    func testChosenTopicsKeepTheCurriculumOrder() {
        let travel = DeckFilter.feed(curriculum, topicOf: topicOf, choice: DeckChoice(topicIDs: ["travel_tourism"]))
        XCTAssertEqual(ids(travel), [2, 4, 6])
        let travelAndWork = DeckFilter.filtered(curriculum, topicOf: topicOf, topicIDs: ["travel_tourism", "workplace_office"])
        XCTAssertEqual(ids(travelAndWork), [2, 4, 5, 6])
    }

    func testAChoiceThatMatchesNothingKeepsEveryWord() {
        // A topic that left the content.
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicOf: topicOf, topicIDs: ["retired_topic"])), [1, 2, 3, 4, 5, 6, 7])
        // Seed words (no database) have no topic.
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicOf: [:], topicIDs: ["travel_tourism"])), [1, 2, 3, 4, 5, 6, 7])
        // A stale id next to a live one: only the live one counts.
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicOf: topicOf, topicIDs: ["retired_topic", "workplace_office"])), [5])
    }

    func testWordsWithoutATopicAreLeftOutOfAChosenDeck() {
        var partial = topicOf
        partial[4] = nil
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicOf: partial, topicIDs: ["travel_tourism"])), [2, 6])
    }

    func testStartLevelFirstThenHarderThenEasier() {
        XCTAssertEqual(ids(DeckFilter.ordered(curriculum, startingAt: .a2)), [3, 4, 5, 6, 7, 1, 2])
        XCTAssertEqual(ids(DeckFilter.ordered(curriculum, startingAt: .b1)), [6, 7, 3, 4, 5, 1, 2])
        XCTAssertEqual(ids(DeckFilter.ordered(curriculum, startingAt: .a1)), [1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(ids(DeckFilter.ordered(curriculum, startingAt: nil)), [1, 2, 3, 4, 5, 6, 7])
    }

    func testLevelOrderIsStableAndPutsUnknownLevelsLast() {
        // Not sorted by level, with an unknown level, a C1 and an S (special, rank 7) card.
        let mixed = [word(10, "B1"), word(11, "??"), word(12, "A2"), word(13, "S"), word(14, "A1"), word(15, "A2"), word(16, "C1")]
        // A2 (12, 15), B1 (10), C1 (16), S (13), then below: A1 (14), then unknown (11).
        XCTAssertEqual(ids(DeckFilter.ordered(mixed, startingAt: .a2)), [12, 15, 10, 16, 13, 14, 11])
    }

    func testTopicAndLevelTogether() {
        // Food words: 1 (A1), 3 (A2), 7 (B1). Starting at A2: 3, 7, then 1.
        let feed = DeckFilter.feed(curriculum, topicOf: topicOf, choice: DeckChoice(topicIDs: ["food_drink"], startLevel: .a2))
        XCTAssertEqual(ids(feed), [3, 7, 1])
    }

    func testEmptyInput() {
        XCTAssertTrue(DeckFilter.feed([], topicOf: topicOf, choice: DeckChoice(topicIDs: ["food_drink"], startLevel: .b1)).isEmpty)
    }
}
