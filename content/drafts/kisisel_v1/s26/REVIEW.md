# s26 QA incelemesi (B2: sağlık, beslenme, spor, iyi yaşam)

Kapsam: `content/drafts/kisisel_v1/s26/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin haberde, doktorda, spor salonunda ve iş yerinde duyduğu sağlık ve iyi yaşam sözcükleri. Hepsi `level: "B2"`, `level_source: "editorial_estimate"`.

Süreç (`docs/icerik_uretimi/README.md`). Bütün ajanlar Opus (orta çaba):

1. **Yazım:** tek yazar ajanı, 5 part (`1_yazar_kurallari.md`). Yazar s0–s25 ve s27 ile lemma, örnek ve quiz cümlesi çakışması olmadığını, kimliklerin `id_registry.json`'da olmadığını bildirdi.
2. **Denetim:** tek denetçi ajanı (`2_denetci_kurallari.md`) 60 kartı tek tek okudu: anlam, tanım, IPA, örnekler ve geri çeviri, gloss/alt/gloss_short, hata maddeleri, sahte dost, confusables, quiz şıkları (her şık boşluğa kondu), seviye. Yazarın "emin olmadığım" maddeleri ayrıca yanıtlandı (aşağıda).

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 52 kelime (22 isim, 18 fiil, 9 sıfat, 3 zarf), 4 eşdizim (side effect, blood pressure, mental health, work-life balance), 2 phrasal verb (cut back on, build up), 1 kalıp (get in shape), 1 deyim (on the mend).
- `primary_topic`: `health_body` 34, `medicine_healthcare` 17, `food_drink` 5, `phrasal_verbs` 2, `workplace_office` 1, `idioms_expressions` 1.
- Değişen kart: **8** (`critic_edited`), değişen alan: **11** (aşağıdaki tablo). `meta.status` hepsinde `draft` kaldı.
- Reddedilen kart (`critic_reject`): **0**. Seviyesi B2'den kuşkulu kartlar silinmedi, aşağıda işaretlendi.
- **Türkçeden çeviri hatası (`mistakes`):** 20 kartta 20 madde; hepsi gerçek Türk öğrenci hatası bulundu, silinen yok. 40 kartta boş.
- **Sahte dost:** 1 kart (condition ↔ kondisyon), tutuldu ve not netleştirildi.
- **Karışan kelimeler (`confusables`):** 27 kartta 32 kayıt (on the mend → under the weather silindi).
- **Kilit ekranı anlamı:** 60 kartın hepsinde ≤16 karakter; `gloss_short` 2 kartta (healthcare "sağlık hizmeti", maintain "sürdürmek"), ikisi de doğal.
- **IPA:** DRESS `/ɛ/` (19 US, 19 UK, `/e/` yok); US "on" `/ɑːn/`, UK `/ɒn/`. vitamin US `/ˈvaɪtəmɪn/`, UK `/ˈvɪtəmɪn/` doğru.
- **Etimoloji:** yalnızca vitamin (Casimir Funk, 1912, *vita* + *amine*) ve calorie (Fransızca, Latince *calor*); ikisi de doğru, kaldı.
- `sensitivity`: hepsi 0 (hastalık sözcükleri sıradan sağlık sözcüğü; kişisel ya da utandırıcı örnek yok).
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`. Çeldirici: 152 farklı şık; en sık recipe, symptom, appetite, pressure 3'er soruda (sınır 4).

## Genel bulgular

- **En sık 3 sorun:**
  1. **`alt`'ta karşılık olmayan sözcükler:** infection "mikrop kapma" (fiil kalıbı, isim karşılığı değil), strength "dayanıklılık" (= endurance), mental "akli" (TDK yazımı "aklî"; zaten "ruhsal" var), on the mend çekimli "toparlanıyor / düzeliyor".
  2. **Zayıf ya da bir şey sınamayan quiz şıkları:** work-life balance'ta "day off / diet plan" ("The day off was terrible" dilbilgisi olarak kurulabiliyordu).
  3. **Küçük Türkçe doğallık sorunları:** "düğünü öncesi" → "düğününden önce", "hesap makinesinden hızlı" → "daha hızlı"; skip alt "ekmek (ders, iş)" kalıp biçimine getirildi.
