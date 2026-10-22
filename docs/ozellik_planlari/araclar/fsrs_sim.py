"""Lockglow: Leitner ile FSRS-6'yı karşılaştıran basit simülasyon.

Kurulum: 1.000 kelime, günde 10 yeni kelime, 90 gün (90 günde 900 kelime
tanıtılır). Her gün aynı saatte (09:00) tek bir Tekrar oturumu olur: zamanı
gelen bütün kelimeler sorulur, sonra 10 yeni kelime gelir. Oturum içinde
"Bilemedim" denen kelime 10 dakika sonra yeniden sorulur (Leitner.relearnDelay).
Oturumun 2 saatlik penceresine sığmayan bir tarih (Leitner'de "Zor" = 12 saat)
ertesi günün oturumuna kalır.

Öğrencinin "gerçek" hafızası FSRS-6'nın varsayılan parametreleriyle modellenir;
fsrs-rs'in ve Anki'nin simülatörü de böyle yapar. Bu FSRS'i kayırır: unutma
hızı 1 iken FSRS'in tahmini tanım gereği doğrudur. Bu yüzden öğrencinin
modelden 3 kat hızlı ya da 2 kat yavaş unuttuğu
durumlar da koşulur: öğrenci için geçen süre bu katsayıyla çarpılır.

Cevap olasılıkları fsrs-rs SimulatorConfig varsayılanlarından (Anki
kullanıcılarının ortalaması): ilk görüşte Bilemedim/Zor/Bildim/Kolay =
0,24/0,094/0,495/0,171; doğru hatırlanan tekrarda Zor/Bildim/Kolay =
0,224/0,631/0,145.

Kullanım (depo kökünden):
    python -X utf8 docs/ozellik_planlari/araclar/fsrs_sim.py             # rapor tabloları
    python -X utf8 docs/ozellik_planlari/araclar/fsrs_sim.py --dogrula   # resmî test değerleri
    python -X utf8 docs/ozellik_planlari/araclar/fsrs_sim.py --tohum 50  # daha çok tekrar

FSRS sınıfı py-fsrs v6.3.2'nin `fsrs/scheduler.py` dosyasının bulanıklaştırma
(fuzz) olmadan Python karşılığıdır:
https://github.com/open-spaced-repetition/py-fsrs/blob/v6.3.2/fsrs/scheduler.py
Aynı hesap `ios/Packages/VocabKit/Sources/Learning/FSRS.swift` içinde Swift'e
taşındı; `--dogrula` iki uygulamanın da tuttuğu resmî test değerlerini dener.
"""

from __future__ import annotations

import argparse
import math
import random
import statistics
import sys
from dataclasses import dataclass, field

AGAIN, HARD, GOOD, EASY = 1, 2, 3, 4
MINUTE = 1 / 1440  # gün cinsinden

# FSRS-6 varsayılanları (py-fsrs DEFAULT_PARAMETERS, fsrs-rs v6.6.2 DEFAULT_PARAMETERS).
DEFAULT_W = (
    0.212, 1.2931, 2.3065, 8.2956, 6.4133, 0.8334, 3.0194, 0.001, 1.8722, 0.1666,
    0.796, 1.4835, 0.0614, 0.2629, 1.6483, 0.6014, 1.8729, 0.5425, 0.0912, 0.0658,
    0.1542,
)
S_MIN = 0.001
D_MIN, D_MAX = 1.0, 10.0

LEARNING, REVIEW, RELEARNING = "learning", "review", "relearning"


@dataclass
class Card:
    state: str = LEARNING
    step: int | None = 0
    s: float | None = None
    d: float | None = None
    due: float = 0.0
    last: float | None = None


