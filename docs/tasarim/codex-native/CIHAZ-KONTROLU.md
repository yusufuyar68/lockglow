# Fiziksel iPhone kontrolü — hazırlık

**TestFlight 0.1.0 (40) kullanıcı onayıyla yüklendi.** Apple VALID ve IN_BETA_TESTING durumu, mevcut Ben grubunda build 40 erişimi ve hesap sahibinin üyeliği 26 Ekim 2026'da salt okunur kontrolle doğrulandı. Fiziksel kurulum ve aşağıdaki test sonuçları henüz kullanıcı tarafından bildirilmedi; hiçbir fiziksel madde tamamlandı sayılmadı.

Otomatik native CI; derleme, paket testleri, simülatör etkileşimleri ve görüntüler için ayrı kanıttır. Sonuçları [KONTROL.md](KONTROL.md) içinde izlenir. Gerçek ses, mikrofon, widget yenilenmesi ve VoiceOver'ın duyulan sesi bu telefonda ayrıca gözlenecek.

- **TestFlight sürümü / build:** 0.1.0 (40); yükleme kaynağı e26a302.
- **iPhone modeli / iOS sürümü:** iPhone 15 Pro Max / iOS 27.0.1 (kullanıcı beyanı).
- **Kontrol tarihi:** Dağıtım 26 Ekim 2026; fiziksel test sonuçları bekleniyor.
- **Ekran / yazı / görünüm / Display Zoom:** Bekliyor. Sonuç bu cihaz/ayar birleşimine aittir; başka model için geçirilmez.

Tüm ekran ve cihaz sınıflarının planı [CIHAZ-UYUM-PLANI.md](CIHAZ-UYUM-PLANI.md) içindedir. Aşağıdaki genişletilmiş maddeler de **henüz denenmedi** durumundadır.

İlk fiziksel tur: TestFlight'ta 0.1.0 (40) güncellenir; mevcut hedef/ilerleme karşılaştırılır, Akış kartı ve örnek/çeviri incelenir, Biliyorum/Geri al ve Dinle/Söyle denenir. Bu turdan sonra koyu görünüm, büyük yazı ve widget maddelerine geçilir. Yalnız kullanıcının gözlediği maddeler sonuçla işaretlenir.

## Önce mevcut veriyi koru

- [ ] **Bekliyor — Yedek:** Mevcut uygulamada **Ayarlar → Verilerin → Yedek dosyasını paylaş** yoluyla JSON kopyasını erişebildiğin bir yere kaydet. Dosyanın oluştuğunu kontrol et.
- [ ] **Bekliyor — Mevcut kayıtlar:** Kurulumdan önce seviye, konular, seçilmiş günlük hedef ve birkaç bildiğin/öğrendiğin kelimeyi not et. Onaylanan aday kurulduktan sonra aynı bilgilerin kaldığını karşılaştır. Günlük hedef mevcut 5/10/15/20 seçiminden hangisiyse onu korumalı.

## Akış kartı

- [ ] **Bekliyor — Normal yazı:** İngilizce kelime, Türkçe anlam ve kısa tanım birlikte okunabilsin. Örnek cümle ve Türkçesi kartın içinde bulunsun.
- [ ] **Bekliyor — Uzun kart:** Kartın içini kaydırarak örneğe, Türkçesine ve varsa **Neden?** düğmesine ulaş. Okurken başka kelimeye atlamadığını; içerik bittikten sonra sonraki karta geçebildiğini kontrol et.
- [ ] **Bekliyor — Koyu görünüm:** Yeşil çizgi, metinler ve düğmeler rahat seçilsin; kartın zemini koyu kalsın.
- [ ] **Bekliyor — Büyük yazı:** iPhone'un yazısını büyüterek aynı kartı dene. Anlam ve düğmeler kesilmesin; son satıra kaydırarak ulaşılabilsin.
- [ ] **Bekliyor — Display Zoom ve güvenli alan:** Cihazın mevcut zoom ayarını kaydet. Büyük yazıda alt düğme, home indicator ve çentik/Dynamic Island çevresi içeriği örtmesin. Klavyeli bir formda son eyleme ulaş; bu gözlemi normal zoom sonucu ile karıştırma.
- [ ] **Bekliyor — Biliyorum / Geri al:** Bir kelimede **Biliyorum**'a dokun. Aynı kart yerinde kalsın, bilinen durumu duyurulsun. **Geri al** görünürken dokun; kelime önceki durumuna dönsün.

## Dinle ve Söyle

