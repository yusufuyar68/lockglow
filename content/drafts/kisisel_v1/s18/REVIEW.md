# s18 QA incelemesi (okul, eğitim ve kurslar)

Kapsam: `content/drafts/kisisel_v1/s18/part_01.json` ... `part_05.json` (45 kart). Konu: okul ve ders (10), sınav, ödev ve okulda ilerleme (10), kurs, üniversite, sertifika, mezuniyet ve kayıt (10), öğrenme alışkanlıkları (10), dil öğrenme kalıpları (5). Seviye A2–B1. Kullanıcı kendisi İngilizce öğrendiği için "dil öğrenme" kalıplarına ağırlık verildi (pick up, brush up on, get by, make progress, get the hang of, how do you say, vocabulary, fluent, accent, native speaker…).

Süreç (`docs/icerik_uretimi/README.md`). Bütün ajanlar Opus (orta çaba):

1. **Yazım:** Part başına bir yazar ajanı (5 ajan), `1_yazar_kurallari.md`. Koordinatör her kelime için tür, seviye, anlam ipucu, isim listesi ve (varsa) Türkçeden gelen hata adayını verdi; yazarlar adayları ancak kendileri de gerçek bulursa kullandı.
2. **Denetim:** Part başına bir denetçi ajanı (5 ajan), `2_denetci_kurallari.md` ve `SYSTEM_C`. Yazarların "emin olmadığım" maddeleri, var olan kartlardaki ilgili hatalar (s2 exam/homework/grade, s4 sign up, s5 study) ve koordinatörün gördüğü zayıf noktalar her denetçiye ayrıca verildi. Dört denetçi kullanım sınırında durdu; sınır sıfırlanınca kaldıkları yerden devam ettirildi (dosyalar yarım kalmamıştı).
3. **Bağımsız doğrulama:** Kartları değiştirmeyen üç ayrı doğrulayıcı ajan bütün akışı okudu: (a) quiz'de tek doğru cevap, (b) Türkçe katman (geri çeviri, gloss, not, hata, TDK yazımı), (c) İngilizce içerik, IPA ve üstveri. Koordinatör bulguları tartıp uyguladı; uygulanan düzeltmeleri bir son kontrol ajanı ayrıca sınadı.
4. **Çeldirici kontrolü:** `3_celdirici_kurallari.md` ölçümü (aşağıda ayrı bölüm).

## Özet

