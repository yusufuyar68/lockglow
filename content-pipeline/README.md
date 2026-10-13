# İçerik hattı (`vocabpipe`)

Kelime kartlarını üretir, doğrular, insan denetiminden geçirir ve uygulamanın okuyacağı `content.sqlite` + widget için `seed_words.json` dosyalarını derler.

- Veri sözleşmesi: [`../docs/contract/content-db.md`](../docs/contract/content-db.md)
- İçerik kuralları ve kategoriler: [`../raporlar/07_icerik_stratejisi.md`](../raporlar/07_icerik_stratejisi.md)

## Kurulum

```bash
cd content-pipeline
python -m pip install -e ".[dev]"
python -m pytest
```

Python 3.11+ gerekir. API anahtarı yalnızca gerçek üretim için gerekir (`ANTHROPIC_API_KEY` ortam değişkeni ya da `ant auth login`). Doğrulama, paketleme, testler ve `--dry-run` anahtarsız çalışır.

## Akış

```
plans/*.csv ──prepare──▶ runs/<run>/ ──A──▶ İngilizce çekirdek ──B──▶ Türkçe katman → taslak + deterministik doğrulama
                                        ──C──▶ eleştirmen kararı ──review export/apply──▶ content/cards/*.json ──build_db──▶ content.sqlite + seed_words.json
```

