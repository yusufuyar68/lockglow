# s4 QA incelemesi (phrasal verb, 100 kart)

Kapsam: `content/drafts/kisisel_v1/s4/part_01..10.json`. Her kart tek tek okundu: Türkçe gloss, kalıp ve ayrılabilirlik, örnekler ve çeviriler, tanım, IPA, seviye, hata listesi, quiz.

## Özet

- İncelenen kart: **100**
- Değişen kart: **31** (toplam 44 alan değişikliği)
- Reddedilen kart (`critic_reject`): **0**
- Değişen her karta `critic_edited` bayrağı eklendi. Mevcut bayraklar korundu.
- `id`, `lemma`, `pos`, `sense_no`, `meta.status` değişmedi.
- Dosya biçimi korundu (1-7 kompakt satır biçimi, 8-10 girintili CRLF biçimi).
- Doğrulayıcı: `100 kart · 100 şemadan geçti · 0 hata · 0 uyarı`.

## Son editör değişikliklerinin kontrolü

- `catch up` → "buluşup sohbet etmek": iyi okunuyor. Alt anlamlar da gerçek. Yalnızca notta 'haberleşmek' vardı, düzeltildi.
- `end up` → "sonunda kendini bulmak": tek başına 'kendini keşfetmek' gibi okunabiliyor. "sonunda kendini ... bulmak" yapıldı. `alt` zaten '...' kullanıyordu.
- `go on` → "olmak, yaşanmak": 'What's going on?' = 'Neler oluyor?' ile uyumlu. Değiştirilmedi. Yerel konuşur kontrolü için listede.

## Değişiklik tablosu

