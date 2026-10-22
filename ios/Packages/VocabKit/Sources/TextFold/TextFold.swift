import Foundation

/// Search normalization, contract section 4. The Python pipeline implements the same
/// algorithm; both sides must keep the shared test vectors green.
public enum TextFold {
    public static func fold(_ input: String) -> String {
        // 1. Unicode NFC.
        let composed = input.precomposedStringWithCanonicalMapping

        // 2. Letter mapping, BEFORE lowercasing (so "I" and "İ" both become "i").
        var mapped = String.UnicodeScalarView()
        for scalar in composed.unicodeScalars {
            mapped.append(mapLetter(scalar))
        }

        // 3. Lowercase (Swift's lowercased() is locale independent).
        let lowered = String(mapped).lowercased()

        // 4. NFKD, then drop combining marks. Final sigma becomes sigma: Python's lower() turns a
        // word-final capital sigma into U+03C2, Swift's lowercased() into U+03C3, and NFKD turns
        // the lunate sigma U+03F2 into U+03C2. Search treats them all as U+03C3.
        let decomposed = lowered.decomposedStringWithCompatibilityMapping
        var stripped = String.UnicodeScalarView()
        for scalar in decomposed.unicodeScalars where !isCombiningMark(scalar) {
            stripped.append(scalar.value == 0x03C2 ? "\u{03C3}" : scalar)
        }

        // 5. Collapse whitespace runs to one space, trim both ends. Whitespace is Unicode's
        // White_Space property; the Python side lists the same set (U+001C...U+001F are not in it).
        var result = ""
        var pendingSpace = false
        for scalar in stripped {
            if scalar.properties.isWhitespace {
                pendingSpace = !result.isEmpty
                continue
            }
            if pendingSpace {
                result.append(" ")
                pendingSpace = false
            }
            result.unicodeScalars.append(scalar)
        }
        return result
    }

    // Code points are written numerically so the file stays correct whatever
    // normalization form an editor saves it in.
    private static func mapLetter(_ scalar: Unicode.Scalar) -> Unicode.Scalar {
        switch scalar.value {
        case 0x0131, 0x0130, 0x0049, 0x00EE, 0x00CE: // ı İ I î Î
            return "i"
        case 0x00E7, 0x00C7: // ç Ç
            return "c"
        case 0x011F, 0x011E: // ğ Ğ
            return "g"
        case 0x00F6, 0x00D6: // ö Ö
            return "o"
        case 0x015F, 0x015E: // ş Ş
            return "s"
        case 0x00FC, 0x00DC, 0x00FB, 0x00DB: // ü Ü û Û
            return "u"
        case 0x00E2, 0x00C2: // â Â
            return "a"
        default:
            return scalar
        }
    }

    /// Same test as Python's `unicodedata.combining(ch) != 0` (canonical combining class),
    /// so both sides drop exactly the same scalars.
    private static func isCombiningMark(_ scalar: Unicode.Scalar) -> Bool {
        return scalar.properties.canonicalCombiningClass.rawValue != 0
    }
}
