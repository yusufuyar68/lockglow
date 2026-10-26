# s28 QA incelemesi (B2: ilişkiler, iletişim ve kişilik)

Kapsam: `content/drafts/kisisel_v1/s28/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: insan ilişkileri, iletişim ve kişilik sözcükleri (isim, fiil, sıfat, zarf), 4 phrasal verb ve 2 deyim. Seviye: hepsi B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** tek yazar ajanı, `1_yazar_kurallari.md`, s22 biçimi. Yazarın "emin olmadığım" maddeleri denetçiye ayrıca verildi.
2. **Denetim:** tek bağımsız denetçi, `2_denetci_kurallari.md`. 60 kart tek tek okundu: anlam, tanım, IPA, örnekler ve geri çeviri, gloss/alt/gloss_short, not, hata maddeleri, sahte dost, quiz'de her şık boşluğa konarak tek doğru cevap.

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 52 kelime (`word`; 22 isim, 18 fiil, 10 sıfat, 2 zarf), 2 eşdizim (body language, eye contact), 4 phrasal verb (rely on, stand up for, tell off, talk into), 2 deyim (get on someone's nerves, see eye to eye).
- Değişen kart: **16** (`critic_edited`), değişen alan: **20** (tablo aşağıda).
- Reddedilen kart (`critic_reject`): **0**. Silinen seviye yok; seviye şüpheleri aşağıda yalnızca işaretlendi.
- Etimoloji: hepsi `null`. `sensitivity`: hepsi 0. `exams`: hepsi `[]`.
- Sahte dost: 1 kart (sympathize ↔ "sempati duymak"); gerçek bulundu, tutuldu.
- Türkçeden çeviri hatası (`mistakes`): denetim sonrası 18 kartta 18 madde. Silinen 2: kindness "Can you do me a kindness?" (eski üslup ama doğru İngilizce, hata sayılamaz), apology "I apologize from you" (gerçek hata ama fiile ait; nota taşındı).
- Çeldirici (`distractor_stats.py`): `s28: 60 quizzes, 148 distinct distractors; top: loyalty×4, praise×4, patience×3, rumor×3, apology×3, grumpy×3` (sınır 4).
- IPA DRESS (`ipa_dress_stats.py`): `/e/` 0, `/ɛ/` 11 (US ve UK).
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Quiz'de ikinci okuma:** patience ("have a little respect" doğal bir kalıp), disagreement ("some agreement… two wanted surgery" kısmi uzlaşma olarak okunuyor), communicate ("the two kids greet with hand signs" mümkün). Üç çeldirici değişti; son hâlde her soruda tek doğru cevap var.
  2. **Kilit ekranında yanlış okunan Türkçe karşılık:** approach alt "başvurmak" (apply), trustworthy alt "emin" (sure), talk into alt "kandırmak" (deceive), see eye to eye gloss_short "aynı fikirde" (kesik). Düzeltildi.
  3. **IPA biçimi:** 6 kartta US NURSE ünlüsü `/ɝː/` yazılmıştı; destenin çoğunluk kuralına göre `/ɜːr/` yapıldı (hepsi 26 karakter sınırında kaldı).
- **Yazarın "emin olmadığım" maddeleri için kararlar:**
  - patience "My patience finished": tutuldu. "Sabrım bitti" → finish, Türkçe konuşanların "The milk finished" gibi bilinen 'bitmek = finish' hatasının bir örneği.
  - tone "speak … with that tone": tutuldu ('-la' → with aktarımı çok yaygın).
  - whisper "whispered to my ear": tutuldu ('kulağıma' yönelme eki → to).
  - deserve "You are deserving a holiday": tutuldu ('hak ediyorsun' -iyor → durum fiilinde -ing; Türkçe konuşanlarda bilinen eğilim). Sınırda; aşağıda listelendi.
  - apology "I apologize from you": isim kartından çıkarıldı, bilgi nota taşındı.
  - sympathize sahte dost: gerçek. "Sempati duymak" birini sevimli bulmak demek, sympathize ise derdini anlamak (sympathetic ≠ sempatik ile aynı aile). Gloss "halinden anlamak" doğal ve doğru.
  - pretend "-mış gibi yapmak": tutuldu; sözlük karşılığı olarak kilit ekranında anlaşılır.
  - supportive "destekleyici": gerçekten kitabi; gloss "destek olan" yapıldı, "destekleyici" alt'a indi.
  - conflict "çatışma, anlaşmazlık": tutuldu; notta disagreement ile fark var, kilit ekranında `gloss_short` "çatışma" görünüyor.
  - frankly, acquaintance, talk into, see eye to eye quiz'leri: her şık denendi, tek doğru cevap var; değişmedi. ("roommates" zayıf ama "at the gym" bağlamında açıkça yanlış.)
  - direct IPA (US /dəˈrɛkt/, UK /daɪˈrɛkt/) ve talk into US /tɔːk/: iki biçim de sözlüklerde var; deste "talkative" /ˈtɔːkətɪv/ ile tutarlı. Değişmedi.
- **Seviye (B2) uygunluğu, değiştirilmedi, yalnızca işaret:**
  - Muhtemelen **B1 (ya da altı):** character (A2–B1), respect, reaction, greet, admit, pretend, express, communicate, whisper.
  - Muhtemelen **C1'e yakın:** tease, reserved (kişilik anlamı), trustworthy, see eye to eye.
  - Geri kalanlar B2 için akla yatkın.
- **Karışan kelimeler:** destede kartı olmayan eşler (royalty, patients, critic, prize, favor, affect, persuade, accept, considerable, respectable, social, tell on, stand up, trust) gerçek tuzaklar; tutuldu. Diğer klasörlerdeki kartlar (personality, reliable, moody, gossip, blame, compliment, make fun of) düzenlenmedi; derleyici çiftleri iki yönlü bağlıyor.

## Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| patience | quiz.distractors | respect → loyalty | 'Please have a little respect' kalıp olarak dilbilgisel ve doğal; ikinci okuma riski. |
| apology | l1.tr.note + mistakes | 'I apologize from you' hatası (mistakes) → hata nota taşındı, mistakes [] | Hata isim kartına değil 'apologize' fiiline ait; bilgi notta korunuyor. |
| encouragement | ipa.us | /ɪnˈkɝːɪdʒmənt/ → /ɪnˈkɜːrɪdʒmənt/ | Deste kuralı: US NURSE ünlüsü /ɜːr/ (s28'de /ɝː/ yazılmıştı). |
| disagreement | quiz.distractors | agreement → silence | 'There was some agreement… two wanted surgery' kısmi uzlaşma olarak okunabiliyordu. |
| kindness | l1.tr.mistakes | Can you do me a kindness? → [] | 'Do me a kindness' eski üslup ama doğru İngilizce; hata sayılamaz. Favor uyarısı notta kalıyor. |
| deserve | ipa.us | /dɪˈzɝːv/ → /dɪˈzɜːrv/ | Deste kuralı: US NURSE ünlüsü /ɜːr/ (s28'de /ɝː/ yazılmıştı). |
| communicate | quiz.distractors | greet → whisper | 'the two kids greet with hand signs' dilbilgisel ve anlamca mümkün. |
| approach | examples[2].tr | İş için birkaç şirkete başvurdu. → İş için birkaç şirketle görüştü. | 'başvurmak' apply demek; approach a company = görüşmek, temasa geçmek. |
| approach | l1.tr.alt | ['yanına gitmek', 'başvurmak'] → ['yanına gitmek'] | 'başvurmak' kilit ekranında 'apply' olarak okunur. |
| considerate | l1.tr.note | Teşekkür ederken 'That's very considerate of you' denir. Dalgın anlamındaki 'düşünceli' için 'thoughtful' denir. 'Considerable' ise 'büyük, önemli' demektir. → Teşekkür ederken 'That's very considerate of you' denir. 'Düşünceli görünüyordu' (kaygılı, dalgın) anlamında 'considerate' kullanılmaz; 'thoughtful' ya da 'worried' denir. 'Considerable' ise 'büyük, önemli' demektir. | 'Dalgın anlamındaki düşünceli' ifadesi belirsizdi; tuzak cümleyle netleştirildi. |
| supportive | l1.tr.gloss / alt | destekleyici / ['destek olan', 'arka çıkan'] → destek olan / ['destekleyici', 'arka çıkan'] | 'Destekleyici' kişi için resmî ve kitabi; gündelik Türkçede 'destek olan'. |
| reserved | ipa.us | /rɪˈzɝːvd/ → /rɪˈzɜːrvd/ | Deste kuralı: US NURSE ünlüsü /ɜːr/ (s28'de /ɝː/ yazılmıştı). |
| trustworthy | ipa.us | /ˈtrʌstwɝːði/ → /ˈtrʌstwɜːrði/ | Deste kuralı: US NURSE ünlüsü /ɜːr/ (s28'de /ɝː/ yazılmıştı). |
| trustworthy | l1.tr.alt | ['itimat edilir', 'emin'] → ['itimat edilir', 'sözüne güvenilir'] | 'emin' tek başına 'sure' olarak okunur. |
| determined | ipa.us | /dɪˈtɝːmɪnd/ → /dɪˈtɜːrmɪnd/ | Deste kuralı: US NURSE ünlüsü /ɜːr/ (s28'de /ɝː/ yazılmıştı). |
| determined | examples[1].tr | Hande dizi ağrısına rağmen maratonu bitirmeye kararlıydı. → Hande dizindeki ağrıya rağmen maratonu bitirmeye kararlıydı. | 'dizi ağrısı' 'dizi' (TV) ile karışıyor; 'dizindeki ağrı' doğal. |
| talk into | l1.tr.alt | ['razı etmek', 'kandırmak'] → ['razı etmek'] | 'kandırmak' çoğunlukla 'deceive' okunur; kartın anlamı ikna. |
| get on someone's nerves | ipa.us | /ɡɛt ɑːn ˈsʌmwʌnz ˈnɝːvz/ → /ɡɛt ɑːn ˈsʌmwʌnz ˈnɜːrvz/ | Deste kuralı: US NURSE ünlüsü /ɜːr/ (s28'de /ɝː/ yazılmıştı). |
| see eye to eye | l1.tr.gloss_short | aynı fikirde → hemfikir olmak | 'aynı fikirde' kesik duruyor; alt'taki 14 karakterlik tam fiil kullanıldı. |
| see eye to eye | examples[2] | The two managers finally see eye to eye on the new plan. || İki yönetici sonunda yeni plan konusunda aynı fikirde. → The two managers now see eye to eye on the new plan. || İki yönetici artık yeni plan konusunda aynı fikirde. | 'finally see' geniş zamanla doğal durmuyordu; 'now' ile durum bildiriyor. |

Değişmeyen ama bakılanlar: 60 quiz'in her şıkkı boşluğa konarak okundu (convince "explained/suggested my dad that", inspire "made/let me to start", accuse "blamed/criticized me of" gibi gerçek hata biçimli çeldiriciler kasıtlı ve doğru). Hata maddeleri respect "respect to", confidence "confidence to myself", insult "insulted to me", approach "approached to me", impress "impressed from", inspire "inspired from", accuse "accused me with", sincere "we are very sincere", get on someone's nerves "touches my nerves", convince "I convinced", admit "admitted the job offer", praise "a big praise", criticism "his critics" gerçek Türkçe kaynaklı hatalar olarak tutuldu.

## Çeldirici çeşitlendirme ve son kontrol (2026-10-26)

- `distractor_stats.py`: `s28: 60 quizzes, 148 distinct distractors; top: loyalty×4, praise×4, patience×3, rumor×3, apology×3, grumpy×3`. Sınır max(4, %5 × 60 = 3) = 4 aşılmıyor; değişen kart **0**, cloze değişikliği yok.
- 60 quiz'in her şıkkı yeniden boşluğa konarak okundu: her soruda tek doğru cevap var; çeldiriciler cevaba eşit değil, tekrarsız, en fazla 16 karakter.
- `ipa_dress_stats.py`: `s28 {'uk_e': 0, 'uk_ɛ': 11, 'us_e': 0, 'us_ɛ': 11}`; düzeltme gerekmedi.
- Başlık çakışması (`dump_lemmas.py`, 1984 başlık): s28'deki 60 lemmanın hiçbiri başka bir akışta yok (yazım farkları, ör. -ise/-ize, -our/-or ve "someone's" kalıpları da tarandı); akış içinde de tekrar yok.

## Anadili Türkçe birinin bakması gerekenler

1. Sınırdaki hata maddeleri: deserve "You are deserving a holiday", patience "My patience finished", whisper "She whispered to my ear". Gerçekte ne kadar sık?
2. Kilit ekranı karşılıkları: pretend "-mış gibi yapmak", supportive "destek olan", encouragement "cesaret verme" ("cesaretlendirme" daha mı doğal?), admit "kabul etmek" (accept ile aynı karşılık; kart bu farkı öğretiyor ama kilit ekranında tek başına görünüyor), reserved "çekingen" (shy'a kayıyor mu?).
3. considerate notu: "'Düşünceli görünüyordu' (kaygılı, dalgın)" açıklaması anlaşılır mı?
4. sympathize örneği "Halinden çok iyi anlıyorum" ve false_friend açıklaması "birini sevimli bulmak, ona ısınmak" doğru mu?
5. approach üçüncü örnek "İş için birkaç şirketle görüştü." İngilizcedeki "approached … about a job" anlamını veriyor mu?

## Son doğrulama

```
python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s28
60 kart · 60 şemadan geçti · 0 hata · 0 uyarı
```

## Örneklem denetimi (2026-10-26)

Üç bağımsız denetçi B2 destesinden 80 kartlık bir örneklemi okudu (Türkçe, İngilizce ve quiz gözüyle). Bulgular tek tek doğrulandı; doğru olanlar düzeltildi. Bulgulardan çıkan beş sistematik sorun (notlarda 'siz' hitabı, İngilizce cümlede özne olan 'Can' adı, ikinci anlama kayan örnek ve eşdizimler, başka sözcük türünden çeldiriciler, B1 olabilecek seviyeler) s23–s32'nin 600 kartında tarandı.

- Bu akışta değişen kart: **4**, alan: **5**. Değişen kartlara `critic_edited` eklendi.
- Çeldirici: `s28: 60 quizzes, 148 distinct distractors; top: loyalty×4, praise×4, patience×3, rumor×3, apology×3, grumpy×3` (sınır max(4, %5) = 4 aşılmıyor).
- Seviye: değiştirilmedi. B1 olabilecek kartlar bu dosyanın seviye bölümünde zaten işaretli; karar kullanıcıda.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| gesture.n.1 | examples[2] | "Sending flowers to the hospital was a kind gesture. / Hastaneye çiçek göndermek ince bir jestti." → "He made a rude gesture at the other driver. / Diğer sürücüye kaba bir el hareketi yaptı." | 'a kind gesture' ince davranış anlamı |
| gesture.n.1 | collocations | "make a gesture, a kind gesture, hand gestures" → "make a gesture, a rude gesture, hand gestures" | 'a kind gesture' ayrı anlam |
| weakness.n.1 | examples[2] | "In the interview, Can talked honestly about his weaknesses. / Mülakatta Can zayıf yönlerinden dürüstçe bahsetti." → "In the interview, Yiğit talked honestly about his weaknesses. / Mülakatta Yiğit zayıf yönlerinden dürüstçe bahsetti." | 'Can' adı İngilizcede modal 'can' gibi okunuyor |
| inspire.v.1 | collocations | "inspire sb to, be inspired by, inspire confidence" → "inspire sb to, be inspired by, inspire a generation" | 'inspire confidence' ayrı anlam (güven uyandırmak) |
| get_on_someones_nerves.idm.1 | examples[2].tr | "Kalemine vurmayı bırak! Herkesin sinirini bozuyor." → "Kalemle masaya vurup durma! Herkesin sinirini bozuyor." | 'Kalemine vurmak' kaleme vurmak gibi okunuyor |

Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Seviye kararı (2026-10-26)

İki bağımsız yargıç B1 olabilecek adayları ayrı ayrı değerlendirdi. İkisinin de B1 ya da altı dediği **9 kart** `level: "B1"` oldu; `level_source` yine `editorial_estimate`. Kart ID'leri seviye içermediği için değişmedi. Yargıçların ayrıntılı gerekçe metinleri bu düzenlemeye gelmedi; satırlardaki gerekçe, yargıç kararının editör özetidir.

- `en.respect.n.1` (respect): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.character.n.1` (character): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.reaction.n.1` (reaction): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.admit.v.1` (admit): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.pretend.v.1` (pretend): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.express.v.1` (express): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.greet.v.1` (greet): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.whisper.v.1` (whisper): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.
- `en.communicate.v.1` (communicate): iki yargıç da B1: günlük dilde sık ve B1 ders kitaplarında geçen bir kelime; B2 için fazla temel.

