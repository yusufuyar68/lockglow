# Ekran görüntüleri: 8 kare (6.3")

> **TASLAK (23 Ekim 2026).** Görseller: [`gorseller/6.3-1206x2622/`](gorseller/6.3-1206x2622/) (Türkçe başlıklar, zorunlu boy), [`gorseller/6.9-1320x2868/`](gorseller/6.9-1320x2868/) (isteğe bağlı büyük boy) ve [`gorseller/en-GB/`](gorseller/en-GB/) (İngilizce başlıklar, iki boy). Üreten betik: [`araclar/gorsel_uret.py`](araclar/gorsel_uret.py). Hiçbiri App Store Connect'e yüklenmedi.
>
> **Marka uyarısı:** "Lockglow" adı için TÜRKPATENT araması ve marka vekili görüşü bitmedi. Karelerde **ad ve ikon yok**; marka kesinleşene kadar da konmaz. Ad ve ikon kesinleşince kareler değişmeden kullanılabilir.

## Kurallar

- **Boyut:** zorunlu olan **6.3"** ("iPhone with Dynamic Island, medium display"): dikey **1206 × 2622**. 6.9" (1320 × 2868) isteğe bağlı ama yine de üretildi: Apple'ın 6.5" satırı "6.9" verilmezse gerekli" diyor, ifade çelişkili; ikisini de yüklemek güvenli. PNG, RGB, alfa kanalı yok. Boyut başına 1–10 kare ([Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), 23 Ekim 2026'da bakıldı).
- **Sıra:** aramada yalnız ilk 2–3 kare görünür. Başa, rakiplerde olmayan üç şey: kilitli ekranda Türkçe anlam, Türkçe konuşana özel **Dikkat** kutusu, widget'tan **ses** (`rakip_analizi.md` §2).
- **Gerçeği göster** (Kural 2.3.3): her kare uygulamanın gerçek ekran görüntüsü ya da gerçek widget çıktısı. Sayı yok (kart sayısı değiştikçe eskimesin; "10.000+" gibi şişirme hiç yok). Rozet, yıldız, "en iyi" yok (Kural 2.3.7, 2.3.14).
- **Başlık:** en çok 2 satır, satır başına en çok ~24 karakter. "Sen" diliyle, uygulamanın arayüzüyle aynı ton; ünlem yok. Her başlıkta bir İngilizce kelime: uygulamadaki gibi serif ve fosfor şeritli. Tek istisna 7. kare (ilerleme ekranında tek bir kelime öne çıkmıyor).
- **Alt satır:** tek satır, en çok ~46 karakter; başlığın sözünü ekrandaki kanıta bağlar.
- **Terimler:** `docs/tasarim/terimler.md` (ör. "kilitli ekran", "Tekrar", "Söyle", "Dinle"). Mağaza alt başlığındaki "Kilit Ekranında" ise arama içindir (`kayit_metinleri_tr.md` → "Alt başlık").
- **Görünüm:** Lockglow'un kâğıt rengi (`#F3F3EE`) ve fosfor sarısı (`#F5E829`). Rakiplerin koyu mor zemini, maskot, fotoğraf yok (Kural 4.3 kopya algısı). Bir kare (2.) koyu tema: uygulamanın gece görünümünü de gösterir.

## 8 kare

