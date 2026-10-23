# s20 QA incelemesi (günlük konuşma kalıpları)

Kapsam: `content/drafts/kisisel_v1/s20/part_01.json` … `part_06.json` (60 kart, 10'ar). Konu: selamlaşma ve vedalaşma (12), teşekkür ve rica (12), özür (7), sohbet açma (9), fikir sorma ve söyleme (11), anlamadığını söyleme (9). Seviye A1–B1.

Süreç (`docs/icerik_uretimi/README.md`; s17–s19 ile aynı). Bütün ajanlar Opus, orta çaba:

1. **Yazım:** 5 yazar ajanı, her biri 12 kart (`1_yazar_kurallari.md`). Koordinatör her kalıp için kimlik, seviye, konu, anlam ipucu, var olan ilgili kartlar ve (varsa) hata adayı verdi. Yazarlar adayları ancak kendileri de gerçek bulursa kullandı. Yazım sırasında kullanım sınırı doldu; ajanlar kaldıkları yerden devam etti.
2. **Denetim:** 5 denetçi ajanı (`2_denetci_kurallari.md`, `SYSTEM_C`); yazarların "emin olmadığım" maddeleri her denetçiye ayrıca verildi.
3. **Bağımsız doğrulama:** kartları değiştirmeyen 3 doğrulayıcı bütün akışı okudu: (a) quiz'de tek doğru cevap, (b) Türkçe katman, (c) İngilizce, IPA ve üstveri. Hiçbirinde YÜKSEK bulgu yok (ORTA: quiz 4, Türkçe 9, İngilizce 5). Bulguları bir ajan uyguladı (`validator_edited`), bir son kontrol ajanı her değişen alanı ayrıca sınadı (1 küçük sorun, düzeltildi).
4. Sonda kartlar sırası korunarak 10'arlık 6 dosyaya bölündü.

## Özet

- Kart: **60** (A1 13 · A2 25 · B1 22). Tür: 54 kalıp (`phrase`, `phr`), 6 kelime (welcome, please, oops, pardon: `interj`; fault: `n`; personally: `adv`).
- `primary_topic`: `social_skills` 41, `opinions_debate` 5, `food_drink` 4, `time_routines` 3, `emotions_feelings` 3, öteki 4. `social_skills` A2–C1 aralığında olduğu için A1 kartlar A1'e açık bir birincil konu aldı (s8'deki gibi); hepsinin `topics` listesinde `social_skills` var.
- `tags.register`: neutral 49, informal 9 (what's up, got it, no offense, I mean, oops …), formal 2 (good evening, may I). Her kartın notunda kullanım bilgisi var: kime / ne zaman söylenir, nasıl cevap verilir.
- `gloss_short`: 18 kart. `confusables`: 37 kart (gerçek karışıklık olmayan 23 kartta alan bilerek yazılmadı: eş anlamlı ya da aynı konudan kelime sayılmaz). `mistakes`: 22 kartta 22 madde. Sahte dost: 0 (pardon kısmi örtüşme; not ve hata maddesi anlatıyor, `equivalence: partial`).
- Değişen kart: denetimde 32, doğrulamada 30 (63 alan). Reddedilen: 0.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`. Çeldirici: 180 şık, hiçbiri birden fazla soruda yok.
- Çakışma: s0–s22 ile kimlik, `def.short`, örnek ya da quiz çakışması yok (`cross_check.py`: 0). 60 kimliğin hiçbiri `id_registry.json`'da yok. s21 ve s22 ile listeler önceden karşılaştırıldı; s22 "it's up to you" ve "make sense"i s20'ye bıraktı.

## Kelime seçimi

Var olan kartlarla aynı anlam yazılmadı. Çıkarılan adaylar: "sorry I'm late" (s3 sorry örneği ve hatası), "would you mind" ve "I don't mind" (s6 mind), "guess what" (s6 guess), "What does … mean?" (s5 mean), "how do you spell" (s2 spell), "is this seat taken" (s8 excuse me örneği), "that's kind of you" (s13 kind notu). Yakın var olan kalıplar (by the way, never mind, no problem, excuse me, see you later, no worries, how's it going, my bad, in my opinion …) yalnızca `confusables` ve notlarda anıldı.

## Denetim (5 denetçi)

### 1. denetçi (1. yazarın 12 kartı)

#### Özet
- İncelenen kart: 12
- Değişen kart: 7 (nice to see you, good night, have a nice day, how have you been, welcome, nice talking to you, I'd better go)
- Değişen alan: 9
- Reddedilen: 0
- Doğrulayıcı: `12 kart · 12 şemadan geçti · 0 hata · 0 uyarı`; `cross_check.py`: `problems: 0`

#### Genel bulgular
- Kartlar genel olarak sağlam. register, not, IPA ve confusables doğru. Yanlış eş bulmadım.
- Quiz: iki kartta tek doğru cevap riski ya da zayıf bir çeldirici vardı. "Nice to meet you again" İngilizcede gerçekten kullanılıyor. "I'm sorry" ise hiçbir şey sınamıyordu.
- Tekrar: kart 11'in cloze'u, s4 `get on` cloze'uyla "train is here" ifadesini paylaşıyordu. Kart 12'nin cloze'unda da tren vardı. Taksiye çevirdim.
- İsimler: Lucas üç kez geçiyordu (sınır 2). Welcome örneğinden çıkardım.
- Yazarın emin olmadığı maddeler:
  1. "seni görmek hoş": kaldı, aşağıda işaretli.
  2. IPA /həv/ ve "been" vurgusu doğru. gloss_short daha olağan söz dizimine çevrildi.
  3. wilcuma: wil + cuma kökeni standart. high güven kalabilir.
  4. "I'm sorry" → "Hello".
  5. good evening kartında formal kaldı. OALD bu ifadeyi "formal" etiketiyle veriyor, örnekler de otel, garson ve TV.
  6. Hatalar: "Good days!", "Welcome to home!" ve "I'd better to go." gerçek hatalar. "I'd better to go" için why daha dürüst hâle getirildi: hata, 'have to go / need to go' benzetmesinden geliyor. "Say my greetings…" kaldı ama işaretli. Confusables'ın üçü de gerçek (biçim benzerliği ya da kullanım farkı). "how are you" destede yok, sorun değil.
  7. Kart 11 cloze'u düzeltildi.

#### Değişiklik tablosu
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| nice to see you | quiz.cloze | "Tom! ______ again!" → "Tom! ______!" | "Nice to meet you again" de doğal, iki doğru cevap çıkıyordu. "It's been a long time" bağlamı tek cevabı zaten belirliyor. |
| good night | examples[2].tr | "Eve sağ salim git." → "Eve sağ salim var." | Daha doğal Türkçe ("get home" = varmak). |
| have a nice day | quiz.distractors | "I'm sorry" → "Hello" | "I'm sorry" bir şey sınamıyordu. "Hello", "iyi günler"in Türkçede selam olarak da kullanılmasından doğan karışıklığı sınıyor. "Thanks, you too!" cevabı onu dışarıda bırakıyor. |
| have a nice day | examples[2].tr | "İşte iyi bir gün geçir!" → "İş yerinde günün iyi geçsin!" | "İşte" ünlem gibi okunabiliyordu. |
| how have you been | l1.tr.gloss_short, alt | "nasılsın bu ara?" → "bu ara nasılsın?" | Olağan söz dizimi (16 grafem). |
| welcome | examples[1] | "Welcome to the team, Lucas!" → "Welcome to the team!" (TR: "Ekibe hoş geldin!") | Lucas parçada 3 kez geçiyordu (sınır 2). |
| nice talking to you | quiz.cloze | "my train is here" → "my taxi is here" | s4 `get on` cloze'una ve kart 12'deki trene benzemesin diye. |
| I'd better go | mistakes[0].why | "…akla 'I have to go' kalıbını getirir; bu yüzden 'to' eklenir…" → "Türkçedeki 'gitmeliyim' akla 'have to go' ya da 'need to go' kalıplarını getirir; bunlar 'to' aldığı için burada da 'to' eklenir. 'had better' sonrasında fiil 'to' almaz." | Yanıltan şey İngilizce kalıp benzetmesi, bunu açıkça söylüyor. Ayrıca 200 grafem sınırı içinde. |

#### Anadili Türkçe birinin bakması gerekenler
- **nice to see you** gloss_short "seni görmek hoş": biraz düz kaçıyor. "seni görmek güzel" daha doğal ama 17 grafem. Alternatif "görmek ne güzel" (15) olabilir ama nesnesi yok.
- **say hello to** hatası "Say my greetings to your mother.": calque olarak akla yatkın ama ne kadar yaygın olduğundan tam emin değilim. Kaldı.
- **nice talking to you** gloss_short "konuşmak güzeldi": kilit ekranında tek başına yeterince açık mı?
- **nice to meet you** örnek 2'de hitaptan önce virgül yok ("memnun oldum Burak"). Bilerek dokunmadım, deste genelinde nasıl kullanıldığına bakılabilir.

### 2. denetçi (2. yazarın 12 kartı)

#### Özet
- İncelenen kart: 12
- Değişen kart: 6 (my pleasure, no thanks, please, could you, may I, do me a favor)
- Değişen alan: 13
- Reddedilen: 0
- Doğrulayıcı: `12 kart · 12 şemadan geçti · 0 hata · 0 uyarı`
- cross_check s20: `problems: 0`

#### Genel bulgular
- Kartlar genel olarak sağlam: tanımlar basit, örnekler doğal, notlarda kime/ne zaman/cevabı bilgisi var, İngilizce sözcükten sonra ayrı ek yok.
- Hatalar (mistakes): brief'teki adayların hepsi gerçek ve Türkçeye özgü bulundu ("Thank you for help me", kapıda "You're welcome!", "Can I take a coffee?", "I like a tea, please", "Can you make me a favor?"). Yazarın kendi eklediklerinden ikisi silindi: please "Give me a coffee." (Türkçeye özgü değil, `why` da tutarsızdı: Türkçedeki kibar biçim 'verir misiniz' "Give me" emrine götürmez) ve could you "Yes, I could." (genel öğrenci hatası, Türkçeyle ilgisi zayıf). may I "May you help me?" kaldı, `why` düzeltildi (Türkçede izin ve rica aynı '-ebil' ekiyle kurulur).
- Confusables: hem `synonyms` hem `confusables` içinde duran eşler kaldırıldı (could you → "can you", may I → "can I"). Bunlar yalnızca kibarlık farkı olan eş anlamlılar; kullanmak hata değil. Kalanlar gerçek: thanks to (benzer biçim, "sayesinde"), with pleasure (benzer biçim, kabul ederken "memnuniyetle"), go ahead / come in (hepsi "buyurun"), can I take ("almak"), could you (May you hatası), welcome, I like, thank you (Türkçede tek başına "sağ ol" = hayır).
- Quiz: iki zayıf ya da ikinci doğru cevaba açık çeldirici değişti (may I "Do I": "Excuse me, doctor. Do I come in?" söylenebilir; could you "Did you").

#### Yazarın belirsiz maddeleri
1. may I IPA `/meɪ ˈaɪ/` → `/ˈmeɪ aɪ/`. "May I come in?" cümlesinde "I" vurgusuzdur; tek başına "May I?" dışında vurgu "may" üzerindedir. Böylece could you `/ˈkʊd ju/` ile de tutarlı.
2. do me a favor gloss_short "bir iyilik yap": kaldı. Türkçede "Bir iyilik yap, şunu getir" kalıbı doğal; "bir ricam var" anlamı "I have a request" yönüne kaydırır (alt'ta duruyor).
3. could you "-ebilir misiniz?" ve can I have "… alabilir miyim?": tutarlı bırakıldı. Kural şu: ardından fiil gelen kalıpta ek biçimi (could you, may I: -ebilir misiniz / -ebilir miyim), ardından isim gelen kalıpta "…" boşluğu (can I have, I'd like, thank you for).
4. Quiz: thanks a lot "thank a lot" kaldı (kalıbın gerçek hatalı biçimi, cümlede açıkça yanlış). could you: "Did you" → "Do you" ("Yardım eder misin?" → "Do you help?" kalıbı, gerçek bir Türkçe aktarması), "Would I" ve "Should you" kaldı.
5. my pleasure register formal → neutral (örneklerin ikisi neutral; arkadaş arasında da söylenir; nottaki "biraz daha resmî" ifadesi kaldı). no thanks confusables ["thank you"] kaldı (nottaki gerçek kullanım farkına dayanıyor).
6. Mistakes: yukarıda.
7. Confusables: yukarıda.

#### Değişiklik tablosu
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| my pleasure | tags.register | formal → neutral | Örnekler çoğunlukla neutral; arkadaşa da söylenir. |
| no thanks | l1.tr.gloss_short | "sağ ol, istemem" → "hayır, sağ ol" | "istemem" tek başına sert okunabilir; "hayır, sağ ol" gloss'a daha yakın ve nötr. |
| no thanks | l1.tr.alt | ["hayır, sağ ol", "sağ ol, istemem"] → ["yok, sağ ol", "sağ ol, istemem"] | gloss_short ile çift olmasın. |
| please | l1.tr.mistakes | "Give me a coffee." → (boş) | Türkçeye özgü değil; why tutarsızdı. |
| could you | l1.tr.mistakes | "Yes, I could." → (boş) | Genel öğrenci hatası; Türkçeyle bağı zayıf. |
| could you | confusables | ["can you"] → (alan yok) | synonyms'te de var; yalnızca kibarlık farkı olan eş anlamlı. |
| could you | quiz.distractors | "Did you" → "Do you" | Daha anlamlı çeldirici ("eder misin?" aktarması). |
| may I | ipa.us / ipa.uk | /meɪ ˈaɪ/ → /ˈmeɪ aɪ/ | "I" bu kalıpta vurgusuz. |
| may I | confusables | ["can I", "could you"] → ["could you"] | "can I" synonyms'te; eş anlamlı. |
| may I | mistakes[0].why | "-ebilir misiniz hem izin hem rica… may yalnızca I ve we ile" → "izin de rica da '-ebil' ekiyle sorulur…; 'may' de her kişiyle kullanılır sanılır. Rica ederken 'Could you…?' denir." | Eski açıklama Türkçeyi yanlış anlatıyordu; "May he…?" da mümkün olduğundan "yalnızca I ve we" iddiası kaldırıldı. |
| may I | quiz.distractors | "Do I" → "Am I" | "Excuse me, doctor. Do I come in?" de söylenebilir (ikinci doğru cevap). |
| do me a favor | examples[1].tr | "…havalimanına gitmem için arabaya ihtiyacım var." → "…Cuma günü beni havalimanına götürecek biri lazım." | "I need a ride" araba ihtiyacı değil; geri çeviri tutmuyordu. |

#### Anadili Türkçe birinin bakması gerekenler
- no thanks gloss_short "hayır, sağ ol" mu, "yok, sağ ol" mu daha doğal?
- I'd like hatası "I like a tea, please." kaldı (brief adayı). Türkçeye özgülüğü orta düzeyde ('d kısaltması Türkçede yok, duyulmuyor); gerçekten sık mı?
- may I "May you help me?" hatası: Türk öğrencilerde yeterince yaygın mı?
- you're welcome örnek 1: "Teşekkür ederim doktor bey." ("bey" cinsiyet ekliyor; dokunulmadı, Türkçede doğal hitap).
- thank you for gloss_short "… için sağ olun" doğal mı ("… için teşekkürler" 16'yı geçiyor)?

### 3. denetçi (3. yazarın 12 kartı)

#### Özet
- İncelenen kart: 12
- Değişen kart: 6 (sorry to bother you, it won't happen again, no harm done, how was your weekend, have we met before, what brings you here)
- Değişen alan: 8
- Reddedilen: 0
- Doğrulayıcı: `12 kart · 12 şemadan geçti · 0 hata · 0 uyarı`; cross_check `problems: 0`

#### Genel bulgular
- Kartlar genel olarak sağlam: tanımlar basit, örnekler doğal, notlarda kullanım bilgisi var, İngilizce sözcükten sonra ayrı yazılmış ek yok.
- İsim sınırı aşılmıştı: Hana 3 kez, Murat 3 kez geçiyordu. Birer tanesini Deniz yaptım (Deniz önce hiç kullanılmamıştı).
- Kısa anlamlardan ikisi zayıftı: `kusura bakmayın` "bother" anlamını kaybediyordu, `ne için geldin?` notun "kaba gelebilir" dediği tona kayıyordu.
- Yazarın sorduğu maddeler:
  1. **how was your weekend:** `hafta sonun nasıldı?` 20 grafem, 16'ya sığan ve geçmiş zamanı koruyan doğal bir biçim bulamadım (`hafta sonu nasıldı` 18, `hafta sonun nasıl` 17). `hafta sonu nasıl` kaldı, Türkçe bilen birine bırakıldı. Quizde `is` şıkkı sorunluydu: dilbilgisi olarak doğru, onu yalnızca cevaptaki "went" eliyordu. Yerine `has` koydum ("How has your weekend?" `been` olmadan yanlış). Şıklar artık did / were / has; hepsi dilbilgisi olarak yanlış ve gerçek öğrenci hatalarına yakın.
  2. **sorry to bother you:** Brief'teki `rahatsız ettiğim için kusura bakmayın` 37 grafem, gloss sınırı 28 (LEN hatası). `rahatsız ediyorum ama` Türkçede tam bu durumda söylenen doğal kalıp, gloss olarak kaldı. Kısa anlam `kusura bakmayın` yerine `rahatsız ettim` oldu ("bother" anlamı korunuyor). `kusura bakmayın` alt'a geçti.
  3. **IPA:** oops US /uːps/, UK /ʊps/: iki sözlükte de iki söyleyiş var, kabul edilebilir. where are you from: `are` için zayıf biçim (/ər/, /ə/) depodaki kurala uyuyor (make yourself at home /jər/, for sale /fər/–/fə/). `where` UK /wɛə/ depoda karışık (hair /hɛə/, wear /weə/), dokunmadım. weekend UK /ˌwiːkˈɛnd/ s2'deki `weekend` kartıyla aynı. fault US /fɔːlt/ depodaki /kɔːl/ ve /tɔːk/ kuralına uyuyor.
  4. **fault kökeni:** Doğru. Orta İngilizce faute, Eski Fransızca faute, Halk Latincesi *fallita, Latince fallere'den geliyor. "l" harfi sonradan Latinceye benzetmek için eklendi. Kaldı. Quizde "mistake" şık değil. Cümle (the other driver's ___) şıklarla birlikte tek cevaplı.
  5. **Confusables:** sorry to bother you için `excuse me` (ikisi de yabancının dikkatini çekmeye yarar, kullanımları farklı) ve `I'm sorry to hear that` (aynı "sorry to" yapısı, anlamı teselli) kaldı. no harm done için `no problem` silindi: özre verilen düz eş anlamlı cevap. `never mind` kaldı: Türkçe "önemli değil / boş ver" ikisine de karşılık geliyor ve kullanımları farklı. I'm afraid için `afraid` kaldı: lemma farklı olduğu için CONF_SELF sayılmaz, korku anlamı gerçek ve çok yaygın bir karışıklık, s3'teki kartla da eşleşiyor. oops için `oh no` kaldı (küçük ve ciddi durum farkı). what do you do için `what are you doing` kaldı.
  6. **Mistakes:** Üçü de gerçek ve yaygın hatalar: "It's not my mistake" ("benim hatam değil"den), "What are you doing?" ile meslek sormak ("Ne iş yapıyorsun?"daki şimdiki zamandan), "I'm from Turkish" (ülke ile milliyet karışıyor). Kaldılar.
- Confusables alanı boş olan kartlar (gerçek bir eş bulamadım): it won't happen again, no offense, how was your weekend, where are you from, have we met before, what brings you here.

#### Değişiklik tablosu
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| sorry to bother you | l1.tr.gloss_short | kusura bakmayın → rahatsız ettim | "bother" anlamı kayboluyordu |
| it won't happen again | examples[2].register | formal → neutral | Raporu yanlış müşteriye gönderme cümlesi resmî değil |
| no harm done | confusables | [never mind, no problem] → [never mind] | `no problem` düz eş anlamlı |
| how was your weekend | quiz.distractors | [is, did, were] → [did, were, has] | `is` dilbilgisi olarak doğruydu, ikinci doğru cevap olabiliyordu |
| have we met before | examples[1] en/tr | Murat → Deniz | Murat 3 kez geçiyordu |
| what brings you here | examples[1] en/tr | Hana → Deniz | Hana 3 kez geçiyordu |
| what brings you here | l1.tr.gloss_short | ne için geldin? → seni ne getirdi? | Eski biçim kaba "Why are you here?" tonundaydı ve nota ters düşüyordu |

#### Anadili Türkçe birinin bakması gerekenler
- `hafta sonu nasıl` (how was your weekend, gloss_short): geçmiş zamanı ve "-un" ekini kaybediyor. 16 grafemlik daha iyi bir biçim var mı?
- `rahatsız ettim` (sorry to bother you, gloss_short): kilit ekranında tek başına okununca doğal mı? Bir şey sormadan önce de söylenebilir mi?
- `seni ne getirdi?` (what brings you here, gloss_short): "buraya" olmadan doğal mı?
- `rahatsız ediyorum ama` (gloss): sonundaki "ama" ile gloss olarak kabul edilebilir mi? Brief'teki uzun biçim 28 grafem sınırını aşıyor.

### 4. denetçi (4. yazarın 12 kartı)

#### Özet
- İncelenen kart: 12 · değişen kart: 10 · değişen alan: 14 · reddedilen: 0
- Doğrulayıcı: `12 kart · 12 şemadan geçti · 0 hata · 0 uyarı`; cross_check `problems: 0`

#### Genel bulgular
- Kartlar genel olarak sağlam: anlamlar, register'lar (yalnızca what have you been up to `informal`, gerisi `neutral`), IPA ve vurgular doğru.
- En sık 3 sorun: (1) bir şey sınamayan çeldiriciler (to be honest: Good luck / Happy New Year; speaking of: In front of / Far from), (2) notlarda küçük yanlış ya da garip ifadeler ("ek fiile göre değişir" denip 'don't you?' örneği verilmesi, "Kısa biçimi: Honestly", "'Make' burada bir fiildir"), (3) desteyle çakışma: personally'nin 1. örneği s1 spicy örneğinin aynısıydı ("I don't like spicy food").
- Yazarın şüpheli maddeleri:
  1. IPA: `/wʌt əv ju bɪn ˈʌp tuː/` (US'de sondaki `tu` → `tuː`, UK ile aynı olsun diye), `/ɪts ʌp tə ˈjuː/` doğru (vurgu "you" üzerinde). been US /bɪn/, UK /biːn/ doğru.
  2. "… demişken" doğru. gloss_short "neler yapıyorsun" soru işaretsiz de kendi başına doğal okunuyor; "?" eklenince 17 grafem oluyor, öyle bıraktım.
  3. Confusables: as long as: benzer biçim ("as long as I know" gerçek bir öğrenci hatası) olduğu için kaldı, ama destede kart değil; sınırda, aşağıya yazdım. it depends: kaldı (Türkçe "sana bağlı" → "It depends on you" karışıklığı gerçek; nota da ekledim). sensible: kaldı (ikisi de "mantıklı"). what are you up to / how have you been: kaldı (benzer biçim, bilinen kullanım farkı). by the way: kaldı (ikisi de konu geçişi; notta fark yazıyor). prefer / I'd better go: kaldı.
  4. "What" (How/Which/Who): Which ve Who bu cümlede açıkça yanlış, How gerçek hata biçimi; madde kartı sınıyor. "have you" (are you/did you/do you): yalnızca "have you" dilbilgisel, "are you" kartın asıl hatası; kaldı.
  5. how long have you been `why`: doğru ("How long are you in Ankara?" kalma süresi olarak anlaşılır), kısaltıldı ve not ile tekrarı azaltıldı.
  6. Hatalar: beşi de Türkçe konuşanlarda gerçekten görülen hatalar; hepsi kaldı.

#### Değişiklik tablosu
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| isn't it | l1.tr.note | "ek fiile göre değişir" → "özneye ve fiile göre değişir" | 'don't you?' ek fiil değil |
| what have you been up to | ipa.us | `…ˈʌp tu/` → `…ˈʌp tuː/` | cümle sonunda tam biçim, UK ile tutarlı |
| speaking of | quiz.distractors | Speaking to / In front of / Far from → Speaking to / Spoken of / Speaks of | yer edatları hiçbir şey sınamıyordu; kalıbın yanlış biçimleri ("Speak of" s22 speak of the devil yüzünden alınmadı) |
| how long have you been | mistakes[0].why | uzun, notu tekrar eden metin → kısaltıldı, "'ne kadar kalacaksın' diye anlaşılır" | sınır 200 grafem, tekrar |
| what do you think | l1.tr.note | "'Sence nasıl?' yüzünden 'How' denmez" → "'Sence nasıl?' akla gelse de 'How' değil 'What' kullanılır" | anlam belirsizdi |
| I don't think so | l1.tr.alt | "hiç sanmam" → "sanmam" | "hiç sanmam" daha güçlü (I really doubt it) |
| it's up to you | collocations | "it's up to you" (lemmanın kendisi) → "it's up to you to decide" | kendini tekrar |
| it's up to you | l1.tr.note | + "'Sana bağlı' için de bu söylenir." | Türkçe "sana bağlı" → "It depends on you" karışıklığı |
| personally | examples[0] | "Personally, I don't like spicy food." → "Personally, I like winter more than summer." / "Şahsen kışı yazdan daha çok severim." | s1 spicy örneğinin kopyası |
| to be honest | quiz.distractors | Good luck / For example / Happy New Year → To be honestly / Be honest / To honesty | ilgisiz çeldiriciler; Good luck s20'de zaten 2 kez |
| to be honest | l1.tr.note | "Kısa biçimi: 'Honestly'" → "Benzeri: 'Honestly'" | kısa biçim değil, ayrı sözcük |
| make sense | examples[1].tr | "Bu mesaj hiç anlaşılır değil." → "Bu mesaj anlaşılmıyor." | "hiç" fazlaydı, doğallık |
| make sense | l1.tr.note | "'Make' burada bir fiildir" → "'Mantıklı' için 'logic' (mantık) denmez; bu kalıp ya da 'logical' kullanılır." | işe yaramaz cümle yerine gerçek bir tuzak (hata alanına koymadım, emin değilim) |

Değişmeyen kartlar: as far as I know, I'd rather.

#### Anadili Türkçe birinin bakması gerekenler
- as far as I know → confusables "as long as": destede kart değil; benzer biçim gerekçesiyle kaldı, istenirse silinebilir.
- what have you been up to gloss_short "neler yapıyorsun" (soru işaretsiz) kilit ekranında soru gibi okunuyor mu?
- it's up to you notundaki "'Sana bağlı' için de bu söylenir." cümlesi yeterince açık mı?
- make sense notunda 'logic' uyarısı: "It's logic" hatası yaygın mı? Yaygınsa mistakes'e taşınabilir.
- to be honest çeldiricisi "To honesty" fazla uydurma görünüyorsa "To be honestly" ve "Be honest" yeterli, üçüncüsü değiştirilebilir.

### 5. denetçi (5. yazarın 12 kartı)

#### Özet

- İncelenen kart: **12**
- Değişen kart: **7** (fair enough, let me think, pardon, I didn't catch that, I see, I don't follow, what do you mean; hepsine `critic_edited` eklendi)
- Değişen alan: 12
- Reddedilen kart: **0**
- Doğrulayıcı: `12 kart · 12 şemadan geçti · 0 hata · 0 uyarı`; `cross_check.py s20`: `problems: 0`

#### Genel bulgular

- Kartlar genel olarak iyiydi: tanımlar döngüsüz, register etiketleri doğru (fair enough, got it, I mean `informal`; geri kalanı `neutral`; pardon'un garson ve öğretmen örnekleri `formal`), notlarda İngilizce sözcükten sonra ayrık ek yok.
- En sık sorunlar: (1) s20'nin başka part'larıyla ortak çeldiriciler (Help yourself, Bless you, Well done, Never mind, Cheers, Not yet); hepsi s20'de tek kullanımlık yenileriyle değişti; (2) gloss ya da çevirinin anlamı biraz kaydırması (fair enough "haklısın" tam katılmak gibi okunuyor; "anons kısıktı"); (3) küçük tutarsızlıklar (what do you mean'de gloss_short'un alt'ta da olması; I don't follow 3. örnekte geçmiş zamanla şimdiki zamanın karışması).
- Yazarın emin olmadığı maddeler:
  1. fair enough gloss: "haklısın" alt'a indi, gloss "peki, anlıyorum" oldu.
  2. could you say that again: gloss_short "tekrarlar mısın?" (sen) ile gloss "tekrar söyler misiniz?" (siz) uyuşmuyor, ama 16 karaktere sığan "siz" biçimi yok ("tekrarlar mısınız?" 18). Kaldı.
  3. IPA: UK /ˌfeər ɪˈnʌf/ depo düzenine uyuyor (bağlayıcı r başka kartlarda da var: /klɪər ˈʌp/, /wɛər ə ju ˈfrɒm/). why not /ˌwaɪ ˈnɑːt/ doğru. Değişmedi.
  4. Quiz: let me think'te "tell" çıktı ("Hmm, let me tell... It's 56!" yarı yarıya kuruluyordu), yerine "help" geldi. got it'teki "Go on" zayıf ama açıkça yanlış ve aynı işlevde, kaldı.
  5. Hatalar: dördü de gerçek bulundu ve kaldı. "Let me to think" bilinen bir let + to hatası. s5 `let` kartında aynı türden bir hata var ("doesn't let me to go out"), ama cümle farklı ve bu kalıba doğrudan bağlı. "Can you say again?" ve "What do you want to say?" Türkçeden birebir çeviriyle çok yaygın. "Pardon, can you help me…" → "Excuse me" de gerçek. pardon: `false_friend: null`, `equivalence: partial` kararına katılıyorum. ABD'de "Pardon me" dikkat çekmek ve küçük özürler için de kullanıldığından tam bir sahte dost değil, kullanım farkı.
  6. Confusables: hepsi kaldı. let me think → let me know benzer biçimde ("let me + fiil = -eyim" kalıbı "let me know"da bozuluyor). could you say that again → tell bilinen say/tell karışıklığı. I see ↔ got it ikisi de "anladım", register farkı var. I didn't catch that ↔ I don't follow ikisi de "anlayamadım", duymak/anlamak farkı var. I mean → in other words ikisi de "yani"; I mean → what do you mean benzer biçim.

#### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| fair enough | l1.tr.gloss / alt | "haklısın" / [makul, peki, anlıyorum, mantıklı] → "peki, anlıyorum" / [haklısın, makul, mantıklı] | "Haklısın" tam katılmak gibi okunuyor; kalıp katılmadan kabul etmek |
| fair enough | examples[0].tr | "Haklısın, anladım." → "Tamam, anlıyorum." | "Gelemem, çalışmam lazım"a "haklısın" denmez |
| fair enough | quiz.distractors | Help yourself, Bless you → Take a seat, Sleep well | s20'de part_02 ve part_01'de de kullanılıyordu |
| let me think | quiz.distractors | tell → help | "let me tell… It's 56" yarı yarıya kuruluyordu |
| pardon | l1.tr.note | "Türkçedeki gibi özür dilerken 'Sorry!'…" → "Türkçede pardon dediğimiz yerlerde özür için 'Sorry!', dikkat çekmek ya da yol istemek için 'Excuse me' daha doğaldır." | Eski cümle "Türkçedeki gibi"yi yanlış yere bağlıyordu |
| pardon | quiz.distractors | Cheers, Well done, Never mind → Enjoy your meal, Nice try, Get well soon | Üçü de s20'nin başka quiz'lerinde vardı |
| I didn't catch that | examples[2].tr | "anons çok kısıktı" → "anonsun sesi çok kısıktı" | Kısık olan anons değil, sesi |
| I see | quiz.distractors | not yet → you too | part_01 not bad'de de vardı |
| I don't follow | examples[2].en/tr | "Omar talked … for ten minutes, but I'm not following." → "Omar is explaining the new tax rules, but I'm not following." / "…anlatıyor ama ben takip edemiyorum." | Geçmiş zamanla şimdiki zaman karışıyordu |
| what do you mean | l1.tr.alt | [nasıl yani?, yani?] → [ne kastediyorsun?, yani?] | "nasıl yani?" zaten gloss_short |

#### Anadili Türkçe birinin bakması gerekenler

- fair enough gloss "peki, anlıyorum": doğal mı, yoksa "tamam, makul" mu daha iyi?
- could you say that again gloss_short "tekrarlar mısın?": "siz" yerine "sen" biçimi kilit ekranında sorun olur mu?
- in other words gloss_short "başka deyişle" ("bir" olmadan) yeterince doğal mı?
- I didn't catch that alt "kaçırdım": tek başına okununca otobüs kaçırmak gibi anlaşılabilir. Silinebilir.

## Bağımsız doğrulama: uygulanan değişiklikler

64 alan değişikliği, 30 kart. Değişen her kartın `meta.qa_flags` alanına bir kez `validator_edited` eklendi. Kart kimlikleri kısa yazıldı (`en.<kimlik>.<tür>.1` biçiminin orta kısmı).
Doğrulama: `vocabpipe.validate --strict s20` → `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`; `cross_check.py` → `problems: 0`. s20 içinde artık hiçbir çeldirici iki kez kullanılmıyor.

| Kart | Alan | Önce → Sonra | Kaynak (quiz/türkçe/ingilizce) |
|---|---|---|---|
| in_other_words | quiz.cloze | The museum is free for children under 18. ______, Omar's kids don't have to pay. → “The soup was salty and the waiter was rude.” “______, you didn't like the place.” | quiz+ingilizce |
| in_other_words | examples.0.en | The shop opens at noon. In other words, we have time for breakfast. → The hotel room is “cozy”. In other words, it's very small. | ingilizce |
| in_other_words | examples.0.tr | Dükkân öğlen açılıyor. Başka bir deyişle, kahvaltıya vaktimiz var. → Otel odası “şirin”. Başka bir deyişle, çok küçük. | ingilizce |
| in_other_words | examples.2.en | Lena's flight leaves at 6 a.m. In other words, she has to get up at four. → Lena is my mother's sister. In other words, she's my aunt. | ingilizce |
| in_other_words | examples.2.tr | Lena'nın uçağı sabah altıda kalkıyor. Başka bir deyişle, saat dörtte kalkması gerekiyor. → Lena annemin kız kardeşi. Başka bir deyişle, teyzem. | ingilizce |
| pardon | quiz.distractors | ["Enjoy your meal", "Nice try", "Get well soon"] → ["Enjoy your meal", "Nice try", "Take care"] | quiz |
| fair_enough | quiz.distractors | ["Take a seat", "Sleep well", "Watch out"] → ["Not bad", "Good job", "Hurry up"] | quiz+ingilizce |
| good_night | quiz.distractors | ["Good evening", "Happy birthday", "Well done"] → ["Good evening", "Good morning", "Well done"] | quiz |
| good_evening | quiz.distractors | ["Good night", "Good morning", "Good afternoon"] → ["Good night", "Good afternoon", "Sleep well"] | quiz (tekrar) |
| what_brings_you_here | l1.tr.gloss | seni buraya ne getirdi? → ne vesileyle buradasın? | türkçe |
| what_brings_you_here | l1.tr.gloss_short | seni ne getirdi? → ne vesileyle? | türkçe |
| what_brings_you_here | l1.tr.alt | ["hangi rüzgâr attı?", "ne için geldin?"] → ["seni buraya ne getirdi?", "buraya ne için geldin?"] | türkçe |
| what_brings_you_here | examples.0.tr | Merhaba, ben Hakan. Eee, seni buraya ne getirdi? → Merhaba, ben Hakan. Eee, buraya ne vesileyle geldin? | türkçe |
| what_brings_you_here | examples.1.tr | “Seni İstanbul'a ne getirdi Deniz?” “İş. Bir toplantı için buradayım.” → “Ne vesileyle İstanbul'dasın Deniz?” “İş. Bir toplantı için buradayım.” | türkçe |
| nice_to_see_you | l1.tr.gloss_short | seni görmek hoş → görmek ne güzel | türkçe |
| how_was_your_weekend | l1.tr.gloss_short | hafta sonu nasıl → nasıl geçti? | türkçe |
| id_like | l1.tr.gloss | … istiyorum → … isterim | türkçe |
| id_like | l1.tr.alt | ["… isterim", "… alayım"] → ["… alayım", "… istiyorum"] | türkçe |
| im_afraid | examples.2.tr | Korkarım bu konuda sana yardım edemem Priya. Lütfen müdüre sor. → Korkarım bu konuda size yardım edemem Priya Hanım. Lütfen müdüre sorun. | türkçe |
| thank_you_for | examples.1.tr | Beklediğiniz için teşekkür ederim. Doktor sizi şimdi görebilir. → Beklediğiniz için teşekkür ederim. Doktor sizi şimdi alabilir. | türkçe |
| say_hello_to | examples.1.tr | Ayşe ofisteki herkese selam söylüyor. → Ayşe'nin ofisteki herkese selamı var. | türkçe |
| have_a_nice_day | l1.tr.alt | ["iyi bir gün geçir"] → ["günün iyi geçsin"] | türkçe |
| pardon | l1.tr.note | Duyamayınca yükselen sesle 'Pardon?' denir; kibardır. Türkçede pardon dediğimiz yerlerde özür için 'Sorry!', dikkat çekmek ya da yol istemek için 'Excuse me' daha doğaldır. → Duyamayınca yükselen bir tonla 'Pardon?' denir; kibardır. Türkçede pardon dediğimiz yerlerde özür için 'Sorry!', dikkat çekmek ya da yol istemek için 'Excuse me' daha doğaldır. | türkçe |
| thank_you_for | ipa.us | /ˈθæŋk ju fɔːr/ → /ˈθæŋk ju fər/ | ingilizce |
| thank_you_for | ipa.uk | /ˈθæŋk ju fɔː/ → /ˈθæŋk ju fə/ | ingilizce |
| thanks_a_lot | def.short | an informal, friendly way to tell someone you are very happy about their help → a warm, friendly way to tell someone you are very happy about their help | ingilizce |
| let_me_think | confusables | ["let me know"] → (alan kaldırıldı) | ingilizce |
| no_thanks | l1.tr.gloss_short | hayır, sağ ol → yok, sağ ol | türkçe |
| no_thanks | l1.tr.alt | ["yok, sağ ol", "sağ ol, istemem"] → ["hayır, sağ ol", "sağ ol, istemem"] | türkçe |
| what_have_you_been_up_to | l1.tr.gloss_short | neler yapıyorsun → ne var ne yok? | türkçe |
| what_have_you_been_up_to | l1.tr.alt | ["ne var ne yok?", "neler yaptın?"] → ["neler yapıyorsun?", "neler yaptın?"] | türkçe |
| where_are_you_from | ipa.uk | /wɛər ə ju ˈfrɒm/ → /weər ə ju ˈfrɒm/ | ingilizce |
| i_didnt_catch_that | ipa.us | /aɪ ˈdɪdənt ˈkætʃ ðæt/ → /aɪ ˌdɪdnt ˈkætʃ ðæt/ | ingilizce |
| i_didnt_catch_that | ipa.uk | /aɪ ˈdɪdənt ˈkætʃ ðæt/ → /aɪ ˌdɪdnt ˈkætʃ ðæt/ | ingilizce |
| what_do_you_do | ipa.us | /wʌt də jə ˈduː/ → /wʌt də ju ˈduː/ | ingilizce |
| what_do_you_do | ipa.uk | /wɒt də jə ˈduː/ → /wɒt də ju ˈduː/ | ingilizce |
| what_do_you_mean | ipa.us | /wʌt du ju ˈmiːn/ → /wʌt də ju ˈmiːn/ | ingilizce |
| what_do_you_mean | ipa.uk | /wɒt du ju ˈmiːn/ → /wɒt də ju ˈmiːn/ | ingilizce |
| sorry_to_bother_you | ipa.us | /ˈsɑːri tə ˈbɑːðər ju/ → /ˌsɑːri tə ˈbɑːðər ju/ | ingilizce |
| sorry_to_bother_you | ipa.uk | /ˈsɒri tə ˈbɒðə ju/ → /ˌsɒri tə ˈbɒðə ju/ | ingilizce |
| sorry_to_bother_you | synonyms | ["sorry to trouble"] → [] | ingilizce |
| it_wont_happen_again | collocations | ["sorry, it won't happen again", "I promise it won't"] → ["sorry, it won't happen again"] | ingilizce |
| thank_you_for | examples.0.en | Thank you for the lovely flowers, Elif. → Thank you for the beautiful scarf, Elif. | ingilizce |
| thank_you_for | examples.0.tr | Güzel çiçekler için teşekkür ederim Elif. → Bu güzel atkı için teşekkür ederim Elif. | ingilizce |
| isnt_it | quiz.cloze | The weather is lovely today, ______? → It's a lovely day today, ______? | ingilizce |
| nice_talking_to_you | examples.2.register | formal → neutral | ingilizce |
| nice_talking_to_you | examples.1.tr | “Seninle sohbet etmek güzeldi.” “Benim için de! Yakında yine görüşelim.” → “Seninle sohbet etmek güzeldi.” “Ben de çok keyif aldım! Yakında yine görüşelim.” | türkçe |
| fair_enough | examples.2.tr | Mia karda araba kullanmak istemedi, abisi de “Tamam, haklısın. Ben kullanırım.” dedi. → Mia karda araba kullanmak istemedi, kardeşi de “Tamam, haklısın. Ben kullanırım.” dedi. | türkçe |
| welcome | examples.2.tr | “Hoş geldiniz! Buyurun, girin.” “Teşekkürler. Ne güzel bir daire!” → “Hoş geldiniz! Buyurun, içeri geçin.” “Teşekkürler. Ne güzel bir daire!” | türkçe |
| fault | l1.tr.alt | ["kabahat", "hata"] → ["kabahat"] | türkçe |
| how_have_you_been | l1.tr.alt | ["bu ara nasılsın?"] → ["nasılsın bu aralar?"] | türkçe |
| thanks_a_lot | quiz.distractors | ["thank a lot", "never mind", "good night"] → ["thank a lot", "never mind", "happy birthday"] | quiz (tekrar) |
| have_a_nice_day | quiz.distractors | ["Good days", "Have nice day", "Hello"] → ["Good days", "Have nice day", "Welcome back"] | quiz (tekrar) |
| welcome | quiz.distractors | ["You're welcome", "Goodbye", "Good luck"] → ["You're welcome", "Bye for now", "Good luck"] | quiz (tekrar) |
| please | quiz.distractors | ["sorry", "hello", "goodbye"] → ["ouch", "hello", "goodbye"] | quiz (tekrar) |
| sorry_to_bother_you | quiz.distractors | ["hear", "miss", "tell"] → ["hear", "miss", "leave"] | quiz (tekrar) |
| what_do_you_mean | quiz.distractors | ["want to say", "talk", "explain"] → ["want to say", "ask", "explain"] | quiz (tekrar) |
| where_are_you_from | quiz.distractors | ["of", "to", "by"] → ["of", "in", "by"] | quiz (tekrar) |
| how_long_have_you_been | quiz.distractors | ["are you", "did you", "do you"] → ["are you", "did you", "were you"] | quiz (tekrar) |
| it_wont_happen_again | quiz.distractors | ["become", "make", "stay"] → ["become", "come", "stay"] | quiz (tekrar) |
| i_didnt_catch_that | quiz.distractors | ["take", "hold", "keep"] → ["throw", "hold", "keep"] | quiz (tekrar) |
| how_was_your_weekend | quiz.distractors | ["did", "were", "has"] → ["did", "were", "had"] | quiz (tekrar) |
| what_brings_you_here | quiz.distractors | ["takes", "gives", "makes"] → ["takes", "puts", "makes"] | quiz (tekrar) |
| thanks_a_lot | quiz.distractors | ["thank a lot", "never mind", "happy birthday"] → ["make", "give", "take"] | quiz (tekrar) |

### Uygulanmayan ya da değiştirilerek uygulanan bulgular

- **here_you_are IPA vurgusu (ingilizce, MEDIUM):** uygulanmadı. Vurgu "here" üzerinde de "are" üzerinde de duyulabiliyor ve ben emin değilim; talimat da yalnızca emin olunursa değiştirmeyi söylüyordu.
- **in_other_words quiz (quiz, MEDIUM):** önerilen "film uzun ve sıkıcıydı" cümlesi kullanılmadı, çünkü s20 i_mean örneği ("The film was long. I mean…") ve s7 anyway örneğiyle çok benzer. Bunun yerine aynı işlevi gören bir özet cümlesi yazıldı (çorba/garson). Çeldiriciler aynı kaldı.
- **in_other_words örnek 3:** "Lena vejetaryen" fikri s9 meat quiz'ine ("Hasan is a vegetarian…") çok yakındı. Bunun yerine "teyze" tanımı kullanıldı.
- **thank_you_for örnek 1:** önerilen "Thank you for the flowers…" cümlesi s21 thoughtful örneğine ("Thanks for the flowers…") çok yakındı. Bunun yerine "beautiful scarf" yazıldı.
- **fair_enough çeldiricileri (ingilizce önerisi):** "Never mind / No way / How come" önerisi uygulanmadı. Quiz raporuna göre Never mind bu diyaloğa uyuyor; No way ve How come da başka s20 quiz'lerinde kullanılıyor. Quiz raporunun önerisi ("Not bad, Good job, Hurry up") uygulandı.
- **good_night çeldiricileri:** öneri olduğu gibi uygulandı. "Good morning" good_evening quiz'inde de bulunduğu için oradaki "Good morning" "Sleep well" ile değiştirildi.
- **pardon çeldiricileri:** quiz raporunun önerisi (Take care) uygulandı. İngilizce raporun "Well done / Cheers" önerisi kullanılmadı, çünkü ikisi de başka s20 quiz'lerinde var.
- **sorry_to_bother_you eş anlamlısı "sorry to trouble you":** 20 grafem, synonym sınırı 16. Kesik parça silindi, eş anlamlılar listesi boş bırakıldı.
- **it_wont_happen_again "I promise it won't happen again":** 31 grafem, collocation sınırı 28. Kesik parça silindi, yalnızca "sorry, it won't happen again" kaldı.
- **what_do_you_do gloss "ne iş yapıyorsun?" (türkçe, LOW):** soru işaretiyle 17 grafem oluyor ve gloss_short gerektiriyor (uyarı verdi). Bu yüzden geri alındı, gloss "ne iş yapıyorsun" olarak kaldı.
- **speaking_of → speak of the devil, personally → take it personally (ingilizce, LOW):** talimat gereği eklenmedi.
- **what_brings_you_here örnek 3 Türkçesi (türkçe, LOW, isteğe bağlı):** gayriresmî örnekte "hangi rüzgâr attı" kabul edilebilir bulundu ve değiştirilmedi. Ayrıca önerilen "Buraya ne için geldin?" nottaki "Why are you here? kaba gelebilir" uyarısına ters düşüyordu. (Bu ifade alt listesinde doğrulayıcının önerdiği gibi duruyor.)
- **whats_up çeldiricileri, please çeldiricilerinin zayıflığı, what_do_you_mean "want to say" (quiz, LOW):** gerekmedi ya da isteğe bağlıydı. Yalnızca please kartındaki tekrar eden "sorry" değiştirildi (ouch).
- **thank_you_for gloss_short "… için sağ ol", fair_enough gloss, sorry_to_bother_you gloss_short "kusura bakmayın", i_didnt_catch_that alt, in_other_words / could_you_say_that_again / nice_talking_to_you gloss_short (türkçe, LOW):** doğrulayıcı bunları zaten kabul edilebilir ya da isteğe bağlı buldu, değiştirilmedi.
- **pardon mistakes[0].why eki "(ABD'de 'Pardon me' bu anlamda da olur.)" (ingilizce, LOW, isteğe bağlı):** uygulanmadı. Madde doğrulayıcıya göre de doğru; ek, why metnini 200 sınırına çok yaklaştırıyordu.

## Son kontrol

Değişen 63 alanın 62'si doğru bulundu. Tek sorun: what brings you here `alt` içindeki "buraya ne için geldin?" ("Why are you here?" gibi kaba duyuluyor, nottaki uyarıyla çelişiyordu) → "hangi rüzgâr attı?" ile değiştirildi.

## Anadili Türkçe birinin bakması gerekenler (kısa liste)

1. Kilit ekranı kısa karşılıkları: nice to see you "görmek ne güzel", how was your weekend "nasıl geçti?", what brings you here gloss "ne vesileyle buradasın?" / kısa "ne vesileyle?", sorry to bother you "rahatsız ediyorum ama" / kısa "rahatsız ettim", fair enough "peki, anlıyorum", could you say that again kısa "tekrarlar mısın?" (sen; siz biçimi 16'ya sığmıyor), nice talking to you "konuşmak güzeldi".
2. Hata maddeleri yaygın mı: "Say my greetings to your mother.", "I like a tea, please.", "May you help me, please?", "Let me to think about it.", "(Kapıda) You're welcome! Please come in."
3. "It's logic." (mantıklı) yaygınsa make sense kartına hata olarak eklensin mi (şimdi yalnızca notta)?
4. as far as I know → confusables "as long as" kalsın mı?
5. I didn't catch that alt "kaçırdım" (otobüs kaçırmak gibi okunabilir) kalsın mı?
