# s6 QA incelemesi (günlük eylemler: dinlenmek, yıkamak, yürümek, atmak, tutmak ...)

Kapsam: `content/drafts/kisisel_v1/s6/part_01.json` ... `part_06.json`. Bakılan kriterler: `SYSTEM_C` listesi (anlam, tanım, örnek, Türkçe karşılık, Türkçe çeviri, IPA, seviye, hata, not, etimoloji, quiz). Her kartın Türkçe örnekleri İngilizceye geri çevrilerek karşılaştırıldı; her quiz şıkkı boşluğa tek tek konuldu.

## Özet

- İncelenen kart: **51**
- Değişen kart: **22** (hepsine `critic_edited` eklendi)
- Toplam düzenleme (alan sayısı): **31**
- Reddedilen kart (`critic_reject`): **0**
- Seviye değişikliği: yok (verilen seviyelerden hiçbiri bariz yanlış değil)
- Doğrulayıcı (tüm klasör): `51 kart · 51 şemadan geçti · 0 hata · 0 uyarı`

## Özel istekler: kararlar

### 1. Quizler

Her fiil quizinde boşluğa dört şık tek tek konuldu; zaman ve kişi biçimleri de denetlendi (changed, caught, passed, knocked, seems gibi çekimli cevaplarda çeldiricilerin hepsi aynı çekimde ve cümlede dilbilgisi dışı).

- **pass:** Haklısınız. `She studied hard, so she ______ the exam.` cümlesinde `failed` ve `missed` bağlama göre doğru olabilirdi (ironik ya da beklenmedik sonuç). Yeni cümle: `I studied hard and I ______ the exam! I got 90 out of 100.` 90/100 sonucu `failed` ve `missed` ile çelişir. `drove` yerine sınav alanından `forgot` kondu (bu cümlede o da açıkça yanlış).
- **prefer:** Sorun yok. `I like tea and coffee, but I ______ tea in the morning.` cümlesine tek uyan `prefer`. Şıklar (wash, throw, push) cümlede dilbilgisi olarak mümkün ama anlamca anlamsız. Bırakıldı.
- **follow (gerçek hata bulundu):** `I don't know the way. Please ______ me and I'll show you.` Cümle kendi içinde çelişiyordu: yolu bilmeyen kişi gösteremez. `I know the way.` yapıldı.
- **allow:** `You can't park here. The police don't ______ cars ...` park yasağı ile araç yasağı karışıyordu. `parking` yapıldı.
- **drop:** `Don't wash it on the floor` dilbilgisi ve anlam olarak kurulabilen bir cümle. `wash` çeldiricisi `lock` yapıldı.
- **belong:** `Is this your pen? ... Does it ______ to you?` aynı soruyu iki kez soruyordu. Sadeleştirildi.
- Diğer tüm fiil quizlerinde tek doğru cevap kuralı sağlanıyor. Sınırda bulunanlar bırakıldı: `walk` (`I don't have a car, so I drive` mantıkça çelişkili), `touch` (`Do not count the paintings` müzede tabela olmaz), `catch` (`washed it with both hands` olay akışına uymuyor).

### 2. Hata cümleleri