class FSRS:
    """FSRS-6 bellek modeli ve zamanlayıcı (py-fsrs Scheduler, fuzz yok)."""

    def __init__(
        self,
        w=DEFAULT_W,
        desired_retention=0.9,
        learning_steps=(10 * MINUTE,),
        relearning_steps=(10 * MINUTE,),
        maximum_interval=36500,
    ):
        w = tuple(w)
        if len(w) == 19:  # FSRS-5: kısa süreli w19 = 0, bozunma 0,5 (fsrs-rs check_and_fill_parameters)
            w = w + (0.0, 0.5)
        assert len(w) == 21
        self.w = w
        self.desired_retention = desired_retention
        self.learning_steps = tuple(learning_steps)
        self.relearning_steps = tuple(relearning_steps)
        self.maximum_interval = maximum_interval
        self.decay = -w[20]
        self.factor = 0.9 ** (1 / self.decay) - 1

    # --- bellek modeli ---
    def retrievability(self, elapsed_days: float, s: float) -> float:
        return (1 + self.factor * elapsed_days / s) ** self.decay

    def raw_interval(self, s: float, r: float | None = None) -> float:
        r = self.desired_retention if r is None else r
        return s / self.factor * (r ** (1 / self.decay) - 1)

    def interval_days(self, s: float) -> int:
        return min(max(round(self.raw_interval(s)), 1), self.maximum_interval)

    def init_s(self, g: int) -> float:
        return max(self.w[g - 1], S_MIN)

    def init_d(self, g: int, clamp: bool = True) -> float:
        d = self.w[4] - math.exp(self.w[5] * (g - 1)) + 1
        return min(max(d, D_MIN), D_MAX) if clamp else d

    def next_d(self, d: float, g: int) -> float:
        delta = -self.w[6] * (g - 3)
        damped = d + (10 - d) * delta / 9
        reverted = self.w[7] * self.init_d(EASY, clamp=False) + (1 - self.w[7]) * damped
        return min(max(reverted, D_MIN), D_MAX)

    def short_term_s(self, s: float, g: int) -> float:
        sinc = math.exp(self.w[17] * (g - 3 + self.w[18])) * s ** -self.w[19]
        if g >= HARD:
            sinc = max(sinc, 1.0)
        return max(s * sinc, S_MIN)

    def recall_s(self, d: float, s: float, r: float, g: int) -> float:
        hard = self.w[15] if g == HARD else 1
        easy = self.w[16] if g == EASY else 1
        return s * (
            1
            + math.exp(self.w[8]) * (11 - d) * s ** -self.w[9]
            * (math.exp((1 - r) * self.w[10]) - 1) * hard * easy
        )

    def forget_s(self, d: float, s: float, r: float) -> float:
        long_term = (
            self.w[11] * d ** -self.w[12] * ((s + 1) ** self.w[13] - 1)
            * math.exp((1 - r) * self.w[14])
        )
        return min(long_term, s / math.exp(self.w[17] * self.w[18]))

    def next_state(self, state, elapsed_days: int, g: int, r: float | None = None):
        """fsrs-rs `step`: (s, d) ve tam gün sayısı -> yeni (s, d). İlk cevapta state None.

        `r` verilirse hatırlama olasılığı olarak o kullanılır (simülasyondaki öğrenci için).
        """
        if state is None:
            return self.init_s(g), self.init_d(g)
        s, d = state
        if elapsed_days < 1:
            new_s = self.short_term_s(s, g)
        else:
            r = self.retrievability(elapsed_days, s) if r is None else r
            new_s = self.forget_s(d, s, r) if g == AGAIN else self.recall_s(d, s, r, g)
        return max(new_s, S_MIN), self.next_d(d, g)

    # --- zamanlayıcı (py-fsrs Scheduler.review_card) ---
    def review(self, card: Card, g: int, now: float) -> Card:
        c = Card(card.state, card.step, card.s, card.d, card.due, card.last)
        days = None if c.last is None else math.floor(now - c.last + 1e-9)
        if c.s is None:
            c.s, c.d = self.init_s(g), self.init_d(g)
        else:
            c.s, c.d = self.next_state((c.s, c.d), days, g)

        if c.state == REVIEW:
            if g == AGAIN and self.relearning_steps:
                c.state, c.step = RELEARNING, 0
                interval = self.relearning_steps[0]
            else:
                interval = self.interval_days(c.s)
        else:
            steps = self.learning_steps if c.state == LEARNING else self.relearning_steps
            if not steps or (c.step >= len(steps) and g != AGAIN):
                c.state, c.step = REVIEW, None
                interval = self.interval_days(c.s)
            elif g == AGAIN:
                c.step = 0
                interval = steps[0]
            elif g == HARD:
                if c.step == 0 and len(steps) == 1:
                    interval = steps[0] * 1.5
                elif c.step == 0:
                    interval = (steps[0] + steps[1]) / 2
                else:
                    interval = steps[c.step]
            elif g == GOOD and c.step + 1 < len(steps):
                c.step += 1
                interval = steps[c.step]
            else:  # son adımda Good ya da Easy: tekrar durumuna geçer
                c.state, c.step = REVIEW, None
                interval = self.interval_days(c.s)
        c.due = now + interval
        c.last = now
        return c


