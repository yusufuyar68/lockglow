# s1 QA incelemesi (ev, yemek, giyim, alışveriş, sağlık, aile)

Kapsam: `content/drafts/kisisel_v1/s1/part_01.json` ... `part_13.json`. Bakılan kriterler: `SYSTEM_C` listesi (anlam, tanım, örnek, Türkçe karşılık, Türkçe çeviri, IPA, seviye, hata, not, etimoloji, quiz).

## Özet

- İncelenen kart: **127**
- Değişen kart: **53** (hepsine `critic_edited` eklendi)
- Toplam düzenleme (alan sayısı): **67**
- Reddedilen kart (`critic_reject`): **0**
- Doğrulayıcı (tüm klasör): `127 kart · 127 şemadan geçti · 0 hata · 0 uyarı`

## Genel bulgular

- Kartların çoğu iyi durumda. İngilizce örnekler doğal, ilk örnekler kilit ekranı için güvenli.
- En yaygın sorun Türkçe yazım: İngilizce sözcükten sonra gelen ek boşlukla ayrılmıştı (`'freezer' dır`). Bu hata 29 notta ve 2 hata açıklamasında vardı. Ek kullanmadan yeniden yazıldı.
- Etimolojiler (spoon, fork, snack, recipe, kettle, dessert, cousin, neighbor, sibling, pajamas, wardrobe, fabric, cash, budget, diet, prescription, vaccine, sofa) tek tek kontrol edildi. Halk etimolojisi yok.
- Sahte dost (sofa, apartment, fabric) kayıtları gerçek. Uydurma sahte dost bulunmadı.
- IPA ve vurgu kontrol edildi. Hata bulunmadı.
- Quiz boşlukları kontrol edildi. Tek bir kartta (teenager) çeldiriciler doğru sayılabiliyordu; düzeltildi.

