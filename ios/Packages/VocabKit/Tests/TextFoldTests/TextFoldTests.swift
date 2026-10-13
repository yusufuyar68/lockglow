import XCTest
import TextFold

final class TextFoldTests: XCTestCase {
    /// Contract section 4 test vectors. Keep identical to the Python side.
    func testContractVectors() {
        let vectors: [(input: String, expected: String)] = [
            ("Çiçek", "cicek"),
            ("IŞIK", "isik"),
            ("İstanbul", "istanbul"),
            ("hâlsiz bırakmak", "halsiz birakmak"),
            ("  Look  Up To ", "look up to"),
            ("naïve", "naive"),
        ]
        for vector in vectors {
            XCTAssertEqual(TextFold.fold(vector.input), vector.expected, "input: \(vector.input)")
        }
    }

    func testDecomposedInputGivesSameResult() {
        // "C" + combining cedilla, "i", "c" + combining cedilla, "ek"
        let decomposed = "C\u{0327}ic\u{0327}ek"
        XCTAssertEqual(TextFold.fold(decomposed), "cicek")
        // "I" + combining dot above is a decomposed capital dotted I.
        XCTAssertEqual(TextFold.fold("I\u{0307}stanbul"), "istanbul")
    }

    func testEmptyAndWhitespaceOnly() {
        XCTAssertEqual(TextFold.fold(""), "")
        XCTAssertEqual(TextFold.fold("   \t\n "), "")
    }

    func testIsIdempotent() {
        let samples = ["Çiçek", "İstanbul", "  Look  Up To ", "naïve", "ŞÖLEN ÜÜ"]
        for sample in samples {
            let once = TextFold.fold(sample)
            XCTAssertEqual(TextFold.fold(once), once, "input: \(sample)")
        }
    }

    func testRemainingTurkishLetters() {
        XCTAssertEqual(TextFold.fold("ĞÜŞİÖÇ ğüşıöç"), "gusioc gusioc")
        XCTAssertEqual(TextFold.fold("âîû ÂÎÛ"), "aiu aiu")
    }
}
