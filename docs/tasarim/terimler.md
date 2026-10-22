# Lockglow terim sözlüğü

22 Ekim 2026. Arayüzde her kavramın **tek bir Türkçe adı** olur. Bu sayfa o adı, kullanılmayacak eş anlamlıları ve bir örneği verir. Kaynaklar: [`ogrenme_ilkeleri.md`](ogrenme_ilkeleri.md) (§1 madde 11–12, §2, §3), [`README.md`](README.md) madde 13 ve [`../denetim/metin_denetimi_2026-10-22.md`](../denetim/metin_denetimi_2026-10-22.md).

Yeni bir metin yazarken önce buraya bak. Bir ad değişirse burayı ve `docs/denetim/araclar/metin_cikar.py` içindeki `TERMS` tablosunu birlikte değiştir. Betik bu tablodaki "kullanma" adlarını `--isaret` ile işaretler.

## 1. Genel kurallar

### Hitap
- **Kullanıcıya "sen":** "dokun", "seçebilirsin", "Bildiğin kelimeler". "Siz" hiçbir yerde yok ("dokunun", "seçiniz" olmaz).
- **Uygulama kendinden "biz" diye söz eder:** "soracağız", "hatırlatalım", "başlayalım". "Ben" yok: "Ne zaman hatırlatayım?" yerine "Ne zaman hatırlatalım?".
- **Düğmeler kullanıcının ağzından konuşabilir (1. tekil):** "Biliyorum", "Bildim", "Bilemedim", ileride "Buldum". Bunlar cevaptır.
- **Başlık, durum ve liste adları "sen"le yazılır:** "Bildiğin kelimeler", "Öğreniyorsun", "Bildiğin kelime". "Bildiğim kelimeler" olmaz; aynı ekranda iki hitap karışmaz.
- **Söyle'de konuşan telefondur.** Kısa durum adları 1. tekil kalabilir: "Dinliyorum…", "Seni duyamadım". Açıklama cümleleri 3. kişidir: "Telefon “think” diye duydu."
- **Dil açıklamalarında kapsayıcı "biz":** "Türkçede iki ekmek deriz."

### Ekler ve sayılar
- **Değişkene, sayıya ve saate Türkçe ek gelmez.** Cümleyi ek gerekmeyecek biçimde kur.
  - "\(word)'ü" yerine "Öğrenmeye döndü: breakfast".
  - "9'u" yerine "7 tanesini bildin".
  - "20:00'de" yerine "Hatırlatma: 20:00".
- **Uygulamadaki adlara kesmeyle ek gelebilir:** "Tekrar'da", "Ayarlar'dan", "Dinle'ye dokun", "Söyle'ye dokun". Bunlar sabit adlardır, değişken değil.
- **Tırnak içindeki düğme adına ek getirme.** "\"Widget'ları yenile\"yi dene" yerine "Widget'ları yenile düğmesine dokun".
- **Sayı birimi her zaman "kelime"dir:** "Başla (10 kelime)", "933 kelime". "kart" sayı birimi olmaz (bkz. kart).
- **"/" yalnız görünür sayaçta durur** ("Kart 3 / 10", "2 / 5"). VoiceOver "/" işaretini "bölü" diye okur. Bu yüzden erişilebilirlik adı "Kart 3, toplam 10" olur.
- **">" ile yol yazma** ("Ayarlar > Yardım"). VoiceOver ">" işaretini "büyüktür" diye okuyabilir. "Ayarlar'da Yardım bölümü" ya da "Ayarlar, sonra Yardım" yaz.
- **Saat 24 saatle ve iki haneyle yazılır:** "09:00". Tarih ve saat birlikte: "bugün 21:40", "yarın 09:15", "24 Ekim 09:00".

