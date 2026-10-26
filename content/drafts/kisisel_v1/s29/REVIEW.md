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