| Hata | Karar | Neden |
|---|---|---|
| pass: `passed from the exam` | Kaldı | 'Sınavdan geçmek' (-dan) çok yaygın Türkçe; "passed from" Türkçe konuşanların klasik hatası. |
| seem: `seems like tired` | Kaldı | 'Yorgun gibi görünüyor' kelimesi kelimesine. Gerçek ve sık. Nottaki 'seem like yalnızca isimle' yanlıştı, düzeltildi. |
| prepare: `I'm preparing` | Kaldı | 'Hazırlanıyorum' -> 'I'm getting ready' için tipik hata. Cümledeki `I'll come in five minutes` Türkçe kalıp gibiydi, `I'll be there in five minutes` yapıldı. |
| drive: `with my car` | Kaldı | '-la/-le' (arabayla) -> 'with'. 'I come with bus' ailesinin bilinen hatası. |
| dream: `see a dream` | Kaldı | 'Rüya görmek' -> 'see a dream'. Çok yaygın. |
| wonder: `Don't wonder` | Kaldı | 'Merak etme' -> 'Don't wonder'. Gerçek ve çok yaygın. |
| hold: `holds her promises` | Kaldı | 'Söz tutmak' -> 'hold a promise'. Gerçek. |
| smell: `I feel the smell of coffee` | Kaldı (emin değilim) | 'Kokuyu hissetmek' Türkçede söylenir, aktarım makul. Sıklığı doğrulanmadı (aşağıdaki listede). |
| knock: `knock the door` | Kaldı | 'Kapıyı çalmak' (-yı hâli) -> edat unutulur. Gerçek. |
| join: `join to` | Kaldı | 'Takıma katılmak' (-e hâli) -> 'to'. Çok yaygın. |
| explain: `explain me` | Kaldı, `why` düzeltildi | Eski açıklama 'kişi başa gelir' diyordu; asıl neden Türkçede kişinin '-a/-e' ekiyle edatsız söylenmesi. |
| check: `control` | Kaldı | 'Kontrol etmek' -> 'control'. Gerçek ve bilinen karışıklık. |
| lock: `closed the door with the key` | **Silindi** | 'Kapıyı anahtarla kapatmak' kalıplaşmış Türkçe değil; hata 'lock' sözcüğünü bilmemekten çıkıyor, Türkçe etkisi değil. Nottaki aynı kalıba dayanan cümle de yeniden yazıldı. |

Ayrıca bakılıp **kalanlar**: `by foot` (walk), `choosed` / `catched` (düzenli çekim alışkanlığı; evrensel ama Türkçenin tamamen düzenli fiil çekimi gerçek bir etken), `describe me` (explain ile aynı aktarım, daha seyrek), `sleep at eleven` (yatmak/uyumak).

### 3. `smell` kartı

Seçilen anlam **kokusunu almak** (`I can smell coffee`). Tanım, üç örnek, gloss (kokusunu almak, koklamak), hata (`I feel the smell`) ve quiz aynı anlamı gösteriyor, yani kart kendi içinde tutarlı. `It smells good` (kokmak) A2'de en az bunun kadar sık, ama bu **ayrı bir anlam** ve kart başına tek anlam kuralı var. Notta ikisi karışık anlatılıyordu ('aynı zamanda kokmak', 'Smells well denmez' nereye ait belli değildi). Not şimdi iki anlamı açıkça ayırıyor: kokusunu almak / kokmak (sonra sıfat gelir). **Öneri:** `en.smell.v.2` (kokmak, `The soup smells good.`) ayrı bir kart olarak sonraki turda eklensin; bu tur kartın anlamı değiştirilmedi.

### 4. Etimolojiler (medium)

| Kelime | Karar |
|---|---|
| choose | Kaldı. Eski İngilizce 'cēosan' hem 'seçmek' hem 'tatmak, denemek'; Latince 'gustare' ile aynı Hint-Avrupa kökü. Doğru ve temkinli yazılmış. |
| practice | Kaldı. Yunanca 'praktikos' < 'prassein' (yapmak), Latince ve Fransızca üzerinden. Doğru. |
| improve | Genişletildi. Anglo-Fransızca 'emprouwer' (kâra çevirmek) doğru; ama 'kâr' -> 'daha iyi yapmak' geçişi eksikti. 'Later it came to mean make better' eklendi. |
| check | Yeniden yazıldı. Satranç kökü (Eski Fransızca 'eschec' < Farsça 'şah') doğru, ama 'kontrol etme' anlamı doğrudan satrançtan gelmiş gibi okunuyordu. Şimdi 'anlam sonradan gelişti' diyor. |
| enjoy | Kaldı. Eski Fransızca 'enjoir' (sevinmek) < en- + joir; 'joy' ile akraba. Doğru. |
| knock | Kaldı. Eski İngilizce 'cnocian', büyük olasılıkla ses taklidi. 'probably' ile temkinli yazılmış; doğru. |
| show | Kaldı. Eski İngilizce 'scēawian' = bakmak; 'göstermek' anlamı sonradan. Doğru (Almanca 'schauen' ile akraba). |

Yüksek güvenli etimolojilerden de (cook, clean, drive, walk, share, explain, repeat, prefer, prepare, describe, join, change, push, throw, catch, count, mind, wonder, notice, expect, recognize, plan, order, return, hold, grow) hiçbirinde halk etimolojisi ya da uydurma yok. Etimolojisi `null` olanlar zaten boştu.

