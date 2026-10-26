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

## Örneklem denetimi (2026-10-26)

Üç bağımsız denetçi B2 destesinden 80 kartlık bir örneklemi okudu (Türkçe, İngilizce ve quiz gözüyle). Bulgular tek tek doğrulandı; doğru olanlar düzeltildi. Bulgulardan çıkan beş sistematik sorun (notlarda 'siz' hitabı, İngilizce cümlede özne olan 'Can' adı, ikinci anlama kayan örnek ve eşdizimler, başka sözcük türünden çeldiriciler, B1 olabilecek seviyeler) s23–s32'nin 600 kartında tarandı.

- Bu akışta değişen kart: **9**, alan: **13**. Değişen kartlara `critic_edited` eklendi.
- Çeldirici: `s30: 60 quizzes, 122 distinct distractors; top: semester×4, doubt×4, tended×4, quote×4, consequence×3, talent×3` (sınır max(4, %5) = 4 aşılmıyor).
- Seviye: değiştirilmedi. B1 olabilecek kartlar bu dosyanın seviye bölümünde zaten işaretli; karar kullanıcıda.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| conclusion.n.1 | examples[2] | "Write your conclusion in the last paragraph. / Sonuç bölümünü son paragrafa yaz." → "My conclusion is that we need more staff. / Vardığım sonuç şu: daha fazla çalışana ihtiyacımız var." | 3. örnek 'yazının son bölümü' anlamındaydı |
| conclusion.n.1 | collocations | "come to a conclusion, reach a conclusion, in conclusion" → "come to a conclusion, reach a conclusion, draw a conclusion" | 'in conclusion' yazının sonu anlamına ait (hata maddesi kaldı) |
| principle.n.1 | examples[1] | "In principle, I agree, but we need more time. / Prensip olarak katılıyorum ama daha fazla zamana ihtiyacımız var." → "My grandfather was a man of strong principles. / Dedem ilkelerine sıkı sıkıya bağlı bir adamdı." | 'In principle' ayrı anlam (genel olarak) |
| principle.n.1 | collocations | "in principle, on principle, a basic principle" → "stick to your principles, on principle, a basic principle" | 'in principle' ayrı anlam |
| tutor.n.1 | examples[0] | "We found a math tutor for Can. / Can'a bir matematik özel öğretmeni bulduk." → "We found a math tutor for Efe. / Efe'ye bir matematik özel öğretmeni bulduk." | 'Can' adı İngilizcede modal 'can' gibi okunuyor |
| intelligence.n.1 | collocations | "artificial intelligence, emotional intelligence, an intelligence test" → "high intelligence, emotional intelligence, an intelligence test" | 'artificial intelligence' ayrı kavram (s27'de ayrı kart) |
| talent.n.1 | l1.tr.alt | "kabiliyet, istidat" → "kabiliyet" | 'istidat' eskimiş, B2 öğrencisi tanımaz |
| conclude.v.1 | collocations | "conclude that, conclude from, conclude a meeting" → "conclude that, conclude from, safely conclude" | 'conclude a meeting' bitirmek anlamı |
| conclude.v.1 | l1.tr.alt | "sonuç çıkarmak, bitirmek" → "sonuç çıkarmak" | 'bitirmek' ayrı anlamın karşılığı |
| underline.v.1 | examples[2] | "The accident underlined the need for safer roads. / Kaza, daha güvenli yollara duyulan ihtiyacın altını çizdi." → "The teacher underlined my spelling mistakes in red. / Öğretmen yazım hatalarımın altını kırmızıyla çizdi." | 'underline the need' mecazi anlam |
| underline.v.1 | collocations | "underline the key words, underline twice, underline the need" → "underline the key words, underline twice, underline in red" | 'underline the need' mecazi anlam |
| convincing.adj.1 | collocations | "a convincing argument, a convincing win, not very convincing" → "a convincing argument, a convincing explanation, not very convincing" | 'a convincing win' açık farkla kazanmak anlamı |
| bear_in_mind.phr.1 | l1.tr.mistakes.0.why | "Kalıp tek parça ezberlendiği için zamir sona eklenir ('pick up it' hatası gibi). 'It, them' gibi zamirler 'bear' ile 'in mind' arasına girer." → "Türkçede 'aklında tutmak' bölünmez, nesne kalıptan önce gelir ('bunu aklımda tutarım'). Bu yüzden zamir kalıbın sonuna konuyor. Oysa 'it, them' gibi zamirler 'bear' ile 'in mind' arasına girer." | 'why' Türkçeden gelen nedeni anlatmıyordu |

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Seviye kararı (2026-10-26)

İki bağımsız yargıç B1 olabilecek adayları ayrı ayrı değerlendirdi. İkisinin de B1 ya da altı dediği **13 kart** `level: "B1"` oldu; `level_source` yine `editorial_estimate`. Kart ID'leri seviye içermediği için değişmedi. Yargıçların ayrıntılı gerekçe metinleri bu düzenlemeye gelmedi; satırlardaki gerekçe, yargıç kararının editör özetidir.

- `en.method.n.1` (method): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.summary.n.1` (summary): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.intelligence.n.1` (intelligence): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel. Konu: `mind_psychology` B1'i kapsamıyordu → `primary_topic` `personality`, `topics` [personality, mind_psychology].
- `en.talent.n.1` (talent): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.focus.v.1` (focus): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.reasonable.adj.1` (reasonable): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.talented.adj.1` (talented): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.obviously.adv.1` (obviously): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.slightly.adv.1` (slightly): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.mainly.adv.1` (mainly): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.point_of_view.phr.1` (point of view): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.on_the_other_hand.phr.1` (on the other hand): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.as_a_result.phr.1` (as a result): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.

B2'de kalan adaylar (yargıçlar ayrıştı ya da B2 dedi): `en.factor.n.1`, `en.identify.v.1`, `en.academic.adj.1`.

## İkinci örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) her akıştan 7 kartlık bir örneklemi (toplam 70 kart) ikinci kez okudu. 35 bulgunun hepsi kartla karşılaştırıldı ve hepsi gerçek çıktı; düzeltildi. Bulgulardan çıkan yeni sistematik sorunlar s23–s32'nin 600 kartında tarandı: `def.long`'un ikinci bir anlama kayması (ve aynı anlamın örnek, eşdizim, `alt` ya da quiz'e girmesi), başka sözcük türünden ya da yalnızca yazımı benzeyen çeldiriciler, ABD IPA'sında ɝ/ɚ yazımı, boş `confusables` dizisi.

- Bu akışta değişen kart: **20**, alan: **47**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.principle.n.1`: Türkçe, 3. örnek (düşük): gerçek ama İngilizce bulgusuyla birlikte kapandı: örnek tümden değişti.
- `en.principle.n.1`: İngilizce, iki anlam (orta): gerçek. Ahlaki ilke anlamı tutuldu; 3. örnek 'She refused the money on principle.', tanımlar ve eşdizimler tek anlama indi.
- `en.motivation.n.1`: İngilizce, def.long ve 2. örnek (orta): gerçek. Neden anlamı silindi; 2. örnek 'It's hard to find the motivation to exercise in winter.'
- `en.underline.v.1`: İngilizce, def.long (düşük): gerçek. 'emphasize' cümlesi silindi; aynı anlamın alt'ı 'vurgulamak' da çıktı (notta var).
- `en.semester.n.1`: Quiz (düşük): gerçek. 'lecture' yerine 'textbook'.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| argument.n.1 | def.long | silinen cümle: "In everyday English it can also mean an angry disagreement: 'They had an argument.'" | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| conclusion.n.1 | def.long | silinen cümle: "It is also the last part of an essay or a speech: 'In conclusion, ...'" | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| logic.n.1 | def.long | "A sensible way of thinking in which one idea follows clearly from another. It is also the name of a subject in philosophy and math. 'There'…" → "A sensible way of thinking in which one idea follows clearly from another. 'There's no logic in it' means it doesn't make sense." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| principle.n.1 | def.short | "a basic rule or belief that guides how you act or how something works" → "a belief about right and wrong that guides how you act" | 'how something works' ikinci anlam (bulgu) |
| principle.n.1 | def.long | "A basic idea or rule that explains how something works, or a belief about right and wrong that guides you. 'In principle' means 'in general…" → "A belief about what is right and wrong that guides the way you act. Doing something 'on principle' means doing it because of this belief." | Çalışma ilkesi anlamı ve 'in principle' çıkarıldı (not 'in principle'ı anlatıyor) (bulgu) |
| principle.n.1 | examples[2] | "The basic principle of the engine is very simple. / Motorun temel ilkesi çok basit." → "She refused the money on principle. / Parayı ilkesi gereği reddetti." | 'basic principle of the engine' çalışma ilkesi anlamı; Türkçe bulgusu da bununla kapandı (bulgu) |
| principle.n.1 | collocations | "[stick to your principles, on principle, a basic principle]" → "[stick to your principles, on principle, a person of principle]" | 'a basic principle' çalışma ilkesine kayıyordu (bulgu) |
| principle.n.1 | grammar.pattern | "in principle; on principle" → "on principle; against sb's principles" | 'in principle' başka anlam (bulgu) |
| semester.n.1 | quiz.distractors | "[lecture, campus, revision]" → "[textbook, campus, revision]" | 'spring lecture' ders dizisi olarak savunulabiliyordu (bulgu) |
| revision.n.1 | def.long | "In British English, the work of studying again what you learned, to prepare for an exam. It can also mean a change to a text or a plan. In …" → "In British English, the work of studying again what you learned, to prepare for an exam. In American English, students usually say 'review'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| intelligence.n.1 | def.long | silinen cümle: "The word is also used for secret information about other countries or enemies, as in 'intelligence services'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| talent.n.1 | def.long | silinen cümle: "It can also mean talented people: 'The club is looking for new talent.'" | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| motivation.n.1 | def.long | silinen cümle: "It can also mean the reason why someone does something." | def.long güdü/neden anlamına kayıyordu (bulgu) |
| motivation.n.1 | examples[1] | "Money isn't my only motivation for working here. / Burada çalışmak için tek motivasyonum para değil." → "It's hard to find the motivation to exercise in winter. / Kışın spor yapmak için motivasyon bulmak zor." | 'my only motivation for working here' neden anlamı (bulgu) |
| discipline.n.1 | def.long | silinen cümle: "It can also mean rules and punishment in a school or the army." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| assume.v.1 | def.long | silinen cümle: "It can also mean to take on a job or power." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| conclude.v.1 | def.long | silinen cümle: "In formal English, it can also mean to end a meeting, a speech or an event." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| reflect.v.1 | def.long | silinen cümle: "It also has a physical meaning: a mirror sends back light or images." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| recall.v.1 | def.long | silinen cümle: "Companies also recall products when they ask people to return them." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| revise.v.1 | sense_note | "study again (UK); change a text" → "study again for an exam (UK)" | Kart iki anlam taşıyordu (sınava tekrar + metni düzeltmek) (tarama) |
| revise.v.1 | def.short | "study again what you learned before an exam (UK); also change a text" → "study again what you learned, to prepare for an exam (UK)" | Tek anlam (tarama) |
| revise.v.1 | def.long | "In British English, to study again what you learned before an exam. In both British and American English, it also means to change a text, p…" → "In British English, to study again what you have learned so that you are ready for an exam. In American English, students usually say 'revi…" | Tek anlam (tarama) |
| revise.v.1 | examples[2] | "The writer revised the last chapter three times. / Yazar son bölümü üç kez elden geçirdi." → "We spent the whole weekend revising for the final exams. / Bütün hafta sonunu final sınavlarına tekrar yaparak geçirdik." | 'revised the last chapter' metni düzeltme anlamı (notta var) (tarama) |
| revise.v.1 | collocations | "[revise for an exam, revise a plan, a revised version]" → "[revise for an exam, revise for a test, revise hard]" | 'revise a plan', 'a revised version' ikinci anlam (tarama) |
| revise.v.1 | l1.tr.gloss | "tekrar yapmak, revize etmek" → "tekrar yapmak" | 'revize etmek' ikinci anlam (tarama) |
| revise.v.1 | l1.tr.gloss_short | "tekrar yapmak" → "(alan silindi)" | gloss 16 karakterin altına indi (tarama) |
| revise.v.1 | l1.tr.alt | "[konuları tekrarlamak, tekrar etmek, elden geçirmek]" → "[konuları tekrarlamak, tekrar etmek]" | 'elden geçirmek' ikinci anlam (tarama) |
| revise.v.1 | tags.topics | "[school_learning, literature_writing]" → "[school_learning]" | literature_writing ikinci anlama aitti (tarama) |
| question.v.1 | def.long | silinen cümle: "It can also mean to ask someone a lot of things in an official way, as the police do after a crime." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| question.v.1 | sense_note | "have doubts about; ask about" → "have doubts about sth" | Kart iki anlam taşıyordu (sorgulamak + sorguya çekmek) (tarama) |
| question.v.1 | examples[2] | "Police questioned two men about the robbery. / Polis soygunla ilgili iki adamı sorguladı." → "Students should learn to question what they read online. / Öğrenciler internette okuduklarını sorgulamayı öğrenmeli." | 'Police questioned two men' sorguya çekme anlamı (notta var) (tarama) |
| question.v.1 | collocations | "[question a decision, question sb about, be questioned by police]" → "[question a decision, question the results, seriously question]" | 'question sb about', 'be questioned by police' ikinci anlam (tarama) |
| question.v.1 | l1.tr.alt | "[şüpheyle yaklaşmak, sorguya çekmek]" → "[şüpheyle yaklaşmak]" | 'sorguya çekmek' ikinci anlam (tarama) |
| identify.v.1 | def.long | "To recognize someone or something and say who or what they are. It can also mean to find or discover something, such as the cause of a prob…" → "To recognize someone or something and say exactly who or what they are, for example a bird in a photo or the cause of a problem." | 'find or discover' ayrı anlam gibi anlatılıyordu; örnekler ve quiz aynı anlamı kullanıyor (tarama) |
| demonstrate.v.1 | def.long | silinen cümle: "It can also mean to prove something, or to protest in the street." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| demonstrate.v.1 | l1.tr.alt | "[uygulamalı göstermek, kanıtlamak, gösteri yapmak]" → "[uygulamalı göstermek]" | 'kanıtlamak', 'gösteri yapmak' başka anlamlar (notta protesto var) (tarama) |
| underline.v.1 | def.long | silinen cümle: "It can also mean to show clearly that something is important, like 'emphasize'." | def.long ikinci bir anlama kayıyordu; o cümle silindi (bulgu) |
| underline.v.1 | l1.tr.alt | "[vurgulamak]" → "[]" | 'vurgulamak' mecazi anlam; notta zaten var (bulgu) |
| highlight.v.1 | sense_note | "mark text with color; point out" → "mark text with color" | Kart iki anlam taşıyordu (işaretlemek + dikkat çekmek) (tarama) |
| highlight.v.1 | def.short | "mark words with a bright pen or color; also show that something is important" → "mark words with a bright pen or a color so they are easy to see" | Tek anlam (tarama) |
| highlight.v.1 | def.long | "To mark part of a text with a bright pen, or with a color on a screen, so it is easy to see. It also means to point out that something is i…" → "To mark part of a text with a bright pen, or with a color on a screen, so it is easy to see. Students often do this when they study." | Tek anlam (tarama) |
| highlight.v.1 | examples[1] | "The report highlights the problem of air pollution in big cities. / Rapor, büyük şehirlerdeki hava kirliliği sorununa dikkat çekiyor." → "You can highlight a word on the screen and copy it. / Ekrandaki bir kelimeyi işaretleyip kopyalayabilirsin." | 'The report highlights the problem' dikkat çekme anlamı (nota taşındı) (tarama) |
| highlight.v.1 | collocations | "[highlight the text, highlight a problem, highlight in yellow]" → "[highlight the text, highlight in yellow, highlight key words]" | 'highlight a problem' ikinci anlam (tarama) |
| highlight.v.1 | l1.tr.gloss | "işaretlemek, vurgulamak" → "işaretlemek" | 'vurgulamak' ikinci anlam (tarama) |
| highlight.v.1 | l1.tr.gloss_short | "işaretlemek" → "(alan silindi)" | gloss 16 karakterin altına indi (tarama) |
| highlight.v.1 | l1.tr.alt | "[dikkat çekmek, fosforlu kalemle çizmek]" → "[fosforlu kalemle çizmek]" | 'dikkat çekmek' ikinci anlam (tarama) |
| highlight.v.1 | l1.tr.note | "Fosforlu kalem İngilizcede 'highlighter' olur. İsim olarak 'highlights' bir maçın ya da olayın en önemli anlarıdır (maç özeti)." → "Fosforlu kalem 'highlighter' olur. Mecazi olarak 'dikkat çekmek' anlamı da vardır: 'The report highlights the problem.' İsim olarak 'highli…" | İkinci anlam nota taşındı (tarama) |

- Çeldirici: `s30: 60 quizzes, 123 distinct distractors; top: semester×4, doubt×4, tended×4, quote×4, consequence×3, talent×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Üçüncü örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) s23–s32'den 80 kartlık yeni bir örneklemi okudu. 35 bulgu kartla karşılaştırıldı: 33'ü gerçek çıktı ve düzeltildi, 2'si (release, carbon footprint çevirileri) gerekçesiyle reddedildi. Önceki iki turun listesinde olmayan sistematik sorunlar s23–s32'nin 600 kartında tarandı: `gloss_short`'ta kesilmiş söz; `alt`'ın kartın kendi notuyla ya da başka bir kartın ayrımıyla çelişmesi (ve önceki taramada kalan ikinci anlam karşılıkları); `grammar.pattern`'da başka anlamın kalıbı; `def.long`'da önceki anahtar sözcük taramasının kaçırdığı ikinci anlam cümleleri (ve aynı anlamın örnek, eşdizim, quiz'e taşması); akraba kartlar arasında neredeyse aynı örnek ya da boşluklu cümle; boşluğa anlamca hiç uymayan, soruyu ele veren çeldiriciler; şapkası düşmüş hâl / dâhil. Seviyeler değişmedi.

- Bu akışta değişen kart: **18**, alan: **24**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.talented.adj.1`: Türkçe ve İngilizce gözü, alt (düşük; iki denetçi aynı bulgu): gerçek. 'becerikli' yerine 'yetenek sahibi'.
- `en.as_a_result.phr.1`: Türkçe, gloss (düşük): gerçek. gloss 'bunun sonucunda', 'sonuç olarak' alt'a geçti.
- `en.question.v.1`: İngilizce, `grammar.pattern` (orta): gerçek. 'question sth; question whether…'.
- `en.debate.n.1`: İngilizce, `def.long`, 3. örnek ve alt (düşük): gerçek. Yarışma cümlesi silindi, 3. örnek 'The new law caused a heated debate in parliament.', 'münazara' alt'tan çıktı (notta var). Şıklar da tarama F'de değişti.
- `en.assume.v.1`: Quiz, çeldiriciler (düşük): gerçek. doubted, denied, questioned (önerilen 'checked/confirmed' saat değişmiş olabileceği için cümlede savunulabilirdi).

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| debate.n.1 | def.long | silinen cümle: "It can also be a school competition with rules and a winner." | def.long ikinci bir anlama kayıyordu; o cümle silindi (bulgu) |
| debate.n.1 | examples[2] | "Selin's team won the school debate competition. / Selin'in takımı okulun münazara yarışmasını kazandı." → "The new law caused a heated debate in parliament. / Yeni yasa mecliste hararetli bir tartışmaya yol açtı." | Okul münazara yarışması ayrı alt anlam (bulgu) |
| debate.n.1 | l1.tr.alt | "[münazara, tartışma programı]" → "[tartışma programı]" | 'münazara' yarışma anlamı (notta var) (bulgu) |
| debate.n.1 | quiz.distractors | "[brochure, timetable, headline]" → "[cartoon, series, forecast]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| argument.n.1 | quiz.distractors | "[semester, discipline, doubt]" → "[question, warning, complaint]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| logic.n.1 | quiz.distractors | "[talent, appetite, salary]" → "[advice, directions, recipe]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| concept.n.1 | def.long | silinen cümle: "In business it can also mean the main idea behind a new product." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| aspect.n.1 | quiz.distractors | "[lectures, receipts, talents]" → "[numbers, prices, colors]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| factor.n.1 | examples.2.tr | "Takımın kazanmasına şans dahil birçok etken yardımcı oldu." → "Takımın kazanmasına şans dâhil birçok etken yardımcı oldu." | TDK yazımı: hâl / dâhil (şapka düşmüştü) (tarama) |
| semester.n.1 | l1.tr.alt | "[yarıyıl, sömestr]" → "[yarıyıl]" | 'sömestr' notun uyardığı şubat tatili anlamı (tarama) |
| summary.n.1 | quiz.cloze | "I didn't read the whole report, just the one-page ______ at the beginning." → "The book has a short ______ on the back cover, so you know what it's about." | başka bir kartta neredeyse aynı cümle vardı (headline quiz: 'I didn't read the whole article, just the ___') (tarama) |
| draft.n.1 | quiz.distractors | "[principle, climate, lecturer]" → "[estimate, guess, idea]" | çeldiriciler boşluğa anlamca hiç uymuyordu; soru kelimeyi sınamıyordu (tarama) |
| assume.v.1 | quiz.distractors | "[underlined, quoted, reflected]" → "[doubted, denied, questioned]" | 'underlined/quoted/reflected' that-cümlesi almıyordu (bulgu) |
| define.v.1 | l1.tr.alt | "[tarif etmek, belirlemek]" → "[belirlemek]" | 'tarif etmek' notun ayırdığı 'describe' (tarama) |
| question.v.1 | grammar.pattern | "question sth; question sb about sth" → "question sth; question whether…" | 'question sb about sth' sorguya çekme anlamı (notta var) (bulgu) |
| apply.v.1 | def.long | silinen cümle: "The more common meaning is to ask formally for a job, a visa or a place at university." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| interpret.v.1 | l1.tr.alt | "[anlamlandırmak, tercümanlık yapmak]" → "[anlamlandırmak]" | 'tercümanlık yapmak' sözlü çeviri anlamı; önceki taramada kalmış (tarama) |
| interpret.v.1 | def.long | silinen cümle: "It can also mean to translate what someone says." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| accurate.adj.1 | examples[2] | "We need accurate numbers before we can make a decision. / Karar verebilmek için kesin rakamlara ihtiyacımız var." → "Make sure your answers are accurate before you send the form. / Formu göndermeden önce cevaplarının doğru olduğundan emin ol." | başka bir kartta neredeyse aynı cümle vardı (data: 'We need more data before we make a decision') (tarama) |
| talented.adj.1 | l1.tr.alt | "[kabiliyetli, becerikli]" → "[kabiliyetli, yetenek sahibi]" | 'becerikli' notun ayırdığı 'skilled' anlamı (bulgu) |
| point_of_view.phr.1 | def.long | silinen cümle: "In stories, it also shows whose eyes we see the events through." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| point_of_view.phr.1 | examples[2] | "The story is told from the dog's point of view. / Hikâye köpeğin bakış açısından anlatılıyor." → "I understand your point of view, but I don't agree. / Bakış açını anlıyorum ama katılmıyorum." | Anlatıcının bakış açısı ayrı anlam (tarama) |
| as_a_result.phr.1 | l1.tr.gloss | "sonuç olarak" → "bunun sonucunda" | 'sonuç olarak' notun uyardığı 'in conclusion' anlamını da taşıyor (bulgu) |
| as_a_result.phr.1 | l1.tr.alt | "[bu yüzden, bunun sonucunda]" → "[bu yüzden, sonuç olarak]" | Eski gloss alt'a geçti (bulgu) |

- Çeldirici: `s30: 60 quizzes, 130 distinct distractors; top: tended×4, quote×4, consequence×3, aspect×3, semester×3, campus×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