# --- Leitner (ios/Packages/VocabKit/Sources/Learning/Leitner.swift, main 29797b4) ---
NEW, KNOWN = "new", "known"


@dataclass
class LeitnerWord:
    state: str = NEW
    box: int = 0
    due: float | None = None
    refreshes: int = 0  # art arda doğru tazeleme sayısı (yalnız büyüyen tazelemede)


class Leitner:
    INTERVALS = (1, 2, 4, 8, 16)
    RELEARN = 10 * MINUTE
    REFRESHER = 30
    HARD_FACTOR = 0.5
    GROWING_REFRESHERS = (30, 60, 120)

    def __init__(self, kayma: bool = False, growing_refresher: bool = False):
        # kayma=True: is3-tekrar dalındaki kural (7900e0d): yanlışta en çok iki kutu
        # iner (kutu max(1, k - 2)), yanlış tazeleme kutu 3'e iner.
        # growing_refresher=True: ogrenme_ilkeleri.md 2.3 önerisi (kodda yok): tazeleme
        # her doğru cevapta uzar, 30 -> 60 -> 120 gün; yanlışta baştan başlar.
        self.kayma = kayma
        self.growing = growing_refresher

    def refresher(self, p: LeitnerWord) -> float:
        if not self.growing:
            return self.REFRESHER
        return self.GROWING_REFRESHERS[min(p.refreshes, len(self.GROWING_REFRESHERS) - 1)]

    def review(self, p: LeitnerWord, g: int, now: float) -> LeitnerWord:
        p = LeitnerWord(p.state, p.box, p.due, p.refreshes)
        if g == AGAIN:
            if self.kayma:
                p.box = 3 if p.state == KNOWN else max(1, p.box - 2)
            else:
                p.box = 1
            p.state = LEARNING
            p.refreshes = 0
            p.due = now + self.RELEARN
        elif g == HARD:
            if p.state == KNOWN:
                p.due = now + self.refresher(p) * self.HARD_FACTOR
            else:
                p.box = max(p.box, 1)
                p.state = LEARNING
                p.due = now + self.INTERVALS[p.box - 1] * self.HARD_FACTOR
        else:
            boxes = 2 if g == EASY else 1
            if p.state == KNOWN:
                p.refreshes += 1
                p.due = now + self.refresher(p)
            elif p.box >= len(self.INTERVALS):
                p.state = KNOWN
                p.due = now + self.refresher(p)
            else:
                p.box = min(max(p.box, 0) + boxes, len(self.INTERVALS))
                p.state = LEARNING
                p.due = now + self.INTERVALS[p.box - 1]
        return p


# --- öğrenci ---
FIRST_RATING_P = (0.24, 0.094, 0.495, 0.171)  # fsrs-rs SimulatorConfig.first_rating_prob
REVIEW_RATING_P = (0.224, 0.631, 0.145)       # fsrs-rs SimulatorConfig.review_rating_prob


class Student:
    """Gerçek hafıza: varsayılan FSRS-6. Geçen süre `forgetting` ile çarpılır."""

    def __init__(self, rng: random.Random, forgetting: float):
        self.rng = rng
        self.k = forgetting
        self.model = FSRS()
        self.memory: dict[int, tuple[float, float, float]] = {}  # kelime -> (s, d, son cevap)

    def answer(self, word: int, now: float) -> tuple[int, float | None]:
        """Notu ve (tekrar ise) cevap anındaki gerçek hatırlama olasılığını döndürür."""
        if word not in self.memory:
            g = self.rng.choices((AGAIN, HARD, GOOD, EASY), FIRST_RATING_P)[0]
            s, d = self.model.next_state(None, 0, g)
            self.memory[word] = (s, d, now)
            return g, None
        s, d, last = self.memory[word]
        # Unutma hızı yalnız hatırlama olasılığını değiştirir; "aynı gün mü" kararı gerçek
        # güne bakar (yoksa 0,5 hızda 1 günlük aralık aynı gün sayılırdı).
        r = self.model.retrievability((now - last) * self.k, s)
        if self.rng.random() < r:
            g = self.rng.choices((HARD, GOOD, EASY), REVIEW_RATING_P)[0]
        else:
            g = AGAIN
        s, d = self.model.next_state((s, d), math.floor(now - last + 1e-9), g, r)
        self.memory[word] = (s, d, now)
        return g, r

    def recall(self, now: float) -> list[float]:
        return [
            self.model.retrievability((now - last) * self.k, s)
            for s, _, last in self.memory.values()
        ]


