# s15 QA incelemesi (alışveriş ve para)

Kapsam: `content/drafts/kisisel_v1/s15/part_01.json` … `part_05.json` (45 kart). Konu: mağaza, fiyat ve pazarlık, ödeme ve iade, banka ve bütçe, internetten sipariş. Seviye A2–B1.

## Süreç

`docs/icerik_uretimi/README.md`'deki üç adım; bütün ajanlar Opus (orta çaba):

1. **Yazım:** 5 yazar ajanı, part başına bir ajan (`1_yazar_kurallari.md`). Önce `dump_lemmas.py` ile var olan 934 başlık kelime çıkarıldı ve yazarlara verildi.
2. **Denetim:** 5 denetçi ajanı, part başına bir ajan (`2_denetci_kurallari.md`, `SYSTEM_C`). Yazarların "emin olmadığım" maddeleri her denetçiye ayrıca verildi.
3. **Bağımsız doğrulama:** Kartları değiştirmeyen 3 doğrulayıcı bütün akışı okudu: (a) quiz'de tek doğru cevap, (b) Türkçe katman (geri çeviri, gloss, not, hata), (c) İngilizce içerik, IPA ve üstveri. Koordinatör bulguları tartıp uyguladı.
4. **Çeldirici kontrolü:** `3_celdirici_kurallari.md` (aşağıda ayrı bölüm).
5. **Son kontrol:** Doğrulamadan sonra değişen bütün alanları ayrı bir doğrulayıcı yeniden okudu.

## Özet

- İncelenen kart: **45** (A2: 16, B1: 29)
- Tür: 22 kelime (`word`), 10 eşdizim (`collocation`), 6 kalıp (`phrase`), 6 phrasal verb, 1 deyim (`idiom`)
- `primary_topic`: 45 kartın hepsi `shopping_money` (A1–B2 aralığı; LEVEL_RANGE uyarısı yok)
- Değişen kart: **43** (`critic_edited`); reddedilen kart (`critic_reject`): **0**
- Toplam düzenleme (alan): **155** (denetçiler 82, koordinatör ve bağımsız doğrulama 72, çeldirici adımı 1)
- Doğrulayıcı (tüm klasör, `--strict`): `45 kart · 45 şemadan geçti · 0 hata · 0 uyarı`
- Çeldirici: en sık şık 3 soruda (receipt, borrow, lend); sınır 4.

## Kelime seçimi

- Görev tanımındaki örneklerin çoğu başka akışlarda zaten vardı ve aynı anlamla tekrar yazılmadı: `receipt`, `refund`, `discount`, `afford`, `cash` (`pay in cash` dahil), `sale` (`on sale` dahil) s1'de; `try on` s4'te. Bunların yerine aynı alanda olup henüz olmayan kelimeler seçildi: `for sale` ("on sale" ile karşıtlığı notta), `cash or card`, `out of stock`, `save up`.
- s1'deki alışveriş kartları (price, pay, wallet, change, bill, delivery, save, bargain, budget, groceries, parcel, queue…) ve s4'teki alışveriş phrasal verb'leri (take back, top up, pay back, sell out, check out) dışarıda bırakıldı. Örnek cümleleri de kopyalanmadı; denetimde benzer bulunan 4 cümle değiştirildi (`bank account` ↔ s3 `salary`, `save up` ↔ s1 `save`, `shipping` ↔ s1 `delivery` iki kez).
- Aynı lemmanın başka anlamı: `en.return.v.2` (mağazaya iade etmek) s6'daki `en.return.v.1` (geri dönmek) kartından ayrı bir kart.
- Aynı anda yazılan s14 (ev) ve s16 (zaman, hava, doğa) için s15 kelime listesi ortak not klasörüne yazıldı.
- Akışlar arası tarama (s0–s13 ve commit öncesi s14/s16 worktree'lerindeki 45'er taslak kart): kimlik, lemma, `def.short`, örnek cümle ve quiz cümlesi çakışması yok. s14'teki `for rent` ile s15'teki `for sale` ayrı lemmalar ve birbirini tamamlıyor.

## Genel bulgular

- Kartların çoğu ilk yazımda sağlamdı: anlamlar doğru, ilk örnekler kısa ve kilit ekranına uygun, etimolojiler (11 kart) doğrulandı, sahte dost alanı hiçbirinde dolu değil (doğru; `cargo/kargo` tuzağı `shipping` kartında hata ve not olarak anlatılıyor).
- **En sık 3 sorun:**
  1. **US IPA tutarsızlığı:** Beş yazar r'li ünlüleri farklı yazmıştı (`ɔr`, `ɝ`, `ɔːr`). Hepsi depo geleneğine (`ɔːr / ɑːr / ɜːr`, `hour` = `aʊər`) çekildi; kalıplardaki çift ana vurgu ikincil + ana vurgu yapıldı. DRESS ünlüsü her yerde `/ɛ/`.
  2. **Quiz:** İkinci doğru cevap veren 1 şık bulundu (`rip off`: "pick up tourists") ve değiştirildi. Bazı sorular başlık ifadeyi sınamıyordu: `cash or card` yalnızca "card"ı, `cost an arm and a leg` yalnızca "leg"i soruyordu; ikisinde de boşluk ifadenin tamamı yapıldı. Hiç ilgisiz çeldiriciler (dentist, farmer, napkin/spoon/chair, proud…) aynı sahneden ama o cümlede açıkça yanlış şıklarla değiştirildi.
  3. **Türkçe doğallık:** Çeviri kokan cümleler ("borç para almayı sevmiyor" → "borçlanmayı sevmiyor"; "herkesin yerine ödemek" → "herkesin hesabını ödemek"; "ateş pahasına mal oldu" → "pahalıya patladı") ve açıklama gibi duran gloss/alt'lar düzeltildi. Kullanıcıya görünen notlardaki iç atıflar ("s4'teki kart", "ayrı bir karttır") kaldırıldı.
- **Yaygın hata (mistakes):** 7 kartta var: worth ("It worths", "It doesn't worth it"), loan ("took a credit"), exchange ("exchange it with"), complain ("complain from"), place an order ("gave an order"), track ("following my order"), shipping ("the cargo"). Üç doğrulayıcı katmanında da gerçek bulundu. Emin olunamayan iki hata çıkarıldı: brand "What mark is your phone?" (denetçi kaldırdı) ve withdraw "pull money" (denetçi ekledi; Türkçe doğrulayıcı yaygınlığından emin olmadı, Türklerin daha çok söylediği "draw money" İngilizcede doğru sayıldığı için koordinatör kaldırdı).
- **Gerçekçilik:** 2026 fiyatlarına göre çok düşük kalan tutarlar yükseltildi (owe 20 → 200 lira, tip 10 → 50 lira, halı 1.500 → 6.000 lira). `go up` sorusundaki benzin fiyatı yerine ekmek fiyatı kondu ("litre/liter" yazım farkı da böylece ortadan kalktı).

## Koordinatörün denetçi kararlarını değiştirdiği yerler

