import pytest

from vocabpipe.validate import validate_cards


def codes(raw_cards, severity="error"):
    _, issues = validate_cards(raw_cards)
    return {i.code for i in issues if i.severity == severity}


def test_sample_dataset_is_clean(sample_entries):
    cards, issues = validate_cards(sample_entries)
    assert len(cards) == 25
    assert [str(i) for i in issues] == []


def test_unmodified_card_is_clean(card):
    assert codes([card]) == set()


# Her kural bir bozulmayla kanıtlanır: kural gerçekten tetiklenmeli.
@pytest.mark.parametrize(
    "mutate,code",
    [
        (lambda c: c["def"].__setitem__("short", "mitigate something bad"), "DEF_CIRCULAR"),
        (lambda c: c["def"].__setitem__("micro", "x" * 29), "LEN"),
        (lambda c: c["def"].__setitem__("micro", "reduce (harm)"), "DEF_PARENS"),
        (lambda c: c["examples"][0].__setitem__("focus", "mitigates"), "EX_FOCUS"),
        (lambda c: c["examples"][1].__setitem__("tr", None), "EX_TR_MISSING"),
        (lambda c: c["examples"].__setitem__(slice(1, None), []), "COUNT"),
        (lambda c: c["examples"][0].__setitem__("en", "They tried to kill the plan to mitigate costs."), "LOCK_UNSAFE"),
        (lambda c: c["quiz"].__setitem__("cloze", "We ______ the ______ here."), "QUIZ_BLANK"),
        (lambda c: c["quiz"]["distractors"].__setitem__(0, c["quiz"]["answer"]), "QUIZ_ANSWER_IN_DISTRACTORS"),
        (lambda c: c["quiz"].__setitem__("cloze", "We mitigate ______ risk."), "QUIZ_LEAK"),
        (lambda c: c["tags"].__setitem__("primary_topic", "no_such_topic"), "TOPIC_UNKNOWN"),
        (lambda c: c["tags"].__setitem__("topics", ["food_drink"]), "TOPIC_PRIMARY"),
        (lambda c: c["tags"].__setitem__("exams", ["cambridge"]), "EXAM_UNKNOWN"),
        (lambda c: c["tags"].__setitem__("sensitivity", 2), "SENSITIVE_2"),
        (lambda c: c["tags"].__setitem__("sensitivity", 1), "SENSITIVE_1_CATEGORY"),
        (lambda c: c.__setitem__("id", "en.mitigate.n.1"), "ID_POS"),
        (lambda c: c.__setitem__("id", "en.mitigation.v.1"), "ID_SLUG"),
        (lambda c: c["ipa"].__setitem__("us", "ˈmɪtɪɡeɪt"), "IPA_FORMAT"),
        (lambda c: c["l1"]["tr"].__setitem__("equivalence", "false_friend"), "FF_MISSING"),
        (lambda c: c["l1"]["tr"].__setitem__("gloss", "hafiflet" + "̇"), "TR_NFC"),
        (lambda c: c["synonyms"].append("mitigate"), "SYN_SELF"),
        (lambda c: c.__setitem__("type", "idiom"), "TYPE_POS"),
    ],
)
def test_rule_fires(card, mutate, code):
    mutate(card)
    assert code in codes([card])


def test_schema_errors_are_reported_not_raised(card):
    card["level"] = "Z9"
    del card["def"]
    found = codes([card])
    assert found == {"SCHEMA"}


def test_folk_etymology_requires_human_flag(card):
    card["id"], card["lemma"] = "en.posh.adj.1", "posh"
    card["examples"] = [
        {"en": "They stayed at a posh hotel.", "tr": "Lüks bir otelde kaldılar.", "register": "informal", "focus": "posh"},
        {"en": "She has a posh accent.", "tr": "Kibar bir aksanı var.", "register": "informal", "focus": "posh"},
    ]
    card["quiz"] = {"cloze": "They stayed at a ______ hotel.", "answer": "posh", "distractors": ["cheap", "noisy", "small"]}
    card["pos"] = "adj"
    card["synonyms"] = ["fancy"]
    assert "ETYM_FOLK_RISK" in codes([card])
    card["meta"]["qa_flags"].append("etym_reviewed")
    assert "ETYM_FOLK_RISK" not in codes([card])


def test_dataset_level_duplicates(card):
    import copy

    twin = copy.deepcopy(card)
    assert "DUP_ID" in codes([card, twin])


def test_turkish_verb_gloss_form_is_a_warning(card):
    card["l1"]["tr"]["gloss"] = "hafifletme"
    assert "TR_VERB_FORM" in codes([card], severity="warning")
    assert "TR_VERB_FORM" not in codes([card], severity="error")


@pytest.mark.parametrize(
    "lemma,ipa,warns",
    [("spoon", "/spuːn/", False), ("cheap", "/tʃiːp/", False), ("fridge", "/frɪdʒ/", False),
     ("tired", "/taɪrd/", False), ("button", "/bʌtn̩/", True), ("pillow", "/pɪloʊ/", True),
     ("pillow", "/ˈpɪloʊ/", False)],
)
def test_stress_warning_counts_syllables_not_letters(card, lemma, ipa, warns):
    card["lemma"], card["ipa"] = lemma, {"us": ipa, "uk": None}
    found = {i.code for i in validate_cards([card])[1] if i.field == "ipa.us"}
    assert ("IPA_STRESS" in found) == warns
