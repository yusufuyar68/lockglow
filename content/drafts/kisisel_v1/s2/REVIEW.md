# s2 QA incelemesi (şehir, ulaşım, seyahat, zaman, hava, teknoloji, okul, hobi, doğa, müzik/film)

Akış: s2 · 13 dosya (part_01 ... part_13) · tarih: 2026-10-12.
Yöntem: Her kart tek tek okundu. Rubrik: `prompts.py` SYSTEM_C. Kalite çıtası: `veri/ornek_kelime_seti_25.json`.
Düzenlemeler metin düzeyinde yapıldı. Dosya biçimi (girinti, satır sonu, UTF-8, NFC) korundu.
Düzenlenen her kartın `meta.qa_flags` alanına `critic_edited` eklendi. `id`, `lemma`, `pos`, `sense_no`, `meta.status` değişmedi.

## Sayılar

- İncelenen kart: **125**
- Değiştirilen kart: **39**
- Toplam alan düzenlemesi: **50**
- Reddedilen kart (`critic_reject`): **0**
- Doğrulayıcı (tüm klasör, `--strict`): 125 kart · 125 şemadan geçti · 0 hata · 0 uyarı

## Değişiklikler

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.bridge.n.1 | l1.tr.note | Köprü adlarının başına 'the' gelir: → Ünlü köprü adlarının başına çoğunlukla 'the' gelir: | Genelleme fazla kesin (Tower Bridge'de 'the' yok); 'çoğunlukla' yapıldı. |
| en.street.n.1 | examples[2].tr | Sokak insan ve müzik doluydu. → Sokak insanlarla ve müzikle doluydu. | 'insan ve müzik doluydu' bozuk Türkçe; 'dolu' ile -la/-le eki gerekir. |
| en.ago.adv.1 | l1.tr.mistakes[0].why | 'Önce' Türkçede kelimenin ardından gelir ama İngilizcede 'before' süreyi başa almaz; 'iki yıl önce' = 'two years ago'. → 'İki yıl önce' diye düşünüp 'before' demeyin. Geçmişte geçen süre için sayıdan sonra 'ago' gelir: two years ago. | Açıklama karışık ve yanlış yönlendiriyordu (Türkçede de 'önce' sondadır); gerçek hata 'önce' = 'before' çevirisi. |
| en.pet.n.1 | examples[2].tr | Bu binada evcil hayvan beslemek yasak. → Bu binada evcil hayvanlara izin verilmiyor. | 'Beslemek' İngilizcede olmayan bilgiyi ekliyor (allowed = izin verilir). |
| en.traffic_jam.phr.1 | examples[1].tr | Bu sabah köprüde büyük bir trafik var. → Bu sabah köprüde büyük bir trafik sıkışıklığı var. | Kartın karşılığıyla (trafik sıkışıklığı) tutarlı ve daha açık. |
| en.subway.n.1 | l1.tr.alt | ["yeraltı treni"] → [] | 'Yeraltı treni' günlük Türkçede kullanılan gerçek bir karşılık değil (calque). |
| en.subway.n.1 | examples[1].tr | Metro istasyonu buradan iki blok ötede. → Metro istasyonu buradan iki sokak ötede. | Türkçede 'blok' apartman bloğu çağrıştırır; 'two blocks' için doğal karşılık 'iki sokak'. |
| en.sidewalk.n.1 | examples[1].tr | Çocuklar bisikletlerine kaldırımda bindi. → Çocuklar kaldırımda bisiklet sürdü. | 'Bisikletlerine bindi' = bisiklete bindiler; 'rode their bikes' = bisiklet sürdüler. |
| en.roundabout.n.1 | quiz.distractors | ["sidewalk", "airport", "elevator"] → ["sidewalk", "kitchen", "elevator"] | 'Turn right at the airport' da doğru olabilir (yön tarifinde yer işareti); çeldirici net yanlış olmalı. |
| en.neighborhood.n.1 | etymology.text | '-hood' means a group or a place. → '-hood' marks a state or a group, as in 'childhood'. | '-hood' 'yer' anlamı taşımaz; durum/topluluk eki (Old English -hād). |
| en.crowded.adj.1 | quiz.cloze | I didn't go to the beach. It was too ______ on Sunday. → The bus was so ______ that I could not find a seat. | Eski cümlede 'too empty/quiet' de makul olabilirdi (birden fazla doğru cevap); yeni cümlede tek doğru cevap var. |
| en.midnight.n.1 | examples[1].tr | Uyuyamıyorum. Saat şimdiden gece yarısı! → Uyuyamıyorum. Saat gece yarısı oldu bile! | 'Şimdiden' erken olduğunu ima eder; 'already midnight' = geç oldu. |
| en.midnight.n.1 | examples[2].tr | Uçağımız gece yarısını biraz geçe iniyor. → Uçağımız gece yarısından hemen sonra iniyor. | 'Gece yarısını biraz geçe' doğal değil; 'just after midnight' = 'gece yarısından hemen sonra'. |
| en.daily.adj.1 | word_family | [{"lemma": "weekly", "pos": "adj"}] → [{"lemma": "day", "pos": "n"}] | 'Weekly' 'daily'nin sözcük ailesinden değil; asıl kök 'day'. |
| en.nowadays.adv.1 | l1.tr.alt | ["günümüzde", "artık"] → ["günümüzde", "şimdilerde"] | 'Artık' = anymore/by now; 'nowadays' için gerçek karşılık değil. |
| en.nowadays.adv.1 | examples[1].tr | Dedem mektup yazardı ama bugün biz mesaj atıyoruz. → Dedem mektup yazardı ama bugünlerde biz mesaj atıyoruz. | 'Bugün' tek bir günü anlatır; 'nowadays' = bugünlerde. |
| en.weekday.n.1 | quiz.cloze | I work from Monday to Friday, so my ______ are very busy. → Banks are open on ______, but they are closed on Saturday and Sunday. | 'so my weekends are very busy' de mantıklı (birden fazla doğru cevap); yeni cümlede tek cevap var. |
| en.download.v.1 | l1.tr.mistakes[0].why | Telefondan internete göndermek 'upload'dır. Download internetten sana almaktır. Türkçede ikisine de 'yüklemek' dediğimiz için karışır. → Telefondan internete göndermek 'upload'dır (fotoğrafı profile yüklemek). Download ise internetten telefonuna almaktır (indirmek). | 'İkisine de yüklemek deriz' yanlış: download Türkçede 'indirmek'. |
| en.upload.v.1 | examples[2].en | Please upload your CV on our website. → Please upload your CV to our website. | Kartın kendi kalıbı 'upload + file (to + site)'; 'to' daha standart. |
| en.battery.n.1 | l1.tr.note | Küçük pillere 'pil', telefon ve laptop için 'batarya' denir; arabada 'akü'dür. → Küçük pillere 'pil'; telefon ve laptop için hem 'pil' hem 'batarya' denir; arabada 'akü'dür. | Telefon pili için 'pil' de çok yaygın; 'sadece batarya' denmesi yanlış genelleme. |
| en.screenshot.n.1 | l1.tr.note | İngilizcede de kısaca 'screenshot' veya 'screen grab' denir. → İngilizcede 'screen grab' ve 'screencap' de denir ama en yaygını 'screenshot'tır. | 'Kısaca screenshot' anlamsızdı: screenshot zaten asıl sözcük. |
| en.screenshot.n.1 | l1.tr.mistakes[0] | hata cümlesi "I did a screenshot of the map." → hata cümlesi "I took screenshot of the map." (doğru cümle: "I took a screenshot of the map.") | 'Ekran görüntüsü almak' zaten 'take' ile eşleşir, 'did a screenshot' Türk öğrenci hatası değil; yerine gerçek hata (artikel eksikliği). |
| en.update.n.1 | examples[1].tr | Telefonumun güncellemesi lazım ama depolama alanı dolu. → Telefonumun güncellenmesi gerekiyor ama depolama alanı dolu. | 'Güncellemesi lazım' doğal değil; 'güncellenmesi gerekiyor' doğru. |
| en.delete.v.1 | l1.tr.note | Dosya, fotoğraf, mesaj ve uygulama silmek için hep 'delete' kullanılır. → Dosya, fotoğraf ve mesaj silmek için 'delete' kullanılır; uygulama için 'delete' veya 'uninstall' denir. | 'Hep delete' fazla kesin; uygulama için 'uninstall' da çok yaygın. |
| en.link.n.1 | l1.tr.note | bu kart internet bağlantısını anlatır. → bu kart tıkladığınız web bağlantısını anlatır. | 'İnternet bağlantısı' = internet connection; karışıklığa yol açıyordu. |
| en.settings.n.1 | examples[0].tr | Ayarları açıp karanlık modu aç. → Ayarları açıp koyu modu aç. | iPhone'da 'Koyu' görünümü / 'koyu mod' kullanılır; telefon kullanıcısının gördüğü ifade. |
| en.signal.n.1 | l1.tr.alt | ["çekim gücü"] → [] | 'Çekim gücü' = yerçekimi/çekim kuvveti; telefon sinyali için gerçek bir karşılık değil (günlük dilde 'çekmiyor' fiili kullanılır, notta var). |
| en.ride.v.1 | quiz.distractors | ["drive", "fly", "sail"] → ["swim", "fly", "sail"] | 'Drive a bike' günlük konuşmada kabul edilebilir (özellikle motosiklet); çeldirici net yanlış olmalı. |
| en.hike.v.1 | quiz.cloze | On Saturdays we like to ______ in the mountains and visit the lake. → We put on our boots and decided to ______ up the mountain. | 'Cook / shop in the mountains' de doğru olabilirdi (birden fazla cevap); 'up the mountain' ile tek cevap kalıyor. |
| en.spell.v.1 | l1.tr.note | Türkçe okunduğu gibi yazılır, bu yüzden Türkçede nadiren 'hecelemek' gerekir. İngilizcede ise çok kullanılır: 'Nasıl yazılıyor?' = 'How do you spell it?' → Türkçedeki 'hecelemek' heceleri ayırır (ka-pı); 'spell' ise harfleri tek tek söyler (K-A-P-I). 'Nasıl yazılıyor?' = 'How do you spell it?' | Asıl öğrenci tuzağı (hece vs harf) notta yoktu; eski not zayıf bir genellemeydi. |
| en.playlist.n.1 | examples[0].tr | Spor için yeni bir çalma listesi hazırladım. → Spor salonu için yeni bir çalma listesi hazırladım. | 'The gym' çeviride düşmüş. |
| en.playlist.n.1 | examples[2].tr | Bu çalma listesi uzun bir yolculuk için mükemmel. → Bu çalma listesi uzun bir araba yolculuğu için mükemmel. | 'Long drive' = uzun araba yolculuğu; 'yolculuk' bilgiyi eksiltiyordu. |
| en.band.n.1 | quiz.distractors | ["team", "class", "crowd"] → ["song", "stage", "radio"] | 'Plays the guitar in a class / team with her friends' de makul (birden fazla doğru cevap). |
| en.commute.v.1 | examples[1].tr | Gidişi de dönüşü de iki saat sürüyor. → Her gün gidişte de dönüşte de iki saat yol yapıyor. | Özne (she) ve 'commute' fiili düşmüştü; cümle genel bir süre bilgisi gibi okunuyordu. |
| en.commute.v.1 | etymology.text | a cheaper train ticket for people who traveled every day. 'Commute' first meant 'to exchange' or 'to reduce'. → a cheaper ticket for people who traveled every day. 'Commute' comes from Latin 'commutare' ('to exchange'). | 'İlk anlam: exchange ya da reduce' kesin değil; 'reduce' sonraki bir uzantı. Yalnızca kesin olan kök bırakıldı. |
| en.rush_hour.phr.1 | examples[1].tr | Yoğun saat, bu yüzden yollar dolu. → Şu an en yoğun saatler, o yüzden yollar dolu. | Eski çeviri telgraf gibi, doğal Türkçe değildi. |
| en.rush_hour.phr.1 | examples[2].tr | Sabah yoğunluğuna takılmamak için ona doğru çıktık. → Sabah trafiğine takılmamak için saat onda çıktık. | 'At ten' = saat onda; 'ona doğru' (yaklaşık on) bilgiyi değiştiriyordu. |
| en.suburb.n.1 | l1.tr.note | 'Suburb' genelde evli, bahçeli, sakin bir semttir. → 'Suburb' genelde evleri ve bahçeleri olan sakin bir bölgedir. | 'Evli, bahçeli semt' anlamsız/yanlış bir ifade ('evli' = married). |
| en.nap.n.1 | examples[1].tr | Bebek uyuyor, lütfen sessiz ol. → Bebek şekerleme yapıyor, lütfen sessiz ol. | 'Taking a nap' = kısa uyku; çeviri kartın kelimesini vermiyordu. |
| en.nap.n.1 | l1.tr.mistakes[0].why | 'Şekerleme yapmak' derken 'make' kullanılır sanılır; İngilizcede 'take a nap' veya 'have a nap' denir. → Türkçede 'şekerleme yapmak' dediğimiz için 'make' denir; İngilizcede 'take a nap' veya 'have a nap' kullanılır. | Açıklama bozuk Türkçeydi ('kullanılır sanılır'); netleştirildi. |
| en.nap.n.1 | quiz.cloze | I was so tired that I took a short ______ after lunch. → I was tired, so I lay down and took a short ______ on the sofa. | Eski cümlede 'took a short exam/lesson' da mümkündü; 'lay down' ile tek cevap kalıyor. |
| en.currently.adv.1 | l1.tr.note | 'Actually' (aslında) ile karıştırılır, ama anlamları farklıdır. → 'Actually' (aslında) ile karıştırmayın: 'güncel' anlamı 'current / currently' ile verilir. | 'Karıştırılır' iddiası belirsizdi; gerçek tuzak aktüel/actual yanlış dostu. |
| en.currently.adv.1 | quiz.distractors | ["actually", "finally", "suddenly"] → ["always", "finally", "suddenly"] | 'I'm actually living in Izmir, but...' de doğal bir cümle (iki doğru cevap). |
| en.meanwhile.adv.1 | l1.tr.mistakes[0].why | 'in the meanwhile' denmez. → 'in the meanwhile' modern İngilizcede doğal değildir. | 'Denmez' fazla kesin; seyrek de olsa görülür. |
| en.souvenir.n.1 | l1.tr.mnemonic | seni o yeri hatırlatan şey. → sana o yeri hatırlatan şey. | Türkçe dil bilgisi: 'hatırlatmak' yönelme (-e) ister. |
| en.sightseeing.n.1 | quiz.cloze | On our first day in Rome, we did some ______ and visited the old buildings. → We love to see famous places, so we go ______ in every new city. | Eski cümlede 'did some packing/booking' de doğru olabilirdi; 'go ______' kalıbı tek cevap bırakıyor. |
| en.currency.n.1 | examples[1].tr | Biraz parayı yabancı paraya çevirmem lazım. → Biraz paramı dövize çevirmem gerekiyor. | 'Biraz parayı' doğal Türkçe değil; 'döviz' = foreign currency. |
| en.round_trip.phr.1 | examples[0].tr | İzmir'e gidiş-dönüş bilet internetten daha ucuz. → İzmir'e gidiş-dönüş bileti internetten daha ucuz. | Belirtili özne için 'bileti' gerekir; eski hâli eksik/tutuk. |
| en.round_trip.phr.1 | synonyms | ["return trip"] → ["return"] | 'Return trip' genelde sadece dönüş yolculuğudur (gidiş-dönüş değil); İngiltere'de bilet için 'a return' denir. |
| en.jet_lag.phr.1 | l1.tr.mistakes[0].why | 'Jet lag' sayılamayan bir isimdir; Türkçedeki 'bir' etkisiyle 'a' eklenmez. → 'Jet lag' sayılamayan bir isimdir. Türkçede 'bir jet lag yaşadım' diyebildiğimiz için 'a' eklenir; ama 'a jet lag' denmez. | Açıklama ters yöne işaret ediyordu (Türkçe 'bir' hatayı doğuran şey, 'a'nın eklenmemesi değil). |

## Kısa genel bulgular

- En sık sorun: quiz sorusunda birden fazla doğru cevap (9 kart). Cümleler daraltıldı ya da çeldirici değiştirildi.
- İkinci sorun: Türkçe çeviride doğal olmayan ya da bilgi ekleyen/eksilten cümleler (18 örnek).
- Üçüncü sorun: "Sık yapılan hata" açıklamalarında yanlış ya da ters yönlü Türkçe gerekçe (5 kart). Ayrıca `screenshot` kartındaki uydurma hata, gerçek bir Türk hatasıyla (artikel eksikliği) değiştirildi.
- Teknoloji kelimelerinde Türkçe karşılıklar iPhone arayüzüne ve günlük kullanıma göre kontrol edildi (bildirim, ekran görüntüsü, depolama, pil, ayarlar, koyu mod).
- Etimolojilerde halk etimolojisi bulunmadı. İki etimoloji (`commute`, `neighborhood`) kesin olmayan ya da yanlış bir kısmından arındırıldı.
- Reddedilen kart yok. Hiçbir kartın anlamı yanlış değil.

## Emin olmadığım kartlar (anadili Türkçe olan biri baksın)

1. `en.spell.v.1`: Karşılık "hecelemek". Ders kitaplarında yaygın ama "heceleri ayırmak" demek. Karşılık "harf harf söylemek" olmalı mı? Not buna göre düzeltildi, gloss değişmedi.
2. `en.roundabout.n.1`: "dönel kavşak" resmî. Günlük dilde "göbekli kavşak" ya da sadece "kavşak" denir. Hangisi başa gelsin?
3. `en.signal.n.1`: Şüpheli "çekim gücü" alt karşılığı silindi. Günlük "çekim" ya da "anten" eklenebilir mi?
4. `en.settings.n.1`: "koyu mod" yapıldı. Bazı telefonlarda "karanlık mod / karanlık tema" yazıyor.
5. `en.password.n.1`: iPhone arayüzünde "Parola" yazıyor. Gloss "şifre", alt "parola" kaldı. Sıra doğru mu?
6. `en.book.v.1` 3. örnek: "booked our flights" = "biletlerimizi aldık". Rezervasyon vurgusu kayboluyor ama Türkçesi doğal.
7. `en.forecast.n.1`: Gloss "hava durumu". "Hava tahmini" daha doğru olabilir mi?
8. `en.stream.v.1`: Gloss "internetten izlemek". Müzik için "dinlemek" ayrı. "Stream etmek / canlı akış" günlük dilde var mı?
9. `en.one_way.adj.1`: Gloss "tek yönlü" sokak için doğal. Bilet için günlük dil "gidiş bileti". Gloss yeterli mi?
10. `en.layover.n.1`: "stopover" eş anlamı. ABD'de "layover" saatlik bekleme, "stopover" genelde günlük konaklama. Eş anlamlı sayılır mı?
11. `en.grade.n.1`: "not" ile "note" gerçek bir yanlış dost mu (Türkçe "not" iki anlamı da taşır), yoksa kısmi eşdeğerlik mi?
12. `en.rush_hour.phr.1` 2. örnek ("Şu an en yoğun saatler") ve `en.commute.v.1` 2. örnek ("iki saat yol yapıyor"): Doğal mı?
13. `en.ago.adv.1` quiz: Çeldirici "before" ("two years before") cümle bağlamsız olduğu için yanlış sayıldı. Çok sıkı bir okuyucu itiraz edebilir.
14. `en.battery.n.1`: "Pil" mi "batarya" mı demeli? Not iki kullanımı da kabul ediyor.
15. `en.pet.n.1` 3. örnek: "evcil hayvanlara izin verilmiyor". "Evcil hayvan beslemek yasak" da yaygın ama bilgi ekliyor.

## Çeldirici çeşitlendirme (2026-10-19)

- Önce: 125 soru, 212 farklı çeldirici; en sık: platform×11, password×9, ticket×7, charger×7, timetable×7, borrow×6.
- Sonra: 125 soru, 227 farklı çeldirici; en sık: borrow×6, corner×5, holiday×5, window×5, sidewalk×5, street×5. Doğrulayıcı sınırı (`QUIZ_DISTRACTOR_REPEAT`): 7.
- Çeldiricisi değişen kart: 17 (`distractors_diversified`). Doğru cevaplar değişmedi.
- Bu bölümü editör (Opus) yazdı: çeşitlendirme ajanı işini bitirip raporu yazamadan kullanım sınırına takıldı. Sayılar dosyalardan ölçüldü.

## Hafıza ipuçları ve denetim (2026-10-22)

- **Hafıza ipucu:** yazar ajan 39 ipucu önerdi. Şüpheci doğrulayıcı 8 tanesini reddetti, 2 tanesini küçük düzeltmeyle kabul etti. **Eklenen: 31** (`meta.qa_flags`: `mnemonic_added`).
- **Düzeltme:** yazarın 7 önerisinden doğrulayıcının onayladığı 7 tanesi uygulandı (çeviri 2, Dikkat 3, mevcut ipucu 1, quiz 1). Düzeltilen kartlara `critic_edited` eklendi.
- Yalnızca A1/A2 kartlarına ipucu eklendi. `id`, `lemma`, anlam, `gloss`, `def` ve IPA değişmedi.
- Doğrulayıcı: `125 kart · 125 şemadan geçti · 0 hata · 0 uyarı`

### Eklenen hafıza ipuçları

| Kart | İpucu |
|---|---|
| en.autumn.n.1 | 'Autumn' sonundaki 'n' sonbaharda yaprak gibi düşer: yazılır ama okunmaz. |
| en.tonight.adv.1 | 'Today', 'tonight', 'tomorrow' üçlüsü: hepsi 'to' ile başlar. Bugün, bu akşam, yarın. |
| en.oclock.adv.1 | O'clock aslında 'of the clock' sözünün kısası: six o'clock = saate göre tam altı. |
| en.twice.adv.1 | 'Two' (iki), 'twin' (ikiz), 'twice' (iki kez): hepsi 'tw' ile başlar, hepsinde iki var. |
| en.homework.n.1 | Home + work = evde yapılan iş. İş (work) gibi ödev de sayılmaz: 'homeworks' denmez. |
| en.traffic_jam.phr.1 | 'Jam' aynı zamanda reçel demek: arabalar kavanozdaki reçel gibi sıkışmış, akmıyor. |
| en.subway.n.1 | Sub = alt ('submarine' denizaltı demek) + way = yol: şehrin altındaki yol, yani metro. |
| en.sidewalk.n.1 | Side + walk: yolun yanında (side) yürünen (walk) yer, yani kaldırım. |
| en.roundabout.n.1 | Round (yuvarlak) + about (etrafında): arabalar yuvarlak göbeğin etrafında döner. |
| en.neighborhood.n.1 | Neighbor (komşu) + -hood: komşuların hepsi bir arada, yani mahalle. 'Childhood' (çocukluk) gibi. |
| en.downtown.adv.1 | 'Go home' gibi düşün: araya 'to' girmez. 'I'm going downtown' = merkeze gidiyorum. |
| en.abroad.adv.1 | Kelimenin içinde 'broad' (geniş) var: evinden çıkıp geniş dünyaya, yurt dışına. 'Go home' gibi 'go abroad' denir. |
| en.directions.n.1 | Yol tarifi tek yön değildir: 'düz git, sağa dön, sonra sola…' Birçok yön, bu yüzden 'directions' çoğul. |
| en.forecast.n.1 | 'Fore' önce demek ('before' içinde de var): forecast = önceden yapılan tahmin. |
| en.storm.n.1 | Türkçedeki 'beyin fırtınası' sözü İngilizce 'brainstorm' çevirisidir: brain = beyin, storm = fırtına. |
| en.freezing.adj.1 | Buzdolabının 'freezer' bölümünü düşün: dışarısı 'freezing' ise hava orası kadar soğuk. |
| en.sunrise.n.1 | Sun + rise (yükselmek): sabah güneş ufuktan yükselir. Akşam güneş batar (set): sunset. |
| en.nowadays.adv.1 | Now + a + days: ortadaki 'a' eskiden 'on' (-de) demekti. '-de' zaten içinde, önüne 'in' koyma. |
| en.arrive.v.1 | Latince 'ad ripam' = 'kıyıya': kelime ilk önce geminin kıyıya varması demekti. |
| en.book.v.1 | Eskiden rezervasyonlar bir deftere (book) yazılırdı: 'book a table' = masayı deftere yazdırmak. |
| en.pack.v.1 | Türkçedeki 'paket' ile akraba: eşyalarını bavula koyup paket yapmak gibi düşün. |
| en.journey.n.1 | 'Bonjour' sözündeki 'jour' gün demek: 'journey' önceleri bir günde gidilen yol demekti. |
| en.download.v.1 | Down = aşağı: dosya buluttan (internetten) telefonuna iner. Tersi 'upload': telefondan buluta çıkar. |
| en.upload.v.1 | Up = yukarı: fotoğraf telefonundan buluta (internete) çıkar. Tersi 'download': buluttan telefona iner. |
| en.text.v.1 | 'I'll call you' gibi 'I'll text you' denir: ikisinde de araya 'to' girmez. |
| en.fan.n.1 | Türkçedeki 'fanatik' taraftarı düşün: 'fan' takımını ya da şarkıcısını çok seven kişi. |
| en.board_game.phr.1 | Board = tahta: oyun bir tahtanın üstünde oynanır. Satranç tahtasına 'chessboard' denir. |
| en.island.n.1 | 'Island' içindeki 's' sonradan, 'isle' kelimesine benzesin diye eklendi. O yüzden okunmaz: 'aylınd'. |
| en.insect.n.1 | Latince 'insectum' = 'çentikli, bölünmüş': karıncaya bak, gövdesi boğum boğum bölümlere ayrılmış. |
| en.series.n.1 | Türkçedeki 'seri' ile aynı kelime: bölümler seri hâlinde, art arda gelir. |
| en.windy.adj.1 | Wind + y = windy. Hava sıfatlarının çoğu böyle: rain → rainy, cloud → cloudy, sun → sunny. |

### Düzeltmeler

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.ferry.n.1 | l1.tr.mnemonic | Feribot kelimesi zaten 'ferry'den geliyor: ferry + boat. → Feribot kelimesi zaten 'ferry boat' sözünden gelir: ferry + boat. | Mevcut ipucunda İngilizce sözcüğe ek getirilmiş ('ferry' + 'den'); rehberde yasak. Anlam aynı. |
| en.temperature.n.1 | l1.tr.mistakes[0] | ✗ How many degrees is it outside? ✓ What's the temperature outside? (Türkçede 'kaç derece?' diye sorarız. İngilizcede doğal soru 'What's the temperature?' sorusudur.) → (silindi) | 'How many degrees is it outside?' dilbilgisi olarak doğru ve konuşmada kullanılır; hata değil, yalnızca bir alternatif. |
| en.meanwhile.adv.1 | l1.tr.mistakes[0] | ✗ In the meanwhile, we can talk. ✓ In the meantime, we can talk. / Meanwhile, we can talk. (Doğru kalıplar 'in the meantime' veya sadece 'meanwhile'dır; 'in the meanwhile' modern İngilizcede doğal değildir.) → (silindi) | 'In the meanwhile' sözlüklerde (Merriam-Webster, Collins) geçen, kabul edilebilir bir kalıp; Türkçe konuşanlara özgü bir hata da değil. |
| en.spell.v.1 | l1.tr.mistakes[0] | ✗ How do you write your name? ✓ How do you spell your name? (Harfleri sormak için 'spell' kullanılır. 'Write' ise kalemle yazmak veya metin yazmak demektir.) → (silindi) | 'How do you write your name?' yazılışı sormak için kabul edilebilir; ana dili İngilizce olanlar da kullanır. 'spell' daha yaygın ama 'write' yanlış değil. |
| en.crowded.adj.1 | examples[2].tr | Pazar cumartesi günleri çok kalabalık olur. → Cumartesi günleri pazar yeri çok kalabalık olur. | 'Pazar cumartesi günleri' önce 'pazar günü / cumartesi' diye okunuyor, karışık. Anlam aynı, belirsizlik gidiyor. |
| en.layover.n.1 | examples[0].tr | Frankfurt'ta dört saatlik aktarma bekleyeceğiz. → Frankfurt'ta dört saatlik bir aktarmamız var. | 'Dört saatlik aktarma bekleyeceğiz' doğal Türkçe değil; 'We have a four-hour layover' = 'dört saatlik bir aktarmamız var'. |
| en.series.n.1 | quiz.distractors[2] | lesson → pillow | 'I stayed up all night to finish the whole lesson on my laptop' de anlamlı (çevrim içi ders). 'pillow' açıkça yanlış. |

