# s22 QA incelemesi (günlük deyimler ve phrasal verb'ler)

Kapsam: `content/drafts/kisisel_v1/s22/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B1 öğrencinin dizide, işte ve günlük konuşmada en sık duyduğu phrasal verb'ler (33) ve deyimler (27). Seviye A2–B1.

Süreç (`docs/icerik_uretimi/README.md`; s17–s19 ile aynı). Bütün ajanlar Opus (orta çaba):

1. **Yazım:** part başına bir yazar ajanı (5 ajan), `1_yazar_kurallari.md`. Koordinatör her ifade için tür, kimlik, seviye, anlam ipucu, karışan kelime adayı ve (varsa) Türkçeden kelimesi kelimesine çeviri hatası adayını verdi. Yazarlar adayları ancak kendileri de gerçek bulursa kullandı. İlk turda dört yazar kullanım sınırında durdu; ikinci turda part_01 kaldığı yerden tamamlandı, part_03–05 yeniden yazıldı.
2. **Denetim:** part başına bir denetçi ajanı (5 ajan), `2_denetci_kurallari.md` ve `SYSTEM_C`. Yazarların "emin olmadığım" maddeleri denetçiye ayrıca verildi.
3. **Bağımsız doğrulama:** kartları değiştirmeyen üç doğrulayıcı bütün akışı okudu: (a) quiz'de tek doğru cevap, (b) Türkçe katman (geri çeviri, gloss, gloss_short, not, hata, TDK yazımı), (c) İngilizce içerik, IPA ve üstveri. Koordinatör bulguları tartıp uyguladı.
4. **Son kontrol:** bir ajan, doğrulamadan sonra değişen her alanı ayrıca sınadı (70 alan; 3 küçük düzeltme daha yapıldı).

## Özet

- İncelenen kart: **60** (A2: 5, B1: 55). Tür: 33 phrasal verb, 19 deyim (`idiom`), 6 kalıp (`phrase`), 1 atasözü (`proverb`: better late than never), 1 eşdizim (`collocation`: make a living).
- `primary_topic`: `phrasal_verbs` 33, `idioms_expressions` 26, `collocations` 1.
- Değişen kart: **49** (`critic_edited`). Denetimde 5 partta 52 satır; doğrulama ve son kontrolde 71 alan (aşağıda).
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: hepsi `null` (kalıp ifade). Sahte dost yok. `sensitivity`: hepsi 0.
- **Kilit ekranı anlamı:** 60 kartın hepsinde ≤16 karakter. 45 kartta `gloss` zaten kısa; 15 kartta `gloss_short` var (anlam kısaysa doğrulayıcı `gloss_short`'u uyarıyla reddediyor, bu yüzden "her kartta gloss_short" yerine "her kartta kilit ekranına sığan tam anlam" uygulandı).
- **Karışan kelimeler (`confusables`):** 48 kartta. Boş kalan 12 kartta gerçek bir tuzak bulunamadı (stick to, not the end of the world, on the tip of your tongue, ring a bell, speak of the devil, easier said than done, not my cup of tea, a piece of cake, give someone a hand, all of a sudden, safe and sound, make a living); eş anlamlı yazmak kuralı bozardı. Destede kartı olan eşler (put off, hand in, look after, try on, run into, sleep in…) yalnızca s22 kartına yazıldı; derleyici çifti iki yönlü bağlıyor.
- **Türkçeden çeviri hatası (`mistakes`):** 35 kartta 38 madde (örn. "Prices fell down", "I earn my life", "Let's melt the ice", "Early or late", "downs and ups", "I can't give a decision", "This name comes familiar to me"). Silinen 5 uydurma görünen madde: "A thief entered our house" (doğru İngilizce), "throw an eye on", "at the end of my tongue", "not according to me", "a hand to my homework". 25 kartta gerçek bir hata bulunamadı; uydurmak yerine boş bırakıldı (kill time ve not the end of the world'de Türkçe resim İngilizceyle aynı, hata yok).
- Doğrulayıcı (tüm klasör, `--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`. Çeldirici: 168 farklı şık; en sık "put away" 3 soruda (sınır 4).

## Kelime seçimi

- Var olan 159 phrasal verb ve 9 deyim tekrar yazılmadı. Görevdeki örneklerden figure out, run into, put off ve get along with s4'te zaten var.
- Paralel akışlarla çakışma: "it's up to you" ve "make sense" s20'de (konuşma kalıpları) olduğu için çıkarıldı; yerlerine cross your mind ve not the end of the world girdi. s22 cümlelerinde s20 kalıpları (speaking of, it's up to you, make sense, fair enough, no harm done) geçmiyor. s21 (duygular) ile ortak kart yok.
- Kimlik ve tekrar taraması (`cross_check.py`): s0–s19 ile kimlik, `def.short`, örnek ya da quiz cümlesi çakışması yok. 60 kimliğin hiçbiri `id_registry.json`'da yok.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Quiz'de ikinci okuma ya da bir şey sınamayan şıklar.** Phrasal verb'lerde çok şık cümleye uyabiliyor: hand out ("handed in copies"), break into ("gave up the office"), pull over ("get in"), bring back ("handed out"), meet up ("wake up with him"), come along ("get along"). Hepsi değişti. Doğrulayıcı son hâlde ikinci doğru cevap bulmadı. Yalnızca biçim yüzünden yanlış olan şıklar (take after, hold up) anlam yüzünden yanlış olanlarla değişti.
  2. **Başlık kelimeyi kullanan tanımlar** (come up, go with, go off, hold up, bring back, meet up, think over).
  3. **Kilit ekranında tek başına yanlış okunan Türkçe:** go through "zorluk yaşamak" → "zor gün geçirmek", turn out "meğer … çıkmak" → "ortaya çıkmak", cut off "(suyu) kesmek" → "kesmek, kesilmek", speak of the devil ana anlamı "iti an çomağı hazırla" → "uzun ömürlüymüş" (İngilizcesi dostça; Türkçe atasözü alt'ta).
- **IPA:** DRESS `/ɛ/`, US "on" `/ɑːn/`, US LOT `/ɑː/`, schwa + n `/-ən/`. Tek istisna: not the end of the world US `/ˈwɝld/` (kuraldaki `/ˈwɜːrld/` 26 karakter sınırını aşıyor).
- **Yazım:** örneklerdeki İngiliz yazımı Amerikan yazımına çevrildi (neighbor, practicing, parking lot, mom, on vacation, gas prices, apartments).

## Değişiklik tablosu

### Denetim (5 denetçi)

Her partın sonundaki "bakması gerekenler" o denetçinin notudur; toplu liste en sonda.

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| come up | def.long | "When something comes up, it happens suddenly…" → "A small problem or an urgent job happens suddenly, and you did not plan for it. People often say 'Sorry, something came up' when they cancel a plan." | Tanımın kendisi başlık kelimeyle kuruluyordu (döngüsel); kalıp yalnızca örnek alıntıda kaldı. |
| turn out | def.micro | "be a surprise in the end" → "be found to be in the end" | Her "turn out" sürpriz değildir ("The test turned out to be easy"); eski kısa tanım anlamı daraltıyordu. |
| hold up | def.short | "make someone or something late; people often say 'I got held up'" → "make someone or something late, for example traffic or a long meeting" | Kısa tanımda başlık kelime geçiyordu. |
| meet up | quiz.distractors | wake up → write down | "I'm going to wake up with him for lunch" dilbilgisi olarak mümkün ve ilişki imasına kayıyor; "write down" nesnesiz kullanılamaz, açıkça yanlış. |
| go for | def.long | "a colour" → "a color" | Deste ABD yazımını kullanıyor (color ×11, colour 0; aynı partta "neighbor"). |
| go with | def.long | "When two things look, sound or taste good together, one goes with the other. You use it for colours…" → "To look, sound or taste good together with another thing. You use it for colors, clothes, furniture and food." | Tanım başlık kelimeyle kuruluyordu; ABD yazımı. |
| think over | confusables | (yok) → ["overthink"] | Gerçek biçim tuzağı: "over" overeat/oversleep'teki gibi "aşırı" sanılıp "think over" = aşırı düşünmek okunuyor. |
| work on | examples[2].tr | "Volkan bütün sabah rapor üzerinde çalıştı ve rapor neredeyse bitti." → "Volkan sabahtan beri rapor üzerinde çalışıyor ve rapor neredeyse bitti." | "has been working … all morning" hâlâ sürüyor; geçmiş zaman anlamı değiştiriyordu. |
| go off | def.long | "When an alarm or an alarm clock goes off, it suddenly starts…" → "For an alarm or an alarm clock: to suddenly start making a loud noise. Be careful: …" | Tanım başlık kelimeyle kuruluyordu. |

Değişmeyen ama bakılanlar: bütün quiz'ler tek tek denendi (come up, turn out, hold up, come along, go for, go with, try out, think over, stick to, work on, go off'ta tek doğru cevap var; work on'da "working out/putting off it" zamir sırası yüzünden dilbilgisel olarak yanlış). Hata maddeleri (8) gerçekçi bulundu, hepsi tutuldu. IPA deste kuralına uygun (prepositional verb'de vurgu fiilde: look for /ˈlʊk fər/ gibi). "stick to the speed limit" doğal İngilizce, bırakıldı.

**Anadili Türkçe birinin bakması gerekenler:**
- turn out gloss_short "meğer … çıkmak": kilit ekranında üç noktalı kalıp tek başına doğal okunuyor mu? Alternatif: "sonunda … çıkmak".
- come along hatası "Will you come together with us?": Türkçeden gelen "birlikte" eklemesi gerçek ama bu cümle ne kadar sık? Sınırda.
- come up hatası "a work came out" ve confusable "come out": "bir işim çıktı" çevirisi gerçekten bu biçimde mi çıkıyor?
- stick to gloss_short "bağlı kalmak": tek başına "bağlantıda kalmak" gibi okunabilir mi? Alternatif: "plana uymak".
- think over → overthink eşi: öğrenciler gerçekten karıştırıyor mu (yeni eklendi)?

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| go through | l1.tr.mistakes[0].why | "Türkçede 'zor bir dönemden geçmek' deriz ve 'geçmek' pass diye çevrilir…" → "Türkçede 'zor bir dönem geçirdim' deriz ve 'geçirmek' pass diye çevrilir…" | Yanıltan kalıp "zor bir dönem geçirmek"tir ("pass a hard time" buradan gelir); "dönemden geçmek" daha seyrek. |
| take after | quiz.distractors | "hands in" → "shows off" | "hands in" ile hand out quiz'indeki "handed in" aynı çeldirici sayılır (part içinde tekrar). "She shows off her." dilbilgisi olarak olmuyor; tek doğru cevap korunuyor. |
| give away | collocations | "give away free" → "give away for free" | "give away free" eşdizim olarak eksik/garip; yaygın kalıp "give away for free". |
| hand out | quiz.cloze | "Before the meeting, Tolga ______ copies of the report to everyone." → "Before the meeting, Tolga ______ a copy of the plan to each person." | Yazarın şüphesi doğru: "handed in copies of the report" tek başına olabiliyordu. "Herkese birer kopya" ile "hand in" (yetkiliye teslim) açıkça yanlış kalıyor; "hand in" tuzağı korunuyor. |
| keep on | quiz.distractors | "turned off" → "put away" | put out quiz'inde "turn off" var (part içinde aynı çeldirici). "gave up / got on with" gibi seçenekler cümleye uyacağı için seçilmedi; "put away playing football" olmuyor. |

Değişmeyen kartlar: put up with, come across, mess up, move on, pass out, stand out, put out. Yazarın şüpheli maddeleri: take after hatası ("resembles to") gerçek bir Türk hatası ve `right` doğru, kaldı; put up with ("put up this noise") kaldı; pass out ("passed out for this song") kaldı; go through gloss_short "zorluk yaşamak" kilit ekranında tek başına doğal ve eksiksiz, kaldı; mess up → mess confusable'ı ("I messed the test" tuzağı, benzer biçim) kaldı.

**Anadili Türkçe birinin bakması gerekenler:**
- pass out: "I passed out for this song!" hatası ancak "pass out = bayılmak" diye yeni öğrenmiş biri için gerçekçi; seyrekse silinebilir.
- put up with: "I can't put up this noise" ('with' düşmesi) gerçek bir hata, ama Türkçeden gelme payı sınırlı.
- take after: hata aslında "resemble" fiiliyle ilgili ("resembles to"); kartta bu kadar dolaylı bir hata tutulmalı mı?
- go through: gloss_short "zorluk yaşamak" mı, "zorluk çekmek" mi daha doğal?

#### part_03

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| go away | l1.tr.note | pass away uyarısı yok → "'Pass away' ise 'vefat etmek' demektir." eklendi, not 220 sınırına kısaltıldı | confusables'taki pass away'in neden tuzak olduğu kartta hiç anlatılmıyordu |
| break into | l1.tr.mistakes | 2 madde → 1 madde ("A thief entered our house" silindi) | Cümle dilbilgisi olarak doğru; öğrenciye doğru İngilizceyi "yanlış" diye göstermek yanıltıcı |
| break into | l1.tr.mistakes[0].why | "'eve girmek' tek fiildir; edat düşünülmez" → "'-e' eki tek başına yönü verir; 'in' mi 'into' mu ayrımı yok… nesne yoksa 'break in'" | Yanıltan Türkçe yapıyı (yönelme eki) adıyla söylesin |
| break into | quiz.distractors | gave up → turned down | "Somebody gave up the office" dilbilgisi olarak kurulabiliyor; turned down açıkça yanlış |
| pull over | quiz.distractors | get in → check in | "get in (şeride girmek) and let it pass" okunabiliyordu (yazar da emin değildi) |
| pull over | examples[1].en | licence → license | Aynı kartta "highway" (ABD) var; yazım birliği |
| look through | l1.tr.mistakes | "throw an eye on" → [] | Gerçek, yaygın bir öğrenci hatası olduğu kanıtlanamıyor (daha çok şaka "Tarzanca"); ayrıca "cast an eye over" doğru İngilizce olduğundan "böyle bir kalıp yok" açıklaması yanıltıcı |
| bring back | def.short | "bring something back to the place…" → "return something to the place or person it came from" | Tanım başlık kelimeyi kullanıyordu (döngüsel) |
| bring back | l1.tr.alt | [iade etmek, geri vermek] → [iade etmek] | "geri vermek" = give back (confusable); karışıklığı artırıyordu |
| bring back | l1.tr.mistakes[0].why | "nesne fiilden önce tek parça…" → "'geri getirmek' bölünmeyen tek fiil gibi düşünülür; zamirler 'bring' ile 'back' arasına girer" | Eski açıklama hatanın nedenini doğru anlatmıyordu |
| bring back | quiz.distractors | handed out, calmed down, signed up → grown up, signed up, sat down | "has only handed out one" kurulabiliyordu; "calmed down" run away'de de var (part içinde tekrar) |
| cut off | l1.tr.gloss / gloss_short | "kesmek, kesilmek" → gloss "(suyu ya da hattı) kesmek", gloss_short "(suyu) kesmek" | Kilit ekranında tek başına "kesmek" bıçakla kesmek gibi okunuyordu; anlamın su/hat olduğu görünsün |
| cut off | l1.tr.alt | [hat kesilmek, bağlantı kopmak] → [kesilmek, hat kesilmek, bağlantı kopmak] | Edilgen kullanım ("was cut off") karşılığı gloss'tan çıktığı için alt'ta kalsın |
| go down | quiz.distractors | wear off → go off | cut off'ta "worn off" var; aynı fiil part içinde iki kez çeldirici olmasın |
| doze off | examples[2].tr | "neredeyse içi geçiyordu" → "neredeyse içi geçecekti" | "almost dozed off" = az kalsın; Türkçede doğal biçim "-ecekti" |
| doze off | examples[*].register, tags.register | informal → neutral | doze off sözlüklerde etiketsiz/nötr; günlük ama argo değil |

Değişmeyen kartlar: run away, kill time, lose track of time, call it a day.

Yazarın "emin değilim" maddeleri:
1. kill time: "killing time" ilk örnekte kalsın; ifade kilit ekranında zararsız, kartı kilit ekranından çıkarmaya gerek yok.
2. break into "entered" maddesi silindi (yukarıda).
3. cut off "The water cut this morning." korundu: "su kesildi / elektrik kesildi" kalıbı Türk öğrencilerde sık; `right` ("was cut off") doğru.
4. go away / pass away: confusable olarak kaldı (aynı "geçmek" fiili + benzer biçim), not artık açıklıyor.
5. doze off: gloss "içi geçmek" kaldı (uyuklamak = sızmadan uyuklamak, tam karşılık değil).
6. pull over "get in" değiştirildi.

**Anadili Türkçe birinin bakması gerekenler:**
- doze off gloss "içi geçmek": kilit ekranında tek başına (meyve "içi geçmiş" anlamıyla) yanlış okunur mu? Alternatif: "uyuklamak".
- cut off gloss_short "(suyu) kesmek": telefon anlamını (hat kesilmesi) dışarıda bırakıyor; yeterli mi?
- lose track of time hatası "I didn't understand how the time passed": Türk öğrencilerde gerçekten yaygın mı? Korundu.
- look through: silinen "throw an eye on" gerçekten öğrencilerin ürettiği bir hata mı, yoksa yalnızca şaka mı?
- go away gloss "geçip gitmek" ağrı anlamında tek başına yeterince açık mı ("geçmek" daha mı iyi)?

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| cross your mind | l1.tr.mistakes[0].why | "'-den' eki 'from', 'geçmek' 'pass' … 'from' almaz" → "'-den geçmek' 'pass from' diye çevrilir ('I passed from the bridge' hatası gibi). 'Pass from my mind' daha çok 'unutulmak' gibi anlaşılır; doğrusu 'cross my mind'." | Hata gerçek bir Türkçe kalıba dayanıyor ("pass from the bridge"). Eski why, doğru olan "pass through my mind" kullanımını da yanlış gösteriyordu ve yanlış cümlenin İngilizcede "unutulmak" diye okunduğunu söylemiyordu. |
| not the end of the world | ipa.us / ipa.uk | /nɑt … ˈwɝld/, UK /ˈend/ → /nɑːt ði ˈɛnd əv ðə ˈwɝld/, UK /ˈɛnd/ | Depo kuralı: US LOT /ɑː/, DRESS /ɛ/. US /ɜːr/ 26 sınırını aştığı için ɝ kaldı. |
| keep in mind | l1.tr.mistakes[0].why | "Türkçede 'aklımda tutarım' … nesne sona eklenir" → kalıp tek parça öğrenilince nesne sona eklenir; zamir araya girer, yalnızca 'that' cümlesi ya da uzun nesne sonda kalır | Türkçede nesne başta gelir ("onu aklımda tutarım"); eski gerekçe yanlıştı. Hata (zamir yeri) gerçek, kaldı. |
| keep in mind | tags.topics | time_routines → mind_psychology | Kartın konusu zaman değil, hatırlamak. |
| sleep on it | ipa.us | /ˈsliːp ɑn ɪt/ → /ˈsliːp ɑːn ɪt/ | Depoda US "on" /ɑːn/. |
| on the tip of your tongue | ipa.us | /ɑn …/ → /ɑːn ðə ˈtɪp əv jʊr ˈtʌŋ/ | Aynı IPA kuralı. |
| on the tip of your tongue | l1.tr.mistakes | "It's at the end of my tongue." → [] | Türkçe konuşanların gerçekten böyle dediğine dair bir iz yok; uydurma bir hata, hiç hata olmamasından daha kötü. Türkçede de aynı resim var. |
| ring a bell | ipa.uk | /ˈbel/ → /ˈbɛl/ | DRESS /ɛ/. |
| speak of the devil | ipa.uk | /ˈdevl/ → /ˈdɛvl/ | DRESS /ɛ/. |
| easier said than done | ipa.uk | /ˈsed/ → /ˈsɛd/ | DRESS /ɛ/. |
| easier said than done | l1.tr.alt | "dile kolay" → "söylemek kolay" | "Dile kolay" Türkçede "söylemesi kolay ama büyük bir şey" demektir ("Dile kolay, 40 yıl"); "yapması zor" anlamı taşımaz. |
| better late than never | ipa.uk | /ˈbetə … ˈnevə/ → /ˈbɛtə … ˈnɛvə/ | DRESS /ɛ/. |
| not my cup of tea | ipa.us | /nɑt/ → /nɑːt/ | US LOT /ɑː/. |
| not my cup of tea | l1.tr.mistakes | "Camping is not according to me." → [] | Bilinen hata "according to me" = "in my opinion" kullanımı. "Not according to me" = "bana göre değil" biçimi için gerçek bir kanıt yok. Yazar da emin değildi. |

Değişmeyenler ve kontrol edilenler:
- **Quiz:** 12 sorunun hepsinde her çeldirici boşluğa kondu ve ikinci doğru cevap çıkmadı. sleep on it (lie/stand/walk) güvenli. "Sit" bilerek kullanılmamış, doğru karar. Bu part içinde aynı çeldirici iki kez geçmiyor.
- **Kalan hatalar:** cross your mind (pass from), no big deal ("It's not important" teşekküre cevap), keep in mind (zamir yeri), make up your mind ("give a decision", bilinen gerçek hata), ring a bell ("comes familiar").
- **confusables:** cross your mind → keep in mind, make up your mind (biçim benzerliği, akıl/mind kalıpları); no big deal → never mind (teşekküre "never mind" demek bilinen bir kullanım tuzağı); diğerleri yerinde. Boş olanlara gerçek bir eş bulunamadı.
- s20 ifadeleri cümlelerde geçmiyor. cross_check: problems: 0.

**Anadili Türkçe birinin bakması gerekenler:**
- sleep on it gloss_short "sabaha bırakmak": tek başına okununca genel bir "ertelemek" gibi durabilir. Kararı ertesi güne bırakma anlamı yeterince açık mı?
- speak of the devil gloss_short "uzun ömürlüymüş": kilit ekranında tek başına okununca bu durum için söylendiği anlaşılıyor mu? Ana anlam "iti an çomağı hazırla".
- better late than never gloss_short "geç de olsa iyi": doğal mı? ("geç de olsa iyi oldu" daha doğal olabilir ama 16 karakteri aşıyor.)
- cross your mind hatası "It never passed from my mind.": "pass from" kalıbı Türklerde bilinen bir hata ama bu deyimde ne kadar yaygın?
- sleep on it ilk örnek çevirisi "Bir gece düşüneyim." doğal mı? Alternatif: "Bir gece üstünde düşüneyim."

#### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| a piece of cake | examples[2].tr | "…uzun yürüyüş çok kolaydı." → "…uzun yürüyüş çocuk oyuncağıydı." | Deyimin Türkçe karşılığı çeviride görünmüyordu. |
| keep an eye on | examples[2].en | "neighbours'" → "neighbors'" | Deste çoğunlukla Amerikan yazımı kullanıyor (neighbor 113 / neighbour 11). |
| keep an eye on | l1.tr.note | "Kısa süreli gözetmek içindir." → "Çoğunlukla kısa süre gözetmek için kullanılır." | Kesin kural yanlış: "keep an eye on the time / prices" gibi kullanımlar da var (kartın kendi eşdizimi). |
| give someone a hand | l1.tr.mistakes | "give me a hand to my homework" → "Can you give me hand with this box?" (a düşmesi) | "-e → to" hatası bu kalıpta doğrulanamadı (gerçek olan "help to me"). Türkçede a/an olmadığı için tanımlığın düşmesi gerçek ve sık bir hata. |
| once in a blue moon | def.long | "…often said about things you would like to do more…" → "…often comes at the end of a sentence: 'We only meet once in a blue moon.'" | Eski iddia doğru değildi (kar yağması gibi istenmeyen şeyler için de kullanılır). |
| all of a sudden | ipa | US /ˈɔːl … ˈsʌdən/, UK /… ˈsʌdn̩/ → ikisi de /ˌɔːl əv ə ˈsʌdən/ | Depo kuralı: schwa + n /-ən/. "all" ikincil vurgulu. |
| sooner or later | quiz.cloze | "practising" → "practicing" | Amerikan yazımı birliği. |
| get used to | ipa | /ɡet/ → /ɡɛt/ (US, UK) | DRESS ünlüsü depo kuralı /ɛ/. |

Değişmeyenler: break the ice, in the same boat, ups and downs, safe and sound, make a living. Bütün quiz şıkları boşluğa tek tek kondu; ikinci doğru cevap yok (in the same boat'taki "ship" gerçek calque biçimi, iyi çeldirici). "geçim sağlamak" (make a living gloss_short) doğal bulundu ("tarımdan geçim sağlamak").

**Anadili Türkçe birinin bakması gerekenler:**
- "once in forty years", "in the same ship", "Early or late", "downs and ups", "Let's melt the ice": olası ve yaygın görünen calque'lar, tutuldu; gerçekten bu kadar sık mı?
- break the ice → confusable "make up": Türkçede "aradaki buzlar eridi" barışma için kullanılıyor; eşleşme yeterince gerçek mi?
- give someone a hand ilk örnek çevirisi "Bu poşetlere bir el atar mısın?": "el atmak" burada doğal mı, yoksa "Bu poşetleri taşımama yardım eder misin?" mi daha iyi?
- all of a sudden ve safe and sound: hata listesi boş bırakıldı (gerçek bir calque bulunamadı).

### Doğrulama ve son kontrol

Kaynak: `val_quiz` (Q), `val_turkce` (T), `val_ingilizce` (E), son kontrol (S). Birden çok alanı değişen kartta her alan ayrı satır.

| Kart | Alan | Önce → Sonra |
|---|---|---|
| turn out | l1.tr.alt | ['… çıkmak', 'olduğu anlaşılmak'] → ['sonradan anlaşılmak', 'olduğu anlaşılmak'] |
| turn out | l1.tr.gloss_short | 'meğer … çıkmak' → 'ortaya çıkmak' |
| turn out | l1.tr.note | "Türkçedeki 'iyi biri çıktı', 'kolay çıktı' kalıbının karşılığıdır: 'turned out to be kind/easy'. 'Turn up' ise gelmek, ortaya çıkmak (ya da sesi açmak) demektir." → "Türkçedeki 'iyi biri çıktı', 'kolay çıktı' kalıbının karşılığıdır: 'turned out to be kind/easy'. 'Turn up' ise gelmek, gelip görünmek (ya da sesi açmak) demektir." |
| hold up | examples[1].tr | 'Toplantı beni oyaladı, bu yüzden otobüsü kaçırdım.' → 'Toplantı beni geciktirdi, bu yüzden otobüsü kaçırdım.' |
| hold up | l1.tr.alt | ['oyalamak', 'trafiğe takılmak'] → ['oyalamak', 'alıkoymak'] |
| hold up | quiz.distractors | ['held on', 'set off', 'gone out'] → ['held on', 'let down', 'turned down'] |
| meet up | def.micro | 'meet a friend by plan' → 'see a friend at a set time' |
| come along | quiz.cloze | "We're going to the cinema tonight. Do you want to ______ with us?" → "I'm walking to the park with the kids. Would you like to ______?" |
| come along | quiz.distractors | ['come across', 'turn down', 'throw away'] → ['come across', 'turn down', 'come apart'] |
| think over | def.micro | 'think well before deciding' → 'consider well, then decide' |
| think over | def.short | 'think carefully about an idea or an offer before you decide' → 'consider an idea or an offer carefully before you decide' |
| go off | quiz.distractors | ['went out', 'gave up', 'sat down'] → ['went out', 'gave up', 'turned off'] |
| go through | l1.tr.gloss_short | 'zorluk yaşamak' → 'zor gün geçirmek' |
| put up with | examples[1].en | "Hakan put up with his neighbour's loud music for months." → "Hakan put up with his neighbor's loud music for months." |
| take after | def.long | "To look or behave like your mother, father or another older family member. It is not used in the -ing form: say 'She takes after her mum'." → "To look or behave like your mother, father or another older family member. It is not used in the -ing form: say 'She takes after her mom'." |
| take after | examples[2].en | 'Who do you take after, your mum or your dad?' → 'Who do you take after, your mom or your dad?' |
| take after | quiz.distractors | ['puts out', 'shows off', 'carries on'] → ['looks after', 'runs into', 'shows off'] |
| mess up | quiz.distractors | ['took after', 'stood out', 'got along with'] → ['put away', 'handed in', 'stood out'] |
| move on | quiz.distractors | ['pass out', 'doze off', 'break down'] → ['move out', 'pass out', 'doze off'] |
| give away | examples[2].en | 'Before moving to Berlin, Omar gave away his sofa to a neighbour.' → 'Before moving to Berlin, Omar gave away his sofa to a neighbor.' |
| give away | l1.tr.alt | ['dağıtmak', 'hediye etmek', 'elden çıkarmak'] → ['dağıtmak', 'hediye etmek', 'karşılıksız vermek'] |
| give away | quiz.distractors | ['looked into', 'set off', 'came over'] → ['threw away', 'put away', 'looked into'] |
| hand out | examples[0].tr | 'Bu kağıtları dağıtır mısın lütfen?' → 'Bu kâğıtları dağıtır mısın lütfen?' |
| hand out | examples[2].tr | 'Öğretmen sınav kağıtlarını dağıttı ve bir saatimiz olduğunu söyledi.' → 'Öğretmen sınav kâğıtlarını dağıttı ve bir saatimiz olduğunu söyledi.' |
| pass out | quiz.distractors | ['come along', 'keep on', 'hang out'] → ['come along', 'keep on', 'pass away'] |
| stand out | examples[0].en | 'That bright yellow car really stands out in the car park.' → 'That bright yellow car really stands out in the parking lot.' |
| stand out | quiz.distractors | ['give away', 'sleep in', 'look forward to'] → ['stand up', 'give away', 'sleep in'] |
| keep on | confusables | ['carry on', 'go on'] → ['keep up with', 'carry on'] |
| keep on | examples[1].en | 'Keep on practising and your English will get better.' → 'Keep on practicing and your English will get better.' |
| keep on | quiz.distractors | ['looked after', 'ran into', 'put away'] → ['gave up', 'looked after', 'ran into'] |
| pull over | ipa.us | '/pʊl ˈoʊvɚ/' → '/pʊl ˈoʊvər/' |
| pull over | tags.flags | ['intransitive'] → [] |
| look through | l1.tr.alt | ['göz atmak', 'karıştırmak', 'üstünden geçmek'] → ['göz atmak', 'karıştırmak', 'şöyle bir bakmak'] |
| look through | quiz.distractors | ['look after', 'look up to', 'run out of'] → ['look after', 'look up to', 'look for'] |
| bring back | quiz.distractors | ['grown up', 'signed up', 'sat down'] → ['looked up', 'signed up', 'put away'] |
| cut off | l1.tr.gloss_short | '(suyu) kesmek' → 'kesmek, kesilmek' |
| go down | examples[1].en | 'Petrol prices are going down again.' → 'Gas prices are going down again.' |
| go down | quiz.distractors | ['break down', 'go off', 'show up'] → ['break down', 'go off', 'go up'] |
| doze off | examples[0].tr | 'Dedemin televizyonun karşısında içi geçti.' → 'Dedemin televizyonun karşısında içi geçmiş.' |
| kill time | examples[0].register | 'informal' → 'neutral' |
| kill time | examples[1].register | 'informal' → 'neutral' |
| kill time | examples[2].register | 'informal' → 'neutral' |
| kill time | tags.register | 'informal' → 'neutral' |
| lose track of time | confusables | ['time flies'] → ['lose time'] |
| lose track of time | l1.tr.note | "Geç kalınca özür için çok kullanılır: 'Sorry, I lost track of time.' 'Time flies' ise genel olarak 'zaman çabuk geçiyor' demektir." → "Geç kalınca özür için çok kullanılır: 'Sorry, I lost track of time.' 'Lose time' ise zaman kaybetmek demektir: 'We lost time in traffic.'" |
| call it a day | quiz.cloze | "It's 9 p.m. and we're all tired. Let's call it a ______." → "It's 6 p.m. and we're all tired. Let's call it a ______." |
| keep in mind | collocations | ['keep in mind that', 'keep it in mind', 'bear in mind'] → ['keep in mind that', 'keep it in mind', 'always keep in mind'] |
| keep in mind | l1.tr.mistakes[0].why | "Kalıp tek parça bir fiil gibi öğrenilince nesne sona eklenir. 'It, them, you' gibi zamirler ise 'keep' ile 'in mind' arasına girer; yalnızca 'that …' cümlesi ya da uzun bir nesne sonda kalır." → "Türkçede 'aklımda tutarım' tek fiil gibidir, bu yüzden 'it' sona eklenir. 'It, them' gibi zamirler 'keep' ile 'in mind' arasına girer; yalnızca 'that …' cümlesi ya da uzun nesne sonda kalır." |
| keep in mind | synonyms | [] → ['bear in mind'] |
| make up your mind | l1.tr.note | "'Change your mind' fikrini değiştirmektir; 'make up' tek başına barışmak demektir. Karar vermek anlamı için 'mind' şart." → "'Change your mind' fikrini değiştirmektir; 'make up' tek başına barışmak ya da uydurmak demektir. Karar vermek anlamı için 'mind' şart." |
| make up your mind | quiz.cloze | "I've looked at both flats three times, but I still can't ______ my mind." → "I've looked at both apartments three times, but I still can't ______ my mind." |
| speak of the devil | examples[0].tr | 'İti an çomağı hazırla! İşte Tom geliyor.' → 'Uzun ömürlüymüş! İşte Tom geliyor.' |
| speak of the devil | l1.tr.alt | ['uzun ömürlüymüş'] → ['iti an çomağı hazırla'] |
| speak of the devil | l1.tr.gloss | 'iti an çomağı hazırla' → 'uzun ömürlüymüş' |
| speak of the devil | l1.tr.gloss_short | 'uzun ömürlüymüş' → None |
| speak of the devil | quiz.cloze | "We were just talking about Leyla, and now she's at the door. Speak of the ______!" → '"Is Leyla coming tonight?" Just then, Leyla walked in. "Speak of the ______!"' |
| keep an eye on | examples[1].tr | 'Lütfen çorbaya göz kulak ol, taşmasın.' → 'Lütfen çorbaya dikkat et, taşmasın.' |
| keep an eye on | examples[2].en | "Gül keeps an eye on her neighbors' house when they are on holiday." → "Gül keeps an eye on her neighbors' house when they are on vacation." |
| give someone a hand | examples[1].en | 'Murat gave his neighbour a hand when she moved house.' → 'Murat gave his neighbor a hand when she moved to a new apartment.' |
| give someone a hand | examples[1].focus | 'gave his neighbour a hand' → 'gave his neighbor a hand' |
| give someone a hand | l1.tr.alt | ['el atmak', 'yardımcı olmak', 'el vermek'] → ['el atmak', 'yardımcı olmak', 'yardım eli uzatmak'] |
| give someone a hand | l1.tr.mistakes[0].why | "Türkçede 'a/an' karşılığı yok ve 'bana el ver' deriz, bu yüzden 'a' düşer. Kalıp her zaman 'give sb a hand' biçimindedir." → "Türkçede 'a/an' gibi bir artikel yok, bu yüzden 'a' kolayca düşer. Kalıp her zaman 'give sb a hand' biçimindedir." |
| all of a sudden | l1.tr.mistakes | [] → None |
| all of a sudden | l1.tr.mistakes[0].right | None → 'All of a sudden, it started to rain.' |
| all of a sudden | l1.tr.mistakes[0].why | None → "Türkçede 'a/an' karşılığı yok, bu yüzden 'a' kolayca düşer. Kalıp her zaman 'all of a sudden' biçimindedir." |
| all of a sudden | l1.tr.mistakes[0].wrong | None → 'All of sudden, it started to rain.' |
| safe and sound | collocations | [] → ['arrive safe and sound', 'get home safe and sound', 'back safe and sound'] |
| safe and sound | l1.tr.alt | ['sapasağlam', 'hiçbir şey olmadan'] → ['sapasağlam', 'başına bir şey gelmeden'] |
| get used to | collocations | [] → ['get used to it', 'slowly get used to', "can't get used to"] |
| get used to | l1.tr.alt | ['alışık hâle gelmek'] → ['-e ısınmak'] |
| get used to | l1.tr.mistakes[1].why | "Türkçede 'alışkınım' tek kelimedir, 'be' fiili unutulur. 'I used to' eskiden yaptığın şeydir; alışkınlık için 'I'm used to' gerekir." → "Türkçede 'alışkınım' tek kelimedir, bu yüzden 'be' fiili unutulur. 'I used to' eskiden yaptığın şeydir; bir şeye alışkın olmak için 'I'm used to' gerekir." |

Alınmayan öneriler: not the end of the world gloss_short "kıyamet kopmadı" (geçmiş zaman, "felaket değil" kaldı); sleep on it "yarın karar vermek" ("sabaha bırakmak" başlıkla birlikte doğru okunuyor); pass out hatasında "for" → "to" (iki biçim de görülüyor); get used to çeldiricileri (use/using/uses hedeflenen hatayı sınıyor); son kontrolün turn out için "meğer öyleymiş" önerisi (fiil değil; onun yerine nottaki "turn up … ortaya çıkmak" ifadesi "gelip görünmek" yapıldı, böylece kilit ekranı anlamıyla çakışmıyor).

## Çeldirici çeşitlendirme

`distractor_stats.py`: `s22: 60 quizzes, 168 distinct distractors; top: put away×3, put off×2, turned up×2, found out×2, turned down×2, look after×2`. Sınır (4) aşılmıyor. On çeldirici başka bir s22 kartının cevabı (ör. come across, give away, pass out); hepsi kendi cümlesinde açıkça yanlış.

## Anadili Türkçe birinin bakması gerekenler

1. Çeviri hatalarının sıklığı: "once in forty years", "in the same ship", "Early or late", "downs and ups", "Let's melt the ice", "I passed out for this song!", "It never passed from my mind", "I didn't understand how the time passed", "The water cut this morning", "Will you come together with us?", "A work came out".
2. Kilit ekranı karşılıkları: turn out "ortaya çıkmak", go through "zor gün geçirmek", sleep on it "sabaha bırakmak", cut off "kesmek, kesilmek", doze off "içi geçmek", stick to "bağlı kalmak", better late than never "geç de olsa iyi", not the end of the world "felaket değil", speak of the devil "uzun ömürlüymüş".
3. Karışan kelime eşleri: break the ice → make up ("aradaki buzlar eridi" barışma anlamında), think over → overthink, go away → pass away.
4. give someone a hand ilk örneği "Bu poşetlere bir el atar mısın?" doğal mı?
