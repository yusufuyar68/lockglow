# App Store kayıt metinleri: Türkçe (tr)

> **TASLAK (22 Ekim 2026).** App Store Connect'e henüz girilmedi.
>
> **Marka uyarısı:** "Lockglow" adı için **TÜRKPATENT araması ve marka vekili görüşü yapılmadı.** Ad kesin değil. Ad değişirse aşağıdaki "Ad" alanı ve açıklamadaki "Lockglow" geçen yerler değişir.
>
> Kurallar ve sınırlar: [`README.md`](README.md) → "Apple sınırları ve kuralları". Metinler yalnızca **bugünkü uygulamada olan** özellikleri anlatır (dal `ios/arayuz-sik`, içerik `2026.10.21-kisisel-5`).

Uzunluklar Python'la sayıldı (`len()`, satır sonu 1 karakter). Anahtar kelime alanı **bayt** ile sınırlı; Türkçe harfler (ç, ğ, ı, İ, ö, ş, ü) UTF-8'de 2 bayttır.

## Özet

| Alan | Sınır | Öneri | Uzunluk |
|---|---|---|---|
| Ad | 30 karakter | `Lockglow: İngilizce Kelime` | 26 karakter |
| Alt başlık | 30 karakter | `Kilit Ekranında Ezberle, Öğren` | 30 karakter |
| Tanıtım metni | 170 karakter | aşağıda | 149 karakter |
| Açıklama | 4000 karakter | aşağıda | 3244 karakter |
| Anahtar kelimeler | 100 bayt | aşağıda | 91 karakter, 99 bayt |
| Bu sürümde yeni | 4000 karakter | 1.0'da alan yok; 1.1 kalıbı aşağıda | — |

## Ad

```text
Lockglow: İngilizce Kelime
```

26 karakter. "ingilizce" ve "kelime" Türkiye'de en çok aranan iki kelime; ada girdikleri için anahtar kelime alanında tekrar edilmez.

**Yedekler** (ad değişirse aynı kalıp): `<Ad>: İngilizce Kelime`. "Ücretsiz", "en iyi", "#1" ve başka uygulama adları **yazılmaz** (Kural 2.3.7, 4.1).

## Alt başlık

```text
Kilit Ekranında Ezberle, Öğren
```

30 karakter (sınırda). Ürünü ayıran şeyi (kilit ekranı) ve iki arama kelimesini (ezberle, öğren) taşır. Addaki kelimelerle birleşir: "ingilizce öğren", "kelime ezberle", "ingilizce kelime öğren".

**Yedekler:**

| Metin | Uzunluk | Not |
|---|---|---|
| `Kilit Ekranında Kelime Ezberle` | 30 | Daha doğal ama "kelime" addakini tekrar eder; "öğren" kaybolur |
| `Widget ile Ezberle, Telaffuz Et` | 31 | **Sınırı aşar** |
| `Ezberle, Öğren, Telaffuz Et` | 27 | Kilit ekranı farkı kaybolur |

## Tanıtım metni (promotional text)

```text
Telefonuna her bakışında bir İngilizce kelime: Türkçe anlamı, örneği ve sesiyle. Widget'tan dinle, Söyle ile telaffuzunu dene. Reklam yok, hesap yok.
```

149 karakter. Aramayı etkilemez; yeni sürüm göndermeden istenildiği zaman değişir. Yeni içerik destesi geldiğinde burası güncellenir (ör. "Yeni: Ev ve Alışveriş konuları").

## Açıklama

Önce fayda, sonra özellikler. Sayılar içerik veritabanından alındı (`ios/App/Resources/content.sqlite`, 22 Ekim 2026). İçerik değişirse sayıları güncelleyin.

