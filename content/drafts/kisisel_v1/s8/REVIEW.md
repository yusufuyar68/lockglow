# s8 QA incelemesi (günlük kalıp ifadeler)

Kapsam: `content/drafts/kisisel_v1/s8/part_01.json` ... `part_06.json`. Bakılan kriterler: `SYSTEM_C` listesi (anlam, tanım, örnek, Türkçe karşılık, Türkçe çeviri, IPA, seviye, hata, not, etimoloji, quiz) ve koordinatörün ek maddesi (quiz çeldiricileri aynı işlevde olsun, ama tek doğru cevap kuralı önce gelir).

Yöntem: 54 kartın her biri tek tek okundu. Her kartta her şık boşluğa yerleştirilip denendi (54 quiz, 216 şık). Türkçe çeviriler İngilizceye geri çevrilip karşılaştırıldı.

## Özet

- İncelenen kart: **54**
- Değişen kart: **34** (hepsine `critic_edited` eklendi)
- Toplam düzenleme (alan sayısı): **56**
- Reddedilen kart (`critic_reject`): **0**
- Doğrulayıcı (tüm klasör, `--strict`): `54 kart · 54 şemadan geçti · 0 hata · 0 uyarı`

## Yazarın şüpheleri: kararlar

1. **`no problem` ("Not problem.")**: Türkçe konuşanlara özgü ve yaygın bir hata olarak doğrulanamadı. 'değil' = not açıklaması makul bir mekanizma gibi duruyor ama kanıtı yok; hata listesi boşaltıldı. **`get ready` ("I'm getting ready dinner.")**: bu da uydurma sayıldı. Öğrenciler 'get ready'yi bir nesneyle kullanmaz; gerçek sorun 'kendini hazırlamak' ile 'bir şeyi hazırlamak' ayrımı ve bunu not zaten anlatıyor. İkisi de silindi, yerine bir şey konmadı (doğrulanmamış hata eklemek yerine boş liste).
2. **`on purpose` ("in purpose")**: 'in purpose' için kanıt yok. Hata türü gerçek (edat tahmini, çünkü 'kasten' sözünde edat yok) ama en olası biçim, aynı akıştaki `by mistake` kalıbından türeyen 'by purpose'. Hata 'by purpose' ile değiştirildi, açıklama yeniden yazıldı. Yine de anadil kontrolü için listede (aşağıda).
3. **`sounds good`, `go ahead`, `a lot of`**: Üçünün de gloss'u makul ve `equivalence: partial` doğru. `sounds good` için 'olur, güzel fikir' kabul edildi; 'olur' tek başına en yaygın karşılık, 'güzel fikir' anlamı tamamlıyor. `go ahead` için 'buyur' izin verme anlamında en yaygın karşılık ('devam et' ve 'başla' alt'ta). `a lot of` için 'çok' doğru; 'çok' aynı zamanda very/much/many olduğu için `partial` kalmalı (full değil). Değişmedi. Yalnızca `go ahead` 3. örnek çevirisinde 'go ahead' karşılığı kaybolmuştu, düzeltildi.
4. **IPA zayıf biçimler**: Akış büyük ölçüde tutarlı (a, of, to, for, from, your = zayıf; at, in, on, by = güçlü, sözlük yazımıyla uyumlu). `for a while` (/fər ə/), `from time to time` (/frəm/), `a lot of` (/ə ˈlɑːt əv/) doğru. Tek tutarsızlık `as soon as` ve `as well` kartlarında 'as' güçlü (/æz/) yazılmıştı; sözlüklerde ve konuşmada zayıf (/əz/). İki kart zayıf biçime çevrildi. Ayrıca `pay attention` UK IPA'sında /e/ vardı; akışın geri kalanı /ɛ/ kullandığı için /ɛ/ yapıldı.
5. **`take care`**: Kart yalnızca veda anlamını anlatıyor, bu doğru. Ancak alt listesindeki 'dikkat et' A2 öğrenciyi 'Take care!' = uyarı sanmaya götürürdü (uyarı için 'Be careful!' denir). 'dikkat et' alt'tan çıkarıldı, nota 'Be careful!' ayrımı eklendi.
6. **A1 kalıp ifadelerin `primary_topic` seçimi**: `social_skills` ve `love_friendship` A2'den başladığı için A1 kartlar o kategoriye konamaz (doğrulayıcı uyarı verir). Seçimler en az kötü seçenekler: `no problem`, `of course`, `good luck` = emotions_feelings; `have fun` = hobbies_sports; `excuse me`, `in front of`, `next to` = cities_transport (yön sorma bağlamı); `see you later` = time_routines; `a lot of` = shopping_money. En zayıfı `a lot of` (miktar sözcüğüne uygun A1 kategori yok) ve `of course` (emotions_feelings). Değişmedi; `topics` listesinde `social_skills` kaldığı için kartlar o kategoride de aranabilir. Öneri: taksonomide `social_skills` alt seviyesi A1 yapılırsa bu kartların asıl kategorisi doğru olur (bu klasörün dışında).