### Atılan ipucu önerileri

Zorlama, doğruluğu şüpheli ya da kartta zaten söylenen öneriler atıldı:

- `weekday`: Şeffaf bileşik, öğrenci week ve day'i zaten bilir; weekday/weekend gerçek bir karışıklık değil, kanca eklemiyor.
- `ago`: Not zaten 'iki yıl önce' ile sıra benzerliğini ve 'before' yerine 'ago'yu söylüyor; tekrar.
- `subject`: Not ve Dikkat subject/lesson farkını zaten veriyor; parça-bütün cümlesi yeni bir kanca kurmuyor.
- `elevator`: A2 öğrenci 'elevate' fiilini bilmez, bağ kurulamaz; 'lift' adı zaten notta var.
- `midnight`: Midnight zaten çok bilinen, şeffaf bir kelime; ipucuna gerek yok.
- `password`: 'Password' Türkiye'de her giriş ekranında görülen, zaten bilinen bir kelime; ipucuna gerek yok.
- `update`: 'Update' günlük Türkçede bile kullanılan, zaten bilinen bir kelime; 'yukarı çekmek' benzetmesi de zorlama.
- `episode`: 'Epizot' günlük Türkçede az bilinen bir kelime; A2 öğrenci için bağ kurulmaz.

### Anadili Türkçe birinin bakması gerekenler

- en.spell.v.1: Dikkat silindi ('How do you write your name?' kabul edilebilir); anadili Türkçe biri 'spell' vurgusunun notta yeterli olduğuna bakabilir.
- en.temperature.n.1 ve en.meanwhile.adv.1: Dikkat maddesi silinince liste boş kalıyor.