### Yazım ve ton
- **Büyük harf cümle düzenindedir:** "Yemek ve içecek", "Widget sağlığı". Başlıkta her kelime büyük olmaz ("İltifatlar ve Laf Sokmalar" olmaz).
- **Vurgu için BÜYÜK HARF kullanılmaz.** Kalın yazı kullanılır. Kodda `.uppercased()` gerekirse `uppercased(with: Locale(identifier: "tr_TR"))` yazılır; yoksa "i" harfi "I" olur.
- **Üç nokta tek karakterdir:** "…" ("..." değil).
- **Ünlem yok.** Tek istisna Söyle'nin iki durum başlığıdır: "Anlaşıldı!" ve "Neredeyse!" (ilkeler 2.7).
- **Kişiye övgü yok:** "Harikasın!", "Güzel iş!", "çok iyi" olmaz. Geri bildirim işe dairdir: "Doğrusu: borrow".
- **Baskı ve suçlama yok:** "kaçırma", "serin bozuldu", "birikti", "seni özledik" olmaz. Büyük birikmiş sayı gösterilmez.
- **Tutulamayan zaman sözü yok:** "10 dakika sonra yine gelir" yerine "Bir sonraki turda yine soracağız."
- **Bir cümle en çok yaklaşık 12 kelimedir.** Bir açıklama en çok iki cümledir. A2 okurun bilmeyebileceği kelimeler ("pekiştirmek", "sınamak", "iletilecek") yerine günlük kelimeler kullanılır.
- **Parantez içinde İngilizce terim yok:** "sınama etkisi (testing effect)" yerine "sınama etkisi".
- **Hata metni kullanıcıya teknik ad göstermez:** "content.sqlite", "App Group", "Debug" gibi adlar yalnız "Teknik bilgiler" içinde durur.

## 2. Ekranlar ve sekmeler

| Ad | Ne demek | Kullanma | Örnek |
|---|---|---|---|
| **Akış** | Kelime kartlarını kaydırarak gördüğün sekme. | Ana sayfa, Anasayfa, Keşfet, Kartlar | "Akış'taki kartlarda Söyle düğmesi var." |
| **Tekrar** | Kelimeleri hatırlamaya çalıştığın sekme. Sekmeyi kastederken büyük T ve kesme işaretiyle: "Tekrar'da", "Tekrar'a". | tekrar turu, Çalış, Pratik, Quiz, Test | "Kelime yeniden Tekrar'a gelir." |
| **tekrar** (küçük) | Bir kelimenin yeniden sorulması; sayılabilir. | sekme adı yerine "tekrara", "tekrarda" | "Bugün: 3 yeni kelime, 12 tekrar." |
| **tur** | Tekrar'da en çok 10 soruluk bölüm. | oturum, set, ders | "Tur bitti", "Bir tur daha", "Bu turun kelimeleri" |
| **Sözlük** | Kelime aradığın sekme. "Kelime ara" eylem olarak serbesttir. | Arama, Ara (sekme adı olarak) | "Akış'ta ve Sözlük'te…" |
| **Ayarlar** | Uygulamanın ayarları. iPhone'un ayarları için **iPhone Ayarları**. | Tercihler, Seçenekler | "iPhone Ayarları'nda Lockglow için bildirimleri aç." |
| **Söyle** | Telaffuz alıştırması: hem düğme hem sayfa adı. Fiil olarak "söyle" serbest. | Telaffuz testi, Konuş, Sesli söyle (düğme adı olarak), alıştırma | "Kartlardaki Söyle'ye dokun." |
| **Nasıl öğrenirim?** | Öğrenme rehberi sayfası. | Yardım, Kılavuz (sayfa adı olarak) | "Ayarlar'da Nasıl öğrenirim?" |
| **Widget sağlığı** | Widget'ın çalışıp çalışmadığını gösteren sayfa. | Widget durumu, Tanılama | "Widget sağlığı · Çalışıyor" |

## 3. Düğmeler ve cevaplar