- [ ] **Bekliyor — Dinle:** Kelimedeki **Dinle** ve örneğin hoparlörü doğru İngilizce metni okusun. **Durdur** sesi kessin; yeniden dinleme çalışsın.
- [ ] **Bekliyor — Mikrofon ve model:** **Söyle**'yi aç; mikrofon/konuşma tanıma izninin durumunu kaydet. “İngilizce konuşma modeli iniyor” mesajı varsa tamamlanmasını bekle; zaten hazırsa bunu not et.
- [ ] **Bekliyor — Cihazda deneme:** Dinle'den sonra **Söyle** ile kısa bir kelime söyle; gerekirse **Bitti**'ye dokun. Model hazırken internet bağlantısı olmadan da dene. Sonuç, bekleme ve hata durumlarını kaydet.
- [ ] **Bekliyor — Sayfayı kapatma:** **Kapat** ile çıkıp Söyle'yi yeniden aç. Önceki ses kaydı görünmesin; mikrofon açık kalmasın.
- [ ] **Bekliyor — iOS/model ayrımı ve izin reddi:** iOS 17–25'te cihazda İngilizce tanıyıcı yoksa uygun hata ve çıkış; iOS 26+'ta model yok/indirilemiyor durumunda bekleme/hata ve Vazgeç erişilsin. İzin verilmemesi ayrı kaydedilsin. Bir sürümün sonucu öteki yolu doğrulamaz.

## Gerçek widget'lar

- [ ] **Bekliyor — Yerleştirme:** **Ayarlar → Yardım → Widget nasıl eklenir?** rehberiyle ana ekrana küçük ve orta widget, kilitli ekrana dikdörtgen widget ekle. Kısa ve uzun bir kelimede metinlerin birbirine veya düğmelere taşmadığını kontrol et.
- [ ] **Bekliyor — Widget düğmeleri:** Küçük/orta widget'taki **Sonraki kelime** ve hoparlörü dene. Uygulama açıkken ve arka plandayken ses geliyor mu, uygulama kendiliğinden açılıyor mu, kaydet.
- [ ] **Bekliyor — Uygulamadan yenileme:** **Ayarlar → Widget sağlığı → Widget'ları yenile** yolunu dene. **Son güncelleme**, **Sonraki değişim** ve görünen kelimeyi not et. Bu işlem mevcut kelimeyi korur.
- [ ] **Bekliyor — Telefonda yenilenme:** Uygulama arka plandayken, ana ekrana dönünce ve telefonu kilitleyip açınca widget'ları gözle. Kelimeyi ve gözlem saatini kaydet. Seçilen değişim sıklığı bir hedef aralıktır; iOS yenilemeyi geciktirebilir, kesin dakika sözü verilmez.
- [ ] **Bekliyor — Diğer sistem yüzeyleri:** Büyük kelime widget'ı, quiz, ilerleme ve Tekrar Live Activity / Dynamic Island'ı cihazın sunduğu alanlarda ayrı dene. iOS 18+ denetimlerini ayrıca kaydet; desteklenmeyen yüzey çalışmış sayılmaz.
- [ ] **Bekliyor — Hassas içerik ve eski önbellek:** Hassas işaretli kart widget'a/ses isteğine sızmasın. Eski quiz önbelleğinde cevap verilmiş soru varsa güncel plan yeniden kurulduğunda eski cevabın yeni seçeneklere taşınmadığını kontrol et; uygulama açılana kadarki boş/bekleme durumunu da kaydet.

## Kamera, fotoğraf ve cihaz içi öneri

- [ ] **Bekliyor — Metinden kelime bul:** Yaz/yapıştır, fotoğraf seç/iptal, okunamayan fotoğraf ve boş OCR durumları denenir. Desteksiz cihazda canlı tarama düğmesi görünmez; yazma/yapıştırma/fotoğraf yolu kalır. Destekli cihazda kamera izni ve gerçek tarama ayrıca kaydedilir.
- [ ] **Bekliyor — Kendi cümleni yaz:** Klavyede Kontrol et/Kapat erişilir, temel kural sonucu çalışır. Cihaz içi model uygun değilken öneri panelinin gizli kalması temel alıştırmayı engellemez. Uygun cihaz/iOS 26+ sonucu ve model kullanılamaz sonucu ayrı kaydedilir.
- [ ] **Bekliyor — Diğer formlar:** Kendi kelimelerini ekle/düzenle, Cümle kur, Yaz ve Dinle ve seç rotalarında dar/büyük yazı/klavye birleşiminde son eylem erişilir. Kaydet/iptal ve geri dönüş bağlamı korunur.

## VoiceOver

- [ ] **Bekliyor — Okuma ve erişim:** VoiceOver ile kelime, Türkçe anlam, tanım ve örneği sırayla dinle. İngilizce ve Türkçe anlaşılır seslerle okunsun; **Dinle**, **Söyle** ve **Biliyorum** ayrı düğmeler olarak bulunabilsin.
- [ ] **Bekliyor — Odak ve geri alma:** VoiceOver açıkken **Biliyorum → Geri al** dene. Durum değişikliği duyulsun; odak kaybolmasın ve kaydırılan içerikteki son düğmeye ulaşılabilsin.

## Bulgu kaydı

- [ ] **Bekliyor — Sonuçları kaydet:** Her bulguya build, iPhone/iOS, kelime, yazı boyutu/görünüm, yapılan dokunuşlar ve mümkünse ekran görüntüsü ekle. CI sonucunu ve bu cihaz gözlemini ayrı yaz.