| Kart | Alan | Önce / Sonra | Neden |
|---|---|---|---|
| en.take_off.phv.1 | mistakes[0] | Önce: Please take off the shoes at the door. → Please take off your shoes at the door.<br>Sonra: Please take out your shoes at the door. → Please take off your shoes at the door. | Eski hata ('the shoes') gerçek bir hata değildi. Yerine gerçek Türkçe kaynaklı hata kondu: çıkarmak → take out. |
| en.sit_down.phv.1 | alt | Önce: yerine oturmak<br>Sonra: [] | 'yerine oturmak' Türkçede 'birinin yerini almak' gibi anlaşılır. Gerçek bir karşılık değil. |
| en.sit_down.phv.1 | mistakes[0] | Önce: My grandmother is sitting down near the window. → My grandmother is sitting near the window.<br>Sonra: We sat down to a table by the window. → We sat down at a table by the window. | Eski hata ('is sitting down') yanlış değildi. Yerine tipik edat hatası kondu (-e hâli → to). |
| en.come_back.phv.1 | def.micro | Önce: be here or there again<br>Sonra: return to a place | Eski micro ('be here or there again') anlaşılmaz ve anlama uymuyordu. |
| en.go_back.phv.1 | quiz.distractors | Önce: come in / get off / put on<br>Sonra: stay in / get off / put on | 'come in' çeldirici de uyabilirdi ('come in to my office'). 'stay in' ile değiştirildi. |
| en.look_after.phv.1 | gloss | Önce: (birine) bakmak<br>Sonra: bakmak, ilgilenmek | '(birine) bakmak' 'birine bakmak = look at someone' gibi okunabilir. 'ilgilenmek' eklenerek bakım anlamı netleştirildi. |
| en.look_after.phv.1 | alt | Önce: ilgilenmek / göz kulak olmak<br>Sonra: göz kulak olmak | Yeni gloss ile uyumlu. 'ilgilenmek' artık gloss içinde. |
| en.pick_up.phv.1 | quiz.cloze | Önce: Your keys fell down. Please ______ them from the floor.<br>Sonra: There is a coin on the floor. Can you ______ the coin? | Eski cümle 'pick up them' çıkarıyordu. Kartın kendi kuralına aykırıydı (zamir ortaya girer). |
| en.get_off.phv.1 | quiz.cloze | Önce: This is my stop. I'll ______ here.<br>Sonra: I'm on the bus and this is my stop. I'll ______ here. | Eski cümlede 'get on' (durakta binmek) de uyabilirdi. 'I'm on the bus' eklendi. |
| en.try_on.phv.1 | quiz.cloze | Önce: I like these jeans. Can I ______ them in the fitting room?<br>Sonra: I like these jeans. Can I ______ a pair in the fitting room? | Eski cümle 'try on them' çıkarıyordu. Kartın kendi kuralına aykırıydı. |
| en.try_on.phv.1 | quiz.distractors | Önce: take off / look for / pick up<br>Sonra: take off / turn on / give up | 'look for' ve 'pick up' yeni cümlede de uyabilirdi. Net yanlış çeldiriciler seçildi. |
| en.fill_in.phv.1 | examples[2].tr | Önce: Ayşe çevrimiçi formu doldurup gönder'e tıkladı.<br>Sonra: Ayşe çevrimiçi formu doldurup Gönder düğmesine tıkladı. | 'gönder'e' yazımı hatalı (küçük harf + kesme). Daha doğal ve doğru yazım. |
| en.check_in.phv.1 | examples[2].tr | Önce: Mehmet giriş işlemini yaptırıp doğrudan odasına çıktı.<br>Sonra: Mehmet giriş işlemini yaptırıp doğrudan odasına gitti. | 'odasına çıktı' İngilizcede olmayan bir bilgi ekliyordu (yukarı çıkmak). 'gitti' yapıldı. |
| en.check_in.phv.1 | quiz.cloze | Önce: Our flight is at nine. We must ______ two hours before.<br>Sonra: Our flight is at nine. We must ______ at the airport two hours before. | Eski cümlede 'check out' (otel) de uyabilirdi. 'at the airport' eklendi, tek cevap kaldı. |
| en.slow_down.phv.1 | mistakes[0] | Önce: Please slow down your speed. → Please slow down.<br>Sonra: Please slow down it a little. → Please slow it down a little. | Eski hata ('slow down your speed') Türkçe kaynaklı tipik bir hata değildi. Kartın ayrılabilir kuralına bağlı hata kondu. |
| en.write_down.phv.1 | note | Önce: 'Not almak' derste ya da toplantıda not tutmaktır ('take notes'). 'Write down' ise tek bir bilgiyi unutmamak için yazmaktır.<br>Sonra: 'Write down' tek bir bilgiyi (numara, adres) unutmamak için yazmaktır. Derste ya da toplantıda sürekli not tutmak için 'take notes' denir. | Eski not 'not almak' sözünü yalnızca ders notu sayıyordu. Ama 'numarayı not almak' da yaygın ve alt listede var. Çelişki giderildi. |
| en.log_out.phv.1 | examples[2] | Önce: You will log out automatically after ten minutes. / On dakika sonra oturumunuz otomatik olarak kapanır.<br>Sonra: Ayşe logged out of the app and went to bed. / Ayşe uygulamadan çıkış yapıp yattı. | 'You will log out automatically' doğal değil (doğrusu: you will be logged out). Doğal ve kartın 'log out of' kalıbını gösteren örnek yazıldı. |
| en.turn_up.phv.1 | mistakes[0] | Önce: Open the music, please. → Turn up the music, please.<br>Sonra: Please open the volume. → Please turn up the volume. | Eski hata ('Open the music') 'müziği aç' = turn on anlamına gelir, turn up değil. Eşleşme yanlıştı. |
| en.turn_down.phv.1 | mistakes[0] | Önce: Close the music, please. → Turn down the music, please.<br>Sonra: Please turn down it a little. → Please turn it down a little. | Eski hata ('Close the music'): 'sesi kıs' ifadesi 'close'a çevrilmez. Uydurma hata. Yerine zamir hatası kondu. |
| en.stay_in.phv.1 | quiz.cloze | Önce: It's very cold outside. Let's ______ and drink tea.<br>Sonra: It's very cold outside. Let's ______ and drink tea at home. | Eski cümlede 'go out' da uyabilirdi (dışarıda çay). 'at home' eklendi. |
| en.look_around.phv.1 | examples[1].tr | Önce: Öğle yemeğinden önce eski mahalleyi gezip görelim.<br>Sonra: Öğle yemeğinden önce eski şehri gezip görelim. | 'old town' = eski şehir. 'eski mahalle' farklı bir şey. |
| en.look_around.phv.1 | mistakes | Önce: Look at around you! → Look around you!<br>Sonra: [] | 'Look at around you' tipik bir Türkçe kaynaklı hata değil, uydurma. Silindi. |
| en.set_up.phv.1 | examples[1].tr | Önce: Wi-Fi'ı kurmama yardım eder misin?<br>Sonra: Wi-Fi'yi kurmama yardım eder misin? | Yazım: 'Wi-Fi' sesli harfle biter (vayfay), belirtme eki -yi olur. |
| en.hang_out.phv.1 | mistakes[0] | Önce: I hang out to my friends on Sundays. → I hang out with my friends on Sundays.<br>Sonra: I hang out my friends on Sundays. → I hang out with my friends on Sundays. | Eski hata ('hang out to') Türkçe '-la' ekiyle çelişiyordu (-la = with). Gerçek hata 'with'i atlamak. |
| en.look_up.phv.1 | gloss | Önce: bakıp bulmak<br>Sonra: bakmak, araştırmak | 'bakıp bulmak' Türkçede bu anlamda kullanılan bir fiil değil. Örnek çevirilerde de 'bakmak' kullanılıyor. |
| en.look_up.phv.1 | alt | Önce: aramak / araştırmak<br>Sonra: sözlüğe bakmak / internette aramak | Yeni gloss ile uyumlu, gerçek karşılıklar. |
| en.come_over.phv.1 | gloss | Önce: eve gelmek<br>Sonra: (birinin) evine gelmek | 'eve gelmek' 'come home' gibi anlaşılır. Ziyaret anlamı net değildi. |
| en.come_over.phv.1 | alt | Önce: uğramak / ziyarete gelmek<br>Sonra: bize gelmek / uğramak / ziyarete gelmek | Not ve örneklerle uyumlu ('bize gelmek' en doğal söyleyiş). |
| en.come_over.phv.1 | quiz.distractors | Önce: Check out / Eat out / Hang up<br>Sonra: Check out / Get off / Hang up | 'Eat out for dinner tonight!' da cümleye uyabilirdi. Net yanlış çeldirici seçildi. |
| en.sleep_in.phv.1 | note | Önce: Türkçede 'geç saate kadar uyumak' ya da 'geç kalkmak' denir. 'Sleep in' çoğunlukla keyif için yapılır; istemeden uyuyup geç kalmak için 'oversleep' kullanılır.<br>Sonra: Türkçede 'geç saate kadar uyumak' ya da 'geç kalkmak' denir. 'Sleep in' çoğunlukla keyif için yapılır; istemeden uyuyup geç kalmak için 'oversleep' daha yaygındır. | Not, kendi 3. örneğiyle çelişiyordu ('I slept in and missed my class'). Daha yumuşak ve doğru yazıldı. |
| en.stay_up.phv.1 | mistakes | Önce: I woke until two a.m. to study. → I stayed up until two a.m. to study.<br>Sonra: [] | 'I woke until two a.m.' tipik bir Türkçe kaynaklı hata değil, uydurma. Silindi. |
| en.set_off.phv.1 | mistakes[0] | Önce: We set off to Ankara at six. → We set off for Ankara at six.<br>Sonra: We set off Ankara at six. → We set off for Ankara at six. | Eski hata ('set off to Ankara') gerçekte yanlış değil ('set off to' kullanılır). Gerçek hata 'for'u atlamak. |
| en.take_off.phv.2 | mistakes | Önce: Please take off your phone before the plane leaves. → Please turn off your phone before the plane takes off.<br>Sonra: [] | 'take off your phone' Türkçe 'kapatmak'tan çıkmaz, uydurma hata. Silindi. |
| en.end_up.phv.1 | def.micro | Önce: finally become or be<br>Sonra: finally be in a situation | Eski micro ('finally become or be') yerine konamaz, belirsizdi. |
| en.end_up.phv.1 | gloss | Önce: sonunda kendini bulmak<br>Sonra: sonunda kendini ... bulmak | Eksiksiz 'sonunda kendini bulmak' Türkçede 'kendini keşfetmek' gibi okunabilir. '...' ile kalıp olduğu belli edildi. |
| en.end_up.phv.1 | mistakes[1] | Önce: We finished in a small village. → We ended up in a small village.<br>Sonra: (silindi) | 'We finished in a small village' tipik bir Türkçe kaynaklı hata değil, uydurma. Silindi. |
| en.cut_down_on.phv.1 | quiz.distractors | Önce: turn down / pick up / look after<br>Sonra: turn on / pick up / look after | 'turn down coffee' (kahveyi geri çevirmek) cümleye uyabilirdi. Net yanlış çeldirici seçildi. |
| en.catch_up.phv.1 | note | Önce: 'Catch up' ayrıca 'yetişmek' anlamına da gelir (catch up with the group). Bu kartta 'uzun süre sonra buluşup haberleşmek' anlamı var.<br>Sonra: 'Catch up' ayrıca 'yetişmek' anlamına da gelir (catch up with the group). Bu kartta 'uzun süre sonra buluşup sohbet etmek' anlamı var. | 'buluşup haberleşmek' uzaktan yazışma gibi okunur. Gloss ile uyumlu hâle getirildi. |
| en.move_out.phv.1 | examples[2] | Önce: The old tenants moved out last week. / Eski kiracılar geçen hafta evden çıktı.<br>Sonra: The family next door moved out last week. / Yan evdeki aile geçen hafta evden taşındı. | 'tenants' A2 öğrenen için çok zor. Basit sözcüklerle yazıldı. |
| en.move_out.phv.1 | mistakes[0] | Önce: We moved out to a new house. → We moved out of our old house.<br>Sonra: I moved out the apartment last week. → I moved out of the apartment last week. | Eski hata ('moved out to a new house') gerçekte yanlış değil. Gerçek hata 'of'u atlamak. |
| en.move_out.phv.1 | quiz.cloze | Önce: The lease ends tomorrow. We have to ______ of the apartment today.<br>Sonra: We found a new house, so we will ______ of this apartment. | 'lease' A2 için çok zor bir sözcük. Basit cümle yazıldı. |
| en.speak_up.phv.1 | alt | Önce: sesini yükseltmek / açıkça konuşmak<br>Sonra: sesini yükseltmek | 'açıkça konuşmak' = açık sözlü olmak. Bu kartın anlamı (sesi yükseltmek) değil. |
| en.speak_up.phv.1 | mistakes | Önce: Please speak more up. → Please speak up. ; Please speak loud. → Please speak louder.<br>Sonra: Please speak with a high voice. → Please speak up a little. | 'speak more up' uydurma. 'speak loud' günlük dilde kabul edilir, 'sıfattır' açıklaması da eksikti. Gerçek Türkçe kaynaklı hata kondu: yüksek ses → high voice. |
| en.plug_in.phv.1 | mistakes[0] | Önce: I need to charge in my phone. → I need to plug in my phone.<br>Sonra: Please plug the charger to the socket. → Please plug the charger into the socket. | Eski hata ('charge in my phone') uydurmaydı. Gerçek hata: -e hâli → to. |

