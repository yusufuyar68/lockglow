# FSRS (v1.2): motor, simülasyon ve geçiş planı

> Durum: 2026-10-23, dal `is5-fsrs`. FSRS uygulamaya bağlandı: **"Ayarlar → Yeni zamanlama (deneme)"** açılınca tekrarları FSRS zamanlıyor. Ayar varsayılan olarak kapalı; kapalıyken her şey Leitner'le eskisi gibi. Neler yapıldı, neler açık: 4.3. FSRS'te basamak: 4.5.
>
> Lockglow kuralları (4.5): "Yerleşti"ye yalnız 4–5. basamaktan, hatırlama sorusuyla geçilir; henüz bilinmeyen kelime en çok 16 gün bekler; aynı gün adımındaki "Zor" en az 12 saat bekler. Ayar kapatılınca çok uzak tarihler Leitner'in en uzun beklemesine çekilir (4.2). Hesap, 4 şıklı sorudaki %25 şans payını hesaba katar (4.3 adım 9).
>
> Önceki adımlar: 2026-10-22 dal `fsrs` (taban `main` 29797b4) saf ve testli FSRS-6 motorunu yazdı (`FSRS.swift`); `is4-ogrenme` 4.3'ün 1. ve 6. adımlarını yaptı.

## Kısa sonuç

- **FSRS-6, bugün kullanılan sürüm.** Anki fsrs-rs 6.6.2'yi kullanıyor (FSRS-6). FSRS-7 yalnız fsrs-rs'in ana dalında var, henüz yayımlanmadı.
- **Motor resmî değerleri tutturuyor.** `FSRS.swift` py-fsrs 6.3.2'nin Swift karşılığı. 16 testin 10'u py-fsrs ve fsrs-rs'in kendi test değerlerini kullanıyor; hepsi Linux CI'da geçti.
- **Simülasyon, 90 gün** (1.000 kelime, günde 10 yeni kelime), varsayılan hedef 0,90:
  - FSRS günlük tekrarı üçte bir azaltıyor: 56,0'dan 37,2'ye.
  - Hatırlama 1,3 puan düşüyor: %96,1'den %94,8'e.
  - Aynı tekrar yükünde FSRS yalnız +0,6 puan daha iyi. Aynı hatırlamada %10 daha az tekrar istiyor.
- **Simülasyon, 365 gün:**
  - FSRS 0,90 ortalama yükü yarıya indiriyor, son ayın yükünü %71 azaltıyor (42,0 → 12,1).
  - Ama hatırlama 3,7 puan düşüyor (%98,5 → %94,8). Aynı yükte FSRS'in belirgin bir üstünlüğü yok.
  - Bugünkü Leitner'in yüksek hatırlaması pahalı: bilinen her kelimeyi 30 günde bir soruyor. Leitner'e "tazeleme 30 → 60 → 120 gün" eklenince sonuç FSRS'e çok benziyor: son ay 13,0 tekrar, hatırlama %95,7.
- **Bu modelde FSRS'in faydası:**
  - "hedef hatırlama" ile yük ve hatırlama arasında bilerek seçim yapma imkânı;
  - aralıkların kendiliğinden uzaması;
  - ileride kişisel parametreler.

  Verimde büyük bir sıçrama yok. Kişisel parametrelerin katkısını bu simülasyon ölçemez (bölüm 3.6).
- **Öneri:**
  1. Şimdi tekrar günlüğünü (`review_log.jsonl`), `lastReviewedAt` ve `lastGrade` alanlarını ekle.
  2. v1.2'de FSRS'i bir ayarın arkasında aç (hedef 0,90).
  3. Kişisel parametreleri birkaç yüz tekrardan sonra hesapla.

  FSRS 2–3 aydan uzun gecikecekse arada Leitner'e büyüyen tazelemeyi ekle. Ayrıntı: bölüm 5.

## 1. FSRS: birincil kaynaklardan özet

### 1.1 Sürüm durumu (2026-10-22'de kontrol edildi)

| Proje | Son sürüm | Algoritma |
|---|---|---|
| fsrs-rs (Anki'nin kullandığı) | v6.6.2, 2026-08-28. Anki `Cargo.toml`: `fsrs = "6.6.2"` | FSRS-6. Ana dalda (yayımlanmamış) varsayılan FSRS-7 (34 parametre) |
| py-fsrs | v6.3.2, 2026-08-09 | FSRS-6 |
| ts-fsrs | v5.4.2, 2026-09-01 | FSRS-6 |
| swift-fsrs | v5.0.0, 2024-10-29 | Yayımlanan sürüm FSRS-5; FSRS-6 yalnız ana dalda (son commit 2026-05-25) |

**Neden swift-fsrs değil de kendi kopyamız:**
- Yayımlanmış sürümü FSRS-5; FSRS-6 için ana dala sabitlemek gerekirdi. Bağımlılık eklemek de istemedik.
- Çekirdek hesap yaklaşık 150 satır.
- py-fsrs en okunaklı resmî uygulama; testleri de birebir taşınabiliyor.

`raporlar/04_teknik_mimari.md` swift-fsrs'i öneriyordu. Bu karar o öneriyi değiştiriyor.

### 1.2 Formüller (FSRS-6)

Semboller:
- S (stability, kararlılık): hatırlama olasılığının %90'a düşmesi için geçen gün sayısı.
- D (difficulty, zorluk): 1 ile 10 arası.
- R (retrievability): şu anki hatırlama olasılığı.
- G: not. Lockglow'daki karşılıkları: Bilemedim 1, Zor 2, Bildim 3, Kolay 4.
- w0…w20: parametreler.

| Ne | Formül |
|---|---|
| Unutma eğrisi | R(t, S) = (1 + f · t / S)^(−w20), f = 0,9^(−1/w20) − 1. Böylece R(S, S) = 0,9 |
| Sonraki aralık | I = S / f · (r^(−1/w20) − 1), r = hedef hatırlama. r = 0,9 iken I = S. Gün olarak yuvarlanır, en az 1 |
| İlk kararlılık | S0(G) = w[G − 1] |
| İlk zorluk | D0(G) = w4 − e^(w5 · (G − 1)) + 1, 1…10 arasına sıkıştırılır |
| Zorluk güncellemesi | ΔD = −w6 · (G − 3); D′ = D + ΔD · (10 − D) / 9; D″ = w7 · D0(4) + (1 − w7) · D′ |
| Doğru cevap sonrası S | S · (1 + e^w8 · (11 − D) · S^(−w9) · (e^(w10 · (1 − R)) − 1) · w15 [Zor ise] · w16 [Kolay ise]) |
| Yanlış cevap sonrası S | min(w11 · D^(−w12) · ((S + 1)^w13 − 1) · e^(w14 · (1 − R)), S / e^(w17 · w18)) |
| Aynı gün tekrar sonrası S | S · e^(w17 · (G − 3 + w18)) · S^(−w19); doğru cevapta çarpan en az 1 |

**Varsayılan parametreler** (FSRS-6, 21 sayı; Anki kullanıcılarının ortalamasına göre):

```
0.212, 1.2931, 2.3065, 8.2956, 6.4133, 0.8334, 3.0194, 0.001, 1.8722, 0.1666, 0.796,
1.4835, 0.0614, 0.2629, 1.6483, 0.6014, 1.8729, 0.5425, 0.0912, 0.0658, 0.1542
```

**FSRS-5'ten farkı** (algoritma belgesi):
- Aynı gün formülüne S^(−w19) eklendi: küçük S hızlı, büyük S yavaş büyür.
- Eğrinin eğimi (w20) öğrenilebilir oldu. FSRS-5'te sabitti: 0,5.
- 19 sayılık FSRS-5 parametresi `w19 = 0`, `w20 = 0,5` eklenerek çalışır. fsrs-rs de böyle yapıyor.

**Bir özellik:** varsayılan eğri çok yatık (w20 = 0,1542). Süre 1,5 katına çıkınca hatırlama yalnız %90'dan %87'ye iniyor. Bu yüzden FSRS'te ezberlenmiş kelimeler uzun süre "büyük olasılıkla hatırlanır" görünür.

### 1.3 Hedef hatırlama oranı (desired retention)

Anki kılavuzu:
- Varsayılan %90.
- %90'ın üstünde yük hızla artar; %97'nin üstü "bunaltıcı" olabilir.
- Önerilen sınır: %97'nin altında kal.
- "Compute minimum recommended retention" aracı Anki 25.07'de kaldırıldı. Kılavuzda bugün farklı hedeflerin yükünü gösteren deneysel bir simülatör var ("Help Me Decide").

Bizim simülasyonumuzda da aynı şekil çıktı:
- 0,90 → 0,95'e geçiş günlük tekrarı %66 artırıyor (37,2 → 61,6).
- Aynı geçiş hatırlamaya yalnız 2,4 puan ekliyor.

### 1.4 Aynı gün (kısa aralıklı) tekrarlar

- **Gün sayımı:** iki cevap arası tam gün olarak sayılır. py-fsrs'te `timedelta.days`, yani 24 saatin aşağı yuvarlanmış katı.
- **Bir günden kısa ara:** "aynı gün" formülü kullanılır (yukarıdaki tablo). Varsayılan parametrelerle:
  - "Kolay" S'yi büyütür.
  - "Bildim" yalnız S yaklaşık 2,1 günden küçükken büyütür. Daha büyük S'de çarpan 1'in altına düşer ve 1'e yükseltilir, yani S aynı kalır.
  - "Zor" S'yi hiçbir zaman düşürmez (çarpan hep 1'e yükseltilir).
  - "Bilemedim" S'yi küçültür (çarpan 1'in altında).
  - Zorluk her cevapta güncellenir.
