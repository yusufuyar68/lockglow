# batch1_hero: editör notları

**Dosya:** `batch1_hero.csv`. 1.292 kart, vitrin kategorileri: YDS/YÖKDİL, akademik, phrasal verb, deyim, karıştırılan kelimeler ve tuzak kelimeler, duygular, havalı kelimeler, nadir kelimeler.
**Kaynak:** 3 taslak (Sonnet ajanları, editoryal tahmin). `plan merge` ile birleştirildi: 0 reddedilen satır, 28 tekrar birleştirildi. Ayrıntı: `batch1_hero_report.json`.

> Bu bir **başlık kelime planıdır**, içerik değildir. Tanımlar, örnekler ve Türkçe katman A/B/C aşamalarında üretilecek, ardından insan denetiminden geçecek. Plan aşamasındaki hatalar o aşamalarda da yakalanabilir. Yine de aşağıdakilere üretimden **önce** bakmak ucuzdur.

## Kategori dağılımı (birincil / üyelik / MVP hedefi)

| Kategori | Birincil | Üye | Hedef |
|---|---|---|---|
| yds_yokdil_core | 300 | 300 | 300 |
| academic_core | 120 | 120 | 120 |
| phrasal_verbs | 200 | 200 | 200 |
| idioms_expressions | 180 | 180 | 180 |
| confusing_words | 95 | 100 | 100 |
| emotions_feelings | 109 | 135 | 110 |
| sound_smarter | 138 | 160 | 160 |
| rare_beautiful | 150 | 150 | 150 |

## Koordinatör kararları (uygulandı)

- **chance / şans tuzak kelime değil.** Türkçede "şans" hem *luck* hem *chance* anlamına gelir. Not "confusable: chance vs luck" olarak düzeltildi.
- **etiquette / etiket ve costume / kostüm kısmi tuzak kelime.** TDK'da etiket görgü kuralları, kostüm de sahne giysisi anlamını da taşıyor. Notlar "partial false friend" olarak düzeltildi.
- Dosyalar arası tekrarlarda kart atılmadı; ikinci kategori kartın `topics` alanına eklendi (ör. *pivotal*: YDS + havalı kelimeler).

## Üretimden önce bakılacaklar

1. **Tuzak kelimeler (20):** Ajan şunlardan emin: college/kolej, pasta, casket/kasket, smoking/smokin, grip, direction/direksiyon, apartment/apartman, climate/klima, mayo, patron. Benim de doğru bulduklarım: speaker/spiker, condition/kondisyon, stage/staj, conserve/konserve, tip, casino/gazino, expertise/ekspertiz. Bir Türk öğretmenin hızlı bir onayı yeterli.
2. **Nadir kelimelerde var olduğu kesin olmayanlar:** saudade (Portekizce alıntı), matutinal, auroral, hortatory, gainsay, tintinnabulation, lucent, plash, sough, oneiric. Ayrıca edenic, elysian ve arcadian sözlüklerde büyük harfle de yazılır. Kuralımız "en az iki büyük sözlükte geçmeli"; şüphelileri çıkarmak ya da onaylamak gerekiyor.
3. **Sınırda S seviyesi olanlar:** luminary, paragon, apogee, kindred, dell, glade. İstenirse C2'ye indirilebilir.
4. **Seviye tahminleri:** YDS satırlarının %67'si C1 olarak işaretli. hamper, curb, assert, withstand ve contend B2 olabilir. Üretimdeki A aşaması modelin kendi seviye tahminini `llm_level:` bayrağıyla yazar; uyuşmazlıklar denetimde görünür.
5. **Sınav etiketleri doğrulanmadı:** 90 satırda `gre`, 8 satırda `sat` var; YDS satırlarının hepsinde `yds|yokdil`. Bu etiketler kartlarda "sınav paketi" olarak gösterileceği için bir sınav öğretmeni örneklem kontrolü yapmalı.
6. **Fiil oranı yüksek:** YDS'de %37 fiil (hedef %35); zarf ve isim biraz eksik. Kabul edilebilir.
7. **Eksik:** emotions_feelings birincil olarak 1 kart, confusing_words 5 kart eksik (üyelik hedefte). Sonraki partide tamamlanabilir.

## Nasıl çalıştırılır (API anahtarı hazır olunca)

Önce 50 kelimelik pilot (`runs/pilot1`). Kalite tamamsa batch1. Komutlar `content-pipeline/README.md`'de.

| Partide | Kart | A aşaması üst sınırı (cache'siz) | A+B+C tahmini |
|---|---|---|---|
| pilot1 | 50 | ~$1,35 | ~$3–4 |
| batch1 | 1.292 | ~$35 | ~$80–100 |
