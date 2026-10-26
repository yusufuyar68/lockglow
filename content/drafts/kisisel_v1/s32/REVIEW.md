# s32 QA incelemesi (B2 phrasal verb'ler, eşdizimler ve deyimler)

Kapsam: `content/drafts/kisisel_v1/s32/part_01.json` … `part_05.json` (60 kart, part başına 12). Konu: B2 öğrencinin işte, haberde ve günlük konuşmada sık duyduğu phrasal verb'ler (28), eşdizimler (18), kalıp ifadeler (6) ve deyimler (8). Seviye: hepsi B2 (`editorial_estimate`).

Süreç (`docs/icerik_uretimi/README.md`):

1. **Yazım:** bir yazar ajanı, `1_yazar_kurallari.md`, s22 biçimi.
2. **Denetim:** bir denetçi ajanı (bu rapor), `2_denetci_kurallari.md`. 60 kart tek tek okundu: anlam, tanım, örnek, geri çeviri, gloss ve gloss_short, hata maddeleri, quiz'de her şık boşluğa konarak tek doğru cevap, IPA, seviye. Yazarın "emin olmadığım" maddeleri ayrıca tartıldı (aşağıda).

## Özet

- İncelenen kart: **60** (B2: 60). Tür: 28 phrasal verb, 18 eşdizim (`collocation`), 6 kalıp (`phrase`), 8 deyim (`idiom`).
- `primary_topic`: `phrasal_verbs` 28, `collocations` 24, `idioms_expressions` 8.
- Değişen kart: **13** (`critic_edited`), 17 alan.
- Reddedilen kart (`critic_reject`): **0**. Etimoloji: hepsi `null`. Sahte dost yok. `sensitivity`: hepsi 0.
- **Kilit ekranı anlamı:** 60 kartın hepsinde ≤16 karakter (17 kartta `gloss_short`).
- **confusables:** 39 kartta.
- **mistakes:** 12 kartta 13 madde (yazarın 14 maddesinden 1'i silindi).
- **Çeldirici:** 144 farklı şık; en sık run out of ×4, make ×4 (sınır 4).
- **IPA:** DRESS 11/11 `/ɛ/`, `/e/` yok.
- Doğrulayıcı (`--strict`): `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`.

## Genel bulgular

- **En sık 3 sorun:**
  1. **Quiz'de sınırda ikinci okuma.** fall through "went off" ("the deal went off" = gerçekleşti okunabilir), out of the question "order" (İngiliz İngilizcesinde "out of order" = kabul edilemez), make a fuss "deal" ("make such a deal about it" "big deal" ile karışıyor), have a go "take" (Amerikan konuşmasında "take a go at it" duyuluyor), make an effort "give" ("give an effort" Amerikan spor dilinde var), run a business "lead" ("lead a company" doğru İngilizce). Hepsi açıkça yanlış şıklarla değişti.
  2. **Kilit ekranında tek başına yanlış okunan Türkçe.** take advantage of kısa anlamı "değerlendirmek", kartın uyardığı "evaluate" çevirisinin ta kendisiydi; look back on "dönüp bakmak" geçmiş anlamını kaybediyordu.
  3. **Uydurma ya da şaka sayılabilecek hata maddesi.** fall through "Our plans fell into the water" s22'de silinen "throw an eye on" gibi bir "Tarzanca" esprisi; öğrencinin gerçekten ürettiği kanıtlanamıyor, silindi.
- Quiz'lerin geri kalanı tek cevaplı bulundu. Örneğin give in'de "gave up" çıkarılmış, run through'da "go through" şık değil, settle down'da "calmed down" şık değil.
- Örneklerin İngilizcesi doğal; Amerikan yazımı tutarlı (closet, highway, vacation, canceled, neighbors).

## Yazarın "emin olmadığım" maddeleri

1. **Kısa anlamlar.**
   - **live up to:** "beklentilere layık olmak / layık olmak" kaldı. "beklentiyi karşılamak" 16'yı aşıyor ve kısaltması anlamı kaybettiriyor. İlk örneğin çevirisi düzeltildi (aşağıda).
   - **spill the beans:** "baklayı ağzından çıkarmak / baklayı çıkarmak" kaldı. "ağzından kaçırmak" 17 karakter, sığmıyor; `alt`'ta ve iki örnekte görünüyor.
   - **at short notice:** ana anlam "son anda haber verilerek" yapıldı. Böylece haberi alan taraf da kapsanıyor ("Thanks for coming at such short notice"). Kısa anlam "son anda" kaldı.
2. **Hata maddeleri.**
   - **bring forward** "took the meeting forward": "öne almak"taki "almak" ofis İngilizcesinde gerçekten "take" olarak çıkıyor; kaldı.
   - **speed up** "fasten the process": Türk öğrencilerde sık görülen gerçek bir hata, kaldı. `why`, "shorten/widen" benzetmesiyle yeniden yazıldı.
   - **make a difference** "create a difference": "fark yaratmak" çevirisi Türk yazılarında sık; kaldı.
   - **fall through** "fell into the water": silindi.
3. **Tek doğru cevap.**
   - **give in:** doğru (gave up yok).
   - **set an example:** "give" kaldı. "by arriving on time" davranışı gösteriyor; "give an example" açıklarken örnek vermek demek. Hedeflenen tuzak tam bu, notta da anlatılıyor.
   - **make out:** "make up" kaldı. "So dark that I couldn't make up the number" anlamsız; hedeflenen biçim tuzağı.
4. **İngiliz lemmaları.** at short notice ve have a go aynen kaldı. İkisi de Amerikan dizilerinde de anlaşılır; notlar Amerikan karşılığını veriyor.
5. **IPA ve not.**
   - **the ball is in your court:** tek vurgulu US IPA kabul edildi (s22'de "not the end of the world" istisnası gibi).
   - **make out:** argodaki "öpüşmek" uyarısı kaldı. B2 öğrenci dizide bu anlamla karşılaşacak; uyarı yanlış anlamayı önlüyor. Kart `sensitivity: 0` kaldı, çünkü kartın anlamı ve örnekleri görme ve duymayla ilgili.

## Değişiklik tablosu

#### part_01
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| fall through | l1.tr.mistakes | "Our plans fell into the water." → [] | "Planlar suya düştü"nün kelime kelime çevirisi bir şaka kalıbı; öğrencinin gerçekten ürettiği kanıtlanamıyor (s22'de "throw an eye on" da aynı nedenle silindi). |
| fall through | quiz.distractors | went off → fell out | "The deal went off" (gerçekleşti) okunabiliyordu; "the deal fell out" olmuyor ve aynı fiil ailesinden bir tuzak. |
| look back on | l1.tr.gloss_short | "dönüp bakmak" → "geçmişe bakmak" | Tek başına "arkaya dönüp bakmak" gibi okunuyordu; geçmiş anlamı korunsun. |

#### part_02
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| live up to | examples[0].tr | "Film, bu kadar övülmeye layık değildi." → "Film, övüldüğü kadar iyi değildi." | Geri çeviri "didn't deserve so much praise" çıkıyordu; "the hype" ile kıyas kaybolmuştu. |
| speed up | l1.tr.mistakes[0].why | "'fast' kelimesinden türemiş gibi…" → "'Shorten', 'widen' gibi kelimelere bakılıp 'fasten' hızlandırmak sanılıyor…" | Hatanın asıl nedeni olan "-en" ekiyle benzetme açıkça söylensin. |

#### part_03
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| wind down | l1.tr.note | "…rüzgâr anlamındaki 'wind' gibi okunmaz… 'Wind up' ise sonunda bir yere düşmek…" → "…rüzgâr anlamındaki 'wind' /wɪnd/ gibi okunmaz… 'Wind up' ise sonunda kendini bir yerde bulmak…" | "Bir yere düşmek" Türkçede doğal değil ve yanlış anlamı çağrıştırıyor; okunuş farkı da gösterildi. |
| make an effort | quiz.distractors | give → keep | "give an effort" Amerikan konuşma dilinde duyuluyor; "keep an effort" açıkça yanlış. |
| make a fuss | quiz.distractors | deal → worry | "make such a deal about it" "big deal" ile ikinci okuma veriyordu; "make such a worry" olmuyor. |
| take advantage of | l1.tr.gloss | "(fırsatı) değerlendirmek" → "(fırsattan) yararlanmak" | Kısa anlam "değerlendirmek" tek başına "evaluate" okunuyordu; kartın hata maddesi tam bu karışıklığı anlatıyor. |
| take advantage of | l1.tr.gloss_short | "değerlendirmek" → "yararlanmak" | Aynı neden; yeni ana anlamın kısaltması. |
| take advantage of | l1.tr.alt | [fırsattan yararlanmak, fırsat bilmek, kullanmak] → [fırsatı değerlendirmek, fırsat bilmek, kullanmak] | Eski ana anlam `alt`'a geçti. |

#### part_04
| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| lose touch | examples[2].tr | "Bağlantıyı koparma! …" → "Sakın kaybolma! …" | "Bağlantıyı koparmak" kasten ilişkiyi kesmek gibi okunuyordu; vedalaşırken doğal söz "sakın kaybolma". |
| run a business | quiz.distractors | lead → do | "lead a small bakery" anlam olarak olabiliyordu. |
| have a go | quiz.distractors | take → try | "take a go" Amerikan konuşmasında duyuluyor; "try a go" açıkça yanlış. |
| out of the question | quiz.distractors | order → way | "out of order" İngiliz İngilizcesinde "kabul edilemez" demek; ikinci okuma veriyordu. |
| at short notice | l1.tr.gloss | "son anda haber vererek" → "son anda haber verilerek" | Edilgen biçim, haberi alan tarafı da kapsıyor ("canceled at short notice", "thanks for coming at such short notice"). |

#### part_05
Değişiklik yok. Bütün quiz'ler denendi. just in case'teki "time" şıkkı ("just in time") güçlü bir tuzak, ama "I'll take my umbrella just in time" bağlamda anlamsız; kaldı. the last straw'daki "drop", kartın hata maddesiyle aynı gerçek hata; kaldı.

## Seviye (B2 dışında olabilecekler; kartlar silinmedi, seviye değiştirilmedi)

- **Daha çok B1:** stand for, pass on, hand over, speed up, wear out, make an effort, take place, take a risk, keep a promise, take it easy, under pressure, just in case. Bunlar Cambridge/EVP listelerinde genelde B1'de geçiyor. B2 destesinde tekrar olarak zararsız; istenirse B1'e çekilebilir (`primary_topic` aralığı B1'i de kapsıyor mu, önce bakılmalı).
- **C1'e yakın:** face up to, fall through. Haber dilinde sık oldukları için B2'de kaldılar.

## Anadili Türkçe birinin bakması gerekenler

1. **Hata maddelerinin sıklığı:** "We took the meeting forward", "create a difference", "fasten the process", "I couldn't hold my tears", "You need to face with the problem", "That was the last drop".
2. **Kilit ekranı karşılıkları:**
   - live up to "layık olmak": tek başına "hak etmek" gibi okunuyor mu?
   - spill the beans "baklayı çıkarmak": kesik bir deyim gibi duruyor mu?
   - at short notice "son anda".
   - put through "bağlamak": tek başına "ip bağlamak" gibi okunuyor mu?
   - make out "zorlukla seçmek": "choose" gibi okunuyor mu?
   - take advantage of "yararlanmak" (yeni).
   - look back on "geçmişe bakmak" (yeni).
3. **Örnek çevirileri:**
   - take in "Kavranamayacak kadar çok şey vardı." doğal mı?
   - give in "uykuya yenik düştü" uygun mu?
   - lose touch "Sakın kaybolma!" uygun mu?
4. **make out notu:** argodaki "öpüşmek" anlamı nota yazılmalı mı?

## Çeldirici ve IPA son kontrolü (2026-10-26)

- `distractor_stats.py`: s32 → 60 quiz, 144 farklı çeldirici; en sık: run out of×4, make×4, put off×3, look up to×3, get rid of×3, do×3. Sınır max(4, %5) = 4; aşan yok, değişiklik gerekmedi. 60 quiz tek tek okundu; her soruda tek doğru cevap var.
- `ipa_dress_stats.py`: s32 → uk_e 0, uk_ɛ 11, us_e 0, us_ɛ 11. DRESS ünlüsü her yerde /ɛ/; düzeltme gerekmedi.
- `dump_lemmas.py`: s32'deki 60 başlık sözcüğünün hiçbiri başka akışta yok.

## Son doğrulama

`python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/s32` → `60 kart · 60 şemadan geçti · 0 hata · 0 uyarı`
