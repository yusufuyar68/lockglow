# s10 QA incelemesi (iş ve ofis hayatı)

Kapsam: `content/drafts/kisisel_v1/s10/part_01.json` … `part_05.json`. 45 kart: toplantı, e-posta, görev, mesai, izin, maaş, iş arama. Süreç (2026-10-20):

1. **Yazım:** 5 yazar ajanı (Sonnet), her parçaya bir ajan. Sonradan eklenen company kartını koordinatör yazdı (aşağıda, "Akışlar arası kimlik çakışması").
2. **Denetim:** 5 denetçi (Opus), her parçaya bir denetçi. Ölçütler `SYSTEM_C` listesi ve A2 öğrenen gözü. Her Türkçe çeviri İngilizceye geri çevrildi, her quiz şıkkı boşluğa kondu.
3. **Bağımsız doğrulama:** 6 doğrulayıcı (Opus) denetçinin kararlarını bilmeden çalıştı. 5'i kendi parçasının bütün alanlarına, 1'i 45 quiz'in hepsine toplu olarak baktı. Böylece her quiz iki ayrı gözden geçti. Bulguları koordinatör tek tek değerlendirip uyguladı. Uygulanan değişiklikleri ayrı bir doğrulayıcı yeniden kontrol etti.
4. **Çeldirici kontrolü:** aşağıda, "Çeldirici çeşitlendirme" bölümünde.

Koordinatör (Opus) 45 kartın hepsini ayrıca baştan sona okudu.

## Özet

- İncelenen kart: **45** (A2 16, B1 29). Tür: 19 kelime, 10 kalıp ifade (`phrase`), 6 eşdizim (`collocation`), 10 phrasal verb.
  - A2: office, take a day off, manager, work from home, employee, let me know, email, job interview, print out, customer, in a meeting, reply, company, as soon as possible, part-time, take notes.
  - B1: get back to, call off, apply for a job, attachment, take over, be in charge of, CV, look into, call in sick, hire, point out, resign, go over, promotion, employer, meet a deadline, bring up, career, get a raise, shift, come up with, get fired, available, give a presentation, urgent, postpone, get in touch, clock in, out of the office.
- Değişen kart: **40** (hepsine `critic_edited` eklendi).
  - Denetimde 35 kartta 106 alan değişti.
  - Doğrulama sonrası 19 kartta 24 alan değişti.
  - Toplam 130 alan; silinen her hata bir alan sayıldı.
- Reddedilen kart (`critic_reject`): **0**
- Seviye değişikliği: yok.
- Kimlik değişiklikleri (ikisinin de henüz kayıtlı numarası yoktu):
  - `en.out_of_office.phr.1` → `en.out_of_the_office.phr.1`; lemma "out of the office" oldu.
  - `en.cancel.v.1` çıkarıldı, yerine `en.company.n.1` (A2) yazıldı. s11'de (seyahat) aynı kimlik ve aynı anlam var. Ayrıntı aşağıda, "Akışlar arası kimlik çakışması" bölümünde.