## Yerel konuşur kontrolü istenen kartlar

- `en.look_up.phv.1`: yeni gloss "bakmak, araştırmak". Eski "bakıp bulmak" doğal değildi. 'Bakmak' tek başına 'look at' ile karışabilir. Not bunu açıklıyor.
- `en.come_over.phv.1`: yeni gloss "(birinin) evine gelmek". En doğal söyleyiş 'bize gelmek'. Gloss mu alt mı olmalı?
- `en.look_after.phv.1`: yeni gloss "bakmak, ilgilenmek". 'ilgilenmek' `deal with` kartının glossunda da var. Karışır mı?
- `en.end_up.phv.1`: "sonunda kendini ... bulmak" bu şekilde widgetta anlaşılır mı?
- `en.go_on.phv.1`: "olmak, yaşanmak". 'olmak' tek başına 'to be' gibi okunabilir. Değiştirmedim.
- `en.catch_up.phv.1`: ilk örnekte "hasret giderelim" biraz duygusal. Arkadaş arası günlük konuşmada normal mi?
- `en.turn_around.phv.1`: "arkasını dönmek" (sırtını dönmek) ile "arkaya dönmek" arasındaki fark. Örnek 1 'Arkana dön' kullanıyor.
- `en.hang_out.phv.1`: alt anlam 'buluşmak' tam karşılık değil (plansız takılmak). Bıraktım.
- `en.take_out.phv.1`: para çekmek (withdraw) anlamı aynı kartta. Ayrı bir kart gerekebilir.
- Yeni hata örnekleri (gerçek Türkçe kaynaklı mı?): `take_off.1` (take out your shoes), `sit_down.1` (sat down to a table), `set_off.1` (set off Ankara), `speak_up.1` (speak with a high voice), `move_out.1` (moved out the apartment), `plug_in.1` (plug to the socket), `hang_out.1` (hang out my friends).
- `en.sort_out.phv.1`: 'I sorted the problem' İngiliz İngilizcesinde günlük dilde kabul edilir. Hata örneği biraz sert olabilir. Bıraktım.
- `en.calm_down.phv.1`: 'Be calm!' dilbilgisi olarak doğru, sadece daha az doğal. Bıraktım. Not bunu söylüyor.
- `en.hold_on.phv.1`: 'Hold a minute' hatası Türkçe kaynaklı olmaktan çok genel bir eksik. Bıraktım.

