# s31 QA incelemesi (para, alışveriş ve ekonomi, B2)

Kapsam: `content/drafts/kisisel_v1/s31/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin haberde, işte ve alışverişte duyduğu para ve ekonomi kelimeleri: gelir-gider, bankacılık, ticaret, reklam, fiyat sıfatları ve birkaç kalıp (splash out, set aside, stock up on, cut costs, cost of living, on a budget, free of charge, get your money's worth). Seviye: hepsi B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** tek yazar ajanı, 60 kart, 5 part (`1_yazar_kurallari.md`). Yazar hiçbir kelimeyi atlamadı; kimlikler `id_registry.json`'da ve başka akışlarda yok. Başka bir akıştaki örnekle birebir aynı çıkan bir economic örneği yazım sırasında değiştirildi.
2. **Denetim:** bağımsız bir denetçi ajanı 60 kartı tek tek okudu (`2_denetci_kurallari.md`). Yazarın "emin olmadığım" maddeleri ayrıca tek tek sınandı (aşağıda). Kartlar yerinde düzeltildi; değişen kartlara `critic_edited` eklendi.

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 52 kelime (25 isim, 15 fiil, 12 sıfat), 3 phrasal verb, 2 eşdizim (`collocation`: cut costs, cost of living), 2 kalıp (`phrase`: on a budget, free of charge), 1 deyim (`idiom`: get your money's worth).
- `primary_topic`: `finance_economics` 28, `shopping_money` 22, `marketing_ecommerce` 6, `phrasal_verbs` 3, `idioms_expressions` 1.
- Değişen kart: **16** (`critic_edited`), değişen alan: **20** (tablo aşağıda).
- Reddedilen kart (`critic_reject`): **0**.
- **Türkçeden çeviri hatası (`mistakes`):** yazarda 24 madde vardı. 2'si silindi (supply, double), 2'si gerçekte duyulan biçimiyle değiştirildi (ship, expire). Son durumda 22 kartta 22 madde. Hepsi Türkçenin yönlendirdiği hatalar: "did a big investment", "made insurance", "with installments", "bus fee", "studied economy", "minimum salary", "make a complain", "two years guarantee", "very luxury", "a funny advertising", "invest to", "renew the page", "by cargo", "very economic", "economic problems at home", "yearly permission", "cost of life" vb.
- **Sahte dost:** 1 (economic ≠ ekonomik "ucuz, az yakan"; `equivalence: false_friend`).
- **Köken:** 3 kartta (inflation, luxury, expire; Latince, `high`). Üçü de doğru; geri kalanı `null`.
- **Karışan kelimeler (`confusables`):** 19 kartta 27 kayıt (profit → prophet çıkarıldı).
- **Kilit ekranı anlamı:** 58 kartta `gloss` ≤16 karakter; 2 kartta `gloss_short` var (cut costs "masraf kısmak", get your money's worth "hakkını çıkarmak").
- `sensitivity`: hepsi 0 (para kelimeleri ama iş ya da para kaybı üzerine kişisel bir ilk örnek yok).
- IPA: DRESS `/ɛ/` (`ipa_dress_stats.py`: us_ɛ 11, uk_ɛ 10, /e/ 0); vurgular doğru hecede (import/export fiilde ikinci hece; manufacture ve guarantee ˌ…ˈ).
- Çeldirici (`distractor_stats.py`): `s31: 60 quizzes, 119 distinct distractors; top: wage×4, renew×4, wealthy×4, refund×3, wages×3, inflation×3`. Sınır (4) aşılmıyor.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Türkçeye özgü olmayan ya da zorlama hata maddeleri.** supply ("supplies the hospitals medicine") ve double ("Prices became double") silindi; ship'te "I'll cargo the package" yerine gerçekten duyulan "by cargo", expire'da "The time of my passport is finished" yerine "My passport's time is over" yazıldı.
  2. **Yanlış yöne kayan Türkçe karşılıklar:** inflation alt "hayat pahalılığı" (cost of living'in anlamı), valuable alt "pahalı" (expensive), get your money's worth alt "parasına değmek" (worth the money; özne şey) çıkarıldı.
  3. **Not ya da örnek içi çelişki:** trade örneği "trade in their own currencies" notun "trade in + ürün" kuralıyla çelişiyordu; genuine notu 'original' için "kopya olmayan" diyerek kendi uyarısını boşa çıkarıyordu; wealth notu "a wealth" kalıbını mutlak yasaklıyordu ("a wealth of" var).
- **Quiz:** 60 sorunun hepsinde şıklar tek tek boşluğa kondu. Tek değişiklik well-off ("worthy enough to buy" zorlamayla okunabiliyordu). Yazarın iki kez okunmasını istediği sorular aşağıda; hepsinde tek doğru cevap var.
- **Türkçe:** 4 örnek çevirisi doğallaştırıldı (profit "az bir kâr etti", purchase "satın aldığınızın kanıtı", tempt "almak içimden geçti", money's worth "hakkını aldık").

## Yazarın "emin olmadığım" maddeleri: karar

1. **Hata maddeleri:**
   - supply "supplies the hospitals medicine": **silindi.** Türkçe yapı (yönelme + belirtme, "hastanelere ilaç sağlamak") bu cümleye itmiyor; "with" düşmesi Türkçeye özgü değil.
   - double "Prices became double": **silindi.** Yaygın bir Türkçe konuşan hatası olarak doğrulanamadı.
   - advertising "a funny advertising": **kaldı.** "bir reklam" sayılabilir olduğu için "an advertising" gerçekten sık.
   - cost of living "cost of life": **kaldı.** "hayat pahalılığı / yaşam maliyeti" doğrudan "life"a götürüyor.
   - guarantee "two years guarantee": **kaldı.** "iki yıl garantisi var" kelime kelime aktarılıyor; bileşik sıfatta tekil "year" Türkçe konuşanlarda bilinen bir hata.
   - goods "The goods was sent": **kaldı.** Türkçede çoğul özneyle tekil fiil olağan ("mallar gönderildi"), "mal" da tekil düşünülüyor.
   - savings "all my saving": **kaldı** (sınırda; aşağıda anadili Türkçe birine soruldu).
2. **economic sahte dostu:** dolduruldu (`tr_word: ekonomik`, `en_for_that: economical / cheap`, `equivalence: false_friend`). "ekonomik araba / ekonomik paket" gerçek ve çok sık bir tuzak; actually ↔ aktüel ile aynı türden.
3. **Tartışmalı karışan kelimeler:** genuine → original **kaldı** (Türkçede "orijinal ürün" denir; not düzeltildi). profit → prophet **çıkarıldı** (eş sesli ama gerçek bir karıştırma değil; not bilgiyi koruyor). label → tag **kaldı** (ikisi de "etiket"). fee → fare/wage/price **kaldı** (hepsi "ücret"; price sınırda ama "course fee" / "price" kullanım farkı gerçek). consumer → customer **kaldı** (bilinen kullanım farkı).
4. **Başka akışlardaki eşler** (guarantee → warranty s15, fee → price s1, convert → exchange s15, worthwhile → worth s15, consumer → customer s10, wage → salary s3): s31 dışına dokunulmadı; derleyici çifti iki yönlü bağlıyor (s22'deki uygulama).
5. **Türkçe karşılıklar:** ship "kargoya vermek" (alt "kargolamak") doğru ve gündelik; double "ikiye katlanmak" doğal ("kiralar ikiye katlandı"); overpriced "fahiş fiyatlı" doğru, "kazık" gündelik alt olarak uygun; worthwhile "zahmetine değer" doğru; on a budget "kısıtlı bütçeyle" doğru; wage "ücret" (alt "maaş") kaldı, çünkü asgari ücrete gündelik dilde "maaş" da deniyor.
6. **Köken:** inflation (Lat. inflare), luxury (Lat. luxuria, Eski Fransızca yoluyla), expire (Lat. exspirare) doğru; kaldı.
7. **İki kez okunacak quiz'ler:** splash out "stock up" (restoran için anlamsız) doğru çeldirici; stock up on "ran out" ("ran out on bread" olmaz, "of" ister) doğru; wealthy "costly / priceless" kişi için kullanılmaz, doğru; well-off "worthy" → "expensive" değişti; wage "tax" (işçiler daha yüksek saatlik vergi istemez) doğru; luxury "bonus" ("a bonus we can't afford" anlamsız) doğru; cost of living'in üç yanlış şıkkı hata biçimleri ("cost of life", "life expenses", "price of life"). Kuraldaki "gerçek hata biçimleri iyi çeldiricidir" ilkesine uyuyor ve hiçbiri doğru İngilizce değil; kaldı.

## Seviye (B2 uygunluğu)

Seviyeler değiştirilmedi; aşağıdakiler editoryal olarak sorgulanabilir:

- **Muhtemelen B1** (gündelik, Oxford 3000/EVP'de B1 civarı): income, payment, label, economy, complaint, valuable, monthly (monthly A2–B1 bile olabilir).
- **Muhtemelen C1:** splash out (gündelik, İngiliz İngilizcesi ağırlıklı), get your money's worth (deyim).
- Geri kalan 51 kart B2 için makul.

## Değişiklik tablosu

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| profit | confusables | ["prophet"] → (yok) | Eş sesli ama B2 öğrencisi 'profit' yerine 'prophet' yazmaz ya da tersini anlamaz; bilgi notta kaldı. |
| profit | examples.0.tr | "Kafe geçen yıl az bir kâr etti." → "Kafe geçen yıl biraz kâr etti." | 'az bir kâr etti' doğal değil. |

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| purchase | examples.1.tr | "Fişi, satın aldığınızın kanıtı olarak saklayın." → "Fişi, satın alma belgesi olarak saklayın." | 'satın aldığınızın kanıtı olarak' çeviri kokuyor; mağazada 'satın alma belgesi' denir. |
| deal | l1.tr.mistakes.0.why | "Türkçedeki 'kaçmaz fırsat' kelime kelime 'opportunity' diye çevriliyor. Uygun fiyatlı alışveriş için İngilizcede 'a (good) deal' denir." → "Türkçedeki 'fırsat' kelime kelime 'opportunity' diye çevriliyor ('fırsat ürünü' gibi). Uygun fiyatlı alışveriş için İngilizcede 'a (good) deal' denir." | Hata gerçek; açıklama 'kaçmaz fırsat' kalıbına daraltılmıştı. |
| inflation | l1.tr.alt | ["hayat pahalılığı"] → [] | 'hayat pahalılığı' cost of living kartının ana anlamı; enflasyonun karşılığı değil. |
| wealth | l1.tr.note | "Sayılamaz: 'a wealth' değil, 'wealth'. Sıfatı 'wealthy' (zengin)." → "Bu anlamda sayılamaz, 'a' almaz: 'great wealth'. ('A wealth of' ise 'bir sürü, bol' demektir.) Sıfatı 'wealthy' (zengin)." | 'a wealth' kalıbı İngilizcede var ('a wealth of information'); not mutlak yanlış söylüyordu. |

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| supply | l1.tr.mistakes | "The company supplies the hospitals medicine." → (silindi) | Uydurma görünüyor: Türkçede 'hastanelere ilaç sağlamak' yönelme + belirtme kurar, 'supply the hospitals medicine' biçimine itmez. 'with' düşmesi Türkçeye özgü değil. |
| double | l1.tr.mistakes | "Prices became double." → (silindi) | 'Prices became double' Türkçe konuşanlarda yaygın bir kalıp olarak doğrulanamadı; uydurma riskine karşı silindi. |
| ship | l1.tr.mistakes | "I'll cargo the package tomorrow." → "I sent the package by cargo." (right: "I shipped the package.") | 'I'll cargo the package' fiil kullanımı zorlama; Türkçe konuşanların gerçekten kurduğu cümle 'by cargo' / 'with cargo' biçimidir. |
| trade | examples.1.en | "The two countries agreed to trade in their own currencies." → "The two countries want to trade more with each other." | Eski örnek 'trade in their own currencies' notta anlatılan 'trade in + ürün' kalıbıyla çelişiyordu (burada 'in' para birimi). |
| trade | examples.1.tr | "İki ülke kendi para birimleriyle ticaret yapma konusunda anlaştı." → "İki ülke birbiriyle daha fazla ticaret yapmak istiyor." | Yeni İngilizce örnekle uyum. |

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| expire | l1.tr.mistakes.0.wrong | "The time of my passport is finished." → "My passport's time is over." | Türkçedeki 'süresi bitti' kalıbının gerçekte duyulan biçimi; 'The time of my passport is finished' yapay. |
| tempt | examples.1.tr | "Kırmızı elbiseyi almak içimden geçti ama çok pahalıydı." → "Kırmızı elbiseyi alasım geldi ama çok pahalıydı." | 'almak içimden geçti' sınırda; 'alasım geldi' 'was tempted to buy' anlamını doğal verir. |
| valuable | l1.tr.alt | ["kıymetli", "pahalı"] → ["kıymetli"] | 'pahalı' expensive'dir; 'valuable advice' anlamını kaçırır. |
| economic | l1.tr.equivalence | "partial" → "false_friend" | Sahte dost dolduruldu. |
| economic | l1.tr.false_friend | (yok) → {"tr_word": "ekonomik", "tr_means": "ucuz, tasarruflu, az yakan (ekonomik araba, ekonomik paket)", "en_for_that": "economical / cheap"} | Gerçek kısmi sahte dost: 'ekonomik araba' = economical car; 'economic car' yanlış. |
| well-off | quiz.distractors | ["valuable", "worthy", "precious"] → ["valuable", "expensive", "precious"] | 'worthy enough to buy' (hak edecek kadar) zorlamayla okunabiliyordu; 'expensive' kişi için açıkça yanlış. |

#### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| genuine | l1.tr.note | "Türkçede sahte olmayan ürüne 'orijinal' denir. İngilizcede bu anlamda 'genuine' ya da 'real' daha yaygındır; 'original' çoğu zaman 'ilk, kopya olmayan' demektir." → "Türkçede sahte olmayan ürüne 'orijinal' denir. İngilizcede bu anlamda 'genuine' ya da 'real' daha yaygındır; 'original' çoğu zaman 'ilk, asıl' demektir: 'the original version'." | Eski not 'original' için 'kopya olmayan' diyordu; bu tam da 'genuine' anlamı, not kendisiyle çelişiyordu. |
| get your money's worth | l1.tr.alt | ["parasına değmek"] → [] | 'parasına değmek' worth the money'dir (özne şey); 'paranın hakkını çıkarmak' kişinin yaptığı şey. |
| get your money's worth | examples.2.tr | "Biletler pahalıydı ama gösteri üç saat sürdü, yani paramızın hakkını aldık." → "Biletler pahalıydı ama gösteri üç saat sürdü, yani paramızın hakkını çıkardık." | Kalıp 'hakkını çıkarmak'; 'hakkını aldık' başka anlama kayıyor. |

Değişmeyen ama bakılanlar: bütün IPA'lar (financial UK /faɪˈnænʃəl/ da kabul edilebilir), bütün quiz'ler (yalnızca well-off değişti), etimolojiler, `primary_topic` seviye aralıkları (doğrulayıcı `LEVEL_RANGE` vermedi). payment quiz'inde "complaint" şıkkı tekil ve artikelsiz olduğu için dilbilgisi olarak yanlış; bırakıldı. affordable quiz'inde "expensive" şıkkı "but" yüzünden mantıksız; bırakıldı.

## Anadili Türkçe birinin bakması gerekenler

1. **Hata maddelerinin sıklığı:** "all my saving" (savings), "My passport's time is over" (expire), "I sent the package by cargo" (ship), "At this price, the phone is a big opportunity" (deal), "The minimum salary went up again" (wage), "I made insurance for my car" (insurance), "The goods was sent yesterday" (goods).
2. **Sahte dost:** economic ↔ ekonomik; `tr_means` metni ("ucuz, tasarruflu, az yakan") doğal mı?
3. **Örnek çevirileri:** tempt "Kırmızı elbiseyi alasım geldi" (eski: "almak içimden geçti"); splash out 3. örnek "Yeni telefona para saçma" ("Don't splash out" için fazla olumsuz mu?); cost of living ana anlam "hayat pahalılığı" mı, "geçim masrafları" mı (cost of living nötr, "hayat pahalılığı" yüksekliği de anlatıyor)?
4. **Karşılıklar:** goods "mallar" (gündelik dilde "ürünler" daha doğal olabilir); fee alt "aidat" (yalnızca üyelik için); deposit ana anlam "kapora" (kiralık evde "depozito" ayrı).
5. **Karışan kelime eşleri:** fee → price ve tempt → attempt sınırda.

## Son doğrulama

Çeldirici ve son kontrol adımı (2026-10-26): 60 sorunun şıkları yeniden tek tek boşluğa kondu; hepsinde tek doğru cevap var, değişiklik gerekmedi. `distractor_stats.py`: `s31: 60 quizzes, 119 distinct distractors; top: wage×4, renew×4, wealthy×4, refund×3, wages×3, inflation×3` (en çok 4; sınır max(4, %5) = 4). `ipa_dress_stats.py`: `uk_e 0, uk_ɛ 10, us_e 0, us_ɛ 11`. Başka akışlarla baş kelime çakışması (lemma, tekil/çoğul ve 'your' normalize edilerek): 0.

```
cd content-pipeline
python -X utf8 -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s31
60 kart · 60 şemadan geçti · 0 hata · 0 uyarı
```

## Örneklem denetimi (2026-10-26)

Üç bağımsız denetçi B2 destesinden 80 kartlık bir örneklemi okudu (Türkçe, İngilizce ve quiz gözüyle). Bulgular tek tek doğrulandı; doğru olanlar düzeltildi. Bulgulardan çıkan beş sistematik sorun (notlarda 'siz' hitabı, İngilizce cümlede özne olan 'Can' adı, ikinci anlama kayan örnek ve eşdizimler, başka sözcük türünden çeldiriciler, B1 olabilecek seviyeler) s23–s32'nin 600 kartında tarandı.

- Bu akışta değişen kart: **7**, alan: **10**. Değişen kartlara `critic_edited` eklendi.
- Çeldirici: `s31: 60 quizzes, 119 distinct distractors; top: wage×4, renew×4, wealthy×4, refund×3, wages×3, inflation×3` (sınır max(4, %5) = 4 aşılmıyor).
- Seviye: değiştirilmedi. B1 olabilecek kartlar bu dosyanın seviye bölümünde zaten işaretli; karar kullanıcıda.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| deposit.n.1 | examples[2] | "When we moved out, the landlord gave us our deposit back. / Evden çıkınca ev sahibi depozitomuzu geri verdi." → "We put down a small deposit to hold the car until Monday. / Arabayı pazartesiye kadar ayırtmak için küçük bir kapora verdik." | Kiralık evdeki depozito ayrı anlam |
| deposit.n.1 | collocations | "pay a deposit, put down a deposit, security deposit, deposit on sth" → "pay a deposit, put down a deposit, a 10 percent deposit, deposit on sth" | 'security deposit' ayrı anlam |
| label.n.1 | collocations | "read the label, food label, price label, designer label" → "read the label, food label, price label, check the label" | 'designer label' marka anlamı |
| wage.n.1 | l1.tr.alt | "yevmiye, maaş" → "yevmiye" | Kartın notu ve hatası 'maaş'ı 'salary'ye bağlıyor; alt'ta çelişkiydi |
| invest.v.1 | collocations | "invest in sth, invest money, invest time" → "invest in sth, invest money, invest wisely" | 'invest time' mecazi anlam |
| valuable.adj.1 | examples[2] | "The internship gave Burak valuable experience. / Staj, Burak'a değerli bir deneyim kazandırdı." → "The thieves took some valuable paintings from the museum. / Hırsızlar müzeden bazı değerli tabloları çaldı." | 'valuable experience' yararlı anlamı |
| valuable.adj.1 | collocations | "valuable items, valuable advice, valuable experience" → "valuable items, valuable jewelry, a valuable painting" | 'valuable advice/experience' yararlı anlamı |
| monthly.adj.1 | def.micro | "happening 12 times a year" → "regular, 12 times a year" | '12 times a year' düzensiz 12 olayı da kapsıyordu; 'regular' eklendi (month türevi doğrulayıcıda yasak) |
| monthly.adj.1 | def.short | "happening, done or paid 12 times a year, like rent or a salary" → "happening, done or paid regularly 12 times a year, like rent or a salary" | 'regular(ly)' eklendi |
| on_a_budget.phr.1 | examples[1] | "As a student on a budget, Can cooks at home most days. / Kısıtlı bütçeli bir öğrenci olan Can çoğu gün evde yemek yapıyor." → "As a student on a budget, Ozan cooks at home most days. / Kısıtlı bütçeli bir öğrenci olan Ozan çoğu gün evde yemek yapıyor." | 'Can' adı İngilizcede modal 'can' gibi okunuyor |

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Seviye kararı (2026-10-26)

İki bağımsız yargıç B1 olabilecek adayları ayrı ayrı değerlendirdi. İkisinin de B1 ya da altı dediği **5 kart** `level: "B1"` oldu; `level_source` yine `editorial_estimate`. Kart ID'leri seviye içermediği için değişmedi. Yargıçların ayrıntılı gerekçe metinleri bu düzenlemeye gelmedi; satırlardaki gerekçe, yargıç kararının editör özetidir.

- `en.payment.n.1` (payment): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.label.n.1` (label): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.complaint.n.1` (complaint): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.valuable.adj.1` (valuable): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.monthly.adj.1` (monthly): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.

B2'de kalan adaylar (yargıçlar ayrıştı ya da B2 dedi): `en.income.n.1`, `en.economy.n.1`.

## İkinci örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) her akıştan 7 kartlık bir örneklemi (toplam 70 kart) ikinci kez okudu. 35 bulgunun hepsi kartla karşılaştırıldı ve hepsi gerçek çıktı; düzeltildi. Bulgulardan çıkan yeni sistematik sorunlar s23–s32'nin 600 kartında tarandı: `def.long`'un ikinci bir anlama kayması (ve aynı anlamın örnek, eşdizim, `alt` ya da quiz'e girmesi), başka sözcük türünden ya da yalnızca yazımı benzeyen çeldiriciler, ABD IPA'sında ɝ/ɚ yazımı, boş `confusables` dizisi.

- Bu akışta değişen kart: **8**, alan: **11**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.set_aside.phv.1`: Türkçe, not (düşük): gerçek. 'aynı resimdir' aktarma; 'birebir aynı mantıktır' yapıldı.
- `en.goods.n.1`: Türkçe, gloss (düşük): gerçek. gloss 'mal, ürünler', alt ['mallar', 'eşya'].
- `en.convert.v.1`: İngilizce, def.long (düşük): gerçek. 'different form' cümlesi silindi.
- `en.commercial.n.1`: İngilizce, tanım kapsamı (düşük): gerçek. def.long 'television or radio' oldu (short ve sense_note ile aynı).

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| deposit.n.1 | def.long | silinen cümle: "It is also money you give a landlord and get back if nothing is damaged." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| goods.n.1 | l1.tr.gloss | "mallar" → "mal, ürünler" | 'mallar' katı bir çoğul; Türkçede 'mal' topluluk adı olarak ya da 'ürünler' kullanılıyor (bulgu) |
| goods.n.1 | l1.tr.alt | "[ürünler, eşya]" → "[mallar, eşya]" | gloss değişince 'ürünler' alt'tan çıktı, 'mallar' alt'a indi (bulgu) |
| commercial.n.1 | def.long | "A short film or recording on television, radio or online that tries to make people buy a product or service. TV channels show them between …" → "A short film or recording on television or radio that tries to make people buy a product or service. TV channels show them between programs." | short ve sense_note ile aynı kapsam (TV/radyo) (bulgu) |
| luxury.n.1 | def.long | silinen cümle: "It can also mean great comfort, as in 'a life of luxury'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| luxury.n.1 | collocations | "[luxury hotel, luxury car, a life of luxury, can't afford luxuries]" → "[luxury hotel, luxury car, can't afford luxuries, a real luxury]" | 'a life of luxury' konfor anlamı (tarama) |
| convert.v.1 | def.long | silinen cümle: "It can also mean changing something into a different form." | def.long ikinci bir anlama kayıyordu; o cümle silindi (bulgu) |
| valuable.adj.1 | def.long | silinen cümle: "It also means very useful, as in 'valuable advice' or 'valuable experience'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| valuable.adj.1 | def.short | "worth a lot of money, or very useful and important" → "worth a lot of money, like jewelry or old paintings" | 'very useful' ikinci anlam (tarama) |
| genuine.adj.1 | def.long | silinen cümle: "It can also describe real feelings, as in 'a genuine smile'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| set_aside.phv.1 | l1.tr.note | "Nesne ortada da olabilir: 'set money aside' ya da 'set aside money'. Türkçedeki 'kenara para koymak' ile aynı resimdir." → "Nesne ortada da olabilir: 'set money aside' ya da 'set aside money'. Türkçedeki 'kenara para koymak' ile birebir aynı mantıktır." | 'aynı resim' İngilizceden aktarma (bulgu) |