| Adım | Komut |
|---|---|
| 1. Planı hazırla | `python -m vocabpipe.generate prepare plans/pilot_50.csv --run pilot1` |
| 2. Maliyeti gör (API'ye gitmez) | `python -m vocabpipe.generate submit --run pilot1 --stage a --dry-run` |
| 3. A: İngilizce çekirdek | `… submit --run pilot1 --stage a` → `… collect --run pilot1 --stage a --wait` |
| 4. B: Türkçe katman (+ taslak ve doğrulama) | `… submit --run pilot1 --stage b` → `… collect --run pilot1 --stage b --wait` |
| 5. C: Eleştirmen | `… submit --run pilot1 --stage c` → `… collect --run pilot1 --stage c --wait` |
| 6. Durum | `python -m vocabpipe.generate status --run pilot1` |
| 7. İnsan denetimi | `python -m vocabpipe.review export --run pilot1 --out review/pilot1.csv`, tabloda `decision` sütununu doldur, ardından `python -m vocabpipe.review apply --run pilot1 --csv review/pilot1.csv --reviewer "Ad Soyad"` |
| 8. Derle | `python -m vocabpipe.build_db ../content/cards --out build/content.sqlite --seed-out build/seed_words.json` |
| Elle doğrulama | `python -m vocabpipe.validate ../content/cards` |

Yeniden çalıştırma güvenlidir: tamamlanmış kartlar tekrar gönderilmez, para boşa harcanmaz. Başarısızlıklar (`refusal`, `max_tokens`, şema uyumsuzluğu) `runs/<run>/failures.jsonl` dosyasına yazılır.

## Kart durumları

`draft` (B sonrası) → `validated` (eleştirmen PASS) → `reviewed` (editör onayı) → `approved` (isteğe bağlı ikinci onay).
`rejected` hiçbir aşamada veritabanına girmez. `build_db` varsayılan olarak yalnızca `reviewed` ve `approved` kartları alır.

Eleştirmenin kararı ile kurala dayalı karar (≥20/24 ve kritik ölçütlerde 0 yok; `quiz_validity` dahil 5 kritik ölçüt) karşılaştırılır; **katı olan uygulanır**.

## Kişisel derleme (taslaklarla, yayın için değil)

API olmadan oturum içi ajanların yazdığı taslak kartlar `../content/drafts/<set>/<akış>/part_*.json` altında durur (her akış bir klasör). Kendi telefonunda denemek için:

```bash
python -m vocabpipe.personal ../content/drafts/kisisel_v1 --out ../ios/App/Resources/content.sqlite --seed-out ../ios/Widgets/Resources/seed_words.json
```

- `draft` ve `sample` kartlar da girer (editör denetimi yapılmadı). **Yayın derlemesinde kullanma.**
- Tüm kartlar ücretsiz işaretlenir (abonelik yok).
- Frekans verisi olmadığı için uygulama akışı ID sırasıyla ilerler. Yeni ID'ler bu yüzden önce seviyeye (A1 → C2), seviye içinde akışlar arasında dönüşümlü sırayla verilir: akış alfabetik değil, konular karışık ilerler.
- ID'ler `data/id_registry.json`'a yazılır ve yeniden derlemede değişmez (uygulamadaki ilerleme ID'ye bağlıdır). Aynı `id` iki akışta varsa ilki tutulur, tekrar raporda listelenir.

## Plan CSV sütunları

| Sütun | Zorunlu | Açıklama |
|---|---|---|
| `lemma` | ✓ | Başlık kelime ya da ifade (`look up to`) |
| `pos` | ✓ | `n v adj adv prep conj pron det interj phv idm phr` |
| `type` | | `word` (varsayılan), `phrasal_verb`, `idiom`, `collocation`, `proverb`, `phrase` |
| `sense_no` | | Varsayılan 1. Aynı kelimenin ikinci anlamı için 2 |
| `sense_hint` | | Hangi anlamın yazılacağı (ör. "machine stops working") |
| `target_level` | ✓ | `A1 … C2`, `S` |
| `level_source` | | `list` (açık lisanslı listeden), `editorial_estimate`, `editor_verified` |
| `primary_topic` | ✓ | `data/taxonomy.json`'daki kategori ID'si |
| `topics` | | Ek kategoriler, `\|` ile ayrılır |
| `exams` | | Yalnızca editörün onayladığı sınav etiketleri: `ielts toefl sat act gre yds yokdil ydt toeic academic` |
| `zipf`, `freq_rank` | | Frekans (açık kaynaklı listeden). Bilinmiyorsa boş bırak, uydurma |
| `ipa_us_ref`, `ipa_uk_ref` | | Telaffuz referansı (ör. CMUdict). Doluysa modelin önerisi yerine bu kullanılır |
| `confusables` | | Karıştırılan kelimeler, `\|` ile |
| `notes` | | Editör notu (ör. "Turkish false friend: hassas") |

## Model ve maliyet

Varsayılan model `claude-opus-5-5`, `effort=medium`, Batch API (%50 indirim). Sistem prompt'u (~4.400 token: kurallar + 4 altın örnek) cache'lenir.

- Pilot (50 kart), cache'siz üst sınır: A ~$1,35 + B + C ≈ **$3–4**.
- 4.000 kart: kabaca **$250–350** üst sınır. Gerçek maliyet cache ile daha düşük olur.

Maliyeti düşürmek istersen taslak için `--model claude-haiku-5-5` veya `claude-sonnet-5-5` verilebilir. Önce pilotta kaliteyi karşılaştırmak gerekir. Bu bir maliyet/kalite kararıdır; varsayılan bilerek en güçlü modeldir.

> **Not:** Batch API sunucu taraflı `fallbacks` parametresini kabul etmez. Modelin reddettiği (refusal) kartlar `failures.jsonl`'a düşer; editör bakar.

## Dosyalar

| Yol | İçerik |
|---|---|
| `data/taxonomy.json` | 7 seviye, 60 kategori, ücretsiz katman kuralları |
| `data/gold_cards.json` | Prompt'lardaki 4 altın örnek. Değiştirirsen `prompts.PROMPT_VERSION`'ı artır |
| `data/id_registry.json` | Kalıcı kart ID'leri (ilk derlemede oluşur). **Git'te tut, elle düzenleme** |
| `data/attribution.txt` | Uygulamadaki atıf metni (taslak; lisanslar eklendikçe güncellenecek) |
| `plans/` | Üretim planları (CSV) |
| `runs/` | Çalışma klasörleri (git'e girmez) |
| `../content/cards/` | Onaylanmış kartlar: içeriğin kalıcı kaynağı |
| `../content/drafts/` | Denetlenmemiş taslak kartlar (kişisel derleme için) |
