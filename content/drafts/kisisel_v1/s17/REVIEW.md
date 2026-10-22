# s17 QA incelemesi (teknoloji, telefon ve internet)

Kapsam: `content/drafts/kisisel_v1/s17/part_01.json` ... `part_05.json` (45 kart). Konu: telefon, şarj ve ekran sorunları (10), arama ve mesaj (10), ayarlar ve ekran kullanımı (10), sosyal medya (10), çevrimiçi güvenlik ve internetten alışveriş güvenliği (5). Seviye A2–B1.

Süreç (`docs/icerik_uretimi/README.md`). Bütün ajanlar Opus (orta çaba):

1. **Yazım:** Part başına bir yazar ajanı (5 ajan), `1_yazar_kurallari.md` ve bu akışa özel ek kurallar. Koordinatör her kelime için id, tür, seviye, anlam ipucu, Türkçe ipucu ve (varsa) gerçek olduğuna inandığı Türkçe kaynaklı hata adayını verdi; yazarlar adayları ancak kendileri de gerçek bulursa kullandı.
2. **Denetim:** Part başına bir denetçi ajanı (5 ajan), `2_denetci_kurallari.md` ve `SYSTEM_C`. Yazarların "emin olmadığım" maddeleri ve koordinatörün gördüğü zayıf quiz'ler her denetçiye ayrıca verildi.
3. **Bağımsız doğrulama:** Kartları değiştirmeyen üç ayrı doğrulayıcı ajan bütün akışı okudu: (a) quiz'de tek doğru cevap, (b) Türkçe katman (geri çeviri, gloss, not, hata, TDK yazımı), (c) İngilizce içerik, IPA ve üstveri. Koordinatör bulguları tartıp uyguladı; bu düzeltmeleri dördüncü bir ajan ayrıca kontrol etti.
4. **Çeldirici kontrolü:** `3_celdirici_kurallari.md` ölçümü (aşağıda ayrı bölüm).

## Özet

