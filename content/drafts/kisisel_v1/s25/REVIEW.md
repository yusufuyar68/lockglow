# s25 QA incelemesi (B2: çevre, iklim ve bilim)

Kapsam: `content/drafts/kisisel_v1/s25/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: haberde, okulda ve iş yerinde en sık geçen çevre, iklim ve bilim kelimeleri. Seviye B2.

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** tek yazar ajanı (`1_yazar_kurallari.md`). Yazar, kartları depo dışındaki betiklerle üretti, ardından "emin olmadığım" maddelerini raporladı.
2. **Denetim:** bağımsız bir denetçi ajanı (Opus) 60 kartı tek tek okudu (`2_denetci_kurallari.md`). Her quiz şıkkı boşluğa kondu, her Türkçe örnek İngilizceye geri çevrildi, IPA deste geleneğiyle karşılaştırıldı. Yazarın maddeleri ayrıca yanıtlandı (aşağıda).

## Özet

- İncelenen kart: **60** (hepsi B2). Tür: 54 kelime (`word`), 3 eşdizim (`collocation`: climate change, global warming, carbon footprint), 2 phrasal verb (die out, cut down), 1 deyim (`idiom`: the tip of the iceberg).
- `primary_topic`: `environment_climate` 27, `science_space` 20, `nature_animals` 10, `phrasal_verbs` 2, `idioms_expressions` 1.
- Değişen kart: **22** (`critic_edited`), **38** alan. `meta.status` hepsinde `draft` kaldı (s22 gibi).
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: hepsi `null`. Sahte dost: yok (gerçek bir Türkçe sahte dost bulunmadı). `sensitivity`: hepsi 0.
- **Kilit ekranı anlamı:** 60 kartın hepsinde ≤16 karakter. 3 kartta `gloss_short` var: endangered "nesli tükenmekte", climate change "iklim değişimi", the tip of the iceberg "buzdağının ucu".
- **Karışan kelimeler (`confusables`):** 25 kartta. Hepsi gerçek bir karışıklık (aynı Türkçe karşılık, benzer yazılış ya da bilinen kullanım farkı) olarak tutuldu.
- **Türkçeden çeviri hatası (`mistakes`):** 3 kartta 3 madde: "many evidences", "survived from the accident", "Ghosts are not exist". Üçü de gerçek Türk öğrenci hatası, tutuldu. Silinen madde yok.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.
- Çeldirici (`distractor_stats.py`): `s25: 60 quizzes, 169 distinct distractors; top: harmful×3, solar energy×3, climate×2, flood×2, warning×2, coast×2`. Sınır (4) aşılmıyor.
- DRESS (`ipa_dress_stats.py`): `us_ɛ 8, uk_ɛ 8, /e/ 0`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **IPA'da hece oluşturan l/n:** yazar `/-tl/, /-bl/, /-fl/, /-kl/, /-tn/` yazmıştı (threaten, environmental, renewable, global, global warming, harmful, tropical). Deste geleneği schwa ile yazmak: chemical /ˈkɛmɪkəl/, available /əˈveɪləbəl/, cheerful /ˈtʃɪrfəl/, garden /ˈɡɑːrdən/. 7 kartta 14 IPA düzeltildi.
  2. **İngiliz yazımı:** petrol, rubbish, maths (fuel, waste, packaging, pollute, calculate). Deste Amerikan yazımı kullanıyor, değiştirildi. `engineering_maths` bir taksonomi kimliği olduğu için dokunulmadı. analyze kartında "analyse" bilerek İngiliz yazımı olarak anılıyor, kaldı.
  3. **Savunulabilir quiz şıkları:** impact ("a big benefit"), rainforest ("the Amazon valley"), eco-friendly ("fully disposable"), rapidly ("spread gradually … within minutes"). Dördü de açıkça yanlış şıklarla değişti. calculate'te "spend" cümledeki "spent" ile cevabı ele veren bir tekrardı, değişti.
- **Türkçe:** genel olarak doğal ve doğru. Geri çeviride yalnızca flow örneğinde sapma vardı ("hot spring" kaplıca değil sıcak su kaynağı; "warm" ılık). TDK yazımı (yer çekimi, resmî, kâğıt, şikâyet, imkân, rüzgâr) doğru.
- **Seviye:** hepsi B2 bırakıldı. Bazıları sözlüklerde (EVP/Oxford 3000) B1 olarak geçiyor olabilir; aşağıda listelendi. Hiçbiri silinmedi, seviyesi değiştirilmedi.

## Değişiklik tablosu

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| fuel | def.short | "something such as petrol, gas or coal…" → "something such as gasoline, coal or wood that is burned to make heat or power" | ABD yazımı; "gas" ABD'de benzin de demek, listeden çıkarıldı |
| fuel | def.long | "such as petrol, diesel, gas…" → "such as gasoline, diesel, gas…" | ABD yazımı |
| fuel | examples[2].en | "…like petrol and diesel." → "…like gasoline and diesel." | ABD yazımı |
| waste | sense_note | "rubbish; things thrown away" → "trash; things thrown away" | ABD yazımı |
| packaging | def.long | "…a lot of it becomes rubbish." → "…a lot of it becomes trash." | ABD yazımı |
| discovery | l1.tr.alt | ["buluş"] → [] | "Buluş" Türkçede daha çok icat (invention) anlamında; kartın karışan kelimesi invention, alt karışıklığı artırıyordu |

Değişmeyen ama bakılanlar: resource (US /ˈriːsɔːrs/, UK /rɪˈzɔːs/ sözlüklerle uyumlu; UK'de /rɪˈsɔːs/ da var), shortage → lack (ikisi de "eksiklik"; gerçek kullanım farkı: "a shortage of nurses" / "a lack of sleep"), waste → waist (aynı okunuş), evidence → proof, evidence hatası "many evidences" (gerçek, çok yaygın). Bütün quiz şıkları boşluğa kondu; ikinci doğru cevap yok ("natural disasters/habitats" doğru eşdizim ama anlamca açıkça yanlış, iyi tuzak).

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| impact | quiz.distractors | benefit → reason | "Tourism has a big benefit…" anlamca olabiliyor, yalnızca "on" edatı yüzünden yanlış; "reason" açıkça yanlış |
| rainforest | quiz.distractors | valley → river | "the Amazon valley" (Amazon havzası) savunulabiliyordu; "river" maymun ve papağanın yaşadığı yer olarak açıkça yanlış |

Değişmeyen ama bakılanlar: atmosphere quiz'i (surface / orbit / climate) tek cevaplı: "the lower part of the earth's orbit/surface/climate" uçak için anlamsız; tutuldu. surface notundaki "sörfıs" benzetmesi Türk okuru için doğru sesi veriyor ("-face" = feys tuzağı gerçek), tutuldu. microscope → telescope (ikisi de "-skop", aynı alan, biçim tuzağı) ve crop → product (ikisi de "ürün") gerçek, tutuldu. environmentalist → eco-friendly ("çevreci ürün" kalıbından "an environmentalist product" hatası) gerçek bir Türkçe kaynaklı karışıklık, not bunu anlatıyor; tutuldu. chemical quiz'inde "harsh flavors" şampuan için anlamsız; tutuldu.

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| pollute | def.long | "…plastic or rubbish…" → "…plastic or trash…" | ABD yazımı |
| threaten | ipa.us, ipa.uk | /ˈθrɛtn/ → /ˈθrɛtən/ | Deste kuralı: schwa + n /-ən/ (garden, button, curtain) |
| threaten | l1.tr.alt | ["tehlikeye atmak"] → ["tehlike oluşturmak"] | "Tehlikeye atmak" endanger/put at risk demek ve özne çoğu zaman kişi; kartın anlamı "be a danger to" = tehlike oluşturmak |
| measure | l1.tr.note | "(Masa iki metre geliyor.)" → "(Masa iki metre uzunluğunda.)" | "Geliyor" konuşma dilinde ve neyin iki metre olduğunu söylemiyor |
| release | l1.tr.alt | ["salıvermek", "açığa çıkarmak"] → ["açığa çıkarmak", "yaymak"] | "Salıvermek" hayvan ya da tutsak için; kartın anlamı gaz/kimyasal salmak |

Değişmeyen ama bakılanlar: survive hatası "He survived from the accident." gerçek ve yaygın ("kazadan kurtuldu" → from); tutuldu. exist hatası "Ghosts are not exist." gerçek (Türk öğrencilerde "it is not exist / are not exist" çok görülür; "yok" → is not); tutuldu. consume örneği "Americans consume more energy per person than people in most countries." doğru (ABD kişi başı enerji tüketiminde dünyanın en yüksek ülkelerinden; önünde yalnızca birkaç ülke var, "most countries" iddiası güvenli). release örneği "Yanan kömür CO2 salar." doğal ve doğru. adapt → adopt klasik; quiz'de "adopted to" gerçek hata biçimi, iyi çeldirici.

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| calculate | sense_note, def.micro, def.short, def.long | "using maths" → "using math" | ABD yazımı |
| calculate | quiz.distractors | spend → weigh | "spend" cümlede "spent" olarak zaten geçiyordu (cevap olmadığını ele veriyor); "weigh" ölçme işlevinden, para için açıkça yanlış |
| flow | examples[1].tr | "Kaplıcadan bütün yıl sıcak su akar." → "Sıcak su kaynağından yıl boyunca ılık su akar." | "Kaplıca" tesis/kür yeri; "hot spring" kaynak. "Warm water" = ılık su (geri çeviri) |
| environmental | ipa.us, ipa.uk | /ɪnˌvaɪrənˈmɛntl/ → /ɪnˌvaɪrənˈmɛntəl/ | Deste kuralı /-əl/ (chemical, political) |
| renewable | ipa.us | /rɪˈnuːəbl/ → /rɪˈnuːəbəl/ | Deste kuralı /-əbəl/ (available, flexible) |
| renewable | ipa.uk | /rɪˈnjuːəbl/ → /rɪˈnjuːəbəl/ | Aynı kural |
| renewable | def.short | "energy from sources like…" → "coming from sources like the sun, wind or water that will not run out" | Sıfat bir isim öbeğiyle tanımlanıyordu |
| solar | l1.tr.gloss | "güneş" → "güneşle ilgili" | Kilit ekranında "solar — güneş" tek başına solar = sun (isim) diye öğretiyor; kart sıfat |
| solar | l1.tr.alt | ["güneşle ilgili", "solar"] → ["güneş", "solar"] | "Güneş" (güneş enerjisi, güneş paneli) alt'a geçti; not tamlama kullanımını anlatıyor |

Değişmeyen ama bakılanlar: calculate'in kalan çeldiricileri "borrow / afford" para konusundan ve "Can you ___ how much…" yapısında açıkça yanlış; tutuldu. flow → fly (flowed/flew) tutuldu: "flew" ile "flowed" biçim karışması öğrencilerde görülüyor ve not bunu anlatıyor; sınırda, aşağıda listelendi. expand → extend (ikisi de "genişletmek/uzatmak") gerçek. endangered → dangerous ("tehlike" sözcüğü yüzünden) ve extinct gerçek, quiz'de iyi tuzak. Danube'ün on ülkeden geçtiği doğru.

#### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| global | ipa.us, ipa.uk | /ˈɡloʊbl/, /ˈɡləʊbl/ → /ˈɡloʊbəl/, /ˈɡləʊbəl/ | Deste kuralı /-əl/ |
| harmful | ipa.us, ipa.uk | /ˈhɑːrmfl/, /ˈhɑːmfl/ → /ˈhɑːrmfəl/, /ˈhɑːmfəl/ | Deste kuralı /-fəl/ (cheerful, thoughtful) |
| eco-friendly | quiz.distractors | disposable → plastic | "fully disposable" (tek kullanımlık) cam şişe için yarı makul okunabiliyordu; "plastic" camla açıkça çelişiyor |
| tropical | ipa.us, ipa.uk | /ˈtrɑːpɪkl/, /ˈtrɒpɪkl/ → /ˈtrɑːpɪkəl/, /ˈtrɒpɪkəl/ | Deste kuralı /-əl/ |
| rapidly | quiz.distractors | gradually → carefully | "spread gradually, and within minutes…" dakikalar içinde kademeli yayılma diye savunulabiliyordu (zarf sorusu, en riskli tür) |
| climate change | l1.tr.note | "Sık sık 'global warming' yerine de kullanılır ama…" → "'Global warming' ile sık karıştırılır; küresel ısınma, iklim değişikliğinin yalnızca bir parçasıdır." | Eski cümle çelişkili okunuyordu |
| global warming | ipa.us, ipa.uk | /ˌɡloʊbl …/, /ˌɡləʊbl …/ → /ˌɡloʊbəl ˈwɔːrmɪŋ/, /ˌɡləʊbəl ˈwɔːmɪŋ/ | Deste kuralı /-əl/ |

Değişmeyen ama bakılanlar: gradually quiz'i (immediately / instantly / abruptly) "didn't stop suddenly" ile tek cevaplı. the tip of the iceberg quiz'inde yalnızca "tip" doğru; "top" bilerek konmamış (bazı anadili İngilizce olanlar "top of the iceberg" diyor), doğru karar; head / peak / edge açıkça yanlış. die out → die down, extinct ve cut down → cut down on, cut off gerçek biçim tuzakları. carbon footprint quiz'inde "reduce your climate change / global warming" "your" yüzünden açıkça yanlış.

## Yazarın "emin olmadığım" maddeleri

1. **gloss_short kural dışı iki kart:** onaylandı. climate change "iklim değişikliği" 17 karakter, bir harf fazla; kısaltılacak bir parça yok (ilk virgül yok). "İklim değişimi" aynı terimin yerleşik kısa biçimi, başka bir deyim ya da eş anlamlı değil; anlam kaymıyor. the tip of the iceberg: "buzdağının ucu" Türkçe haber dilinde de kullanılıyor ("sorunun buzdağının ucu olduğu"), anlam aynı. İki kart da kural istisnası olarak kayda geçti.
2. **Uydurma olabilecek hatalar:** üçü de gerçek, tutuldu (yukarıda).
3. **Zayıf quiz şıkları:** calculate (spend → weigh), eco-friendly (disposable → plastic) değişti. tip of the iceberg ve atmosphere tutuldu.
4. **Tartışmalı confusables:** flow → fly sınırda ama tutuldu; microscope → telescope, crop → product, environmentalist ↔ eco-friendly, shortage → lack tutuldu. Destede kartı olmayan eşler (lack, invention, proof, package, effect, telescope, product, fly, waist, chemistry, analysis, scientist, adopt, die down) yalnızca s25 kartında; destede olanlar (source, extend, dangerous, cut down on, cut off) derleyicide iki yönlü bağlanıyor.
5. **IPA ve Türkçe:** resource doğru; threaten ve harmful deste kuralına çevrildi; solar ana anlamı "güneşle ilgili" yapıldı; surface notu ve release örneği doğru; consume örneği doğru.

## Seviye (B2 dışı olabilecekler; değiştirilmedi)

- **B1 olabilir** (Oxford 3000 / EVP'de B1 olarak geçebilir, kesin değil): fuel, waste, wildlife, laboratory, discovery, disaster, atmosphere, surface, store, calculate, measure, global, scientific.
- **C1 olabilir:** drought, carbon footprint, the tip of the iceberg (deyim ve terim olarak B2 için ileri).
- Kartlar silinmedi; deste seviye listesi netleşince `level` değiştirilebilir.

## Anadili Türkçe birinin bakması gerekenler

1. Kilit ekranı karşılıkları: climate change "iklim değişimi" (gloss_short), the tip of the iceberg "buzdağının ucu", solar "güneşle ilgili" (yeni; açıklama gibi mi duruyor?), shortage "kıtlık" ("hemşire eksikliği" bağlamında ağır mı; "eksiklik" mi daha iyi?).
2. threaten alt "tehlike oluşturmak" ve release alt "yaymak" (yeni) doğal mı?
3. flow örneği "Sıcak su kaynağından yıl boyunca ılık su akar." doğal mı (sıcak/ılık yan yana)?
4. exist hatası "Ghosts are not exist." ve flow → fly karışması: Türk öğrencilerde ne kadar sık?
5. environmental alt "çevre" (sıfat yerine isim tamlaması: "çevre sorunu") alt olarak yeterince açık mı?

## Çeldirici çeşitlendirme ve son kontrol (2026-10-26)

- `distractor_stats.py`: `s25: 60 quizzes, 169 distinct distractors; top: harmful×3, solar energy×3, climate×2, flood×2, warning×2, coast×2`. En sık çeldirici 3 soruda; sınır (max(4, %5) = 4) aşılmıyor. Değişen kart: 0.
- `ipa_dress_stats.py`: `uk_e 0, uk_ɛ 8, us_e 0, us_ɛ 8`. DRESS ünlüsü deste geleneğine uygun (/ɛ/); düzeltme gerekmedi.
- Başka akışlarla çakışan madde başı (`dump_lemmas.py` ile aynı tarama): yok. s25'teki 60 lemmanın hiçbiri s0–s32'nin başka bir akışında geçmiyor.

Doğrulayıcı (son, 2026-10-26): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

Üç bağımsız denetçi B2 destesinden 80 kartlık bir örneklemi okudu (Türkçe, İngilizce ve quiz gözüyle). Bulgular tek tek doğrulandı; doğru olanlar düzeltildi. Bulgulardan çıkan beş sistematik sorun (notlarda 'siz' hitabı, İngilizce cümlede özne olan 'Can' adı, ikinci anlama kayan örnek ve eşdizimler, başka sözcük türünden çeldiriciler, B1 olabilecek seviyeler) s23–s32'nin 600 kartında tarandı.

- Bu akışta değişen kart: **5**, alan: **11**. Değişen kartlara `critic_edited` eklendi.
- Çeldirici: `s25: 60 quizzes, 169 distinct distractors; top: harmful×3, solar energy×3, climate×2, flood×2, warning×2, coast×2` (sınır max(4, %5) = 4 aşılmıyor).
- Seviye: değiştirilmedi. B1 olabilecek kartlar bu dosyanın seviye bölümünde zaten işaretli; karar kullanıcıda.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| theory.n.1 | examples[2] | "In theory, the new system should save energy, but we'll see. / Teoride yeni sistemin enerji tasarrufu sağlaması gerekiyor ama göreceğiz." → "Scientists tested the theory in the lab. / Bilim insanları teoriyi laboratuvarda test etti." | 'In theory' ayrı anlam (s30'da ayrı kartı var) |
| theory.n.1 | collocations | "a scientific theory, in theory, prove a theory" → "a scientific theory, test a theory, prove a theory" | 'in theory' ayrı anlam |
| disaster.n.1 | examples[2] | "Our camping trip was a total disaster: it rained all weekend. / Kamp gezimiz tam bir felaketti: bütün hafta sonu yağmur yağdı." → "The government sent help to the disaster area. / Hükümet afet bölgesine yardım gönderdi." | 'a total disaster' gündelik 'başarısızlık' anlamı |
| disaster.n.1 | collocations | "a natural disaster, a total disaster, disaster area" → "a natural disaster, a major disaster, disaster area" | 'a total disaster' gündelik anlam |
| chemical.n.1 | def.micro | "substance made in a lab" → "substance used in industry" | Kimyasallar laboratuvarda yapılmak zorunda değil |
| chemical.n.1 | def.short | "a substance made or used in science and industry, often by mixing others" → "a natural or man-made substance, especially one used in industry or farming" | Tanım 'başkalarını karıştırarak yapılan' diyordu; yanlış |
| chemical.n.1 | def.long | "A substance, often made in a laboratory or factory, such as those in cleaning products or the ones used on farms. Some of them can be harmful to people and nature." → "A natural or man-made substance, such as those in cleaning products or the ones used on farms. Some of them can be harmful to people and nature." | Kimyasal doğal da olabilir |
| survive.v.1 | quiz.distractors | "started, caused, spread" → "survived from, lived, stayed" | 'started/caused/spread' ağaçla akla yatkın değildi; yeni şıklar 'kurtulmak, yaşamak, kalmak' tuzakları |
| generate.v.1 | examples[2] | "The new factory will generate hundreds of jobs. / Yeni fabrika yüzlerce iş imkânı yaratacak." → "Burning coal generates a lot of heat. / Kömür yakmak çok fazla ısı üretir." | 3. örnek 'iş yaratmak' anlamına kayıyordu |
| generate.v.1 | collocations | "generate electricity, generate power, generate income" → "generate electricity, generate power, generate heat" | 'generate income' ayrı anlam |
| generate.v.1 | l1.tr.alt | "oluşturmak, yaratmak" → "oluşturmak" | 'yaratmak' yalnızca kaldırılan iş/gelir anlamına uyuyordu |

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Seviye kararı (2026-10-26)

İki bağımsız yargıç B1 olabilecek adayları ayrı ayrı değerlendirdi. İkisinin de B1 ya da altı dediği **11 kart** `level: "B1"` oldu; `level_source` yine `editorial_estimate`. Kart ID'leri seviye içermediği için değişmedi. Yargıçların ayrıntılı gerekçe metinleri bu düzenlemeye gelmedi; satırlardaki gerekçe, yargıç kararının editör özetidir.

- `en.fuel.n.1` (fuel): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.wildlife.n.1` (wildlife): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.waste.n.1` (waste): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.laboratory.n.1` (laboratory): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.discovery.n.1` (discovery): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.disaster.n.1` (disaster): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.survive.v.1` (survive): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.measure.v.1` (measure): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.calculate.v.1` (calculate): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.store.v.1` (store): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.scientific.adj.1` (scientific): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.

B2'de kalan adaylar (yargıçlar ayrıştı ya da B2 dedi): `en.atmosphere.n.1`, `en.surface.n.1`, `en.global.adj.1`.

## İkinci örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) her akıştan 7 kartlık bir örneklemi (toplam 70 kart) ikinci kez okudu. 35 bulgunun hepsi kartla karşılaştırıldı ve hepsi gerçek çıktı; düzeltildi. Bulgulardan çıkan yeni sistematik sorunlar s23–s32'nin 600 kartında tarandı: `def.long`'un ikinci bir anlama kayması (ve aynı anlamın örnek, eşdizim, `alt` ya da quiz'e girmesi), başka sözcük türünden ya da yalnızca yazımı benzeyen çeldiriciler, ABD IPA'sında ɝ/ɚ yazımı, boş `confusables` dizisi.

- Bu akışta değişen kart: **7**, alan: **7**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.atmosphere.n.1`: İngilizce, def.long (düşük): gerçek. 'mood of a place' cümlesi silindi (notta var).

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| atmosphere.n.1 | def.long | silinen cümle: "It can also mean the feeling or mood of a place." | def.long ikinci bir anlama kayıyordu; o cümle silindi (bulgu) |
| disaster.n.1 | def.long | silinen cümle: "Informally, it can also mean something that goes very badly." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| threaten.v.1 | def.long | silinen cümle: "It also means to say you will hurt someone." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| consume.v.1 | def.long | silinen cümle: "It can also mean to eat or drink something, but this is formal." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| release.v.1 | def.long | silinen cümle: "It also means to let a person or animal go free." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| environmental.adj.1 | quiz.distractors | "[environmentalist, emotional, personal]" → "[historical, emotional, personal]" | 'environmentalist' isim (tarama) |
| scientific.adj.1 | quiz.distractors | "[scientist, solar, eco-friendly]" → "[ancient, solar, eco-friendly]" | 'scientist' isim (tarama) |

