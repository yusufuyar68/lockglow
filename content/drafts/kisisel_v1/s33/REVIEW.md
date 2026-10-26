# s33 QA incelemesi (YDS/YÖKDİL Çekirdek 1: akademik fiiller)

Kapsam: `content/drafts/kisisel_v1/s33/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: YDS ve YÖKDİL okuma parçalarında sık geçen akademik fiiller. Seviye: 47 C1, 13 B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** bir yazar ajanı, `1_yazar_kurallari.md`, s32 biçimi.
2. **Denetim:** bir denetçi ajanı (bu rapor), `2_denetci_kurallari.md` ve B2 turu denetimlerinden çıkan tuzak listesi. 60 kart tek tek okundu. Her kartta şunlara bakıldı:
   - anlam ve tek anlam kuralı (sense_note, tanımlar, örnekler, eşdizimler, `alt`, quiz)
   - örneklerin geri çevirisi
   - gloss ve gloss_short
   - hata maddeleri
   - quiz'de her şıkkın boşluğa konarak denenmesi
   - IPA ve seviye

   Yazarın "emin olmadığım" maddeleri ayrıca tartıldı (aşağıda).

## Özet

- İncelenen kart: **60** (C1: 47, B2: 13). Hepsi `type: word`, `pos: v`, `sense_no: 1`.
- `primary_topic`: hepsi `yds_yokdil_core`. `tags.exams`: `["yds", "yokdil"]`. `sensitivity`: hepsi 0.
- Değişen kart: **5** (`critic_edited`), **10** alan.
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: hepsi `null`. Sahte dost yok.
- **Kilit ekranı anlamı:** 60 kartın hepsinde ≤16 karakter (46 kartta `gloss_short`, hepsi ana anlamın kısaltması).
- **confusables:** 24 kartta; boş dizi yok.
- **mistakes:** 8 kartta 8 madde; hepsi kaldı (aşağıda).
- **Çeldirici:** 118 farklı şık. En sık olanlar 4'er soruda geçiyor: exceed, neglect, exert, undergo, inhibit, persist. Sınır max(4, %5) = 4.
- **IPA:** US `ɜːr/ər`, ɝ/ɚ yok. DRESS ünlüsü 5/5 `/ɛ/`.
- **Örnek isimleri:** "Can" yok. Notların hepsinde "sen" hitabı var.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Quiz'de sınırda ikinci okuma.**
     - alter: "convey its plans", yani planlarını bildirmek, dilbilgisi ve anlam olarak olabiliyordu.
     - transform: "was modified into a … center" sınırda kabul edilebiliyordu ("modified into a hospital ship" gibi kullanımlar var).
     - Her iki şık da cümleye hiç uymayan şıklarla değişti.
  2. **Ana anlama ikinci bir anlam karışması.**
     - impose: ana anlamdaki "dayatmak" (impose your views on sb) kartın "vergi ya da yasak getirmek" anlamından ayrı bir anlam.
     - impose: eş anlamlı olarak verilen "enforce" var olan bir kuralı uygulatmak demek; o da başka bir anlam.
     - comprise: "include" bütünün yalnızca bir kısmını anlatır, "-den oluşmak" demek değildir.
  3. **Kilit ekranında zayıf karşılık.** eliminate'in kısa anlamı "gidermek"ti. Bu, örneklerdeki "tamamen ortadan kaldırmak" anlamını taşımıyor ve "susuzluğu gidermek" gibi okunuyor.
- **Quiz'ler:** geri kalanı tek cevaplı. Geçişsiz fiil tuzakları (sustain, trigger, modify) ve edat tuzakları (prohibit/deprive "from" ve "of", coincide "with") YDS'nin soru tarzına uygun.
- **Örnekler:** kısa, akademik ya da haber üslubunda ve B2 okurun çözebileceği uzunlukta. Amerikan yazımı tutarlı (center, behavior, program).
- **Tek anlam:** derive, constitute, comprise, restore, yield, adopt, foster, inhibit ve trigger'da başka anlamlar örneklere, eşdizimlere ya da `alt`'a sızmamış.

## Yazarın "emin olmadığım" maddeleri

1. **Hata maddeleri:** sekizi de kaldı.
   - **intervene to the crisis:** Türkçedeki "krize müdahale etmek" -e hâli alıyor; Türk öğrenci yazılarında gerçekten görülen bir hata.
   - **compensate a bad diet:** "telafi etmek" Türkçede geçişli; edatın düşmesi tipik bir hata.
   - **enable to save time:** "zaman kazanmayı sağlar" nesnesiz kuruluyor. Hata Türk öğrencilerde çok sık görülüyor.
   - **facilitate students to learn, prohibit sb to do:** Türkçeye özgü değil, genel öğrenci hataları. Gerçek oldukları için kaldılar; `why` alanları hatayı zaten başka İngilizce kalıpların taşınmasına bağlıyor, Türkçeye değil.
   - **comprise of, deprive from, adapt/adopt:** sağlam.
2. **Kısa anlamlar:**
   - **exert "baskı uygulamak":** kaldı. YDS çevirilerinde en sık karşılık bu; "etki" kullanımı `alt`'ta ("etki etmek") ve örneklerde görünüyor.
   - **impose "yasak getirmek":** ana anlam "(yasak/vergi) getirmek" oldu, kısa anlam kaldı. "Dayatmak" başka bir anlam olduğu için çıktı.
   - **eliminate "gidermek":** ana anlam "yok etmek, ortadan kaldırmak", kısa anlam "yok etmek" oldu. "Gidermek" `alt`'a geçti.
   - **ensure "sağlamak":** kaldı. YDS'de ensure'ın standart karşılığı bu; `alt`'taki "güvence altına almak" ve notta anlatılan insure/assure farkı anlamı yeterince netleştiriyor.
3. **Quiz sınırları:** dört soru da her şık boşluğa konarak yeniden denendi; hepsi tek doğru cevaplı.
   - **comprise:** "consists" ("of" eksik), "constitutes" (yön ters: parçalar özne olur) ve "composes" ("is composed of" gerekir) hepsi yanlış.
   - **sustain:** deteriorate, persist ve emerge bu cümlede nesne alamıyor ("cannot deteriorate this rate of growth" olmuyor).
   - **confine:** "was committed to one room" anlamsız.
   - **restore:** "to retain the damaged bridge" bağlamda anlamsız (köprüyü yeniden yapmak gerekiyor).
4. **IPA:** ensure UK `/ɪnˈʃʊə/` ve foster US `/ˈfɑːstər/` kaldı. İkisi de sözlüklerde verilen geçerli okunuşlar (Oxford `/ɪnˈʃʊə(r)/`, Merriam-Webster `ˈfä-stər` de veriyor).
5. **Tek anlam:** derive, restore ve comprise'daki daraltmalar doğru karar. İkinci anlamlar ayrı kart olarak sonra eklenebilir (derive from = kaynaklanmak, restore order, be comprised of).

## Değişiklik tablosu

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| comprise | synonyms | [consist of, include] → [consist of, be made up of] | "include" bütünün bir kısmını anlatır; "-den oluşmak" anlamının eşi değil. |
| impose | l1.tr.gloss | "(yasak) getirmek, dayatmak" → "(yasak/vergi) getirmek" | "Dayatmak" (impose your views on sb) ikinci bir anlam. Vergi anlamı ana anlama girdi; 2. örnek ve quiz vergi ve para cezasıyla ilgili. |
| impose | synonyms | [introduce, enforce] → [introduce, levy] | "enforce" var olan kuralı uygulatmak demek, başka anlam; "levy" (vergi koymak) aynı anlam. |

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| alter | quiz.distractors | convey → undergo | "had to convey its plans because of the crisis" (planlarını bildirmek) olabiliyordu. |
| alter | quiz.distractors | deprive → obtain | deprive biçimleri (deprive/deprives/deprived) akışta 8 soruda çeldiriciydi, 7'ye indi. "had to obtain its plans" anlamsız. |

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| eliminate | l1.tr.gloss | "gidermek, ortadan kaldırmak" → "yok etmek, ortadan kaldırmak" | "Gidermek" tek başına "susuzluğu gidermek" gibi zayıf okunuyor; kart "tamamen ortadan kaldırmak" anlamında. |
| eliminate | l1.tr.gloss_short | "gidermek" → "yok etmek" | Yeni ana anlamın kısaltması. |
| eliminate | l1.tr.alt | [yok etmek, tamamen çıkarmak] → [gidermek, tamamen çıkarmak] | Eski ana anlam `alt`'a geçti. |

#### part_04
Değişiklik yok. Bütün quiz'ler denendi.
- **neglect:** "restored" şıkkı "and are now in poor condition" ile çelişiyor; bu yüzden yanlış ve kaldı.
- **compensate:** "compete for a poor diet" anlamsız.

#### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| transform | quiz.distractors | modified → specified | "was modified into a busy tourist center" sınırda kabul edilebiliyordu; "specified into" olmuyor. |

part_05'in geri kalanı denendi:
- **adopt:** gerçek tuzak "adapt" şıklarda yok; "decided to adapt the new system" savunulabilirdi, olmaması doğru.
- **deprive:** "rob" doğru olurdu ama şıklarda yok.
- **coincide:** "collide with the opening" anlamsız.

## Seviye (kartlar silinmedi, seviye değiştirilmedi)

- **B2 verilenler** (13 kart): acquire, alter, assess, obtain, indicate, ensure, enable, establish, pursue, restore, justify, adopt, transform. Hepsi EVP/Oxford 3000'de B1–B2 aralığında; B2 makul.
- **B2'ye yakın C1'ler:** emerge, perceive, retain, ve ayrıca exceed, modify, eliminate, anticipate. Oxford 5000'de B2 görünenler var. YDS çekirdek destesinde C1 olarak kalmaları zararsız; karar kullanıcıda.
- **C1'den yukarı olabilecekler:** yok. confine, deprive, inhibit ve foster C1'in üst ucunda ama YDS metinlerinde sık.

## Anadili Türkçe birinin bakması gerekenler

1. **Hata maddelerinin sıklığı:** "intervened to the crisis", "compensate a bad diet", "enables to save time".
2. **Kilit ekranı karşılıkları:**
   - exert "baskı uygulamak": etki anlamı kayboluyor mu?
   - impose "yasak getirmek": vergi anlamı yeterince seziliyor mu?
   - eliminate "yok etmek" (yeni): "ortadan kaldırmak"tan sert mi?
   - ensure "sağlamak": "provide" gibi mi okunuyor?
   - coincide "denk gelmek".
3. **Örnek çevirileri:**
   - exert "Ebeveynler çocukları üzerinde güçlü bir etki uygular." Doğal mı, yoksa "güçlü bir etkiye sahiptir" mi denmeli?
   - modify "Kurs, yetişkin öğrencilere uyması için uyarlandı." Burada "uyarlamak" adapt'e mi kayıyor?

## Çeldirici ve IPA son kontrolü (2026-10-26)

- `distractor_stats.py`: `s33: 60 quizzes, 118 distinct distractors; top: exceed×4, neglect×4, exert×4, undergo×4, inhibit×4, persist×4`. Sınır max(4, %5) = 4; aşan yok.
- **Sözcük ailesi bazında yük:** deprive (deprive/deprives/deprived) 7 ve exceed (exceed/exceeds/exceeded) 9 soruda geçiyor. Biçim başına sınır aşılmıyor; yine de sonraki akışlarda bu ikisinin çeldirici olarak daha az kullanılması iyi olur.
- `ipa_dress_stats.py`: `s33 {'uk_e': 0, 'uk_ɛ': 5, 'us_e': 0, 'us_ɛ': 5}`. Düzeltme gerekmedi.

## Son doğrulama

`python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s33` → `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