- Çeldirici: `s31: 60 quizzes, 119 distinct distractors; top: wage×4, renew×4, wealthy×4, refund×3, wages×3, inflation×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Üçüncü örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) s23–s32'den 80 kartlık yeni bir örneklemi okudu. 35 bulgu kartla karşılaştırıldı: 33'ü gerçek çıktı ve düzeltildi, 2'si (release, carbon footprint çevirileri) gerekçesiyle reddedildi. Önceki iki turun listesinde olmayan sistematik sorunlar s23–s32'nin 600 kartında tarandı: `gloss_short`'ta kesilmiş söz; `alt`'ın kartın kendi notuyla ya da başka bir kartın ayrımıyla çelişmesi (ve önceki taramada kalan ikinci anlam karşılıkları); `grammar.pattern`'da başka anlamın kalıbı; `def.long`'da önceki anahtar sözcük taramasının kaçırdığı ikinci anlam cümleleri (ve aynı anlamın örnek, eşdizim, quiz'e taşması); akraba kartlar arasında neredeyse aynı örnek ya da boşluklu cümle; boşluğa anlamca hiç uymayan, soruyu ele veren çeldiriciler; şapkası düşmüş hâl / dâhil. Seviyeler değişmedi.

- Bu akışta değişen kart: **10**, alan: **11**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.affordable.adj.1`: Türkçe, alt (düşük): gerçek. 'ucuz' yerine 'makul fiyatlı'.
- `en.genuine.adj.1`: Quiz, çeldiriciler (düşük): gerçek. fake, artificial, imitation ('but' karşıtlığıyla açıkça yanlış).
- `en.advertising.n.1`: Quiz, çeldiriciler (düşük): gerçek. banking, insurance, retail; cümleye '… making TV and online ads for big brands' eklendi.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| deposit.n.1 | l1.tr.alt | "[ön ödeme, depozito]" → "[ön ödeme]" | 'depozito' kiralık ev anlamı (notta var); önceki taramada kalmış (tarama) |
| inflation.n.1 | examples[2] | "The central bank raised rates to bring inflation down. / Merkez bankası enflasyonu düşürmek için faizleri artırdı." → "Many families are worried about rising inflation. / Birçok aile artan enflasyondan endişe ediyor." | başka bir kartta neredeyse aynı cümle vardı (interest: 'The central bank raised interest rates again') (tarama) |
| luxury.n.1 | examples[1] | "They stayed in a luxury hotel in Bodrum. / Bodrum'da lüks bir otelde kaldılar." → "They spent their honeymoon in a luxury villa in Kaş. / Balayılarını Kaş'ta lüks bir villada geçirdiler." | başka bir kartta neredeyse aynı cümle vardı (luxurious: 'We stayed in a luxurious hotel in Bodrum') (tarama) |
| advertising.n.1 | quiz.cloze | "She studied marketing and now has a job in ______." → "She studied marketing and now has a job in ______, making TV and online ads for big brands." | Sektör şıklarını eleyen bağlam (bulgu) |
| advertising.n.1 | quiz.distractors | "[savings, interest, wages]" → "[banking, insurance, retail]" | 'savings/interest/wages' iş alanı değil (bulgu) |
| invest.v.1 | def.long | silinen cümle: "You can also put time or effort into something." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| affordable.adj.1 | l1.tr.alt | "[hesaplı, ucuz]" → "[hesaplı, makul fiyatlı]" | 'ucuz' notun olumsuz bulduğu 'cheap' (bulgu) |
| genuine.adj.1 | quiz.distractors | "[faulty, annual, broken]" → "[fake, artificial, imitation]" | 'annual/faulty/broken leather' anlamsızdı (bulgu) |
| splash_out.phv.1 | l1.tr.alt | "[bol para harcamak, para saçmak]" → "[bol para harcamak]" | 'para saçmak' olumsuz; not çoğu zaman olumlu diyor (tarama) |
| cut_costs.phr.1 | l1.tr.note | "Türkçedeki 'masrafları kısmak' ile aynı resimdir. Benzer anlamda 'cut back on sth' de denir: 'cut back on eating out'." → "Türkçedeki 'masrafları kısmak' ile birebir aynı mantıktır. Benzer anlamda 'cut back on sth' de denir: 'cut back on eating out'." | 'aynı resim' İngilizceden aktarma (önceki turda bir kartta düzeltilmişti) (tarama) |
| get_your_moneys_worth.idm.1 | l1.tr.note | "İyelik sözcüğü kişiye göre değişir: 'get my/our/his money's worth'. Türkçedeki 'paranın hakkını çıkarmak' ile aynı resimdir." → "İyelik sözcüğü kişiye göre değişir: 'get my/our/his money's worth'. Türkçedeki 'paranın hakkını çıkarmak' ile birebir aynı mantıktır." | 'aynı resim' İngilizceden aktarma (önceki turda bir kartta düzeltilmişti) (tarama) |

- Çeldirici: `s31: 60 quizzes, 123 distinct distractors; top: wage×4, renew×4, wealthy×4, refund×3, inflation×3, wealth×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