## Değişiklik tablosu

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.bowl.n.1 | examples[2].tr | Yumurtayı ve unu büyük bir kapta karıştırın. → Yumurtayı ve unu büyük bir kasede karıştırın. | Karşılık 'kase' ile tutarlı değildi; 'kap' bowl'u göstermiyordu. |
| en.recipe.n.1 | l1.tr.mistakes[0].why | Türkçedeki 'pastanın tarifi' (tamlama) yüzünden 'of' denir; İngilizcede yemek için 'recipe for' kullanılır. → Türkçedeki 'pastanın tarifi' tamlaması 'of' dedirtir; oysa İngilizcede yemek için 'recipe for' kalıbı kullanılır. | Eski açıklama 'of' kullanılırmış gibi okunuyordu; belirsizdi. |
| en.leftovers.n.1 | examples[0].tr | Bugün öğle yemeğinde dünden kalanları yedik. → Bugün öğle yemeğinde artan yemekleri yedik. | Çeviriye 'dün' bilgisi eklenmişti; İngilizcede yok. |
| en.leftovers.n.1 | examples[2].tr | Mehmet artan yemeğini kutuda işe götürdü. → Mehmet artan yemeğini bir kutuya koyup işe götürdü. | 'Kutuda götürmek' doğal Türkçe değil. |
| en.bake.v.1 | def.long | To cook food in an oven with dry heat, without oil. People bake bread, cakes, and biscuits, and sometimes fish or potatoes. → To cook food in an oven with dry heat. People bake bread, cakes, and biscuits, and sometimes fish or potatoes. | 'without oil' yanlış: kek ve kurabiyede yağ/tereyağı vardır; tanım gereksiz ve hatalıydı. |
| en.bake.v.1 | l1.tr.note | 'Pasta yapmak' İngilizcede 'bake a cake' olur. 'Bake' yalnızca fırında pişirmektir; tavada pişirmek 'fry', ızgarada pişirmek 'grill' dir. → 'Pasta yapmak' İngilizcede 'bake a cake' olur. 'Bake' yalnızca fırında pişirmektir; tavada pişirmek 'fry', ızgarada pişirmek 'grill' olur. | Yazım hatası: 'grill' dir (ek ayrı yazılmış). |
| en.ripe.adj.1 | examples[0].tr | Bu muzlar henüz olgunlaşmamış. → Bu muzlar henüz olgun değil. | '-miş' (olgunlaşmamış) İngilizcedeki düz cümleye uymuyor; doğal söyleyiş 'olgun değil'. |
| en.ripe.adj.1 | l1.tr.alt | yenecek kıvamda → olmuş (meyve) | 'yenecek kıvamda' sözcük değil, açıklama; gerçek bir karşılık ('olmuş meyve') ile değiştirildi. |
| en.fridge.n.1 | l1.tr.note | Günlük konuşmada 'fridge', resmî yazıda 'refrigerator' kullanılır. Dondurucu bölüm 'freezer' dır. → Günlük konuşmada 'fridge', resmî yazıda 'refrigerator' kullanılır. Dondurucu bölüme 'freezer' denir. | Yazım hatası: 'freezer' dır. |
| en.shower.n.1 | l1.tr.mistakes[0].wrong | I do a shower every day. → I take shower every day. | Eski hata ('do a shower') Türkçeden gelen tipik bir hata değil: 'duş almak' zaten 'take' ile aynı. Gerçek hata 'a' eksikliği. |
| en.shower.n.1 | l1.tr.mistakes[0].why | İngilizcede duş için 'do' veya 'make' kullanılmaz; 'take a shower' ya da 'have a shower' denir. → Türkçede 'bir' demeden 'duş alırım' dersiniz. İngilizcede 'shower' sayılabilir bir isimdir; tekil olduğu için önüne 'a' gelir: take a shower. | Yeni hatanın açıklaması. |
| en.kettle.n.1 | examples[1].tr | Su kaynıyor. Lütfen kapat. → Su ısıtıcısı kaynıyor. Lütfen kapat. | Çeviride 'kettle' kayboluyordu; kart kelimesi görünmeli. |
| en.dishes.n.1 | l1.tr.note | Türkçede 'bulaşık' tek kelimedir; İngilizcede tüm kirli kaplar için çoğul 'the dishes' kullanılır. Bulaşık makinesi 'dishwasher' dır. → Türkçede 'bulaşık' tek kelimedir; İngilizcede tüm kirli kaplar için çoğul 'the dishes' kullanılır. Bulaşık makinesine 'dishwasher' denir. | Yazım hatası: 'dishwasher' dır. |
| en.laundry.n.1 | l1.tr.note | 'Çamaşır' iç çamaşırı da olabilir; İngilizcede 'laundry' yıkanacak ya da yıkanmış giysi yığınıdır. İç çamaşırı 'underwear' dır. → 'Çamaşır' iç çamaşırı da olabilir; İngilizcede 'laundry' yıkanacak ya da yıkanmış giysi yığınıdır. İç çamaşırına 'underwear' denir. | Yazım hatası: 'underwear' dır. |
| en.balcony.n.1 | examples[2].tr | Dairemizin manzarası güzel küçük bir balkonu var. → Dairemizin güzel manzaralı küçük bir balkonu var. | Önceki cümle ('manzarası güzel küçük bir balkonu') bozuk ve anlaşılması zordu. |
| en.pillow.n.1 | l1.tr.note | Uyku yastığı 'pillow', kanepedeki süs yastığı (kırlent) ise 'cushion' dur. → Uyku yastığı 'pillow', kanepedeki süs yastığı (kırlent) ise 'cushion' olur. | Yazım hatası: 'cushion' dur. |
| en.furniture.n.1 | examples[0].tr | Biraz yeni mobilya almamız lazım. → Yeni mobilya almamız lazım. | 'Biraz yeni mobilya' doğal Türkçe değil. |
| en.rent.n.1 | l1.tr.note | Kiracı 'tenant', ev sahibi 'landlord' dur. Fiil olarak 'rent' hem kiralamak hem kiraya vermek için kullanılabilir. → Kiracı 'tenant', ev sahibi 'landlord' olur. Fiil olarak 'rent' hem kiralamak hem kiraya vermek için kullanılabilir. | Yazım hatası: 'landlord' dur. |
| en.vacuum.v.1 | l1.tr.note | Türkçede kısaca 'süpürmek' dersiniz. İngilizcede elektrikli süpürgeyle temizlemek 'vacuum', el süpürgesiyle süpürmek 'sweep' tir. → Türkçede kısaca 'süpürmek' dersiniz. İngilizcede elektrikli süpürgeyle temizlemek 'vacuum', el süpürgesiyle süpürmek 'sweep' olur. | Yazım hatası: 'sweep' tir. |
| en.chore.n.1 | l1.tr.alt | günlük iş, angarya → rutin iş, angarya | 'günlük iş' chore için gerçek bir karşılık değil (meslek gibi anlaşılır). |
| en.chore.n.1 | examples[2].tr | Akşam yemeğinden önce bitirmem gereken bir sürü iş var. → Akşam yemeğinden önce bitirmem gereken bir sürü ev işi var. | Çeviride 'chores' (ev işleri) anlamı kayboluyordu. |
| en.mess.n.1 | l1.tr.alt | karmaşa, pis ortalık → karışıklık | 'pis ortalık' kalıplaşmış bir karşılık değil; 'karmaşa' da dağınık oda için uygun değil. |
| en.leak.v.1 | l1.tr.alt | damlatmak, akıtmak → akmak, damlatmak | 'akıtmak' ettirgen fiil ve leak için uygun değil; 'akmak' (çatı akıyor, kalem aktı) gerçek karşılık. |
| en.leak.v.1 | l1.tr.note | Türkçede 'çatı akıyor' dersiniz; İngilizcede çatı ya da boru özne olur: The roof leaks. İsim olarak 'a leak' sızıntı demektir. → Türkçede 'çatı akıyor' ya da 'musluk damlatıyor' dersiniz; İngilizcede hepsi için 'leak' kullanılır: The roof leaks. İsim olarak 'a leak' sızıntı demektir. | Eski not Türkçe ile İngilizce arasında olmayan bir fark anlatıyordu (iki dilde de özne çatı/boru). |
| en.landlord.n.1 | l1.tr.note | 'Ev sahibi' Türkçede misafir ağırlayan kişi için de kullanılır; İngilizcede kiraya veren kişi 'landlord', misafir ağırlayan 'host' tur. → 'Ev sahibi' Türkçede misafir ağırlayan kişi için de kullanılır; İngilizcede kiraya veren kişi 'landlord', misafir ağırlayan 'host' olur. | Yazım hatası: 'host' tur. |
| en.ceiling.n.1 | l1.tr.note | 'Ceiling' odanın içindeki üst yüzeydir; dışarıdaki çatı 'roof' tur. 'Tavan' kelimesi bazen 'üst sınır' (price ceiling) anlamında da kullanılır. → 'Ceiling' odanın içindeki üst yüzeydir; dışarıdaki çatı 'roof' olur. 'Tavan' kelimesi bazen 'üst sınır' (price ceiling) anlamında da kullanılır. | Yazım hatası: 'roof' tur. |
| en.iron.v.1 | examples[2].en | This shirt has lots of lines. Can you iron it? → This shirt is very wrinkled. Can you iron it? | 'has lots of lines' doğal İngilizce değil; 'wrinkled' kullanılır. |
| en.iron.v.1 | examples[2].tr | Bu gömlek buruşuk. Ütüler misin? → Bu gömlek çok buruşuk. Ütüler misin? | Yeni İngilizce cümleye uygun çeviri. |
| en.iron.v.1 | quiz.cloze | My shirt has lots of lines. I need to ______ it. → My shirt is all wrinkled. I need to ______ it. | 'has lots of lines' doğal İngilizce değil. |
| en.cousin.n.1 | l1.tr.note | Türkçede 'amca çocuğu', 'dayı çocuğu' gibi ayrı söylenen kişilerin hepsi İngilizcede 'cousin' dir. Cinsiyeti belirtmek için 'female cousin' denir. → Türkçede 'amca çocuğu', 'dayı çocuğu' gibi ayrı söylenen kişilerin hepsine İngilizcede 'cousin' denir. Cinsiyeti belirtmek gerekirse 'female cousin' dersiniz. | Yazım hatası: 'cousin' dir. |
| en.neighbor.n.1 | examples[0].tr | Komşumuzun çok sevimli bir köpeği var. → Komşumuzun çok dost canlısı bir köpeği var. | 'friendly' = dost canlısı; 'sevimli' (cute) anlamı kaydırıyordu. |
| en.neighbor.n.1 | l1.tr.note | Ortadaki 'gh' okunmaz: 'ney-bır'. 'Neighborhood' mahalle demektir. İngiliz yazımı 'neighbour' dur. → Ortadaki 'gh' okunmaz: 'ney-bır'. 'Neighborhood' mahalle demektir. İngiliz yazımı 'neighbour' olur. | Yazım hatası: 'neighbour' dur. |
| en.nephew.n.1 | l1.tr.note | Türkçede 'yeğen' erkek ya da kız olabilir; İngilizcede erkek yeğen 'nephew', kız yeğen 'niece' dir. → Türkçede 'yeğen' erkek ya da kız olabilir; İngilizcede erkek yeğen 'nephew', kız yeğen 'niece' olur. | Yazım hatası: 'niece' dir. |
| en.niece.n.1 | l1.tr.note | Türkçede erkek ve kız çocuğu için ortak 'yeğen' kullanılır; İngilizcede kız yeğen 'niece' dir. → Türkçede erkek ve kız çocuğu için ortak 'yeğen' kullanılır; İngilizcede kız yeğen 'niece' olur. | Yazım hatası: 'niece' dir. |
| en.teenager.n.1 | quiz.distractors | toddler, relative, grandparent → toddler, baby, grandparent | 'relative' çeldirici de doğru sayılabilir (ağabey bir akrabadır); tek doğru cevap kalsın diye 'baby' yapıldı. |
| en.engaged.adj.1 | examples[2].tr | Onlar nişanlı ve gelecek yaz evlenmek istiyor. → Onlar nişanlı ve gelecek yaz evlenmek istiyorlar. | 'Onlar' öznesiyle fiil çoğul olmalı (istiyorlar). |
| en.coat.n.1 | l1.tr.note | Uzun ve sıcak dış giysilerin hepsi (mont, palto, kaban) 'coat' tur. Daha kısa ve hafif olanlara 'jacket' denir. → Uzun ve sıcak dış giysilerin hepsine (mont, palto, kaban) 'coat' denir. Daha kısa ve hafif olanlara 'jacket' denir. | Yazım hatası: 'coat' tur. |
| en.jacket.n.1 | l1.tr.note | Takım elbisenin ceketi de 'jacket' tır. Günlük dış giysi olan mont için de kullanılır; çok kalın olanlara 'coat' denir. → Takım elbisenin ceketi de İngilizcede 'jacket' olur. Günlük dış giysi olan mont için de kullanılır; çok kalın olanlara 'coat' denir. | Yazım hatası: 'jacket' tır. |
| en.sock.n.1 | l1.tr.note | Çift için 'a pair of socks' denir; tek çorap 'a sock' tır. İnce kadın çorabı (külotlu çorap) için 'tights' kullanılır. → Çift için 'a pair of socks' denir; tek çorap ise 'a sock' olur. İnce kadın çorabı (külotlu çorap) için 'tights' kullanılır. | Yazım hatası: 'a sock' tır. |
| en.size.n.1 | l1.tr.note | Giysi için 'beden', ayakkabı için 'numara' dersiniz; İngilizcede ikisi de 'size' dır: What size are you? → Giysi için 'beden', ayakkabı için 'numara' dersiniz; İngilizcede ikisine de 'size' denir: What size are you? | Yazım hatası: 'size' dır. |
| en.scarf.n.1 | l1.tr.note | Kalın, boyna takılan 'atkı' ile ince 'eşarp' ya da 'şal' İngilizcede 'scarf' tır. Çoğulu 'scarves' tır (scarfs da kabul edilir). → Kalın, boyna takılan 'atkı' ile ince 'eşarp' ya da 'şal' için İngilizcede 'scarf' denir. Çoğulu 'scarves' olur (scarfs da kabul edilir). | Yazım hatası: 'scarf' tır, 'scarves' tır. |
| en.slipper.n.1 | l1.tr.note | Ev terliği 'slippers', plaj terliği ise 'flip-flops' tır. Genellikle çift olarak, çoğul kullanılır. → Ev terliği 'slippers', plaj terliğine ise 'flip-flops' denir. Genellikle çift olarak, çoğul kullanılır. | Yazım hatası: 'flip-flops' tır. |
| en.fit.v.1 | l1.tr.note | Giysi için 'bana oluyor / uyuyor', bir yere sığma için 'sığmak' dersiniz; İngilizcede ikisi de 'fit'. 'Yakışmak' ise 'suit' tir. → Giysi için 'bana oluyor / uyuyor', bir yere sığma için 'sığmak' dersiniz; İngilizcede ikisi de 'fit'. 'Yakışmak' ise 'suit' olur. | Yazım hatası: 'suit' tir. |
| en.fit.v.1 | l1.tr.mistakes[0].why | Beden olarak uymak 'fit', yakışmak ise 'suit' tir. Küçük geldiği için 'fit' demelisiniz. → Beden olarak uymak 'fit', yakışmak ise 'suit' olur. Küçük geldiği için 'fit' demelisiniz. | Yazım hatası: 'suit' tir. |
| en.sleeve.n.1 | l1.tr.note | Giysinin kolu 'sleeve', vücudunuzun kolu 'arm' dır. 'Kısa kollu' = short-sleeved; kolsuz = sleeveless. → Giysinin kolu 'sleeve', vücudunuzun kolu 'arm' olur. 'Kısa kollu' = short-sleeved; kolsuz = sleeveless. | Yazım hatası: 'arm' dır. |
| en.sleeve.n.1 | l1.tr.mistakes[0].why | Türkçede giysi kolu da 'kol' dur; İngilizcede giysinin kolu 'sleeve', vücudun kolu 'arm' denir. → Türkçede giysi kolu da vücut kolu da 'kol' sözcüğüyle söylenir; İngilizcede giysinin kolu 'sleeve', vücudun kolu 'arm' denir. | Yazım hatası: 'kol' dur (boşluklu ek). |
| en.fabric.n.1 | l1.tr.note | Türkçedeki 'fabrika' İngilizcede 'factory' dir. 'Fabric' kumaştır. İkisi aynı Latince köke (fabrica) dayanır. → Türkçedeki 'fabrika' İngilizcede 'factory' olur. 'Fabric' kumaştır. İkisi aynı Latince köke (fabrica) dayanır. | Yazım hatası: 'factory' dir. |
| en.price.n.1 | l1.tr.note | Fiyat 'high' ya da 'low' olur; 'pahalı' ve 'ucuz' ise ürün için 'expensive' ve 'cheap' dir. → Fiyat 'high' ya da 'low' olur; 'pahalı' ve 'ucuz' ise ürün için 'expensive' ve 'cheap' ile söylenir. | Yazım hatası: 'cheap' dir. |
| en.cash.n.1 | l1.tr.mistakes[0].why | Kart için 'by card' denir ama nakit için 'in cash' kullanılır; 'by cash' yanlıştır. → Kart için 'by card' denir; nakit için en doğal kalıp 'in cash' olur. 'By cash' anlaşılır ama daha az doğaldır. | 'by cash yanlıştır' iddiası fazla kesindi; anadili konuşanlar da bazen kullanır. |
| en.cost.v.1 | l1.tr.mistakes[0].wrong | How much costs this? → How much this costs? | Türkçe sözdizimine (özne önde) bağlı tipik hata bu; eski cümle ('How much costs this?') Türkçe etkisi gibi durmuyordu. |
| en.cost.v.1 | l1.tr.mistakes[0].why | Soruda 'does' gerekir; 'cost' fiili yalın kalır: How much does this cost? → Soruda 'does' gerekir ve özne 'does'tan sonra gelir; 'cost' fiili yalın kalır: How much does this cost? | Yeni hataya uygun açıklama. |
| en.bill.n.1 | l1.tr.note | Evde ödenen fatura ve restoranda istenen 'hesap' İngilizcede 'bill' dir. Banka hesabı ise 'account' tur. → Evde ödenen fatura ve restoranda istenen 'hesap' İngilizcede 'bill' olur. Banka hesabı ise 'account' diye geçer. | Yazım hatası: 'bill' dir, 'account' tur. |
| en.delivery.n.1 | l1.tr.alt | kargo, kurye → kargo, eve servis | 'kurye' kişidir (courier), 'delivery' hizmetinin karşılığı değil. |
| en.delivery.n.1 | l1.tr.note | Türkçede paket için 'kargo', yemek için 'kurye' ya da 'eve servis' dersiniz; İngilizcede hepsi 'delivery'. → Türkçede paket için 'kargo', yemek için 'eve servis' dersiniz; İngilizcede hepsi 'delivery'. | Alt listesiyle uyum; 'kurye' kişidir. |
| en.refund.n.1 | l1.tr.note | Ürünü geri vermek 'return', parayı geri almak 'refund' dır: I returned the shirt and got a refund. → Ürünü geri vermek 'return', parayı geri almak 'refund' olur: I returned the shirt and got a refund. | Yazım hatası: 'refund' dır. |
| en.groceries.n.1 | l1.tr.note | 'Groceries' hep çoğul kullanılır. 'Grocery store' bakkal ya da küçük market demektir; büyük market için 'supermarket' denir. → 'Groceries' hep çoğul kullanılır. 'Grocery store' yiyecek ve ev ihtiyaçları satan market demektir; büyük olanına 'supermarket' da denir. | 'bakkal ya da küçük market' yanlış: ABD'de grocery store büyük market de olabilir. |
| en.headache.n.1 | examples[2].tr | Ekrana çok bakmak bana baş ağrısı yapıyor. → Ekrana çok bakmak başımı ağrıtıyor. | 'Bana baş ağrısı yapıyor' doğal değil; 'başımı ağrıtıyor' daha doğru. |
| en.hurt.v.1 | l1.tr.alt | acımak, canı yanmak → acımak | 'canı yanmak' ağrımak değil, incinmek/yanmak anlamı; bu anlam için alt değil. |
| en.flu.n.1 | def.micro | serious illness with a fever → bad illness with a fever | 'serious illness' abartılı: grip çoğu zaman ağır bir hastalık değildir. |
| en.cough.v.1 | l1.tr.note | İsim olarak 'a cough' öksürüktür: I have a cough. Okunuşu 'kof' dur (ough = of); 'though' gibi değil. → İsim olarak 'a cough' öksürüktür: I have a cough. Okunuşu 'kof' gibidir (ough = of); 'though' gibi değil. | Yazım hatası: 'kof' dur. |
| en.sore.adj.1 | l1.tr.mistakes[0].why | Türkçedeki 'boğaz ağrısı' tamlamasından 'pain throat' çıkarılır; İngilizcede 'sore throat' denir. → Türkçedeki 'boğaz ağrısı' tamlamasını kelime kelime çevirince 'pain throat' çıkar. İngilizcede doğru kalıp 'sore throat'. | Eski cümle ('çıkarılır') anlaşılması zor ve bozuktu. |
| en.pain.n.1 | l1.tr.note | Türkçede vücut ağrısı için 'ağrı', duygusal acı için 'acı' dersiniz; İngilizcede ikisi de 'pain' dir. 'In pain' = acı çeken. → Türkçede vücut ağrısı için 'ağrı', duygusal acı için 'acı' dersiniz; İngilizcede ikisine de 'pain' denir. 'In pain' = acı çeken. | Yazım hatası: 'pain' dir. |
| en.exercise.n.1 | examples[2].tr | Doktorlar daha çok egzersiz ve daha az şeker gerektiğini söylüyor. → Doktorlar daha çok egzersiz yapıp daha az şeker yememiz gerektiğini söylüyor. | Önceki çeviri ('egzersiz ve daha az şeker gerektiğini') dilbilgisi olarak eksik ve kulağa yapay. |
| en.prescription.n.1 | l1.tr.note | İlaç reçetesi 'prescription', yemek tarifi 'recipe' dir. Reçetesiz satılan ilaç için 'over-the-counter medicine' denir. → İlaç reçetesi 'prescription', yemek tarifi 'recipe' olur. Reçetesiz satılan ilaç için 'over-the-counter medicine' denir. | Yazım hatası: 'recipe' dir. |
| en.allergy.n.1 | l1.tr.note | Türkçe 'alerji' ile aynı kökten gelir; ilk hecede vurgulanır ve 'g' /dʒ/ okunur. Sıfatı 'allergic' tir: I'm allergic to milk. → Türkçe 'alerji' ile aynı kökten gelir; ilk hecede vurgulanır ve 'g' /dʒ/ okunur. Sıfatı 'allergic' olur: I'm allergic to milk. | Yazım hatası: 'allergic' tir. |
| en.vaccine.n.1 | examples[0].tr | Çocuklar ilk yıllarında birkaç aşı olur. → Çocuklara hayatlarının ilk yılında birkaç aşı yapılır. | 'ilk yıllarında' (first years) ≠ 'first year'; çeviri yanlış sayıyı gösteriyordu. |
| en.vaccine.n.1 | l1.tr.mistakes[0].why | Türkçede 'aşı oldum' dersiniz; İngilizcede 'do' kullanılmaz, 'get a vaccine' ya da 'get vaccinated' denir. → Türkçede 'aşı oldum' ya da 'aşı yaptırdım' dersiniz; İngilizcede 'do' veya 'make' kullanılmaz, 'get a vaccine' ya da 'get vaccinated' denir. | Hatanın Türkçe kaynağı ('aşı yaptırdım') açıkça gösterildi; eski açıklama 'aşı oldum' ile 'do' arasında bağ kuramıyordu. |

