# s11 QA incelemesi (seyahat: havalimanı, uçuş, otel, yol sorma, toplu taşıma)

Kapsam: `content/drafts/kisisel_v1/s11/part_01.json` … `part_05.json` (45 kart). Süreç `docs/icerik_uretimi/README.md`'deki üç adımla yürüdü, araya bağımsız bir doğrulama turu eklendi:

1. **Yazım:** Üç yazar ajan (Sonnet) part'ları paralel yazdı: part_01–02, part_03–04 ve part_05.
2. **Denetim:** Her part'ı ayrı bir denetçi ajan (Opus) `2_denetci_kurallari.md`'ye göre kart kart düzeltti.
3. **Bağımsız doğrulama:** Üç şüpheci ajan (Opus) kartlara dokunmadan bütün akışı yeniden sınadı:
   - quiz: tek doğru cevap var mı;
   - Türkçe katman: geri çeviri, TDK yazımı, hatalar;
   - İngilizce katman: tanım, örnek, IPA, köken.

   Önerileri koordinatör (Opus) tek tek okuyup uyguladı. Bazı düzeltmeleri de kendisi ekledi (tabloda "editör").
4. **Çeldirici kontrolü:** `3_celdirici_kurallari.md`'ye göre bir Opus ajanı yaptı.

## Özet

- İncelenen kart: **45**
  - Seviye: A2 19 · B1 26.
  - Tür: 20 kelime, 13 collocation, 5 phrase, 7 phrasal verb.
