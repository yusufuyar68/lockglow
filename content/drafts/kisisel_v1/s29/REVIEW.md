# s29 QA incelemesi (B2: seyahat, turizm, kültür ve eğlence)

Kapsam: `content/drafts/kisisel_v1/s29/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin seyahatte, tatil sitelerinde, haberlerde ve dizi/film konuşmalarında karşılaştığı kelimeler (konaklama, gezi, kültür, gösteri, spor seyirciliği) ve birkaç yol deyimi. Seviye hepsinde B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** bir yazar ajanı, `1_yazar_kurallari.md`. Yazar 60 kartı yazdı, kelime atlamadı, "emin olmadığım" 5 madde bıraktı.
2. **Denetim:** bağımsız bir denetçi ajanı, `2_denetci_kurallari.md`. 60 kartın hepsi tek tek okundu: anlam, tanım, IPA, örnekler ve çevirilerinin geri çevirisi, gloss/alt, yaygın hata, not, quiz (her şık boşluğa konarak), confusables, seviye. Yazarın maddeleri ayrıca tartıldı (aşağıda).

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 54 kelime (24 isim, 18 fiil, 11 sıfat, 1 zarf), 3 deyim (`idiom`), 2 phrasal verb, 1 kalıp (`phrase`: travel light).
- `primary_topic`: `travel_tourism` 31, `music_film` 8, `hobbies_sports` 7, `culture_celebrations` 6, `idioms_expressions` 3, `art_design_architecture` 2, `phrasal_verbs` 2, `food_drink` 1.
- Değişen kart: **15** (`critic_edited`), değişen alan: **19**. `meta.status` hepsinde `draft` kaldı.
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: hepsi `null`. Sahte dost alanı: hepsi `null` (gerçek sahte dostlar, ör. ancient ↔ "antika", nota ve yaygın hataya yazılı). `sensitivity`: hepsi 0.
- **Yaygın hata (`mistakes`):** 14 maddeden 2'si silindi (reserve, plot), kalan 12 kartta 12 madde. Silinenler aşağıda.
- **Karışan kelimeler (`confusables`):** 36 kartta 46 kayıt (önce 36 kartta 48). İki düz eş anlamlı / zayıf eş çıkarıldı: set out → set off, costume → suit.
- Kilit ekranı: `gloss_short` iki kartta (off the beaten track "kıyıda köşede", travel light "hafif seyahat"); diğer 58 kartta `gloss` zaten ≤16 karakter.
- Çakışma: s0–s28 ile ortak başlık kelime yok (yeniden tarandı).
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`. Çeldirici: 158 farklı şık; en sık attended, sail, ancient (3'er soruda, sınır 4). IPA DRESS: `/e/` 0, `/ɛ/` 21.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Gerçekliği zayıf "yaygın hata"lar.** "I made a reserve" Türkçeden gelmiyor: Türkçede kullanılan "rezervasyon" kelimesi doğrudan "reservation"a gider. "What is the subject of the film?" ise yanlış değil, yalnızca daha az doğal; öğrenciye doğru İngilizceyi "yanlış" diye göstermemek için silindi. İkisinde de doğru kullanım zaten notta anlatılıyor.
  2. **Çevirilerde anlam kayması ya da doğal olmayan Türkçe:** experience örneğinde "yakından tanımak" (fiilin karşılığı kayboluyordu), accompany örneğinde "hastaneye giderken" (kimin gittiği belirsiz), stunning'de "gelinliğinin içinde", historic'te "Tarihî Yarımada'sı" (kesme ve iyelik yanlış), hit the road'da "öğle yemeğine kadar varmak".
  3. **Düz eş anlamlı confusables:** set out → set off (aynı anlam). costume → suit: Türkçede "kostüm"ün takım elbise anlamı TDK'da var ama günümüzde seyrek; tuzak zayıf olduğu için çıkarıldı, bilgi notta kaldı.
- **Quiz:** 60 sorunun hepsinde şıklar tek tek boşluğa kondu; ikinci doğru cevap bulunmadı. Yazarın zayıf bulduğu tour, accompany, applaud şıkları cümlede açıkça yanlış; daha iyi bir şık (ör. applaud için "cheered", tour için "visit/see") ikinci doğru cevap olacağı için değiştirilmedi. overseas sorusunun sıfat kullanımını sınaması kabul edildi (zarf cümlelerinde "abroad" da doğru oluyor).
- **IPA:** tournament UK `/ˈtʊənəmənt/` → `/ˈtɔːnəmənt/` (günümüz İngiliz telaffuzunda baskın biçim; eski biçim Cambridge'de ikinci sırada). applaud US `/əˈplɔːd/` deste kuralına (US THOUGHT `/ɔː/`) uygun, kaldı. spectator US ilk hece, UK ikinci hece vurgulu: iki sözlükte de böyle, kaldı. ruins kartına `plural_only` eklenmedi; tekil "a ruin" da kullanılıyor.
- **Gerçek kişi:** star örneğindeki "The new series stars Kıvanç Tatlıtuğ" gerçek bir oyuncu hakkında doğrulanamayan, zamanla eskiyecek bir iddia; genel bir cümleyle değiştirildi.

### Seviye (B2 uygunluğu)

Kartlar silinmedi; aşağıdakiler yalnızca işaret. Tahmin, denetçinin bilgisine dayanıyor; EVP/CEFR-J ile tek tek doğrulanmadı.

- **Daha çok B1 görünenler (bazıları A2):** hostel, campsite, coast, cruise, guidebook, sail, dive, sunbathe, ancient, historic, cultural, exotic, photograph (fiil), film (fiil), tour (fiil), performance, entertainment, architecture, attraction, resort, unforgettable, impressive, lively, participate, cheer, spectacular, plot. Bunlar B2 akışında tekrar ve kullanım farkı (ör. Turkish kitchen, antique city, very luxury, lived problems) için değerli; seviyesinin B1'e çekilmesi düşünülebilir.
- **Daha çok C1 görünenler:** off the beaten track, hit the road (deyimler), stop over, travel light. B2 öğrencisi bunları duyar ama aktif kullanımları C1'e yakın.
- **B2'ye oturanlar:** accommodation, excursion, landmark, monument, cuisine, sculpture, costume, craft, leisure, spectator, tournament, ruins, wander, reserve, entertain, applaud, experience (fiil), stroll, accompany, extend, rate, stunning, luxurious, entertaining, overseas, set out, a change of scenery.

## Yazarın "emin olmadığım" maddeleri: karar

| Madde | Karar |
|---|---|
| reserve "I made a reserve" | Silindi (Türkçeden gelmiyor). |
| plot "What is the subject of the film?" | Silindi (yanlış değil, daha az doğal). Not "What is the film about?" kalıbını zaten veriyor. |
| photograph "My hobby is photograph" | Kaldı. photograph/photography karışıklığı öğrencilerde sık; "hobim fotoğraf" Türkçede doğal bir söyleyiş. |
| cultural "a very cultural man" | Kaldı, `why` düzeltildi ("kültürlü" sözlükte "cultural" diye çıkmaz; yanıltan, kelimelerin ortak kökü). |
| lively "a very alive city" | Kaldı ("canlı" → alive aktarımı gerçekçi). Anadili Türkçe birinin onayı iyi olur. |
| overseas "study in overseas" | Kaldı ("go to abroad" ile aynı mekanizma). |
| accommodation "an accommodation" | Kaldı (an information / an advice ile aynı sayılamayan isim hatası). |
| costume: suit | `suit` confusables'tan çıktı, not "eskiden" diye yumuşatıldı; `false_friend` boş kaldı. |
| travel light "hafif seyahat etmek" / "hafif seyahat" | Türkçede gezi yazılarında yerleşik bir kalıp; kaldı. Nottaki "buradan gelir" köken iddiası çıkarıldı. Bakınız son bölüm. |
| tournament / applaud / spectator IPA | Yukarıda. |
| zayıf şıklar (tour, accompany, applaud) | Tek doğru cevaplı; değiştirilmedi. |
| wander ↔ stroll, excursion → trip/tour | Kaldı: Türkçede aynı karşılık ("gezinmek", "gezi"); kural bunu karışma ölçütü sayıyor ve notlar farkı anlatıyor. |

## Değişiklik tablosu

#### part_01
Değişiklik yok. Bakılanlar: 12 quiz tek cevaplı (excursion'da "an" ipucu bütün şıklarda ünlüyle başlayarak etkisizleştirilmiş). cuisine "Turkish kitchen" ve accommodation "an accommodation" hataları gerçek. monument alt "abide" TDK'da var. harbor alt "marina" kısmi karşılık ama yanlış değil.

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| costume | confusables | ["suit", "custom"] → ["custom"] | "kostüm = takım elbise" anlamı günümüzde seyrek; suit gerçek bir karışma değil. custom (benzer yazılış) kaldı. |
| costume | l1.tr.note | "Türkçede 'kostüm' bazen ceket ve pantolondan ya da etekten oluşan takım için de kullanılır…" → "Türkçede 'kostüm' eskiden takım elbise için de kullanılırdı. İngilizcede takım elbise 'suit' olur; bu kelime ise sahne kıyafeti ya da kılık kıyafettir." | Bugünkü kullanımı yansıtıyor; "sahne ya da kılık kıyafetidir" yapısı düzeltildi. |
| tournament | ipa.uk | /ˈtʊənəmənt/ → /ˈtɔːnəmənt/ | Günümüz İngiliz telaffuzunda baskın biçim. |
| plot | l1.tr.mistakes | "What is the subject of the film?" → (boş) | İngilizcede yanlış değil, yalnızca daha az doğal; doğru kalıp notta var. |

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| reserve | l1.tr.mistakes | "I made a reserve at the hotel." → (boş) | Türkçe "rezervasyon" doğrudan "reservation"a gider; hata Türkçeden gelmiyor. "make a reservation" notta var. |
| star | examples[1].en | "The new series stars Kıvanç Tatlıtuğ." → "The new series stars a famous Turkish actor." | Gerçek kişi hakkında doğrulanamayan ve eskiyecek bir iddia. |
| star | examples[1].tr | "Yeni dizinin başrolünde Kıvanç Tatlıtuğ var." → "Yeni dizinin başrolünde ünlü bir Türk oyuncu var." | İngilizceye uyum. |
| experience | examples[1].tr | "…yerel kültürü yakından tanıyabilir." → "…yerel kültürü yaşayabilir." | Geri çeviri "get to know closely" çıkıyordu; fiilin karşılığı kayboluyordu. |
| accompany | examples[2].tr | "Zeynep hastaneye giderken babaannesine eşlik etti." → "Zeynep, babaannesine hastaneye kadar eşlik etti." | Hastaneye kimin gittiği belirsizdi; "accompany sb to" yapısını yansıtıyor. |

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| stunning | examples[2].tr | "Gelinliğinin içinde göz kamaştırıcıydı." → "Gelinliğiyle göz kamaştırıyordu." | "…in içinde" çeviri kokuyor; doğal söyleyiş. |
| historic | examples[2].tr | "İstanbul'un Tarihî Yarımada'sı UNESCO Dünya Mirası Listesi'nde." → "İstanbul'daki Tarihî Yarımada, UNESCO Dünya Mirası Listesi'nde." | "Yarımada'sı" yanlış kesme/iyelik; doğal yapı. |
| cultural | def.long | "…A center or event of this kind is about art and traditions." → "…People use it for events, differences and heritage." | İkinci cümle anlam katmıyor, tanımı tekrarlıyordu. |
| cultural | l1.tr.mistakes[0].why | "…'kültürlü' ile 'kültürel' birbirine benzer ve ikisi de bu kelimeye çevrilir…" → "'kültürlü' kelimesi 'kültür' ile başladığı için akla önce bu kelime gelir. Ama bilgili, görgülü kişi için 'cultured' kullanılır; bu kelime 'kültürel' demektir." | "kültürlü" sözlükte "cultural" diye çevrilmez; yanıltan ortak kök. |

#### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| entertaining | l1.tr.mistakes[0].right | "The concert was very entertaining, and we danced all night." → "The concert was a lot of fun, and we danced all night." | Dans edilen bir konser için anadili İngilizce olan kişi "fun" der; "entertaining" seyirlik şeyler için daha doğal. `why` iki kelimeyi de anıyor. |
| overseas | l1.tr.note | "…'abroad' ise yalnızca zarftır." → "…'abroad' ise isimden önce sıfat olarak kullanılmaz." | "from abroad" gibi kullanımlar yüzünden "yalnızca zarf" fazla kesin; asıl fark sıfat kullanımı. |
| set out | confusables | ["set off", "set up"] → ["set up"] | set off düz eş anlamlı (kural dışı). set up benzer biçim tuzağı olarak kaldı. |
| travel light | l1.tr.note | "…Türkçedeki 'hafif seyahat etmek' ifadesi de buradan gelir." → "…Türkçede de 'hafif seyahat etmek' denir." | Köken iddiası doğrulanamıyor. |
| hit the road | def.long | "…People also use it when they simply want to leave: 'It's late, I should get going.'" → "…People also use it when they simply want to leave a party or a friend's house: 'It's late, I'd better go.'" | Örnek alıntı deyimi içermediği için kafa karıştırıyordu; bağlam eklendi. |
| hit the road | examples[1].tr | "…öğle yemeğine kadar Antalya'ya vardık." → "…öğlene kadar Antalya'ya vardık." | "by lunch" burada saat anlamında; "öğle yemeğine kadar varmak" doğal değil. |

Değişmeyen ama bakılanlar: ruins, hostel, campsite ("a camping" hatası gerçek), wander, entertain, applaud, photograph, sail, dive, stroll, extend, participate ("participate to" gerçek), sunbathe, cheer, tour, rate, film, ancient ("antique city" gerçek), exotic, luxurious ("very luxury" gerçek), spectacular, unforgettable, impressive, lively, off the beaten track, stop over, a change of scenery.

## Anadili Türkçe birinin bakması gerekenler

1. **Yaygın hataların sıklığı:** "My hobby is photograph", "a very cultural man", "a very alive city", "I want to study in overseas". Gerçekçi bulundu ama sıklıkları kesin değil; seyrekse silinebilir.
2. **travel light kısa anlamı "hafif seyahat":** Kural fiil karşılıklarının kısa biçiminin de "-mek/-mak" ile bitmesini istiyor. 16 karaktere sığan doğal bir fiil bulunamadı ("az eşyayla gezmek" 17, "hafif gezmek" başka anlama kayıyor). İsim biçimi bırakıldı; "az eşya taşımak" (15) bir seçenek.
3. **costume notu:** "kostüm" kelimesinin takım elbise anlamı için "eskiden" demek doğru mu, yoksa bazı bölgelerde/yaşlarda hâlâ canlı mı?
4. **Karşılıklar:** stop over "kısa süre kalmak" (yolculuk anlamı kilit ekranında kayboluyor mu?), leisure alt "dinlence", cheer örneğindeki "coşkuyla bağırdı", dive örneğindeki "tramplenden havuza daldı" ("atladı" mı daha doğal?).
5. **Seviye:** yukarıdaki B1/C1 listesi; özellikle hostel, campsite, sail, coast gibi temel kelimelerin B2 akışında kalması.

## Çeldirici çeşitlendirme ve son doğrulama (2026-10-26)

`distractor_stats.py`: `s29: 60 quizzes, 158 distinct distractors; top: attended×3, sail×3, ancient×3, scenery×2, postcard×2, sculptor×2`. Sınır (4) aşılmıyor; çeldirici değiştirilmedi. Teknik kontroller (3 farklı şık, cevaba eşit değil, ≤16 karakter) hepsinde tamam.

`ipa_dress_stats.py`: `s29 {'uk_e': 0, 'uk_ɛ': 11, 'us_e': 0, 'us_ɛ': 10}`; DRESS ünlüsü her yerde `/ɛ/`, düzeltme gerekmedi.

Çakışma (`dump_lemmas.py` ile aynı tarama): s29 başlık kelimelerinden hiçbiri başka bir akışta yok; akış içinde de tekrar yok.

Doğrulayıcı (tüm klasör, `--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

Üç bağımsız denetçi B2 destesinden 80 kartlık bir örneklemi okudu (Türkçe, İngilizce ve quiz gözüyle). Bulgular tek tek doğrulandı; doğru olanlar düzeltildi. Bulgulardan çıkan beş sistematik sorun (notlarda 'siz' hitabı, İngilizce cümlede özne olan 'Can' adı, ikinci anlama kayan örnek ve eşdizimler, başka sözcük türünden çeldiriciler, B1 olabilecek seviyeler) s23–s32'nin 600 kartında tarandı.

- Bu akışta değişen kart: **8**, alan: **11**. Değişen kartlara `critic_edited` eklendi.
- Çeldirici: `s29: 60 quizzes, 158 distinct distractors; top: attended×3, sail×3, ancient×3, scenery×2, postcard×2, sculptor×2` (sınır max(4, %5) = 4 aşılmıyor).
- Seviye: değiştirilmedi. B1 olabilecek kartlar bu dosyanın seviye bölümünde zaten işaretli; karar kullanıcıda.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| tournament.n.1 | def.long | "A sports or games competition with many players or teams. They play a series of games, and the losers leave until only the winner is left." → "A sports or games competition with many players or teams. They play a series of games to decide who is the best." | Yalnızca eleme usulünü anlatıyordu |
| architecture.n.1 | examples[2] | "Can studied architecture and now designs eco-friendly houses. / Can mimarlık okudu, şimdi çevre dostu evler tasarlıyor." → "Alp studied architecture and now designs eco-friendly houses. / Alp mimarlık okudu, şimdi çevre dostu evler tasarlıyor." | 'Can' adı İngilizcede modal 'can' gibi okunuyor |
| ruins.n.1 | examples[2] | "After the earthquake, the old part of the city was in ruins. / Depremden sonra şehrin eski kısmı harabeye dönmüştü." → "We walked among the ruins of an old castle on the hill. / Tepedeki eski bir kalenin kalıntıları arasında yürüdük." | 'in ruins' yıkılmış anlamı |
| ruins.n.1 | collocations | "ancient ruins, Roman ruins, the ruins of, in ruins" → "ancient ruins, Roman ruins, the ruins of, explore the ruins" | 'in ruins' ayrı anlam |
| reserve.v.1 | examples[2] | "This parking space is reserved for hotel guests. / Bu park yeri otel misafirlerine ayrılmıştır." → "We reserved a room with a sea view. / Deniz manzaralı bir oda ayırttık." | 'reserved for hotel guests' birine ayrılmak anlamı |
| entertain.v.1 | l1.tr.note | "'eğlenmek' değil, 'eğlendirmek' demektir: başkasını eğlendirirsin. Kendin eğlendiysen 'I had fun' ya da 'I enjoyed myself' dersin." → "Anlamı 'eğlenmek' değil, 'eğlendirmek'tir: başkasını eğlendirirsin. Kendin eğlendiysen 'I had fun' ya da 'I enjoyed myself' dersin." | Cümle küçük harfle başlıyordu |
| dive.v.1 | examples[2] | "Emre dived into the pool from the high board. / Emre yüksek tramplenden havuza daldı." → "Emre dived down to look at an old shipwreck. / Emre eski bir batığa bakmak için dibe daldı." | 'havuza tramplenden atlamak' ayrı anlam |
| dive.v.1 | collocations | "go diving, scuba diving, dive into the water" → "go diving, scuba diving, learn to dive" | 'dive into the water' suya atlamak anlamı |
| dive.v.1 | l1.tr.alt | "dalış yapmak, suya atlamak" → "dalış yapmak" | 'suya atlamak' ayrı anlamın karşılığı |
| spectacular.adj.1 | quiz.distractors | "spectator, spectacles, spectacularly" → "spectacularly, jet-lagged, seasick" | 'spectator/spectacles' isim; tür bilerek seçiliyordu |
| entertaining.adj.1 | l1.tr.note | "Türkçedeki 'eğlenceli' çoğu zaman 'fun' ya da 'entertaining' olur. 'funny' ise komik, güldüren demektir." → "Türkçedeki 'eğlenceli' çoğu zaman 'fun' ya da 'entertaining' olur. 'Funny' ise komik, güldüren demektir." | Cümle küçük harfle başlıyordu |

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Seviye kararı (2026-10-26)

İki bağımsız yargıç B1 olabilecek adayları ayrı ayrı değerlendirdi. İkisinin de B1 ya da altı dediği **26 kart** `level: "B1"` oldu; `level_source` yine `editorial_estimate`. Kart ID'leri seviye içermediği için değişmedi. Yargıçların ayrıntılı gerekçe metinleri bu düzenlemeye gelmedi; satırlardaki gerekçe, yargıç kararının editör özetidir.

- `en.attraction.n.1` (attraction): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.resort.n.1` (resort): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.cruise.n.1` (cruise): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.guidebook.n.1` (guidebook): yargıç 1 A2 (temel seyahat kelimesi), yargıç 2 B1; en yüksek karar B1 olduğu için B1'e taşındı.
- `en.coast.n.1` (coast): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.performance.n.1` (performance): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.entertainment.n.1` (entertainment): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.plot.n.1` (plot): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.architecture.n.1` (architecture): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel. Konu: `art_design_architecture` B1'i kapsamıyordu → `primary_topic` `travel_tourism`, `topics` [travel_tourism, culture_celebrations, art_design_architecture].
- `en.hostel.n.1` (hostel): yargıç 1 A2 (temel seyahat kelimesi), yargıç 2 B1; en yüksek karar B1 olduğu için B1'e taşındı.
- `en.campsite.n.1` (campsite): yargıç 1 A2 (temel seyahat kelimesi), yargıç 2 B1; en yüksek karar B1 olduğu için B1'e taşındı.
- `en.photograph.v.1` (photograph): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.sail.v.1` (sail): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.dive.v.1` (dive): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.sunbathe.v.1` (sunbathe): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.cheer.v.1` (cheer): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.tour.v.1` (tour): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.film.v.1` (film): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.historic.adj.1` (historic): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.ancient.adj.1` (ancient): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.cultural.adj.1` (cultural): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.exotic.adj.1` (exotic): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.spectacular.adj.1` (spectacular): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.unforgettable.adj.1` (unforgettable): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.impressive.adj.1` (impressive): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.lively.adj.1` (lively): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.

B2'de kalan adaylar (yargıçlar ayrıştı ya da B2 dedi): `en.participate.v.1`.

## İkinci örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) her akıştan 7 kartlık bir örneklemi (toplam 70 kart) ikinci kez okudu. 35 bulgunun hepsi kartla karşılaştırıldı ve hepsi gerçek çıktı; düzeltildi. Bulgulardan çıkan yeni sistematik sorunlar s23–s32'nin 600 kartında tarandı: `def.long`'un ikinci bir anlama kayması (ve aynı anlamın örnek, eşdizim, `alt` ya da quiz'e girmesi), başka sözcük türünden ya da yalnızca yazımı benzeyen çeldiriciler, ABD IPA'sında ɝ/ɚ yazımı, boş `confusables` dizisi.

- Bu akışta değişen kart: **14**, alan: **22**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.cultural.adj.1`: Türkçe, hata açıklaması (düşük): gerçek. Önerilen metin uygulandı.
- `en.sunbathe.v.1`: Türkçe, not (düşük): gerçek. Not isim/fiil farkını ve titreşimli 'th'yi anlatıyor.
- `en.overseas.adv.1`: İngilizce, quiz (orta) ve quiz gözü, cloze/şıklar (orta): ikisi aynı sorun, gerçek. Yeni cloze 'After university, she moved ______ to work in Canada.', şıklar upstairs, indoors, nearby ('abroad' yeni cümlede doğru olacağı için kullanılmadı).
- `en.costume.n.1`: Quiz (düşük): gerçek. Önerilen 'uniform' cümlede kabul edilebileceği için şıklar ticket, souvenir, invitation oldu.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| coast.n.1 | quiz.distractors | "[cost, coach, cruise]" → "[cost, wave, cruise]" | 'coach' yalnızca yazım benzeri, konu dışı ('cost' gerçek karışan kelime, kaldı) (tarama) |
| performance.n.1 | def.long | silinen cümle: "It can also mean how well someone does a job." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| costume.n.1 | quiz.distractors | "[custom, customer, texture]" → "[ticket, souvenir, invitation]" | 'custom', 'customer', 'texture' yazım benzeri/konu dışı (bulgu) |
| leisure.n.1 | quiz.distractors | "[pleasure, treasure, measure]" → "[pleasure, routine, schedule]" | 'treasure', 'measure' yalnızca kafiye, konu dışı (tarama) |
| entertain.v.1 | def.long | silinen cümle: "It can also mean having guests at your home and giving them food and drinks." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| entertain.v.1 | l1.tr.alt | "[oyalamak, ağırlamak]" → "[oyalamak]" | 'ağırlamak' misafir anlamı (tarama) |
| applaud.v.1 | def.long | silinen cümle: "It can also mean to praise an action: 'We applaud her decision.'" | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| applaud.v.1 | def.short | "hit your hands together many times to show that you enjoyed a show or agree" → "hit your hands together many times to show that you enjoyed a show" | 'or agree' ikinci anlam (tarama) |
| applaud.v.1 | examples[2] | "Many people applauded the city's decision to close the street to cars. / Pek çok kişi, belediyenin caddeyi araçlara kapatma kararını alkışl…" → "We applauded when the plane landed safely. / Uçak sorunsuz inince alkışladık." | 'applauded the city's decision' takdir etmek anlamı (tarama) |
| applaud.v.1 | collocations | "[applaud loudly, applaud the performance, applaud a decision]" → "[applaud loudly, applaud the performance, applaud the speaker]" | 'applaud a decision' ikinci anlam (tarama) |
| applaud.v.1 | l1.tr.alt | "[el çırpmak, takdir etmek]" → "[el çırpmak]" | 'takdir etmek' ikinci anlam (tarama) |
| applaud.v.1 | l1.tr.note | "Günlük konuşmada 'clap' daha sık kullanılır; bu kelime biraz daha resmîdir. İsmi 'applause' (alkış) sayılamaz: 'a big round of applause'." → "Günlük konuşmada 'clap' daha sık kullanılır. 'We applaud her decision' gibi bir kararı takdir etmek için de söylenir; bu kelime biraz daha …" | İkinci anlam nota taşındı (tarama) |
| dive.v.1 | def.long | silinen cümle: "It also means to jump into water with your head and arms first." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| extend.v.1 | def.long | silinen cümle: "It can also mean to make something bigger or longer, like a road or a house." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| extend.v.1 | l1.tr.alt | "[süresini uzatmak, genişletmek]" → "[süresini uzatmak]" | 'genişletmek' büyütme anlamı (notta 'expand') (tarama) |
| sunbathe.v.1 | l1.tr.note | "Fiil 'e' harfiyle biter ve sondaki ses yumuşak 'th' olur. Günlük konuşmada 'lie in the sun' da denir." → "İsim 'sunbath', fiil 'sunbathe' olur; fiildeki 'th', 'this' kelimesindeki gibi titreşimli okunur. Günlük konuşmada 'lie in the sun' da deni…" | 'yumuşak th' Türk öğrenciye bir şey anlatmıyor (bulgu) |
| historic.adj.1 | l1.tr.alt | "[tarihte önemli olan, tarihsel]" → "[tarihte önemli olan]" | 'tarihsel' historical'ın karşılığı; not da bu ayrımı anlatıyor (tarama) |
| cultural.adj.1 | l1.tr.mistakes.0.why | "'kültürlü' kelimesi 'kültür' ile başladığı için akla önce bu kelime gelir. Ama bilgili, görgülü kişi için 'cultured' kullanılır; bu kelime …" → "'Kültürlü' derken 'cultural' kelimesi 'kültürel'e benzediği için akla o geliyor. Ama 'cultural' 'kültürel' demektir; bilgili, görgülü kişi …" | Küçük harfle başlıyordu, 'bu kelime' belirsizdi, neden zayıftı (bulgu) |
| spectacular.adj.1 | quiz.distractors | "[spectacularly, jet-lagged, seasick]" → "[homesick, jet-lagged, seasick]" | 'spectacularly' zarf (tarama) |
| impressive.adj.1 | quiz.distractors | "[impressed, impression, expressive]" → "[impressed, noisy, expressive]" | 'impression' isim (tarama) |
| overseas.adv.1 | quiz.cloze | "The company's ______ sales grew by 20% last year." → "After university, she moved ______ to work in Canada." | Soru sıfat kullanımını (overseas sales) sınıyordu; kart zarf (bulgu) |
| overseas.adv.1 | quiz.distractors | "[abroad, foreigner, aboard]" → "[upstairs, indoors, nearby]" | 'foreigner' isim, 'aboard' yazım benzeri; 'abroad' yeni cümlede doğru olurdu (bulgu) |

- Çeldirici: `s29: 60 quizzes, 157 distinct distractors; top: attended×3, sail×3, ancient×3, scenery×2, souvenir×2, postcard×2` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Üçüncü örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) s23–s32'den 80 kartlık yeni bir örneklemi okudu. 35 bulgu kartla karşılaştırıldı: 33'ü gerçek çıktı ve düzeltildi, 2'si (release, carbon footprint çevirileri) gerekçesiyle reddedildi. Önceki iki turun listesinde olmayan sistematik sorunlar s23–s32'nin 600 kartında tarandı: `gloss_short`'ta kesilmiş söz; `alt`'ın kartın kendi notuyla ya da başka bir kartın ayrımıyla çelişmesi (ve önceki taramada kalan ikinci anlam karşılıkları); `grammar.pattern`'da başka anlamın kalıbı; `def.long`'da önceki anahtar sözcük taramasının kaçırdığı ikinci anlam cümleleri (ve aynı anlamın örnek, eşdizim, quiz'e taşması); akraba kartlar arasında neredeyse aynı örnek ya da boşluklu cümle; boşluğa anlamca hiç uymayan, soruyu ele veren çeldiriciler; şapkası düşmüş hâl / dâhil. Seviyeler değişmedi.

- Bu akışta değişen kart: **12**, alan: **26**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.stop_over.phv.1`: Türkçe, 2. örnek ve alt (düşük): gerçek. 'mola vermek' alt'tan çıktı; çeviri 'Aktarma sırasında İstanbul'da kalırsan …'.
- `en.accommodation.n.1`: Türkçe, dâhil yazımı (düşük): gerçek. 600 kartta 3 yer 'dâhil' oldu; yazar kuralındaki 'boşluklar dahil' de düzeltildi.
- `en.spectacular.adj.1`: Quiz, çeldiriciler (düşük): gerçek. boring, disappointing, dull; cümleye '… and the crowd cheered for ten minutes' eklendi ki şıklar açıkça yanlış olsun (önerilen 'ordinary' 'a' ile uyuşmadığı için alınmadı).

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| accommodation.n.1 | examples.0.tr | "Fiyata uçuş ve konaklama dahil." → "Fiyata uçuş ve konaklama dâhil." | TDK yazımı: hâl / dâhil (şapka düşmüştü) (tarama) |
| monument.n.1 | l1.tr.alt | "[abide, tarihî eser]" → "[abide]" | 'tarihî eser' eski yapı anlamı (aşağıda def.long'dan da silindi) (tarama) |
| monument.n.1 | def.long | silinen cümle: "Very old buildings, like temples and castles, can also be called this." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| monument.n.1 | examples[2] | "Many ancient monuments in the region are now protected by law. / Bölgedeki pek çok antik anıt artık yasayla korunuyor." → "The town built a monument to the famous poet in the main park. / Kasaba, ana parka ünlü şairin anısına bir anıt dikti." | 'ancient monuments' eski yapı anlamı (tarama) |
| resort.n.1 | examples.1.tr | "Antalya'da her şey dahil bir tatil köyünde kaldık." → "Antalya'da her şey dâhil bir tatil köyünde kaldık." | TDK yazımı: hâl / dâhil (şapka düşmüştü) (tarama) |
| sculpture.n.1 | l1.tr.alt | "[yontu, heykelcilik]" → "[yontu]" | 'heykelcilik' sanat dalı anlamı (notta var) (tarama) |
| sculpture.n.1 | def.long | silinen cümle: "The word also means the art of making these things." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| sculpture.n.1 | examples[1] | "Selin studied sculpture at university. / Selin üniversitede heykel okudu." → "The garden has a stone sculpture of a horse. / Bahçede taştan bir at heykeli var." | 'studied sculpture' sanat dalı anlamı (tarama) |
| sculpture.n.1 | collocations | "[a bronze sculpture, a marble sculpture, modern sculpture]" → "[a bronze sculpture, a marble sculpture, a wooden sculpture]" | 'modern sculpture' sanat dalı anlamı (tarama) |
| architecture.n.1 | l1.tr.alt | "[mimarlık]" → "[]" | 'mimarlık' meslek/bölüm anlamı (notta var) (tarama) |
| architecture.n.1 | def.long | silinen cümle: "It is also the subject that people study so they can design buildings." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| architecture.n.1 | def.short | "the style and design of buildings, or the job of designing them" → "the style and design of buildings in a place or period" | 'or the job of designing them' ikinci anlam (tarama) |
| architecture.n.1 | examples[2] | "Alp studied architecture and now designs eco-friendly houses. / Alp mimarlık okudu, şimdi çevre dostu evler tasarlıyor." → "The architecture of the new library is very modern. / Yeni kütüphanenin mimarisi çok modern." | 'studied architecture' meslek/bölüm anlamı (tarama) |
| architecture.n.1 | collocations | "[modern architecture, Ottoman architecture, study architecture]" → "[modern architecture, Ottoman architecture, traditional architecture]" | 'study architecture' meslek anlamı (tarama) |
| dive.v.1 | grammar.pattern | "go diving; dive into sth" → "go diving; dive down (to sth)" | 'dive into sth' önceki turda silinen suya atlama anlamı (tarama) |
| tour.v.1 | l1.tr.alt | "[dolaşmak, turneye çıkmak]" → "[dolaşmak]" | 'turneye çıkmak' müzisyen anlamı (notta var); önceki taramada kalmış (tarama) |
| tour.v.1 | grammar.pattern | "tour sth; be touring" → "tour sth" | 'be touring' turne anlamı (notta var) (tarama) |
| tour.v.1 | def.long | silinen cümle: "Bands and theater groups also do this when they perform in many cities." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| tour.v.1 | examples[2] | "The band is touring Europe this autumn. / Grup bu sonbahar Avrupa turnesinde." → "Thousands of visitors tour the castle every summer. / Her yaz binlerce ziyaretçi kaleyi geziyor." | 'The band is touring Europe' turne anlamı (tarama) |
| rate.v.1 | def.long | silinen cümle: "People also use it to say what they think: 'I rate this film highly.'" | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| ancient.adj.1 | def.long | silinen cümle: "In everyday speech it can also mean very old: 'an ancient car'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| spectacular.adj.1 | quiz.cloze | "On New Year's Eve, the city put on a ______ fireworks show over the Bosphorus." → "On New Year's Eve, the city put on a ______ fireworks show, and the crowd cheered for ten minutes." | Yeni şıkları dışarıda bırakan bağlam (bulgu) |
| spectacular.adj.1 | quiz.distractors | "[homesick, jet-lagged, seasick]" → "[boring, disappointing, dull]" | Duygu sıfatları gösteriyi niteleyemiyordu; soru sınamıyordu (bulgu) |
| stop_over.phv.1 | l1.tr.alt | "[ara durakta kalmak, mola vermek]" → "[ara durakta kalmak]" | 'mola vermek' yolda dinlenme molası, aktarma değil (bulgu) |
| stop_over.phv.1 | examples.1.tr | "İstanbul'da mola verirsen şehri bir gün gezebilirsin." → "Aktarma sırasında İstanbul'da kalırsan şehri bir gün gezebilirsin." | 'mola verirsen' yanlış anlam (bulgu) |
| travel_light.phr.1 | l1.tr.gloss_short | "hafif seyahat" → "az eşya taşımak" | 'hafif seyahat' kesilmiş fiil öbeği; -mak ile biten tam karşılık (tarama) |

- Çeldirici: `s29: 60 quizzes, 156 distinct distractors; top: attended×3, sail×3, ancient×3, scenery×2, souvenir×2, postcard×2` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