B2'de kalan aday yok.

## İkinci örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) her akıştan 7 kartlık bir örneklemi (toplam 70 kart) ikinci kez okudu. 35 bulgunun hepsi kartla karşılaştırıldı ve hepsi gerçek çıktı; düzeltildi. Bulgulardan çıkan yeni sistematik sorunlar s23–s32'nin 600 kartında tarandı: `def.long`'un ikinci bir anlama kayması (ve aynı anlamın örnek, eşdizim, `alt` ya da quiz'e girmesi), başka sözcük türünden ya da yalnızca yazımı benzeyen çeldiriciler, ABD IPA'sında ɝ/ɚ yazımı, boş `confusables` dizisi.

- Bu akışta değişen kart: **3**, alan: **3**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.loyalty.n.1`: Türkçe, 2. örnek (düşük): gerçek, ama gerekçe kısmen. 'Müşteri sadakati' Türkçede yaygın bir terim; asıl sorun 'zor yıldaki sadakatiniz' yapısıydı. Önerilen 'bize gösterdiğiniz bağlılık' cümlesi uygulandı.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| loyalty.n.1 | examples.1.tr | "Bu zor yıldaki sadakatiniz için teşekkür ederiz." → "Bu zor yılda bize gösterdiğiniz bağlılık için teşekkür ederiz." | 'zor yıldaki sadakatiniz' yapısı kurumsal teşekkürde doğal değil (bulgu) |
| gesture.n.1 | def.long | silinen cümle: "It can also mean a kind action that shows you care." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| sympathize.v.1 | def.long | silinen cümle: "It can also mean to agree with someone's ideas." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |

- Çeldirici: `s28: 60 quizzes, 148 distinct distractors; top: loyalty×4, praise×4, patience×3, rumor×3, apology×3, grumpy×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`

## Üçüncü örneklem denetimi (2026-10-26)

Üç denetçi (Türkçe, İngilizce, quiz) s23–s32'den 80 kartlık yeni bir örneklemi okudu. 35 bulgu kartla karşılaştırıldı: 33'ü gerçek çıktı ve düzeltildi, 2'si (release, carbon footprint çevirileri) gerekçesiyle reddedildi. Önceki iki turun listesinde olmayan sistematik sorunlar s23–s32'nin 600 kartında tarandı: `gloss_short`'ta kesilmiş söz; `alt`'ın kartın kendi notuyla ya da başka bir kartın ayrımıyla çelişmesi (ve önceki taramada kalan ikinci anlam karşılıkları); `grammar.pattern`'da başka anlamın kalıbı; `def.long`'da önceki anahtar sözcük taramasının kaçırdığı ikinci anlam cümleleri (ve aynı anlamın örnek, eşdizim, quiz'e taşması); akraba kartlar arasında neredeyse aynı örnek ya da boşluklu cümle; boşluğa anlamca hiç uymayan, soruyu ele veren çeldiriciler; şapkası düşmüş hâl / dâhil. Seviyeler değişmedi.

- Bu akışta değişen kart: **8**, alan: **14**. Değişen kartlara `critic_edited` eklendi.

### Bulgu kararları

- `en.sympathize.v.1`: Türkçe, hâl yazımı (düşük): gerçek. gloss ve iki örnek 'hâlinden'; aynı yazım s26'daki 'ruh hâline' ile birlikte 600 kartta tarandı.
- `en.sympathize.v.1`: İngilizce, 3. örnek (düşük): gerçek. 'I sympathize with your situation, but I can't change the rules.'
- `en.convince.v.1`: İngilizce, `def.long` (orta): gerçek. Cümle silindi; 'convince sb to do sth' notta, yalnız Amerikan diye etiketlenmeden anıldı.

### Değişiklik tablosu

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| conflict.n.1 | def.long | silinen cümle: "In the news it can also mean fighting between countries." | def.long ikinci bir anlama kayıyordu; o cümle silindi (tarama) |
| conflict.n.1 | quiz.cloze | "The two countries signed a peace deal to end the ______." → "The two managers finally talked and solved the ______ between their teams." | 'peace deal' silahlı çatışma anlamını sınıyordu (tarama) |
| gesture.n.1 | grammar.pattern | "make a gesture; a kind gesture" → "make a gesture (to sb)" | 'a kind gesture' önceki turda silinen ikinci anlam (tarama) |
| reaction.n.1 | quiz.cloze | "When I told him I was moving abroad, his first ______ was silence." → "The audience's ______ to the new film was mixed: some loved it, others hated it." | başka bir kartta neredeyse aynı cümle vardı (react quiz: 'when you told them you were moving abroad') (tarama) |
| rumor.n.1 | l1.tr.alt | "[dedikodu, rivayet]" → "[rivayet]" | 'dedikodu' notun ayırdığı 'gossip' (tarama) |
| weakness.n.1 | grammar.pattern | "strengths and weaknesses; a weakness for sth" → "strengths and weaknesses; sb's biggest weakness" | 'a weakness for sth' (zaaf) başka anlam (notta var) (tarama) |
| weakness.n.1 | collocations | "[strengths and weaknesses, biggest weakness, a weakness for sth]" → "[strengths and weaknesses, biggest weakness, a major weakness]" | 'a weakness for sth' başka anlam (tarama) |
| convince.v.1 | def.long | silinen cümle: "In American English it can also mean to get someone to do something." | def.long ikinci bir anlama kayıyordu; o cümle silindi (bulgu) |
| convince.v.1 | l1.tr.note | "'Convince someone that…' (birini …e ikna etmek) ve 'be convinced' (ikna olmak) kalıpları yaygındır." → "'Convince someone that…' (birini …e ikna etmek) ve 'be convinced' (ikna olmak) kalıpları yaygındır. 'Convince sb to do sth' (birini bir şey…" | Silinen kullanım nota, yalnız Amerikan diye etiketlenmeden taşındı (bulgu) |
| sympathize.v.1 | examples[2] | "I sympathize with your problem, but I can't change the rules. / Derdinizi anlıyorum ama kuralları değiştiremem." → "I sympathize with your situation, but I can't change the rules. / Durumunuzu anlıyorum ama kuralları değiştiremem." | 'sympathize with your problem' doğal değil (bulgu) |
| sympathize.v.1 | l1.tr.gloss | "halinden anlamak" → "hâlinden anlamak" | TDK yazımı: hâl / dâhil (şapka düşmüştü) (tarama) |
| sympathize.v.1 | examples.0.tr | "Halinden çok iyi anlıyorum." → "Hâlinden çok iyi anlıyorum." | TDK yazımı: hâl / dâhil (şapka düşmüştü) (tarama) |
| sympathize.v.1 | examples.1.tr | "Ece'nin uçuşu iptal edilince hepimiz onun halinden anladık." → "Ece'nin uçuşu iptal edilince hepimiz onun hâlinden anladık." | TDK yazımı: hâl / dâhil (şapka düşmüştü) (tarama) |
| direct.adj.1 | l1.tr.alt | "[dobra, doğrudan]" → "[dobra]" | 'doğrudan' notun ayırdığı 'direkt, hemen' anlamı (tarama) |

- Çeldirici: `s28: 60 quizzes, 148 distinct distractors; top: loyalty×4, praise×4, patience×3, rumor×3, apology×3, grumpy×3` (sınır max(4, %5) = 4).
- Doğrulayıcı (son satır): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
