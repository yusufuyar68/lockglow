import XCTest
import CoreModels
@testable import Learning

/// "Yol haritası" (`LevelMap`): counts per level and the topics that come next.
final class LevelMapTests: XCTestCase {
    private func word(_ id: Int, _ level: String) -> WidgetWord {
        return WidgetWord(id: id, lemma: "w\(id)", pos: "n", level: level, defMicro: "", defShort: "", exampleEN: "")
    }

    private func met(_ state: LearningState = .learning) -> WordProgress {
        var p = WordProgress(wordID: 0)
        p.state = state
        p.box = state == .learning ? 1 : 0
        return p
    }

    private let order = ["food": 0, "home": 1, "travel": 2, "work": 3, "phrasal": 41]

    func testCountsWordsAndMetWordsPerLevel() {
        let words = [word(1, "A1"), word(2, "A1"), word(3, "A2"), word(4, "B1"), word(5, "B1")]
        let progress = [1: met(), 4: met(.known), 5: WordProgress(wordID: 5)]
        let map = LevelMap.make(
            levels: [.a1, .a2, .b1],
            words: words,
            upcoming: words,
            progress: progress,
            topicsOf: [:],
            topicOrder: order,
            startLevel: .a1
        )
        XCTAssertEqual(map.stops.map { $0.total }, [2, 1, 2])
        XCTAssertEqual(map.stops.map { $0.met }, [1, 0, 1])
        XCTAssertEqual(map.stops.map { $0.level }, [.a1, .a2, .b1])
        XCTAssertEqual(map.startLevel, .a1)
    }

    func testTheUsersOwnWordsAreNotOnTheMap() {
        let own = WidgetWord(id: CustomWordID.first + 1, lemma: "mine", pos: "", level: "A1", defMicro: "", defShort: "", exampleEN: "")
        let map = LevelMap.make(
            levels: [.a1],
            words: [word(1, "A1"), own],
            upcoming: [own, word(1, "A1")],
            progress: [:],
            topicsOf: [1: ["food"]],
            topicOrder: order,
            startLevel: nil
        )
        XCTAssertEqual(map.stops.first?.total, 1)
        XCTAssertEqual(map.currentLevel, .a1)
    }

    func testNextTopicsFollowTheOrderOfTheNextNewWords() {
        let words = [word(1, "A2"), word(2, "A2"), word(3, "A2"), word(4, "A2"), word(5, "A2"), word(6, "A2")]
        let topics: [Int: Set<String>] = [
            1: ["food"],
            2: ["travel", "phrasal"],
            3: ["food"],
            4: ["work"],
            5: ["home"],
            6: ["home"],
        ]
        let map = LevelMap.make(
            levels: [.a2],
            words: words,
            upcoming: words,
            progress: [1: met()],
            topicsOf: topics,
            topicOrder: order,
            startLevel: .a2
        )
        // Word 1 was met; word 2 is named by its first topic in display order, not "phrasal".
        XCTAssertEqual(map.stops.first?.nextTopicIDs, ["travel", "food", "work"])
        XCTAssertEqual(map.currentLevel, .a2)
    }

    func testAChosenTopicNamesTheWord() {
        let map = LevelMap.make(
            levels: [.a1],
            words: [word(1, "A1")],
            upcoming: [word(1, "A1")],
            progress: [:],
            topicsOf: [1: ["food", "travel"]],
            topicOrder: order,
            preferredTopicIDs: ["travel"],
            startLevel: nil
        )
        XCTAssertEqual(map.stops.first?.nextTopicIDs, ["travel"])
    }

    func testTopicsNotShownAreNotNamed() {
        let map = LevelMap.make(
            levels: [.a1],
            words: [word(1, "A1"), word(2, "A1")],
            upcoming: [word(1, "A1"), word(2, "A1")],
            progress: [:],
            topicsOf: [1: ["tiny"], 2: ["home"]],
            topicOrder: order,
            startLevel: nil
        )
        XCTAssertEqual(map.stops.first?.nextTopicIDs, ["home"])
    }

    func testTheCurrentLevelIsTheLevelOfTheNextNewWord() {
        let words = [word(1, "A1"), word(2, "A2"), word(3, "B1")]
        let map = LevelMap.make(
            levels: [.a1, .a2, .b1],
            words: words,
            upcoming: [word(2, "A2"), word(3, "B1"), word(1, "A1")],
            progress: [2: met()],
            topicsOf: [:],
            topicOrder: order,
            startLevel: .a2
        )
        XCTAssertEqual(map.currentLevel, .b1)
    }

    func testEveryWordMetLeavesNoNextTopics() {
        let map = LevelMap.make(
            levels: [.a1, .a2],
            words: [word(1, "A1"), word(2, "A2")],
            upcoming: [word(1, "A1"), word(2, "A2")],
            progress: [1: met(.known)],
            topicsOf: [1: ["food"], 2: ["home"]],
            topicOrder: order,
            startLevel: nil
        )
        XCTAssertEqual(map.stops[0].everyWordMet, true)
        XCTAssertEqual(map.stops[0].nextTopicIDs, [])
        XCTAssertEqual(map.stops[1].everyWordMet, false)
        XCTAssertEqual(map.stops[1].nextTopicIDs, ["home"])
        XCTAssertEqual(map.currentLevel, .a2)
    }

    func testNoNewWordLeftHasNoCurrentLevel() {
        let map = LevelMap.make(
            levels: [.a1],
            words: [word(1, "A1")],
            upcoming: [word(1, "A1")],
            progress: [1: met()],
            topicsOf: [:],
            topicOrder: order,
            startLevel: nil
        )
        XCTAssertNil(map.currentLevel)
        XCTAssertFalse(LevelMap.Stop(level: .b1, total: 0, met: 0, nextTopicIDs: []).everyWordMet)
    }
}
