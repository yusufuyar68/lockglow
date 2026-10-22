# Lockglow kart denetimi: ortak kurallar (kisisel_v1, 2. tur, 2026-10-17)

Başka bir ajanın yazdığı kelime kartlarını **kart kart okuyup düzelteceksin**. Kartları kullanacak kişi Türkçe konuşuyor, seviyesi **A2 ve altı**, günlük İngilizce öğreniyor. Kartlar onun telefonunda kilit ekranında, akışta ve tekrar sorularında görünecek. Senin işin, yanlış ya da yanıltıcı hiçbir şeyin ona ulaşmaması.

## Çalışma yeri

- Depo kökü: bu deponun klasörü (Claude Code'un çalışma klasörü ya da onun geçici bir worktree'si)
- Yalnızca sana verilen akış klasöründeki dosyaları değiştir: `content/drafts/kisisel_v1/<akış>/part_*.json` ve yeni bir `REVIEW.md`.
- Git'e yazma (commit, push vb.) yok. Başka klasöre dokunma.

## Önce oku

- Yazarın kuralları: `docs/icerik_uretimi/1_yazar_kurallari.md`.
- Denetim ölçütleri: `git show pipeline/critic-quiz-backtranslation:content-pipeline/vocabpipe/prompts.py` içindeki `SYSTEM_C`. Rubrik: `git show pipeline/critic-quiz-backtranslation:raporlar/07_icerik_stratejisi.md`.
- Örnek denetim raporu: `content/drafts/kisisel_v1/s1/REVIEW.md`. Biçimi buna benzesin.

## Her kartta bak

1. **Anlam ve tanım:** Seçilen anlam doğru mu, A2 öğrencisinin en çok karşılaşacağı anlam mı? Tanımlar doğru, basit ve döngüsüz mü (başlık kelimeyi kullanmıyor mu)?
2. **Örnekler:**
   - İngilizce doğal mı, gerçek bir anadili İngilizce olan kişi böyle der mi?
   - İlk örnek kilit ekranına uygun mu (kısa, tek başına anlaşılır)?
3. **Türkçe çeviri:** Çeviriyi **İngilizceye geri çevir**. İngilizce cümleyle aynı anlam çıkıyorsa iyi. Fazla ya da eksik bilgi, doğal olmayan Türkçe ya da kelimenin karşılığının kaybolması düzeltilir.
4. **gloss ve alt:** Gerçek ve yaygın Türkçe karşılıklar mı? Açıklama cümlesi değil, sözcük ya da kalıp mı?
   - **gloss_short** (anlam 16 karakteri geçiyorsa var): kilit ekranında tek başına okununca doğal ve doğru mu? Kesilmiş gibi durmuyor mu, olumsuzluğu koruyor mu, başka anlama kaymıyor mu ("randevu istemek" ask out için doktor randevusu gibi okunur)?
   - **confusables:** her eş gerçek bir karışıklık mı (Türkçede aynı karşılık, benzer yazılış ya da ses, sahte dost, bilinen kullanım farkı)? Düz eş anlamlı ya da aynı konudan kelimeyse sil. Destedeki eşte de karşılığı var mı?
   - **sensitivity:** kart, kilit ekranında başkası görünce sahibini utandırabilecek ya da özel hayatı sanılabilecek bir konuda mı (ilişki, ayrılık, beden, alkol, kaba kelime, iş ya da para kaybı)? Öyleyse `1`, değilse `0`.
5. **Yaygın hata (mistakes):** Türkçe konuşanların **gerçekten** yaptığı bir hata mı?
   - Uydurma, zorlama ya da Türkçeyle ilgisiz bir hataysa sil (liste boş kalabilir) ya da gerçek bir hatayla değiştir.
   - `right` gerçekten doğru mu?
   - `why`, Türkçenin nasıl yanılttığını doğru anlatıyor mu?
6. **Not (note):** Doğru ve yararlı mı? İngilizce sözcükten sonra ayrı yazılmış ek var mı ('freezer' dır)? Varsa cümleyi eksiz kur.
7. **Quiz:**
   - Boşluğa her şıkkı tek tek koy. **Yalnızca bir** şık doğru ve doğal olmalı.
   - Bir çeldirici de dilbilgisi ve anlam olarak olabiliyorsa cümleyi ya da çeldiriciyi değiştir.
   - Cevap cümlede görünmüyor mu?
   - Çeldiriciler aynı türden ve aynı işlevde mi? Cümleye hiç uymayan, bir şey sınamayan çeldiricileri (ör. bir söylem belirteci sorusunda "On foot / Next to") aynı işlevden ama o cümlede açıkça yanlış seçeneklerle değiştir. Bir kalıbın gerçek hata biçimleri iyi çeldiricidir ("did a mistake", "took a mistake"). Tek doğru cevap kuralı önce gelir; emin olamıyorsan mevcut çeldiriciyi bırak.
8. **IPA:** US ve UK doğru mu? Çok heceli kelimede vurgu doğru hecede mi?
9. **Köken (etymology):** Gerçek mi? Emin değilsen `null` yap. Halk etimolojisi olmasın.
10. **Sahte dost:** Gerçekse kalsın, değilse `null`.
11. **Seviye:** Listede verilen seviye bariz yanlışsa değiştir ve raporda söyle.

## Düzelttiğin kartta

- `meta.qa_flags` listesine `"critic_edited"` ekle (zaten yoksa).
- Kartı reddetmen gerekiyorsa (anlamı düzeltilemeyecek kadar bozuk) `"critic_reject"` ekle ve raporda nedenini yaz. Bu çok nadir olmalı; önce düzeltmeyi dene.

## Bitirmeden önce

```
cd <depo kökü>/content-pipeline
python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/<akış>
```

Sonuç **0 hata · 0 uyarı** olmalı.

## REVIEW.md

`content/drafts/kisisel_v1/<akış>/REVIEW.md` dosyasına yaz:
- **Özet:** incelenen kart, değişen kart, alan sayısı, reddedilen, doğrulayıcı satırı.
- **Genel bulgular.**
- **Değişiklik tablosu:** Kart | Alan | Önce → Sonra | Neden.
- **Anadili Türkçe birinin bakması gerekenler:** emin olmadığın maddeler.

## Rapor (son mesajın)

Kısa tut: sayılar, en sık 3 sorun, doğrulayıcının son satırı.
