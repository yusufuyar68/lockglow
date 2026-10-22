# s16 QA incelemesi (zaman, hava ve doğa)

Kapsam: `content/drafts/kisisel_v1/s16/part_01.json` ... `part_05.json` (45 kart). Konu: zaman ifadeleri (15), hava durumu (15), mevsimler ve doğa (15). Seviye A2–B1.

Süreç (`docs/icerik_uretimi/README.md`). Bütün ajanlar Opus (orta çaba):

1. **Yazım:** Part başına bir yazar ajanı (5 ajan), `1_yazar_kurallari.md`. Koordinatör her kelime için tür, seviye, anlam ipucu ve (varsa) gerçek olduğuna inandığı Türkçe kaynaklı hata adayını verdi; yazarlar adayları ancak kendileri de gerçek bulursa kullandı.
2. **Denetim:** Part başına bir denetçi ajanı (5 ajan), `2_denetci_kurallari.md` ve `SYSTEM_C`. Yazarların "emin olmadığım" maddeleri ve koordinatörün gördüğü zayıf quiz'ler her denetçiye ayrıca verildi.
3. **Bağımsız doğrulama:** Kartları değiştirmeyen üç ayrı doğrulayıcı ajan bütün akışı okudu: (a) quiz'de tek doğru cevap, (b) Türkçe katman (geri çeviri, gloss, not, hata, TDK yazımı), (c) İngilizce içerik, IPA ve üstveri. Koordinatör bulguları tartıp uyguladı.
4. **Çeldirici kontrolü ve son kontrol:** `3_celdirici_kurallari.md` ölçümü ve koordinatör düzeltmelerinin bağımsız kontrolü (bir ajan; aşağıda ayrı bölüm).

## Özet