## Genel bulgular

- Kartların çoğu iyi: ilk örnekler kısa ve kilit ekranına güvenli, Türkçe çeviriler büyük ölçüde doğal ve sadık, etimoloji alanı hep `null` (kalıp ifade), sahte dost hiçbirinde yok (doğru). Seviyeler makul; değiştirilen yok. Notlarda 'freezer' dır türü ayrı yazılmış ek bulunmadı.
- **En sık 3 sorun:**
  1. **Quiz çeldiricileri alakasız, cümlede nesnesiz ya da doğru sayılabilir** (13 kart). 'On foot / Next to / In front of' gibi şıklar cümleye hiç uymuyordu, soru bir şey sınamıyordu. Aynı işlevde ve açıkça yanlış olan şıklarla değiştirildi. Bir kartta (`come on`) çeldiricilerden biri ('At last') doğru da sayılabiliyordu; kaldırıldı.
  2. **Tanımlarda başlık kelimesi ya da ailesi** (9 kart; `time`, `times`, `way`, `have`, `see`, `lose`, `better`) ve **'talk' kullanımı** (3 kart; İngilizcede 'in a talk' konuşma/sunum demektir, sohbet için 'conversation').
  3. **Hata (mistakes) listesinde zayıf ya da yanlış açıklama** (10 düzenleme): iki hata silindi (`no problem`, `get ready`), biri değiştirildi (`on purpose`), altısında `why` Türkçenin nasıl yanılttığını yanlış ya da belirsiz anlatıyordu (`as soon as`, `in the end`, `take a photo`, `take a seat`, `get lost`, `next to`).
- Diğer düzeltmeler: bir örnek çevirisi in time / on time karışıklığını geri getiriyordu (`in time`), bir örnek kartın kendi notuyla çelişiyordu (`pay attention`: uyarı için 'Be careful!' denir), iki collocations alanında kalıp olmayan cümle parçaları vardı (`at last`, `get lost`), `as well` collocations'ında farklı bir kalıp ('as well as') vardı, `by mistake` alt'ında gerçek karşılık olmayan bir sözcük vardı.
- Hata türü incelenip gerçek bulunan mistakes (bazılarında yalnızca `why` düzeltildi, yukarıda): it depends (on eksik), how about (to + fiil), on time (in time), in time (on time), in a hurry (have; a eksik), on the way (to home), take a break (give), have fun (a fun), good luck (lucks), as well (olumsuzda), in the end (at the end), make a decision (give), make a mistake (do), take a seat (sit/seat), get better (more good), catch a cold (take), change your mind (idea), see you later (after), all the time (every time), how often (how long), a lot of (of eksik; a eksik), a few (few), in front of (opposite), on foot (by foot), sounds good (well), pay attention (to eksik), take a photo (make). Hepsi Türkçe konuşanlar için makul ve gerçek hata kalıpları.

## Değişiklik tablosu

