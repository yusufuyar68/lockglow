# Taslak kartlar (denetlenmemiş)

Bu klasördeki kartlar editör onayından **geçmedi** (`meta.status: draft`). Kişisel kullanım için yazıldı, yayın derlemesine girmez.

- `kisisel_v1/`: kurucu için A1–B1 günlük İngilizce seti (2026-10-11/12). 5 akış:
  - `s0_ornek`: örnek setin A1–B1 kartları
  - `s1`: ev, yemek, giyim, alışveriş, sağlık, aile
  - `s2`: şehir, ulaşım, seyahat, zaman, hava, teknoloji, okul, hobiler
  - `s3`: duygular, kişilik, sosyal beceriler, iş yeri, kutlamalar, karıştırılan kelimeler
  - `s4`: phrasal verb'ler
- Oturum içi ajanlar yazdı (Claude Sonnet), Opus kontrol etti. Hepsi `vocabpipe.validate --strict` ile 0 hata, 0 uyarı.
- **Denetim turu (2026-10-12):** her akış ayrı bir eleştirmen ajanınca kart kart okundu (SYSTEM_C ölçütleri + A2 öğrenen gözü). 474 kartın 182'si düzeltildi (`critic_edited`), hiçbiri reddedilmedi. En sık sorunlar: birden çok doğru cevabı olan boşluk doldurma soruları, uydurma "yaygın hata" örnekleri, doğal olmayan Türkçe çeviriler. Değişiklik tabloları ve anadili Türkçe birinin bakması gereken maddeler: her akışın `REVIEW.md` dosyası.
- Elle düzeltilen kartların `meta.qa_flags` alanında `*_edited_by_editor_agent` işareti var.
- **2. tur (2026-10-17/20):** temel günlük İngilizce için 273 yeni kart, 5 yeni akışta:
  - `s5`: temel fiiller (get, have, keep, leave, mean…)
  - `s6`: günlük eylemler (choose, order, prefer, pass…)
  - `s7`: sıfat ve zarflar (early, busy, already, yet, enough…)
  - `s8`: kalıp ifadeler (by the way, never mind, it depends…)
  - `s9`: günlük isimler (people, news, glass, holiday…)

  Her akışı ayrı bir denetçi okudu ve 123 kart düzeltildi. Sonra tüm akışlarda (s1–s9) quiz şıkları çeşitlendirildi: 318 kart (`distractors_diversified`). Toplam 752 kart: A1 179, A2 347, B1 226. Aynı gün `en.smell.v.2` (kokmak) eklendi: 753 kart, A2 348. 3. tur (2026-10-21): s10 iş, s11 seyahat, s12 sağlık, s13 sosyal hayat akışları eklendi (4 × 45 kart): toplam 933. Süreç ve kurallar: [`docs/icerik_uretimi/`](../../docs/icerik_uretimi/README.md).

- **Kısa anlam düzeltmesi (2026-10-24, `2026.10.24-kisisel-13`):** widget, tam anlam sığmazsa `gloss_short`'u gösterir; bu yüzden kısa anlam artık ana anlamın ilk anlamı ya da aynı kelimelerle kısaltılmışı olmalı (yeni deyim ya da eş anlamlı yok, noktalama korunur). 79 `gloss_short` değişti, 12'si kaldırıldı (ana anlam 16 grafeme indirildi; eski ana anlam `alt`'a taşındı). Anlamlardaki "…"/"..." yer tutucuları parantezli Türkçeyle değişti: "(bir şey) isterim", "sonunda (bir yerde) kalmak".
- **B2 turu (2026-10-26, `2026.10.26-kisisel-15`):** 10 yeni akış, her biri 60 B2 kart (5 part × 12): s23 iş hayatı ve kariyer, s24 siyaset, haber ve toplum, s25 çevre, iklim ve bilim, s26 sağlık, beslenme, spor, s27 teknoloji, internet ve medya, s28 ilişkiler, iletişim ve kişilik, s29 seyahat, turizm, kültür ve eğlence, s30 görüş ve tartışma, okul ve öğrenme, s31 para, alışveriş ve ekonomi, s32 phrasal verb'ler, eşdizimler ve deyimler. Hepsi `validate --strict` ile 0 hata, 0 uyarı. Hiçbir şık 4'ü geçmiyor (sınır max(4, %5)), DRESS ünlüsü her yerde `/ɛ/`, akışlar arası (lemma, pos) tekrarı yok. Başka akışta aynı lemma iki kartta var ama türü farklı: major (s18 isim, s24 sıfat), question (s9 isim, s30 fiil). Toplam 1.983 kart: A1 192, A2 580, B1 611, B2 600. 600 yeni ID (1384–1983). Ayrıntılar: her akışın `REVIEW.md` dosyası.

Uygulamaya derlemek için: `content-pipeline/README.md` → "Kişisel derleme".
Bir kartı yayına almak için `review` akışından geçirip `content/cards/`'a taşı (status `reviewed`).
