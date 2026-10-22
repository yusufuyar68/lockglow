# Arayüz metinleri denetimi (22 Ekim 2026)

- **Taban:** `origin/main` 29797b4. Satır numaraları bu commit'e göredir. is3-* dalları birleşince satırlar kayar ve bazı metinler değişir: her satırdaki "Bağlı" sütununa bak.
- **Kod değişmedi.** Bu rapor yalnız öneri. Terim kararları [`../tasarim/terimler.md`](../tasarim/terimler.md) içinde.
- **Ölçüt:** [`ogrenme_ilkeleri.md`](../tasarim/ogrenme_ilkeleri.md) §1 madde 11–12, §2'deki metin önerileri ve §3 "Kaçınılacaklar"; tasarım [`README.md`](../tasarim/README.md) madde 13 (saat yazımı).
- **Yöntem:** metinler betikle çıkarıldı. Her biri bağlamıyla okundu. VoiceOver kısmını ayrı bir Opus denetçi okudu; bulgularını kodda yeniden doğruladım.

```
python -X utf8 docs/denetim/araclar/metin_cikar.py            # bütün metinler (Markdown tablo)
python -X utf8 docs/denetim/araclar/metin_cikar.py --isaret   # kurala takılanlar
python -X utf8 docs/denetim/araclar/metin_cikar.py --terim    # terim sayımı
```

Betiğin bulduğu: **605 metin, 41 dosya** (`ios/App`, `ios/Widgets`, `ios/Shared`, `ReminderPlanner.swift`, ek olarak `PronunciationCheck.swift` ve `project.yml` izin metinleri). Türlere göre: görünür 323, VoiceOver 48, bildirim 20, iletişim kutusu 1, izin 4, yardımcı fonksiyondan dönen ("değer") 209. "Değer" metinlerinin çoğu da ekranda görünür; tür yalnız nereden geldiğini söyler.

**Öncelik:**
- **Yüksek:** ilkelerde [ŞART] olan bir kuralı bozuyor, yanlış bilgi veriyor ya da VoiceOver'da ana bir düğmeyi yanıltıcı okuyor.
- **Orta:** aynı şeye iki ad, A2 için zor metin, VoiceOver'da karışık okuma.
- **Düşük:** cila, nadir görülen ekran.

**Bağlı:** öneri hangi oturumun dalıyla birlikte ele alınmalı. "—" ise bağımsız, hemen yapılabilir.

## Genel tablo

İyi olanlar (korunacak):
- **Hitap:** "siz" hiç yok. Uygulama her yerde "sen" diyor.
- **Ekler:** değişkenden sonra Türkçe ek yok (betik 0 buldu). "Hatırlatma: 20:00", "Yeni kelime: 09:00", "bugün 21:40" kurallara uygun.
- **Büyük harf:** locale vermeden `.uppercased()` çağrısı yok.
- **Ton:** seri, puan ve kırmızı sayaç yok. "Bugünlük tamam", "Tur bitti", "Bir gün atlarsan dert etme" gibi sakin metinler.
- **Kurallara uygun metinler:** "Doğrusu: … / Senin seçtiğin: …", "Neden?". Apple'ın Türkçe adları da doğru: "Araç Takımı Ekle", "Özelleştir", "basılı tut".

Sorunlar dört kümede toplanıyor:
1. **İlkelerin açıkça değiştirdiği metinler hâlâ eski hâlinde.** "Doğru, çok iyi!", Söyle'de "Doğru!", "10 dakika sonra yine gelir", bildirimde sayı.
2. **Aynı kavrama iki ad.**
   - Bildiğim / bildiğin / Biliyorsun.
   - Zor / Zordu.
   - Anlamı / Anlamını göster.
   - kart / kelime (sayı birimi olarak).
   - Bildirim / hatırlatma.
   - kilit ekranı / kilitli ekran.
   - düzey / seviye.
   - bas / dokun.
3. **"hatırlatma" iki anlamda.** Günlük bildirim ile 30 gün sonraki tek soru aynı adı taşıyor. Rehber widget'a bakmayı da "hatırlatma" diye anlatıyor.
4. **VoiceOver'da "/" ve ">" işaretleri ve İngilizce kelimeyi Türkçe sesle okuma** (satır içi kilitli ekran widget'ı).

## En önemli 15 düzeltme

| # | Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|---|
| 1 | `QuizCardView.swift:81` (ekranda ve duyuruda), `:353` | "Doğru, çok iyi!" · duyuru "Yanlış. Doğrusu: spoon…" | "Doğru." · duyuru "Doğrusu: spoon, Türkçesi: kaşık" | Madde 12: kişiye övgü ve "Yanlış" sözü yok. §3 ünlem. | Yüksek | is3-quiz ("Doğru!" yaptı, "Yanlış." kalktı; ünlemi de kaldır) |
| 2 | `PronunciationCheck.swift:484–485`, `:496`; `LearningGuideView.swift:765` | "Doğru!" / "Anlaşılır söyledin." · "'\(heard)' duydum. Önce hoparlör düğmesiyle dinle, sonra yavaş ve net söyle." | "Anlaşıldı!" / "Telefon “\(heard)” diye duydu." · "Telefon “\(heard)” diye duydu. Önce Dinle'ye dokunup dinle, sonra yavaş ve net söyle." Rehberdeki örnek de "Anlaşıldı!" | İlkeler 2.7 iki metni de açıkça değiştiriyor. §3: anlaşılırlığa "Doğru!" denmez. | Yüksek | is3-olcum (aynı dosyalar, metne dokunmuyor) |
| 3 | `QuizCardView.swift:548`; `ReviewView.swift:504` + `:974` (Bilemedim düğmesindeki süre) | "Bu kelime 10 dakika sonra yine gelir." · Bilemedim düğmesinde "10 dakika sonra" | "Bu kelimeyi bir sonraki turda yine soracağız." · Bilemedim'de "sonraki turda" | İlkeler 2.3 ve §3: tutulamayan zaman sözü verilmez. Günde tek bildirim var; 10 dakika sonra kimse geri gelmiyor. | Yüksek | is3-tekrar (kayma kuralı) |
| 4 | `ReminderPlanner.swift:147–148`, `:156`, `:200` | "Tekrar zamanı" / "12 kelime tekrar için hazır." · "breakfast ve 11 kelime daha hazır." · "Bugün 5 yeni kelime var, istersen bir göz at." | "Kısa bir tekrar" / "Bugün için birkaç kelime hazır." · "Sırada breakfast var." · "İstersen birkaç yeni kelimeye göz at." | İlkeler 2.10 [ŞART]: bildirim kelime taşır, sayı ya da görev taşımaz. §3: "gövdede tekrar sayısı". | Yüksek | is3-bildirim |
| 5 | `SearchView.swift:894` (VoiceOver ipucu); `LearningGuideView.swift:169` | "Kelime widget'tan çıkar, 30 gün sonra hatırlatma olarak döner." · "Kelimeyi zaten iyi biliyorsan bas. Kelime sıradan çıkar ve yalnızca 30 günde bir sorulur. Emin değilsen basma." | "Kelime widget'tan çıkar. 3 gün sonra bir kez sorarız." · "Kelimeyi zaten biliyorsan dokun. Kelime widget'tan çıkar; 3 gün sonra bir kez sorarız." | Burada "hatırlatma" kelimesi günlük bildirimle karışıyor (terimler §5). İlkeler 2.2 [ŞART]: Biliyorum'dan 3 gün sonra tek bir kontrol sorusu gelir; birleşmeden sonra "30 gün" yanlış bilgi olur. "bas" yerine "dokun". | Yüksek | is3-tekrar (3 gün kuralı gelene kadar "30 gün sonra bir kez sorarız") |
| 6 | `ReviewView.swift:758`, `:774`, `:783`, `:793` | Sayaç rozetinde ve başlıkta toplam sayı: "23 kelime tekrar bekliyor" · "Önce öğrendiğin kelimeleri pekiştirelim." · "Başla (10 kart)" | Başlık "Tekrar zamanı" · "Önce öğrendiğin kelimeleri hatırlayalım." · "Başla (10 kelime)". 20'yi geçince ilkeler 2.3'teki metin: "Ara verdin, sorun değil." / "Unutulmaya en yakın 10 kelimeyle başlayalım." | §3: aradan sonra büyük birikmiş sayı gösterilmez. "kart" sayı birimi değil (terimler §4). "pekiştirmek" A2 için zor. | Yüksek | is3-tekrar ("Ara verdin" kartı) |
| 7 | `KnownWordsView.swift:42`; `SettingsView.swift:353–354`, `:375`; `SearchView.swift:226`, `:915` | "Bildiğim kelimeler" (aynı ekranın boş hâli "Henüz bildiğin kelime yok") · kutucuklar "bildiğim kelime", "öğreniyorum" · "Biliyorsun" | "Bildiğin kelimeler" · "bildiğin kelime", "öğrenme listende" · "Bildiğin kelime" | Aynı ekranda iki hitap. Başlık ve durum adları "sen"le (terimler §1). Akış'taki "Bildiğin kelime" ile aynı ad. | Orta | — · UI testi `LockglowScreenshotTests.swift:88` ("Bildiğim kelime") birlikte değişmeli |
| 8 | `QuizCardView.swift:522`, `:531`, `:538` | "Ya da bu soru nasıl geldi?" + "Zordu" / "Kolaydı" | "Zor muydu, kolay mı?" + "Zor" / "Kolay" | "Bu soru nasıl geldi?" A2 okur için belirsiz. Kart cevapları, tur özeti ve rehber "Zor / Kolay" diyor; quiz'de "Zordu" diye dokunulan cevap özette "Zor" görünüyor. | Orta | is3-quiz (ilkeler 2.3 "Zordu / Kolaydı" adını da güncelle) |
| 9 | `ReviewView.swift:1358`, `:764`, `:1348`; `OnboardingView.swift:101` | VoiceOver: "Bugünkü hedef: 2 / 5 yeni kelime" · "Adım 2 / 4" · görünür "bugünkü hedef" | VoiceOver: "Günlük hedef 5 yeni kelime. Bugün 2 tanesini çalıştın." · "Adım 2, toplam 4". Görünür "günlük hedef" | VoiceOver "/" işaretini "bölü" diye okur. Kartta "Kart 2, toplam 10" doğru yapılmış (`ReviewView.swift:156`). Ayar adı "günlük hedef". | Orta | — |
| 10 | `ReviewView.swift:440` | "Anlamı göster" | "Anlamını göster" | İlkeler 2.3 ve rehber (`LearningGuideView.swift:708`) "Anlamını göster" diyor. | Orta | is3-tekrar · UI testi `LockglowScreenshotTests.swift:38` birlikte değişmeli |
| 11 | `SettingsView.swift:298–299` | Bölüm "Bildirim" · "Ne zaman hatırlatayım?" | Bölüm "Hatırlatma" · "Ne zaman hatırlatalım?" | Özelliğin adı "hatırlatma" ("Hatırlatma: 20:00"). Uygulama kendinden "biz" diye söz ediyor ("başlayalım", "soracağız"); "ben" yok. | Orta | is3-ayarlar |
| 12 | `ios/Widgets/WordWidget.swift:13` | "Ana ekranda ve kilit ekranında yeni kelimeler." | "Ana ekranda ve kilitli ekranda yeni kelimeler." | Apple'ın ve uygulamanın her yerdeki adı "kilitli ekran". Widget galerisindeki ilk cümle bu. | Orta | — |
| 13 | `LearningGuideView.swift:161` | "Widget'ı kilitli ekrana ekle. Telefona her baktığında kelimeyi görürsün; bu, gün içinde birçok kısa hatırlatma demek." | "Widget'ı kilitli ekrana ekle. Telefona her baktığında kelimeyi görürsün. Kelimeyi asıl Tekrar'da hatırlayarak öğrenirsin." | §3: bakmayı öğrenme diye anlatmak. Ayrıca "hatırlatma" kelimesi üçüncü bir anlama kayıyor. | Orta | — |
| 14 | `PronunciationPracticeView.swift:296`; `:382` + `:411–412` | "Dinliyorum... Bitince sus ya da Bitti'ye bas." · beklerken soluk "Söyle" düğmesi | "Dinliyorum… Bitirince bekle ya da Bitti'ye dokun." · beklerken "Bekle" | "sus" kaba okunabilir. "bas" yerine "dokun", "..." yerine "…". Soluk "Söyle" VoiceOver'da "şimdi konuş" gibi duyuluyor. | Orta | is3-olcum |
| 15 | `ios/Widgets/AccessoryWordViews.swift:114–116` | Satır içi kilitli ekran widget'ı: "actually · aslında, gerçekte" tek Türkçe sesle okunur | Erişilebilirlik adı: İngilizce kelime İngilizce sesle (`widgetEnglishVoice()`), sonra "Türkçesi: aslında, gerçekte". "·" okunmaz. | §3 Türkçe: İngilizce kelimeyi Türkçe sese okutmak. Uygulamanın ana yüzeyi bu. Önceki erişilebilirlik raporunda V5; hâlâ duruyor. | Orta | is3-kilit (aynı dosya) |