- **Quiz:** 60 sorunun hepsinde her şık boşluğa kondu; work-life balance dışında ikinci doğru cevap ya da sınamayan şık bulunmadı. Gerçek hata biçimleri iyi çeldirici olarak kaldı: gained ↔ "took", prescribed ↔ "wrote", blood pressure ↔ "tension", get in shape ↔ "get in form", stressful ↔ "stressed", properly ↔ "proper".
- **Seviye (silinmedi, yalnızca işaret):**
  - **B1'e daha yakın görünenler:** vitamin, protein, calorie, muscle, fitness, lifestyle, physical, energetic, stressful, bend, treatment. Bunlar B1 öğrencinin de tanıdığı sözcükler; kartlar B2 kalıplarını (build muscle, receive treatment, physical activity, burn calories) öne çıkardığı için tutulabilir.
  - **C1'e yakın olabilecekler:** on the mend (deyim, daha çok İngiliz İngilizcesi), unwind, remedy. B2 için kabul edilebilir sınırda.

## Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| infection | l1.tr.alt | ["iltihap", "mikrop kapma"] → ["iltihap"] | "Mikrop kapma" bir eylem ("mikrop kapmak"), "infection" isminin karşılığı değil. |
| condition | l1.tr.note | "Türkçedeki 'kondisyon' (spor formu) İngilizcede 'fitness' olur. Formda olmamak 'be out of shape' diye söylenir." → "Türkçedeki 'kondisyon' (spor formu) İngilizcede çoğunlukla 'fitness' olur; formda olmamak 'be out of shape' denir. 'Condition' tek başına çoğu zaman bir hastalık ya da bir şeyin durumu anlamına gelir." | İngilizcede "physical condition", "in good condition" da var; "her zaman fitness" demek fazla kesindi. Notun kartın asıl anlamına (hastalık) bağlanması gerekiyordu. |
| condition | l1.tr.false_friend.en_for_that | "fitness / be in shape" → "fitness / being in shape" | İsim karşılığıyla aynı biçim. |
| strength | l1.tr.alt | ["kuvvet", "dayanıklılık"] → ["kuvvet"] | "Dayanıklılık" = endurance/stamina; strength değil. |
| skip | l1.tr.alt | ["es geçmek", "ekmek (ders, iş)"] → ["es geçmek", "(dersi) ekmek"] | Destedeki parantez biçimi ("(yara) kapanmak", "(ilaç) yazmak"); "ekmek" tek başına "bread" gibi okunuyordu. |
| mental | l1.tr.alt | ["ruhsal", "akli"] → ["ruhsal"] | TDK yazımı "aklî"; ayrıca günlükte seyrek ve "ruhsal" yeterli. |
| mental | examples[2].tr | "…hesap makinesinden hızlı yapıyor." → "…hesap makinesinden daha hızlı yapıyor." | Karşılaştırmada "daha" düşünce Türkçe kırık okunuyor. |
| work-life balance | quiz.distractors | ["job interview", "day off", "diet plan"] → ["job interview", "work permit", "job market"] | Yazarın şüphesi doğru: "The day off was terrible" kurulabiliyor, "diet plan" konu dışı. Yeni şıklar iş dünyasından, ama "aileye hiç zaman ayıramadım" cümlesinin devamı olarak açıkça yanlış. |
| get in shape | examples[1].tr | "Elif düğünü öncesi forma girmek…" → "Elif düğününden önce forma girmek…" | "Düğünü öncesi" gazete başlığı gibi; günlük Türkçede "düğününden önce". |
| on the mend | l1.tr.alt | ["toparlanıyor", "düzeliyor"] → ["toparlanmak", "iyileşmeye başlamak"] | `alt` sözlük biçimi olmalı; "iyileşmeye başlamak" deyimin "henüz tam değil ama düzeliyor" anlamını veriyor. |
| on the mend | confusables | ["under the weather"] → (silindi) | Karışıklık değil, karşıt durum (hafif hasta olmak). Kural: zıt anlamlı confusable değildir. s12'deki under the weather kartında karşı bağ yok. |

## Yazarın "emin olmadığım" maddeleri

1. **Hata maddeleri:** altısı da tutuldu.
   - pressure "makes pressure on me" ("baskı yapmak"): Türk öğrencilerde çok bilinen bir hata.
   - specialist "expert doctor" ("uzman doktor"): Türk hastane sitelerinde "Expert Dr." çevirisi olarak bile yaygın. Gerçek.
   - muscle "make muscle" ("kas yapmak") ve appetite "opened my appetite" ("iştah açmak"): gerçek, sık.
   - maintain "protect my weight" ("kilomu korumak"): gerçek görünüyor ama ötekilerden seyrek; aşağıda anadili Türkçe kişiye soruldu.
   - cure "cure of this illness" (ilgi eki → of): Türkçe tamlamanın "of" ile çevrilmesi bilinen bir örüntü; tutuldu, sınırda.
