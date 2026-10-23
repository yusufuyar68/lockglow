/// British and American spellings of the same spoken word, for "Söyle". With the accent set to
/// İngiltere the recognizer listens in British English and writes "colour", "recognise",
/// "travelled", "pyjamas"; the cards are spelled the American way ("neighbor", "recognize"). A
/// few cards use the British spelling ("apologise", "favourite") and the American recognizer
/// writes those the American way. Both sides are compared in the American spelling, so a word
/// said right counts whichever way it is written.
///
/// Only spellings of one word that sounds the same: "mum"/"mom", "aluminium"/"aluminum" or
/// "learnt"/"learned" sound different and stay apart (the recognizer writes what it hears). The
/// "-ise" verbs are listed by stem, because "advise", "exercise" or "surprise" never take "-ize".
public enum SpellingVariants {
    /// Lowercase British spelling (apostrophes dropped, as `PronunciationCheck` keys) → American.
    public static let american: [String: String] = {
        var map: [String: String] = [:]
        func add(_ british: String, _ american: String) {
            if british != american {
                map[british] = american
            }
        }
        // colour, coloured, colourful; favourite; neighbourhood; behavioural.
        let ourEndings = ["", "s", "ed", "ing", "ful", "fully", "less", "able", "ably", "al", "ite", "ites", "hood", "hoods", "er", "ers", "ly", "y"]
        for stem in ourStems {
            for ending in ourEndings {
                add(stem + "our" + ending, stem + "or" + ending)
            }
        }
        // centre, centres, centred; theatre; kilometre.
        for stem in reStems {
            add(stem + "re", stem + "er")
            add(stem + "res", stem + "ers")
            add(stem + "red", stem + "ered")
            add(stem + "ring", stem + "ering")
        }
        // organise, organised, organisation; recognise; apologise.
        let iseEndings = [("ise", "ize"), ("ises", "izes"), ("ised", "ized"), ("ising", "izing"),
                          ("isation", "ization"), ("isations", "izations"), ("iser", "izer"), ("isers", "izers")]
        for stem in iseStems {
            for (british, american) in iseEndings {
                add(stem + british, stem + american)
            }
        }
        // analyse, paralysed.
        for stem in ["anal", "paral", "catal"] {
            for (british, american) in [("yse", "yze"), ("ysed", "yzed"), ("ysing", "yzing"), ("yser", "yzer")] {
                add(stem + british, stem + american)
            }
        }
        // cancelled, travelling, traveller, marvellous, counsellor.
        for stem in llStems {
            add(stem + "led", stem + "ed")
            add(stem + "ling", stem + "ing")
            add(stem + "ler", stem + "er")
            add(stem + "lers", stem + "ers")
            add(stem + "lor", stem + "or")
            add(stem + "lors", stem + "ors")
            add(stem + "lous", stem + "ous")
        }
        for (british, american) in words {
            add(british, american)
        }
        return map
    }()

    /// The American spelling of `key`, or `key` itself.
    public static func americanSpelling(_ key: String) -> String {
        return american[key] ?? key
    }

    private static let ourStems = [
        "col", "fav", "flav", "hon", "hum", "lab", "neighb", "behavi", "harb", "rum", "od", "vap",
        "arm", "sav", "endeav", "parl", "tum", "vig", "val", "rig", "clam", "ard", "splend",
    ]

    private static let reStems = [
        "cent", "theat", "met", "lit", "fib", "kilomet", "centimet", "millimet", "somb", "spect",
        "lust", "meag", "sab", "calib",
    ]

    private static let iseStems = [
        "organ", "real", "recogn", "apolog", "critic", "memor", "emphas", "priorit", "special",
        "summar", "sympath", "final", "minim", "maxim", "custom", "personal", "social", "normal",
        "standard", "visual", "util", "author", "categor", "character", "energ", "legal", "modern",
        "mobil", "stabil", "symbol", "vandal", "optim", "civil", "global", "harmon", "hospital",
        "local", "magnet", "moral", "national", "natural", "neutral", "fertil", "steril", "patron",
        "synchron", "sanit", "theor", "agon", "colon", "familiar", "fantas", "hypnot", "jeopard",
        "item", "monopol", "penal", "popular", "scrutin", "terror", "tranquil", "urban", "western",
        "computer", "digit", "motor", "capital", "commercial", "central", "industrial", "spiritual",
    ]

    private static let llStems = [
        "cancel", "travel", "label", "model", "level", "fuel", "signal", "total", "quarrel", "dial",
        "marvel", "counsel", "channel", "tunnel", "pedal", "rival", "shovel", "snorkel", "jewel",
        "duel", "equal", "grovel", "libel", "panel", "parcel", "pencil", "revel", "swivel", "towel",
    ]

    private static let words: [(String, String)] = [
        ("grey", "gray"), ("greys", "grays"), ("greyer", "grayer"), ("greyish", "grayish"),
        ("pyjamas", "pajamas"), ("pyjama", "pajama"), ("tyre", "tire"), ("tyres", "tires"),
        ("programme", "program"), ("programmes", "programs"), ("catalogue", "catalog"),
        ("catalogues", "catalogs"), ("analogue", "analog"), ("dialogue", "dialog"), ("dialogues", "dialogs"),
        ("defence", "defense"), ("offence", "offense"), ("licence", "license"), ("licences", "licenses"),
        ("pretence", "pretense"), ("practise", "practice"), ("practised", "practiced"),
        ("practises", "practices"), ("practising", "practicing"), ("plough", "plow"), ("mould", "mold"),
        ("mouldy", "moldy"), ("moustache", "mustache"), ("sceptical", "skeptical"), ("ageing", "aging"),
        ("judgement", "judgment"), ("judgements", "judgments"), ("doughnut", "donut"), ("doughnuts", "donuts"),
        ("whisky", "whiskey"), ("kerb", "curb"), ("sulphur", "sulfur"), ("diarrhoea", "diarrhea"),
        ("manoeuvre", "maneuver"), ("manoeuvres", "maneuvers"), ("anaemia", "anemia"), ("anaesthetic", "anesthetic"), ("paediatrician", "pediatrician"),
        ("oesophagus", "esophagus"), ("enrol", "enroll"), ("enrols", "enrolls"), ("enrolment", "enrollment"),
        ("fulfil", "fulfill"), ("fulfils", "fulfills"), ("fulfilment", "fulfillment"), ("skilful", "skillful"),
        ("wilful", "willful"), ("instalment", "installment"), ("instalments", "installments"),
        ("jewellery", "jewelry"), ("cosy", "cozy"), ("cosier", "cozier"), ("yoghurt", "yogurt"),
        ("yoghurts", "yogurts"), ("tonne", "ton"), ("tonnes", "tons"), ("draught", "draft"),
        ("draughts", "drafts"), ("woollen", "woolen"), ("cheque", "check"), ("cheques", "checks"),
    ]
}