## Emin olunmayan kartlar (anadil kontrolü için)

- **en.change.n.2**: `mistakes[0]` 'Here is your rest.' Türk konuşurlar için gerçek bir hata mı? 'Üstü kalsın' için 'keep the rest' daha olası. Dokunulmadı.
- **en.cost.v.1**: Karşılık 'mal olmak'. Fiyat sorusunda 'tutmak' / 'etmek' (ne kadar tutar, kaç eder) daha doğal olabilir. Sıra değişmedi.
- **en.mess.n.1**: Yeni alt 'karışıklık' dağınık oda için yeterince doğal mı? Eski 'pis ortalık' ve 'karmaşa' çıkarıldı.
- **en.ripe.adj.1**: Yeni alt 'olmuş (meyve)' widget'ta anlaşılır mı? Eski 'yenecek kıvamda' sözcük değil açıklamaydı.
- **en.uncle.n.1, en.aunt.n.1, en.relative.n.1**: 'holiday' çevirisi 'bayram'. Ya 'tatil' olmalı ya da bayram bağlamı kalmalı. Dokunulmadı.
- **en.taste.v.1**: Karşılık 'tadı ... olmak' bir kalıp. Sözlük karşılığı olarak yeterince doğal mı?
- **en.tidy.adj.1**: Alt 'toplu' tek başına 'tidy' için kullanılıyor mu? 'derli toplu' içinde yaygın.
- **en.sleeve.n.1**: Karşılık 'giysi kolu'. Günlük dilde 'kol', yazı dilinde 'yen' var; hangisi birinci olmalı?
- **en.fit.v.1**: Karşılık 'uymak, tam gelmek'. 'Tam gelmek' doğal mı? 'Bana oluyor' gibi bir kalıp daha iyi olabilir.
- **en.leak.v.1**: Karşılık 'sızdırmak'. 'Çatı akıyor' çok yaygın olduğu için 'akmak' birinci karşılık olmalı mı? Şimdilik alt listesine eklendi.
- **en.fever.n.1**: `mistakes[0]` 'I have fire ...' gerçekçi mi? Mantıklı ama sık görülen bir hata mı bilinmiyor.
- **en.cheap.adj.1**: `mistakes[0]` 'The price is very cheap.' İngilizce anadil konuşurları 'cheap price' diyebilir. Hata sayılmalı mı? Ayrıca `examples[2]` ikinci cümle (I think it's low quality) kelimeyi açıklıyor gibi.
- **en.vaccine.n.1**: `mistakes[0]` 'I did the vaccine.' Türk konuşurlar için yaygın mı? 'Aşı yaptırdım' kaynağı varsayıldı.
- **en.dessert.n.1**: Eş anlam 'pudding' yalnızca İngiliz İngilizcesinde geçerli. Türkçedeki 'puding' ile karışabilir. Dokunulmadı.
- **en.trousers.n.1, en.scarf.n.1**: Çeviride 'giymişti' / 'takmıştı' kullanıldı. Kıyafet betimlemesi için doğal ama basit geçmiş de olabilir. Dokunulmadı.
- **en.delicious.adj.1**: `mistakes[0]` 'very delicious' tartışmalı: anadil konuşurları da kullanır. Açıklama zaten yumuşak ('pek kullanılmaz'), olduğu gibi bırakıldı.

## Sayılar

| Ölçü | Sayı |
|---|---|
| İncelenen kart | 127 |
| Değişen kart | 53 |
| Düzenlenen alan | 67 |
| Reddedilen kart | 0 |
| Doğrulayıcı sonucu | 0 hata, 0 uyarı |

## Çeldirici çeşitlendirme (2026-10-19)

- Önce: 127 quizzes, 166 distinct distractors; top: towel×17, recipe×16, menu×11, wear×10, receipt×9, tidy×9
- Sonra: 127 quizzes, 173 distinct distractors; top: menu×5, receipt×5, wash×5, drink×5, cheap×5, window×5 (hiçbir çeldirici 5'ten fazla değil; hedef 6)
- Değişen kart: 38 (yalnızca `quiz.distractors` ve `meta.qa_flags`; her birine `"distractors_diversified"` eklendi).
- `quiz.cloze` değiştirilen kart: yok. Doğru cevaplar ve cümleler aynı kaldı.
- `recipe`/`menu`/`receipt` üçlüsü (karıştırılan sözcükler) yalnızca `recipe`, `receipt`, `prescription`, `medicine`, `parcel`, `ingredient`, `sale` gibi sınav değeri olan kartlarda bırakıldı; diğer yerlerde konuya yakın ama cümleye uymayan sözcüklerle (mutfak, ev, alışveriş, sağlık) değiştirildi.
- Doğrulayıcı: `python -m vocabpipe.validate --strict` → 0 hata · 0 uyarı.

## Hafıza ipuçları ve denetim (2026-10-22)

- **Hafıza ipucu:** yazar ajan 31 ipucu önerdi. Şüpheci doğrulayıcı 7 tanesini reddetti, 4 tanesini küçük düzeltmeyle kabul etti. **Eklenen: 24** (`meta.qa_flags`: `mnemonic_added`).
- **Düzeltme:** yazarın 4 önerisinden doğrulayıcının onayladığı 4 tanesi uygulandı (çeviri 1, Dikkat 2, quiz 1). Düzeltilen kartlara `critic_edited` eklendi.
- Yalnızca A1/A2 kartlarına ipucu eklendi. `id`, `lemma`, anlam, `gloss`, `def` ve IPA değişmedi.
- Doğrulayıcı: `127 kart · 127 şemadan geçti · 0 hata · 0 uyarı`

### Eklenen hafıza ipuçları

| Kart | İpucu |
|---|---|
| en.boil.v.1 | Türkçedeki 'boyler' (sıcak su kazanı) İngilizce 'boiler' kelimesinden gelir: 'boiler' suyu kaynatan kazan. |
| en.fry.v.1 | Patates kızartmasına 'French fries' denir: 'fry' kızartmak, 'fries' kızarmış patates. |
| en.apartment.n.1 | 'Apartment' apartman değil, tek bir daire! Bütün bina 'apartment building'. |
| en.kettle.n.1 | Türkiye'de de mutfakta 'kettle' denir: suyu hızla kaynatan elektrikli ısıtıcı. |
| en.housework.n.1 | 'Housework' evin (house) işi: temizlik, ütü. 'Homework' ise okul ödevi: evde (home) yapılan ders işi. |
| en.rent.n.1 | Tatil yerlerindeki 'Rent a Car' tabelalarını hatırla: araba kiralama. 'Rent' kira demek. |
| en.aunt.n.1 | ABD'de çoğu kişi 'aunt' kelimesini 'ant' (karınca) gibi okur. Yazarken 'u' harfini unutma: a-u-n-t. |
| en.grandparent.n.1 | 'Grand' büyük demek: grand + mother = büyükanne, grand + father = büyükbaba. Tıpkı Türkçedeki gibi. |
| en.neighbor.n.1 | 'Neigh-' eski İngilizcede 'yakın' demekti (bugünkü 'near' ile akraba): yakında oturan kişi, komşu. |
| en.jacket.n.1 | Türkçedeki 'ceket' ile aynı kökten gelir; okunuşu 'CEK-it'. |
| en.size.n.1 | Türkçedeki 'size' ile aynı yazılır: mağazada 'Size hangi beden lazım?' diye düşün. Okunuşu 'sayz'. |
| en.button.n.1 | Ekrandaki 'buton' ile aynı kökten: gömlekteki düğme de, asansördeki tuş da 'button'. |
| en.slipper.n.1 | 'Slip' kaymak demek: ayağını içine kaydırıp giydiğin ev ayakkabısı 'slipper'. |
| en.fit.v.1 | Yapboz parçası yerine tam oturunca 'It fits!' denir; ayakkabı ayağına tam olunca da öyle. |
| en.wardrobe.n.1 | Ward (korumak) + robe (elbise): elbiseleri koruyan dolap. Türkçedeki 'gardırop' da aynı kelimeden. |
| en.price.n.1 | 'Price' (fiyat) 'c' ile yazılır: cüzdan. 'Prize' (ödül) 'z' ile: zafer. Okunuşları da farklı: prays, prayz. |
| en.change.n.2 | 'Change' değiştirmek demek; büyük parayı küçüklerle değiştirmek gibi düşün: para üstü ve bozukluk da 'change'. |
| en.receipt.n.1 | Satıcı paranı alır (receive), sana 'receipt' verir: ikisi aynı kökten. |
| en.discount.n.1 | 'Dis-' (dışarı) + 'count' (saymak): fiyatın bir kısmını hesaptan çıkarmak, yani indirim. |
| en.cash.n.1 | Türkçedeki 'kasa' ile aynı kökten (Latince 'capsa': kutu): kasadaki para 'cash'. |
| en.save.v.2 | Bilgisayarda dosya kaybolmasın diye 'save' tuşuna basarsın; parayı harcamayıp saklamak da 'save'. |
| en.headache.n.1 | Head (baş) + ache (ağrı). 'Ache' içindeki 'ch' k gibi okunur: 'hed-eyk'. Toothache = diş ağrısı. |
| en.flu.n.1 | 'Flu', 'influenza' kelimesinin kısa hâli; gribin tıptaki adı Türkçede de 'enflüanza'. |
| en.sick.adj.1 | 'Seasick' (deniz + hasta) deniz tutması, 'homesick' (ev + hasta) sıla hasreti: ikisinde de 'sick' hasta demek. |

### Düzeltmeler

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.fork.n.1 | quiz.distractors[2] | plate → kettle | 'plate' de doğru: 'I need a knife and a plate for this steak' tamamen doğal. |
| en.delicious.adj.1 | l1.tr.mistakes[0] | ✗ This cake is very delicious. ✓ This cake is really delicious. ('Delicious' zaten 'çok güzel' demektir; 'very' ile pek kullanılmaz. Vurgu için 'really' ya da 'absolutely' kullanın.) → (silindi) | 'very delicious' İngilizcede kabul edilebilir (rehberde örnek); gerçek hata değil. |
| en.cash.n.1 | l1.tr.mistakes[0] | ✗ I'll pay by cash. ✓ I'll pay in cash. (Kart için 'by card' denir; nakit için en doğal kalıp 'in cash' olur. 'By cash' anlaşılır ama daha az doğaldır.) → (silindi) | 'pay by cash' kabul edilebilir (why kendisi de 'anlaşılır' diyor); gerçek hata değil. |
| en.second_hand.adj.1 | examples[2].tr | Kenji eski telefonunu ikinci el bir dükkâna sattı. → Kenji eski telefonunu bir ikinci el dükkânına sattı. | Eski çeviri dükkânın kendisini ikinci el gibi okutuyordu; önerilen 'eşya alan' ise bilgi ekliyor, doğal kalıp 'ikinci el dükkânı'. |

### Atılan ipucu önerileri

Zorlama, doğruluğu şüpheli ya da kartta zaten söylenen öneriler atıldı:

- `plate`: Plaka-levha-tabak zinciri dolaylı; ikinci yarısı notu (bowl) tekrar ediyor ve kelime zaten kolay.
- `fridge`: 'Frigorifik' A2 öğrencisi için yaygın değil, Latince kök anlatımı ağır; kelime zaten kolay.
- `shower`: Kartın anlamı (duş) dışında ikinci bir anlam (sağanak) getiriyor; A1 için kafa karıştırır, kanca zayıf.
- `sofa`: Notu ve sahte dost alanını aynen tekrar ediyor; bugün çoğu Türk 'sofa'yı zaten kanepe sanır, karışıklık zayıf.
- `laundry`: Köken doğru ama 'lavabo' ile 'laundry' arasındaki ses bağı zayıf ve Latince kök A2 için uzak.
- `relative`: Kanca A2 öğrencisinin bilmediği 'related' kelimesine dayanıyor; akılda bağ kurmuyor.
- `coat`: Türk öğrenciler 'coat' ile 'kot' kelimesini karıştırmaz; olmayan bir karışıklık yaratıyor.

### Anadili Türkçe birinin bakması gerekenler

- en.groceries.n.1 ex[1]: 'Taşımama' çeviride eklenmiş; 'Market alışverişi arabada' biraz yapay (dokunulmadı)
- en.dishes.n.1 quiz: 'stairs' (do the stairs = merdiveni temizlemek, İngiltere) sınırda (dokunulmadı)
- en.cheap.adj.1 Dikkat[0]: 'The price is very cheap' günlük İngilizcede de duyulur; sınırda (dokunulmadı)
- en.bargain.n.1 Dikkat[0]: 'make a bargain' = anlaşma yapmak, İngilizcede doğru bir söz; sınırda (dokunulmadı)
- en.sofa.n.1: Türkçede 'sofa' (hol) bugün ne kadar biliniyor, anadili Türkçe biri baksın.
- en.second_hand.adj.1 ex[2]: 'ikinci el dükkânı' mı 'ikinci elci' mi daha doğal, anadili Türkçe biri baksın.