- Doğrulayıcı (tüm klasör): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`
- En sık çeldirici: patients×2 (sınır 4).

## Genel bulgular

- **Yaygın hata (`mistakes`) yine en sık sorun.** Yazarlar 19 hata yazdı; 8'i silindi, kalan 11'in çoğunun `why` metni düzeltildi.
  - Silinenlerin bir kısmı Türkçeye özgü değildi: "print out it", "point out it", "bring up it" ve "let me to know" her anadilden öğrencide görülür.
  - Bir kısmı İngilizcede aslında doğruydu: "do a presentation", ABD'de "apply to a job", "half-time job".
  - Biri kanıtsızdı: "do a career".
  - Kalanlarda doğru bir İngilizce biçimi yanlış gösteren aşırı kesin açıklamalar yumuşatıldı: "work at home" doğru, "do a job interview" doğal, "mail" bazen e-posta demek.
- **Quiz.** 45 quiz'in her şıkkı iki ayrı göz tarafından boşluğa kondu.
  - İkinci bir şıkkın da uyabildiği 4 soru düzeltildi:
    - career: İngiliz İngilizcesinde "start a diploma" ve "start a pension" doğal.
    - bring up: İngiliz İngilizcesinde "look after a problem" bir sorunla ilgilenmek demek.
    - employer: "employee" şıkkı bağlamca kesin dışlanmıyordu.
    - get fired: aynı kartın örneğinde aynı kişi kovulmuyordu.
  - part-time quiz'indeki "second-hand" şıkkı değişti: "a second-hand job" içinde kaba bir argo söz oyunu çıkıyordu.
  - Hiçbir şey sınamayan çeldiriciler (be in charge of: "is full of / is made of / is short of") ve benzetme cümlesi (customer) gerçek, günlük cümlelerle değişti.
  - İki quiz cümlesi kendi örneğinin neredeyse kopyasıydı: get in touch (benzerlik 0,82), call in sick (0,81). İkisine yeni bağlam yazıldı. Akışta artık en yüksek benzerlik 0,74; bu oran önceki akışlarla aynı düzeyde.
- **Akışlar arası tekrar.** İki ilk örnek başka akışlardaki örneklerle birebir aynıydı: office (s9 floor ile) ve as soon as possible (s7 possible ile). İkisi de değişti. Son taramada s10'un hiçbir örneği ya da quiz cümlesi başka bir akıştaki bir cümleye %85'ten fazla benzemiyor.
- **Tanımlar.** A2/B1 kartlarda zor sözcükler temel sözcüklerle değişti: formal, hire, officially, employer, responsibility.
  - job interview mikro tanımı başlıktaki "job" sözcüğünü kullanıyordu.
  - let me know mikro tanımı ("tell me when you can") anlama bir koşul ekliyordu.
  - employer mikro tanımı yalnızca kişiyi kapsıyordu.
- **IPA.** Vurgu yerleri genelde doğruydu; depo geleneğine uyduruldu:
  - tek heceli fiil + parçacıkta ikincil vurgu işareti yok (print out, take over);
  - look into vurgusu fiilde (s4'teki run into gibi);
  - hire UK işaretsiz;
  - as soon as possible s8'deki "as soon as" ile uyumlu;
  - work from home'da iki ana vurgudan biri ikincil oldu.
- **Etimoloji.** 16 etimolojinin hepsi okundu. hire, resign ve customer Wiktionary ile denetlendi (etymonline 403 verdi).
  - customer'daki "ilk anlam düzenli alıcı" bilgisi yanlıştı; ilk anlam gümrük ya da vergi memuru. Metin doğrulanan kısma indirildi.
  - Halk etimolojisi yok.
- **Kategori (taksonomi sınırı).** `workplace_office`, `careers_interviews` ve `business_management` B1'den başlıyor. Bu yüzden 16 A2 kartın `primary_topic`'i A2'ye açık başka bir kategoride: time_routines, confusing_words, social_skills, technology_internet, shopping_money, school_learning, home_household.
  - `workplace_office` bu kartların hepsinde `topics` içinde duruyor. s3'teki job, work ve earn de böyle yapılmıştı.
  - İş kartlarının konu filtresinde birlikte görünmesi istenirse `taxonomy.json`'da bu kategorilerin alt sınırı A2'ye çekilmeli. Bu, s10 dışında bir karar.
- **Lemma.** "out of office" → "out of the office".
  - Standart kullanım "be out of the office".
  - Artikelsiz "out of office" siyasette "görevde değil" demek.
  - Örnekler ve quiz cevabı zaten "the" ile yazılmıştı.
- **Phrasal verb bayrakları.** take over `separable` oldu (önce `inseparable`); clock in `intransitive` oldu (depodaki log in ve check in gibi).

## Akışlar arası kimlik çakışması: cancel → company

- Denetim bittikten sonra yapılan taramada `en.cancel.v.1` hem s10'da hem s11'de (seyahat, aynı gün paralel yazıldı) çıktı. Anlam da aynı: bir planın hiç olmayacağına karar vermek, "iptal etmek". Birleşik derlemede DUP_ID hatası verirdi.
- s11 bu kelimeyi kendi listesinde saymıştı ve "cancel a flight" seyahat akışına çok uygun. Bu yüzden kart s10'dan çıkarıldı. s10'daki call off ve postpone kartları kalıyor; postpone kartının `confusable:cancel` bayrağı s11'deki karta işaret ediyor.
- Yerine aynı yerde (part_03'ün ilk kartı) `en.company.n.1` yazıldı: A2, "şirket" anlamı. Bu karta denetimde `critic_edited` işareti eklenmedi, çünkü sonradan yazıldı.
  - Kartı koordinatör yazdı; ayrı bir Opus doğrulayıcı bağımsız olarak kontrol etti (sonucu hemen aşağıda).
  - Kelime s1–s13 akışlarında ve altın kartlarda yok. Örnek ve quiz cümleleri hiçbir akıştaki bir cümleye %85'ten fazla benzemiyor.
  - Çıkarılan cancel kartı denetimden geçmişti ve hiçbir alanı değişmemişti; s11'deki kart yerine tercih edilirse git geçmişinde duruyor (commit 72da80d).
- s11, s12 ve s13 ile başka kimlik ya da lemma çakışması yok (2026-10-20, üç akışın 45'er kartlık hâliyle tarandı).

**company kartının bağımsız doğrulaması: 0 bulgu.** Doğrulayıcı şunları uygun buldu:

- tanımlar: micro 27, short 72 karakter, başlık kelime yok;
- örnekler ve Türkçe çeviriler: geri çeviride anlam birebir tutuyor;
- IPA: /ˈkʌmpəni/;
- etimoloji: Eski Fransızca compaignie < Geç Latince compāniō < com- "ile" + pānis "ekmek"; Wiktionary ile eşleşiyor;
- quiz: dört şıktan yalnızca "company" uyuyor;
- kategori: `shopping_money` (A1–B2), aynı akıştaki customer kartıyla aynı.

## Değişiklik tablosu

Alan adları kartın JSON yoludur; `l1.tr` Türkçe katmandır. Uzun metinler kısaltıldı.

### Denetim (parça denetçileri)

#### part_01

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| office | tags.primary_topic | cities_transport → time_routines | Kartla ilgisizdi. A2'ye açık kategoriler arasında en uygunu: örnekler ve quiz günlük işe gidişi anlatıyor. |
| office | tags.topics | [cities_transport, workplace_office] → [time_routines, workplace_office] | primary_topic ile uyum. |
| office | examples[0].en | My office is on the third floor. → Our office is open from nine to five. | s9 `en.floor.n.1` ilk örneğiyle birebir aynıydı (akışlar arası tekrar). Yeni cümle kısa, kilit ekranına uygun ve time_routines konusuna uyuyor. focus "office" değişmedi. |
| office | examples[0].tr | Ofisim üçüncü katta. → Ofisimiz dokuzdan beşe kadar açık. | Yeni İngilizce cümlenin çevirisi. |
| office | examples[2].tr | …bu yüzden geri gitti. → …bu yüzden geri döndü. | "went back" için doğal Türkçe "geri döndü". |
| take a day off | l1.tr.alt[1] | izin yapmak → izinli olmak | "İzin yapmak" yöresel ve standart dışı; "izinli olmak" yaygın ve doğal. |
| take a day off | l1.tr.mistakes[0].wrong | I will take a permission on Friday. → I will take permission on Friday. | Türkçede "izin almak" "bir" almaz. Tek bir hata (izin = permission) gösterilsin diye. |
| take a day off | l1.tr.mistakes[0].why | 'Permission' iş izni için kullanılmaz… → İşe gitmediğin gün için 'permission' kullanılmaz… | "İş izni" Türkçede çalışma izni (work permit) diye okunabiliyordu. |
| get back to | l1.tr.note | 'Return to' ise bir yere geri gitmek demektir… → 'Return to' ise çoğunlukla bir yere geri dönmektir; cevap vermek anlamı taşımaz. | "return to work / to a topic" de var; mutlak ifade yumuşatıldı. |
| get back to | l1.tr.mistakes[0].why | 'Return to' fiziksel olarak geri gitmektir… → Ama 'return to you' cevap vermek anlamına gelmez; bunun için 'get back to you' denir. | Aynı neden: "fiziksel olarak" fazla kesindi. Açıklama doğrudan hatayı anlatıyor. |
| work from home | ipa.us | /ˈwɜːrk frəm ˈhoʊm/ → /ˌwɜːrk frəm ˈhoʊm/ | İki ana vurgu vardı. Ana vurgu "home", "work" ikincil. |
| work from home | ipa.uk | /ˈwɜːk frəm ˈhəʊm/ → /ˌwɜːk frəm ˈhəʊm/ | Aynı neden. |
| work from home | l1.tr.note | Araya 'in' ya da 'the' koyma: 'work in home' ve 'work from the home' denmez. → 'Work at home' kalıbı da doğrudur; ama 'work in home' denmez. | "Work at home" da doğru, not bunu göstersin. "from the home" gerçek bir hata değildi. |
| work from home | l1.tr.mistakes[0].why | İşi evden yapmak için ise 'from' gerekir… → Ama 'in home' denmez; 'at home' ya da 'from home' denir. Evden çalışmak için en yaygın kalıp 'work from home'. | Eski açıklama yalnızca "from" doğruymuş gibi okunuyordu. "At home" da doğru. |
| employee | l1.tr.note | …sonu '-ee' olan sözcük işi yapan kişidir. → …'-er' işe alan, '-ee' işe alınan kişidir. Aynı ayrım interviewer ve interviewee çiftinde de var. | Eski ipucu genel kural olarak yanlış (interviewee, trainee) ve etimolojiyle çelişiyordu. |
| employee | quiz.distractors | tourists, patients, passengers → tourists, patients, employers | Kartın asıl karışıklığını sınıyor. "has fifty employers… pays all of them" açıkça yanlış; tek cevap korunuyor. |
| let me know | l1.tr.note | 'Let me know' bundan daha yumuşak ve kibardır… → 'tell me' demekten daha yumuşak duyulur. 'Let' fiilinden sonra 'to' gelmez. Ardından çoğunlukla 'if', 'when' ya da 'what'… | "Haber ver"den daha kibar olduğu kanıtsız; doğru karşılaştırma "tell me" ile. Silinen hatanın bilgisi buraya taşındı. |
| let me know | l1.tr.mistakes[0] | Please let me to know. → Please let me know. :: Türkçede fiiller hep -mek/-mak biçiminde öğrenilir… → (silindi) | Hata Türkçeye özgü değil (let/make + to birçok anadilde görülüyor); `why` içindeki Türkçe bağı kanıtsız. |
| call off | def.micro | stop something planned → cancel something planned | "Stop" devam eden bir şeyi durdurmak gibi okunuyordu. Bu anlam iptal etmek. |
| email | l1.tr.mistakes[0].why | İngilizcede 'mail' postayla gelen mektup ve paketlerdir… → 'mail' çoğunlukla posta demektir ve tek bir mesaj için 'a mail' pek denmez; doğal söyleyiş 'an email' olur. | "Check my mail" gibi kullanımda "mail" e-posta da olabilir. Mutlak ifade yumuşatıldı. |
| job interview | def.micro | a formal talk to get hired → a meeting for a new job | "formal" ve "hire" B1 sözcükleri; A2 kartında temel sözcükler gerekli. |
| job interview | def.short | a formal talk where a company asks you questions to decide if it will hire you → a meeting where a company asks you questions to choose a new worker | Aynı neden. |
| job interview | def.long | A formal talk where… → A meeting where… | micro ve short ile uyum; "formal" çıkarıldı. |
| job interview | l1.tr.mistakes[0].why | 'yapmak' sözü 'make' ya da 'do' diye çevrilir… → 'yapmak' sözü 'make' diye çevrilir. Ama 'make a job interview' denmez; görüşmeye giren kişi 'have a job interview' der. | "I did a job interview" anadili İngilizce olanlarda doğal; "do" yanlış gösterilmemeli. |

#### part_02

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| print out | ipa.us | /ˌprɪnt ˈaʊt/ → /prɪnt ˈaʊt/ | Vurgu doğru; s4 kuralı: tek heceli fiilde ikincil vurgu işareti yok (/teɪk ˈɔːf/, /pɪk ˈʌp/). |
| print out | ipa.uk | /ˌprɪnt ˈaʊt/ → /prɪnt ˈaʊt/ | Aynı neden. |
| print out | l1.tr.mistakes[0] | Please print out it for me. → Please print it out for me. :: "Türkçede böyle ayrılan fiil yoktur; ... zamir sona konur" → (silindi) | Genel phrasal verb hatası, Türkçeye özgü değil; `why` metnindeki Türkçe bağı uydurma (Türkçede nesne zamiri fiilden önce gelir). Liste boş. |
| print out | l1.tr.note | "... 'it' gibi zamir ortada durur." → "... 'It' gibi zamir ortada durur; 'print out it' denmez." | Silinen hatanın bilgisi nota taşındı (look into notundaki "look it into denmez" ile aynı biçim). |
| customer | examples[2].tr | Dina devamlı müşteri olduğu için sahibi onun adını biliyor. → Dina devamlı müşteri olduğu için dükkân sahibi onun adını biliyor. | "sahibi" iyelik eki istiyor ve "Dina'nın sahibi" gibi okunabiliyordu. İngilizcedeki "the owner" dükkânın sahibidir. |
| customer | etymology.text | From 'custom' (habit). At first, a customer was someone who bought from the same seller again and again. → From 'custom', which comes from a Latin word for 'habit'. In the 1400s, a customer was a person who often bought from the same seller. | "At first" yanlış: İngilizcede ilk anlam (14. yy sonu) gümrük ya da vergi memuru. "Düzenli alıcı" anlamı yaklaşık 1400'den (etymonline özeti, Wiktionary'de eskimiş anlam olarak geçiyor). Kök Latince consuetudo "alışkanlık". |
| customer | l1.tr.mnemonic | Custom = alışkanlık. Aynı dükkâna alışkanlıkla gelen kişi 'customer' olur. → Custom = gelenek, alışkanlık. Eskiden 'customer', aynı dükkândan alışkanlıkla alışveriş yapan kişiydi. | Eski metin bugünkü anlamı daraltıyordu (bir kez alan da müşteridir). "Eskiden" diye etimolojiyle uyumlu yapıldı. |
| customer | quiz.cloze | A school has students, and a shop has ______. → This new bakery is very popular. It gets a lot of ______ every morning. | Benzetme cümlesi günlük ve doğal bir cümleyle değiştirildi; tek cevap korunuyor. |
| customer | quiz.distractors | patients, passengers, pilots → patients, players, readers | Fırın bağlamında üçü de açıkça yanlış; akışta passengers sayısı azaldı. |
| apply for a job | ipa.us | /əˈplaɪ fər ə dʒɑːb/ → /əˌplaɪ fər ə ˈdʒɑːb/ | Öbek vurgusu "job" üzerinde; s10 "get a raise", s8 "take a break" ile tutarlı. |
| apply for a job | ipa.uk | /əˈplaɪ fə ə dʒɒb/ → /əˌplaɪ fər ə ˈdʒɒb/ | Aynı neden; ünlüden önce bağlayıcı r (s8 "for a while" UK /fər ə/). |
| apply for a job | l1.tr.mistakes[0] | I applied to a job at that bank. → I applied for a job at that bank. → (silindi) | ABD İngilizcesinde "apply to a job / apply to jobs" anadili İngilizce olanların rahatça kullandığı biçim; hata sayılamaz. Liste boş. |
| apply for a job | l1.tr.note | "... '-e' eki akla 'to' getirir. İngilizcede iş için 'for' gelir ... Şirket ya da okul için ise 'to' gelir" → "Türkçedeki 'işe başvurmak' kalıbı akla 'to' getirebilir. İngilizcede iş için genellikle 'for' gelir: apply for a job. Şirket ya da okul için 'to' gelir: apply to a company. ABD'de 'apply to a job' da duyulur." | "Yalnızca for" kesinliği yumuşatıldı; ABD kullanımı eklendi. "apply to a company" doğru olarak kaldı. |
| attachment | examples[1].tr | Lütfen e-postadaki eki açın ve tarihleri kontrol edin. → Lütfen eki açın ve tarihleri kontrol edin. | "e-postadaki" İngilizcede yok (fazla bilgi). İş yazışmasında "eki açın" doğal. |
| attachment | l1.tr.mistakes[0].why | "... 'ekte' sözü 'in attachment' diye çevrilir. İngilizcede 'attached' ya da 'as an attachment' denir." → "Türkçede 'Dosya ekte' denir ve '-te' eki 'in' diye çevrilir. İngilizcede 'The file is attached.' denir; gönderirken 'as an attachment' kullanılır." | Eski metin "The file is as an attachment" yanlışını düşündürebiliyordu; "as an attachment" yalnızca göndermekle (send/sent) kullanılır. Mekanizma (-te = in) açık yazıldı. |
| take over | ipa.us | /ˌteɪk ˈoʊvər/ → /teɪk ˈoʊvər/ | Vurgu doğru; s4 come over /kʌm ˈoʊvər/ ile tutarlı (tek heceli fiilde ˌ yok). |
| take over | ipa.uk | /ˌteɪk ˈəʊvə/ → /teɪk ˈəʊvə/ | Aynı neden. |
| take over | grammar.pattern | take over (from sb) / take over sth → take over sth / take sth over (from sb) | Ayrılabilir kullanım ("take the project over", "take it over") gösterildi. |
| take over | tags.flags | [inseparable] → [separable] | "take the company over / take it over" doğal; bu anlamda ayrılabilir. |
| be in charge of | quiz.cloze | Mehmet ______ the kitchen, so the cooks ask him before they start. → Daniel ______ the kitchen, ... | Bu parçada "Mehmet" 9 kez geçiyordu (yazar kuralı: isimler çeşitli olsun). Cümle aynı. |
| be in charge of | quiz.distractors | is full of, is made of, is short of → is afraid of, is tired of, is in front of | Eskiler anlamca saçmaydı, bir şey sınamıyordu. Yenileri aynı yapıda, akla yatkın ("in front of" biçimce benzer), ama "so the cooks ask him" sonucunu açıklamadığı için açıkça yanlış. |
| reply | l1.tr.mistakes[0].why | "... '-a' eki fiile ait gibi durur, bu yüzden 'to' atlanır." → "Türkçede 'bana cevap ver' denir; 'bana' tek sözcük olduğu için 'me' diye çevrilir ve 'to' atlanır. İngilizcede 'reply to me' denir." | Eski açıklama belirsiz ve yanıltıcıydı. Gerçek mekanizma "Can you say me" ile aynı: 'bana' = 'me'. |
| CV | l1.tr.note | "... Okunuşu 'si-vi' olur, 'se-ve' olmaz." → "... Okunuşu 'si-vi' olur, 'ce-ve' olmaz." | Türkçe harf okunuşu "ce-ve"dir; "se-ve" hiçbir okunuşa karşılık gelmiyor. |
| CV | quiz.cloze | Mehmet is looking for a new job, so ... → Kerem is looking for a new job, so ... | İsim çeşitliliği (Mehmet tekrarı). Cümle aynı. |
| look into | ipa.us | /lʊk ˈɪntu/ → /ˈlʊk ɪntu/ | Edat fiili: vurgu fiilde ("I'll LOOK into it"). s4 run into /ˈrʌn ɪntu/, turn into /ˈtɜːrn ɪntu/ ile tutarlı. |
| look into | ipa.uk | /lʊk ˈɪntu/ → /ˈlʊk ɪntə/ | Aynı neden; UK zayıf biçim s4 run into /ˈrʌn ɪntə/ gibi. |

#### part_03

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| call in sick | examples[0].tr | …bu sabah işyerine hasta olduğunu bildirdi. → …bu sabah iş yerine hasta olduğunu bildirdi. | TDK yazımı "iş yeri" (ayrı); depoyla tutarlı. |
| call in sick | examples[1].tr | …bugün işyerine hasta olduğunu bildirecek. → …bugün iş yerine hasta olduğunu bildirecek. | Aynı neden. |
| call in sick | l1.tr.note | …işyerini arayıp ya da mesaj atıp… → …iş yerini arayıp ya da mesaj atıp… | Aynı neden. |
| hire | ipa.uk | /ˈhaɪə/ → /haɪə/ | Tek heceli sözcük; depoda tired /taɪəd/, hear /hɪə/ da işaretsiz. |
| hire | etymology.text | From Old English 'hyrian', meaning to pay someone for their work. → From Old English 'hyrian', to hire. It comes from the noun 'hyr', which meant pay for work. | Wiktionary'ye göre hȳrian "to hire"; "ücret, hizmet karşılığı" anlamı isim kökü hȳr'a ait. Doğrulanan biçime çekildi. |
| point out | def.micro | tell someone a missed fact → make someone notice a fact | "missed fact" doğal değil ve belirsiz; yeni tanım anlamı (dikkat çekmek) açık veriyor. |
| point out | l1.tr.mistakes[0] | Please point out it to me. → Please point it out to me. (silindi) | Genel phrasal verb hatası, Türkçeye özgü değil; `why`'daki Türkçe bağı uydurma. Bilgi grammar.pattern ve 3. örnekte duruyor. |
| as soon as possible | ipa.us | /æz suːn æz ˈpɑːsəbəl/ → /əz ˈsuːn əz ˈpɑːsəbəl/ | s8 "as soon as" kartıyla tutarlılık; "soon" vurgulu, "as" zayıf. |
| as soon as possible | ipa.uk | /æz suːn æz ˈpɒsəbəl/ → /əz ˈsuːn əz ˈpɒsəbəl/ | Aynı neden. |
| as soon as possible | examples[0].en | Please call me as soon as possible. → Please reply as soon as possible. | Eski cümle s7 `possible` kartının 2. örneğiyle birebir aynıydı. |
| as soon as possible | examples[0].tr | Lütfen beni en kısa sürede ara. → Lütfen en kısa sürede cevap verin. | Yeni İngilizce cümlenin çevirisi. |
| resign | etymology.text | …'resignare', meaning to unseal or cancel, and later to give up. …through Old French. → …'resignare', which could mean to unseal, to cancel or to give up. …through French. | Latince anlamlar doğrulandı, ama "and later" sırası doğrulanamadı. Wiktionary Anglo-Norman/Orta Fransızca diyor. |
| part-time | l1.tr.mistakes[0] | I have a half-time job. → I have a part-time job. (silindi) | Türkçe konuşanlarda yaygınlığı kanıtsız; "half-time" (çalışma süresinin yarısı) İngilizcede var olan bir sıfat, cümle kesin yanlış değil. |
| part-time | l1.tr.note | 'Part-time' çalışma saatleri azdır; … → 'Part-time' işlerde çalışma saatleri azdır; … | Türkçe cümle eksikti ("'Part-time' çalışma saatleri azdır" bozuk). |

#### part_04

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| employer | quiz.cloze | My ______ puts my pay into my bank account every month. → I work for a small shop, and my ______ pays me every Friday. | "I work for" ile konuşanın çalışan olduğu kesinleşti; "employee" şıkkı açıkça yanlış oldu. "puts my pay into" da doğal değildi. |
| meet a deadline | examples[1].en | Cem missed the deadline because his laptop broke. → Elif asked her team for help so she could meet the deadline. | Örnek başlığı değil karşıtını gösteriyordu. |
| meet a deadline | examples[1].tr | Cem'in dizüstü bilgisayarı bozulduğu için son teslim tarihini kaçırdı. → Elif son teslim tarihine yetişebilmek için ekibinden yardım istedi. | Yeni cümlenin çevirisi. Eski çeviride özne karışıyordu. |
| meet a deadline | examples[1].focus | missed the deadline → meet the deadline | Focus başlığın biçimi olmalı. |
| meet a deadline | examples[2].en | Omar always meets his deadlines, so his boss trusts him. → Ayşe always meets her deadlines, so her boss trusts her. | İsim çeşitliliği ve cinsiyet dengesi. |
| meet a deadline | examples[2].tr | Omar son teslim tarihlerine her zaman yetişir… → Ayşe son teslim tarihlerine her zaman yetişir… | İsim. |
| meet a deadline | examples[2].focus | meets his deadlines → meets her deadlines | Yeni cümleye uygun. |
| meet a deadline | quiz.distractors | miss a deadline, skip a deadline, lose a deadline → miss a deadline, skip a deadline, catch a deadline | "catch" Türkçe "yetişmek" aktarımıyla akla yatkın ama yanlış; "lose" bir şey sınamıyordu. |
| bring up | l1.tr.mistakes[0] | I will bring up it at the meeting. → I will bring it up at the meeting. :: Türkçede ayrılan fiil yapısı yoktur… → (silindi) | Genel phrasal verb sıra hatası, Türkçeye özgü değil. Bilgi notta duruyor. |
| career | l1.tr.mistakes[0] | She wants to do a career in music. → She wants to have a career in music. :: Türkçede 'kariyer yapmak' denir… → (silindi) | Kanıtsız; aktarım daha çok doğru bir biçim olan "make a career" sonucunu verir. |
| career | l1.tr.note | …tek bir iş için 'job' denir. → …tek bir iş için 'job' denir. 'Kariyer yapmak' için 'have a career' ya da 'make a career' denir. | Silinen hatadaki yararlı bilgi doğru biçimde nota taşındı; "make a career" doğru olarak gösterildi. |
| career | examples[2].en | Omar decided to change careers… → Kenji decided to change careers… | İsim çeşitliliği. |
| career | examples[2].tr | Omar kariyerini değiştirip… → Kenji kariyerini değiştirip… | İsim. |
| get a raise | synonyms | pay rise → get a pay rise | Kart fiil kalıbı; eşanlamlı da fiil kalıbı olmalı. |
| get a raise | antonyms | pay cut → take a pay cut | Aynı neden. |
| come up with | def.long | …and then tell it to others. It is inseparable: the thing you think of comes after 'with'. → …often because you need one. The thing you think of always comes after 'with'. | "Başkalarına söylemek" anlamın zorunlu parçası değil ("I can't come up with a name"). "inseparable" A2 için terim. |
| come up with | examples[2].tr | Pazartesiye kadar bir plan bulmalıyız. → Pazartesiye kadar bir plan ortaya koymamız gerekiyor. | "Plan bulmak" daha az doğal; "need to" gereklilik. "Ortaya koymak" `alt` içinde var. |
| give a presentation | def.micro | talk to a group with slides → stand and talk to a group | Slayt zorunlu değil; `def.short` ile uyumlu. |
| give a presentation | l1.tr.mistakes[0] | I have to do a presentation on Monday. → I have to give a presentation on Monday. :: Türkçede 'sunum yapmak' dersin… → (silindi) | "Do a presentation" anadili İngilizce olanların da kullandığı doğru biçim; hata değil. |
| give a presentation | l1.tr.note | …'Do a presentation' günlük konuşmada duyulsa da iş ve okulda 'give' tercih edilir. → …'Do a presentation' ve 'make a presentation' da doğrudur; 'give' biraz daha standart ve resmîdir. | Eski not "do" biçimini yalnızca günlük konuşmaya ait gösteriyordu; İngiliz iş ve okul dilinde de yaygın. |
| give a presentation | examples[2].en | Omar practiced a lot… → Mehmet practiced a lot… | İsim çeşitliliği. |
| give a presentation | examples[2].tr | Omar tüm ekibe sunum yapmadan önce… → Mehmet tüm ekibe sunum yapmadan önce… | İsim. |

#### part_05

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| urgent | def.long | …an important job matters a lot, but it can wait. → …an important job matters a lot, but it can often wait. | Önemli bir iş acil de olabilir; "it can wait" mutlak bir yanlış genellemeydi. |
| urgent | l1.tr.note | …'Important' (önemli) ise çok değerli ama bekleyebilen şeydir: önemli bir iş acil olmayabilir. → …'Important' ise 'önemli' demektir; önemli bir iş her zaman acil değildir. 'Acil durum' ve 'acil çıkış' için 'emergency' kullanılır: emergency exit. | "Önemli = bekleyebilen şey" tanımı yanlıştı. Türkçede 'acil' hem urgent hem emergency karşılığı; gerçek bir Türkçe tuzağı olduğu için not olarak eklendi (kanıt olmadığından hataya çevrilmedi). |
| get in touch | l1.tr.note | 'Get in touch with + kişi' kalıbında kişiden önce 'with' gelir. 'Keep in touch' ise… → Kişiden önce 'with' gelir: get in touch with me. Eş anlamlı 'contact' ise 'with' almaz: contact me. 'Keep in touch' farklıdır: haberleşmeye devam etmek demektir. | Türkçe konuşanların bilinen hatası "contact with me" ile karşıtlık eklendi; keep in touch uyarısı korundu. |
| clock in | tags.flags | [inseparable] → [intransitive] | Bu anlamda nesne almıyor (not da böyle diyor). Depodaki log in, check in, sign up da `intransitive`. |
| clock in | word_family | [clock out (phv)] → [] | clock out karşıt anlamlı ve antonyms'te zaten var; kelime ailesi değil. |
| clock in | l1.tr.alt[0] | giriş yapmak → kart okutmak | "Giriş yapmak" tek başına log in / içeri girmek demek, yanıltıcı. |
| clock in | l1.tr.note | …Bu fiil nesne almaz: 'clock in' dersin, nesne eklemezsin. → …Bu fiil nesne almaz; kartı söylemek için 'with' eklenir: clock in with my card. | Eski cümle kendini tekrar ediyordu. Yenisi "kart basmak" kalıbındaki kartın İngilizcede nasıl söyleneceğini gösteriyor. |
| out of the office | lemma | out of office → out of the office | Karar 3: standart biçim, artikelsiz biçimin siyasi anlamı, Türkçede artikel yok, örnekler ve quiz zaten "the" ile. |
| out of the office | id | en.out_of_office.phr.1 → en.out_of_the_office.phr.1 | Lemma slug'ıyla uyum (ID_SLUG). Başka gönderme yok. |
| out of the office | ipa.us | /aʊt əv ˈɔːfɪs/ → /aʊt əv ði ˈɔːfɪs/ | "the" eklendi; ünlüden önce /ði/. |
| out of the office | ipa.uk | /aʊt əv ˈɒfɪs/ → /aʊt əv ði ˈɒfɪs/ | Aynı neden. |
| out of the office | def.short | away from work and not able to answer for a time → away from your place of work for a time | "answer" nesnesiz kalıyordu. Ofis dışında olmak her zaman cevap verememek demek değil. |
| out of the office | def.long | Away from work, …, and not able to answer. People write it in an automatic email reply: 'I'm out of the office until Monday.' → Away from your place of work for a time, for example on holiday or on a trip. An automatic email that says this is often called an 'out-of-office' reply. | Aynı neden. İkinci cümle 1. örneği tekrar ediyordu; yerine "out-of-office reply" adı açıklandı. |
| out of the office | grammar.pattern | be out of (the) office → be out of the office | Yeni lemma'ya uyum. |
| out of the office | examples[2].en | Nina turned on her out-of-office reply before her holiday. → Sofia will be out of the office next week, so she set up an automatic email reply. | Eski `focus` ("out-of-office") başlığın biçimi değildi. Yeni örnek başlığı içeriyor, otomatik yanıt bağlamını koruyor; isim tekrarı azaldı. |
| out of the office | examples[2].tr | Nina tatilinden önce ofis dışı otomatik yanıtını açtı. → Sofia gelecek hafta ofis dışında olacak, bu yüzden otomatik e-posta yanıtı ayarladı. | Yeni cümlenin çevirisi. "Ofis dışı otomatik yanıtı" yapaydı. |
| out of the office | examples[2].focus | out-of-office → out of the office | Yeni örnek. |
| out of the office | l1.tr.gloss | ofiste değil → ofis dışında | Edat öbeğinin karşılığı ve otomatik yanıtlarda kalıp. "Ofiste değil" yüklem biçimi. |
| out of the office | l1.tr.alt | [ofis dışında, izinde] → [ofiste değil, izinde] | Gloss ile yer değiştirdi. |
| out of the office | l1.tr.note | Genelde 'out of the office' denir. E-postadaki otomatik yanıt 'out-of-office reply' olur. Türkçedeki 'izinde'… → Cümlede 'the' ile kullanılır: I'm out of the office. Otomatik e-posta yanıtının adı 'Out of Office' ya da 'out-of-office reply' olur. 'İzinde' yalnızca izni anlatır; İngilizce ifade iş gezisi için de kullanılır. | Yeni lemma'ya uyarlandı. Türkçede artikel olmadığı için "the" düşürme riski vurgulandı. Eski nottaki ayrı ek sorunu yoktu, yenisinde de yok. |

### Bağımsız doğrulama sonrası (koordinatör uyguladı)

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| job interview | def.micro | a meeting for a new job → a meeting to choose a worker | Mikro tanım başlığın parçası olan 'job' sözcüğünü kullanıyordu (SYSTEM_A: tanımda başlık kelime yok). (koordinatör) |
| let me know | def.micro | tell me when you can → tell me | 'when you can' anlamda olmayan bir koşul ekliyordu; örneklerin yerine konamıyordu. (doğrulayıcı part_01) |
| let me know | l1.tr.gloss | haber vermek → bana haber ver | Kalıptaki 'me' kayboluyordu; depodaki kalıp kartları gibi işlevsel karşılık (take your time = acele etme). (doğrulayıcı part_01) |
| let me know | l1.tr.alt | bildirmek, bilgi vermek → bana bildir, haberim olsun | Gloss ile uyum; 'haberim olsun' günlük ve doğal. (doğrulayıcı part_01) |
| call off | l1.tr.alt | vazgeçmek → (boş) | 'Vazgeçmek' çoğunlukla give up / change your mind; 'I called off smoking' gibi yanlış kullanıma götürebilir. (doğrulayıcı part_01 + koordinatör) |
| in a meeting | examples.0.tr | Üzgünüm, Mehmet şu anda toplantıda. → Kusura bakmayın, Mehmet şu anda toplantıda. | 'Sorry' burada kibar bir özür kalıbı; 'Üzgünüm' birebir çeviri kokuyor. (doğrulayıcı part_02) |
| look into | l1.tr.alt | incelemek, ilgilenmek → incelemek | 'İlgilenmek' be interested in anlamını da çağrıştırıyor; s4 look after / deal with kartlarında da var. (doğrulayıcı part_02) |
| print out | examples.2.tr | Zeynep formu kâğıt üzerinde istiyor, ben de çıktısını alırım. → Zeynep'e formun kâğıt hâli lazım, ben de çıktısını alırım. | Geri çeviride 'needs' yerine 'wants' çıkıyordu; 'kâğıt üzerinde' yapaydı. (doğrulayıcı part_02) |
| resign | def.short | officially tell your boss that you are leaving your job → tell your boss that you are leaving your job | 'officially' (B2) B1 kartın tanımı için zor. (doğrulayıcı part_03) |
| resign | def.long | To tell your employer officially that you are leaving your job, often in a letter or an email. It is your own choice; if the company ends your job, you do not resign. → To tell your boss that you are leaving your job, often in a letter or an email. It is your own choice; if the company ends your job, you do not resign. | 'employer' (B1) ve 'officially' (B2) yerine temel sözcükler. (doğrulayıcı part_03) |
| resign | synonyms | quit, step down → quit | 'step down' yalnızca önemli görevler için; sıradan bir işten ayrılmanın eş anlamlısı değil. (doğrulayıcı part_03) |
| part-time | quiz.distractors | full-time, second-hand, homemade → full-time, one-way, homemade | 'a second-hand job' içinde kaba bir argo söz oyunu çıkıyor; tekrar ekranında görünmemeli. (doğrulayıcı part_03) |
| hire | l1.tr.note | 'Hire' bir kişiyi işe almaktır. Kendi isteğiyle ayrılan kişi için 'resign' (istifa etmek), işveren çıkarırsa 'fire' (işten çıkarmak) kullanılır. → 'Hire' bu kartta birini işe almaktır; işveren çıkarırsa 'fire', kişi kendisi ayrılırsa 'resign' denir. İngiliz İngilizcesinde 'hire a car' (araba kiralamak) gibi kullanımlarda 'kiralamak' anlamına da gelir. | İngiliz İngilizcesindeki yaygın 'kiralamak' anlamı (car hire) depoda hiçbir yerde anlatılmıyordu. (doğrulayıcı part_03) |
| promotion | def.long | A move to a higher, better job in the same company, often with more money and more responsibility. You can get a promotion after doing good work for a long time. → A move to a higher, better job in the same company, often with more money and more important work. You can get a promotion after doing good work for a long time. | 'responsibility' (B1) yerine temel sözcükler. (doğrulayıcı part_03) |
| take notes | grammar.pattern | take notes (on / of + noun) → take notes (on + noun) | 'of' seçeneği anlamı farklı 'take note of' (dikkate almak) kalıbıyla karışabiliyor. (doğrulayıcı part_03) |
| call in sick | quiz.cloze | Ali has a fever, so he will ______ and stay home today. → Pedro woke up with a sore throat and a headache, so he decided to ______. | Quiz cümlesi 2. örneğin neredeyse aynısıydı (benzerlik 0,81); soru ezbere dönüyordu. (koordinatör) |
| employer | def.micro | a person who pays workers → person or company paying you | Yalnızca kişiyi kapsıyordu; kartın notu ve def.short şirketi de sayıyor. (doğrulayıcı part_04) |
| career | quiz.distractors | diploma, pension, interview → salary, uniform, interview | BrE'de 'start a diploma' (bir programa başlamak) ve 'start a pension' boşluğa uyabiliyordu. (doğrulayıcı part_04 + quiz) |
| get fired | quiz.cloze | Cem was often late and made many mistakes, so he ______ last month. → Emre was often late and made many mistakes, so he ______ last month. | Aynı kartın 3. örneğinde 'Cem didn't get fired'; quiz'de Cem kovuluyordu. (doğrulayıcı part_04) |
| career | examples.1.tr | Fatma aynı bankada uzun ve mutlu bir kariyer yaptı. → Fatma'nın aynı bankada uzun ve mutlu bir kariyeri oldu. | 'Mutlu bir kariyer yapmak' doğal değil; 'has had a career' = 'kariyeri oldu'. (doğrulayıcı part_04) |
| available | examples.1.tr | Üzgünüm, Fatma şu anda müsait değil. → Kusura bakmayın, Fatma şu anda müsait değil. | 'Sorry' burada kibar bir özür kalıbı; in a meeting kartıyla tutarlı. (doğrulayıcı part_04) |
| bring up | quiz.distractors | puts on, looks after, gets off → puts on, fills in, gets off | BrE'de 'look after a problem' (bir sorunla ilgilenmek) boşluğa uyabiliyordu. (doğrulayıcı quiz) |
| urgent | examples.2.tr | Leila'ya acil bir telefon geldiği için toplantıdan erken ayrıldı. → Leila acil bir telefon yüzünden toplantıdan erken ayrıldı. | İngilizcedeki 'because of an urgent phone call' yapısına daha yakın; özne açık. (denetçi + doğrulayıcı part_05) |
| get in touch | quiz.cloze | Here is my number. Please ______ if you need any help. → The office is closed today, but you can ______ with us by email. | Quiz cümlesi 1. örneğin neredeyse aynısıydı (benzerlik 0,82); soru ezbere dönüyordu. (koordinatör (denetçi part_05 gözlemi)) |

## Çeldirici çeşitlendirme (2026-10-20)

- Önce (yazım sonrası): `s10: 45 quizzes, 133 distinct distractors; top: patients×2, passengers×2, stadium×1, beach×1, playground×1, take a seat×1`
- Sonra: `s10: 45 quizzes, 134 distinct distractors; top: patients×2, stadium×1, beach×1, playground×1, take a seat×1, take a bath×1`
- Hedef (hiçbir çeldirici 4'ten fazla soruda geçmesin) yazımdan beri sağlanıyordu. Yazarlara her parçada bir çeldiriciyi en fazla bir kez kullanmaları ve genel iş sözcüklerinden kaçınmaları söylenmişti. Bu yüzden çeşitlendirme için değişen kart yok; `distractors_diversified` işareti hiçbir karta eklenmedi.
- Quiz doğruluğu için değişen çeldiriciler (`critic_edited` ile, tablolarda):
  - denetimde customer, be in charge of, employee ve meet a deadline;
  - doğrulamada part-time, career ve bring up.
- `cloze`'u değişen kartlar ve nedenleri:
  - customer: benzetme cümlesi yerine günlük bir cümle;
  - employer: "employee" şıkkını kesin dışlamak için;
  - call in sick ve get in touch: kendi örneklerinin neredeyse kopyasıydı;
  - get fired: aynı kartın örneğiyle isim çelişkisi;
  - be in charge of ve CV: yalnızca isim (part_02'de "Mehmet" 9 kez geçiyordu).
- Sonraki çeşitlendirmelerde aşağıdaki şıklar ilgili karta **eklenmemeli**, çünkü boşluğa uyarlar:
  - company: firm, business, factory;
  - postpone: delay, put off, move, push back;
  - urgent: important, serious;
  - available: free;
  - get in touch: contact, reach out;
  - clock in: log in, sign in, check in;
  - out of the office: away, on holiday, busy, off sick;
  - get a raise: get promoted, get a bonus;
  - get fired: resigned, quit;
  - career: diploma, pension (İngiliz İngilizcesinde uyar);
  - bring up: looks after (İngiliz İngilizcesinde uyar).

## Anadili Türkçe birinin bakması gerekenler

### Yaygın hata kayıtları: Türk öğrenciler gerçekten böyle mi diyor?

- **take a day off:** "I will take permission on Friday." ("izin" = permission). Mekanizma kesin, yaygınlığı doğrulanmadı.
- **get back to:** "I will return to you." ("sana döneceğim"). Yoksa daha çok "I will turn back to you" mu deniyor?
- **email:** "I'll send you a mail." Hata olarak mı kalmalı, yalnızca notta mı anlatılmalı?
- **reply:** "Please reply me soon." ("bana cevap ver"). Türk öğrencilerde "answer me" daha sık olabilir.
- **attachment:** "The file is in attachment." ("Dosya ekte"). Ne kadar yaygın?
- **take notes:** "I got a good note in the exam." ("not" = grade). "I took a good note" biçimi daha mı sık?
- **postpone:** "We postponed to buy new chairs." ("almayı ertelemek"). Ne kadar yaygın?
- **urgent:** Nota eklenen "acil" = emergency tuzağı ("urgent exit") gerçekten görülüyor mu? Görülüyorsa hata listesine taşınabilir.
- **Silinen hatalar:** "Please let me to know", "I applied to a job" ve "do a career" Türk öğrencilerde çok sıksa, açıklaması Türkçeye dayanarak yazılabiliyorsa geri konabilir.

### Türkçe karşılıklar (gloss ve alt)

- **take a day off:** gloss "bir gün izin almak", alt "izin kullanmak" ve "izinli olmak" doğal mı? "İzin yapmak" yöresel diye çıkarıldı; yaygınsa geri konabilir.
- **let me know:** Yeni gloss "bana haber ver"; alt "bana bildir" ve "haberim olsun". Doğal mı?
- **call in sick:** "hasta olduğunu bildirmek" en doğal karşılık mı? Daha kısa, günlük bir söyleyiş var mı?
- **as soon as possible:** "en kısa sürede". İş yazışmasında asıl karşılık "mümkün olan en kısa sürede" mi olmalı? Bu ifade alt için 24 karakter sınırını aşıyor.
- **meet a deadline:** "son tarihe yetişmek" mi, "teslim tarihine yetişmek" mi? Nottaki "tutturmak" uygun mu?
- **come up with:** "bulmak, akıl etmek" yeterli mi?
- **get fired:** alt "işten çıkarılmak" toplu işten çıkarmayı ("be laid off") da kapsıyor. Sorun olur mu?
- **employee:** alt "personel" tek bir kişi için uygun mu?
- **in a meeting:** alt "görüşmede" iş görüşmesi anlamına kayar mı?
- **clock in:** alt "kart okutmak", "kart basmak" kadar doğal mı?
- **out of the office:** gloss "ofis dışında" mı, "ofiste değil" mi? `equivalence` partial mı kalmalı, full mu olmalı?
- **go over:** "gözden geçirmek" tam karşılık sayılıp `equivalence` full yapılabilir mi?
- **CV:** Günlük Türkçede "si-vi" mi, "ce-ve" mi daha yaygın? Not yalnızca İngilizce okunuşu öğretiyor.

### Çeviriler: doğal mı?

- **in a meeting, available:** Telefondaki "Sorry," için "Kusura bakmayın," kullanıldı. Doğal mı, yoksa "Maalesef" mi daha iyi?
- **as soon as possible, get in touch:** as soon as possible ilk örneği "siz" ("cevap verin"), öbür örnekler "sen". get in touch ilk örneği "iletişime geç" (sen). İş bağlamında "geçin" daha mı doğal?
- **take over:** "Sara ayrılınca kim devralacak?" Nesnesiz "devralmak" doğal mı, yoksa "yerine kim geçecek?" mi?
- **customer:** "dükkân sahibi" (İngilizcede yalnızca "the owner").
- **print out:** "Zeynep'e formun kâğıt hâli lazım, ben de çıktısını alırım."
- **promotion:** "terfi aldı" mı, "terfi etti" mi?
- **meet a deadline:** "Elif son teslim tarihine yetişebilmek için ekibinden yardım istedi."
- **career:** "Fatma'nın aynı bankada uzun ve mutlu bir kariyeri oldu." "Mutlu bir kariyer" doğal mı?
- **come up with:** "Pazartesiye kadar bir plan ortaya koymamız gerekiyor."
- **bring up:** "fikrini öğle yemeğinde ortaya attı." "Dile getirdi" daha mı yakın?
- **employer:** "işvereni" günlük konuşmada resmî mi duruyor?
- **out of the office:** "otomatik e-posta yanıtı ayarladı" doğal mı, yoksa "otomatik yanıt koydu" mu denir?
- **look into:** Nottaki "gerçeğini araştırmak" yerine "aslını araştırmak" daha mı doğal?
- **customer (mnemonic):** "Custom = gelenek, alışkanlık…" A2 öğrencisine yararlı mı, yoksa null mu olmalı?