| # | Dosya | Başlık (TR) | Alt satır (TR) | Ekran (kaynak) | Neden bu sırada? |
|---|---|---|---|---|---|
| 1 | `01-kilitli-ekran` | Telefona her bakışta / bir kelime: **actually** | Kilitli ekranda, Türkçe anlamıyla | Montaj: koyu duvar kâğıdı, saat 9:41, gerçek kilitli ekran widget'ı (`rect-actually`) + yakın çekim | Ürünün çekirdeği: kelime, uygulama açılmadan gözüne çarpar. Yakın çekim küçük önizlemede de okunur. |
| 2 | `02-dikkat` | **breakfast** derken / hata nerede? | Türkçeden gelen hatayı doğrusuyla gösterir | Akış kartı, koyu tema (`1-akis`): Türkçe anlam, örnek ve Dikkat satırı "I did breakfast → I had breakfast" + "Neden?" yakın çekimi | Rakipte karşılığı olmayan en güçlü fark (630 kelimede Dikkat). Soru biçimi merak uyandırır; cevap ekranda. |
| 3 | `03-widget-dinle` | **misunderstanding** / nasıl okunur? | Uygulamayı açmadan, widget'tan dinle | Montaj: ana ekranda iki orta, iki küçük widget (açık ve koyu); Biliyorum, Dinle, Sonraki düğmeleri | Widget'tan ses ikinci büyük fark. Açık ve koyu widget birlikte. **Cihazda doğrulanmalı** (aşağıda). |
| 4 | `04-tanis-hatirla` | Görmek yetmez: / **corner** neydi? | Yeni kelimede önce tanış, sonra hemen hatırla | Tekrar, Hatırla sorusu: "Anlamını seç", 4 Türkçe şık (`13-tekrar-hatirla-soru`) | Öğrenme yöntemi: widget'ta görmek tekrar sayılmaz; kelime hemen bir kez hatırlanır (`ogrenme_ilkeleri.md` §1). |
| 5 | `05-soyle` | Sesli söyle: / **look forward to** | Telefon dinler; sesin kaydedilmez | Söyle sayfası, Kelime / Örnek cümle seçimi, "Ses telefondan çıkmaz ve kaydedilmez." (`8b-soyle-sayfasi`) | Cihaz içi telaffuz alıştırması ve gizlilik birlikte; rakiplerde böyle bir ekran yok. |
| 6 | `06-kendi-kelimen` | Kendi kelimeni ekle: / **binge-watch** | Widget'ta ve Tekrar'da karşına çıkar | Kendi kelimelerin listesi ve "binge-watch eklendi. Widget'ta ve Tekrar'da karşına çıkacak." bildirimi, yakın çekim (`15d-kendi-kelime-liste`) | Yeni özellik; alt satır uygulamanın kendi cümlesiyle aynı. Not: binge-watch kartlarda da var (UI testi öyle çekiyor); yeni çekimde kartlarda olmayan bir kelime (ör. doomscroll) daha doğru olur. |
| 7 | `07-ilerleme` | Seri yok, baskı yok: / kendi hızında ilerle | Reklam yok, hesap yok, takip yok | İlerleme: "Bu hafta 1 gün çalıştın. 5 yeni kelimeyle tanıştın.", kitaplık, bu haftanın kelimeleri (`14a-ilerleme`) | Sakin ilerleme ve gizlilik. "Reklam yok, hesap yok" artık tek başına fark değil (rakip analizi), bu yüzden sonda ve alt satırda. |
| 8 | `08-sozluk` | "kahvalti" yaz, / **breakfast** çıksın | Türkçe harfleri yazmasan da bulur | Sözlük: "kahvalti" (ı yerine i) aranınca breakfast (`16d-sozluk-kahvalti`) | Küçük ama somut ve rakipte yok. Klavye yer kapladığı için en sonda. |