- Denetimde değişen kart: **41**, hepsine `critic_edited` eklendi. Değişen alan: **108**.
- Bağımsız doğrulamada değişen kart: **23**, hepsine `verifier_edited` eklendi. Değişen alan: **36**.
- Hiç değişmeyen kart: **3** (reservation, tourist, How far is it).
- Reddedilen kart (`critic_reject`): **0**.
- Doğrulayıcı (tüm klasör, `--strict`): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`

## Kelime seçimi

- Liste, depoda var olan 754 başlık kelimeyle (`dump_lemmas.py`) karşılaştırılarak seçildi. Görevde örnek verilen bazı sözcükler başka akışlarda zaten vardı, bu yüzden yeniden yazılmadı:
  - luggage (s0);
  - delay, isim (s2);
  - round trip (s2);
  - check in (s4);
  - miss (s3; "fail to catch" anlamı "miss the flight"ı da kapsıyor).

  Yerlerine yakın ama yeni kartlar yazıldı: delayed (sıfat), suitcase, carry-on bag, baggage claim, boarding pass, direct flight.
- Genel kelimeler seyahat anlamıyla yazıldı: cancel, included, announcement, in advance, route, reception, terminal. s10, s12 ya da s13'te aynı kelime aynı `sense_no` ile çıkarsa derlemede id çakışmasına bakılmalı.

## Yazarın şüpheleri: kararlar

- **announcement:** "did an announcement" hatası kaldı. Bu, 'anons yapmak' kalıbından gelen do/make karışması. Anadil kontrolü listesinde.
- **overnight (sıfat), IPA:** Vurgu ilk heceye alındı: US /ˈoʊvərnaɪt/, UK /ˈəʊvənaɪt/. OALD ve LDOCE sıfatı böyle veriyor. Wiktionary vurguyu 'night' hecesine koyuyor; sözlükler ayrışıyor.
- **"Could you tell me the way to":**
  - IPA'da sıkışmış /kʊdʒə/ biçimi yerine /kʊdju ˌtɛl mi ðə ˈweɪ tə/ yazıldı. Sınır 26 karakter olduğu için "could you" bitişik yazıldı.
  - Quiz çeldiricileri "Could you say me", "Could you help" ve "How can I go". İkisi gerçek hata biçimi, biri nazik bir kalıp.
  - Cevap 28 karakter olduğu için uzunluğu ipucu veriyor. Çeldirici sınırı 16 karakter olduğundan bu kaçınılmaz.
- **show around quiz'i:** Edilgen cümle ("was shown around … by a colleague") kaldırıldı. Yeni cevap "show you around"; depodaki ilk zamirli quiz cevabı bu. Uygulama boşluğu seçilen şıkla doldurduğu için (`QuizCardView`, `filledSentence`) sorun çıkmaz.
- **part_05 çeldiricileri:** Yazar bilerek konu dışı şıklar seçmişti (cut down on, plug in, tearing up). Hepsi, cevapla aynı biçimde seyahat ve hareket phrasal verb'leriyle değiştirildi.
- **Etimolojiler:** 15 kartta var. Hepsi Wiktionary ve Etymonline ile karşılaştırıldı, halk etimolojisi yok. Dört kartın metni düzeltildi: passport, visa, terminal, announcement.
- **euro / avro:** Depodaki öteki akışlarda iki yazım da var: 'euro' 2 kez, 'avro' 1 kez geçiyor. Günlük dilde daha yaygın olduğu için s11'de 'euro' kaldı.

## Genel bulgular

- **Quiz:** En sık sorunlar buradaydı.
  - 13 kartta quiz cümlesi ilk örneğin neredeyse aynısıydı, soru ezberle çözülüyordu. Hepsine yeni cümle yazıldı.
  - Bazı çeldiriciler konu dışıydı ya da yalnızca dilbilgisiyle eleniyordu (tea bag, phone case, "a umbrella", "at boarding gate", cut down on).
  - İki kartta ikinci bir doğru cevap olabiliyordu: direct flight'ta "bus ticket", fare'de "seat".
  - Bağımsız doğrulamada 45 sorunun hepsi 4 şıkla yeniden sınandı; ikinci doğru cevap kalmadı.
  - Üç soruda cümledeki bir sözcük cevabı ele veriyordu (go straight: "Don't turn", lost and found: "lost", overnight: "at night"). Bunlar düzeltildi.
- **Tanımlar:**
  - departure ve arrival saati değil eylemi anlatacak biçimde yeniden yazıldı.
  - suitcase'teki yanıltıcı "flat" çıkarıldı.
  - security check artık yeri değil aramanın kendisini anlatıyor.
  - room service ve direct flight tanımları yerine konabilir hâle getirildi.
- **Türkçe:**
  - TDK düzeltmeleri: 'cuma' küçük harf, 'hava yolu' ayrı yazım.
  - land örneğinde çeviride kaybolan 'biz' bilgisi geri kondu.
  - reception kartında hitap tutarlı hâle getirildi (siz).
  - Doğallık düzeltmeleri: "yanlışlıkla bıraktım", "Terminal 2'den", "tatil yeri", "İndikten sonra", "İşarete göre", "bir gecelik yer", "İki sokak", "Kahvaltı dâhil", "evinin yolunu tuttu" ve diğerleri.
  - İngilizce sözcükten sonra ayrı yazılmış ek yok.
- **Notlardaki yanlış bilgiler düzeltildi:**
  - 'lost property' kaybolan eşyaların kendisi için de kullanılır;
  - "yer adından önce the gelir" kuralı şehir adlarında geçerli değil;
  - walking distance'ta standart edat "of";
  - route'un ABD'de /raʊt/ okunuşu da var;
  - 'land' fiili her zaman nesnesiz değil;
  - 'önceden', 'eskiden' anlamına da gelir, 'in advance' bu anlamı karşılamaz;
  - kaynaksız "head to ABD'de daha sık" iddiası çıkarıldı.
- **Yaygın hatalar:**
  - 3 gerçek hata eklendi: "two hand luggages", "Our flight delayed.", "got back to home".
  - Zorlama bir hata ("He showed around us the town"), en yaygın biçimiyle değiştirildi: "Can you show around me?".
  - Uydurma hata bulunmadı. Şu an 9 kartta 10 hata var.
- **IPA:**
  - overnight'ta sıfat vurgusu düzeltildi.
  - rent a car ve "Could you tell me the way to" kalıplarında çift ana vurgu vardı; depo geleneğine göre ˌ…ˈ yapıldı.
  - DRESS ünlüsü her yerde /ɛ/ (`ipa_dress_stats.py`: s11'de /e/ = 0).
- **İsimler:** Çeşitlilik orta düzeyde. 135 örnekte Ayşe 9, Mehmet 9, Maria 8, Elif 7, Kenji 7, Sam 3, Emre 1 kez geçiyor. Sonraki akışlarda isim havuzu genişletilebilir.

## Değişiklik tablosu: denetim

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman. Bazı satırlar sonraki doğrulama turunda yeniden değişti; son hâl bir sonraki tablodadır.

### part_01: havalimanı ve uçuş

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.boarding_pass.phr.1 | quiz.distractors | hotel key, bus map, phone case → hotel key, bus map, seat belt | 'phone case' konu dışıydı. 'seat belt' akışta kart olan bir sözcük, cümledeki 'seat number' ile yanıltıcı bir benzerlik kuruyor ve cümlede açıkça yanlış. |
| en.passport.n.1 | examples[2].tr | Pasaportumu yanlışlıkla otelde unuttum. → Pasaportumu yanlışlıkla otelde bıraktım. | 'Yanlışlıkla unutmak' fazlalıklı bir söyleyiş; 'left … by mistake' tam karşılığı 'yanlışlıkla bıraktım'. |
| en.passport.n.1 | etymology.text | From French 'passeport', made from 'passer' (to pass) and 'port'. → From 15th-century French 'passeport', from 'passer' (to pass) and 'port'. Sources differ on whether 'port' meant a harbor or a way through. | 'port' açıklanmamıştı. Etymonline 'liman', Académie française 'geçit, yol' diyor; kaynaklar ayrıştığı için bu belirtildi. |
| en.passport.n.1 | quiz.distractors | suitcase, ticket, umbrella → suitcase, ticket, boarding pass | 'umbrella' konu dışıydı. Biniş kartında fotoğraf olmadığı için yeni şık açıkça yanlış. |
| en.passport_control.phr.1 | def.long | …look at your papers and decide if you can enter the country. … → …check your papers when you enter or leave a country. … | Pasaport kontrolü çıkışta da yapılır (Türkiye, Schengen; Longman da 'leave or enter' diyor). |
| en.passport_control.phr.1 | quiz.cloze | We stood in line at ______ and the officer stamped my passport. → When I arrived in London, an officer at ______ asked how long I was staying. | Cümledeki 'passport' sözcüğü cevabı ele veriyordu; soru sözcük eşleştirerek çözülebiliyordu. |
| en.passport_control.phr.1 | quiz.distractors | check-in, baggage claim, boarding gate → departures, baggage claim, duty-free | 'boarding gate' artikelsizdi ('at boarding gate'), anlamla değil dilbilgisiyle eleniyordu. Yeni cümlede 'check-in' otel girişi olarak okunabilirdi. Yeni şıkların hepsi artikelsiz kullanılan yer adları ve 'arrived' ile 'officer' bağlamında açıkça yanlış. |
| en.security_check.phr.1 | def.long | …and make sure you are safe before you go to your gate. … → …and make sure you are not carrying anything dangerous before you go to your gate. … | 'make sure you are safe' yolcunun kendi güvenliği gibi okunuyordu. |
| en.security_check.phr.1 | quiz.distractors | gift shop, ticket desk, waiting room → gift shop, ticket desk, baggage claim | 'at the waiting room' edat olarak bozuk (doğrusu 'in the waiting room'); şık dilbilgisiyle eleniyordu. |
| en.flight.n.1 | examples[1].tr | Ayşe'nin Cuma günü … → Ayşe'nin cuma günü … | TDK: belirli bir tarih bildirmeyen gün adı küçük harfle yazılır. |
| en.departure.n.1 | def.short | the time when a plane, train, or bus leaves a place → the act of leaving a place, especially by plane, train, or bus | Sözcük saati değil eylemi bildirir (kalkış); 'departure time' ifadesiyle de çelişiyordu. |
| en.departure.n.1 | def.long | The time when a plane, train, or bus leaves a place, or the act of going away. … → The act of leaving a place, especially when a plane, train, or bus starts its trip. … | Aynı neden. İkinci cümle değişmedi. |
| en.departure.n.1 | examples[1].en | Maria checked the departure time on her ticket. → Emre got to the airport two hours before departure. | İlk iki örneğin ikisi de 'departure time' idi. Yeni örnek sık kullanılan 'before departure' kalıbını gösteriyor; isim çeşitliliği de arttı. |
| en.departure.n.1 | examples[1].tr | Maria biletindeki kalkış saatine baktı. → Emre kalkıştan iki saat önce havalimanına vardı. | Yeni cümlenin çevirisi; kart sözcüğünün karşılığı ('kalkış') korundu. |
| en.departure.n.1 | quiz.cloze | The ______ of my train is at 8:15, so I must leave home before 7. → Our ______ is at 8:15, so we must leave home before 7. | 'The departure of my train is at …' yapay; 'Our departure is at …' doğal. Şıklar (platform, seat, station) yine açıkça yanlış. |
| en.arrival.n.1 | def.short | the time when a plane, train, or bus gets to a place → the act of getting to a place, especially at the end of a trip | departure ile aynı neden; tanım 'on arrival' kullanımına da uyuyor. |
| en.arrival.n.1 | def.long | The time when a plane, train, bus, or person gets to a place at the end of a trip. … → The act of getting to a place at the end of a trip, for example when a plane, train, or bus comes in. … | Aynı neden. İkinci cümle değişmedi. |
| en.arrival.n.1 | examples[2].en | Sam waited at the arrivals hall … → Sam waited in the arrivals hall … | Salon için doğal edat 'in'. |
| en.arrival.n.1 | quiz.distractors | lunch, school, birthday → lunch, school, breakfast | 'birthday time' kalıp değil; 'breakfast time' gerçek bir kalıp ve cümlede anlamca açıkça yanlış. |
| en.terminal.n.1 | examples[0].tr | Uçuşumuz 2 numaralı terminalden kalkıyor. → Uçuşumuz Terminal 2'den kalkıyor. | '2 numaralı terminal' çeviri gibi duruyor; tabelalarda ve konuşmada 'Terminal 2' denir. |
| en.terminal.n.1 | etymology.text | From Latin 'terminus', meaning an end or a limit. A terminal is a place where a line of travel ends. → From Latin 'terminalis' (of the end), from 'terminus' (end, limit). It meant a station at the end of a railway line before it meant an airport building. | İkinci cümle yorumdu ve havalimanı terminali için doğru değildi. Yerine doğrulanmış tarihçe kondu (Etymonline: demiryolu 1870, havayolu 1921; Wiktionary: Late Latin terminalis). |
| en.terminal.n.1 | l1.tr.note | Türkçede de 'terminal' denir, ama günlük konuşmada çoğu zaman otogar anlaşılır. … → Türkçede 'terminal' otogar için de kullanılır; İngilizcede otogara çoğu zaman 'bus station' denir. Havalimanında ise 'terminal', … | 'Çoğu zaman otogar anlaşılır' genellemesi yumuşatıldı; yararlı İngilizce karşılık eklendi. |
| en.announcement.n.1 | etymology.text | From the verb 'announce', which comes from Latin 'annuntiare' (to report) and 'nuntius' (a messenger). → From French 'annoncement'. The verb 'announce' goes back to Latin 'annuntiare', literally 'to bring news to', from 'nuntius' (a messenger). | 've' bağlacı iki ayrı kaynak varmış gibi okunuyordu. Fransızca aracı eklendi (Etymonline, Wiktionary). |
| en.announcement.n.1 | l1.tr.equivalence | partial → full | Bu anlam için 'anons' ve 'duyuru' tam karşılık. 'partial' Türkçede tek bir karşılık olmadığını gösterir; bu kart için yanlış. |
| en.announcement.n.1 | l1.tr.mistakes[0].wrong | The airport did an announcement about the gate. → They did an announcement about the gate change. | Cümle doğallaştırıldı; sınanan hata aynı (do/make). |
| en.announcement.n.1 | l1.tr.mistakes[0].right | The airport made an announcement about the gate. → They made an announcement about the gate change. | 'The airport made …' ve 'about the gate' doğal değil. |
| en.visa.n.1 | etymology.text | From Latin 'visa', meaning 'things seen', from 'videre' (to see). It shows that an official has seen your papers. → From French 'visa', from Latin 'charta visa' (a paper that has been seen), from 'videre' (to see). It first meant an official signature on a passport. | Fransızca aracı eksikti. Yorum cümlesinin yerine doğrulanmış ilk anlam kondu (1831; Etymonline ve Wiktionary). |
| en.visa.n.1 | quiz.distractors | map, hotel, umbrella → map, hotel, boarding pass | 'a umbrella' artikel hatası ipucu veriyordu ve şık konu dışıydı. |

### part_02: bagaj ve uçak yolculuğu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.carry_on_bag.phr.1 | l1.tr.alt | el bagajı → el bagajı, kabin bagajı | THY ve Pegasus'un resmî terimi 'kabin bagajı'; öğrenci bunu görecek. |
| en.carry_on_bag.phr.1 | l1.tr.note | Türkçede 'kabin çantası' ya da 'el bagajı' denir. İngiltere'de 'hand luggage' daha yaygındır. Büyük bavullar ise uçağın bagajına verilir. → Kısaca yalnızca 'a carry-on' demek de yaygındır; İngiltere'de ise daha çok 'hand luggage' kullanılır. Bagaja verdiğiniz büyük bavula 'checked bag' denir. | İlk cümle karşılığı tekrar ediyordu. Yerine işe yarar bilgi kondu: kısa 'a carry-on' ve karşıtı 'checked bag'. |
| en.carry_on_bag.phr.1 | l1.tr.mistakes | [] → I have two hand luggages. / I have two carry-on bags. / 'iki el bagajı' deriz; 'luggage' sayılamaz, sayarken 'carry-on bag' | Gerçek Türkçe hatası: sayılamayan isme çoğul eki (luggage kartındaki 'luggages' hatasıyla aynı). Eş anlamlı olarak 'hand luggage' verildiği için burada önemli. |
| en.carry_on_bag.phr.1 | quiz.distractors | checked bag, tea bag, trash bag → checked bag, seat belt, boarding gate | 'tea bag' ve 'trash bag' rastgeleydi ve bir şey sınamıyordu. Yeni şıklar havalimanı terimleri, 'kept my ___ with me on the plane' cümlesinde açıkça yanlış. 'baggage claim' seçilmedi, çünkü bagaj fişi gibi okunabilir. |
| en.suitcase.n.1 | def.micro | big flat bag for travel → big bag for clothes on trips | Bavul yassı (flat) değil; 'flat' A2 öğrencisini yanıltır. |
| en.suitcase.n.1 | def.short | a big flat bag with a handle … → a big bag with a handle … | Aynı neden. |
| en.suitcase.n.1 | def.long | A big, flat bag with … → A big bag with … | Aynı neden. |
| en.baggage_claim.phr.1 | l1.tr.alt | bagaj alma bölümü → bagaj alım alanı | İstanbul Havalimanı tabelaları 'Bagaj Alım' der (ör. 'Bagaj Alım Bandı 20A'). |
| en.baggage_claim.phr.1 | l1.tr.note | … dönen bir bantta gelir. → … dönen bir bantta (bagaj bandı) gelir. | Türkçede en çok kullanılan söz 'bagaj bandı' öğrenciye gösterildi. |
| en.seat_belt.phr.1 | examples[2].tr | Tabelaya göre artık … → İşarete göre artık … | Uçaktaki ışıklı kemer işaretine 'tabela' denmez. |
| en.seat_belt.phr.1 | l1.tr.alt | güvenlik kemeri, kemer → kemer | 'güvenlik kemeri' yaygın değil, aramada hep 'emniyet kemeri' çıkıyor. |
| en.direct_flight.phr.1 | def.long | … all the way to your final place. … → … all the way to the place you are going. … | 'your final place' doğal İngilizce değil. |
| en.direct_flight.phr.1 | l1.tr.note | Uçak değiştirmezsiniz. Günlük konuşmada aynı anlamda 'non-stop flight' sözü de kullanılır. → Günlük dilde 'non-stop flight' ile aynı anlamdadır. Havayolu dilinde ise 'direct flight' arada bir yere inebilir; yine de uçak değiştirmezsiniz. | Doğru ve işe yarar ayrım eklendi: biletinde 'direct, 1 stop' gören öğrenci şaşırmasın. |
| en.direct_flight.phr.1 | quiz.cloze | I want a ______ to Berlin, … → I want a ______ to London, … | 1. örnek 'direct flight to Berlin'; ezberle çözülmesin. |
| en.direct_flight.phr.1 | quiz.distractors | window seat, hotel room, bus ticket → window seat, round trip, hotel room | 'bus ticket' de olabiliyordu (otobüsle giden uçak değiştirmez). 'round trip' bilet türü, ama gerekçeye uymuyor. |
| en.land.v.1 | examples[2].tr | İnişten sonra Maria … → İndikten sonra Maria … | 'After we landed' fiil cümlesi; fiil kartında 'inmek' fiili görünsün. |
| en.land.v.1 | l1.tr.note | İngilizcede 'land' nesnesizdir → Bu anlamda nesne almaz | 'land' her zaman nesnesiz değil (pilot 'lands the plane'). |
| en.delayed.adj.1 | l1.tr.mistakes | [] → Our flight delayed. / Our flight was delayed. / 'gecikti' deriz; 'delay' geciktirmek demektir, 'was delayed' gerekir | Gerçek Türkçe hatası: nesnesiz 'gecikmek' ile geçişli 'delay' karışıyor. |
| en.delayed.adj.1 | quiz.cloze | Our plane is ______ because of the storm, so we are still at the airport. → The train is ______, so it will leave at 9:30, not at 8:00. | Eski cümle 1. ve 3. örneğin birleşimiydi. Yeni cümle anlamı sınıyor. 'canceled' bilerek şık yapılmadı (ertesi sefere kalma yorumu riskli). |
| en.delayed.adj.1 | quiz.distractors | cheap, clean, comfortable → early, direct, fast | Eski şıklar rastgeleydi. 'early' saatle çelişiyor; 'direct' ve 'fast' gerekçeye uymuyor. |
| en.cancel.v.1 | l1.tr.note | Türkçedeki 'iptal etmek' ile aynı anlamdadır. → İsim hâli ise iki ülkede de 'cancellation' (çift l) olur. | Dolgu cümle yerine doğru ve işe yarar yazım bilgisi kondu. |
| en.unpack.v.1 | def.long | … suitcase after a trip, and put them in their places. Most people unpack soon after they get home or to a hotel. → … suitcase and put them away, for example when you get home or to a hotel. | 'after a trip' ile otel örneği çelişiyordu; 'Most people…' doğrulanmamış bir genellemeydi. |
| en.overnight.adj.1 | ipa.us | /ˌoʊvərˈnaɪt/ → /ˈoʊvərnaɪt/ | Sıfat (isimden önce) ilk heceden vurgulanır (OALD sıfat, Oxford Pocket). |
| en.overnight.adj.1 | ipa.uk | /ˌəʊvəˈnaɪt/ → /ˈəʊvənaɪt/ | Aynı neden (OALD sıfat: /ˈəʊvənaɪt/). |
| en.overnight.adj.1 | l1.tr.note | (eklendi) Zarf olarak kullanılınca ('stay overnight' = geceyi geçirmek) vurgu 'night' hecesine geçer. | IPA değişince zarftaki farklı vurgu açıklandı. |

### part_03: otel ve rezervasyon

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.double_room.phr.1 | def.short | a hotel bedroom with a big bed for two people → a hotel bedroom for two people, usually with one big bed | 'Double room' her zaman tek büyük yataklı değil; def.long zaten "usually" diyor, kısa tanım kesin konuşuyordu. |
| en.double_room.phr.1 | l1.tr.note | … 'double room' geniş yataklıdır; … → … 'double room' genellikle tek geniş yataklıdır; … | Aynı neden; not mutlak bir bilgi veriyordu. |
| en.room_service.phr.1 | quiz.cloze | We are too tired to go out. Let's order ______ and have dinner in bed. → We were too tired to go out, so we ordered ______ and had dinner in bed. | 1. örnek "Let's order room service tonight." ile aynı kalıptı (ezber). Şıklar aynı kaldı, tek cevaplı. |
| en.fully_booked.phr.1 | l1.tr.alt | hiç yer yok → dolu | "hiç yer yok" bir cümle, sözlük karşılığı değil. Günlük dilde "Otel dolu" denir. |
| en.fully_booked.phr.1 | quiz.cloze | Sorry, we have no rooms. The hotel is ______ tonight. → There are no free tables on Saturday. The restaurant is ______. | 1. örnek "Sorry, the hotel is fully booked." ile neredeyse aynıydı. Yeni cümlede tanımdaki restoran bağlamı var. |
| en.fully_booked.phr.1 | quiz.distractors | half empty, almost empty, completely empty → half empty, almost empty, available | Üç "… empty" şıkkı cevabı tek "farklı" şık yapıyordu. 'available' karşıt anlamı sınıyor ve cümleyle açıkça çelişiyor. |
| en.included.adj.1 | quiz.cloze | The room costs 80 euros, and breakfast is ______ in the price. → Do we pay extra for breakfast, or is it ______? | 1. örnekteki "Breakfast is included" kalıbını, 3. örnekteki "X costs … euros, and lunch is included" yapısını tekrarlıyordu. Yeni cümle anlamı sınıyor (extra ↔ included). |
| en.included.adj.1 | quiz.distractors | cooked, served, missed → cooked, missed, delayed | Yeni cümlede "…or is it served?" tek başına doğal bir soru gibi okunabiliyor (kahvaltı veriliyor mu?). Riskli olduğu için 'delayed' ile değiştirildi. |
| en.in_advance.phr.1 | l1.tr.note | Türkçedeki 'önceden' ile aynı anlamdadır ve çoğunlukla cümlenin sonuna gelir: … Süreyle de kullanılır: 'a week in advance' = bir hafta önceden. → 'Önceden' demektir ama yalnızca 'bir şey olmadan önce' anlamında kullanılır ve çoğunlukla cümlenin sonuna gelir: book in advance. 'Eskiden' anlamındaki 'önceden' için 'before' ya da 'in the past' denir. | "Aynı anlamdadır" yanıltıcıydı. Türkçede 'önceden' 'eskiden' anlamına da gelir; 'in advance' gelmez. 'a week in advance' collocations'ta duruyor. |
| en.in_advance.phr.1 | quiz.cloze | The museum is very popular, so you should buy tickets ______. → This hotel is very popular in summer, so you should book a room ______. | 1. örnek "You can buy tickets in advance." ile aynı kalıptı (you + modal + buy tickets ___). |
| en.in_advance.phr.1 | quiz.distractors | on foot, by mistake, for a while → in the past, too late, by mistake | 'on foot' ve 'for a while' işlevsizdi. 'in the past', Türkçedeki 'önceden = eskiden' karışmasını sınıyor; 'too late' karşıt zaman. Üçü de "should" ile açıkça yanlış. |
| en.rent_a_car.phr.1 | ipa.us | /ˈrɛnt ə ˈkɑːr/ → /ˌrɛnt ə ˈkɑːr/ | İki ana vurgu vardı. Ana vurgu 'car'da; depodaki kalıp ifadelerle tutarlı hâle getirildi. |
| en.rent_a_car.phr.1 | ipa.uk | /ˈrɛnt ə ˈkɑː/ → /ˌrɛnt ə ˈkɑː/ | Aynı neden. |
| en.rent_a_car.phr.1 | l1.tr.note | … Arabayı kiraya vermek için 'rent out' denir. İngiltere'de 'hire a car' da denir. → … kiraya vermek için 'rent out' denir. Türkçede 'rent a car' şirket adı gibi kullanılır; İngilizcede bu iş için çoğunlukla 'car rental' (İngiltere'de 'car hire') denir. | Son cümle eş anlamlılar listesini tekrarlıyordu. Onun yerine Türkçeye özgü gerçek bir fark yazıldı: Türkiye'de 'rent a car' isim gibi kullanılıyor, İngilizcede kiralama işi 'car rental'. |
| en.destination.n.1 | examples[1].tr | Paris popüler bir tatil destinasyonu. → Paris popüler bir tatil yeri. | 'tatil destinasyonu' turizm/reklam dili. A2 öğrenci için doğal karşılık 'tatil yeri' ('destinasyon' alt'ta ve notta duruyor). |
| en.destination.n.1 | quiz.cloze | After ten hours on the bus, we finally reached our ______. → Our flight stops in Istanbul, but our final ______ is Tokyo. | 1. örnek "We reached our destination at midnight." ile aynı kalıptı. Yeni cümle notta anlatılan 'final destination'ı sınıyor. |
| en.destination.n.1 | quiz.distractors | passport, ticket, visa → departure, journey, timetable | Belge adları yer adı olmadığı için hiçbir şey sınamıyordu (passport/ticket akışta 3'er kez geçiyordu). Yenileri yolculuk isimleri: 'departure' başlangıç ↔ varış farkını, 'journey' yolculuk ↔ varılan yer farkını sınıyor. |

### part_04: yol sorma ve toplu taşıma

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.could_you_tell_me_the_way_to.phr.1 | ipa.us, ipa.uk | /kʊdʒə ˈtɛl mi ðə ˈweɪ tə/ → /kʊdju ˈtɛl mi ðə ˈweɪ tə/ | Sıkışmış hızlı konuşma biçimi (couldja) "you" sözcüğünü gizliyordu ve yalnızca karakter sınırı yüzünden seçilmişti. Dikkatli biçim, "could you" bitişik yazılarak 26 karaktere sığdı. |
| en.could_you_tell_me_the_way_to.phr.1 | l1.tr.note | "Türkçede yer adına '-e' eki gelir (müzeye)… Yer adından önce çoğu zaman 'the' gelir. Kısa söylemek için…" → "Türkçede 'müzenin yolu' ya da 'müzeye giden yol' denir; İngilizcede 'of' değil 'to' kullanılır: the way to the museum. Kısaca 'How do I get to…?' diye de sorulur." | "Yer adından önce the" kuralı şehir adlarında yanlış. Gerçek Türkçe kaynaklı 'of' hatası ('istasyonun yolu' → the way of) eklendi. |
| en.could_you_tell_me_the_way_to.phr.1 | l1.tr.mistakes[0].why | "Türkçede artikel yoktur… yer adından önce çoğu zaman 'the' gerekir: the station, the museum." → "Türkçede 'the' karşılığı bir sözcük yoktur… 'station', 'museum' gibi sözcüklerin önüne genellikle 'the' gelir; şehir adlarına gelmez: the way to Izmir." | Aynı yanlış genelleme ("yer adı"). |
| en.could_you_tell_me_the_way_to.phr.1 | l1.tr.mistakes[1].why | "'Could you tell me' ile başlayan nazik sorularda düz cümle sırası kullanılır…" → "Türkçede soruyu olduğu gibi söyleyebiliriz: 'İstasyon nerede, söyler misiniz?' İngilizcede 'Could you tell me' sonrasında soru sırası değil, düz cümle sırası gelir…" | Eski açıklama kuralı veriyordu ama Türkçenin nasıl yanılttığını anlatmıyordu. |
| en.could_you_tell_me_the_way_to.phr.1 | quiz.distractors | Could you say me, Could you open, Could you carry → Could you say me, Could you help, How can I go | "open" ve "carry" konu dışıydı. "Could you help" aynı kalıpta ve yolunu kaybeden birinin ilk söylediği söz. "How can I go" eksik 'to' hatasını sınıyor. "Could you say me" gerçek hata olduğu için kaldı. |
| en.go_straight.phr.1 | l1.tr.alt | doğru gitmek → düz gitmek, doğru gitmek | Yol tarifinde en sık duyulan "düz git" eksikti. |
| en.go_straight.phr.1 | quiz.cloze | "Don't turn here. ______ for two blocks and the bank…" → "Don't turn here. ______ for about 200 meters and the bank is on your left." | Boşluğun çevresi ilk örnekle aynıydı (Go straight for two blocks); soru ezberle çözülebiliyordu. |
| en.bus_stop.phr.1 | def.short | "a place by the road where a bus stops for people to get on or off" → "a place by the road where people get on and off a bus" | Kısa tanımda başlık sözcüğün ailesinden "stops" kullanılmıştı. |
| en.fare.n.1 | l1.tr.gloss | bilet ücreti → ulaşım ücreti | "bilet ücreti" taksiyi kapsamıyor ve konser ya da müze biletine genellemeye açık. 'fare' yalnızca yolculuk ücreti. |
| en.fare.n.1 | l1.tr.alt | ulaşım ücreti, yol parası → bilet ücreti, yol parası | gloss ile yer değiştirdi. |
| en.fare.n.1 | l1.tr.note | "Türkçede tek bir sözcüğü yoktur: 'bilet ücreti', 'taksi ücreti' denir. 'Fare' ödenen paradır…" → "Türkçede araca göre 'otobüs ücreti', 'taksi ücreti' denir. 'Fare' yolculuk için ödenen paradır… Konser ya da müze için 'fare' değil 'ticket price' denir…" | Yeni gloss ile uyumlu hâle geldi. Yanlış genellemeye ("concert fare") karşı uyarı eklendi. |
| en.fare.n.1 | quiz.cloze | "The bus ______ is two euros. I paid the driver with coins." → "How much is the train ______ to Berlin? I only have 20 euros." | Cümle ilk örneğin ("The bus fare is two euros.") birebir aynısıydı. |
| en.fare.n.1 | quiz.distractors | seat, stop, platform → route, stop, platform | "seat" doğru cevap olarak da okunabilir: "a seat on the train" koltuk ya da bilet bedeli demek olabilir, Avrupa'da ücretli koltuk ayırma da var. |
| en.route.n.1 | l1.tr.note | "Günlük Türkçede 'güzergâh' ya da 'rota' denir. 'Route' ile 'root' (kök) aynı okunur: /ruːt/." → "Türkçede 'güzergâh' ya da 'rota' denir. 'Route' çoğunlukla 'root' (kök) gibi okunur: /ruːt/. ABD'de 'raut' (/raʊt/) diye okuyanlar da vardır." | ABD'de yaygın olan /raʊt/ okunuşu eksikti. "güzergâh" günlük dilden çok resmî dile ait. |
| en.route.n.1 | quiz.cloze | "The bus ______ goes from the airport to the city center." → "The map on my phone shows the shortest ______ from the hotel to the beach." | İlk örnekle ("The bus route goes past the museum.") aynı kalıptaydı. |
| en.walking_distance.phr.1 | l1.tr.note | "…'within' ile kurulur ve yer adından önce 'of' ya da 'from' gelir…" → "…genellikle 'within' ile kurulur ve yerden önce 'of' gelir… Konuşmada 'It's walking distance from here' da denir." | 'within' zorunlu değil. Standart edat 'of'. |
| en.walking_distance.phr.1 | quiz.distractors | waiting time, opening hours, ticket price → waiting time, opening hours, driving distance | "ticket price" rastgele bir şıktı. "driving distance" aynı kalıpta; "we do not need a car" ile çeliştiği için açıkça yanlış ve anlamı sınıyor. |
| en.lost_and_found.phr.1 | l1.tr.note | "…İkisi de eşyanın kendisini değil, eşyaların saklandığı yeri anlatır." → "…'Lost and found' eşyaların saklandığı yeri anlatır; 'lost property' ise kaybolan eşyalar için de kullanılır." | Yanlış bilgi: 'lost property' kaybolan eşyaların kendisi için de kullanılır. |
| en.lost_and_found.phr.1 | quiz.cloze | "I left my bag on the train. I will ask at the ______." → "Ali lost his jacket at the airport. He went to the ______ to look for it." | İlk örnekle ("I left my phone on the train, so I called the lost and found.") neredeyse aynıydı. |
| en.go_past.phv.1 | quiz.cloze | "Don't stop at the bank. ______ it and turn left at the corner." → "You will see a school on your left. ______ it and take the next street on the right." | İlk örnekle ("Go past the bank and turn left.") neredeyse aynıydı. |
| en.go_past.phv.1 | quiz.distractors | Look after, Get over, Wait for → Go into, Wait for, Get over | "Look after" yol tarifiyle ilgisizdi. "Go into" aynı fiille edatı sınıyor. |
| en.get_back.phv.1 | l1.tr.mistakes | (boş) → wrong: We got back to home at midnight. / right: We got back home at midnight. / why: '-e' eki (eve) 'to' gibi çevrilir; 'home' önüne 'to' gelmez. | Türkçe konuşanlarda çok bilinen gerçek bir hata ('eve' → to home). Örnek 3 ve collocation'larda zaten 'get back home' var. |
| en.get_back.phv.1 | quiz.distractors | check in, sign up, stay up → check in, pack up, look around | "sign up" ve "stay up" yolculukla ilgisizdi. Yeni şıklar seyahat phrasal verb'leri ve 'home' ile açıkça yanlış. |

### part_05: seyahat phrasal verb'leri

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.see_off.phv.1 | quiz.distractors | cut down on, dress up, tidy up → set off, get off, pack up | Konudan uzak şıklar. Yenileri seyahat fiilleri ve "to ___ the players" içinde açıkça yanlış. set off ile see off karışıklığı sınanıyor. |
| en.see_off.phv.1 | l1.tr.mnemonic | 'See' görmek, 'off' uzaklaşmak gibidir: gidenin uzaklaşışını görürsün, yani uğurlarsın. → 'Off' burada 'kapalı' değil, ayrılıp gitmeyi anlatır: gideni yola çıkarken görürsün, yani uğurlarsın. | Eski çağrışım gevşek ve dolambaçlıydı. Yenisi 'off = kapalı' (turn off) alışkanlığına karşı işe yarar bir ipucu veriyor. |
| en.get_away.phv.1 | quiz.distractors | pay back, speed up, plug in → stay in, see off, break down | Rastgele şıklar. stay in (evde kalmak) 'at the beach' ile çelişiyor. see off nesnesiz olmaz. break down (bozulmak) anlamsız ve 'break = mola' tuzağını sınıyor. |
| en.get_around.phv.1 | quiz.cloze | Taxis are expensive here, but it is easy to ______ the city by bus. → Taxis are expensive here, so most people ______ the city by bus. | Eski cümle ilk örneğin ("It's easy to get around Istanbul by metro.") neredeyse aynısıydı. |
| en.get_around.phv.1 | quiz.distractors | give away, sort out, count on → get on, get away, show around | Konudan uzak şıklar. Yenileri aynı get/around ailesinden. "___ the city by bus" içinde hepsi yanlış: get away 'from' ister, show around kişi nesnesi ister. |
| en.show_around.phv.1 | examples[2].tr | Yeni öğrenciler pazartesi günü okulda gezdirildi. → Yeni öğrencilere pazartesi günü okul gezdirildi. | 'Tanıtmak için dolaştırmak' anlamında gezdirmek kişiyi -e, yeri -i ile alır (TDK: "Konuklara Ankara'yı gezdirdi"). Eski cümle 'okulun içinde dolaştırıldılar' gibi okunuyordu. |
| en.show_around.phv.1 | l1.tr.alt | gezdirip göstermek → etrafı göstermek | 'gezdirip göstermek' kalıplaşmış bir karşılık değil, açıklama gibi. "Sana etrafı göstereyim" = Let me show you around. |
| en.show_around.phv.1 | l1.tr.mistakes[0].wrong | He showed around us the town. → Can you show around me? | Eski hata zorlama bir yapıydı ve why ile uyuşmuyordu (zamir sonda değildi). Ayrılabilen fiillerin en yaygın zamir hatası kondu. |
| en.show_around.phv.1 | l1.tr.mistakes[0].right | He showed us around the town. → Can you show me around? | Yeni hata cümlesinin doğrusu. |
| en.show_around.phv.1 | quiz.cloze | On her first day, Maria was ______ the office by a colleague. → Welcome to Izmir! I'm free tomorrow, so I can ______ the city. | Edilgen + by yapısı A2 için ağırdı. Kişi ortaya girdiği için 'fiil + parçacık + isim' kalıbı bu fiilde doğal değil. En sık kalıp sınanıyor. |
| en.show_around.phv.1 | quiz.answer | shown around → show you around | Yeni cümleye uyan biçim. |
| en.show_around.phv.1 | quiz.distractors | mixed up, packed up, washed up → see you off, pick you up, drop you off | Aynı biçim (fiil + you + parçacık) ve misafir karşılama konusuna yakın. Hiçbiri doğrudan 'the city' alamaz; see you off 'Welcome' ile de çelişiyor. |
| en.head_for.phv.1 | l1.tr.note | …aynı anlamdadır; 'head to' Amerikan İngilizcesinde daha sık duyulur. → …aynı anlamdadır. Ev için edatsız da denir: 'Let's head home.' | Kaynaksız bölgesel sıklık iddiası çıkarıldı. Yerine doğru ve yararlı bir bilgi kondu: 'go home' gibi 'head home' da edatsız söylenir. |
| en.head_for.phv.1 | quiz.distractors | calling off, tearing up, giving out → getting off, setting off, getting away | Rastgele şıklar. Yenileri 'ayrılıp gitmek' anlamlı ve akla yatkın; ama hiçbiri doğrudan bir yer (the exit) alamaz. |

## Değişiklik tablosu: bağımsız doğrulama ve editör kararları

Bu turdaki 36 değişikliğin hepsi uygulandı; her birinde dosyadaki eski değer birebir kontrol edildi. Değişen 23 karta `verifier_edited` eklendi. "Editör" satırları, doğrulayıcıların isteğe bağlı önerilerinden koordinatörün seçip uyguladıklarıdır.

| Kart | Alan | Önce → Sonra | Neden | Kaynak |
|---|---|---|---|---|
| en.overnight.adj.1 | quiz.cloze | The ______ bus leaves at eleven at night and gets to Izmir early the next day. → The ______ bus leaves at 11 p.m. and gets to Izmir early the next day. | 'at night' cevaptaki 'night' ile eşleşiyor ve üç gündüz çeldiricisini (morning, afternoon, daytime) kelime düzeyinde eliyor. '11 p.m.' aynı anlamı verir, öğrencinin saati yorumlamasını ister; çeldiriciler yine açıkça yanlış. | quiz doğrulayıcısı |
| en.go_straight.phr.1 | quiz.distractors | Turn left, Turn right, Turn around → Turn left, Turn right, Cross the road | Cümledeki 'Don't turn here' üç 'Turn …' şıkkını yalnızca kelime eşleşmesiyle eliyor; cevap biçimi farklı tek şık olarak kendini ele veriyor. 'Cross the road' aynı türden bir yol tarifi; 'for about 200 meters' ile açıkça yanlış (karşıdan karşıya geçmek 200 metre sürmez). | quiz doğrulayıcısı |
| en.lost_and_found.phr.1 | quiz.cloze | Ali lost his jacket at the airport. He went to the ______ to look for it. → Ali left his jacket at the airport. He went to the ______ to look for it. | Cümledeki 'lost' cevabın ilk sözcüğüyle birebir aynı; öğrenci anlamı bilmeden kelime eşleştirerek seçebiliyor. 'left' (unutup bırakmak) anlamı korur, ipucunu kaldırır; post office / box office / tax office yine açıkça yanlış. | quiz doğrulayıcısı |
| en.go_straight.phr.1 | quiz.cloze | Don't turn here. ______ for about 200 meters and the bank is on your left. → The bank is on this street. ______ for about 200 meters and you'll see it on your left. | 'Don't turn here' cümlesi 'Turn …' şıklarını kelime eşleşmesiyle eliyordu. Yeni cümle aynı bilgiyi (bu sokakta, dönmeden) anlamla veriyor. | editör |
| en.direct_flight.phr.1 | l1.tr.note | Türkçede 'direkt uçuş' ya da 'aktarmasız uçuş' denir. Günlük dilde 'non-stop flight' ile aynı anlamdadır. Havayolu dilinde ise 'direct flight' arada bir yere inebilir; yine de uçak değiştirmezsiniz. → Türkçede 'direkt uçuş' ya da 'aktarmasız uçuş' denir. Günlük dilde 'non-stop flight' ile aynı anlamdadır. Havacılık dilinde ise 'direct flight' arada bir yere inebilir; yine de uçak değiştirmezsiniz. | TDK 'hava yolu' diye ayrı yazar; 'havayolu' sözlükte yok. Burada kastedilen sektör terimi olduğu için 'Havacılık dilinde' hem TDK'ye uygun hem doğal. | Türkçe doğrulayıcısı |
| en.land.v.1 | examples[2].tr | İndikten sonra Maria telefonunu açtı. → Biz indikten sonra Maria telefonunu açtı. | İngilizce 'After we landed': konuşan da uçakta. '-dikten sonra' kişi göstermediği için 'biz' bilgisi düşmüş, özne Maria gibi okunuyor. | Türkçe doğrulayıcısı |
| en.cancel.v.1 | examples[0].tr | Havayolu şirketi uçuşumu iptal etti. → Hava yolu şirketi uçuşumu iptal etti. | TDK yazımı: 'hava yolu' ayrı yazılır (GTS madde başı 'hava yolu'; 'havayolu' maddesi yok). | Türkçe doğrulayıcısı |
| en.reception.n.1 | examples[2].tr | Resepsiyon bütün gece açık, bu yüzden geç gelebilirsin. → Resepsiyon bütün gece açık, bu yüzden geç gelebilirsiniz. | Kart içinde hitap tutarsız: 1. örnek 'siz' (anahtarınızı bırakın), 3. örnek 'sen'. Cümle otelin konuğa verdiği bilgi gibi okunuyor; 'siz' bağlama da uyuyor. | Türkçe doğrulayıcısı |
| en.departure.n.1 | l1.tr.note | Havalimanında 'departures' kalkış, 'arrivals' geliş bölümüdür. 'Depart' fiili resmî bir sözcüktür; günlük konuşmada 'leave' denir. → Havalimanında 'departures' gidiş (kalkış), 'arrivals' geliş bölümüdür. 'Depart' fiili resmî bir sözcüktür; günlük konuşmada 'leave' denir. | Not iki ayrı çifti karıştırıyordu (kalkış/varış, gidiş/geliş); havalimanı tabelalarındaki gidiş/geliş çiftine bağlandı. | editör |
| en.arrival.n.1 | l1.tr.note | 'On arrival' varır varmaz anlamına gelir. Havalimanında 'arrivals' gelen yolcuların bölümüdür. Zıttı 'departure' (kalkış). → 'On arrival' varınca, varışta demektir. Havalimanında 'arrivals' gelen yolcuların bölümüdür. Zıttı 'departure' (kalkış). | 'Varır varmaz' dar kalıyordu; temel anlam 'varınca, varışta' (pay on arrival = varışta ödeme). | editör |
| en.visa.n.1 | l1.tr.note | Türkçedeki 'vize' ile aynı sözcüktür; İngilizcede son harf a olur: visa. Pasaporta damga ya da elektronik belge olabilir. → Türkçedeki 'vize' ile aynı sözcüktür; İngilizcede 'visa' yazılır, 'viza' gibi okunur. Pasaporta damga ya da elektronik belge olabilir. | Okunuş eklendi; Türk öğrenci sözcüğü 'vize' diye okuyabilir. | editör |
| en.overnight.adj.1 | examples[1].tr | Mehmet küçük bir otelde bir gecelik konaklama ayırttı. → Mehmet küçük bir otelde bir gecelik yer ayırttı. | 'konaklama ayırttı' çeviri kokuyordu. | editör |
| en.reception.n.1 | l1.tr.note | Türkçedeki 'resepsiyon' ile aynı yerdir. İngilizcede 'reception' ya da 'reception desk' denir; ABD'de çoğunlukla 'front desk' söylenir. → Türkçedeki 'resepsiyon' ile aynı sözcüktür. İngilizcede 'reception' ya da 'reception desk' denir; ABD'de çoğunlukla 'front desk' söylenir. | Bir sözcük için 'aynı yerdir' denmişti; öteki eş kökenli kartlarla aynı kalıp kullanıldı. | editör |
| en.included.adj.1 | examples[0].tr | Kahvaltı fiyata dâhil. → Kahvaltı dâhil. | 'fiyata' İngilizcede yok; otel dilindeki tam karşılık 'Kahvaltı dâhil.' | editör |
| en.go_straight.phr.1 | examples[0].tr | İki blok dümdüz git, sonra sola dön. → İki sokak dümdüz git, sonra sola dön. | Türkçe yol tarifinde 'blok' yerine 'sokak' denir. | editör |
| en.route.n.1 | examples[2].tr | Trafik yüzünden eve farklı bir güzergâhtan gittik. → Trafik yüzünden eve farklı bir yoldan gittik. | 'güzergâhtan gittik' günlük konuşmada resmî kalıyor; 'yol' alt'ta var, ilk iki örnek 'güzergâh' kullanıyor. | editör |
| en.get_away.phv.1 | examples[0].tr | Hafta sonu için bir yerlere kaçmam lazım. → Hafta sonu bir yerlere kaçmam lazım. | 'için' fazlalıktı (denetçi ve Türkçe doğrulayıcı ikisi de işaretledi). | editör |
| en.get_around.phv.1 | examples[1].tr | Şehirde arabasız dolaşabilir misin? → Şehirde arabasız dolaşılabilir mi? | İngilizcedeki 'you' genel anlamda; 'dolaşabilir misin' dinleyicinin kendi becerisini soruyor gibi okunuyordu. | editör |
| en.head_for.phv.1 | examples[2].tr | Yağmur başlayınca herkes eve doğru yöneldi. → Yağmur başlayınca herkes evinin yolunu tuttu. | 'eve doğru yöneldi' kitabi ve 'eve' sahnedeki belirli bir ev gibi okunuyordu; 'yolunu tutmak' head for'un doğal karşılığı. | editör |
| en.head_for.phv.1 | l1.tr.alt | yönelmek → yönelmek, yolunu tutmak | 3. örnekteki 'yolunu tutmak' karşılığı alt listesine eklendi. | editör |
| en.security_check.phr.1 | def.micro | where officers look in bags → search of bags at an airport | Tanım yeri (checkpoint) anlatıyor; başlık ve listedeki hedef anlam kontrolün kendisi (arama). 1. örnek 'The security check was quick today' yer tanımıyla okunmuyor ('the place was quick'). OALD 'security' maddesi: 'carried out security checks' (işlem); yer için 'security' denir. | İngilizce doğrulayıcısı |
| en.security_check.phr.1 | def.short | the place at an airport where officers look in your bags to keep people safe → a search of people and their bags at an airport, to keep everyone safe | Aynı neden: üç katman tek anlamı (kontrol/arama) anlatsın. Yer okuması ('wait at the security check', quiz) yine doğal kalıyor. 'güvenlik kontrolü / güvenlik araması' karşılıklarıyla da birebir örtüşüyor. | İngilizce doğrulayıcısı |
| en.security_check.phr.1 | def.long | The place at an airport where officers look in your bags and make sure you are not carrying anything dangerous before you go to your gate. You often put your bag, phone, and coat in a tray. → A search of people and their bags at an airport before they go to their gate, to make sure no one is carrying anything dangerous. You often put your bag, phone, and coat in a tray. | Aynı neden; ilk cümle yer yerine aramayı tanımlıyor, ikinci cümle (tepsi) korunuyor. Başlık sözcükleri (security, check) kullanılmadı. | İngilizce doğrulayıcısı |
| en.room_service.phr.1 | tags.flags | (boş) → uncountable | 'room service' sayılamaz isim (Longman: [uncountable]); kartın kendi notu da 'a/the olmadan kullanılır' diyor. Depoda aynı tür kalıplar işaretli (s2 'jet lag': uncountable). Bayrak eksik. | İngilizce doğrulayıcısı |
| en.see_off.phv.1 | def.long | To go to the airport or station with someone who is starting a trip, and say goodbye there. Put words like 'him' or 'me' in the middle: 'see her off'. → To go to the airport or station when someone is starting a trip, and say goodbye there. Put words like 'him' or 'me' in the middle: 'see her off'. | 'with someone' birlikte gitmeyi şart koşuyor; OALD (to go to a station, an airport… to say goodbye), Longman ve Collins Concise böyle bir koşul koymuyor. Kartın 2. örneği de çelişiyor: 'Ayşe came to the station to see me off' (Ayşe ayrı geliyor). Tek sözcük düzeltmesi. | İngilizce doğrulayıcısı |
| en.terminal.n.1 | def.micro | big part of an airport → building at an airport | 'big part of an airport' belirsizdi (pist, otopark); sense_note 'airport building'. | editör |
| en.announcement.n.1 | def.long | A message that someone says out loud to all the people in a place, such as an airport or a train station. It is often made through a speaker. → A message that someone says out loud to all the people in a place, such as an airport or a train station. It is often made over a loudspeaker. | Doğal kalıp 'over a loudspeaker'. | editör |
| en.direct_flight.phr.1 | def.short | a plane trip to a place where you do not have to change planes → a plane trip on which you do not have to change planes | 'where' yan cümlesi 'place' sözcüğüne bağlanıyordu; aktarmasız olan yer gibi okunuyordu. | editör |
| en.overnight.adj.1 | def.long | Used for something that lasts from the evening until the next morning, like a trip, a bus, or a stay in a hotel. An overnight flight leaves late and gets there early the next day. → Used for something that lasts from the evening until the next morning, like a trip, a bus ride, or a stay in a hotel. An overnight flight leaves late and gets there early the next day. | Otobüsün kendisi geceyi kapsayan bir şey değil; 'bus ride' doğru. | editör |
| en.double_room.phr.1 | collocations | book a double room, a double room for two, a double room with a view → book a double room, a double room for two nights, a double room with a view | 'a double room for two' bir totolojiydi (double zaten iki kişilik). | editör |
| en.room_service.phr.1 | def.short | when hotel workers bring food or drinks to your door → food and drinks that hotel workers bring to your door | Tanım yerine konabilir bir isim öbeği değildi ('order when hotel workers…'); yenisi 'order ___' içinde çalışıyor. | editör |
| en.room_service.phr.1 | def.long | When hotel workers bring food or drinks to your door. You order by phone, and the workers bring your meal to you. You usually pay more for it. → Food and drinks that hotel workers bring to your door. You order them by phone and eat in your room. You usually pay more for this. | Kısa tanımla aynı isim öbeği; ikinci cümledeki 'bring' tekrarı kaldırıldı. | editör |
| en.could_you_tell_me_the_way_to.phr.1 | ipa.us | /kʊdju ˈtɛl mi ðə ˈweɪ tə/ → /kʊdju ˌtɛl mi ðə ˈweɪ tə/ | İki ana vurgu vardı; depo geleneği ˌ…ˈ (never mind, rent a car). | editör |
| en.could_you_tell_me_the_way_to.phr.1 | ipa.uk | /kʊdju ˈtɛl mi ðə ˈweɪ tə/ → /kʊdju ˌtɛl mi ðə ˈweɪ tə/ | Aynı neden. | editör |
| en.go_straight.phr.1 | collocations | go straight ahead, go straight on, go straight for two blocks, go straight until the end → go straight ahead, go straight on, go straight for two blocks, go straight until the lights | 'until the end' yarım kalıyordu (neyin sonu?). | editör |
| en.fare.n.1 | def.micro | money paid for a ride → money paid to travel | Uçak için 'ride' doğal değil; kısa tanım uçağı da sayıyor. | editör |

## Sayılar

| | Sayı |
|---|---|
| Kart | 45 (A2 19 · B1 26) |
| Tür | 20 kelime · 13 collocation · 5 phrase · 7 phrasal verb |
| Denetimde değişen kart / alan | 41 / 108 |
| Doğrulamada değişen kart / alan | 23 / 36 |
| Hiç değişmeyen kart | 3 |
| Reddedilen kart | 0 |
| Etimolojisi olan kart | 15 |
| Hata (mistakes) içeren kart | 9 (10 hata) |
| Doğrulayıcı sonucu | 0 hata, 0 uyarı |

## Çeldirici çeşitlendirme (2026-10-21)

- Önce: 45 soru, 117 farklı çeldirici; en sık: suitcase×3, platform×3, seat belt×2, ticket×2, boarding pass×2, departures×2.
- Sonra: 45 soru, 117 farklı çeldirici; en sık: suitcase×3, platform×3, seat belt×2, ticket×2, boarding pass×2, departures×2. Doğrulayıcı sınırı (`QUIZ_DISTRACTOR_REPEAT`): 4.
- Çeldiricisi değişen kart: 0. Doğru cevaplar değişmedi.
- Cloze değişikliği: yok.
- En sık geçen çeldiriciler:
  - 3 soruda: suitcase (`en.passport.n.1`, `en.terminal.n.1`, `en.reservation.n.1`) ve platform (`en.departure.n.1`, `en.announcement.n.1`, `en.fare.n.1`).
  - 2 soruda (14 şık): baggage claim, board, boarding pass, departures, fly, hotel, pack up, passport, seat belt, stop, terminal, ticket, timetable, wallet.
  - Kalan 101 şık yalnızca bir soruda geçiyor.
- Değerlendirme:
  - Hedef baştan sağlanıyordu: en sık şık 3 soruda geçiyor, sınır 4. Bu yüzden çeşitlendirme gerekmedi.
  - Biçim: Her soruda şıklar cevapla aynı türde ve biçimde. İki sınır durum bilerek kaldı. `en.land.v.1` sorusundaki "take off" şıkkı phrasal verb, ama kart listesi buna izin veriyor ve şık zıt anlamı sınıyor. `en.walking_distance.phr.1` sorusundaki "opening hours" şıkkı çoğul, ama "within ______ of" kalıbı tekili de çoğulu da alıyor; şık dilbilgisiyle elenmiyor.
  - Tek doğru cevap: 135 şıkkın her biri boşluğa konup okundu; hiçbiri makul bir okumayla doğru olmuyor. Doğrulayıcının "zorlama okuma" dediği iki şık da kaldı: `en.passport_control.phr.1` sorusunda "baggage claim", `en.tourist.n.1` sorusunda "neighbor". Denenen yerine koymalar (customs, arrivals, student) ikinci bir doğru cevap yaratıyor.
  - Konu: Şıkların çoğu seyahatle ilgili. `en.arrival.n.1` (lunch, school, breakfast) ve `en.flight.n.1` (airport, hotel, terminal) şıkları konu dışı ya da farklı türden görünüyor. Bu bilinçli: yolculukla ilgili "… time" sözleri ya da olay isimleri ikinci bir doğru cevap yaratır.
- Doğrulayıcı (`--strict`): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`.