## Ekran ekran bütün bulgular

İlk 15'teki maddeler burada "↑ #n" diye anılır.

### Tekrar (`ReviewView.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `:758`, `:774`, `:783`, `:793` | ↑ #6 | | | Yüksek | is3-tekrar |
| `:440` | ↑ #10 | | | Orta | is3-tekrar |
| `:504`, `:974` | ↑ #3 (Bilemedim düğmesindeki "10 dakika sonra") | | | Yüksek | is3-tekrar |
| `:518` | VoiceOver değeri "\(when) yeniden gelir" | "\(when) yine gelir" | Görünür metin ve ilkeler "yine" diyor; tek fiil (terimler §6). | Düşük | — |
| `:451` | "Bu kelimeyi ne kadar bildin?" | Yeni kelimede kalkar (Tanış + Hatırla). Kutu 4–5'te: "Göstermeden önce aklına geldi mi?" | İlkeler 2.3: yeni kelimede kendini puanlama sorusu kalkar. Metinden çok akış işi. | Orta | is3-tekrar |
| `:784` | "Kelimeye bak, anlamını hatırlamaya çalış. Sonra ne kadar bildiğini seç." | "Önce tanış, sonra hemen bir kez hatırla." | İlkeler 2.3 bu metnin kalkmasını istiyor. | Orta | is3-tekrar |
| `:764`, `:1348`, `:1358` | ↑ #9 | | | Orta | — |
| `:709–714` | "10 kelime çalıştın." | "10 kelime çalıştın, 7 tanesini bildin." (ikinci yarı ilk denemede bilinenler) | İlkeler 2.5 ve 1b. İşe dair geri bildirim; yüzde ve yanlış sayısı yok. | Düşük | is3-tekrar |
| `:847` | "Kilitli ekranın yeni kelimeleri göstermeye devam ediyor." | "Kilitli ekranda yeni kelimeler görünmeye devam eder." | Daha kısa ve düz. | Düşük | — |
| `:726–728` | "content.sqlite ve seed_words.json pakete eklenmemiş." | "Kelimeler yüklenemedi. Uygulamayı kapatıp yeniden aç." | Kullanıcıya dosya adı gösterilmez; açılıştaki metinle aynı olsun (`OnboardingView.swift:276`). | Düşük | — |

