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