- `value for money` gloss: denetçi "fiyat/performansı iyi" yapmıştı; Türkçe doğrulayıcının önerisiyle "fiyatına göre iyi" oldu ("fiyat/performans" alt'ta ve notta duruyor). İlk örnek: "Bu otel ödediğin paranın karşılığını veriyor."
- `worth` gloss: "değerinde, değer" → "değerinde" (alt: değmek, değer). Tek gloss; "It's worth 50 lira" = "50 lira değerinde".
- `withdraw` mistakes: denetçinin eklediği "pull money" hatası kaldırıldı (yukarıda).
- `go up` quiz: "A loaf of bread was 15 lira last month. Now it is 20. The price ______ last week." (benzin cümlesinde fiyat düşüktü ve "litre" UK yazımıydı).
- `cost an arm and a leg` quiz: boşluk deyimin tamamı oldu (cevap "costs an arm and a leg"; çeldiriciler "costs nothing", "is very cheap", "is on the house").

## Değişiklik tablosu

Denetçi tabloları denetim anındaki değişiklikleri gösterir. Sonra aynı alanda yapılan değişiklikler koordinatör tablosunda.

### Denetim: part_01

- İncelenen kart: **10** · değişen kart: **8** · değişen alan: **14** · reddedilen: **0**
- Doğrulayıcı (`--strict`, part_01): `10 kart · 10 şemadan geçti · 0 hata · 0 uyarı`
- Seviye değişmedi (checkout ve out of stock B1, diğerleri A2).

**Genel bulgular**
- Kartlar genel olarak sağlamdı: anlamlar, tanımlar ve ilk örnekler doğru, kilit ekranına uygun. s1/s4 kartlarıyla kopya örnek cümle yok.
- Kullanıcıya görünen notlarda iç depo atıfları vardı ("s4'teki 'check out'", "s1'deki 'sale' kartı"). Öğrenci s1 ya da s4'ü bilmiyor; üç notta atıf kaldırıldı.
- `for sale` 3. örneğinde Türkçe isim "Can" cümle başında modal fiil gibi okunuyordu ("Can put his old car…"). İsim Emre yapıldı.
- Quiz'ler tek cevaplıydı; bazı çeldiriciler cümleyle hiç ilgisizdi (dentist/farmer). Aynı işlevden ama o cümlede açıkça yanlış olan şıklarla değiştirildi.
- `for sale` US IPA'sında 'for' güçlü yazılmıştı, UK'de zayıftı. Depodaki geleneğe (s8 `for a while` /fər/) uyuldu.

**Yazar şüphelerine kararlar**
1. **brand mistakes:** Silindi (liste boş). "What mark is your phone?" Türk öğrencilerin yaygın hatası olarak belgeli değil; 'brand' Türkçede de pazarlama dilinde dolaşıyor. `right` biçimi ("What brand is your phone?") doğruydu. Not zaten 'mark' ile 'marka' farkını anlattığı için uyarı kartta kalıyor.
2. **cashier etimolojisi:** Doğru, kaldı (medium). İngilizce cashier, Fransızca caissier ← caisse (para kutusu) ← Provençal/Latince capsa; Türkçe kasa İtalyanca cassa üzerinden aynı Latince capsa'ya gidiyor. Metne İtalyanca ara halka ve 'cash' ile ortak kök eklendi. (Etymonline bir de Felemenkçe 'kassier' ihtimalini anıyor, bu yüzden high'a çıkarılmadı.)
3. **IPA:** checkout /ˈtʃɛkaʊt/ (US ve UK) doğru. fitting room /ˈfɪtɪŋ ruːm/ doğru ve depo geleneğiyle (waiting room, double room) tutarlı. Değişiklik yok.
4. **Quiz tek cevap:** shop assistant: "cashier" şıklarda yok, tek cevap. "dentist" → "waiter" (hizmet işi, mağazada yok). for sale: "for rent" yok; out of order / on time / in stock bir daireye uymuyor. Değişiklik yok. I'll take it: "Excuse me" → "I'm just looking" (aynı mağaza işlevinde, "It's perfect" ile çelişiyor). "I'll think about it" gibi olabilecek şıklardan kaçınıldı.
5. **Türkçe:** "alıyorum" gloss'u mağazada söylenen doğal karşılık, kaldı. "ödeme adımına hiç geçmedim" e-ticaret Türkçesinde doğal, kaldı. basket ve checkout'ta `technology_internet` ikincil konu olarak uygun (iki tanımda da internet anlamı var), kaldı.

**Değişiklik tablosu**

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.cashier.n.1 | etymology.text | From French 'caissier', from 'caisse' (money box). Turkish 'kasa' comes from the same Latin word 'capsa' (box). → …from 'caisse' (money box); 'cash' has the same root. Turkish 'kasa' (from Italian 'cassa') also goes back to Latin 'capsa' (box). | Kasa'nın İtalyanca üzerinden geldiği belirtildi; cash bağlantısı eklendi. |
| en.cashier.n.1 | quiz.distractors | waiter, dentist, farmer → waiter, customer, dentist | 'farmer' ilgisizdi; 'customer' süpermarket bağlamında ama 'scanned my milk' ile açıkça yanlış. |
| en.checkout.n.1 | l1.tr.note | "…s4'teki 'check out' ise iki kelimelik bir fiildir…" → "Ayrı yazılan 'check out' ise fiildir: otelden çıkış yapmak ya da bir şeye göz atmak…" | Kullanıcıya iç depo atfı görünüyordu. |
| en.shop_assistant.phr.1 | quiz.distractors | bus driver, tour guide, dentist → bus driver, waiter, tour guide | Daha yakın hizmet işi; 'cashier' bilerek dışarıda. |
| en.fitting_room.phr.1 | examples[2].en | You can take only five things… → You can only take five things… | Daha doğal sözcük sırası. |
| en.fitting_room.phr.1 | examples[2].tr | …beş parça götürebilirsin. → …beş parça alabilirsin. | Mağazada 'kabine … alabilirsin' denir. |
| en.ill_take_it.phr.1 | examples[2].tr | …o yüzden bunu alıyorum. → …o yüzden alıyorum. | Ceketten söz edilirken 'bunu' fazlalık; İngilizcedeki 'it' Türkçede düşer. |
| en.ill_take_it.phr.1 | quiz.distractors | No, thanks / Never mind / Excuse me → No, thanks / Never mind / I'm just looking | Aynı işlevde (mağazada müşteri cevabı), 'It's perfect' ile çelişen şık. |
| en.brand.n.1 | l1.tr.mistakes | [What mark is your phone? → What brand…] → [] | Yaygın gerçek Türk öğrenci hatası olarak doğrulanamadı; not uyarıyı zaten taşıyor. |
| en.for_sale.phr.1 | ipa.us | /fɔːr ˈseɪl/ → /fər ˈseɪl/ | Vurgusuz 'for' zayıf; UK ve s8 `for a while` ile tutarlı. |
| en.for_sale.phr.1 | examples[2].en | Can put his old car up for sale… → Emre put his old car up for sale… | 'Can' isim olarak modal fiil gibi okunuyordu. |
| en.for_sale.phr.1 | examples[2].tr | Can geçen hafta… → Emre geçen hafta… | İsim değişikliğine uyum. |
| en.for_sale.phr.1 | l1.tr.note | "…(s1'deki 'sale' kartı)…" → atıf kaldırıldı | İç depo atfı. |
| en.out_of_stock.phr.1 | l1.tr.note | "s4'teki 'sell out' bir fiildir" → "'sell out' bir fiildir" | İç depo atfı. |