**Neden 8 kare?** Görev 7–8 kare istedi; her biri ayrı bir özellik. 9. ve 10. yer boş kalır: is5 oturumlarından gelen yeni özellikler (büyük widget, etkileşimli quiz widget'ı, yeni alıştırmalar) birleşince oraya eklenebilir.

**Kullanılmayan ekranlar:**
- Açılış (seviye, konular): başlıkta gösterecek bir kelime yok ve uygulamanın kullanımını az gösteriyor (Kural 2.3.3 kareler "uygulamayı kullanılırken" göstersin diyor).
- Boşluk doldurma (`17-tekrar-quiz-soru`, `-cevap`): iyi bir ekran ama 4. kare yöntemi zaten anlatıyor. 9. kare adayı ("Unutmadan önce **corner** yine gelir").
- Ayarlar, Widget sağlığı: simülatörde "Bilinmiyor" görünüyor; mağazada "bozuk" izlenimi verir.
- Tur özeti: sayılar ve "Bildim / Bilemedim" listesi; küçük önizlemede okunmaz.

## İngilizce (en-GB) başlıklar

İngilizce yerelleştirmede de **aynı Türkçe arayüz** görünür (uygulama Türkçe); başlıklar İngilizce. Görseller `gorseller/en-GB/6.3-1206x2622/` içinde. İngilizce kareler yüklenmezse App Store Connect Türkçe kareleri kullanır.

| # | Başlık (EN) | Alt satır (EN) |
|---|---|---|
| 1 | A word every time / you look: **actually** | On your Lock Screen, with its Turkish meaning |
| 2 | Where's the mistake / with **breakfast**? | Common mistakes of Turkish speakers, put right |
| 3 | How do you say / **misunderstanding**? | Listen from the widget, without opening the app |
| 4 | Seeing is not enough: / what was **corner**? | Meet a new word, then recall it straight away |
| 5 | Say it out loud: / **look forward to** | Your phone listens; nothing is recorded |
| 6 | Add your own word: / **binge-watch** | It turns up on your widget and in Tekrar |
| 7 | No streaks, no pressure: / learn at your own pace | No ads, no account, no tracking |
| 8 | Type "kahvalti", / get **breakfast** | Finds words even without Turkish letters |

## Neyin gerçek, neyin montaj olduğu

- **2, 4–8:** telefonun içi, `screenshots.yml` çalıştırmalarının gerçek 6.3" ekran görüntüleri; hiç değiştirilmedi. Durum çubuğu simülatörün (9:41).
  - 4–8: run `39876481512` (`entegrasyon-4` aa7ef5d, 23 Ekim gece; `pro` geçişi, açık tema). Çalıştırma süre sınırında durdu ama bu geçişin görüntüleri yüklendi.
  - 2: run `39863210580` (`main` bf90b74, `pro-koyu` geçişi). Aynı geçişin açık tema Akış çekimi iki çalıştırmada da zaman aşımına uğradı. Akış kartının kodu (`FeedView.swift`, `CardDetailViews.swift`) bf90b74'ten aa7ef5d'ye değişmedi; yalnız örnek cümle yazısı 17'den 18 pt'ye büyüdü (`LockglowTheme.swift`). Görsel fark çok küçük.
- **1 (kilitli ekran):** duvar kâğıdı, tarih ve saat çizildi. Widget, `WidgetSnapshotTests`'in gerçek kilitli ekran çıktısı (`rect-actually`); gri test plakası iOS'un yarı saydam görünümüne çevrildi. Durum simgeleri gerçek ekran görüntüsünden.
- **3 (ana ekran):** duvar kâğıdı, saat ve "Ara" kapsülü çizildi. Widget'lar gerçek çıktılar (`medium-misunderstanding`, `small-fridge-koyu`, `small-actually`, `medium-under the weather-koyu`), 6.3" ekrandaki boylarında (orta 338 × 158 pt, küçük 158 × 158 pt). Başka uygulama ikonu yok.
- **Yakın çekim (1, 2, 6):** ekranın bir bölümü büyütülüp beyaz kenarlı bir kart olarak telefonun üstüne kondu. İçerik aynı.

## Göndermeden önce

1. **3. kare:** widget'taki Dinle düğmesi uygulama açılmadan ses çıkarıyor mu? Cihazda dene (`ios/README.md` kontrol listesi, açık madde). Çalışmazsa kareyi çıkar ya da alt satırı "Kelimeyi widget'tan da dinle" yap ve videodaki 2. sahneyi değiştir (Kural 2.3.3).
2. **1. kare:** mümkünse gerçek bir iPhone'dan alınmış kilitli ekran görüntüsüyle değiştir (montaj kabul edilir ama gerçek çekim daha güvenli). Kilitli ekranda başka widget ve bildirim olmasın.
3. **5. kare:** "Anlaşıldı!" sonucu gerçek konuşma ister; gerçek iPhone'dan çekilirse daha güçlü olur. Betik önce `8c-soyle-sonuc` adını arar: o adla bir görüntü verilirse kendiliğinden onu kullanır.
4. **2. kare:** bir sonraki tam çekimde açık tema `1-akis` gelirse betik onu kullanır (kaynak listesinde ilk sırada).
5. **Paralel tasarım işleri** (is5-akis-tasarim, is5-sozluk-tasarim, is5-w-tasarim, is5-w-cila) birleşirse ekranlar değişir: `screenshots.yml` bir kez çalıştırılıp kareler yeniden üretilir (`gorseller/README.md` → "Nasıl üretilir?").

## Yeniden çekim notları

- `screenshots.yml` geçişleri: `se`, `pro` (6.3", mağaza boyutu), `pro-koyu`; istenirse `promax`. Görüntüler artifact'te `shots/<geçiş>/` (manifest.json ile) ve iş tamamlanırsa `named/<geçiş>/<ad>.png`.
- Widget çıktıları yalnız ilk geçişte üretilir (`se`); betik onları `--widgetlar` klasöründen alır.
- `pro` geçişinde `testCaptureMainScreens` (Akış, Sözlük kartı, Ayarlar) 23 Ekim gecesi zaman aşımına uğradı ("Timed out while evaluating UI query"). Tekrar ederse ekran görüntüsü testlerinin sahibine bildirilmeli.
- Simülatörde çekilemeyenler: kilitli ekran, Söyle "Anlaşıldı!" sonucu, Widget sağlığı "Çalışıyor". Bunlar gerçek iPhone'dan.