## Anadili Türkçe birinin bakması gerekenler

Önce bakılması iyi olanlar (karşılık ve hata kararları):

1. **en.carry_on_bag.phr.1 · gloss:** Birinci karşılık "kabin çantası" mı olmalı, yoksa "el bagajı" ya da "kabin bagajı" mı? "Kabin çantası" daha çok ürün adı gibi duruyor olabilir. Karşılık değişirse üç örneğin çevirisi de değişmeli.
2. **en.baggage_claim.phr.1 · gloss:** "bagaj teslim alma" yer adı olarak eksik duruyor olabilir. "bagaj alım alanı" (İstanbul Havalimanı tabelalarında "Bagaj Alım") daha doğal mı? Değişirse üç örnek de değişmeli.
3. **en.announcement.n.1 · mistakes[0]:** "They did an announcement…" hatası Türk öğrencilerde gerçekten sık mı? Mekanizma ('anons yapmak' → do) reservation kartındaki "I did a reservation" ile aynı.
4. **en.delayed.adj.1 · mistakes[0]:** "Our flight delayed." ('uçuşumuz gecikti' → be olmadan) sık mı?
5. **en.get_back.phv.1 · mistakes[0]:** "We got back to home" hatası. 'go to home' türü hatanın Türk öğrencilerde çok bilindiği düşünülüyor; yine de göz atılmalı.
6. **en.see_off.phv.1 ve en.show_around.phv.1 · mistakes[0].why:** Zamir yeri hatası ("I saw off him", "Can you show around me?") genel bir öğrenci hatası. Açıklamalar bunu "uğurlamak / gezdirmek tek fiil" benzetmesine bağlıyor. Bu açıklama inandırıcı mı?
7. **en.how_far_is_it.phr.1 ve en.go_past.phv.1 · mistakes:** İki kartın da listesi boş. "How much far is it?" ('ne kadar uzak') ve "We passed from the bank" ('önünden geçmek') gerçek ve sık hatalarsa eklenebilir.
8. **en.tourist.n.1 · mistakes:** "We visited many touristic places." eklensin mi? 'touristic' İngilizcede var ama seyrek kullanılıyor, bu yüzden hata olarak yazılmadı. Not alanı 'tourist attraction' karşılığını zaten veriyor.
9. **en.fare.n.1 · gloss:** "ulaşım ücreti" bütün araçları kapsıyor ama biraz resmî. "yol ücreti" daha mı iyi?