# --- simülasyon ---
SESSION_HOUR = 9 / 24
SESSION_WINDOW = 2 / 24


@dataclass
class Result:
    name: str
    reviews: list[int] = field(default_factory=list)   # zamanı gelen tekrar (günün ilk sorusu)
    repeats: list[int] = field(default_factory=list)   # aynı gün yeniden sorma
    new: list[int] = field(default_factory=list)
    correct: int = 0
    asked: int = 0
    recall_end: float = 0.0       # 90. gün sonunda tanıtılan kelimelerin ortalama hatırlama olasılığı
    remembered_end: float = 0.0   # aynı anda hatırlanması beklenen kelime sayısı


def simulate(policy: str, seed: int, *, forgetting=1.0, retention=0.9, words=1000,
             new_per_day=10, days=90) -> Result:
    rng = random.Random(seed)
    student = Student(rng, forgetting)
    fsrs = FSRS(desired_retention=retention)
    leitner = Leitner(kayma=policy in ("leitner_kayma", "leitner_buyuyen"),
                      growing_refresher=(policy == "leitner_buyuyen"))
    cards: dict[int, object] = {}
    res = Result(policy)
    next_word = 0
    for day in range(days):
        start = day + SESSION_HOUR
        end = start + SESSION_WINDOW
        reviews = repeats = 0
        asked_today: set[int] = set()
        new_today = []
        while len(new_today) < new_per_day and next_word < words:
            new_today.append(next_word)
            next_word += 1
        # Önce zamanı gelenler, sonra yeni kelimeler; oturum içi tekrarlar tarih sırasıyla.
        queue = [(c.due, w) for w, c in cards.items() if c.due is not None and c.due <= start + 1e-9]
        queue.sort()
        queue += [(start, w) for w in new_today]
        while queue:
            due, w = queue.pop(0)
            now = max(start, due)
            g, r = student.answer(w, now)
            if w in new_today and w not in cards:
                cards[w] = Card() if policy == "fsrs" else LeitnerWord()
            elif w in asked_today:
                repeats += 1
            else:
                reviews += 1
                res.asked += 1
                res.correct += g != AGAIN
            asked_today.add(w)
            cards[w] = fsrs.review(cards[w], g, now) if policy == "fsrs" else leitner.review(cards[w], g, now)
            if cards[w].due <= end:
                queue.append((cards[w].due, w))
                queue.sort()
        res.reviews.append(reviews)
        res.repeats.append(repeats)
        res.new.append(len(new_today))
    recall = student.recall(days + SESSION_HOUR)
    res.recall_end = sum(recall) / len(recall)
    res.remembered_end = sum(recall)
    return res


def summarize(runs: list[Result]) -> dict[str, float]:
    def mean(f):
        return statistics.mean(f(r) for r in runs)

    return {
        "tekrar_gun": mean(lambda r: statistics.mean(r.reviews)),
        "tekrar_son30": mean(lambda r: statistics.mean(r.reviews[-30:])),
        "tekrar_tepe": mean(lambda r: max(r.reviews)),
        "ayni_gun": mean(lambda r: statistics.mean(r.repeats)),
        "cevap_gun": mean(lambda r: statistics.mean(
            [a + b + c for a, b, c in zip(r.reviews, r.repeats, r.new)])),
        "dogru": mean(lambda r: r.correct / r.asked),
        "hatirlama": mean(lambda r: r.recall_end),
        "hatirlanan": mean(lambda r: r.remembered_end),
        "toplam_cevap": mean(lambda r: sum(r.reviews) + sum(r.repeats) + sum(r.new)),
        # tohumlar arası standart sapma
        "tekrar_gun_sd": statistics.stdev(statistics.mean(r.reviews) for r in runs) if len(runs) > 1 else 0,
        "hatirlama_sd": statistics.stdev(r.recall_end for r in runs) if len(runs) > 1 else 0,
    }


