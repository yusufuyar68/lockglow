# s27 QA incelemesi (teknoloji, internet ve medya, B2)

Kapsam: `content/drafts/kisisel_v1/s27/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin işte, haberde ve telefonunda her gün gördüğü teknoloji, internet ve medya kelimeleri (data, privacy, upgrade, attach, distract, wireless, breaking news, catch on…). Seviye: hepsi B2.

Süreç (`docs/icerik_uretimi/README.md`). Ajanlar Opus (orta çaba):

1. **Yazım:** tek yazar ajanı, `1_yazar_kurallari.md`. Kartları scratchpad'deki üretim betikleri yazdı (depoda değil). Atlanan kelime ve var olan kartlarla çakışma yok.
2. **Denetim:** bağımsız bir denetçi ajanı, `2_denetci_kurallari.md`. 60 kartı tek tek okudu: anlam, tanım, IPA, örneklerin doğallığı, Türkçe çevirinin geri çevirisi, gloss/alt/not, hata maddeleri, sahte dost, karışan kelimeler ve quiz'de her şıkkın boşluğa konması. Yazarın "emin olmadığım" maddeleri ayrıca yanıtlandı (aşağıda).

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 52 kelime (22 isim, 18 fiil, 11 sıfat, 1 zarf), 4 eşdizim (`collocation`: artificial intelligence, search engine, social media, breaking news), 3 phrasal verb (shut down, catch on, pop up), 1 deyim (behind the times).
- `primary_topic`: `technology_internet` 40, `society_media` 11, `ai_data_programming` 4, `phrasal_verbs` 3, `music_film` 1, `idioms_expressions` 1. Hepsi B2'yi kapsıyor (`LEVEL_RANGE` uyarısı yok).
- Değişen kart: **25** (`critic_edited`), **37** alan. `meta.status` hepsinde `draft` kaldı (s22 gibi).
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: hepsi `null`. Sahte dost: yok (`null`). `sensitivity`: hepsi 0.
- **Kilit ekranı anlamı:** 58 kartta `gloss` ≤16 karakter; 2 kartta `gloss_short` var (distract "dikkat dağıtmak", breaking news "son dakika").
- **Karışan kelimeler (`confusables`):** 11 kartta 13 kayıt (hardware → software, security → safety, channel → canal, viewer → audience, upgrade → update, publish → broadcast, develop → improve, distract → disturb, electronic → electric/electrical, shut down → close/shut up, catch on → catch up). Hepsi gerçek tuzak; düz eş anlamlı yok.
- **Türkçeden gelen hata (`mistakes`):** 6 kartta 6 madde: "access to my account", "Which canal…", "in social media", "a breaking news", "Close the computer", ve denetimde eklenen "datas". Yazarın maddelerinin hiçbiri uydurma bulunmadı, silinen yok.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`. Çeldirici: 133 farklı şık; en sık recharge, attach, refresh, subscribe ve portable 4'er soruda (sınır 4). IPA DRESS: uk `/ɛ/` 15, us `/ɛ/` 16, düz `/e/` 0.

## Yazarın "emin olmadığım" maddeleri

