# Rakip analizi ve anahtar kelime stratejisi (Türkiye App Store, 23 Ekim 2026)

> **TASLAK.** Mağaza sayfası için son kararlar: [`kayit_metinleri_tr.md`](kayit_metinleri_tr.md), [`kayit_metinleri_en.md`](kayit_metinleri_en.md), [`ekran_goruntusu_basliklari.md`](ekran_goruntusu_basliklari.md). Bu belge onların gerekçesi. 22 Ekim'deki kısa derleme: [`rakiplerden_ogrenilenler.md`](rakiplerden_ogrenilenler.md).

> Önceki çalışmanın üzerine kuruldu: `docs/magaza/rakiplerden_ogrenilenler.md` (22 Ekim), `kayit_metinleri_tr.md` / `_en.md` anahtar kelime bölümleri, `raporlar/08` §1.3–2.2, `raporlar/14`.
>
> **Yöntem:** Apple iTunes Search/Lookup API (`country=tr`), App Store arama ipucu (hints) uç noktası (TR vitrin kodu 143480), `apps.apple.com/tr/...` sayfaları (varsayılan = en-GB, `?l=tr` = Türkçe), Google otomatik tamamlama (`hl=tr, gl=tr` ve `en-GB, gb`). Ekran görüntüleri tarayıcıda tek tek açılıp bakıldı. **Ücretli ASO aracı kullanılmadı.** Bu yüzden arama hacmi yok; talep yalnızca "öneri listesinde çıkıyor mu" ile, rekabet de üst sıradaki uygulamaların puan sayısıyla tahmin edildi.
>
> **Kopyalama yok:** Rakip açıklamaları ve alt başlıkları kendi sözlerimle özetlendi. Tırnak içinde yalnızca uygulama adları var.
>
> [D] = doğrulanmadı ya da tek kaynağa dayanıyor.

---

## 0. Kısa özet: 22 Ekim'den bu yana değişenler