Çeviri ve doğallık soruları:

10. **en.passport.n.1 · examples[2].tr:** "Pasaportumu yanlışlıkla otelde bıraktım." doğal mı, yoksa "otelde unutmuşum" mu?
11. **en.departure.n.1:**
    - examples[1].tr: "kalkıştan iki saat önce" doğal mı, yoksa "uçuştan iki saat önce" mi?
    - note: Türk havalimanı tabelaları "Gidiş/Geliş" mi der, "Kalkış/Varış" mı?
12. **en.terminal.n.1:**
    - note: 'terminal' sözcüğünün otogar anlamında kullanıldığını söyleyen "otogar için de kullanılır" ifadesi doğru ve yeterince yumuşak mı?
    - examples[0].tr: "Terminal 2'den" mi doğal, "2. terminalden" mi?
13. **en.land.v.1 · examples[2].tr:** "Biz indikten sonra Maria telefonunu açtı." doğal mı? "biz" bilgisi koruma için eklendi.
14. **en.seat_belt.phr.1 · examples[2].tr:** "İşarete göre artık emniyet kemerlerimizi çıkarabiliriz." doğal mı?
15. **en.delayed.adj.1 · examples[0].tr:** "Uçuşumuz gecikmeli." tabela dili gibi. Günlük dilde "Uçağımız rötarlı." daha mı doğal?
16. **en.destination.n.1:**
    - examples[0].tr: "Gece yarısı varış noktamıza ulaştık." biraz resmî. "Gece yarısı gideceğimiz yere vardık." daha mı iyi?
    - alt: 'destinasyon' kalsın mı?