### Denetim: part_02

- İncelenen kart: **10** (worth, value for money, cost an arm and a leg, go up, come to, rip off, haggle, shop around, waste of money, discount code)
- Değişen kart: **9** (`shop around` dışında hepsi; `critic_edited` eklendi)
- Değişen alan: **27**
- Reddedilen: **0**
- Doğrulayıcı (`--strict`, part_02): `10 kart · 10 şemadan geçti · 0 hata · 0 uyarı`

**Genel bulgular**
- Kartlar genel olarak sağlam: anlamlar doğru, ilk örnekler kısa ve güvenli, etimoloji yalnızca `worth`ta (Old English weorþ / Almanca wert, doğru). s1 (price, cost, discount, bargain, cheap, expensive) ve s4 kartlarıyla kopya örnek yok. Seviyeler değişmedi.
- **IPA:** Kalıplarda iki ana vurgu vardı (`value for money`, `waste of money`), depo geleneğine göre ilk vurgu ikincil (ˌ) yapıldı. `leg` DRESS ünlüsü `/e/` → `/ɛ/`. `come to` içindeki 'to' her zaman nesne aldığı için zayıf `/tə/` (s13 `look up to` geleneği).
- **Türkçe:** Birkaç çeviri düz ya da kalıba uymuyordu ('biletler dudak uçuklatıyordu', 'ateş pahasına mal oldu', 'boşa giden para oldu', 'yüzde 15 tasarruf etti'). `waste of money` gloss'u ünlemdi ('paraya yazık'); isim karşılığı 'para israfı' gloss yapıldı. `worth` gloss'u 'değer' tek başına isim (value) gibi okunuyordu.
- **Quiz:** Tek-cevap ihlali yok denecek kadar azdı. `rip off` sorusundaki "pick up" (tourists) dilbilgisi ve anlam olarak olabilirdi, değiştirildi. `go up` bağlamı sayılarla netleştirildi.

**Yazar şüphelerine kararlar**
1. **worth hataları:** İkisi de kaldı. "It worths…" ve "It doesn't worth it" Türk öğrencilerde çok sık görülen hatalar ('değer / değmez' Türkçede fiil). İki `why` da doğru. Gloss 'değerinde, değer' yapıldı.
2. **IPA:** `cost an arm and a leg` vurgu dağılımı doğru (arm ikincil, leg birincil); yalnızca `leg` ünlüsü `/ɛ/` yapıldı. `come to` `/ˈkʌm tuː/` → `/ˈkʌm tə/`.
3. **go up quiz:** Yeterince net değildi ("more expensive now" tek ipucu). Cümle: "Petrol was 40 lira a litre last month. Now it is 45. The price ______ last week." Artık "went down" sayılarla eleniyor.
4. **haggle / bargain:** "bargain" synonyms'dan çıkarıldı (liste pos göstermediği için s1'deki 'kelepir' kartıyla karışabilirdi). Not, bargain'in fiil olarak da 'pazarlık etmek' olduğunu ama çoğunlukla isim 'kelepir' olarak duyulduğunu söyleyecek biçimde yeniden yazıldı. `mistakes` boş kaldı; Türkçeden gelen gerçek bir hata yok.
5. **value for money Türkçesi:** 'fiyat/performans' en yaygın karşılık; sıfat işlevine uysun diye gloss 'fiyat/performansı iyi' yapıldı, alt: 'fiyatına göre iyi', 'parasına değer'. İlk örnek 'Bu otelin fiyat/performansı iyi.' doğal, kaldı. Quiz'de 'real value for money' → 'great value for money' (daha doğal eşdizim).

**Değişiklik tablosu**

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.worth.adj.1 | l1.tr.gloss | değer → değerinde, değer | 'değer' tek başına isim (value) gibi okunuyor; '50 lira değerinde' kalıbı eklendi |
| en.worth.adj.1 | examples[1].tr | …ama buna değdi. → …ama değdi. | 'buna' fazlalık, doğal söyleyiş 'ama değdi' |
| en.value_for_money.phr.1 | ipa.us / ipa.uk | /ˈvæljuː…ˈmʌni/ → /ˌvæljuː…ˈmʌni/ | Kalıpta tek ana vurgu (depo geleneği) |
| en.value_for_money.phr.1 | l1.tr.gloss | fiyatına göre iyi → fiyat/performansı iyi | En yaygın Türkçe karşılık |
| en.value_for_money.phr.1 | l1.tr.alt | [fiyat/performans, parasına değer] → [fiyatına göre iyi, parasına değer] | Gloss ile yer değişimi |
| en.value_for_money.phr.1 | quiz.cloze | It was real ______. → It was great ______. | 'great value for money' daha doğal eşdizim |
| en.cost_an_arm_and_a_leg.idm.1 | ipa.us / ipa.uk | ˈleɡ → ˈlɛɡ | DRESS ünlüsü depo geleneğinde /ɛ/ |
| en.cost_an_arm_and_a_leg.idm.1 | examples[1].tr | …ateş pahasına mal oldu. → …çok pahalıya patladı. | Geçmiş zamanda doğal günlük karşılık |
| en.cost_an_arm_and_a_leg.idm.1 | examples[2].tr | biletler dudak uçuklatıyordu → biletler ateş pahasıydı | 'dudak uçuklatmak' fiyat için kullanılır, bilet için zorlama |
| en.cost_an_arm_and_a_leg.idm.1 | l1.tr.alt | + 'pahalıya patlamak' | Gerçek, yaygın karşılık; örnekte kullanılıyor |
| en.cost_an_arm_and_a_leg.idm.1 | quiz.cloze | Don't eat at that hotel. → Don't eat at the hotel restaurant. | 'eat at that hotel' biraz tuhaf |
| en.go_up.phv.1 | quiz.cloze | Petrol is more expensive now… → Petrol was 40 lira a litre last month. Now it is 45. The price ______ last week. | 'went down'u sayılarla kesin eler |
| en.come_to.phv.1 | ipa.us / ipa.uk | /ˈkʌm tuː/ → /ˈkʌm tə/ | Nesne alan 'to' zayıf (s13 look up to) |
| en.come_to.phv.1 | examples[2].tr | Kargoyla birlikte…, Can da kartla ödedi. → Kargo dahil…, bu yüzden Can kartla ödedi. | 'so' kayboluyordu; 'kargo dahil' daha doğal |
| en.rip_off.phv.1 | quiz.distractors | pick up → give up | 'pick up tourists' de olabilir (ikinci cevap) |
| en.haggle.v.1 | synonyms | [negotiate, bargain] → [negotiate] | s1'deki bargain (kelepir) ile karışma |
| en.haggle.v.1 | l1.tr.note | yeniden yazıldı | bargain'in fiil anlamını da doğru anlatsın |
| en.waste_of_money.phr.1 | ipa.us / ipa.uk | /ˈweɪst…/ → /ˌweɪst…/ | Kalıpta tek ana vurgu |
| en.waste_of_money.phr.1 | l1.tr.gloss / alt | paraya yazık → para israfı; alt [paraya yazık, boşa giden para] | Gloss isim kalıbına uysun; 'paraya yazık' ünlem |
| en.waste_of_money.phr.1 | examples[2].tr | …yıllık üyeliği boşa giden para oldu. → …yıllık üyeliğine verdiği para boşa gitti. | Düz çeviri |
| en.discount_code.phr.1 | examples[2].tr | …yüzde 15 tasarruf etti. → …yüzde 15 daha ucuza aldı. | Doğal Türkçe |
| en.discount_code.phr.1 | l1.tr.alt | [] → [promosyon kodu, kupon kodu] | Yaygın gerçek karşılıklar (promo/coupon code) |