```text
Günde onlarca kez telefonuna bakıyorsun. Lockglow her bakışı küçük bir İngilizce dersine çevirir: kilit ekranında ve ana ekranında, Türkçe anlamıyla bir kelime durur. Uygulamayı açmadan okursun, dinlersin, öğrenirsin.

Lockglow, günlük İngilizce öğrenen Türkçe konuşanlar için yapıldı. Kelimeler A1, A2 ve B1 seviyesinde: yemekten seyahate, sağlıktan iş yerine, her gün kullanacağın İngilizce.

NEDEN İŞE YARAR
• Her gün biraz: Kelime, sen başka bir iş yaparken gözünün önüne gelir.
• Türkçe açıklama: Her kartta Türkçe anlam, örnek cümle ve cümlenin Türkçesi var.
• Unutmadan önce tekrar: Zorlandığın kelime sık, iyi bildiğin kelime seyrek gelir.
• Hatayı baştan gör: Birçok kartta Türkçe konuşanların sık yaptığı hata ve doğrusu var. Örneğin "I did breakfast" değil, "I had breakfast".

KİLİT EKRANI VE ANA EKRAN WIDGET'LARI
• Ana ekranda küçük ve orta widget; kilit ekranında dikdörtgen ve tek satırlık widget.
• Ana ekran widget'ında "Kelimeyi dinle": uygulama açılmadan kelimeyi sesli okur.
• "Biliyorum" ve "Sonraki" düğmeleri ana ekran widget'ının üstünde.
• Kelimenin ne sıklıkla değişeceğini sen seçersin: 5 dakikadan 2 saate kadar.
• Widget sağlığı ekranı, widget'ın güncellenip güncellenmediğini gösterir.

933 KELİME KARTI
• 179 A1, 418 A2 ve 336 B1 kartı.
• 668 kelime, 132 phrasal verb, kalıp ifadeler ve eşdizimler.
• Okunuş (IPA), Türkçe anlam, kısa İngilizce tanım; yaklaşık 2.800 örnek cümle ve Türkçeleri.
• 571 kartta "Dikkat" kutusu: yanlış ve doğru kullanım, kısa Türkçe açıklamayla.

TEKRAR VE QUIZ
• Yeni kelimede dört cevap: Bilemedim, Zor, Bildim, Kolay. Kelimenin ne zaman yeniden geleceği düğmede yazar.
• Leitner kutu sistemi: Kelime, zamanı gelince yeniden sorulur.
• Zamanı gelen kelimede dört şıklı boşluk doldurma. Yanlış seçersen doğru cevabı ve anlamını hemen görürsün.
• Günlük yeni kelime hedefi: 5, 10, 15 ya da 20.

SÖYLE: TELAFFUZ ALIŞTIRMASI
• Kelimeyi ya da örnek cümleyi sesli söyle. Telefon dinler ve Türkçe cevap verir: "Doğru!", "Neredeyse!" ya da neye dikkat etmen gerektiği.
• Tanıma yalnızca iPhone'unda yapılır. Sesin kaydedilmez ve telefondan çıkmaz.

SÖZLÜK
• Bütün kartlarda İngilizce ya da Türkçe ara.
• "ı/i", "ş/s", "ğ/g" gibi harfleri karıştırsan da bulur.
• Her kelimede örnek cümleler ve ses düğmesi.

SANA GÖRE BAŞLA
• İlk açılışta seviyeni ve konularını seçersin; widget kurulumunu adım adım gösterir.
• Konulardan bazıları: yeme içme, ev, aile, alışveriş, sağlık, şehir ve ulaşım, seyahat, iş yeri, duygular, sosyal hayat, phrasal verb'ler.
• Günlük hatırlatma: seçtiğin saatte, çalışacak kelime varsa tek bir bildirim.
• Bildiğin kelimeler listesi: yanlışlıkla işaretlediğini geri alabilirsin.

GİZLİLİK
• Hesap yok, reklam yok, takip yok.
• İlerlemen telefonunda durur; biz göremeyiz.
• Lockglow senin verini hiçbir sunucuya göndermez.

BİLMEN GEREKENLER
• iPhone, iOS 17 ve sonrası.
• Söyle: iOS 26 ve sonrasında İngilizce konuşma modeli ilk kullanımda iner. iOS 17–25'te telefonunda cihaz içi İngilizce (ABD) tanıma olması gerekir.
• Widget'ın ne zaman yenileneceğine son kararı iOS verir; yenileme bazen birkaç dakika gecikebilir.

Gizlilik Politikası: [GİZLİLİK POLİTİKASI WEB ADRESİ]
Kullanım Şartları (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

3244 karakter (sınır 4000; yaklaşık 750 karakter boş). Notlar:

- **Doğrulanan iddialar:** kart, seviye, tür, örnek ve "Dikkat" sayıları veritabanından; widget düğmeleri `ios/Widgets/WidgetButtons.swift`; sıklık seçenekleri (5, 15, 30, 60, 120 dk) ve günlük hedef (5, 10, 15, 20) `ios/App/AppPreferences.swift:8–9`; Söyle mesajları `PronunciationCheck.swift:484–495`; sözlük harf katlaması `card_fts` (`lemma_fold`, `gloss_fold`); iOS 17 `ios/project.yml:5`.
- **Kullanılmayan iddialar** (bugün yok, yazmayın): YDS/YÖKDİL/IELTS, C1–C2, günlük seri, temalar, iCloud yedeği, iPad, "10.000+ kelime", "yapay zekâ".
- **"Ücretsiz" kelimesi** açıklamaya bilerek yazılmadı: abonelik eklenirse metin yanlış kalır. İlk sürüm ücretsizse fiyat zaten mağazada "Al" (Get) olarak görünür.
- **Gizlilik cümleleri** `docs/legal/` taslak-2 ile aynı; App Privacy cevabı "Data Not Collected" (`docs/legal/app_store_privacy_etiketi.md` §2A). Analitik ya da abonelik eklenirse "hiçbir sunucuya göndermez" cümlesi **değişmelidir**.
- Gizlilik politikası web adresi henüz yok (alan adı alınmadı; `marketing/landing/` marka kontrolünden önce yayımlanmayacak).

## Anahtar kelimeler

```text
widget,telaffuz,kartları,ekranı,günlük,ezberleme,öğrenme,kelimeler,sözlük,tekrar,testi,ders
```

91 karakter, **99 bayt** (sınır 100 bayt). Virgülden sonra boşluk yok.

| Kelime | Ad/alt başlıkla birleşince | Neden |
|---|---|---|
| widget | "ingilizce kelime widget" | Ürünün farkı; TR'de rakipleri az puanlı |
| telaffuz | "ingilizce telaffuz" | Google'da "telaffuz uygulaması" önerisi var; Söyle |
| kartları | "kelime kartları" | Google önerisi; orta rekabet |
| ekranı | "kilit ekranı" (alt başlıktaki "kilit" ile) | "Ekranında" ayrı bir kelime sayılabilir; güvence |
| günlük | "günlük ingilizce", "günlük kelime" | Widget rakipleri kullanıyor |
| ezberleme | "kelime ezberleme" | Google önerisi; "ezberle"den ayrı kelime |
| öğrenme | "kelime öğrenme", "ingilizce öğrenme" | Google önerisi |
| kelimeler | "ingilizce kelimeler" | Google önerisi; "kelime"den ayrı kelime |
| sözlük | "ingilizce sözlük" | Sözlük özelliği; büyük sözlüklerle rekabet |
| tekrar | "kelime tekrar" | Aralıklı tekrar |
| testi | "kelime testi" | Google önerisi; quiz |
| ders | "ingilizce ders" | Genel talep |

**Bilerek konmayanlar:**

- `ingilizce`, `kelime`, `kilit`, `ezberle`, `öğren`, `lockglow`: zaten ad ve alt başlıkta.
- `eğitim`: kategori adı, zaten aranır.
- `yds`, `yökdil`, `ielts`, `toefl`: talep var ama içerik A1–B1; yanıltıcı olur (Kural 2.3.7).
- Rakip adları (Duolingo, Kolay İngilizce vb.): yasak (Kural 4.1).
- `a1`, `a2`, `b1`: Apple her kelimenin 2 karakterden uzun olmasını istiyor.
- Aksansız yazımlar (`telafuz`, `sozluk`): Apple aksan eşleşmesini belgelemiyor; aramalarda "ingilizce" ile "İngilizce" aynı sonucu veriyor. Bayt harcamaya değmez.

**Kanıt düzeyi:** Talep verisi dolaylıdır: Google otomatik tamamlama, rakip adları ve `raporlar/08_aso_isim_metadata.md` §1.3. Ücretli bir ASO aracı kullanılmadı. Yayından 2–4 hafta sonra App Store Connect'teki arama terimi raporuna bakıp zayıf kelimeleri değiştirin (anahtar kelimeler yalnızca yeni sürümle değişir).

**İkinci alan:** Türkiye mağazasında İngilizce (U.K.) yerelleştirmesinin anahtar kelimeleri de aranır; İngilizce terimler oraya: [`kayit_metinleri_en.md`](kayit_metinleri_en.md).

## Bu sürümde yeni (What's New)

**1.0 (ilk sürüm):** App Store Connect bu alanı ilk sürümde göstermez. Aşağıdaki kısa metin TestFlight'ın "Test Edilecekler" (What to Test) alanında kullanılabilir:

```text
İlk sürüm: kilit ekranı ve ana ekran widget'ları, 933 kelime kartı, dört cevaplı tekrar, boşluk doldurma, sözlük, Söyle ile telaffuz alıştırması ve günlük hatırlatma.
```

166 karakter.

**1.1 ve sonrası için kalıp** (Kural 2.3.12: değişiklikleri açıkça yaz; en önemlisi en üstte):

```text
Yeni
• [Özellik]: [kullanıcıya faydası, tek cümle].
• [N] yeni kelime: [konu adları].

Düzeltmeler
• [Sorun] düzeltildi.

Lockglow'u beğendiysen App Store'da puan vermen çok yardımcı olur.
```

Örnek (yalnızca biçim; içerik gelince doldurun): "• 120 yeni kelime: Ev & Ev İşleri, Alışveriş & Para."
