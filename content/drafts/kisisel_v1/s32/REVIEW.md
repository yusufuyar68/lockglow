# s32 QA incelemesi (B2 phrasal verb'ler, eşdizimler ve deyimler)

Kapsam: `content/drafts/kisisel_v1/s32/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin işte, haberde ve günlük konuşmada sık duyduğu phrasal verb'ler (28), eşdizimler (18), kalıp ifadeler (6) ve deyimler (8). Seviye: hepsi B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** bir yazar ajanı, `1_yazar_kurallari.md`, s22 biçimi.
2. **Denetim:** bir denetçi ajanı (bu rapor), `2_denetci_kurallari.md`. 60 kart tek tek okundu: anlam, tanım, örnek, geri çeviri, gloss ve gloss_short, hata maddeleri, quiz'de her şık boşluğa konarak tek doğru cevap, IPA, seviye. Yazarın "emin olmadığım" maddeleri ayrıca tartıldı (aşağıda).

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 28 phrasal verb, 18 eşdizim (`collocation`), 6 kalıp (`phrase`), 8 deyim (`idiom`).
- `primary_topic`: `phrasal_verbs` 28, `collocations` 24, `idioms_expressions` 8.
- Değişen kart: **13** (`critic_edited`), 17 alan.
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: hepsi `null`. Sahte dost yok. `sensitivity`: hepsi 0.
- **Kilit ekranı anlamı:** 60 kartın hepsinde ≤16 karakter (17 kartta `gloss_short`).
- **confusables:** 39 kartta.
- **mistakes:** 12 kartta 13 madde (yazarın 14 maddesinden 1'i silindi).
- **Çeldirici:** 144 farklı şık; en sık run out of ×4, make ×4 (sınır 4).
- **IPA:** DRESS 11/11 `/ɛ/`, `/e/` yok.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Quiz'de sınırda ikinci okuma.** fall through "went off" ("the deal went off" = gerçekleşti okunabilir), out of the question "order" (İngiliz İngilizcesinde "out of order" = kabul edilemez), make a fuss "deal" ("make such a deal about it" "big deal" ile karışıyor), have a go "take" (Amerikan konuşmasında "take a go at it" duyuluyor), make an effort "give" ("give an effort" Amerikan spor dilinde var), run a business "lead" ("lead a company" doğru İngilizce). Hepsi açıkça yanlış şıklarla değişti.
  2. **Kilit ekranında tek başına yanlış okunan Türkçe.** take advantage of kısa anlamı "değerlendirmek", kartın uyardığı "evaluate" çevirisinin ta kendisiydi; look back on "dönüp bakmak" geçmiş anlamını kaybediyordu.
  3. **Uydurma ya da şaka sayılabilecek hata maddesi.** fall through "Our plans fell into the water" s22'de silinen "throw an eye on" gibi bir "Tarzanca" esprisi; öğrencinin gerçekten ürettiği kanıtlanamıyor, silindi.
- Quiz'lerin geri kalanı tek cevaplı bulundu. Örneğin give in'de "gave up" çıkarılmış, run through'da "go through" şık değil, settle down'da "calmed down" şık değil.
- Örneklerin İngilizcesi doğal; Amerikan yazımı tutarlı (closet, highway, vacation, canceled, neighbors).

## Yazarın "emin olmadığım" maddeleri

1. **Kısa anlamlar.**
   - **live up to:** "beklentilere layık olmak / layık olmak" kaldı. "beklentiyi karşılamak" 16'yı aşıyor ve kısaltması anlamı kaybettiriyor. İlk örneğin çevirisi düzeltildi (aşağıda).
   - **spill the beans:** "baklayı ağzından çıkarmak / baklayı çıkarmak" kaldı. "ağzından kaçırmak" 17 karakter, sığmıyor; `alt`'ta ve iki örnekte görünüyor.
   - **at short notice:** ana anlam "son anda haber verilerek" yapıldı. Böylece haberi alan taraf da kapsanıyor ("Thanks for coming at such short notice"). Kısa anlam "son anda" kaldı.
2. **Hata maddeleri.**
   - **bring forward** "took the meeting forward": "öne almak"taki "almak" ofis İngilizcesinde gerçekten "take" olarak çıkıyor; kaldı.
   - **speed up** "fasten the process": Türk öğrencilerde sık görülen gerçek bir hata, kaldı. `why`, "shorten/widen" benzetmesiyle yeniden yazıldı.
   - **make a difference** "create a difference": "fark yaratmak" çevirisi Türk yazılarında sık; kaldı.
   - **fall through** "fell into the water": silindi.
3. **Tek doğru cevap.**
   - **give in:** doğru (gave up yok).
   - **set an example:** "give" kaldı. "by arriving on time" davranışı gösteriyor; "give an example" açıklarken örnek vermek demek. Hedeflenen tuzak tam bu, notta da anlatılıyor.
   - **make out:** "make up" kaldı. "So dark that I couldn't make up the number" anlamsız; hedeflenen biçim tuzağı.
4. **İngiliz lemmaları.** at short notice ve have a go aynen kaldı. İkisi de Amerikan dizilerinde de anlaşılır; notlar Amerikan karşılığını veriyor.
5. **IPA ve not.**
   - **the ball is in your court:** tek vurgulu US IPA kabul edildi (s22'de "not the end of the world" istisnası gibi).
   - **make out:** argodaki "öpüşmek" uyarısı kaldı. B2 öğrenci dizide bu anlamla karşılaşacak; uyarı yanlış anlamayı önlüyor. Kart `sensitivity: 0` kaldı, çünkü kartın anlamı ve örnekleri görme ve duymayla ilgili.

## Değişiklik tablosu

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| fall through | l1.tr.mistakes | "Our plans fell into the water." → [] | "Planlar suya düştü"nün kelime kelime çevirisi bir şaka kalıbı; öğrencinin gerçekten ürettiği kanıtlanamıyor (s22'de "throw an eye on" da aynı nedenle silindi). |
| fall through | quiz.distractors | went off → fell out | "The deal went off" (gerçekleşti) okunabiliyordu; "the deal fell out" olmuyor ve aynı fiil ailesinden bir tuzak. |
| look back on | l1.tr.gloss_short | "dönüp bakmak" → "geçmişe bakmak" | Tek başına "arkaya dönüp bakmak" gibi okunuyordu; geçmiş anlamı korunsun. |

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| live up to | examples[0].tr | "Film, bu kadar övülmeye layık değildi." → "Film, övüldüğü kadar iyi değildi." | Geri çeviri "didn't deserve so much praise" çıkıyordu; "the hype" ile kıyas kaybolmuştu. |
| speed up | l1.tr.mistakes[0].why | "'fast' kelimesinden türemiş gibi…" → "'Shorten', 'widen' gibi kelimelere bakılıp 'fasten' hızlandırmak sanılıyor…" | Hatanın asıl nedeni olan "-en" ekiyle benzetme açıkça söylensin. |

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| wind down | l1.tr.note | "…rüzgâr anlamındaki 'wind' gibi okunmaz… 'Wind up' ise sonunda bir yere düşmek…" → "…rüzgâr anlamındaki 'wind' /wɪnd/ gibi okunmaz… 'Wind up' ise sonunda kendini bir yerde bulmak…" | "Bir yere düşmek" Türkçede doğal değil ve yanlış anlamı çağrıştırıyor; okunuş farkı da gösterildi. |
| make an effort | quiz.distractors | give → keep | "give an effort" Amerikan konuşma dilinde duyuluyor; "keep an effort" açıkça yanlış. |
| make a fuss | quiz.distractors | deal → worry | "make such a deal about it" "big deal" ile ikinci okuma veriyordu; "make such a worry" olmuyor. |
| take advantage of | l1.tr.gloss | "(fırsatı) değerlendirmek" → "(fırsattan) yararlanmak" | Kısa anlam "değerlendirmek" tek başına "evaluate" okunuyordu; kartın hata maddesi tam bu karışıklığı anlatıyor. |
| take advantage of | l1.tr.gloss_short | "değerlendirmek" → "yararlanmak" | Aynı neden; yeni ana anlamın kısaltması. |
| take advantage of | l1.tr.alt | [fırsattan yararlanmak, fırsat bilmek, kullanmak] → [fırsatı değerlendirmek, fırsat bilmek, kullanmak] | Eski ana anlam `alt`'a geçti. |

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| lose touch | examples[2].tr | "Bağlantıyı koparma! …" → "Sakın kaybolma! …" | "Bağlantıyı koparmak" kasten ilişkiyi kesmek gibi okunuyordu; vedalaşırken doğal söz "sakın kaybolma". |
| run a business | quiz.distractors | lead → do | "lead a small bakery" anlam olarak olabiliyordu. |
| have a go | quiz.distractors | take → try | "take a go" Amerikan konuşmasında duyuluyor; "try a go" açıkça yanlış. |
| out of the question | quiz.distractors | order → way | "out of order" İngiliz İngilizcesinde "kabul edilemez" demek; ikinci okuma veriyordu. |
| at short notice | l1.tr.gloss | "son anda haber vererek" → "son anda haber verilerek" | Edilgen biçim, haberi alan tarafı da kapsıyor ("canceled at short notice", "thanks for coming at such short notice"). |

#### part_05
Değişiklik yok. Bütün quiz'ler denendi. just in case'teki "time" şıkkı ("just in time") güçlü bir tuzak, ama "I'll take my umbrella just in time" bağlamda anlamsız; kaldı. the last straw'daki "drop", kartın hata maddesiyle aynı gerçek hata; kaldı.

## Seviye (B2 dışında olabilecekler; kartlar silinmedi, seviye değiştirilmedi)

- **Daha çok B1:** stand for, pass on, hand over, speed up, wear out, make an effort, take place, take a risk, keep a promise, take it easy, under pressure, just in case. Bunlar Cambridge/EVP listelerinde genelde B1'de geçiyor. B2 destesinde tekrar olarak zararsız; istenirse B1'e çekilebilir (`primary_topic` aralığı B1'i de kapsıyor mu, önce bakılmalı).
- **C1'e yakın:** face up to, fall through. Haber dilinde sık oldukları için B2'de kaldılar.

## Anadili Türkçe birinin bakması gerekenler

1. **Hata maddelerinin sıklığı:** "We took the meeting forward", "create a difference", "fasten the process", "I couldn't hold my tears", "You need to face with the problem", "That was the last drop".
2. **Kilit ekranı karşılıkları:**
   - live up to "layık olmak": tek başına "hak etmek" gibi okunuyor mu?
   - spill the beans "baklayı çıkarmak": kesik bir deyim gibi duruyor mu?
   - at short notice "son anda".
   - put through "bağlamak": tek başına "ip bağlamak" gibi okunuyor mu?
   - make out "zorlukla seçmek": "choose" gibi okunuyor mu?
   - take advantage of "yararlanmak" (yeni).
   - look back on "geçmişe bakmak" (yeni).
3. **Örnek çevirileri:**
   - take in "Kavranamayacak kadar çok şey vardı." doğal mı?
   - give in "uykuya yenik düştü" uygun mu?
   - lose touch "Sakın kaybolma!" uygun mu?
4. **make out notu:** argodaki "öpüşmek" anlamı nota yazılmalı mı?

## Çeldirici ve IPA son kontrolü (2026-10-26)

- `distractor_stats.py`: s32 → 60 quiz, 144 farklı çeldirici; en sık: run out of×4, make×4, put off×3, look up to×3, get rid of×3, do×3. Sınır max(4, %5) = 4; aşan yok, değişiklik gerekmedi. 60 quiz tek tek okundu; her soruda tek doğru cevap var.
- `ipa_dress_stats.py`: s32 → uk_e 0, uk_ɛ 11, us_e 0, us_ɛ 11. DRESS ünlüsü her yerde /ɛ/; düzeltme gerekmedi.
- `dump_lemmas.py`: s32'deki 60 başlık sözcüğünün hiçbiri başka akışta yok.

## Son doğrulama

`python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s32` → `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

