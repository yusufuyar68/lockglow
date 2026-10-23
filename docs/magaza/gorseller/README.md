# App Store tanıtım görselleri (TASLAK, 23 Ekim 2026)

> **Marka uyarısı:** "Lockglow" adı için TÜRKPATENT araması ve marka vekili görüşü bitmedi. Bu görseller **taslaktır**. Görsellerde ad ve ikon bilerek yok; marka kesinleşene kadar konmaz. Ad değişse de kareler kullanılabilir.
>
> Hiçbir görsel App Store Connect'e yüklenmedi. Yüklemek kullanıcının işidir.

Senaryo, başlıklar ve sıra: [`../ekran_goruntusu_basliklari.md`](../ekran_goruntusu_basliklari.md).

## Klasörler

| Klasör | Boyut | Ne |
|---|---|---|
| [`6.3-1206x2622/`](6.3-1206x2622/) | 1206 × 2622 | 8 kare, **Türkçe başlıklar**. Apple'ın zorunlu iPhone boyutu ("iPhone with Dynamic Island, medium display") |
| [`6.9-1320x2868/`](6.9-1320x2868/) | 1320 × 2868 | Aynı 8 kare, Türkçe, büyük ekran ("large display", Pro Max). İsteğe bağlı |
| [`en-GB/6.3-1206x2622/`](en-GB/6.3-1206x2622/), [`en-GB/6.9-1320x2868/`](en-GB/6.9-1320x2868/) | iki boy | Aynı 8 kare, **İngilizce başlıklar** (English (U.K.) yerelleştirmesi için; telefonun içi yine Türkçe) |

Hepsi PNG, RGB, alfa kanalı yok (Apple saydamlık kabul etmiyor).

- **Neden 6.9" de var?** Apple'ın sayfası 6.3"ü zorunlu, 6.9"u isteğe bağlı sayıyor; ama 6.5" (Face ID) satırında "6.9" verilmezse gerekli" yazıyor ve ifade çelişkili. Güvenli yol ikisini de yüklemek. 22 Ekim'deki 6.9" kareler eski ekranları gösterdiği için yenileriyle değiştirildi.
- **Kaynak hep 6.3" çekim:** yeni `screenshots.yml` mağaza boyutunda (iPhone NN Pro) çekiyor. 6.9" karede telefon görselin %80'i kadar çizildiği için kaynak büyütülmez, yalnız küçültülür.

## Kareler

| # | Dosya | Başlık (TR) | Ekran |
|---|---|---|---|
| 1 | `01-kilitli-ekran.png` | Telefona her bakışta bir kelime: **actually** | Kilitli ekran montajı + widget yakın çekimi |
| 2 | `02-dikkat.png` | **breakfast** derken hata nerede? | Akış kartı (koyu tema) + Dikkat satırı yakın çekimi |
| 3 | `03-widget-dinle.png` | **misunderstanding** nasıl okunur? | Ana ekran montajı: iki orta, iki küçük widget |
| 4 | `04-tanis-hatirla.png` | Görmek yetmez: **corner** neydi? | Tekrar, Hatırla sorusu |
| 5 | `05-soyle.png` | Sesli söyle: **look forward to** | Söyle sayfası |
| 6 | `06-kendi-kelimen.png` | Kendi kelimeni ekle: **binge-watch** | Kendi kelimelerin + "eklendi" bildirimi yakın çekimi |
| 7 | `07-ilerleme.png` | Seri yok, baskı yok: kendi hızında ilerle | İlerleme (Kitaplığın) |
| 8 | `08-sozluk.png` | "kahvalti" yaz, **breakfast** çıksın | Sözlük, ı yerine i ile arama |

Gerekçeler ve İngilizce başlıklar: [`../ekran_goruntusu_basliklari.md`](../ekran_goruntusu_basliklari.md).

**Başlık kuralı:** her başlıkta (7. kare hariç) tek bir İngilizce kelime var; uygulamadaki gibi serif yazılır ve fosfor şeridi alır. Geri kalan her şey kâğıt ve mürekkep. Başlıklar en çok 2 satır; bütün karelerde başlık boyutu aynı (en uzun satır belirler). Alt satır tek satır; sığmazsa küçülür. Sayı yok (kart sayısı değiştikçe görsel eskimesin; Kural 2.3.3).

## Neyin gerçek, neyin montaj olduğu

- **2, 4–8:** telefonun içi gerçek simülatör ekran görüntüsü; hiç değiştirilmedi. Durum çubuğu 9:41.
- **1 (kilitli ekran):** duvar kâğıdı, tarih ve saat çizildi. Widget, `WidgetSnapshotTests`'in gerçek kilitli ekran çıktısı (`rect-actually`); gri test plakası iOS'un yarı saydam görünümüne çevrildi. Sinyal, Wi-Fi ve pil simgeleri gerçek ekran görüntüsünden.
- **3 (ana ekran):** duvar kâğıdı, saat ve "Ara" kapsülü çizildi. Widget'lar gerçek çıktılar (`medium-misunderstanding`, `small-fridge-koyu`, `small-actually`, `medium-under the weather-koyu`), 6.3" ekrandaki boylarında (orta 338 × 158 pt, küçük 158 × 158 pt). Başka uygulama ikonu yok.
- **Yakın çekim (1, 2, 6):** ekranın bir bölümü büyütülüp beyaz kenarlı bir kart olarak telefonun üstüne kondu. İçerik aynı.