| Ad | Ne demek | Kullanma | Örnek |
|---|---|---|---|
| **Dinle** | Kelimeyi ya da cümleyi sesli okutan düğme. VoiceOver adı "Kelimeyi dinle" ya da "Cümleyi dinle"dir; Sesli Denetim için `accessibilityInputLabels(["Dinle"])`. Çalarken "Durdur". | Seslendir, Sesli oku, hoparlör düğmesi, Oynat | "Önce Dinle'ye dokunup dinle." |
| **Biliyorum** | Kelimeyi öğrenme listesinden çıkaran işaret (Akış, widget). 3 gün sonra bir kez sorulur (ilkeler 2.2). Sözlük'ün "Durum" bölümünde uzun biçimi **Biliyorum olarak işaretle** (ilkeler 2.6). | Bildiklerime ekle, Bu kelimeyi biliyorum, Öğrendim | "Biliyorum" → "Tamam. 3 gün sonra bir kez soracağız." |
| **Bunu zaten biliyorum** | (İleride, ilkeler 2.3) Tanış ön yüzündeki düz düğme. "Biliyorum" ile aynı kuralı izler. | Zaten biliyorum, Atla | — |
| **Öğrenmeye geri al** | Bildiğin bir kelimeyi öğrenme listesine döndürür. Kısa biçimi **Geri al** yalnız yanında "Bildiğin kelime" yazısı varken ya da 5 saniyelik bildirimde kullanılır. VoiceOver'da kısa düğme kelimeyi de söyler (değer: "breakfast"). | Kaldır, Sil, Bilmiyorum | "Öğrenmeye döndü: breakfast" + "Vazgeç" |
| **Anlamını göster** | Tekrar'da anlamı açan düğme. | Anlamı göster, Cevabı göster, Çevir | "Anlamını göster" → "Sonraki" (ilkeler 2.3) |
| **Bilemedim** | Tekrar cevabı: aklına gelmedi. Kelime bir sonraki turda yine sorulur. | Bilmiyorum, Unuttum, Yanlış, Tekrar et | "Bilemedim · sonraki turda" |
| **Zor** | Tekrar cevabı: bildin ama zorlandın. Quiz'de doğru cevaptan sonra da aynı ad. | Zordu, Zor ama bildim | "“Zor” da doğru cevap sayılır." |
| **Bildim** | Tekrar cevabı: bildin. | Biliyordum, Doğru bildim, Biliyorum (cevap olarak) | "Bildim · yarın" |
| **Kolay** | Tekrar cevabı: hiç düşünmeden bildin. Quiz'de doğru cevaptan sonra da aynı ad. | Kolaydı, Çok kolay | "Kolay · 2 gün sonra" |
| **Zor muydu, kolay mı?** | Quiz'de doğru cevaptan sonraki isteğe bağlı soru; düğmeleri "Zor" ve "Kolay". | Ya da bu soru nasıl geldi?, Nasıldı? | — |
| **Tanış**, **Hatırla** | (İleride, ilkeler 2.3) Yeni kelime turunun iki adımı. | Öğren, Sına, Test | "Önce tanış, sonra hemen bir kez hatırla." |
| **Göster**, **Bulamadım**, **Buldum** | (İleride, ilkeler 2.3) Kutu 4–5 hatırlama ekranı. | Bilmiyorum / Biliyorum | "Göstermeden önce aklına geldi mi?" |
| **Sonraki kelime** | Widget'ta sıradaki kelimeye geçen düğme. | Atla, Geç, İleri | — |
| **Devam** | Quiz'de sonraki soruya geçer. | İleri, Sonraki (quiz'de) | — |
| **Bitir** | Turu erken bitirir; cevaplar kaydedilir. | Çık, Kapat (turda) | — |
| **Tamam** | Özeti kapatır; onaylar. | OK, Peki | — |
| **Kapat** | Sayfayı kapatır. | Bitti (sayfada), Geri | — |
| **Vazgeç** | İletişim kutusunu kapatır ya da az önceki değişikliği bırakır. | İptal | — |
| **Atla** | Yalnız açılış sayfalarını geçer. | Geç, Sonra | — |
| **dokun** | Ekrandaki her dokunma eylemi. Apple'ın "basılı tut" sözü serbest. | bas, basma, tıkla | "Bitti'ye dokun." |

