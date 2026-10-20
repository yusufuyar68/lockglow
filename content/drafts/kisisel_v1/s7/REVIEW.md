# s7 QA incelemesi (temel sıfatlar ve zarflar)

Kapsam: `content/drafts/kisisel_v1/s7/part_01.json` ... `part_06.json`. Bakılan kriterler: `SYSTEM_C` listesi (anlam, tanım, örnek, Türkçe karşılık, Türkçe çeviri, IPA, seviye, hata, not, etimoloji, quiz) ve ajan görevinde ayrıca istenen beş konu (zarf quizleri, hata cümleleri, `loud`/`strong` çevirileri, `sure`/`really` IPA'sı, `enough`).

## Özet

- İncelenen kart: **59** (33 sıfat, 25 zarf, 1 belirleyici)
- Değişen kart: **29** (hepsine `critic_edited` eklendi)
- Toplam düzenleme (alan sayısı): **35** (12'si İngiliz IPA'sında tek tip düzeltme)
- Reddedilen kart (`critic_reject`): **0**
- Doğrulayıcı (tüm klasör): `59 kart · 59 şemadan geçti · 0 hata · 0 uyarı`

## Genel bulgular

- Kartlar genel olarak sağlam: anlamlar A2 için doğru seçilmiş, İngilizce örnekler doğal, ilk örnekler kilit ekranı için güvenli, Türkçe çeviriler geri çevrildiğinde İngilizceyle uyuşuyor. Etimolojiler tek tek kontrol edildi (early, late, busy, free, sure, fast, easy, empty, quiet, loud, careful, alone, almost, again, also, only, soon, else ve diğerleri); halk etimolojisi yok. Tek düzeltme `sure` kartında: Eski Fransızca yazımı `sür` değil `seur`.
- Sahte dost: tüm kartlarda `null` ve doğru (`popular` ↔ `popüler` sahte dost değil, eş kökenli; kart zaten `cognate`).
- Seviyeler makul; bariz yanlış seviye bulunmadı (especially, exactly, quite, even, instead, anyway B1; diğer zarflar A1-A2).
- Boşluk quizleri: zarf quizlerinin çoğu tek doğru cevaplıydı. Üç kartta (still, almost, maybe) cümle ya da çeldirici sıkılaştırıldı; ayrıca important kartında doğal olmayan bir senaryo değiştirildi.
- Çeldiricilerin çoğu aynı havuzdan geliyor (never, yet, often, soon...). Bir işlevi sınamıyorlar ama cümlede açıkça yanlışlar; "emin olamıyorsan bırak" kuralı gereği ve tek doğru cevap korunduğu için dokunulmadı. Kalıbın gerçek hata biçimlerini kullanan quizler (else: other/another/next; too: very/so/quite) zaten iyi.
- Sıfat → zarf hataları (fastly, hardly, lately, carefully) gerçek ve yaygın. Ancak üçünün açıklaması ("Türkçede sıfat zarf gibi kullanılır, bu yüzden -ly eklenir") kendi içinde çelişiyordu: Türkçedeki bu özellik -ly eklemeyi gerektirmez, tersine gereksiz kılar. Açıklamalar, hatanın asıl nedenini (İngilizcede çoğu zarfın -ly alması) dürüstçe söyleyecek biçimde yeniden yazıldı. `careful` kartındaki açıklama doğruydu ve değişmedi (orada Türkçedeki "dikkatli sür" gerçekten -ly'yi düşürtüyor).
- IPA: s1–s4 geleneği, kısa DRESS ünlüsünü hem ABD hem İngiliz IPA'sında /ɛ/ yazmak (ör. recipe /ˈrɛsɪpi/, `parent` UK /ˈpeərənt/ yalnızca diftongda /e/). s7'de 12 kartta İngiliz IPA'sı /e/ ile yazılmıştı; /ɛ/ yapıldı. (Not: s5'te de aynı sapma var, bu görevin kapsamı dışında bırakıldı.)

## Özellikle sorulan konular ve kararlar

### 1. Zarf quizleri

Her şık boşluğa tek tek konuldu.

| Kart | Şıklar boşlukta | Karar |
|---|---|---|
| usually | always / never / rarely: "on most days, not on Sundays" ile üçü de açıkça yanlış | Bırakıldı |
| sometimes | always / never / yet yanlış; `usually`, `often` şıkta yok | Bırakıldı |
| still | `already` eski cümlede akla yatkındı ("evening ... already raining"), `yet` eski/edebî | **Yeniden kuruldu**: "It began to rain at noon and has not stopped..." |
| already | yet ("has yet bought" ✗), never, soon yanlış; `just` şıkta yok | Bırakıldı |
| yet | soon / never / often ("has not arrived soon/never/often") yanlış; `still` şıkta yok | Bırakıldı |
| almost | `never` ("The cake is never finished") alışkanlık okumasıyla geçebilirdi | **Çeldirici değişti**: never → hardly |
| probably | never / hardly / always: kara bulutlar bağlamı ile üçü de yanlış | Bırakıldı |
| quite | never / yet / soon yanlış; `very`, `really` şıkta yok (olsaydı çakışırdı) | Bırakıldı |
| really | never / hardly / rarely ("I love this song. I ... like it") yanlış | Bırakıldı |
| too | very / so / quite: "... tired to cook" yapısı yalnızca `too` ile kurulur | Bırakıldı (iyi quiz) |
| also | never / hardly / yet yanlış; `too`, `as well` şıkta yok | Bırakıldı |
| even | never / often / yet yanlış; `only`, `just` şıkta yok | Bırakıldı |
| only | never / also / yet: "also on Saturdays" + "On other days it is closed" çelişir | Bırakıldı |
| just | never / often / soon yanlış; `already` şıkta yok (olsaydı iki şık doğru olurdu) | Bırakıldı |
| soon | yesterday / never / always yanlış; `later` şıkta yok | Bırakıldı |
| later | early / yesterday / before yanlış; `soon` şıkta yok | Bırakıldı |
| instead | never / yet / soon yanlış | Bırakıldı |
| anyway | never / yet / already yanlış; `still` şıkta yok | Bırakıldı |
| else | other / another / next: gerçek hata biçimleri, tek doğru cevap | Bırakıldı (iyi quiz) |
| maybe | Cümle çelişkiliydi ("I'm not sure. I will come, but ...") | **Yeniden kuruldu** |
| especially, exactly, never, again | Tek doğru cevap, çeldiriciler açıkça yanlış | Bırakıldı |

### 2. Hata cümleleri

| Hata | Karar |
|---|---|
| "You have right." | **Gerçek, bırakıldı.** Kaynak "haklısın" değil, "hakkın var" kalıbı ("haklısın" zaten "you are right" ile birebir örtüşür). Kartın açıklaması da bunu söylüyor. Romance dilleri ve Almanca konuşanlarda çok bilinen bir hata; Türk konuşurlardaki yaygınlığı doğrulanamadı, anadili Türkçe kişi onaylamalı. |
| "A child even can use..." | Gerçek, bırakıldı. Türkçede "bile" kelimeden sonra gelir (çocuk bile), bu yüzden `even` sona kayar. |
| "I sure he will come." | **Zayıf, değiştirildi.** "I'm sure" erken öğrenilen bir kalıp ve "I sure do" gerçek bir İngilizce yapı. Yerine Türkçe -dan hâlinden gelen "I am sure from my answer." kondu (afraid from ile aynı mekanizma). |
| "It is danger." | Gerçek, bırakıldı; ama Türkçeden çok isim/sıfat karışıklığı. Açıklamaya "-li ≈ -ous" köprüsü eklendi. |
| "fastly" | Gerçek ve yaygın, bırakıldı. Açıklama düzeltildi. Nottaki "diye bir kelime yoktur" "kullanılmaz" yapıldı (eski İngilizcede ender de olsa vardı). |
| "full with" | Gerçek ve tipik (-la/-le → with). Bırakıldı. |
| "feel myself safe" | Gerçek ve tipik ("kendimi güvende hissediyorum"). Bırakıldı. |
| "difficult to me" | Gerçek ve tipik (-e hâli → to). Bırakıldı. |
| "I go usually..." | **Silindi** (liste boş kaldı). Fiil-zarf-nesne sırası Fransızca/İspanyolca konuşanların hatası. Türkçede zarf fiilden önce gelir, yani "I usually go" ile örtüşür; Türkçeye özgü bir hata olduğu doğrulanamadı. Sıra bilgisi notta duruyor. |
| late / lately | Gerçek ve yaygın, bırakıldı. Açıklama düzeltildi. |
| hard / hardly | Gerçek ve yaygın, bırakıldı. Açıklama çelişkiliydi; düzeltildi. |
| `right` biçimleri | Doğru: "You are right" = haklısın, "the right bus" = doğru otobüs, "right" (sağ) notta ayrı. |

### 3. Çeviriler

- `loud` = "yüksek (ses)": doğal. "Sesi yüksek", "yüksek sesle", "müziğin sesi yüksek" standart Türkçe. Gloss `yüksek sesli` de ("yüksek sesli müzik") yaygın. Tek düzeltme: 3. örnekte çeviriye "çok" eklenmişti; çıkarıldı.
- `strong` = "kuvvetli rüzgâr": doğal ve standart (hava durumu dilinde "kuvvetli rüzgâr"). "Güçlü rüzgâr" da kullanılır. Değişmedi.

### 4. IPA

- `sure`: ABD /ʃʊr/, İngiliz /ʃɔː/ bırakıldı. İngiliz için /ʃɔː/ ana sözlüklerde ilk sırada ve s8'deki `make_sure` ile tutarlı; /ʃʊə/ de yaygın bir ikinci biçim. Alan tek değer taşıdığı için ikincisi eklenmedi.
- `really`: ABD /ˈriːəli/, İngiliz /ˈrɪəli/ bırakıldı. Tutarlı (s9 `idea`: /aɪˈdiːə/ ~ /aɪˈdɪə/) ve ana sözlüklerin (ör. Cambridge) verdiği biçim. /ˈrɪli/ (ve ABD'de /ˈriːli/) yaygın kısaltılmış söyleyiştir, savunulabilir ama ana değer olarak seçilmedi.
- 12 kartta İngiliz /e/ → /ɛ/ (yukarıda genel bulgularda).
- Vurgu işaretleri kontrol edildi: important (ikinci hece), especially, together, instead, probably, usually, dangerous, already, anyway doğru.

### 5. `enough` (pos: det)

Örnekler ikisini de gösteriyor: belirleyici (enough chairs, enough money) ve sıfattan sonra (old enough). Karar: tek kart, tek çekirdek anlam ("gerektiği kadar"), `pos: det` ve id (`en.enough.det.1`) korundu.
- Quiz belirleyici kullanımı sınıyor (enough chairs; every/each/another sayı uyumsuzluğuyla yanlış) ve ilk örnekle tutarlı.
- Not ve hata cümlesi ("She is enough old", Türkçe "yeterince büyük" yüzünden) sıfat sonrası kullanımı anlatıyor; bu en gerçekçi Türkçe hatası olduğu için korundu.
- Eksik olan, tanımın ikinci kullanımı anlamla bağlamamasıydı. `def.long` şimdi "old enough to drive means 'as old as you need to be'" diyerek ikisini aynı anlamda birleştiriyor.
- Ayrı bir `enough` zarf kartı gerekirse sonraki turda eklenebilir; bu görevde kart eklenmedi.

## Değişiklik tablosu

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.late.adj.1 | l1.tr.mistakes[0].why | Türkçede 'geç' hem sıfat hem zarftır (geç geldi). İngilizcede zarf olarak da 'late' kullanılır. 'Lately' ise 'son zamanlarda' demektir. → Türkçede 'geç geldi' dersiniz; 'geç' hem sıfat hem zarf olur. İngilizcede de 'late' zarf olarak aynen kalır. Zarf diye '-ly' eklemek akla gelir; ama 'lately' 'son zamanlarda' demektir. | Eski açıklama Türkçenin neden yanılttığını söylemiyordu. Hata gerçek ve yaygın (late/lately); açıklama düzeltildi. |
| en.free.adj.1 | l1.tr.alt | ücretsiz, parasız → ücretsiz | 'parasız' bir A2 öğrencisi için 'parası olmayan' (broke) anlamına gelir; 'bedava' karşılığı olarak yanıltıcı. |
| en.ready.adj.1 | ipa.uk | /ˈredi/ → /ˈrɛdi/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.sure.adj.1 | def.micro | without any doubt → having no doubt | Eski tanım ('without any doubt') zarf gibi okunuyordu; sıfat öbeği olmalı (I'm sure = I'm having no doubt). |
| en.sure.adj.1 | l1.tr.mistakes | 'I sure he will come.' → 'I'm sure he will come.' → 'I am sure from my answer.' → 'I am sure about my answer.' | 'I sure he will come' tipik bir Türkçe hatası değil ('I'm sure' erken öğrenilen bir kalıp; 'I sure do' da gerçek bir İngilizce yapı). Yerine -dan hâlinden gelen 'sure from' hatası kondu. |
| en.sure.adj.1 | etymology.text | From Old French 'sür', from Latin 'securus', meaning 'free from worry'. 'Secure' comes from the same Latin word. → From Old French 'seur', from Latin 'securus', meaning 'free from worry'. 'Secure' comes from the same Latin word. | Eski Fransızca yazımı 'seur' / 'sur'; 'sür' standart bir yazım değil. |
| en.fast.adj.1 | l1.tr.mistakes[0].why | Türkçede 'hızlı' ve 'hızlıca' gibi biçimler akla gelir, bu yüzden '-ly' eklenir. İngilizcede 'fast' hem sıfat hem zarftır ve '-ly' almaz. → Türkçede 'hızlı' sıfat da zarf da olur (hızlı gitti); İngilizcede de 'fast' böyledir. 'Quickly', 'slowly' gibi zarflar '-ly' aldığı için 'fastly' denir, ama bu yanlıştır. | Eski açıklama ('hızlıca akla gelir') zorlamaydı; hata gerçek (fastly), nedeni İngilizce '-ly' kuralının genellenmesi. |
| en.fast.adj.1 | l1.tr.note | 'Fast' hem sıfat hem zarftır: a fast car, drive fast. Zarf için '-ly' eklenmez; 'fastly' diye bir kelime yoktur. 'Quick' = çabuk, kısa sürede. → 'Fast' hem sıfat hem zarftır: a fast car, drive fast. Zarf için '-ly' eklenmez; 'fastly' kullanılmaz. 'Quick' = çabuk, kısa sürede. | 'fastly diye bir kelime yoktur' fazla kesin: eski İngilizcede ender de olsa vardı. 'Kullanılmaz' doğru ve yeterli. |
| en.hard.adj.1 | l1.tr.mistakes[0].why | Türkçede sıfat zarf gibi de kullanılır (sıkı çalışmak), bu yüzden zarf için '-ly' eklenir. Ama 'hardly' = neredeyse hiç: 'He hardly studies' = neredeyse hiç çalışmaz. → Türkçede 'sıkı' sıfat da zarf da olur (sıkı çalıştı); İngilizcede de 'hard' böyledir. '-ly' eklenirse anlam değişir: 'hardly' = neredeyse hiç. He hardly studies = neredeyse hiç çalışmaz. | Eski açıklama kendi içinde çelişiyordu ('sıfat zarf gibi kullanılır, bu yüzden -ly eklenir'). Hata gerçek (hard/hardly); açıklama düzeltildi. |
| en.important.adj.1 | quiz.cloze | The teacher will give us the exam questions on Friday, so this class is very ______. → Our final exam is on Monday, so studying this weekend is very ______. | Eski cümlede öğretmenin sınav sorularını önceden vermesi doğal olmayan bir durumdu; günlük, doğal bir bağlam kuruldu. Tek doğru cevap 'important'. |
| en.same.adj.1 | def.long | Exactly like another person or thing. You always need 'the' before it: the same bag, the same day. 'The same as' compares two things. → Exactly like another person or thing. You usually need 'the' before it: the same bag, the same day. 'The same as' compares two things. | 'always' fazla kesin: 'Same here!' gibi kalıplarda 'the' yok. 'Usually' doğru. |
| en.same.adj.1 | l1.tr.mistakes[0].why | Türkçede 'aynı' önüne bir şey almaz (aynı öğretmen). İngilizcede 'same' önünde her zaman 'the' gerekir: the same teacher. → Türkçede 'aynı' önüne bir şey almaz (aynı öğretmen). İngilizcede 'same' önünde hemen her zaman 'the' gerekir: the same teacher. | 'Her zaman' fazla kesin (aynı gerekçe). |
| en.empty.adj.1 | ipa.uk | /ˈempti/ → /ˈɛmpti/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.loud.adj.1 | def.long | Making a lot of sound, so it is easy to hear, sometimes too easy. Music, a voice, a car or a party can be loud. Neighbors often ask us to turn loud music down. → Making a lot of sound, so it is easy to hear, sometimes too easy. Music, a voice, a car or a party can be loud. Neighbors may ask you to turn the music down if it is too loud. | 'turn loud music down' doğal bir söyleyiş değil; 'turn the music down' kullanılır. |
| en.loud.adj.1 | examples[2].tr | Dışarıdan çok yüksek bir ses geldi ve köpek uyandı. → Dışarıdan yüksek bir ses geldi ve köpek uyandı. | Çeviriye 'çok' eklenmişti; 'a loud noise' ≠ 'a very loud noise'. |
| en.dangerous.adj.1 | l1.tr.mistakes[0].why | Türkçede 'tehlike' (isim) ve 'tehlikeli' (sıfat) ayrı kelimelerdir. İngilizcede de öyledir: isim 'danger', sıfat 'dangerous'. 'It is danger' denmez. → Türkçede 'tehlike' ve 'tehlikeli' ayrı sözcüklerdir; '-li' eki İngilizcede çoğu zaman '-ous' olur. 'Danger' isimdir (tehlike), 'dangerous' sıfattır (tehlikeli). | Hata gerçek (It is danger); eski açıklama 'İngilizcede de öyledir' diyerek Türkçenin neden yanılttığını söylemiyordu. '-li' ≈ '-ous' köprüsü eklendi. |
| en.healthy.adj.1 | ipa.uk | /ˈhelθi/ → /ˈhɛlθi/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.alone.adj.1 | l1.tr.alt | tek başına, tek → tek başına, yapayalnız | 'tek' tek başına 'alone' karşılığı değil ('tek başına' kalıbı zaten var); 'yapayalnız' gerçek bir karşılık. |
| en.enough.det.1 | def.long | As much or as many as you need, not less. You can have enough money, time or food. After an adjective, it goes behind it: She is old enough to drive. → As much or as many as you need, not less. You can have enough money, time or food. After an adjective it goes behind it: old enough to drive means 'as old as you need to be'. | Örneklerde hem belirleyici (enough money) hem sıfat sonrası (old enough) kullanım var; tanım ikinci kullanımın anlamını bağlamıyordu. Aynı çekirdek anlam ('gerektiği kadar') olarak bağlandı. |
| en.still.adv.1 | quiz.cloze | It began to rain at noon. It is now evening, and it is ______ raining. → It began to rain at noon and has not stopped. It is evening now, and it is ______ raining. | 'already' çeldiricisi eski cümlede ('It is now evening, and it is already raining') akla yatkın okunabiliyordu; 'has not stopped' ile 'already' açıkça yanlış oldu. |
| en.already.adv.1 | ipa.uk | /ɔːlˈredi/ → /ɔːlˈrɛdi/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.yet.adv.1 | ipa.uk | /jet/ → /jɛt/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.almost.adv.1 | quiz.distractors | never, often, yet → hardly, often, yet | 'never' ('The cake is never finished. Only one piece is left.') alışkanlık okumasıyla kabul edilebilirdi; 'hardly' gerçek bir karışıklık çeldiricisi ve cümlede açıkça yanlış. |
| en.again.adv.1 | ipa.uk | /əˈɡen/ → /əˈɡɛn/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.usually.adv.1 | l1.tr.mistakes | 'I go usually to work by bus.' → 'I usually go to work by bus.' → (boş liste) | 'I go usually to work' (fiil-zarf-nesne) Türkçe sıra yapısından gelmez: Türkçede zarf fiilden önce gelir, yani 'I usually go' ile örtüşür. Türkçe konuşanlara özgü bir hata olduğu doğrulanamadı; silindi. |
| en.never.adv.1 | ipa.uk | /ˈnevə/ → /ˈnɛvə/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.maybe.adv.1 | quiz.cloze | I'm not sure. I will come, but ______ I will be late. → I will come to your party, but ______ I will be a little late. | Eski cümlede 'I'm not sure. I will come' çelişkili okunuyordu; bağlam netleştirildi, tek doğru cevap 'maybe'. |
| en.maybe.adv.1 | def.long | Used when you are not sure about something. It can be true or it can happen, but it can also be not. It usually goes at the start of a sentence: 'Maybe it will rain.' → Used when you are not sure about something. It may be true, or it may not. It usually goes at the start of a sentence: 'Maybe it will rain.' | Eski cümle ('it can also be not') bozuk İngilizceydi; sade ve doğal biçimde yeniden yazıldı. |
| en.especially.adv.1 | ipa.uk | /ɪˈspeʃəli/ → /ɪˈspɛʃəli/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.quite.adv.1 | l1.tr.note | 'Quite' = oldukça. 'Very' (çok) kadar güçlü değildir. Sıfattan önce gelir: quite good. Dikkat: 'quiet' (sessiz) ayrı bir kelimedir. 'Not quite' = tam olarak değil. → 'Quite' = oldukça. İngiliz İngilizcesinde 'very' (çok) kadar güçlü değildir; ABD'de bazen daha güçlü anlamda kullanılır. Sıfattan önce gelir: quite good. 'Quiet' (sessiz) ayrı kelimedir. 'Not quite' = tam değil. | 'Very kadar güçlü değildir' yalnızca İngiliz kullanımı için kesin; ABD'de 'quite good' çoğu zaman 'very good'a yakındır. Not buna göre yumuşatıldı. |
| en.just.adv.1 | examples[1].tr | Sam yeni çıktı. Hâlâ yetişebilirsin. → Sam az önce çıktı. Hâlâ yetişebilirsin. | Karşılık 'az önce' kartın başlık karşılığı; çeviride görünmüyordu ('yeni' alt karşılık). |
| en.together.adv.1 | ipa.uk | /təˈɡeðə/ → /təˈɡɛðə/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.instead.adv.1 | ipa.uk | /ɪnˈsted/ → /ɪnˈstɛd/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.anyway.adv.1 | ipa.uk | /ˈeniweɪ/ → /ˈɛniweɪ/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |
| en.else.adv.1 | ipa.uk | /els/ → /ɛls/ | s1–s4 geleneği: kısa DRESS ünlüsü hem ABD hem İngiliz IPA'da /ɛ/ yazılıyor; s7'de İngiliz IPA'da /e/ kalmıştı. |

## Anadili Türkçe birinin bakması gerekenler

- **en.right.adj.1**: `mistakes[0]` "You have right." "Hakkın var" kalıbından geldiği varsayıldı. Türk konuşurlarda gerçekten yaygın mı?
- **en.sure.adj.1**: Yeni hata "I am sure from my answer." ("cevabımdan eminim" → from). Gerçekten böyle söyleniyor mu, yoksa "I am sure about..." kalıbında asıl hata başka mı? Eski hata ("I sure he will come") çıkarıldı.
- **en.free.adj.2**: `mistakes[0]` "Are you empty on Saturday?" "Boşum" = müsaitim, çok yaygın; ama İngilizcede "empty" diye çevrildiği sık görülüyor mu?
- **en.just.adv.1**: `mistakes[0]` "I just have arrived." Türkçede zarf fiilden önce geldiği için mantıklı, ama sık görülen bir hata olduğu doğrulanamadı.
- **en.still.adv.1**: `mistakes[0]` "Is she yet at work?" ("Daha işte mi?" → yet). Sık mı, yoksa yapay mı?
- **en.already.adv.1**: `mistakes[0]` "I haven't done my homework already." Bazı anadili konuşurlar da söyler (özellikle ABD); Türk öğrenci hatası olarak anlamlı mı?
- **en.different.adj.1, en.dangerous.adj.1**: Hata gerçek (the different / It is danger) ama Türkçeden çok isim-sıfat karışıklığı. Tutulsun mu, silinsin mi? Bu rapordaki karar: tut (yaygın), dürüst açıklamayla.
- **en.usually.adv.1**: Hata listesi boşaltıldı. Türkçe konuşanların "usually" ile yaptığı gerçek bir hata biliyorsanız eklenebilir (ör. cümle sonunda "I go to work by bus usually").
- **en.never.adv.1**: Gloss "asla"; ama üç örnek çevirisi de "hiç / hiçbir" kullanıyor ("hiç kahve içmem"). Günlük dilde birinci karşılık "hiç" olmalı mı?
- **en.loud.adj.1**: Gloss "yüksek sesli"; 2. örnek "Ayşe'nin sesi yüksek". "Gür sesi var" daha doğal olur mu?
- **en.busy.adj.1**: 3. örnek "Alışveriş caddesi cumartesi günleri çok işlek". "Çok kalabalık" daha doğal mı? ('işlek' alt listede olduğu için bırakıldı.)
- **en.quite.adv.1**: Yeni not, ABD'de 'quite'ın çoğu zaman 'very'ye yakın olduğunu söylüyor. Eklenen bu bilgi yeterince yumuşak mı?
- **en.alone.adj.1**: Quizde "I live lonely" çeldiricisi iyi olurdu, ama edebî dilde kabul edilebilir göründüğü için eklenmedi.
- **en.almost.adv.1**: 3. örnek "neredeyse otobüsü kaçırıyordum". "Az kalsın ... kaçırıyordum" ya da "neredeyse ... kaçıracaktım" daha doğal mı?

## Sayılar

| Ölçü | Sayı |
|---|---|
| İncelenen kart | 59 |
| Değişen kart | 29 |
| Düzenlenen alan | 35 |
| Reddedilen kart | 0 |
| Doğrulayıcı sonucu | 0 hata, 0 uyarı |

## Çeldirici çeşitlendirme (2026-10-19)

- Önce: 59 quizzes, 55 distinct distractors; top: never×19, early×15, yet×12, empty×10, dirty×10, busy×7
- Sonra: 59 quizzes, 81 distinct distractors; top: tall×4, early×4, busy×4, free×4, sure×4, empty×4 (hiçbir çeldirici 4'ten fazla değil)
- Değişen kart: 40 (yalnızca `quiz.distractors` ve `meta.qa_flags`; her birine `"distractors_diversified"` eklendi).
- `quiz.cloze` değiştirilen kart: yok. Doğru cevaplar ve cümleler aynı kaldı.
- Zarf sorularında zarflar birbirinin yerine geçebildiği için çeldiriciler başka işlevden zarflar (here, away, ago, tomorrow, far...) veya cümleye açıkça uymayan sözcüklerle değiştirildi; her yeni şık boşluğa konup tek tek okundu; o cümlede doğru olabilecek sözcükler (ör. `again` sorusunda `slowly`/`tomorrow`, `anyway` sorusunda `there`/`alone`, `maybe` sorusunda `perhaps`/`tomorrow`) kullanılmadı.
- `free.adj.1` (bedava) ve `free.adj.2` (müsait) sorularında diğer anlama gelen bir çeldirici yok (`busy`, `available`, `cheap` kullanılmadı).
- Doğrulayıcı: `python -m vocabpipe.validate --strict` → 0 hata · 0 uyarı.