- **Yeni kelime adımları (learning steps):** py-fsrs'te varsayılan 1 dk ve 10 dk.
  - Bilemedim: ilk adıma döner.
  - Zor: aynı adımda kalır (tek adımda 1,5 katı).
  - Bildim: sonraki adıma geçer; son adımda gün aralığına geçer.
  - Kolay: adımları atlar.
- **Yeniden öğrenme adımları (relearning steps):** yanlış cevaplanan, gün aralığındaki kelime için. Varsayılan 10 dk.
- Anki kılavuzu adımların bir günden kısa olmasını öneriyor ("10m or 30m are good").

## 2. Motor: `FSRS.swift`

**API:**
- `FSRS(weights:desiredRetention:learningSteps:relearningSteps:maximumIntervalDays:)`.
- Bellek modeli:
  - `retrievability(elapsedDays:stability:)`;
  - `intervalDays(stability:retention:)`;
  - `scheduledDays(stability:)`;
  - `initialMemory(_:)`;
  - `nextMemory(_:elapsedDays:grade:)`.
- Zamanlayıcı: `review(_ card: FSRSCard, grade:at:) -> FSRSCard` ve `retrievability(of:at:)`.
- `FSRSCard`: aşama (learning / review / relearning), adım, `FSRSMemory` (S, D), `dueAt`, `lastReviewAt`.

**Not eşlemesi:** `ReviewGrade` (Leitner.swift, değişmedi). Bilemedim = Again, Zor = Hard, Bildim = Good, Kolay = Easy.

**Seçimler:**
- Bulanıklaştırma (fuzz) yok: tarihler belirlenimci. Tek kullanıcıda yük yığılması küçük; istenirse sonra eklenir.
- Gün aralığı py-fsrs gibi "yarım çifte" yuvarlanıyor (`.toNearestOrEven`). Gün sayımı 24 saatin katı.
- Varsayılan adımlar py-fsrs'inkiler. Lockglow için önerilen ayar `learningSteps: [600]` ve `relearningSteps: [600]`: Leitner'in 10 dakikası, pratikte "bir sonraki tur".
- Parametreler py-fsrs'in sınırlarıyla denetlenir (`FSRS.weightBounds`, `FSRS.areValid(weights:)`). Sınır dışı parametre (ör. bozunma 0) sonsuz ya da tanımsız (NaN) aralık verirdi. `init` böyle parametrede durur; kayıttan okunan parametre önce `areValid` ile denetlenmeli.
- Yok: tam parametre eniyileme (optimizer), FSRS-7. Motorun kendisinde kalıcı kayıt biçimi yok; kelimenin belleğini `FSRSState` saklar (4.1). Cihazda yalnız w0…w3 hesaplanır (`FSRSParameterFit`, 4.3 adım 9).

**Lockglow'da yeni kelimenin ilk cevabı** (önerilen adımlarla):

| Cevap | Bugün Leitner | FSRS-6 |
|---|---|---|
| Bilemedim | 10 dk | 10 dk |
| Zor | 12 saat | 15 dk (adım × 1,5) |
| Bildim | 1 gün | 2 gün (S0 = 2,31) |
| Kolay | 2 gün | 8 gün (S0 = 8,30) |

**Testler:** `ios/Packages/VocabKit/Tests/LearningTests/FSRSTests.swift`, 16 test.
- 10'u py-fsrs ve fsrs-rs'in kendi test değerlerini kullanıyor; 6'sı değerleri formülden elle hesaplıyor (hesap yorumda).
- İlk sürüm (commit 17d34b2, 15 test) Linux CI'da yeşildi: run 39791520626, 205 testin hepsi geçti.

Resmî değerli testler:
- **py-fsrs `test_review_card`:** Bildim ×6, Bilemedim ×2, Bildim ×5 dizisinin aralıkları `[0, 2, 11, 46, 163, 498, 0, 0, 2, 4, 7, 12, 21]`. Her adımın S ve D değeri test yorumunda tablo olarak var.
- **py-fsrs `test_memo_state` ve fsrs-rs `test_memory_state`:** S = 53,62691, D = 6,3574867.
- **fsrs-rs `test_next_states`:** gerçek bir koleksiyondan FSRS-5 parametreleri, dört notun S ve D değerleri.
- **fsrs-rs `test_next_interval`:** hedef 0,1…1,0 için aralıklar. fsrs-rs 32 bit hesaplıyor; 0,1'de milyonda 1 fark var, testte göreli tolerans kullanıldı.
- **py-fsrs adım testleri:** yeni kelime adımları, yeniden öğrenme, aynı gün "Zor"un S'yi düşürmemesi, art arda "Kolay"ın D'yi 1'e indirmesi, S'nin 0,001'in altına inmemesi.
- **py-fsrs parametre sınırları:** sınır dışı parametrenin reddedilmesi.

Formülden hesaplanan testler: ilk cevabın S ve D değerleri, R(S, S) = 0,9, FSRS-5 doldurma, gün aralığının alt ve üst sınırı, kartın hatırlama olasılığı, Lockglow'un dört notu (yukarıdaki tablo).

Aynı değerleri Python'da da denemek için:
`python -X utf8 docs/ozellik_planlari/araclar/fsrs_sim.py --dogrula` (22/22 TAMAM).

## 3. Simülasyon: Leitner ve FSRS

Betik: `docs/ozellik_planlari/araclar/fsrs_sim.py`. Bütün tablolar 20 rastgele tohumun ortalaması. Betik yaklaşık 1 dakikada biter ve aynı sayıları yeniden üretir.

