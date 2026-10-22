# App Store tanıtım görselleri (TASLAK, 22 Ekim 2026)

> **Marka uyarısı:** "Lockglow" adı için TÜRKPATENT araması ve marka vekili görüşü bitmedi. Bu görseller **taslaktır**. Görsellerde ad ve ikon bilerek yok; ad değişse de kareler kullanılabilir.
>
> Hiçbir görsel App Store Connect'e yüklenmedi. Yüklemek kullanıcının işidir.

## Klasörler

| Klasör | Boyut | Apple'daki adı | Gerekli mi? |
|---|---|---|---|
| [`6.9-1320x2868/`](6.9-1320x2868/) | 1320 × 2868 | iPhone with Dynamic Island (large display): 16/17 Pro Max | En büyük ekran; yüklenmesi önerilir |
| [`6.3-1206x2622/`](6.3-1206x2622/) | 1206 × 2622 | iPhone with Dynamic Island (medium display): 16/17 Pro, 17 | **Zorunlu** (aşağıya bak) |

Hepsi PNG, RGB, alfa kanalı yok (Apple saydamlık kabul etmiyor).

## Boyutlar: Apple ne diyor? (22 Ekim 2026'da bakıldı)

Kaynak: [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications).

- **Zorunlu olan:** sayfanın başında "iPhone: At least one screenshot for iPhone with Dynamic Island (medium display)" yazıyor. Bu boyutlar **1206 × 2622** ya da 1179 × 2556.
- **6.9" (large):** 1260 × 2736, 1290 × 2796 ya da **1320 × 2868**. Zorunlu diye yazmıyor.
- **6.5" (Face ID, large):** 1284 × 2778 ya da 1242 × 2688. Yalnızca 6.9" görüntü verilmezse zorunlu. 6.9" verdiğimiz için gerekmez. Betik isterse bunu da üretir (`--boyut 6.5`).
- Cihaz boyutu başına en az 1, en çok 10 görüntü. `.png`, `.jpg` ya da `.jpeg`. Alfa kanalı ve saydamlık olmaz.

[`../ekran_goruntusu_basliklari.md`](../ekran_goruntusu_basliklari.md) de bu kurala göre güncellendi (22 Ekim, `is4-ekran`): zorunlu boyut 6.3" (1206 × 2622).

## Sıra ve gerekçe

Aramada yalnızca ilk 2–3 kare görünür. Bu yüzden en güçlü üçü başta: **widget, kelime kartı, Tekrar.**

| # | Dosya | Başlık | Alt satır | Ekran | Neden bu sırada? |
|---|---|---|---|---|---|
| 1 | `01-kilit-ekrani-widget.png` | Telefona her bakışta yeni kelime: **actually** | Kilit ekranında, Türkçe anlamıyla | Kilit ekranı montajı + widget'ın yakın çekimi | Uygulamanın asıl farkı: kelime, uygulama açılmadan gözüne çarpar. Yakın çekim, küçük önizlemede de okunsun diye. |
| 2 | `02-kelime-karti.png` | **breakfast** ne demek? | Türkçesi, örneği ve sesi tek kartta | `1-akis` | "Türkçe açıklamalı" vaadini tek bakışta gösterir. Soru biçimi merak uyandırır; cevap (kahvaltı) ekranda. |
| 3 | `03-tekrar.png` | Unutmadan önce **breakfast** yine gelir | Bildiğine göre tekrar zamanı ayarlanır | `5-tekrar-kart-arka` + cevap düğmelerinin yakın çekimi | Öğrenme yöntemini anlatır. Dört cevap ve süreleri ("10 dakika sonra" … "2 gün sonra") büyütülerek gösterilir; böylece 2. kareden ayrışır. |
| 4 | `04-widget-dinle.png` | **misunderstanding** nasıl okunur? | Uygulamayı açmadan, widget'tan dinle | Ana ekran montajı: iki orta + iki küçük widget | Widget'taki Dinle, Biliyorum, Sonraki düğmeleri. Açık ve koyu widget birlikte. |
| 5 | `05-dikkat.png` | **spoon** derken hata nerede? | Türkçeden gelen hatayı doğrusuyla gösterir | `2-akis-ikinci-kart` + Dikkat kutusunun yakın çekimi | Türkçe konuşanların sık yaptığı hatayı ve nedenini gösterir; yalnız çeviri veren uygulamalardan ayrılır. |
| 6 | `06-soyle.png` | Sesli söyle: **look forward to** | Sesin kaydedilmez, hiçbir yere gönderilmez | `8b-soyle-sayfasi` | Söyleme alıştırması ve gizlilik. Uygulama ekranda "Ses telefondan çıkmaz ve kaydedilmez" diyor; alt satır bunu karışmayacak biçimde söylüyor. |
| 7 | `07-sozluk.png` | Türkçesini yaz, **breakfast** çıksın | Birkaç harf yazman yeter | `7-sozluk-arama` | Ekranda "kahv" yazınca breakfast çıkıyor; alt satır tam bunu söylüyor. Sözlük yardımcı bir özellik; en sona. Klavye yer kapladığı için görsel olarak en zayıf kare. |