İki denetçi (Türkçe ve İngilizce gözü) s33–s36'dan alınan 48 kartlık örneklemi okudu; 21 bulgu (17 kart) kartla karşılaştırıldı: 20'si gerçek çıktı ve düzeltildi, 1'i (scarcity, 'işçi kıtlığı') gerekçesiyle reddedildi. Bulgulardaki her sistematik sorun s33–s36'nın 240 kartında tarandı: yanlış sözcük ailesi bilgisi (virtually), notla çelişen örnek ya da fazla keskin ayrım (başka yok), anlamı düşen `gloss_short` (başka yok), yerleşik olmayan Türkçe terim (başka yok), çeviri kokan Türkçe örnek (6 kart), bağlacın anlamı ve dilbilgisi (başka yok), tanım doğruluğu (başka yok), eş anlamlı inceliği ve kartın tek anlamı (precisely, perceive, stimulate), doğal olmayan eşdizim (başka yok), örneklerle uyuşmayan `grammar.pattern` (bulguyla birlikte 21 kart), kilit ekranı karşılığının quiz bağlamını karşılamaması (impose, exert) ve seviye (Oxford 3000'de B2 olan 10 kart daha B2'ye indi). 'Can' adı, 'siz' hitabı, şapkasız hâl/dâhil, IPA ve boş `confusables` yeniden tarandı; sorun yok.