Üç bağımsız denetçi B2 destesinden 80 kartlık bir örneklemi okudu (Türkçe, İngilizce ve quiz gözüyle). Bulgular tek tek doğrulandı; doğru olanlar düzeltildi. Bulgulardan çıkan beş sistematik sorun (notlarda 'siz' hitabı, İngilizce cümlede özne olan 'Can' adı, ikinci anlama kayan örnek ve eşdizimler, başka sözcük türünden çeldiriciler, B1 olabilecek seviyeler) s23–s32'nin 600 kartında tarandı.

- Bu akışta değişen kart: **7**, alan: **9**. Değişen kartlara `critic_edited` eklendi.
- Çeldirici: `s32: 60 quizzes, 144 distinct distractors; top: run out of×4, make×4, put off×3, look up to×3, get rid of×3, do×3` (sınır max(4, %5) = 4 aşılmıyor).
- Seviye: değiştirilmedi. B1 olabilecek kartlar bu dosyanın seviye bölümünde zaten işaretli; karar kullanıcıda.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| live_up_to.phv.1 | l1.tr.gloss | "beklentilere layık olmak" → "beklentiyi karşılamak" | 'beklentilere layık olmak' doğal bir eşdizim değil |
| live_up_to.phv.1 | l1.tr.gloss_short | "layık olmak" → "hakkını vermek" | 'layık olmak' tek başına 'hak etmek' anlamına kayıyor |
| live_up_to.phv.1 | l1.tr.alt | "beklentiyi karşılamak, hakkını vermek" → "hakkını vermek, umulduğu kadar iyi olmak" | 'beklentiyi karşılamak' ana anlama çıktı; örneklerdeki karşılık alt'a eklendi |
| take_advantage_of.phr.1 | examples[2] | "Be careful; some people may try to take advantage of you. / Dikkatli ol, bazı insanlar seni kullanmaya çalışabilir." → "I took advantage of the long flight to finish my book. / Uzun uçuşu fırsat bilip kitabımı bitirdim." | 'birini kullanmak' olumsuz anlam |
| keep_a_promise.phr.1 | collocations | "keep your promise, break a promise, make a promise" → "keep your promise, always keep your promises, keep a promise to sb" | 'break/make a promise' başka kalıplar, eşdizim değil |
| have_a_go.phr.1 | l1.tr.note | "Gayriresmî bir kalıptır, çoğunlukla İngiliz İngilizcesinde kullanılır. 'Have a go at sb' ise birine çıkışmak, laf sokmak demektir; karıştırmayın." → "Gayriresmî bir kalıptır, çoğunlukla İngiliz İngilizcesinde kullanılır. 'Have a go at sb' ise birine çıkışmak, laf sokmak demektir; karıştırma." | Notlarda 'siz' yerine destenin geneli gibi 'sen' |
| come_to_a_decision.phr.1 | collocations | "come to a decision, come to the conclusion" → "come to a decision about, come to a quick decision, come to a final decision" | Başlığın kendisi ve 'come to the conclusion' eşdizim değil |
| reach_an_agreement.phr.1 | def.long | "When two people or groups agree on something after discussing it for a long time, for example on a price, a plan or the rules of a deal." → "When two people or groups agree on something after discussing or negotiating it, for example on a price, a plan or the rules of a deal." | 'for a long time' fazla güçlü |
| under_pressure.phr.1 | examples[2] | "The government is under pressure to lower prices. / Hükümet, fiyatları düşürmesi için baskı altında." → "Doctors often have to make decisions under pressure. / Doktorlar çoğu zaman baskı altında karar vermek zorunda kalır." | 3. örnek 'birileri tarafından zorlanmak' anlamına kayıyordu |

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Seviye kararı (2026-10-26)