1. **channel – "Which canal is the match on?":** Tutuldu. "kanal" kelimesinden "canal" yazılması Türkçe konuşanlarda (özellikle "my YouTube canal") görülen bir hata; confusables'taki "canal" ve quiz şıkkı aynı tuzağı sınıyor. B2'de ne kadar sık olduğu anadili Türkçe birine soruldu (aşağıda).
2. **İki yönlü confusables:** Denetçi yalnızca s27'yi değiştirebildiği için audience, update, improve ve close kartlarına dokunulmadı. s22'de belirtildiği gibi derleyici çifti iki yönlü bağlıyor; ayrıca elle eklemek gerekmiyor. İstenirse sonraki bir turda o akışlara yazılabilir.
3. **distract quiz:** Yazara katılındı. "disturb me from my work" sınırda kabul görebilir; "disturb" şıkkı "annoy" ile değişti. distract/disturb farkı notta ve confusables'ta duruyor.
4. **IPA:** upgrade (fiil) `/ˌʌpˈɡreɪd/` doğru, kaldı (ABD'de ilk heceye vurgu da duyuluyor, ama fiilde ikinci hece vurgusu sözlüklerde ilk sırada). privacy ABD `/ˈpraɪvəsi/`, İngiltere `/ˈprɪvəsi/` doğru; not da bunu söylüyor. artificial intelligence ABD IPA'sı sınırın içinde, doğrulayıcı geçiyor.
5. **Türkçe karşılıklar:** catch on "(bir şey) tutmak", pop up "(aniden) çıkmak" ve breaking news gloss_short "son dakika" doğru ve doğal bulundu, kaldı. gadget'ta gloss "elektronik alet" kaldı (destede teknoloji bağlamı), not "kitchen gadget" için elektronik olmayan aletleri de açıkça kapsayacak biçimde yeniden yazıldı. subscribe ve react'te hata listesi boş kaldı (Türkçe "abone olmak/-e tepki vermek" İngilizce "to" ile örtüşüyor, Türkçeden gelen bir hata yok). data'ya gerçek bir hata eklendi: "datas" (Türkçedeki "datalar/veriler" çoğulu).

## Genel bulgular

- **En sık 3 sorun:**
  1. **İngiliz yazımı:** deste ABD yazımını kullanıyor; 17 alanda programme, favourite, analyses, criticised, recognising, neighbourhoods, advert, bin ve "mobile phone" düzeltildi.
  2. **Quiz'de savunulabilir ikinci cevap:** security ("improved its online reputation"), upgrade ("update to a newer model"), display ("the screen adjusts the temperature"), distract ("disturb me from my work"). Dördünde yalnızca çeldirici değişti, cümle aynı kaldı. Diğer 56 quiz'in her şıkkı boşluğa konup okundu; tek doğru cevap var.
  3. **Doğal olmayan Türkçe ya da İngilizce örnek:** privacy "özel hayatlarının olmamasından", edit "Makale kısaltmak için düzenlendi" (özne uyumsuz), upgrade "premium pakete yükseltebilirsin" (nesnesiz), portable "bir taşınabilir", viewer "The video got a million viewers" (doğrusu "views").
- **Seviye (B2 uygunluğu):** Kartlar silinmedi, seviye değiştirilmedi; aşağıdakiler yalnızca işaretlendi.
  - **B1'e daha yakın görünenler:** channel, user, network, version, virus, data, feature, connection, digital, electronic, technical, react, develop, surf, social media, search engine. Hepsi gündelik ve çok sık; Cambridge EVP gibi listelerde B1 (bazıları A2) olarak geçtiğini düşünüyoruz. Destede B1'de karşılıkları yoksa B2'de kalmaları zararsız, ama derlemeden önce seviye listesine bakılmalı.
  - **C1'e yakın olabilecek:** behind the times (deyim; bazı listelerde C1). catch on de B2/C1 sınırında.
  - Gerisi (privacy, security, hardware, database, broadcast, journalism, documentary, gadget, upgrade, attach, distract, virtual, wireless, outdated, portable, user-friendly, breaking news, shut down, pop up…) B2 için uygun.
- **IPA:** 60 kartın hepsi kontrol edildi; düzeltme gerekmedi. DRESS `/ɛ/`, ABD LOT `/ɑː/`, phrasal verb'lerde vurgu parçacıkta.
- **Anlam ve tanımlar:** Başlık kelimeyi kullanan tanım yok. Çok anlamlı kelimelerde (feature, filter, display, refresh, transfer) teknoloji anlamı seçilmiş ve öbür anlam notta; doğru.

## Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| data | examples.2.en | "Ayşe analyses sales data for a big supermarket chain." → "Ayşe analyzes sales data for a big supermarket chain." | ABD yazımı (deste ABD yazımını kullanıyor) |
| data | l1.tr.mistakes | [] → [{"wrong": "We need more datas before we decide.", "right": "We need more data before we decide.", "why": "Türkçede 'veriler' ya da 'datalar' diye çoğul eki alır, bu yüzden 'datas' yazılır. İngilizcede 'data' '-s' almaz."}] | Boş listeye gerçek ve sık bir hata eklendi: Türkçedeki 'datalar/veriler' çoğulu 'datas' yazdırıyor. |
| network | def.long | "A system of computers, phones or other devices that are connected so they can share information. A mobile phone company's system is also called a network." → "A system of computers, phones or other devices that are connected so they can share information. A phone company's system is also called a network." | ABD yazımı (deste ABD yazımını kullanıyor) ('mobile phone' yerine) |
| artificial intelligence | def.long | "Computer systems that can do things that usually need a human mind, such as understanding language, learning from data, recognising faces or making decisions. It is often shortened to AI." → "Computer systems that can do things that usually need a human mind, such as understanding language, learning from data, recognizing faces or making decisions. It is often shortened to AI." | ABD yazımı (deste ABD yazımını kullanıyor) |
| privacy | examples.1.tr | "Ünlüler sık sık özel hayatlarının olmamasından şikâyet eder." → "Ünlüler sık sık özel hayatlarının kalmadığından yakınır." | "özel hayatlarının olmamasından" doğal değil; "lack of privacy" burada özel hayatın kalmaması. |
| security | quiz.distractors | ["advertising", "entertainment", "reputation"] → ["advertising", "entertainment", "fashion"] | "improved its online reputation" saldırıdan sonra akla yatkın ikinci cevap; "fashion" açıkça yanlış. |
| feature | examples.1.en | "My favourite feature of this phone is the camera." → "My favorite feature of this phone is the camera." | ABD yazımı (deste ABD yazımını kullanıyor) |
| feature | quiz.cloze | "My favourite ______ of this app is that it also works without the internet." → "My favorite ______ of this app is that it also works without the internet." | ABD yazımı (deste ABD yazımını kullanıyor) |
| version | examples.2.tr | "Filmin orijinal versiyonunu yeniden çekimine tercih ederim." → "Filmin orijinal versiyonunu yeniden çevrimine tercih ederim." | "remake" Türkçede "yeniden çevrim"; "yeniden çekim" bir sahnenin tekrar çekilmesi gibi okunuyor. |
| user | l1.tr.note | "'User name' kullanıcı adıdır. İnternette birini izleyen kişiye 'viewer', ürün satın alan kişiye 'customer' denir." → "'User name' kullanıcı adıdır. Video ya da yayın izleyen kişiye 'viewer', ürün satın alan kişiye 'customer' denir." | "birini izleyen" takip etmek ya da gözetlemek anlamına kayıyor. |
| broadcast | def.long | "A programme, a speech or news that is sent out on television, radio or the internet so that many people can watch or listen. A 'live broadcast' is shown at the same time as it happens." → "A program, a speech or news that is sent out on television, radio or the internet so that many people can watch or listen. A 'live broadcast' is shown at the same time as it happens." | ABD yazımı (deste ABD yazımını kullanıyor) |
| channel | def.long | "A television station that shows programmes, or a page on a video website like YouTube where a person or a company regularly shares videos. You can change it with the remote." → "A television station that shows programs, or a page on a video website like YouTube where a person or a company regularly shares videos. You can change it with the remote." | ABD yazımı (deste ABD yazımını kullanıyor) |
| media | examples.2.en | "The government was criticised in the media for the decision." → "The government was criticized in the media for the decision." | ABD yazımı (deste ABD yazımını kullanıyor) |
| documentary | def.short | "a film or TV programme that gives facts about real people, places or events" → "a film or TV program that gives facts about real people, places or events" | ABD yazımı (deste ABD yazımını kullanıyor) |
| documentary | def.long | "A film or a television or radio programme that shows real people, places and events and gives facts about them, rather than telling an invented story." → "A film or a television or radio program that shows real people, places and events and gives facts about them, rather than telling an invented story." | ABD yazımı (deste ABD yazımını kullanıyor) |
| documentary | examples.2.en | "Hakan is making a documentary on life in Istanbul's old neighbourhoods." → "Hakan is making a documentary on life in Istanbul's old neighborhoods." | ABD yazımı (deste ABD yazımını kullanıyor) |
| gadget | l1.tr.note | "Mutfakta kullanılan pratik aletlere de 'kitchen gadget' denir." → "Elektronik olmayan küçük, pratik aletler için de kullanılır: 'kitchen gadget' (pratik mutfak aleti)." | Yazarın notu: gloss 'elektronik alet' ile 'kitchen gadget' notu çelişiyordu; not, elektronik olmayan aletleri açıkça kapsayacak biçimde yeniden yazıldı. |
| viewer | def.short | "a person who watches a TV programme or a video, especially one of many" → "a person who watches a TV program or a video, especially one of many" | ABD yazımı (deste ABD yazımını kullanıyor) |
| viewer | def.long | "A person who watches something, especially a television programme or an online video. TV channels and video makers often talk about how many they have." → "A person who watches something, especially a television program or an online video. TV channels and video makers often talk about how many they have." | ABD yazımı (deste ABD yazımını kullanıyor) |
| viewer | examples.2.en | "The video got more than a million viewers in two days." → "The live stream had more than a million viewers." | Bir video için anadili İngilizce olan biri "a million views" der; canlı yayın için "viewers" doğal. |
| viewer | examples.2.tr | "Video iki günde bir milyondan fazla izleyiciye ulaştı." → "Canlı yayının bir milyondan fazla izleyicisi vardı." | Yeni İngilizce örneğin çevirisi. |
| viewer | l1.tr.note | "Televizyon ve internet için 'viewer' kullanılır. Bir salonda ya da etkinlikte bir arada izleyen topluluk 'audience' olur." → "'Viewer' tek tek izleyen kişilerdir: 'five million viewers'. 'Audience' izleyicilerin hepsini tek bir topluluk olarak anlatır: 'a large audience', 'the audience in the theater'." | Eski not 'audience' kelimesini yalnızca salondaki topluluğa bağlıyordu; 'a TV audience' da doğru. Fark kişi / topluluk olarak anlatıldı. |
| upgrade | examples.2.tr | "Ayda beş dolara premium pakete yükseltebilirsin." → "Ayda beş dolara paketini premium'a yükseltebilirsin." | "premium pakete yükseltebilirsin" nesnesiz kalıyordu; Türkçede yükseltilen şey paketin kendisi. |
| upgrade | quiz.distractors | ["update", "recharge", "delete"] → ["renew", "recharge", "delete"] | "update to a newer model" bazı okurlarca kabul edilebilir ("update to iOS 18" doğru). "renew" (Türkçedeki "yenilemek" tuzağı) bu cümlede açıkça yanlış. |
| edit | examples.2.tr | "Makale kısaltmak için düzenlendi." → "Makale daha kısa olsun diye düzenlendi." | "Makale kısaltmak için düzenlendi" cümlesinde özne uyumsuz (makale kısaltmıyor). |
| recharge | l1.tr.alt | ["yeniden doldurmak", "dinlenmek"] → ["yeniden şarj etmek", "şarj olmak"] | "dinlenmek" kartın anlamı (pil) için değil, deyimin karşılığı; "yeniden doldurmak" pil için kullanılmıyor. İkinci örnekteki geçişsiz kullanım için "şarj olmak" eklendi. |
| display | quiz.distractors | ["attaches", "adjusts", "selects"] → ["attaches", "deletes", "pastes"] | "The screen on the fridge adjusts/selects the temperature" dokunmatik bir panel için savunulabilir; yeni şıklar açıkça yanlış. |
| select | quiz.cloze | "______ the photos you want to delete, and then tap the bin icon." → "______ the photos you want to delete, and then tap the trash icon." | ABD yazımı (deste ABD yazımını kullanıyor) ("bin" İngiliz) |
| refresh | examples.0.en | "Try to refresh the page." → "Try refreshing the page." | Öneri için doğal kalıp "try refreshing"; "try to refresh" zorlukla çabalamayı ima ediyor. |
| distract | quiz.distractors | ["disturb", "remind", "attract"] → ["annoy", "remind", "attract"] | Yazarın notu: "disturb me from my work" bazı okurlarca kabul edilebilir. distract/disturb farkı not ve confusables alanında kalıyor; quiz'de tek doğru cevap için "annoy" kondu. |
| portable | examples.1.tr | "Çantanda her zaman bir taşınabilir şarj cihazı bulundur." → "Çantanda her zaman taşınabilir bir şarj cihazı bulundur." | Sözcük sırası: "bir taşınabilir" yerine doğal sıra "taşınabilir bir". |
| breaking news | def.long | "News about an important event that is happening at this moment or has just happened. TV channels often stop a programme to give it." → "News about an important event that is happening at this moment or has just happened. TV channels often stop a program to give it." | ABD yazımı (deste ABD yazımını kullanıyor) |
| breaking news | quiz.cloze | "We interrupt this programme for ______: there has been a strong earthquake in the east." → "We interrupt this program for ______: there has been a strong earthquake in the east." | ABD yazımı (deste ABD yazımını kullanıyor) |
| pop up | def.long | "To appear suddenly or when you do not expect it, especially a window, a message or an advert on a computer or phone screen." → "To appear suddenly or when you do not expect it, especially a window, a message or an ad on a computer or phone screen." | ABD yazımı (deste ABD yazımını kullanıyor) ("advert" İngiliz) |
| behind the times | examples.0.tr | "Babam biraz çağın gerisinde." → "Babam biraz çağın gerisinde kaldı." | Türkçede kalıp "çağın gerisinde kalmak" fiiliyle doğal. |
| behind the times | l1.tr.note | "Genelde 'be' ile kullanılır: 'He's behind the times.' Karşıtı 'up to date' (güncel) ya da 'ahead of the times' (çağının ilerisinde) olur." → "Genelde 'be' ile kullanılır: 'He's behind the times.' Karşıtı 'up to date' (güncel) ya da 'ahead of your time' (çağının ilerisinde) olur." | Yerleşik kalıp "ahead of your/its time"; "ahead of the times" seyrek. |
| refresh | examples.0.focus | "refresh" → "refreshing" | Yeni örneğe uyum. |

Değişmeyen ama bakılanlar: access "I can't access to my account", social media "in social media", breaking news "a breaking news" ve shut down "Close the computer" Türkçe konuşanların gerçekten yaptığı hatalar, tutuldu. hardware notundaki "hardware store = nalbur" doğru. publish notundaki yayımlamak/yayınlamak ayrımı TDK'ya uygun. content notundaki vurgu farkı (CON-tent isim, con-TENT "memnun") doğru.

## Çeldirici çeşitlendirme

`distractor_stats.py`: `s27: 60 quizzes, 133 distinct distractors; top: recharge×4, attach×4, refresh×4, subscribe×4, portable×4, password×3`. Sınır (4) aşılmıyor. Denetimde değişen 4 çeldirici listesi (security, upgrade, display, distract) tek doğru cevap için değişti; sınırdaki şıklardan hiçbiri yeni bir soruya eklenmedi.

## Anadili Türkçe birinin bakması gerekenler

1. channel hatası "Which canal is the match on?": B2 öğrencide bu hata ne kadar sık? Seyrekse liste boş bırakılabilir (confusables ve quiz şıkkı yine tuzağı öğretir).
2. Kilit ekranı karşılıkları: catch on "(bir şey) tutmak", pop up "(aniden) çıkmak", distract "dikkat dağıtmak", breaking news "son dakika", gadget "elektronik alet", behind the times "çağın gerisinde".
3. database: gloss "veritabanı" bitişik, alt "veri tabanı" ayrı. TDK ayrı yazıyor; bilişim dilinde bitişik yaygın. Hangisi ana karşılık olmalı?
4. distract ikinci örnek "Bildirimler sürekli dikkatimi işimden dağıtıyor." doğal mı? Alternatif: "Bildirimler yüzünden sürekli işime odaklanamıyorum." (ama kelimenin karşılığı kaybolur).
5. adjust ilk örnek "Parlaklığı Ayarlar menüsünden ayarlayabilirsin." ("in the settings"): "menüsünden" eklemesi kabul edilebilir mi?
6. Seviye: B1'e yakın görünen 16 kart (Genel bulgular) B2'de kalmalı mı?

Son kontrol (2026-10-26): `distractor_stats.py` en sık şık 4 soruda (sınır max(4, %5) = 4), değişiklik gerekmedi; `ipa_dress_stats.py` uk `/ɛ/` 15, us `/ɛ/` 16, düz `/e/` 0; `dump_lemmas.py` ile bakıldı, s27'deki 60 başlık kelimenin hiçbiri başka bir akışta yok.

Son doğrulama (2026-10-26) (`python -X utf8 -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s27`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
