# s24 QA incelemesi (B2: siyaset, haber ve toplum)

Kapsam: `content/drafts/kisisel_v1/s24/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin haberlerde, gazetede ve iş yerinde en sık karşılaştığı siyaset, kamu ve haber dili kelimeleri. Seviye: hepsi B2.

Süreç (`docs/icerik_uretimi/README.md`; s22 ile aynı biçim):

1. **Yazım:** bir yazar ajanı, `1_yazar_kurallari.md`. Kartlar oturumun geçici klasöründeki betiklerle (mk.py, p1–p5.py) üretildi. Destede var olan hiçbir başlık kelime tekrar yazılmadı; atlanan kelime yok.
2. **Denetim:** bir denetçi ajanı (Opus), `2_denetci_kurallari.md`. 60 kart tek tek okundu, yazarın "emin olmadığım" maddeleri ayrıca tartıldı (aşağıda). Düzeltmeler doğrudan JSON'a yapıldı. Üretim betikleri bu düzeltmelerle eşitlenmedi; kartlar betiklerden yeniden üretilirse düzeltmeler kaybolur.

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 54 kelime (24 isim, 18 fiil, 8 sıfat, 4 zarf), 3 kalıp (`phrase`: according to, in favor of, on behalf of), 1 eşdizim (`collocation`: make headlines), 1 deyim (`idiom`: break the news), 1 phrasal verb (call for).
- `primary_topic`: `society_media` 35, `politics_government` 18, `law_legal` 3, `opinions_debate` 2, `phrasal_verbs` 1, `idioms_expressions` 1.
- Değişen kart: **16** (`critic_edited`), değişen alan: **23**.
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: hepsi `null`. Sahte dost: hepsi `null` (campaign için aşağıya bakın). `sensitivity`: hepsi 0. `meta.status`: hepsi `draft`.
- **Kilit ekranı anlamı:** yalnızca make headlines'ta `gloss_short` var ("manşete çıkmak"). Doğal bulundu, kaldı. Öteki 59 kartın anlamı 16 karakteri geçmiyor.
- **Karışan kelimeler (`confusables`):** 22 kartta. Destede kartı olan eşler (actual, guess, major) ve s24 içi çiftler (mayor ↔ major, affect ↔ influence, deny ↔ reject) yazarın notundaki gibi; derleyici iki yönlü bağlıyor.
- **Türkçeden gelen hata (`mistakes`):** 20 kartta 21 madde. Silinen uydurma madde: 1 (elect, "I elected the blue shirt").
- Doğrulayıcı (tüm klasör, `--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`. Çeldirici: 137 farklı şık; en sık headline, minority, predicted ve official, 4'er soruda (sınır 4). IPA DRESS: us_ɛ 11 / us_e 0, uk_ɛ 11 / uk_e 0.

## Genel bulgular

- **En sık 3 sorun:**
  1. **İngiliz kullanımı** (deste Amerikan İngilizcesi kullanıyor): rubbish, queues, towards, holiday (2 kez), flat. Hepsi ABD karşılığına çevrildi. council'ın "collects the rubbish" örneği değişti, çünkü ABD'de çöpü belediye meclisi toplamaz. Yerine meclisin gerçek işini anlatan bir cümle girdi.
  2. **Quiz'de ikinci doğru cevap riski:** current'ta "the actual mayor" kurulabiliyordu (vekile karşı asıl başkan anlamında). elect'te "voted her as … mayor" konuşma dilinde duyuluyor. worldwide'da "spread equally" kurulabiliyordu. current'ın cümlesi zaman karşıtlığıyla yeniden kuruldu; öteki ikisinde çeldirici değişti.
  3. **Türkçede küçük doğallık sorunları:**
     - reveal: "sırrını açığa vurdu" → "açıkladı".
     - respond: "sellere hızlı tepki verdi" → "hızla müdahale etti".
     - spread: "dedikodusunu" → "söylentisini" (rumor karşılığı).
     - mayor ve resident: tek başına "sakinler" → "şehir halkı" ve "bölge sakinleri".
     - source: çeviriye fazladan eklenmiş "araştırmaya" çıkarıldı.
- **Tanımda başlık kalıp:** in favor of'un `def.short`'unda "in favour of" geçiyordu. `def.long`'daki örnek ("70% voted for the plan") de kalıbı göstermiyordu. İkisi yeniden yazıldı.
- **alt:** on behalf of'tan "yerine" çıkarıldı, "temsilen" eklendi. "Yerine" instead of'un karşılığı ve instead of kartın kendi confusable'ı.

### Yazarın "emin olmadığım" maddeleri

1. **campaign, `false_friend`:** `null` kaldı. Kısmi sahte dost gerçek ("Migros'ta kampanya var" = sale). Ama alan doldurulunca doğrulayıcı `equivalence: false_friend` istiyor (`FF_EQUIV`), ve kelimenin ana anlamı Türkçeyle aynı olduğu için bu yanlış olurdu. Uyarı `note` ve `mistakes` içinde yeterince görünüyor.
2. **Hata maddeleri:**
   - elect, "I elected the blue shirt": silindi. Türk öğrencilerde bilinen bir hata değil; choose/select/elect farkını not zaten anlatıyor.
   - survey, "We made a survey": kaldı. "Anket yapmak" → make; make/do karışıklığının gerçek ve sık bir örneği.
   - spread, "spreaded": kaldı. Genel bir öğrenci hatası, ama Türkçede düzensiz geçmiş zaman olmadığı için `why` savunulabilir.
   - raise, "Prices raised": kaldı. rise/raise karışıklığı çok sık; artmak/artırmak açıklaması doğru.
   - make headlines: hata maddesi yok. Boş kalması doğru, çünkü Türkçedeki resim İngilizceyle aynı.
3. **resident ve authority:**
   - resident, "sakin, oturan": kaldı. "Oturan" eki tek başına "sakin = sessiz" okumasını önlüyor.
   - authority, "yetkili makam": kaldı. Tekil kart anlamı için doğru; "yetkililer" alt'ta ve örneklerde var.
4. **Quiz'ler:**
   - current: değişti (yukarıda).
   - affect, "effected": kaldı. Fiil olarak var ama "bring about" anlamında; cümlede açıkça yanlış ve gerçek bir hata biçimi.
   - investigate, "researching the robbery": kaldı. Doğal değil ve Türkçedeki "araştırmak" tuzağını sınıyor.
   - raise, "rise / lift / arise": kaldı. "Lift awareness" kurulamıyor.
   - officially, biçim çeldiricileri (official / office / officer): kaldı. Doğru karar, çünkü "formally opened" da doğru olurdu.
5. **IPA ve tür seçimleri:**
   - IPA uygun: mayor US /ˈmeɪər/, UK /meə/; call for zayıf biçimle /fər/, /fə/; in favor of UK /ɪn ˈfeɪvər əv/ (bağlayıcı r).
   - Tür ve pos seçimleri (phrase/phr, collocation/phr, idiom/idm, phrasal_verb/phv) doğrulayıcıyla ve s22 ile tutarlı.

### Değişmeyen ama bakılanlar

- **Quiz:** 60 sorunun hepsinde her şık boşluğa kondu. Değişen 3 soru dışında ikinci doğru cevap bulunmadı. Sınırda bırakılanlar şunlar; hepsi bağlamda açıkça yanlış:
  - decline: "The number of tourists has increased because of the high hotel prices" (dilbilgisi doğru, anlamca çelişkili).
  - democratic: "a political country".
  - public: "open to the audience".
  - deny: "rejected taking money".
- **Kalan 21 hata:** hepsi Türkçe kalıptan gelen bilinen hatalar.
  - campaign: "big campaign at the supermarket"
  - citizen: "a Turkey citizen"
  - policy: "changed its politics"
  - majority: "The most of the people"
  - crisis: "crisises" ve "heart crisis"
  - mayor: "president of the municipality"
  - parliament: "accepted in the parliament"
  - statement: "made an explanation"
  - survey: "made a survey"
  - deny: "refused the accusations"
  - oppose: "oppose to"
  - affect: "affected on"
  - influence: "influences on"
  - raise: "Prices raised"
  - spread: "spreaded"
  - political: "politic problems"
  - official: "official clothes"
  - current: "actual problems"
  - according to: "According to me"
  - on behalf of: "in the name of"
- **IPA:** 60 kartın hepsi kontrol edildi. Vurgu yerleri doğru; DRESS /ɛ/, US LOT /ɑː/.

### Seviye (B2) kontrolü

Kartlar silinmedi, seviye alanı değiştirilmedi. Aşağıdakiler Oxford 3000 / English Vocabulary Profile'da büyük olasılıkla daha düşük seviyede. B2 destesinde kolay kalabilirler:

- Büyük olasılıkla A2–B1: according to, affect, official, illegal, legal.
- Büyük olasılıkla B1: citizen, policy, source, statement, survey, political, current, public (isim), press, issue, majority, minister.
- C1'e kayan kart yok. make headlines, break the news, on behalf of ve call for B2 için uygun.

Kesin seviye için listenin EVP ile karşılaştırılması önerilir.

## Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| **part_01.json** | | | |
| source | examples[2].tr | "Vikipedi araştırmaya başlamak için faydalı ama tek kaynağın o olmamalı." → "Vikipedi başlamak için faydalı bir yer ama tek kaynağın o olmamalı." | Çeviri İngilizcede olmayan 'araştırmaya' sözcüğünü ekliyordu. |
| council | def.long | "A group of people, usually elected, who make decisions and run local services for a town, city or area, such as rubbish collection, parks and local roads." → "A group of people, usually elected, who make decisions and run local services for a town, city or area, such as trash collection, parks and local roads." | Deste Amerikan İngilizcesi kullanıyor (rubbish → trash). |
| council | examples[1].en | "The council collects the rubbish every Tuesday." → "The council will discuss the new bus lanes on Tuesday." | 'The council collects the rubbish' İngiliz kullanımı (ABD'de belediye meclisi çöp toplamaz); meclisin gerçek işi olan bir cümleyle değişti. |
| council | examples[1].tr | "Belediye çöpleri her salı topluyor." → "Belediye meclisi yeni otobüs şeritlerini salı günü görüşecek." | Yeni İngilizce cümlenin çevirisi. |
| mayor | examples[1].tr | "Sakinler mart ayında yeni bir belediye başkanı seçecek." → "Şehir halkı mart ayında yeni bir belediye başkanı seçecek." | Tek başına 'Sakinler' Türkçede eksik duruyor; seçim bağlamında doğal karşılık 'şehir halkı'. |
| **part_02.json** | | | |
| voter | quiz.cloze | "On election day, long queues of ______ waited outside the polling stations." → "On election day, long lines of ______ waited outside the polling stations." | Amerikan yazımı/kullanımı: queues → lines. |
| trend | grammar.pattern | "a trend towards/in sth; follow a trend" → "a trend toward/in sth; follow a trend" | Amerikan yazımı: towards → toward. |
| trend | examples[1].en | "There's a clear trend towards smaller families in big cities." → "There's a clear trend toward smaller families in big cities." | Amerikan yazımı: towards → toward. |
| resident | examples[2].tr | "Bazı sakinler sel yüzünden evlerini terk etmek zorunda kaldı." → "Bazı bölge sakinleri sel yüzünden evlerini terk etmek zorunda kaldı." | 'Bazı sakinler' tek başına 'sakin = sessiz' okumasına açık; 'bölge sakinleri' kalıbı doğal. |
| **part_03.json** | | | |
| elect | l1.tr.mistakes | "I elected the blue shirt. (1 madde)" → [] | 'I elected the blue shirt' Türk öğrencilerde bilinen bir hata değil (elect bu seviyede eşya için kullanılmıyor); uydurma hata silindi. Not, choose/select farkını zaten anlatıyor. |
| elect | quiz.distractors | ["voted", "decided", "stated"] → ["predicted", "decided", "stated"] | 'voted her as their first female mayor' konuşma dilinde duyulabiliyor ('She was voted mayor' doğru); ikinci doğru cevap riski. 'predicted her as' dilbilgisi olarak olmuyor. |
| reveal | examples[0].tr | "Sonunda sırrını açığa vurdu." → "Sonunda sırrını açıkladı." | 'Açığa vurmak' daha çok duygu için kullanılır; sır için doğal fiil 'açıklamak'. |
| reveal | quiz.cloze | "The investigation ______ that the minister had used public money for his holiday." → "The investigation ______ that the minister had used public money for his vacation." | Amerikan kullanımı: holiday → vacation. |
| **part_04.json** | | | |
| respond | examples[1].tr | "Hükümet sellere hızlı tepki verdi." → "Hükümet sellere hızla müdahale etti." | 'Sellere hızlı tepki verdi' duygusal tepki gibi okunuyor; hükümet bağlamında doğal fiil 'müdahale etmek'. |
| spread | examples[2].tr | "Biri okulun kapanacağı dedikodusunu yaydı." → "Biri okulun kapanacağı söylentisini yaydı." | 'Rumor' karşılığı 'söylenti'; 'dedikodu' (gossip) kişiler hakkında konuşmadır. |
| current | quiz.cloze | "The ______ mayor has been in office for six years." → "Leyla's ______ job is in a bank, but before that she was a teacher." | 'The actual mayor' (vekil değil asıl başkan) İngilizcede kurulabiliyordu; zaman karşıtlığı ('before that') yalnızca 'current'ı doğru bırakıyor, 'actual' tuzağı korunuyor. |
| current | quiz.distractors | ["actual", "recent", "modern"] → ["actual", "former", "modern"] | Yeni cümlede 'recent job is' doğal değil ama sınırda; 'former' ise 'before that' ile açıkça çelişiyor. |
| **part_05.json** | | | |
| officially | l1.tr.note | "Bazen bir şeyin kâğıt üzerinde böyle olduğunu ama gerçekte farklı olduğunu anlatır: 'Officially he's on holiday, but he's still answering emails.'" → "Bazen bir şeyin kâğıt üzerinde böyle olduğunu ama gerçekte farklı olduğunu anlatır: 'Officially he's on vacation, but he's still answering emails.'" | Amerikan kullanımı: on holiday → on vacation. |
| increasingly | examples[1].en | "It's becoming increasingly difficult to find a cheap flat in the city." → "It's becoming increasingly difficult to find a cheap apartment in the city." | Amerikan kullanımı: flat → apartment. |
| worldwide | quiz.distractors | ["worldly", "officially", "equally"] → ["worldly", "officially", "nationally"] | 'spread equally' dilbilgisi olarak olabiliyor (eşit dağılmak); 'nationally' 'every continent' ile açıkça çelişiyor. |
| in favor of | def.short | "supporting a plan, idea or person; British spelling 'in favour of'" → "supporting a plan, idea or person, or agreeing with it" | Kısa tanım başlık kalıbı ('in favour of') içeriyordu. |
| in favor of | def.long | "Supporting or agreeing with a plan, idea or decision. It is often used for votes: '70% voted for the plan.' The British spelling is 'in favour of'." → "Supporting or agreeing with a plan, idea or decision. It is often used for votes, and its opposite is 'against'. The British spelling uses 'our'." | Tanımdaki örnek ('70% voted for the plan') kalıbı göstermiyordu ve başlık kalıbı tanımda geçiyordu. |
| on behalf of | l1.tr.alt | ["namına", "yerine"] → ["namına", "temsilen"] | 'yerine' instead of'un karşılığı; kartın confusable'ı da instead of olduğu için karışıklığı artırıyordu. |

## Anadili Türkçe birinin bakması gerekenler

1. **Hata maddeleri gerçek ve sık mı?**
   - citizen: "I am a Turkey citizen"
   - mayor: "He is the president of the municipality"
   - parliament: "The new law was accepted in the parliament"
   - affect: "The news affected on my decision"
   - campaign: "There is a big campaign at the supermarket"
2. **Kilit ekranı karşılıkları:**
   - resident: "sakin, oturan" (alternatif: "bölge sakini")
   - authority: "yetkili makam" (alternatif: "yetkililer")
   - make headlines: kısa anlam "manşete çıkmak"
   - in favor of: "-den yana"
   - call for: "çağrıda bulunmak"
3. **Türkçe cümleler:**
   - Değişti: respond, "Hükümet sellere hızla müdahale etti." ("respond" karşılığı olarak yeterli mi?)
   - Değişti: reveal, "Sonunda sırrını açıkladı."
   - Değişmedi: in favor of, "Cumartesi çalışmaktan yana değilim." ("Cumartesi çalışmaya karşıyım" daha mı doğal?)
4. **campaign `false_friend`:** Bu kısmi sahte dostun alanı boş. Destede apartman ve fabrika gibi kısmi sahte dostlarda alan dolu. Doğrulayıcının `FF_EQUIV` kuralı nedeniyle doldurulmadı; istenirse `equivalence: false_friend` ile doldurulabilir.
5. **Seviye:** yukarıda B1 olasılıklı diye sayılan kelimeler B2 destesinde kalsın mı?

## Çeldirici çeşitlendirme

`distractor_stats.py`: `s24: 60 quizzes, 137 distinct distractors; top: headline×4, minority×4, predicted×4, official×4, survey×3, major×3`. Sınır max(4, %5 = 3) = 4 aşılmıyor; değişen kart yok. 60 sorunun hepsi yeniden okundu, her şık boşluğa kondu ve her soruda tek doğru cevap kaldı. 43 farklı çeldirici başka bir s24 kartının başlığı ya da cevabı (ör. majority ↔ minority, mayor ↔ major); hepsi kendi cümlesinde açıkça yanlış.

`ipa_dress_stats.py`: `uk_e 0, uk_ɛ 11, us_e 0, us_ɛ 11`. DRESS sesi her yerde /ɛ/; düzeltme gerekmedi.

Başlık tekrarı (`dump_lemmas.py` ile karşılaştırma): yalnızca major başka akışta da var (s18, `en.major.n.1`, "ana dal"). s24'teki kart `en.major.adj.1`, "çok önemli, büyük" anlamında; farklı tür ve anlam olduğu için tekrar sayılmadı.

## Son doğrulama

`python -X utf8 -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s24` → `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı` (çeldirici ve IPA kontrolünden sonra, 2026-10-26)
