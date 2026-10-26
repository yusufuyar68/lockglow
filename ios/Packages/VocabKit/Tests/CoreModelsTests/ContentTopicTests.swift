import XCTest
import CoreModels

/// `ContentTopic`'s names on screen: the topic's own Turkish name from the content
/// (`category.name_tr`) and the title of its group in the topic choice.
final class ContentTopicTests: XCTestCase {
    private func topic(_ id: String, group: String, nameTR: String) -> ContentTopic {
        return ContentTopic(id: id, group: group, nameEN: id, nameTR: nameTR, sort: 0, cardCount: 240)
    }

    /// The exam topic has no name of its own in the app: the content's Turkish name is shown as
    /// it is (no "&" to replace), under "Sınavlar".
    func testTheExamTopicShowsItsContentNameUnderSinavlar() {
        let exam = topic("yds_yokdil_core", group: "I", nameTR: "YDS / YÖKDİL Çekirdek")
        XCTAssertEqual(exam.displayName, "YDS / YÖKDİL Çekirdek")
        XCTAssertEqual(exam.groupTitle, "Sınavlar")
    }

    func testGroupTitles() {
        let titles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "Z"].map { topic("t", group: $0, nameTR: "T").groupTitle }
        XCTAssertEqual(titles, [
            "Günlük hayat", "Seyahat ve kültür", "İnsanlar ve duygular", "İş ve teknoloji", "İş ve teknoloji",
            "Seyahat ve kültür", "Kalıplar ve tuzaklar", "Zengin kelimeler", "Sınavlar", "Diğer",
        ])
    }

    func testAContentNameWithAnAmpersandReadsVe() {
        XCTAssertEqual(topic("new_topic", group: "A", nameTR: "Spor & Oyun").displayName, "Spor ve Oyun")
        XCTAssertEqual(topic("food_drink", group: "A", nameTR: "Yeme & İçme").displayName, "Yemek ve içecek")
    }
}
