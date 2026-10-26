# s23 QA incelemesi (B2 iş hayatı ve kariyer)

Kapsam: `content/drafts/kisisel_v1/s23/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin iş ilanında, iş yerinde ve ekonomi haberlerinde karşılaştığı kelimeler. 24 isim, 18 fiil, 12 sıfat, 4 phrasal verb ve 2 deyim. Hepsi B2 seviyesinde.

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** tek yazar ajanı yazdı (`1_yazar_kurallari.md`). Yazar, listedeki 60 kelimenin destedeki hiçbir kartla çakışmadığını `dump_lemmas.py` ile kontrol etti.
2. **Denetim:** bağımsız bir denetçi (bu rapor) 60 kartın hepsini tek tek okudu (`2_denetci_kurallari.md`). Her quiz'de dört şık boşluğa tek tek kondu. Türkçe çeviriler İngilizceye geri çevrildi. Yazarın "emin olmadığım" 10 maddesi ayrıca incelendi (aşağıda).

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 54 kelime, 4 phrasal verb (take on, carry out, follow up, fill in for), 2 deyim (be snowed under, get the ball rolling).
- `primary_topic`: `careers_interviews` 20, `workplace_office` 15, `business_management` 14, `success_productivity` 4, `phrasal_verbs` 4, `idioms_expressions` 2, `personality` 1.
- Değişen kart: **20** (`critic_edited`). Değişen alan: **32**.
- Reddedilen kart (`critic_reject`): **0**. `meta.status` hepsinde `draft` kaldı (s22'deki gibi). `sensitivity` hepsinde 0, `tags.exams` boş.
- **Silinen yaygın hata:** 0. 10 kartta 10 hata maddesi var ve hepsi gerçek Türkçe kaynaklı hata olarak tutuldu: "too many works", "made an internship", "did a great teamwork", "became retired", "headquarter", "in my agenda", "approve my new job", "consult to a lawyer", "I promoted last month", "capable to run".
- **Karışan kelimeler:** target ↔ objective çifti iki yönden de silindi. İkisi düz eş anlamlı ve kullanım farkı bir hata doğurmuyor. Kalan çiftler: applicant ↔ candidate, achievement → success, reputation → fame, retirement → pension, client → customer, proposal → offer/suggestion, vacancy → vacation, contract → contact, negotiate → bargain, recruit → hire, handle → deal with, submit → hand in, launch → lunch, estimate → guess, qualified ↔ skilled, efficient ↔ productive, efficient → effective, capable → able, trainee → trainer, take on → take over, carry out → carry on, fill in for → fill in.
- **Sahte dost:** 1 (agenda ≠ ajanda). Gerçek bir sahte dost; tutuldu.
- **Etimoloji:** 3 kart (candidate, agenda, strategy). Üçü de doğrulandı: candidatus/toga candida, agere/agenda (Fransızca agenda > ajanda) ve strategos. Kalan kartlarda `null`.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **İngiliz yazımı ve kullanımı.** Deste ABD yazımını kullanıyor. Şunlar değişti: behaviour, programme, neighbour, head teacher, Ms/Mr (noktasız), "holiday request", "on holiday", "ill" ve "flat". `CV` kaldı, çünkü destede 29 kez geçiyor.
  2. **Türkçe çevirilerde zorlama ya da devrik kalıplar.** Örnekler: "Kendisi çok yetkin bir yönetici", "yapabilecek yetenekte", "Mimar unvanını almak", "Dükkân ikinci el kitaplarda uzmanlaşmış", "katkı yapıyor" ve "takım çalışması sayesinde geldiğini".
  3. **`alt` içinde başka bir kelimenin karşılığı.** represent için "vekâlet etmek" fill in for'a, volunteer için "üstlenmek" take on'a, motivate için "cesaretlendirmek" encourage'a ait. trainee için yazılan "yönetici adayı" yalnızca management trainee'yi karşılıyor. objective için yazılan "erek" ise neredeyse hiç kullanılmıyor.
- **Quiz:** 60 sorunun hepsinde tek doğru cevap var. Üç soruda şıklar değişti:
  - submit sorusunda "approve your application form" kurulabiliyordu.
  - represent sorusunda "consult our company" kurulabiliyordu.
  - efficient sorusunda "more powerful: … works faster" kısmen savunulabiliyordu.
  - capable sorusundaki "able/skilled/ready of" şıkları gerçek bir hata kalıbını sınıyor ve iyi.
- **IPA:** DRESS `/ɛ/`; US 13, UK 13, `/e/` 0. headquarters için US `/ˈhɛdkwɔːrtɚz/` (ilk hece vurgulu) ve UK `/ˌhɛdˈkwɔːtəz/` doğru; Cambridge ve Merriam-Webster aynı vurguyu veriyor. self-employed, competitive (US `/kəmˈpɛtətɪv/`) ve temporary (US `/ˈtɛmpərɛri/`) de doğru.
- **Çeldirici:** `s23: 60 quizzes, 124 distinct distractors; top: vacancy×4, agenda×4, salary×4, deadline×4, workload×3, reputation×3`. Sınır 4 ve aşılmıyor.

## Yazarın "emin olmadığım" maddeleri

| # | Madde | Karar |
|---|---|---|
| 1 | cooperate `gloss_short` "iş birliği etmek" | Kaldı. Ana anlamın ("iş birliği yapmak", 17 karakter) yardımcı fiil değişmiş kısaltması; "iş birliği etmek" Türkçede kullanılan bir biçim. "işbirliği yapmak" (16) TDK yazımına aykırı, "birlikte çalışmak" (17) sığmıyor. Anadili Türkçe birinin bakmasına bırakıldı. |
| 2 | retirement hatası "became retired" | Kaldı. "Emekli olmak" → "become/be retired" aktarımı gerçek (olmak = become; "I became married" gibi). "was retired" İngilizcede edilgen (emekliye ayrılmak) olarak doğru olduğundan hata cümlesi olarak seçilmemeli; mevcut biçim doğru seçim. |
| 3 | approve hatası "approve of" | Kaldı. `def.long` ve `note` "approve of" anlamını zaten anlatıyor; hata Türkçeden gerçek bir aktarım (onaylamak + doğrudan nesne). |
| 4 | agenda sahte dost | Kaldı. Bazı ABD okullarında öğrenci ajandasına "agenda" denebiliyor ama yaygın İngilizcede "agenda" gündemdir; Türkçe ve Fransızca konuşanların bilinen sahte dostu. |
| 5 | qualify `gloss` ve 2. örnek | `gloss` "diploma almak" kaldı (kilit ekranında kısa ve anlaşılır); `alt`'a "meslek sahibi olmak" eklendi, "hak kazanmak" (spor anlamı) öne alındı. 2. örnek çevirisi "Mimarlık diploması almak beş yıl sürüyor." oldu. |
| 6 | be snowed under | Ana anlam "işe boğulmak" kaldı; örneklerde çoğul daha doğal: "işlere boğuldum", "siparişlere boğulduk". Lemma "be snowed under" kaldı. Seviye C1'e yakın olabilir (aşağıda). |
| 7 | get the ball rolling `alt` ve "wheel" | "startı vermek" günlük Türkçede yaygın, kaldı. "wheel" kalıp olarak yanlış ("get the wheels turning" ayrı ve çoğul), akla yatkın bir çeldirici; kaldı. |
| 8 | Etimolojiler | Üçü de doğru; `confidence: high` kaldı. |
| 9 | Karışan kelimeler | target ↔ objective silindi (düz eş anlamlı). retirement → pension (Türkçede "emeklilik/emekli maaşı"), reputation → fame ("ün"), launch → lunch (yazılış ve ses) gerçek tuzak; kaldı. Destedeki eşlerin yalnızca s23'e yazılması s22 uygulamasıyla aynı. |
| 10 | IPA | Hepsi doğru, değişiklik yok. |

## Seviye notu (silinmedi, yalnızca işaret)

- **B1 olabilir:** contract, temporary, permanent, flexible, achievement, qualification, client. Bunlar EVP/Oxford listelerinde çoğunlukla B1 olarak geçiyor. B2 destede tekrar olarak işe yarıyor, `level` değiştirilmedi.
- **C1 olabilir:** be snowed under (Cambridge'de C2 deyim), get the ball rolling (C1). İş hayatında çok sık duyuldukları için B2 akışında tutuldu.
- Geri kalan 51 kart B2 için uygun.

## Değişiklik tablosu

### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| workload | quiz.cloze | "I can't take any new projects; …" → "I can't take on any new projects; …" | "take any new projects" doğal değil; doğru kalıp "take on". |
| workplace | def.long | "behaviour" → "behavior" | ABD yazımı. |
| trainee | collocations | "trainee programme" → "trainee program" | ABD yazımı. |
| trainee | quiz.distractors | neighbour → neighbor | ABD yazımı. |
| trainee | l1.tr.alt | ["eğitimdeki çalışan", "yönetici adayı"] → ["kursiyer"] | "eğitimdeki çalışan" açıklama; "yönetici adayı" yalnızca management trainee (notta zaten var). |
| target | confusables | ["objective"] → (yok) | Düz eş anlamlı; kurala göre karışan kelime değil. |
| objective | confusables | ["target"] → (yok) | Aynı neden (iki yönlü silindi). |
| objective | l1.tr.alt | ["erek"] → [] | "erek" günlük dilde neredeyse hiç kullanılmıyor; öğrenciyi yanıltır. |

Değişmeyenler: applicant, candidate, qualification, internship, contract, agenda, achievement. "too many works" ve "made an internship" gerçek hatalar. agenda sahte dostu ve "in my agenda" hatası tutuldu.

### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| teamwork | examples[2].tr | "…galibiyetin tamamen takım çalışması sayesinde geldiğini söyledi." → "…galibiyetin tamamen takım çalışmasının eseri olduğunu söyledi." | "sayesinde geldiğini" devrik ve doğal değil. |

Değişmeyenler: leadership, reputation, retirement, supervisor, client, proposal, headquarters, vacancy, reference, employment, strategy. Bunların quiz'lerinin hepsinde tek doğru cevap var. "holiday" çeldiricisi (reference) ABD'de de geçerli bir kelime olduğu için kaldı.

### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| appoint | examples[0].en | "They appointed a new head teacher." → "They appointed a new principal." | ABD kullanımı ("okul müdürü" çevirisi aynı kaldı). |
| appoint | quiz.cloze | "Ms Kaya" → "Ms. Kaya" | ABD yazımı. |
| handle | l1.tr.note | "'I can handle it' (ben hallederim)" → "'I'll handle it' (ben hallederim)" | "I can handle it" "başa çıkabilirim" demektir; "ben hallederim" karşılığı 1. örnekteki "I'll handle it". |
| submit | quiz.distractors | approve → attend | "You must approve your application form" dilbilgisi olarak kurulabiliyordu; "attend a form" olmuyor. |
| approve | examples[0].en | "holiday request" → "vacation request" | ABD kullanımı. |
| approve | quiz.cloze | "…buy the flat." → "…buy the apartment." | ABD kullanımı. |
| qualify | examples[1].tr | "Mimar unvanını almak beş yıl sürüyor." → "Mimarlık diploması almak beş yıl sürüyor." | Yazarın da belirttiği zorlama; "diploma almak" karşılığı da görünür oldu. |
| qualify | l1.tr.alt | ["unvan almak", "hak kazanmak"] → ["hak kazanmak", "unvan almak", "meslek sahibi olmak"] | Dar kalan `gloss`'u genişletmek için. |
| motivate | l1.tr.alt | "cesaretlendirmek" → "heveslendirmek" | "cesaretlendirmek" encourage'ın karşılığı. |

Değişmeyenler: negotiate, recruit, supervise, cooperate, launch, consult. "consult to a lawyer" gerçek bir hata (danışmak + -a).

### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| represent | l1.tr.alt | ["adına konuşmak", "vekâlet etmek"] → ["adına konuşmak"] | "vekâlet etmek" birinin yerine bakmak (fill in for) anlamına kayıyor. |
| represent | quiz.distractors | consult → resign | "Three managers will consult our company at the fair" kurulabiliyordu. |
| specialize | examples[1].tr | "Dükkân ikinci el kitaplarda uzmanlaşmış." → "Dükkânın uzmanlık alanı ikinci el kitaplar." | Dükkân için "uzmanlaşmış" doğal değil. |
| volunteer | l1.tr.alt | ["gönüllü çalışmak", "üstlenmek"] → ["gönüllü çalışmak"] | "üstlenmek" take on kartının ana anlamı; gönüllülüğü taşımıyor. |
| contribute | examples[2].tr | "…100 lira katkı yapıyor." → "…100 lira katkı payı ödüyor." | Para için doğal kalıp "katkı payı ödemek". |
| efficient | quiz.distractors | powerful → dangerous | "more powerful: … works faster" kısmen savunulabiliyordu. |

Değişmeyenler: estimate, promote, qualified, skilled, flexible, competitive, permanent. "I promoted last month" gerçek bir hata.

### part_05
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| capable | examples[0].tr | "Kendisi çok yetkin bir yönetici." → "Çok yetkin bir yöneticidir." | Cümle başındaki "Kendisi" çeviri kokuyor. |
| capable | examples[1].tr | "…yapabilecek yetenekte olduğundan…" → "…yapabilecek yetkinlikte olduğundan…" | "yetenekte olmak" doğal değil; `gloss` "yetkin" ile uyum. |
| capable | l1.tr.mistakes[0].why | "Türkçedeki '-ebilecek durumda' anlamı ve 'able to' kalıbı yüzünden…" → "'Yapabilmek' akla önce 'able to' kalıbını getirdiği için 'capable' de 'to' ile kuruluyor…" | Hatanın nedeni daha açık anlatılıyor. |
| fill in for | def.long | "ill or on holiday" → "sick or on vacation" | ABD kullanımı. |
| fill in for | examples[1].en | "on holiday" → "on vacation" | ABD kullanımı. |
| fill in for | quiz.cloze | "Our teacher is ill today, so Mr Yılmaz…" → "Our teacher is sick today, so Mr. Yılmaz…" | ABD kullanımı ve yazımı. |
| be snowed under | examples[0].tr | "bu hafta işe boğuldum" → "bu hafta işlere boğuldum" | Çoğul daha doğal. |
| be snowed under | examples[1].tr | "siparişe boğulduk" → "siparişlere boğulduk" | Çoğul daha doğal. |

Değişmeyenler: temporary, self-employed, demanding, rewarding, productive, take on, carry out, follow up, get the ball rolling.

## Çeldirici çeşitlendirme

`distractor_stats.py`: `s23: 60 quizzes, 124 distinct distractors; top: vacancy×4, agenda×4, salary×4, deadline×4, workload×3, reputation×3`. Sınır (4) aşılmıyor. Denetimde değişen üç şıktan sonra da sınırın içinde. Yeni şıkların (attend, resign, dangerous) her biri akışta en çok iki kez geçiyor.

## Anadili Türkçe birinin bakması gerekenler

1. cooperate `gloss_short` "iş birliği etmek": kilit ekranında doğal mı, yoksa "iş birliği yapmak" yerine kısaltma gibi mi duruyor?
2. Hata maddelerinin sıklığı: "My father became retired last year", "We did a great teamwork", "I made an internship at a bank", "She is capable to run the team". Sonuncusu genel bir öğrenci hatası; Türkçeden gelme payı sınırlı.
3. qualify `gloss` "diploma almak": "qualify as a doctor" için yeterli mi? Başka bir aday "meslek sahibi olmak" (19 karakter, `gloss_short` gerekir).
4. be snowed under "işe boğulmak" ve örneklerdeki "işlere boğuldum": doğal mı, yoksa "işim başımdan aşkın" mı öne alınmalı?
5. trainee `alt` "kursiyer": şirketteki stajyer için uygun mu, yoksa `alt` boş mu kalmalı?
6. follow up 1. örnek "Yarın bir e-postayla konuyu takip ederim": iş Türkçesinde doğal; "Yarın e-postayla dönüş yaparım" daha mı yaygın?
7. Seviye: B1'e yakın 7 kart ve C1'e yakın 2 deyim (yukarıdaki seviye notu).

## Son doğrulama (2026-10-26)

- Çeldirici: en sık şık 4 soruda (vacancy, agenda, salary, deadline); sınır max(4, %5 × 60 = 3) = 4 aşılmıyor, değişiklik gerekmedi. Her soruda tek doğru cevap, üç farklı şık, en fazla 16 karakter.
- IPA (`ipa_dress_stats.py`): UK `/ɛ/` 13, US `/ɛ/` 13, `/e/` 0.
- Başlık çakışması: s23'teki 60 lemmanın hiçbiri `content/` altındaki başka bir akışta ya da destede yok.

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Örneklem denetimi (2026-10-26)

Üç bağımsız denetçi B2 destesinden 80 kartlık bir örneklemi okudu (Türkçe, İngilizce ve quiz gözüyle). Bulgular tek tek doğrulandı; doğru olanlar düzeltildi. Bulgulardan çıkan beş sistematik sorun (notlarda 'siz' hitabı, İngilizce cümlede özne olan 'Can' adı, ikinci anlama kayan örnek ve eşdizimler, başka sözcük türünden çeldiriciler, B1 olabilecek seviyeler) s23–s32'nin 600 kartında tarandı.

- Bu akışta değişen kart: **6**, alan: **7**. Değişen kartlara `critic_edited` eklendi.
- Çeldirici: `s23: 60 quizzes, 124 distinct distractors; top: vacancy×4, agenda×4, salary×4, deadline×4, workload×3, reputation×3` (sınır max(4, %5) = 4 aşılmıyor).
- Seviye: değiştirilmedi. B1 olabilecek kartlar bu dosyanın seviye bölümünde zaten işaretli; karar kullanıcıda.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| workload.n.1 | examples[1] | "When Can joined the team, my workload got lighter. / Can ekibe katılınca iş yüküm hafifledi." → "When Onur joined the team, my workload got lighter. / Onur ekibe katılınca iş yüküm hafifledi." | 'Can' adı İngilizcede modal 'can' gibi okunuyor |
| vacancy.n.1 | examples[2] | "The hotel sign said 'No vacancies', so we drove on. / Otelin tabelasında 'Boş oda yok' yazıyordu, biz de yolumuza devam ettik." → "The company is having trouble filling the vacancy. / Şirket açık pozisyonu doldurmakta zorlanıyor." | 'No vacancies' otel odası anlamı |
| qualify.v.1 | collocations | "qualify as a doctor, fully qualify, qualify for the final" → "qualify as a doctor, fully qualify, qualify as a teacher" | 'qualify for the final' spor anlamı |
| qualify.v.1 | l1.tr.alt | "hak kazanmak, unvan almak, meslek sahibi olmak" → "unvan almak, meslek sahibi olmak" | 'hak kazanmak' spor anlamının karşılığı |
| motivate.v.1 | collocations | "motivate staff, motivate sb to do, highly motivated" → "motivate staff, motivate sb to do, motivate students" | 'highly motivated' sıfatın eşdizimi |
| specialize.v.1 | examples[2] | "After medical school, Can wants to specialize in children's health. / Can tıp fakültesinden sonra çocuk sağlığı alanında uzmanlaşmak istiyor." → "After medical school, Berk wants to specialize in children's health. / Berk tıp fakültesinden sonra çocuk sağlığı alanında uzmanlaşmak istiyor." | 'Can' adı İngilizcede modal 'can' gibi okunuyor |
| qualified.adj.1 | examples[2].tr | "Bu konuda tavsiye verecek kadar yetkin hissetmiyorum." → "Bu konuda tavsiye verecek kadar kendimi yetkin hissetmiyorum." | 'kendimi' eksikti |

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Seviye kararı (2026-10-26)

İki bağımsız yargıç B1 olabilecek adayları ayrı ayrı değerlendirdi. İkisinin de B1 ya da altı dediği **5 kart** `level: "B1"` oldu; `level_source` yine `editorial_estimate`. Kart ID'leri seviye içermediği için değişmedi. Yargıçların ayrıntılı gerekçe metinleri bu düzenlemeye gelmedi; satırlardaki gerekçe, yargıç kararının editör özetidir.

- `en.qualification.n.1` (qualification): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.achievement.n.1` (achievement): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.client.n.1` (client): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.permanent.adj.1` (permanent): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.temporary.adj.1` (temporary): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.

B2'de kalan adaylar (yargıçlar ayrıştı ya da B2 dedi): `en.contract.n.1`, `en.flexible.adj.1`.

## İkinci örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) her akıştan 7 kartlık bir örneklemi (toplam 70 kart) ikinci kez okudu. 35 bulgunun hepsi kartla karşılaştırıldı ve hepsi gerçek çıktı; düzeltildi. Bulgulardan çıkan yeni sistematik sorunlar s23–s32'nin 600 kartında tarandı: `def.long`'un ikinci bir anlama kayması (ve aynı anlamın örnek, eşdizim, `alt` ya da quiz'e girmesi), başka sözcük türünden ya da yalnızca yazımı benzeyen çeldiriciler, ABD IPA'sında ɝ/ɚ yazımı, boş `confusables` dizisi.

- Bu akışta değişen kart: **39**, alan: **74**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.efficient.adj.1`: Türkçe, not (orta): gerçek. 'harcamadan' hiç harcamamak gibi okunuyordu; 'boşa harcamadan' yapıldı.
- `en.leadership.n.1`: Türkçe, alt (düşük): gerçek. 'yöneticilik' çıktı, ['önderlik'] kaldı.
- `en.leadership.n.1`: İngilizce, def.long (düşük): gerçek. 'the people who lead a group' cümlesi silindi (not bu anlamı anlatıyor).
- `en.reference.n.1`: İngilizce, def.long ve 2. örnek (orta): gerçek. Kişi anlamı ve 'phone call' silindi; 2. örnek 'She asked her old teacher for a reference.'; kişi anlamı notta.
- `en.represent.v.1`: Quiz (düşük): gerçek. Şıklar employ, dismiss, recruit (geçişli, anlamca yanlış). Önerilen 'interview' ve 'fire' biri savunulabilir, biri kaba olduğu için alınmadı.
- Genel: İngilizce, ABD IPA'sı (düşük, genel bulgu): gerçek. Bu akışta 11 kartta ɝ/ɚ vardı; s1–s22'nin yazımı olan ɜːr/ər'e çevrildi.
- Genel: İngilizce, boş `confusables` (düşük, genel bulgu): gerçek. Bu akışta 34 kartta boş dizi vardı; yazar kuralına göre alan silindi.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| agenda.n.1 | def.long | silinen cümle: "It also means the most important issues for a government or a group." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| agenda.n.1 | examples[2] | "Climate change is high on the government's agenda. / İklim değişikliği hükümetin gündeminde üst sıralarda." → "Is there anything else on the agenda? / Gündemde başka bir şey var mı?" | 'high on the government's agenda' siyasi gündem anlamı (tarama) |
| leadership.n.1 | l1.tr.alt | "[önderlik, yöneticilik]" → "[önderlik]" | 'yöneticilik' liderlik becerisi değil, yöneticilik işi (bulgu) |
| leadership.n.1 | def.long | silinen cümle: "It can also mean the people who lead a group." | def.long ikinci bir anlama kayıyordu; o cümle silindi (bulgu) |
| vacancy.n.1 | def.long | silinen cümle: "It can also mean a free room in a hotel." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| reference.n.1 | def.long | "A letter or a phone call in which a former employer or teacher tells a new company about your skills and character. The person who writes i…" → "A letter in which a former employer or teacher tells a new company about your skills and character." | Kişi anlamı ve 'phone call' çıkarıldı (bulgu) |
| reference.n.1 | examples[1] | "Please give the names of two references. / Lütfen referans olarak iki kişinin adını verin." → "She asked her old teacher for a reference. / Eski öğretmeninden bir referans mektubu istedi." | 'names of two references' kişi anlamı (bulgu) |
| reference.n.1 | l1.tr.note | "Türkçedeki gibi hem mektup hem de seni öneren kişi için kullanılır. ABD'de akademik tavsiye mektubuna daha çok 'letter of recommendation' d…" → "Türkçedeki gibi seni öneren kişi için de kullanılır: 'Please give the names of two references.' ABD'de akademik tavsiye mektubuna daha çok …" | Kişi anlamı yalnızca notta (bulgu) |
| launch.v.1 | def.long | silinen cümle: "It also means to send a rocket into the sky." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| launch.v.1 | l1.tr.alt | "[lansmanını yapmak, fırlatmak]" → "[lansmanını yapmak]" | 'fırlatmak' roket anlamı (notta var) (tarama) |
| qualify.v.1 | def.long | silinen cümle: "It also means to win a place in the next stage of a competition." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| consult.v.1 | def.long | silinen cümle: "It can also mean to look at a book or a map to find information." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| consult.v.1 | l1.tr.alt | "[fikir almak, başvurmak]" → "[fikir almak]" | 'başvurmak' kitaba/sözlüğe bakma anlamı (tarama) |
| represent.v.1 | quiz.distractors | "[resign, specialize, qualify]" → "[employ, dismiss, recruit]" | Üç şık da nesne almadığı için dilbilgisinden eleniyordu (bulgu) |
| contribute.v.1 | def.long | silinen cümle: "It can also mean to be one of the causes of something." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| efficient.adj.1 | l1.tr.note | "'Efficient' zaman ve kaynak harcamadan iş görmektir (verimli). 'Effective' ise istenen sonucu vermektir (etkili). Türkçedeki 'efektif' ikin…" → "'Efficient' zamanı ve kaynakları boşa harcamadan iş görmektir (verimli). 'Effective' ise istenen sonucu vermektir (etkili). Türkçedeki 'efe…" | 'harcamadan' hiç harcamamak gibi okunuyordu; anlam boşa harcamamak (bulgu) |
| competitive.adj.1 | sense_note | "wanting to win; good compared to others" → "always wanting to win" | Kart üç anlam taşıyordu (kişi, fiyat/maaş, pazar) (tarama) |
| competitive.adj.1 | def.short | "wanting very much to win, or as good as or cheaper than others" → "wanting very much to win or to be better than other people" | Tek anlam (quiz kişi anlamını sınıyor) (tarama) |
| competitive.adj.1 | def.long | "Always wanting to win or to be better than others. It also describes prices, salaries or products that are as good as or better than those …" → "Always wanting to win or to be better than other people, in sport, games, school or work. Some people are like this even in small things." | Tek anlam (tarama) |
| competitive.adj.1 | examples[0] | "We offer a competitive salary. / Rekabetçi bir maaş sunuyoruz." → "You need to be competitive to succeed in sport. / Sporda başarılı olmak için hırslı olmak gerekir." | 'competitive salary' fiyat/maaş anlamı (notta var) (tarama) |
| competitive.adj.1 | examples[2] | "The phone market is extremely competitive. / Telefon pazarı son derece rekabetçi." → "My sister and I were very competitive as children. / Ablamla ben çocukken çok rekabetçiydik." | 'The phone market is extremely competitive' rekabetin yoğun olduğu pazar anlamı (tarama) |
| competitive.adj.1 | collocations | "[competitive salary, competitive prices, highly competitive]" → "[very competitive, highly competitive, competitive spirit]" | 'competitive salary/prices' ikinci anlam (tarama) |
| competitive.adj.1 | l1.tr.alt | "[hırslı, uygun fiyatlı]" → "[hırslı]" | 'uygun fiyatlı' ikinci anlam (tarama) |
| competitive.adj.1 | l1.tr.note | "İş ilanındaki 'competitive salary' piyasaya göre iyi bir maaş demektir. Kişi için 'hırslı, hep kazanmak isteyen' anlamına gelir." → "Kişi için 'hırslı, hep kazanmak isteyen' anlamına gelir. İş ilanındaki 'competitive salary' ise piyasaya göre iyi bir maaş, 'a competitive …" | Diğer anlamlar nota taşındı (tarama) |
| take_on.phv.1 | def.long | silinen cümle: "It can also mean to give someone a job, as in 'take on new staff'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| take_on.phv.1 | examples[2] | "The shop is taking on extra staff for the holidays. / Mağaza tatil dönemi için ek personel alıyor." → "Don't take on too much, or you'll burn out. / Çok fazla iş üstlenme, yoksa tükenirsin." | 'taking on extra staff' işe alma anlamı (tarama) |
| take_on.phv.1 | collocations | "[take on a project, take on too much, take on staff]" → "[take on a project, take on too much, take on a role]" | 'take on staff' işe alma anlamı (tarama) |
| take_on.phv.1 | l1.tr.alt | "[sorumluluk almak, işe almak]" → "[sorumluluk almak]" | 'işe almak' ikinci anlam (tarama) |
| take_on.phv.1 | l1.tr.note | "'Take on too much' (çok fazla iş üstlenmek) sık kullanılır. Ayrılabilir: 'take on a project' ya da 'take it on'." → "'Take on too much' (çok fazla iş üstlenmek) sık kullanılır. Ayrılabilir: 'take on a project' ya da 'take it on'. 'Take on staff' ise eleman…" | İkinci anlam nota taşındı (tarama) |

