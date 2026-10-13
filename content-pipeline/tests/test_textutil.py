import pytest

from vocabpipe.textutil import contains_phrase, fold, glen, slugify_lemma

# docs/contract/content-db.md §4 ile birebir aynı olmalı (Swift TextFold testleri de aynısını kullanır).
CONTRACT_VECTORS = [
    ("Çiçek", "cicek"),
    ("IŞIK", "isik"),
    ("İstanbul", "istanbul"),
    ("hâlsiz bırakmak", "halsiz birakmak"),
    ("  Look  Up To ", "look up to"),
    ("naïve", "naive"),
]


@pytest.mark.parametrize("text,expected", CONTRACT_VECTORS)
def test_fold_contract_vectors(text, expected):
    assert fold(text) == expected


def test_fold_turkish_case_variants_meet():
    assert fold("DİRENÇLİ") == fold("dirençli") == fold("direncli") == "direncli"
    assert fold("ılık") == fold("ILIK") == "ilik"


def test_glen_counts_graphemes_not_code_points():
    decomposed = "é"  # é = e + birleşik vurgu
    assert glen(decomposed) == 1
    assert glen("/rɪˈzɪliənt/") == len("/rɪˈzɪliənt/")


def test_contains_phrase_respects_word_boundaries():
    assert contains_phrase("We must mitigate the risk.", "mitigate")
    assert not contains_phrase("a remitigated plan", "mitigate")
    assert contains_phrase("I've always looked up to her.", "looked up to")
    assert not contains_phrase("anything", "")


@pytest.mark.parametrize(
    "lemma,slug",
    [("look up to", "look_up_to"), ("break the ice", "break_the_ice"), ("well-being", "well_being"), ("o'clock", "oclock")],
)
def test_slugify(lemma, slug):
    assert slugify_lemma(lemma) == slug