2. **condition / kondisyon:** sahte dost yeterince güçlü: Türkçe "kondisyon" hiçbir zaman hastalık demek değil, öğrenci "my condition is bad" deyince İngiliz bir hastalık anlıyor. Not yumuşatıldı ("çoğunlukla fitness"), çünkü "physical condition" da var. condition ↔ fitness iki yönlü bağı kaldı (Türkçede aynı sözcük "kondisyon").
3. **Türkçe:** on the mend gloss "iyileşme yolunda" iyi; alt düzeltildi. remedy "kocakarı ilacı" gerçek ve yaygın (hafif şakacı ama kaba değil), kaldı. surgeon "operatör doktor" gerçek unvan ("Op. Dr."), kaldı. prescribe "(ilaç) yazmak" doğal ("doktor ilaç yazdı"), kaldı. skip alt düzeltildi.
4. **Quiz:** physical (physics/physician/physically) kaldı: üçü de "your ___ and mental health" boşluğunda açıkça yanlış ve "physically" gerçek bir biçim hatası. mental health "soul health" yalnızca şık olarak kaldı. work-life balance değişti. condition: "heart pressure" İngilizcede bir terim değil, açıkça yanlış.
5. **Diğer:** infection ↔ injection kaldı (Türkçede de "enfeksiyon/enjeksiyon" karışır, biçim benzerliği ölçütü). suffer'da hata maddesi olmaması doğru karar. `content/drafts/README.md` ve DEVIR.md güncellemesi bu adımın kapsamı dışında bırakıldı.

Değişmeyen ama bakılanlar: gain "took three kilos", blood pressure "tension", prescribe "wrote me a medicine", operate "operated my father", calorie "250 calorie", quit "quit to eat", relaxation "for relax", fitness "I do fitness", energetic "energic", stressful "I'm stressful", regularly/properly (-ly düşmesi), get in shape "get in form": hepsi gerçek Türk öğrenci hatası. `word_family` öğeleri `{lemma, pos}` biçiminde; doğrulayıcı kabul ediyor.

## Anadili Türkçe birinin bakması gerekenler

1. maintain hatası "I eat less in winter to protect my weight.": "kilomu korumak → protect" ne kadar sık? Seyrekse silinebilir.
2. cure hatası "There is still no cure of this illness.": "of" hatası gerçek ama bu sözcükte ne kadar yaygın?
3. remedy örneği "Anneannemin her hastalık için bir kocakarı ilacı var.": "kocakarı" büyükanne için kaba durur mu? Alternatif: "…her derde bir doğal çaresi var."
4. Kilit ekranı karşılıkları: properly "düzgünce" (alternatif "doğru dürüst"), suffer "acı çekmek" (kartın anlamı "suffer from" hastalık; alternatif "(hastalık) çekmek"), on the mend "iyileşme yolunda".
5. treatment alt "bakım": tıbbi bağlamda tek başına yeterince açık mı ("tıbbi bakım")?
6. Seviye: B1'e yakın görünen 11 kart (yukarıda) B2 destesinde kalsın mı?

## Çeldirici çeşitlendirme ve son kontroller (2026-10-26)

- `distractor_stats.py`: `s26: 60 quizzes, 152 distinct distractors; top: recipe×3, symptom×3, appetite×3, pressure×3, lifestyle×2, nutrition×2`. Sınır (max(4, %5) = 4) aşılmıyor; değişen kart: **0**, cloze değişmedi.
- `ipa_dress_stats.py`: `s26 {'uk_e': 0, 'uk_ɛ': 19, 'us_e': 0, 'us_ɛ': 19}`. DRESS hepsinde `/ɛ/`, düzeltme gerekmedi.
- Başlık sözcüğü çakışması (`dump_lemmas.py` mantığıyla, büyük/küçük harf duyarsız): s26'daki 60 lemmanın hiçbiri öteki akışlarda (s0_ornek, s1–s25, s27–s32) yok; akış içinde de tekrar yok.

