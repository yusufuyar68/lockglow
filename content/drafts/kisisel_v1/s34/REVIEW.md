# s34 QA incelemesi (YDS/YÖKDİL Çekirdek 2: akademik isimler)

Kapsam: `content/drafts/kisisel_v1/s34/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: YDS ve YÖKDİL okuma parçalarında sık geçen akademik isimler. Seviye: 52 C1, 8 B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** bir yazar ajanı, `1_yazar_kurallari.md`, s32 biçimi.
2. **Denetim:** bir denetçi ajanı (bu rapor), `2_denetci_kurallari.md` ve B2 tur denetimlerinden çıkan tuzak listesi. 60 kart tek tek okundu: tek anlam (sense_note, tanımlar, örnekler, eşdizimler, `grammar.pattern`, `alt`, quiz), geri çeviri, gloss ve `gloss_short`, hata maddeleri, quiz'de her şık boşluğa konarak tek doğru cevap, akraba kartlar arasında benzer cümle, IPA, seviye, YDS'ye uygunluk. Yazarın "emin olmadığım" maddeleri ayrıca tartıldı (aşağıda).

## Özet

- İncelenen kart: **60** (C1: 52, B2: 8). Hepsi `type: word`, `pos: n`, `sense_no: 1`.
- `primary_topic`: hepsi `yds_yokdil_core` (B1–C1). `tags.exams`: `["yds", "yokdil"]`. `sensitivity`: hepsi 0.
- Değişen kart: **13** (`critic_edited`), **22** alan.
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: 2 kartta (emergence, advent; ikisi de doğru), diğerleri `null`. Sahte dost yok.
- **Kilit ekranı anlamı:** 60 kartın hepsinde ≤16 karakter (2 kartta `gloss_short`: prospect "olasılık", variation "değişim"; ikisi de ana anlamın gerçek kısaltması).
- **confusables:** 18 kartta; boş `confusables: []` yok.
- **mistakes:** 4 kartta 4 madde (reached to a consensus, the most important criteria, emphasizes on, did a contribution); hepsi kaldı.
- **Çeldirici:** 76 farklı şık; en sık precaution ×4, sequence ×4, insight ×4, aftermath ×4, variable ×4, setback ×4 (sınır max(4, %5) = 4).
- **IPA:** US `ɜːr/ər`, ɝ/ɚ yok. DRESS US 18/18, UK 15/15 `/ɛ/`.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Akraba kartlarla ya da kartın kendi örneğiyle neredeyse aynı cümle.** emergence ile advent'in hem 1. örneği hem boşluklu cümlesi aynı yapıdaydı ("Since the ______ of smartphones" / "Since the ______ of the printing press"); emergence sorusunda "advent" de doğru olurdu. proportion'ın 3. örneği ve quiz'i fraction'ın 1. örneğiyle aynı kalıptaydı ("Only a small ______ of the money"); bu soruda "fraction" da doğru olurdu. deficiency ve reliance quiz'leri kartın kendi 2. örneğinin neredeyse aynısıydı. Dördü de yeni cümle aldı.
  2. **İkinci anlama kayma.** capacity'de "production capacity" (2. örnek, eşdizim) ve quiz'deki "double the country's capacity to produce electricity" üretilebilecek miktar anlamını sınıyordu; nottaki "üretme gücü" de aynı yöne itiyordu. Kart "yeti, yapabilme gücü" anlamına indirildi. notion'ın tanımları "often one that may be wrong" ile anlamı yanlış daraltıyordu.
  3. **Türkçe doğallık ve sözcük türü.** setback örnek çevirileri ("büyük bir aksilik oldu", "bir aksilik yaşadı") haber Türkçesinde "darbe", "sekteye uğramak" olur. emphasis'te "vurgu … üzerinde" çeviri kokuyordu. `alt`'ta başka sözcük türü vardı (incentive "teşvik edici", fraction "azıcık"). predecessor'da "öncül" mantıktaki "premise" olarak okunuyordu; TDK'nin "selef" karşılığı "öncel" kondu.
- precaution quiz'indeki venue, monument, vacancy cümlenin konusuna hiç uymuyordu ve soruyu ele veriyordu; incentive, verdict, setback ile değişti.
- Quiz'lerin geri kalanı tek cevaplı bulundu. Cevabı da kabul edebilecek eş anlamlılar (notion/assumption, advent/emergence, fraction/proportion, variation/fluctuation) aynı soruda şık değil. variation sorusundaki "variable" ve distribution sorusundaki "contribution" bilinçli biçim tuzakları; boşlukta anlamsızlar. inquiry sorusunda ("launched an ______") üç çeldirici de ünlüyle başlıyor; "an" ipucu vermiyor.
- Örneklerin İngilizcesi doğal ve YDS okuma diline uygun (kısa haber ve araştırma cümleleri). Amerikan yazımı tutarlı (urbanization, defense, center, color). "Can" adı geçmiyor; özneler Mert, Burak, Zeynep ya da genel.
- Notlarda hitap hep "sen"; notlar büyük harfle başlıyor; hâl, tarihî, resmî, mâni şapkalı.
- YDS uygunluğu: 60 başlığın hepsi YDS/YÖKDİL okuma parçalarında ve eş anlamlı soru tiplerinde sık geçen akademik isimler. Notlardaki "YDS'de X ile eş anlamlı sorulur" ipuçları doğru eşleri veriyor (drawback/disadvantage, constraint/restriction, obstacle/impediment, aftermath/in the wake of).

## Yazarın "emin olmadığım" maddeleri

1. **contribution "She did a great contribution to the team":** kaldı. "Katkı yapmak" Türkçede yaygın ve do/make karışıklığı Türk öğrencilerde bilinen bir hata türü ("do a mistake" gibi). Sıklığı yine de anadili Türkçe birinin onayına bırakıldı (aşağıda).
2. **outcome → income:** kaldı. Biçim karışıklığı (in-come / out-come) gerçek: öğrenci "outcome"u "income"un karşıtı (gider, çıkan para) sanabiliyor; not bunu düzeltiyor. Düz eş anlam ya da yalnızca aynı konu değil.
3. **Karşı yön bağlantıları:** emergence → emergency (s12), outcome → income (s31), proportion → portion (s26), tendency → trend (s24), sequence → consequence (s30) hâlâ tek yönlü. Denetçi de yalnızca s34'e yazabildiği için eklenmedi; karşı yön sonraki bir toplu düzeltmede s12, s24, s26, s30, s31 kartlarına eklenmeli. consent, perspective, effectiveness ve prevention destede başlık değil; tek yön yeterli.
4. **counterpart "mevkidaş, muadil":** kaldı. İkisi de Türk haber dilindeki gerçek karşılık ("Fransız mevkidaşıyla görüştü"); YDS öğrencisi bunları zaten okuyor. `alt`'taki "eşdeğer, akran" kolay karşılığı veriyor. **predecessor:** "selef, öncül" → "selef, öncel" (yukarıda).
5. **inquiry US IPA `/ˈɪŋkwəri/`:** kaldı. Amerikan sözlüklerinde yaygın biçim olarak geçiyor; UK `/ɪnˈkwaɪəri/`.
6. **fraction "küçük bir kısım":** kaldı. Tek sözcüklük doğru karşılık yok ("kesir" matematik anlamı); kilit ekranında 16 karakter ve doğal okunuyor. `alt`'taki "azıcık" (isim değil) değişti.
7. **Daraltılmış anlamlar:**
   - **deficiency:** bedendeki madde eksikliği tek anlam olarak tutarlı (tanımlar, örnekler, eşdizimler, quiz); sistem kusuru anlamına kayan yer yok. Kaldı.
   - **capacity:** "production capacity" gerçekten miktar anlamına kayıyordu; düzeltildi (yukarıda).
8. **incentive "tax burdens":** kaldı. "Offering tax burdens to companies that create new jobs" anlamsız; "tax burden" gerçek bir öbek olduğu için iyi bir tuzak. Tek doğru cevap "incentives".

## Değişiklik tablosu

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| emergence.n.1 | examples[0] | "The emergence of the internet changed how we learn. / İnternetin ortaya çıkışı öğrenme biçimimizi değiştirdi." → "The study examines the emergence of modern democracy. / Çalışma, modern demokrasinin ortaya çıkışını inceliyor." | advent kartının 1. örneğiyle ('The advent of television changed family life') neredeyse aynı yapıdaydı |
| emergence.n.1 | quiz.cloze | "Since the ______ of smartphones, most people read the news on small screens." → "The ______ of a new opposition party has changed the political balance in the country." | advent kartının boşluklu cümlesiyle ('Since the ______ of the printing press') neredeyse aynıydı; 'advent' de cevap olabilecek bir kalıptı |
| notion.n.1 | def.short | "an idea or a belief about something, often one that may be wrong" → "an idea or a belief about what something is like" | 'often one that may be wrong' anlamı daraltıp yanlış bir çağrışım ekliyordu |
| notion.n.1 | def.long | "An idea or a belief about what something is like or how it should be, especially one that some people think is wrong." → "An idea or a belief about what something is like or how it should be. It is often used when people question or reject that idea." | 'one that some people think is wrong' sözcüğün anlamı değil, kullanım bağlamı; öyle anlatıldı |
| assumption.n.1 | examples[2] | "Try not to make assumptions about people from their clothes. / İnsanlar hakkında kıyafetlerine bakarak varsayımlarda bulunmamaya çalış." → "Try not to make assumptions about people based on their clothes. / İnsanlar hakkında kıyafetlerine bakarak varsayımlarda bulunmamaya çalış." | 'from their clothes' doğal değil; 'based on' olmalı |
| capacity.n.1 | examples[1] | "The factory's production capacity has doubled. / Fabrikanın üretim kapasitesi iki katına çıktı." → "Some patients lose the capacity to make decisions for themselves. / Bazı hastalar kendi kararlarını verme yetisini kaybeder." | 'production capacity' üretilebilecek miktar anlamına (ikinci anlam) kayıyordu |
| capacity.n.1 | collocations | "[production capacity, the capacity to do sth, capacity for learning]" → "[the capacity to do sth, capacity for learning, lack the capacity]" | 'production capacity' miktar anlamı; kartın yeti anlamına uyan eşdizim kondu |
| capacity.n.1 | l1.tr.note | "Burada yeti ya da üretme gücü anlamındadır. YDS'de 'the capacity to do sth' ve 'capacity for sth' kalıplarıyla sorulur; 'capability' ile y…" → "Burada bir şeyi yapabilme yetisi ya da gücü anlamındadır. YDS'de 'the capacity to do sth' ve 'capacity for sth' kalıplarıyla sorulur; 'cap…" | 'üretme gücü' miktar anlamına (fabrika kapasitesi) kayıyordu |
| capacity.n.1 | quiz.cloze | "The new power plant will double the country's ______ to produce electricity." → "Long periods of stress can reduce our ______ to think clearly." | 'double the country's capacity to produce electricity' üretim miktarı anlamını sınıyordu |

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| deficiency.n.1 | quiz.cloze | "Doctors say that iron ______ is one reason why some people feel tired all the time." → "Weak bones can be a sign of calcium ______." | 2. örnekle ('Iron deficiency can make you feel tired') neredeyse aynı cümleydi |
| deficiency.n.1 | quiz.distractors | "[density, emphasis, validity]" → "[emphasis, validity, transition]" | 'calcium density' (kemik yoğunluğu çağrışımı) yeni cümlede ikinci okuma verebilirdi |
| incentive.n.1 | l1.tr.alt | "[özendirme, teşvik edici]" → "[özendirme]" | 'teşvik edici' sıfat; isim kartında başka sözcük türü |

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| proportion.n.1 | examples[2] | "Only a small proportion of plastic waste is recycled. / Plastik atıkların yalnızca küçük bir kısmı geri dönüştürülüyor." → "What proportion of your income do you spend on rent? / Gelirinin ne kadarını kiraya harcıyorsun?" | fraction kartının 1. örneğiyle ('Only a fraction of the money…') aynı yapıdaydı |
| proportion.n.1 | quiz.cloze | "Only a small ______ of the money was spent on education." → "A growing ______ of young people now choose to live alone." | 'Only a small ______ of the money' fraction kartının örneğiyle neredeyse aynıydı ve 'fraction' da doğru olurdu |
| reliance.n.1 | quiz.cloze | "The country is trying to reduce its ______ on imported gas." → "Heavy ______ on a single crop makes farmers vulnerable to bad weather." | 2. örnekle ('reduce its reliance on imported oil') neredeyse aynı cümleydi |

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| setback.n.1 | examples[0] | "The injury was a major setback for the team. / Sakatlık takım için büyük bir aksilik oldu." → "The injury was a major setback for the team. / Sakatlık takım için büyük bir darbe oldu." | 'büyük bir aksilik oldu' doğal değil |
| setback.n.1 | examples[1] | "The project suffered a setback when its funding was cut. / Fonu kesilince proje bir aksilik yaşadı." → "The project suffered a setback when its funding was cut. / Fonu kesilince proje sekteye uğradı." | 'bir aksilik yaşadı' doğal değil; 'sekteye uğramak' haber dilindeki karşılık |
| emphasis.n.1 | examples[2] | "In this course, the emphasis is on speaking skills. / Bu kursta vurgu konuşma becerileri üzerinde." → "In this course, the emphasis is on speaking skills. / Bu kursta ağırlık konuşma becerilerinde." | 'vurgu … üzerinde' çeviri kokuyordu |

#### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| precaution.n.1 | quiz.distractors | "[venue, monument, vacancy]" → "[incentive, verdict, setback]" | venue, monument, vacancy cümlenin konusuna hiç uymuyordu, soruyu ele veriyordu |
| fraction.n.1 | l1.tr.alt | "[ufak bir parça, azıcık]" → "[ufak bir parça, çok az bir miktar]" | 'azıcık' isim değil (zarf/sıfat) |
| predecessor.n.1 | l1.tr.gloss | "selef, öncül" → "selef, öncel" | 'öncül' Türkçede çoğunlukla mantıktaki 'premise' anlamında okunuyor; TDK'de 'selef' karşılığı 'öncel' |
| predecessor.n.1 | l1.tr.alt | "[önceki kişi, önceki model]" → "[önceki kişi, bir önceki model]" | 'önceki model' örnekteki karşılıkla ('bir önceki modelinden') uyumlu |

## Seviye (kartlar silinmedi, seviye değiştirilmedi)

- **B2 işaretli 8 kart** (outcome, assumption, obstacle, efficiency, emphasis, interaction, priority, contribution): Oxford 5000 / EVP'de B2 civarında; uygun. priority ve contribution B1'e yakın sayılabilir ama akademik kalıplarıyla (give priority to, make a contribution to) B2'de kalabilir.
- **C1 kartlar:** prevalence, notion, trait, constraint, scope, stance, threshold, counterpart, predecessor, aftermath, advent, inquiry, scarcity, fluctuation gibi çoğu kart C1 için inandırıcı. **B2'ye yakın olabilecekler:** capacity, component, criterion, dimension, mechanism, perception, phenomenon, proportion, significance, tendency, variation, transition, distribution, burden. Bunlar sözlük listelerinde B2 olarak da geçiyor; hepsi `yds_yokdil_core` aralığında (B1–C1) kaldığı için doğrulayıcı uyarı vermiyor. Karar kullanıcıda.

## Anadili Türkçe birinin bakması gerekenler

1. **Hata maddelerinin sıklığı:** "She did a great contribution to the team", "They finally reached to a consensus", "The most important criteria is the price", "The report emphasizes on the risks".
2. **Kilit ekranı karşılıkları:**
   - counterpart "mevkidaş, muadil": B2–C1 öğrencisine ağır geliyor mu?
   - predecessor "selef, öncel" (yeni).
   - fraction "küçük bir kısım": öbek olarak doğal mı?
   - setback "aksilik": örneklerde "darbe" ve "sekteye uğramak" kullanıldı; gloss "gerileme" mi olmalı?
   - welfare "refah, esenlik": notta "çocuk esenliği" mi "çocuk refahı" mı?
3. **Örnek çevirileri:**
   - setback "Fonu kesilince proje sekteye uğradı." (yeni)
   - emphasis "Bu kursta ağırlık konuşma becerilerinde." (yeni)
   - prevalence "genç erkekler arasında sigara kullanımının yüksek yaygınlıkta olduğunu buldu" doğal mı?
4. **outcome → income** karışıklığının öğrencide gerçekten olup olmadığı.

## Çeldirici ve IPA son kontrolü (2026-10-26)

- `distractor_stats.py`: `s34: 60 quizzes, 76 distinct distractors; top: precaution×4, sequence×4, insight×4, aftermath×4, variable×4, setback×4`. Sınır max(4, %5) = 4; aşan yok. (Ara adımda precaution sorusuna konan "consensus" 5'e çıkınca "verdict" ile değiştirildi.)
- `ipa_dress_stats.py`: `s34 {'uk_e': 0, 'uk_ɛ': 15, 'us_e': 0, 'us_ɛ': 18}`. DRESS ünlüsü her yerde `/ɛ/`; ABD IPA'sında ɝ/ɚ yok.
- Başlık taraması: s34'teki 60 başlık sözcüğünün hiçbiri başka akışta başlık değil.

## Son doğrulama

`python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s34` → `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

