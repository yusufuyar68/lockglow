# s35 QA incelemesi (YDS/YÖKDİL akademik sıfatlar ve zarflar)

Kapsam: `content/drafts/kisisel_v1/s35/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: YDS ve YÖKDİL okuma parçalarında sık geçen akademik sıfatlar (36) ve zarflar (24). Seviye: 20 B2, 40 C1 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** bir yazar ajanı, `1_yazar_kurallari.md`, s32 biçimi.
2. **Denetim:** bir denetçi ajanı (bu rapor), `2_denetci_kurallari.md` ve B2 turu tuzak listesi. 60 kart tek tek okundu. Bakılanlar:
   - anlam ve tek anlam ilkesi (sense_note, def, örnekler, eşdizimler, kalıp, alt, quiz);
   - örneklerin geri çevirisi;
   - gloss, gloss_short ve alt;
   - hata maddeleri;
   - quiz'de her şık boşluğa konarak tek doğru cevap;
   - IPA, seviye ve YDS'ye uygunluk.

   Yazarın "emin olmadığım" maddeleri ayrıca tartıldı (aşağıda).

## Özet

- İncelenen kart: **60** (B2: 20, C1: 40). Tür: 36 sıfat, 24 zarf.
- Bütün kartlarda:
  - `primary_topic`: `yds_yokdil_core`, exams `["yds","yokdil"]`;
  - `sensitivity`: 0;
  - etimoloji `null`, sahte dost `null`.
- Değişen kart: **11** (`critic_edited`), 13 alan.
- Reddedilen kart (`critic_reject`): **0**.
- **mistakes:** 1 kartta 1 madde (scarcely, çifte olumsuzluk). Madde gerçek, kaldı.
- **Çeldirici:** en sık kullanılan şıklar 4'er kez geçiyor (ambiguous, explicit, tentative, reluctant, adequate, implicit, adverse, abundant, fragile, hostile, respectfully, scarcely). Sınır 4, aşılmıyor.
- **IPA:** DRESS `/ɛ/` her yerde. ɝ/ɚ yok. Boş `confusables` yok. "Can" adı yok. Satır sonları LF.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Quiz'de zayıf bağlam ya da örnekle aynı cümle.**
     - explicit: "The rules are ___: no phones…" cümlesinde "implicit" de kural içeriğiyle okunabiliyordu.
     - vast: "only three failed" küçük bir sınıfta "slim majority" ile de uyuşabiliyordu.
     - sufficient: quiz, 3. örneğin ("not sufficient evidence to find him guilty") neredeyse aynısıydı.
  2. **alt'ta notla çelişen ya da başka anlama kayan Türkçe.**
     - tentative: "geçici", notun uyardığı temporary karışıklığının ta kendisi. 2. örnekteki "geçici anlaşma" da aynı sorunu taşıyordu.
     - arguably: "muhtemelen", kartın anlamı değil (probably).
     - abundant: "bereketli", verimli toprak anlamına kayıyor.
     - entirely: "baştan sona", zaman ya da sıra anlamına kayıyor.
  3. **Yazım ve doğallık.**
     - integral: "asli" → TDK "aslî". 3. örnek çevirisi serbestti.
     - arbitrary: "keyfe göre" doğal değil.
     - consistent ("hep 'with'") ve susceptible ("Hep 'to'"): notlar, def.long'daki "usually / almost always" ile çelişiyordu.
- Geri kalan quiz'ler tek cevaplı bulundu. Çeldiriciler aynı türden (sıfat ya da zarf) ve boşluğa biçim olarak uyuyor. Örneğin implicit ve integral'de "an" bütün şıklara uyuyor, ipucu vermiyor.
- Örnekler kısa ve akademik ya da haber üslubunda; B2 öğrenci çözebilir. Amerikan yazımı tutarlı (rigor, favorable, defenseless, vacation).
- Her kart tek anlamda kalıyor:
  - contemporary: "aynı döneme ait" anlamı yok;
  - readily: "willingly" anlamı yok;
  - consistent: yalnızca "consistent with";
  - apparent: yalnızca "açık, belli" anlamı ("seeming" anlamı yok).

## Yazarın "emin olmadığım" maddeleri

1. **Tek yönlü confusables.**
   - Destede kartı olan eşler (yalnızca s35 düzenlenebildiği için dokunulmadı, ileride ters bağ eklenebilir):
     - temporary (s23/part_05);
     - efficient (s23/part_04);
     - ambitious (s3/part_05);
     - apparently (s24/part_05);
     - virtual (s27/part_04).
   - Destede kartı olmayan eşler: inherit, averse, comprehensible, distinctive, therefore, whereby, respectfully, considerately, noticeably. Hepsi gerçek yazılış ya da anlam karışıklığı, kaldı. respectfully s35'te çeldirici olarak da geçiyor.
   - s35 içindeki çiftler iki yönlü: explicit↔implicit, feasible↔plausible, merely↔solely.
2. **Hata maddeleri.**
   - scarcely "I couldn't scarcely hear him": gerçek bir hata, kaldı. Türkçe olumsuz fiil kurulduğu için "couldn't hardly/scarcely" öğrencilerde sık görülür.
   - "susceptible against" ve "primarily = firstly" eklenmedi. İkisi de kanıtlanamıyor. primarily notundaki uyarı cümlesi zararsız, kaldı.
3. **Bağlamla elenen çeldiriciler.** Hepsi boşluğa konarak denendi:
   - tentative "fixed" ("but it may still change"): yanlış, kaldı.
   - considerably "barely" ("takes half the time"): yanlış, kaldı.
   - entirely "partly" ("nothing in common"): yanlış, kaldı.
   - solely "partly" ("not partly the driver's fault; the road was also…"): anlamsız, kaldı.
   - approximately "precisely" ("but the exact number changes"): yanlış, kaldı.
   - roughly "precisely" ("it's a little less, I think"): yanlış, kaldı.
   - feasible "eligible": bir proje "eligible" olamaz, kaldı.
   - subsequent "liable" ("liable tests"): olmuyor, kaldı.
   - vast "slim": cümle sıkılaştırıldı ("only three out of two hundred failed"). Artık "slim majority" açıkça yanlış.
   - crucial "harmful" ve fundamental "trivial": dilbilgisi olarak uyuyor ama cümleler dünya bilgisiyle açıkça yanlış. Kaldı.
4. **Türkçe seçimler.**
   - arguably: "belki de, denebilir ki" kaldı. Not doğru, "tartışmasız" uyarısı yerinde. alt'taki "muhtemelen" değişti.
   - arbitrary: "gelişigüzel, keyfî" kaldı (TDK "keyfî"). alt'taki "keyfe göre" değişti.
   - tentative: "kesin olmayan" kaldı. alt'taki "geçici" çıkarıldı (aşağıda).
   - integral: 3. örnek yeniden çevrildi.
5. **IPA ve anlam.**
   - IPA doğru: primarily US /praɪˈmɛrəli/, UK /ˈpraɪmərəli/; simultaneously US /ˌsaɪm-/, UK /ˌsɪm-/; integral /ˈɪntɪɡrəl/ (ikinci hece vurgulu okunuş da var ama birincisi yaygın).
   - adverse: US /ædˈvɜːrs/, UK /ˈædvɜːs/. Sözlüklerdeki farkla uyumlu.
   - conventional: "conventional medicine" notu doğru ve yararlı.

## Değişiklik tablosu

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| abundant | l1.tr.alt | "bereketli" → "bolca bulunan" | "Bereketli" verimli toprak ya da hasat anlamına kayıyor. Kartın anlamı "çok miktarda bulunan". |
| arbitrary | l1.tr.alt | "keyfe göre" → "kuralsız" | "Keyfe göre" doğal Türkçe değil. "Kuralsız" tanımdaki "not by a rule or system" kısmını karşılıyor. |
| consistent | l1.tr.note | "Bu anlamda hep 'with'…" → "Bu anlamda çoğunlukla 'with'…" | def.long "usually followed by 'with'" diyor. "consistent across studies" gibi kullanımlar da var. |

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| explicit | quiz.cloze | "The rules are ______: no phones are allowed in the exam room under any circumstances." → "The exam rules are ______: the first line says, in capital letters, \"NO PHONES IN THE ROOM.\"" | Eski cümle kuralın içeriğini veriyordu, açıkça yazıldığını göstermiyordu. "implicit" savunulabilirdi. Yeni bağlam yalnızca "explicit"e izin veriyor. |

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| sufficient | quiz.cloze | "The judge said there was not ______ evidence to prove that he was guilty." → "The company does not have ______ funds to open a new office this year." | Quiz, 3. örneğin neredeyse aynısıydı. "efficient funds" tuzağı yine çalışıyor. |
| susceptible | l1.tr.note | "Hep 'to' ile kullanılır" → "Neredeyse hep 'to' ile kullanılır" | def.long ile ("almost always") tutarlı olsun. |
| tentative | l1.tr.alt | "geçici" → "kesinleşmemiş" | Not "temporary (kısa süreli) ile karıştırma" diyor. "Geçici" tam o karışıklığı besliyordu. |
| tentative | examples[1].tr | "İki ülke geçici bir anlaşmaya vardı." → "İki ülke bir ön anlaşmaya vardı." | "Tentative agreement" haber dilinde "ön anlaşma"dır. "Geçici anlaşma" temporary agreement okunur. |
| vast | quiz.cloze | "…passed the exam; only three failed." → "…passed the exam; only three out of two hundred failed." | Küçük bir sınıfta "slim majority" de uyabiliyordu. Sayı verilince yalnızca "vast" kalıyor. |
| integral | l1.tr.alt | "asli" → "aslî" | TDK yazımı. |
| integral | examples[2].tr | "Projenin başarısında yerel halkın payı vazgeçilmezdi." → "Yerel halk, projenin başarısında vazgeçilmez bir rol oynadı." | Eski çeviri serbestti ("pay" İngilizcede yok). Özne korunarak daha doğal kuruldu. |

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| arguably | l1.tr.alt | "muhtemelen" → "tartışmaya açık olsa da" | "Muhtemelen" probably demek. Kartın notu "tartışmaya açık ama savunulabilir" anlamını vurguluyor. |

#### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| entirely | l1.tr.alt | "baştan sona" → "tümüyle" | "Baştan sona" zaman ya da sıra anlamına kayıyor ("baştan sona okudum"). "Tümüyle" kartın anlamı. |

## Seviye (kartlar silinmedi, seviye değiştirilmedi)

- **vast (C1):** EVP'de B2 görünüyor. "the vast majority" B2 öğrencisi için de yaygın. İstenirse B2'ye çekilebilir.
- **approximately (B2):** daha çok B1. Tekrar olarak zararsız.
- **entirely, precisely, widely (B2):** B1/B2 sınırında. Kalabilir.
- **consistent (C1):** genel anlamı ("hep aynı") B2. "consistent with" (uyumlu) anlamı için C1 makul.
- Geri kalan C1 kartlar (prevalent, inherent, thereby, presumably, notably, readily, scarcely, respectively…) akademik okuma için C1'e uygun.

## Anadili Türkçe birinin bakması gerekenler

- **presumably** alt "anlaşılan": "apparently" karşılığına da yakın. Kalsın mı?
- **arguably** alt "tartışmaya açık olsa da": bir kalıp. Kilit ekranında değil, yalnızca alt'ta görünüyor.
- **inherent** alt "içkin": felsefe terimi, YDS çevirilerinde geçiyor. Fazla teknik mi?
- **virtually** alt "âdeta": "neredeyse" yerine "sanki" tonu taşıyabilir.
- **diverse** 2. örnek: "farklı farklı geçmişlerden" konuşma diline yakın. "farklı geçmişlerden" yeterli olabilir.
- Tek yönlü confusables: temporary (s23), efficient (s23), ambitious (s3), apparently (s24) ve virtual (s27) kartlarına ters bağ eklemek ayrı bir iş.

## Çeldirici, IPA ve son doğrulama (2026-10-26)

- Çeldirici istatistiği (önce): `s35: 60 quizzes, 78 distinct distractors; top: ambiguous×4, explicit×4, tentative×4, reluctant×4, adequate×4, implicit×4`. Sınır max(4, %5) = 4, aşılmıyor.
- 60 quiz'in her şıkkı boşluğa konarak yeniden okundu. Değişen kart: **1** (`distractors_diversified`), cloze değişmedi:
  - **plausible:** "feasible" → "obsolete". "His story wasn't feasible" bazı okurlarca savunulabilir ("olası/yapılabilir" yakınlığı); "obsolete" açıkça yanlış.
- Çeldirici istatistiği (sonra): `s35: 60 quizzes, 78 distinct distractors; top: ambiguous×4, explicit×4, tentative×4, reluctant×4, adequate×4, implicit×4` (en sık şık 4 kez).
- IPA (`ipa_dress_stats.py`): `s35 {'uk_e': 0, 'uk_ɛ': 11, 'us_e': 0, 'us_ɛ': 16}`. ɝ/ɚ yok, boş `confusables` yok.
- Yineleme: (lemma, pos) çiftleri s0…s34 ve s36 ile karşılaştırıldı; çakışma yok.
- Satır sonları LF.
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

İki denetçi (Türkçe ve İngilizce gözü) s33–s36'dan alınan 48 kartlık örneklemi okudu; 21 bulgu (17 kart) kartla karşılaştırıldı: 20'si gerçek çıktı ve düzeltildi, 1'i (scarcity, 'işçi kıtlığı') gerekçesiyle reddedildi. Bulgulardaki her sistematik sorun s33–s36'nın 240 kartında tarandı: yanlış sözcük ailesi bilgisi (virtually), notla çelişen örnek ya da fazla keskin ayrım (başka yok), anlamı düşen `gloss_short` (başka yok), yerleşik olmayan Türkçe terim (başka yok), çeviri kokan Türkçe örnek (6 kart), bağlacın anlamı ve dilbilgisi (başka yok), tanım doğruluğu (başka yok), eş anlamlı inceliği ve kartın tek anlamı (precisely, perceive, stimulate), doğal olmayan eşdizim (başka yok), örneklerle uyuşmayan `grammar.pattern` (bulguyla birlikte 21 kart), kilit ekranı karşılığının quiz bağlamını karşılamaması (impose, exert) ve seviye (Oxford 3000'de B2 olan 10 kart daha B2'ye indi). 'Can' adı, 'siz' hitabı, şapkasız hâl/dâhil, IPA ve boş `confusables` yeniden tarandı; sorun yok.

- Bu akışta değişen kart: **21**, alan: **30**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.roughly.adv.1`: Türkçe ve İngilizce, not (orta; iki denetçi aynı sorun): gerçek. 'rough' sözcüğüyle ilgisi yok deniyordu; oysa 'rough' da 'yaklaşık' demektir (a rough estimate) ve 'roughly' buradan gelir. Not önerilen biçimde yazıldı. Aynı yanlış taramada virtually notunda da çıktı ('virtual' da 'fiilen, neredeyse' demektir).
- `en.roughly.adv.1`: Türkçe, 2. ve 3. örnek (düşük): gerçek. Süre ve oranla 'kabaca' çeviri kokuyordu; 'yaklaşık' ve 'aşağı yukarı' oldu. Taramada 6 kartta daha çeviri kokan Türkçe düzeltildi (exert, proportion, prevalence, fraction, tentative, single out).
- `en.precisely.adv.1`: İngilizce, 3. örnek (düşük): gerçek. 'measure precisely, to 0.1 degrees' hassasiyet anlamıydı; 'That is precisely what the study set out to test.' oldu. Aynı anlamın izleri de temizlendi: eşdizimde 'precisely because' (vurgu kullanımı), eş anlamlıda 'accurately', `alt`'ta 'hassas biçimde', notta 'precisely because'.
- `en.presumably.adv.1`: İngilizce, `grammar.pattern` (düşük): gerçek. 'Presumably, + clause; also mid-clause' oldu (önerilen biçim 50 grafem sınırını aşıyordu). Taramada 20 kartta daha kalıp örneklerle uyumlu hâle getirildi.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| adequate.adj.1 | grammar.pattern | "adequate for sth; adequate to do sth" → "adequate + noun; adequate (for sth / to do sth)" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| substantial.adj.1 | grammar.pattern | "a substantial amount/number of sth" → "substantial + noun (a substantial amount of sth)" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| substantial.adj.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| inherent.adj.1 | grammar.pattern | "inherent in sth" → "inherent + noun; inherent in sth" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| adverse.adj.1 | grammar.pattern | "adverse effect on sth" → "adverse + noun; an adverse effect on sth" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| comprehensive.adj.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| crucial.adj.1 | grammar.pattern | "crucial to/for sth; it is crucial that" → "crucial + noun; crucial to/for sth" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| distinct.adj.1 | grammar.pattern | "distinct from sth" → "distinct + noun; distinct (from sth)" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| feasible.adj.1 | grammar.pattern | "feasible to do sth" → "feasible (to do sth)" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| fundamental.adj.1 | grammar.pattern | "fundamental to sth" → "fundamental + noun; fundamental to sth" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| fundamental.adj.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| inevitable.adj.1 | grammar.pattern | "it is inevitable that + clause" → "be inevitable; it is inevitable that + clause" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| profound.adj.1 | grammar.pattern | "a profound effect/impact on sth" → "profound + noun; a profound effect/impact on sth" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| sufficient.adj.1 | grammar.pattern | "sufficient for sth; sufficient to do sth" → "sufficient + noun; sufficient for sth/to do sth" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| tentative.adj.1 | examples[0].tr | "Cuma için kesin olmayan bir plan yaptık." → "Cuma için henüz kesinleşmemiş bir plan yaptık." | 'kesin olmayan bir plan' çeviri kokuyordu (tarama) |
| vast.adj.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| vulnerable.adj.1 | grammar.pattern | "vulnerable to sth" → "vulnerable (to sth)" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| merely.adv.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| primarily.adv.1 | grammar.pattern | "primarily for/because of sth" → "primarily + verb/adj/prep phrase" | Örneklerdeki kullanım kalıpta yoktu (tarama) |
| primarily.adv.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| virtually.adv.1 | l1.tr.note | "Bu anlamda 'virtual' (sanal) sözcüğüyle ilgisi yoktur; 'almost' demektir. 'Virtually impossible' (neredeyse imkânsız) kalıbı çok sık geçer." → "'Virtual'ın 'sanal' anlamıyla ilgisi yoktur; 'virtual' 'fiilen' anlamında da kullanılır (a virtual monopoly) ve 'virtually' buradan gelir. 'Virtually impossible' (neredeyse imkânsız) çok sık geçer." | 'virtual' ile ilgisi yok deniyordu; 'virtual' da 'neredeyse, fiilen' demektir (tarama) |
| presumably.adv.1 | grammar.pattern | "Presumably, + clause" → "Presumably, + clause; also mid-clause" | 2. ve 3. örnekte cümle içinde (bulgu) |
| roughly.adv.1 | l1.tr.note | "Bu anlamda 'rough' (kaba, sert) sözcüğüyle ilgisi yoktur; 'yaklaşık' demektir. 'Approximately' daha resmî, 'roughly' daha günlük bir karşılıktır." → "Buradaki anlam 'rough'ın 'kaba, yaklaşık' anlamından gelir (a rough estimate = kaba tahmin); 'sert' anlamıyla ilgisi yoktur. 'Approximately' daha resmî, 'roughly' daha günlük bir karşılıktır." | Not 'rough' ile ilgisi olmadığını söylüyordu; 'rough' da 'yaklaşık' demektir (bulgu) |
| roughly.adv.1 | examples[1].tr | "Yolculuk kabaca üç saat sürüyor." → "Yolculuk yaklaşık üç saat sürüyor." | Süreyle 'kabaca' çeviri kokuyordu (bulgu) |
| roughly.adv.1 | examples[2].tr | "Dünya yüzeyinin kabaca yüzde 70'i suyla kaplıdır." → "Dünya yüzeyinin aşağı yukarı yüzde 70'i suyla kaplıdır." | Oranla 'kabaca' çeviri kokuyordu (bulgu) |
| precisely.adv.1 | examples[2] | "The machine can measure the temperature precisely, to 0.1 degrees. / Makine sıcaklığı 0,1 dereceye kadar tam olarak ölçebiliyor." → "That is precisely what the study set out to test. / Çalışmanın sınamaya çalıştığı şey tam olarak buydu." | 'measure precisely' doğruluk/hassasiyet anlamı (bulgu) |
| precisely.adv.1 | collocations | "[precisely because, at precisely, precisely what]" → "[at precisely, precisely what, precisely how]" | 'precisely because' vurgu kullanımı, ayrı anlam (bulgu) |
| precisely.adv.1 | synonyms | "[exactly, accurately]" → "[exactly]" | 'accurately' hassasiyet anlamı (tarama) |
| precisely.adv.1 | l1.tr.alt | "[tam, hassas biçimde]" → "[tam, tam tamına]" | 'hassas biçimde' hassasiyet anlamı (tarama) |
| precisely.adv.1 | l1.tr.note | "Zıt anlamlısı 'roughly' ya da 'approximately'. 'Precisely because' (tam da … yüzünden) kalıbı vurgu için kullanılır." → "Zıt anlamlısı 'roughly' ya da 'approximately'. Saatlerle ve 'what, how, why' ile çok kullanılır: 'at precisely 9 a.m.', 'precisely what happened'." | 'precisely because' vurgu kullanımı ayrı anlam; not kartın anlamına çekildi (tarama) |

- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
