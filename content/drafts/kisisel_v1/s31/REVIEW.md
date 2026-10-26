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