İki denetçi (Türkçe ve İngilizce gözü) s33–s36'dan alınan 48 kartlık örneklemi okudu; 21 bulgu (17 kart) kartla karşılaştırıldı: 20'si gerçek çıktı ve düzeltildi, 1'i (scarcity, 'işçi kıtlığı') gerekçesiyle reddedildi. Bulgulardaki her sistematik sorun s33–s36'nın 240 kartında tarandı: yanlış sözcük ailesi bilgisi (virtually), notla çelişen örnek ya da fazla keskin ayrım (başka yok), anlamı düşen `gloss_short` (başka yok), yerleşik olmayan Türkçe terim (başka yok), çeviri kokan Türkçe örnek (6 kart), bağlacın anlamı ve dilbilgisi (başka yok), tanım doğruluğu (başka yok), eş anlamlı inceliği ve kartın tek anlamı (precisely, perceive, stimulate), doğal olmayan eşdizim (başka yok), örneklerle uyuşmayan `grammar.pattern` (bulguyla birlikte 21 kart), kilit ekranı karşılığının quiz bağlamını karşılamaması (impose, exert) ve seviye (Oxford 3000'de B2 olan 10 kart daha B2'ye indi). 'Can' adı, 'siz' hitabı, şapkasız hâl/dâhil, IPA ve boş `confusables` yeniden tarandı; sorun yok.

