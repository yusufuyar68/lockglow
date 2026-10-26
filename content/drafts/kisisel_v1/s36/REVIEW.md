# s36 QA incelemesi (YDS/YÖKDİL Çekirdek 4: bağlaçlar, akademik kalıplar ve sık phrasal verb'ler)

Kapsam: `content/drafts/kisisel_v1/s36/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: YDS ve YÖKDİL'in bağlaç, edat öbeği ve phrasal verb sorularında ve okuma parçalarında sık geçen sözcükler. Seviye: 41 C1, 19 B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** bir yazar ajanı, `1_yazar_kurallari.md`, s32 biçimi.
2. **Denetim:** bir denetçi ajanı (bu rapor), `2_denetci_kurallari.md` ve B2 turu denetimlerinden çıkan tuzak listesi (tek anlam, "sen" hitabı, gerçek hata maddeleri, gloss_short, tek doğru cevap, IPA). 60 kart tek tek okundu: anlam, tanım, örnek, geri çeviri, gloss ve gloss_short, alt, hata maddeleri, quiz'de her şık boşluğa konarak tek doğru cevap, IPA, seviye, YDS'ye uygunluk. Yazarın "emin olmadığım" maddeleri ayrıca tartıldı (aşağıda).

## Özet

- İncelenen kart: **60** (C1: 41, B2: 19). Tür: 15 `word` (2 `conj`, 3 `prep`, 10 `adv`), 33 `phrase` (`phr`), 12 `phrasal_verb` (`phv`). Hepsi `sense_no: 1`.
- `primary_topic`: hepsi `yds_yokdil_core` (B1–C1 aralığı). `tags.exams`: `["yds", "yokdil"]`. `sensitivity`: hepsi 0.
- Değişen kart: **21** (`critic_edited`), **32** alan.
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: yalnızca albeit (`high`), diğerleri `null`. Sahte dost yok.
- **Kilit ekranı anlamı:** 60 kartın hepsinde ≤16 karakter (44 kartta `gloss_short`; notwithstanding'de ana anlam kısaldığı için gerek kalmadı).
- **confusables:** 28 kartta; akış içi çiftler iki yönlü. Boş `confusables` dizisi yok.
- **mistakes:** 10 kartta 10 madde; hepsi gerçek öğrenci hatası olarak tutuldu (aşağıda). Uydurma ya da şaka hata yok.
- **Çeldirici:** 103 farklı şık; en sık unless, so that, by means of, in terms of, likewise, nevertheless ×4 (sınır max(4, %5) = 4).
- **IPA:** US `ɜːr/ər`, ɝ/ɚ yok; DRESS US 12/12, UK 10/10 `/ɛ/`, `/e/` yok.
- Satır sonu: hepsi LF.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Çeviri dili (haber çevirisi Türkçesi ve geri çeviride kayan anlam).** amid'in üç örneği "… endişeleri ortasında" diye kuruluydu; Türk haber dilindeki doğal karşılıklar ("endişelerinin gölgesinde", "eleştiriler karşısında", "endişesiyle") kullanıldı. not to mention "pahalı olduğunu söylemeye bile gerek yok" geri çevirisinde "needless to say" çıkıyordu → "üstelik pahalı da". boil down to "paraya dayanıyor" → deyimsel "dönüp dolaşıp paraya çıkıyor". single out, let alone, by contrast ve in contrast to ("ablasının" İngilizcede olmayan bilgi) çevirileri düzeltildi.
  2. **Akraba kartlar arasında ve kart içinde neredeyse aynı cümle.** albeit'in boşluklu cümlesi kendi 3. örneğinin neredeyse aynısıydı ("The economy grew …, albeit at a slower rate"); prior to (kalkıştan önce) ve by no means (… is by no means easy) quiz'leri de ilk örneklerini tekrarlıyordu. consequently'nin 1. örneği thus kartının 1. örneğiyle ("didn't study … failed the exam" / "was ill … missed the exam"), due to'nun hata maddesi on account of'ın 1. örneğiyle ("The match was canceled …") aynı kalıptaydı. Hepsi yeni cümleyle değişti.
  3. **Sınırda ikinci okuma veren şık ya da alt.** on the grounds that'te "as if" ("The license was refused as if the company had broken safety rules") dilbilgisi ve anlam olarak kurulabiliyordu → "unless". consequently'de "meanwhile" yalnızca zayıfça yanlıştı → "likewise". amid alt'ındaki "arasında" fiziksel anlamı ("amid the trees") taşıyordu, single out alt'ındaki "ayırt etmek" başka anlamdı (distinguish), so as to alt'ındaki "-sın diye" 'so that' yapısıydı; regardless of eş anlamlılarındaki "despite" eş anlamlı değildi.
- **Tek anlam:** accordingly ('act accordingly'), due to ('be due to + fiil'), account for (oran), at the expense of ('at sb's expense'), draw up (araç), with respect to ('with respect') ikinci anlamları yalnızca notta; tanım, örnek, eşdizim ve quiz tek anlamda. account for'un `def.long`'u ("If bad weather does this for a delay…") anlaşılmaz bir cümleydi, yeniden yazıldı.
- **Quiz:** zarf ve bağlaç sorularında aynı işlevdeki eş anlamlılar aynı soruda şık değil; çeldiriciler başka işlevden (karşıtlık / ekleme / sonuç / koşul). Edat öbeği sorularında çeldiriciler aynı biçimde (in/on/by … of). rather than'deki "instead of" (+ yalın fiil) ve in the case of'taki "in case of" bilinçli biçim tuzağı; ikisi de o cümlede yanlış.
- **YDS uygunluğu:** 60 kartın hepsi YDS/YÖKDİL bağlaç, edat öbeği ve phrasal verb sorularında ya da okuma parçalarında sık geçen sözcükler; notlardaki YDS ipuçları (karışan çift, eş anlamlı şık, kalıp) doğru. Örnekler kısa, haber/akademik dilde ve B2 öğrencinin çözebileceği yapıda.
- "Can" adı hiçbir örnekte yok; notlar "sen" hitabıyla ve büyük harfle başlıyor; hâl, dâhil, resmî yazımı doğru.

## Yazarın "emin olmadığım" maddeleri

1. **Hata maddeleri.**
   - **in accordance to:** kaldı. Türk öğrencilerin akademik yazısında çok sık görülen gerçek bir hata; `why` doğru nedeni ('according to' ile karışma) veriyor.
   - **provided that … will:** kaldı. Türkçede koşul gelecek zamanla da kurulabiliyor ("sessiz olacaksan"), `why` bunu anlatıyor; Türk öğrencilerde gerçek bir aktarım hatası.
   - **to some extend:** kaldı. Türkçeden kaynaklanmıyor ama YDS hazırlığındaki Türk öğrencilerin en sık yazım hatalarından; `why` "Türkçe yanıltıyor" demiyor, iki sözcüğün benzerliğini anlatıyor. Anadili Türkçe birinin onayına bırakıldı.
2. **Seviye.** Değiştirilmedi. nevertheless, furthermore, moreover, thus, due to, rather than, in addition to B1'e de çekilebilir; ama resmî yazı ve okuma parçası kullanımı B2'de öğretiliyor, B2 savunulabilir. prior to, given that, owing to B2'ye de çekilebilir; C1 de savunulabilir. Kategori aralığı B1–C1, iki karar da `LEVEL_RANGE` vermez.
3. **Kısa anlamlar.**
   - **in the case of** "örneğinde": kaldı; ana anlamın ilk kısmı, kesilmiş değil. "söz konusu olunca" 17 karakter.
   - **with respect to** "bakımından": kaldı; ana anlamın ikinci parçası, eş anlamlı değil.
   - **boil down to** "-e dayanmak": kaldı; alt'a deyimsel "dönüp dolaşıp -e çıkmak" eklendi.
   - **rule out** "ihtimal vermemek": kaldı; "dışlamak" tek başına "ostracize" okunur. Örnekler "ihtimalini dışlamak" diyor, alt'ta "olasılığı dışlamak" var.
   - **phase out** "aşamalı bırakmak": kaldı; "aşamalı kaldırmak" ve "kademeli kaldırmak" 17–18 karakter. Doğallığı anadili Türkçe birine soruldu (aşağıda).
4. **Tek doğru cevap.**
   - **conversely** ("Hot air rises; ______, cold air sinks."): nevertheless (karşıtlık değil ters ilişki), besides (ekleme), instead (yerine) yanlış; kaldı.
   - **nonetheless** ("They are, ______, very encouraging."): thus / likewise / consequently, "not final" ile "encouraging" arasındaki karşıtlıkta yanlış; kaldı.
   - **consequently:** "meanwhile" → "likewise" (aşağıda).
5. **Çeviriler.** amid, not to mention, single out, boil down to düzeltildi (tablo).

## Değişiklik tablosu

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| albeit | quiz.cloze | "The economy is growing, ______ at a slower rate than last year." → "The plan worked, ______ not as well as we had hoped." | Kartın 3. örneğinin neredeyse aynısıydı. |
| notwithstanding | l1.tr.gloss | "-e rağmen, -e karşın" → "-e rağmen" | alt'taki eskimiş "-e bakmayarak" kalkınca "-e karşın" alt'a geçti. |
| notwithstanding | l1.tr.gloss_short | "-e rağmen" → (yok) | Ana anlam 16 karakteri geçmiyor. |
| notwithstanding | l1.tr.alt | [-e bakmayarak] → [-e karşın] | "-e bakmayarak" eskimiş Türkçe. |
| amid | examples[0].tr | "Petrol fiyatları, kıtlık endişeleri ortasında yükseldi." → "Kıtlık endişelerinin gölgesinde petrol fiyatları yükseldi." | Çeviri Türkçesi; haber dilinde doğal karşılık. |
| amid | examples[1].tr | "Bakan, artan eleştiriler ortasında istifa etti." → "Bakan, giderek artan eleştiriler karşısında istifa etti." | Aynı neden. |
| amid | examples[2].tr | "Fırtına endişeleri ortasında okullar erken kapatıldı." → "Fırtına endişesiyle okullar erken kapatıldı." | Aynı neden. |
| amid | l1.tr.gloss | "ortasında, arasında" → "ortasında, sırasında" | "arasında" fiziksel anlam ("amid the trees"); kart olay/endişe anlamında. |
| amid | l1.tr.alt | [sırasında, -in gölgesinde] → [-in gölgesinde] | "sırasında" ana anlama geçti. |
| moreover | examples[2] | "Moreover, the survey shows that young people read less than before." → "Reading is fun. Moreover, it improves your vocabulary." / "Okumak eğlencelidir. Dahası, kelime dağarcığını geliştirir." | Öncesinde cümle olmadan "Moreover" ile başlıyordu; ekleme işlevi görünmüyordu. |
| consequently | examples[0] | "He didn't study and consequently failed the exam." → "The factory closed and consequently many people lost their jobs." / "Fabrika kapandı ve bunun sonucunda pek çok kişi işini kaybetti." | thus kartının 1. örneğiyle ("He was ill and thus missed the exam") neredeyse aynıydı. |
| consequently | quiz.distractors | meanwhile → likewise | "meanwhile" yalnızca zayıfça yanlıştı; "likewise" açıkça yanlış. |

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| accordingly | examples[2] | "The risk of flooding is high; … were evacuated." → "The risk of flooding was high; … were evacuated." / "Sel riski yüksekti; …" | Zaman uyumsuzluğu. |
| regardless_of | synonyms | [irrespective of, despite] → [irrespective of, no matter] | "despite" eş anlamlı değil (rağmen ≠ bakmaksızın); notta "no matter" zaten veriliyor. |
| due_to | l1.tr.mistakes[0] | "The match was canceled due to it was raining." → "The school was closed due to it was snowing." (right ve why da uyarlandı) | on account of'ın 1. örneğiyle ("The match was canceled on account of the rain") aynı kalıptaydı. |

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| by_contrast | examples[2].tr | "Eski sistem yavaştı. Yenisi ise buna karşılık saniyeler içinde çalışıyor." → "Eski sistem yavaştı. Buna karşılık yenisi saniyeler içinde çalışıyor." | "ise" ile "buna karşılık" art arda; doğal değildi. |
| in_contrast_to | examples[0].tr | "Ablasının aksine …" → "Kardeşinin aksine …" | "sister" büyük mü küçük mü belli değil; "abla" İngilizcede olmayan bilgi. |
| prior_to | quiz.cloze | "Passengers must check in at least two hours ______ departure." → "All visitors must sign in ______ entering the building." | 1. örnek ("30 minutes prior to departure") ile aynıydı; yeni cümle '+ -ing' kalıbını da sınıyor. |
| on_the_grounds_that | quiz.distractors | as if → unless | "refused as if the company had broken safety rules" kurulabiliyordu. |
| so_as_to | l1.tr.alt | [-mek amacıyla, -sın diye] → [-mek amacıyla, -mek üzere] | "-sın diye" 'so that' yapısı (başka özneye amaç); not bu iki yapıyı ayırıyor. |
| let_alone | examples[2].tr | "Bu hastalığı duyan çok az; nasıl tedavi edileceğini bilmek şöyle dursun." → "Bu hastalığı duyan bile çok az; nasıl tedavi edileceğini bilen nerede kaldı." | Eksik ve devrik kalmıştı. |
| not_to_mention | examples[0].tr | "Daire küçük, pahalı olduğunu söylemeye bile gerek yok." → "Daire küçük, üstelik pahalı da." | Geri çeviri "needless to say" çıkıyordu; gloss "üstelik". |

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| in_line_with | l1.tr.gloss | "doğrultusunda, uyumlu" → "doğrultusunda, -e paralel" | "uyumlu" sıfat; edat öbeğinin karşılığı değil. |
| in_line_with | l1.tr.alt | [paralel olarak, -e uygun olarak] → [paralel olarak, -e uygun olarak, ile uyumlu] | "be in line with" (ile uyumlu olmak) karşılığı alt'ta kalsın. |
| with_the_exception_of | word_family | [exceptional (adj)] → [] | "exceptional" (olağanüstü) başka anlam. |
| by_no_means | quiz.cloze | "The problem is ______ easy to solve." → "The result of the vote is ______ certain; it could still go either way." | 1. örnek ("The task is by no means easy") ile aynıydı. |

#### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| account_for | def.long | "To give or be the explanation for something. If bad weather does this for a delay, bad weather is the reason for the delay." → "To give an explanation for something, or to be the main reason why it happens, for example when bad weather is the reason for a delay." | "does this for a delay" anlaşılmıyordu. |
| single_out | examples[0].tr | "Antrenör aralarından özellikle Burak'ı övdü." → "Antrenör övgüsünde özellikle Burak'ı öne çıkardı." | "aralarından" bağlamsız kalıyordu; "öne çıkarmak" alt'taki karşılık. |
| single_out | l1.tr.alt | [öne çıkarmak, ayırt etmek] → [öne çıkarmak, seçip ayırmak] | "ayırt etmek" (distinguish) başka anlam. |
| boil_down_to | examples[0].tr | "Sonuçta her şey paraya dayanıyor." → "Her şey dönüp dolaşıp paraya çıkıyor." | Türkçedeki deyimsel karşılık. |
| boil_down_to | l1.tr.alt | [meselenin özü olmak] → [dönüp dolaşıp -e çıkmak, meselenin özü olmak] | Aynı neden. |
| boil_down_to | l1.tr.note | "… (sonuçta her şey paraya dayanıyor) …" → "… (her şey dönüp dolaşıp paraya çıkıyor) …" | Örnekle uyum. |

## Anadili Türkçe birinin bakması gerekenler

- **phase out** "aşamalı bırakmak": "aşamalı (olarak) kaldırmak" daha doğal ama 16 karaktere sığmıyor. Kabul edilebilir mi?
- **amid** "ortasında, sırasında": kilit ekranında "ortasında" tek başına fiziksel okunabilir; haber anlamı için "-in gölgesinde" daha iyi mi?
- **given that** `gloss_short` "düşünülürse": "-diği" düşünce kalan biçim yeterince açık mı?
- **to some extent** hata maddesi ("to some extend"): Türkçeden kaynaklanmayan ama çok sık görülen bir yazım hatası; kartta kalsın mı?
- **single out** 1. örnek "övgüsünde özellikle Burak'ı öne çıkardı" doğal mı?
- Seviye: yukarıdaki B1/B2 ve B2/C1 sınırındaki 10 kart.

## Çeldirici, IPA ve son doğrulama (Adım 3, 2026-10-26)

- Çeldiriciler tek tek boşluğa konup okundu; yalnızca bir şık değişti: **by means of** "on account of" → "in search of" ("pumped ... on account of an electric motor" "motor yüzünden" diye savunulabiliyordu). Karta `distractors_diversified` eklendi.
- Yineleme: s0..s36 içinde (lemma, pos) çakışması yok.
- US IPA'da ɝ/ɚ yok; boş `confusables` yok.
- Çeldirici: `s36: 60 quizzes, 103 distinct distractors; top: unless×4, so that×4, by means of×4, in terms of×4, likewise×4, nevertheless×4` (sınır max(4, %5) = 4).
- IPA: `s36 {'uk_e': 0, 'uk_ɛ': 10, 'us_e': 0, 'us_ɛ': 12}`.
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

İki denetçi (Türkçe ve İngilizce gözü) s33–s36'dan alınan 48 kartlık örneklemi okudu; 21 bulgu (17 kart) kartla karşılaştırıldı: 20'si gerçek çıktı ve düzeltildi, 1'i (scarcity, 'işçi kıtlığı') gerekçesiyle reddedildi. Bulgulardaki her sistematik sorun s33–s36'nın 240 kartında tarandı: yanlış sözcük ailesi bilgisi (virtually), notla çelişen örnek ya da fazla keskin ayrım (başka yok), anlamı düşen `gloss_short` (başka yok), yerleşik olmayan Türkçe terim (başka yok), çeviri kokan Türkçe örnek (6 kart), bağlacın anlamı ve dilbilgisi (başka yok), tanım doğruluğu (başka yok), eş anlamlı inceliği ve kartın tek anlamı (precisely, perceive, stimulate), doğal olmayan eşdizim (başka yok), örneklerle uyuşmayan `grammar.pattern` (bulguyla birlikte 21 kart), kilit ekranı karşılığının quiz bağlamını karşılamaması (impose, exert) ve seviye (Oxford 3000'de B2 olan 10 kart daha B2'ye indi). 'Can' adı, 'siz' hitabı, şapkasız hâl/dâhil, IPA ve boş `confusables` yeniden tarandı; sorun yok.

- Bu akışta değişen kart: **10**, alan: **13**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.albeit.conj.1`: İngilizce, `def.micro` ve `sense_note` (orta): gerçek. 'even if' varsayım bildirir; 'albeit' gerçek bir durumu ekler. İkisi de 'although; even though' oldu.
- `en.regardless_of.phr.1`: İngilizce, eş anlamlılar ve not (orta): gerçek. 'no matter' isimle kullanılmaz (*no matter age); eş anlamlılardan çıkarıldı, nota 'yalnızca wh- ile' farkı yazıldı.
- `en.consequently.adv.1`: İngilizce, seviye (düşük): gerçek. Oxford 3000'de B2; C1 → B2. Taramada 1. örnekteki 'and consequently' kalıba eklendi.
- `en.given_that.phr.1`: Türkçe, `gloss_short` (düşük): gerçek. 'düşünülürse' '-diği' ekini düşürüp anlamı kaybediyordu; '-diği düşünülürse' 17 grafem olduğu için `alt`'taki '-dığına göre' alındı.
- `en.come_about.phv.1`: İngilizce, `def.short` (düşük): gerçek. 'not planned or hard to explain' fazlaydı; 'to happen or develop, often used when asking how or why something happened' oldu.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| albeit.conj.1 | sense_note | "although; even if" → "although; even though" | 'even if' varsayım bildirir; albeit gerçek bir durumu ekler (bulgu) |
| albeit.conj.1 | def.micro | "although; even if" → "although; even though" | 'even if' varsayım bildirir (bulgu) |
| nevertheless.adv.1 | grammar.pattern | "…; nevertheless, …" → "…; nevertheless, … / … but nevertheless …" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| thus.adv.1 | grammar.pattern | "…, thus + -ing / …; thus, …" → "…, thus + -ing / …; thus, … / … and thus …" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| consequently.adv.1 | level | "C1" → "B2" | Oxford 3000/EVP'de B2; temel bağlayıcı (bulgu) |
| consequently.adv.1 | grammar.pattern | "…; consequently, …" → "…; consequently, … / … and consequently …" | 1. örnekteki 'and consequently' kalıpta yoktu (tarama) |
| accordingly.adv.1 | grammar.pattern | "…; accordingly, …" → "…; accordingly, … / … and, accordingly, …" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| regardless_of.phr.1 | synonyms | "[irrespective of, no matter]" → "[irrespective of]" | 'no matter' isimle kullanılmaz (*no matter age) (bulgu) |
| regardless_of.phr.1 | l1.tr.note | "YDS'de 'regarding' (hakkında) ile karıştırılır. Eş anlamlıları: 'irrespective of', 'no matter'. Ardından isim ya da 'wh-' cümlesi gelir: 'regardless of what happens'." → "YDS'de 'regarding' (hakkında) ile karıştırılır. Ardından isim ya da 'wh-' cümlesi gelir: 'regardless of age/what happens'. 'No matter' ise yalnızca 'wh-' ile kullanılır (no matter where); ardından isim gelmez." | 'no matter' eş anlamlı diye verilmişti; dilbilgisi farkı eklendi (bulgu) |
| by_contrast.phr.1 | grammar.pattern | "X. By contrast, Y." → "X. By contrast, Y. / Y, by contrast, …" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| given_that.phr.1 | l1.tr.gloss_short | "düşünülürse" → "-dığına göre" | 'düşünülürse' '-diği' ekini düşürüp anlamı kaybediyordu; '-diği düşünülürse' 17 grafem (bulgu) |
| come_about.phv.1 | def.short | "to happen, especially in a way that is not planned or is hard to explain" → "to happen or develop, often used when asking how or why something happened" | 'not planned or hard to explain' fazlaydı, def.long ile uyuşmuyordu (bulgu) |
| single_out.phv.1 | examples[0].tr | "Antrenör övgüsünde özellikle Burak'ı öne çıkardı." → "Antrenör, oyuncular arasından özellikle Burak'ı övdü." | 'övgüsünde ... öne çıkardı' yapay duruyordu (tarama) |

- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