Alan adları kartın JSON yoludur. `l1.tr` = Türkçe katman.

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.by_the_way.phr.1 | def.short | used in a talk to add something new or something you just remembered → used to add something new or something you just remembered | 'in a talk' (konuşma/sunum anlamı) doğal değil; ifade çıkarıldı. |
| en.by_the_way.phr.1 | def.long | People say this in a talk to add a new point, often something small that they just remembered. The new point is usually not the main topic. → People say this to add a new point, often something small that they just remembered. The new point is usually not the main topic. | 'in a talk' doğal İngilizce değil; kaldırıldı. |
| en.by_the_way.phr.1 | quiz.distractors | ["On foot", "Next to", "In front of"] → ["For example", "Of course", "At last"] | 'On foot / Next to / In front of' cümle başına hiç uymuyordu, soru bir şey sınamıyordu. Aynı işlevde (cümle başı söylem ifadeleri) ve cümlede açıkça yanlış çeldiriciler. |
| en.no_problem.phr.1 | l1.tr.mistakes | [{"wrong": "Not problem.", "right": "No problem.", "why": "Türkçede 'sorun değil' derken 'değil' sözünü 'not' diye çevirmek kolaydır. İngilizcede 'hiç sorun yok' diye düşün: no problem."}] → [] | 'Not problem.' Türkçeye özgü ve yaygın bir hata olarak doğrulanamadı ('değil' = not açıklaması zorlama). Uydurma hata kötü karttan kötüdür; silindi. |
| en.of_course.phr.1 | quiz.distractors | ["Have fun", "Excuse me", "On time"] → ["Have fun", "Excuse me", "Good luck"] | 'On time' cümle başında anlamsızdı ve diğer çeldiricilerle aynı işlevde değildi; kalıp ifade çeldiricisi ile değiştirildi. |
| en.what_about.phr.1 | def.long | You use this to ask about another person or thing in a talk, often to keep the talk going. You can also use it to remind people of something they forgot. → You use this to ask about another person or thing in a conversation, often to keep it going. You can also use it to remind people of something they forgot. | 'talk' (konuşma/sunum) yerine 'conversation'; 'keep the talk going' doğal değil. |
| en.on_time.phr.1 | def.micro | at the planned time → when it was planned | 'time' başlık kelimeden geliyordu (döngüsel tanım). |
| en.on_time.phr.1 | def.short | not late and not early; at the exact time that was planned → not late; at the moment that was planned | 'not early' yanlış: erken gelmek de 'on time' sayılır. 'time' kullanılmadı. |
| en.on_time.phr.1 | def.long | Not late: at the time that was agreed or planned. A bus, a train or a person can come at this time, and you can finish your work at this time too. → Not late: when it was agreed or planned. A bus, a train or a person can arrive on time, and you can finish your work on time too. | İlk cümlede başlık kelime 'time' kullanılıyordu; 'come at this time' de garipti. |
| en.in_time.phr.1 | def.short | not too late for something; with enough time to do it or catch it → not too late for something; early enough to catch it or do it | 'with enough time' başlık kelime 'time' içeriyordu. |
| en.in_time.phr.1 | examples[2].tr | Doktor çocuğa yardım etmek için zamanında geldi. → Doktor zamanında yetişip çocuğa yardım edebildi. | Eski çeviri ('zamanında geldi') İngilizceye geri çevrilince 'on time' çıkıyordu; kartın tam da uyardığı in time / on time karışıklığı. 'Yetişip ... edebildi' doğru anlamı verir. |
| en.in_time.phr.1 | quiz.distractors | ["out of order", "by the way", "in front of"] → ["out of order", "by the way", "at last"] | 'in front of' çeldiricisi cümlede nesnesiz kalıyordu ('...station in front of to catch'); dilbilgisiyle elenirdi. |
| en.at_last.phr.1 | collocations | ["at last, it's here"] → ["at long last"] | 'at last, it's here' bir kalıp değil cümle parçası; 'at long last' gerçek bir eşdizimlilik. |
| en.at_last.phr.1 | quiz.distractors | ["On purpose", "On foot", "Out of order"] → ["On purpose", "For example", "As well"] | 'On foot / Out of order' alakasızdı; cümle başı zarf/bağlaç işlevinde ve açıkça yanlış çeldiriciler. ('At least' ve 'By the way' bu cümleye uyabildiği için kullanılmadı.) |
| en.at_the_moment.phr.1 | quiz.distractors | ["on foot", "in front of", "next to"] → ["in time", "on foot", "out of order"] | 'in front of' ve 'next to' cümle sonunda nesnesiz kalıyordu; dilbilgisiyle elenirdi. |
| en.for_a_while.phr.1 | quiz.distractors | ["on foot", "out of order", "in front of"] → ["on foot", "out of order", "by mistake"] | 'in front of' nesnesiz kalıyordu. |
| en.take_care.phr.1 | def.long | People say this at the end of a talk or a message when someone goes away. It shows you like the person and want them to stay safe and well. → People say this at the end of a conversation or a message when someone goes away. It shows you like the person and want them to stay safe and well. | 'at the end of a talk' (konuşma/sunum) doğal değil; 'conversation'. |
| en.take_care.phr.1 | l1.tr.alt | ["kendine dikkat et", "dikkat et"] → ["kendine dikkat et"] | 'dikkat et' alt'ı A2 öğrenciyi uyarı anlamına ('Take care!' = 'Dikkat!') yöneltir; kart yalnızca veda anlamı. Kaldırıldı. |
| en.take_care.phr.1 | l1.tr.note | Vedalaşırken söylenir ve mesajın sonuna da yazılır. 'Take care of' ise 'bakmak, ilgilenmek' demektir: 'take care of a baby'. → Vedalaşırken söylenir, mesajın sonuna da yazılır. 'Dikkat et!' diye uyarmak için 'Be careful!' denir. 'Take care of' ise 'bakmak, ilgilenmek' demektir: 'take care of a baby'. | Veda anlamı ile 'dikkat et' (uyarı) anlamının karışmaması için 'Be careful!' notu eklendi. |
| en.take_a_break.phr.1 | quiz.distractors | ["make a mistake", "get lost", "pay attention"] → ["make a mistake", "catch a cold", "pay attention"] | 'get lost' ("Let's get lost" = gidelim) argo olarak söylenebiliyor; tamamen açık yanlış olanla değiştirildi. |
| en.have_fun.phr.1 | def.long | To enjoy what you are doing and have a good, happy time. People also say it to wish someone a good time, as in 'Have fun!'. → To enjoy an activity and feel happy while you do it. People also say it to wish someone a good time, as in 'Have fun!'. | İlk cümlede başlık kelime 'have' kullanılıyordu. |
| en.go_ahead.phr.1 | examples[2].tr | Hazırız, başlayabilirsin Kenji. → Hazırız, buyur başlayabilirsin Kenji. | Çeviride 'go ahead' karşılığı (buyur) kayboluyordu; kart kelimesi görünmeli. |
| en.come_on.phr.1 | quiz.distractors | ["Take care", "At last", "Good luck"] → ["Take care", "Good luck", "Have fun"] | 'At last' ('Sonunda Mehmet! Otobüs beş dakikaya kalkıyor!') Mehmet geç geldiğinde doğal bir cümle olurdu; tek doğru cevap için kaldırıldı. |
| en.no_way.phr.1 | def.short | used to say no in a very strong way, or to say something is impossible → used to say no very strongly, or to say something is impossible | Tanımda başlık kelime 'way' kullanılıyordu. |
| en.as_soon_as.phr.1 | ipa.us | /æz ˈsuːn æz/ → /əz ˈsuːn əz/ | Akıcı konuşmada ve sözlüklerde 'as' zayıf biçimdedir; akışın geri kalanı (of, a, to, for, from) zayıf biçim kullanıyor. |
| en.as_soon_as.phr.1 | ipa.uk | /æz ˈsuːn æz/ → /əz ˈsuːn əz/ | Aynı gerekçe. |
| en.as_soon_as.phr.1 | l1.tr.mistakes[0].why | Türkçede 'varacağım zaman' gibi gelecek ekiyle de söyleyebiliriz, bu yüzden 'will' eklenir. 'As soon as' ifadesinden sonra gelecek için bile geniş zaman gelir: I arrive. → İş gelecekte olacağı için 'will' eklenir. Oysa 'as soon as' ve 'when' gibi bağlaçlardan sonra gelecek için bile geniş zaman kullanılır: I arrive. | Eski açıklama ('Türkçede gelecek ekiyle de söyleriz') Türkçenin neden yanılttığını doğru anlatmıyordu; hata dile özgü değil, genel bir öğrenci hatası. |
| en.as_well.phr.1 | ipa.us | /æz ˈwɛl/ → /əz ˈwɛl/ | Zayıf 'as' (tutarlılık). |
| en.as_well.phr.1 | ipa.uk | /æz ˈwɛl/ → /əz ˈwɛl/ | Zayıf 'as' (tutarlılık). |
| en.as_well.phr.1 | collocations | ["as well as", "me as well"] → ["me as well", "you as well"] | 'as well as' ayrı bir bağlaçtır ('ve, ayrıca'); 'as well' ile aynı kalıp gibi görünmesi yanıltıcı. |
| en.in_the_end.phr.1 | l1.tr.mistakes[1].why | 'Of' ile birlikte 'at the end' kullanılır. 'In the end' tek başına sonuç anlatır, bir şeyin sonu için kullanılmaz. → Türkçede 'filmin sonunda' deriz; İngilizcede bu 'at the end of the film' olur. 'In the end' ise sonucu anlatır, bir şeyin son kısmı için kullanılmaz. | Eski açıklama Türkçenin nasıl yanılttığını söylemiyordu. |
| en.in_the_end.phr.1 | quiz.distractors | ["on time", "on foot", "out of order"] → ["by the way", "for example", "as well"] | 'on time / on foot / out of order' alakasızdı; cümle başı bağlayıcı işlevinde ve açıkça yanlış çeldiriciler ('at last' ve 'finally' uyabildiği için kullanılmadı). |
| en.on_purpose.phr.1 | l1.tr.mistakes[0].wrong | She did it in purpose. → She did it by purpose. | 'in purpose' yaygın bir Türkçe hatası olarak doğrulanamadı. 'By mistake' kalıbından türetilen 'by purpose' daha olası hata; aynı akışta 'by mistake' kartı da var. |
| en.on_purpose.phr.1 | l1.tr.mistakes[0].why | Türkçede 'kasten' sözünde edat yoktur, bu yüzden 'in/by/with' diye tahmin edilir. Bu kalıpta 'on' kullanılır: on purpose. → Türkçede 'kasten' sözünde edat yoktur, bu yüzden edat tahmin edilir. 'By mistake' (yanlışlıkla) örneğinden 'by purpose' denir; oysa kalıp 'on purpose'. | Yeni hataya uygun açıklama. |
| en.by_mistake.phr.1 | l1.tr.alt | ["kazara", "dalgınlıkla"] → ["kazara", "istemeden"] | 'dalgınlıkla' = absent-mindedly; 'by mistake' karşılığı değil. 'istemeden' (without meaning to) tanıma uyar. |
| en.out_of_order.phr.1 | quiz.distractors | ["on time", "on foot", "in front of"] → ["on time", "on foot", "in a hurry"] | 'in front of' cümle sonunda nesnesiz kalıyordu. |
| en.pay_attention.phr.1 | examples[1].en | Pay attention, Mehmet! The road is very busy. → Pay attention, Mehmet! I am explaining something important. | Eski örnek ('Pay attention! The road is very busy.') uyarı olarak anadili konuşurun 'Be careful!' diyeceği bir durumdu ve kartın kendi notuyla çelişiyordu. |
| en.pay_attention.phr.1 | examples[1].tr | Dikkat et Mehmet! Yol çok yoğun. → Dikkatini ver Mehmet! Önemli bir şey anlatıyorum. | Yeni İngilizce cümleye uygun çeviri. |
| en.pay_attention.phr.1 | ipa.uk | /peɪ əˈtenʃən/ → /peɪ əˈtɛnʃən/ | Akışta UK IPA hep /ɛ/ ile yazılıyor; /e/ tutarsızdı. |
| en.take_a_photo.phr.1 | l1.tr.mistakes[0].why | Türkçede kelimesi kelimesine çevirmeye çalışıp 'make' ya da 'do' denir. İngilizcede fotoğraf için 'take' kullanılır: take a photo. → Türkçedeki 'çekmek' hiçbir İngilizce fiille birebir örtüşmez; bu yüzden tanıdık 'make' ya da 'do' seçilir. İngilizcede fotoğraf için 'take' kullanılır. | Eski açıklama belirsizdi ('kelimesi kelimesine çevirmeye çalışıp'). |
| en.take_a_seat.phr.1 | l1.tr.mistakes[0].why | Türkçede kısa 'i' ile uzun 'ii' ayrımı olmadığı için 'sit' (oturmak) ve 'seat' (koltuk, yer) karışır. Doğrusu: take a seat. → Türkçede kısa ve uzun 'i' ayrımı olmadığı için 'sit' (oturmak) ve 'seat' (koltuk, yer) karışır. Doğrusu: take a seat. | 'ii' yazımı anlaşılmazdı. |
| en.get_ready.phr.1 | l1.tr.mistakes | [{"wrong": "I'm getting ready dinner.", "right": "I'm making dinner.", "why": "Türkçede 'yemeği hazırlıyorum' ve 'hazırlanıyorum' birbirine benzer. 'Get ready' kendini hazırlamaktır; yemek için 'make' ya da 'prepare' kullanılır."}] → [] | 'I'm getting ready dinner.' Türkçe konuşanların yaygın hatası olarak doğrulanamadı; zorlama. 'Get ready' (kendini hazırlamak) ile 'prepare' (bir şeyi hazırlamak) ayrımını not zaten anlatıyor. |
| en.get_lost.phr.1 | def.micro | lose your way → not know where you are | 'lose' (lost'un kökü) başlık kelime ailesinden. |
| en.get_lost.phr.1 | l1.tr.mistakes[0].why | Türkçede 'kayboldum' tek bir sözcüktür. İngilizcede 'lost' tek başına fiil değildir; önüne 'got' ya da 'am' gelir: I got lost. → Türkçede 'kayboldum' tek sözcüktür, bu yüzden 'I lost' denir. Ama 'I lost' 'bir şeyi kaybettim' demektir. Kaybolmak için 'I got lost' ya da 'I am lost' denir. | Eski açıklama yanlıştı: 'lost' fiil olabilir (I lost my keys); sorun, anlamın değişmesi. |
| en.get_lost.phr.1 | collocations | ["get lost in", "easy to get lost"] → ["get lost in"] | 'easy to get lost' bir eşdizimlilik değil, serbest bir cümle parçası. |
| en.get_better.phr.1 | def.micro | become better than before → improve or feel well again | 'better' başlık kelimeydi (döngüsel). |
| en.get_better.phr.1 | def.long | To become better than before. You can say it about a person who was ill and feels well again, or about a skill, a situation or the weather. → To improve, or to feel well again after being ill. People say it about a person, a skill, a situation or the weather. | İlk cümlede 'better' kullanılıyordu. |
| en.see_you_later.phr.1 | def.long | A friendly way to say goodbye when you plan to see or talk to the person again, maybe today or in a few days. It does not mean a fixed time. → A friendly way to say goodbye when you plan to meet or talk to the person again, maybe today or in a few days. It does not mean a fixed time. | İlk cümlede başlık kelime 'see' kullanılıyordu. |
| en.see_you_later.phr.1 | quiz.distractors | ["At least", "On time", "A lot of"] → ["Of course", "No way", "By the way"] | 'At least / On time / A lot of' alakasızdı (veda sözü yerine nicelik sözcüğü). Aynı işlevde (sohbet kalıbı) ve cümlede açıkça yanlış çeldiriciler. 'Take care' ve 'Good luck' veda gibi okunabildiği için kullanılmadı. |
| en.from_time_to_time.phr.1 | def.long | Used for things that happen a few times, not often and not on a fixed day. It is about the same as 'sometimes', but a little more formal. → Used for things that happen sometimes, but not often and not on a fixed day. It is about the same as 'sometimes'. You can use it in speaking and in writing. | İlk cümlede 'times' (başlık kelime ailesi) vardı; 'biraz daha resmî' iddiası da abartılıydı. |
| en.all_the_time.phr.1 | def.long | Used for something that happens many times, or that does not stop. It can be a good or a bad thing, and it is often used when you complain about something. → Used for something that happens again and again, or that does not stop. It can be a good or a bad thing, and it is often used when you complain about something. | İlk cümlede 'times' (başlık kelime ailesi) vardı. |
| en.a_lot_of.phr.1 | quiz.cloze | We have ______ homework today. I will study all evening. → The room is full. There are ______ people here. | Eski cümlede çeldiriciler ('next to', 'in front of') dilbilgisiyle elenirdi, 'a few' ise yalnızca 'homework' sayılamaz olduğu için yanlıştı. Yeni cümle anlamla (oda dolu) tek cevaba götürür. |
| en.a_lot_of.phr.1 | quiz.distractors | ["a few", "next to", "in front of"] → ["a few", "no", "one"] | Aynı işlevde (miktar sözcükleri), cümlede açıkça yanlış çeldiriciler. |
| en.a_few.phr.1 | quiz.distractors | ["a lot of", "next to", "in front of"] → ["a lot of", "a little", "much"] | 'next to' / 'in front of' alakasızdı; aynı işlevde (miktar sözcükleri) ve açıkça yanlış çeldiriciler. |
| en.next_to.phr.1 | l1.tr.mistakes[0].why | Türkçede 'postanenin yanında' derken ek yeter. İngilizcede ek yerine 'to' gerekir ve unutulur: next to. → Türkçede 'yanında' tek sözcüktür; bu yüzden 'next' yeter sanılır. İngilizcede ise iki sözcüktür: next to. | Eski açıklama ('ek yerine to gerekir') yanlıştı: 'yanında' bulunma durumudur, 'to' ile eşleşmez. |
| en.on_foot.phr.1 | l1.tr.note | Otobüsle gitmek 'by bus', arabayla gitmek 'by car' olur; yürüyerek gitmek ise 'on foot' olur. 'By foot' denmez. → Otobüsle gitmek 'by bus', arabayla gitmek 'by car' olur; yürüyerek gitmek ise 'on foot' olur. 'By foot' yerine 'on foot' denir. | 'By foot denmez' fazla kesindi; 'by foot' nadiren de olsa duyulur. |

## Anadili Türkçe birinin bakması gerekenler

- **en.no_problem.phr.1**: Silinen 'Not problem.' hatası Türk öğrencilerde gerçekten sık görülüyor mu? Sıksa geri eklenebilir. Ayrıca karşılık 'sorun değil': teşekkürden sonra 'bir şey değil / önemli değil / rica ederim' daha doğal olabilir; üçüncü örnekte ('Kapıyı kapatır mısın?' / 'Sorun değil.') 'Olur / Tabii' daha doğal olabilir.
- **en.get_ready.phr.1**: Silinen hata yerine gerçek bir hata varsa: 'hazırlanıyorum' (hazırlamak + kendini) yüzünden 'I prepare myself for school' diyen Türk öğrenci çok mu? Çoksa bu eklenebilir.
- **en.on_purpose.phr.1**: Yeni hata 'by purpose' ('by mistake' etkisi). Türk öğrencilerin en sık hangi edatı seçtiği (by / in / with) doğrulanmadı.
- **en.as_soon_as.phr.1**: Gloss '-ir -mez (varır varmaz)' bir ek kalıbı; widget'ta tek başına anlaşılır mı? Üç örnek de 'varır varmaz / açar açmaz' kullanıyor; 'eve varır varmaz' yerine 'eve gelir gelmez' daha doğal olabilir.
- **en.go_ahead.phr.1**: Gloss 'buyur'. 'Tabii, buyur' ve 'Buyurun' (örnek 1, 2) doğal; düzelttiğim 3. örnek 'Hazırız, buyur başlayabilirsin Kenji.' doğal mı?
- **en.sounds_good.phr.1**: 3. örnekte 'sounds good' = 'güzel olur'. Şimdiki zaman ('kulağa hoş geliyor' / 'güzel fikir gibi') daha sadık olabilir. Gloss 'olur, güzel fikir' kabul edildi.
- **en.never_mind.phr.1**: 1. örnekte özür cevabı olarak 'Boş ver. Vaktimiz var.' Bu bağlamda 'Önemli değil. Vaktimiz var.' daha doğal mı?
- **en.keep_in_touch.phr.1**: Gloss 'haberleşmek'. Günlük konuşmada 'görüşmek / görüşelim' daha yaygın olabilir; 'haberleşelim' (örnek 1) yeterince doğal mı?
- **en.a_lot_of.phr.1**: 3. örnekte 'Çok trafik vardı' doğal mı, yoksa 'Trafik çok yoğundu' mu?
- **en.take_care.phr.1**: Alt 'kendine dikkat et' veda olarak yaygın mı? ('Kendine iyi bak' gloss'u kesinlikle doğal.)
- **en.have_fun.phr.1**: 'Have a fun!' hatası Türkçeden mi geliyor, yoksa 'Have a nice day' kalıbından mı? Şimdilik 'iyi eğlenceler' (çoğul, sayılabilir 'eğlence') açıklamasıyla bırakıldı.
- **en.in_front_of.phr.1**: Tek hata cümlesi ('in front of my house, across the street') anadili İngilizce olan birine biraz yapay gelebilir; Türkçede 'karşısında' ≠ 'önünde' karışıklığı gerçek. Dokunulmadı.
- **en.in_time.phr.1**: Gloss 'yetişecek kadar erken' bir açıklama (kural: tek sözcük yoksa kısa açıklama + `partial`). 'Geç kalmadan' daha sözcük gibi mi?
- **en.get_lost.phr.1**: 'I lost in Istanbul.' (kayboldum → lost) Türk öğrencilerde yaygın mı? Yeniden yazılan açıklama doğru mu?
- **en.at_least.phr.1**: Primary topic `time_routines` (alt konu `shopping_money`). Karşılıkta 'en az' tamam; kategori tartışmalı: sayı/miktar ifadesi için daha iyi bir kategori varsa değiştirilebilir. Dokunulmadı.
- **A1 kartların kategorisi** (yukarıda 6. madde): `of course`, `a lot of` en zayıf eşleşmeler.
- **IPA**: `as soon as`, `as well` /əz/ yapıldı; `see you later` /ju/ (zayıf /jə/ da olabilir) bırakıldı. Bir IPA kaynağıyla (Cambridge) doğrulanabilir.

## Sayılar

| Ölçü | Sayı |
|---|---|
| İncelenen kart | 54 |
| Değişen kart | 34 |
| Düzenlenen alan | 56 |
| Reddedilen kart | 0 |
| Doğrulayıcı sonucu | 0 hata, 0 uyarı |

## Editör kararları (Opus, 2026-10-19)

- `en.on_purpose.phr.1`: "She did it by purpose." hatası silindi (`mistake_removed_by_editor_agent`). Türkçeden gelen bir hata olduğu doğrulanamadı; liste boş.

## Çeldirici çeşitlendirme (2026-10-19)

- Önce: 54 soru, 58 farklı çeldirici; en sık: on foot×13, at last×11, good luck×11, have fun×8, out of order×8, of course×6.
- Sonra: 54 soru, 75 farklı çeldirici; en sık: at last×4, on foot×4, out of order×4, as well×4, on time×4, well done×3. Doğrulayıcı sınırı (`QUIZ_DISTRACTOR_REPEAT`): 4.
- Çeldiricisi değişen kart: 36 (`distractors_diversified`). Doğru cevaplar değişmedi.
- Bu bölümü editör (Opus) yazdı: çeşitlendirme ajanı işini bitirip raporu yazamadan kullanım sınırına takıldı. Sayılar dosyalardan ölçüldü.

## Hafıza ipuçları ve denetim (2026-10-22)

- **Hafıza ipucu:** yazar ajan 14 ipucu önerdi. Şüpheci doğrulayıcı 3 tanesini reddetti, 2 tanesini küçük düzeltmeyle kabul etti. **Eklenen: 11** (`meta.qa_flags`: `mnemonic_added`).
- **Düzeltme:** yok. Yazar bütün kartlarda çevirileri, Dikkat kutularını ve quiz şıklarını tek tek denedi; bariz bir hata bulmadı.
- Yalnızca A1/A2 kartlarına ipucu eklendi. `id`, `lemma`, anlam, `gloss`, `def` ve IPA değişmedi.
- Doğrulayıcı: `54 kart · 54 şemadan geçti · 0 hata · 0 uyarı`

### Eklenen hafıza ipuçları

| Kart | İpucu |
|---|---|
| en.by_the_way.phr.1 | Kelimesi kelimesine 'yol kenarında': sohbet yolunda ilerlerken aklına gelen yan bir şeyi eklersin. |
| en.never_mind.phr.1 | 'Mind' burada 'kafaya takmak' demek ('Do you mind?' gibi): never mind = hiç kafana takma, boş ver. |
| en.it_depends.phr.1 | 'Depend', 'pandantif' ile aynı 'asılı durmak' kökünden: cevap bir şeye asılıdır, o yüzden 'depends on' denir. |
| en.on_time.phr.1 | 'On' noktanın üstü gibi: tren tam 8.15'te, saati saatine gelir. 'In time' = süre bitmeden içeri yetişmek. |
| en.at_least.phr.1 | 'Least' şu sıranın sonu: little, less, least (az, daha az, en az). 'At last' ise 'son' (last) demek. |
| en.take_a_break.phr.1 | 'Break' kırmak demek: çalışmayı kısa bir süre kırarsın. Molayı vermezsin, alırsın: take a break. |
| en.take_a_photo.phr.1 | Fotoğraf makinesi o anı alıp saklar: fotoğrafı 'çekmezsin', alırsın (take). |
| en.take_a_seat.phr.1 | Uçak biletinde 'Seat 14A' yazar: 'seat' koltuk demek. Kendine bir koltuk alırsın: take a seat. |
| en.how_often.phr.1 | 'Often' kelimesinde 't' çoğu zaman okunmaz (ofın). 'Listen' kelimesindeki 't' gibi. |
| en.a_few.phr.1 | 'A' gidince elde neredeyse hiç kalmaz: 'a few' = birkaç tane var, 'few' = neredeyse hiç. |
| en.on_foot.phr.1 | Yürürken ayaklarının üstünde (on) gidersin: bu yüzden 'by foot' değil, 'on foot'. |

### Atılan ipucu önerileri

Zorlama, doğruluğu şüpheli ya da kartta zaten söylenen öneriler atıldı:

- `make sure`: Sözcük sözcük çeviriden ibaret; not zaten aynı şeyi söylüyor.
- `excuse me`: Yalnızca sözcük sözcük çeviri; A1 düzeyinde zaten çok bilinen bir kalıp.
- `of course`: Köken gerçek ama soyut; A1 öğrencinin zaten bildiği bir kalıba bir şey katmıyor.
