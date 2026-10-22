# s9 QA incelemesi (günlük isimler: aile, ev, yiyecek, mekân, beden, hava)

Kapsam: `content/drafts/kisisel_v1/s9/part_01.json` ... `part_06.json`. Bakılan kriterler: `SYSTEM_C` listesi (anlam, tanım, örnek, Türkçe karşılık, Türkçe çeviri, IPA, seviye, hata, not, etimoloji, quiz). Her kart tek tek okundu; Türkçe çeviriler İngilizceye geri çevrildi; quiz boşluklarına her şık tek tek konuldu.

## Özet

- İncelenen kart: **59**
- Değişen kart: **19** (hepsine `critic_edited` eklendi)
- Toplam düzenleme (alan sayısı): **31** (silinen her hata ayrı bir alan sayıldı)
- Reddedilen kart (`critic_reject`): **0**
- Doğrulayıcı (tüm klasör): `59 kart · 59 şemadan geçti · 0 hata · 0 uyarı`
- Seviye değişikliği: yok (listedeki seviyeler makul).

## Genel bulgular

- Kartların büyük kısmı iyi. İngilizce örnekler doğal, ilk örnekler kilit ekranı için güvenli, çeviriler İngilizceye geri çevrilince aynı anlama geliyor. İngilizce sözcükten sonra ayrı yazılmış ek (`'freezer' dır` türü) bu akışta yok.
- **En sık sorun: kanıtsız ya da yanlış etiketlenmiş "yaygın hata".** Altı hata silindi (key, glass, money, library, supermarket, rain), biri yenisiyle değiştirildi (weather), üçünün açıklaması düzeltildi (people, lunch, beach) ve biri yumuşatıldı (fruit). Ortak sorun: Türkçe etkisi gerçek olsa bile İngilizce cümle aslında yanlış değildi (`go to the market`, `a glass of tea`, `The air is cold`).
- **Etimoloji:** Orta güvenli üç etimoloji (ticket, kind, rice) Wiktionary'ye karşı denetlendi (etymonline 403 verdi). Üçü de gerçek; ama ticket'ta doğrulanamayan bir ayrıntı ('door or post'), kind'da kesin olmayan bir anlam ('family'), rice'ta eksik bir halka (İtalyanca) vardı. Metinler doğrulanan çekirdeğe indirildi. Diğer etimolojilerin hepsi tek tek okundu; halk etimolojisi yok.
- **Sahte dost:** Tek kayıt (library) gerçek değildi, kaldırıldı. Başka sahte dost iddiası yok.
- **IPA ve vurgu:** Tüm kartlar kontrol edildi, değişiklik gerekmedi. Özellikle: address US /ˈædrɛs/ (isim için; ABD'de /əˈdrɛs/ da duyulur), UK /əˈdrɛs/; holiday US /ˈhɑːlədeɪ/, UK /ˈhɒlədeɪ/; library US /ˈlaɪbrɛri/, UK /ˈlaɪbrəri/. Üçü de doğru.
- **Sayılamayan isimler (money, news, information, bread, rice, hair, fruit):** Örnekler ve quiz tek tek okundu. Tek dilbilgisi sorunu rice quiz'inde ("They are rice") bulundu ve düzeltildi. Diğerlerinde sayılamaz isim doğru kullanılıyor (tekil fiil, 'a' yok, çoğul eki yok). `fruit` örnek 3 ("are my favorite fruit") dilbilgisi olarak doğru; olduğu gibi bırakıldı.
- **Quiz:** 59 quiz'in hepsi kontrol edildi. Hiçbir çeldirici boşluğa uymuyor; tek doğru cevap korunuyor. Yalnızca rice quiz'i değişti.

### İstenen kararlar

1. **library:** `false_friend` null, `equivalence` partial, `false_friend_tr` bayrağı çıkarıldı. "Where is the library?" (kitapçı yerine) hatası silindi: Türkçede 'library'ye benzeyen bir sözcük yok; 'librairie/librería' karışıklığı Fransızca ve İspanyolca konuşanlara özgü. Not yeniden yazıldı (gerçek Türkçe farkı: 'kütüphane' kitap dolabı da demek).
2. **Kanıtsız hatalar:**
   - **supermarket ('go to the market'):** Türkçe etkisi gerçek ama İngilizce cümle yanlış değil (pazar; ABD'de market mağazası). Hata silindi, nüans notta.
   - **beach ('go to the sea'):** Hata gerçek ('denize gitmek'), ama 'go to the sea' mümkün. Kart tutuldu; açıklama "mümkün ama yüzmek ve güneşlenmek için doğal olan go to the beach" diye kuruldu.
   - **glass ('a glass of tea'):** Yanlış değil; hata silindi, liste boş.
   - **baby (oyuncak bebek için 'baby'):** Türkçe mekanizma kesin ('bebek' = baby ve doll). Sıklığından emin olunamadığı için kart tutuldu ve aşağıdaki "Anadili Türkçe birinin bakması gerekenler" listesine eklendi.
3. **IPA:** Yukarıda; değişiklik yok.
4. **wife / husband:** 'karı' tek başına kaba duyulabildiği için wife karşılığı 'eş (kadın)' yapıldı; notta 'karım/eşim' gösterildi. husband karşılığı 'koca' (alt 'eş') nötr ve doğru; dokunulmadı.
5. **Etimoloji:** ticket, kind ve rice gerçek; metinler doğrulanan çekirdeğe indirildi, güven 'medium' kaldı. Hiçbiri null yapılmadı.
6. **Sayılamayan isimler:** Yukarıda; yalnızca rice quiz'i düzeltildi, fruit hatasının açıklaması yumuşatıldı.

## Değişiklik tablosu

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.people.n.1 | l1.tr.mistakes[1].why | 'People' çoğul sayılır, fiil de çoğul olur: are, were, have. Türkçede 'halk' tekil olduğu için 'people' için de 'is' demek kolay olur. → Türkçede 'insanlar geliyor' derken çoğul özneye genellikle tekil fiil gelir. İngilizcede 'people' çoğuldur, bu yüzden 'be' de çoğul olur: People are, People were. | Eski açıklama ('halk tekil') yanıltıcıydı. Gerçek etki: Türkçede çoğul özneden sonra fiil genellikle tekil kalır (insanlar geliyor). |
| en.wife.n.1 | l1.tr.gloss | eş, karı → eş (kadın) | Tek başına 'karı' kaba duyulabilir (karım ve eşim nötrdür). Karşılık nötr ve cinsiyeti gösteren 'eş (kadın)' yapıldı. |
| en.wife.n.1 | l1.tr.note | Resmî dilde 'eş' kadınlar için de erkekler için de söylenir. İngilizcede kadın eş 'wife', erkek eş 'husband' olur. Çoğulu 'wives' biçimindedir. → Resmî dilde 'eş' kadınlar için de erkekler için de söylenir; günlük dilde 'karım' ve 'eşim' denir. İngilizcede kadın eş 'wife', erkek eş 'husband' olur. Çoğulu 'wives' biçimindedir. | Günlük dilde 'karım' ve 'eşim' denildiği notta gösterildi; çıkan 'karı' sözcüğünün işi burada karşılanıyor. |
| en.key.n.1 | l1.tr.mistakes[0] | Please close the door with the key. -> Please lock the door. :: Türkçede 'kapıyı anahtarla kapatmak' denir. İngilizcede anahtarla kapatmak 'lock' demektir; 'close' yalnızca kapıyı kapatır, kilitlemez. → (silindi) | 'Anahtarla kapatmak' için Türkçe bağı zayıf, yaygınlığı kanıtsız; hata 'key'den çok 'lock' ile ilgili. Silindi. |
| en.bottle.n.1 | def.micro | tall container for drinks → container with a narrow neck | 'Tall' yanıltıcı: biberon, parfüm şişesi gibi kısa şişeler de var. Ortak özellik dar boyun. |
| en.glass.n.1 | l1.tr.mistakes[0] | Would you like a glass of tea? -> Would you like a cup of tea? :: Türkçede çay bardakla içilir ('bir bardak çay'). İngilizcede sıcak çay ve kahve için genellikle 'cup' denir: a cup of tea. 'Glass' daha çok soğuk içecekler içindir. → (silindi) | 'A glass of tea' yanlış değil (çay bardakta içilir); hata olarak kalmamalı. Silindi (liste boş). |
| en.ticket.n.1 | etymology.text | From Old French 'estiquet', a small note stuck on a door or post. It is related to the word 'stick'. → From Old French 'estiquet', a small note or label. It comes from a verb meaning 'to stick', so it is related to 'stick'. | 'Door or post' ayrıntısı doğrulanamadı. Doğrulanan çekirdek bırakıldı: Eski Fransızca estiquet (etiket) < 'yapıştırmak' fiili; 'stick' ile akraba. |
| en.money.n.1 | l1.tr.mistakes[1] | The money are on the table. -> The money is on the table. :: 'Money' tekil sayılır ve 'is' ile kullanılır. Türkçede 'paralar masada' diye çoğul düşünüldüğü için 'are' demek kolay olur. → (silindi) | 'The money are' için Türkçe bağı ('paralar masada') zorlama; Türk konuşurlara özgü ya da yaygın olduğu kanıtsız. Silindi. Asıl hata ('how many money') kaldı. |
| en.lunch.n.1 | l1.tr.mistakes[0].why | Türkçede 'the' gibi bir sözcük yoktur, bu yüzden öğün adlarına 'the' eklemek kolay olur. İngilizcede öğün adlarının önüne genellikle 'the' gelmez: have lunch, eat lunch. → İngilizcede öğün adlarının önüne genellikle 'the' gelmez: have lunch, eat lunch. Türkçede 'öğle yemeğini yerim' dersiniz; belirtme eki 'the' gibi duyulabilir. | Eski neden mantıksızdı (Türkçede artikel yoksa neden 'the' eklenir?). Yeni neden Türkçedeki belirtme ekini gösteriyor; 'duyulabilir' diye temkinli. |
| en.kind.n.1 | etymology.text | From Old English 'cynd', meaning 'nature' or 'family'. → From Old English 'cynd', meaning 'nature' or 'race'. It is related to the word 'kin'. | Eski İngilizce cynd/gecynd 'doğa, soy, tür' demektir; 'family' kesin değil. 'Kin' ile akrabalık doğrulandı. |
| en.rice.n.1 | etymology.text | From Old French 'ris', which came through Latin from Greek 'oryza'. → From Old French 'ris', which came from Italian 'riso'. The Italian word comes from Latin and Greek 'oryza'. | Zincir doğrulandı ama İtalyanca (riso) halkası eksikti: Eski Fransızca ris < İtalyanca riso < Latince/Yunanca oryza. |
| en.rice.n.1 | quiz.cloze | We cook small white grains in water and eat them with chicken. They are ______. → We cook small white grains in water and eat them with chicken. This food is ______. | 'They are rice' dilbilgisi olarak tuhaf (çoğul zamir + sayılamaz isim). 'This food is ______' ile tek cevap korunarak düzeltildi. |
| en.meat.n.1 | def.micro | animal flesh that people eat → the part of an animal we eat | 'Flesh' A1 kartı için fazla zor. Daha basit söyleyiş. |
| en.meat.n.1 | examples[2].en | The butcher sells good meat in this street. → The butcher on our street sells very good meat. | 'The butcher sells ... in this street' doğal değil; 'on our street' denir. |
| en.meat.n.1 | examples[2].tr | Kasap bu sokakta iyi et satıyor. → Sokağımızdaki kasap çok iyi et satıyor. | Yeni İngilizce cümleye uygun çeviri. |
| en.meat.n.1 | l1.tr.note | 'Meat' sayılamaz: 'meats' denmez. Balık 'fish' olarak ayrı sayılır, 'meat' içine girmez. Sığır eti 'beef', kuzu ya da koyun eti 'lamb' olur. → 'Meat' sayılamaz: 'meats' denmez. Balık 'fish' olarak ayrı sayılır, 'meat' içine girmez. Sığır eti 'beef', kuzu eti 'lamb', koyun eti 'mutton' olur. | Yanlış bilgi: koyun eti 'mutton'dır, 'lamb' değil. Kuzu (lamb) ve koyun (mutton) ayrıldı. |
| en.fruit.n.1 | l1.tr.mistakes[0].why | Türkçede 'meyveleri severim' diyebilirsiniz, bu yüzden 'fruits' denir. İngilizcede meyve genel olarak sayılamaz ve -s almaz. → Türkçede 'meyveleri severim' diyebilirsiniz, bu yüzden 'fruits' denir. İngilizcede genel anlamda 'fruit' kullanılır; 'fruits' yalnızca farklı meyve türleri için söylenir. | 'I like fruits' tamamen yanlış değil (farklı türler için kullanılır). Açıklama 'genel anlamda fruit daha doğal' diye yumuşatıldı. |
| en.menu.n.1 | l1.tr.note | Türkçede 'menü' hem yemek listesini hem hızlı yemek zincirlerindeki hazır paketi ('hamburger menü') anlatır. İngilizcede 'menu' yalnızca listedir; paket için 'combo' ya da 'meal deal' denir. → Türkçede 'menü' hem yemek listesini hem hızlı yemek zincirlerindeki hazır paketi ('hamburger menü') anlatır. İngilizcede 'menu' genellikle listedir; hazır paket için 'combo' ya da 'value meal' denir. | 'Yalnızca listedir' aşırı kesin: 'set menu' sabit yemek anlamına da gelir. 'Genellikle' denildi; 'meal deal' (yalnız İngiltere) yerine 'value meal'. |
| en.library.n.1 | l1.tr.equivalence | false_friend → partial | Sahte dost kaldırıldı. 'Kütüphane' evdeki kitaplığı da anlattığı için kitchen/mutfak kartındaki kurala uyularak 'partial'. |
| en.library.n.1 | l1.tr.false_friend | {'tr_word': 'kitapçı', 'tr_means': 'kitap satan dükkân', 'en_for_that': 'bookstore (UK: bookshop)'} → null | Türkçede 'library'ye benzeyen bir sözcük yok. 'Librairie/librería' karışıklığı Fransızca ve İspanyolca konuşanlara özgü; Türkçe konuşanlara değil. |
| en.library.n.1 | l1.tr.note | 'Library' kitap ödünç verir, kitap satmaz. Kitap alınan yere 'bookstore' (İngiltere'de 'bookshop') denir. Fransızca 'librairie' ve İspanyolca 'librería' kitapçıdır, bu yüzden karışabilir. → Türkçede evdeki kitap dolabına da 'kütüphane' denir; İngilizcede ona 'bookcase' denir. 'Library' kitap ödünç verilen yerdir; kitap satılan yere 'bookstore' denir. | Eski not Fransızca/İspanyolca karışıklığını anlatıyordu. Yeni not gerçek bir Türkçe farkı veriyor: 'kütüphane' kitap dolabı da olabilir (bookcase). |
| en.library.n.1 | l1.tr.mistakes[0] | I want to buy a book. Where is the library? -> I want to buy a book. Where is the bookstore? :: 'Library' kitap satmaz, ödünç verir. Kitap satın alınan yer 'bookstore' ya da 'bookshop' olur. Fransızca 'librairie' gibi benzer sözcükler kitapçıdır; bu yüzden karışır. → (silindi) | 'Where is the library?' (kitapçı yerine) Türkçe konuşanlara özgü değil: Türkçede kitapçı ve kütüphane karışmaz. Silindi. |
| en.library.n.1 | tags.flags | [false_friend_tr] → [] | 'false_friend_tr' bayrağı sahte dost kalktığı için çıkarıldı. |
| en.pharmacy.n.1 | def.long | A shop where you can buy medicine, and where a pharmacist gives you the medicine that your doctor wrote for you. It also sells things like soap and vitamins. → A shop where you can buy medicine, including the medicine that your doctor tells you to take. It also sells things like soap and vitamins. | İlk cümlede başlığın ailesinden 'pharmacist' geçiyordu (döngüsel). Yeniden yazıldı. |
| en.supermarket.n.1 | l1.tr.mistakes[0] | I am going to the market to buy milk and bread. -> I am going to the supermarket to buy milk and bread. :: Türkçede 'market' süpermarket ve bakkal demektir. İngilizcede 'market' çoğunlukla açık hava pazarıdır; süt ve ekmek için 'supermarket' ya da 'shop' denir. → (silindi) | Türkçe etkisi gerçek ('market' = süpermarket) ama 'go to the market' İngilizcede yanlış değil (açık hava pazarı; ABD'de market mağazası da olur). 'Wrong' etiketi yanlış olurdu; bilgi nota taşındı. |
| en.supermarket.n.1 | l1.tr.note | Türkçede bakkal ve küçük dükkânlara da 'market' dersiniz. İngilizcede 'market' çoğunlukla açık hava pazarıdır; büyük mağazaya 'supermarket', küçük mahalle dükkânına 'corner shop' denir. → Türkçede bakkal ve küçük dükkânlara da 'market' dersiniz. İngilizcede 'market' çoğunlukla açık hava pazarıdır (ABD'de bazen süpermarket de olur); büyük mağazaya 'supermarket' denir. | ABD'de 'market'in süpermarket anlamına da gelebildiği eklendi; 220 karakter sınırı için 'corner shop' bilgisi çıkarıldı. |
| en.beach.n.1 | l1.tr.mistakes[0].why | Türkçede 'denize gitmek' dersiniz. İngilizcede 'go to the sea' yolculuk gibi anlaşılır; yüzmek ve güneşlenmek için 'go to the beach' denir. → Türkçede 'denize gitmek' dersiniz. İngilizcede 'go to the sea' mümkündür ama denize doğru gitmek gibi duyulur; yüzmek ve güneşlenmek için doğal söyleyiş 'go to the beach' olur. | Hata gerçek ('denize gitmek') ama 'go to the sea' mümkün bir söyleyiş. Eski açıklama 'yolculuk gibi anlaşılır' diyordu; şimdi 'mümkün ama yüzmek için doğal olan beach' diye doğru kuruldu. |
| en.weather.n.1 | l1.tr.mistakes[0].wrong | The air is very cold today. → How is the air today? | 'The air is very cold' İngilizcede yanlış değil; gerçekten yanlış olan 'How is the air today?'. |
| en.weather.n.1 | l1.tr.mistakes[0].right | The weather is very cold today. → How is the weather today? | Yeni 'wrong' cümleye uygun düzeltme. |
| en.weather.n.1 | l1.tr.mistakes[0].why | Türkçede 'hava soğuk' dersiniz ve 'hava' sözcüğü 'air' sanılır. İngilizcede dış ortamın durumu için 'the weather' denir; 'air' soluduğumuz havadır. → Türkçede 'Bugün hava nasıl?' dersiniz ve 'hava' sözcüğü 'air' sanılır. İngilizcede hava durumunu sorarken 'weather' kullanılır; 'air' soluduğumuz havadır. | Yeni hataya uygun açıklama ('Bugün hava nasıl?' -> 'hava' = air sanılır). |
| en.rain.n.1 | l1.tr.mistakes[0] | Rain is raining now. -> It is raining now. :: Türkçede 'yağmur yağıyor' dersiniz ve özne 'yağmur' olur. İngilizcede hava olaylarında özne 'it' olur: It is raining. → (silindi) | 'Rain is raining' hatasının Türk konuşurlarda yaygın olduğuna dair kanıt yok (A1'de 'It is raining' öğretilir). Silindi; bilgi notta duruyor. |

## Anadili Türkçe birinin bakması gerekenler

- **en.wife.n.1:** Yeni karşılık 'eş (kadın)'. Parantezli karşılık widget'ta doğal mı? 'Karı' tek başına kaba mı duyuluyor (çıkarıldı), yoksa sözlük karşılığı olarak kalmalı mıydı?
- **en.husband.n.1:** 'koca' tek başına (alt: 'eş') sorunsuz mu? Dokunulmadı.
- **en.baby.n.1:** `mistakes[0]` 'her baby' (oyuncak bebek için). Mekanizma kesin ama Türk konuşurlarda ne kadar yaygın bilinmiyor. Yaygın değilse silinmeli.
- **en.place.n.1:** `mistakes[0]` 'Is there any place for me in the car?' ('yer var mı?'). Gerçek mi? Tutuldu.
- **en.menu.n.1:** `mistakes[0]` 'Can I take the menu?' ('menüyü alabilir miyim?'). Tutuldu; yaygınlığı belirsiz.
- **en.meal.n.1:** `mistakes[1]` 'I love Turkish meals'. Anlaşılır ama kesin yanlış değil; 'Turkish food' daha doğal. Tutuldu.
- **en.fruit.n.1:** `mistakes[0]` 'I like fruits very much' kesin yanlış değil; açıklama yumuşatıldı. Silmek de mümkün.
- **en.lunch.n.1:** `mistakes[0]` 'I eat the lunch'. Yeni neden (belirtme eki 'the' dedirtir) bir varsayım; 'duyulabilir' diye yumuşak yazıldı.
- **en.beach.n.1:** `mistakes[0]` açıklamasındaki 'go to the sea mümkündür ama...' ifadesi A2 için fazla ince mi?
- **en.weather.n.1:** Yeni hata 'How is the air today?' ('Bugün hava nasıl?'). Gerçekten yapılan bir hata mı?
- **en.supermarket.n.1:** Silinen 'go to the market' hatası Türk konuşurlarda çok yaygın. Not yeterli mi, yoksa 'daha az doğal' diye yumuşak bir hata olarak geri konmalı mı?
- **en.rain.n.1:** Silinen 'Rain is raining' hatası gerçekten duyuluyor mu? Duyuluyorsa geri konabilir.
- **en.glass.n.1:** Hata silindi (liste boş). 'Glass' için gerçek bir Türkçe hatası varsa eklenebilir.
- **en.library.n.1:** Yeni not: 'Evdeki kitap dolabına da kütüphane denir.' Günlük dilde doğru mu? (Eminim, ama anadil kontrolü iyi olur.)
- **en.holiday.n.1:** `alt` 'bayram' (resmî tatil için) kabul edilebilir mi? s1'de de aynı soru vardı.
- **en.bathroom.n.1:** `alt` 'tuvalet' (ABD'de 'bathroom' tuvalet yerine geçer) kabul edilebilir mi?
- **en.umbrella.n.1:** `examples[2]` 'Can I share your umbrella to the station?' anadili İngilizce biri için tam doğal mı? Anlaşılır ve dilbilgisi doğru; doğallığı kesin değil.
- **en.ticket.n.1, en.kind.n.1, en.rice.n.1:** Etimoloji metinleri Wiktionary'ye göre yazıldı (etymonline erişilemedi). Güven 'medium'.

## Sayılar

| Ölçü | Sayı |
|---|---|
| İncelenen kart | 59 |
| Değişen kart | 19 |
| Düzenlenen alan | 31 |
| Reddedilen kart | 0 |
| Doğrulayıcı sonucu | 0 hata, 0 uyarı |

## Editör kararları (Opus, 2026-10-19)

- `en.rain.n.1`: "Rain is raining now." hatası geri kondu (`mistake_restored_by_editor_agent`). "Yağmur yağıyor" kalıbından gelen, Türkçe konuşan öğrencilerde iyi bilinen bir hata.

## Çeldirici çeşitlendirme (2026-10-19)

- Önce: 59 quizzes, 104 distinct distractors; top: bottle×7, kitchen×7, ticket×6, library×6, pencil×5, umbrella×5
- Sonra: 59 quizzes, 116 distinct distractors; top: menu×4, pencil×4, bread×4, garden×4, holiday×3, lesson×3
- Değişen kart: 11 (`distractors_diversified` işareti eklendi): hair, idea, mistake, window, back, floor, station, weather, kitchen, bathroom, beach.
- Cloze değişen kart: yok. Doğru cevaplar ve cümleler aynı kaldı, yalnızca çeldiriciler değişti.
- `en.hair.n.1`: sayılamayan cevap olduğu için üç çeldirici de sayılamayan isim yapıldı (shampoo, soap, milk). Eski çeldiriciler (umbrella, ticket, bottle) "long, dark ______ ... brushes it" cümlesine dilbilgisi olarak uymuyordu.
- Doğrulayıcı: 0 hata, 0 uyarı (`--strict`).

## Editör kararları (Opus, 2026-10-20)

- `en.key.n.1`, `en.question.n.1`, `en.mistake.n.1`, `en.window.n.1`: ilk örnek başka bir kartın örneğiyle aynıydı (find, ask, make a mistake, open). Yeni kısa örnekler yazıldı (`example_dedup_by_editor_agent`).

## Hafıza ipuçları ve denetim (2026-10-22)

- **Hafıza ipucu:** yazar ajan 26 ipucu önerdi. Şüpheci doğrulayıcı 5 tanesini reddetti, 3 tanesini küçük düzeltmeyle kabul etti. **Eklenen: 21** (`meta.qa_flags`: `mnemonic_added`).
- **Düzeltme:** yazarın 3 önerisinden doğrulayıcının onayladığı 3 tanesi uygulandı (çeviri 1, Dikkat 2). Düzeltilen kartlara `critic_edited` eklendi.
- Yalnızca A1/A2 kartlarına ipucu eklendi. `id`, `lemma`, anlam, `gloss`, `def` ve IPA değişmedi.
- Doğrulayıcı: `59 kart · 59 şemadan geçti · 0 hata · 0 uyarı`

### Eklenen hafıza ipuçları

| Kart | İpucu |
|---|---|
| en.husband.n.1 | 'Husband' içinde 'hus' var: eski İskandinav dilinde 'hús' ev (house) demek. İlk anlamı 'evin sahibi' idi. |
| en.address.n.1 | 'Address' kelimesi 'add' (eklemek) ile başlar: Türkçe 'adres' sözcüğüne bir 'd' ve bir 's' ekle. |
| en.glass.n.1 | Bardak camdan yapılır, bu yüzden ikisi de 'glass'. İki camlı gözlüğe de 'glasses' denir. |
| en.umbrella.n.1 | Latincede 'umbra' gölge demektir: 'umbrella' seni gölgede tutar. |
| en.ticket.n.1 | 'Ticket' ile Türkçedeki 'etiket' aynı Fransızca kelimeden gelir: ikisi de üstünde yazı olan küçük kâğıt. |
| en.news.n.1 | 'News' kelimesi 'new' (yeni) kelimesinden gelir: haber, yeni olan şeydir. |
| en.information.n.1 | Türkçedeki 'enformasyon' ile aynı kelime: enformasyon masası, bilgi aldığın yerdir. |
| en.mistake.n.1 | 'Mis' yanlış, 'take' almak demek: bir şeyi yanlış alırsan hata yaparsın. |
| en.half.n.1 | 'Half' kelimesinde 'l' okunmaz: 'haf' dersin. Tıpkı 'walk' ve 'talk' kelimelerindeki gibi. |
| en.window.n.1 | 'Window' eski İskandinav dilinde 'rüzgâr gözü' demekti: evin, içeri rüzgâr giren gözü. |
| en.meat.n.1 | 'Meat' içinde 'eat' (yemek) var: m + eat. 'Meet' (tanışmak) aynı okunur ama iki 'e' ile yazılır. |
| en.chicken.n.1 | 'Chicken' (tavuk) ile 'kitchen' (mutfak) çok karışır. Tavuk, 'chick' (civciv) ile başlar. |
| en.fruit.n.1 | 'Fruit' tek hece okunur: 'fruut', 'i' sessizdir. Meyve şekeri 'fruktoz' da aynı Latince kökten gelir. |
| en.vegetable.n.1 | 'Vegetable' üç hece okunur: 'VEC-tı-bıl', ikinci 'e' okunmaz. Anlamı için Türkçedeki 'vejetaryen' sözcüğünü düşün. |
| en.meal.n.1 | 'Meal' eskiden 'belli bir zaman' demekti: öğün, belli saatte yenen yemektir. 'Meat' (et) ile karıştırma. |
| en.holiday.n.1 | 'Holiday' = 'holy' (kutsal) + 'day' (gün). İlk anlamı 'kutsal gün', yani bayram. |
| en.library.n.1 | 'Library' 'LAY-bre-ri' diye okunur, 'li' değil. Latincede 'liber' kitap demektir: kitapların yeri. |
| en.pharmacy.n.1 | 'Ph' harfleri 'f' okunur: 'FAR-mı-si'. İlaç bilimi 'farmakoloji' de aynı Yunanca kökten gelir. |
| en.airport.n.1 | 'Air' hava, 'port' liman demek: 'airport' tıpkı Türkçedeki gibi hava + liman. |
| en.hotel.n.1 | Türkçedeki 'otel' ile aynı kelime, ama İngilizcede baştaki 'h' okunur: 'ho-TEL'. |
| en.tooth.n.1 | 'Tooth' çoğulda 'teeth' olur, tıpkı 'foot' (ayak) ve 'feet' gibi: 'oo' gider, 'ee' gelir. |

### Düzeltmeler

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.umbrella.n.1 | examples[2].tr | İstasyona kadar şemsiyeni paylaşabilir miyim? → İstasyona kadar şemsiyenin altına girebilir miyim? | 'Şemsiyeni paylaşmak' İngilizceden birebir çeviri; Türkçede 'şemsiyenin altına girmek' ya da 'şemsiyene girmek' denir. |
| en.dinner.n.1 | l1.tr.mistakes[0] | ✗ I will do dinner tonight. ✓ I will make dinner tonight. (Türkçede 'akşam yemeği yapmak' dersiniz ve 'yapmak' çoğu zaman 'do' sanılır. İngilizcede yemek hazırlamak için 'make' ya da 'cook' kullanılır.) → (silindi) | 'I'll do dinner tonight' günlük İngilizcede doğru ve yaygın ('do' = yemeği hazırlamak; Cambridge: 'Who's doing the dinner?'). Gerçek hata değil. |
| en.beach.n.1 | l1.tr.mistakes[0] | ✗ We go to the sea every weekend in summer. ✓ We go to the beach every weekend in summer. (Türkçede 'denize gitmek' dersiniz. İngilizcede 'go to the sea' mümkündür ama denize doğru gitmek gibi duyulur; yüzmek ve güneşlenmek için doğal söyleyiş 'go to the beach' olur.) → (silindi) | 'Yanlış' cümle doğru İngilizce (İngiliz İngilizcesinde 'go to the sea/seaside' yaygın); maddenin kendisi de 'mümkündür' diyor. Gerçek hata değil. |

### Atılan ipucu önerileri

Zorlama, doğruluğu şüpheli ya da kartta zaten söylenen öneriler atıldı:

- `people`: A1 düzeyinde çok kolay bir kelime; 'popüler' bağı köken olarak doğru ama hatırlamaya yardım etmiyor.
- `key`: Kelime çok kolay ve klavye tuşu bilgisi zaten notta var.
- `room`: Oda/yer ikiliğini notta zaten anlatıyor; yeni bir kanca eklemiyor.
- `kitchen`: Köken doğru ama 'kitchen' ile 'cook' arasındaki bağ öğrencinin gözünde ya da kulağında görünmüyor; zorlama.
- `vacation`: Bağ, A2 öğrencisinin bilmediği 'vacant' kelimesine ve uçak tuvaleti tabelasına dayanıyor; zorlama.
