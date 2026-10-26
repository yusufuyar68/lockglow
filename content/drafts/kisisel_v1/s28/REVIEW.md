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