İki bağımsız yargıç B1 olabilecek adayları ayrı ayrı değerlendirdi. İkisinin de B1 ya da altı dediği **8 kart** `level: "B1"` oldu; `level_source` yine `editorial_estimate`. Kart ID'leri seviye içermediği için değişmedi. Yargıçların ayrıntılı gerekçe metinleri bu düzenlemeye gelmedi; satırlardaki gerekçe, yargıç kararının editör özetidir.

- `en.pass_on.phv.1` (pass on): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.speed_up.phv.1` (speed up): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.make_an_effort.phr.1` (make an effort): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.take_place.phr.1` (take place): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.take_a_risk.phr.1` (take a risk): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.keep_a_promise.phr.1` (keep a promise): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.take_it_easy.phr.1` (take it easy): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.just_in_case.phr.1` (just in case): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.

B2'de kalan adaylar (yargıçlar ayrıştı ya da B2 dedi): `en.hand_over.phv.1`, `en.stand_for.phv.1`, `en.wear_out.phv.1`, `en.under_pressure.phr.1`.

## İkinci örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) her akıştan 7 kartlık bir örneklemi (toplam 70 kart) ikinci kez okudu. 35 bulgunun hepsi kartla karşılaştırıldı ve hepsi gerçek çıktı; düzeltildi. Bulgulardan çıkan yeni sistematik sorunlar s23–s32'nin 600 kartında tarandı: `def.long`'un ikinci bir anlama kayması (ve aynı anlamın örnek, eşdizim, `alt` ya da quiz'e girmesi), başka sözcük türünden ya da yalnızca yazımı benzeyen çeldiriciler, ABD IPA'sında ɝ/ɚ yazımı, boş `confusables` dizisi.

- Bu akışta değişen kart: **7**, alan: **26**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.look_back_on.phv.1`: Türkçe, not (düşük): gerçek. Yalın 'look back' de geçmişi düşünmek demek; not düzeltildi (220 grafem sınırı için kısaltılarak).
- `en.settle_down.phv.1`: İngilizce, iki anlam (yüksek): gerçek. 'Sakinleşmek' anlamı tutuldu; tanımlar, 2. örnek, eşdizimler, gloss, alt ve konu etiketleri tek anlama indi; 'yerleşmek' anlamı nota taşındı.
- `en.take_it_easy.phr.1`: İngilizce, iki anlam (orta): gerçek. 'Dinlenmek, kendini yormamak' anlamı tutuldu; 3. örnek 'I'm going to take it easy after the exams.'; 'Sakin ol!' kullanımı nota taşındı.
- `en.make_a_difference.phr.1`: İngilizce, 3. örnek ve def.long (düşük): gerçek. 'makes no difference' tanımdan, örnekten ve eşdizimlerden çıktı; notta kaldı.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| look_back_on.phv.1 | l1.tr.note | "'On' edatından sonra geçmişteki dönem ya da olay gelir: 'look back on my childhood'. Yalnızca 'look back' ise başını çevirip arkaya bakmak …" → "'On'dan sonra geçmişteki dönem ya da olay gelir: 'look back on my childhood'. Yalın 'look back' arkana dönüp bakmaktır ama 'Looking back, ……" | Yalın 'look back' de geçmişi düşünmek anlamında kullanılıyor; not eksik bilgi veriyordu (bulgu) |
| get_on_with.phv.1 | def.long | silinen cümle: "In British English it can also mean to have a good relationship with someone." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| hold_back.phv.1 | def.long | silinen cümle: "It can also mean to stop someone from making progress." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| pick_out.phv.1 | def.long | silinen cümle: "It can also mean to see or recognize someone in a crowd." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| pick_out.phv.1 | l1.tr.alt | "[ayırmak, tanımak]" → "[ayırmak]" | 'tanımak' kalabalıkta görme anlamı (notta var) (tarama) |
| settle_down.phv.1 | sense_note | "become calm; start a stable life" → "become calm and quiet" | Kart iki anlam taşıyordu (sakinleşmek + düzen kurmak) (bulgu) |
| settle_down.phv.1 | def.micro | "become calm; live stably" → "become calm and quiet" | Tek anlam (bulgu) |
| settle_down.phv.1 | def.short | "become calm and quiet, or start a stable life with a home, partner or job" → "become calm and quiet after being excited, noisy or upset" | Tek anlam (bulgu) |
| settle_down.phv.1 | def.long | "To become calm and quiet after being excited or noisy. It also means to start living a stable life in one place, often with a home, a partn…" → "To become calm and quiet after being excited, noisy or upset. Teachers often say it to a noisy class." | Tek anlam (bulgu) |
| settle_down.phv.1 | grammar.pattern | "settle down (in a place)" → "settle down (after sth)" | Yer kalıbı ikinci anlama aitti (bulgu) |
| settle_down.phv.1 | examples[1] | "After years of traveling, Ozan wants to settle down in Izmir. / Ozan yıllarca gezdikten sonra İzmir'e yerleşmek istiyor." → "It took the dog an hour to settle down after the fireworks. / Havai fişeklerden sonra köpeğin sakinleşmesi bir saat sürdü." | 'settle down in Izmir' ikinci anlam (yerleşmek) (bulgu) |
| settle_down.phv.1 | collocations | "[settle down in a new city, settle down to work]" → "[finally settle down, settle down to work]" | 'settle down in a new city' ikinci anlam (bulgu) |
| settle_down.phv.1 | l1.tr.gloss | "sakinleşmek, yerleşmek" → "sakinleşmek" | Tek anlam (bulgu) |
| settle_down.phv.1 | l1.tr.gloss_short | "sakinleşmek" → "(alan silindi)" | gloss 16 karakterin altına indi (bulgu) |
| settle_down.phv.1 | l1.tr.alt | "[durulmak, düzen kurmak, yerleşik hayata geçmek]" → "[durulmak, yatışmak]" | 'düzen kurmak', 'yerleşik hayata geçmek' ikinci anlam (bulgu) |
| settle_down.phv.1 | l1.tr.note | "İki anlamı vardır: gürültüden sonra sakinleşmek ve bir yere yerleşip düzenli bir hayat kurmak (çoğu zaman evlenip yuva kurmak). Yeni bir ev…" → "Burada gürültüden ya da heyecandan sonra sakinleşmek anlamındadır. Bir yere yerleşip düzenli bir hayat kurmak da 'settle down' ile söylenir…" | İkinci anlam nota taşındı (bulgu) |
| settle_down.phv.1 | tags.topics | "[phrasal_verbs, family_relationships, emotions_feelings]" → "[phrasal_verbs, emotions_feelings]" | family_relationships ikinci anlama aitti (bulgu) |
| make_a_difference.phr.1 | def.long | silinen cümle: "'It makes no difference' means that it is not important." | 'makes no difference' ayrı anlam (fark etmez) (bulgu) |
| make_a_difference.phr.1 | examples[2] | "It makes no difference to me whether we go today or tomorrow. / Bugün ya da yarın gitmemiz benim için fark etmez." → "Recycling really makes a difference to the environment. / Geri dönüşüm çevre için gerçekten fark yaratıyor." | 'It makes no difference to me' fark etmez anlamı (bulgu) |
| make_a_difference.phr.1 | collocations | "[make a big difference, make no difference, make a real difference]" → "[make a big difference, make a real difference, make a difference to sth]" | 'make no difference' ayrı anlam; notta kaldı (bulgu) |
| take_it_easy.phr.1 | sense_note | "relax" → "relax, not do too much" | Tek anlam (bulgu) |
| take_it_easy.phr.1 | def.short | "relax and not do too much, or stay calm and not get angry" → "relax and not do too much, especially when you are tired or ill" | 'stay calm' ikinci anlam (bulgu) |
| take_it_easy.phr.1 | def.long | silinen cümle: "It is also said to tell someone to calm down." | 'calm down' ikinci anlam (bulgu) |
| take_it_easy.phr.1 | examples[2] | "Take it easy! It was only a joke. / Sakin ol! Sadece şakaydı." → "I'm going to take it easy after the exams. / Sınavlardan sonra biraz kafa dinleyeceğim." | 'Take it easy! It was only a joke.' sakin ol anlamı (bulgu) |
| take_it_easy.phr.1 | l1.tr.alt | "[dinlenmek, sakin olmak, rahat olmak]" → "[dinlenmek, kafa dinlemek]" | 'sakin olmak' ikinci anlam (bulgu) |
| take_it_easy.phr.1 | l1.tr.note | "İki kullanımı vardır: dinlenmek, kendini yormamak ve 'sakin ol'. Amerikan İngilizcesinde vedalaşırken de söylenir: 'See you, take it easy!'" → "Burada dinlenmek, kendini yormamak anlamındadır. Biri sinirlenince 'Take it easy!' (Sakin ol!) da denir. Amerikan İngilizcesinde vedalaşırk…" | 'Sakin ol' anlamı nota taşındı (bulgu) |