## Kaynak görüntüler

| Kare | Çalıştırma | Geçiş | Not |
|---|---|---|---|
| 4–8 | `screenshots` run **39876481512** (`entegrasyon-4` aa7ef5d = bugünkü `main`) | `pro` (açık) | Çalıştırma 130 dk sınırında durdu; `pro` geçişinin görüntüleri yine de yüklendi. `named/` klasörü oluşmadı; betik `shots/pro/manifest.json` ile okur |
| 1, 3 (widget'lar) | aynı run | `se` (widget çıktıları ilk geçişte) | |
| 2 | run **39863210580** (`main` bf90b74) | `pro-koyu` | Açık tema `1-akis` iki çalıştırmada da zaman aşımına uğradı (`testCaptureMainScreens`). Akış kartının kodu o günden beri aynı; yalnız örnek cümle yazısı 17'den 18 pt'ye büyüdü |

Artifact'ler 7 gün saklanır (22–23 Ekim'den). Süre geçerse yeni bir `screenshots.yml` çalıştırması gerekir.

## Göndermeden önce

1. **3. kare için cihazda dene:** widget'taki Dinle düğmesi uygulama açılmadan ses çıkarıyor mu? (`ios/README.md` kontrol listesi, açık madde). Çalışmıyorsa 3. kareyi çıkar ya da alt satırı değiştir (Kural 2.3.3).
2. **Kilitli ekran:** mümkünse 1. kareyi gerçek bir iPhone'dan alınmış kilitli ekran görüntüsüyle değiştir.
3. **Söyle:** "Anlaşıldı!" sonucu yalnız gerçek konuşmayla çıkar. Gerçek iPhone'dan alınan görüntü `8c-soyle-sonuc.png` adıyla kaynak klasöre konursa betik onu kullanır.
4. **Ad ve ikon kesinleşince** görsellerin değişmesi gerekmez. İstenirse ikon eklenebilir.
5. **Arayüz değişirse** (is5 tasarım oturumları birleşince) yeniden üret (aşağıda).

## Nasıl üretilir?

Betik: [`../araclar/gorsel_uret.py`](../araclar/gorsel_uret.py) (Pillow). Başlıklar ve kare listesi betiğin başındaki `KARELER` içinde.

```bash
gh run download <id> -R yusufuyar68/lockglow -n screenshots -D <klasör>
```

```bash
python -X utf8 docs/magaza/araclar/gorsel_uret.py --kaynak <klasör>/shots/pro --widgetlar <klasör>/shots/se --dil tr en
```

- `--kaynak` birden çok klasör alır; adlar sırayla aranır (ör. eksik bir ekran için başka bir çalıştırmanın klasörü). İş tamamlandıysa `<klasör>/named/pro` da olur.
- `--boyut 6.3 6.9 6.5`: hangi boyutlar (varsayılan 6.3); `--dil tr en`: başlık dili (en → `en-GB/` alt klasörü); `--sadece 01 04`: yalnız bu kareler.
- Yakın çekim kutuları 402 pt genişliğindeki ekrana göre (iPhone NN Pro). Ekran düzeni değişirse kutular `KARELER` içinde düzeltilir.
- Pillow yoksa: `python -m pip install pillow`.

### Yazı tipleri ve lisans

| Kullanım | Yazı tipi | Lisans | Bu bilgisayarda nerede bulundu? |
|---|---|---|---|
| Başlık ve alt satır | **Inter** (değişken; başlık 800, alt satır 500) | SIL Open Font License 1.1 | D5 Launcher'ın içinde (`%APPDATA%\D5\D5 Launcher\assets\Inter-V-*.ttf`) |
| İngilizce kelime | **KaTeX_Main Bold** (Computer Modern tabanlı serif) | MIT (Khan Academy, `KaTeX/katex-fonts`) | Bir Chrome eklentisinin içinde (`…\Extensions\…\assets\KaTeX_Main-Bold-*.ttf`) |

- Yazı tipi dosyaları depoya **eklenmedi**. Betik onları bilgisayarda arar; bulamazsa `--sans` / `--serif` ile yol verilir (ya da `LOCKGLOW_SANS` / `LOCKGLOW_SERIF`).
- Inter, SF Pro'ya en yakın serbest yazı. Başka bilgisayarda [rsms.me/inter](https://rsms.me/inter/) adresinden indirilebilir.
- **SF Pro ve New York kullanılmadı:** Apple'ın lisansı bunları yalnızca Apple platformları için arayüz taslağında kullanmaya izin veriyor. Telefonun içindeki yazılar uygulamanın kendi ekran görüntüsü olduğu için orada SF Pro ve New York görünür; bu normal.

## Renkler

`ios/Shared/LockglowTheme.swift` açık tema: zemin `#F3F3EE`, mürekkep `#15181B`, ikincil yazı `#4E555B`, fosfor şeridi `#F5E829`. Şerit uygulamadaki gibi: harflerin alt kısmının arkasında, uçları eğik.