### 5. IPA

- **wash:** ABD ünlüsü `/wɔːʃ/` idi; s1-s4 geleneğine (`watch /wɑːtʃ/`, `want /wɑːnt/`) uyarak `/wɑːʃ/` yapıldı. UK `/wɒʃ/` doğru.
- **knock** `/nɑːk/ /nɒk/`, **lock** `/lɑːk/ /lɒk/`, **drop** `/drɑːp/ /drɒp/`, **follow** `/ˈfɑːloʊ/ /ˈfɒləʊ/`: s1-s4 geleneğiyle (`chop`, `sock`, `jog`, `rob`, `job`, `drop off`) tutarlı, değişmedi.
- Çok heceli tüm kelimelerde vurgu doğru hecede (explain, prefer, prepare, describe, enjoy, notice, expect, belong, recognize, return, allow, improve, wonder, order, practice, follow).

## Genel bulgular

- Kartların çoğu iyi durumda: tanımlar döngüsüz, örnekler doğal, ilk örnekler kilit ekranı için güvenli, Türkçe çeviriler geri çevrildiğinde İngilizceyle uyuşuyor.
- En sık sorun **Türkçe notlarda aşırı kesin ifade** (`yalnızca`, `denmez`): count, hold, seem, improve, pass. Bunlar gerçek kullanımın bir kısmını yok sayıyordu, yumuşatıldı.
- İkinci sorun **uydurma ya da zayıf Türkçe dayanak** (lock'taki 'kapıyı anahtarla kapatmak', explain/describe'daki açıklamalar): neden yanlış açıklanmıştı ya da Türkçede o kalıp yoktu.
- Üçüncü sorun **quiz mantığı**: pass (birden çok şık bağlama göre doğru), follow (cümle kendi içinde çelişik), allow, drop, belong (doğal olmayan cümle).
- **Quiz çeldiricileri güvenli ama zayıf.** Çoğu quizde çeldiriciler cümleyle hiç ilgisi olmayan fiiller (`wash`, `lock`, `count`, `cook` aynı üçlü onlarca kartta tekrarlanıyor). Tek doğru cevap kuralı sağlanıyor, ama öğrenci kelimeyi bilmeden de eleme yoluyla bulabilir. İlgili alandan çeldirici seçmek (rest için `run/dance`, pull için `push` gibi) bu akışta doğru cevabı belirsizleştirme riski taşıdığı için (örn. `wash/buy/eat` cook cümlesinde de doğru olurdu) toplu değiştirilmedi. Sonraki turda kart kart, her şık cümleye konarak yapılması önerilir.
- Bir kart iki kullanımı birleştiriyor: **catch** (top yakalamak ve otobüse yetişmek). Not ikisini açıkça ayırıyor; ileride bölmek istenirse `catch.v.2` (otobüse/trene yetişmek) ayrı kart olabilir.
- Küçük düzeltmeler: expect'in `primary_topic` değeri `weather_seasons` idi (yalnızca ilk örnekteki 'rain' yüzünden), `emotions_feelings` yapıldı. pull'da `pulley` ('makara', Eski Fransızca poulie) 'pull' ile akraba değil, kelime ailesinden çıkarıldı.
- Bu akışta başka akışlarla çakışan kart yok (s1-s5, s7-s9 kontrol edildi). Seviyeler (A1-B1) makul.

