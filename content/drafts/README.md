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

Uygulamaya derlemek için: `content-pipeline/README.md` → "Kişisel derleme".
Bir kartı yayına almak için `review` akışından geçirip `content/cards/`'a taşı (status `reviewed`).