ABD IPA'sı ɜːr/ər yazımına çevrildi (11 kart): workload.n.1 /ˈwɝːkloʊd/ → /ˈwɜːrkloʊd/; workplace.n.1 /ˈwɝːkpleɪs/ → /ˈwɜːrkpleɪs/; internship.n.1 /ˈɪntɝːnʃɪp/ → /ˈɪntɜːrnʃɪp/; teamwork.n.1 /ˈtiːmwɝːk/ → /ˈtiːmwɜːrk/; leadership.n.1 /ˈliːdɚʃɪp/ → /ˈliːdərʃɪp/; retirement.n.1 /rɪˈtaɪɚmənt/ → /rɪˈtaɪərmənt/; supervisor.n.1 /ˈsuːpɚvaɪzɚ/ → /ˈsuːpərvaɪzər/; headquarters.n.1 /ˈhɛdkwɔːrtɚz/ → /ˈhɛdkwɔːrtərz/; supervise.v.1 /ˈsuːpɚvaɪz/ → /ˈsuːpərvaɪz/; permanent.adj.1 /ˈpɝːmənənt/ → /ˈpɜːrmənənt/; be_snowed_under.idm.1 /bi ˌsnoʊd ˈʌndɚ/ → /bi ˌsnoʊd ˈʌndər/.