## Kontrol edilip bırakılanlar (kısa)

- `top up`: İngiliz İngilizcesine yakın olduğu hem `def.long` hem notta zaten yazıyor. Değişiklik gerekmedi.
- Çift anlamlı kartlar (pick up 1/2, take off 1/2, turn down 1/2, work out 1/2, give up 1/2, put on 1/2, check out 1/2): anlamlar net ayrışıyor, `sense_note` ve çapraz notlar tutarlı.
- Zamirli ayrılabilir fiiller: bayraklar ve kalıplar doğru. Quiz'de 'pick up them' / 'try on them' çıkaran iki cümle düzeltildi.
- IPA: tüm kartlarda vurgu doğru (ikinci hece / edat üzerinde).
- Seviye: A2 ve B1 uygun. A1 yok.

## Çeldirici çeşitlendirme (2026-10-19)

Akış: s4 (100 phrasal verb sorusu). Hedef: hiçbir çeldirici 5'ten fazla soruda geçmesin.

- **Önce:** 100 soru, 73 farklı çeldirici; en sık: give up×32, get off×17, take off×15, put on×14, pick up×13, turn on×13 (5'ten fazla geçen 16 çeldirici; doğrulayıcı 16 `QUIZ_DISTRACTOR_REPEAT` uyarısı veriyordu).
- **Sonra:** 100 soru, 94 farklı çeldirici; en sık: sit down×5, slow down×5, take off×5, get on×5, sign up×5, calm down×5 (hiçbiri 5'i geçmiyor). Doğrulayıcı `--strict`: 0 hata, 0 uyarı.
- **Değişen kart:** 81 (her birine `distractors_diversified` işareti eklendi). Değişmeyen 19 kartın çeldiricileri zaten sorunsuzdu.
- **Cloze'u değiştirilen kart:** yok. Doğru cevaplar ve cümleler aynı; yalnızca `quiz.distractors` ve `meta.qa_flags` değişti.

Nasıl seçildi:

- Yeni çeldiricilerin hepsi s4'ün kendi phrasal verb'lerinden; cevabın biçimiyle aynı (geçmiş zaman için geçmiş, `-ing` için `-ing`, "We've ____ paper" için üçüncü hâl, emir cümlesi için büyük harf).
- Her yeni şık boşluğa konup okundu. Boşluktan sonra nesne gelen cümlelerde (`the light`, `your coat`, `the volume`...) nesne almayan phrasal verb'ler (`come back`, `stay up`, `lie down`, `catch up`...) tercih edildi; dilbilgisi açısından açıkça yanlıştırlar. Anlamca uyabilen şıklar (örn. `put on` giysi cümlesinde, `turn on` müzik cümlesinde, `look for` bir arama cümlesinde, `find out` / `look up` bilgi cümlesinde) kullanılmadı.
- Eski çeldiricilerden cümleye uyabilen veya doğal duyulanlar da değiştirildi: `get_in` ("Let's get up and go to the airport" doğal), `lie_down` ("go out for a few minutes" baş dönmesinde doğal), `get_together` ("Let's set off this weekend"), `eat_out` ("Let's give up tonight"), `drop_off` ("I'll look after the kids at school" doğal), `hang_out` ("check in with my friends"), `turn_around` ("give up and go back"), `get_off` ("get up here").

Editör için işaretler (değişmeyen eski çeldiriciler):

- `fill_in`: çeldirici `fill up this form`; bazı İngilizce çeşitlerinde duyuluyor, ama standart değil. Eski haliyle bırakıldı.
- `get_on`: çeldirici `get up before it leaves`; doğal değil ama dilbilgisi olarak mümkün. Bırakıldı.
- `work_out` (1): çeldirici `sit down for an hour`; "spor salonuna gidip oturmak" mümkün ama tuhaf. Bırakıldı.
- `warm_up`: çeldiriciler `take out` / `put away the soup in the microwave`; dilbilgisi olarak mümkün, cümleye uymuyor. Bırakıldı.
