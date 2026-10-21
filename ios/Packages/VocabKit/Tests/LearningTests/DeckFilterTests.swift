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

    /// `card_category` membership: a card can be in several topics.
    private let topicsOf: [Int: Set<String>] = [
        1: ["food_drink"],
        2: ["travel_tourism"],
        3: ["food_drink", "home_household"],
        4: ["travel_tourism", "cities_transport"],
        5: ["workplace_office"],
        6: ["travel_tourism", "workplace_office"],
        7: ["food_drink"],
    ]

    private func ids(_ list: [WidgetWord]) -> [Int] {
        return list.map { $0.id }
    }

    private func progress(known: [Int], learning: [Int]) -> [Int: WordProgress] {
        var result: [Int: WordProgress] = [:]
        for id in known {
            var p = WordProgress(wordID: id)
            p.state = .known
            result[id] = p
        }
        for id in learning {
            var p = WordProgress(wordID: id)
            p.state = .learning
            p.box = 1
            result[id] = p
        }
        return result
    }

    // MARK: Topics

    func testNoChoiceKeepsEveryWordInOrder() {
        let feed = DeckFilter.feed(curriculum, topicsOf: topicsOf, choice: DeckChoice())
        XCTAssertEqual(ids(feed), [1, 2, 3, 4, 5, 6, 7])
    }

    func testChosenTopicsKeepTheCurriculumOrder() {
        let travel = DeckFilter.feed(curriculum, topicsOf: topicsOf, choice: DeckChoice(topicIDs: ["travel_tourism"]))
        XCTAssertEqual(ids(travel), [2, 4, 6])
    }

    func testMembershipCountsNotOnlyTheMainTopic() {
        // 3 is a food card that also belongs to home; 4 a travel card that also belongs to cities.
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicsOf: topicsOf, topicIDs: ["home_household"])), [3])
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicsOf: topicsOf, topicIDs: ["cities_transport"])), [4])
    }

    func testAWordInSeveralChosenTopicsComesOnce() {
        // 6 is in travel and in work.
        let travelAndWork = DeckFilter.filtered(curriculum, topicsOf: topicsOf, topicIDs: ["travel_tourism", "workplace_office"])
        XCTAssertEqual(ids(travelAndWork), [2, 4, 5, 6])
    }

    func testAChoiceThatMatchesNothingKeepsEveryWord() {
        // A topic that left the content.
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicsOf: topicsOf, topicIDs: ["retired_topic"])), [1, 2, 3, 4, 5, 6, 7])
        // Seed words (no database) have no topic.
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicsOf: [:], topicIDs: ["travel_tourism"])), [1, 2, 3, 4, 5, 6, 7])
        // A stale id next to a live one: only the live one counts.
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicsOf: topicsOf, topicIDs: ["retired_topic", "workplace_office"])), [5, 6])
    }

    func testWordsWithoutATopicAreLeftOutOfAChosenDeck() {
        var partial = topicsOf
        partial[4] = nil
        XCTAssertEqual(ids(DeckFilter.filtered(curriculum, topicsOf: partial, topicIDs: ["travel_tourism"])), [2, 6])
    }

    // MARK: Level order

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
        let feed = DeckFilter.feed(curriculum, topicsOf: topicsOf, choice: DeckChoice(topicIDs: ["food_drink"], startLevel: .a2))
        XCTAssertEqual(ids(feed), [3, 7, 1])
    }

    func testEmptyInput() {
        XCTAssertTrue(DeckFilter.feed([], topicsOf: topicsOf, choice: DeckChoice(topicIDs: ["food_drink"], startLevel: .b1)).isEmpty)
    }

    // MARK: Summary and new words

    func testSummaryCountsTheDeckOnceAndItsNewWords() {
        // 2 known, 4 learning, the rest never studied.
        let studied = progress(known: [2], learning: [4])
        XCTAssertEqual(
            DeckFilter.summary(curriculum, topicsOf: topicsOf, topicIDs: ["travel_tourism"], progress: studied),
            DeckSummary(wordCount: 3, newCount: 1)
        )
        // No choice: every word.
        XCTAssertEqual(
            DeckFilter.summary(curriculum, topicsOf: topicsOf, topicIDs: [], progress: studied),
            DeckSummary(wordCount: 7, newCount: 5)
        )
        // The summary counts what the feed shows (6 is in both topics, counted once).
        let choice = DeckChoice(topicIDs: ["travel_tourism", "workplace_office"])
        XCTAssertEqual(
            DeckFilter.summary(curriculum, topicsOf: topicsOf, topicIDs: choice.topicIDs, progress: [:]).wordCount,
            DeckFilter.feed(curriculum, topicsOf: topicsOf, choice: choice).count
        )
    }

    func testHasNewWords() {
        let studied = progress(known: [2], learning: [4])
        XCTAssertFalse(DeckFilter.hasNewWords([word(2, "A1"), word(4, "A2")], progress: studied))
        XCTAssertTrue(DeckFilter.hasNewWords([word(2, "A1"), word(4, "A2"), word(6, "B1")], progress: studied))
        XCTAssertFalse(DeckFilter.hasNewWords([], progress: studied))
    }

    func testNewWordsComeFromEveryTopicOnceTheDeckHasNone() {
        let studied = progress(known: [2], learning: [4])
        let finished = [word(2, "A1"), word(4, "A2")]
        let open = [word(2, "A1"), word(6, "B1")]
        XCTAssertEqual(ids(DeckFilter.newWordFeed(deck: finished, fallback: curriculum, progress: studied)), [1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(ids(DeckFilter.newWordFeed(deck: open, fallback: curriculum, progress: studied)), [2, 6])
        XCTAssertTrue(DeckFilter.newWordFeed(deck: [], fallback: [], progress: studied).isEmpty)
    }
}