### Denetim: part_03

İncelenen kart: 10 · değişen kart: 7 · değişen alan: 15 · reddedilen: 0
Doğrulayıcı: `10 kart · 10 şemadan geçti · 0 hata · 0 uyarı`

**Genel bulgular**
- US IPA'lar depo geleneğine (s15/part_01, 02, 04, 05 ve s6 return.v.1) uymuyordu: `ɔr/ɑr/ɝ/ɑ` → `ɔːr/ɑːr/ɜːr/ɑː`. 5 kartta düzeltildi. debit card UK'de DRESS `/e/` → `/ɛ/`.
- cash or card quizi kalıbı değil yalnızca "card" sözcüğünü sınıyordu; koordinatör kararıyla kalıbın tamamı boşluk yapıldı.
- split the bill notundaki "Alman usulü için de kullanılabilir" bilgisi yanıltıcıydı; düzeltildi.
- Birkaç küçük alan: zıt anlamlı olmayan "antonym" (coin → note), gerçek bir karşılık olmayan alt'lar (hesap kartı, temassız ödeme), doğrulanamayan bir genelleme ("Türkçede her karta kredi kartı denebiliyor").
- Örnekler doğal, çeviriler sadık; s1/s4/s6 kartlarıyla kopya cümle yok. Seviyeler makul, değişiklik yok.

**Yazarın "emin olmadığım" maddeleri**
1. cash or card gloss soru biçiminde ("nakit mi, kart mı?") ve def.micro "how do you want to pay?": kalsın. Başlık bir soru kalıbı; karşılığı da soru olmalı.
2. Etimolojiler: coin (Eski Fransızca coin "kama; para basma kalıbı" < Latince cuneus "kama") doğru, medium kalsın. warranty < Old North French/Anglo-Norman warantie, Paris Fransızcası garantie'nin w-'li biçimi (war/guerre, warden/guardian gibi): doğru, high kalsın. Mnemonic: Türkçe "garanti" doğrudan modern Fransızca garantie'den gelir. "Aynı kök" doğru ama "ikisi de eski Fransızcadan" ifadesi gevşekti; "ikisi de Fransızca 'garantie' kökünden" olarak sadeleştirildi.
3. IPA: debit card US `/ˈdɛbɪt kɑːrd/`, UK `/ˈdɛbɪt kɑːd/`. Bileşik isimde ana vurgu ilk öğede, ikincil vurgu gerekmiyor. cash or card US `/ˌkæʃ ɔːr ˈkɑːrd/`, UK değişmedi. Diğer US'ler de aynı biçime çekildi (contactless, return, warranty).
4. Quiz return (ironed/painted/folded) ve complain (smiled/cheered/agreed): her şık boşluğa kondu, tek doğru cevap var ("ironed it to the shop" vb. olmuyor; "smiled/agreed to the waiter" soğuk çorba bağlamında anlamsız). Kalsın.
5. Mistakes: "exchange it with a bigger size" (-le değiştirmek) ve "complain from" (-den şikâyet etmek) gerçek ve yaygın Türk öğrenci hataları. `right` cümleleri doğru, `why` açıklamaları doğru. Kalsın.

**Koordinatör kararları**
- cash or card quiz: `At the till, the cashier asked me, "______?" I said, "Card, please."`. Cevap "Cash or card", çeldiriciler "Here or to go", "Small or large", "Hot or cold". Hiçbiri "Card, please." cevabıyla uyuşmuyor. Cevap cümlede birebir geçmiyor (doğrulayıcı da onayladı).
- split the bill: not düzeltildi. "go halves" synonym'i çıkarıldı: iki kişilik ve İngiliz argosu, 3–4 kişilik hesap için yanıltıcı. Yerine "split the check" (US) kondu.

**Değişiklik tablosu**

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| cash or card | ipa.us | /ˌkæʃ ɔr ˈkɑrd/ → /ˌkæʃ ɔːr ˈkɑːrd/ | depo US geleneği |
| cash or card | quiz | "Cash or ______?" / card / bag, box, price → "\"______?\" I said, \"Card, please.\"" / Cash or card / Here or to go, Small or large, Hot or cold | kalıbın tamamını sınamak (koordinatör kararı) |
| debit card | ipa | /ˈdɛbɪt kɑrd/, /ˈdebɪt kɑːd/ → /ˈdɛbɪt kɑːrd/, /ˈdɛbɪt kɑːd/ | US gelenek, DRESS /ɛ/ |
| debit card | tr.alt | hesap kartı → bankamatik kartı | "hesap kartı" yaygın bir karşılık değil |
| debit card | tr.note | "Türkçede her karta 'kredi kartı' denebiliyor ama…" → "İngilizcede fark önemlidir: …" | Türkçede banka kartı/kredi kartı ayrımı zaten net; genelleme yanlış |
| contactless | ipa.us | /ˈkɑntæktləs/ → /ˈkɑːntæktləs/ | depo US geleneği |
| contactless | tr.alt | [temassız ödeme] → [] | sıfat karşılığı değil, bir kalıp (notta zaten var) |
| split the bill | synonyms | go halves → split the check | go halves iki kişilik ve İngiliz argosu |
| split the bill | tr.note | "…Alman usulü için de kullanılabilir." → "Genelde hesabı (çoğunlukla eşit) bölmek demektir; ABD'de 'split the check' de denir. Herkes kendi yediğini öderse (Alman usulü) 'pay separately' ya da 'go Dutch' denir." | yanlış bilgi (koordinatör kararı) |
| coin | antonyms | [note] → [] | kâğıt para zıt anlamlı değil, ayrımı tanım ve not zaten veriyor |
| return (v.2) | ipa.us | /rɪˈtɝn/ → /rɪˈtɜːrn/ | depo US geleneği (s6 return.v.1 ile aynı) |
| warranty | ipa.us | /ˈwɔrənti/ → /ˈwɔːrənti/ | depo US geleneği |
| warranty | tr.mnemonic | "aynı köktendir: ikisi de eski Fransızcadan gelir" → "akrabadır: ikisi de Fransızca 'garantie' kökünden gelir" | Türkçe garanti modern Fransızcadan |