- Bu akışta değişen kart: **8**, alan: **12**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.tendency.n.1`: Türkçe ve İngilizce, not (orta; iki denetçi aynı sorun): gerçek. Not 'trend'i toplumun gidişatına, 'tendency'yi kişiye ayırıyordu; 2. örnek ('a growing tendency for people to…') bununla çelişiyordu. Not yumuşatıldı. Seviye (düşük): gerçek, Oxford 3000'de B2; C1 → B2. Taramada `grammar.pattern`'a örneklerdeki 'for sb to do' ve 'towards sth' eklendi.
- `en.welfare.n.1`: Türkçe, not ve 2. örnek (düşük): gerçek. 'çocuk esenliği' → 'çocuk refahı'; 'her çocuğun esenliğini' → 'iyiliğini'.
- `en.scarcity.n.1`: Türkçe, 2. örnek (düşük): **reddedildi**. 'İşçi kıtlığı', 'işgücü kıtlığı', 'eleman kıtlığı' Türkçe ekonomi haberlerinde yerleşik kullanımlardır; 'kıtlık' yalnızca kıtlık/mal darlığı için değil, emek için de kullanılır. Ayrıca çeviri kartın ana karşılığı 'kıtlık'ı koruyor; 'açığı' ya da 'eksikliği' bu bağı koparırdı.
- `en.capacity.n.1`: İngilizce, seviye (düşük): gerçek. Yeti anlamı Oxford 3000'de B2; C1 → B2.
- `en.distribution.n.1`: İngilizce, seviye (düşük): gerçek. Oxford 3000'de B2; C1 → B2.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| prevalence.n.1 | examples[1].tr | "Anket, genç erkekler arasında sigara kullanımının yüksek yaygınlıkta olduğunu buldu." → "Anket, genç erkekler arasında sigara kullanımının çok yaygın olduğunu ortaya koydu." | 'yüksek yaygınlıkta olduğunu buldu' çeviri kokuyordu (tarama) |
| capacity.n.1 | level | "C1" → "B2" | Yeti anlamı Oxford 3000/EVP'de B2 (bulgu) |
| mechanism.n.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| proportion.n.1 | examples[0].tr | "Öğrencilerin büyük bir oranı ailesiyle yaşıyor." → "Öğrencilerin büyük bir kısmı ailesiyle yaşıyor." | 'büyük bir oranı' çeviri kokuyordu (tarama) |
| proportion.n.1 | level | "C1" → "B2" | Oxford 3000'de B2, kartın anlamı temel anlam (tarama) |
| tendency.n.1 | l1.tr.note | "Kalıp: 'a tendency to do sth'. 'Trend' ile karıştırma: 'trend' toplumdaki genel gidişattır, 'tendency' bir kişinin ya da şeyin yatkınlığıdır." → "Kalıp: 'a tendency to do sth'. 'Trend' daha çok moda ya da istatistiksel gidişat için kullanılır; 'tendency' hem bir kişinin yatkınlığını hem de genel bir eğilimi anlatabilir: 'a growing tendency for people to…'." | Not 2. örnekle çelişiyordu; ayrım fazla keskindi (bulgu) |
| tendency.n.1 | level | "C1" → "B2" | Oxford 3000/EVP'de B2, temel anlam (bulgu) |
| tendency.n.1 | grammar.pattern | "a tendency to do sth" → "a tendency (for sb) to do sth / towards sth" | 2. ve 3. örneğin kalıbı yoktu (tarama) |
| distribution.n.1 | level | "C1" → "B2" | Oxford 3000/EVP'de B2 (bulgu) |
| welfare.n.1 | l1.tr.note | "'Animal welfare' (hayvan refahı) ve 'child welfare' (çocuk esenliği) öbekleri YDS'de sık geçer. 'Well-being' ile yakın anlamlıdır." → "'Animal welfare' (hayvan refahı) ve 'child welfare' (çocuk refahı) öbekleri YDS'de sık geçer. 'Well-being' ile yakın anlamlıdır." | 'çocuk esenliği' yerleşik terim değil (bulgu) |
| welfare.n.1 | examples[1].tr | "Öğretmenler her çocuğun esenliğini düşünmek zorunda." → "Öğretmenler her çocuğun iyiliğini düşünmek zorunda." | 'esenliğini' yapay duruyordu (bulgu) |
| fraction.n.1 | examples[1].tr | "Onu internetten fiyatının küçük bir kısmına alabilirsin." → "Onu internetten fiyatının çok altına alabilirsin." | 'fiyatının küçük bir kısmına' çeviri kokuyordu (tarama) |

- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
