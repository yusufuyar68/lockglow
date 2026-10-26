# s30 QA incelemesi (B2: görüş ve tartışma, okul ve öğrenme, zihin)

Kapsam: `content/drafts/kisisel_v1/s30/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin okulda, işte ve haberlerde karşılaştığı görüş bildirme, tartışma, öğrenme ve düşünme kelimeleri. Seviye: hepsi B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** bir yazar ajanı, 5 part (s22 düzeni), `1_yazar_kurallari.md`. Yazarın doğrulayıcı satırı: `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`. Atlanan kelime yok. Var olan `question (n)` kartından ayrı olarak `en.question.v.1` yazıldı.
2. **Denetim:** bir denetçi ajanı (bu rapor), `2_denetci_kurallari.md`. 60 kartın her alanı tek tek okundu. Her quiz'de dört şık da boşluğa konup denendi. Yazarın "emin olmadığım" 5 maddesi aşağıda tek tek yanıtlandı.

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 54 kelime (`word`: 24 isim, 18 fiil, 8 sıfat, 4 zarf), 5 kalıp (`phrase`: point of view, on the other hand, as a result, in theory, bear in mind), 1 deyim (`idiom`: jump to conclusions).
- `primary_topic`: `opinions_debate` 31, `school_learning` 23, `mind_psychology` 5, `idioms_expressions` 1.
- Değişen kart: **14** (`critic_edited`), değişen alan: **24**. `meta.status` hepsinde `draft` kaldı.
- Reddedilen kart (`critic_reject`): **0**. Silinen yaygın hata: **0**; bir hatanın açıklaması yeniden yazıldı. `sensitivity`: hepsi 0. `exams`: hepsi boş.
- Sahte dost: 1 (semester ≠ sömestr). Yarım sahte dost olarak bırakıldı; ayrıntısı aşağıda.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.
- Çeldirici (`distractor_stats.py`): `s30: 60 quizzes, 122 distinct distractors; top: semester×4, doubt×4, tended×4, quote×4`. Sınır 4, aşılmıyor.
- IPA DRESS (`ipa_dress_stats.py`): UK `/ɛ/` 18, US `/ɛ/` 19, düz `e` 0.

## Genel bulgular

- **Kartların çoğu temiz.** Anlam seçimi, tanımlar, Türkçe çeviriler ve quiz'ler genel olarak sağlam. Hiçbir tanım başlık kelimeyi kullanmıyor. 60 quiz'in hepsinde tek doğru cevap var; ikinci bir okumaya izin veren şık bulunmadı. Değişikliklerin yarısı, İngiliz yazımının ya da sözcüğünün ABD biçimine çevrilmesi.
- **En sık 3 sorun:**
  1. **İngiliz yazımı ve sözcükleri.** Deste, s22'de olduğu gibi ABD İngilizcesini kullanıyor. Düzeltmeler:
     - maths → math (logic, tutor ×3)
     - flat → apartment (factor, on the other hand, bear in mind)
     - at weekends → on weekends; motorways → highways; judgement → judgment
     - Ms → Ms. (lecturer ×2)
     - "jump the queue" çeldiricisi → "cut corners"

     Bilerek bırakılanlar: revise ve revision kartları İngiliz anlamını (sınav için tekrar) öğretiyor. Bu yüzden İngiliz örnekleri ("maths exam", "I've got to do some revision") korundu.
  2. **Kilit ekranı anlamı.**
     - revise: kısa anlam "tekrar etmek" tek başına okununca "repeat" gibi anlaşılıyor. Bu da kartın uyardığı hatayı ("I'm repeating for my exam") pekiştiriyordu. Yeni kısa anlam "tekrar yapmak": öğrenciler sınav tekrarına böyle der ve kartın örnek çevirileri de bu biçimde.
     - jump to conclusions: kısa anlam, ana anlamın kısaltması değildi. Ana anlam "acele hükmetmek" (16 karakter) oldu, "acele hüküm vermek" alt'a taşındı.
  3. **Fazla kesin ya da uydurma açıklamalar.**
     - reflect notunda "hep 'reflect on'" → "çoğu zaman".
     - bear in mind: hatanın kendisi gerçek (zamirin yeri, "pick up it" türü), ama Türkçeye özgü değil. `why` alanı Türkçeden gelen bir neden uyduruyordu ("aklımda tutarım tek fiil gibidir"); açıklama dürüstçe yeniden yazıldı.
     - intelligence: alt'taki "anlayış" zekâ anlamına gelmediği için silindi.

### Yazarın "emin olmadığım" maddeleri

1. **semester / sömestr.** Resmî anlam ("yarıyıl") İngilizceyle örtüşüyor. Ama günlük dilde "sömestr(de)" neredeyse her zaman şubattaki yarıyıl tatili demek ("sömestrde kayağa gidelim"). Bu yüzden yarım bir sahte dost.
   - `false_friend` kaldı. `tr_means` "yarıyıl; günlük dilde çoğu zaman yarıyıl tatili" yapıldı, böylece iki anlam da görünüyor.
   - Hata cümlesi ("We have semester in February, so let's go skiing.") doğrudan bu Türkçe kullanımdan geliyor. Tutuldu; anadili Türkçe birinin bakması için aşağıdaki listede.
2. **Yaygın hatalar.**
   - lecture, "gave a conference" (konferans vermek): gerçek ve iyi bilinen bir Türkçe tuzak. Tutuldu.
   - academic, "academician" (akademisyen): gerçek ve çok yaygın; Türk üniversitelerinin İngilizce sayfalarında bile geçer. Tutuldu.
   - debate, "made a debate" (tartışma yapmak): Türk öğrencilerde görülen make/have karışıklığının bir örneği. Tutuldu.
   - aspect, "In this aspect" (bu açıdan): Türklerin akademik yazısında sık görülür; doğrusu "in this respect". Tutuldu, listede.
   - revise, "I'm repeating for my maths exam" (dersi tekrar etmek → repeat): "I will repeat the lesson" türü cümleler Türk öğrencilerde gerçekten görülüyor. Tutuldu, listede.
3. **Kısa anlamlar.**
   - lecturer: "hoca", ana anlamın ("üniversite hocası") baş sözcüğü; bu yüzden kısaltma sayılır. Türkiye'de üniversite hocasına zaten "hoca" denir. Kaldı, listede.
   - jump to conclusions ve revise: yukarıda anlatıldığı gibi düzeltildi.
4. **Notlar.**
   - lecturer: not doğru. Türk üniversitelerinde "lektör" çoğunlukla yabancı dil okutan, genellikle o dili anadili olarak konuşan öğretim elemanıdır.
   - concept: not doğru. "Düğün konsepti" ve "parti konsepti" İngilizcede "wedding theme" ve "party theme" olur.
5. **Karışan kelimeler.**
   - Destede kartı olmayan eşlerin hepsi gerçek bir ölçüte dayanıyor (benzer yazılış ya da Türkçede aynı karşılık: yorum, ilgili, şüphe, motivasyon/motif). Liste: principal, comment/translate, lightly, related, suspicion, motive, review. Kaldı.
   - talent → skill/ability ("yetenek") ve revise → repeat ("tekrar etmek") "Türkçede aynı karşılık" ölçütüne tam uyuyor. Kaldı.
   - Destede kartı olan eşler (lesson, describe, repeat, review, skilled, sensible, translate, comment, apparently…) yalnızca s30 kartına yazılı. Derleyici çifti iki yönlü bağlıyor; s22'de de aynı yol izlendi.
6. **complex, US IPA** `/kɑːmˈplɛks/`. Sözlükler sıfat için ABD'de vurgunun ikinci hecede olduğu biçimi veriyor (Cambridge US). `/ˈkɑːmplɛks/` da duyuluyor. Kaldı.

### Seviye

Hepsi B2 kaldı; değiştirmeyi gerektiren bariz bir yanlış yok. Ama aşağıdakiler genel kelime listelerinde çoğunlukla **B1** (birkaçı A2) olarak geçer; editör isterse B1'e indirilebilir: mainly, slightly, obviously, method, factor, summary, talent, talented, intelligence, focus, identify, reasonable, academic, on the other hand, as a result, point of view. C1 düzeyinde görünen kart yok. Zorluk olarak en üstte jump to conclusions, bear in mind, in theory ve question (fiil) var.

### Kontrol edilip değişmeyenler

- Bütün quiz'ler dört şıkla denendi. Sınırda görünen ama bırakılanlar:
  - tend: "keeps/enjoys/avoids to fall asleep" yalnızca biçim yüzünden yanlış, ama Türk öğrencinin "enjoy to" hatasını sınıyor.
  - in theory: "In fact, … but it's usually late" anlamca çelişiyor.
  - principle: "a matter of luck/fashion" bu bağlamda anlamsız.
- apply kartı yalnızca "apply to = geçerli olmak" anlamını öğretiyor ve `en.apply.v.1` kimliğini alıyor. Destede "apply for = başvurmak" kartı yok. Kartın notu "en bilinen anlamı başvurmaktır" diyor; bu yanlış değil, ama ileride yazılacak başvurmak kartı `sense_no: 2` alacak.
- Etimolojiler gerçek: debate, logic, concept, method, semester, intelligence, talent, discipline, campus. talent'ın "yetenek" anlamının İncil'deki talant meselinden geldiği doğru.
- `sensitivity`: hiçbir kart kişisel bir konuda değil; hepsi 0.

## Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| logic | def.long | "…philosophy and maths…" → "…philosophy and math…" | ABD yazımı (deste geleneği) |
| factor | def.long | "…when you choose a flat." → "…when you choose an apartment." | ABD İngilizcesi (deste geleneği) |
| tutor | grammar.pattern | "a private tutor; a maths tutor" → "a private tutor; a math tutor" | ABD yazımı |
| tutor | collocations[1] | "a maths tutor" → "a math tutor" | ABD yazımı |
| tutor | examples[0].en | "We found a maths tutor for Can." → "We found a math tutor for Can." | ABD yazımı |
| tutor | examples[0].tr | "Can için bir matematik özel öğretmeni bulduk." → "Can'a bir matematik özel öğretmeni bulduk." | Bu cümlede yönelme hâli daha doğal. |
| lecturer | examples[2].en | "Ms Demir is a popular lecturer…" → "Ms. Demir is a popular lecturer…" | ABD yazımı: Ms. (destede de böyle) |
| lecturer | quiz.cloze | "Ms Yılmaz is a ______ in economics…" → "Ms. Yılmaz is a ______ in economics…" | ABD yazımı: Ms. |
| semester | l1.tr.false_friend.tr_means | "günlük dilde yarıyıl tatili" → "yarıyıl; günlük dilde çoğu zaman yarıyıl tatili" | Resmî anlam ("yarıyıl") İngilizceyle örtüşüyor; sahte dostluk yalnızca günlük kullanımdaki "tatil" anlamında. |
| intelligence | l1.tr.alt | ["akıl", "anlayış"] → ["akıl"] | "Anlayış" zekâ değil, kavrayış ya da hoşgörü demek; yanıltıcı. |
| reflect | l1.tr.note | "Düşünmek anlamında hep 'reflect on' kalıbıyla kullanılır." → "Düşünmek anlamında çoğu zaman 'reflect on' kalıbıyla kullanılır." | "Hep" fazla kesin; "Take time to reflect." gibi edatsız kullanım da var. |
| revise | l1.tr.gloss | "tekrar etmek, revize etmek" → "tekrar yapmak, revize etmek" | "Tekrar etmek" tek başına "repeat" okunuyor ve kartın uyardığı hatayı kilit ekranında pekiştiriyordu. Öğrenciler sınav tekrarına "tekrar yapmak" der; örnek çevirileri de böyle. |
| revise | l1.tr.gloss_short | "tekrar etmek" → "tekrar yapmak" | Ana anlamın ilk virgülden önceki kısmı; neden yukarıdakiyle aynı. |
| revise | l1.tr.alt | ["konuları tekrarlamak", "gözden geçirmek", "elden geçirmek"] → ["konuları tekrarlamak", "tekrar etmek", "elden geçirmek"] | Eski ana anlamdaki "tekrar etmek" alt'a taşındı (en çok 3 öğe). |
| tend | examples[0].en | "I tend to eat too much at weekends." → "I tend to eat too much on weekends." | ABD İngilizcesi |
| apply | examples[2].en | "The new speed limit doesn't apply to motorways." → "The new speed limit doesn't apply to highways." | ABD İngilizcesi |
| reasonable | def.long | "…based on good judgement…" → "…based on good judgment…" | ABD yazımı |
| on the other hand | examples[0].en | "The flat is small. On the other hand, it's cheap." → "The apartment is small. On the other hand, it's cheap." | ABD İngilizcesi |
| bear in mind | quiz.cloze | "When you choose a flat, ______ that…" → "When you choose an apartment, ______ that…" | ABD İngilizcesi |
| bear in mind | l1.tr.mistakes[0].why | "Türkçede 'aklımda tutarım' tek fiil gibidir, bu yüzden 'it' sona eklenir. …" → "Kalıp tek parça ezberlendiği için zamir sona eklenir ('pick up it' hatası gibi). …" | Eski açıklama Türkçeden gelen bir neden uyduruyordu. Hata gerçek ama Türkçeye özgü değil. |
| jump to conclusions | l1.tr.gloss | "acele hüküm vermek" → "acele hükmetmek" | Kısa anlam ana anlamın kısaltması değildi (kisisel-13 kuralı). Ana anlam 16 karaktere indi. |
| jump to conclusions | l1.tr.gloss_short | "acele hükmetmek" → (yok) | Ana anlam artık 16 karaktere sığıyor; kısa anlama gerek kalmadı. |
| jump to conclusions | l1.tr.alt | ["hemen yargıya varmak", "erken sonuç çıkarmak"] → ["acele hüküm vermek", "hemen yargıya varmak", "erken sonuç çıkarmak"] | Eski ana anlam alt'a taşındı. |
| jump to conclusions | quiz.distractors[0] | "jump the queue" → "cut corners" | "Jump the queue" İngiliz İngilizcesi; "cut corners" aynı türden bir deyim ve bu cümlede açıkça yanlış. |

## Anadili Türkçe birinin bakması gerekenler

1. **semester / sömestr:** "Sömestr" günlük dilde gerçekten "yarıyıl tatili" diye mi anlaşılıyor (yarım sahte dost)? Hata cümlesi "We have semester in February, so let's go skiing." gerçekçi mi?
2. **Hataların sıklığı:** "In this aspect" (bu açıdan), "I'm repeating for my maths exam" (tekrar etmek), "We made a debate" (tartışma yapmak). Üçü de gerçek görünüyor, ama ne kadar sık oldukları anadili Türkçe bir öğretmenin gözüyle doğrulanmalı.
3. **Kilit ekranı anlamları:**
   - revise "tekrar yapmak": tek başına okununca sınav tekrarı olarak anlaşılıyor mu?
   - lecturer "hoca": fazla genel mi? ("üniversite hocası" 17 karakter, sığmıyor.)
   - jump to conclusions "acele hükmetmek": "acele hüküm vermek" kadar doğal mı?
   - revision "tekrar".
4. **tutor ilk örneği:** "Can'a bir matematik özel öğretmeni bulduk." doğal mı ("Can için" yerine)?
5. **Seviye:** yukarıdaki 16 B1 adayı B2 destesinde kalmalı mı?

## Çeldirici çeşitlendirme ve son kontrol (2026-10-26)

- `distractor_stats.py`: `s30: 60 quizzes, 122 distinct distractors; top: semester×4, doubt×4, tended×4, quote×4, consequence×3, talent×3`. Sınır max(4, %5 × 60 = 3) = 4; aşan çeldirici yok. Değişen kart: **0**; cloze'u değişen kart yok.
- 4 kez geçen çeldiricilerin (semester, doubt, tended, quote) geçtiği 15 soru yeniden okundu; hepsinde tek doğru cevap var.
- Teknik kontrol: her quiz'de 3 farklı çeldirici, hiçbiri cevaba eşit değil, hiçbiri 16 karakteri aşmıyor.
- IPA DRESS (`ipa_dress_stats.py`): UK `/ɛ/` 18, US `/ɛ/` 19, düz `e` 0; düzeltme gerekmedi.
- Başlık çakışması (`dump_lemmas.py` mantığı, tüm akışlar): tek ortak başlık `question`. s9'daki kart isim (`en.question.n.1`), s30'daki fiil (`en.question.v.1`); bilerek ayrı yazıldı, çakışma yok.

Son doğrulama (`python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s30`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
