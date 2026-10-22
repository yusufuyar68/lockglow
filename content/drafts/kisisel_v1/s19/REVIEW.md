# s19 QA incelemesi (boş zaman: hobiler, spor, oyunlar, dizi/film, müzik)

Kapsam: `content/drafts/kisisel_v1/s19/part_01.json` ... `part_05.json` (45 kart). Konu: hobiler ve boş zaman (10), spor ve maç (10), spor salonu ve form (10), oyunlar ve evde dizi (10), müzik, sanat ve öneri (5). Seviye A2–B1.

Süreç (`docs/icerik_uretimi/README.md`; s17 ve s18 ile aynı). Bütün ajanlar Opus (orta çaba):

1. **Yazım:** Part başına bir yazar ajanı (5 ajan), `1_yazar_kurallari.md`. Koordinatör her kelime için tür, kimlik, seviye, anlam ipucu, var olan ilgili kartlar, isim listesi ve (varsa) Türkçeden gelen hata adayını verdi; yazarlar adayları ancak kendileri de gerçek bulursa kullandı.
2. **Denetim:** Part başına bir denetçi ajanı (5 ajan), `2_denetci_kurallari.md` ve `SYSTEM_C`. Yazarların "emin olmadığım" maddeleri her denetçiye ayrıca verildi. Dört denetçi kullanım sınırında durdu; sınır sıfırlanınca kaldıkları yerden devam ettirildi (dosyalar yarım kalmamıştı; part_03 denetçisi sınırdan sonra başladı).
3. **Bağımsız doğrulama:** Kartları değiştirmeyen üç ayrı doğrulayıcı ajan bütün akışı okudu: (a) quiz'de tek doğru cevap, (b) Türkçe katman (geri çeviri, gloss, gloss_short, not, hata, TDK yazımı), (c) İngilizce içerik, IPA ve üstveri. Koordinatör bulguları tartıp uyguladı; uygulanan her alanı bir son kontrol ajanı ayrıca sınadı.
4. **Çeldirici kontrolü:** `3_celdirici_kurallari.md` ölçümü (aşağıda ayrı bölüm).

## Özet