## 4. Öğrenme kavramları

| Ad | Ne demek | Kullanma | Örnek |
|---|---|---|---|
| **kelime** | Öğrenilen her şey: tek kelime ya da kalıp. Sayılar hep "kelime" ile. | sözcük, madde, kart (sayı birimi olarak) | "Bugünün yeni kelimeleri: 5" |
| **kart** | Ekrandaki kutu: Akış kartı, Tekrar kartı, Sözlük ayrıntısı. Yalnız görünüşten söz ederken. Sıra göstergesi "Kart 3 / 10" kalabilir. | sayı birimi olarak ("10 kart", "933 kart") | "Kartın tamamını açar." |
| **kalıp** | Birden çok kelimelik ifade ("Could you tell me the way to"). Kartta tür etiketi. | ifade, phrase, öbek | Tür etiketi: "kalıp" |
| **kalıp fiil** | İki ya da üç parçalı fiil (get up, look forward to). Konu adı "Kalıp fiiller" (ilkeler 2.2 [BELKİ]). | iki kelimeli fiil (look forward to üç kelime), phrasal verb | Tür etiketi: "kalıp fiil" |
| **deyim** | Yalnız "Deyimler" konusu için (idiom). | kalıp yerine deyim | — |
| **anlam** | Kelimenin Türkçe karşılığı. | mana, çeviri, tercüme | "Anlamı: kaşık" |
| **Türkçesi** | Örnek cümlenin Türkçesi; VoiceOver'da anlamın öneki. | Çeviri, Tercüme | "spoon, Türkçesi: kaşık" |
| **örnek cümle** | Kelimenin geçtiği İngilizce cümle. Bölüm başlığında "Örnekler". | cümle örneği | "Örnek cümle ve Dikkat" |
| **ipucu** | Tekrar ön yüzünde örnek cümleyi açan çip. Sözlük'te ayrı bir kavram: **Hafıza ipucu**. | yardım, hint | "İpucu" |
| **Dikkat** | Türkçe konuşanların sık yaptığı hata kutusu. Olumlu kuralla yazılır. | Uyarı, Hata, Sık yapılan hatalar (başlık olarak) | "Dikkat: sık yapılan hata" |
| **sahte dost** | Türkçeye benzeyen ama anlamı başka olan kelime. | tuzak kelime, yanıltıcı kelime | "Sahte dost: aktüel ≠ actually" |
| **birlikte kullanılır** | Eşdizim (collocation). Sözlük bölümü "Birlikte kullanılır"; konu adı "Kelime ikilileri". | eşdizim, collocation | — |
| **öğrenme listesi** | Öğrenmekte olduğun kelimeler. | kuyruk, sıra (kullanıcıya) | "Bu kelime öğrenme listene döndü." |
| Durum adları | **Yeni kelime** · **Öğreniyorsun** · **Bildiğin kelime** | Biliyorsun, Öğreniyorum, Bildiğim kelime | Sözlük "Durum" bölümü |
| **Bildiğin kelimeler** | "Biliyorum" dediğin ya da öğrendiğin kelimelerin listesi. | Bildiğim kelimeler, Bildiklerim | "Henüz bildiğin kelime yok" |
| **basamak** | Kullanıcıya anlatılan tekrar aralığı adımı (1, 2, 4, 8, 16 gün). Kodda ve ilkelerde "kutu", alt-ilerleme önerisinde "raf". Arayüzde yalnız "basamak". | kutu, raf, seviye (bu anlamda) | "Kelime bir basamak çıkar." |
| **seviye** | A1, A2, B1. | düzey, kur, level | "İngilizcen hangi seviyede?" |
| **konu** | İçerik grubu: "Yemek ve içecek". Konu gruplarının başlıkları ("Günlük hayat") ayrı bir ad almaz. | deste, kategori, paket, set | "Seçili: 120 kelime" |
| **Tümü** / **tüm** | Bütün konuları seçmek. Aynı satırda "Tümü" ile "Bütün konular" karışmaz. | bütün (aynı ekranda karışık) | "Tümü · Tüm konular, 933 kelime" |
| **günlük hedef** | Günde kaç yeni kelime çalışmak istediğin. Halkanın altında da aynı ad. | bugünkü hedef, kota, görev | "Günlük hedefi değiştir" |
| **sıradaki tekrar** | En yakın tekrar zamanı. | sonraki seans | "Sıradaki tekrar: bugün 21:40" |