### 3.1 Kurulum

- 1.000 kelime, günde 10 yeni kelime, 90 gün. 90 günde 900 kelime tanıtılır.
- Her gün 09:00'da tek bir Tekrar oturumu: önce zamanı gelen kelimeler, sonra yeni kelimeler.
- Oturum içinde "Bilemedim" 10 dakika sonra yeniden sorulur.
- **Oturum 09:00–11:00 arası açık sayılır.** Bu sürede zamanı gelen kelime zamanında sorulur; örneğin dün 09:10'da yeniden sorulup bugün 09:10'a zamanlanan kelime.
  - Pencereye sığmayan tarih ertesi güne kalır. Leitner'in "Zor = 12 saat"i pratikte 1 gün olur.
  - Bağımsız denetimin bulgusu: ilk sürümde pencere yoktu, 09:10'a zamanlanan kelimeler bir gün geç soruluyordu. Düzeltme sayıları biraz değiştirdi, sonuçları değiştirmedi.
- **Öğrencinin "gerçek" hafızası:** varsayılan FSRS-6 modeli. Anki'nin ve fsrs-rs'in simülatörü de böyle yapıyor.
- **Cevap olasılıkları** fsrs-rs `SimulatorConfig` varsayılanlarından (Anki kullanıcılarının ortalaması):
  - ilk görüşte Bilemedim / Zor / Bildim / Kolay = 0,24 / 0,094 / 0,495 / 0,171;
  - doğru hatırlanan tekrarda Zor / Bildim / Kolay = 0,224 / 0,631 / 0,145.