## Değişiklik tablosu

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.wash.v.1 | ipa.us | /wɔːʃ/ → /wɑːʃ/ | US IPA geleneği (watch /wɑːtʃ/, want /wɑːnt/) ile tutarlı: /wɑːʃ/ (UK /wɒʃ/ kalır). |
| en.cook.v.1 | sense_note | make food hot to eat → prepare food with heat | 'make food hot to eat' soğuk servis edilen pişmiş yemeği dışarıda bırakıyor ve yanıltıcı. |
| en.check.v.1 | etymology.text | The word 'check' comes from chess, through Old French 'eschec', from Persian 'shāh', meaning king. → From Old French 'eschec', the chess word 'check', which came from Persian 'shāh' (king). The meaning 'test or make sure' developed later. | Eski metin 'kontrol etme' anlamının doğrudan satrançtan geldiğini düşündürüyordu; şimdi satranç kökü ve anlamın sonradan gelişmesi ayrıldı. |
| en.explain.v.1 | l1.tr.mistakes.0.why | Türkçede 'bana açıkla' dersiniz; kişi başa gelir. İngilizcede 'explain' önce nesneyi alır, kişi 'to' ile sona gelir: explain sth to sb. → Türkçede kişi '-a/-e' ekiyle söylenir ('bana açıkla'), edat gerekmez. İngilizcede 'explain' kişiyi doğrudan almaz; kişi 'to' ile gelir: explain sth to sb. | Eski açıklama sorunu söz dizimine ('kişi başa gelir') bağlıyordu; asıl neden Türkçede '-a/-e' hâlinin edatsız kişi bildirmesi. |
| en.describe.v.1 | l1.tr.note | Türkçedeki 'tarif' yemek tarifi (recipe) ve yol tarifi (directions) için de kullanılır. 'Describe' bunların hiçbiri değildir; bir şeyin nasıl olduğunu anlatır. → Türkçedeki 'tarif' yemek tarifi (recipe) ve yol tarifi (directions) için de kullanılır; bunlar için 'describe' denmez. 'Describe' bir kişinin ya da şeyin nasıl olduğunu anlatır. | Eski notta dilbilgisi hatası vardı ('bir şeyi nasıl olduğunu') ve 'bunların hiçbiri değildir' cümlesi anlaşılmıyordu. |
| en.describe.v.1 | l1.tr.mistakes.0.why | Türkçede 'bana tarif et' dersiniz; kişi başa gelir. İngilizcede 'describe' önce nesneyi alır, kişi 'to' ile sona gelir: describe sb/sth to sb. → Türkçede kişi '-a/-e' ekiyle söylenir ('bana tarif et'), edat gerekmez. İngilizcede 'describe' kişiyi doğrudan almaz; kişi 'to' ile gelir: describe sb/sth to sb. | 'Kişi başa gelir' açıklaması asıl nedeni (edatsız -a/-e hâli) göstermiyordu. |
| en.follow.v.1 | quiz.cloze | I don't know the way. Please ______ me and I'll show you. → I know the way. Please ______ me, and I'll show you. | Eski cümle ('I don't know the way ... I'll show you') kendi içinde çelişiyordu: yolu bilmeyen kişi gösteremez. |
| en.pass.v.1 | quiz.cloze | She studied hard, so she ______ the exam. → I studied hard and I ______ the exam! I got 90 out of 100. | 'failed' ve 'missed' eski cümlede (She studied hard, so she ___ the exam) bağlama göre doğru olabilirdi. '90 out of 100' sonucu yalnızca 'passed' ile uyuşur. |
| en.pass.v.1 | quiz.distractors | ["failed", "missed", "drove"] → ["failed", "missed", "forgot"] | 'drove' yerine sınav alanından ama yeni cümlede açıkça yanlış bir fiil ('forgot'); '90 out of 100' ile çelişir. |
| en.pass.v.1 | def.micro | get a good result in a test → get enough points in a test | 'get a good result' fazla güçlü: sınırda geçen kişi de 'pass' eder; 'enough points' anlamı doğru verir. |
| en.pass.v.1 | l1.tr.note | 'Pass' sınavda başarılı olmak demektir; karşıtı 'fail'. Zaman ya da tatil geçirmek için 'pass' değil 'spend' kullanılır: 'spend time'. → 'Pass' sınavda başarılı olmak demektir; karşıtı 'fail'. Tatil ya da zaman geçirmek için genellikle 'pass' değil 'spend' kullanılır: 'spend the holiday', 'spend time'. | 'Zaman geçirmek için pass değil spend' kesin kural gibi yazılmıştı; 'pass the time' (sıkıntıyla vakit geçirmek) de var, ifade yumuşatıldı. |
| en.lock.v.1 | l1.tr.mistakes | [{"wrong": "I closed the door with the key.", "right": "I locked the door.", "why": "Türkçede 'kapıyı anahtarla kapatmak' dersiniz. İngilizcede bunun tek bir fiili var: 'lock'. 'Close' yalnızca kapıyı kapatır, kilitlemez."}] → [] | 'Kapıyı anahtarla kapatmak' kalıplaşmış bir Türkçe söyleyiş değil; hata Türkçe etkisinden çok 'lock' sözcüğünü bilmemekten çıkıyor. Zorlama hata silindi. |
| en.lock.v.1 | l1.tr.note | 'Kapıyı anahtarla kapatmak' yerine 'lock the door' denir. 'Close' yalnızca kapatır, 'lock' kilitler. Kilidi açmak için 'unlock' kullanılır. → 'Close the door' kapıyı kapatmak, 'lock the door' kapıyı kilitlemek demektir; ikisi aynı şey değildir. Kilidi açmak için 'unlock', kilitli için 'locked' denir. | Eski not uydurma bir Türkçe kalıba ('kapıyı anahtarla kapatmak') dayanıyordu. |
| en.count.v.1 | l1.tr.note | Türkçede 'saymak' 'saygı duymak' anlamına da gelir ('Seni çok sayarım'); 'count' yalnızca sayı saymak ve toplamını bulmaktır. 'Count on' (güvenmek) ayrı bir kalıptır. → Türkçede 'saymak' 'saygı duymak' anlamına da gelir ('Seni çok sayarım'); 'count' bu anlamda kullanılmaz. 'Count' sayı saymak ve toplamını bulmaktır. 'Count on' (güvenmek) ayrı bir kalıptır. | 'count yalnızca sayı saymaktır' fazla kesindi ('Every vote counts' gibi başka kullanımları var); ifade bu anlama sınırlandı. |
| en.smell.v.1 | l1.tr.note | 'Smell' aynı zamanda 'kokmak' demektir: 'It smells good' (iyi kokuyor). Sonrasında sıfat gelir: smells good, smells bad. 'Smells well' denmez. → 'Smell' iki ayrı şey anlatır: kokusunu almak ('I can smell coffee') ve kokmak ('It smells good'). Kokmak anlamında sonra sıfat gelir: smells good, smells bad; 'smells well' denmez. | Eski not iki anlamı karıştırıyordu ('aynı zamanda kokmak'); şimdi kartın anlamı (kokusunu almak) ile ikinci anlam (kokmak) açıkça ayrıldı. |
| en.expect.v.1 | tags.primary_topic | weather_seasons → emotions_feelings | 'weather_seasons' yalnızca ilk örnekteki 'rain' yüzünden seçilmişti; 'expect' hava durumu kelimesi değil. Benzer fiiller (hope, think) s3-s5'te emotions_feelings altında. |
| en.expect.v.1 | tags.topics | ["weather_seasons", "social_skills"] → ["emotions_feelings", "social_skills"] | primary_topic ile uyum. |
| en.pull.v.1 | word_family | [{"lemma": "pullover", "pos": "n"}, {"lemma": "pulley", "pos": "n"}] → [{"lemma": "pullover", "pos": "n"}] | 'pulley' (makara) 'pull' ile akraba değil (Eski Fransızca poulie); yanlış kelime ailesi kaydı kaldırıldı. |
| en.dream.v.1 | collocations | ["dream about sb", "dream of sth", "dream at night", "dream that ..."] → ["dream about sb", "dream of sth", "dream that ..."] | 'dream at night' kalıplaşmış bir eşdizim değil (serbest birleşim); eşdizim uydurma olmamalı. |
| en.belong.v.1 | collocations | ["belong to sb", "belong to a club", "belong together", "belong here", "belong in a box"] → ["belong to sb", "belong to a club", "belong together", "belong here", "belong to a team"] | 'belong in a box' sık bir eşdizim değil; 'belong to a team' gerçek ve yaygın. |
| en.belong.v.1 | quiz.cloze | Is this your pen? I found it on the floor. Does it ______ to you? → I found this pen on the floor. Does it ______ to you? | 'Is this your pen? ... Does it ___ to you?' aynı soruyu iki kez soruyordu; doğal değildi. |
| en.order.v.1 | def.long | To ask for food or a drink in a restaurant or café. The waiter comes to your table, and you tell him what you want. → To ask for food or a drink in a restaurant or café. The waiter comes to your table, and you say what you want. | Garson için 'him' cinsiyet varsayımı; yansız hâle getirildi. |
| en.grow.v.1 | examples.2.tr | Fabrika açılınca kasaba hızla büyüdü. → Yeni fabrika açılınca kasaba hızla büyüdü. | Çeviride 'new' (yeni) kaybolmuştu. |
| en.drop.v.1 | quiz.distractors | ["fall", "wash", "cook"] → ["fall", "lock", "cook"] | 'Don't wash it on the floor' dilbilgisi ve anlam olarak mümkün bir cümle; 'wash' çeldiricisi 'lock' ile değiştirildi. |
| en.hold.v.1 | l1.tr.note | Türkçede 'tutmak' çok anlamlıdır: elinde tutmak (hold), yakalamak (catch), sözünü tutmak (keep a promise). 'Hold' yalnızca elinde ya da kollarında tutmaktır. Düzensiz fiil: hold - held - held. → Türkçede 'tutmak' çok anlamlıdır: elinde tutmak (hold), yakalamak (catch), sözünü tutmak (keep a promise). Bu anlamda 'hold' elinde ya da kollarında tutmaktır. Düzensiz fiil: hold - held - held. | 'Hold yalnızca ...' fazla kesindi ('hold a meeting', 'hold the line' gibi başka anlamları var). |
| en.seem.v.1 | l1.tr.note | 'Seem' sonrasında sıfat doğrudan gelir: 'seems tired'. 'Seem like' yalnızca isimle kullanılır: 'It seems like a good idea.' 'Seems like tired' denmez. → 'Seem' sonrasında sıfat doğrudan gelir: 'seems tired'. 'Seem like' ise isimle gelir: 'It seems like a good idea.' 'Seems like tired' denmez. | 'Seem like yalnızca isimle' yanlıştı: 'It seems like the shop is closed' (cümleyle) de yaygın. |
| en.allow.v.1 | quiz.cloze | You can't park here. The police don't ______ cars on this street. → You can't park here. The police don't ______ parking on this street. | Eski cümlede 'You can't park' ile 'don't allow cars' çelişkiliydi (park yasağı ile araç yasağı farklı); 'parking' ile mantık tutuyor. |
| en.improve.v.1 | etymology.text | From Anglo-French 'emprouwer', meaning 'to make a profit from', built on Old French 'prou' (profit). → From Anglo-French 'emprouwer', 'to turn to profit', built on Old French 'prou' (profit). Later it came to mean 'make better'. | Gerçek; ama 'kâr' kökünün 'iyileştirmek' anlamına nasıl vardığı eksikti. Anlamın sonradan 'daha iyi yapmak'a kaydığı eklendi. |
| en.improve.v.1 | l1.tr.note | Türkçede 'geliştirmek' İngilizcede çoğu zaman 'improve' olur; 'develop' daha çok yeni bir şey (plan, ürün) geliştirmek içindir. 'Improve my English' denir, 'develop my English' denmez. → Türkçede 'geliştirmek' İngilizcede çoğu zaman 'improve' olur; 'develop' daha çok yeni bir şey (plan, ürün) geliştirmek içindir. 'Improve my English' denir; 'develop my English' pek duyulmaz. | 'develop my English denmez' fazla kesin ('develop your English skills' kullanılır); 'pek duyulmaz' denerek yumuşatıldı. |
| en.prepare.v.1 | l1.tr.mistakes.0.wrong | Wait, I'm preparing. I'll come in five minutes. → Wait, I'm preparing. I'll be there in five minutes. | İki cümlede de 'I'll come in five minutes' Türkçe kalıp gibi duruyordu; 'I'll be there in five minutes' doğal. |
| en.prepare.v.1 | l1.tr.mistakes.0.right | Wait, I'm getting ready. I'll come in five minutes. → Wait, I'm getting ready. I'll be there in five minutes. | Doğru cümle de anadilinden biri gibi doğal olsun. |