POLICIES = (
    ("leitner", "Leitner (main)"),
    ("leitner_kayma", "Leitner + iki kutu düşme (is3-tekrar)"),
    ("leitner_buyuyen", "Leitner + iki kutu düşme + tazeleme 30/60/120 gün (öneri)"),
    ("fsrs", "FSRS-6, hedef 0,90"),
)


def table(seeds: int, forgetting: float, days: int = 90) -> list[tuple[str, dict[str, float]]]:
    rows = []
    for policy, label in POLICIES:
        runs = [simulate(policy, s, forgetting=forgetting, days=days) for s in range(seeds)]
        rows.append((label, summarize(runs)))
    return rows


def sweep(seeds: int, forgetting: float, retentions, days: int = 90) -> list[tuple[float, dict[str, float]]]:
    return [
        (dr, summarize([simulate("fsrs", s, forgetting=forgetting, retention=dr, days=days)
                        for s in range(seeds)]))
        for dr in retentions
    ]


def fmt(x: float, digits: int = 1) -> str:
    return f"{x:.{digits}f}".replace(".", ",")


def print_rows(rows):
    print("| Yöntem | Tekrar/gün (ortalama) | Tekrar/gün (son 30 gün) | En yoğun gün | Aynı gün yeniden | Tekrarda doğru | Sondaki hatırlama | Hatırlanan kelime | Toplam cevap |")
    print("|---|---|---|---|---|---|---|---|---|")
    for label, m in rows:
        print(
            f"| {label} | {fmt(m['tekrar_gun'])} | {fmt(m['tekrar_son30'])} | {fmt(m['tekrar_tepe'], 0)} | "
            f"{fmt(m['ayni_gun'])} | %{fmt(100 * m['dogru'])} | %{fmt(100 * m['hatirlama'])} | "
            f"{fmt(m['hatirlanan'], 0)} | {fmt(m['toplam_cevap'], 0)} |"
        )


def print_sweep(points):
    print("| FSRS hedefi | Tekrar/gün (ortalama) | Tekrar/gün (son 30 gün) | Tekrarda doğru | Sondaki hatırlama | Hatırlanan kelime |")
    print("|---|---|---|---|---|---|")
    for dr, m in points:
        print(
            f"| {fmt(dr, 2)} | {fmt(m['tekrar_gun'])} | {fmt(m['tekrar_son30'])} | %{fmt(100 * m['dogru'])} | "
            f"%{fmt(100 * m['hatirlama'])} | {fmt(m['hatirlanan'], 0)} |"
        )


