# İçerik Veritabanı Sözleşmesi (v1)

Bu belge, içerik hattının (`content-pipeline/`) ürettiği dosyalar ile iOS uygulamasının (`ios/`) okuduğu dosyalar arasındaki **tek doğruluk kaynağıdır**. Bir tarafta yapılan değişiklik önce burada yapılır, `schema_version` artırılır.

## 1. Üretilen dosyalar

| Dosya | Üreten | Okuyan | Not |
|---|---|---|---|
| `content.sqlite` | `python -m vocabpipe.build_db` | Yalnızca uygulama (`ContentStore`) | Uygulama paketine gömülür ve **paketten doğrudan, salt okunur** açılır (GRDB `readonly`). App Group'a kopyalanmaz, çünkü widget veritabanını hiç açmaz. Dosya `journal_mode=DELETE` ile üretilir; WAL olmaz, aksi halde salt okunur açılış başarısız olabilir |
| `seed_words.json` | `python -m vocabpipe.build_db --seed-out` | Widget extension | Uygulama hiç açılmadan eklenen widget boş kalmasın diye widget paketine gömülür |
| `data/id_registry.json` | Hat (yalnızca ekleme) | Hat | `card_id` → kalıcı tam sayı ID eşlemesi. **Git'te tutulur, asla elle düzenlenmez** |

## 2. Kalıcı kimlikler

- `card_id` (metin): `en.<lemma_slug>.<pos>.<sense_no>`. Örnekler: `en.breakfast.n.1`, `en.look_up_to.phv.1`.
  - `lemma_slug` = küçük harf, boşluk ve tire yerine `_`, yalnızca `[a-z0-9_]`.
- `card.rowid` (tam sayı) = `id_registry.json`'daki kalıcı ID. Kullanıcı ilerlemesi (`UserWordProgress.word_id`), widget kuyruğu ve CloudKit senkronu **yalnızca bu tam sayıyı** kullanır.
- **Kural:** Bir ID bir kez verildikten sonra asla başka karta verilmez. Kart silinse bile ID kayıtta kalır (`retired`).

## 3. SQLite şeması (`PRAGMA user_version = 2`)

```sql
CREATE TABLE content_meta (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
-- anahtarlar: schema_version, content_version, built_at, card_count, l1_langs, attribution

CREATE TABLE category (
  id          TEXT PRIMARY KEY,      -- ör. 'phrasal_verbs'
  grp         TEXT NOT NULL,         -- 'A'..'I'
  name_en     TEXT NOT NULL,
  name_tr     TEXT NOT NULL,
  access      TEXT NOT NULL,         -- 'F' ücretsiz | 'S' örneklemeli | 'P' premium
  free_count  INTEGER NOT NULL,      -- bu kategoride ücretsiz olan ilk N kart (F için tümü)
  hero        INTEGER NOT NULL,      -- 1 = vitrin kategorisi
  sort        INTEGER NOT NULL
);

CREATE TABLE card (
  rowid           INTEGER PRIMARY KEY,   -- kalıcı ID (bkz. §2)
  card_id         TEXT NOT NULL UNIQUE,
  lemma           TEXT NOT NULL,
  type            TEXT NOT NULL,         -- word|phrasal_verb|idiom|collocation|proverb|phrase
  pos             TEXT NOT NULL,
  sense_no        INTEGER NOT NULL,
  sense_note      TEXT,
  level           TEXT NOT NULL,         -- A1..C2|S
  level_rank      INTEGER NOT NULL,      -- A1=1 … C2=6, S=7
  freq_rank       INTEGER,
  zipf            REAL,
  ipa_us          TEXT,
  ipa_uk          TEXT,
  def_micro       TEXT NOT NULL,         -- ≤28 grafem: kilit ekranı satır içi/dikdörtgen
  def_short       TEXT NOT NULL,         -- ≤80: küçük/orta widget
  def_long        TEXT NOT NULL,         -- ≤220: büyük widget, uygulama
  example_en      TEXT NOT NULL,         -- 1. örnek (kilit ekranında güvenli)
  primary_topic   TEXT NOT NULL REFERENCES category(id),
  register        TEXT NOT NULL,
  sensitivity     INTEGER NOT NULL,      -- 0 temiz | 1 kişisel konu ya da hafif kaba kelime (bkz. kurallar)
  is_free         INTEGER NOT NULL,      -- 1 = ücretsiz katmanda
  json            TEXT NOT NULL          -- kartın tamamı (detay ekranı için), şema v1.0
);
CREATE INDEX idx_card_level ON card(level_rank, is_free);
CREATE INDEX idx_card_topic ON card(primary_topic);
CREATE INDEX idx_card_free ON card(is_free, sensitivity, level_rank);  -- topics() için (is5-performans); isteğe bağlı

CREATE TABLE card_l1 (
  card_rowid   INTEGER NOT NULL REFERENCES card(rowid),
  lang         TEXT NOT NULL,            -- 'tr'
  gloss        TEXT NOT NULL,            -- ≤28: widget 2. satır
  equivalence  TEXT NOT NULL,            -- full|partial|cognate|false_friend|none
  example_tr   TEXT,                     -- 1. örneğin çevirisi
  gloss_short  TEXT,                     -- ≤16: gloss sığmayınca widget'ta gösterilen kısa anlam; gloss ≤16 ise NULL
  PRIMARY KEY (card_rowid, lang)
);

-- Karışan kelimeler (borrow ↔ lend). İki yönlü: (A,B) varsa (B,A) da var. Yalnız destede kartı olan
-- eşler; kartın kendi listesi (eşi destede olmayanlar dahil) card.json içindeki "confusables" alanında.
CREATE TABLE card_confusable (
  card_rowid   INTEGER NOT NULL REFERENCES card(rowid),
  other_rowid  INTEGER NOT NULL REFERENCES card(rowid),
  PRIMARY KEY (card_rowid, other_rowid)
);

CREATE TABLE card_category (
  card_rowid   INTEGER NOT NULL REFERENCES card(rowid),
  category_id  TEXT NOT NULL REFERENCES category(id),
  is_primary   INTEGER NOT NULL,
  rank         INTEGER NOT NULL,         -- kategori içi sıra (0'dan); is_free hesabında kullanılır
  PRIMARY KEY (card_rowid, category_id)
);
CREATE INDEX idx_cc_cat ON card_category(category_id, rank);

-- Arama: içeriksiz FTS5. rowid = card.rowid. Metinler §4'teki fold() ile normalize edilmiş halde yazılır.
CREATE VIRTUAL TABLE card_fts USING fts5(
  lemma_fold, gloss_fold,
  content='', tokenize='unicode61 remove_diacritics 2'
);
```