17. **en.go_straight.phr.1:**
    - alt: "doğru gitmek" belirsiz olabilir (doğru = correct).
    - Yol tariflerinde (go straight, go past) "sen" mi daha uygun, "siz" mi? Yol soran cümleler "siz" kullanıyor.
18. **en.could_you_tell_me_the_way_to.phr.1:**
    - mistakes[1].why: "İstasyon nerede, söyler misiniz?" kalıbı hatanın kaynağı olarak inandırıcı mı?
    - alt: "… giden yol hangisi?" yerine "… nasıl gidebilirim?" daha mı yaygın?
19. **en.head_for.phv.1 · examples[2].tr:** "Yağmur başlayınca herkes evinin yolunu tuttu." doğal mı?
20. **en.get_around.phv.1 · alt:** "gidip gelmek" 'işe gidip gelmek' gibi okunuyor. Bu anlam için yeterli mi?

Küçük sorular:

21. **Karşılık ve alt listeleri:**
    - en.fully_booked.phr.1: alt "dolu" yeterli mi, yoksa "yer kalmamış" mı?
    - en.double_room.phr.1: alt listesine "double oda" eklenmeli mi?
    - en.walking_distance.phr.1: alt "yürüyüş mesafesi" kalsın mı?
    - en.security_check.phr.1: alt "güvenlik araması" mı, "güvenlik taraması" mı?
    - en.overnight.adj.1: alt "gece" tek başına anlaşılır mı?
    - en.unpack.v.1: alt "bavulu açmak" uygun mu?
    - en.show_around.phv.1: alt "etrafı göstermek" uygun mu?
    - en.boarding_pass.phr.1: alt "uçağa biniş kartı" gereksiz mi?
