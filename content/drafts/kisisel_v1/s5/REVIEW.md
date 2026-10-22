# s5 QA incelemesi (temel fiiller)

Kapsam: `content/drafts/kisisel_v1/s5/part_01.json` ... `part_05.json` (50 kart: get, have, go, come, give, put, keep, leave, find, try, need, want, know, think, understand, mean, feel, look, start, stop, finish, open, close, wait, call, ask, answer, help, meet, visit, stay, live, study, learn, teach, speak, talk, use, carry, send, buy, sell, become, happen, let, worry, agree, believe, forget, decide). Bakılan kriterler: `SYSTEM_C` listesi ve denetim kuralı dosyasındaki 11 madde. Her kart tek tek okundu; her quiz şıkları tek tek boşluğa konarak denendi.

## Özet

- İncelenen kart: **50**
- Değişen kart: **19** (hepsine `critic_edited` eklendi)
- Toplam düzenleme (alan sayısı): **31** (1'i silinen bir hata maddesi)
- Reddedilen kart (`critic_reject`): **0**
- Seviye değişikliği: **yok**
- Doğrulayıcı (`python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s5`): `50 kart · 50 şemadan geçti · 0 hata · 0 uyarı`

## İstenen özel kararlar

### 1. Kaynaksız hata cümleleri (8 madde)

| Cümle | Karar | Gerekçe |
|---|---|---|
| "I finished to read" (en.finish) | **Tutuldu**, açıklama düzeltildi | Gerçek ve yaygın hata ('okumayı bitirdim' → 'okumak' = to read). `right` ("finished reading") doğru. Eski açıklama 'okumayı' için "fiil -mek/-mak biçimindedir" diyordu; 'okumayı' isim-fiildir (-ma + -yı), mastar değil. Neden 'to' denildiği yeniden yazıldı. |
| "I started to the English course" (en.start) | **Tutuldu**, dokunulmadı | 'Kursa başladım' (-a hâli) → 'to'. 'Start to school / start to the course' Türkçe konuşanlarda görülen gerçek bir kalıp. `right` doğru. Güven orta; aşağıdaki "Anadil kontrolü" listesinde. |
| "What is mean 'lazy'?" (en.mean) | **Silindi** | Türkçe konuşanlara özgü yaygın bir hata olarak doğrulanamadı; 'öğrenciler boşluğu is ile doldurur' açıklaması tahmindi. Ana Türkçe kaynaklı hata ('Bu kelime ne demek?' → "What means this word?") ilk maddede zaten var. Liste artık tek maddeli. |
| "I forgot buying milk" (en.forget) | **Tutuldu**, açıklama netleştirildi | Gerçek hata: Türkçede 'unuttum' için tek yapı var ('almayı unuttum') ve '-ma' eki çoğu zaman '-ing' diye çevriliyor. `right` ("forgot to buy") doğru. 'Forget to buy' = yapmadı, 'forget buying' = yaptığını unuttu açıklaması korundu. |
| "I gave a decision" (en.decide) | **Tutuldu** | 'Karar vermek' → 'give a decision' Türkçe kaynaklı, yaygın bir hata. `right` olarak "I decided to learn English." konmuş; kartın kelimesi 'decide' olduğu için doğru ve en doğal biçim bu ('made a decision' de notta var). Nottaki "give a decision denmez" fazla kesindi (mahkeme/yetkili 'gives a decision'); 'kendi kararın için' diye sınırlandı. |
| "It became eight o'clock" (en.become) | **Tutuldu**, dokunulmadı | 'Saat sekiz oldu' ('olmak' = be/become/happen) kaynaklı gerçek bir calque. `right` ("It was eight o'clock") doğru. Güven orta-yüksek; "Anadil kontrolü" listesinde. |
| "Stop a minute" (en.stop) | **Değiştirildi** | 'Stop a minute' İngilizcede söylenebilir (özellikle İngiliz İngilizcesi: "stop a minute and think"), yani net bir hata değil. 'Dur bir dakika' için doğal olan 'Wait a minute' bilgisi nottan korundu. Yerine daha net, Türkçe kaynaklı bir hata kondu: "Please stop to talk." ('konuşmayı bırak' → 'to talk'); doğrusu "Please stop talking." |
| "I will search you tonight" (en.call) | **Tutuldu**, açıklama düzeltildi | 'Seni arayacağım' → 'search' Türkçe konuşanlarda görülen gerçek bir yanılgı ('aramak' = call / search / look for). `right` ("I will call you tonight") doğru. Açıklama 'search'ün ne olduğunu söylemiyordu; eklendi. |

### 2. Quizler

Her kartta şıklar boşluğa tek tek konuldu (zaman/kişi biçimleri dahil). Sonuçlar:

- **want**: Eski cümle ("My little sister ______ to be a doctor when she grows up.") `hopes`, `plans`, hatta `needs` ile de doğru kuruluyordu; çeldiriciler (plays, opens, wears) ise hiçbir şeyi sınamıyordu. Yeni cümle: "My sister ______ a new bike for her birthday." Çeldiriciler: hopes, asks, wishes. Üçü de isim nesnesini doğrudan almaz (hope for, ask for, wish for), yalnızca `wants` uyar. `needs` ve `gets` bilerek çeldirici yapılmadı: ikisi de uyar.
- **need**: "The doctor says I ______ to rest for two days." cümlesi iyi (doktor kişinin neye ihtiyacı olduğunu söyler). Ama çeldiricilerden `refuse` ve `forget` "kişinin gerçek davranışı" olarak okunabiliyordu. Yeni çeldiriciler: hope, plan, decide (doktorun söyleyemeyeceği zihinsel eylemler). `want` bilerek konmadı: "The doctor says I want to rest" tuhaf ama "açıkça yanlış" denemez; tek doğru cevap kuralı önce geldiği için çeldirici yapılmadı.
- **go**: Eski çeldiriciler (stay, sit, wait) 'go to school' kalıbına zaten uymayan, hiçbir şeyi sınamayan fiillerdi. Yenileri: walk, run, fly. `by bus` yüzünden yalnızca `go` uyar. `come` bilerek konmadı: bağlama göre doğru sayılabilir. Cümlede özne çoğul ("Sofia and I"), bu yüzden goes/went biçimleri sorun çıkarmıyor.
- **stay**: "We are on holiday. We ______ in a small hotel..." cümlesine `live` da dilbilgisi olarak uyuyordu (insanlar otelde yaşar). "for a week" eklendi.
- **answer**: `carry` ("carry my message" = mesajı iletmek) doğru sayılabiliyordu; `wear` ile değiştirildi.
- **become**: `stopped` ("stopped a doctor") kurulabiliyordu; `felt` ile değiştirildi.
- Diğer 44 quizde şık tek tek denendi, tek doğru cevap kuralı sağlanıyor. Bazı çeldiriciler hâlâ kolay (have: wear/go; come: waits/opens/sits; start: sells/wears; live, study, believe) ama her okumada yanlış; "emin olamıyorsan bırak" kuralı gereği dokunulmadı.
- Hiçbir quizde cevap cümlede görünmüyor. `find` ve `ask` quizleri 1. örnekle neredeyse aynı cümle (düşük öncelikli not).

### 3. Etimolojiler

| Kart | Karar |
|---|---|
| understand | Gerçek (OE `understandan`; ilk öğe büyük olasılıkla 'among/between'). 'Stand under' halk etimolojisi yazılmamış. "among the facts" kaynakta yoktu; 'stand in the middle of' biçimine yaklaştırıldı. `medium` kaldı. |
| stop | Gerçek (OE `forstoppian` 'tıkamak, doldurmak'; 'durmak' anlamı çok sonra). Metin değişmedi. `medium` kaldı. |
| answer | Gerçek (OE `andswaru`: `and-` 'karşı' + 'swear' ile ilgili kelime; ilk anlam suçlamaya karşı cevap). 'swerian' doğrudan kök gibi yazılmıştı; temkinli yeniden yazıldı. `medium` kaldı. |
| forget | Gerçek (OE `forgietan`: `for-` + `gietan`, 'get' ile akraba). Metin değişmedi. `medium` kaldı. |

Diğer etimolojiler de (get, want, try, start, wait, call, close, finish, study, carry, teach, sell, visit, become, happen, worry, agree, decide) tek tek kontrol edildi; hepsi gerçek, halk etimolojisi yok. Etimolojisi `null` olan kartlar boş bırakılmış, doğru.

### 4. IPA (call, talk)

**Değiştirilmedi.** US /kɔːl/ ve /tɔːk/, s1-s4'teki geleneğe uyuyor: aynı ünlüde `/ɔː/` kullanılan kartlar var (walk /wɔːk/, fall /fɔːl/, cough /kɔːf/, call back /kɔːl ˈbæk/, wash /wɔːʃ/), `cot` sınıfında ise `/ɑː/` (stop /stɑːp/, want /wɑːnt/, job /dʒɑːb/). Bu, Oxford/Longman öğrenici sözlüklerindeki ABD yazımıyla da aynı. Yalnızca iki kartı `/kɑːl/` ya da `/kɔl/` yapmak geleneği bölerdi. Uygulama genelinde cot-caught birleşmesine geçilmek istenirse bütün `/ɔː/` US kayıtları tek seferde ele alınmalı. s5'teki diğer IPA'lar (vurgu dahil: understand /ˌʌndərˈstænd/, answer, worry, become, forget, decide, agree, believe, visit, finish) doğru.

### 5. Çok anlamlı fiiller

| Fiil | Seçilen anlam | Sonuç |
|---|---|---|
| get | receive (almak) | Tanım, 3 örnek, çeviriler, quiz tutarlı. Dokunulan tek şey: 3. örnekteki "Can got ..." ('Can' modal gibi okunuyordu) → "Kaan got ...". |
| have | eat or drink | Tanım, örnekler, mistake, quiz tutarlı. 'Sahip olmak' ayrı anlam; nota eklendi. |
| keep | continue to have (saklamak) | Örnekler/quiz tutarlı. `collocations` içindeki 'keep a diary' (günlük tutmak) başka anlam; 'keep old photos' ile değişti. |
| leave | go away from a place | Tanım, örnekler (3. örnek: tren kalkıyor, aynı anlam), mistake ve quiz tutarlı. 'Bırakmak' anlamı yalnızca notta. |
| mean | have a meaning (kelime/işaret) | `collocations` içindeki 'what do you mean' (kişinin kastı) çıkarıldı. Geri kalan tutarlı. |
| look | seem (görünmek) | Tanım, 3 örnek, mistake, quiz tutarlı. 'look at/for' yalnızca notta. |

Ek olarak forget kartının 3. örneği ("forgot her keys at the office", bir yerde bırakmak) tanımın `long` kısmındaki "forget ... your keys" ile uyumlu.

## Genel bulgular

- Kartlar genel olarak iyi: İngilizce örnekler doğal, ilk örnekler kısa ve kilit ekranı için güvenli, Türkçe çeviriler geri çevrildiğinde İngilizceyle aynı anlama geliyor. Seviye (A1/A2) dağılımı makul; değiştirilen yok. Sahte dost kaydı yok, doğru.
- En sık 3 sorun:
  1. **Quiz çeldiricileri** (6 kart: want, need, go, stay, answer, become): ya hiçbir şeyi sınamıyordu ya da doğru sayılabiliyordu.
  2. **Hata (mistakes) açıklamaları ve zayıf hata maddeleri** (6 kart: understand, mean, stop, finish, call, forget): açıklama hatanın Türkçe kaynağını anlatmıyor, ya da hata Türkçeyle ilgisiz/kesin değildi.
  3. **Küçük doğruluk ve anlam tutarlılığı sorunları** (nottaki "stop düzensiz" hatası, 'kendine güvenmek' çevirisi, decide notunun fazla kesin ifadesi, 'keep a diary' kalıbı, 'ailesi' fazla bilgisi, 'Can got' belirsizliği, 'Çantanda' çevirisi, etimoloji ifadeleri).
- Yazım kuralı: İngilizce sözcükten sonra ayrı yazılmış ek ('freezer' dır türü) bu akışta yok; 'ya', 'da' gibi bağlaçlar doğru kullanılmış.
- Birden fazla kartta tekrar eden "Türkçede düzensiz fiil yoktur; bu yüzden -ed eklenir" açıklaması (put, keep, sell) dokunulmadı: hata tüm dillerden öğrencilerde görülür ama Türkçede geçmiş zaman tek kalıpla kurulduğu için açıklama savunulabilir.

## Değişiklik tablosu

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.get.v.1 | examples[2].en | Can got a nice gift from his boss. → Kaan got a nice gift from his boss. | 'Can got' modal fiil 'can' gibi okunuyordu; 'get' kartında kafa karıştırıcı. İsim değiştirildi. |
| en.get.v.1 | examples[2].tr | Can patronundan güzel bir hediye aldı. → Kaan patronundan güzel bir hediye aldı. | Yeni İngilizce cümleye uygun çeviri. |
| en.have.v.1 | l1.tr.note | Yemek ve içecek için 'eat' ya da 'drink' yerine sık sık 'have' denir: kahvaltı yapmak = have breakfast. Düzensiz: have - had - had. → Yemek ve içecek için 'eat' ya da 'drink' yerine sık sık 'have' denir: kahvaltı yapmak = have breakfast. 'Sahip olmak' (I have a car) ayrı bir anlamdır. Düzensiz: have - had - had. | Kart yalnızca 'yemek/içmek' anlamını anlatıyor; 'sahip olmak' ayrı bir anlam olduğu belirtildi (get kartındaki gibi). |
| en.go.v.1 | quiz.distractors | stay, sit, wait → walk, run, fly | 'stay, sit, wait' hiçbir şeyi sınamıyordu ('go to school' kalıbına uymayan fiiller). Yeni çeldiriciler aynı türden hareket fiilleri; 'by bus' yüzünden yalnızca 'go' uyuyor. 'come' bilerek konmadı: bağlama göre doğru sayılabilir. |
| en.keep.v.1 | collocations[4] | keep a diary → keep old photos | 'keep a diary' (günlük tutmak) başka bir anlam (düzenli yazmak); kartın 'elinde tutmak/saklamak' anlamıyla uyumlu bir kalıp konuldu. |
| en.need.v.1 | quiz.distractors | hope, forget, refuse → hope, plan, decide | 'forget' ve 'refuse' doktor cümlesinde kişinin gerçek davranışı olarak okunabiliyordu ('The doctor says I refuse to rest' tuhaf ama kurulabilir). Doktorun söyleyemeyeceği zihinsel eylem fiilleri kondu; 'want' bilerek konmadı (need/want bu cümlede karışabilir). |
| en.want.v.1 | quiz.cloze | My little sister ______ to be a doctor when she grows up. → My sister ______ a new bike for her birthday. | Eski cümlede ('...to be a doctor when she grows up') 'hopes' ve 'plans' da uyuyordu; çeldiriciler ('plays, opens, wears') ise hiçbir şeyi sınamıyordu. Yeni cümle 'want + isim' kalıbına dayanıyor. |
| en.want.v.1 | quiz.distractors | plays, opens, wears → hopes, asks, wishes | 'hopes/asks/wishes' isim nesnesini doğrudan almaz ('hope for, ask for, wish for'); yalnızca 'wants' uyuyor. 'needs' ve 'gets' bilerek konmadı: onlar da uyar. |
| en.understand.v.1 | etymology.text | From Old English 'understandan'. Here 'under' probably meant 'among', so the idea is 'to stand among' the facts. → From Old English 'understandan'. Here 'under' probably meant 'among' or 'between', so the idea was 'to stand in the middle of' something. | 'among the facts' kaynakta yok, sonradan eklenmişti; yaygın kaynaklardaki 'stand in the midst of' biçimine yaklaştırıldı. 'Stand under' halk etimolojisi yazılmamış. Güven medium kaldı. |
| en.understand.v.1 | l1.tr.mistakes[0].why | Türkçede 'anlıyorum' tek kelimedir. 'I am' + fiil biçiminde çevrilince yanlış çıkar: İngilizcede 'am' ile yalın fiil birlikte kullanılmaz. → Türkçede 'anlıyorum' tek kelimedir ve sondaki -um 'ben'i taşır; bu yüzden 'I am' + fiil denir. İngilizcede 'am' ile yalın fiil birlikte kullanılmaz. | Eski açıklama ('çevrilince yanlış çıkar') neden yanıldığını anlatmıyordu. |
| en.understand.v.1 | l1.tr.mistakes[1].wrong | I'm not understanding this word. → I don't understand nothing. | 'I'm not understanding' anadili konuşurlarca da (özellikle günlük konuşmada) söylenir; net bir hata sayılmaz. Yerine gerçek bir Türkçe etkisi olan çift olumsuzluk konuldu. |
| en.understand.v.1 | l1.tr.mistakes[1].right | I don't understand this word. → I don't understand anything. | Yeni hataya uygun doğru biçim. |
| en.understand.v.1 | l1.tr.mistakes[1].why | Türkçede 'anlamıyorum' -yor ekiyle (şimdiki zaman) söylenir. 'Understand' durum fiilidir; olumsuzu 'don't understand' olur. → Türkçede 'hiçbir şey anlamıyorum' denir; 'hiçbir şey' ile birlikte fiil de olumsuzdur. İngilizcede olumsuz fiilden sonra 'nothing' değil 'anything' gelir. | Yeni hataya uygun açıklama. |
| en.mean.v.1 | l1.tr.mistakes[1] | {"wrong": "What is mean 'lazy'?", "right": "What does 'lazy' mean?", "why": "Türkçede 'Ne demek?' sorusunda yardımcı fiil yoktur; öğrenciler boşluğu 'is' ile doldurur. İngilizcede 'is' ile yalın 'mean' birlikte kullanılmaz: 'does' gerekir."} → (silindi) | 'What is mean ...?' Türkçe konuşanlara özgü yaygın bir hata olarak doğrulanamadı; 'öğrenciler boşluğu is ile doldurur' açıklaması tahmine dayanıyordu. Asıl Türkçe kaynaklı hata ilk maddede ('What means this word?') zaten var. |
| en.mean.v.1 | collocations[3] | what do you mean → mean something | 'what do you mean' kişinin ne demek istediğini sorar; kartın anlamıyla (kelime/işaret bir şey 'demektir') aynı değil. |
| en.stop.v.1 | l1.tr.note | 'Stop' + -ing = bir işi bırakmak: stop talking = konuşmayı bırakmak. Ama 'durmak' bazen 'beklemek' demektir: 'bir dakika dur' için 'wait' denir. Düzensiz: stop - stopped - stopped. → 'Stop' + -ing = bir işi bırakmak: stop talking = konuşmayı bırakmak. Ama 'durmak' bazen 'beklemek' demektir: 'bir dakika dur' için 'wait' denir. Geçmiş zaman: stopped (p ikilenir). | 'Düzensiz: stop - stopped - stopped' yanlıştı: 'stop' düzenli bir fiildir (yalnızca p ikilenir). |
| en.stop.v.1 | l1.tr.mistakes[0].wrong | Stop a minute, I'm coming. → Please stop to talk. The baby is sleeping. | 'Stop a minute' İngilizcede söylenebilen bir kalıp (özellikle İngiliz İngilizcesi); açıkça 'yanlış' denemez ve Türkçe konuşanların yaygın hatası olarak doğrulanamadı. Yerine 'konuşmayı bırak'tan doğan gerçek 'stop to + fiil' hatası kondu; 'dur = wait' bilgisi nottan korunuyor. |
| en.stop.v.1 | l1.tr.mistakes[0].right | Wait a minute, I'm coming. → Please stop talking. The baby is sleeping. | Yeni hataya uygun doğru biçim. |
| en.stop.v.1 | l1.tr.mistakes[0].why | Türkçede 'dur' hem 'stop' hem 'wait' hem 'stay' demektir: 'Dur bir dakika!' İngilizcede bir şeyi beklemek için 'wait' kullanılır; 'stop' hareketi ya da işi bitirmektir. → Türkçede 'konuşmayı bırak' denir; 'konuşmak' (to talk) akla geldiği için 'stop to talk' denir. 'Stop to talk' konuşmak için durmak demektir. Bırakmak için 'stop talking' gerekir. | Yeni hataya uygun açıklama. |
| en.finish.v.1 | l1.tr.mistakes[0].why | Türkçede 'okumayı bitirdim' denir ve fiil -mek/-mak biçimindedir; bu yüzden 'to read' denir. İngilizcede 'finish' + -ing kullanılır, 'to' gelmez. → Türkçede 'okumayı bitirdim' denir; 'okumak' (to read) akla geldiği için 'to read' denir. İngilizcede 'finish' ile fiil -ing alır: finish reading. | Eski açıklama 'fiil -mek/-mak biçimindedir' diyordu; oysa 'okumayı' isim-fiildir (-ma + -yı). Neden 'to' denildiği doğru anlatıldı. |
| en.stay.v.1 | quiz.cloze | We are on holiday. We ______ in a small hotel near the beach. → We are on holiday for a week. We ______ in a small hotel near the beach. | 'We are on holiday. We live in a small hotel' dilbilgisi olarak kurulabiliyordu (insanlar otelde yaşar). 'for a week' geçici süreyi netleştirir; yalnızca 'stay' uyuyor. |
| en.live.v.1 | examples[1].tr | Emre ailesiyle birlikte yaşıyor. → Emre anne babasıyla birlikte yaşıyor. | 'his parents' = anne babası; 'ailesi' (family) kardeşleri de kapsar, fazla bilgi. |
| en.call.v.1 | l1.tr.mistakes[1].why | Türkçede 'aramak' hem telefon etmek hem bulmaya çalışmak demektir. İngilizcede telefon için 'call', bir şeyi bulmaya çalışmak için 'look for' kullanılır. → Türkçede 'aramak' hem telefon etmek hem bulmaya çalışmak demektir; bu yüzden 'search' denir. Telefon için 'call' gerekir; 'search' bir yeri ya da internette bir şeyi aramaktır. | Hata cümlesi 'search' diyor ama açıklama 'search'ün ne olduğunu söylemiyordu. |
| en.answer.v.1 | etymology.text | From Old English 'andswaru': 'and-' (against) + 'swerian' (to swear). It first meant a statement made against a charge. → From Old English 'andswaru', a reply to a charge. It joins 'and-' (against) and a word related to 'swear'. | 'swerian' doğrudan kök olarak yazılmıştı; kaynaklar 'swear ile ilgili' diyor. İfade temkinli yapıldı. Güven medium kaldı. |
| en.answer.v.1 | quiz.distractors | ask, say, carry → ask, say, wear | 'carry my message' (mesajı iletmek) dilbilgisi olarak doğru ve 'Maybe he is busy' ile bağdaşabiliyordu; çeldirici de doğru sayılabilirdi. |
| en.become.v.1 | quiz.distractors | opened, sold, stopped → opened, sold, felt | 'she finally stopped a doctor' kurulabilen bir cümle (bir doktoru durdurdu). 'felt a doctor' açıkça yanlış. |
| en.let.v.1 | examples[0].tr | Çantanda sana yardım edeyim. → İzin ver, çantana yardım edeyim. | 'Çantanda sana yardım edeyim' doğal değil: 'çantanda' (çantanın içinde) yanlış durum eki; 'let' karşılığı 'izin ver' de çeviride görünmüyordu. |
| en.believe.v.1 | l1.tr.note | Türkçede 'inanmak' -a hâli ister ('sana inanıyorum'); İngilizcede 'believe' kişiyi doğrudan alır. 'Believe in yourself' = kendine güvenmek. → Türkçede 'inanmak' -a hâli ister ('sana inanıyorum'); İngilizcede 'believe' kişiyi doğrudan alır. 'Believe in yourself' = kendine inanmak. | 'Believe in yourself' karşılığı 'kendine güvenmek' değil, 'kendine inanmak'. |
| en.decide.v.1 | def.long | To choose what to do after thinking about different possibilities. You can decide where to eat, what to buy, or when to leave. We often say 'decide to' and a verb. → To choose what to do after thinking about different choices. You can decide where to eat, what to buy, or when to leave. We often say 'decide to' and a verb. | 'possibilities' A2 için zor; 'choices' ile değiştirildi. |
| en.decide.v.1 | l1.tr.note | Türkçede 'karar vermek' iki sözcüktür; İngilizcede 'decide' tek fiildir. 'Give a decision' denmez: 'decide' ya da 'make a decision' denir. → Türkçede 'karar vermek' iki sözcüktür; İngilizcede 'decide' tek fiildir. Kendi kararın için 'give a decision' denmez: 'decide' ya da 'make a decision' denir. | 'Give a decision denmez' fazla kesindi: mahkeme ya da yetkili için 'give a decision' söylenir. Kendi kararın için olduğu belirtildi. |
| en.forget.v.1 | l1.tr.mistakes[0].why | Türkçede 'süt almayı unuttum' denir ve fiil tek biçimdedir. İngilizcede 'forget to buy' yapılmayan işi, 'forget buying' yapılmış ama unutulmuş işi anlatır. → Türkçede 'süt almayı unuttum' tek yapıdır; '-mayı' eki çoğu zaman '-ing' gibi çevrilir. 'Forget to buy' yapılmayan işi, 'forget buying' yapılmış ama unutulmuş işi anlatır. | Hatanın Türkçe kaynağı (-ma/-me ekinin '-ing' diye çevrilmesi) açıkça yazıldı. |

## Anadili Türkçe birinin bakması gerekenler

- **en.start.v.1**: `mistakes[0]` "I started to the English course last week." 'Kursa başladım' kaynaklı; 'start to school' kadar yaygın mı? Gerçek ama kesin değil.
- **en.become.v.1**: `mistakes[0]` "It became eight o'clock." 'Saat sekiz oldu' gerçekten bu hataya yol açıyor mu? Kart ('olmak' = be/become/happen) ile uyumlu.
- **en.call.v.1**: `mistakes[1]` "I will search you tonight." Hata kaynağı gerçek ama cümle anadili İngilizce okurun gözünde ürkütücü ('arama' anlamında). "I searched you, but your phone was off." gibi bir cümle daha gerçekçi olabilir. Dokunulmadı.
- **en.want.v.1**: `mistakes[1]` "I want that you help me." Türkçe konuşanların 'yardım etmeni istiyorum'dan "that" çıkarması mı, yoksa "I want you help me" (to düşürme) mi daha yaygın? Dokunulmadı.
- **en.put / keep / sell**: "putted / keeped / selled" hataları: Türkçe etkisi tartışmalı (düzensiz fiil olmaması), gerçek hata ama tüm dillerde görülür.
- **en.meet.v.1**: `mistakes[0]` "Nice to know you." Aslında 'tanıdığıma memnun oldum' da Türkçede söylenir; İngilizce 'Nice to know you' bazı bağlamlarda doğru (veda). Hata sayılmalı mı?
- **en.live.v.1**: `mistakes[1]` "I live at Izmir." 'İzmir'de' → at: bu hata ne kadar yaygın?
- **en.think.v.1**: ilk örnek "Bence bu iyi bir fikir." Kartın kelimesinin karşılığı ('düşünmek') çeviride görünmüyor, 'bence' var. Doğal ama brief'e tam uymuyor.
- **en.buy.v.1**: Karşılık 'satın almak', ama 1. ve 2. örnek çevirilerinde 'almak' kullanılmış. Günlük dilde doğal; gloss sırası 'almak' olmalı mı?
- **en.need.v.1**: 2. örnek çevirisi "Çantalarınız için yardıma ihtiyacınız var mı?" doğal mı? ('Çantalarınızla ilgili' ya da 'Çantalarınızı taşımak için' daha mı iyi?)
- **en.let.v.1**: 3. örnek çevirisi "Lütfen telefonunu bir dakika Leo'nun kullanmasına izin ver." biraz ağır; doğru ve belirsiz değil ama günlük Türkçe daha basit olabilir. Dokunulmadı.
- **en.agree.v.1**: `alt` 'kabul etmek' bu anlam ('aynı fikirde olmak') için fazla 'to accept' tarafına mı kayıyor?
- **en.have / come / start / live / study / believe** quizleri: çeldiriciler hâlâ kolay (wear, go, sells, wears...). Daha iyi ama tek cevap kuralını bozmayan şıklar önerilirse değiştirilebilir.
- **IPA**: call/talk için US /kɔːl/, /tɔːk/ (s1-s4 geleneği korundu). Cot-caught birleşmesi uygulama genelinde istenirse topluca değişmeli.

## Sayılar

| Ölçü | Sayı |
|---|---|
| İncelenen kart | 50 |
| Değişen kart | 19 |
| Düzenlenen alan | 31 |
| Reddedilen kart | 0 |
| Doğrulayıcı sonucu | 0 hata, 0 uyarı |

## Çeldirici çeşitlendirme (2026-10-19)

- Önce: 50 soru, 80 farklı çeldirici; en sık: wear×12, sell×7, say×6, carry×6, open×6, speak×4.
- Sonra: 50 soru, 84 farklı çeldirici; en sık: wait×4, say×4, speak×4, wash×4, wear×4, lose×4. Doğrulayıcı sınırı (`QUIZ_DISTRACTOR_REPEAT`): 4.
- Çeldiricisi değişen kart: 15 (`distractors_diversified`). Doğru cevaplar değişmedi.
- Bu bölümü editör (Opus) yazdı: çeşitlendirme ajanı işini bitirip raporu yazamadan kullanım sınırına takıldı. Sayılar dosyalardan ölçüldü.

## Hafıza ipuçları ve denetim (2026-10-22)

- **Hafıza ipucu:** yazar ajan 23 ipucu önerdi. Şüpheci doğrulayıcı 3 tanesini reddetti, 6 tanesini küçük düzeltmeyle kabul etti. **Eklenen: 20** (`meta.qa_flags`: `mnemonic_added`).
- **Düzeltme:** yok. Yazar bütün kartlarda çevirileri, Dikkat kutularını ve quiz şıklarını tek tek denedi; önerdiği 1 düzeltme doğrulayıcıdan geçmedi.
- Yalnızca A1/A2 kartlarına ipucu eklendi. `id`, `lemma`, anlam, `gloss`, `def` ve IPA değişmedi.
- Doğrulayıcı: `50 kart · 50 şemadan geçti · 0 hata · 0 uyarı`

### Eklenen hafıza ipuçları

| Kart | İpucu |
|---|---|
| en.know.v.1 | 'Know' tıpkı 'no' gibi okunur; baştaki 'k' sessizdir. |
| en.meet.v.1 | Türkçedeki 'miting' ile aynı kelime: 'meeting', insanların bir araya gelmesi. 'Meet' = buluşmak, tanışmak. |
| en.teach.v.1 | 'Teacher' (öğretmen) kelimesinin içinde 'teach' var: öğretmek öğretmenin işi. Sen öğrenirken 'learn' dersin. |
| en.study.v.1 | 'Student' (öğrenci) ile 'study' aynı aileden: ders çalışmak öğrencinin işi. Para kazanmak için çalışmak 'work'. |
| en.speak.v.1 | Türkçedeki 'spiker' ile aynı kelime: 'speaker', yani konuşan kişi. 'Speak' = konuşmak. |
| en.talk.v.1 | Televizyondaki 'talk show' bir sohbet programıdır: 'talk' sohbet etmek. Bir dili konuşmak ise 'speak English'. |
| en.carry.v.1 | 'Carry' ile 'car' (araba) aynı Latince kökten gelir: eskiden yükler arabayla taşınırdı. |
| en.buy.v.1 | 'Buy' içindeki 'u' okunmaz; 'bye' (hoşça kal) ile aynı söylenir. Kasada öde, al, 'bye' de çık. |
| en.sell.v.1 | Mağaza camındaki 'SALE' yazısını bilirsin: 'sell' (satmak) ile aynı aileden. |
| en.become.v.1 | İçinde 'come' var ama 'gelmek' değil! 'Become' = olmak: 'become a doctor' doktor olmak. |
| en.happen.v.1 | 'Happen' ile 'happy' aynı eski kelimeden gelir: 'hap' (şans). Şans eseri bir şey olunca 'it happened' denir. |
| en.believe.v.1 | 'Believe' yazılışında 'lie' (yalan) saklı: be-LIE-ve. Yalana inanma! 'ie' sırasını böyle hatırla. |
| en.call.v.1 | 'Call center' telefonla aradığın yerdir: 'call' = telefonla aramak. Kayıp anahtarı aramak ise 'look for'. |
| en.wait.v.1 | Restorandaki 'waiter' (garson) masanın yanında bekler: 'wait' + '-er'. Beklediğin şeyden önce 'for': wait for me. |
| en.live.v.1 | 'Live' ile 'life' (hayat) aynı aileden: hayatını geçirdiğin yerde 'live'. Tatilde birkaç gün kalırsan 'stay'. |
| en.let.v.1 | Bildiğin 'Let's go!' aslında 'let us go' demek: bize izin ver, gidelim. 'Let' = izin vermek. |
| en.keep.v.1 | Futboldaki 'goalkeeper' (kaleci) topu kaptırmaz, elinde tutar: 'keep' = vermemek, elinde tutmak. |
| en.leave.v.1 | Geçmişi 'left', yani 'sol' ile aynı yazılır. 'He left' = gitti; sola dönmek değil! |
| en.find.v.1 | Havalimanındaki 'Lost and Found' kayıp eşya bürosudur: kaybolan ve bulunan. 'Found', 'find' fiilinin geçmişi. |
| en.answer.v.1 | 'Answer' kelimesindeki 'w' yazılır ama okunmaz, tıpkı 'two' kelimesindeki 'w' gibi. |

### Geri çevrilen düzeltme önerileri

- en.buy.v.1 `examples[1].tr`: Cem pazardan ekmek ve süt aldı. → Cem marketten ekmek ve süt aldı. (doğrulayıcı: 'Market' hem semt pazarı hem market olabilir; 'pazardan ekmek ve süt aldı' da doğal Türkçe, bariz hata değil.)

### Atılan ipucu önerileri

Zorlama, doğruluğu şüpheli ya da kartta zaten söylenen öneriler atıldı:

- `understand`: Yalnızca geçmiş biçimi açıklıyor (notta zaten var); anlamı hatırlatan bir kanca değil, bilgi.
- `open`: Turn on / open ayrımını not ve Dikkat kutusu zaten aynen söylüyor; musluk sahnesi ışık ve TV için bağ kurmuyor.
- `put`: 't' ile biten kısa fiiller değişmez genellemesi yanlış (get-got, sit-sat, meet-met); kalan kısım notu tekrarlıyor.

### Anadili Türkçe birinin bakması gerekenler

- en.feel.v.1 ex[0]: 'Bugün yorgun hissediyorum' yerine 'Bugün kendimi yorgun hissediyorum' daha doğal olabilir (dokunulmadı).
- en.need.v.1 quiz: 'The doctor says I plan to rest' dilbilgisi olarak olası ama anlamca zayıf; şimdilik dokunulmadı.
- en.meet.v.1: 'miting' Türkçede siyasi toplantı/gösteri anlamında; ipucunun 'buluşmak' bağı anadil gözüyle doğrulanmalı.