**Uygulama tarafı kuralları**
- Veritabanı salt okunurdur; uygulama içine asla yazılmaz. Kullanıcı verisi ayrı bir depodadır.
- `is_free = 0` olan kart, abonelik yoksa widget kuyruğuna girmez ve akışta kilitli olarak gösterilir.
- **Hassasiyet** (`card.sensitivity`, şema 2'den beri; `docs/tasarim/ogrenme_ilkeleri.md` §2.1):
  - `1` = kişisel konu (ilişki, ayrılık, beden, işini ya da parasını kaybetmek) ya da hafif kaba kelime. Kilit ekranını aile ya da iş arkadaşları görebilir; bu kartlar **kilit ekranında ve orta widget'ta varsayılan olarak gösterilmez**, Akış'ta, Tekrar'da ve Sözlük'te kalır. Her kategoride olabilir (şema 1'deki "yalnız etiketli kategoride" kuralı kalktı).
  - `2` veritabanına hiç girmez.
  - Seed yalnız `sensitivity = 0` kartları alır.
- **Kısa anlam** (`card_l1.gloss_short`): Türkçe anlam widget'ta hiçbir zaman "…" ile kesilmez. Sığmazsa sırayla tam `gloss` → ilk virgülden önceki kısım → `gloss_short` denenir; hiçbiri sığmazsa anlam gizlenir. `gloss_short` en çok 16 grafemdir ve kendisi de kesilmez.
- **Karışan kelimeler** (`card_confusable`): iki karışan kelime aynı gün yeni kelime olarak verilmez; eşi henüz bilinmiyorsa (kutu 2'nin altında) quiz'de çeldirici olmaz (`ogrenme_ilkeleri.md` §1 madde 8 ve 1b).
- Kategori içi `rank`, ücretsiz kartları belirler: `rank < category.free_count` ise kart o kategoride ücretsizdir. `card.is_free`, kartın birincil kategorisine göre hesaplanmış sonuçtur.
- **Konu (deste) süzgeci** `card_category` üyeliğini okur, `is_primary` ne olursa olsun: bir kart üyesi olduğu her konuda sayılır ve seçilen konulardan birinde olması yeter (birden çok seçilen konuda olan kart bir kez gelir). Konu sayımına yalnız `is_free = 1 AND sensitivity = 0` kartlar girer. Akış sorgusu (`freeCards`) `card_category` ile birleştirilmez, yoksa kartlar tekrarlanır. Grup başlıkları (`category.grp` harfinin Türkçe adı) ve bazı sade görünen adlar (ör. `phrasal_verbs` → "İki kelimeli fiiller") veritabanında değil, uygulamada durur; `category.name_tr` değişmez. Şema değişmedi, `schema_version` artmaz.

## 4. Arama normalizasyonu: `fold()`

Swift ve Python **aynı** algoritmayı uygular. Sorgu da aynı fonksiyondan geçirilir.

1. Unicode NFC.
2. Harf eşlemesi (büyük/küçük harfe çevirmeden ÖNCE): `ı→i, İ→i, I→i, ç/Ç→c, ğ/Ğ→g, ö/Ö→o, ş/Ş→s, ü/Ü→u, â/Â→a, î/Î→i, û/Û→u`.
3. Küçük harf (locale bağımsız; Türkçe harfler 2. adımda zaten çözüldü).
4. NFKD + birleşik işaretleri (combining marks) at.
5. Ardışık boşlukları tek boşluğa indir, baştaki ve sondaki boşlukları kırp.

Test vektörleri (iki tarafın birim testlerinde aynısı olmalı):

| Girdi | Çıktı |
|---|---|
| `Çiçek` | `cicek` |
| `IŞIK` | `isik` |
| `İstanbul` | `istanbul` |
| `hâlsiz bırakmak` | `halsiz birakmak` |
| `  Look  Up To ` | `look up to` |
| `naïve` | `naive` |

## 5. `seed_words.json` (widget paketi)

```json
{
  "schema_version": 2,
  "content_version": "2026.10.11-1",
  "words": [
    {
      "id": 101,
      "lemma": "resilient",
      "pos": "adj",
      "level": "C1",
      "ipa_us": "/rɪˈzɪliənt/",
      "def_micro": "quick to recover",
      "def_short": "able to recover quickly after something difficult",
      "example_en": "Children are often more resilient than adults.",
      "gloss_tr": "dirençli, çabuk toparlanan",
      "gloss_short_tr": "dirençli"
    }
  ]
}
```

- Yalnızca `is_free = 1` ve `sensitivity = 0` kartlar girer. A1–C1 seviyeleri sırayla dönüşümlü seçilir, varsayılan 400 kart.
- `gloss_short_tr` her kelimede vardır, anlam kısaysa `null`'dır (şema 2).
- Widget belleği (~30 MB sınırı) için dosya **< 300 KB** tutulur.

## 6. Widget anlık görüntüsü ve olay posta kutusu (App Group)

Bu bölüm uygulama ile widget arasındaki sözleşmedir; içerik hattını ilgilendirmez.

**Temel kural: her dosyanın tek bir yazanı vardır.** Uygulama ve widget ayrı süreçlerdir; aynı dosyaya iki taraf yazarsa veri yarışı ve `0xDEAD10CC` çökmeleri olur. Paylaşılan, yazılabilir bir SQLite kullanılmaz.

| Dosya | Yazan | Okuyan |
|---|---|---|
| `widget_plan.json` | **Yalnızca uygulama** | Widget |
| `widget_state.json` | **Yalnızca widget** (intent'ler dahil) | Widget + uygulama |
| `events/*.json` | **Yalnızca widget** (her olay yeni bir dosya) | Uygulama (okur, işler, siler) |

- `widget_plan.json` (atomik yazma, dosya koruması `.completeUntilFirstUserAuthentication`):
  `{ "version":1, "plan_id":String, "is_premium":Bool, "interval_seconds":Int, "queue":[WidgetWord], "updated_at":ISO8601 }`
  - `queue`: uygulamanın SRS'e ve filtrelere göre seçtiği sonraki 48–96 kelime. Widget veritabanı açmaz, yalnızca bu kuyruğu okur.
  - `plan_id`: uygulama her yeni plan yazdığında değişir (UUID). Widget, `widget_state.plan_id` farklıysa imlecini sıfırlar.
  - `WidgetWord` = `{ "id":Int, "lemma":String, "pos":String, "level":String, "ipa_us":String?, "def_micro":String, "def_short":String, "example_en":String, "gloss_tr":String?, "gloss_short_tr":String?, "sensitivity":Int?, "confusable_ids":[Int]? }`.
    - İlk dokuz alan ve `gloss_short_tr` seed ile aynıdır.
    - `sensitivity` (`card.sensitivity`) ve `confusable_ids` (`card_confusable.other_rowid`) yalnız veritabanından gelir; seed'de yoktur.
    - Şema 2'de eklenen alanların hepsi opsiyoneldir: yoksa ya da `null` ise eski JSON da çözülür. Swift'te `glossShortTR`, `sensitivity`, `isSensitive`, `confusableIDs`.
- `widget_state.json` (widget yazar, atomik):
  `{ "version":1, "plan_id":String, "cursor_offset":Int, "cursor_anchor":ISO8601, "known_ids":[Int], "updated_at":ISO8601 }`
  - Anlamı: `cursor_anchor` anında döngü kuyruğun `cursor_offset` indeksindeydi.
  - "Sonraki" (kelime W, zaman t): `cursor_offset = index(W)+1`, `cursor_anchor = t`.
  - "Biliyorum" (W, t): `known_ids += W`, `cursor_offset = index(W)`, `cursor_anchor = t`; W atlanır, sıradaki bilinmeyen kelime gösterilir.
  - Uygulama yeni plan yazınca bu dosya anlamsızlaşır (`plan_id` farklıdır), çünkü yeni plan bilinen kelimeleri zaten içermez ve widget'ın o an gösterdiği kelimeden başlar.

**Döngü algoritması (tek saf fonksiyon: `Scheduler.TimelinePlanner`; widget ve uygulama aynı kodu kullanır).** Amaç: zaman çizelgesi yeniden yüklense de, plan yeniden yazılsa da widget tekrar başa dönmesin.

1. Aralık **globaldir**: `step = max(plan.interval_seconds, 300)`. Tüm widget örnekleri (ana ekran + kilit ekranı) aynı anda aynı kelimeyi gösterir. Plan yoksa (seed) `step = 3600`.
2. Taban `(b, d)`: `plan_id`'si eşleşen durum varsa `b = cursor_offset`, `d = cursor_anchor`. Yoksa `b = 0`, `d = plan.updated_at`. Seed için `d = 2026-01-01T00:00:00Z` (sabit), böylece seed kelimeleri de zamanla belirleyici şekilde döner.
3. `R` = kuyruğun `b` indeksinden başlayan bir turu, `known_ids` çıkarılmış.
4. `sınır(t) = floor((t + yerel_UTC_farkı) / step)`; `geçen(d, t) = max(0, sınır(t) − sınır(d))`. Yerel fark, günlük aralığın yerel gece yarısına denk gelmesi içindir.
5. `t` anında gösterilen kelime = `R[geçen(d, t) mod |R|]`. Zaman çizelgesi girişleri: `[şimdi, sonraki her sınır…]`, i. giriş = `R[(geçen(d, şimdi) + i) mod |R|]`.
6. Uygulama planı yeniden yazarken önce **eski** plan ve durumla `t = şimdi` için gösterilen kelimeyi hesaplar, yeni kuyruğu o kelimeyle başlatır ve `updated_at = şimdi` yazar.
- `events/` klasörü: her olay ayrı bir dosya, adı `<unix_ms>-<uuid>.json`, içeriği:
  `{ "type":"next|known|unknown|reveal", "word_id":Int, "at":ISO8601, "source":"system_small|system_medium|accessory_rectangular|accessory_inline" }`.
  Uygulama ön plana gelince olayları işler (SRS'e "bildi/bilmedi" olarak), dosyaları siler, yeni `widget_plan.json` yazar ve `WidgetCenter.reloadAllTimelines()` çağırır.

## 7. Sürüm geçmişi

| Sürüm | Tarih | Değişiklik |
|---|---|---|
| 1 | 2026-10-11 | İlk sürüm |
| 1.1 | 2026-10-11 | Kod incelemesi sonrası: tek yazan kuralı; `cursor_anchor` ve zamana bağlı döngü algoritması (yeniden yüklemede tekrar başa dönme hatası giderildi); global döngü aralığı; veritabanı App Group'a kopyalanmadan paketten açılır; `journal_mode=DELETE` |
| 2 | 2026-10-22 | `card_l1.gloss_short` ve seed'de `gloss_short_tr` (widget'ta kesilmeyen kısa anlam); yeni `card_confusable` tablosu; `sensitivity = 1`'in yeni anlamı (kişisel konu, kilit ekranı ve orta widget'ta varsayılan olarak gizli, her kategoride olabilir); `WidgetWord`'e opsiyonel `gloss_short_tr`, `sensitivity`, `confusable_ids`. Eski okuyucular bozulmaz: yalnız sütun, tablo ve opsiyonel alan eklendi. `user_version` ve seed `schema_version` 2 |