22. **Notlar:**
    - en.in_advance.phr.1: 'önceden / eskiden' ayrımını anlatan not açık mı?
    - en.rent_a_car.phr.1: "Türkçede 'rent a car' şirket adı gibi kullanılır" ifadesi doğal mı?
23. **Mnemonic'ler (insan onayı ister):**
    - en.see_off.phv.1: "'Off' burada 'kapalı' değil…"
    - en.head_for.phv.1: "'Head' baş demektir…"
    - en.land.v.1: "'Land' kara demektir…"
24. **A2 öğrencisi bu quiz cümlelerini anlar mı?**
    - en.lost_and_found.phr.1: "Ali left his jacket at the airport." cümlesindeki 'left' "bıraktı" diye mi anlaşılır?
    - en.overnight.adj.1: "11 p.m."
    - en.go_straight.phr.1: "Cross the road" şıkkı.

## Hafıza ipuçları ve denetim (2026-10-22)

- **Hafıza ipucu:** yazar ajan 8 ipucu önerdi. Şüpheci doğrulayıcı 0 tanesini reddetti, 0 tanesini küçük düzeltmeyle kabul etti. **Eklenen: 8** (`meta.qa_flags`: `mnemonic_added`).
- **Düzeltme:** yok. Yazar bütün kartlarda çevirileri, Dikkat kutularını ve quiz şıklarını tek tek denedi; bariz bir hata bulmadı.
- Yalnızca A1/A2 kartlarına ipucu eklendi. `id`, `lemma`, anlam, `gloss`, `def` ve IPA değişmedi.
- Doğrulayıcı: `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`

