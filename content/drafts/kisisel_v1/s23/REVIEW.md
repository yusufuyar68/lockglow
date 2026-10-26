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
