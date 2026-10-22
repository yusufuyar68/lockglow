import XCTest
import TextFold

/// Edge cases of `fold()` (contract section 4): 1. NFC, 2. Turkish letter map, 3. lowercase,
/// 4. NFKD and drop combining marks, 5. collapse and trim whitespace.
/// Every expected output below was also produced by the Python side
/// (`content-pipeline/vocabpipe/textutil.py`, `fold`) on 2026-10-22, unless marked otherwise.
/// Inputs use numeric escapes so the file stays correct whatever normalization an editor applies.
final class TextFoldEdgeTests: XCTestCase {
    private func assertFolds(_ vectors: [(input: String, expected: String)], file: StaticString = #filePath, line: UInt = #line) {
        for vector in vectors {
            let scalars = vector.input.unicodeScalars.map { String($0.value, radix: 16) }.joined(separator: " ")
            XCTAssertEqual(TextFold.fold(vector.input), vector.expected, "input: \(scalars)", file: file, line: line)
        }
    }

    func testTurkishDottedAndDotlessI() {
        assertFolds([
            // Step 2 runs before step 3: "I" becomes "i" (never "ı"), "ı" becomes "i".
            ("ISPARTA \u{0131}l\u{0131}k", "isparta ilik"),
            ("\u{0131}Ii\u{0130}", "iiii"),
            // "İ" alone: lowercasing it first would give "i" + U+0307; step 2 maps it to plain "i".
            ("\u{0130}", "i"),
            // Small i + combining dot above: no precomposed form, the dot is dropped in step 4.
            ("i\u{0307}stanbul", "istanbul"),
            // Dotless ı + combining dot above: ı -> i in step 2, the dot is dropped in step 4.
            ("\u{0131}\u{0307}", "i"),
            // "Ï" and "I" + combining diaeresis (NFC composes it to "Ï"): lowercase, then the mark goes.
            ("\u{00CF}", "i"),
            ("I\u{0308}", "i"),
        ])
    }

    func testDecomposedTurkishLettersFoldLikeTheComposedOnes() {
        // (decomposed, composed, folded). NFC composes the pair first, then step 2 maps it.
        let letters: [(String, String, String)] = [
            ("G\u{0306}", "\u{011E}", "g"), ("g\u{0306}", "\u{011F}", "g"),
            ("S\u{0327}", "\u{015E}", "s"), ("s\u{0327}", "\u{015F}", "s"),
            ("C\u{0327}", "\u{00C7}", "c"), ("c\u{0327}", "\u{00E7}", "c"),
            ("O\u{0308}", "\u{00D6}", "o"), ("o\u{0308}", "\u{00F6}", "o"),
            ("U\u{0308}", "\u{00DC}", "u"), ("u\u{0308}", "\u{00FC}", "u"),
            ("A\u{0302}", "\u{00C2}", "a"), ("a\u{0302}", "\u{00E2}", "a"),
            ("I\u{0302}", "\u{00CE}", "i"), ("i\u{0302}", "\u{00EE}", "i"),
            ("U\u{0302}", "\u{00DB}", "u"), ("u\u{0302}", "\u{00FB}", "u"),
        ]
        for (decomposed, composed, folded) in letters {
            XCTAssertEqual(TextFold.fold(decomposed), folded, "decomposed \(composed)")
            XCTAssertEqual(TextFold.fold(composed), folded, "composed \(composed)")
        }
        assertFolds([
            ("G\u{0306}u\u{0308}nes\u{0327}", "gunes"),
            ("s\u{0327}ehir", "sehir"),
            ("u\u{0308}zu\u{0308}m", "uzum"),
        ])
    }

    func testStackedCombiningMarksAreAllDropped() {
        assertFolds([
            // a + circumflex + acute: NFC makes U+1EA5 (not in the Turkish map); NFKD splits it again.
            ("a\u{0302}\u{0301}", "a"),
            // o + diaeresis + macron: NFC U+022B.
            ("o\u{0308}\u{0304}", "o"),
            // e + acute + cedilla: canonical order puts the cedilla (class 202) before the acute (230).
            ("e\u{0301}\u{0327}", "e"),
            // Capital I + dot above + dot below: NFC makes U+1ECA + U+0307, both marks go.
            ("I\u{0307}\u{0323}", "i"),
        ])
    }