Son doğrulama (2026-10-26) (`python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s26`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

Üç bağımsız denetçi B2 destesinden 80 kartlık bir örneklemi okudu (Türkçe, İngilizce ve quiz gözüyle). Bulgular tek tek doğrulandı; doğru olanlar düzeltildi. Bulgulardan çıkan beş sistematik sorun (notlarda 'siz' hitabı, İngilizce cümlede özne olan 'Can' adı, ikinci anlama kayan örnek ve eşdizimler, başka sözcük türünden çeldiriciler, B1 olabilecek seviyeler) s23–s32'nin 600 kartında tarandı.

- Bu akışta değişen kart: **4**, alan: **5**. Değişen kartlara `critic_edited` eklendi.
- Çeldirici: `s26: 60 quizzes, 152 distinct distractors; top: recipe×3, symptom×3, appetite×3, pressure×3, lifestyle×2, nutrition×2` (sınır max(4, %5) = 4 aşılmıyor).
- Seviye: değiştirilmedi. B1 olabilecek kartlar bu dosyanın seviye bölümünde zaten işaretli; karar kullanıcıda.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| protein.n.1 | examples[2] | "After the gym, Can always has a protein shake. / Can spor salonundan sonra hep protein shake içer." → "After the gym, Umut always has a protein shake. / Umut spor salonundan sonra hep protein shake içer." | 'Can' adı İngilizcede modal 'can' gibi okunuyor |
| quit.v.1 | collocations | "quit sugar, quit your job, quit a habit" → "quit sugar, quit smoking, quit a habit" | 'quit your job' ayrı anlam (işten ayrılmak) |
| quit.v.1 | l1.tr.alt | "vazgeçmek, (işten) ayrılmak" → "vazgeçmek" | '(işten) ayrılmak' ayrı anlamın karşılığı |
| physical.adj.1 | quiz.distractors | "physics, physician, physically" → "physically, financial, legal" | Şıkların hepsi başka sözcük türü; tür bilerek seçiliyordu |
| get_in_shape.phr.1 | collocations | "get in shape, stay in shape, out of shape" → "get in shape for summer, try to get in shape, get back in shape" | Başlığın kendisi ve 'out of shape' eşdizim değil |

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Seviye kararı (2026-10-26)

İki bağımsız yargıç B1 olabilecek adayları ayrı ayrı değerlendirdi. İkisinin de B1 ya da altı dediği **10 kart** `level: "B1"` oldu; `level_source` yine `editorial_estimate`. Kart ID'leri seviye içermediği için değişmedi. Yargıçların ayrıntılı gerekçe metinleri bu düzenlemeye gelmedi; satırlardaki gerekçe, yargıç kararının editör özetidir.

- `en.treatment.n.1` (treatment): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel. Konu: `medicine_healthcare` B1'i kapsamıyordu → `primary_topic` `health_body`, `topics` [health_body, medicine_healthcare].
- `en.fitness.n.1` (fitness): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.vitamin.n.1` (vitamin): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.calorie.n.1` (calorie): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.lifestyle.n.1` (lifestyle): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.muscle.n.1` (muscle): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.bend.v.1` (bend): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.physical.adj.1` (physical): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.energetic.adj.1` (energetic): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.stressful.adj.1` (stressful): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.

B2'de kalan adaylar (yargıçlar ayrıştı ya da B2 dedi): `en.protein.n.1`.

## İkinci örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) her akıştan 7 kartlık bir örneklemi (toplam 70 kart) ikinci kez okudu. 35 bulgunun hepsi kartla karşılaştırıldı ve hepsi gerçek çıktı; düzeltildi. Bulgulardan çıkan yeni sistematik sorunlar s23–s32'nin 600 kartında tarandı: `def.long`'un ikinci bir anlama kayması (ve aynı anlamın örnek, eşdizim, `alt` ya da quiz'e girmesi), başka sözcük türünden ya da yalnızca yazımı benzeyen çeldiriciler, ABD IPA'sında ɝ/ɚ yazımı, boş `confusables` dizisi.

- Bu akışta değişen kart: **3**, alan: **4**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.fully.adv.1`: Türkçe, 3. örnek (düşük): gerçek. 'tam şarjlı olduğundan'.
- `en.fully.adv.1`: Quiz (orta): gerçek. 'full'/'fullness' başka sözcük türü; şıklar loudly, lately, early oldu.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| physical.adj.1 | quiz.distractors | "[physically, financial, legal]" → "[musical, financial, legal]" | 'physically' zarf (tarama) |
| properly.adv.1 | quiz.distractors | "[proper, rarely, nearly]" → "[loudly, rarely, nearly]" | 'proper' sıfat (tarama) |
| fully.adv.1 | examples.2.tr | "Yolculuktan önce telefonunun tamamen şarj olduğundan emin ol." → "Yolculuktan önce telefonunun tam şarjlı olduğundan emin ol." | 'tamamen şarj olduğundan' hantal; notta da 'tam şarjlı' var (bulgu) |
| fully.adv.1 | quiz.distractors | "[full, fullness, lately]" → "[loudly, lately, early]" | 'full' sıfat, 'fullness' isim: dilbilgisinden eleniyordu (bulgu) |

- Çeldirici: `s26: 60 quizzes, 151 distinct distractors; top: recipe×3, symptom×3, appetite×3, pressure×3, lifestyle×2, nutrition×2` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Üçüncü örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) s23–s32'den 80 kartlık yeni bir örneklemi okudu. 35 bulgu kartla karşılaştırıldı: 33'ü gerçek çıktı ve düzeltildi, 2'si (release, carbon footprint çevirileri) gerekçesiyle reddedildi. Önceki iki turun listesinde olmayan sistematik sorunlar s23–s32'nin 600 kartında tarandı: `gloss_short`'ta kesilmiş söz; `alt`'ın kartın kendi notuyla ya da başka bir kartın ayrımıyla çelişmesi (ve önceki taramada kalan ikinci anlam karşılıkları); `grammar.pattern`'da başka anlamın kalıbı; `def.long`'da önceki anahtar sözcük taramasının kaçırdığı ikinci anlam cümleleri (ve aynı anlamın örnek, eşdizim, quiz'e taşması); akraba kartlar arasında neredeyse aynı örnek ya da boşluklu cümle; boşluğa anlamca hiç uymayan, soruyu ele veren çeldiriciler; şapkası düşmüş hâl / dâhil. Seviyeler değişmedi.

- Bu akışta değişen kart: **11**, alan: **12**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.treatment.n.1`: Türkçe, alt (düşük): gerçek. 'bakım' çıktı, ['tedavi yöntemi'] kaldı.
- `en.heal.v.1`: İngilizce, `def.long` ve alt (düşük): gerçek. Geçişli anlam cümlesi ve 'iyileştirmek' çıktı.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| treatment.n.1 | l1.tr.alt | "[bakım, tedavi yöntemi]" → "[tedavi yöntemi]" | 'bakım' (care) tedavi karşılığı değil (bulgu) |
| recovery.n.1 | examples[1] | "After the operation, his recovery took about three months. / Ameliyattan sonra iyileşmesi yaklaşık üç ay sürdü." → "Rest is an important part of recovery. / Dinlenmek iyileşmenin önemli bir parçasıdır." | başka bir kartta neredeyse aynı cümle vardı (fully: 'three months to fully recover from the operation') (tarama) |
| infection.n.1 | quiz.cloze | "Keep the wound clean and dry to avoid ______." → "Wash your hands often to stop ______ from spreading." | başka bir kartta neredeyse aynı cümle vardı (heal quiz: 'Keep the wound clean …') (tarama) |
| vitamin.n.1 | quiz.cloze | "Fish and eggs are good sources of ______ D." → "Our skin makes ______ D when we spend time in the sun." | başka bir kartta neredeyse aynı cümle vardı (protein quiz: 'good sources of ___') (tarama) |
| portion.n.1 | l1.tr.alt | "[pay, kısım]" → "[pay]" | 'kısım' (part) porsiyon karşılığı değil (tarama) |
| cure.n.1 | examples.2.tr | "Kötü bir ruh haline en iyi ilaç uykudur." → "Kötü bir ruh hâline en iyi ilaç uykudur." | TDK yazımı: hâl / dâhil (şapka düşmüştü) (tarama) |
| nutrition.n.1 | l1.tr.alt | "[besin, besin değeri]" → "[besin değeri]" | 'besin' notun ayırdığı 'nutrient' (tarama) |
| heal.v.1 | def.long | silinen cümle: "It can also mean to make it better: 'This cream helps cuts heal faster'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (bulgu) |
| heal.v.1 | l1.tr.alt | "[(yara) kapanmak, iyileştirmek]" → "[(yara) kapanmak]" | 'iyileştirmek' geçişli anlam (bulgu) |
| quit.v.1 | def.long | "To stop doing something completely, especially a habit like eating sugar or drinking too much coffee. It is also used for leaving a job. Th…" → "To stop doing something completely, especially a habit like eating sugar or drinking too much coffee. The past form is also 'quit'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| effective.adj.1 | examples[1] | "Exercise is an effective way to lower stress. / Egzersiz, stresi azaltmanın etkili bir yoludur." → "Walking is an effective way to lose weight. / Yürümek kilo vermenin etkili bir yoludur." | başka bir kartta neredeyse aynı cümle vardı (lower: 'Exercise can lower your stress') (tarama) |
| build_up.phv.1 | quiz.cloze | "Start with ten minutes of exercise a day and slowly ______ your strength." → "Doing push-ups every day will ______ the muscles in your arms." | başka bir kartta neredeyse aynı cümle vardı (gradually: 'Start with ten minutes a day and gradually increase') (tarama) |

- Çeldirici: `s26: 60 quizzes, 151 distinct distractors; top: recipe×3, symptom×3, appetite×3, pressure×3, lifestyle×2, nutrition×2` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