1. **Doğrudan yeni rakip: "Lugat: İngilizce Kelime"** (bireysel geliştirici, 15 Ekim'de yayımlandı, 3 puan).
   - Yalnızca Türkçe. Ücretsiz, uygulama içi satın alma yok. Gizlilik etiketi **"Data Not Collected"**.
   - Hesap, reklam ve internet gerektirmiyor. Kilit ekranı widget'ı var. Türkçe anlam, aralıklı tekrar (hafıza kutuları), seslendirme ve boşluk doldurma da var.
   - Alt başlığı bizim TR taslağımıza çok yakın: kilit ekranında kelime öğrenmeyi söylüyor.
   - **Sonuç:** "reklam yok, hesap yok, veri toplanmıyor" artık tek başına fark değil.
2. **"Wordlet: İngilizce Kelime"** (2 Ekim'de çıktı, 22 Ekim'de v2.0).
   - Widget'ta Türkçe anlam var. Widget'ta tek dokunuşla "Biliyorum / Tekrar" işaretleniyor.
   - Kilit ekranı ve Denetim Merkezi'nde de var. FSRS kullanıyor, kendi kelimeni ekleyebiliyorsun. Reklam yok.
   - Hesap isteğe bağlı. Düello, lig ve seri gibi sosyal özellikler var.
   - **Sonuç:** "Biliyorum düğmesi widget'ta" ve "Denetim Merkezi" artık bize özgü değil.
3. **Kolay İngilizce ömür boyu fiyatını yükseltti.** 20 Ekim'de ₺499,99 idi, bugün ₺799,99. Ayrıca ₺999,99'a "Reklamları Kaldır" seçeneği var. Yıllık plan hâlâ ₺299,99.
4. **Orbit (Widget Vocabulary)** 22 Ekim'de v3.1.1'e geçti. TR Eğitim listesinde 7. sırada.
   - TR ekran görüntülerinde kilit ekranı widget'ı **Türkçe anlam** gösteriyor.
   - Bu yüzden `raporlar/14`'teki "Orbit'te widget'ta Türkçe anlam yok" tespiti **artık geçersiz**.
5. **"Zarafa"** (3 Ekim'de çıktı): 40 dil, kilit ekranı widget'ı, Live Activity, "Data Not Collected", çevrimdışı çalışıyor, seri baskısı yok. Türkçe sayfası var.

---

## 1. Rakip profilleri (TR mağazası, 23 Ekim 2026)

### Tablo açıklaması

- **Ad (TR):** `?l=tr` sayfasındaki ad. Türkçe ad yoksa varsayılan ad yazıldı.
- **Puan:** TR vitrinindeki puan sayısı ve ortalaması (Lookup API).
- **Güncelleme:** son sürümün tarihi.
- **Takip / Bağlı:** App Privacy etiketinin özeti. "Takip" = Data Used to Track You, "Bağlı" = Data Linked to You.
- **Reklam:** Yaş derecelendirmesi bölümündeki "Contains Advertising" ibaresi.
- **TR sayfa:** Türkçe telefonda görünen sayfanın dili.

### 1a. Widget / kilit ekranı odaklı uygulamalar

| Uygulama (TR adı) · geliştirici türü | Alt başlığın konusu (kendi sözümle) | Fiyat (TR) | Puan | Kilit / Ana ekran widget'ı | Widget'ta Türkçe anlam | Widget'ta ses | Aralıklı tekrar | Telaffuz | Gizlilik | Yaş · güncelleme · TR sayfa |
|---|---|---|---|---|---|---|---|---|---|---|
| "Widget Vocabulary: Learn Words" · Orbit Studios | İngilizce kelime öğrenme | Haftalık ₺499,99; yıllık ₺2.499,99 | 327 · 4,27 (Eğitim #7) | Var / Var | **Var** (TR ekran görüntüsünde) | Açıklamada yok; widget'ta fonetik yazım var [D] | İddia yok (testler, "1000+ seviye") | Söyleme alıştırması (v3.1.0) | Takip: tanımlayıcılar. Reklam var | 4+ · 22 Eki · Ad İngilizce, alt başlık ve açıklama Türkçe |
| "Lugat: İngilizce Kelime" · bireysel geliştirici | Kilit ekranında kelime öğrenme | **Ücretsiz, satın alma yok** | 3 · 5,0 | Var; ana ekranda mini test widget'ı | Var (açıklamaya göre) | Yok [D] | Var (hafıza kutuları, 5 soru türü) | Dinleme, IPA; söyleme yok | **Data Not Collected** | 4+ · 16 Eki · Tamamen Türkçe |
| "Wordlet: İngilizce Kelime" · bireysel geliştirici | Widget'la her gün yeni kelime | Ücretsiz, satın alma listelenmemiş | 14 · 5,0 | Var / Var; Denetim Merkezi de var | Var | Yok [D] | **FSRS** | Dinleme | Bağlı: iletişim bilgisi, kullanıcı içeriği, tanımlayıcılar. Reklam yok | 4+ · 22 Eki · Tamamen Türkçe |
| "İngilizce Öğren: Kelime Widget" · bireysel geliştirici | Ana ekranda günlük ezber | Haftalık ₺49,99; yıllık ₺499,99 | 1 · 5,0 | Var / Var | Var | Widget görüntüsünde hoparlör simgesi; uygulamayı açmadan çalıp çalmadığı belli değil [D] | Kısa tekrar, hatırlatma | Dinleme | Bağlı: satın alma, konum, tanımlayıcılar, kullanım | 4+ · 22 Eki · Türkçe. A1–C2 içerik ama açıklamada YDS/IELTS/TOEFL geçiyor |
| "Lingo Widget: Günlük Kelime" · bireysel geliştirici | Ana ve kilit ekranı kartları | Haftalık ₺119,99; aylık ₺379,99; yıllık ₺1.499,99; ömür boyu ₺2.999,99 | 20 · 4,35 | Ana ekran kesin; kilit ekranı alt başlıkta | Var | Hoparlöre dokununca ses, **premium'da** [D: uygulama açılıyor mu?] | "Quick Recall" | Dinleme ve hatırlama | Bağlı: satın alma, konum, tanımlayıcılar, kullanım | 4+ · 16 Eki · Türkçe. "Hesap yok, seri yok" diyor |
| "Zarafa: İngilizce öğren widget" · bireysel geliştirici | Kelime ezberleme ve dil | Aylık ₺105–149,99; yıllık ₺499,99–999,99; ömür boyu ₺1.499,99 | 0 | Var / Var; Live Activity | Var (ana dile çeviri) | Yok [D] | Kelime testleri; SRS iddiası yok | Dinleme | **Data Not Collected** | 4+ · 22 Eki · Türkçe (40 dil) |
| "Wrd – Günün Kelimesi Widget'ı" · bireysel geliştirici | Kelime ve ifadeler öğrenme | Aylık ₺79,99; yıllık ₺699,99 | 12 · 4,08 | Var / Var | Çeviri modu | Yok [D] | Alıştırma; SRS iddiası yok | Dinleme | Takip: satın alma, tanımlayıcılar, kullanım | 4+ · 21 Eki · Türkçe. "Reklam yok, seri yok" |
| "Word Widget: İngilizce Kelime" · bireysel geliştirici | Günün kelimesi ve ezber | Haftalık ₺99,99–199,99; yıllık ₺399,99–1.299,99 | 6 · 5,0 | Ana ekran / kilit [D] | Anlam var; Türkçe olduğu belli değil [D] | Yok | Testler; SRS yok | Yok | Takip: tanımlayıcılar, kullanım | 4+ · 15 Eki · Türkçe |
| "Vocabulary - Learn words daily" · Monkey Taps | (TR'de alt başlık yok) | Aylık ₺119,99; yıllık ₺799,99; ₺1.299,99'a kadar | 1.211 · 4,6 | Var / Var | **Yok** (yalnızca İngilizce tanım; Türkçe arayüz yok) | Yok [D] | Yok | Yok | Takip: satın alma, içerik, arama geçmişi, tanımlayıcılar, kullanım. Reklam var | 13+ · 21 Eki · **İngilizce** |

### 1b. Büyük ve genel uygulamalar

| Uygulama (TR adı) · geliştirici türü | Alt başlığın konusu | Fiyat (TR) | Puan | Widget | Aralıklı tekrar | Telaffuz | Gizlilik | Yaş · güncelleme · TR sayfa |
|---|---|---|---|---|---|---|---|---|
| "Kolay İngilizce Kelime Öğren" · bireysel geliştirici | Günde 5 dakikada ezber | Aylık ₺49,99; yıllık ₺299,99; aile ₺399,99; ömür boyu ₺799,99; reklam kaldırma ₺999,99 | **36.919 · 4,80** | Ana ve kilit ekranı (v4.7, 19 Eki): günün kelimesi, anlamı, ilerleme | "Akıllı tekrar" | Dinleme [D] | Bağlı: satın alma, içerik, tanımlayıcılar, kullanım, tanılama. Takip yok. Reklam var | 4+ · 19 Eki · Türkçe |
| "Atlas - İngilizce Kelime Öğren" · Sayan Yazılım | TOEFL, YÖKDİL, IELTS hazırlığı | Aylık ₺99,99; yıllık ₺699,99; premium ₺899,99–1.999,99 | 8.634 · 4,75 | Ana ekran widget'ı | Var | Dinleme; yapay zekâ öğretmen | Takip: tanımlayıcılar. Bağlı: konum, iletişim dahil. Reklam var | 4+ · 22 Eki · Türkçe |
| "İngilizce - Kelimeler Öğren" (English Words Trainer) · bireysel geliştirici | Kelime öğrenme ve ezber | Aylık ₺149,99; premium ₺539,99 | 5.286 · 4,86 | Açıklamada yok | 1-3-7-30-120 gün aralıkları | Ana dili İngilizce olan kişinin sesi | Takip: satın alma, tanımlayıcılar | 4+ · 11 Eki · Türkçe |
| "İngilizce Kelime Kartları" · Codeida | Test et ve ezberle | Aylık ₺29,99; yıllık ₺199,99 | 1.350 · 4,58 | Ana ekran | SRS | ABD/İngiliz sesi; konuşma alıştırması | Takip: tanımlayıcılar, kullanım. Reklam var | 4+ · 30 Ağu · Türkçe. En düşük iOS 18.6 |
| "Duolingo: Dil ve Satranç" | Birden çok dil ve satranç | ₺329,99–1.209,99 | 496.882 · 4,73 (Eğitim #3) | Var (seri widget'ı) [D: sayfadan değil, genel bilgi] | Kendi yöntemi | Var | Geniş takip | 4+ · 21 Eki · Türkçe |
| "WordUp: İngilizce Kelime Öğren" · Geeks | Kartlarla kelime ezberleme | Aylık ₺69,99–99,99; yıllık ₺284,99–399,99 | 3.588 · 4,68 | [D] | SRS | Var | Takip: kullanım | 13+ · 28 Eyl · Türkçe |
| "Flaş İngilizce: Kelime Ezberle" · bireysel geliştirici | Hikâye ve görselle öğrenme | Aylık ₺99,99; yıllık ₺499,99; yapay zekâ ₺2.999,99'a kadar | 58 · 4,71 | Açıklamada yok | 1-2-4-7-14 gün | Dinleme; yapay zekâ öğretmen | Bağlı: iletişim, içerik, kullanım | 13+ · 11 Eki · Türkçe. YDS/YÖKDİL de hedefliyor |
| "Blarma - Kelimeler öğren!" | İngilizce kelime öğrenme | ₺299,99–2.499,99 | 5.413 · 4,72 (#41) | [D] | Var | Var | Takip: satın alma, konum, iletişim, kullanım | 4+ · 22 Eki · Türkçe |

### Gözlemler

- **TR adı ve alt başlığı ayrı yazmak artık yaygın.** Atlas, EWT, WordUp, Lingo, Word Widget, Zarafa, Wrd ve Duolingo Türkçe telefonda farklı ad ya da alt başlık gösteriyor. Türkçe yerelleştirmesi zayıf olan tek büyük rakip Monkey Taps.
- **Kilit ekranında Türkçe anlam artık sıradan.** Orbit, Lugat, Wordlet, Kelime Widget, Lingo, Zarafa ve Kolay'da var.
- **Fiyat yelpazesi çok geniş.**
  - Ücretsiz ve satın almasız: Lugat, Wordlet.
  - Ucuz: Kartları (₺199,99/yıl), Kolay (₺299,99/yıl).
  - Pahalı haftalık planlar: Orbit (₺499,99/hafta), Lingo (₺119,99/hafta), Word Widget, Kelime Widget.
- **Ekim'de en az dört yeni Türkçe widget uygulaması çıktı:** Wordlet, Lugat, Zarafa ve bugün yeni görünen "Kelime Dağarcığı" (22 Eki, 0 puan, incelenmedi). Kategori hızla kalabalıklaşıyor; Kural 4.3 (kopya uygulama) riski artıyor.

---

## 2. Rakiplerin hedeflediği arama ifadeleri ve boşluklar

### 2.1 Ad ve alt başlıklardaki kelime kümeleri (TR sayfaları)

| Küme | Bu kümeyi kullananlar |
|---|---|
| ingilizce + kelime + öğren/öğrenme | Kolay, Atlas, EWT, WordUp, Blarma, Orbit (TR alt başlığı), Kelime Widget |
| ezberle / ezberleme / ezber | Kolay, EWT, Kartları, WordUp, Flaş, Word Widget, Kelime Widget, Zarafa |
| widget | Orbit, Lingo, Wordlet, Kelime Widget, Word Widget, Zarafa, Wrd |
| kilit ekranı / ana ekran | Lugat (alt başlıkta), Lingo (alt başlıkta) |
| günün kelimesi / günlük | Word Widget, Wrd, Lingo |
| kart | Kartları, WordUp, Lingo |
| sınav (TOEFL/YÖKDİL/IELTS) | Atlas (alt başlıkta); Kelime Widget, Flaş, EWT (açıklamada) |

### 2.2 Hiç kimsenin inandırıcı biçimde söylemediği şeyler (Lockglow'un söyleyebileceği)

| İddia | Rakipte durum | Lockglow için değerlendirme |
|---|---|---|
| **Türk konuşanların tipik hataları** ("Dikkat" kutusu) | Kimse söylemiyor. Lugat Türkçeye benzeyen kelimeleri çıkarıyor. Zarafa'da "sahte dostlar" konusu var. Bunlar yakın ama aynı şey değil. | **En güçlü özgün iddia.** 1–2. ekran görüntüsü karesinde gösterilmeli. |
| **Cihazda telaffuz kontrolü, ses telefondan çıkmıyor** | Orbit'te söyleme alıştırması var ama nerede işlendiği yazmıyor. Gizlilik etiketinde tanımlayıcılar ve takip var. | Özgün. Hem gizlilik hem telaffuz kümesine hitap ediyor. |
| **Widget'tan uygulamayı açmadan dinleme** | Lingo (premium) ve Kelime Widget'ın widget'ında hoparlör simgesi var. Uygulama açılmadan çaldığı yazılı değil [D]. | Açıkça ve kanıtla (video ya da kare) söylenirse fark yaratır. "Kimsede yok" denmemeli. |
| **Gündelik İngilizce, A2–B1, sınav yok** | Herkes A1–C2 ya da sınav vaat ediyor. Kelime Widget A1–C2 içerikle bile YDS/IELTS yazıyor. | Dürüst ve net konumlanma. 4.3 riskine karşı da farklılaştırıyor. |
| **Tamamen ücretsiz, satın alma yok, Data Not Collected** | Yalnızca Lugat'ta tam olarak böyle. Zarafa da veri toplamıyor ama paralı. Wordlet ücretsiz ama veri topluyor. | Hâlâ çoğunluktan ayırıyor, ama "tek biz" denemez. |
| **Seri yok, sakin ilerleme** | Lingo, Wrd ve Zarafa "seri yok / seri baskısı yok" diyor. | Ayırt edici değil. Destekleyici cümle olarak kalmalı. |
| **Biliyorum / Sonraki düğmeleri widget'ta** | Wordlet (Biliyorum/Tekrar), Lingo (Öğrendim), Kelime Widget (biliyorum) | Artık özgün değil. Göster ama ana iddia yapma. |
| **Türkçe harflere duyarsız sözlük araması** (ı/i, ş/s…) | Kimse söylemiyor | Küçük ama somut. Açıklamada bir madde olabilir. |
| **Kendi kelimeni ekleme** | Orbit (5 deste), Wordlet | Standart özellik. |

---

## 3. Anahtar kelime stratejisi

### 3.1 Kanıtlar

#### App Store arama ipuçları (TR vitrini, 23 Ekim)

**Talebi açıkça görünen ifadeler:**

- "ingilizce kelime öğrenme", "ingilizce kelime öğren"
- "ingilizce kelimeler öğren", "ingilizce kelime ezberleme"
- "ingilizce kelime kartları", "ingilizce kelime" (öneri listesinde)
- "kelime öğren" (2.), "kelime ezberleme", "kelime ezberle", "kelime ezber"
- "kelime kartları", "kelime kartı", "kelime defteri"
- "kelime dağarcığı" ("kelime d" yazınca 1. öneri)
- "ingilizce telaffuz", "ingilizce kelime testi"
- "ingilizce b1 kelime", "a1 seviye ingilizce", "ingilizce seviye testi"
- "ingilizce günlük konuşma", "günün kelimesi"
- "kelime tekrarlayıcı" (öneri var, arama sonucu neredeyse boş)
- "ingilizce sözlük"

**Zayıf ya da tuzaklı ifadeler:**

- "kilit" / "kilit ekranı": önerilerin tamamı ayet ve dua uygulamaları. "Kilit ekranı" tek başına başka bir niyeti çağırıyor.
- "widget": önerileri Widgetsmith ve Widgetable gibi tema uygulamaları dolduruyor.
- "ingilizce kelime widget": öneri yok.
- "kelime w" yazınca yalnızca bir rakibin adı geliyor.
- "aralıklı": yalnızca aralıklı oruç geliyor.
- "kelime": tek başına kelime oyunları (Kelimelik, Kelime Gezmece).

#### Google otomatik tamamlama (TR)

- "kilit ekranı ingilizce kelime" var. Küçük ama tam isabetli bir niş.
- "ingilizce kelime uygulaması" ailesinde ücretsiz, ezberleme, kart, defter ve kaydetme varyantları var.
- "ingilizce günlük kelimeler (ve okunuşları / anlamları)" var.
- "a2/b1 ingilizce kelimeler (listesi, testi)" var.
- "ingilizce telaffuz uygulaması (ücretsiz)" var.
- "reklamsız ingilizce sözlük" var.
- "Türklerin İngilizce hataları" için öneri yok. Hatalar arama terimi değil, satış argümanı.

#### Google en-GB

- "vocabulary widget (iphone, lock screen, free)" var.
- "lock screen vocabulary (app, widget)" var.
- "english for turkish speakers" var.
- "learn english words daily app" var.

#### Rekabet (TR'de ilk 5 sonucun puan sayısı)

- **Yüksek:** "ingilizce kelime", "kelime öğren", "kelime ezberleme". İlk sıralarda Kolay (37 bin), Quizlet (29 bin), Atlas (8,6 bin) var. Yeni bir uygulama bunlarda ilk 10'a zor girer.
- **Düşük:** "kilit ekranı kelime" (en iyisi Lingo, 20 puan), "ingilizce widget", "kelime widget", "ingilizce b1 kelime", "a2 ingilizce", "kelime tekrarlayıcı", "günün kelimesi". Bunlarda ilk sıralara çıkmak gerçekçi.

#### Strateji

- **Ad**, en çok aranan küme olan "ingilizce kelime"yi taşımalı. Uzun vadede değer burada.
- **Alt başlık ve anahtar kelimeler**, düşük rekabetli uzun kuyruğu yakalamalı: kilit ekranı, widget, b1/a2, telaffuz, günlük.

### 3.2 Kurallar

Apple'ın ürün sayfası kılavuzu (23 Ekim'de okundu):

- Ad ve alt başlık en fazla 30 karakter.
- Anahtar kelime alanı **100 bayt** (App Store Connect belgesi; Apple'ın pazarlama sayfası "karakter" diyor); virgülle ayrılır, virgülden sonra boşluk yok.
- **Her anahtar kelime 2 karakterden uzun olmalı** ([Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), 23 Ekim 2026). Bu yüzden `a1`, `a2`, `b1` yazılamaz; ilk taslaktaki setler buna göre düzeltildi (aşağıda).
- Kaçınılacaklar: tekrar eden kelimeler, tekil hali zaten olan kelimenin çoğulu, kategori adları, "app" kelimesi, rakip adları, alakasız terimler.

Bizim ek kurallarımız:

- Ad ve alt başlıktaki kelimeler anahtar kelime alanında tekrarlanmaz.
- "Ücretsiz/free", fiyat ifadeleri, YDS/YÖKDİL/IELTS/TOEFL kullanılmaz; içerik A1–B1.

**Not:** Türkçe çekimlerde ("kelime" ve "kelimeler", "öğren" ve "öğrenme") Apple'ın kök eşlemesi yapıp yapmadığı belgelenmemiş. Ayrı kelime olarak yazmayı öneriyorum. Apple'ın "çoğul yazma" uyarısı İngilizce için kesin; Türkçe için [D].

### 3.3 Önerilen setler

Uzunluklar ve bayt sayıları `python -X utf8` ile hesaplandı. Ad ve alt başlıkla çakışma kontrolü de betikle yapıldı.

#### TR seti A: kilit ekranı önde (taslağa yakın, önerilen)

| Alan | Değer | Uzunluk |
|---|---|---|
| Ad | `Lockglow: İngilizce Kelime` | 26 karakter |
| Alt başlık | `Kilit Ekranında Ezberle, Öğren` | 30 karakter |
| Anahtar kelimeler | `widget,telaffuz,kartları,ekranı,günlük,ezberleme,öğrenme,kelimeler,tekrar,testi,okunuş,ders` | 91 karakter, **98 bayt** |

Taslaktan farklar:

- **Çıkanlar:** `sözlük` ve `ders`. "ingilizce sözlük" aramalarını Tureng ve Sesli Sözlük tutuyor; "ders" belirsiz bir kelime.
- **Girenler:**
  - `okunuş`: Google'da "günlük kelimeler ve okunuşları" önerisi var.
  - `ders`: genel talep ("ingilizce ders"); `a2` ve `b1` 2 karakter olduğu için yazılamadı. "ingilizce b1 kelime" araması yine de değerli: açıklamada A1, A2, B1 geçiyor, ama açıklama App Store aramasına girmez.

Bu setin oluşturduğu birleşimler:

- "ingilizce kelime widget", "kilit ekranı ingilizce kelime", "ingilizce telaffuz"
- "ingilizce kelime kartları", "ingilizce kelime ezberleme", "ingilizce kelime testi"
- "günlük ingilizce kelimeler"

**Risk:** Lugat'ın alt başlığı aynı fikri taşıyor ("kilit ekranında" + "kelime öğren"). Bizimki kelime kelime aynı değil. Yine de farkı ekran görüntüsü ve açıklamada açıkça göstermek gerekiyor (Dikkat kutusu, Söyle, widget'tan dinleme).

#### TR seti B: widget ve telaffuz önde

| Alan | Değer | Uzunluk |
|---|---|---|
| Ad | `Lockglow: İngilizce Kelime` | 26 karakter |
| Alt başlık | `Widget, Telaffuz ve Tekrar` | 26 karakter |
| Anahtar kelimeler | `kilit,ekranı,ezberle,ezberleme,öğren,öğrenme,kartları,günlük,kelimeler,testi,okunuş,ders` | 88 karakter, **97 bayt** |

- **Ne zaman seçilmeli:** "Söyle" ve widget'tan dinleme ilk sürümün vitrini olacaksa. Bu set "ingilizce telaffuz" kümesine (orta rekabet) alt başlıktan girer, kilit ekranını anahtar kelimelere bırakır.
- **Zayıf yanı:** Alt başlık kendi başına fayda cümlesi değil, bir özellik listesi gibi okunuyor.

#### en-GB seti A: taslağa yakın (önerilen)

| Alan | Değer | Uzunluk |
|---|---|---|
| Name | `Lockglow: Vocabulary Widget` | 27 karakter |
| Subtitle | `English for Turkish Speakers` | 28 karakter |
| Keywords | `lock,screen,learn,words,flashcards,pronunciation,daily,vocab,quiz,memorize,beginner,practice,day` | 96 karakter, **96 bayt** |

Taslaktan farklar:

- **Çıkanlar:**
  - `dictionary`: TR vitrininde sözlük uygulamaları baskın.
  - `esl`: TR'de öneri kanıtı bulunamadı.
- **Girenler:**
  - `practice`: "english practice" (`a1`, `a2`, `b1` 2 karakter olduğu için yazılamadı).
  - `day`: "word of the day" için; "word" kelimesi "words" ile karşılanıyor [D].

Google en-GB'de "vocabulary widget iphone lock screen" ve "english for turkish speakers" önerileri var.

#### en-GB seti B: "learn english words" önde

| Alan | Değer | Uzunluk |
|---|---|---|
| Name | `Lockglow: Learn English Words` | 29 karakter |
| Subtitle | `Lock Screen Vocabulary Widget` | 29 karakter |
| Keywords | `turkish,flashcards,pronunciation,daily,vocab,quiz,memorize,beginner,reklamsız,okunuş,ezber` | 90 karakter, **92 bayt** |

- Son üç kelime **Türkçe**. Türkiye vitrini en-GB yerelleştirmesini de dizinlediği için TR alanına sığmayan terimleri buraya koyma denemesi.
- Bu yaklaşım Apple tarafından belgelenmemiş [D]. İngiltere'deki kullanıcı için anlamsız. Arama raporu (Apple Ads "Search Popularity" ya da App Analytics) görülmeden kullanılmamalı.

#### Yer tutucu marka (Lockglow kesin değil)

- Bütün setler `<Marka>: …` kalıbında.
- Markanın en fazla uzunluğu:
  - TR A/B: **12 karakter**
  - en-GB A: **11 karakter**
  - en-GB B: **9 karakter**
- Marka değişince anahtar kelime alanı aynı kalır. Yalnızca markanın kendisi anahtar kelimelere yazılmaz.
- Marka Türkçe harf içerirse ad karakterle sayılır, bayt sorunu çıkmaz.

#### Kenara konan adaylar ve gerekçeleri

| Aday | Neden kenarda |
|---|---|
| `dağarcığı` (12 bayt) | Öneri güçlü, ama ilk sonuçlar kelime oyunları; bayt pahalı |
| `tekrarlayıcı` | "kelime tekrarlayıcı" önerisi var, arama sonuçları neredeyse boş; 14 bayt |
| `defteri` | "kelime defteri" Tureng'in kalesi |
| `türkçe` | "ingilizce türkçe" niyeti sözlük ve çeviri |
| `reklamsız` | Gerçeğe uygun, Google'da "reklamsız ingilizce sözlük" var; App Store'da kanıt yok |

Bunlar sonraki sürümlerde alan değişikliğiyle denenebilir. Her sürümde 2–3 kelimeden fazlası değiştirilmemeli ki etkisi ölçülebilsin.

---

## 4. Ekran görüntüsü kalıpları (TR sayfaları, ilk 3 kare)

| Uygulama | 1. kare | 2. kare | 3. kare |
|---|---|---|---|
| Orbit | Koyu yıldızlı kilit ekranı, Türkçe anlamlı widget'lar ve bildirim; büyük başlık | Ana ekran widget galerisi | Kelime kartı + "10.000'den fazla kelime" sayı iddiası (önceki raporda şişirilmiş sayı uyarısı vardı) |
| Kolay | Turuncu zemin, "günde 5 dakika / 10 kelime" sayı iddiası, ana menü | Günlük/haftalık/aylık kelime sayısı vaadi | Kaydırmalı kart. **Widget ilk 3 karede yok** |
| Atlas | "Editörün Seçimi" defne rozeti + illüstrasyonlu kart | Günde 5 dakika vaadi + kelime defteri | "10.000+ kelime" rozeti + seviye listesi |
| Lingo Widget | Gülümseyen kadın fotoğrafı + "App Store 4.8 / 100K+ değerlendirme" defne rozeti (TR'de 20 puan; kaynağı belirsiz [D]) | Ana ekran widget'ları: bayraklı İngilizce–Türkçe, hoparlör simgesi, "biliyorum" | Bildirimler + widget |
| Kelime Widget | Pastel turuncu; widget'ta kelime, Türkçe anlam, hoparlör, "biliyorum" | Kilit ekranı bildirimleri | Ayrıntılı kelime kartı |
| Wordlet | Koyu zemin; Biliyorum/Tekrar düğmeli widget; altında 3 madde | Kaydırmalı kart ekranı | Düello ekranı |
| Lugat | **Başlıksız**, ham "Bugün" ekranı (seri, hedef) | Öğrenme kartı (bildiği/göster düğmeleri) | Geri bildirim (doğru cevap) |
| Zarafa | Kilit ekranı widget'ı, maskot zürafa | Ana ekran widget'ları (zürafalı) | (bakılmadı) |
| Wrd | Siyah-beyaz dağ fotoğraflı kilit ekranı, tek widget | (bakılmadı) | (bakılmadı) |
| Word Widget | İllüstrasyonlu "kelime bilgisi" başlığı, uygulama yok | Konu seçimi | (bakılmadı) |

### Ortak kalıplar

- **Kurgu:** Widget odaklı uygulamalarda 1. kare kilit ya da ana ekran widget'ı. Genel uygulamalarda 1. kare sayı vaadi ("5 dakika", "10.000+").
- **Başlık:** Üstte, kalın, 2–5 kelimelik fayda cümlesi.
- **Sosyal kanıt:** Defne rozetleri ("Editörün Seçimi", "4.8 yıldız"). Lingo'nun rozeti TR puanıyla uyuşmuyor; bu tür iddia Kural 2.3 açısından riskli.
- **Görsel dil:** Koyu tema (Orbit, Wordlet, Lingo) ya da tek sıcak renk (Kolay, Kelime Widget). Maskot ya da fotoğraf sık kullanılıyor.
- **Kimsenin göstermediği şeyler:**
  - telaffuzu cihazda kontrol eden bir ekran;
  - Türk konuşanlara özgü hata kutusu;
  - widget'tan uygulamayı açmadan dinlemenin gösterimi;
  - gizlilik etiketinin kendisi.

### Lockglow için öneri (ilk 3 kare)

1. **Kilit ekranı + ana ekran birlikte, aynı kelime.** Türkçe anlam ve Dinle / Biliyorum / Sonraki düğmeleri görünür olsun. Başlık faydayı söylesin: telefonuna her baktığında bir kelime.
   - Bu kare tek başına rakiplerden ayırmaz. Ayıran şey widget'ta **ses düğmesi**. Hoparlör simgesinin yanında "uygulama açılmaz" gibi kısa bir not olsun.
2. **"Dikkat" kutusu.** Gerçek bir örnek kart göster (ör. Türklerin sık yaptığı bir eşleme hatası). Bu karenin rakipte karşılığı yok.
3. **Söyle.** Telaffuz kontrolü ve "ses telefondan çıkmaz" kilidi/notu.
4. Sonraki karelere:
   - tekrar turu (Tanış + Hatırla, 4 seçenekli boşluk doldurma);
   - sözlük;
   - kendi kelimesi;
   - sakin ilerleme;
   - gizlilik: "Data Not Collected" etiketiyle aynı dil.

### Farklı yapılacaklar

- Sayı şişirme ve defne rozeti yok. 1.200 kart ise "1.200 kart" yazılsın, "10.000+" denmesin.
- Fotoğraf ya da maskot yok.
- Başlıklar Türkçe ve emir kipi yerine fayda cümlesi olsun.
- Lugat'ın başlıksız ham ekranlarına karşı başlıklı ve kısa anlatımlı kareler kullanılsın.
- Orbit, Wordlet ve Lingo'nun koyu-mor paletinden uzak durulsun (4.3 kopya algısı).

---

## 5. Açık noktalar ve doğrulanacaklar

- [D] Lingo ve Kelime Widget'ta widget'taki hoparlör uygulamayı açmadan mı çalıyor? Cihazda denenmeli. "Widget'tan dinle" iddiasının "kimsede yok" diye yazılmaması bundan.
- [D] Duolingo, WordUp ve Blarma'nın widget durumu sayfa metninden doğrulanmadı.
- [D] Türkiye vitrininde en-GB ve TR anahtar kelimelerinin birleşip birleşmediği, Türkçe kök eşlemesi ve ı/i katlaması belgelenmemiş. `raporlar/08` §1.3'te kısmi API kanıtı var.
- Arama hacmi yok. Yayından sonra Apple Ads "Search Popularity" ve App Analytics'teki arama terimleriyle setler gözden geçirilmeli.
- Ekran görüntülerinin sırası sayfa HTML'inden çıkarıldı. Kartları ve Monkey Taps'te sıra tutarsız görünüyor [D].
- "Kelime Dağarcığı" (id 6816658119, 22 Eki) incelenmedi.

---

## 6. Kaynaklar (hepsine 23 Ekim 2026'da bakıldı)

### Apple

- https://developer.apple.com/app-store/product-page/ (anahtar kelime, ad ve alt başlık kuralları)

### App Store sayfaları

Her biri `https://apps.apple.com/tr/app/id<ID>` (varsayılan) ve `…?l=tr` (Türkçe) olarak açıldı:

- 6775767149 Widget Vocabulary (Orbit)
- 1195424864 Kolay İngilizce
- 1438344260 Atlas
- 1492827466 English Words Trainer
- 1016187881 İngilizce Kelime Kartları
- 570060128 Duolingo
- 1084540807 Monkey Taps Vocabulary
- 6740177041 Lingo Widget
- 6788272428 İngilizce Öğren: Kelime Widget
- 6446258258 Word Widget
- 6816242470 Wordlet
- 6813183074 Lugat
- 6800867995 Flaş İngilizce
- 1365078730 WordUp
- 6760948982 Wrd
- 6815355508 Zarafa
- 1594884449 Blarma

### API'ler

- **Lookup:** `https://itunes.apple.com/lookup?id=<yukarıdaki ID'ler>&country=tr` (ve `&lang=tr_tr`)
- **Search:** `https://itunes.apple.com/search?term=<terim>&entity=software&country=tr&limit=15`. Terimler:
  - ingilizce kelime; kelime öğren; kelime ezberle; kilit ekranı kelime
  - ingilizce widget; kelime widget; vocabulary widget; widget vocabulary
  - günün kelimesi; kelime kartları; ingilizce öğren; lock screen vocabulary
  - ingilizce telaffuz; kelime dağarcığı; ingilizce kelime testi; a2 ingilizce
  - ingilizce b1 kelime; ingilizce okunuş; kelime tekrarlayıcı; kelime defteri
  - ingilizce günlük konuşma; english turkish; turkish english vocabulary; kelime ezberleme
- **App Store ipuçları:** `https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints?clientApplication=Software&term=<önek>`, `X-Apple-Store-Front: 143480-29,29`. 50 önek; ayrıntılar ve ham çıktı aşağıdaki dosyalarda.
- **Google otomatik tamamlama:** `https://suggestqueries.google.com/complete/search?client=firefox&hl=tr&gl=tr&q=<sorgu>` (17 TR sorgusu) ve `hl=en-GB&gl=gb` (6 sorgu).

### Ekran görüntüleri

`https://is1-ssl.mzstatic.com/image/thumb/...` adreslerindeki TR görselleri, Orbit, Kolay, Atlas, Lingo, Kelime Widget, Wordlet, Lugat, Zarafa, Wrd ve Word Widget için tarayıcıda görüntülendi. Adresler `rk/shots_body.json` dosyasında.

### Ham veri

Ham veri (API çıktıları, sayfa metinleri) depoya eklenmedi: rakip açıklamalarının tam metni var ve kopya sayılmasın. Gerekirse aynı sorgular yukarıdaki adreslerle yeniden çalıştırılır. Bayt hesabı: [`araclar/metin_say.py`](araclar/metin_say.py).