- Bu akışta değişen kart: **9**, alan: **14**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.yield.v.1`: İngilizce, `gloss_short` ve quiz (düşük): gerçek. Kilit ekranındaki 'sonuç vermek' quiz'deki pirinç bağlamını karşılamıyordu; `gloss_short` 'vermek, getirmek' oldu (ana anlamın kısaltması). Aynı sorun taranınca impose ('yasak getirmek' ↔ para cezası) ve exert ('baskı uygulamak' ↔ 'influence') bulundu; ikisinde quiz cümlesi kilit ekranı karşılığına uyduruldu.
- `en.perceive.v.1`: İngilizce, eşdizim (düşük): gerçek. 'perceive a threat' fark etmek anlamına kayıyordu; 'widely perceived as' oldu. Taramada `alt`'taki 'kavramak' (idrak etmek) çıkarıldı ve 3. örnek ('How we perceive risk') kalıba eklendi.
- `en.imply.v.1`: İngilizce, eşdizim (düşük): gerçek. 'be implied in' yerine 'clearly imply', 'seem to imply'.
- `en.coincide.v.1`: İngilizce, eş anlamlılar (düşük): gerçek. 'clash' sorunlu bir çakışma, 'overlap' kısmi örtüşmedir; 'happen together', 'occur together' oldu (önerilen 'happen at the same time' 16 grafem sınırını aşıyor).

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| exert.v.1 | examples[0].tr | "Ebeveynler çocukları üzerinde güçlü bir etki uygular." → "Ebeveynlerin çocukları üzerinde güçlü bir etkisi vardır." | 'etki uygular' çeviri kokuyordu (REVIEW'da soru olarak duruyordu) (tarama) |
| exert.v.1 | quiz.cloze | "Social media ______ a powerful influence on young people's opinions." → "Some parents ______ too much pressure on their children to get high grades." | 'baskı uygulamak' kilit ekranı karşılığı 'influence' bağlamını karşılamıyordu (tarama) |
| exert.v.1 | quiz.answer | "exerts" → "exert" | Yeni cümleye göre biçim (tarama) |
| exert.v.1 | quiz.distractors | "[undergoes, derives, deprives]" → "[derive, convey, allocate]" | Yeni cümleye göre biçim; çok kullanılan 'undergo/deprive' yerine (tarama) |
| impose.v.1 | quiz.cloze | "The government decided to ______ a heavy fine on companies that pollute rivers." → "The city plans to ______ a ban on cars in the historic center." | 'yasak getirmek' kilit ekranı karşılığı para cezası bağlamını karşılamıyordu (tarama) |
| yield.v.1 | l1.tr.gloss_short | "sonuç vermek" → "vermek, getirmek" | 'sonuç vermek' quiz'deki ürün (pirinç) bağlamını karşılamıyordu (bulgu) |
| emerge.v.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| perceive.v.1 | collocations | "[be perceived as, perceive a threat]" → "[be perceived as, widely perceived as]" | 'perceive a threat' fark etmek anlamına kayıyordu (bulgu) |
| perceive.v.1 | l1.tr.alt | "[kavramak, anlamak]" → "[değerlendirmek, anlamak]" | 'kavramak' anlamayı/idrak etmeyi anlatır, 'X'i Y olarak görmek' anlamı değil (tarama) |
| perceive.v.1 | grammar.pattern | "perceive sb/sth as sth" → "perceive sb/sth as sth; how sb perceives sth" | 3. örnek ('How we perceive risk') kalıpta yoktu (tarama) |
| eliminate.v.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| imply.v.1 | collocations | "[imply that, be implied in]" → "[imply that, clearly imply, seem to imply]" | 'be implied in' doğal bir eşdizim değil (bulgu) |
| stimulate.v.1 | l1.tr.alt | "[uyarmak, harekete geçirmek, uyandırmak]" → "[harekete geçirmek, uyandırmak]" | 'uyarmak' duyu/sinir uyarımı anlamı (tarama) |
| coincide.v.1 | synonyms | "[clash, overlap]" → "[happen together, occur together]" | 'clash' sorunlu çakışma, 'overlap' kısmi örtüşme (bulgu) |

- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
