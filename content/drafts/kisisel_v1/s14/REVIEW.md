# s14 QA incelemesi (ev ve günlük işler)

Kapsam: `content/drafts/kisisel_v1/s14/part_01.json` ... `part_05.json` (45 kart). Konu: temizlik ve toparlama, çamaşır, mutfak işleri, ev eşyası, tamir, komşular, kira ve eve yerleşme. Seviye A2–B1.

Süreç (`docs/icerik_uretimi/README.md`), bütün ajanlar Opus:

1. **Yazım:** Part başına bir yazar ajanı (5 ajan), `1_yazar_kurallari.md`. Var olan kelimeler önce `dump_lemmas.py` ile çıkarıldı.
2. **Denetim:** Part başına bir denetçi ajanı (5 ajan), `2_denetci_kurallari.md` ve `SYSTEM_C`. Yazarların "emin olmadığım" maddeleri her denetçiye ayrıca verildi.
3. **Çeldirici kontrolü:** Bir ajan, `3_celdirici_kurallari.md` (aşağıda ayrı bölüm).
4. **Bağımsız doğrulama:** Kartları değiştirmeyen üç ayrı ajan bütün akışı okudu: (a) quiz'de tek doğru cevap, (b) Türkçe doğallık (geri çeviri, gloss, not, hata), (c) İngilizce içerik, IPA, tekrar ve üstveri. Koordinatör bulguları tartıp uyguladı.

## Özet