- İncelenen kart: **45** (A2: 20, B1: 25)
- Tür: 24 kelime (`word`), 8 phrasal verb, 6 eşdizim (`collocation`), 6 kalıp (`phrase`), 1 deyim (`idiom`)
- `primary_topic`: hepsi `school_learning`
- Değişen kart: **41** (hepsine `critic_edited` eklendi). Hiç değişmeyen: report card, drop out, beginner, get by.
- Toplam düzenleme (yazım → son, meta hariç alan sayısı): **127**. Denetim aşamasında 88, doğrulama ve son kontrol aşamasında 49 alan (28 kart) değişti (bazı alanlar iki aşamada da değiştiği için toplam daha az).
- Reddedilen kart (`critic_reject`): **0**
- Yaygın hata (`mistakes`): 14 kartta 14 madde; hepsi Türkçeden aktarım, üç denetim katmanı da gerçek buldu. Etimoloji 15 kartta (kalıp ifadelerde `null`). Sahte dost 1 kartta (`college` ≠ kolej).
- Doğrulayıcı (tüm klasör, `--strict`): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`

## Kelime seçimi

- Görevde örnek verilen kelimelerin çoğu başka akışlarda aynı anlamla zaten var; tekrar yazılmadı: `homework`, `fail`, `exam`, `lesson`, `subject`, `grade`, `assignment`, `pronounce`, `spell` (s2), `hand in`, `sign up`, `look up`, `write down` (s4), `study`, `learn`, `teach` (s5), `pass`, `practice`, `improve`, `explain`, `repeat` (s6), `make a mistake`, `pay attention` (s8), `take notes`, `go over` (s10), `attend`, `feedback` (s3).
- Görevdeki örneklerden yazılanlar: `catch up on`, `degree`, `pick up` (dil), `brush up on`, `make progress`. "pass an exam", "sign up for a course", "hand in", "take notes" yerine aynı alanda yeni lemmalar seçildi: `take an exam` (sınava girmek), `enroll`, `do well`, `catch up on`, `fall behind`, `keep up with`.
- Aynı lemmanın yeni anlamı: `degree` **sense 2** (üniversite derecesi; s16'da sense 1 sıcaklık derecesi), `pick up` **sense 3** (dili ders almadan kapmak; s4'te sense 1 yerden almak, sense 2 birini almak). `catch up on` ayrı lemma (s4'teki `catch up` = buluşup sohbet etmek).
- Kimlik ve tekrar taraması (koordinatörün `cross_check.py`'si, son düzeltmelerden sonra): s0–s16 ile kimlik, `def.short`, örnek cümle ya da quiz cümlesi çakışması yok. Tek bulgular beklenen iki lemma+pos eşleşmesi (degree, pick up; anlamları farklı). Yazımdan sonra raise your hand'in bir örneği s9'daki bir cümleyle birebir aynıydı; denetimde değişti. 45 kimliğin hiçbiri `id_registry.json`'da yok. Aynı anda yazılan s17 (teknoloji) için kelime listesi ortak not klasörüne bırakıldı (`translate`, `course`, `quiz` s18'de).

## Genel bulgular

- Kartların çoğu iyi durumdaydı: ilk örnekler kısa ve kilit ekranına güvenli, tanımlar döngüsüz, seviyeler makul. Seviye değişmedi.
- **En sık 3 sorun:**
  1. **Quiz çeldiricileri ilgisizdi ya da ikinci bir okumaya izin veriyordu** (denetimde 17 kartta, doğrulamada 6 kartta quiz değişti). "The teacher opened the ______ door" (elevator da olurdu), "If you know the answer, ______ and wait" (turn around), "got lost in his exams" (mecaz), "get rid of it / put up with it" (brush up on). İlgisiz şıklar: "sneeze, yawn, smile", "bed, lunch", "headache, haircut, souvenir", "afraid at, tired at" (İngilizcede yok). Mümkün olan yerde konuya yakın ama yanlış şıklar ya da kalıbın gerçek hata biçimleri kondu: "join an exam, make an exam, win an exam", "How do you call", "lesson" (kurs yerine), "license" (lisans tuzağı), "enrolled from university", "good for / good to". Bağımsız quiz doğrulayıcısı **ikinci doğru cevap bulmadı** (YÜKSEK 0).
  2. **Türkçede birebir çeviri, anlam kayması ve yazım.** "Yarın kelime kısa sınavımız var", "ekonomi alanında üniversite diploması", "Bu derse yetişemiyorum" (derse zamanında varamamak demek), "aklında tutmak" (≠ ezberlemek), "söz istemek", "hatasını göstermek", "okul arkadaşı" (≠ classmate), "Mr. Clark" (öteki kartta "Patel Hanım"). TDK: "dilbilgisi" → "dil bilgisi" (4 yer), "anadili" → "ana dili" (3 örnek), "'derece'si" kesmesi kaldırıldı. Gloss'lar açıklama cümlesinden gerçek karşılığa çekildi: native speaker, catch up on, pick up ("(bir dili) kapmak"), major ("bölüm").
  3. **İsimler ve örnek cümleler.** "Can" adı İngilizce cümle başında modal fiil gibi okunuyordu ("Can graduated…"), "Ben" adı Türkçe çeviride "ben" (I) gibi okunuyordu; ikisi de değişti. Örnek çevirisinde İngilizce sözcük + kesmeli ek gerektiren "Phrasal verb'ler" cümleleri İngilizce tarafta değiştirildi.
- **Yaygın hatalar:** 14 madde kaldı: class friend, raise my finger, special lessons, enter the exam (s2 exam kartında da var; daha gerçek ikinci hata bulunamadı), I won the university, concentrate to, go to English course, I am graduated, a big progress, knowledges, vocabularies, How is it called, I'm confusing, speak English fluent. Denetimde eklenen tek hata `concentrate to` (önce yalnızca nottaydı). "good in" (ABD'de bazen doğru), "a knowledge" ("a good knowledge of" doğal) ve major için "department" (yanlış değil, yalnızca doğal değil) bilerek yazılmadı. Yaygınlıklar derlemle doğrulanmadı; en az emin olunanlar aşağıdaki anadil listesinde.
- **IPA:** DRESS `/ɛ/` (`ipa_dress_stats`: s18'de `/e/` 0), US'de r'li ünlüler uzunluk işaretli (`/kɔːrs/`, depoda 41 kartla aynı). Phrasal verb'lerde depodaki iki gelenek korundu: parçacıkta vurgu (pick up, catch up on, keep up with, fall behind, drop out, brush up on, get by), "X into"da fiilde vurgu (`get into` → /ˈɡɛt ɪntu/, s10–s16'daki look/run/turn into gibi). `get the hang of` UK'de zayıf "of" /əv/.
- **Üstveri:** `how do you say` gereksiz `informal` idi, `neutral` oldu; `skip class` örneklerinin register'ı kartla tutarlı biçimde `informal`. Eş anlamlılardan yanlış olanlar çıktı: get the hang of ≠ "get used to", habit ≠ "routine", correct ≠ "mark". `knowledge` etimolojisinde metin ile `origin` tutarsızdı, düzeldi.

## Yazar şüphelerine kararlar (kısa)

- **part_01:** "raise my finger", "enter the exam", "class friend", "special lessons" kaldı (gerçek aktarımlar; son ikisi derlemle doğrulanmadı). high school `false_friend` null kaldı ("yüksekokul" tuzağı notta). IPA'lar değişmedi.
- **part_02:** "I won the university" kaldı. "concentrate to" hataya taşındı. Phrasal verb IPA'ları tutarlı; yalnızca get into değişti. catch up on gloss "eksiğini kapatmak" oldu. keep up with quiz'i okul dışı bağlamda kaldı (okul bağlamında "deal with / get along with" da uyuyordu).
- **part_03:** course ve graduate hataları kaldı. major "department" notta kaldı. college sahte dostu kaldı; nota İngiltere anlamı (16 yaş sonrası okul) eklendi. degree ve major etimolojisi `medium` kaldı. native speaker micro ve gloss düzeldi.
- **part_04:** Beş hata kaldı. knowledge etimolojisi düzeldi. "afraid at / tired at" çıktı. step by step quiz'i ("take it ______") tek cevaplı, kaldı.
- **part_05:** pick up gloss önce kaldı, doğrulamada "(bir dili) kapmak" oldu ("kendiliğinden öğrenmek" açıklamaydı). brush up on IPA ve fluent hatası kaldı. get by `equivalence: full` kaldı.

## Değişiklik tablosu

### Denetim (part başına denetçi)

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| classroom | examples[0].tr | "Dersliğimizin büyük pencereleri var." → "Sınıfımızın büyük pencereleri var." | Daha doğal; gloss görünüyor |
| classroom | quiz | "The teacher opened the ______ door and the students walked in." (kitchen, garage, elevator) → "The students sat at their desks in the ______ and waited for the lesson to start." (corridor, playground, car park) | "elevator door" da doğruydu |
| high school | examples[2].tr | "Liseden sonra Elif bir üniversitede…" → "Elif liseden sonra üniversitede…" | "bir üniversitede" birebir |
| raise your hand | examples[0] | "Please raise your hand if you have a question." → "Who wants to read first? Raise your hand." / "Kim önce okumak istiyor? Parmak kaldırsın." | s9/part_06'daki örnekle birebir aynıydı |
| raise your hand | l1.tr.alt | el kaldırmak, söz istemek → el kaldırmak | "söz istemek" anlamı kaydırıyor |
| raise your hand | quiz | "If you know the answer, ______ and wait for the teacher." (close the door, turn around, go to sleep) → "Kaan knew the answer, so he ______ and waited for the teacher to call his name." = raised his hand (left the room, fell asleep, shook his head) | "turn around" okunabiliyordu; şıklar aynı biçim |
| skip class | examples[0–2].register | neutral → informal | Kartın register'ıyla tutarlı |
| quiz | examples[0].tr | "Yarın kelime kısa sınavımız var." → "Yarın kısa bir kelime sınavımız var." | Doğal sıra |
| quiz | quiz.distractors | picnic, movie, nap → break, picnic, nap | "movie" ilgisizdi |
| correct | l1.tr.alt | hatasını göstermek → (boş) | Açıklamaydı |
| take an exam | quiz | "Leo is nervous because he has to ______…" (write a letter, go shopping, watch a film) → "Leo didn't study enough, and now he has to ______ in math tomorrow morning." (join an exam, make an exam, give an exam) | Şıklar çok uzaktı; yeniler gerçek hata biçimleri |
| do well | quiz.distractors | did badly, stayed home, got lost → did badly, made well, got well | "got lost in his exams" mecazen olabiliyordu |
| essay | l1.tr.note | "…en yaygın sözcük 'essay' olur." → "Okulda yazılan kompozisyona İngilizcede genellikle 'essay' denir. …" | Devrik Türkçe |
| essay | quiz.distractors | receipt → dictionary | Konuya yakın |
| cheat | quiz.distractors | sneeze, yawn, smile → pass, succeed, try hard | İlgisizdi; yeniler "zero points" ile çelişiyor |
| cheat | l1.tr.note | + "Dikkat: 'cheat on someone' ise sevgilisini aldatmak demektir." | Öteki anlam bilinmeli |
| catch up on | gloss / alt | geride kalanı yetiştirmek; telafi etmek, açığı kapatmak → telafi etmek; yetiştirmek, açığı kapatmak | Açıklama gibiydi |
| catch up on | examples[0].tr | geride kalan ödevlerimi → biriken ödevlerimi | Doğal Türkçe |
| catch up on | l1.tr.note | "'catch up' tek başına … demektir" → "…çoğunlukla birine yetişmek ya da…" | "Yalnızca" demek yanlıştı |
| fall behind | quiz | "If you miss too many lessons, you will ______." (show up, dress up, sleep in) → "Ali was ill for three weeks, so he ______ in math." = fell behind (slept in, dressed up, checked in) | Tanıma ve 1. örneğe yakındı; şıklar aynı biçim |
| keep up with | examples[0].tr | "Bu derse yetişemiyorum." → "Bu dersin hızına yetişemiyorum." | "Derse yetişmek" zamanında varmak demek |
| keep up with | examples[1].tr | diğer öğrencilere yetişmek için → diğer öğrencilerden geri kalmamak için | Anlam aynı hızda gitmek |
| get into | ipa.us / ipa.uk | /ɡɛt ˈɪntuː/ → /ˈɡɛt ɪntu/, /ˈɡɛt ɪntə/ | Depodaki "X into" kartlarıyla tutarlı |
| get into | l1.tr.note | "'be accepted to' de denir" → "Daha resmî bir karşılığı 'be accepted' kalıbıdır." | Ayrı ek; "accepted to" yalnızca ABD |
| memorize | l1.tr.alt | aklında tutmak → ezbere öğrenmek | "Aklında tutmak" hatırlamak demek |
| concentrate | l1.tr.mistakes | (boş) → "I can't concentrate to my lessons." → "…on my lessons." | Gerçek hata yalnızca nottaydı |
| concentrate | l1.tr.note | "…'to' kullanmayın." → "…Aynı anlamda 'focus on' kalıbı da çok kullanılır." | Not hatayı tekrar etmesin |
| course | quiz.distractors | recipe, kitchen, menu → lesson, teacher, recipe | "lesson" ders/kurs ayrımını sınıyor |
| course | examples[1] | Kenji → Mia | Kenji iki kartta |
| certificate | l1.tr.note | "…diploma için ise genelde 'degree' denir." → "…Üniversite bitirince alınan derece için ise genelde 'degree' denir." | Diploma kâğıdı 'diploma', degree derecedir |
| graduate | examples[0] | "Can graduated…" → "Selin graduated…" | "Can" modal fiil gibi okunuyor |
| graduate | quiz.distractors | retired, failed, escaped → retired, failed, enrolled | "escaped" şakacıydı |
| degree | examples[0].tr | "Emma'nın ekonomi alanında üniversite diploması var." → "Emma'nın ekonomi diploması var." | Ağırdı |
| degree | quiz.cloze | "Elif studied for four years and finished with a ______ in biology." → "Elif finished university last year with a ______ in biology." | graduate quiz'iyle aynı başlıyordu |
| major | gloss / alt | ana dal; bölüm → bölüm; ana dal | En yaygın karşılık; örneklerde "bölüm" |
| college | examples[2] | "Can met…" → "Kerem met…" | "Can" modal fiil gibi |
| college | quiz | Kenji → Diego; kindergarten, bed, lunch → kindergarten, primary school, middle school | İlgisizdi; "school" ABD'de doğru olurdu |
| scholarship | quiz.distractors | headache, haircut, souvenir → diploma, bill, receipt | İlgisizdi; "loan, prize" ikinci cevap olabilirdi |
| native speaker | def.micro | person born into a language → someone raised speaking it | Zorlamaydı (doğrulamada yine değişti) |
| native speaker | gloss / alt | anadili o dil olan kişi; (boş) → ana dili İngilizce olan; ana dil konuşuru | Açıklama gibiydi (doğrulamada yine değişti) |
| native speaker | l1.tr.note | → "…Başka diller için de kullanılır: 'a native speaker of Spanish'… Karşıtı 'non-native speaker' olur." | Gloss İngilizceye özgüydü |
| native speaker | examples[0–2].tr | anadili → ana dili | TDK |
| get the hang of | ipa.uk | /ɡɛt ðə ˈhæŋ ɒv/ → /ɡɛt ðə ˈhæŋ əv/ | Zayıf "of"; depoyla tutarlı |
| get the hang of | examples[2] | "Phrasal verbs are tricky…" → "Writing essays in English is hard at first, but you'll get the hang of it with practice." | Türkçede "Phrasal verb'ler" yazımı gerekmesin |
| knowledge | etymology.text | Middle English "knowleche" → "made from the verb 'know' (Old English 'cnāwan')…" | `origin` ile tutarsızdı |
| knowledge | examples[0] | "…knowledge of English grammar is very good." → "Leyla's knowledge of English is very good." / "Leyla'nın İngilizce bilgisi çok iyi." | Türkçe ağırdı; kilit ekranı için kısa |
| translate | quiz.cloze | "I don't understand this email. Can you ______ it into Turkish for me?" → "This song is in Spanish. Can you ______ the words into English?" | 1. örnekle neredeyse aynıydı |
| how do you say | register (3 örnek + tags) | informal → neutral | Her bağlamda kullanılır |
| how do you say | examples[2].tr | "Bunu İngilizcede nasıl söylersiniz?" → "Bu İngilizcede nasıl denir?" | Gloss görünsün |
| be good at | quiz.distractors | bad at, afraid at, tired at → bad at, good for, good to | İki şık İngilizcede yoktu; "good in" ABD'de doğru olabildiği için şık olamaz |
| confusing | def.long | "…describes the thing, not the person." → "…usually describes a thing or a situation, not how a person feels." | Bir kişi de confusing olabilir |
| confusing | examples[2] | "Sofia finds phrasal verbs confusing…" → "Sofia finds some English words confusing because one word can have many meanings." | "Phrasal verb'ler" yazımı gerekmesin |
| confusing | mistakes[0].why | yeniden yazıldı (doğrulamada yine değişti) | Eski açıklama nedeni anlatmıyordu |
| confusing | quiz.cloze | "Two words sound the same but mean different things, which is ______…" → "When two words sound the same but mean different things, it is ______ for learners." | Dilbilgisi bozuktu |
| pick up | examples[0–2].tr | "kulaktan … kaptı" / "kendiliğinden … öğrendim" / "komşularından kaptı" → "biraz İspanyolca kaptı" / "epey İngilizce öğrendim" / "komşularından öğrendi" | İngilizcede olmayan bilgi; "kaptı" iki kez |
| brush up on | quiz | "I learned German at school but forgot a lot. I want to ______ it before my trip." (run out of, put up with, get rid of) → "I forgot a lot of my school German. Before my new job in Berlin, I must ______ my German." (run out of, look forward to, drop out of) | 1. örneğe yakındı; "it" ile iki şık oturuyordu |

### Doğrulama (koordinatör, üç doğrulayıcının bulgularıyla)

| Kart | Alan | Önce → Sonra | Neden (kaynak) |
|---|---|---|---|
| classmate | l1.tr.alt | okul arkadaşı → (boş) | "okul arkadaşı" = schoolmate (Türkçe) |
| high school | quiz.cloze | "Mert is 16 and in tenth grade at ______." → "Mert is 16, so he goes to ______." | ABD/İngiltere karışık söyleyiş (quiz, İngilizce) |
| raise your hand | examples[2].tr | "Mr. Clark bağırmak yerine konuşmadan önce…" → "Clark Bey, konuşmadan önce bağırmak yerine…" | "Patel Hanım" ile tutarlılık; söz dizimi (Türkçe) |
| private lesson | examples[0] | "Sara takes private lessons in piano." → "Sara takes private lessons after school." / "Sara okuldan sonra özel ders alıyor." | "lessons in piano" doğal değil (İngilizce) |
| quiz | examples[1].tr | "Mr. Clark bize…" → "Clark Bey bize…" | Tutarlılık (Türkçe) |
| correct | examples[0].tr | "İngilizcemi düzeltebilir misin, lütfen?" → "Lütfen İngilizcemi düzeltir misin?" | Doğal sıra (Türkçe) |
| correct | synonyms | fix, mark → fix | "mark" not vermek, yalnızca İngiltere (İngilizce) |
| take an exam | l1.tr.note | "…öğrenci 'takes' (…) the exam; …öğretmen 'gives' the exam…" → "Sınava giren öğrenci için 'take an exam' (İngiltere'de 'sit an exam' kalıbı da kullanılır), sınavı yapan öğretmen için 'give an exam' denir. …" | Karma Türkçe-İngilizce cümle (Türkçe); İngiltere'de de 'take' yaygın (son kontrol) |
| take an exam | quiz.distractors | give an exam → win an exam | "give an exam" Hint İngilizcesinde "sınava girmek"; "sınavı kazanmak" da gerçek bir Türkçe aktarım (İngilizce) |
| catch up on | gloss / alt | telafi etmek; yetiştirmek, açığı kapatmak → eksiğini kapatmak; yetiştirmek, telafi etmek | "ödevleri telafi etmek" doğal değil (Türkçe) |
| catch up on | l1.tr.note | "buluşup hasret gidermek" → "buluşup sohbet etmek" | Fazla güçlüydü (Türkçe) |
| keep up with | examples[1].tr | "çok kitap okuyor" → "çok okuyor" | "kitap" İngilizcede yok (Türkçe) |
| enroll | quiz.distractors | retire, apologize, celebrate → graduate, retire, apologize | Konuya yakın şık (quiz) |
| degree | l1.tr.alt | derece, lisans → diploma, lisans | "derece" Türkçede akademik anlamda pek kullanılmaz, notla çelişiyordu (Türkçe) |
| degree | l1.tr.note | "sıcaklık 'derece'si" → "sıcaklık derecesi" | Gereksiz kesme (Türkçe) |
| major | l1.tr.note | "'department' da kullanılır" → "'department' demek akla gelir, ama… 'major' denir ya da 'What do you study?' diye sorulur." | "department" doğruymuş gibi okunuyordu (Türkçe) |
| college | l1.tr.note | + "İngiltere'de 16 yaşından sonra gidilen okul da olabilir." | İngiltere anlamı eksikti (İngilizce, Türkçe, son kontrol) |
| native speaker | def.micro | someone raised speaking it → grew up using the language | "it" belirsiz (İngilizce); öneri "a first-language speaker" başlık kelimeyi içerdiği için kullanılmadı |
| native speaker | gloss / alt | ana dili İngilizce olan; ana dil konuşuru → ana dili olarak konuşan kişi; ana dili İngilizce olan | Gloss notla çelişiyordu; alt dilbilim jargonu (Türkçe); gloss isim öbeği olsun (son kontrol) |
| habit | synonyms | routine → (boş) | Eş anlamlı değil (İngilizce) |
| step by step | examples[1].tr | dilbilgisini → dil bilgisini | TDK (Türkçe) |
| make progress | def.micro / short / long | "slowly get better…" → "get better at something…" | İlerleme hızlı da olabilir (İngilizce) |
| get the hang of | examples[0] | "Typing in English was hard, but I'm getting the hang of it." / "İngilizce yazmak zordu ama yavaş yavaş alışıyorum." → "Chess is hard, but I'm slowly getting the hang of it." / "Satranç zor ama yavaş yavaş mantığını kapıyorum." | "Typing" çeviride kayboluyordu; gloss ("kapmak") görünsün (Türkçe) |
| get the hang of | synonyms | get used to → (boş) | "Alışmak" demek, "işi kapmak" değil (İngilizce) |
| knowledge | examples[2] | Ben → Max | "Ben" Türkçede "ben" (I) gibi okunuyor (Türkçe) |
| vocabulary | examples[2].en, quiz.cloze | "…is big" / "…is quite big" → "…is large" / "…is quite large" | Doğal eşdizim "large vocabulary" (İngilizce) |
| vocabulary | mistakes[0].why | → "Öğrenciler 'vocabulary' kelimesini 'kelime' sanıp 'kelimeler' gibi çoğul yapar. Oysa 'vocabulary' bildiğin kelimelerin tamamıdır; tek tek sayarken 'words' denir." | Kaynak zayıf açıklanmıştı (Türkçe); yanılan Türkçe değil öğrenci (son kontrol) |
| translate | def.micro | say it in another language → put into another language | "it" belirsiz (İngilizce); ilk öneri 29 karakterdi; ara biçim "change into…" dönüşmek gibi okunabiliyordu (son kontrol) |
| how do you say | quiz.cloze | "______ “kitap” in English? Is it “book”?" → "I asked the waiter, “______ ‘water’ in Italian?”" | 1. örneğin neredeyse aynısıydı (quiz) |
| be good at | examples[1].tr | dilbilgisinde → dil bilgisinde | TDK (Türkçe) |
| be good at | l1.tr.alt | bir şeyi iyi yapmak, başarılı olmak → bir şeyi iyi yapmak | "başarılı olmak" do well'in gloss'u (Türkçe); önerilen "bir şeyde becerikli olmak" 24 karakter sınırını aşıyordu |
| confusing | mistakes[0].why | "Türkçede … kimin karıştırdığı, kimin karıştığı ayrımı yapılmaz…" → "Türkçede 'karışık' hem kafa karıştıran şey hem kişi için kullanılır ('kafam karışık'). İngilizcede kişinin hissi -ed ile anlatılır: 'I'm confused'. 'I'm confusing' 'kafa karıştıran biriyim' demek." | Türkçe "karıştı/karıştırıyor" ayrımını yapar (Türkçe); ara biçim alt'taki "karışık" karşılığıyla çelişiyordu (son kontrol, ORTA) |
| confusing | examples[1] | Ben → Tim | "Ben" Türkçede "ben" (I) gibi okunuyor; knowledge kartıyla tutarlı (son kontrol) |
| pick up | gloss / alt | kendiliğinden öğrenmek; kapmak, kulaktan öğrenmek → (bir dili) kapmak; ders almadan öğrenmek, kulaktan öğrenmek | Açıklamaydı; doğal karşılık "kapmak" (Türkçe). Biçim kuralı (-mak ile bitmeli) için parantez başa alındı |
| pick up | examples[1].tr | "epey İngilizce öğrendim" → "epey İngilizce kaptım" | Nüans kayboluyordu (Türkçe) |
| brush up on | examples[2].tr | dilbilgisinin → dil bilgisinin | TDK (Türkçe) |
| fluent | mistakes[0].why | "…'I'm fluent in English' de." → "…Ya da 'I'm fluent in English' diyebilirsin." | "de" bağlaç gibi okunuyordu (Türkçe) |
| fluent | quiz.distractors | famous, lazy, strict → famous, lazy, confused | Konuya yakın şık (quiz) |
| accent | l1.tr.note | dilbilgisini → dil bilgisini | TDK (Türkçe) |

Uygulanmayan doğrulayıcı önerileri: brush up on ve cheat quiz cümlelerinin yeniden yazılması (ikisi de tek cevaplı, yalnızca üslup), accent alt'ındaki "şive"nin silinmesi (gündelik dilde kullanılıyor), course hatasında `right` alanının "I take an English course" yapılması (düzeltme artikel hatasını gösteriyor; fiili değiştirmek odağı bulandırır), native speaker micro'sunun "a first-language speaker" yapılması (başlık kelimeyi içeriyor), pick up gloss'unun "(dil, beceri) kapmak" yapılması (doğrulayıcı gloss'u virgülden bölüp her parçanın -mak ile bitmesini istiyor; kart da dil öğrenme odaklı).

**Son kontrol:** Bağımsız bir ajan yukarıdaki doğrulama tablosunun her satırını kartla karşılaştırdı (hepsi işlenmiş), değişen 6 quiz'in 24 seçeneğini tek tek boşluğa koydu (ikinci doğru cevap yok) ve yeni Türkçe/İngilizce metinleri okudu: YÜKSEK 0, ORTA 1 (confusing `why`), DÜŞÜK 8. ORTA bulgu ve 6 DÜŞÜK öneri uygulandı (tabloda "son kontrol" diye işaretli).

## Anadili Türkçe birinin bakması gerekenler

1. **"class friend"** (classmate) ve **"special lessons"** (private lesson): Türkçeden aktarım olarak inandırıcı, ama yaygınlıkları derlemle doğrulanmadı.
2. **"I go to English course"** (course): hata gerçek ama "I go to English class" doğru olduğu için sınırda.
3. **native speaker** gloss "ana dili olarak konuşan kişi", alt "ana dili İngilizce olan": kilit ekranında doğal duruyor mu? "ana dili" ayrı yazım (TDK güncel sözlük) doğru mu, "anadili" mi? (2026-10-22: kilit ekranı için `gloss_short` "ana dili olan" eklendi; aşağıdaki Bakım bölümüne bakın.)
4. **pick up** gloss "(bir dili) kapmak": "kapmak" A2 öğrencisine fazla gayriresmî mi?
5. **catch up on** gloss "eksiğini kapatmak": "ödevlerimi yetiştirmek" ve "uykumu telafi etmek" ile birlikte doğru mu?
6. **major** gloss "bölüm" (alt "ana dal"): öğrenci ağzında doğru, terim olarak "ana dal" daha kesin.
7. **raise your hand** 1. örnek "Kim önce okumak istiyor? Parmak kaldırsın." (öğretmen ağzı) mı, "Parmak kaldırın." mı?
8. **skip class** alt "dersi kırmak": yaygın mı ("okulu kırmak" daha bilinen olabilir)?
9. **keep up with** 1. örnek "Bu dersin hızına yetişemiyorum." kilit ekranında doğal mı?
10. **do well** alt "iyi geçmek": öznesi sınav ("sınavım iyi geçti"); kalabilir mi? Çeldirici "made well" gerçek bir hata biçimi mi?
11. **memorize** alt "ezbere öğrenmek": daha yaygın bir karşılık var mı?
12. **get the hang of** 1. örnek "Satranç zor ama yavaş yavaş mantığını kapıyorum." doğal mı?
13. **be good at** 1. örnek "Leyla dillerde iyidir." mi, "Leyla'nın dile yatkınlığı var." mı?
14. **brush up on** 3. örnek "dil bilgisinin üzerinden geçti" mi, "gramerini tazeledi" mi?
15. **accent** alt "şive": "Fransız şivesi" doğal mı?
16. ~~**certificate** notu "derece için 'degree' denir" anlaşılır mı?~~ **Çözüldü (2026-10-22):** not "Üniversite diploması için ise genelde 'degree' denir." oldu (degree kartının anlamıyla aynı söz).

## Çeldirici kontrolü (2026-10-22)

- Sınır (max(4, %5) = 4) yazarlara baştan verildi; denetçiler ve koordinatör yeni şık seçerken öteki partlara baktı. Çeşitlendirme gerekmedi; `distractors_diversified` bayrağı eklenmedi.
- Önce (yazım sonrası, `distractor_stats.py`): `s18: 45 quizzes, 127 distinct distractors; top: kitchen×2, teacher×2, kindergarten×2, put up with×2, sleep in×2, handed in×2`.
- Sonra: `s18: 45 quizzes, 127 distinct distractors; top: teacher×3, kindergarten×2, handed in×2, lesson×2, passport×2, spelling×2`. Hiçbir şık 4'ten fazla soruda geçmiyor.
- Biçim kuralı: geçmiş zaman (raised his hand, fell behind, did well, graduated, got into, dropped out, picked up), -ing (making) ve phrasal verb cevaplarında şıklar aynı biçimde. Küçük istisna graduate'teki "failed" ("from" ile kurulamıyor ama geçmiş zaman).
- Bağımsız quiz doğrulayıcısı 45 sorunun her şıkkını boşluğa koyarak okudu: ikinci doğru cevap yok (YÜKSEK 0). Doğrulamada değişen 6 quiz'i son kontrol ajanı ayrıca sınadı.
- Doğrulayıcı: `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`

## Bakım (2026-10-22, s19 oturumu)

- **`gloss_short` (6 kart):** entegrasyon dalındaki doğrulayıcı, anlamı 16 grafemi geçen kartlarda kısa anlam istiyor (GLOSS_SHORT_MISSING); s18 bu kural birleşmeden önce yazıldığı için 6 uyarı veriyordu. Eklenenler: catch up on "eksiği kapatmak", degree (2) "diploma", native speaker "ana dili olan", make progress "ilerlemek", be good at "başarılı olmak", pick up (3) "bir dili kapmak". native speaker için önce "yerli konuşmacı" yazıldı; bağımsız Türkçe doğrulayıcı bunu çeviri kokan ve "toplantıdaki konuşmacı" gibi okunan bir söz buldu, "ana dili olan" ile değişti ("ana dil konuşuru": TDK'ye göre "ana dil" ata dil demek; "doğuştan konuşan": kalıplaşmış değil).
- **`confusables`:** confusing kartındaki eski `confusable:confused` bayrağı yeni alana taşındı (confused kartı zaten ["confusing"] diyor).
- **certificate notu:** anadil listesi madde 16.
- Değişen 8 karta `critic_edited` eklendi (zaten olanlarda tekrar edilmedi). Türkçe katmanı bağımsız bir doğrulayıcı ve son kontrol ajanı okudu. Doğrulayıcı: `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`.