Doğru olanlar: "Kart 1 / 10" ve VoiceOver'daki "Kart 1, toplam 10". "Bilemedim · Zor · Bildim · Kolay". "Tur bitti", "Bu turun kelimeleri". "\"Zor\" da bilinmiş sayılır." "Bugünlük tamam", "Tekrar edecek kelime kalmadı. Şimdi kapatabilirsin." "Sıradaki tekrar: bugün 21:40", "Hatırlatma: 20:00", "Bugün: 3 yeni kelime, 12 tekrar."

### Quiz (`QuizCardView.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `:81`, `:353` | ↑ #1 | | | Yüksek | is3-quiz |
| `:548` | ↑ #3 | | | Yüksek | is3-tekrar |
| `:522`, `:531`, `:538` | ↑ #8 | | | Orta | is3-quiz |
| `:534`, `:541`, `:579` | Dönüş zamanı yalnız ipucunda: "Kelime \(time) yeniden gelir" | Değer (`accessibilityValue`): "\(time) yine gelir" | İpuçları geç okunur ve çok kişi kapatır. Kart cevaplarında bu düzeltildi (`ReviewView.swift:518`). | Orta | is3-quiz |
| `:238` | Boşluk VoiceOver'da İngilizce sesle "boşluk" | İngilizce sesle "blank" | Önceki raporda V4. | Orta | is3-quiz (yaptı) |
| `:703` / `:711` | Görünür "Dinle", VoiceOver "Cümleyi dinle" | Ad kalsın; `accessibilityInputLabels(["Dinle"])` ekle | Sesli Denetim'de görünen ad söylenince bulunmalı. Kodda hiç `accessibilityInputLabels` yok. | Düşük | — |

Doğru olanlar: "Boşluğa hangisi gelir?", şıkta küçük "Doğru cevap" / "Yanlış" etiketi simgeyle, "Doğrusu: spoon = kaşık", "Senin seçtiğin: knife = bıçak", "Neden?".