## Anadili Türkçe birinin bakması gerekenler

- **en.smell.v.1**: `mistakes[0]` 'I feel the smell of coffee.' 'Kokuyu hissetmek' Türkçede söylenir ama bu hata Türk öğrencilerde gerçekten sık mı? Daha olası hata 'I'm smelling coffee' (şimdiki zaman) olabilir. Ayrıca gloss 'kokusunu almak' tek sözcük değil; 'koklamak' alt olarak yeterli mi? `smell.v.2` (kokmak) ayrı kart olarak eklensin mi?
- **en.lock.v.1**: Silinen hata 'I closed the door with the key.' Türkçede 'kapıyı anahtarla kapatmak' gerçekten kullanılıyorsa (ör. 'kapıyı çift kilit kapat'), hata geri eklenebilir. Ben kalıplaşmış bulmadım.
- **en.walk.v.1**: `mistakes[0]` 'by foot'. Türk öğrencilerde sık, ama başka dillerde de görülen bir hata. `why` Türkçeye bağlı bir neden göstermiyor, 'by bus' kalıbını yanlış genelleme olarak anlatıyor. Bırakıldı.
- **en.describe.v.1**: `mistakes[0]` 'Describe me your best friend.' 'Explain me' kadar yaygın mı? Aynı aktarım var ama 'describe' A2 öğrencisinde seyrek bu kalıpta geçer.
- **en.sleep.v.1**: `mistakes[0]` 'I usually sleep at eleven.' Kaynak 'yatmak' mı, 'uyumak' mı? 'Saat 11'de uyurum' da denir; hata o zaman daha az Türkçeye özgü.
- **en.choose.v.1, en.catch.v.1**: 'choosed' / 'catched'. 'Fiil çekimi Türkçede hep düzenlidir' gerekçesi doğru ama bu hata her dilden öğrencide görülür. Türkçeye özgü sayılır mı?
- **en.check.v.1**: Yeni etimoloji metni 'The meaning test or make sure developed later' diyor. Daha ayrıntılı (satranç -> 'durdurmak' -> 'doğrulamak') anlatım istenirse kaynakla doğrulanmalı; ben yalnızca emin olduğum kısmı yazdım.
- **en.mind.v.1**: Karşılık 'sakınca görmek'. Günlük konuşmada 'umursamak' (alt) daha mı yaygın? 'Do you mind if...' için 'sakıncası var mı' doğru, ama 'I don't mind' için 'sorun değil / fark etmez' daha doğal olabilir. Örnek 2 çevirisi ('rahatsız olmam') biraz resmî.
- **en.seem.v.1**: Karşılık 'gibi görünmek' (alt 'görünmek'). Tek başına 'görünmek' sözlük karşılığı olarak birinci sırada olmalı mı?
- **en.practice.v.1**: Örnek 2 'piyano çalışıyor' (practice the piano). 'Çalmak' ile karışmaz mı? Karşılık listesine 'çalışmak' eklenmedi.
- **en.pass.v.1**: Karşılık 'sınavı geçmek' nesneyi içeriyor ve 'geçmek' tek başına belirsiz olduğu için bırakıldı. Alt 'başarmak' yeterli mi?
- **en.shout.v.1**: Örnek 2 ('shouted to her friend across the street' -> 'bağırdı'). 'Seslendi' daha doğru olabilir; not zaten 'shout to = seslenmek' diyor.
- **en.wash.v.1**: Örnek 3 'My brother' -> 'Kardeşim'. Cinsiyet kayboluyor ('erkek kardeşim' daha tam ama ağır). Bırakıldı.

## Sayılar

| Ölçü | Sayı |
|---|---|
| İncelenen kart | 51 |
| Değişen kart | 22 |
| Düzenlenen alan | 31 |
| Reddedilen kart | 0 |
| Doğrulayıcı sonucu | 0 hata, 0 uyarı |

## Çeldirici çeşitlendirme (2026-10-19)

- Önce: 51 soru, 29 farklı çeldirici; en sık: wash×33, lock×19, cook×15, count×14, sleep×12, drive×10.
- Sonra: 51 soru, 76 farklı çeldirici; en sık: cook×4, bake×4, drive×4, chop×4, iron×4, shout×4. Doğrulayıcı sınırı (`QUIZ_DISTRACTOR_REPEAT`): 4.
- Çeldiricisi değişen kart: 47 (`distractors_diversified`). Doğru cevaplar değişmedi.
- Bu bölümü editör (Opus) yazdı: çeşitlendirme ajanı işini bitirip raporu yazamadan kullanım sınırına takıldı. Sayılar dosyalardan ölçüldü.