- **Yöntemler:**
  1. **Leitner (main):** `Leitner.swift`'in bugünkü kuralları. Kutular 1-2-4-8-16 gün, yanlışta kutu 1, Zor yarım aralık, Kolay iki kutu, son kutudan sonra 30 günde bir tazeleme.
  2. **Leitner + iki kutu düşme:** başka bir oturum (`is3-tekrar`, commit 7900e0d, main'de değil) "kayma kuralını" ekliyor. Yanlışta kutu en çok iki iner (kutu max(1, k − 2)); yanlış tazeleme kutu 3'e iner. Kaynak: `docs/tasarim/ogrenme_ilkeleri.md` 2.3.
  3. **Leitner + iki kutu düşme + büyüyen tazeleme:** `ogrenme_ilkeleri.md` 2.3'teki öneri (kodda yok). Tazeleme her doğru cevapta uzar: 30 → 60 → 120 gün.
  4. **FSRS-6:** varsayılan parametreler, hedef 0,90, adımlar 10 dk / 10 dk.
- **Ölçüler:**
  - **Tekrar/gün:** zamanı gelen kelimeler; yeni kelimeler ve aynı gün yeniden sormalar hariç.
  - **Aynı gün yeniden:** "Bilemedim" ve adım tekrarları.
  - **Tekrarda doğru:** tekrarlarda doğru cevap oranı.
  - **Sondaki hatırlama:** simülasyon bitince tanıtılan kelimelerin ortalama gerçek hatırlama olasılığı.
  - **Hatırlanan kelime:** bu olasılıkların toplamı.

### 3.2 Ana sonuç: 90 gün, öğrenci modelle aynı hızda unutuyor

| Yöntem | Tekrar/gün (ortalama) | Tekrar/gün (son 30 gün) | En yoğun gün | Aynı gün yeniden | Tekrarda doğru | Sondaki hatırlama | Hatırlanan kelime (900'den) | Toplam cevap |
|---|---|---|---|---|---|---|---|---|
| Leitner (main) | 56,0 | 74,5 | 93 | 7,2 | %91,6 | %96,1 | 865 | 6589 |
| Leitner + iki kutu düşme | 54,4 | 71,5 | 88 | 7,1 | %91,4 | %95,8 | 862 | 6434 |
| Leitner + iki kutu düşme + tazeleme 30/60/120 | 54,3 | 71,3 | 88 | 7,1 | %91,4 | %95,8 | 862 | 6428 |
| **FSRS-6, hedef 0,90** | **37,2** | **49,8** | **64** | 9,6 | %88,9 | %94,8 | 853 | 5119 |

Tohumlar arası standart sapma en çok ±1,0 tekrar/gün ve ±0,17 puan hatırlama. Farklar bundan çok büyük.

**FSRS'in hedefi değişince:**

| FSRS hedefi | Tekrar/gün (ortalama) | Tekrar/gün (son 30 gün) | Tekrarda doğru | Sondaki hatırlama | Hatırlanan kelime |
|---|---|---|---|---|---|
| 0,70 | 13,5 | 19,1 | %70,1 | %83,4 | 751 |
| 0,75 | 16,9 | 23,4 | %75,5 | %86,5 | 779 |
| 0,80 | 20,8 | 28,0 | %79,5 | %89,2 | 802 |
| 0,85 | 27,3 | 36,4 | %84,2 | %92,4 | 832 |
| 0,90 | 37,2 | 49,8 | %88,9 | %94,8 | 853 |
| 0,95 | 61,6 | 82,5 | %93,6 | %97,2 | 875 |

**Ne gösteriyor:**
- **Hedef 0,90, Leitner'e göre:**
  - günlük tekrar −%34 (56,0 → 37,2);
  - en yoğun gün 93 → 64;
  - toplam cevap −%22;
  - buna karşılık hatırlama −1,3 puan; 900 kelimeden 12 kelime az.
- **Aynı yükte:** Leitner'in 56,0 tekrarı FSRS'te yaklaşık 0,94 hedefine denk gelir. Orada hatırlama yaklaşık %96,7, yani +0,6 puan ve yaklaşık +5 kelime. Bu sayılar iki tablo satırı arasında doğrusal ara değerle bulundu; kaba tahmin.
- **Aynı hatırlamada (%96,1):** FSRS günde yaklaşık 50,4 tekrar ister, yani −%10.
- **FSRS'in asıl kazancı tek bir düğme.** Hedef hatırlamayı seçerek yük ile hatırlama arasında bilerek takas yapılabiliyor. Leitner'de böyle bir düğme yok.
- **Aynı gün yeniden sorma artıyor (7,2 → 9,6).** Artışın tamamı "Zor"dan geliyor:
  - Adım içindeki kelimeye "Zor" denince FSRS onu 15 dakika sonra yine soruyor; Leitner ertesi güne bırakıyor. Bu, FSRS'te günde 3,1 soru.
  - "Bilemedim"den gelen yeniden sormalar FSRS'te daha az: 6,5'e karşı 7,2.
- **"Tekrarda doğru" hedeften düşük (%88,9, hedef %90):** aralıklar tam güne yuvarlanıyor ve en az 1 gün. İlk cevabı "Bilemedim" olan kelimenin S'si 1 günden küçük (0,25); 1 gün sonra %78 civarında hatırlanıyor.

### 3.3 İki kutu düşme kuralı (is3-tekrar)

Bu kural `Leitner.swift`'i değiştiriyor ve şu an başka bir oturumda. Simülasyonda etkisi küçük:
- 90 günde günlük tekrar −1,6 (−%3), hatırlama −0,3 puan;
- 365 günde günlük tekrar −2,5, hatırlama −0,3 puan.

Kural birleşince bu belgedeki "Leitner" sayıları neredeyse değişmez; FSRS kararını etkilemez. FSRS'e geçince kural da biter: yanlış cevaptan sonraki aralığı FSRS'in yanlış cevap formülü belirler.

### 3.4 Duyarlılık: varsayılan parametreler bu öğrenciye uymazsa

Yukarıdaki sonuç FSRS'i kayırıyor: öğrencinin hafızası FSRS'in kendisi olduğu için FSRS'in tahmini tanım gereği doğru. Gerçekte varsayılan parametreler Anki kullanıcılarından geliyor; Lockglow'un kullanıcısı yeni İngilizce kelime öğrenen bir A2 öğrencisi. Öğrencinin unutma süresi bir katsayıyla çarpılarak iki sapma denendi (90 gün):

| Senaryo | Yöntem | Tekrar/gün | Sondaki hatırlama | Hatırlanan kelime | Tekrarda doğru |
|---|---|---|---|---|---|
| 3 kat hızlı unutuyor (FSRS'in %90 dediği anda gerçekte %81) | Leitner (main) | 60,6 | %93,7 | 844 | %85,7 |
| | FSRS 0,90 | 47,1 | %92,9 | 836 | %83,3 |
| | FSRS 0,95 | 73,8 | %96,2 | 866 | %90,1 |
| 2 kat yavaş unutuyor (gerçekte %94) | Leitner (main) | 54,3 | %97,0 | 873 | %94,0 |
| | FSRS 0,90 | 33,8 | %95,7 | 861 | %91,5 |
| | FSRS 0,95 | 56,4 | %97,6 | 879 | %95,2 |

Üç senaryoda da sonuç aynı yönde (doğrusal ara değerle):
- Aynı yükte FSRS +0,4–0,9 puan önde (temel senaryoda +0,6).
- Aynı hatırlamada %9–12 daha az tekrar istiyor.
- Hedef 0,90'da yükü %22–38 azaltıyor, hatırlamayı 0,8–1,3 puan düşürüyor.

Hızlı unutan öğrencide FSRS hedefi tutturamıyor: %90 isteniyor, %83 oluyor. Bunu düzeltecek olan, kişisel parametrelerin öğrencinin kendi tekrar günlüğünden hesaplanması. Bunun için günlük şart (bölüm 4).

### 3.5 Uzun vade: 365 gün

1.000 kelimenin hepsi 100. güne kadar tanıtılıyor; öğrenci modelle aynı hızda unutuyor.

| Yöntem | Tekrar/gün (ortalama) | Tekrar/gün (son 30 gün) | Sondaki hatırlama | Hatırlanan kelime (1.000'den) |
|---|---|---|---|---|
| Leitner (main) | 48,9 | 42,0 | %98,5 | 985 |
| Leitner + iki kutu düşme | 46,4 | 39,9 | %98,2 | 982 |
| Leitner + iki kutu düşme + tazeleme 30/60/120 | 30,5 | 13,0 | %95,7 | 957 |
| FSRS-6, hedef 0,85 | 17,9 | 8,7 | %92,2 | 922 |
| FSRS-6, hedef 0,90 | 24,6 | 12,1 | %94,8 | 948 |
| FSRS-6, hedef 0,95 | 41,5 | 21,2 | %97,4 | 974 |

- **Bugünkü Leitner** bilinen her kelimeyi 30 günde bir soruyor. 1.000 kelimede bu, sonsuza kadar günde yaklaşık 33 tazeleme demek. Yüksek hatırlamanın (%98,5) bedeli bu.
- **FSRS 0,90, Leitner'e göre:**
  - ortalama yük −%50 (48,9 → 24,6);
  - son 30 günün yükü −%71 (42,0 → 12,1);
  - buna karşılık hatırlama −3,7 puan (%98,5 → %94,8); 1.000 kelimeden 37 kelime az.
  - 90 günde bu kayıp 1,3 puandı; süre uzadıkça büyüyor.
- **Aynı yükte üstünlük yok.** FSRS'i Leitner'in ortalama yüküne (48,9) çıkarmak için hedefi 0,95'in üstüne almak gerekiyor. Tablodaki çizgi uzatılınca hatırlama yaklaşık %98,4–98,5 çıkıyor, Leitner'le aynı. Bu sayı tablonun dışına uzatılmış bir tahmin.
- **Büyüyen tazeleme** FSRS'e çok benzer bir seçim:
  - son ayın yükü 42,0 → 13,0;
  - hatırlama −2,8 puan (%98,5 → %95,7); 28 kelime az.
  - FSRS 0,90'ın sayıları da yakın: 12,1 ve %94,8.
  - Uzun vadeli yük kazancının çoğu FSRS'e geçmeden alınabiliyor, ama aynı hatırlama kaybıyla.
- **Büyüyen tazeleme 90 günde hiçbir şey değiştirmiyor** (3.2'deki satır neredeyse aynı). Hep "Bildim" denen kelime 31. günde "bilinen" olur (hep "Kolay" ile 26. günde), ilk tazelemesi 30 gün sonra gelir; kural ancak 2–3. aydan sonra işe yarar.

### 3.6 Sınırlar

- Öğrencinin hafıza modeli FSRS-6. FSRS'in gerçek üstünlüğü burada görünenden küçük de olabilir, büyük de. Kişisel parametrelerin katkısı bu yüzden ölçülemiyor: öğrenci zaten varsayılan modelin ta kendisi.
- Lockglow'un tekrar sorusu 4 şıklı boşluk doldurma. Şans payı (%25) modelde yok. Widget'ta görmek (exposure) de modelde yok; gerçek hayatta hatırlamayı biraz artırıyor olabilir.
- Her gün tek oturum varsayıldı; atlanan gün yok.
- "Biliyorum" (`markKnown`) ve is3-tekrar'ın 3 gün kontrolü simüle edilmedi.
- Oturum saatine bağlı sonuçlar: Leitner'in 12 saatlik "Zor"u gün içinde ikinci oturum açan kullanıcıda aynı gün gelir.

## 4. Geçiş planı

Motor `is5-fsrs`'te uygulamaya bağlandı. Kod:
- `ReviewScheduler.swift`: tek giriş noktası (`ReviewScheduler`, `LeitnerScheduler`, `SchedulerKind`).
- `FSRSScheduler.swift`: FSRS + Lockglow kuralları, `FSRSState`.
- `FSRSMigration.swift`: açma (`takeOver`) ve kapama (`handBack`).
- `FSRSParameterFit.swift`: w0…w3'ün günlükten hesabı.
- `ios/App/AppModel+Scheduler.swift`: ayar, açma/kapama, haftalık yenileme.

### 4.1 `WordProgress`'teki alanlar

İsteğe bağlı (`Optional`) alanlar. Eksik anahtar `nil` okunur, yani eski `progress.json` bozulmaz.

| Alan | JSON anahtarı | Tür | Neden |
|---|---|---|---|
| `lastReviewedAt` | `last_reviewed_at` | `Date?` | Geçen gün sayısı buradan hesaplanır. Yalnız bir cevap yazar; widget'ta görmek (`markExposure`) yazmaz. `is4-ogrenme`'de eklendi. |
| `lastGrade` | `last_grade` | `ReviewGrade?` | `QueueComposer`'ın "bugün kaçırıldı" ayrımı. `is4-ogrenme`'de eklendi. |
| `fsrs` | `fsrs` | `FSRSState?` (iç içe bir nesne) | FSRS belleği; `nil` = FSRS'in bu kelime için belleği yok. |

Plandaki dört ayrı `fsrs_…` alanı yerine tek bir iç içe nesne var. `fsrs` nesnesinin alanları:

| Alan | JSON anahtarı | Ne |
|---|---|---|
| `stability` | `stability` | S, gün |
| `difficulty` | `difficulty` | D, 1…10 |
| `phase` | `phase` | `learning` / `review` / `relearning` |
| `step` | `step` | Adımın sırası; `review`'da yok |
| `lastReviewAt` | `last_review_at` | FSRS'in bildiği son cevap: kendi cevabında tam, devraldığı kelimede tahmin |
| `reviews` | `reviews` | Bu belleğin içerdiği cevap sayısı. `WordProgress.reviews`'a eşitse bellek güncel |
| `shelfBefore` | `shelf_before` | FSRS'in son cevabından hemen önceki raf (`ProgressSummary.Shelf`, yoksa 0). Günlükten kurulan bellekte yok (4.5) |

- Okunamayan ya da sınır dışı bir `fsrs` nesnesi (sonsuz, NaN, aralık dışı) bütünüyle atılır; yerine tahmin gelir. Kelimenin geri kalanı okunur.
- `dueAt` `fsrs` içinde tutulmaz: kelimenin kendi `dueAt`'i geçerli.

**Aynen kalanlar:**
- `state`, `dueAt` (FSRS açıkken FSRS yazar), `reviews`, `lapses`, `exposures`, `knownOverride`, `saved`, `refresherStep`, `firstReviewedAt`.
- **`box` dondurulmuyor** (ilk plan dondurmaktı). FSRS açıkken de güncellenir ve **basamak** olarak kalır: FSRS beklemesinden bulunur (4.5). Böylece ekranlar, widget sırası ve hatırlatma iki zamanlayıcıda da aynı alanları okur.

**"Bilinen kelime" FSRS'te iki yoldan olur:**
- S ≥ 30 gün (gün aralığı aşamasında) ve kelime cevaptan önce 4. ya da 5. basamaktaydı (4.5). Mimari raporu "21–30 gün ve en az 2 doğru cevap" diyordu (`raporlar/04_teknik_mimari.md`); eşik Leitner'in ilk tazelemesi olan 30 gün oldu.
- Ya da kullanıcı "Biliyorum" demiştir (`knownOverride`) ve kontrol cevabı henüz gelmemiştir. Bugünkü gibi `state == .known` kalır.

**Ayrı bir dosya: `review_log.jsonl`.** `alt-ilerleme` tasarım notunda da planlı.
- Her cevap bir satır: `word_id`, `at`, `grade`, `source` (tekrar / quiz / widget kontrolü), `elapsed_days`.
- FSRS'in üç işi buna bağlı:
  1. geçişte belleği tahminle değil, tam hesapla kurmak (py-fsrs `reschedule_card`, fsrs-rs `memory_state`);
  2. kişisel parametreleri hesaplamak;
  3. parametre ya da sürüm değişince (ör. ileride FSRS-7) belleği yeniden hesaplamak.
- **En önemli adım bu ve FSRS'ten bağımsız:** ne kadar erken başlarsa geçiş o kadar doğru olur.

### 4.2 Mevcut ilerlemenin çevrilmesi

`FSRSMigration.takeOver(_:log:scheduler:now:)`. "Yeni zamanlama" açılınca çalışır.
- Önce bekleyen widget dokunuşları işlenir, sonra günlük okunur ve parametreler hesaplanır (4.3 adım 9).
- **Yalnız `fsrs` değişir.** Tarihler (`dueAt`), basamaklar, durumlar, "Yerleşti", sayaçlar aynen kalır. Ekrandaki sayılar geçiş günü değişmez.
- Dokunduğu kelimeler: en az bir kez cevaplanmış ve belleği yok ya da güncel değil (`fsrs.reviews != reviews`). Belleği güncel kelime korunur. Yani iki kez çalışsa da bir şey değişmez.
- İlerleme ayar değişmeden önce kaydedilir. Kayıt başarısız olursa ayar açılmaz, Leitner sürer.
- Sonuç bir raporda sayılır (`Report`): günlükten kurulan, tahmin edilen, korunan, belleksiz.

1. **Bütün cevapları günlükte olan kelime:** bellek günlükteki cevaplardan sırayla hesaplanır (`FSRSScheduler.replay`). Doğru bir "Biliyorum" kontrolü burada da kelimeyi bilinen yapar (4.5). Tam doğru.
2. **Cevaplarının bir kısmı günlükte olmayan kelime** (günlükten önceki, kırpılmış ya da kaybolmuş satırlar): tahmin (`estimatedCard`).
   - **S:** kelimenin kutusunun aralığı (`Leitner.intervalDays[box − 1]`: 1, 2, 4, 8, 16 gün); bilinen kelimede tazeleme beklemesi (30, `refresherStep`'e göre 60 ya da 120).
     - Gerekçe: Leitner kelimeyi bu aralıktan sonra soruyordu. Hedef 0,9 iken FSRS'te aralık = S.
     - fsrs-rs'in eski zamanlayıcıdan çevirme fonksiyonu `memory_state_from_sm2(ease, interval, retention)` da S'yi aynı yoldan kurar.
   - **D:** başlangıç D0(Bildim) = 2,12. Sonra `lapses` kadar kez "Bilemedim" zorluk güncellemesi uygulanır: 1 yanlış ≈ 7,39, 2 yanlış ≈ 9,13.
     - Zor ve Kolay da D'yi değiştirir ama Leitner bunları saklamıyor. Bir "Zor" 2,12'yi 4,75'e çıkarır; bir "Kolay" 2,12'yi 1'e, 7,39'u 6,51'e indirir. Bu yüzden tahmin kaba.
     - "Bildim" D'yi neredeyse hiç değiştirmez. D'deki hata, S'deki hatadan daha uzun sürer; ancak sonraki Zor/Kolay/Bilemedim cevaplarıyla düzelir. Günlüğü erken başlatmak için bir neden daha.
   - **Aşama:** `review`.
   - **Son cevap:** `lastReviewedAt`; yoksa `dueAt`'ten S gün önce.
3. **"Biliyorum" denmiş ama kanıtlanmamış kelime** (`knownOverride`) ve **"Tanış"a dönmüş kelime:** bellek uydurulmaz (`fsrs = nil`). Biliyorum denmiş kelime `known` kalır ve "Bildiğim kelimeler"de sayılır. Bir sonraki cevap FSRS'in ilk cevabı olur.
4. **Hiç cevaplanmamış kelime:** değişmez. İlk cevapta `initialMemory`.
5. **`dueAt` korunur.** Bütün kelimeler bir anda yeniden zamanlanmaz, yani geçiş günü yığılma olmaz. Bir sonraki cevaptan sonra FSRS zamanlar.

**Geri dönüş (FSRS kapatılırsa): `FSRSMigration.handBack(_:)`.** FSRS `state`, `box`, `dueAt` ve `refresherStep`'i Leitner'in terimleriyle yazıyor (4.5). Leitner FSRS'in bıraktığı basamaktan ve tazeleme adımından devam eder.
- Önce bekleyen widget dokunuşları işlenir, yani FSRS onları kendi kurallarıyla cevaplar. Açarken de aynı.
- **Yalnız çok uzak tarihler öne çekilir.** FSRS bir yıla kadar bekletebilir, Leitner en çok 120 gün. Son cevabı FSRS'in olan kelimenin tarihi, Leitner'in o basamaktaki beklemesinden uzaksa `lastReviewedAt` + o bekleme olur:
  - öğrenilen kelimede basamağın aralığı (`Leitner.intervalDays`: 1, 2, 4, 8, 16 gün);
  - bilinen kelimede tazeleme beklemesi (`Leitner.refresherWait`: 30, 60 ya da 120 gün).
- Tarih yalnız öne gelir, hiç geriye gitmez. Başka hiçbir alan değişmez.
- Dokunmadıkları: bekleyen "Biliyorum" kontrolü, belleği güncel olmayan kelime, günlükten kurulan bellek (`shelfBefore` yok: son cevap FSRS'in değil). İki kez çalışsa da bir şey değişmez.
- Değişen bir şey varsa ilerleme ayar değişmeden önce kaydedilir. Kayıt başarısız olursa ayar kapanmaz.

**Bayatlayan bellek.** Bellekler dosyada kalır. Ayar kapalıyken Leitner bir kelimeyi cevaplayınca o kelimenin `fsrs.reviews`'ı artık `reviews`'a eşit olmaz; bellek güncel sayılmaz. Bellek şu zamanlarda yeniden kurulur:
- ayar bir sonraki açılışında (`takeOver`);
- ayar açıkken haftalık yenilemede (`refreshFSRSIfDue`): güncel olmayan kelime varsa hemen, yoksa 7 günde bir;
- o arada FSRS bu kelimeyi cevaplarsa, cevaptan önce tahminle (`card(of:at:)`).

### 4.3 Bağlama adımları

| Adım | Durum |
|---|---|
| 1. Günlük, `lastReviewedAt`, `lastGrade` | Yapıldı (`is4-ogrenme`) |
| 2. Tek giriş noktası, ayar | Yapıldı (`is5-fsrs`) |
| 3. Çeviri, sayaçlar | Yapıldı (`is5-fsrs`) |
| 4. Hedef 0,90, adımlar 10 dk | Yapıldı (`is5-fsrs`); "Tekrar temposu" açık |
| 5. Bilinen kelime | Yapıldı (`is5-fsrs`) |
| 6. `QueueComposer.lastAnswer` | Yapıldı (`is4-ogrenme`) |
| 7. Düğme süreleri | Yapıldı (`is5-fsrs`) |
| 8. Gün sınırı 04:00 | **Açık** |
| 9. Kişisel parametreler | Kısmen (`is5-fsrs`): cihazda yalnız w0…w3; tam eniyileme açık |

1. **Yapıldı.** `review_log.jsonl` yazmaya başla; `WordProgress`'e `lastReviewedAt` ve `lastGrade` ekle. Leitner de yazsın.
2. **Yapıldı.** Tek bir giriş noktası: `ReviewScheduler.review(_:grade:at:) -> WordProgress` (`LeitnerScheduler`, `FSRSScheduler`).
   - Tekrar, hatırlama ekranı, "Biliyorum" kontrolü, widget'ın "Bilmiyorum"u (`ProgressIngest`) ve düğme süreleri bunu çağırır (`AppModel.reviewScheduler`).
   - Seçim: "Ayarlar → Yeni zamanlama (deneme)", tercih anahtarı `lockglow.scheduler` (`leitner` / `fsrs`). Varsayılan ve bilinmeyen değer Leitner.
   - Görmek, "Biliyorum" ve geri alması cevap değil: ikisinde de `Leitner.markExposure`, `markKnown`, `undoKnown`.
3. **Yapıldı.** `WordProgress` ↔ `FSRSCard` çevirisi. Sayaçlar Leitner'deki gibi işler:
   - her cevapta `reviews += 1`, `lastSeenAt`, `lastReviewedAt`, `lastGrade`; ilk cevapta `firstReviewedAt`;
   - basamaktaki ya da bilinen kelimede "Bilemedim" `lapses += 1` yapar; "Bilemedim" `knownOverride`'ı kaldırır.
   - Bu yüzden günlük iki zamanlayıcıdan da aynı satırları alır.
4. **Yapıldı.** `FSRS.lockglowSettings`: `learningSteps: [600]`, `relearningSteps: [600]`, hedef 0,90, en uzun bekleme 365 gün (`FSRSScheduler.maximumIntervalDays`; Leitner'in en uzunu 120 gün).
   - **Açık:** isteğe bağlı bir "Tekrar temposu" ayarı: Rahat 0,85 / Dengeli 0,90 / Yoğun 0,95.
   - 0,95'i "yük yaklaşık %65 artar" diye açıkla (simülasyonda 90 günde %66, 365 günde %69).
5. **Yapıldı.** Bilinen kelime: 4–5. basamakta S ≥ 30 gün ya da bekleyen "Biliyorum" (4.1). "Bildiğim kelimeler" listesi ve widget'ın tazeleme slotu `state == .known`'u okur, FSRS bunu yazar (4.5).
6. **Yapıldı.** `QueueComposer.lastAnswer` aralık eşleştirmesi yerine `lastReviewedAt` ve `lastGrade` kullanmalı.
   - Bugün `dueAt − lastSeenAt` farkını Leitner'in aralıklarıyla karşılaştırıyor; FSRS aralıklarında bu eşleşme tutmaz (is3-widgetsira notu).
   - Hata güvenli tarafta olur (kelime yalnız gizlenir), ama "bugün cevaplananlar önce" kuralı sessizce çalışmaz.
   - `QueueComposerTests` gerçek `Leitner.review` ile kurulu; bilerek kırılır.
7. **Yapıldı. Düğme etiketleri.** Tasarım önerisi "Bildim · yarın", "Kolay · 2 gün" gibi süreler yazıyor. FSRS'te bu süreler kelimeye göre değişir. `AppModel.dueDate(ifAnswering:for:now:)` seçili zamanlayıcının `review`'unu bir kopya üstünde çağırır; süreler iki zamanlayıcıda da doğru.
8. **Açık. Gün sınırı.** FSRS 24 saatin katlarıyla sayar: akşam 23:00'teki cevap iki gün sonra 23:00'te "zamanı gelmiş" olur. Anki günü sabah 04:00'te başlatır. Tekrar listesi "bugün"ü yerel 04:00'ten saymalı ki kelime sabah oturumunda gelsin.
9. **Kısmen yapıldı. Kişisel parametreler.**
   - Anki kılavuzu "birkaç yüzden az tekrar" ile eniyilemenin iyi çalışmadığını söylüyor.
   - **Cihazda, yalnız w0…w3** (dört notun ilk kararlılığı): `FSRSParameterFit.fit(_:base:)`. fsrs-rs'in "pretrain" adımının sade bir kopyası. Saf, belirlenimci, dosya okumaz.
     - Örnek: günlükte ilk cevabı olan kelime (`reviews == 1`, `seed` yok, "Biliyorum" kontrolü değil) ve en az bir tam gün sonra gelen ikinci cevabı. Örnek = (ilk not, geçen tam gün, ikinci cevap doğru mu).
     - Her not için unutma eğrisine en uyan S aranır (log ızgara, sonra altın oran araması; S 0,1…100 gün).
     - **Şans payı:** ikinci cevap çoğu zaman 4 şıklı cloze. Kelimeyi unutan öğrenci de dörtte bir doğru şıkkı seçer. Bu yüzden doğru cevabın olasılığı R değil, 0,25 + 0,75 · R (`guessChance`). Yoksa şanslı seçimler hafıza sayılır, ilk S'ler şişer (4.4'teki şans payı riski). Günlük soru türünü yazmıyor; payı her örneğe uygulanır.
     - Varsayılana çekme: log ölçeğinde 32 sahte örnek ağırlığıyla (`priorWeight`). Sonra `FSRS.weightBounds` içine sıkıştırılır ve w0 ≤ w1 ≤ w2 ≤ w3 sıralanır.
     - Bir notta 16'dan az örnek (`minimumSamples`): o not varsayılanda kalır.
     - Günlükte 400'den az cevap (`minimumAnswers`): bütün parametreler varsayılan.
     - Sonuç `FSRS.areValid(weights:)`'ten geçmezse varsayılan. w4…w20 hep varsayılan.
   - Ne zaman: ayar açılırken ve açıkken haftada bir (`refreshFSRSIfDue`, `fsrsRefitInterval` 7 gün). Günlük ana iş parçacığının dışında okunur. Parametreler `lockglow.fsrsWeights`'te; okunurken yine `areValid` ile denetlenir.
   - Ayarlar ekranı kaç cevaptan hesaplandığını ve parametrelerin kişisel olup olmadığını gösterir (`fsrsFitSummary`). "İlerlemeyi sıfırla" parametreleri siler. Sıfırlamadan önce günlüğü okumuş bir yenileme sonucunu yazmaz (`AppPreferences.fsrsFitGeneration`).
   - **Açık:** bütün parametrelerin tam eniyilemesi. Günlük dışa aktarılır, py-fsrs'in eniyileyicisiyle (PyTorch ister) bilgisayarda hesaplanır, `FSRS.areValid(weights:)` ile denetlenip uygulamaya yazılır. Cihaz içinde tam eniyileme Swift'te yok; fsrs-rs'i iOS'a derlemek ağır bir iş.

### 4.4 Riskler

| Risk | Etki | Önlem |
|---|---|---|
| Simülasyon FSRS'i kayırıyor (hafıza modeli FSRS'in kendisi) | Gerçek kazanç daha küçük olabilir | Ayarın arkasında aç; günlükle gerçek doğru oranını izle (hedef 0,90 → simülasyonda %89) |
| Varsayılan parametreler A2 öğrencisine uymayabilir | Hedef tutmaz: 3 kat hızlı unutan öğrencide %90 yerine %83 | Günlük + kişisel parametreler; o zamana kadar gerçek doğru oranı %80'in altındaysa hedefi yükselt |
| Uzun vadede daha düşük hatırlama | 365 günde hedef 0,90 Leitner'den 3,7 puan aşağıda | Bilerek seçilen bir takas; daha yüksek hatırlama istenirse hedef 0,93–0,95 |
| 4 şıklı soruda şans payı (%25) | Şansla doğru cevap "hatırladı" sayılır, S şişer, aralıklar uzar | Uzun aralıkta daha zor soru türü (ogrenme_ilkeleri 2.4: "soru türü kutuya göre değişir"). FSRS'te basamak S'den bulunduğu için soru türü de S'ye bağlı (4.5). "Yerleşti"ye yalnız 4–5. basamaktan, hatırlama sorusuyla geçilir (4.5). Parametre hesabı şans payını hesaba katar (4.3 adım 9) |
| "Zor"un unutulan kelimede kullanılması | FSRS "Zor"u doğru sayar, aralıklar fazla uzar (Anki kılavuzunun en büyük uyarısı) | Düğme metni "Zor ama bildim" (tasarım önerisi); unutan "Bilemedim"e basmalı |
| `lastSeenAt` widget'ta da değişiyor | Yanlış geçen gün sayısı → yanlış S | `lastReviewedAt` (4.1) |
| `QueueComposer` Leitner aralıklarını tanıyor | "Bugün cevaplananlar önce" kuralı sessizce bozulur | 4.3 adım 6 |
| Geçişte tahmin edilen S ve D | İlk tekrarlar biraz erken ya da geç; D'deki hata daha uzun sürer | Günlüğü şimdi başlat; `dueAt` korunur |
| Aynı gün yeniden sorma artar (7,2 → 9,6/gün) | Tur biraz uzar. Neden: FSRS adım içindeki "Zor"u 15 dakika sonra yeniden sorar (Leitner'de 12 saat) | Lockglow'da adım içindeki "Zor" en az 12 saat bekler (4.5); fark yalnız "Bilemedim"de kalır. Adımları boşaltmak (`[]`) çözüm değil: o zaman "Bilemedim" de 1 gün sonraya kalır |
| "Bildiğim kelimeler" sayısı geçiş günü değişir | Kullanıcı şaşırır | Geçişte bilinen kelimelere S = 30 verilir (eşik 30); "Biliyorum" denmiş kelimeler bayrakla bilinen kalır (4.1). Sayı korunur |
| Bozuk ya da sınır dışı parametre (ör. eniyileyici çıktısı) | Sonsuz/NaN aralık, uygulama durur | Yüklemeden önce `FSRS.areValid(weights:)`; geçmezse varsayılan parametreler |
| FSRS-7 ve parametre değişiklikleri | Bellek yeniden hesaplanmalı | Günlük varsa tek seferlik yeniden hesap |
| 32 bit / 64 bit ve yuvarlama farkları | fsrs-rs ile milyonda 1 fark | Testlerde tolerans; py-fsrs ile aynı yuvarlama |

### 4.5 FSRS'te basamak

Ekranlar, widget sırası, soru türü ve İlerleme "basamak"ı (`box`) okuyor. FSRS'in kendi basamağı yok. Bu yüzden FSRS açıkken basamak FSRS beklemesinden bulunur (`FSRSScheduler.box(forStability:)`).

**Tanım:** basamak, FSRS beklemesinin ulaştığı son Leitner basamağı. Hedef 0,9 iken FSRS beklemesi = S. Leitner'in beklemeleri 1, 2, 4, 8, 16 gün (`Leitner.intervalDays`).

| S (gün) | Basamak | Sonraki soru (yaklaşık) |
|---|---|---|
| 2'den az | 1 | 2 günden önce |
| 2 – 4 | 2 | 2–4 gün |
| 4 – 8 | 3 | 4–8 gün |
| 8 – 16 | 4 | 8–16 gün |
| 16 ve üstü | 5 | en çok 16 gün |
| 30 ve üstü, 4–5. basamaktan (gün aralığı aşamasında) | **Yerleşti** (bilinen, basamak 5) | 30 gün ve sonrası, en çok 365 |

Böylece 3. basamaktaki kelime Leitner'deki gibi 4–8 gün sonra gelir.

**Henüz bilinmeyen kelime en çok 16 gün bekler** (`FSRSScheduler.unprovenMaximumWait`, Leitner'in 5. basamağı). S daha büyük olsa da sonraki soru 16 gün içinde gelir.

**İstisna: yeni kelime 1. basamaktan başlar.** Basamakta olmayan kelime (yeni, ya da "Tanış"a dönmüş) ilk cevabıyla hep 1. basamağa gelir, ilk beklemesi ne olursa olsun. Örnek: "Hatırla"da "Bildim" 2 gün bekletir (S0 = 2,31) ama kelime 1. basamaktadır. ("Hatırla" yalnız Bildim, Zor ve Bilemedim verir.)
- Neden: ilk gerçek soru yazılmış cloze (ogrenme_ilkeleri 1.2, 2.4). 4 şıklı "Hatırla" bunu kanıtlamaz.
- İlerleme de "ilk turun kelimeleri ilk basamağa gelir" diyor.
- Sonraki doğru cevap kelimeyi yeni S'nin basamağına taşır. Örnek: 2 gün sonra "Bildim" → S ≈ 10,8 → 4. basamak.

**İki sakin kural:**
- Doğru cevap basamağı hiç indirmez ve bilinen kelimeyi "Yerleşti"den hiç çıkarmaz. S'nin basamağı kelimenin şimdiki basamağından düşük olabilir (ör. Leitner'den gelen, belleği tahmin edilen kelimede); o zaman basamak yerinde kalır. Ekranda yalnız unutulan kelime aşağı iner (`ProgressSummary`).
- "Bilemedim" basamağı hiç yükseltmez: yeni basamak, S'nin basamağı ile önceki basamağın küçüğü.

**Yerleşme:** 4. ya da 5. basamaktaki kelime (`ReviewPlanner.recallFromBox`) gün aralığında S ≥ 30'a ulaşınca bilinen olur, basamak 5. Leitner'de kutu 5'ten çıkmak gibi.
- Neden: bu basamaklarda soru hatırlama sorusu. 4 şıklı bir tahmin kelimeyi yerleştirmemeli (ogrenme_ilkeleri 2.4).
- Daha alt basamakta S 30'a ulaşırsa kelime öğrenilen kalır, 5. basamağa çıkar (`box(forStability:)`) ve en çok 16 gün sonra hatırlama sorusuyla gelir. O soruyu bilirse yerleşir.

**Adım içinde "Zor" en az 12 saat bekler** (`FSRSScheduler.hardStepWait`, Leitner'in 1. basamaktaki "Zor"u). FSRS kelime aynı gün adımındayken (yeni kelime ya da unutulmuş kelime) "Zor"u 15 dakika sonra sorar; Lockglow'da en az 12 saat.
- Neden: ilk gerçek soru başka bir günde gelir (ogrenme_ilkeleri 1.2). Hiçbir düğme dakikayla süre vaat etmez.
- FSRS'in belleği değişmez; yalnız tarih geç olur.

**Güvenlik:** S sonlu bir sayı değilse (geçerli parametrelerle olmaz) cevabı `Leitner.review` zamanlar. Kaydedilemeyen bir tarih yazılmaz.

**Soru türü basamağa bağlı, eskisi gibi** (`ReviewPlanner`): 1–3. basamak cloze, 4–5. basamak ve bilinen kelime hatırlama (`recallFromBox = 4`).

**İlerleme'deki "bir basamak çıktı":** FSRS'te "Bildim" her zaman bir sonraki basamağa çıkarmaz. Bu yüzden yalnız gerçek çıkışlar sayılır. FSRS her cevapta cevaptan önceki rafı saklar (`FSRSState.shelfBefore`), `FSRSScheduler.lastAnswer` buna bakar:

| Son cevap | İlerleme'de |
|---|---|
| "Bilemedim" | unuttu |
| Öğrenilen kelime, öncekinden yüksek basamakta | bir basamak çıktı |
| Öğrenilen kelime, aynı basamakta ya da "Tanış"tan sonra ilk kez | yerinde kaldı |
| 4. basamaktan "Yerleşti"ye | bir basamak çıktı |
| 5. basamakta ya da "Yerleşti"de hatırlandı, doğru "Biliyorum" kontrolü | en üstte hatırlandı (Leitner'deki gibi) |

Günlükten kurulan bellekte `shelfBefore` yok; o kelimenin son cevabını Leitner'in okuması değerlendirir. Okuma ayara değil kelimenin kendi kaydına bakar: geçiş eski cevapları yanlış okutamaz.

**Tazeleme adımı (`refresherStep`):** bilinen kelimede S'den bulunur: S ≥ 60 → 1, S ≥ 120 → 2, daha azı 0 (`Leitner.refresherDays` 30/60/120). Ayar kapatılınca Leitner benzer bir beklemeyle devam eder.

**"Biliyorum" kontrolü FSRS'te** (`awaitsKnownCheck`, 3 gün sonraki tek soru):
- Doğru: kelime bilinen olur, S en az 30'a çıkarılır, sonraki soru S'nin beklemesi kadar sonra (en az 30 gün).
- Yanlış: kelime "Tanış"a döner (yeni, basamak 0, tarihsiz). FSRS'in bu cevaptan kurduğu bellek saklanır.
- Neden: ogrenme_ilkeleri 2.2. "Biliyorum" bir iddia, kontrol onu bir kez sınar; doğru kontrolden sonraki soru 30 gün sonra gelir. Bu tek cevaptan gelen S (ilk cevap, birkaç gün) bunu bozardı ve kelimeyi bilinenlerden çıkarırdı.

## 5. Öneri

1. **Şimdi: tekrar günlüğü, `lastReviewedAt` ve `lastGrade`.**
   - Küçük bir iş; QueueComposer'ın bugünkü sorununu da çözer.
   - FSRS geçişini tahminden kurtarır.
   - Kişisel parametrelerin tek kaynağıdır.
2. **v1.2: FSRS'i bir ayarın arkasında aç.**
   - Ayarlar: hedef 0,90, adımlar 10 dk / 10 dk.
   - Günlükte birkaç hafta veri birikince aç; geçişi günlükten kur.
   - **Beklenen, 90 günde:** günlük tekrar yaklaşık üçte bir azalır, hatırlama yaklaşık 1,3 puan düşer.
   - **Beklenen, bir yılda:** yük yarıya iner, hatırlama yaklaşık 3,7 puan düşer.
   - Bu takas istenmiyorsa hedef 0,93–0,95. 90 günde 0,94, Leitner'in yükünde ondan biraz daha iyi hatırlama veriyor.
3. **Sonra: kişisel parametreler.** Birkaç yüz tekrar birikince bilgisayarda hesapla. Öğrenci varsayılan modelden farklıysa FSRS hedefi ancak böyle tutturur. Leitner'in hiç yapamadığı, FSRS'in asıl farkı bu; ama bu simülasyon değerini ölçemiyor.
4. **FSRS 2–3 aydan uzun gecikecekse arada Leitner'e "tazeleme 30 → 60 → 120 gün".**
   - Bir yıl sonra günlük yükü 42,0'dan 13,0'a indiriyor, hatırlamayı 2,8 puan düşürüyor.
   - 90 güne kadar etkisi yok.
   - Kod küçük; kayma kuralıyla birlikte is3-tekrar'ın işine eklenebilir.
   - FSRS yakında gelecekse gerek yok: FSRS bu kuralın yerini alır.
5. **Hedef 0,95'in üstüne çıkma.** Yük 0,90'a göre %66 artıyor; Anki de %97'nin altını öneriyor.

## Kaynaklar

- FSRS algoritma belgesi (FSRS-6 formülleri ve varsayılan parametreler): https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm (eski adres https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm buraya yönlendiriyor)
- py-fsrs v6.3.2, zamanlayıcı: https://github.com/open-spaced-repetition/py-fsrs/blob/v6.3.2/fsrs/scheduler.py
- py-fsrs v6.3.2, testler: https://github.com/open-spaced-repetition/py-fsrs/blob/v6.3.2/tests/test_basic.py
- fsrs-rs v6.6.2, model: https://github.com/open-spaced-repetition/fsrs-rs/blob/v6.6.2/src/model.rs
- fsrs-rs v6.6.2, çıkarım ve testler (`test_memory_state`, `test_next_states`, `test_next_interval`, `memory_state_from_sm2`): https://github.com/open-spaced-repetition/fsrs-rs/blob/v6.6.2/src/inference.rs
- fsrs-rs v6.6.2, simülatör varsayılanları (`SimulatorConfig`): https://github.com/open-spaced-repetition/fsrs-rs/blob/v6.6.2/src/simulation.rs
- fsrs-rs ana dal (FSRS-7 varsayılan, yayımlanmamış): https://github.com/open-spaced-repetition/fsrs-rs/blob/main/src/model.rs
- Anki'nin fsrs sürümü: https://github.com/ankitects/anki/blob/main/Cargo.toml
- Anki kılavuzu, FSRS ve hedef hatırlama: https://docs.ankiweb.net/deck-options.html#fsrs (kaynak: https://github.com/ankitects/anki-manual/blob/main/src/deck-options.md)
- swift-fsrs: https://github.com/open-spaced-repetition/swift-fsrs