**Başlık kuralı:** her başlıkta tek bir İngilizce kelime var. O kelime uygulamadaki gibi serif yazılır ve fosfor şeridi alır. Geri kalan her şey kâğıt ve mürekkep. Tek istisna 6. kare: "look forward to" üç kelimelik bir kalıp ama uygulamada tek kart (tek "kelime").

Başlıklar en çok 2 satır. Sayı yok (kart sayısı değiştikçe görsel eskimesin; Kural 2.3.3). Bütün karelerde başlık boyutu aynı; en uzun satır ("misunderstanding") boyutu belirler.

**Bağımsız denetim (22 Ekim):** bir denetçi ajan bütün kareleri inceledi. Önerilerinden şunlar uygulandı:
- 1. karenin başlığı ("actually öğren", "aslında öğren" gibi okunuyordu);
- 3, 5, 6 ve 7. karelerin alt satırları;
- 3. karede cevap düğmelerinin yakın çekimi;
- 4. karedeki boşluk;
- montajlardaki saat (gerçek çekimlerle aynı, 9:45).

Önerdiği sıra (01, 02, 04, 05, 03, …) uygulanmadı: görev ilk üç için widget, kelime kartı ve Tekrar'ı istedi.

## Neyin gerçek, neyin montaj olduğu

- **2, 3, 5, 6, 7:** telefonun içi, `screenshots.yml` çalıştırmasının gerçek Pro Max ekran görüntüsü. Hiç değiştirilmedi. Durum çubuğundaki saat gerçek çekimdeki gibi (9:45, 9:46).
- **1 (kilit ekranı):** duvar kâğıdı, tarih ve saat (9:45) çizildi. Widget, `WidgetSnapshotTests`'in gerçek kilit ekranı çıktısı (`rect-actually`). Gri test plakası, iOS'un kilit ekranındaki yarı saydam görünüme çevrildi. Wi-Fi ve pil simgeleri gerçek ekran görüntüsünden alındı.
- **4 (ana ekran):** duvar kâğıdı, saat ve "Ara" kapsülü çizildi. Widget'lar gerçek çıktılar (`medium-misunderstanding`, `small-fridge-koyu`, `small-actually`, `medium-under the weather-koyu`), Pro Max widget boyutuna (364 × 170 pt, 170 × 170 pt) getirildi. Başka uygulama ikonu yok.
- **Yakın çekim (1, 3 ve 5):** ekranın bir bölümü büyütülüp beyaz kenarlı bir kart olarak telefonun üstüne kondu. İçerik aynı.

## Göndermeden önce

1. **4. kare için cihazda dene:** widget'taki Dinle düğmesi uygulama açılmadan ses çıkarıyor mu? `docs/tasarim/README.md` bunu "cihazda denenmeli" diye listeliyor. Çalışmıyorsa 4. kareyi çıkar ya da alt satırı değiştir (Kural 2.3.3: görseller doğru olmalı).
2. **Kilit ekranı:** mümkünse 1. kareyi gerçek bir cihazdan alınmış kilit ekranı görüntüsüyle değiştir. Montaj kabul edilebilir ama gerçek çekim daha güvenli.
3. **Ad kesinleşince** görsellerin değişmesi gerekmez (ad yok). İkon kesinleşirse istenirse eklenebilir.
4. Görüntüler `ios/arayuz-sik` dalının 22 Ekim çekiminden. Arayüz değişirse yeniden üret (aşağıda).

### Sonraki çekimde (screenshots.yml tek turda)

