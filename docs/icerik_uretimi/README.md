# İçerik üretimi (API'siz, oturum içi ajanlarla)

Anthropic API anahtarı olmadığı için kişisel kartlar Claude Code oturumunda ajanlarla yazılıyor. Bir tur üç adımdır. Her adımda her akış (`content/drafts/kisisel_v1/<akış>/`) ayrı bir ajana (Sonnet) verilir, Opus koordine eder ve sonuçları kontrol eder.

1. **Yazım:** [1_yazar_kurallari.md](1_yazar_kurallari.md). Ajana akış adı ve kelime listesi verilir (lemma, pos, seviye, gerekirse anlam ipucu). Ajan her 10 kartı bitirince bir `part_NN.json` dosyasını diske yazar. Böylece oturum kesilse bile iş kaybolmaz.
2. **Denetim:** [2_denetci_kurallari.md](2_denetci_kurallari.md). Başka bir ajan kartları tek tek okur ve düzeltir (`critic_edited`). Ardından akışın `REVIEW.md` dosyasını yazar. Yazarın raporundaki "emin olmadığım" maddeler denetçiye ayrıca verilir.
3. **Çeldirici kontrolü:** [3_celdirici_kurallari.md](3_celdirici_kurallari.md). Bir quiz şıkkı akıştaki soruların en fazla `max(4, %5)` kadarında geçebilir. Doğrulayıcı bunu `QUIZ_DISTRACTOR_REPEAT` uyarısıyla yakalar.

Her adımın sonunda şu komut **0 hata · 0 uyarı** vermeli:

```bash
cd content-pipeline
python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/<akış>
```

En son uygulamaya derlenir (bkz. `content-pipeline/README.md` → "Kişisel derleme"). `--content-version` her derlemede artırılır.

## Araçlar

- `araclar/dump_lemmas.py`: var olan başlık kelimeleri listeler. Yazarın tekrar yazmaması için ona verilir.
- `araclar/distractor_stats.py`: her akışta en sık geçen quiz şıklarını gösterir.
- `araclar/ipa_dress_stats.py`: İngiliz/Amerikan IPA'da DRESS ünlüsünü sayar. Depo geleneği `/ɛ/`; `--fix <akış>` ile düzeltir.

Python'u Windows'ta `-X utf8` ile çalıştır (IPA ve Türkçe karakterler konsolda bozulmasın). Dosya yazarken `newline="\n"` kullan; depo LF ister.

## Dersler (2. tur, 2026-10-17/20)

- **Yaygın hata:** Ajanlar "yaygın hata" uydurmaya yatkın. Denetçi Türkçeden gelmeyen ya da İngilizcede aslında doğru olan cümleleri sildi. Örnekler: "a glass of tea", "go to the market", "by purpose". Gerçek hatalar kaldı: "I am agree", "Rain is raining", "make a photo".
- **Sahte dost:** "library" Türkçe için sahte dost değil. Türkçe sahte dost örnekleri: sympathetic ≠ sempatik, actually ≠ aktüel.
- **Quiz şıkları:** Yazarlar güvenli olsun diye hep aynı birkaç şıkkı kullanıyor. s6'da "wash" 51 sorunun 33'ündeydi. Bu yüzden 3. adım şart.
- **Zarf soruları:** En riskli soru türü. Bağlam yalnızca bir zarfı zorunlu kılmalı.

## Widget ve kilit ekranı alanları (2026-10-22)

`docs/tasarim/ogrenme_ilkeleri.md` §2.12'deki içerik işi. Kurallar `1_yazar_kurallari.md`'de, denetim soruları `2_denetci_kurallari.md`'de, veritabanı karşılıkları `docs/contract/content-db.md` (şema 2) içinde.

- **`l1.tr.gloss_short`:** anlamı 16 karakteri geçen 97 kartın hepsine yazıldı. 36'sı `alt`'tan, 20'si anlamın ilk virgülden önceki kısmından seçildi, 41'i yeni yazıldı. Bir ajan yazdı; bağımsız bir doğrulayıcı 97'sini okudu ve 6 değişiklik önerdi. Beşi alındı: ask out "çıkmayı önermek", stop "durmak/durdurmak", agree "hemfikir olmak", disagree "hemfikir olmamak", frustrated "sinir olmuş". Parantezli "değiş(tir)mek" önerisi alınmadı; change "değiştirmek" kaldı.
- **`confusables`:** 276 kartta 355 kayıt (63'ü destede kartı olmayan bir kelimeye: actually → currently gibi).
  - Eski 153 `confusable:` bayrağının 130'u bu alana taşındı, 23'ü düşürüldü (düz eş anlamlı ya da zıt anlamlı). Bayraklar kartlardan silindi; derleyici eski biçimi yine okur.
  - Eksik klasik çiftler eklendi: borrow/lend iki yönlü, actually/currently, get up/stand up, receipt/recipe, appointment ↔ date, kitchen/chicken, way → road, weather → air.
  - Bağımsız doğrulayıcı 195 çiftten 3'ünü düşürdü ve 20 eksik önerdi. Kartın anlamına uyan 17'si alındı; rent/hire ve spend/pass destedeki kartların anlamına uymadığı için alınmadı.
- **`tags.sensitivity`:** 1.068 kartın hepsi üç ajanla okundu ve 9 kart `1` oldu: divorce, ex, crush, date, break up, ask out, throw up, get fired, broke. Bağımsız ikinci okuma dokuzuna da katıldı ve kaçan kart bulmadı. Destede alkol, sigara, kaba kelime ya da özel beden konusu yok.
  - Yalnızca ilk örneği kişisel olan ama kelimesi sıradan kartlar işaretlenmedi: stay over, fall out with, ashamed, guilty. İstenirse başka bir örnekleri başa alınabilir.
