/// CEFR level of a card. `rank` matches `card.level_rank` in the content DB (A1 = 1 ... C2 = 6, S = 7).
public enum Level: String, Codable, CaseIterable, Comparable, Sendable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"
    case s = "S"

    public var rank: Int {
        switch self {
        case .a1: return 1
        case .a2: return 2
        case .b1: return 3
        case .b2: return 4
        case .c1: return 5
        case .c2: return 6
        case .s: return 7
        }
    }

    public init?(rank: Int) {
        guard let match = Level.allCases.first(where: { $0.rank == rank }) else {
            return nil
        }
        self = match
    }

    public static func < (lhs: Level, rhs: Level) -> Bool {
        return lhs.rank < rhs.rank
    }
}