- İncelenen kart: **45** (A2: 24, B1: 21)
- Tür: 31 kelime (`word`), 8 eşdizim (`collocation`), 3 kalıp (`phrase`), 2 phrasal verb, 1 deyim (`idiom`)
- `primary_topic`: technology_internet 45 (ikincil: phrasal_verbs 2, collocations 2, shopping_money 2, idioms_expressions 1; hepsi kategori seviye aralığında)
- Değişen kart: **41** (hepsine `critic_edited` eklendi). Hiç değişmeyen: app, screen, type, addicted.
- Toplam düzenleme (alan sayısı): **148** (denetçiler 98, koordinatör ve bağımsız doğrulama 50)
- Reddedilen kart (`critic_reject`): **0**
- Yaygın hata (`mistakes`): 7 kartta 7 madde (dead, missed call, save, volume, online, fake, hack); hepsi Türkçeden aktarım. Etimoloji 4 kartta (app, charge, scam, secure); kalıp ifadelerde hepsi `null`.
- Doğrulayıcı (tüm klasör, `--strict`): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`

## Kelime seçimi

- Görevde örnek verilen kelimelerin çoğu başka akışlarda aynı anlamla zaten var; tekrar yazılmadı: `charger`, `download`, `screenshot`, `update`, `password` (s2), `turn on`, `turn off`, `log in`, `sign up` (s4). `run out of battery` da yazılmadı: s4'teki `run out of` kartının ikinci örneği zaten "I'm running out of battery". s2'deki öteki teknoloji kartları (upload, delete, link, settings, username, signal, text, install, browse, stream, scroll, scan, storage, device, crash, notification, subscription) ve s4/s10'daki ilgili kartlar (set up, plug in, hang up, call back, turn up/down, look up; email, attachment, reply) dışarıda bırakıldı.
- Görevdeki örneklerden yazılanlar: `go viral`, `back up`. Kapsamdaki konular yeni kelimelerle karşılandı: şarj (`charge`, `dead`, `power bank`), şifre ve hesap (`reset`, `account`, `verification code`), uygulama (`app`), mesaj ve arama (`missed call`, `video call`, `voice message`, `group chat`, `forward`, `mute`, `block`), ayarlar ve güncelleme (`volume`, `up to date`, `restart`, `on silent`), sosyal medya (`post`, `follower`, `comment`, `tag`, `screen time`), çevrimiçi alışveriş güvenliği (`scam`, `hack`, `suspicious`, `secure`, `fake`).
- **Anlam numaraları:** Kelimenin temel anlamı başka olan ve sonra yazılabilecek kartlarda `sense_no` 1 boş bırakıldı: `dead` 2 (temel anlam "ölü"), `charge` 2 ("ücret almak"), `down` 2 ("aşağı", "keyifsiz"), `post` 2 ("postayla göndermek"), `block` 2 ("yolu kapatmak"), `account` 2 (banka hesabı; s15'te `bank account` kalıbı var). `save` 3: s1'de `save` (v, 2) "para biriktirmek" var. Öteki kartlar 1.
- **Yakın kartlarla ayrım (notlarda):** `post` ↔ s6 `share`, `swipe` ↔ s2 `scroll`, `down` ↔ s2 `crash`, `secure` ↔ s7 `safe`, `comment` ↔ s15 `review`, `account` ↔ s15 `bank account`, `tap` (v) ↔ s1 `tap` (n, musluk), `unlock` ↔ s6 `lock`, `save` (kaydetmek) ↔ s1 `save` (biriktirmek), `restart` ↔ s17 `reset`. Bunlardan beşi `confusable:` bayrağı taşıyor (crash, scroll, share, review, safe).
- **Kimlik ve tekrar taraması** (koordinatörün `cross_check.py` betiği, son düzeltmelerden sonra): s0–s16 ve aynı anda yazılan s18 taslağıyla (s18 worktree'si, 45 kart) kimlik, `def.short`, örnek cümle ya da quiz cümlesi çakışması yok. Tek lemma+pos eşleşmesi `save` (s1'de sense 2, burada sense 3; bilerek). 45 kimliğin hiçbiri `id_registry.json`'da yok. s18'le ortak kelime yok; s17 listesi ortak not klasörüne bırakıldı.
- **Şema uyumu:** `is3-icerik` dalı `tr.gloss_short` (≤16 grafem) alanını getiriyor; birleşince 16 grafemi aşan gloss'larda `GLOSS_SHORT_MISSING` uyarısı çıkacak. Bu dalın (main) şeması alanı kabul etmediği için `gloss_short` yazılmadı; bunun yerine bütün gloss'lar 16 grafem ya da daha kısa tutuldu (en uzunları "taşınabilir şarj", "tekrar başlatmak": 16). `confusable:` bayrakları eski biçimde (`tags.flags`); `is3-icerik` birleşince yeni `confusables` alanına taşınabilir (derleyici eski biçimi de okuyor).

## Genel bulgular

- Yazarların kartları genel olarak sağlamdı: tanımlar döngüsüz, ilk örnekler kısa, marka adı yok. Seviye değişmedi.
- **En sık 3 sorun:**
  1. **Quiz çeldiricileri konudan uzaktı ya da başka bir s17 kartının cevabıydı** (denetimde 28 kartta, doğrulamada 10 kartta quiz değişti). Yazarlar tek doğru cevabı korumak için çok uzak şıklar seçmişti ("fold, kick, pour" bir ekran dokunuşu sorusunda; "upstairs, together, early" `online` sorusunda; "garden, umbrella, jacket" `account` sorusunda). Denetçiler bunları konuya yakın ama o cümlede açıkça yanlış şıklarla değiştirdi ("join to the internet", "can't go offline", "real / verified"); ikinci doğru cevap olabilecek şıkları (press/touch, slide/drag, shared/uploaded, fans/likes, voicemail, on hold, fake/strange) bilerek koymadılar. İki kartta (online, fake) eski cümlede ikinci doğru cevap kurulabildiği için cümle değişti. Bağımsız quiz doğrulayıcısı **ikinci doğru cevap bulmadı** (YÜKSEK 0).
  2. **Türkçede düz çeviri ve küçük dilbilgisi** (denetimde 21 kartta 32 alan, doğrulamada 19 alan). Örnekler: "Telefonumu düşürdüm ve artık ekranı çatlak" → "…ekranı çatladı", "Taşınabilir şarjını ödünç alabilir miyim?" → "Powerbankini alabilir miyim?", "yazmak ona yavaş geliyor", "Yalnızca senin için." Üç notta "denir" yönelme durumu istiyordu ("alete ise 'charger' denir", "sıfırlamaya ise", "inmeye ise"). Alt'tan çıkanlar: "resetlemek" (restart ≠ reset), "parmakla kaydırmak" (açıklama), "hafifçe vurmak" (tap'in ekran anlamı değil), "tuhaf" (suspicious ≠ strange), "tuzak" (scam), "etiket atmak", "hoparlöre almak" (fiil kalıbı, gloss zarf).
  3. **US IPA'da uzunluk işareti eksikti** (part_02 ve part_04'te 11 kart). Depo geleneği US'de de uzunluk işaretli (s4/s5 `/kɔːl/`, s6 `/ˈfɑːloʊ/`, s4 `/lɔːɡ ˈɪn/`); hepsi bu geleneğe çekildi. Vurgular doğruydu: birleşik adlarda ana vurgu ilk öğede (lock screen, screen time, power bank, video call, voice message, group chat, verification code), `missed call`'da sonda.
- **Yaygın hatalar:** Yazarlar 9 madde yazdı; denetçiler 3'ünü sildi, 1'ini ekledi (`fake`), 7 kaldı. Silinenler: `voice message` "sound message" (gerçek aktarım olduğu doğrulanamadı), `connect` "connect the Wi-Fi" (Türkçe "Wi-Fi'ye bağlanmak" yönelme ekiyle "to"yu destekliyor, hata Türkçeden gelmiyor), `volume` "the voice of the TV" (kanıtsız). Koordinatörün `comment` için verdiği "do a comment" adayı yazılmadı: Türkçe "yorum yapmak" doğru olan "make a comment"e gidiyor. Kalanlar: My charge is finished (şarjım bitti), Why didn't you open the phone? (telefonu açmak), I recorded your number (kaydetmek = record), Can you open the sound? (sesi aç), I bought it from internet (internetten), This is a fake news (news sayılamaz), My account hacked yesterday (Türkçe edilgen ek). Türkçe doğrulayıcı yedisini de gerçek buldu; yaygınlıkları derlemle doğrulanmadı.
- **Kilit ekranı:** İlk örneklerin hepsi kısa ve sakin. İki ilk örnek, kilit ekranında gerçek bir uyarı sanılabileceği için genelleştirildi: `hack` "My account was hacked last night." → "Someone tried to hack my account.", `scam` "Don't reply. This message is a scam." → "Many 'You won a prize!' messages are scams." `addicted` örnekleri yalnızca telefon, oyun ve dizi.
- **gloss seçimi:** `restart` için Türkçe doğrulayıcı menüdeki "yeniden başlatmak"ı önerdi; 17 grafem olduğu için 16 sınırına sığmıyor. Gloss "tekrar başlatmak", alt "yeniden başlatmak, kapatıp açmak" kaldı; not menüdeki "Yeniden Başlat" yazısını anlatıyor. `addicted` için "kendini kaptırdı" önerisi uygulanmadı (kartın karşılığı "bağımlı" çeviriden düşüyordu).

## Değişiklik tablosu

### Denetim (part başına denetçiler)

#### part_01 (telefon, şarj, sorunlar): 7 kart, 22 alan

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.charge.v.2 | examples[1] | Can I charge my phone here? It's almost dead. / …Şarjı bitmek üzere. → Can I charge my phone in your car? / Telefonumu arabanda şarj edebilir miyim? | s2 battery/charger örneklerini ("almost dead", "Telefonumun şarjı bitmek üzere") tekrar ediyordu. |
| en.dead.adj.2 | synonyms | flat → (boş) | "flat" yalnızca İngiliz İngilizcesinde kullanılıyor, bilgi nota taşındı. |
| en.dead.adj.2 | l1.tr.alt | şarjı bitti → şarjsız | gloss "şarjı bitmiş" ile neredeyse aynıydı. |
| en.dead.adj.2 | l1.tr.note | … 'My phone died' de denir. → + "İngiliz İngilizcesinde pil için 'flat' da kullanılır: 'My battery is flat.'" | flat'in nerede kullanıldığı belirtildi. |
| en.dead.adj.2 | examples[0–2].register | neutral → informal (3 alan) | Kartın register'ıyla tutarlı olsun diye. |
| en.dead.adj.2 | quiz.distractors | full, cheap, bright → locked, clean, wet | "full" doğal değildi, "cheap" ve "bright" ilgisizdi. Yeni şıklar telefonun durumunu anlatıyor ama "so I charged it" cümlesinde açıkça yanlış. "new" bilerek konmadı: yeni telefon da şarj edilir. |
| en.restart.v.1 | examples[0].en / focus | try to restart it → try restarting it / focus restarting | Öneride "try + -ing" daha doğal. |
| en.restart.v.1 | l1.tr.gloss | kapatıp açmak → tekrar başlatmak | Menüdeki "Yeniden Başlat" ile aynı fiil, 16 grafem. |
| en.restart.v.1 | l1.tr.alt | yeniden başlatmak, resetlemek → yeniden başlatmak, kapatıp açmak | reset ≠ restart. |
| en.restart.v.1 | l1.tr.note | 'Restart' cihazı kapatıp açmaktır; … → Telefon menüsündeki 'Yeniden Başlat' İngilizcede 'Restart' olur. Ayarları sıfırlamak ise 'reset' denir. | Öğrencinin gördüğü menü yazısına bağlandı. |
| en.unlock.v.1 | quiz.distractors | delete, pack, repair → lock, delete, repair | "pack" ilgisizdi. "lock" asıl karıştırılan sözcük: telefon yüzle kilitlenmez, kilidi açılır. |
| en.lock_screen.phr.1 | antonyms | home screen → (boş) | Zıt anlamlı değil, yalnızca başka bir ekran. Fark notta zaten anlatılıyor. |
| en.lock_screen.phr.1 | collocations | lock screen photo → lock screen wallpaper | Daha yerleşik bir kalıp. |
| en.cracked.adj.1 | l1.tr.note | null → Türkçede 'ekranım kırıldı' denir; ekran parçalanmadıysa İngilizcede çoğu zaman 'cracked' kullanılır… | Türkçede "kırık" denen durumda öğrenci "broken" diyebilir. |
| en.cracked.adj.1 | quiz.distractors | loud, silent, wireless → smooth, thick, waterproof | Eski şıklar camla ilgisizdi. Yeniler cam için akla yatkın ama "Be careful with your finger" ile çelişiyor. "broken", "sharp" ve "scratched" bilerek konmadı: üçü de cümleye uyabilirdi. |
| en.down.adj.2 | quiz.distractors | up, fast, safe → open, fast, safe | "up" yalnızca karşıt anlamdı. "open" bir sitenin durumunu anlatır ama bilet alamama nedeni olamaz. "offline", "slow", "busy" ve "closed" bilerek konmadı: hepsi cümleye uyabilirdi. |

#### part_02 (arama, mesaj): 9 kart, 21 alan

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| missed call | ipa.us | /ˌmɪst ˈkɔl/ → /ˌmɪst ˈkɔːl/ | Depo geleneği (s4/s5 kɔːl) |
| video call | ipa.us | /ˈvɪdioʊ ˌkɔl/ → /ˈvɪdioʊ ˌkɔːl/ | Aynı |
| group chat | ipa.us | ɡrup → ɡruːp | Uzunluk işareti geleneği |
| on silent | ipa.us | ɑn → ɑːn | Gelenek (on time /ɑːn ˈtaɪm/) |
| on speaker | ipa.us | /ɑn ˈspikər/ → /ɑːn ˈspiːkər/ | Gelenek |
| forward | ipa.us | /ˈfɔrwərd/ → /ˈfɔːrwərd/ | Gelenek |
| mute | ipa.us | /mjut/ → /mjuːt/ | Gelenek (commute /kəˈmjuːt/) |
| block | ipa.us | /blɑk/ → /blɑːk/ | Gelenek (lock /lɑːk/) |
| missed call | l1.tr.mistakes[0].why | "hem cevap vermek hem cihazı çalıştırmak…" → "gelen aramaya cevap vermeye 'telefonu açmak' denir; 'açmak' 'open' diye çevrilince…" | Asıl yanıltan noktayı anlatıyor |
| missed call | l1.tr.note | çoğul notu → "'Missed' = kaçırılmış; 'I missed your call' (Aramanı kaçırdım)" | Daha yararlı |
| video call | quiz.distractors | phone number, power cut, rush hour → phone call, voicemail, phone number | Başka kartlarla tekrarı önlemek ve "görmek"i sınamak |
| voice message | l1.tr.mistakes | "sound message" → [] | Gerçek bir aktarım olduğu doğrulanamadı |
| voice message | l1.tr.alt | [] → ["ses kaydı"] | Yaygın Türkçe karşılık |
| voice message | examples[2].tr | "yazmak ona yavaş geliyor" → "çünkü yazmakta yavaş" | Doğal Türkçe |
| voice message | quiz.distractors | shopping list, birthday card, train ticket → text message, shopping list, birthday card | "can't type" koşulunu sınıyor |
| group chat | examples[2].tr | "Lucas'ı da gruba… O da partiye geliyor." → "Lucas'ı gruba ekler misin? Partiye geliyor." | Fazla "da" |
| group chat | quiz.distractors | phone call, video game, bus stop → video game, ringtone, phone bill | phone call video call'a geçti; bus stop ilgisizdi |
| on speaker | l1.tr.alt | ["hoparlöre almak"] → [] | Fiil kalıbı gloss ile aynı türden değil; notta var |
| mute | examples[2].tr | "…Lena otobüste…" → "…, o yüzden Lena otobüste…" | Eksik "so" |
| mute | quiz.distractors | charge, upload, print → update, upload, print | charge s17'de bir kartın cevabı |
| block | examples[2].tr | "…artık onun paylaşımlarını göremiyor." → "…artık o Defne'nin paylaşımlarını göremiyor." | Özne belirsizdi (Defne göremiyor gibi okunuyordu) |

#### part_03 (ayarlar, kullanım): 10 kart, 18 alan

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| tap | quiz.distractors | fold, kick, pour → hide, upload, delete | Konudan uzaktı. Yeni şıklar telefon eylemi, ama "fotoğrafı açmak için" ile çelişiyor. press/touch/click iki doğru cevap riski taşıdığı için seçilmedi. |
| swipe | quiz.distractors | charge, wrap, print → copy, send, print | charge s17'de cevap, wrap uzaktı. slide/drag/move ikinci doğru cevap olurdu, seçilmedi. |
| swipe | l1.tr.alt | ["parmakla kaydırmak"] → [] | Gloss'un açıklaması gibiydi; gerçek ayrı bir karşılık yok. |
| click | quiz.distractors | type, hang, listen → write, search, read | type s17'de cevap. "type on the blue button" yanlış olsa da yerine aynı işlevden başka şıklar kondu. tap/press okunabilirdi, seçilmedi. |
| zoom in | quiz.distractors | sit down → shut down | Teknoloji alanından phrasal verb; o cümlede yanlış. zoom out ve log out kaldı. |
| connect | quiz.distractors | plug, fix, wake → join, plug, download | "join to the internet" gerçek bir karışma ve dilbilgisi olarak yanlış. fix/wake uzaktı. |
| connect | l1.tr.mistakes | "connect the Wi-Fi" → [] | Türkçe "Wi-Fi'ye bağlanmak" yönelme ekiyle "to"yu destekliyor, yani hata Türkçeden gelmiyor; `why` gerekçesi tutmuyor. |
| save | quiz.distractors | spend, lend, peel → spend, open, share | peel uzaktı, lend s17'de 2 kez geçiyordu. spend kaldı (save money karşıtı). finish/download seçilmedi (okunabilir). |
| save | examples[2] | Elif → Deniz | Aynı dosyada tap örneğinde de Elif vardı. |
| volume | l1.tr.mistakes | 2 madde → 1 madde | "The voice of the TV" silindi: yazar emin değildi; "sound/voice" karışması var ama "voice of the TV" biçimi kanıtsız. "open the sound" kaldı (sesi aç'tan; s4 turn up kartında benzeri "open the volume" var, çakışma değil). |
| up to date | l1.tr.alt | "son sürüm" → "güncellenmiş" | "son sürüm" bir isim (latest version), sıfat anlamını vermiyor. |
| up to date | examples[2].tr | "güncel kalmak için" → "gelişmelerden haberdar olmak için" | Haber okuma bağlamında "güncel kalmak" düz çeviri kokuyor. |
| back up | quiz.distractors | run out of → turn off, set up (give up kaldı; wake up çıktı) | Telefonla ilgili phrasal verb'ler, cümlede açıkça yanlış. run out of biçim olarak farklıydı. |
| reset | quiz.distractors | unplug, mute, heat → unplug, install, lock | mute s17'de cevap, heat uzaktı. change/recover okunabilirdi, seçilmedi. |
| reset | examples[1] | "Click the link in the email to reset your password." → "We sent you an email so you can reset your password." | s2 `link` kartındaki "Click the link to reset your password." ile neredeyse aynıydı. |
| hepsi | meta.qa_flags | + critic_edited | |

#### part_04 (sosyal medya): 9 kart, 31 alan

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| online | ipa.us | /ˌɑnˈlaɪn/ → /ˌɑːnˈlaɪn/ | Depo geleneği US'de `ɑː` (follow, on time, turn on). İkincil vurgu kaldı (Oxford/Longman çift vurgu veriyor; s17 restart/reset ile tutarlı). UK doğru. |
| online | quiz.cloze | My grandmother doesn't use the internet, so she never shops ______. → Our Wi-Fi isn't working, so I can't go ______ to check my email. | Eski cümlede çeldirici olarak "abroad", "alone" gibi zarflar da doğru olabiliyordu; cevap da cümlede neredeyse söyleniyordu. Yeni cümle 'go online' kalıbını sınıyor. |
| online | quiz.distractors | upstairs, together, early → offline, abroad, outside | "together" dilbilgisi olarak saçmaydı. Yenileri aynı türden zarf, 'go ___' ile kurulabiliyor ama bu cümlede açıkça yanlış. |
| account | def.micro | a user profile on an app → your place on an app or site | Dar ve "profile" ile karışıyordu; def.short ile uyumlu. |
| account | synonyms | profile → [] | Profil hesabın görünen sayfası, eşanlamlı değil. |
| account | l1.tr.note | "Bu kart internet ve uygulama hesabı içindir…" → banka hesabı + 'create an account', 'log in to your account' | Kart içi meta dil yerine iki işe yarar kalıp; s15 `bank account` ile fark korunuyor. |
| account | quiz.distractors | garden, umbrella, jacket → battery, ringtone, username | Konuya yakın, cümlede açıkça yanlış. "phone/inbox/profile" bilerek konmadı (doğru olabilirdi). |
| post | synonyms | upload → share | 'Upload' dosya aktarma; en yakın eşanlamlı 'share'. |
| post | antonyms | delete → [] | Karşıt anlam değil. |
| post | l1.tr.alt | göndermek → atmak, yayınlamak | 'Göndermek' Türkçede birine yollamak demek (send). 'Fotoğraf atmak' ve 'yayınlamak' gerçek ve yaygın. |
| post | l1.tr.note | "'Post' bir şeyi internete ilk kez koymaktır…" → kendi içeriğini koymak; 'share' de bu anlamda kullanılır ama başkasının gönderisini paylaşmak da olabilir | Eski not 'share'in kendi içerik için de kullanıldığını gizliyordu. Gloss "paylaşmak" kaldı (en yaygın karşılık); equivalence partial ve confusable:share doğru. |
| post | quiz.distractors | cooked, washed, borrowed → downloaded, charged, unlocked | Konuya yakın geçmiş zaman; kendi çektiğim fotoğrafı "downloaded/charged/unlocked it on social media" açıkça yanlış. shared/uploaded şıklara bilerek konmadı. |
| follower | ipa.us | /ˈfɑloʊər/ → /ˈfɑːloʊər/ | s6 `follow` /ˈfɑːloʊ/ ile tutarlı. |
| follower | examples[2].tr | …ve onun takipçisi Kenji'ninkinden fazla! → …ve Kenji'den daha çok takipçisi var! | Daha doğal Türkçe. |
| follower | quiz.distractors | passports, pillows, stamps → passwords, chargers, headphones | Konuya yakın. fans/viewers/likes/comments bilerek konmadı (doğru olabilirdi). |
| comment | ipa.us | /ˈkɑmɛnt/ → /ˈkɑːmɛnt/ | Depo geleneği. |
| comment | quiz.distractors | lessons, receipts, menus → settings, downloads, screenshots | Konuya yakın, "wrote kind ___" ile açıkça yanlış. messages/words/reviews/emojis bilerek konmadı. |
| tag | l1.tr.alt | etiket atmak → [] | Yerleşik bir kullanım değil; 'etiketlemek' tek başına yeterli. |
| tag | l1.tr.note | "Edat 'in' olur, 'on' değil." → "Fotoğraf, video ve gönderi için 'in' kullanılır." | Platform için 'on' doğru ("tag me on social media"); eski not mutlak bir yasak koyuyordu. |
| tag | tags.register | informal → neutral | 'Tag' nötr bir sözcük. |
| tag | quiz.distractors | wake, lend, fix → block, mute, scroll | Konuya yakın uygulama fiilleri; "so my friends can find it" ile açıkça yanlış. mention/show bilerek konmadı. wake/lend/fix akışta part_03'te de vardı. |
| go viral | examples[0].tr | Onun komik videosu viral oldu. → Komik videosu viral oldu. | "Onun" gereksiz, düz çeviri. |
| go viral | quiz.distractors | went missing, went bad, went wrong → went bad, went cold, went wrong | "went missing" sınırdaydı (izlenen video kaldırılabilir). |
| screen time | quiz.distractors | lunch break, bedtime, rush hour → home screen, battery life, phone case | rush hour part_02'de de vardı; yenileri konuya yakın ve "is too high" ile yanlış. phone bill / data plan bilerek konmadı. |
| fake | synonyms | false → [] | "false news" doğal değil; iyi bir A2 eşanlamlı yok. |
| fake | l1.tr.note | 'fake news' sayılamaz… → kullanım + 'fake account', 'fake news (sahte haber, yalan haber)' | Sayılamazlık bilgisi mistakes'e taşındı. |
| fake | l1.tr.mistakes | [] → This is a fake news. → This is fake news. | Gerçek Türkçe aktarımı ("bir sahte haber"; listedeki "news are" ailesi). |
| fake | quiz.cloze | This isn't a real person's profile. It's a ______ account. → Be careful! This account uses someone else's name and photos. It's ______. | Eski cümlede "official/private/business account" da kurulabiliyordu (gerçek kişi olmayan şirket hesabı). |
| fake | quiz.distractors | private, free, busy → real, safe, verified | Hepsi "Be careful! … başkasının adı ve fotoğrafları" ile çelişiyor. |
| (hepsi) | meta.qa_flags | [] → [critic_edited] | 9 kart. |

#### part_05 (güvenlik): 4 kart, 6 alan

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| scam | examples[0].tr | "Bu mesaj dolandırıcılık." → "Bu bir dolandırıcılık mesajı." | Önceki Türkçe yavan; yeni hali daha doğal |
| scam | l1.tr.alt | [tuzak, sahtekârlık] → [sahtekârlık] | "tuzak" = trap, gevşek bir karşılık. "kazık" fazla ücret ya da fiyat kazığı demek, bu anlama uymuyor |
| hack | quiz.distractors | charged → unplugged (printed, folded kaldı) | "charge" s17'de başka bir kartın cevabı; "my account was charged" da neredeyse olabiliyordu |
| verification code | l1.tr.alt | + "tek kullanımlık şifre" (21 karakter) | Bankacılıkta çok yaygın bir terim |
| verification code | quiz.distractors | lock screen → area code | "lock screen" s17'de başka bir kartın cevabı; "area code" aynı türden ve o cümlede açıkça yanlış |
| secure | quiz.distractors | popular, cheap, empty → broken, slow, expensive | Eskileri konudan uzaktı, "cheap" de akışta başka bir yerde kullanılıyordu. Yeniler site ve alışverişle ilgili, kilit simgesiyle ilgisiz. "safe" şıklarda yok |

### Bağımsız doğrulama ve koordinatör (23 kart, 50 alan)

Üç doğrulayıcının bulguları: quiz (a) YÜKSEK 0 · ORTA 4 · DÜŞÜK 6; Türkçe (b) YÜKSEK 0 · ORTA 2 · DÜŞÜK 17; İngilizce/IPA/üstveri (c) YÜKSEK 0 · ORTA 1 · DÜŞÜK 9. Koordinatör ORTA bulguların hepsini, DÜŞÜK bulguların çoğunu uyguladı; uygulanmayanlar tablonun altında. Düzeltmeleri dördüncü bir ajan kontrol etti: YÜKSEK 0 · ORTA 0 · DÜŞÜK 5 (biri uygulandı: "Powerbank'ini" → "Powerbankini", TDK'ye göre cins isimde kesme işareti yok).

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| restart | quiz.distractors | borrow, drop, hide → lock, mute, delete | Eski şıklar telefonla ilgisizdi. reset ve update bilerek konmadı (donmuş telefonda onlar da düzeltebilir). |
| missed call | quiz.distractors | bus ticket → phone bill | "a bus ticket from Selin" bir şey sınamıyordu. voicemail bilerek konmadı. |
| hack | quiz.distractors | unplugged, printed, folded → muted, tagged, downloaded | Hesap bağlamında akla yatkın değildi. locked/blocked bilerek konmadı (şifre bulununca hesap kilitlenebilir). |
| suspicious | quiz.distractors | useful, colorful, quiet → safe, normal, official | Mesaj için sınayıcı değildi. fake/strange bilerek konmadı. |
| voice message | quiz.cloze, distractors | "I'm driving and can't type…" → "I'm carrying heavy bags and can't type…"; birthday card → comment | Araba kullanırken mesaj göndermek iyi örnek değil (s2 text kartı da bunu yasaklıyor); "ellerim ıslak" bağlamı on speaker'da zaten var. |
| on silent | quiz.distractors | on foot → on speaker | Aynı kalıptan, konuya yakın; zil sesini kısmaz, o cümlede açıkça yanlış. |
| mute | quiz.distractors | print → unmute | Mikrofon bağlamında anlamlı ve yanlış. |
| block | quiz.cloze | "…strange messages…" → "…rude messages…" | "stranger … strange" tekrarı. |
| power bank | quiz.cloze, distractors | "My phone is at 2%…" → "There's no socket on the bus, but I can charge my phone with my ______."; notebook → headset | Eski cümle 2. örneğe çok yakındı. Önerilen kamp cümlesi alınmadı: "selfie stick" de doğru olurdu. |
| zoom in | quiz.cloze | "The text is very small, so I need to ______ to read it." → "The bird in this photo is too small to see. Let me ______." | Eski cümle 1. örneğin neredeyse aynısıydı; önerilen harita cümlesi de 2. örneğe yakındı. |
| power bank | examples[1–2].tr | "Taşınabilir şarjını ödünç alabilir miyim?", "…taşınabilir şarjını doldurur…" → "Powerbankini alabilir miyim?", "…powerbankini şarj eder…" | Günlük konuşmada "powerbank" denir ve "şarj edilir". |
| cracked | examples[0].tr | "…ve artık ekranı çatlak." → "Telefonumu düşürdüm, ekranı çatladı." | "now" düz çevrilmişti. |
| charge, restart, swipe | l1.tr.note | "alet ise / sıfırlamak ise / inmek ise … denir" → "alete ise / sıfırlamaya ise / inmeye ise … denir" | "denir" yönelme durumu ister. |
| restart | examples[2].tr | "…Wi-Fi iki dakika sonra yine çalıştı." → "…iki dakika sonra Wi-Fi tekrar çalışmaya başladı." | "yine (de)" diye okunabiliyordu. |
| fake | mistakes[0].why | "bir sahte haber" → "sahte bir haber" | Türkçe söz dizimi. |
| online | mistakes[0].why | + "'internet' kullanılırsa önüne 'the' gelir" | Asıl hata "the" eksikliği de. |
| mute | examples[2].tr | "…otobüste sesini kapattı." → "…otobüste videonun sesini kapattı." | Lena'nın kendi sesi gibi okunuyordu. |
| click | examples[1].tr, note | "ona çift tıkla" → "üzerine çift tıkla"; gereksiz virgül | Doğal Türkçe. |
| forward | examples[2].tr | "…kimseye iletme. Yalnızca senin için." → "…kimseye iletme, sadece sana özel." | Düz çeviri. |
| voice message | examples[2].tr | "çünkü yazmakta yavaş" → "çünkü yazmak ona uzun sürüyor" | Sakil. |
| scam | l1.tr.note | "(Bu bir dolandırıcılık!)" → "(Bu dolandırıcılık!)" | Konuşma dili. |
| tap | l1.tr.alt, synonyms | "hafifçe vurmak" çıktı; press çıktı (touch kaldı) | Kapıya/omuza vurma anlamı; telefonda "press" çoğu zaman basılı tutmak. |
| suspicious | l1.tr.alt, synonyms | "tuhaf" çıktı; strange → fishy | Tuhaf bir şey şüpheli olmak zorunda değil. |
| zoom in | l1.tr.note | "yakınlaştırırsınız / söylersiniz" → "yakınlaştırırsın / söylersin" | Öteki kartlar "sen" kullanıyor. |
| scam | synonyms | con, fraud → con | "fraud" daha geniş, resmî bir suç adı. |
| secure | antonyms | unsafe → insecure | Site/bağlantı için yerleşik karşıt. |
| reset | def.micro, def.short | "first settings" → "original settings" | Doğal değildi. |
| missed call | def.micro/short/long | "a ring you didn't pick up", "a phone ring…" → "a call you did not answer", "a phone call…" | "a phone ring" yapay. |
| verification code | collocations | enter the code → enter a verification code | Kalıp başlık kelimeyle. |
| go viral | collocations | go viral online → go viral on social media | "viral online" tekrar. |
| online | examples[1], grammar.pattern | "Are you online?…" → "We had our English class online today." / "Bugün İngilizce dersimizi çevrimiçi yaptık."; "be online" → "study / go online" | Kart zarf; "Are you online?" sıfat kullanımı. Gloss "çevrimiçi" artık bir çeviride de görünüyor. |
| hack | examples[0] | "My account was hacked last night." → "Someone tried to hack my account." | Kilit ekranında gerçek bir uyarı sanılabilirdi. |
| scam | examples[0] | "Don't reply. This message is a scam." → "Many 'You won a prize!' messages are scams." | Aynı neden; genel ve sakin bir cümle. |

Uygulanmayan öneriler: `restart` gloss "yeniden başlatmak" (17 grafem, sınır 16), `addicted` "diziye kendini kaptırdı" (kartın karşılığı "bağımlı" çeviriden düşüyordu), `secure` notuna "insecure = kendine güvensiz (kişi için)" eklemek (not uzunluğu; karşıt anlam bağlamda açık), `block` ve `voice message` cloze'larının örneklerle aynı fikri taşıması (cevabı ele vermiyor), `hack` ex0 ile ex1'in ikisinin de "Someone" ile başlaması.

## Çeldirici kontrolü (`3_celdirici_kurallari.md`, 2026-10-22)

- Ölçüm (`distractor_stats.py`, son hâl): `s17: 45 quizzes, 114 distinct distractors; top: ringtone×3, lock×3, delete×3, safe×3, headset×2, plug×2`
- Hedef (hiçbir çeldirici 4'ten fazla soruda değil) yazım aşamasında zaten tutuyordu (yazarların ilk hâlinde en sık `print`×3); bu adımda ayrı bir çeşitlendirme gerekmedi, `distractors_diversified` bayrağı eklenmedi. Denetim ve doğrulamada değişen şıklardan sonra yeniden ölçüldü; yine en fazla 3.
- Başka bir s17 kartının cevabı olan çeldiriciler: `block`, `mute` (tag sorusunda), `on speaker` (on silent sorusunda). Üçü de o cümlede açıkça yanlış; öğrenci ikisini de öğreneceği için bilerek bırakıldı. Yazarlardaki öteki örnekler (charge, type, lock screen, mute) denetimde değişti.
- Cloze cümlesi değişen kartlar: online, fake (ikinci doğru cevap riski), voice message, block, power bank, zoom in (doğrulama; nedenleri yukarıdaki tabloda).

## Anadili Türkçe birinin bakması gerekenler

1. `restart` gloss "tekrar başlatmak" (menüde "Yeniden Başlat"; 16 grafem sınırı yüzünden). "kapatıp açmak" mı daha iyi?
2. `dead` hatası "My charge is finished." ve alt "şarjsız": yaygın mı?
3. `missed call` hatası "Why didn't you open the phone?": gerçek ve yaygın olduğu düşünülüyor; yine de bakılsın.
4. `volume` hatası: yaygın biçim "open the sound" mu, "open the volume" mu? (s4 `turn up` kartında "open the volume" var.)
5. `save` hatası "I recorded your number" ve 3. örnekteki "bastırabilmek" ("çıktısını alabilmek" daha mı doğal?).
6. `hack` hatası "My account hacked yesterday." ve alt "ele geçirmek" ("hesabı ele geçirmek" mi?).
7. `power bank`: gloss "taşınabilir şarj", çevirilerde "powerbank". İkisi de yaygın mı, gloss "powerbank" mı olmalı?
8. `on speaker` gloss "hoparlörde": "hoparlörü açık" gibi bir karşılık mı daha anlaşılır?
9. `post` alt "atmak" ("fotoğraf attım"; ama "birine atmak" = send ile de karışabilir) ve gloss "paylaşmak" (s6 `share` ile aynı).
10. `addicted` alt "müptela" (doğru ama eskice), `online` gloss "çevrimiçi" ile alt "internetten" sırası (örneklerin ikisi "internetten").
11. `up to date` 3. örnek: "gelişmelerden haberdar olmak" mı, "gündemi takip etmek" mi?
12. `verification code` alt "SMS kodu" (konuşma dili, terim değil) ve "tek kullanımlık şifre"; `scam` alt'ta yalnızca "sahtekârlık" var.
13. `block` 3. örnek "artık o Defne'nin paylaşımlarını göremiyor" doğal mı?
14. `voice message`: "voice record" ("ses kaydı at"tan) gerçek bir hata olabilir; emin olunmadığı için eklenmedi.