Boş `confusables` dizisi silindi (34 kart): qualification.n.1, workload.n.1, workplace.n.1, internship.n.1, agenda.n.1, teamwork.n.1, leadership.n.1, supervisor.n.1, headquarters.n.1, reference.n.1, employment.n.1, strategy.n.1, appoint.v.1, supervise.v.1, cooperate.v.1, approve.v.1, qualify.v.1, motivate.v.1, consult.v.1, represent.v.1, specialize.v.1, volunteer.v.1, promote.v.1, contribute.v.1, flexible.adj.1, competitive.adj.1, permanent.adj.1, temporary.adj.1, self_employed.adj.1, demanding.adj.1, rewarding.adj.1, follow_up.phv.1, be_snowed_under.idm.1, get_the_ball_rolling.idm.1.

- Çeldirici: `s23: 60 quizzes, 124 distinct distractors; top: vacancy×4, agenda×4, salary×4, deadline×4, recruit×4, workload×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Üçüncü örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) s23–s32'den 80 kartlık yeni bir örneklemi okudu. 35 bulgu kartla karşılaştırıldı: 33'ü gerçek çıktı ve düzeltildi, 2'si (release, carbon footprint çevirileri) gerekçesiyle reddedildi. Önceki iki turun listesinde olmayan sistematik sorunlar s23–s32'nin 600 kartında tarandı: `gloss_short`'ta kesilmiş söz; `alt`'ın kartın kendi notuyla ya da başka bir kartın ayrımıyla çelişmesi (ve önceki taramada kalan ikinci anlam karşılıkları); `grammar.pattern`'da başka anlamın kalıbı; `def.long`'da önceki anahtar sözcük taramasının kaçırdığı ikinci anlam cümleleri (ve aynı anlamın örnek, eşdizim, quiz'e taşması); akraba kartlar arasında neredeyse aynı örnek ya da boşluklu cümle; boşluğa anlamca hiç uymayan, soruyu ele veren çeldiriciler; şapkası düşmüş hâl / dâhil. Seviyeler değişmedi.

- Bu akışta değişen kart: **18**, alan: **40**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.follow_up.phv.1`: Türkçe, 1. örnek (orta): gerçek. 'Yarın e-postayla tekrar dönüş yaparım.'
- `en.follow_up.phv.1`: Türkçe, not (düşük): gerçek. 'a follow-up email' artık 'konuyla ilgili sonradan gönderilen e-posta, örneğin hatırlatma ya da teşekkür'.
- `en.promote.v.1`: Türkçe, 3. örnek (düşük): gerçek. 'Şirket bu yıl üç kadını terfi ettirip yönetim kuruluna aldı.' (kartın karşılığı çeviride kalsın diye 'terfi ettirip').
- `en.supervisor.n.1`: İngilizce, iki anlam (orta): gerçek. Tez danışmanı cümlesi `def.long`'dan, 3. örnekten ('The shift supervisor told us to take a short break.'), eşdizimlerden ('report to your supervisor') ve alt'tan çıktı. Not, destenin geneli gibi bu anlamı tek cümleyle anmaya devam ediyor (öteki turlarda da ikinci anlam nota taşındı).
- `en.applicant.n.1`: İngilizce, alt (düşük): gerçek. alt ['başvuran'].

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| applicant.n.1 | l1.tr.alt | "[başvuran, aday]" → "[başvuran]" | 'aday' notun ayırdığı 'candidate' (bulgu) |
| candidate.n.1 | def.long | silinen cümle: "The word is also used for people in an election or an exam." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| objective.n.1 | quiz.distractors | "[employment, headline, audience]" → "[budget, client, office]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| achievement.n.1 | quiz.distractors | "[reputation, retirement, vacancy]" → "[failure, disappointment, loss]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| supervisor.n.1 | l1.tr.alt | "[süpervizör, tez danışmanı]" → "[süpervizör]" | 'tez danışmanı' akademik anlam (notta var) (bulgu) |
| supervisor.n.1 | def.long | silinen cümle: "At university, it is the teacher who guides your thesis." | def.long ikinci bir anlama kayıyordu; o cümle silindi (bulgu) |
| supervisor.n.1 | examples[2] | "Zehra's thesis supervisor gave her very useful feedback. / Zehra'nın tez danışmanı ona çok faydalı geri bildirim verdi." → "The shift supervisor told us to take a short break. / Vardiya amiri bize kısa bir mola vermemizi söyledi." | Tez danışmanı akademik anlam (bulgu) |
| supervisor.n.1 | collocations | "[my supervisor, shift supervisor, thesis supervisor]" → "[my supervisor, shift supervisor, report to your supervisor]" | 'thesis supervisor' akademik anlam (bulgu) |
| client.n.1 | quiz.distractors | "[deadline, budget, timetable]" → "[customer, patient, passenger]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| proposal.n.1 | quiz.distractors | "[achievement, teamwork, supervisor]" → "[holiday, promotion, meeting]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| employment.n.1 | quiz.distractors | "[retirement, leadership, headquarters]" → "[unemployment, retirement, pensions]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| recruit.v.1 | l1.tr.alt | "[personel almak, üye toplamak]" → "[personel almak]" | 'üye toplamak' kulüp/örgüt anlamı; önceki taramada kalmış (tarama) |
| cooperate.v.1 | l1.tr.alt | "[birlikte çalışmak, yardımcı olmak]" → "[birlikte çalışmak]" | 'yardımcı olmak' polise yardım anlamı (tarama) |
| cooperate.v.1 | def.long | silinen cümle: "It also means to do what someone asks, for example to help the police." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| cooperate.v.1 | def.short | "work together with other people to do something, or help when asked" → "work together with other people to do something" | 'or help when asked' ikinci anlam (tarama) |
| cooperate.v.1 | examples[1] | "The witness agreed to cooperate with the police. / Tanık polisle iş birliği yapmayı kabul etti." → "Our company cooperates closely with local universities. / Şirketimiz yerel üniversitelerle yakın iş birliği yapıyor." | 'cooperate with the police' istenileni yapma anlamı (tarama) |
| cooperate.v.1 | collocations | "[cooperate with sb, cooperate closely, refuse to cooperate]" → "[cooperate with sb, cooperate closely, cooperate on a project]" | 'refuse to cooperate' ikinci anlam (tarama) |
| cooperate.v.1 | quiz.distractors | "[retire, borrow, arrive]" → "[argue, complain, apologize]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| approve.v.1 | grammar.pattern | "approve sth; approve of sth" → "approve sth; be approved (by sb)" | 'approve of sth' başka anlam (notta var) (tarama) |
| approve.v.1 | def.long | silinen cümle: "With 'of', it means to think that something is good or right." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| approve.v.1 | examples[1] | "The city council approved the plan for a new park. / Belediye meclisi yeni bir park planını onayladı." → "The government approved the new budget. / Hükümet yeni bütçeyi onayladı." | başka bir kartta neredeyse aynı cümle vardı (council: 'The city council wants to build a new park') (tarama) |
| qualify.v.1 | grammar.pattern | "qualify as sth; qualify for sth" → "qualify as sth" | 'qualify for sth' spor anlamı (notta var) (tarama) |
| volunteer.v.1 | def.long | silinen cümle: "It also means to work without pay to help people." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| volunteer.v.1 | examples[2] | "Every weekend, Jack volunteers at an animal shelter. / Jack her hafta sonu bir hayvan barınağında gönüllü çalışıyor." → "My brother volunteered to drive us to the airport. / Kardeşim bizi havalimanına götürmeye gönüllü oldu." | Barınakta gönüllü çalışmak ikinci anlam (tarama) |
| volunteer.v.1 | collocations | "[volunteer to help, volunteer for a job, volunteer at a charity]" → "[volunteer to help, volunteer for a job, volunteer to do sth]" | 'volunteer at a charity' ikinci anlam (tarama) |
| volunteer.v.1 | l1.tr.alt | "[gönüllü çalışmak]" → "[gönüllü çıkmak]" | 'gönüllü çalışmak' ikinci anlam (tarama) |
| promote.v.1 | examples.2.tr | "Şirket bu yıl üç kadını yönetim kuruluna yükseltti." → "Şirket bu yıl üç kadını terfi ettirip yönetim kuruluna aldı." | 'yönetim kuruluna yükseltti' doğal değil (bulgu) |
| qualified.adj.1 | l1.tr.alt | "[diplomalı, yetkin]" → "[diplomalı]" | 'yetkin' beceri/deneyim anlamı; not 'qualified' belgeyi vurgular diyor (tarama) |
| qualified.adj.1 | def.long | silinen cümle: "It also means having the right skills or experience." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| qualified.adj.1 | examples[2] | "I don't feel qualified to give advice on this. / Bu konuda tavsiye verecek kadar kendimi yetkin hissetmiyorum." → "Only qualified teachers can work in state schools. / Devlet okullarında yalnızca diplomalı öğretmenler çalışabilir." | 'feel qualified to give advice' bilgi/beceri anlamı (tarama) |
| skilled.adj.1 | l1.tr.alt | "[becerikli, yetenekli, kalifiye]" → "[becerikli, kalifiye]" | 'yetenekli' talented'ın karşılığı (talent/talented notları ayırıyor) (tarama) |
| skilled.adj.1 | quiz.distractors | "[temporary, competitive, permanent]" → "[careless, lazy, clumsy]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| demanding.adj.1 | l1.tr.alt | "[emek isteyen, talepkâr]" → "[emek isteyen]" | 'talepkâr' kişi anlamı (notta var); önceki taramada kalmış (tarama) |
| demanding.adj.1 | grammar.pattern | "a demanding job/boss" → "a demanding job/task" | 'demanding boss' kişi anlamı (tarama) |
| demanding.adj.1 | def.long | silinen cümle: "A person can also be like this when they expect a lot from others, like a boss or a customer." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| demanding.adj.1 | examples[1] | "My new boss is quite demanding. / Yeni patronum epey talepkâr." → "Looking after a newborn baby is very demanding. / Yeni doğmuş bir bebeğe bakmak çok yorucu." | 'demanding boss' kişi anlamı (tarama) |
| demanding.adj.1 | collocations | "[demanding job, physically demanding, demanding customer]" → "[demanding job, physically demanding, a demanding schedule]" | 'demanding customer' kişi anlamı (tarama) |
| demanding.adj.1 | quiz.distractors | "[efficient, generous, cheerful]" → "[relaxing, easy, restful]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| follow_up.phv.1 | examples.0.tr | "Yarın bir e-postayla konuyu takip ederim." → "Yarın e-postayla tekrar dönüş yaparım." | 'e-postayla konuyu takip ederim' kelime kelime aktarma (bulgu) |
| follow_up.phv.1 | l1.tr.note | "'Follow up on sth' ya da 'follow up with sb' kalıplarıyla kullanılır. İsim hâli tireyle yazılır: 'a follow-up email' (hatırlatma e-postası)." → "'Follow up on sth' ya da 'follow up with sb' kalıplarıyla kullanılır. İsim hâli tireyle yazılır: 'a follow-up email' (konuyla ilgili sonrad…" | Follow-up e-postası yalnızca hatırlatma değil (bulgu) |

- Çeldirici: `s23: 60 quizzes, 129 distinct distractors; top: agenda×4, salary×4, recruit×4, vacancy×3, deadline×3, workload×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