- Çeldirici: `s25: 60 quizzes, 169 distinct distractors; top: harmful×3, solar energy×3, climate×2, flood×2, warning×2, coast×2` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Üçüncü örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) s23–s32'den 80 kartlık yeni bir örneklemi okudu. 35 bulgu kartla karşılaştırıldı: 33'ü gerçek çıktı ve düzeltildi, 2'si (release, carbon footprint çevirileri) gerekçesiyle reddedildi. Önceki iki turun listesinde olmayan sistematik sorunlar s23–s32'nin 600 kartında tarandı: `gloss_short`'ta kesilmiş söz; `alt`'ın kartın kendi notuyla ya da başka bir kartın ayrımıyla çelişmesi (ve önceki taramada kalan ikinci anlam karşılıkları); `grammar.pattern`'da başka anlamın kalıbı; `def.long`'da önceki anahtar sözcük taramasının kaçırdığı ikinci anlam cümleleri (ve aynı anlamın örnek, eşdizim, quiz'e taşması); akraba kartlar arasında neredeyse aynı örnek ya da boşluklu cümle; boşluğa anlamca hiç uymayan, soruyu ele veren çeldiriciler; şapkası düşmüş hâl / dâhil. Seviyeler değişmedi.

- Bu akışta değişen kart: **10**, alan: **12**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.release.v.1`: Türkçe, 1. örnek (düşük): **reddedildi.** 'Burning coal releases CO2' İngilizcede ortaç olarak da (yanan kömür) okunur ve iki okuma aynı olguyu anlatır; 'Yanan kömür CO2 salar' doğal ve doğru Türkçe. Değişmedi.
- `en.carbon_footprint.phr.1`: Türkçe, 1. örnek (düşük): **reddedildi.** Türkçede yolcu için 'uçmak' olağan kullanım ('Londra'ya uçtuk', 'daha az uçmak'); çeviri doğal. Değişmedi.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| theory.n.1 | def.long | silinen cümle: "'In theory' means something should be true but may not be in real life." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| surface.n.1 | def.long | silinen cümle: "'On the surface' can also mean how something looks at first." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| crop.n.1 | def.long | silinen cümle: "It can also mean the amount collected in one season: 'a good crop of apples'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| crop.n.1 | def.short | "a plant such as wheat, corn or rice that farmers grow, or the amount collected" → "a plant such as wheat, corn or rice that farmers grow in large amounts" | 'or the amount collected' ikinci anlam (tarama) |
| crop.n.1 | collocations | "[grow crops, crop failure, a good crop]" → "[grow crops, crop failure, the main crop]" | 'a good crop' hasat miktarı anlamı (tarama) |
| threaten.v.1 | examples[1] | "The new road could threaten the local wildlife. / Yeni yol bölgedeki yaban hayatını tehdit edebilir." → "A big storm is threatening the island. / Büyük bir fırtına adayı tehdit ediyor." | başka bir kartta neredeyse aynı cümle vardı (wildlife: 'The new road will be dangerous for local wildlife') (tarama) |
| measure.v.1 | examples[0] | "The nurse measured my blood pressure. / Hemşire tansiyonumu ölçtü." → "The nurse measured my height. / Hemşire boyumu ölçtü." | başka bir kartta neredeyse aynı cümle vardı (blood pressure: 'The nurse checked my blood pressure') (tarama) |
| generate.v.1 | def.long | silinen cümle: "In business it also means to create money, ideas or jobs: 'generate income'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| exist.v.1 | examples[1] | "Dinosaurs existed millions of years ago. / Dinozorlar milyonlarca yıl önce vardı." → "This old map shows a village that no longer exists. / Bu eski harita artık var olmayan bir köyü gösteriyor." | başka bir kartta neredeyse aynı cümle vardı (extinct: 'Dinosaurs became extinct millions of years ago') (tarama) |
| calculate.v.1 | examples[1] | "Scientists calculated that the ice is melting faster than expected. / Bilim insanları buzun beklenenden daha hızlı eridiğini hesapladı." → "Scientists calculated the age of the rock. / Bilim insanları kayanın yaşını hesapladı." | başka bir kartta neredeyse aynı cümle vardı (rapidly: ice melting faster than scientists expected) (tarama) |
| endangered.adj.1 | l1.tr.gloss_short | "nesli tükenmekte" → "nesli tehlikede" | 'nesli tükenmekte' kesilmiş söz; alt'taki tam karşılık seçildi (tarama) |
| tropical.adj.1 | quiz.cloze | "Parrots and monkeys live in ______ forests." → "Mangoes and pineapples grow in ______ countries like Thailand and Brazil." | başka bir kartta neredeyse aynı cümle vardı (rainforest quiz: parrots, monkeys) (tarama) |

- Çeldirici: `s25: 60 quizzes, 169 distinct distractors; top: harmful×3, solar energy×3, climate×2, flood×2, warning×2, coast×2` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