- İncelenen kart: **45** (A2: 22, B1: 23)
- Tür: 21 kelime (`word`), 15 kalıp (`phrase`), 7 eşdizim (`collocation`), 1 deyim (`idiom`), 1 phrasal verb
- `primary_topic`: weather_seasons 17, time_routines 14, nature_animals 13, idioms_expressions 1
- Değişen kart: **41** (hepsine `critic_edited` eklendi). Hiç değişmeyen: foggy, get wet, thunder, lake.
- Toplam düzenleme (alan sayısı): **132** (denetçiler 76, koordinatör ve bağımsız doğrulama 56)
- Reddedilen kart (`critic_reject`): **0**
- Yaygın hata (`mistakes`): 21 kartta 22 madde; hepsi Türkçeden aktarım. Etimoloji 12 kartta (kalıp ifadelerde hepsi `null`).
- Doğrulayıcı (tüm klasör, `--strict`): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`

## Kelime seçimi

- Görevde örnek verilen kelimelerin bir kısmı başka akışlarda aynı anlamla zaten var; tekrar yazılmadı: `forecast`, `humid`, `freezing`, `sunset` (s2), `on time`, `in time`, `from time to time` (s8). s2'deki öteki hava ve zaman kartları (temperature, storm, chilly, heatwave, flood, cloudy, windy, autumn, sunrise, midnight, tonight, nowadays, recently, meanwhile, island, leaf, soil, hike) ve s8'deki zaman kalıpları (for a while, at the moment, all the time, right now, at last, in the end) dışarıda bırakıldı. s9'daki `weather`, `rain`, `umbrella`, `beach` ve s12'deki `under the weather` de yazılmadı.
- Görevdeki örneklerden yazılanlar: `the day after tomorrow`, `in a while`, `these days`, `pour with rain` ("pouring with rain"), `clear up`, `shore`, `valley`, `go for a walk`.
- Yakın anlamlı kartlar ayrıştırıldı: `these days` (s2 `nowadays` ile eş anlamlı; tanım ve not kişisel, geçici kullanıma kaydırıldı), `in a while` (s8 `for a while` ile farkı notta), `boiling` (s2 `freezing` ile karşıt; notlar birbirine gönderme yapıyor).
- Lemma: `pour with rain` (sözlüklerdeki temel biçim; örnekler "It's pouring with rain"), `be running late` (s10'daki `be in charge of` geleneği). Bütün lemmalar LEMMA_SPEAKABLE kuralına uyuyor (yalnızca harf, boşluk).
- Kimlik ve tekrar taraması: s0–s13 ile kimlik, lemma+pos, `def.short`, örnek cümle ya da quiz cümlesi çakışması yok (koordinatörün `cross_check.py` taraması, son düzeltmelerden sonra). Aynı anda yazılan s14 (ev) ve s15 (alışveriş, para) için kelime listesi ortak not klasörüne bırakıldı.

## Genel bulgular

- Kartların çoğu iyi durumdaydı: ilk örnekler kısa ve kilit ekranına güvenli, tanımlar döngüsüz, seviyeler makul. Seviye değişmedi.
- **En sık 3 sorun:**
  1. **Quiz çeldiricileri yalnızca zaman kipini sınıyordu ya da cümleyle ilgisizdi** (27 kartta quiz değişti). Zaman ifadesi sorularında gelecek cümlesine geçmiş, geçmiş cümlesine gelecek şıklar konmuştu; bazı şıklar hiç ilgisizdi ("by heart, on foot", "Good luck, Take care", "bridge, tower, roof"). Mümkün olan yerde aynı yönde ama yanlış gün/süre ("tomorrow", "in three days") ya da kalıbın gerçek hata biçimi ("yesterday night", "today morning", "make a picnic", "go to camping", "went for walk") kondu. 7 kartta quiz cümlesi bir örneğin neredeyse aynısıydı, cümle değişti. Bağımsız quiz doğrulayıcısı **ikinci doğru cevap bulmadı** (YÜKSEK 0). Doğrulamadan sonra yalnızca 'did a walk' (İngiliz kullanımında sınırda doğru), 'moonlight' (yeni lightning cümlesinde okunabilirdi) ve biçim kuralına uymayan 'percent' değişti.
  2. **Türkçede düz çeviri ve yazım** (38 kartta Türkçe katmanda en az bir düzenleme). Örnekler: "Ocak ayı için", "Biraz gölge", "montu olmadan eve yürüdü", "katlanılır hâle getirdi", "Her an yağmur başlayacak". Yazım: 'bu günlerde' → 'bugünlerde', 'Nisan'da' → 'Nisanda', hitaptan önce virgül (3 örnek). 'evvelsi gün' → 'evvelki gün' (TDK maddesi). 'taşra' (countryside), 'rötar yapmak' (kişi için), 'şimdilik' (so far) ve 'akşam olmak' (get dark) anlamı kaydırdığı için alt'tan çıktı.
  3. **Not, tanım ve hata arasında çelişki ya da eksik bilgi.** `last night` notu alt ve örnekle çelişiyordu; `half an hour` hatasının `why`'ı yanlış gerekçe veriyordu; `be running late` notu "I'm late" yalnızca varınca söylenir diyordu; `in a while` Amerikan İngilizcesindeki "I haven't seen you in a while" (uzun zamandır) anlamını yok sayıyordu; `every other day` tanımı doğal olmayan "once in two days" kullanıyordu; `at the last minute` anlam notu "just in time" iptal örneğine uymuyordu.
- **Yaygın hatalar:** 22 madde kaldı, hiçbiri silinmedi; denetçiler ve Türkçe doğrulayıcı hepsini gerçek Türkçe aktarımı buldu: after tomorrow, before yesterday, yesterday night, today morning, one and half hour, after ten minutes, "Let's meet the other day" (öbür gün tuzağı), since ages, in the last minute, 30 degree, the weather is 30 degrees, under zero, the weather is getting dark, the weather opened (hava açtı), sit in the shadow, the nature, make a walk, take fresh air, made a picnic, went to camping, Van Lake, in countryside. Yaygınlıkları derlemle doğrulanmadı; en az emin olunanlar aşağıdaki anadil listesinde.
- **IPA:** US'de r'li ünlü `ər` (1 kartta `ɚ` düzeltildi), DRESS `/ɛ/`, kalıplarda tek ana vurgu. `at the last minute`'taki "at" `/æt/` kaldı (s8'deki at least, at last, at the moment ile tutarlı; zayıf `/ət/` fonetik olarak daha doğru, değişecekse s8 ile birlikte). `the day before yesterday`'de "day" ikincil vurgusuz: ˌ ile US biçimi 27 karakter oluyor (sınır 26). İkizi `the day after tomorrow`'da ˌdeɪ var. `pour with rain`'de ana vurgu "pour" üzerinde.
- **Üstveri:** `pour with rain` kartındaki depoda tanımsız `british` bayrağı kaldırıldı (bilgi tanımda ve notta); register `neutral` yapıldı. `boiling` örneklerinin register'ı kartla tutarlı biçimde `informal` oldu. `countryside`'daki `confusable:country`, `shade`'deki `confusable:shadow` ve `thunder`/`lightning`'deki karşılıklı `confusable` bayrakları doğru ve yararlı, kaldı.
- **Konu:** `half an hour` örneği ve quiz'i otobüs saatlerinden günlük hayata ve doğaya çekildi; `have a picnic` quiz'indeki ev işleri şıkları (s14 konusu) değişti. `below zero` ile `lake` kartlarının 3. örnekleri neredeyse aynıydı (göl donar, çocuklar paten kayar); `below zero` örneği değişti.

## Yazar şüphelerine kararlar (kısa)

- **Kalan hatalar:** Yazarların şüphelendiği "Let's meet the other day", "in the last minute", "The weather is getting dark", "The weather is 30 degrees", "The weather opened", "take fresh air", "Van Lake" ve "in countryside" kaldı. Hepsinin `why` alanı Türkçenin nasıl yanılttığını anlatıyor. "The weather is 30 degrees" dilbilgisi olarak bozuk değil ama anadili İngilizce olan biri böyle demiyor; `right` "It's 30 degrees."
- **IPA:** Yukarıdaki IPA maddesine bakın.
- **Karşılıklar:** `pour with rain` gloss'u "şakır şakır yağmak" ("bardaktan boşanırcasına yağmak" 28 karakteri aşıyor; deyim alt'ta ve örneklerde). İkinci alt "sicim gibi yağmak": doğrulayıcının önerdiği "sağanak yağmak"ı denetçi yerleşik bulmamıştı. `countryside` gloss'u "kırsal kesim", alt "kır". `for ages` gloss'u "uzun zamandır", equivalence partial.
- **Etimoloji:** rainbow, thunder (Thor/Thursday bağlantısı), shade, season, nature, lake, view, valley, melt, degree `high`; hill ve forest `medium`. Doğrulayıcı hepsini doğru buldu; degree ve hill metinleri sadeleşti. wave, shore, lightning, breeze, mild, soaked ve bütün kalıplar `null`.
- **Lemma harfi:** Bütün lemmalar küçük harfle. Quiz'de cevap cümle başındaysa büyük harfle (`Time flies`).

## Değişiklik tablosu

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman. Önce denetçilerin değişiklikleri (part sırasıyla), sonra koordinatörün ve bağımsız doğrulamanın değişiklikleri. Aynı alan iki kez değiştiyse ikinci satır son hâlidir. Denetçi bölümlerindeki "Genel bulgular" ve "Yazar şüphelerine kararlar" o partın denetçisine aittir; anadil listeleri en sonda tek listede birleştirildi.

### part_01 (denetçi)

Özet: 10 kart incelendi, 9 kart değişti (`critic_edited`), 19 alan. Reddedilen 0. Değişmeyen: `so_far`. Doğrulayıcı (`--strict`, part_01): `10 kart · 10 şemadan geçti · 0 hata · 0 uyarı`.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.the_day_after_tomorrow.phr.1 | quiz.distractors | the other day, a week ago, yesterday → the other day, tomorrow, in three days | "a week ago" ve "yesterday" yalnızca kipi sınıyordu. "tomorrow" (Salı) ve "in three days" (Perşembe) gün sayımını sınıyor; Pazartesi + Çarşamba bağlamında ikisi de açıkça yanlış. "in two days" bilerek seçilmedi (Çarşamba'ya denk gelir). |
| en.the_day_before_yesterday.phr.1 | ipa.us | /ðə deɪ bɪfɔːr ˈjɛstɚdeɪ/ → /ðə deɪ bɪfɔːr ˈjɛstərdeɪ/ | Depo geleneği `ər`. İkincil vurguyla 27 karakter oluyor (sınır 26), o yüzden ˌ yok. |
| en.the_day_before_yesterday.phr.1 | quiz.distractors | next weekend, in two days, tomorrow morning → yesterday, three days ago, in two days | Üç şık da gelecekti, yalnızca kipi sınıyordu. Şimdi "yesterday" (Salı) ve "three days ago" (Pazar) geçmiş ama yanlış gün; "in two days" iki gün ama ters yön. |
| en.last_night.phr.1 | l1.tr.note | Dün sabah 'yesterday morning', dün akşam 'yesterday evening' denir; ama dün gece 'last night'. → Dün sabah 'yesterday morning'; dün gece 'yesterday night' değil 'last night'. 'Last night' dün akşamı da kapsar. | Eski not "dün akşam = yesterday evening" diyordu; oysa alt'ta 'dün akşam' var ve 3. örnek 'Last night' → 'Dün akşam'. Çelişki giderildi. |
| en.last_night.phr.1 | quiz.distractors | next Friday, in an hour, tomorrow night → yesterday night, tomorrow night, a year ago | Gerçek hata biçimi "yesterday night" iyi çeldirici. "a year ago" geçmiş ama "so I'm tired today" ile anlamca uyuşmuyor. |
| en.this_morning.phr.1 | quiz.distractors | this evening, next month, for an hour → this evening, today morning, tomorrow morning | "for an hour" farklı işlevdeydi ("at seven for an hour" yarı yarıya kurulabiliyor). "today morning" gerçek hata biçimi. "last night" bilerek konmadı (seven last night doğal olurdu). |
| en.these_days.phr.1 | def.micro | in this period of life → around now, in this period | "of life" fazlaydı. |
| en.these_days.phr.1 | def.long | …We often use it to say that things are different from before. → …People use it a lot about their own life, for example: 'I'm busy these days.' | s2 `nowadays` tanımı "different now from before" fikrini kullanıyor; iki kart ayrışsın diye kişisel/geçici kullanım öne alındı. |
| en.these_days.phr.1 | examples[1].tr | Bu aralar kasabamıza pek kar yağmıyor. → Son zamanlarda kasabamıza pek kar yağmıyor. | Kar yağışı yıllara yayılan bir değişim; 'bu aralar' birkaç haftayı çağrıştırıyor. 'son zamanlarda' alt'ta var. |
| en.these_days.phr.1 | l1.tr.note | 'Nowadays' ile hemen hemen aynı… → 'Nowadays' ile yakın anlamlı; 'these days' konuşmada daha sık ve kişinin kendi geçici durumları için de kullanılır: 'I'm busy these days.' | Asıl farkı gösteriyor. |
| en.half_an_hour.phr.1 | examples[0] | The next bus comes in half an hour. / Sonraki otobüs yarım saat sonra geliyor. → I'll be ready in half an hour. / Yarım saate hazır olurum. | Ulaşım yerine günlük hayat; kilit ekranında daha kısa. |
| en.half_an_hour.phr.1 | quiz.cloze | The first bus left at 9:00, and the next one came at 9:30, ______ later. → We left home at 10:00 and got to the lake at 10:30. The walk took ______. | Konu doğaya çekildi; şıklar (a whole day, ten minutes, two hours) saatlerle açıkça yanlış. |
| en.half_an_hour.phr.1 | l1.tr.note | …'an hour and a half' denir… → …'an hour and a half' ya da 'one and a half hours' denir… | 'one and a half hours' da doğru; eski not tek doğru biçim varmış gibi gösteriyordu. |
| en.half_an_hour.phr.1 | l1.tr.mistakes[0].why | İngilizcede önce saat gelir, sonra yarım. → 'saat' tekil kalır; İngilizcede 'an hour and a half' ya da 'one and a half hours' (çoğul). | Eski açıklama yanlıştı ('one and a half hours' sırası Türkçeyle aynı ve doğru). Asıl Türkçe kaynaklı sorun: 'a' düşmesi ve tekil 'hour'. |
| en.in_a_while.phr.1 | l1.tr.mistakes[0].why | …'in' kullanılır… → …'in' kullanılır (in ten minutes, in a while)… | Hatayı kartın kalıbına bağlıyor. |
| en.in_a_while.phr.1 | quiz.distractors | an hour ago, since Monday, all last week → an hour ago, next year, since Monday | "next year" gelecek ama "Don't go out yet" ile anlamca uyuşmuyor. "for a while" / "for ages" bilerek konmadı ("will stop for a while" kurulabiliyor). |
| en.the_other_day.phr.1 | l1.tr.note | Türkçedeki 'öbür gün' ile karıştırma… → Hep geçmiş zamanla kullanılır. Kesin günü söylemez; birkaç gün ya da bir hafta önce olabilir. | Eski not mistakes ile birebir aynı bilgiydi (dolgu). Öbür gün tuzağı hatada ve `the_day_after_tomorrow` notunda duruyor. |
| en.for_ages.phr.1 | examples[0].tr | Seni görmeyeli çok uzun zaman oldu! → Seni görmeyeli uzun zaman oldu! | Daha kısa ve doğal; 'çok uzun' abartıyı ikiye katlıyordu. |
| en.for_ages.phr.1 | examples[2].tr | …her plajı bilir. → …her plajı biliyor. | 'yaşıyor' ile aynı kipte; 'bilir' geniş zaman genelleme gibi okunuyordu. |

**Genel bulgular**

- Kartlar genel olarak sağlamdı: tanımlar döngüsüz, ilk örnekler kısa ve güvenli, etimoloji ve sahte dost hepsinde `null` (doğru), seviyeler makul.
- **En sık sorun: quiz çeldiricileri yalnızca kipi sınıyordu** (6 kartta değişti). Gelecek cümlesine geçmiş, geçmiş cümlesine gelecek şıklar. Mümkün olan yerde aynı yönde ama yanlış gün/süre (tomorrow, in three days, three days ago) ya da gerçek hata biçimi (yesterday night, today morning) kondu. `the_other_day`, `so_far`, `for_ages` sorularında kip dışı anlam sınayan güvenli bir çeldirici bulunamadı (geçmişteki her ifade "I met Kerem ___" boşluğuna uyar); oralar tek doğru cevap kuralı için olduğu gibi bırakıldı.
- **Not–örnek/hata tutarsızlığı ya da tekrarı** (3 kart): `last_night` notu alt ve örnekle çelişiyordu; `the_other_day` notu hatayı tekrar ediyordu; `half_an_hour` notu/why 'one and a half hours'u yok sayıyordu.
- **US IPA'da `ɚ`** (1 kart) `ər` yapıldı.
- Konu: tek kayma `half_an_hour` (otobüs); örnek ve quiz günlük hayat/doğaya çekildi.
- Çeldirici tekrarı: yeni eklenen şıkların hiçbiri s16'da 2'yi geçmiyor (a year ago 2, since Monday 2, the other day 1, yesterday 1, tomorrow 1…). "tomorrow morning" ve "next weekend" bu partta azaldı.
- Hatalar: 8 kartta birer hata kaldı, hiçbiri silinmedi; hepsi bilinen Türkçe aktarımları (after tomorrow, before yesterday, yesterday night, today morning, one and half hour, after ten minutes, öbür gün → the other day, since ages).

**Yazar şüphelerine kararlar**

1. **IPA:** before yesterday US `/ðə deɪ bɪfɔːr ˈjɛstərdeɪ/` (ikincil vurguyla 27 karakter, sığmıyor; ˌ atıldı). UK `/ðə deɪ bɪfɔː ˈjɛstədeɪ/` aynı biçimde bırakıldı. after tomorrow (`/ðə ˌdeɪ æftər təˈmɑːroʊ/`, 25) zaten `ər` kullanıyor ve sığdığı için ˌdeɪ kaldı. İki kart `ər` ve tek ana vurgu açısından tutarlı; tek fark sınırdan gelen ˌ.
2. **"Let's meet the other day."** Gerçek hata olarak kalsın. 'öbür' = 'other' sözcük sözcük eşleşiyor ve Türk öğretmenlerin bilinen tuzak listelerinde var; `right` (the day after tomorrow) ve `why` doğru. Not tekrar olmasın diye nota başka bilgi yazıldı.
3. **half an hour / otobüs:** İlk örnek "I'll be ready in half an hour." ve quiz göle yürüyüş yapıldı.
4. **these days / nowadays:** Önceki tanım nowadays'in "geçmişle karşılaştırma" fikrini tekrar ediyordu; tanım ve not kişisel/geçici kullanıma (I'm busy these days) kaydırıldı. Synonym `nowadays` kalsın (gerçekten yakın anlamlı). Quiz geçmişle karşılaştırma kurduğu için "nowadays" şıklarda yok; olmamalı.
5. **for ages:** gloss 'uzun zamandır', equivalence partial doğru (gloss "I haven't seen you" türünü karşılıyor, "waited for ages" için alt'taki 'çok uzun süre' gerekiyor). İlk örnek çevirisi "Seni görmeyeli uzun zaman oldu!" yapıldı: doğal ve kısa.
- **"after ten minutes"**: Türkçeden geliyor ('on dakika sonra'), çok yaygın; `right` "in ten minutes" doğru, why'daki "geçmişte doğrudur" doğru.
- **"one and half hour"**: Türkçeden geliyor ('bir buçuk saat': 'a' yok, isim tekil). `right` doğru; why yanlış gerekçe veriyordu, düzeltildi.

### part_02 (denetçi)

İncelenen: 10 kart. Değişen: 7 kart (hepsine `critic_edited`), 16 alan. Reddedilen: 0.
Doğrulayıcı (`--strict`, part_02): `10 kart · 10 şemadan geçti · 0 hata · 0 uyarı`

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| any minute now | quiz.cloze | "Look at those black clouds. It's going to rain ______." → "Hurry up! The train is leaving ______. The doors are closing." | Eski cümle 2. örneğin ("It's going to rain any minute now") neredeyse aynısıydı. |
| any minute now | quiz.distractors | a week ago, since Monday, last summer → next year, in ten years, next winter | Eski şıklar yalnızca kipten eleniyordu (hepsi geçmiş). Yeni şıklar da gelecek, ama "kapılar kapanıyor" bağlamında açıkça yanlış: artık anlamı ("çok yakında") sınıyor. a week ago / since Monday / last summer s16'da 2'şer kez geçiyordu, bu yük de azaldı. |
| at the last minute | quiz.distractors | by heart, out of order, on foot → a month ago, the week before, last spring | Eski şıklar cümleyle ilgisizdi. Yeniler aynı işlevde (bilet alma zamanı), ama "never plans ahead" ve "ten minutes before it left" ile çelişiyor. |
| every other day | examples[1].tr | "Nisan'da gün aşırı…" → "Nisanda gün aşırı…" | TDK: belirli tarih bildirmeyen ay adı küçük harfle yazılır, kesme işareti yok. |
| every other day | examples[2].en | "Tom runs in the park every other day, so today is his rest day." → "Tom runs every other day. He ran yesterday, so today is his rest day." | "so" sonucu mantıksal olarak çıkmıyordu (dün koştuğu bilgisi eksikti). |
| every other day | examples[2].tr | Yeni İngilizceye göre: "Tom gün aşırı koşuyor. Dün koştu, yani bugün dinlenme günü." | Çeviri uyumu. |
| be running late | quiz.cloze | "My train is slow" → "My train is delayed" | "train is slow" doğal değil. |
| be running late | quiz.distractors | getting up, running away, taking off → running early, right on time, already here | Eski şıklar konuyla ilgisizdi ("getting up" iki soruda). Yeniler aynı işlevde (varış durumu), "delayed" ve "start without me" ile çelişiyor. |
| time flies | quiz.distractors | Good luck, Never mind, Take care → Time's up, About time, Just in time | Eski şıklar zamanla ilgisiz kalıplardı, bir şey sınamıyordu. Yeniler zamanla ilgili ünlemler; hiçbiri "saatler on dakika gibi geldi" tepkisine uymuyor. |
| below zero | quiz.distractors | above thirty, up the hill, on the way → above zero, over thirty, up to twenty | Eski şıkların ikisi sıcaklıkla ilgisizdi. Yeniler sıcaklık ifadeleri; su bunlarda donmaz. |
| get dark | quiz.distractors | getting up, getting better, getting married → getting hot, getting windy, getting cold | "it's getting X" hava kalıbıyla aynı işlevde; hiçbiri ışığı yakmayı ve okuyamamayı açıklamıyor. "getting cloudy" ve "getting late" bilerek seçilmedi (ikinci doğru cevaba yakın). "getting up" tekrarı da kalktı. |

Değişmeyen kartlar: foggy, degree, get wet (her alanı okundu; sorun yok).

**Genel bulgular**

- Kartların içeriği (tanım, örnek, Türkçe, not) genel olarak iyiydi. Asıl sorun quiz çeldiricileriydi: 10 kartın 6'sında çeldiriciler değişti. Çoğu cümleyle ilgisizdi ya da yalnızca dilbilgisini sınıyordu.
- Tek doğru cevap: hiçbir kartta ikinci doğru şık bulunmadı. Yeni şıklar her biri boşluğa konarak kontrol edildi. Yeni şıkların hiçbiri s16'nın diğer partlarında geçmiyor.
- any minute now sorusu 2. örneğin kopyasıydı; cümle değişti.
- Türkçe: bir TDK yazımı (Nisan'da → Nisanda). Geri çevirilerde fazla ya da eksik bilgi yok.
- Etimoloji: yalnızca degree'de var (Eski Fransızca degré < Latince gradus 'adım'); doğru. Diğerleri null, kalıp kuralına uygun.
- Seviyeler makul; değişiklik yok.

**Yazar şüphelerine kararlar**

1. IPA: `any minute now /ˌɛni ˈmɪnɪt naʊ/` doğru (ana vurgu minute'te, now vurgusuz). `time flies /taɪm ˈflaɪz/` kalsın: depoda kalıbın başındaki tek heceli sözcük işaretsiz bırakılıyor (get wet, drop by, clock in). `at the last minute`'taki `/æt/` kalsın: s8'deki at least, at last, at the moment kartları da `/æt/` kullanıyor. Zayıf `/ət/` fonetik olarak daha doğru, ama tutarlılık için değiştirmedim. Bütün depoda değiştirilecekse s8 ile birlikte yapılmalı.
2. "She arrived in the last minute" gerçek bir hata: Türkçe 'son dakikada'nın bulunma eki doğrudan 'in'e gidiyor. Kalsın. "The weather is getting dark" de gerçek: 'hava kararıyor' birebir aktarılıyor ('hava' = weather/air). Kalsın.
3. "The weather is 30 degrees" kalsın. Dilbilgisi olarak bozuk değil, ama anadili İngilizce olan biri böyle demez ("It's 30 degrees" ya da "The temperature is 30 degrees"). Hata da doğrudan 'hava 30 derece'den geliyor. "why" metni bunu doğru anlatıyor.
4. time flies etimolojisi null kalsın.

### part_03 (denetçi)

İncelenen kart: 10 · değişen kart: 7 (`critic_edited`) · alan: 18 · reddedilen: 0
Doğrulayıcı (`--strict part_03.json`): `10 kart · 10 şemadan geçti · 0 hata · 0 uyarı`

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| rainbow | def.long | "red, orange, yellow, green, blue and violet" → "A curved band of colors in the sky, from red to violet. …" | Altı renk sayılıyordu (indigo eksik), 3. örnek "yedi renk" diyordu; çelişki giderildi. |
| rainbow | examples[2] | "A rainbow has seven colors, from red to violet." → "There was a double rainbow over the city after the storm." / "Fırtınadan sonra şehrin üstünde çift gökkuşağı vardı." | Örnek bilgi cümlesiydi, kelimeyi tanımlıyordu; eşdizim (double rainbow) gösteren doğal cümle. |
| pour with rain | tags.flags | ["british"] → [] | Depoda böyle bir bayrak yok. İngiliz kullanımı bilgisi def.long ve notta duruyor. |
| pour with rain | tags.register | informal → neutral | Sözlükler "pour (with rain)"u gayriresmî diye işaretlemiyor (informal olan "bucket down"); örneklerin register'ı da neutral. |
| pour with rain | ipa | /ˌpɔːr wɪð ˈreɪn/ → /ˈpɔːr wɪð ˌreɪn/ (UK /ˈpɔː wɪð ˌreɪn/) | "rain" tahmin edilebilir olduğu için vurgusuz kalır; ana vurgu "pour(ing)" üzerinde ("It's POURing with rain"). |
| pour with rain | def.micro | "fall from the sky very hard" → "water falls hard from clouds" | Eski tanımın öznesi belirsizdi (kalıbın öznesi 'it'); başlık kelimeyi (rain) kullanmadan açık. |
| pour with rain | def.short | "of the weather, have a lot of water falling…" → "used when a lot of water falls very hard and fast from the clouds" | Dolaylı ve hantal yapı sadeleşti. |
| pour with rain | examples[0] | "Take a coat. It's pouring with rain." / "Mont al. …" → "Look outside! It's pouring with rain." / "Dışarı bak! Bardaktan boşanırcasına yağıyor." | s2 `chilly` ("Take a jacket.") kalıbını tekrar ediyordu; "Mont al" doğal değildi. |
| pour with rain | l1.tr.gloss | "bardaktan boşanmak" → "şakır şakır yağmak" | "bardaktan boşanmak" deyimin kesik hâli; tek başına yerleşik değil. "şakır şakır yağmak" doğal ve sınıra sığıyor. |
| pour with rain | l1.tr.alt | ["sağanak yağmak", "çok şiddetli yağmak"] → ["bardaktan boşanırcasına", "çok şiddetli yağmak"] | "sağanak yağmak" yerleşik değil ("sağanak yağış" isim); tanıdık deyim alt'ta tam biçimiyle (23 karakter) duruyor. |
| clear up | examples[2].tr | "Hava durumuna göre cumartesiye kadar hava açacak…" → "…cumartesiye kadar açacakmış…" | "hava … hava" tekrarı; "says" anlamı -mış ile korunuyor. |
| clear up | quiz.distractors | broke down, gave up, woke up → clouded over, fell down, turned off | Eski şıklar hava cümlesinde hiçbir şey sınamıyordu. "clouded over" anlam karşıtı (but … we went out ile çelişir); hepsi geçmiş zaman phrasal verb, s16'da hiç geçmiyor. |
| boiling | examples[0].tr | "Biraz gölge bulalım." → "Gölge bir yer bulalım." | "Biraz gölge" düz çeviri. |
| mild | examples[0].tr | "Ocak ayı için hava çok ılık." → "Ocak ayına göre hava çok ılık." | "for January" = '-e göre'; 'için' düz çeviri. |
| soaked | examples[1].tr | "Burak montsuz eve yürüdü…" → "Burak eve montu olmadan yürüdü…" | Söz dizimi doğal değildi. |
| soaked | examples[2] | "Take off your soaked jacket and sit by the heater." → "We got soaked to the skin while we waited for the bus." / "Otobüs beklerken iliklerimize kadar ıslandık." | Sıfat önünde "soaked jacket" doğal değil (wet / soaking wet denir); yeni örnek "soaked to the skin" eşdizimini gösteriyor, ev konusundan uzak. |
| shade | l1.tr.note | "…karanlık şekli ise 'shadow' denir" → "…karanlık şekline ise 'shadow' denir" | Hâl eki hatası. |
| shade | mistakes[0].why | "Türkçede tek kelime (gölge) olduğu için 'shadow' denir." → "Türkçede ikisi de 'gölge' olduğu için 'shadow' demek kolaydır. …" | Eski cümle 'shadow' denir diye okunup doğru kullanım gibi anlaşılabiliyordu. |

**Genel bulgular**

- Kartlar genel olarak iyi: tanımlar doğru, ilk örnekler kısa ve güvenli, IPA depo geleneğine uygun (phrasal verb'ler `/klɪr ˈʌp/` gibi s4 ile aynı).
- **En sık 3 sorun:** (1) Türkçe çevirilerde düz çeviri ("Ocak ayı için", "Biraz gölge", "Mont al", "montsuz eve yürüdü"), 5 örnek; (2) `pour with rain` kartında üstveri ve karşılık sorunları (uydurma bayrak, register, gloss, vurgu); (3) doğal olmayan ya da bilgi cümlesi olan örnekler (rainbow 3, soaked 3).
- **Quiz, tek doğru cevap:** 10 sorunun hepsinde her şık boşluğa konup okundu; ikinci doğru cevap yok. `pour with rain`: "falling / dropping / spilling with rain" İngilizcede doğal değil (doğal olanlar "pelting / teeming / bucketing", şıklarda yok); Türkçe 'boşanmak/dökülmek' aktarımını sınadığı için iyi çeldiriciler, kaldı. `thunder / lightning / rainbow` birbirinin çeldiricisi: "heard loud rainbow", "a flash of thunder", "saw a big thunder" açıkça yanlış; tek cevap kesin. Yalnızca `clear up` çeldiricileri değişti.
- **Çeldirici sayımı:** Yeni şıklar (clouded over, fell down, turned off) s16'da başka yerde yok. part_03'teki tekrar edenler (thunder 2, puddle 2, heat 2, chilly 2, dry 2) sınırın altında.
- **Hatalar:** `clear up` ("the weather opened") ve `shade` ("sit in the shadow") gerçek Türk öğrenci hataları, kaldı. Diğer kartlarda uydurma hata yok, boş listeler doğru.
- **s2 ile tutarlılık:** `boiling`/`freezing` notları birbirine karşıt olarak gönderme yapıyor; örnekler s2'deki freezing, humid, chilly, storm, heatwave örneklerini tekrar etmiyor (tek benzerlik, pour with rain 1. örneği, değiştirildi).
- Seviye değişmedi.

**Yazar şüphelerine kararlar**

1. *pour with rain IPA:* Ana vurgu "pour" üzerine alındı: US `/ˈpɔːr wɪð ˌreɪn/`, UK `/ˈpɔː wɪð ˌreɪn/`. "rain" bu kalıpta tahmin edilebilir bilgi olduğu için konuşmada vurgusuz kalır.
2. *micro tanımı ve register:* Micro "water falls hard from clouds" yapıldı. Register `neutral` (sözlüklerde etiket yok; informal olan "bucket down").
3. *gloss:* "bardaktan boşanmak" deyimin kesik hâli olduğu için gloss yapılmadı. Gloss: "şakır şakır yağmak". Deyim alt'ta "bardaktan boşanırcasına" biçiminde (24 sınırına sığıyor), örneklerde tam hâliyle duruyor. "sağanak yağmak" yerleşik değil, çıkarıldı.
4. *"The weather opened":* Gerçek. "Hava açtı" kelime kelime aktarımı Türk öğrencilerde yaygın; kaldı. (İngilizcede "the heavens opened" tam tersine "sağanak başladı" demek; nota eklenmedi, A2 için fazla.)
5. *Etimolojiler:* Üçü de doğru, "high" kalabilir. rainbow < OE *regnboga* (rain + bow). thunder < OE *þunor*; Thor (Norse *Þórr*) ve Thursday (OE *Þunresdæg*, "Thunor'un günü") aynı Germen kökünden. shade ve shadow ikisi de OE *sceadu*'dan (biri yalın, biri çekimli biçimden).

### part_04 (denetçi)

Değişen kart: 7/10 (season, go for a walk, fresh air, have a picnic, go camping, forest, view). Alan: 10. Reddedilen: 0. Doğrulayıcı (`--strict part_04.json`): `10 kart · 10 şemadan geçti · 0 hata · 0 uyarı`.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.season.n.1 | l1.tr.note | tatil sezonu (holiday season) → turizm sezonu (tourist season) | 'Holiday season' (özellikle ABD'de) Noel–yılbaşı dönemi demek; Türkçedeki 'tatil sezonu' (yaz) ile örtüşmüyor. |
| en.season.n.1 | examples[2].en | Kenji's town gets a lot of rain in the rainy season. → In Thailand, the rainy season starts in May. | Eski cümle kendini tekrar ediyordu (yağmur mevsiminde çok yağmur); Türkçesi de 'yağmur … yağmur … yağmur' diye okunuyordu. |
| en.season.n.1 | examples[2].tr | Kenji'nin kasabasına yağmur mevsiminde çok yağmur yağar. → Tayland'da yağmur mevsimi mayısta başlar. | Yeni örneğe uygun. |
| en.go_for_a_walk.phr.1 | quiz.distractors | went for a drive, stayed at home, went to work → made a walk, did a walk, went to a walk | 'went for a drive' bağlamla çelişiyor ama aynı kalıbı sınamıyordu; 'stayed at home … in the park' ve 'went to work … with the dog' hiç ilgisizdi. Yeni şıklar 'yürüyüş yapmak' aktarımının gerçek hata biçimleri. 'took a walk', 'went on a walk' ve 'went to walk' (amaç) doğru olabileceği için bilerek seçilmedi. |
| en.fresh_air.phr.1 | quiz.distractors | hot water, homework, sleep → dirty air, smoke, dust | 'get some sleep' dilbilgisi ve eşdizim olarak oturuyordu; 'homework', 'hot water' ilgisizdi. Yeni şıklar aynı türden (dışarıdaki havada olan şeyler) ama 'I need to … get some ___' cümlesinde açıkça yanlış. |
| en.have_a_picnic.phr.1 | quiz.distractors | have a shower, go to bed, do the dishes → make a picnic, do a picnic, go a picnic | Eski şıklar yalnızca anlamsızlığı sınıyordu ve s14 (ev) konusuna kayıyordu. Yeni şıklar 'piknik yapmak' aktarımının hata biçimleri. |
| en.go_camping.phr.1 | quiz.distractors | go bowling, go dancing, go skating → go to camping, make camping, go skating | Bağlam (tent, sleeping bags) cevabı zaten zorunlu kılıyordu ama soru, kartın asıl tuzağını ('go to camping') sınamıyordu. Bir anlam çeldiricisi (go skating) kaldı. |
| en.forest.n.1 | word_family | [forests (n)] → [] | Çoğul biçim kelime ailesi değildir. |
| en.view.n.1 | quiz.distractors | noise, weather, taste → noise, map, taste | 'The weather of the mountains is beautiful from here' dilbilgisi olarak kurulabiliyordu. 'map' aynı türden (isim) ama 'from here' ile açıkça yanlış. |

Çeldirici tekrarı: yeni şıkların hiçbiri s16'nın başka part'larında yok.

**Genel bulgular**

- Kartların içeriği (tanım, örnek, çeviri, IPA) genel olarak iyiydi; ilk örnekler kısa ve kilit ekranına uygun. Konu kayması yok (yalnızca picnic quiz'indeki ev işleri şıkları, değişti).
- **En sık sorun: quiz çeldiricileri** (5 kart). Ya kalıbı sınamıyordu (cümleyle ilgisiz eylemler) ya da biri dilbilgisi olarak oturuyordu (sleep, weather). Eşdizim kartlarında (walk, picnic, camping) gerçek Türkçe kaynaklı hata biçimleri çeldirici yapıldı.
- Kendi kendini tekrar eden örnek (season ex3) ve yanıltıcı karşılık örneği (holiday season) düzeltildi.
- Kelime ailesinde çoğul biçim (forest → forests) silindi.
- IPA: 10 kartın hepsi depo geleneğine uyuyor (US 'air' /ɛr/, DRESS /ɛ/, tek heceli kelimede vurgu yok, kalıpta tek ana vurgu).
- Etimolojiler (season, nature, hill, lake, forest, view) doğru; kalıp ifadelerde `null`.
- Seviye değişmedi (hepsi A2, uygun).

**Yazar şüphelerine kararlar**

1. **Hatalar:** Üçü de kaldı. 'make a walk' ('yürüyüş yapmak') ve 'made a picnic' ('piknik yapmak') bilinen 'yapmak → make' aktarımları. 'take fresh air' ('temiz hava almak', 'almak → take') de yaygın bir Türk öğrenci hatası; 'almak → take' aktarımı çok üretken (take a decision vb.). Üçü içinde en az kesin olan bu, ama silinecek kadar şüpheli değil.
2. **Lake Van:** Kaldı. Türkçedeki 'Van Gölü' sırası, Türkiye'de üretilen İngilizce metinlerde 'Van Lake', 'Salda Lake' gibi biçimlerin çok görülmesine yol açıyor; Türk kullanıcı için yararlı. Standart biçim 'Lake Van', 'Lake Tuz'. 'genellikle' sözcüğü istisnaları (Crater Lake, Salt Lake) kapsıyor.
3. **Kalıp IPA:** Uyumlu. Depoda 'go' ve 'have' hafif fiil olarak vurgusuz yazılıyor (go out /ɡəʊ ˈaʊt/, have fun /hæv ˈfʌn/, have a look). 'fresh air' /ˌfrɛʃ ˈɛr/ ile 'last night' /ˌlɑːst ˈnaɪt/ aynı yapıda. US /ɛr/, depodaki 'where', 'care' ile tutarlı.
4. **Etimoloji:** hill: Old English 'hyll', Latince 'collis' ile aynı Hint-Avrupa kökünden; doğru, medium kaldı. forest: Geç Latince '(silva) forestis', Latince 'foris' (dışarıda) ile ilişkilendirilir; Germen kökü önerisi de olduğu için 'probably' ve medium uygun. İkisi de değişmedi.
5. **hill / yokuş:** Değişmedi. 'Yokuş' gerçek bir karşılık (up/down the hill = yokuş yukarı/aşağı), alt'ta ve notta açıklanıyor; 3. örnek bu anlamı gösteriyor. Karşılık çeviride görünüyor ('yokuş' bir karşılık). İlk iki örnek ana karşılık 'tepe'yi gösteriyor.

### part_05 (denetçi)

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.wave.n.1 | examples[1].tr | Deniz ve Leo kumun üstüne oturup dalgaları dinlediler. → Deniz ve Leo kuma oturup dalgaları dinlediler. | 'kumun üstüne oturmak' yapay; Türkçede 'kuma oturmak' denir. |
| en.wave.n.1 | quiz.distractors | ["cliff", "shell", "path"] → ["shell", "pebble", "island"] | 'cliff' valley sorusunda da vardı; 'path' konu dışıydı. Yeniler deniz kıyısında görülen şeyler ama "a huge ___ hit the rocks" cümlesinde açıkça yanlış ('huge pebble' çelişkili; ada ve deniz kabuğu çarpmaz). 'storm' ve 'tide' ikinci doğru cevap olabileceği için seçilmedi. |
| en.shore.n.1 | quiz.distractors | ["bridge", "tower", "roof"] → ["deck", "field", "mountain"] | Eskiler kolay ve konu dışıydı (bridge ve tower akışta 2. kez geçiyordu). 'deck' teknenin parçası, "swam away from the boat" ile çelişiyor; 'field' ve 'mountain' kumla ve yüzerek dönmekle çelişiyor. 'beach', 'coast', 'island', 'rocks', 'cave', 'harbor', 'bottom' ikinci doğru cevap olabileceği için seçilmedi. |
| en.valley.n.1 | quiz.cloze | The river runs through a green ______ between two high mountains. → We walked down the mountain into a green ______ with a small river in the middle. | Eski cümle 3. örnekle ("A cold river runs through the valley") ve def.long ile neredeyse aynıydı. Şıklar (peak, cliff, desert) yeni cümlede de açıkça yanlış ('green desert', dağdan inip 'peak'e girmek). |
| en.countryside.n.1 | ipa.uk | /ˈkʌntrisaɪd/ → /ˈkʌntriˌsaɪd/ | US ile tutarlı; son hece tam ünlülü ve ikincil vurgulu (depodaki babysit, grandparent gibi). |
| en.countryside.n.1 | l1.tr.alt | ["kır", "taşra"] → ["kır"] | 'taşra' büyük şehir/başkent dışındaki yerleri (küçük şehirler dahil) anlatır, doğa ve tarla çağrışımı yok; yanlış karşılık olurdu. |
| en.countryside.n.1 | l1.tr.note | 'Country' ülke demektir; kır, kırsal yer için 'countryside' kullanılır. Genelde 'the' ile söylenir: in the countryside. → 'Country' çoğunlukla 'ülke' demektir. Kırlar ve kırsal yerler için 'countryside' denir. 'In the country' de bazen 'kırda' anlamında kullanılır. | 'Country' hiç kır anlamına gelmiyormuş gibi okunuyordu (live in the country doğru İngilizce). 'the' bilgisi zaten hata maddesinde; tekrar kaldırıldı. |
| en.countryside.n.1 | l1.tr.mistakes[0].why | Türkçede 'kırsalda' derken bir tanımlık yok; ... → Türkçede 'the' gibi bir tanımlık yok, bu yüzden 'the' kolayca düşer. Oysa bu sözcük neredeyse hep 'the' ile kullanılır: in the countryside. | Nedeni daha açık: Türkçede hiç tanımlık yok (yalnızca 'kırsalda' değil). |
| en.countryside.n.1 | quiz.distractors | ["airport", "stadium", "subway"] → ["capital", "desert", "jungle"] | Eskiler konu dışı şehir yapılarıydı. Yeniler yer adları ama cümlede açıkça yanlış: 'capital' "left the city" ile, 'desert' ve 'jungle' "cows and fields" ile çelişiyor. 'country' bilerek konmadı: "in the country" bu cümlede doğru olurdu. 'mountains', 'suburbs', 'village' de aynı nedenle seçilmedi. |
| en.melt.v.1 | def.short | ...into water because of heat → ...into a liquid because of heat | Tereyağı ve çikolata eriyince su olmaz (def.long da 'liquid' diyor). |
| en.melt.v.1 | quiz.cloze / answer | Eat your ice cream fast before it ______ in the hot sun. (melts) → I left the chocolate in the car on a hot day, and it ______. (melted) | Eski cümle 2. örnekle ("Eat your ice cream quickly, Selin. It's melting!") neredeyse aynıydı. |
| en.melt.v.1 | quiz.distractors | ["freezes", "boils", "grows"] → ["froze", "boiled", "grew"] | Yeni cümlenin zamanına uyduruldu; sıcak arabada donmak, kaynamak, büyümek açıkça yanlış. |

Değişen kart: 5/5 (hepsine `critic_edited`), değişen alan: 13. Reddedilen: 0.
Doğrulayıcı: `5 kart · 5 şemadan geçti · 0 hata · 0 uyarı`

**Genel bulgular**

- Kartlar genelde sağlamdı: anlamlar, tanımlar, IPA (countryside dışında), seviye (hepsi B1, uygun) ve örneklerin çoğu doğru.
- **En sık sorun quiz'di (5/5 kartta değişti):** konu dışı çeldiriciler (shore: bridge/tower/roof; countryside: airport/stadium/subway), 'cliff' tekrarı ve iki kartta (valley, melt) quiz cümlesinin bir örneğin neredeyse aynısı olması. Yeni şıklar doğa/kıyı/yer türünden; her biri boşluğa konup ikinci doğru cevap olmadığı kontrol edildi.
- **Çeldirici sayımı (s16 bütünü):** yeni şıkların hiçbiri akışta daha önce yok; yalnızca 'desert' 2 → 3 (part_04 forest, part_05 valley, countryside). 'cliff' artık 1 kez.
- **countryside Türkçe katmanı:** 'taşra' çıkarıldı; not 'country' = 'ülke' ayrımını korudu ama "the country = kır" kullanımını da yanlışlamayacak biçimde yazıldı.
- `tags.flags` içindeki `confusable:country` doğru biçimde (prompts.py'deki `confusable:<word>` kalıbı) ve yararlı: not ve hata maddesi bu karışıklığı işliyor. Kaldı. `uncountable` da doğru.
- Etimoloji: valley (Eski Fransızca valee < Latince vallis) ve melt (Eski İngilizce meltan) standart sözlüklerde aynen geçiyor, "high" kalabilir. wave (fiilden türeme, kökeni karışık) ve shore (Orta Hollandaca/Aşağı Almanca 'schōre' ile ilişkili, kesin değil) için null doğru.

**Yazar şüphelerine kararlar**

1. countryside hatası "in countryside": **Kaldı.** Genel bir artikel hatası ama doğrudan Türkçeden geliyor (Türkçede tanımlık yok) ve bu sözcükte özellikle sık; part_04'teki `nature` ("the nature", ters yön) ile birlikte iyi bir karşıtlık kuruyor. `why` daha açık yazıldı.
2. "taşra": **Çıkarıldı** (merkez dışı küçük şehir çağrışımı; countryside'ın karşılığı değil). gloss 'kırsal kesim', alt ['kır'], equivalence partial kaldı.
3. shore quiz'inde "lay on the sand" bağlamı 'beach'i çağırıyor: Şıklarda beach/coast yok, sorun değil; cümle 'shore' için de tamamen doğal. Çeldiriciler aynı türden ama açıkça yanlış olanlarla değişti.
4. countryside IPA: **İkisi de /ˈkʌntriˌsaɪd/** (ikincil vurgulu).
5. Etimoloji: valley ve melt doğru, "high" kaldı; wave ve shore null kaldı.

### Koordinatör (bağımsız doğrulama sonrası)

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.the_day_after_tomorrow.phr.1 | examples.2.tr | Bugün ve yarın meşgulüm. Öbür gün buluşabilir miyiz Leyla? → Bugün ve yarın meşgulüm. Öbür gün buluşabilir miyiz, Leyla? | TDK: hitaptan önce virgül (Türkçe doğrulayıcı). |
| en.the_day_before_yesterday.phr.1 | l1.tr.gloss | evvelsi gün → evvelki gün | 'Evvelsi gün' bölgesel/eski kokuyor; TDK maddesi ve yaygın biçim 'evvelki gün' (Türkçe doğrulayıcı; denetçi de sormuştu). |
| en.the_day_before_yesterday.phr.1 | examples.0.tr | Evvelsi gün kar yağdı. → Evvelki gün kar yağdı. | Gloss ile uyum. |
| en.the_day_before_yesterday.phr.1 | examples.1.tr | Evvelsi gün Murat'ı aradım ama açmadı. → Evvelki gün Murat'ı aradım ama açmadı. | Gloss ile uyum. |
| en.the_day_before_yesterday.phr.1 | examples.2.tr | Evvelsi gün benim doğum günümdü ve güzel, güneşli bir gündü. → Evvelki gün benim doğum günümdü ve güzel, güneşli bir gündü. | Gloss ile uyum. |
| en.last_night.phr.1 | def.micro | yesterday evening → yesterday, after dark | 'yesterday evening' anlamı daraltıyordu; kartın karşılığı 'dün gece' (İngilizce doğrulayıcı). |
| en.last_night.phr.1 | examples.2.en | Last night we sat outside and looked at the stars with Daniel. → Last night Daniel and I sat outside and looked at the stars. | Sondaki 'with Daniel' yanlış yerdeydi, okurken takılıyordu (İngilizce doğrulayıcı). Çeviri aynı kaldı. |
| en.last_night.phr.1 | collocations | ["late last night", "sleep last night"] → ["late last night", "since last night"] | 'sleep last night' gerçek bir eşdizim değil (İngilizce doğrulayıcı); 'since last night' A2 için daha yararlı (son kontrol). |
| en.these_days.phr.1 | l1.tr.alt | ["bu günlerde", "son zamanlarda"] → ["bugünlerde", "son zamanlarda"] | TDK: zarf 'bugünlerde' bitişik yazılır (Türkçe doğrulayıcı). |
| en.these_days.phr.1 | examples.2.tr | Hava çok güzel olduğu için Sofia bu günlerde işe yürüyerek gidiyor. → Hava çok güzel olduğu için Sofia bugünlerde işe yürüyerek gidiyor. | TDK: 'bugünlerde' bitişik. |
| en.these_days.phr.1 | quiz.cloze | Winters were very cold when I was a child, but ______ it doesn't snow much. → Winters were very cold when I was a child, but ______ they are much warmer. | 'it doesn't snow much' 2. örnekle örtüşüyordu (quiz doğrulayıcı). Şıklar aynı, hâlâ tek doğru cevap. |
| en.in_a_while.phr.1 | def.long | After a short time from now; we do not say exactly how long. It is about the future, for example: 'I'll call you in a while.' → After a short time from now; we do not say exactly how long. For example: 'I'll call you in a while.' In negative sentences, 'I haven't seen you in a while' means for a long time. | 'It is about the future' mutlak söylenmişti; olumsuz cümledeki 'uzun zamandır' anlamı eksikti (İngilizce doğrulayıcı). Bu kullanım yalnızca Amerikan İngilizcesine ait değil (son kontrol). |
| en.in_a_while.phr.1 | l1.tr.note | 'For a while' bir süre boyunca demektir: 'I waited for a while.' 'In a while' ise birazdan demektir ve gelecekle ilgilidir. → 'For a while' bir süre boyunca demektir: 'I waited for a while.' 'In a while' ise birazdan demektir. Olumsuz cümlede 'uzun zamandır' anlamına da gelir: I haven't seen him in a while. | Aynı neden; not tanımla uyumlu. |
| en.in_a_while.phr.1 | examples.2.tr | Git oyna Nil. Yemek az sonra hazır olur. → Git oyna, Nil. Yemek az sonra hazır olur. | TDK: hitaptan önce virgül. |
| en.in_a_while.phr.1 | quiz.distractors | ["an hour ago", "next year", "since Monday"] → ["an hour ago", "next year", "a while ago"] | 'since Monday' yalnızca dilbilgisini sınıyordu; 'a while ago' in/ago karışıklığını sınar ve 'will stop' ile açıkça yanlış (quiz doğrulayıcı). |
| en.so_far.phr.1 | l1.tr.alt | ["şu ana kadar", "şimdilik"] → ["şu ana kadar", "bugüne kadar"] | 'şimdilik' = 'for now'; anlamı kaydırıyordu (Türkçe doğrulayıcı). |
| en.for_ages.phr.1 | examples.0.tr | Seni görmeyeli uzun zaman oldu! → Seni görmeyeli yıllar oldu! | 'for ages' abartısı Türkçede de abartıyla verildi (Türkçe doğrulayıcı); alt'ta 'yıllardır' var. |
| en.for_ages.phr.1 | l1.tr.note | Gündelik ve abartılı bir ifadedir; süre gerçekten yıllar olmayabilir. 'It took ages' (çok uzun sürdü) de çok kullanılır. → Gündelik ve abartılı bir ifadedir; süre gerçekten yıllar olmayabilir. 'It took ages' (çok uzun sürdü) de çok kullanılır. Olumsuz cümlede 'in ages' de denir: I haven't seen you in ages. | Olumsuzdaki 'in ages' biçimi eklendi (İngilizce doğrulayıcı); yalnızca Amerikan değil (son kontrol). |
| en.for_ages.phr.1 | quiz.cloze | Where have you been? I haven't seen you ______! → Hurry up! You've been on the phone ______! | Eski cümle 1. örneğin, ilk düzeltme 2. örneğin neredeyse aynısıydı (quiz ve son kontrol doğrulayıcıları). Şıklar present perfect ile açıkça yanlış. |
| en.any_minute_now.phr.1 | examples.1.tr | Şemsiyeni al. Her an yağmur başlayacak. → Şemsiyeni al. Her an yağmur başlayabilir. | 'Her an' kesin gelecekle ('başlayacak') doğal değil (Türkçe doğrulayıcı). |
| en.any_minute_now.phr.1 | quiz.distractors | ["next year", "in ten years", "next winter"] → ["a minute ago", "every minute", "next winter"] | Üç şık da uzak gelecekti, aynı mantıkla eleniyordu; 'minute' ifadelerini ayırt etmeyi sınar (quiz doğrulayıcı). |
| en.at_the_last_minute.phr.1 | sense_note | very late, just in time → very late, just before the time | 'just in time' iptal örneğine uymuyordu (İngilizce doğrulayıcı). |
| en.at_the_last_minute.phr.1 | def.long | Very late, just before an event starts or just before it is too late to do something. Plans that change like this can be stressful. → Very late, just before an event starts or just before it is too late to do something. People often use it about plans that change. | 'can be stressful' tanıma bir şey katmayan yorumdu. |
| en.every_other_day.phr.1 | sense_note | once in two days → every second day | 'once in two days' doğal İngilizce değil (İngilizce doğrulayıcı). |
| en.every_other_day.phr.1 | def.short | once in two days, for example on Monday, Wednesday and Friday → once every two days, for example on Monday, Wednesday and Friday | Aynı neden. |
| en.every_other_day.phr.1 | def.long | Once in two days: you do something one day, skip the next day, then do it again. People use it for habits like sport or watering plants. → Once every two days: you do something one day, skip the next day, then do it again. People use it for habits like sport or watering plants. | Aynı neden. |
| en.be_running_late.phr.1 | l1.tr.alt | ["gecikmek", "rötar yapmak"] → ["gecikmek"] | 'rötar yapmak' yalnızca araçlar için; kişi için kullanılmaz (denetçi ve Türkçe doğrulayıcı). |
| en.be_running_late.phr.1 | l1.tr.note | Genelde şimdiki zamanla, hâlâ yoldayken söylenir: 'I'm running late' (geç kalıyorum). Varmışsan ve geç kalmışsan 'I'm late' denir. → Genelde hâlâ yoldayken, plandan geride olduğunu söylemek için kullanılır: 'I'm running late' (geç kalıyorum). 'I'm late' ise genel olarak 'geç kaldım' demektir; yolda da, varınca da söylenir. | Eski not 'I'm late'in yalnızca varınca söylendiğini ima ediyordu (Türkçe doğrulayıcı). |
| en.time_flies.idm.1 | examples.1.en | Time flies when you're having fun with friends. → Time flies when you're having fun! | Kalıp bu biçimde; sondaki 'with friends' kalıbı bozuyordu (İngilizce doğrulayıcı). |
| en.time_flies.idm.1 | examples.1.tr | Arkadaşlarla eğlenirken zaman su gibi geçer. → Eğlenirken zaman su gibi geçer! | Yeni cümleye göre. |
| en.time_flies.idm.1 | l1.tr.note | Türkçedeki 'zaman su gibi akıp geçiyor' sözüne çok yakındır. Genelde biraz şaşırarak söylenir. → Genelde biraz şaşırarak söylenir. 'Time flies when you're having fun' (eğlenirken zaman çabuk geçer) kalıbı da çok yaygındır. | Not gloss'u tekrar ediyordu (Türkçe doğrulayıcı). |
| en.degree.n.1 | l1.tr.mistakes.0.why | Türkçede sayıdan sonra isim tekil kalır (30 derece). İngilizcede birden büyük sayılardan sonra çoğul gerekir: 30 degrees. → Türkçede sayıdan sonra isim tekil kalır (30 derece). İngilizcede 1 dışındaki sayılardan sonra çoğul gerekir: 30 degrees, zero degrees. | 'birden büyük sayılar' eksikti: 0 da çoğul alır (Türkçe doğrulayıcı). |
| en.degree.n.1 | etymology.text | From Old French 'degré', which comes from Latin 'gradus', meaning a step. → From Old French 'degré', from Latin 'de-' + 'gradus', meaning a step. | Sözcük doğrudan 'gradus'tan değil, 'de- + gradus'tan geliyor (İngilizce doğrulayıcı). |
| en.below_zero.phr.1 | l1.tr.alt | ["eksi derecede"] → ["eksilerde"] | 'eksi derecede' yapay; konuşmada 'hava eksilerde' denir (Türkçe doğrulayıcı). |
| en.below_zero.phr.1 | examples.2.en | When it's below zero, the lake freezes and children skate on it. → When it's below zero, the roads get icy, so drive carefully. | Eski cümle `lake` kartının 3. örneğiyle neredeyse aynıydı (göl donar, çocuklar paten kayar). |
| en.below_zero.phr.1 | examples.2.tr | Hava sıfırın altındayken göl donar ve çocuklar üstünde paten kayar. → Hava sıfırın altındayken yollar buz tutar, o yüzden dikkatli sür. | Yeni cümleye göre. |
| en.get_dark.phr.1 | l1.tr.alt | ["karanlık olmak", "akşam olmak"] → ["karanlık basmak", "karanlık olmak"] | 'akşam olmak' ışığı değil zamanı anlatıyor (Türkçe doğrulayıcı). |
| en.pour_with_rain.phr.1 | l1.tr.alt | ["bardaktan boşanırcasına", "çok şiddetli yağmak"] → ["bardaktan boşanırcasına", "sicim gibi yağmak"] | 'çok şiddetli yağmak' açıklama gibiydi (Türkçe doğrulayıcı). Doğrulayıcının önerdiği 'sağanak yağmak'ı denetçi yerleşik bulmamıştı; yerleşik deyim 'sicim gibi yağmak' seçildi. |
| en.pour_with_rain.phr.1 | quiz.cloze | Don't go out without an umbrella. It's ______ with rain! → The football match was cancelled because it was ______ with rain. | Eski cümle 1. örnekle, ilk düzeltme de 2. örnekle neredeyse aynıydı (quiz ve son kontrol doğrulayıcıları). Şıklar aynı. |
| en.clear_up.phv.1 | quiz.distractors | ["clouded over", "fell down", "turned off"] → ["clouded over", "cleaned up", "closed up"] | 'fell down' ve 'turned off' gökyüzüyle ilgisizdi; 'cleaned up' clear/clean karışıklığını sınar (quiz doğrulayıcı). |
| en.boiling.adj.1 | examples.0.register | neutral → informal | tags.register 'informal' ile örneklerin register'ı tutarlı olsun (İngilizce doğrulayıcı). |
| en.boiling.adj.1 | examples.1.register | neutral → informal | Aynı neden. |
| en.boiling.adj.1 | examples.2.register | neutral → informal | Aynı neden. |
| en.soaked.adj.1 | examples.1.tr | Burak eve montu olmadan yürüdü ve sırılsıklam oldu. → Burak montsuz yürüyerek eve döndü ve sırılsıklam oldu. | 'montu olmadan eve yürüdü' düz çeviri kokuyordu (Türkçe doğrulayıcı). |
| en.breeze.n.1 | examples.2.tr | Akşam hafif bir meltem, sıcak günü çok daha katlanılır hâle getirdi. → Akşam esen hafif bir meltem sayesinde sıcak gün çok daha rahat geçti. | 'katlanılır hâle getirdi' çeviri kokuyordu (Türkçe doğrulayıcı). |
| en.lightning.n.1 | quiz.cloze | During the storm, a flash of ______ hit the tall tree in the park. → The old house on the hill was hit by ______ during the storm, and the TV stopped working. | Eski cümle 3. örnekle neredeyse aynıydı; 'a flash of lightning hit' de doğal değildi (İngilizce ve son kontrol doğrulayıcıları). 'hit by thunder' Türk öğrencinin gerçek karışıklığını sınar. |
| en.lightning.n.1 | quiz.distractors | ["thunder", "moonlight", "mist"] → ["thunder", "fog", "mist"] | 'moonlight hit the tree' ('ay ışığı ağaca vurdu') yeni cümlede kabul edilebilir okunabilirdi; 'fog' ile değişti. |
| en.nature.n.1 | examples.0.en | We spent the weekend in nature, far from the city. → We spent the weekend out in nature, far from the city. | 'spent the weekend in nature' Türkçe kokuyordu; anadili İngilizce olan 'out in nature' der (İngilizce doğrulayıcı). |
| en.nature.n.1 | l1.tr.note | 'Nature' bir kişinin huyu, yaradılışı anlamına da gelir: 'She is kind by nature.' (O, yaradılıştan naziktir.) → 'Nature' bir kişinin huyu, yaradılışı anlamına da gelir: 'She is kind by nature.' (Yaradılıştan nazik biridir.) | '(O, yaradılıştan naziktir.)' kitabi (Türkçe doğrulayıcı). |
| en.go_for_a_walk.phr.1 | quiz.distractors | ["made a walk", "did a walk", "went to a walk"] → ["made a walk", "went for walk", "went to a walk"] | 'did a walk' İngiliz kullanımında sınırda kabul edilebilir; 'went for walk' (artikel düşmesi) kesin yanlış (quiz doğrulayıcı). |
| en.hill.n.1 | etymology.text | From Old English 'hyll'. It is related to Latin 'collis', which also means a small mountain. → From Old English 'hyll'. It is related to Latin 'collis', meaning hill. | 'a small mountain' kartın kendi tanımını tekrar ediyordu (İngilizce doğrulayıcı). |
| en.forest.n.1 | examples.0.tr | Bu ormanda çok sayıda uzun ağaç var. → Bu ormanda bir sürü uzun ağaç var. | 'çok sayıda' yazı dili; kilit ekranı için konuşma dili (Türkçe doğrulayıcı). |
| en.view.n.1 | examples.0.tr | Tepeden manzara harika. → Tepeden görünen manzara harika. | 'Tepeden manzara harika' eksiltili ve kopuk (Türkçe doğrulayıcı). |
| en.melt.v.1 | examples.1.tr | Dondurmanı çabuk ye Selin. Eriyor! → Dondurmanı çabuk ye, Selin. Eriyor! | TDK: hitaptan önce virgül. |
| en.countryside.n.1 | examples.0.tr | Büyükannemle büyükbabam kırsalda yaşıyor. → Büyükannemle büyükbabam kırsal kesimde yaşıyor. | Gloss 'kırsal kesim' ile uyum (Türkçe doğrulayıcı). |
| en.degree.n.1 | quiz.distractors | ["minutes", "meters", "percent"] → ["minutes", "meters", "kilos"] | 'percent' çoğul biçim almıyor; şıklar cevapla (degrees) aynı biçimde olsun (çeldirici kuralı 1, son kontrol). |

## Anadili Türkçe birinin bakması gerekenler

Denetçilerin ve doğrulayıcıların listeleri birleştirildi; sonradan düzeltilenler çıkarıldı.

1. `the day before yesterday` gloss'u 'evvelki gün' (TDK maddesi). Yazar 'evvelsi gün' yazmıştı; denetçi 'önceki gün'ü önerdi (alt'ta). Hangisi en doğal?
2. `the day after tomorrow` gloss'u 'öbür gün': bazı yörelerde belirsiz 'başka bir gün' gibi de kullanılıyor. 'yarından sonraki gün' alt'ta.
3. `half an hour` 1. örnek: "Yarım saate hazır olurum." doğal mı? (alternatif: "Yarım saat içinde hazır olurum.")
4. `any minute now` notu: "'her an' bazen 'her zaman' anlamına da gelir ('her an yanındayım')". Bu ayrım öğrenciye yararlı mı, kafa mı karıştırıyor?
5. `below zero` 2. örnek: "Dün gece sıcaklık sıfırın altında on dereceydi." ('eksi on derece' daha doğal ama kalıbın karşılığı kaybolur). Alt: 'eksilerde'.
6. `pour with rain`: gloss 'şakır şakır yağmak', alt 'bardaktan boşanırcasına' (deyimin zarf biçimi) ve 'sicim gibi yağmak'.
7. `boiling` notu: "'I'm boiling.' = Çok sıcakladım." (alternatif: "Sıcaktan pişiyorum.")
8. Yaygınlığı derlemle doğrulanmamış hatalar: 'take fresh air' (temiz hava almak), "Let's meet the other day" (öbür gün), "The weather opened" (hava açtı), "Van Lake" (Van Gölü). Hepsini denetçi ve Türkçe doğrulayıcı gerçek buldu.
9. `countryside`: gloss 'kırsal kesim', alt 'kır'; 1. örnek "Büyükannemle büyükbabam kırsal kesimde yaşıyor." Kilit ekranında 'kır, kırsal bölge' daha sıcak durabilir.
10. `hill` 3. örnek 'yokuşu çıkmak' (alt 'yokuş'): 'tepeye çıkmak' mı olmalı?
11. `wave` 3. örnek: "Büyük bir dalga kumsala kadar geldi…" ('came up the beach') doğal mı?
12. `season` notu: 'turizm sezonu' (tourist season).
13. Doğrulama sonrası yeni çeviriler: `breeze` 3. örnek "Akşam esen hafif bir meltem sayesinde sıcak gün çok daha rahat geçti.", `soaked` 2. örnek "Burak montsuz yürüyerek eve döndü ve sırılsıklam oldu."

## Çeldirici kontrolü (2026-10-22)

- Sınır (max(4, %5)) yazarlara baştan verildi; denetçiler de yeni şık seçerken öteki partlara baktı. Bu yüzden çeşitlendirme gerekmedi ve `distractors_diversified` bayrağı eklenmedi.
- Önce (yazım sonrası, ilk tam ölçüm): en sık şıklar 2 soruda (a week ago, next weekend, next month, since Monday, last summer, getting up, chilly, dry).
- Sonra (`distractor_stats.py`): `s16: 45 quizzes, 125 distinct distractors; top: desert×3, a year ago×2, dry×2, chilly×2, puddle×2, thunder×2`. Hiçbir şık 4'ten fazla soruda geçmiyor.
- Biçim kuralı (bağımsız kontrol, 45 soru): geçmiş zaman, -ing, çoğul ve phrasal verb cevaplarında şıklar aynı biçimde. Tek istisna `degree`'deki 'percent' idi (çoğul almıyor); 'kilos' ile değişti.
- Bu adımda değişen kart: 4 (`lightning`, `pour with rain`, `for ages` cümleleri ve `degree` şıkkı; ayrıntı koordinatör tablosunda). Cümlesi değişen 3 kartın yeni cümlesi bir önceki düzeltmede başka bir örneğe yaklaşmıştı; yeni cümleler kartın örneklerinden ayrışıyor ve şıklar aynı kaldı.
- Son kontrol, koordinatör tablosundaki her satırı kartla karşılaştırdı ve değişen 8 quiz'in her şıkkını boşluğa koyarak okudu: ikinci doğru cevap yok (YÜKSEK 0).
- Doğrulayıcı: `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`
