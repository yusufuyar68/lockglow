import CoreModels

/// Real cards from content.sqlite chosen to stress the widget layouts (generated once from
/// the database; refresh by hand if the texts change): a typical word, the longest headword,
/// the longest Turkish gloss, the longest micro and short definitions, the longest example.
enum SnapshotWords {
    static let all: [WidgetWord] = [
        WidgetWord(
            id: 1, lemma: "breakfast", pos: "n", level: "A1", ipaUS: "/ˈbrɛkfəst/",
            defMicro: "first meal of the day", defShort: "the first meal of the day, eaten in the morning",
            exampleEN: "I usually have breakfast at seven.", glossTR: "kahvaltı"
        ),
        WidgetWord(
            id: 311, lemma: "look forward to", pos: "phv", level: "B1", ipaUS: "/lʊk ˈfɔːrwərd tə/",
            defMicro: "wait happily for something", defShort: "feel happy and excited about something that will happen",
            exampleEN: "I'm looking forward to the weekend.", glossTR: "dört gözle beklemek"
        ),
        WidgetWord(
            id: 399, lemma: "end up", pos: "phv", level: "B1", ipaUS: "/ɛnd ˈʌp/",
            defMicro: "finally be in a situation", defShort: "be in a place or situation at the end, often by chance",
            exampleEN: "We got lost and ended up in a small village.", glossTR: "sonunda kendini ... bulmak"
        ),
        WidgetWord(
            id: 11, lemma: "fridge", pos: "n", level: "A1", ipaUS: "/frɪdʒ/",
            defMicro: "machine that keeps food cold", defShort: "a big kitchen machine that keeps food and drinks cold",
            exampleEN: "There is some milk in the fridge.", glossTR: "buzdolabı"
        ),
        WidgetWord(
            id: 140, lemma: "date", pos: "n", level: "A2", ipaUS: "/deɪt/",
            defMicro: "a romantic meeting", defShort: "a planned time when two people meet because they like each other romantically",
            exampleEN: "I have a date on Friday night.", glossTR: "romantik buluşma"
        ),
        WidgetWord(
            id: 286, lemma: "actually", pos: "adv", level: "B1", ipaUS: "/ˈæktʃuəli/",
            defMicro: "in fact; in reality", defShort: "used to say what is really true, often when it is not what people expect",
            exampleEN: "I thought the test would be hard, but it was actually quite easy.", glossTR: "aslında, gerçekte"
        ),
    ]
}
