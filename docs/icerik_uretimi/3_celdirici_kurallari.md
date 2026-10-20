# Quiz çeldiricilerini çeşitlendirme (kisisel_v1, 2026-10-19)

Lockglow'un "Tekrar" sekmesinde her kart için bir boşluk doldurma sorusu sorulur: `quiz.cloze` (boşluk `______`), doğru cevap `quiz.answer` ve üç çeldirici `quiz.distractors`. Öğrencinin seviyesi A2 ve altı, Türkçe konuşuyor.

## Sorun

Bazı akışlarda aynı çeldirici onlarca soruda tekrar ediyor. Örneğin s6'da "wash" 51 sorunun 33'ünde var. Öğrenci kısa sürede "wash hiç doğru cevap değil" diye öğreniyor ve soru bir şey sınamaz hâle geliyor.

## Hedef

Sana verilen akışta **hiçbir çeldirici 4'ten fazla soruda geçmesin.** s4'te 5'e kadar izin var. Doğru cevaplar ve sorunun özü aynı kalsın.

## Kurallar

1. **Biçim aynı olsun.** Yeni çeldirici, cevapla aynı türden ve aynı biçimde olsun:
   - cevap "washed" ise çeldiriciler de geçmiş zaman;
   - cevap çoğul isimse çeldiriciler de çoğul isim;
   - cevap phrasal verb ise çeldiriciler de phrasal verb.
2. **Konuya yakın olsun.** Akla yatkın görünsün, cümlenin konusuna yakın dursun. Örneğin bir mutfak cümlesinde "cut, mix, pour", bir alışveriş cümlesinde "pay, carry, return".
3. **O cümlede açıkça yanlış olsun.** Her yeni şıkkı boşluğa koyup cümleyi oku. Dilbilgisi ya da anlam olarak doğru olabiliyorsa o şıkkı kullanma.
4. **Tek doğru cevap kuralı her şeyden önce gelir.** Emin olmadığın bir değişikliği yapma. Gerekirse eski çeldiriciyi tut ve başka bir soruda o çeldiriciyi değiştir.
5. **Teknik sınırlar:** Çeldirici cevaba eşit olmasın, aynı soruda iki kez geçmesin, en fazla 16 karakter olsun. Cevap cümlede görünmesin. Eskisi doğruysa cümleyi (`cloze`) değiştirme; yalnızca çeldiriciyi değiştir.
6. **İşaret:** Değiştirdiğin karta `meta.qa_flags` içine `"distractors_diversified"` ekle.

## Dosyalar

- Depo kökü: bu deponun klasörü (Claude Code'un çalışma klasörü ya da onun geçici bir worktree'si)
- Kartlar: `content/drafts/kisisel_v1/<akış>/part_*.json`. Yalnızca `quiz.distractors` alanını ve `qa_flags`'i değiştir; gerekirse çok nadiren `quiz.cloze`'u.
- JSON biçimini koru: 2 boşluk girinti, `ensure_ascii=False`, sonda yeni satır.
- Git'e yazma, başka klasöre dokunma.

## Ölçüm ve doğrulama

```
python -I -X utf8 docs/icerik_uretimi/araclar/distractor_stats.py content/drafts/kisisel_v1
cd <depo kökü>\content-pipeline
python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/<akış>
```

Doğrulayıcı **0 hata · 0 uyarı** vermeli. İstatistikte hedef sağlanmalı.

## Kayıt

Akışın `REVIEW.md` dosyasının sonuna "## Çeldirici çeşitlendirme (2026-10-19)" başlıklı bir bölüm ekle (s4'te dosya varsa sonuna ekle):
- önce/sonra istatistik satırı;
- değişen kart sayısı;
- cloze'u değiştirdiğin kartlar ve nedenleri.

## Rapor

Kısa tut: önce/sonra istatistik, değişen kart sayısı, doğrulayıcının son satırı.