    func testCompatibilityCharactersAreDecomposed() {
        assertFolds([
            ("\u{FB01}nal", "final"),                 // fi ligature
            ("\u{216B}", "xii"),                      // Roman numeral twelve (lowercased to U+217B first)
            ("\u{2160}", "i"),                        // Roman numeral one
            ("\u{FF23}\u{FF21}\u{FF26}\u{00C9}", "cafe"), // fullwidth CAF + É
            ("\u{FF29}", "i"),                        // fullwidth I: lowercased to U+FF49, NFKD "i"
            ("x\u{00B2}", "x2"),                      // superscript two
            ("\u{2460}", "1"),                        // circled one
            ("\u{212B}", "a"),                        // Angstrom sign: NFC turns it into Å
            ("\u{212A}", "k"),                        // Kelvin sign: NFC turns it into K
        ])
    }

    func testEveryKindOfWhitespaceCollapsesToOneSpace() {
        assertFolds([
            ("look\u{00A0}up", "look up"),            // no-break space
            ("look\u{3000}up", "look up"),            // ideographic space
            ("a\u{202F}b", "a b"),                    // narrow no-break space
            ("a\u{2028}b", "a b"),                    // line separator
            ("a\u{0085}b", "a b"),                    // next line (NEL)
            ("\r\n\t look \t\r\n up \u{00A0}", "look up"),
            // Spacing diaeresis: NFKD gives a space + a combining diaeresis; the space stays.
            ("a\u{00A8}b", "a b"),
        ])
    }

    func testInvisibleCharactersThatAreNotWhitespaceStay() {
        // Zero-width space and combining grapheme joiner are neither whitespace nor combining marks
        // (canonical combining class 0), so both sides keep them.
        assertFolds([
            ("look\u{200B}up", "look\u{200B}up"),
            ("a\u{034F}b", "a\u{034F}b"),
        ])
    }

    /// Contract order, not a Swift bug: lowercasing (step 3) runs BEFORE NFKD (step 4), so letters
    /// that only appear in step 4 keep their case. Python gives the same. The FTS index and the query
    /// both go through `fold`, so search still matches; but `fold` is not idempotent for these.
    func testCompatibilityLettersKeepTheirCaseBecauseLowercasingComesFirst() {
        assertFolds([
            ("\u{2122}", "TM"),   // trade mark sign
            ("\u{2116}", "No"),   // numero sign
            ("\u{2110}", "I"),    // script capital I: an "I" the Turkish map in step 2 never saw
        ])
        XCTAssertEqual(TextFold.fold(TextFold.fold("\u{2122}")), "tm")
    }

    func testLongTurkishSentence() {
        assertFolds([
            ("  \u{015E}EK\u{0130}LL\u{0130}  \u{00C7}\u{0130}\u{00C7}EK\tDA\u{011E}\u{0131}  ", "sekilli cicek dagi"),
        ])
    }

    // MARK: Cases where the two sides used to differ

    /// Same vectors as `SHARED_EDGE_VECTORS` in `content-pipeline/tests/test_textutil.py`.
    /// Whitespace is Unicode's White_Space property: U+001C...U+001F (information separators) are
    /// not in it, so they stay and are not trimmed (Python's `\s` and `strip()` alone would take them).
    func testInformationSeparatorsAreNotWhitespace() {
        assertFolds([
            ("a\u{1F}b", "a\u{1F}b"),
            ("a\u{1C}\u{1D}\u{1E}b", "a\u{1C}\u{1D}\u{1E}b"),
            ("\u{1F} look \u{1F}", "\u{1F} look \u{1F}"),
            ("\u{1F}a\u{1F}", "\u{1F}a\u{1F}"),
        ])
    }

    /// Every sigma folds to U+03C3: a word-final capital sigma (Python's `lower()` gives U+03C2 there),
    /// a typed final sigma U+03C2, and the lunate sigmas U+03F2/U+03F9 (NFKD gives U+03C2).
    func testEverySigmaFoldsToTheSameLetter() {
        assertFolds([
            ("\u{039F}\u{0394}\u{039F}\u{03A3}", "\u{03BF}\u{03B4}\u{03BF}\u{03C3}"),
            ("\u{03BF}\u{03B4}\u{03BF}\u{03C2}", "\u{03BF}\u{03B4}\u{03BF}\u{03C3}"),
            ("\u{03A3}\u{0391}\u{03A3} \u{03A3}", "\u{03C3}\u{03B1}\u{03C3} \u{03C3}"),
            ("\u{03F2}\u{03F9}", "\u{03C3}\u{03C3}"),
        ])
    }
}
