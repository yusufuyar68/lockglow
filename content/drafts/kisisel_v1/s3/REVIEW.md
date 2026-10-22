# s3 İnceleme Raporu

Akış: s3 (duygular, kişilik, sosyal beceriler, aşk/arkadaşlık, kutlamalar, iş yeri ve karışan kelimeler).
Kontrol: şema, uzunluk, NFC ve FF_* kuralları. Doğrulayıcı sonucu: 123 kart, 0 hata, 0 uyarı.

## Sayılar

- İncelenen kart: 122 (+1 atlandı: `en.engaged.adj.1`, s1 ile çift kayıt, otomatik düşer).
- Değiştirilen kart: 59 (hepsine `critic_edited` eklendi).
- Toplam alan değişikliği: 76.
- Reddedilen kart (`critic_reject`): 0.

## Değişiklik tablosu

Alan adlarında `examples[n]` sıfır tabanlıdır (`examples[0]` = ilk örnek).

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.hope.v.1 | synonyms | [wish] → [] | 'wish' eş anlamlı değil; kartın kendi notu da farkı anlatıyor. |
| en.tired.adj.1 | antonyms | [awake, energetic] → [rested, energetic] | 'awake' (uyanık) 'asleep'in zıttıdır, 'tired'ın değil. |
| en.angry.adj.1 | def.micro | ready to shout at someone → having strong bad feelings | Tanım yanlış yönlendiriyor: 'kızgın' bir duygudur, 'bağırmaya hazır olmak' değil. |
| en.afraid.adj.1 | l1.tr.note | 'Afraid' sadece 'be' fiilinden sonra gelir: 'an afraid man' denmez, 'a scared man' denir. → 'Afraid' isimden önce kullanılmaz: 'an afraid man' denmez, 'a scared man' denir. | 'Sadece be fiilinden sonra' yanlış: 'feel/look afraid' de olur; asıl kural 'isimden önce gelmez'. |
| en.excited.adj.1 | quiz.cloze | We are ______ about the concert on Friday. → We can't wait! We are ______ about the concert on Friday. | 'sorry/angry about the concert' da mümkün; ipucu eklendi, tek doğru cevap kaldı. |
| en.sorry.adj.1 | l1.tr.gloss+alt | gloss: özür dileyen, üzgün; alt: pişman → gloss: üzgün, pişman; alt: özür dileyen | 'özür dileyen' (apologetic) sıfat 'sorry'nin anlamı değil; 'sorry' = üzgün/pişman. 'Özür dilerim' kalıbı notta duruyor. |
| en.worried.adj.1 | examples[2] | Don't be worried. It's only a small problem. / Endişelenme. Sadece küçük bir sorun. → She looks worried. Is everything okay? / Endişeli görünüyor. Her şey yolunda mı? | 'Don't be worried' doğal değil ('Don't worry' denir); Türkçe de fiil/sıfat uyuşmuyordu. |
| en.proud.adj.1 | quiz.distractors | [afraid, tired, angry] → [angry, lonely, sorry] | 'afraid/tired of my sister' dilbilgisel olarak doğru; 'of' ile uyuşmayan çeldiriciler seçildi. |
| en.proud.adj.1 | synonyms | [pleased, delighted] → [pleased] | 'delighted' (çok sevinmiş) 'proud' (gurur duyan) ile aynı anlam değil. |
| en.lonely.adj.1 | antonyms | [popular] → [] | 'popular' zıt anlam değil; popüler biri de yalnız hissedebilir. |
| en.upset.adj.1 | examples[2].tr | Arkadaşıyla yaptığı tartışmaya üzülmüştü. → Arkadaşıyla yaşadığı tartışma yüzünden üzgündü. | 'was upset' = üzgündü; 'üzülmüştü' (mış'lı geçmiş) zaman kaydırıyor ve 'tartışmaya yapmak' kullanımı yapay. |
| en.relaxed.adj.1 | examples[0].tr | Tatilden sonra kendimi çok rahat hissediyorum. → Tatilden sonra kendimi çok rahatlamış hissediyorum. | 'rahat hissetmek' = kendini yadırgamamak; 'relaxed' için 'rahatlamış' doğru anlam. |
| en.jealous.adj.1 | quiz.distractors | [tired, sorry, afraid] → [angry, sorry, happy] | 'tired of / afraid of his friend's bike' de doğru olabilir; 'of' alamayan çeldiriciler seçildi. |
| en.embarrassed.adj.1 | synonyms | [ashamed, awkward] → [red-faced, mortified] | Kartın notu 'ashamed'in farklı olduğunu söylüyor; eş anlamlı olarak verilmemeli. |
| en.mood.n.1 | synonyms | [spirits, temper] → [spirits] | 'temper' = huy/öfke; 'mood' ile aynı anlam değil. |
| en.relieved.adj.1 | examples[2].tr | Kimsenin yaralanmamasına çok sevindik, içimiz rahatladı. → Kimse yaralanmadığı için rahatladık. | Çeviri bilgi ekliyor ('çok sevindik'); sadeleştirildi. |
| en.rude.adj.1 | quiz.distractors | [shy, lazy, brave] → [tired, lazy, brave] | 'Don't be shy. Say please...' sık kullanılan bir kalıp; 'shy' de doğru sayılabilirdi. |
| en.generous.adj.1 | examples[0].tr | Amcam zamanı konusunda çok cömerttir. → Amcam, zaman ayırma konusunda çok cömerttir. | 'zamanı konusunda cömert' Türkçede doğal değil; 'generous with his time' = zaman ayırmakta cömert. |
| en.generous.adj.1 | synonyms | [kind, giving, big-hearted] → [giving, big-hearted] | 'kind' (nazik) 'generous' (cömert) ile aynı anlam değil. |
| en.selfish.adj.1 | examples[0].tr | Pastanın son dilimini almak bencilceydi. → Pastanın son dilimini almak bencillikti. | 'bencilceydi' yapay; 'bencillikti' doğal. |
| en.ambitious.adj.1 | collocations | ambitious young → ambitious goal | 'ambitious young' yarım bir kalıp; tam ve yaygın bir birleşim verildi. |
| en.easygoing.adj.1 | examples[2].tr | Biz kolay insanlarız. Hangi restoran olursa olur. → Biz geçimi kolay insanlarız. Hangi restoran olursa olur. | 'kolay insanlar' Türkçede başka bir anlama gelir; 'geçimi kolay' doğru karşılık. |
| en.mature.adj.1 | l1.tr.alt | [ağırbaşlı, büyümüş] → [ağırbaşlı, yaşından büyük] | 'büyümüş' bu anlamda doğal bir karşılık değil; 'yaşından büyük' (davranan) gerçek kullanım. |
| en.invite.v.1 | quiz.distractors | [visit, follow, answer] → [visit, thank, answer] | 'follow all our friends to the party' de anlamlı bir cümle; çeldirici değiştirildi. |
| en.apologise.v.1 | quiz.distractors | [answer, refuse, argue] → [refuse, argue, borrow] | 'answer to him' doğru bir kalıp olabilir; kesin yanlış çeldiriciler seçildi. |
| en.advice.n.1 | ipa.us | /ædˈvaɪs/ → /ədˈvaɪs/ | Standart ABD telaffuzu /ədˈvaɪs/; /æd-/ nadir bir varyant. |
| en.chat.v.1 | quiz.cloze | We sat in the garden and ______ for hours. → We sat in the garden and ______ about our holiday plans. | 'studied/worried for hours' de doğru olabilirdi; tek doğru cevap kalacak şekilde değiştirildi. |
| en.chat.v.1 | quiz.distractors | [worried, studied, paid] → [paid, slept, painted] | Eski çeldiriciler (worried, studied) cümleye uyuyordu. |
| en.chat.v.1 | synonyms | [talk, gossip] → [talk, natter] | 'gossip' (dedikodu yapmak) 'chat' ile aynı anlam değil; kartın kendi dedikodu kartı var. |
| en.secret.n.1 | synonyms | [mystery] → [] | 'mystery' (gizem) 'secret' (sır) ile aynı anlam değil. |
| en.argue.v.1 | quiz.cloze | They always ______ about who washes the dishes. → My brothers always ______ and shout about who washes the dishes. | 'agree about who washes...' de olabilirdi; 'shout' ipucu ile tek doğru cevap kaldı. |
| en.manners.n.1 | quiz.cloze | Please eat quietly. Good ______ are important. → Don't talk with your mouth full. It is bad ______. | 'Good prices/seats/lessons are important' de doğru bir cümle; yeni cümlede yalnızca 'manners' uyar. |
| en.interrupt.v.1 | examples[0].tr | Bölüyorum ama yemek hazır. → Kusura bakmayın, sözünüzü kesiyorum ama yemek hazır. | 'Bölüyorum ama' yapay; 'Sorry to interrupt' için doğal Türkçe kalıp kullanıldı. |
| en.interrupt.v.1 | quiz.cloze | Please don't ______ me while I'm talking. → Please don't ______ me while I'm talking. Wait until I finish. | 'follow/teach/thank me' de dilbilgisi olarak doğru; ipucu eklendi. |
| en.ignore.v.1 | examples[2].tr | Bir hafta boyunca bütün mesajlarıma cevap vermedi. → Bir hafta boyunca bütün mesajlarımı görmezden geldi. | 'ignored' = görmezden gelmek; 'cevap vermedi' anlamı daraltıyor. |
| en.ignore.v.1 | quiz.distractors | [invite, borrow, repeat] → [invite, wear, visit] | 'repeat your doctor's advice' de doğru bir cümle olabilir. |
| en.date.n.1 | quiz.cloze | I'm so nervous about my first ______ with Elif tomorrow. → Tomorrow night I'm going on a ______ with Elif. I really like her. | 'first lesson/trip/exam with Elif' de doğru olabilirdi; 'go on a date' kalıbıyla tek cevap kaldı. |
| en.date.n.1 | quiz.distractors | [lesson, trip, exam] → [lesson, meeting, salary] | 'go on a trip' de doğru bir kalıp; çeldiriciler değiştirildi. |
| en.date.n.1 | synonyms | [outing] → [] | 'outing' (gezinti) romantik buluşma anlamını vermez. |
| en.date.n.1 | examples[1].tr | Sinemaya randevuya gittiler. → Randevu için sinemaya gittiler. | 'Sinemaya randevuya gittiler' Türkçede bozuk bir cümle. |
| en.couple.n.1 | examples[2].tr | Ali ve Elif üç yıldır birliktelerler. → Ali ile Elif üç yıldır birlikteler. | 'birliktelerler' hatalı çoğul (çift ek); doğrusu 'birlikteler'. |
| en.trust.v.1 | quiz.cloze | I can't ______ him. He lies all the time. → I can't ______ him with my money. He lies all the time. | 'I can't ask/call him. He lies all the time' de mantıklı; 'trust sb with sth' kalıbıyla tek cevap kaldı. |
| en.forgive.v.1 | quiz.cloze | I'm sorry I forgot. Please ______ me. → I'm sorry I forgot your birthday. Please ______ me. | 'Please teach/follow me' de dilbilgisi olarak doğru; bağlam güçlendirildi. |
| en.forgive.v.1 | synonyms | [pardon, excuse] → [pardon] | Kartın kendi notu 'excuse'un farklı olduğunu söylüyor (nezaket kalıbı). |
| en.forgive.v.1 | examples[0].tr | Lütfen beni affet. Kastetmedim. → Lütfen beni affet. Kastım bu değildi. | 'Kastetmedim' nesnesiz ve eksik duruyor; 'I didn't mean it' için doğal kalıp 'Kastım bu değildi'. |
| en.guest.n.1 | quiz.distractors | [price, lesson, gift] → [price, lesson, report] | 'The first gift arrived at the party' da anlamlı bir cümle (hediye gelmesi). |
| en.tradition.n.1 | synonyms | [custom, habit] → [custom] | 'habit' (alışkanlık) kişiseldir; 'tradition' ile aynı anlam değil. |
| en.custom.n.1 | l1.tr.note | 'Customs' (hep çoğul, büyük harfsiz) 'gümrük' demektir: 'go through customs' = gümrükten geçmek. Tekil 'custom' = âdet, görenek. → Tekil 'custom' = âdet, görenek. 'Customs' ise hem 'âdetler' hem 'gümrük' demektir: 'go through customs' = gümrükten geçmek. | Not kendi içinde çelişiyordu ('customs' = gümrük derken örnek 3'te 'customs' = âdetler); 'büyük harfsiz' ifadesi anlamsızdı. |
| en.custom.n.1 | quiz.cloze | In Japan, it's the ______ to take off your shoes at home. → In many countries, it's the ______ to take off your shoes at home. | Belirli bir ülke adı yerine genel ifade (ülke kalıp yargısından kaçınmak için). |
| en.congratulate.v.1 | synonyms | [praise] → [] | 'praise' (övmek) 'congratulate' (tebrik etmek) ile aynı anlam değil. |
| en.colleague.n.1 | quiz.cloze | I asked a ______ to help me with the report. → We work at the same company, so he is my ______. | 'asked a neighbor/cousin to help me' de doğru; yeni cümlede yalnızca 'colleague' uyar. |
| en.meeting.n.1 | synonyms | [conference, get-together] → [session] | 'get-together' sosyal bir buluşmadır; iş toplantısı anlamı için yanlış. |
| en.boss.n.1 | quiz.cloze | My ______ asked me to finish the report today. → My ______ gave me a day off because I worked all weekend. | 'My neighbor/cousin/student asked me to finish the report' de doğru; yeni cümlede yalnızca 'boss' uyar. |
| en.lend.v.1 | collocations | lend a hand → lend your phone | 'lend a hand' (yardım etmek) ayrı bir deyim ve farklı anlam; bu kartın anlamına ait değil. |
| en.say.v.1 | synonyms | [speak, state] → [state] | 'speak' 'say' yerine kullanılamaz ('She spoke she was tired' yanlış). |
| en.tell.v.1 | l1.tr.note | Kişi belirtmeden 'say' kullanılır. → Aktarma cümlesinde kişi yoksa 'say' kullanılır. | 'Kişi belirtmeden say' genellemesi yanlış: 'tell the truth / a story' kişisiz de olur. |
| en.tell.v.1 | l1.tr.mistakes[1].why | Kişi belirtmeden 'tell' kullanılmaz; kişi yoksa 'say', kişi varsa 'tell me' denir. → Aktarma cümlesinde kişi yoksa 'say' kullanılır; kişi varsa 'tell me that...' denir. | Açıklama aşırı genelleme yapıyordu ('tell the truth' kişisiz doğru). |
| en.tell.v.1 | examples[2].tr | Ailene gezi hakkında söyledin mi? → Annene babana gezi hakkında söyledin mi? | 'your parents' = anne baban; 'ailene' (ailene = your family) anlamı kaydırıyor. |
| en.make.v.1 | quiz.distractors | [do, tell, hold] → [do, tell, sleep] | 'Can you hold some coffee?' de dilbilgisi olarak doğru bir cümle. |
| en.do.v.1 | quiz.distractors | [make, take, give] → [make, wear, drive] | 'take / give my homework' da anlamlı olabilir; çeldiriciler değiştirildi. |
| en.fun.n.1 | quiz.distractors | [funny, homework, noise] → [funny, joke, friend] | 'had a lot of homework / noise' de doğru bir cümle; 'a lot of' ile uyuşmayan çeldiriciler seçildi. |
| en.boring.adj.1 | quiz.distractors | [bored, excited, funny] → [bored, excited, tired] | 'it was really funny' de olabilir; 'funny' çıkarıldı. |
| en.steal.v.1 | quiz.distractors | [robbed, lost, won] → [robbed, won, earned] | 'Someone lost my wallet on the train' de anlamlı bir cümle. |
| en.rob.v.1 | l1.tr.alt | [gasp etmek] → [soygun yapmak] | 'gasp etmek' (hukuki, zorla el koymak) 'rob' için yaygın karşılık değil. |
| en.rob.v.1 | quiz.cloze | Two men ______ the bank on Friday morning. → Two men with masks ______ the bank and ran away with the money. | 'missed/lost the bank' bağlamsız cümlede mümkün; bağlam eklendi. |
| en.miss.v.1 | l1.tr.alt | [ıskalamak, gelememek] → [ıskalamak, yetişememek] | 'gelememek' 'miss' karşılığı değil; 'yetişememek' (otobüse/trene) gerçek karşılık. |
| en.win.v.1 | synonyms | [succeed] → [] | 'succeed' (başarmak) 'win' (yarışı kazanmak) ile aynı anlam değil. |
| en.remember.v.1 | quiz.distractors | [remind, tell, miss] → [remind, miss, carry] | 'I can't tell where I put my keys' doğru bir İngilizce cümle. |
| en.bring.v.1 | examples[2] | She always brings her dog to the park. / Köpeğini her zaman parka getirir. → She always brings her dog when she visits us. / Bizi ziyarete geldiğinde köpeğini de getirir. | 'brings her dog to the park' konuşan parkta değilse 'takes' olmalı; bring/take farkını bulandırıyordu. |
| en.job.n.1 | quiz.distractors | [work, salary, desk] → [work, lesson, desk] | 'looking for a new salary because I want more money' da anlamlı olabilir. |
| en.job.n.1 | l1.tr.mistakes[1] | yanlış: I have a lot of jobs to do today. · doğru: I have a lot of work to do today. → yanlış: I go to job by bus every day. · doğru: I go to work by bus every day. | Eski 'hata' uydurmaydı: 'I have a lot of jobs to do' doğal İngilizce (jobs = tek tek görevler). Gerçek Türkçe kaynaklı hata ('işe gitmek') ile değiştirildi. |
| en.work.n.1 | synonyms | [labor, tasks] → [labor] | 'tasks' sayılabilir çoğul; 'work' sayılamaz ve 'tasks' eş anlamlısı değil. |
| en.work.n.1 | collocations | [go to work, hard work, a lot of work, homework, at work] → [go to work, hard work, a lot of work, paid work, at work] | 'homework' ayrı bir sözcük; 'work' ile gerçek bir birleşim ('paid work') verildi. |
| en.actual.adj.1 | antonyms | [imaginary, planned] → [imaginary, estimated] | 'planned' zıt anlam değil; 'estimated cost' ↔ 'actual cost' gerçek zıtlık. |
| en.sensible.adj.1 | tags.flags | [false_friend_tr, confusable:sensitive] → [confusable:sensitive] | 'false_friend_tr' bayrağı kartın l1 katmanıyla çelişiyordu (false_friend=null, equivalence=full); Türkçede 'sensible'a benzeyen bir sözcük yok. |
| en.see.v.1 | antonyms | [miss] → [] | 'miss' bu anlamda 'see'nin zıttı değil. |

## Ana dili Türkçe olan biri baksın (emin olmadığım kartlar)

- `en.sorry.adj.1`: Gloss artık 'üzgün, pişman'. Ana kullanım 'özür dilerim' olduğu için not bunu açıklıyor; sıralama uygun mu?
- `en.embarrassed.adj.1`: 'utanmış' ile 'ashamed' arasındaki fark Türkçede zor. Alt listede 'rezil olmuş' biraz sert kaldı.
- `en.homesick.adj.1`: 'gurbet çeken' ve 'memleket hasreti' sıfat olarak ne kadar doğal?
- `en.crush.n.1`: Gloss 'hoşlanma'. 'Göz ağrısı' alt anlamı gerçekten bu anlamda mı kullanılıyor?
- `en.compliment.n.1`: Örnek 1: 'İltifatın için teşekkürler!' biraz resmî olabilir. 'Kompliman için teşekkürler' daha mı doğal?
- `en.honest.adj.1`: Alt anlam 'namuslu' dürüstlükle mi, başka bir çağrışımla mı anılır?
- `en.lonely.adj.1`: Örnek 3: 'yalnız bir dönem' yerine 'yalnızlık dolu bir dönem' daha doğal olabilir.
- `en.brave.adj.1`: Örnek 3: 'İlk önce konuşması cesurca bir davranıştı.' biraz hantal.
- `en.date.n.1`: Örnek 1: 'Cuma akşamı bir randevum var.' doktor randevusu gibi de okunabilir. 'Buluşma' daha net olur mu?
- `en.schedule.n.1`: Not 'program' İngilizcede yalnızca TV/bilgisayar programıdır diyor. İngiliz 'programme' etkinlik programı da olabilir; sadeleştirme kabul edilebilir mi?
- `en.reliable.adj.1`: Hata: 'trustable'. Kelime nadir ama var; gerçek bir Türk öğrenci hatası mı?
- `en.eventually.adv.1`: Hata cümlesinin doğru hâli 'I may possibly come…' biraz zorlama; 'I may come…' daha doğal.
- `en.sensible.adj.1`: Türkçede 'sensible'a benzeyen bir sözcük yok; `false_friend_tr` bayrağını kaldırdım. Boru hattı bunu bilerek mi tutuyordu?
- `en.rob.v.1`: İlk örnek soygun haberi. Kilit ekranı için kabul edilebilir mi? (hassasiyet 0 bırakıldı; 1 bu kategoride izinli değil)
- `en.hope.v.1 / en.excited.adj.1 / en.surprised.adj.1 / en.afraid.adj.1`: Seviye A1 yazılmış; CEFR listelerinde A2 olabilir. Değiştirmedim.
- `en.homesick.adj.1 / en.guilty.adj.1 / en.nervous.adj.1`: Quiz çeldiricileri hâlâ dilbilgisel olarak mümkün (lucky, proud, angry). Bağlam güçlü ama %100 tek cevap değil.

## Değiştirilmeyen ama kontrol edilenler

- Etimoloji: polite, rude, honest, generous, colleague doğru; diğer kartlarda `null`. Halk etimolojisi yok.
- Yanlış dost: yalnızca `actual` (aktüel) ve `eventually` (eventüel) gerçek. Başka kartta `false_friend` kullanılmamış.
- IPA ve vurgu: schedule, frustrated, advice (düzeltildi), mature, introduce, interrupt kontrol edildi; ABD/İngiliz farkları doğru.
- Romantik kartlar (date, crush, couple, ex, hug, engaged) temiz ve nötr.

## Çeldirici çeşitlendirme (2026-10-19)

- Önce: 123 soru, 180 farklı çeldirici; en sık: lazy×15, proud×12, angry×11, rude×9, price×9, lesson×8.
- Sonra: 123 soru, 192 farklı çeldirici; en sık: bored×6, tired×6, salary×6, happy×5, lucky×5, excited×5. Doğrulayıcı sınırı (`QUIZ_DISTRACTOR_REPEAT`): 7.
- Çeldiricisi değişen kart: 33 (`distractors_diversified`). Doğru cevaplar değişmedi.
- Bu bölümü editör (Opus) yazdı: çeşitlendirme ajanı işini bitirip raporu yazamadan kullanım sınırına takıldı. Sayılar dosyalardan ölçüldü.

## Hafıza ipuçları ve denetim (2026-10-22)

- **Hafıza ipucu:** yazar ajan 26 ipucu önerdi. Şüpheci doğrulayıcı 2 tanesini reddetti, 6 tanesini küçük düzeltmeyle kabul etti. **Eklenen: 24** (`meta.qa_flags`: `mnemonic_added`).
- **Düzeltme:** yazarın 4 önerisinden doğrulayıcının onayladığı 4 tanesi uygulandı; koordinatör 2 yazım düzeltmesi ekledi (çeviri 2, diğer 3, Dikkat 1). Düzeltilen kartlara `critic_edited` eklendi.
- Yalnızca A1/A2 kartlarına ipucu eklendi. `id`, `lemma`, anlam, `gloss`, `def` ve IPA değişmedi.
- Doğrulayıcı: `123 kart · 123 şemadan geçti · 0 hata · 0 uyarı`

### Eklenen hafıza ipuçları

| Kart | İpucu |
|---|---|
| en.lend.v.1 | Krediyi veren bankaya 'lender' denir: parayı o verir (lend). Sen ise bankadan borç alırsın (borrow). |
| en.say.v.1 | Fotoğrafçı 'Say cheese!' der: 'say' söylenen sözün kendisini alır. Kişiye söylemek için 'tell me' denir. |
| en.tell.v.1 | Falcıya 'fortune teller' denir: sana geleceğini anlatır. 'Tell' de dinleyeni hemen yanına alır: 'tell me'. |
| en.make.v.1 | Kahve makinesine 'coffee maker' denir: ortaya yeni bir şey çıkarır. Ödev, bulaşık gibi işler ise 'do' ile yapılır. |
| en.do.v.1 | 'To-do list' yapılacak işler listesidir: ödev, bulaşık, alışveriş gibi işler 'do' ile yapılır. |
| en.fun.n.1 | Lunaparka İngilizcede 'funfair' de denir: oradaki duygu 'fun' (eğlence). Güldüren komik şey ise 'funny'. |
| en.lose.v.1 | 'Lose' kelimesi bir 'o' harfini kaybetmiş gibi: tek 'o' var. Gevşek anlamındaki 'loose' iki 'o' ile yazılır. |
| en.win.v.1 | Geçmiş hâli 'won', tıpkı 'one' (bir) gibi okunur: kazanan bir numara olur! |
| en.hear.v.1 | 'Hear' kelimesinin içinde 'ear' (kulak) var: ses kulağına kendiliğinden gelir. |
| en.listen.v.1 | 'Listen' kelimesinde 't' okunmaz: 'lisın' denir. O sessiz 't' gibi sen de sessizce dinle. |
| en.remember.v.1 | 'Remember' ile 'memory' (hafıza) aynı kökten: hatırlayan senin hafızandır. Başkasına hatırlatmak 'remind'. |
| en.bring.v.1 | 'Bring' ile 'buraya' aynı harfle başlar: 'Bring it here!' Buradan uzağa götürmek ise 'take'. |
| en.take.v.1 | Paket yemeğe İngilizcede 'takeaway' denir: yemeği alıp götürürsün. 'Take' buradan uzağa götürmektir. |
| en.watch.v.1 | Bekçiye 'watchman' denir: gece boyunca dikkatle izler. Film ve maç da böyle, uzun uzun 'watch' ile izlenir. |
| en.worried.adj.1 | Ünlü şarkıyı hatırla: 'Don't worry, be happy' = Endişelenme, mutlu ol. |
| en.upset.adj.1 | 'Upset' devirmek, altüst etmek de demek. Üzgün kişi için Türkçede de 'içi altüst oldu' deriz. |
| en.calm.adj.1 | 'Calm' kelimesinde 'l' okunmaz: 'kaam' gibi söylenir. Sakin ol, 'l' de sessiz kalsın. |
| en.polite.adj.1 | 'Polite' ile 'polish' (cilalamak) aynı kökten: kibar insanın tavırları cilalı gibi pürüzsüzdür. |
| en.advice.n.1 | 'Advice' sonu 'ice' (buz) gibi okunur ve buz gibi sayılmaz: 'an advice' ya da 'advices' denmez. |
| en.secret.n.1 | 'Secret' ile 'secretary' (sekreter) aynı kökten: sekreter, eskiden sırlar emanet edilen kişi demekti. |
| en.date.n.1 | 'Date' tarih demek. Takvimde günü belirlenen romantik buluşmaya da zamanla 'date' denmeye başlandı. |
| en.guest.n.1 | 'Guest' kelimesindeki 'u' okunmaz: 'gest' denir. 'Guess' ve 'guitar' kelimelerinde de 'u' sessizdir. |
| en.laugh.v.1 | 'Laugh' kelimesinde 'gh' 'f' gibi okunur: 'laf' denir. Komik bir lafa gülersin! |
| en.introduce.v.1 | Şarkının girişine 'intro' denir: 'introduce' da bir tanışmanın girişidir, iki kişiyi ilk kez buluşturur. |

### Düzeltmeler

| Kart | Alan | Önce → Sonra | Neden |
|---|---|---|---|
| en.tell.v.1 | examples[2].tr | Annene babana gezi hakkında söyledin mi? → Annene babana geziyi söyledin mi? | Eski çeviri doğal değildi; 'Annenle babana' yerine orijinaldeki daha yaygın 'Annene babana' korundu. |
| en.lonely.adj.1 | examples[2].tr | Yurt dışına taşınmak yalnız bir dönem olabilir. → Yurt dışına taşınmak, yalnızlık dolu bir dönem olabilir. | 'yalnız bir dönem' Türkçede doğal değil; 'a lonely time' = yalnızlık dolu bir dönem. |
| en.colleague.n.1 | l1.tr.mistakes[0].wrong | She is my colleague from school. → She is my colleague from school. (= sınıf arkadaşım) | Cümle tek başına doğru olabilir (aynı okulda çalışan iki öğretmen). Kastedilen 'sınıf arkadaşı' anlamı diğer kartlardaki gibi belirtilmeli. |
| en.suggest.v.1 | l1.tr.note | 'Suggest' + kişi + 'to do' kalıbı yoktur. 'Suggest doing sth' ya da 'suggest that we do sth' denir. 'Recommend' (tavsiye etmek) daha güçlü bir önerididir. → 'Suggest' + kişi + 'to do' kalıbı yoktur. 'Suggest doing sth' ya da 'suggest that we do sth' denir. 'Recommend' (tavsiye etmek) daha güçlü bir öneridir. | Yazım hatası: 'önerididir' yerine 'öneridir'. |
| en.funny.adj.1 | l1.tr.alt[0] | espirili → esprili | Yazım hatası: doğrusu 'esprili' (koordinatör). |
| en.mood.n.1 | l1.tr.alt[1] | modu → mod | Karşılık çekimli biçimde yazılmıştı; yalın hâli 'mod' ('modum yok') (koordinatör). |

### Atılan ipucu önerileri

Zorlama, doğruluğu şüpheli ya da kartta zaten söylenen öneriler atıldı:

- `miss`: Kartın notu iki anlamı ve 'I miss you' örneğini zaten veriyor; 'kaçırdığını özlersin' bağı da mantıksal olarak zayıf.
- `nervous`: Sahte dost gerçek ama not ve Dikkat kutusu 'sinirli değil, gergin, sınav öncesi' bilgisini aynen veriyor; tekrar.

### Anadili Türkçe birinin bakması gerekenler

- en.funny.adj.1: alt 'espirili' yanlış yazılmış; doğrusu 'esprili' (alt, dokunulmadı)
- en.mood.n.1: alt 'modu' tek başına garip; 'mod' ya da 'keyif' daha doğal olabilir (alt, dokunulmadı)
- en.nervous.adj.1: quiz çeldiricisi 'hungry' ('I always feel hungry before a big presentation') sınırda olabilir; dokunulmadı
- en.attend.v.1: quiz çeldiricisi 'followed' (çevrimiçi toplantıyı takip etmek) sınırda olabilir; dokunulmadı
- en.colleague.n.1: Türklerin 'colleague' kelimesini sınıf arkadaşı için gerçekten kullanıp kullanmadığına anadili Türkçe biri baksın; değilse madde tümden silinebilir.
- en.polite.adj.1: ipucu kartın İngilizce ety alanıyla aynı bilgiyi Türkçe veriyor; ety uygulamada gösteriliyorsa tekrar sayılabilir.