- İncelenen kart: **45** (A2: 18, B1: 27)
- Tür: 35 kelime (`word`), 4 eşdizim (`collocation`), 4 kalıp (`phrase`), 2 phrasal verb
- `primary_topic`: `hobbies_sports` 30, `music_film` 8, `health_body` 5, `home_household` 1 (remote), `culture_celebrations` 1 (exhibition)
- Değişen kart: **33** (hepsine `critic_edited` eklendi). Hiç değişmeyen: hobby, spare time, knit, team, match, goal, referee, race, rule, play cards, binge-watch, remote.
- Alan sayısı (meta hariç): denetimde 56 değişiklik satırı (aşağıdaki tablo; bazı satırlar birden çok alanı kapsıyor), doğrulama ve son kontrolde 20 kartta 32 alan.
- Reddedilen kart (`critic_reject`): **0**
- Yaygın hata (`mistakes`): 11 kartta 11 madde (spare time, go fishing, collect, beat, race, gym, lose weight, put on weight, exhausted, ending, audience). Silinen: support "Which team do you hold?", turn "It's your queue." (kanıt bulunamadı), recommend "I recommend you to watch" (kalıp İngiliz İngilizcesinde resmî dilde geçerli). Etimoloji 9 kartta. Sahte dost yok.
- `gloss_short` 3 kartta: take up "hobiye başlamak", stretch "esneme yapmak", sing along "beraber söylemek".
- `confusables` 13 kartta 14 kayıt: collect → save, relax → rest, match → game, beat → win, live → alive, sweat → sweet, stretch → yawn, exhausted → exhausting, turn → queue, season → series, ending → end, recommend → suggest, advise, audience → crowd. Destede kartı olan eşlere (save, rest, win, queue, suggest) ayrıca yazılmadı; derleyici çifti iki yönlü bağlıyor.
- Doğrulayıcı (tüm klasör, `--strict`): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`

## Kelime seçimi

- **Konu:** derlenmiş içerikte (`content.sqlite`, `2026.10.22-kisisel-7`, 1.068 kart) günlük hayat grubunun (A) en az kartlı kategorisi `hobbies_sports`: birincil 12, etiketli 24 kart. `music_film` 11/20. Boş zaman (hobiler, spor, maç, spor salonu, oyun, dizi) A2–B1'in temel konuşma konusu ("What do you do in your free time?", "Which team do you support?"). Sonraki adaylar: `culture_celebrations` 9/16, `love_friendship` 14/31, `clothes_fashion` 19/39.
- Var olan kartlarla aynı anlam yazılmadı: jog, hike, ride, puzzle, board game, fan, score, equipment, playlist, series, episode, band, lyrics, podcast, subtitles, trailer, stream (s2); win, lose, fun, bored (s3); work out, warm up, join in, hang out (s4); enjoy, practice, join, throw, catch (s6); have fun (s8); go for a walk, go camping, have a picnic (s16).
- Aynı lemmanın yeni anlamı ya da türü: `season` **sense 2** (dizi sezonu; s16'da sense 1 mevsim), `live` **sıfat** (canlı yayın; s5'te fiil yaşamak), `fit` **sıfat** (formda; s1'de fiil uymak), `support` sense 2 (takım tutmak), `turn` isim (sıra).
- Kimlik ve tekrar taraması (koordinatörün `cross_check.py`'si, son düzeltmelerden sonra): s0–s18 ile kimlik, `def.short`, örnek cümle ya da quiz cümlesi çakışması yok; tek bilgi notu beklenen season n.1/n.2 eşleşmesi. 45 kimliğin hiçbiri `id_registry.json`'da yok.

## Genel bulgular

- Kartların çoğu iyi durumdaydı: ilk örnekler kısa ve kilit ekranına güvenli, tanımlar döngüsüz, seviyeler makul. Seviye değişmedi.
- **En sık 3 sorun:**
  1. **Kilit ekranında tek başına yanlış okunan Türkçe karşılıklar.** be into "meraklı olmak" (merak eden kişi gibi) → "meraklısı olmak"; take up "uğraşa başlamak" → "bir hobiye başlamak"; ending "son" → "son, final"; sing along "şarkıya katılmak" (yarışmaya katılmak gibi) → "beraber söylemek"; train alt "çalışmak" çıktı. stretch notu düzeldi: kişi için "esnemek" yalnızca yawn; stretch "gerinmek / esneme hareketi yapmak".
  2. **Quiz'de ikinci okuma ve bir şey sınamayan şıklar.** live ("it's boring on TV" de kuruluyordu), video game ("board games" konsolda da var), collect ("stuck them", "sold"), put on weight ("won a race"). Bağımsız quiz doğrulayıcısı son hâlde **ikinci doğru cevap bulmadı** (YÜKSEK 0, ORTA 0).
  3. **Doğrulanamayan "yaygın hata"lar ve zayıf `why` metinleri.** Üç hata silindi (yukarıda). Kalanların `why` metinleri Türkçenin nasıl yanılttığını anlatacak biçimde yeniden yazıldı (beat, lose weight, put on weight, exhausted, collect).
- **Tekrar:** turn'ün 3. örneği ve cloze'u s1'deki "Whose turn is it to wash the dishes?" ile neredeyse aynıydı; değişti. Yazarlar ve denetçiler bütün akışları taradı.
- **IPA:** DRESS `/ɛ/` (`ipa_dress_stats`: s19'da `/e/` 0), US r'li ünlüler uzunluk işaretli (`/tɜːrn/`), US "on" `/ɑːn/` (put on weight), schwa + n `/-ən/` (exhibition UK düzeldi). referee /ˌrɛfəˈriː/ ve photography /fəˈtɑːɡrəfi/ vurguları doğrulandı.
- **Üstveri:** be into ve binge-watch `informal`; photography ve exhibition'a `art_design_architecture` ikincil konusu eklendi; dört etimolojiye `origin: Latin` eklendi; coach etimolojisi (Kocs köyü, 1800'lerin Oxford argosunda özel öğretmen) netleşti.

## Değişiklik tablosu

### Denetim (5 denetçi)

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| be into | l1.tr.gloss | "bir şeye meraklı olmak" → "-e meraklı olmak" | 16 karaktere sığıyor, gloss_short'a gerek kalmıyor |
| be into | l1.tr.gloss_short | "meraklı olmak" → (silindi) | Tek başına "curious" gibi okunuyordu |
| be into | l1.tr.alt | "bir şeyi çok sevmek" → "-i çok sevmek" | Açıklama yerine kalıp; öteki alt ile aynı biçim |
| be into | examples[0].focus | "really into" → "into" | "really" kalıba ait değil (s18 be good at → "good at") |
| be into | examples[2].focus | "is only into" → "into" | Aynı neden |
| take up | l1.tr.gloss | "yeni bir uğraşa başlamak" → "bir hobiye başlamak" | Daha doğal, sense_note ile aynı |
| take up | l1.tr.gloss_short | "uğraşa başlamak" → "hobiye başlamak" | Kilit ekranında tek başına anlaşılır |
| take up | l1.tr.alt | "bir hobiye başlamak" → "yeni bir uğraşa başlamak" (bir spora başlamak kaldı) | Gloss'a taşınan çıktı, eski gloss alt'a geçti |
| collect | l1.tr.mistakes[0].why | "'collect money' daha çok bağış toplamak demektir" → "başkalarından para toplamak (bağış, aidat) demektir" | Daha doğru |
| collect | examples[0].tr | "Dedem eski madeni paralar biriktirir." → "Dedem eski paralar biriktirir." | Daha doğal |
| collect | quiz.distractors | stuck → lost | "has stuck them (in an album)" zorlama okunuyordu |
| gardening | examples[0] | "Gardening helps me forget my stress." → "Gardening makes me happy." / "Bahçe işleri beni mutlu ediyor." | "forget my stress" doğal değil |
| gardening | examples[2].tr | "…bahçıvanlığa ilgi duymaya başladı…" → "…bahçe işlerine merak sardı…" | Doğal Türkçe; "got interested in" karşılığı |
| photography | def.long | "…Notice the stress: phoTOgraphy, but PHOtograph." → "…Many people learn it on short courses or from online videos." | Tanımda başlık kelime vardı; vurgu bilgisi notta |
| photography | tags.topics | music_film → art_design_architecture | Fotoğraf sanatı müzik/film değil |
| go fishing | def.micro | "go to a lake with a rod" → "go out to catch fish" | "rod" A2 üstü, anlam eksikti |
| go fishing | def.short | "…try to catch the animals that swim there" → "…try to catch fish" | Dolambaçlı |
| go fishing | def.long | "…with a rod and try to catch the animals that swim there…" → "…spend time trying to catch fish, for fun or for food." | Aynı |
| go fishing | quiz.cloze | "Murat took his rod to the lake early in the morning to ______." → "Murat loves to ______, but today he sat by the lake for hours and caught nothing." | "rod" kaldırıldı; bağlam çeldiricileri (skiing, jogging, dancing) açıkça dışlıyor |
| coach | etymology.text | "From Kocs, a town in Hungary... Later, students used 'coach' for a private teacher..." → "From Kocs, a village in Hungary where a kind of carriage was first made. In the 1800s, Oxford students used 'coach' for a private teacher; later it meant a sports trainer." | Daha doğru ve net (Kocs bir köy; özel öğretmen anlamı 19. yy Oxford argosundan) |
| beat | l1.tr.mistakes[0].why | "Türkçede 'yendik' ile 'kazandık' yakın olduğu için 'won' kullanılıyor..." → "'Yenmek' de çoğu zaman 'win' diye öğreniliyor. Ama 'win' rakibi nesne almaz: rakip kişi ya da takımsa 'beat', maç ya da ödülse 'win' gelir." | Hatanın sebebi daha doğru anlatılıyor |
| draw | examples[2].tr | "İki saatlik satrançtan sonra Yuki ve Ozan beraberlikte anlaştı." → "İki saat satranç oynadıktan sonra Yuki ile Ozan berabere kalmayı kabul etti." | Doğal olmayan Türkçe ("agreed to a draw") |
| support | l1.tr.mistakes | "Which team do you hold?" → [] | Gerçek ve yaygın bir hata olduğu doğrulanamadı |
| live | quiz | "The match isn't recorded; it's ______ on TV right now." (famous/boring/tired) → "This isn't a recording; it's a ______ broadcast, so we see the match as it happens." (short/famous/quiet) | "boring" de dilbilgisi olarak boşluğa uyuyordu; bağlam artık yalnızca live'a izin veriyor |
| live | l1.tr.alt | ["naklen"] → [] | "naklen" eski ve günlük dilde az kullanılıyor |
| fit (adj) | l1.tr.note | "Fiil olarak 'fit' başka anlamdadır: 'This jacket fits me.' (Bu ceket bana oluyor.) …" → "Fiil olarak 'fit' beden olarak uymak demektir: 'This jacket fits me.' (Bu ceket bana tam oluyor.) …" | Fiil anlamını (s1 uymak) açıkça adlandırıyor; "bana oluyor" eksik ve konuşma dili kokuyor |
| sweat | examples[1].tr | "Burak koşu bandında yirmi dakika sonra terlemeye başlamıştı." → "Burak koşu bandında yirmi dakikanın sonunda terliyordu." | Geri çeviri: "had started sweating"; İngilizcede "başlamak" yok |
| stretch | sense_note | "make muscles long before sport" → "make your body long, e.g. before sport" | 2. örnek (uyanınca gerinmek) ve def.long yalnızca spordan önceki esnemeyi anlatmıyor |
| stretch | l1.tr.note | "uykudan ağzını açmak 'yawn', kaslarını uzatıp gevşetmek 'stretch'" → "uykusu gelince ağzını açmak 'yawn', kollarını, bacaklarını uzatıp kaslarını gevşetmek 'stretch'" | Daha doğal ve daha açık Türkçe |
| exhausted | mistakes[0].why | "-ed ve -ing karıştırılıyor. …" → "Türkçede 'yorgun' ve 'yorucu' ayrı kelimeler, İngilizcede yalnızca son ek değişiyor. Yorulan kişi için -ed (exhausted) kullanılır; 'I'm exhausting' 'Ben çok yorucu biriyim' demektir." | why, Türkçeyle bağlantıyı ve yanlış cümlenin gerçek anlamını anlatmalı |
| lose weight | mistakes[0].why | "… İngilizcede kilo 'lose' ile verilir." → "Türkçe 'kilo vermek' kelime kelime çevrilince 'give' kullanılıyor. İngilizcede kilo 'kaybedilir': 'lose weight', 'lose 3 kilos'." | "kilo 'lose' ile verilir" çelişkili okunuyordu |
| put on weight | mistakes[0].why | "Türkçede 'kilo almak' dendiği için 'take' kullanılıyor; …" → "Türkçe 'kilo almak' kelime kelime çevrilince 'take' kullanılıyor. İngilizcede 'put on' ya da 'gain' olur: 'put on 2 kilos'." | Daha açık; doğru kalıp örnekle |
| put on weight | quiz.distractors | lost weight, got fit, won a race → lost weight, got fit, become thinner | "won a race" bu cümlede bir şey sınamıyordu; yeni çeldirici aynı biçimde (geçmiş ortaç + tümleç), konuya yakın, cümlede açıkça yanlış |
| membership | examples[2].en | "The swimming club gives a cheaper membership to …" → "The swimming club offers cheaper membership to …" | "offers … membership" daha doğal |
| membership | examples[2].tr | "… daha ucuz üyelik veriyor." → "… daha ucuz üyelik sunuyor." | İngilizce cümleye uyum |
| turn | ipa.us | /tɝːn/ → /tɜːrn/ | Deponun ABD IPA biçimine uyum (turn up, work) |
| turn | examples[2] | "Whose turn is it to do the dishes tonight, Burak's or mine?" → "It's Esra's turn to choose the film tonight." / "Bu akşam filmi seçme sırası Esra'da." | s1 dishes örneği ve cloze'unun tekrarıydı |
| turn | l1.tr.mistakes | "It's your queue." → [] | Yaygın gerçek bir hata olduğu kanıtlanamadı (uydurma riski); ayrım not ve confusables'da veriliyor |
| turn | quiz.cloze | "You played first last time, so now it's my ______." → "You went first last time, so it's my ______ to start." | Daha doğal İngilizce, bağlam daha açık; queue/row/seat hâlâ açıkça yanlış |
| chess | def.micro | "game with a king and queen" → "a black and white board game" | İskambilde de papaz ve kız var; tanım satranca özgü değildi |
| video game | def.short | "...using buttons or a keyboard" → "a game you play on a screen, like on a computer, a phone or a TV" | Telefon oyunları dokunmatik; tanım eksikti |
| video game | def.long | "...with buttons or a keyboard." → "...with buttons, a keyboard or by touching the screen." | Aynı neden |
| video game | quiz.distractors | board games → marbles | Masa oyunları konsolda da oynanabiliyor; ikinci doğru cevap riski |
| backgammon | examples[1].en | "...won the backgammon game." → "...won at backgammon." | Daha doğal kullanım; Türkçesi ("tavlada kazandı") daha iyi örtüşüyor |
| ending | l1.tr.gloss | "son" → "son, final" | Tek başına "son" kilit ekranında belirsiz |
| ending | l1.tr.alt | ["final", "bitiş"] → [] | "final" gloss'a taşındı; "bitiş" hikâye sonu için doğal değil |
| ending | l1.tr.note | "...Sonunu önceden söyleyen kişi ya da bilgi 'spoiler' olur." → "...Filmin sonunu önceden anlatan bilgiye 'spoiler' denir." | 'spoiler' kişi değil, bilgi |
| ending | l1.tr.mistakes[0].why | genişletildi | "happy end"in Türkçede neden yaygın olduğu ve "end"in anlamı netleştirildi |
| recommend | l1.tr.mistakes | "I recommend you to watch this film." → (boş) | Kalıp BrE resmî dilde geçerli sayılıyor (OALD); kesin hata olarak öğretilmemeli |
| recommend | l1.tr.note | "… 'Suggest' ise daha çok bir fikir ortaya atmaktır: 'I suggest we leave now.'" → "… En doğal kalıplar: 'I recommend watching it.', 'I recommend that you watch it.' 'Suggest' ise daha çok bir fikir ortaya atmaktır." | Doğru kalıp bilgisi hatadan nota taşındı (220 karakter sınırı için suggest örneği çıktı) |
| recommend | grammar.pattern | "recommend sth (to sb) / recommend + -ing" → "recommend sth (to sb) / recommend + -ing / that" | "that" kalıbı not ve eşdizimlerle tutarlı |
| sing along | examples[2] | "… but I sing along when the chorus comes." / "… nakarat gelince eşlik ediyorum." → "… but I always sing along to the chorus." / "Sözlerin hepsini bilmiyorum, ama nakarata hep eşlik ediyorum." | "when the chorus comes" doğal değil; yeni cümle "sing along to" kalıbını da gösteriyor |
| sing along | l1.tr.note | "Ardından 'to' ya da 'with' gelir: …" → "Neye eşlik ettiğini söylerken 'to' ya da 'with' gelir: …" | İlk örnekte (ve sık kullanımda) ardından hiçbir şey gelmiyor; not her zaman gelir gibi okunuyordu |
| exhibition | l1.tr.alt | ["fuar"] → [] | Fuar = fair/trade fair, bu kartın anlamı değil |
| exhibition | l1.tr.note | "Ortadaki 'h' okunmaz: 'eksıbişın'. Fuar için de kullanılır. ABD'de …" → "Ortadaki 'h' okunmaz: 'eksıbişın'. ABD'de …" | Aynı neden |
| audience | l1.tr.mistakes | (boş) → "The audiences loved the film." → "The audience loved the film." | Türkçe çoğul "seyirciler" aktarımı; tek salondaki seyirci için "audience" tekil grup adı |

### Doğrulama ve son kontrol (koordinatör, 3 doğrulayıcının bulgularından)

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| be into | l1.tr.gloss, alt | "-e meraklı olmak" / ["-den hoşlanmak", "-i çok sevmek"] → "meraklısı olmak" / ["bir şeye meraklı olmak", "çok sevmek"] | Ekle başlayan karşılık kilit ekranında yarım okunuyordu |
| be into | ipa.us; examples[1].focus | /bi ˈɪntu/ → /bi ˈɪntuː/; "is into" → "into" | Vurgulu, sonda; öteki örneklerle aynı odak |
| stretch | l1.tr.note | "Türkçe 'esnemek' iki anlama gelir…" → "Dikkat: uykusu gelince esnemek 'yawn' olur. Gerinmek ya da spordan önce esneme hareketi yapmak ise 'stretch' olur." | Kişi için "esnemek" yalnızca yawn |
| beat | l1.tr.mistakes[0].why | yeniden yazıldı | Türkçe "onları yendik" kalıbını adlandırıyor |
| train | l1.tr.alt | ["idman yapmak", "çalışmak"] → ["idman yapmak"] | "çalışmak" tek başına iş ya da ders gibi okunuyor |
| exhausted | l1.tr.mistakes[0].why | "Türkçede 'yorgun' ve 'yorucu' ayrı kelimeler…" → "Yorulan kişi için -ed (exhausted), yoran şey için -ing (exhausting) kullanılır…" | Türkçe de yalnızca eki değiştirir (yorgun/yorucu); eski iddia yanlıştı |
| ending | examples[2].tr | "…son bölümün finalinde ağladı." → "…son bölümün finalini izlerken ağladı." | Daha doğal |
| out of breath | examples[1].tr | "…nefes nefese vardı." → "Gül beşinci kata kadar çıktı ve nefes nefese kaldı." | Daha doğal |
| sweat | l1.tr.note; def.long | "Okunuşu 'svet'…" → "Okunuşu 'suet' gibidir (tek hece)."; "When you are hot…" → "To have water come out of your skin because you are hot, nervous or doing hard exercise. …" | /w/ v gibi öğretilmesin; fiil tanımı "To …" ile |
| season | l1.tr.alt; def.short | ["dizi sezonu"] → []; "…that come out in the same year" → "…that come out one after another" | alt, gloss'un açılımıydı; her sezon aynı yıl çıkmaz |
| exhibition | ipa.uk; tags.topics; etymology.origin | /ˌɛksɪˈbɪʃn/ → /ˌɛksɪˈbɪʃən/; + art_design_architecture; + Latin | Depo yazımı; sergi sanat konusu |
| relax | def.micro | "rest and feel calm" → "feel calm and stop worrying" | Kendi karışan kelimesiyle (rest) tanımlanıyordu |
| membership | ipa.us | /ˈmɛmbərˌʃɪp/ → /ˈmɛmbərʃɪp/ | UK ile tutarlı |
| recommend, sing along | def.short | baştaki "to" kalktı | Akıştaki öteki fiil tanımlarıyla aynı biçim |
| recommend, instrument, audience | etymology.origin | + Latin | Depodaki etimolojilerin çoğunda origin var |
| audience | def.long | "…We use it for people sitting together in a hall…" → "…It can be people in a hall, a cinema or a theatre, or people watching at home." | Tanımın ilk cümlesindeki TV izleyicisiyle çelişiyordu |
| sing along | quiz.distractors; l1.tr.gloss_short | takes off → turns down; "şarkıya katılmak" → "beraber söylemek" | Konuya yakın şık; "katılmak" yarışmaya katılmak gibi okunuyor (yazar kurallarındaki örnek), Türkçe doğrulayıcı ve son kontrol aynı yönde |
| go fishing | word_family | fish (n) → fish (v) | Kalıbın ailesi fiil |
| chess | def.long | "tries to catch the other player's king" → "tries to trap the other player's king" | Şah alınmaz, kıstırılır |
| collect | quiz.distractors | sold → torn | "has sold them … and now has 500" zorlama da olsa okunabiliyordu |
| gym | quiz.distractors | cinema → pool | Konuya yakın ama cümlede açıkça yanlış |

Uygulanmayan öneriler: play cards tanımındaki "deck" (başlık kelime ailesi yüzünden daha iyi bir A2 biçimi yok), spare time seviyesi A2 (EVP'de "spare" B1; B1 kaldı), take up gloss'unu genişletmek ("hobiye başlamak" spor ve çalgı örneklerini de karşılıyor), exhausted `why` için son kontrolün isteğe bağlı ikinci metni.

## Çeldirici kontrolü (`3_celdirici_kurallari.md`, 2026-10-22)

- Sınır (max(4, %5) = 4) ve "partta her şık bir kez" kuralı yazarlara baştan verildi. Çeşitlendirme gerekmedi; `distractors_diversified` bayrağı eklenmedi.
- Son hâl (`distractor_stats.py`): `s19: 45 quizzes, 135 distinct distractors; top: job×1, career×1, salary×1, overtime×1, rush hour×1, deadline×1`. Hiçbir şık birden fazla soruda geçmiyor.
- Başka bir s19 kartının cevabı olan dokuz şık var (coach/referee, match (race sorusunda), chess (backgammon sorusunda), lost weight / put on weight…). Hepsi kendi cümlesinde açıkça yanlış; öğrenci ikisini de öğreneceği için bilerek bırakıldı.
- Doğrulayıcı: `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`

## Anadili Türkçe birinin bakması gerekenler

1. **collect** hatası "I'm collecting money for a car." (para biriktirmek → collect money): akla yatkın, derlemle doğrulanmadı. `confusables: ["save"]` buna dayanıyor.
2. **race** hatası "Let's make a race to the park!" (yarış yapmak → make): make a photo türünden, ama bu kalıbın yaygınlığı doğrulanmadı.
3. **audience** hatası "The audiences loved the film." ("seyirciler" çoğulundan): yaygın mı?
4. **be into** gloss "meraklısı olmak": kilit ekranında tek başına doğal mı? (Önceki "-e meraklı olmak" ekle başlıyordu.)
5. **ending** gloss "son, final" mi, "(filmin) sonu" mu?
6. **sing along** gloss_short "beraber söylemek" ("şarkıya katılmak" yerine) kilit ekranında anlaşılır mı?
7. Silinen iki hata geri eklensin mi: support "Which team do you hold?" ve turn "It's your queue." (ikisi de akla yatkın ama kanıt bulunamadı).
8. **stretch** gloss_short "esneme yapmak" (alternatif "vücudu esnetmek") ve **exhibition** notundaki okunuş "eksıbişın".