## 5. Widget, kilitli ekran ve hatırlatma

| Ad | Ne demek | Kullanma | Örnek |
|---|---|---|---|
| **widget** | Ana ekrana ya da kilitli ekrana eklenen Lockglow kutusu. Apple Türkçede "araç takımı" der; uygulamada "widget" kalır ve rehber bunu bir kez söyler. Apple düğme adları tam yazılır: "Araç Takımı Ekle". Ekler kesmeyle: widget'a, widget'ta. | pencere öğesi, bileşen, araç (tek başına) | "iPhone widget'a “araç takımı” der." |
| **kilitli ekran** | Apple'ın Türkçe adı. | kilit ekranı, kilit ekran | "Kelimeler kilitli ekranında kendiliğinden değişir." |
| **ana ekran** | Apple'ın Türkçe adı. | giriş ekranı, masaüstü | "Ana ekranda boş bir yeri basılı tut." |
| **hatırlatma** | Günde bir gelen bildirim (Lockglow özelliği). Ayarlar bölümünün adı da "Hatırlatma". iOS izni için Apple'ın adı: **bildirim izni**. | Bildirim (özellik adı olarak), uyarı, alarm. Ayrıca "hatırlatma" başka anlamda kullanılmaz: widget'ta görmek ya da 30 gün sonraki soru "hatırlatma" değildir. | "Hatırlatma: 20:00", "Bildirim iznini aç" |
| **Yeni kelime: 09:00** | Orta widget'ta kelimenin değişeceği saat (README madde 13). VoiceOver adı "Sonraki değişim: 09:00". | "09:00'da değişir" | — |
| **Kelime değişim sıklığı** | Widget'taki kelimenin ne kadar sürede bir değiştiği. | yenileme aralığı, rotasyon | "Kelime ne sıklıkla değişsin?" |

## 6. Sık karışan çiftler: hangisi nerede?

- **Biliyorum** (işaret, Akış/widget/Sözlük) ≠ **Bildim** (Tekrar cevabı). İkisi aynı ekranda görünmez.
- **Bilemedim** (Tekrar cevabı) ≠ **Yanlış** (yalnız quiz şıkının küçük etiketi, simgeyle).
- **Tekrar** (sekme, büyük harf) ≠ **tekrar** (bir kelimenin yeniden sorulması).
- **hatırlatma** (günlük bildirim) ≠ **hatırlamak** (Tekrar'da cevabı akıldan bulmak) ≠ 3 gün / 30 gün sonraki **tek soru** ("bir kez sorarız").
- **Sonraki kelime** (widget düğmesi) ≠ **sıradaki kelime** (kuyrukta bekleyen kelime; bildirim başlığı).
- **kalıp** (çok kelimelik ifade) ≠ **kalıp fiil** (phrasal verb) ≠ **deyim** (idiom konusu).
- **yine gelir** her yerde; "yeniden gelir" ile karışmaz ("Bildim, yarın yine gelir").