### Eklenen hafıza ipuçları

| Kart | İpucu |
|---|---|
| en.suitcase.n.1 | 'Suit' takım elbise, 'case' kutu ya da kılıf demek: takım elbiseni koyup taşıdığın kutu, yani bavul. |
| en.boarding_pass.phr.1 | 'Board' uçağa binmek demek: kapıda 'Now boarding' anonsunu duyunca biniş başlar. 'Boarding pass' bu binişin kartı. |
| en.flight.n.1 | 'Fly' (uçmak) fiilinden gelir. İçindeki 'gh' okunmaz: 'night', 'light' gibi 'flayt' denir. |
| en.cancel.v.1 | Latince kökü 'üstünü çapraz çizgilerle çizmek' demek: takvimdeki planının üstüne kocaman bir çarpı attığını düşün. |
| en.unpack.v.1 | 'Un-' bir işi tersine çevirir: 'lock' kilitle, 'unlock' kilidi aç; 'pack' bavulu doldur, 'unpack' bavulu boşalt. |
| en.double_room.phr.1 | 'Twin' ikiz demek: 'twin room' içinde ikizler gibi yan yana iki ayrı yatak var. 'Double room' içinde tek büyük yatak. |
| en.go_straight.phr.1 | 'Straight' kelimesinde 'gh' okunmaz, 'streyt' denir. Düz saça da 'straight hair' denir: yol da o saç gibi dümdüz. |
| en.go_past.phv.1 | Saatte 'ten past five' (beşi on geçiyor) derken kullanılan 'past' bu: 'go past the bank' bankayı geçip gitmek. |