- **Durum çubuğu:** saat 9:41, tam sinyal ve tam pil. Şimdi gri "operatör yok" noktaları ve 9:45/9:46 görünüyor. Simülatörde `xcrun simctl status_bar <cihaz> override --time 9:41 --cellularBars 4 --batteryLevel 100` ile ayarlanır. Montajlardaki saat de `gorsel_uret.py` içindeki `SAAT` ile 9:41 yapılır.
- **Söyle:** "Doğru!" sonucuyla çekilsin. Şimdiki çekim 1. adımda (Dinle); arkadaki sayfanın altında yarım bir satır görünüyor.
- **Kelime çeşitliliği:** 2, 3 ve 7. karede aynı kelime (breakfast) var. Tekrar ve Sözlük başka bir kelimeyle çekilirse kareler birbirinden daha çok ayrışır.
- **Sözlük:** "kahvalti" (ı yerine i) yazılarak çekilirse "ı/i karışsa da bulur" özelliği de görünür.
- **Quiz:** Pro Max'te tam ekran quiz çekimi ("Boşluğu doldur" karesi için).
- **Uygulama metni:** Söyle sayfasındaki "Ses telefondan çıkmaz" cümlesi "telefondan ses çıkmaz" gibi de okunabiliyor. Ayrı bir iş olarak düşünülebilir (ör. "Sesin kaydedilmez, telefonunda kalır").

## Kullanılmayan ekranlar

- **Seviye seçimi, Konular:** başlıkta İngilizce kelime yok; konu sayıları değiştikçe eskir.
- **Ayarlar:** "Widget sağlığı: Bilinmiyor" görünüyor; mağazada "bozuk" izlenimi verebilir.
- **Quiz:** Pro Max'te tam ekran çekim yok, yalnızca kart parçası (750 piksel genişlik). Yeni çekimde eklenebilir ("Boşluğu doldur").
- **Nasıl öğrenirim?:** çok yazı var; küçük önizlemede okunmaz.

## Nasıl üretilir?

Betik: [`../araclar/gorsel_uret.py`](../araclar/gorsel_uret.py) (Pillow). Başlıklar ve kare listesi betiğin başındaki `KARELER` içinde.

```bash
gh run download 39753249085 -R yusufuyar68/lockglow -n screenshots -D <klasör>
```

```bash
python -X utf8 docs/magaza/araclar/gorsel_uret.py --kaynak <klasör>/shots/large
```

- Kaynak: 22 Ekim 2026 `screenshots` çalıştırması (run `39753249085`, dal `ios/arayuz-sik`). Betik `manifest.json` ile "1-akis" gibi adları gerçek dosyaya eşler.
- `--boyut 6.9 6.3 6.5`: hangi boyutlar; `--sadece 01 04`: yalnız bu kareler.
- Pillow yoksa: `python -m pip install pillow`.

### Yazı tipleri ve lisans

| Kullanım | Yazı tipi | Lisans | Bu bilgisayarda nerede bulundu? |
|---|---|---|---|
| Türkçe başlık ve alt satır | **Inter** (değişken; başlık 800, alt satır 500) | SIL Open Font License 1.1 | D5 Launcher'ın içinde (`%APPDATA%\D5\D5 Launcher\assets\Inter-V-*.ttf`) |
| İngilizce kelime | **KaTeX_Main Bold** (Computer Modern tabanlı serif) | MIT (Khan Academy, `KaTeX/katex-fonts`) | Bir Chrome eklentisinin içinde (`…\Extensions\…\assets\KaTeX_Main-Bold-*.ttf`) |

- Yazı tipi dosyaları depoya **eklenmedi**. Betik onları bilgisayarda arar; bulamazsa `--sans` / `--serif` ile yol verilir (ya da `LOCKGLOW_SANS` / `LOCKGLOW_SERIF`).
- Inter, SF Pro'ya en yakın serbest yazı. Başka bilgisayarda [rsms.me/inter](https://rsms.me/inter/) adresinden indirilebilir.
- **SF Pro ve New York kullanılmadı:** Apple'ın lisansı bunları yalnızca Apple platformları için arayüz taslağında kullanmaya izin veriyor. Windows'taki Segoe UI ve Georgia da Microsoft'un; kullanılmadı.
- Telefonun içindeki yazılar uygulamanın kendi ekran görüntüsü olduğu için orada SF Pro ve New York görünür; bu normal.

## Renkler

`ios/Shared/LockglowTheme.swift` açık tema: zemin `#F3F3EE`, mürekkep `#15181B`, ikincil yazı `#4E555B`, fosfor şeridi `#F5E829`. Şerit uygulamadaki gibi: harflerin alt kısmının arkasında, uçları eğik.
