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

  Her akışı ayrı bir denetçi okudu ve 123 kart düzeltildi. Sonra tüm akışlarda (s1–s9) quiz şıkları çeşitlendirildi: 318 kart (`distractors_diversified`). Toplam 752 kart: A1 179, A2 347, B1 226. Süreç ve kurallar: [`docs/icerik_uretimi/`](../../docs/icerik_uretimi/README.md).

Uygulamaya derlemek için: `content-pipeline/README.md` → "Kişisel derleme".
Bir kartı yayına almak için `review` akışından geçirip `content/cards/`'a taşı (status `reviewed`).