- Çeldirici: `s32: 60 quizzes, 144 distinct distractors; top: run out of×4, make×4, put off×3, look up to×3, get rid of×3, do×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Üçüncü örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) s23–s32'den 80 kartlık yeni bir örneklemi okudu. 35 bulgu kartla karşılaştırıldı: 33'ü gerçek çıktı ve düzeltildi, 2'si (release, carbon footprint çevirileri) gerekçesiyle reddedildi. Önceki iki turun listesinde olmayan sistematik sorunlar s23–s32'nin 600 kartında tarandı: `gloss_short`'ta kesilmiş söz; `alt`'ın kartın kendi notuyla ya da başka bir kartın ayrımıyla çelişmesi (ve önceki taramada kalan ikinci anlam karşılıkları); `grammar.pattern`'da başka anlamın kalıbı; `def.long`'da önceki anahtar sözcük taramasının kaçırdığı ikinci anlam cümleleri (ve aynı anlamın örnek, eşdizim, quiz'e taşması); akraba kartlar arasında neredeyse aynı örnek ya da boşluklu cümle; boşluğa anlamca hiç uymayan, soruyu ele veren çeldiriciler; şapkası düşmüş hâl / dâhil. Seviyeler değişmedi.

- Bu akışta değişen kart: **9**, alan: **22**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.spill_the_beans.idm.1`: Türkçe, `gloss_short` (orta): gerçek. 'baklayı çıkarmak' kesilmiş deyimdi. `gloss` 'ağzından kaçırmak' oldu (1. ve 2. örnek de böyle çeviriyor). Önerilen kısa biçim 16 değil 17 grafem olduğu için `gloss_short` alt'taki 'sırrı ifşa etmek' oldu; 'baklayı ağzından çıkarmak' 24 grafem sınırını aştığı için alt'a alınamadı, notta anlatılıyor.
- `en.in_the_long_run.phr.1`: Türkçe, alt (orta): gerçek. 'eninde sonunda' notun ayırdığı 'in the end' anlamı; alt ['zamanla', 'ileride'].
- `en.wind_down.phv.1`: Türkçe, İngilizce ve quiz gözü, 2. örnek ve boşluklu cümle (düşük; üç denetçi aynı sorun): gerçek. 2. örnek 'After work, Kerem winds down with a bit of gardening.', quiz 'On Sunday evenings, I ______ with a jigsaw puzzle before the busy week starts.' Akrabalı kartlar arası benzer cümle taraması yapıldı.
- `en.give_in.phv.1`: İngilizce, 3. örnek ve eşdizim (orta): gerçek. 'The kids begged for a dog, and finally their parents gave in.'; 'give in to demands'.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| hand_over.phv.1 | l1.tr.alt | "[devretmek, vermek]" → "[vermek]" | 'devretmek' işi devretme anlamı (notta var) (tarama) |
| hand_over.phv.1 | def.long | silinen cümle: "It is also used when you give control of a job or a business to someone else." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| hand_over.phv.1 | def.short | "give something to someone, especially when they ask for it or take control of it" → "give something to someone, especially when they ask for it" | 'or take control of it' ikinci anlam (tarama) |
| hand_over.phv.1 | examples[2] | "Murat will hand over the project to Zeynep before he goes on leave. / Murat izne çıkmadan önce projeyi Zeynep'e devredecek." → "The thief handed over the stolen bag to the police. / Hırsız çaldığı çantayı polise teslim etti." | Projeyi devretmek ikinci anlam (tarama) |
| hand_over.phv.1 | collocations | "[hand over the keys, hand over control, hand over to sb]" → "[hand over the keys, hand over the money, hand over to sb]" | 'hand over control' ikinci anlam (tarama) |
| hand_over.phv.1 | quiz.cloze | "When Mr. Aydın retired, he ______ the family business to his daughter." → "The guard asked us to ______ our bags before we went into the concert." | Aile işini devretmek ikinci anlamı sınıyordu (tarama) |
| hand_over.phv.1 | quiz.distractors | "[handed out, took over, turned down]" → "[hand out, take over, turn down]" | Yeni cümleye göre yalın biçim (tarama) |
| hand_over.phv.1 | quiz.answer | "handed over" → "hand over" | Yeni cümleye göre yalın biçim (tarama) |
| give_in.phv.1 | examples[2] | "Hakan wanted to stay up, but he gave in to sleep at midnight. / Hakan geç saate kadar oturmak istiyordu ama gece yarısı uykuya yenik düştü." → "The kids begged for a dog, and finally their parents gave in. / Çocuklar bir köpek için yalvarıp durdu, sonunda anne babaları boyun eğdi." | 'gave in to sleep' baskı olmadan bir dürtüye yenilmek (bulgu) |
| give_in.phv.1 | collocations | "[give in to pressure, give in to temptation, refuse to give in]" → "[give in to pressure, give in to demands, refuse to give in]" | 'give in to temptation' başka anlam (bulgu) |
| wind_down.phv.1 | examples[1] | "After work, Pınar winds down with a short walk. / Pınar iş çıkışı kısa bir yürüyüşle rahatlıyor." → "After work, Kerem winds down with a bit of gardening. / Kerem iş çıkışı biraz bahçeyle uğraşarak gevşiyor." | unwind kartındaki 'Pınar … with a short walk' cümlesinin neredeyse aynısıydı (bulgu) |
| wind_down.phv.1 | quiz.cloze | "After a long day at the office, I like to ______ with some music and a cup of tea." → "On Sunday evenings, I ______ with a jigsaw puzzle before the busy week starts." | unwind kartının boşluklu cümlesinin neredeyse aynısıydı (bulgu) |
| make_a_fuss.phr.1 | def.long | silinen cümle: "'Make a fuss of/over sb' means to give someone a lot of attention." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| make_a_fuss.phr.1 | examples[2] | "My grandmother always makes a fuss over us when we visit. / Ziyarete gittiğimizde babaannem hep üstümüze titrer." → "He made a fuss because his hotel room was a bit small. / Otel odası biraz küçük diye yaygara kopardı." | 'make a fuss over us' üstüne titremek anlamı (tarama) |
| take_advantage_of.phr.1 | grammar.pattern | "take advantage of sth/sb" → "take advantage of sth" | 'take advantage of sb' kişiyi kullanma anlamı (notta var) (tarama) |
| take_advantage_of.phr.1 | def.long | silinen cümle: "With a person, it often has a bad meaning: to use someone unfairly for your own benefit." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| keep_a_promise.phr.1 | examples[2] | "The mayor kept her promise and opened a new library. / Belediye başkanı sözünü tuttu ve yeni bir kütüphane açtı." → "The mayor kept her promise and built a new playground. / Belediye başkanı sözünü tuttu ve yeni bir oyun parkı yaptırdı." | başka bir kartta neredeyse aynı cümle vardı (mayor: 'The mayor opened the new library') (tarama) |
| in_the_long_run.phr.1 | l1.tr.alt | "[eninde sonunda, ileride]" → "[zamanla, ileride]" | 'eninde sonunda' notun ayırdığı 'in the end' anlamı (bulgu) |
| under_pressure.phr.1 | examples[1] | "Students are under a lot of pressure before exams. / Öğrenciler sınavlardan önce büyük bir baskı altında." → "She was under pressure to finish the report by Monday. / Raporu pazartesiye kadar bitirmesi için baskı altındaydı." | başka bir kartta neredeyse aynı cümle vardı (pressure: 'Exams put a lot of pressure on students') (tarama) |
| spill_the_beans.idm.1 | l1.tr.gloss | "baklayı ağzından çıkarmak" → "ağzından kaçırmak" | Kartın anlamı (kazara söylemek) ve 1.–2. örnekler 'ağzından kaçırmak' (bulgu) |
| spill_the_beans.idm.1 | l1.tr.gloss_short | "baklayı çıkarmak" → "sırrı ifşa etmek" | 'baklayı çıkarmak' kesilmiş deyim; 'ağzından kaçırmak' 17 grafem olduğu için alt'taki 16 grafemlik karşılık seçildi (bulgu) |
| spill_the_beans.idm.1 | l1.tr.alt | "[ağzından kaçırmak, sırrı ifşa etmek]" → "[sırrı ifşa etmek]" | Eski gloss notta anlatılıyor; 24 grafem sınırını aştığı için alt'a alınamadı (bulgu) |

- Çeldirici: `s32: 60 quizzes, 145 distinct distractors; top: run out of×4, make×4, put off×3, look up to×3, get rid of×3, do×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
