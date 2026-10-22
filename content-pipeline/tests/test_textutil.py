import pytest

from vocabpipe.textutil import FOLD_WHITESPACE, contains_phrase, fold, glen, slugify_lemma

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


# Swift TextFoldEdgeTests'teki "Python ile ortak" vektörlerin aynısı. Eskiden iki taraf burada ayrılıyordu.
SHARED_EDGE_VECTORS = [
    # U+001C–U+001F boşluk değil (Unicode White_Space): olduğu gibi kalır, kırpılmaz.
    ("a\x1fb", "a\x1fb"),
    ("a\x1c\x1d\x1eb", "a\x1c\x1d\x1eb"),
    ("\x1f look \x1f", "\x1f look \x1f"),
    ("\x1fa\x1f", "\x1fa\x1f"),
    # Her sigma σ olur: sözcük sonundaki Σ, elle yazılmış ς ve NFKD'nin ϲ/Ϲ'den yaptığı ς.
    ("ΟΔΟΣ", "οδοσ"),
    ("οδος", "οδοσ"),
    ("ΣΑΣ Σ", "σασ σ"),
    ("ϲϹ", "σσ"),
]


@pytest.mark.parametrize("text,expected", SHARED_EDGE_VECTORS)
def test_fold_matches_swift_on_control_characters_and_sigma(text, expected):
    assert fold(text) == expected


def test_fold_whitespace_is_python_whitespace_without_information_separators():
    python_space = {chr(c) for c in range(0x110000) if chr(c).isspace()}
    assert python_space - set(FOLD_WHITESPACE) == {"\x1c", "\x1d", "\x1e", "\x1f"}
    assert set(FOLD_WHITESPACE) <= python_space
    for ch in FOLD_WHITESPACE:
        assert fold(f"a{ch}{ch}b{ch}") == "a b", hex(ord(ch))


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