# --- resmî test değerleriyle doğrulama ---
def verify() -> bool:
    ok = True

    def check(name, got, want, tol=0.0):
        nonlocal ok
        good = got == want if tol == 0 else abs(got - want) <= tol
        ok &= good
        print(f"{'TAMAM' if good else 'HATA '} {name}: {got} (beklenen {want})")

    # py-fsrs tests/test_basic.py::test_review_card (adımlar 1 dk, 10 dk; yeniden öğrenme 10 dk).
    f = FSRS(learning_steps=(MINUTE, 10 * MINUTE), relearning_steps=(10 * MINUTE,))
    card, now, history = Card(), 0.0, []
    for g in (GOOD,) * 6 + (AGAIN, AGAIN) + (GOOD,) * 5:
        card = f.review(card, g, now)
        history.append(math.floor(card.due - card.last + 1e-9))
        now = card.due
    check("py-fsrs test_review_card", history, [0, 2, 11, 46, 163, 498, 0, 0, 2, 4, 7, 12, 21])

    # py-fsrs test_memo_state ve fsrs-rs test_memory_state: S = 53,62691, D = 6,3574867.
    card, now = Card(), 0.0
    for g, ivl in zip((AGAIN,) + (GOOD,) * 5, (0, 0, 1, 3, 8, 21)):
        now += ivl
        card = f.review(card, g, now)
    check("test_memo_state S", round(card.s, 5), 53.62691, 1e-4)
    check("test_memo_state D", round(card.d, 7), 6.3574867, 1e-4)

    # fsrs-rs test_next_interval: S = 1, hedef 0,1 ... 1,0. fsrs-rs 32 bit (f32) hesaplıyor; 0,1'deki
    # 3.116.766 burada 64 bitle 3.116.769 çıkar (fark milyonda 1), o yüzden göreli tolerans.
    want = [3116766, 34793, 2508, 387, 90, 27, 9, 3, 1, 1]
    for i, w in zip(range(1, 11), want):
        got = max(round(FSRS(desired_retention=i / 10).raw_interval(1.0)), 1)
        check(f"fsrs-rs test_next_interval {i / 10}", got, w, 1e-5 * w)

    # fsrs-rs test_next_states: FSRS-5 parametreleri (19 sayı), geçmiş (1,0) (3,1) (3,3) (3,8), sonra 21 gün.
    w5 = (0.6845422, 1.6790825, 4.7349424, 10.042885, 7.4410233, 0.64219797, 1.071918, 0.0025195254,
          1.432437, 0.1544, 0.8692766, 2.0696752, 0.0953, 0.2975, 2.4691248, 0.19542035, 3.201072,
          0.18046261, 0.121442534)
    f5 = FSRS(w=w5)
    state = None
    for g, dt in ((AGAIN, 0), (GOOD, 1), (GOOD, 3), (GOOD, 8)):
        state = f5.next_state(state, dt, g)
    want = {AGAIN: (2.9691455, 8.000659), HARD: (17.091452, 7.6913934),
            GOOD: (31.722992, 7.382128), EASY: (71.7502, 7.0728626)}
    for g, (ws, wd) in want.items():
        s, d = f5.next_state(state, 21, g)
        check(f"fsrs-rs test_next_states S[{g}]", round(s, 5), ws, 1e-3)
        check(f"fsrs-rs test_next_states D[{g}]", round(d, 6), wd, 1e-4)
    check("fsrs-rs next_interval(121.01552)", round(f5.raw_interval(121.01552), 4), 121.01551, 1e-3)
    return ok


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--dogrula", action="store_true", help="resmî test değerlerini dene")
    ap.add_argument("--tohum", type=int, default=20, help="kaç rastgele tohumun ortalaması (varsayılan 20)")
    args = ap.parse_args(argv)
    if args.dogrula:
        return 0 if verify() else 1
    # FSRS-6'nın eğrisi çok yatık: süreyi 1,5 katına çıkarmak FSRS'in %90 dediği anı yalnız %87'ye
    # indirir. 3 kat, varsayılan parametrelerin bu öğrenciye hiç uymadığı durumdur (%90 yerine %81).
    for k, label in ((1.0, "modelle aynı hızda"), (3.0, "3 kat hızlı"), (0.5, "2 kat yavaş")):
        r_at_s = FSRS().retrievability(k, 1.0)
        print(f"\n### 90 gün; öğrenci {label} unutuyor (unutma hızı {fmt(k, 2)}: FSRS'in %90 dediği "
              f"anda gerçek hatırlama %{fmt(100 * r_at_s)}), {args.tohum} tohum ortalaması\n")
        rows = table(args.tohum, k)
        print_rows(rows)
        sd = max(m["tekrar_gun_sd"] for _, m in rows), max(m["hatirlama_sd"] for _, m in rows)
        print(f"\nTohumlar arası standart sapma en çok: tekrar/gün ±{fmt(sd[0], 2)}, "
              f"sondaki hatırlama ±{fmt(100 * sd[1], 2)} puan.")
        print()
        print_sweep(sweep(args.tohum, k, (0.70, 0.75, 0.80, 0.85, 0.90, 0.95)))
    print(f"\n### Uzun vade: 365 gün (1.000 kelimenin hepsi 100. güne kadar tanıtılır), unutma hızı 1, "
          f"{args.tohum} tohum ortalaması\n")
    print_rows(table(args.tohum, 1.0, days=365))
    print()
    print_sweep(sweep(args.tohum, 1.0, (0.85, 0.90, 0.95), days=365))
    return 0


if __name__ == "__main__":
    sys.exit(main())