- İncelenen kart: **45** (A2: 19, B1: 26)
- Tür: 23 kelime (`word`), 9 eşdizim (`collocation`), 8 phrasal verb, 5 kalıp (`phrase`)
- Birincil konu: `home_household` 35, `phrasal_verbs` 7, `food_drink` 2, `social_skills` 1
- Değişen kart: **43** (hepsine `critic_edited` eklendi; değişmeyen: `stain`, `power cut`)
- Toplam düzenleme (alan sayısı): **181** (denetçiler 96, çeldirici adımı 1, koordinatör ve bağımsız doğrulama 84)
- Reddedilen kart (`critic_reject`): **0**
- Doğrulayıcı (tüm klasör, `--strict`): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`
- Çeldirici: en sık şık 3 soruda (sınır 4).

## Kelime seçimi

- Görev tanımındaki örneklerin çoğu başka akışlarda zaten vardı ve aynı anlamla tekrar yazılmadı: `laundry`, `vacuum`, `landlord`, `dishes`, `trash`, `fix`, `leak`, `chore`, `housework`, `rent` (s1); `run out of`, `take out` (s4).
- "do the dishes" ve "take out the trash" ayrı kart olarak yazılmadı: s1 `dishes` kartının quiz'i "It's my turn to do the ______" ve ilk örneği "I'll do the dishes after dinner."; s1 `trash` kartının quiz'i "Please take out the ______". "Fix a leak" de s1 `fix` ve `leak` kartlarında örnek olarak var. Yerine aynı alandan, depoda olmayan kalıplar seçildi: `make the bed`, `set the table`, `clear the table`, `water the plants`.
- s4'teki ev phrasal verb'leri (clean up, put away, throw away, warm up, move in, plug in, turn on/off) dışarıda bırakıldı. Yakın olanlar (`tidy up`, `use up`, `settle in`, `leave on`, `get rid of`) ile s4 kartları birbirinin çeldiricisi yapılmadı; notlar farkı anlatıyor.
- Aynı lemmanın başka anlamı: `hang up` (`en.hang_up.phv.2`, kıyafet asmak) s4'teki `en.hang_up.phv.1` (telefonu kapatmak) kartından ayrı bir kart.
- Aynı anda yazılan s15 (alışveriş, para) ve s16 (zaman, hava, doğa) ile kimlik çakışmasın diye: `complain` s15'te olduğu için çıkarıldı, yerine `spare key` yazıldı; `deposit` (s15'te banka anlamı) ve `recycle` (s16 doğa) seçilmedi. Listeler paylaşılan not klasöründe karşılaştırıldı; s14 kimliklerinin hiçbiri öteki akışlarda ya da `id_registry.json`'da yok.

## Genel bulgular

- Kartlar genel olarak sağlamdı: anlamlar doğru, ilk örnekler kısa ve kilit ekranına güvenli. Sahte dost hiçbirinde yok (doğru). Etimoloji yalnızca `curtain`, `plumber`, `tenant` kartlarında var ve üçü de doğru (`high`).
- **En sık 3 sorun:**
  1. **Quiz çeldiricileri bir şey sınamıyordu ya da biçim tutmuyordu** (bütün adımlarda 23 kartta quiz değişti; 3'ünde yalnızca isim). Örnekler: nesne almayan phrasal verb'ler (`put up`: sleep in, cheer up), konu dışı kalıplar (`make the bed`: miss the bus), yatak tekstili şıklar (`shelf`, `sink`), tekil şıklar ve çoğul cevap (`curtains`). İkinci doğru cevap olabilecek şık 3 kartta bulundu: `make the bed` ("I feed the cat and put the pillows…"), `cupboard` (tabak çekmecesi: drawer), `let in` ("Please cheer me up"). 9 kartta cümle (`cloze`) de değişti: `fold`, `drawer`, `blocked`, `keep it down`, `lock yourself out` (örneklere çok yakındı), `wipe` (it meyve suyunu gösteriyordu), `clear the table` (zaman), `make the bed`, `light bulb` (cümledeki 'light' cevabı ele veriyordu).
  2. **IPA depo geleneğine uymuyordu** (19 kart). US'de uzunluk işareti eksikti (key, keep, lock, door, heating, blocked…), UK'de DRESS ünlüsü /e/ yazılmıştı (bed, set, get), hece oluşturan ünsüz /n̩/, /l/ yazılmıştı (curtain, settle, table), kalıplarda iki ana vurgu vardı (`water the plants`, `lock yourself out`).
  3. **Türkçe çeviri ve karşılıklarda düz çeviri ya da tutarsızlık.** Aynı nesne akışta hem 'evye' hem 'lavabo' diye geçiyordu; günlük dile uygun olarak 'lavabo' yapıldı ('evye' alt'ta). 'mutfağın yerini süpürmek', 'banyonun yerindeki su', 'mutfağın zemininde' gibi çeviri kokan ifadeler düzeltildi. Açıklama gibi duran gloss'lar sözcüğe çevrildi: `lock yourself out` 'anahtarsız kapıda kalmak' → 'kapıda kalmak', `put up` 'duvara takmak' → 'takmak, asmak', `use up` 'hepsini kullanıp bitirmek' → 'bitirmek, tüketmek'.
- **Yaygın hatalar (mistakes):** 7 hata kaldı (`sweep`, `clear the table`, `oven`, `shelf`, `put up`, `heating`, `leave on`). Silinenler: `spill` ("poured … by mistake" yanlış değil, yalnızca daha az doğal), `light bulb` ("is burned": yaygınlığı şüpheli, bilgi not'ta), `broken` ("is broke": Türkçeden gelmiyor), `get rid of` ("get rid from": yaygınlığı kesin değil). `leave on` hatası "open the light" ailesinin doğrudan biçimi yapıldı ("I left the light open").
- **Tekrar ve isimler:** Ardışık 4 kartın (cupboard, drawer, shelf, sink) ilk örneği "The cups are in/on X" kalıbındaydı; ikisi değişti. 4 örnek başka akışlardaki örneklere çok yakındı (heating–s4 turn on, doorbell–s6 knock, keep it down–s7 quiet, noisy–s1 neighbor); değişti. part_04'te "Daniel" 5, "Hakan" 4 kartta geçiyordu; şimdi en çok 3. Cümle başındaki "Can" adı ("Can makes his bed") fiille karıştığı için başka adlarla değiştirildi.
- **Bayraklar:** Yazarların eklediği depoda olmayan bayraklar (`countable`, `irregular_verb`, `irregular_plural`) kaldırıldı. `separable`, `intransitive`, `confusable:*` kaldı.
- Seviye değişmedi.

## Yazar şüphelerine kararlar (kısa)

- `burn` quiz cevabı "burned"; UK "burnt" şıklarda yok, not iki biçimi de anlatıyor.
- `drawer` US /drɔːr/, UK /drɔː/ (depo geleneği; not iki biçimi de veriyor).
- `hang up` 3. örnekte focus "hung it up": s4 geleneği zamiri focus'a katıyor ("warm it up").
- `next door` çeldiricileri: far away / abroad / in another city (upstairs, nearby gibi doğru olabilecek şıklar kullanılmadı).
- `get rid of` türü `phrase`/`phr` kaldı (değişseydi kimlik de değişirdi).
- `water the plants` tanımları başlık kelimeleri kullanmadan, yapay mecaz olmadan yeniden yazıldı.

## Değişiklik tablosu

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman.

### part_01 (denetçi): temizlik ve toparlama

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.make_the_bed.phr.1 | ipa.uk | /meɪk ðə ˈbed/ → /meɪk ðə ˈbɛd/ | Depo geleneği: DRESS ünlüsü UK'de de /ɛ/. |
| en.make_the_bed.phr.1 | def.micro | neaten sheets and covers → tidy sheets and covers | 'neaten' A2 değil; 'tidy' s1'de A2. |
| en.make_the_bed.phr.1 | l1.tr.alt | ["yatağı düzeltmek", "yatağı yapmak"] → ["yatağı düzeltmek", "yatağı toparlamak"] | 'Yatağı yapmak' çoğu zaman yatmak için yatak hazırlamak anlamına gelir. |
| en.make_the_bed.phr.1 | quiz.distractors | miss the bus, lose my keys, pay the bill → set the table, do the dishes, feed the cat | Konu dışı şıklar hiçbir şeyi sınamıyordu. Aynı türden ev işleri seçildi; 'put the pillows in place' yalnızca cevaba uyuyor. |
| en.tidy_up.phv.1 | l1.tr.gloss | toplamak, derleyip toplamak → toplamak, toparlamak | İki yaygın sözcük. Deyim alt'a alındı. |
| en.tidy_up.phv.1 | l1.tr.alt | ["ortalığı toplamak", "toparlamak"] → ["ortalığı toplamak", "derleyip toplamak"] | 'toparlamak' gloss'a çıktı. |
| en.sweep.v.1 | tags.flags | ["irregular_verb", "confusable:vacuum"] → ["confusable:vacuum"] | Depoda kullanılmayan bayrak. |
| en.sweep.v.1 | l1.tr.alt | ["süpürgeyle süpürmek"] → [] | 'Süpürge' bugün çoğu zaman elektrik süpürgesi demek; alt yanıltıyordu. 'Saplı süpürgeyle süpürmek' 24 grafem sınırını aşıyor. |
| en.sweep.v.1 | l1.tr.note | 'Sweep' süpürgeyle, yani fırça süpürgeyle süpürmektir. Elektrik süpürgesiyle süpürmeye 'vacuum' denir. … → 'Sweep' saplı süpürgeyle (fırçayla) süpürmektir. Elektrik süpürgesiyle süpürmek 'vacuum' olur. … | 'Fırça süpürge' yaygın bir ad değil; 'saplı süpürge' aracı açıkça ayırıyor. |
| en.mop.v.1 | l1.tr.alt | ["paspas yapmak", "silmek"] → ["paspas yapmak", "yeri silmek"] | Tek başına 'silmek' `wipe` ile karışıyor. |
| en.wipe.v.1 | quiz.cloze | There is juice on the table. Can you ______ it with this cloth? → The table is wet and sticky. Can you ______ it with this cloth? | 'it' meyve suyunu gösteriyordu ('wipe it up' daha doğal). Artık masayı gösteriyor. "delete" çeldiricisi kaldı. |
| en.vacuum_cleaner.phr.1 | def.short | …machine that cleans floors and carpets by sucking up dirt → …machine that sucks up dust and dirt from floors and carpets | Başlık kelimenin parçası (clean) tanımda geçiyordu. |
| en.vacuum_cleaner.phr.1 | examples[2].tr | …yeri süpürgeyle süpürdü. → …yeri saplı süpürgeyle süpürdü. | 'Süpürge' elektrik süpürgesi olarak da okunuyor; cümlenin karşıtlığı kayboluyordu. |
| en.dishwasher.n.1 | def.short | …machine that washes plates… → …machine that cleans plates… | Başlık kelimenin parçası (wash) tanımda geçiyordu. |
| en.dishwasher.n.1 | def.long | A kitchen machine that washes plates… → A kitchen machine that cleans plates… | Aynı neden. |
| en.water_the_plants.phr.1 | ipa.us | /ˈwɔːtər ðə ˈplænts/ → /ˌwɔːtər ðə ˈplænts/ | Kalıpta tek ana vurgu (depo geleneği). |
| en.water_the_plants.phr.1 | ipa.uk | /ˈwɔːtə ðə ˈplɑːnts/ → /ˌwɔːtə ðə ˈplɑːnts/ | Aynı neden. |
| en.water_the_plants.phr.1 | def.micro | give flowers a drink → wet the soil around flowers | Yapay mecaz; başlık kelimeler kullanılmadan düz anlatım. |
| en.water_the_plants.phr.1 | def.short | give flowers in pots or in a garden a drink so they stay alive → make the soil in pots or in a garden wet so flowers don't get dry | Aynı neden. |
| en.water_the_plants.phr.1 | def.long | To give a drink to the flowers and green things… → To make the soil around the flowers and green things in your home or garden wet, for example with a can or a hose, so they stay healthy. … | Aynı neden. Kullanım notu ('water the flowers'…) kaldı. |
| en.spill.v.1 | def.micro | drop a drink by accident → let liquid fall by accident | 'Drop a drink' bardağı düşürmek gibi okunuyor. |
| en.spill.v.1 | l1.tr.mistakes | [poured … by mistake → spilled] → [] | "Poured coffee on my shirt by mistake" yanlış değil, yalnızca daha az doğal. pour/spill ayrımı notta duruyor. |

### part_02 (denetçi): çamaşır ve mutfak

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.washing_machine.phr.1 | tags.flags | ["countable"] → [] | Depoda kullanılmayan bayrak |
| en.fold.v.1 | quiz.cloze | Please ______ your T-shirts and put them in the drawer. → The clean towels are on the bed. Can you ______ them and put them in the cupboard? | 2. örnekle neredeyse aynıydı |
| en.hang_up.phv.2 | examples[2].en | Deniz washed her dress and hung it up in the wardrobe. → Deniz ironed her dress and hung it up in the wardrobe. | Yeni yıkanmış ıslak elbise gardıroba asılmaz |
| en.hang_up.phv.2 | examples[2].tr | Deniz elbisesini yıkadı ve gardıroba astı. → Deniz elbisesini ütüledi ve gardıroba astı. | İngilizceye uyum |
| en.hang_up.phv.2 | l1.tr.note | Bu kart kıyafet asmak anlamı içindir; 'telefonu kapatmak' anlamı ayrı bir kart. … → 'Hang up' telefonu kapatmak demek de olabilir; burada ise ceket ya da kıyafet asmak anlamında. … | Kart düzenine gönderme yerine kullanıcıya yönelik açıklama |
| en.set_the_table.phr.1 | ipa.uk | /set ðə ˈteɪbl/ → /sɛt ðə ˈteɪbl/ | Depo geleneği: DRESS /ɛ/ |
| en.clear_the_table.phr.1 | quiz.cloze | We finished dinner. … → We've finished dinner. … | Daha doğal |
| en.clear_the_table.phr.1 | quiz.distractors | take a photo → make the bed | Aynı türden (ev işi) ama tabaklarla açıkça yanlış şık |
| en.clear_the_table.phr.1 | l1.tr.mistakes[0].why | Türkçedeki 'sofrayı toplamak' kelime kelime 'collect the table' olmaz. … → 'Toplamak' çoğu zaman 'collect' diye çevrilir, ama sofra için 'clear' kullanılır: tabakları kaldırıp masayı boşaltmak demek. | Yanılmanın nedenini daha açık anlatıyor |
| en.burn.v.1 | ipa.us | /bɝn/ → /bɜːrn/ | Depo geleneği (furniture /ˈfɜːrnɪtʃər/) |
| en.oven.n.1 | tags.flags | "countable" çıkarıldı | Depoda kullanılmayan bayrak |
| en.cupboard.n.1 | tags.flags | "countable" çıkarıldı | Depoda kullanılmayan bayrak |
| en.drawer.n.1 | tags.flags | "countable" çıkarıldı | Depoda kullanılmayan bayrak |
| en.drawer.n.1 | ipa.us | /drɔr/ → /drɔːr/ | Depo geleneği (chore, floor) |
| en.drawer.n.1 | l1.tr.note | Genelde tek hece gibi söylenir: /drɔː/. … → Çoğu zaman tek hece gibi söylenir: Amerikan İngilizcesinde /drɔːr/, İngiliz İngilizcesinde /drɔː/. … | Yalnızca UK biçimi veriliyordu |
| en.drawer.n.1 | quiz.cloze | The forks are in the top ______ … → The spoons are in the top ______ … | 1. örnekle (forks … drawer) çok benzer |
| en.drawer.n.1 | quiz.distractors | sink, ceiling, balcony → shelf, sink, bowl | ceiling/balcony bir şey sınamıyordu; shelf yakın çift ama "pull it open" yalnızca drawer'ı bırakıyor |
| en.sink.n.1 | tags.flags | "countable" çıkarıldı | Depoda kullanılmayan bayrak |
| en.sink.n.1 | sense_note | basin with taps in a kitchen → basin with taps for washing | Kart banyo lavabosunu da kapsıyor |
| en.sink.n.1 | examples[1].tr | Ana sebzeleri mutfak evyesinde yıkadı. → Ana sebzeleri mutfaktaki evyede yıkadı. | "mutfak evyesi" yapay |

### part_03 (denetçi): ev eşyası ve tamir

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.shelf.n.1 | tags.flags | ["irregular_plural"] → [] | Depoda kullanılmayan bayrak. |
| en.put_up.phv.1 | quiz.distractors | sleep in, cheer up, calm down → try on, throw away, write down | Nesne almayan şıklar dilbilgisinden eleniyordu; şimdi nesne alan ama anlamca yanlış. |
| en.put_up.phv.1 | l1.tr.note | ...(ör. misafiri evde ağırlamak)... → ...(ör. birine evinde kalacak yer vermek)... | 'put sb up' yatıya kalacak yer vermektir, 'ağırlamak' daha geniş. |
| en.curtain.n.1 | ipa | /ˈkɝtn̩/, /ˈkɜːtn̩/ → /ˈkɝtən/, /ˈkɜːtən/ | Depo geleneği (button, garden, kettle) schwa ile. |
| en.curtain.n.1 | etymology.confidence | medium → high | cortine < cortina zinciri standart kaynaklarda kesin. |
| en.light_bulb.phr.1 | l1.tr.mistakes | "is burned" → "has burned out" → [] | Yaygınlığı şüpheli; bilgi not'ta. |
| en.light_bulb.phr.1 | l1.tr.note | 'has gone' ya da 'has burned out' → 'has gone', 'has blown' ya da 'has burned out' + "yalnızca 'burned' ateşte yanmış gibi anlaşılır" | Silinen hatanın uyarısı not'a taşındı; İngiliz kullanımı 'blown' eklendi. |
| en.light_bulb.phr.1 | collocations | new light bulb → the bulb has blown | Zayıf eşdizim yerine gerçek kalıp. |
| en.broken.adj.1 | l1.tr.mistakes | "My phone is broke." → [] | Türkçeden gelmiyor (s13'teki "Congratulation" kararıyla aynı); broke/broken ayrımı not'ta duruyor. |
| en.broken.adj.1 | quiz.distractors | tidy, sleepy, spicy → new, lost, clean | Eşya için kullanılan ama bu cümlede açıkça yanlış sıfatlar. |
| en.blocked.adj.1 | def.micro | full, so water can't pass → closed, so water can't pass | 'full' yanıltıcı (dolu lavabo ≠ tıkalı). |
| en.blocked.adj.1 | def.short | full of something, so water or air cannot pass through → closed by something stuck inside, so water or air cannot pass through | Aynı neden. |
| en.blocked.adj.1 | quiz.cloze | The kitchen sink is ______ again. The water won't go down. → I can't wash the dishes. The sink is ______, and the water won't go down. | 1. örneğin neredeyse aynısıydı. |
| en.blocked.adj.1 | quiz.distractors | lazy, bored, ripe → empty, dry, warm | İnsan/meyve sıfatları yerine lavaboya uyan ama bağlamda yanlış sıfatlar. |
| en.plumber.n.1 | l1.tr.note | Sondaki 'b' okunmaz → 'b' harfi okunmaz | b sonda değil. |
| en.heating.n.1 | examples[0] | It's cold. Can you turn on the heating? / Hava soğuk. Kaloriferi açabilir misin? → Can you turn on the heating? I'm cold. / Kaloriferi açabilir misin? Üşüyorum. | s4 turn on kartındaki örneğe çok yakındı. |
| en.heating.n.1 | l1.tr.note | taşınabilir sobaya 'heater' → taşınabilir ısıtıcıya 'heater' | heater soba değil, ısıtıcı. |
| en.knock_over.phv.1 | quiz.distractors | gave up, showed up, looked for → put away, looked for, gave back | showed up nesne almıyor; hepsi artık nesne alan geçmiş zaman phrasal verb. |

### part_04 (denetçi): komşular ve kira

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.next_door.phr.1 | ipa.us | /ˌnɛkst ˈdɔr/ → /ˌnɛkst ˈdɔːr/ | US uzunluk işareti (s12 `sore` /sɔːr/, s1 `landlord`). |
| en.next_door.phr.1 | quiz.distractors | ["abroad", "on foot", "by mistake"] → ["far away", "abroad", "in another city"] | Hepsi aynı işlevde (yer) ve 'share a wall' ile açıkça çelişiyor. Eskilerden ikisi yer bildirmiyordu. |
| en.noisy.adj.1 | examples[2].en | …only use it in the day. → …only use it during the day. | 'in the day' doğal değil. Türkçe çeviri ('gündüz') aynı kaldı. |
| en.noisy.adj.1 | l1.tr.alt | ["gürültücü", "sesli"] → ["gürültücü"] | 'sesli' 'gürültülü' anlamına gelmiyor. |
| en.noisy.adj.1 | l1.tr.note | 'Loud' daha çok sesin kendisi için… 'Noisy' ise … için kullanılır → 'Loud' çoğunlukla sesin kendisi için kullanılır: 'loud music'. 'Noisy' daha çok ses çıkaran kişi, yer ya da makine için: 'a noisy street'. Kesin kural değildir; 'loud neighbors' da denir. | Eski not bir eğilimi kural gibi anlatıyordu (yazar şüphesi 4). |
| en.spare_key.phr.1 | ipa.us | /ˌspɛr ˈki/ → /ˌspɛr ˈkiː/ | US uzunluk işareti. |
| en.spare_key.phr.1 | ipa.uk | /ˌspɛə ˈkiː/ → /ˌspeə ˈkiː/ | Depoda UK SQUARE ünlüsü /eə/ yazılıyor (parent, wear off). |
| en.spare_key.phr.1 | quiz.distractors | ["boarding pass", "power cut", "bus stop"] → ["broken key", "lost key", "door lock"] | Eskiler ilgisiz isimlerdi. Yeniler anahtarla ilgili ama 'just in case' ile birlikte bırakılacak bir şey olamaz. 'spare' anlamını sınıyor. |
| en.keep_it_down.phr.1 | ipa.us | /ˌkip ɪt ˈdaʊn/ → /ˌkiːp ɪt ˈdaʊn/ | US uzunluk işareti. |
| en.keep_it_down.phr.1 | quiz.cloze | The baby is sleeping. Could you ______, please? → It's after midnight and people are trying to sleep. Could you ______, please? | s7 `quiet` 1. örneğine ve kartın 3. örneğine çok yakındı. |
| en.keep_it_down.phr.1 | quiz.distractors | [..., "make a mistake"] → ["turn it up", "speak up", "wake them up"] | 'make a mistake' başka türdendi. Yeni şık bağlamla açıkça çelişiyor. 'turn it down' bilerek konmadı (uyabilir). |
| en.doorbell.n.1 | ipa.us | /ˈdɔrˌbɛl/ → /ˈdɔːrbɛl/ | Uzunluk işareti. Tek kelimelik bileşik UK ile aynı biçimde, ikincil vurgu yok. |
| en.doorbell.n.1 | examples[1] | Priya pressed the doorbell twice, but nobody came to the door. / Priya zile iki kez bastı ama kimse kapıya gelmedi. → The doorbell rang while Priya was in the shower. / Priya duştayken kapı zili çaldı. | s6 `knock` 3. örneğiyle aynı kalıptaydı. |
| en.doorbell.n.1 | quiz.distractors | ["kettle", "pillow", "towel"] → ["doormat", "door handle", "doorway"] | Eskiler ilgisiz ev eşyalarıydı. Yeniler de kapıyla ilgili, ama hiçbiri 'ring' ile kullanılmıyor. |
| en.let_in.phv.1 | quiz.distractors | ["let me down", "wake me up", "cheer me up"] → ["let me down", "let me out", "wake me up"] | 'It's raining! Please cheer me up' savunulabilirdi. 'let me out' asıl karşıtı sınıyor ve 'I'm outside' ile çelişiyor. |
| en.lock_yourself_out.phr.1 | ipa.us | /ˌlɑk jərˈsɛlf ˈaʊt/ → /ˌlɑːk jərˌsɛlf ˈaʊt/ | Uzunluk işareti. İki ana vurgu → tek ana vurgu + ikincil (s13 kuralı). |
| en.lock_yourself_out.phr.1 | ipa.uk | /ˌlɒk jəˈsɛlf ˈaʊt/ → /ˌlɒk jəˌsɛlf ˈaʊt/ | Aynı neden. |
| en.lock_yourself_out.phr.1 | l1.tr.gloss | anahtarsız kapıda kalmak → kapıda kalmak | Eskisi açıklamaydı. 'kapıda kalmak' yerleşik bir kalıp (yazar şüphesi 2). |
| en.lock_yourself_out.phr.1 | l1.tr.alt | ["kapıda kalmak", "dışarıda kalmak"] → ["dışarıda kalmak"] | 'kapıda kalmak' gloss'a taşındı. |
| en.lock_yourself_out.phr.1 | l1.tr.note | Türkçede tek kelimelik karşılığı yok; 'anahtarı içeride unutup kapıda kalmak' diye anlatılır… → Kapıyı kapatıp anahtarı içeride unutunca Türkçede 'kapıda kalmak' denir. 'Yourself' kişiye göre değişir: … | Eski not, yerleşik karşılık olmadığını söylüyordu. |
| en.lock_yourself_out.phr.1 | examples[0].tr | Eyvah! Anahtarı içeride unutup yine dışarıda kaldım. → Eyvah! Anahtarı içeride unuttum, yine kapıda kaldım. | Daha doğal ve kısa. |
| en.lock_yourself_out.phr.1 | examples[1].tr | Ece anahtarı içeride unutup dışarıda kaldı, o yüzden ev arkadaşının eve gelmesini bekledi. → Ece kapıda kaldı, o yüzden ev arkadaşının gelmesini bekledi. | Uzun ve yapaydı. 'eve gelmesini' gereksiz tekrardı. |
| en.lock_yourself_out.phr.1 | examples[2].tr | Anahtarını içeride unutup dışarıda kalırsan beni ara… → Kapıda kalırsan beni ara. Bende yedek anahtar var. | Kısa ve doğal. |
| en.lock_yourself_out.phr.1 | quiz (cloze, answer, distractors) | Ece left her keys inside and ______. She had to wait on the stairs. / locked herself out / [got lost, fell asleep, checked in] → I left my keys inside and ______. Now I have to wait on the stairs. / locked myself out / [locked myself in, fell asleep, checked in] | 2. örnekle aynı kişi ve durum vardı, 'got lost' bir şey sınamıyordu. 'locked myself in' in/out farkını sınıyor ve sonraki cümleyle çelişiyor. Birinci şahıs, 16 grafem sınırı yüzünden seçildi. |
| en.roommate.n.1 | ipa.us | /ˈrumˌmeɪt/ → /ˈruːmmeɪt/ | Uzunluk işareti. UK ile aynı biçim. |
| en.for_rent.phr.1 | quiz.distractors | ["for sale", "on time", "out of order"] → ["for sale", "on sale", "in stock"] | Hepsi satış ve alışverişle ilgili. 'can't buy' ile açıkça çelişiyor. 'on time' ve 'out of order' bir şey sınamıyordu. |

### part_05 (denetçi): eve yerleşme ve ev düzeni

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.furnished.adj.1 | ipa.us | /ˈfɝːnɪʃt/ → /ˈfɜːrnɪʃt/ | Depo geleneği US NURSE /ɜːr/ (39 kart) |
| en.settle_in.phv.1 | ipa.us | /ˌsɛtl ˈɪn/ → /ˌsɛtəl ˈɪn/ | Hece oluşturan l depoda /əl/ |
| en.settle_in.phv.1 | ipa.uk | /ˌsetl ˈɪn/ → /ˌsɛtəl ˈɪn/ | DRESS /ɛ/ + /əl/ |
| en.settle_in.phv.1 | grammar.pattern | settle in (to + place) → settle in / settle into + place | Yer alınca bitişik "settle into" yazılır |
| en.settle_in.phv.1 | collocations | settle in to a new job → settle into a new job | Aynı neden |
| en.leave_on.phv.1 | l1.tr.mistakes | "I forgot the light open." → "I left the light open." (why yeniden yazıldı) | Gerçek "open the light" hata ailesinin doğrudan biçimi; daha kesin |
| en.use_up.phv.1 | def.long | "... The subject is the person who used it." cümlesi çıkarıldı | Tanım değil, öğrenciye gereksiz dilbilgisi notu |
| en.get_rid_of.phr.1 | ipa.uk | /ɡet ˈrɪd əv/ → /ɡɛt ˈrɪd əv/ | DRESS /ɛ/ geleneği |
| en.get_rid_of.phr.1 | l1.tr.alt | [elden çıkarmak, başından savmak] → [elden çıkarmak] | "Başından savmak" insanlar için; eşya anlamında yanıltıcı |
| en.get_rid_of.phr.1 | l1.tr.mistakes | "get rid from" → [] | Türklerde yaygınlığı kesin değil |

### Koordinatör ve bağımsız doğrulama

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.heating.n.1 | ipa.us | /ˈhitɪŋ/ → /ˈhiːtɪŋ/ | Depo geleneği: US'de uzunluk işareti. |
| en.blocked.adj.1 | ipa.us | /blɑkt/ → /blɑːkt/ | Depo geleneği: US'de uzunluk işareti. |
| en.knock_over.phv.1 | ipa.us | /nɑk ˈoʊvər/ → /nɑːk ˈoʊvər/ | Depo geleneği: US'de uzunluk işareti. |
| en.curtain.n.1 | ipa.us | /ˈkɝtən/ → /ˈkɜːrtən/ | Depo geleneği: US NURSE /ɜːr/. |
| en.make_the_bed.phr.1 | examples[1].en / .tr | Can makes his bed… / Can kahvaltı… → Kerem makes his bed… / Kerem kahvaltı… | Cümle başındaki 'Can' adı 'can' fiiliyle karışıyor. |
| en.mop.v.1 | examples[1].en / .tr | Can mops the kitchen floor… / Can her cumartesi… → Emre mops the kitchen floor… / Emre her cumartesi… | Aynı neden. |
| en.dishwasher.n.1 | quiz.cloze | After dinner, Can put all the dirty plates in the ______. → After dinner, Leo put all the dirty plates in the ______. | Aynı neden ('Can put' fiil gibi okunuyor). |
| en.sink.n.1 | l1.tr.gloss | evye → lavabo | Türkçe doğrulama: günlük dilde mutfaktaki için de 'lavabo' denir; 'evye' alt'ta. Akış boyunca tek sözcük. |
| en.sink.n.1 | l1.tr.alt | ["lavabo"] → ["evye"] | Türkçe doğrulama: günlük dilde mutfaktaki için de 'lavabo' denir; 'evye' alt'ta. Akış boyunca tek sözcük. |
| en.sink.n.1 | examples[0].tr | Kirli fincanlar evyede. → Kirli fincanlar lavaboda. | Türkçe doğrulama: günlük dilde mutfaktaki için de 'lavabo' denir; 'evye' alt'ta. Akış boyunca tek sözcük. |
| en.sink.n.1 | examples[1].tr | Ana sebzeleri mutfaktaki evyede yıkadı. → Ana sebzeleri mutfak lavabosunda yıkadı. | Türkçe doğrulama: günlük dilde mutfaktaki için de 'lavabo' denir; 'evye' alt'ta. Akış boyunca tek sözcük. |
| en.sink.n.1 | l1.tr.note | Mutfaktaki 'evye' de banyodaki 'lavabo' da 'sink' olur. Türkçede 'lavaboya gitmek' tuvalete gitmek demektir; İngilizcede bunun için 'toilet' ya da 'bathroom' denir. → Mutfaktaki lavabo (evye) de banyodaki lavabo da 'sink' olur. Türkçedeki 'lavaboya gitmek' (tuvalete gitmek) için ise 'go to the toilet' ya da 'go to the bathroom' denir. | Türkçe doğrulama: günlük dilde mutfaktaki için de 'lavabo' denir; 'evye' alt'ta. Akış boyunca tek sözcük. |
| en.sink.n.1 | quiz.distractors | ["oven", "pillow", "blanket"] → ["oven", "fridge", "drawer"] | Türkçe doğrulama: günlük dilde mutfaktaki için de 'lavabo' denir; 'evye' alt'ta. Akış boyunca tek sözcük. |
| en.clear_the_table.phr.1 | examples[1].tr | Selin sofrayı topladı ve tabakları evyeye koydu. → Selin sofrayı topladı ve tabakları lavaboya koydu. | 'lavabo' birliği (sink kararı). |
| en.cupboard.n.1 | examples[2].tr | Evyenin üstündeki dolapta bir paket pirinç var. → Lavabonun üstündeki dolapta bir paket pirinç var. | 'lavabo' birliği / quiz doğrulaması: 'drawer' tabak için de olabilir; kapılı ama açıkça yanlış 'wardrobe'. |
| en.washing_machine.phr.1 | l1.tr.note | Çamaşır yıkamak 'do the laundry' olur. Bulaşık makinesi ise 'dishwasher' denir. → Çamaşır yıkamak 'do the laundry' olur. Bulaşık makinesine ise 'dishwasher' denir. | Dilbilgisi: 'denir' yönelme hâli ister. |
| en.keep_it_down.phr.1 | l1.tr.gloss | sesini kısmak → sessiz olmak | 'Keep it down' her türlü gürültüyü kapsar; 'sesini kısmak' nottaki 'turn it down' ile karışıyordu. |
| en.keep_it_down.phr.1 | l1.tr.alt | ["sessiz olmak", "gürültü yapmamak"] → ["sesini kısmak", "gürültü yapmamak"] | 'Keep it down' her türlü gürültüyü kapsar; 'sesini kısmak' nottaki 'turn it down' ile karışıyordu. |
| en.knock_over.phv.1 | l1.tr.alt | ["yere düşürmek"] → ["düşürmek"] | 'yere düşürmek' drop anlamına kayıyor; devrilen bardak masada kalabilir. |
| en.put_up.phv.1 | l1.tr.gloss | duvara takmak → takmak, asmak | 'duvara takmak' kalıplaşmış değil ve perdeye uymuyor. |
| en.put_up.phv.1 | l1.tr.alt | ["asmak", "monte etmek"] → ["duvara asmak", "monte etmek"] | 'duvara takmak' kalıplaşmış değil ve perdeye uymuyor. |
| en.spare_key.phr.1 | l1.tr.alt | ["fazladan anahtar"] → [] | 'fazladan anahtar' gerçek bir karşılık değil. |
| en.next_door.phr.1 | l1.tr.alt | ["yan ev", "yan daire", "bitişikte"] → ["yan ev", "yan daire"] | 'bitişikte' az kullanılan, yazı dili kokan söyleyiş. |
| en.use_up.phv.1 | l1.tr.gloss | hepsini kullanıp bitirmek → bitirmek, tüketmek | Gloss açıklama gibiydi; daha doğal çeviri. |
| en.use_up.phv.1 | l1.tr.alt | ["bitirmek", "tüketmek"] → ["kullanıp bitirmek"] | Gloss açıklama gibiydi; daha doğal çeviri. |
| en.use_up.phv.1 | examples[0].tr | Kahvenin hepsini kim bitirdi? → Bütün kahveyi kim bitirdi? | Gloss açıklama gibiydi; daha doğal çeviri. |
| en.sweep.v.1 | l1.tr.note | 'Sweep' saplı süpürgeyle (fırçayla) süpürmektir. Elektrik süpürgesiyle süpürmek 'vacuum' olur. Geçmiş zamanı düzensizdir: 'swept'. → 'Sweep' saplı süpürgeyle süpürmektir. Elektrik süpürgesiyle süpürmek 'vacuum' olur. Geçmiş zamanı düzensizdir: 'swept'. | 'fırça süpürge' yerleşik ad değil; 'mutfağın yerini' çeviri kokuyor. |
| en.sweep.v.1 | examples[0].tr | Her gün mutfağın yerini süpürürüm. → Her gün mutfağı süpürürüm. | 'fırça süpürge' yerleşik ad değil; 'mutfağın yerini' çeviri kokuyor. |
| en.mop.v.1 | examples[1].tr | Emre her cumartesi sabahı mutfağın yerini paspaslıyor. → Emre her cumartesi sabahı mutfağı paspaslıyor. | 'mutfağın yerini', 'banyonun yerindeki' doğal değil; satıştaki ad 'saplı paspas'. |
| en.mop.v.1 | examples[2].tr | Zeynep banyonun yerindeki suyu paspasla aldı. → Zeynep banyoda yerdeki suyu paspasla aldı. | 'mutfağın yerini', 'banyonun yerindeki' doğal değil; satıştaki ad 'saplı paspas'. |
| en.mop.v.1 | l1.tr.note | İsim olarak 'mop' sopalı paspas demek. Kapının önündeki paspasa ise 'doormat' denir. → İsim olarak 'mop' saplı paspas demek. Kapının önündeki paspasa ise 'doormat' denir. | 'mutfağın yerini', 'banyonun yerindeki' doğal değil; satıştaki ad 'saplı paspas'. |
| en.vacuum_cleaner.phr.1 | examples[2].tr | Elektrik süpürgesi bozuldu, Tom da onun yerine yeri saplı süpürgeyle süpürdü. → Elektrik süpürgesi bozuldu, Tom da yeri saplı süpürgeyle süpürdü. | 'yerine yeri' art arda kulağa kötü geliyor; anlam 'Tom da' ile korunuyor. |
| en.spill.v.1 | l1.tr.note | 'Spill' yalnızca kazayla dökmek demek. Bardağa bilerek su, çay doldurmak 'pour' olur. → 'Spill' yalnızca kazayla dökmek demek. Bilerek dökmek, örneğin bardağa çay koymak 'pour' olur. | 'doldurmak' fill demek; pour = dökmek/koymak. |
| en.burn.v.1 | examples[2].tr | Ateşi kıs, yoksa pilavı yakacaksın. → Ocağın altını kıs, yoksa pilavı yakacaksın. | Mutfakta doğal söyleyiş 'ocağın altını kısmak'. |
| en.hang_up.phv.2 | examples[0].tr | Lütfen ceketini as. → Lütfen montunu as. | coat = mont/palto; 'ceket' jacket (2. örnekte zaten ceket). |
| en.doorbell.n.1 | examples[2].tr | Kapı zilimiz bozuk, o yüzden gelince lütfen kapıyı çalın. → Kapı zilimiz bozuk, o yüzden gelince lütfen kapıyı tıklatın. | Kartın notu 'kapı çalmak'ın iki anlamını anlatıyor; knock için açık karşılık. |
| en.curtain.n.1 | examples[0].tr | Lütfen perdeleri aç. Güneşli bir gün. → Lütfen perdeleri aç. Hava güneşli. | Doğallık. |
| en.broken.adj.1 | examples[2].tr | Dikkat et, mutfağın zemininde kırık cam var. → Dikkat et, mutfakta yerde kırık cam var. | 'mutfağın zemininde' yazı dili. |
| en.make_the_bed.phr.1 | quiz.cloze | After I get up, I ______ and put the pillows in place. → I ______ every morning, so my sheets and pillows look neat. | Quiz doğrulaması: 'and' ile iki ayrı iş; 'I feed the cat and put the pillows…' de savunulabilirdi. |
| en.light_bulb.phr.1 | quiz.cloze | The kitchen light went out, so Ali changed the ______. → The lamp doesn't work, so Fatma changed the ______. | Quiz doğrulaması: cümledeki 'light' cevabın bir parçasını ele veriyordu. |
| en.cupboard.n.1 | quiz.distractors | ["drawer", "pocket", "shelf"] → ["wardrobe", "pocket", "shelf"] | 'lavabo' birliği / quiz doğrulaması: 'drawer' tabak için de olabilir; kapılı ama açıkça yanlış 'wardrobe'. |
| en.shelf.n.1 | quiz.distractors | ["blanket", "towel", "pillow"] → ["roof", "wall", "step"] | Quiz doğrulaması: yatak tekstili şıklar hiçbir şey sınamıyordu. |
| en.roommate.n.1 | quiz.cloze | Daniel and I aren't family, but we live together and share the rent. He's my ______. → Omar and I aren't family, but we live together and share the rent. He's my ______. | part_04'te 'Daniel' üç soruda geçiyordu. |
| en.for_rent.phr.1 | quiz.cloze | Daniel can't buy a house, so he is looking for a flat ______. → Ece can't buy a house, so she is looking for a flat ______. | part_04'te 'Daniel' üç soruda geçiyordu. |
| en.sweep.v.1 | l1.tr.mistakes[0].why | …fırça süpürge kullanıyorsan 'sweep' dersin. → …saplı süpürge kullanıyorsan 'sweep' dersin. | 'fırça süpürge' yerleşik ad değil; 'mutfağın yerini' çeviri kokuyor. |
| en.set_the_table.phr.1 | ipa.uk | /sɛt ðə ˈteɪbl/ → /sɛt ðə ˈteɪbəl/ | Depo geleneği: hece oluşturan l /əl/ (US tarafı zaten böyle). |
| en.clear_the_table.phr.1 | ipa.uk | /klɪə ðə ˈteɪbl/ → /klɪə ðə ˈteɪbəl/ | Depo geleneği: hece oluşturan l /əl/. |
| en.tenant.n.1 | examples[2].en | Daniel has been a tenant in this building for six years. → Leyla has been a tenant in this building for six years. | part_04'te 'Daniel' 5 kartta geçiyordu. |
| en.tenant.n.1 | examples[2].tr | Daniel altı yıldır bu binada kiracı. → Leyla altı yıldır bu binada kiracı. | part_04'te 'Daniel' 5 kartta geçiyordu. |
| en.let_in.phv.1 | examples[1].en | Hakan opened the back door and let the cat in. → Oscar opened the back door and let the cat in. | part_04'te 'Hakan' 4 kartta geçiyordu. |
| en.let_in.phv.1 | examples[1].tr | Hakan arka kapıyı açtı ve kediyi içeri aldı. → Oscar arka kapıyı açtı ve kediyi içeri aldı. | part_04'te 'Hakan' 4 kartta geçiyordu. |
| en.roommate.n.1 | examples[2].en | Hakan and his roommate take turns cleaning the kitchen. → Arda and his roommate take turns cleaning the kitchen. | part_04'te 'Hakan' 4 kartta geçiyordu. |
| en.roommate.n.1 | examples[2].tr | Hakan ve ev arkadaşı mutfağı sırayla temizliyor. → Arda ve ev arkadaşı mutfağı sırayla temizliyor. | part_04'te 'Hakan' 4 kartta geçiyordu. |
| en.spill.v.1 | examples[1].en | Tom spilled coffee on his white shirt. → Burcu spilled coffee on her white shirt. | part_01'de 'Tom' 4 kartta geçiyordu. |
| en.spill.v.1 | examples[1].tr | Tom beyaz gömleğine kahve döktü. → Burcu beyaz gömleğine kahve döktü. | part_01'de 'Tom' 4 kartta geçiyordu. |
| en.shelf.n.1 | examples[0].en | The cups are on the top shelf. → The jam is on the top shelf. | Ardışık 4 kartın ilk örneği 'The cups are in/on X' kalıbındaydı; 3. örnek cupboard'daki pirinç cümlesine çok yakındı. |
| en.shelf.n.1 | examples[0].tr | Fincanlar en üst rafta. → Reçel en üst rafta. | Ardışık 4 kartın ilk örneği 'The cups are in/on X' kalıbındaydı; 3. örnek cupboard'daki pirinç cümlesine çok yakındı. |
| en.shelf.n.1 | examples[2].en | Can you get the rice from the shelf above the oven? → Can you get the salt from the shelf above the oven? | Ardışık 4 kartın ilk örneği 'The cups are in/on X' kalıbındaydı; 3. örnek cupboard'daki pirinç cümlesine çok yakındı. |
| en.shelf.n.1 | examples[2].tr | Fırının üstündeki raftan pirinci alabilir misin? → Fırının üstündeki raftan tuzu alabilir misin? | Ardışık 4 kartın ilk örneği 'The cups are in/on X' kalıbındaydı; 3. örnek cupboard'daki pirinç cümlesine çok yakındı. |
| en.sink.n.1 | examples[0].en | The dirty cups are in the sink. → Don't leave dirty plates in the sink. | İlk örnek aynı kalıptaydı; 3. örnek blocked kartının quiz cevabını önceden veriyordu. |
| en.sink.n.1 | examples[0].tr | Kirli fincanlar lavaboda. → Kirli tabakları lavaboda bırakma. | İlk örnek aynı kalıptaydı; 3. örnek blocked kartının quiz cevabını önceden veriyordu. |
| en.sink.n.1 | examples[2].en | The bathroom sink is blocked, so the water isn't going down. → Kaan filled the sink with hot water and soap. | İlk örnek aynı kalıptaydı; 3. örnek blocked kartının quiz cevabını önceden veriyordu. |
| en.sink.n.1 | examples[2].tr | Banyodaki lavabo tıkalı, o yüzden su gitmiyor. → Kaan lavaboyu sıcak su ve sabunla doldurdu. | İlk örnek aynı kalıptaydı; 3. örnek blocked kartının quiz cevabını önceden veriyordu. |
| en.noisy.adj.1 | examples[0].en | Our new neighbors are a little noisy at night. → The kids are really noisy today. | s1 neighbor kartındaki 'My neighbors are noisy on weekends.' cümlesine çok yakındı. |
| en.noisy.adj.1 | examples[0].tr | Yeni komşularımız geceleri biraz gürültülü. → Çocuklar bugün çok gürültücü. | s1 neighbor kartındaki 'My neighbors are noisy on weekends.' cümlesine çok yakındı. |
| en.knock_over.phv.1 | examples[0].en | Oops! I knocked over my coffee. → The cat knocked over my glass of water. | spill'in ilk örneğiyle aynı kalıp ('Oops' + içecek). |
| en.knock_over.phv.1 | examples[0].tr | Eyvah! Kahvemi devirdim. → Kedi su bardağımı devirdi. | spill'in ilk örneğiyle aynı kalıp ('Oops' + içecek). |
| en.settle_in.phv.1 | examples[1].en | Lena settled in quickly at her new flat. → Lena settled in quickly and loves her new flat. | 'settle in at + yer' doğal değil. |
| en.settle_in.phv.1 | examples[1].tr | Lena yeni dairesine çabucak alıştı. → Lena çabucak alıştı ve yeni dairesini çok seviyor. | 'settle in at + yer' doğal değil. |
| en.blocked.adj.1 | examples[1].en | Yuki's shower is blocked, so the water stays on the floor. → The shower is blocked, so Yuki called the landlord. | Su duş teknesinde kalır, yerde değil; cümle tuhaftı. |
| en.blocked.adj.1 | examples[1].tr | Yuki'nin duşu tıkalı, bu yüzden su yerde kalıyor. → Duş tıkalı, bu yüzden Yuki ev sahibini aradı. | Su duş teknesinde kalır, yerde değil; cümle tuhaftı. |
| en.oven.n.1 | examples[1].en | Liam heated the oven before he made the pizza. → Liam turned on the oven before he made the pizza. | 'heated the oven' A2 için tuhaf; doğal kullanım 'turn on'. |
| en.oven.n.1 | examples[1].tr | Liam pizzayı yapmadan önce fırını ısıttı. → Liam pizzayı yapmadan önce fırını açtı. | 'heated the oven' A2 için tuhaf; doğal kullanım 'turn on'. |
| en.spare_key.phr.1 | examples[0].en | My mom has a spare key to my flat. → My mom has a spare key to my apartment. | Tek cümlede US 'mom' ile UK 'flat' karışımı. |
| en.keep_it_down.phr.1 | def.long | A direct but polite way to ask someone to make less noise. People often say it to neighbors, roommates or children: 'Could you keep it down, please?' → An informal way to ask someone to make less noise. People often say it to neighbors, roommates or children. With 'Could you … please?' it sounds polite. | Tek başına 'Keep it down!' kibar değil, gündelik; kibarlığı 'Could you… please?' sağlıyor. |
| en.keep_it_down.phr.1 | tags.register | neutral → informal | Tek başına 'Keep it down!' kibar değil, gündelik; kibarlığı 'Could you… please?' sağlıyor. |
| en.next_door.phr.1 | def.long | In the house or flat that is right beside yours, with only a wall between you. You can live next door, or talk about the people next door. → In the house or flat that is right beside yours. You can live next door, or talk about the people next door. | Müstakil yan evler duvar paylaşmaz; 'only a wall between you' yanıltıcı. |
| en.curtain.n.1 | def.long | A long piece of cloth that hangs at the side of a window. You close it at night or when the sun is too bright, and open it in the morning. → A long piece of cloth that hangs in front of a window. You close it at night or when the sun is too bright, and open it in the morning. | Perde kapalıyken pencerenin önündedir; 'at the side' kısa tanımla çelişiyordu. |
| en.hang_up.phv.2 | def.long | To put a coat, shirt or other clothes on a hook or a hanger, so they stay neat. With 'it' or 'them', the word goes in the middle: hang it up. → To put a coat, shirt or other clothes on a hook or a hanger, so they stay neat. Put 'it' or 'them' between 'hang' and 'up': hang it up. | 'the word goes in the middle' belirsizdi. |
| en.water_the_plants.phr.1 | def.long | To make the soil around the flowers and green things in your home or garden wet, for example with a can or a hose, so they stay healthy. You can also say 'water the flowers' or 'water the garden'. → To make the soil around the flowers in your home or garden wet, for example with a can or a hose, so they stay healthy. You can also say 'water the flowers' or 'water the garden'. | 'green things' doğal İngilizce değil. |
| en.furnished.adj.1 | antonyms | ["unfurnished", "empty"] → ["unfurnished"] | 'empty' zıt anlamlı değil. |
| en.plumber.n.1 | tags.topics | ["home_household", "workplace_office"] → ["home_household"] | workplace_office ofis kategorisi; meslek kartları konu kategorisinde (nurse, dentist). |

## Çeldirici çeşitlendirme (2026-10-22)

- Önce: `s14: 45 quizzes, 117 distinct distractors; top: freezer×3, set the table×2, feed the cat×2, melt×2, oven×2, pocket×2`
- Sonra: `s14: 45 quizzes, 117 distinct distractors; top: freezer×3, set the table×2, feed the cat×2, melt×2, oven×2, pocket×2`
- Hedef (hiçbir çeldirici 4'ten fazla soruda değil) baştan sağlanıyordu; en sık çeldirici 3 soruda.
- Son durum (bağımsız doğrulama düzeltmelerinden sonra): `s14: 45 quizzes, 117 distinct distractors; top: freezer×3, fridge×3, set the table×2, feed the cat×2, melt×2, oven×2`. Yazarlara "bir çeldiriciyi kendi dosyanda en çok bir kez kullan" kuralı verildiği için tekrar baştan düşüktü.
- 45 sorunun hepsinde her şık boşluğa konup okundu (biçim, konu yakınlığı, açıkça yanlışlık; yakın anlamlı çiftler).
- Değişen kart sayısı: 1

| kart | önce → sonra | neden |
|---|---|---|
| en.curtain.n.1 | carpet, sofa, mirror → carpets, cushions, mirrors | Cevap çoğul ("curtains"); tekil çeldiriciler biçimden cevabı ele veriyordu. "windows/doors" bilerek seçilmedi ("close the ___" ile doğru olurdu). |

- Yakın anlamlı çiftler: cupboard/drawer/shelf (cupboard: "Open the door"; drawer: "pull it open") ve set the table/clear the table (her iki kartta "Dinner is almost ready" / "We've finished dinner") bağlamla tek cevaba bağlanıyor; değişiklik gerekmedi. Diğer çiftler birbirinin çeldiricisi olarak geçmiyor.
- Cloze'u değiştirilen kart: yok.

## Anadili Türkçe birinin bakması gerekenler

Bağımsız Türkçe doğrulama 15 maddeye karar verdi (ör. 'yatağı toparlamak', 'yeri silmek', 'kombi', 'açık unutmak' kalsın; 'evye' yerine 'lavabo'). Aşağıdakiler yine de bir göz ister.

**Türkçe karşılıklar ve çeviriler:**

- en.sink.n.1 · `l1.tr.gloss`: 'lavabo' (alt 'evye') yapıldı ve akış boyunca mutfak için de 'lavabo' kullanıldı. Mutfakta 'evye/eviye' daha mı doğal?
- en.lock_yourself_out.phr.1 · `l1.tr.gloss`: 'kapıda kalmak'. Türkçede başka nedenle dışarıda kalmayı da anlatır; anahtar anlamı bağlamdan geliyor (`equivalence: partial`).
- en.keep_it_down.phr.1 · `l1.tr.gloss`: 'sessiz olmak' (alt 'sesini kısmak'). Kilit ekranında "keep it down · sessiz olmak" doğal mı?
- en.use_up.phv.1 · `l1.tr.gloss`: 'bitirmek, tüketmek' (alt 'kullanıp bitirmek'). 'finish' ile karışmasın diye not `run out of` farkını anlatıyor; yeterli mi?
- en.settle_in.phv.1 · `l1.tr.gloss`: 'yeni yerine alışmak' mı, 'yeni yere alışmak' mı?
- en.noisy.adj.1 · `examples[0].tr`: "Çocuklar bugün çok gürültücü." 'Gürültücü' huy gibi duruyor; bugünlük durum için 'gürültü yapıyor' daha mı doğal?
- en.oven.n.1 · `examples[1].tr`: "fırını açtı" (turned on). Kapağını açmak gibi de okunabilir; 'fırını yaktı' ya da 'fırını çalıştırdı' daha mı iyi?
- en.cupboard.n.1 · `l1.tr.note`: "'kabırd' gibi söylenir" sesletim ipucu yeterince açık mı (UK'de sondaki r okunmaz)?
- en.heating.n.1 · `l1.tr.gloss`: ana karşılık 'kalorifer', alt 'ısıtma', 'kombi'. Sıra doğru mu?

**Yaygın hatalar (Türk öğrencilerde gerçekten sık mı?):** Hepsi Türkçeden gelebilir ve bağımsız doğrulama gerçek buldu, ama derlemle doğrulanmadı.

- en.clear_the_table.phr.1: "Can you collect the table?" ('sofrayı toplamak').
- en.oven.n.1: "I bought fresh bread from the oven." ('fırın' = bakery). Not aynı bilgiyi veriyor; silinirse bilgi kaybolmaz.
- en.sweep.v.1: "I swept the carpet with the vacuum cleaner." ('süpürmek' ikisi için).
- en.heating.n.1: "Can you open the heating?" ('kaloriferi aç').
- en.leave_on.phv.1: "I left the light open." ('ışığı açık bırakmak').
- Silinen ya da eklenmeyen adaylar (sıksa geri eklenebilir): `spill` "I poured my tea on the table" (kazayla dökmek için 'pour'), `light bulb` "The bulb is burned" ('ampul yandı'), `get rid of` "get rid from" ('-den kurtulmak'), `for rent` "a for rent flat" ('kiralık daire' sırası).

## Derleme için not (s14 dışı, dokunulmadı)

- UK IPA'da hece oluşturan l'yi /l/ yazan kartlar başka akışlarda da var: `timetable` /ˈtaɪmteɪbl/ (s2), `twist your ankle` /ˈæŋkl/ (s12). Depo geleneği /əl/.
- s13 `make yourself at home` IPA'sında hâlâ iki ana vurgu var.