### Akış ve kart parçaları (`FeedView.swift`, `CardDetailViews.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `FeedView.swift:498` | "Biliyorum"a dokununca hiçbir metin çıkmıyor | 5 sn alt bildirim: "Tamam. 3 gün sonra bir kez soracağız." + "Geri al" | İlkeler 2.2 [ŞART]; §3 "görünür sonucu olmayan düğme". | Yüksek | is3-akis (ekliyor; metni 3 gün kuralına göre denetle) |
| `FeedView.swift:494` | "Geri al" (VoiceOver'da neyin geri alındığı yok) | İpucu: "Kelime öğrenme listene döner." | Kısa "Geri al" yalnız "Bildiğin kelime" yazısının yanında anlaşılır (terimler §3). | Düşük | is3-akis |
| `CardDetailViews.swift:252`; `TopicPickerView.swift:319` | "iki kelimeli fiil" · konu "İki kelimeli fiiller" | "kalıp fiil" · "Kalıp fiiller" | "look forward to" gibi 9 kart üç kelimeli; ad yanlış bilgi veriyor. İlkeler 2.2 [BELKİ]. | Orta | — |
| `CardDetailViews.swift:111–153` | Dikkat farkı (altı çizili kelime) VoiceOver'da söylenmiyor | Satıra "değişen kelime: spoons" eki | Önceki raporda V12. | Düşük | is3-akis |

Doğru olanlar: "Dikkat: sık yapılan hata", "Örnek cümle ve Dikkat", "Şu an kilitli ekranda", "Kartın tamamını açar", "Türkçesi:" öneki.

### Sözlük (`SearchView.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `:894` | ↑ #5 | | | Yüksek | is3-tekrar |
| `:226`, `:915` | ↑ #7 ("Biliyorsun") | | | Orta | — |
| `:109` | "Kelimenin başını yazmayı dene. Türkçe harfler gerekmez: odunc da ödünç bulur." | "Kelimenin başını yazmayı dene. Türkçe harf gerekmez: odunc yazınca ödünç çıkar." | "odunc da ödünç bulur" anlaşılmıyor. Boş kutudaki ipucuyla (`:72`) aynı kalıp olsun. | Orta | — |
| `:883` | "Kelime yeniden widget'a ve tekrara gelir." | "Kelime yeniden widget'a ve Tekrar'a gelir." | Sekmeyi kastediyor: büyük harf ve kesme (terimler §2). | Düşük | — |
| `:850` | Eşdizim çipinde ipucu "Sesli okur" / "Durdurur" | Ad değişsin: "Dinle: \(phrase)" / "Durdur" | Öteki bütün ses düğmelerinde ad değişiyor; ipucu değil. | Düşük | — |
| `:137` | "\(n) sonuç" duyurulmuyor | Arama bitince duyuru: "\(n) sonuç" | Önceki raporda V7. | Düşük | — |

Doğru olanlar: "İngilizce ya da Türkçe kelime", "Türkçe harfleri yazmasan da bulur: odunc yazınca ödünç çıkar.", "\"brekfast\" bulunamadı" (ek yok), "Biliyorum olarak işaretle" / "Öğrenmeye geri al" (ilkeler 2.6), "Yeni kelime / Öğreniyorsun".

### Bildiğin kelimeler (`KnownWordsView.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `:42` | ↑ #7 | | | Orta | — |
| `:105` | Alt bildirim ve duyuru: "breakfast geri alındı" | "Öğrenmeye döndü: breakfast" (kelime İngilizce sesle) | "geri alındı" kelime silindi gibi okunuyor; ek kuralına da uyuyor. | Orta | — |
| `:26` | "Widget'ta \"Biliyorum\" dediğin ya da tekrarda öğrendiğin kelimeler burada görünür." | "\"Biliyorum\" dediğin ya da Tekrar'da öğrendiğin kelimeler burada görünür." | "Biliyorum" Akış'ta ve Sözlük'te de var; sekme adı büyük harfle. | Düşük | — |
| `:73`, `:181` | "\"Geri al\" kelimeyi yeniden tekrara ve widget'a getirir." · ipucu "Kelime yeniden tekrara ve widget'a gelir." | "Geri al: kelime yeniden Tekrar'a ve widget'a gelir." · ipucu aynı cümle | Sekme adı; Sözlük'teki ipucuyla aynı sıra. | Düşük | — |
| `:177` | Satırdaki "Geri al" VoiceOver'da hangi kelime olduğunu söylemiyor | `accessibilityValue(Text(verbatim: word.lemma))` (ad "Geri al" kalır, test bozulmaz) | Önceki raporda V11. | Düşük | — |
| `:131` | "Vazgeç" bildirimi VoiceOver'da 10 sn sonra kaybolur | Odak bildirimdeyken kapanmasın | Önceki raporda V12 (WCAG 2.2.1). | Düşük | — |

### Söyle (`PronunciationPracticeView.swift`, `PronunciationCheck.swift`, `project.yml`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `PronunciationCheck.swift:484–485`, `:496` | ↑ #2 | | | Yüksek | is3-olcum |
| `PronunciationCheck.swift:481` | "'th' yerine 's' duydum. …" | "Telefon 'th' yerine 's' duydu. …" | Açıklama cümlesinde konuşan telefon (terimler §1). | Düşük | — |
| `PronunciationPracticeView.swift:296`, `:382`, `:411–412` | ↑ #14 | | | Orta | is3-olcum |
| `PronunciationPracticeView.swift:784` | "Konuşma tanıma bu sefer çalışmadı. Bir daha dene. (\(detail))" | "(\(detail))" kalksın ya da yalnız tanılamada görünsün | Sistem hatası çoğu zaman İngilizce; Türkçe sesle okunur. | Düşük | is3-olcum |
| `PronunciationPracticeView.swift:780` | "Bu telefonda cihaz içi İngilizce tanıma kurulu değil. Ayarlar > Genel > Klavye bölümünde İngilizce (ABD) klavyeyi ekleyip Dikte'yi açınca çalışır." | "Bu telefonda İngilizce tanıma kurulu değil. iPhone Ayarları'nda Genel, sonra Klavye bölümüne gir. İngilizce (ABD) klavyeyi ekle ve Dikte'yi aç." | Uzun cümle; ">" VoiceOver'da "büyüktür" okunabilir. | Düşük | — |
| `project.yml:65` (izin metni) | "Kelimeyi doğru söyleyip söylemediğini anlamak için konuşma tanıma yalnızca telefonda çalışır. Sesin Apple'a ya da başka bir sunucuya gönderilmez." | "Söylediğin kelimenin anlaşılıp anlaşılmadığını görmek için konuşma tanıma kullanılır. Bu iş telefonda yapılır; sesin hiçbir yere gönderilmez." | Söyle doğruluğu değil anlaşılırlığı ölçer (ilkeler 2.7). İlk cümle uzun. | Düşük | — (mağaza metniyle uyumlu olmalı) |

Doğru olanlar: "Ses telefondan çıkmaz ve kaydedilmez.", "Adım 2/3: Söyle", "Neredeyse!", "Şunlar duyulmadı: up.", "Seni duyamadım", "Telefon farklı bir şey anladı.", izin sayfası metinleri ("Söyle için mikrofon gerekiyor…").

### Ayarlar (`SettingsView.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `:298–299` | ↑ #11 | | | Orta | is3-ayarlar |
| `:353–354`, `:375` | ↑ #7 | | | Orta | — |
| `:92` | "Dokun ve \"Widget'ları yenile\"yi dene. Düzelmezse widget'ı kaldırıp yeniden ekle." | "Yukarıdaki satıra dokun, sonra Widget'ları yenile düğmesine dokun. Düzelmezse widget'ı kaldırıp yeniden ekle." | Neye dokunulacağı belli değil; tırnaklı ada ek geliyor. İlkeler 2.9'daki üç adım ileride buraya gelir. | Orta | is3-ayarlar |
| `:336` | "Seçtiğin saatte, tekrarı gelen bir kelimeyi ya da sıradaki yeni kelimeyi gösteren kısa bir bildirim gelir. O günün işini bitirdiysen gelmez." | "Seçtiğin saatte kısa bir hatırlatma gelir. İçinde bir kelime olur. O günün işini bitirdiysen gelmez." | İlk cümle 15 kelime. | Düşük | is3-bildirim |
| `:505–509` | "İlerleme dosyası okunamadı, 24 Ekim 2026 09:00 tarihli yedekten geri yüklendi. Ondan sonraki değişiklikler kaybolmuş olabilir." (ve iki benzeri) | "Kayıtların okunamadı. Yedekten geri yükledik (yedek: 24 Ekim 2026 09:00). Bu tarihten sonraki değişiklikler kaybolmuş olabilir." | Kısa cümle, "biz", tarihten sonra ek yok. Üçüncüsü: "Kayıtların okunamadı ve yedek yoktu. İlerleme sıfırdan başladı. Eski dosyayı silmedik." | Düşük | — |
| `:148` | "…iPhone, pili korumak için bunu biraz geciktirebilir." yalnız 30 dk'nın altında | Her seçimde göster | İlkeler 2.9 bu notu "dürüst" diye koruyor. is3-ayarlar'dan sonra 30 dk'nın altı kalmıyor; not hiç görünmez olur. | Düşük | is3-ayarlar |
| `:462` | "Lockglow 1.0 · içerik 2026.10.21 (933 kart)" | "(933 kelime)" | Sayı birimi "kelime". | Düşük | — |
| `:138` | Seçenek "30 dk" | VoiceOver adı "30 dakika" | Kısaltma sesle "dk" okunur. | Düşük | — |
| `:215`, `:217` | "**A2** · …" | VoiceOver adında "·" yerine virgül | "·" cihazda nasıl okunuyor, bakılmalı. | Düşük | — |

Doğru olanlar: soru biçimli başlıklar ("Kelime ne sıklıkla değişsin?", "Hangi seviyeden başlayalım?", "Günde kaç yeni kelime?"), "İlerleme sıfırlansın mı?" + "Bu işlem geri alınamaz.", "Vazgeç", "Bildirim iznini aç" (iOS izninin adı).

### Widget sağlığı ve widget rehberi (`WidgetHealthView.swift`, `WidgetGuideView.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `WidgetHealthView.swift:304` | "\"Widget'ları yenile\"ye dokun; düzelmezse widget'ı kaldırıp yeniden ekle." | "Widget'ları yenile düğmesine dokun. Düzelmezse widget'ı kaldırıp yeniden ekle." | Tırnaklı ada ek. | Düşük | — |
| `WidgetHealthView.swift:93` | "Uygulamaya iletilecek dokunuş" | "Widget'ta bekleyen dokunuş" ya da "Teknik bilgiler"e taşı | A2 için ağır; kullanıcıya bir şey söylemiyor. | Düşük | — |
| `WidgetHealthView.swift:146–158`, `:221`, `:230` | "App Group", "Yalnızca zaman çizelgelerini yenile", "boş (Debug/simülatör)", "seed_words.json (yedek)" | Kapalı "Teknik bilgiler" içinde kalabilir; mağaza sürümünde gizlensin | Teknik adlar. | Düşük | is3-olcum (`DiagnosticsSwitch.showsInRelease`) |
| `WidgetGuideView.swift:22–28` | Kilitli ekran / Ana ekran seçiminin grup adı yok | `accessibilityLabel("Nereye ekleyeceksin?")` | Ayarlar'daki seçimler adlı. | Düşük | — |

Doğru olanlar: "iPhone widget'a “araç takımı” der.", adımlar ("**Özelleştir**'e dokun", "**Araç Takımı Ekle**'ye dokun"), "Her şey yolunda", "Widget ekli değil · Nasıl eklenir?".

### Açılış ve konular (`OnboardingView.swift`, `TopicPickerView.swift`, `DeckSummaryLine.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `OnboardingView.swift:101` | ↑ #9 | | | Orta | — |
| `OnboardingView.swift:199` | "İngilizcen ne düzeyde?" (alt satır "bu seviyeden") | "İngilizcen hangi seviyede?" | Aynı sayfada "düzey" ve "seviye". | Orta | — |
| `OnboardingView.swift:264` | "Kelimeyi önce widget'ta görürsün, sonra Tekrar'da kendini sınarsın." | "Kelimeyi önce widget'ta görürsün, sonra Tekrar'da hatırlamaya çalışırsın." | "kendini sınamak" A2 için ağır. | Düşük | — |
| `OnboardingView.swift:250`, `:276` | "Ayarlar > Yardım", "Ayarlar > Widget sağlığı" | "Ayarlar'da Yardım bölümü", "Ayarlar'da Widget sağlığı" | ">" VoiceOver'da "büyüktür" okunabilir. | Düşük | — |
| `OnboardingView.swift:226`; `TopicPickerView.swift:23` | "Konu listesi yok. Şimdilik bütün kelimeler gösterilecek." · "Konu listesi yok (içerik veritabanı yüklenmedi). Bütün kelimeler gösteriliyor." | İkisi de: "Konu listesi yüklenemedi. Şimdilik bütün kelimeler gelir." | Aynı durum, iki metin; teknik ad. | Düşük | — |
| `TopicPickerView.swift:37` | "Bir kelime birkaç konuda olabilir; toplamda bir kez sayılır. Öğrendiğin kelimelerin tekrarı her konuda sürer." | "Bir kelime birkaç konuda olabilir; bir kez sayılır. Bir konuyu kaldırsan da öğrendiğin kelimeler Tekrar'da sorulmaya devam eder." | İkinci cümle ne demek istediğini söylemiyor. | Orta | — |
| `TopicPickerView.swift:128` | "Tümü" + "Bütün konular, 933 kelime" | "Tümü" + "Tüm konular, 933 kelime" | Aynı satırda "Tümü" ve "Bütün"; özet satırı "Tüm konular: N kelime" diyor. | Düşük | — |
| `TopicPickerView.swift:323` (yedek ad) | Adı yazılmamış konular başlık düzeninde gelir: "İltifatlar ve Laf Sokmalar", "Günlük Argo ve Gündelik Dil", "Toplum, Medya ve Haberler", "Çevre ve İklim" (kartları varsa görünür) | Açık adlar: "İltifat ve laf sokma", "Argo ve gündelik dil", "Toplum ve haberler", "Çevre ve iklim" | Öteki konular cümle düzeninde ("Yemek ve içecek"). | Düşük | — |

Doğru olanlar: "Hangi konular ilgini çekiyor?", "İstediğin kadar seç. Hiç seçmezsen hepsi gelir.", "Tüm konularla devam" / "3 konuyla devam", seviye satırları, "Kelime az; widget aynı kelimeleri sık gösterir. Bir konu daha seçebilirsin."

### Rehber: Nasıl öğrenirim? (`LearningGuideView.swift`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `:161` | ↑ #13 | | | Orta | — |
| `:169` | ↑ #5 | | | Yüksek | is3-tekrar |
| `:765` | ↑ #2 ("Doğru!" örneği) | | | Yüksek | — |
| `:96–128` | "Kelime ilk basamağa döner." (Bilemedim), basamak süreleri | Kayma kuralı değişince: "Kelime iki basamak iner, sonraki turda yine sorulur." | İlkeler 2.3 kayma kuralı. Süreler koddan geliyor; cümleler elle. | Orta | is3-tekrar, fsrs |
| `:137` | "Buna “sınama etkisi” (testing effect) denir." | "Buna “sınama etkisi” denir." | Parantezde İngilizce terim. | Düşük | — |
| `:190` | "…kelimenin yanında bir mikrofon var. Ona dokun, önce dinle, sonra **Söyle**'ye bas ve kelimeyi yüksek sesle söyle." | "Akış'ta ve Sözlük'te kartlardaki **Söyle**'ye dokun. Önce dinle, sonra **Söyle**'ye dokunup kelimeyi yüksek sesle söyle." | Düğmenin adı "Söyle"; "bas" yerine "dokun". | Düşük | — |
| `:697` | "Önce kendin hatırlamaya çalış. Sonra düğmeye bas." | "… Sonra düğmeye dokun." | dokun. | Düşük | — |
| `:491` | "Dürüst cevap ver: “Zor” da doğru cevap sayılır." | "“Zor” da doğru cevap sayılır. Zorlandıysan Zor'u seç." | "Dürüst ol" suçlama gibi okunabilir (madde 11). | Düşük | — |

Doğru olanlar: "Görmek tek başına yetmez; kelime, hatırladıkça yerleşir.", "Bir gün atlarsan dert etme.", "Bir ayda yaklaşık 150 yeni kelime öğrenmeye başlarsın. Tekrarlarla kalıcı olurlar."

### Widget'lar (`ios/Widgets`, `ios/Shared`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `WordWidget.swift:13` | ↑ #12 | | | Orta | — |
| `AccessoryWordViews.swift:114–116` | ↑ #15 | | | Orta | is3-kilit |
| `HomeWordViews.swift:264` | VoiceOver "Yeni kelime: 14:30" ("yeni kelime 14:30" gibi duyuluyor) | Görünür metin kalsın (README madde 13); VoiceOver adı "Sonraki değişim: 14:30" | Widget sağlığındaki adla aynı. | Düşük | is3-kilit |
| `SpeakWordIntent.swift:17`; `WordIntents.swift:33` | Kestirme başlıkları "Kelimeyi seslendir", "Bu kelimeyi biliyorum" | "Kelimeyi dinle", "Biliyorum" | Widget düğmelerinin adıyla aynı olsun (terimler §3). | Düşük | — |

Doğru olanlar: "Sonraki kelime", "Biliyorum", "Kelimeyi dinle" (düğme adları), "Seviye A2", "Türkçesi: kaşık".

### Bildirimler (`ReminderPlanner.swift`, `ReminderText`)

| Yer | Şu anki | Önerilen | Gerekçe | Öncelik | Bağlı |
|---|---|---|---|---|---|
| `:147–148`, `:156`, `:200` | ↑ #4 | | | Yüksek | is3-bildirim |
| `:152`, `:154` | "Hatırlıyor musun: breakfast?" · "breakfast ne demekti?" (Tekrar'da sırası gelmiş kelime) | Koordinatör kararı: ilkelerin 1b kararı "bilgi taşıyan bildirim" ("borrow = ödünç almak"); soru biçimi [BELKİ] ve yalnız içerik uzantısıyla. Bildirimdeki kelime, 6 saat içinde Tekrar'da sorulacak kelime olamaz (2.10). | Metin kurallara uyuyor: ek yok, suçlama yok. Ama şablon seçimi ilkelerle çelişiyor. | Orta | is3-bildirim, is3-widgetsira (`QueueComposer.lastAnswer` aynı kural) |

Doğru olanlar: "Unuttuysan sorun değil, tekrar bunun için var.", "Sırada spoon var.", "Anlamı: kaşık. Örnek cümlesi uygulamada.", sayısız başlıklar, ünlem ve emoji yok.

## VoiceOver özeti

Ayrı denetçinin bulguları (kodda yeniden bakıldı). Simgesi tek başına duran bütün düğmelerin adı var. İngilizce ses için üç yardımcı var: `englishVoice()`, `cardEnglishVoice()`, `widgetEnglishVoice()`. Raporda yukarıda geçmeyenler:

- **Aynı düğmenin farklı adları:**
  - Dinle: "Dinle" / "Kelimeyi dinle" / "Kelimeyi seslendir".
  - Biliyorum: "Biliyorum" / "Biliyorum olarak işaretle" / "Bu kelimeyi biliyorum".
  - Geri al: "Geri al" / "Öğrenmeye geri al".
  - Hepsi terimler.md'de tek ada bağlandı. Kısa "Geri al" ve uzun "Biliyorum olarak işaretle" ilkeler 2.6 yüzünden yerinde kaldı.
- **Duyurusu olmayan değişiklikler** (önceki raporda V7):
  - Akış'ta "Biliyorum";
  - Sözlük durum düğmeleri;
  - açılışta sayfa değişimi;
  - Söyle'nin hazırlık ve sorun durumları;
  - bildirim izni reddi;
  - sıfırlama;
  - widget yenileme.
- **"·" işareti** (`SettingsView.swift:215`, `WidgetHealthView.swift:202`, satır içi widget): cihazda nasıl okunduğuna bakılmalı.
- **Önceki raporun (`erisilebilirlik_2026-10-22.md`) VoiceOver maddeleri bu commit'te:**
  - Düzeldi: V1, V2, V10.
  - Kısmen düzeldi: V3, V8, V9.
  - Hâlâ duruyor: V4, V11.
  - Karışık: V5, V7, V12.

## Birleştirmeden sonra yeniden bakılacaklar

- **is3-quiz:** #1, #8, quiz ipuçları. "Doğru!"daki ünlem.
- **is3-tekrar:** #3, #5, #6, #10, Tekrar'daki iki metin (`:451`, `:784`), rehberdeki basamak cümleleri, özetin ikinci yarısı.
- **is3-akis:** "Biliyorum" alt bildirimi ("Tamam. N gün sonra bir kez soracağız."): N, 3 gün kuralıyla 3 olmalı. "Geri al" ipucu.
- **is3-bildirim:** #4 ve şablon seçimi. Ayarlar'daki açıklama (`SettingsView.swift:336`).
- **is3-ayarlar:** #11, pil notu, widget onarım adımları.
- **is3-kilit:** #15 ve "Yeni kelime: …" VoiceOver adı.
- **is3-olcum:** #2, #14 ve Söyle hata ayrıntısı.
- **UI testleri:** `LockglowScreenshotTests.swift:38` ("Anlamı göster") ve `:88` ("Bildiğim kelime") metinle birlikte değişmeli.

Birleştirmeden sonra betiği yeniden çalıştır. `--isaret` ve `--terim` çıktısı yeni metinleri de tarar.

## Betik hakkında

`docs/denetim/araclar/metin_cikar.py` (yalnız standart kütüphane):
- Swift dize sabitlerini okur. Yorumları ve `#Preview` gövdelerini atlar; `\(…)` aradeğerlerini olduğu gibi bırakır.
- Her dizenin içinde durduğu çağrıyı bulur ve türünü ona göre seçer (görünür, sesli, iletişim, bildirim, izin, değer).
- Türkçe harfi olmayan metinler için iki yol kullanır: önce Türkçe harfli metinlerden bir sözcük listesi kurar, ayrıca kesme işaretli Türkçe ekleri tanır ("**Bitti**'ye dokun.").

Sınırları:
- `Text(cond ? "a" : "b")` gibi metinlerde ikisi de bulunur, ama türü "değer" olabilir.
- Kodda birleştirilen cümleler parça parça görünür (ör. `"Sıradaki tekrar: " + …`).
- İçerik veritabanındaki metinler (kart anlamları, Dikkat cümleleri) kapsam dışı.
- Kural işaretleri yalnız ipucudur; her biri elle okunmalı.