(qa_flags'e "critic_edited" eklenen 7 kart: cash or card, debit card, contactless, split the bill, coin, return, warranty.)

### Denetim: part_04

- İncelenen kart: **10** (bank account, withdraw, balance, loan, owe, save up, pay off, broke, due, pocket money)
- Değişen kart: **6** (bank account, withdraw, balance, loan, broke, due; hepsine `critic_edited`)
- Değişen alan: **14**
- Reddedilen: **0**
- Seviye değişmedi.
- Doğrulayıcı: `10 kart · 10 şemadan geçti · 0 hata · 0 uyarı`

**Genel bulgular**
- Kartlar genel olarak sağlamdı: anlamlar doğru, ilk örnekler kısa ve güvenli, IPA depo geleneğine uygun, etimolojiler doğru.
- **Kopya:** `bank account` 2. örneği ve quiz'i s3 `salary` kartındaki "My salary goes into my bank account on the 15th." cümlesine çok yakındı. İkisi de değiştirildi.
- **Quiz:** `due` kartında "free" zayıf bir çeldiriciydi ve cümle tarihe bağlıydı. Cümle "late" bağlamıyla daraltıldı. Öteki 9 kartta her şık boşluğa kondu; tek cevap var.
- **Hata (mistakes):** `withdraw` kartına gerçek bir Türkçe aktarma hatası eklendi ("pull money", 'para çekmek'ten). `loan` hatası gerçek; `why` netleştirildi.
- **Türkçe:** `broke` çevirilerinde 'meteliksiz oluyor' → 'meteliksiz kalıyor' (doğal kalıp 'meteliksiz/parasız kalmak').

**Yazarın "emin olmadığım" maddelerine kararlar**
1. **withdraw IPA:** Depoda US THOUGHT/CLOTH ünlüsü `/ɔː/` (take off /teɪk ˈɔːf/, office /ˈɔːfɪs/, talk, lost, cough). US `/wɪðˈdrɔː/` doğru, değişmedi.
2. **pay off US:** Aynı gelenekle `/peɪ ˈɔːf/` kaldı (s4 `take off` ile tutarlı).
3. **balance etimolojisi:** Latince *bilanx* ('iki kefeli'), Eski Fransızca *balance* (terazi) yoluyla geliyor; doğru. Para anlamı muhasebede iki tarafın (giren/çıkan) karşılaştırılmasından geliyor; bu da doğru. Metne Eski Fransızca halkası eklendi, cümle sadeleştirildi; confidence `medium` kaldı.
4. **Quiz tek cevap:** `owe`: lend (mantık ve zaman yanlış), borrow (dilbilgisi yanlış: *borrow you*), spend (yanlış), yani tek cevap var, değişmedi. `due`: cümle değişti (aşağıda).
5. **Türkçe:** `due` gloss 'ödenmesi gereken' Türkçede yerleşik bir sıfat-fiil kalıbı ('ödenmesi gereken fatura'). Daha kısa ve eşdeğer bir sözcük yok, o yüzden kaldı. Açıklama gibi okunan alt 'son ödeme günü olan' → 'ödenecek'. `broke` 2. örnek: 'hep meteliksiz kalıyor' yapıldı.
6. **loan hatası:** "I took a credit from the bank" Türk öğrencilerde çok yaygın, gerçek bir hata. `right` "I took out a loan from the bank." doğru ve doğal. `why`daki "credit veresiye için kullanılır" ifadesi eksikti; 'credit' borçla alma düzenini anlatır ('buy on credit', 'credit card'), bankadan alınan belli para 'a loan' olur diye düzeltildi.

**Değişiklik tablosu**

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| bank account | examples[1].en | "My salary goes into my bank account every month." → "I'll send the money to your bank account tonight." | s3 `salary` örneğiyle neredeyse aynıydı |
| bank account | examples[1].tr | "Maaşım her ay banka hesabıma yatıyor." → "Parayı bu akşam banka hesabına gönderirim." | yeni örnek |
| bank account | quiz.cloze | "…open a ______ so my salary can go into it." → "I want to keep my money safe, so I'm going to open a ______." | salary kopyasından uzaklaştırma |
| bank account | quiz.distractors | shopping list, price tag, phone bill → price tag, phone bill, shopping bag | "open a shopping list" (uygulamada liste açmak) olabiliyordu |
| withdraw | l1.tr.mistakes | [] → "pull some money from the cash machine" → "withdraw…" | 'para çekmek' aktarması, gerçek hata |
| balance | examples[1].en | "My balance is low until payday." → "My balance is always low before payday." | "low until payday" doğal değildi |
| balance | examples[1].tr | → "Maaş gününden önce bakiyem hep düşük olur." | yeni örnek |
| balance | etymology.text | Latin bilanx… → Latin bilanx (with two pans), Old French 'balance'… money in / money out | doğrulandı, Fransızca halkası eklendi, sadeleştirildi |
| loan | mistakes[0].why | "…'Credit' daha çok kredi kartı ya da veresiye için…" → "…'credit' borçla alma düzenini anlatır: 'buy on credit', 'credit card'." | daha doğru açıklama |
| broke | examples[1].tr | "hep meteliksiz oluyor" → "hep meteliksiz kalıyor" | doğal kalıp 'meteliksiz kalmak' |
| broke | examples[2].tr | "haftalarca tamamen beş parasızdı" → "haftalarca tamamen meteliksiz kaldı" | daha doğal; gloss ile tutarlı |
| due | def.long | "…If a bill is like this, you must pay it by that day." → "…If you pay after that day, your payment is late." | "like this" belirsizdi; tekrarlı anlatım |
| due | l1.tr.alt | vadesi gelen, son ödeme günü olan → vadesi gelen, ödenecek | alt açıklama cümlesi gibiydi |
| due | quiz.cloze | "The electricity bill is ______ on the 15th, so pay it before then." → "Pay the electricity bill today. It's ______ tomorrow, and you don't want to be late." | bağlam daraltıldı; çeldiriciler (cheap, empty, free) aynı kaldı, "free" artık açıkça yanlış |

### Denetim: part_05

- İncelenen kart: **5** (place an order, track, shipping, review, customer service; hepsi B1)
- Değişen kart: **4** (`critic_edited`), `review` değişmedi
- Değişen alan: **12**
- Reddedilen: **0**
- Doğrulayıcı (`--strict`, part_05): `5 kart · 5 şemadan geçti · 0 hata · 0 uyarı`

**Genel bulgular**
- Kartlar genel olarak sağlamdı: anlamlar doğru, ilk örnekler kısa ve güvenli, quiz'lerde ikinci doğru cevap yok, seviyeler (B1) makul.
- **Komşu kartlarla kopya:** `shipping` hatası (`Is the cargo free?` → `Is shipping free?`) s1 `delivery` kartındaki hatayla harfi harfine aynıydı; aynı gerçek hata farklı cümleyle verildi. `place an order` hatası ("give an order") s6 `order` kartındaki hatayla aynı kökten, ama bu kartın asıl konusu olduğu için kaldı (cümleler farklı).
- **IPA:** US yazımı depo geleneğine çekildi (`ɔːr`, `ɜːr`). `customer service`te iki ana vurgu vardı; depodaki kalıp kartları gibi ikincil + ana vurgu yapıldı.
- **İsim:** `customer service` 2. örnekte "Can waited…" A2 öğrencisi için "can" fiiliyle karışıyordu; "Kerem" yapıldı.
- `track` kartında `synonyms: ["follow"]` vardı; oysa kartın hatası tam da "follow" kullanmak. Çelişki giderildi (liste boş).

**Yazarın "emin olmadığım" maddeleri**
- *place an order, "I gave an order online":* Gerçek ve çok yaygın bir Türkçe aktarım hatası ("sipariş vermek" → give an order). **Kaldı.** Ayrıca quiz'de anlamsız "spent" yerine aynı hata biçimi "gave" çeldirici yapıldı (o cümlede açıkça yanlış).
- *track, "following my order":* "takip etmek = follow" sözlük eşlemesinden gelen gerçek bir hata; **kaldı**, `why` netleştirildi ve kısaltıldı.
- *shipping quiz "cargo":* Boşlukta ("… and ______ is free") anadili İngilizce biri için açıkça yanlış ve kartın hedef hatasını sınıyor; öğretici. **Kaldı.** "delivery" şıklarda yok, doğru karar.
- *review etimolojisi:* Fransızca revue (Orta Fransızca reveue), revoir "yeniden görmek" fiilinin ortacından; doğru. **Kaldı** (high).
- *customer service:* "room service" çeldiricisi, evde kırık gelen kulaklık bağlamında açıkça yanlış ve gerçek bir karışıklık; **kaldı**. IPA iki ana vurgudan `/ˌkʌstəmər ˈsɜːrvɪs/` (UK `/ˌkʌstəmə ˈsɜːvɪs/`) yapıldı.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| place an order | ipa.us | /pleɪs ən ˈɔrdər/ → /pleɪs ən ˈɔːrdər/ | depo US yazımı |
| place an order | def.micro | ask to buy goods online → ask to buy goods | telefonda/mağazada da olur (def.long ile uyum) |
| place an order | quiz.distractors | spent → gave | gerçek hata biçimi daha iyi çeldirici |
| track | synonyms | ["follow"] → [] | kartın hatasıyla çelişiyordu |
| track | examples[1].tr | "…hafta sonundan önce istediği için…" → "…çünkü hafta sonundan önce elinde olmasını istiyordu." | düz çeviri, doğal değildi |
| track | mistakes[0].why | yeniden yazıldı | 'follow'un asıl anlamını açıklıyor |
| shipping | mistakes[0].wrong/right | Is the cargo free? → How much is the cargo? / How much is shipping? | s1 delivery ile birebir aynıydı |
| customer service | ipa.us, ipa.uk | iki ˈ → ˌ + ˈ; ɜr → ɜːr | depo kalıp vurgu geleneği |
| customer service | examples[1].en/tr | Can → Kerem | "Can waited" fiil gibi okunuyor |

### Bağımsız doğrulama ve son kontrol (koordinatör)

Bulgular: quiz doğrulayıcısı 7 (7'si uygulandı), Türkçe 21 (20), İngilizce/IPA 20 (18), son kontrol 6 (5). Uygulanmayanlar aşağıda "Uygulanmayan öneriler" bölümünde. Değişen kartlara `critic_edited` eklendi.

| Kart | Alan | Önce → Sonra |
|---|---|---|
| en.cost_an_arm_and_a_leg.idm.1 | quiz | {"cloze": "Don't eat at the hotel restaurant. The food costs an arm and a ______.", "answ… → {"cloze": "Don't eat at the hotel restaurant. The food ______. A sandwich is 25 euros!", … |
| en.opening_hours.phr.1 | quiz.cloze | The museum is open from 10 a.m. to 6 p.m. Those are its ______. → You can visit the museum from 10 a.m. to 6 p.m. Those are its ______. |
| en.tip.n.1 | quiz.distractors | ["napkin", "spoon", "chair"] → ["fee", "menu", "napkin"] |
| en.cashier.n.1 | quiz.distractors | ["waiter", "customer", "dentist"] → ["waiter", "customer", "chef"] |
| en.return.v.2 | quiz.distractors | ["ironed", "painted", "folded"] → ["wore", "ironed", "folded"] |
| en.basket.n.1 | quiz.distractors | ["receipt", "fridge", "ladder"] → ["receipt", "fridge", "suitcase"] |
| en.customer_service.phr.1 | quiz.distractors | ["room service", "the bakery", "a hairdresser"] → ["room service", "first aid", "lost property"] |
| en.value_for_money.phr.1 | l1.tr.gloss | fiyat/performansı iyi → fiyatına göre iyi |
| en.value_for_money.phr.1 | l1.tr.alt | ["fiyatına göre iyi", "parasına değer"] → ["parasının karşılığı", "fiyat/performans"] |
| en.value_for_money.phr.1 | examples[0].tr | Bu otelin fiyat/performansı iyi. → Bu otel ödediğin paranın karşılığını veriyor. |
| en.value_for_money.phr.1 | examples[2].tr | Zeynep'inki gibi kalabalık bir aile için büyük paket fiyatına göre daha avantajlı. → Zeynep'inki gibi kalabalık bir aile için büyük paket daha hesaplı. |
| en.due.adj.1 | examples[0].tr | Kiranın cuma günü ödenmesi gerekiyor. → Kiranın son ödeme günü cuma. |
| en.due.adj.1 | l1.tr.note | 'Due date' son ödeme tarihidir. Tarih 'on' ile, son gün 'by' ile söylenir: 'due on Friday… → 'Due date' son ödeme tarihidir. Gün ya da tarih 'on' ile söylenir: 'due on Friday'. 'En g… |
| en.withdraw.v.1 | l1.tr.mistakes | [{"wrong": "I need to pull some money from the cash machine.", "right": "I need to withdr… → [] |
| en.worth.adj.1 | l1.tr.gloss | değerinde, değer → değer |
| en.worth.adj.1 | l1.tr.alt | ["değmek"] → ["değmek", "değerinde"] |
| en.split_the_bill.phr.1 | examples[2].tr | Sara herkesin yerine ödemek istedi ama arkadaşları hesabı bölüşmek istedi. → Sara herkesin hesabını ödemek istedi ama arkadaşları hesabı bölüşmek istedi. |
| en.customer_service.phr.1 | examples[2].tr | Dizüstü bilgisayar çalışmayı bıraktı, bu yüzden Aisha müşteri hizmetlerine yazdı ve yenis… → Dizüstü bilgisayar bozuldu, bu yüzden Aisha müşteri hizmetlerine yazdı ve yenisini aldı. |
| en.cash_or_card.phr.1 | examples[0].en | "Cash or card?" "Card, please." → “Cash or card?” “Card, please.” |
| en.cash_or_card.phr.1 | examples[0].tr | "Nakit mi, kart mı?" "Kart, lütfen." → “Nakit mi, kart mı?” “Kartla.” |
| en.cash_or_card.phr.1 | examples[1].en | The man at the market looked at me and asked, "Cash or card?" → The man at the market looked at me and asked, “Cash or card?” |
| en.cash_or_card.phr.1 | examples[1].tr | Pazardaki adam bana bakıp "Nakit mi, kart mı?" diye sordu. → Pazardaki adam bana bakıp “Nakit mi, kart mı?” diye sordu. |
| en.cash_or_card.phr.1 | examples[2].en | When Selin got to the front of the queue, the cashier smiled and said, "Cash or card?" → When Selin got to the front of the queue, the cashier smiled and said, “Cash or card?” |
| en.cash_or_card.phr.1 | examples[2].tr | Selin sıranın önüne geldiğinde kasiyer gülümsedi ve "Nakit mi, kart mı?" dedi. → Selin sıranın önüne geldiğinde kasiyer gülümsedi ve “Nakit mi, kart mı?” dedi. |
| en.cash_or_card.phr.1 | quiz.cloze | At the till, the cashier asked me, "______?" I said, "Card, please." → At the till, the cashier asked me, “______?” I said, “Card, please.” |
| en.come_to.phv.1 | examples[2].tr | Kargo dahil toplam 320 lira tuttu, bu yüzden Can kartla ödedi. → Kargo dâhil toplam 320 lira tuttu, bu yüzden Can kartla ödedi. |
| en.return.v.2 | l1.tr.note | Bu kartta 'return' mağazaya iade etmek demektir; 'geri dönmek' anlamı ayrı bir karttır. G… → Bu kartta 'return' mağazaya iade etmek demektir; kelimenin 'geri dönmek' anlamı da vardır… |
| en.complain.v.1 | l1.tr.alt | ["yakınmak", "dert yanmak"] → ["yakınmak", "şikâyetçi olmak"] |
| en.opening_hours.phr.1 | l1.tr.alt | ["açık olduğu saatler", "açılış saatleri"] → ["açılış saatleri", "açılış-kapanış saatleri"] |
| en.pay_off.phv.1 | l1.tr.gloss | borcu ödeyip bitirmek → borcu kapatmak |
| en.pay_off.phv.1 | l1.tr.alt | ["borcu kapatmak", "tamamen ödemek"] → ["borcu ödeyip bitirmek", "tamamen ödemek"] |
| en.place_an_order.phr.1 | examples[0].tr | Yeni kulaklık için sipariş verdim. → Yeni bir kulaklık için sipariş verdim. |
| en.coin.n.1 | l1.tr.note | Kâğıt para 'note' (ABD'de 'bill') olur. Kasada verilen para üstü ise 'change' olarak geçe… → Kâğıt para 'note' (ABD'de 'bill') olur. Para üstüne ve cepteki bozukluklara 'change' deni… |
| en.warranty.n.1 | l1.tr.mnemonic | Türkçedeki 'garanti' ile akrabadır: ikisi de Fransızca 'garantie' kökünden gelir. → w ↔ g: warranty ≈ garanti. İkisi de Eski Fransızcadaki aynı kelimeden gelir. |
| en.worth.adj.1 | ipa.us | /wɝθ/ → /wɜːrθ/ |
| en.worth.adj.1 | examples[2].en | Mehmet says the fish market by the sea is worth visiting on Sundays. → Mehmet says the fish market by the sea is worth visiting in the morning. |
| en.worth.adj.1 | examples[2].tr | Mehmet'e göre deniz kenarındaki balık pazarı pazar günleri gidip görmeye değer. → Mehmet'e göre deniz kenarındaki balık pazarı sabahları gidip görmeye değer. |
| en.opening_hours.phr.1 | ipa.us | /ˈoʊpənɪŋ aʊrz/ → /ˈoʊpənɪŋ aʊərz/ |
| en.contactless.adj.1 | examples[2].en | The machine was broken, so Can couldn't pay contactless and had to enter his PIN. → The bill was over the contactless limit, so Can had to put his card in and enter his PIN. |
| en.contactless.adj.1 | examples[2].tr | Makine bozuktu, bu yüzden Can temassız ödeyemedi ve şifresini girmek zorunda kaldı. → Hesap temassız limitin üstündeydi, bu yüzden Can kartını takıp şifresini girmek zorunda k… |
| en.owe.v.1 | examples[0].en | I owe you 20 lira for lunch. → I owe you 200 lira for lunch. |
| en.owe.v.1 | examples[0].tr | Öğle yemeği için sana 20 lira borçluyum. → Öğle yemeği için sana 200 lira borçluyum. |
| en.owe.v.1 | l1.tr.note | 'I owe you 20 lira' = 'Sana 20 lira borçluyum'. Teşekkür ederken söylenen 'I owe you one'… → 'I owe you 200 lira' = 'Sana 200 lira borçluyum'. Teşekkür ederken söylenen 'I owe you on… |
| en.tip.n.1 | examples[1].en | Emre gave the taxi driver a ten-lira tip. → Emre gave the taxi driver a fifty-lira tip. |
| en.tip.n.1 | examples[1].tr | Emre taksi şoförüne on lira bahşiş verdi. → Emre taksi şoförüne elli lira bahşiş verdi. |
| en.save_up.phv.1 | examples[0].en | I'm saving up for a new bike. → We're saving up for a holiday in Italy. |
| en.save_up.phv.1 | examples[0].tr | Yeni bir bisiklet için para biriktiriyorum. → İtalya'da bir tatil için para biriktiriyoruz. |
| en.debit_card.phr.1 | antonyms | ["credit card"] → [] |
| en.debit_card.phr.1 | examples[1].tr | Tom banka kartını kullanıyor çünkü borç para almayı sevmiyor. → Tom banka kartını kullanıyor çünkü borçlanmayı sevmiyor. |
| en.debit_card.phr.1 | examples[2].en | Zeynep's debit card didn't work because her account was almost empty. → Zeynep's debit card is linked to her bank account, so she can't spend more than she has. |
| en.debit_card.phr.1 | examples[2].tr | Zeynep'in banka kartı çalışmadı çünkü hesabında neredeyse hiç para kalmamıştı. → Zeynep'in banka kartı banka hesabına bağlı, bu yüzden elindeki paradan fazlasını harcayam… |
| en.review.n.1 | synonyms | ["rating", "comment"] → ["comment"] |
| en.complain.v.1 | synonyms | ["moan", "grumble"] → ["make a complaint"] |
| en.go_up.phv.1 | quiz.cloze | Petrol was 40 lira a litre last month. Now it is 45. The price ______ last week. → Petrol was 60 lira last month. Now it is 65. The price ______ last week. |
| en.exchange.v.1 | def.long | To take something you bought back to the shop and get a different thing, for example the … → To take something you bought back to the shop and get a different thing, for example the … |
| en.checkout.n.1 | def.long | The place in a supermarket or shop where you pay for the things you want to buy. In onlin… → The place in a supermarket or shop where you pay for the things you want to buy. In onlin… |
| en.cost_an_arm_and_a_leg.idm.1 | grammar | null → {"pattern": "sth costs (sb) an arm and a leg"} |
| en.track.v.1 | examples[1].en | Burak tracked his parcel all day because he wanted it before the weekend. → Burak kept tracking his parcel because he needed it before the weekend. |
| en.track.v.1 | examples[1].tr | Burak kargosunu bütün gün takip etti, çünkü hafta sonundan önce elinde olmasını istiyordu. → Burak hafta sonundan önce ihtiyacı olduğu için kargosunu sürekli takip etti. |
| en.haggle.v.1 | examples[2].en | Lucas haggled with the seller and got the carpet for 1,500 lira. → Lucas haggled with the seller and got the carpet for 6,000 lira. |
| en.haggle.v.1 | examples[2].tr | Lucas satıcıyla pazarlık etti ve halıyı 1.500 liraya aldı. → Lucas satıcıyla pazarlık etti ve halıyı 6.000 liraya aldı. |
| en.shipping.n.1 | examples[0].en | Shipping is free on this website. → How much is shipping to Turkey? |
| en.shipping.n.1 | examples[0].tr | Bu sitede kargo ücretsiz. → Türkiye'ye kargo ne kadar? |
| en.for_sale.phr.1 | antonyms | ["not for sale"] → [] |
| en.worth.adj.1 | l1.tr.gloss | değer → değerinde |
| en.worth.adj.1 | l1.tr.alt | ["değmek", "değerinde"] → ["değmek", "değer"] |
| en.worth.adj.1 | examples.2.en | Mehmet says the fish market by the sea is worth visiting in the morning. → Mehmet says the fish market by the sea is worth visiting early in the morning. |
| en.worth.adj.1 | examples.2.tr | Mehmet'e göre deniz kenarındaki balık pazarı sabahları gidip görmeye değer. → Mehmet'e göre deniz kenarındaki balık pazarı sabah erkenden gidip görmeye değer. |
| en.contactless.adj.1 | examples.2.en | The bill was over the contactless limit, so Can had to put his card in and enter his PIN. → The total was over the contactless limit, so Can had to put his card in and enter his PIN. |
| en.contactless.adj.1 | examples.2.tr | Hesap temassız limitin üstündeydi, bu yüzden Can kartını takıp şifresini girmek zorunda k… → Tutar temassız ödeme limitini aştığı için Can kartını takıp şifresini girmek zorunda kald… |
| en.go_up.phv.1 | quiz.cloze | Petrol was 60 lira last month. Now it is 65. The price ______ last week. → A loaf of bread was 15 lira last month. Now it is 20. The price ______ last week. |
| en.save_up.phv.1 | examples.0.tr | İtalya'da bir tatil için para biriktiriyoruz. → İtalya tatili için para biriktiriyoruz. |

## Çeldirici kontrolü (2026-10-22)

- Önce: `s15: 45 quizzes, 120 distinct distractors; top: receipt×3, borrow×3, lend×3, waiter×2, on time×2, in stock×2`
- Sonra: `s15: 45 quizzes, 120 distinct distractors; top: receipt×3, borrow×3, lend×3, waiter×2, on time×2, in stock×2`
- Sayı hedefi (hiçbir çeldirici 4'ten fazla soruda değil) baştan sağlanıyordu; sayı için değişiklik yapılmadı. 45 sorunun çeldiricileri biçim, konuya yakınlık ve açıkça yanlış olma açısından gözden geçirildi.
- Değişen kart sayısı: 1

| Kart | Önce | Sonra | Neden |
|---|---|---|---|
| worth (adj) | cheap, costly, proud | cheap, costly, valuable | "proud" fiyat cümlesiyle ilgisizdi ve bir şey sınamıyordu. "valuable" konuya yakın bir sıfat; "is valuable 300 euros" İngiliz ve Amerikan İngilizcesinde dilbilgisi olarak yanlış. |

- Cloze değişikliği: yok.

## Uygulanmayan öneriler

- `brand` mistakes ("What mark is your phone?"): Türkçe doğrulayıcı "çok yaygın" dedi, denetçi belgeleyemedi. Uydurma hata riski yüzünden eklenmedi; `mark` / `marka` farkı notta duruyor. Aşağıda anadili Türkçe birine soruldu.
- `complain` seviyesi A2'ye çekilmedi (İngilizce doğrulayıcı EVP'de A2 dedi); listede verilen B1 bırakıldı, bariz yanlış değil. Eş anlamlılar düzeltildi.
- `checkout` synonyms içindeki "till" (UK) ve `cash or card` collocations ("pay in cash", "pay by card") kaldı; doğrulayıcı da "kalabilir" dedi.
- `cost an arm and a leg` için quiz doğrulayıcısının önerdiği biçim çeldiricileri ("a leg and an arm", "a hand and a leg") yerine anlam çeldiricileri seçildi; uydurma deyim biçimleri öğrenciye gösterilmesin diye.
- `tip` için önerilen "bill" çeldiricisi kullanılmadı: Amerikan İngilizcesinde "bill" kâğıt para da demek; "left him a big bill" bahşiş olarak okunabilir. Yerine "menu" kondu.

## Akışlar arası notlar (koordinatör için; bu görevde dokunulmadı)

- `shipping` kartı ("How much is the cargo?") ile s1 `delivery` kartı aynı gerçek hatayı ("cargo" ≠ kargo) farklı cümlelerle öğretiyor.
- `place an order` kartındaki "gave an order" hatası s6 `order` kartındaki hatayla aynı kökten (sipariş vermek); bu kartın asıl konusu olduğu için kaldı.
- `en.return.v.2` (iade etmek) s6'daki `en.return.v.1` (geri dönmek) ile aynı lemma, farklı anlam; kimlik çakışması yok.
- s14 taslağındaki `for rent` ile s15'teki `for sale` birbirini tamamlıyor; derlemede ikisi de kalabilir.

## Anadili Türkçe birinin bakması gerekenler

1. `value for money` gloss "fiyatına göre iyi": "fiyat/performans" mı gloss olmalı?
2. `worth` gloss "değerinde" (alt: değmek, değer): kilit ekranında yeterince açık mı?
3. `due` gloss "ödenmesi gereken": açıklama gibi mi duruyor? "vadesi gelen" daha mı iyi?
4. `brand`: "What mark is your phone?" hatası Türk öğrencilerde sık mı? Sıksa geri eklenebilir.
5. `withdraw`: "pull money" hatası sık mı? (Silindi; "draw money" İngilizcede doğru sayılıyor.)
6. `cash or card`: kasada cevap olarak "Kartla." doğal mı? Alt "nakit mi, kartla mı?" gerekli mi?
7. `debit card` alt "bankamatik kartı" hâlâ yaygın mı?
8. `shop assistant` gloss "satış görevlisi" mi, "tezgâhtar" mı daha yaygın?
9. `opening hours` gloss "çalışma saatleri", alt "açılış saatleri": müze için "ziyaret saatleri" daha mı iyi?
10. `cost an arm and a leg` ilk örnek "Yeni bir telefon ateş pahası.": "Telefonlar ateş pahası" gibi genel kullanım daha mı doğal?
11. `checkout` 3. örnek "ödeme adımına hiç geçmedim" mi, "ödemeye hiç geçmedim" mi?
12. `place an order` alt "siparişte bulunmak" resmî/eskice mi?
13. `exchange` alt "başkasıyla değiştirmek" açıklamaya yakın mı?
14. `review` gloss "yorum" mu, "değerlendirme" mi?
15. `broke` 3. örnek "haftalarca tamamen meteliksiz kaldı": "tamamen" fazla mı?
