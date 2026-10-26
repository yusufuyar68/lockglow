# Fiziksel iPhone kontrolü — hazırlık

**Bu aktarımı içeren TestFlight yüklemesi henüz onaylanmadı ve yapılmadı.** Bu liste, onaylanan aday iPhone'a kurulduktan sonra kullanılacak. Henüz hiçbir madde tamamlanmadı.

Otomatik native CI; derleme, paket testleri, simülatör etkileşimleri ve görüntüler için ayrı kanıttır. Sonuçları [KONTROL.md](KONTROL.md) içinde izlenir. Gerçek ses, mikrofon, widget yenilenmesi ve VoiceOver'ın duyulan sesi bu telefonda ayrıca gözlenecek.

- **TestFlight sürümü / build:** Bekliyor.
- **iPhone modeli / iOS sürümü:** Bekliyor.
- **Kontrol tarihi:** Bekliyor.

## Önce mevcut veriyi koru

- [ ] **Bekliyor — Yedek:** Mevcut uygulamada **Ayarlar → Verilerin → Yedek dosyasını paylaş** yoluyla JSON kopyasını erişebildiğin bir yere kaydet. Dosyanın oluştuğunu kontrol et.
- [ ] **Bekliyor — Mevcut kayıtlar:** Kurulumdan önce seviye, konular, seçilmiş günlük hedef ve birkaç bildiğin/öğrendiğin kelimeyi not et. Onaylanan aday kurulduktan sonra aynı bilgilerin kaldığını karşılaştır. Günlük hedef mevcut 5/10/15/20 seçiminden hangisiyse onu korumalı.

## Akış kartı

- [ ] **Bekliyor — Normal yazı:** İngilizce kelime, Türkçe anlam ve kısa tanım birlikte okunabilsin. Örnek cümle ve Türkçesi kartın içinde bulunsun.
- [ ] **Bekliyor — Uzun kart:** Kartın içini kaydırarak örneğe, Türkçesine ve varsa **Neden?** düğmesine ulaş. Okurken başka kelimeye atlamadığını; içerik bittikten sonra sonraki karta geçebildiğini kontrol et.
- [ ] **Bekliyor — Koyu görünüm:** Yeşil çizgi, metinler ve düğmeler rahat seçilsin; kartın zemini koyu kalsın.
- [ ] **Bekliyor — Büyük yazı:** iPhone'un yazısını büyüterek aynı kartı dene. Anlam ve düğmeler kesilmesin; son satıra kaydırarak ulaşılabilsin.
- [ ] **Bekliyor — Biliyorum / Geri al:** Bir kelimede **Biliyorum**'a dokun. Aynı kart yerinde kalsın, bilinen durumu duyurulsun. **Geri al** görünürken dokun; kelime önceki durumuna dönsün.

## Dinle ve Söyle

- [ ] **Bekliyor — Dinle:** Kelimedeki **Dinle** ve örneğin hoparlörü doğru İngilizce metni okusun. **Durdur** sesi kessin; yeniden dinleme çalışsın.
- [ ] **Bekliyor — Mikrofon ve model:** **Söyle**'yi aç; mikrofon/konuşma tanıma izninin durumunu kaydet. “İngilizce konuşma modeli iniyor” mesajı varsa tamamlanmasını bekle; zaten hazırsa bunu not et.
- [ ] **Bekliyor — Cihazda deneme:** Dinle'den sonra **Söyle** ile kısa bir kelime söyle; gerekirse **Bitti**'ye dokun. Model hazırken internet bağlantısı olmadan da dene. Sonuç, bekleme ve hata durumlarını kaydet.
- [ ] **Bekliyor — Sayfayı kapatma:** **Kapat** ile çıkıp Söyle'yi yeniden aç. Önceki ses kaydı görünmesin; mikrofon açık kalmasın.

## Gerçek widget'lar

- [ ] **Bekliyor — Yerleştirme:** **Ayarlar → Yardım → Widget nasıl eklenir?** rehberiyle ana ekrana küçük ve orta widget, kilitli ekrana dikdörtgen widget ekle. Kısa ve uzun bir kelimede metinlerin birbirine veya düğmelere taşmadığını kontrol et.
- [ ] **Bekliyor — Widget düğmeleri:** Küçük/orta widget'taki **Sonraki kelime** ve hoparlörü dene. Uygulama açıkken ve arka plandayken ses geliyor mu, uygulama kendiliğinden açılıyor mu, kaydet.
- [ ] **Bekliyor — Uygulamadan yenileme:** **Ayarlar → Widget sağlığı → Widget'ları yenile** yolunu dene. **Son güncelleme**, **Sonraki değişim** ve görünen kelimeyi not et. Bu işlem mevcut kelimeyi korur.
- [ ] **Bekliyor — Telefonda yenilenme:** Uygulama arka plandayken, ana ekrana dönünce ve telefonu kilitleyip açınca widget'ları gözle. Kelimeyi ve gözlem saatini kaydet. Seçilen değişim sıklığı bir hedef aralıktır; iOS yenilemeyi geciktirebilir, kesin dakika sözü verilmez.

## VoiceOver

- [ ] **Bekliyor — Okuma ve erişim:** VoiceOver ile kelime, Türkçe anlam, tanım ve örneği sırayla dinle. İngilizce ve Türkçe anlaşılır seslerle okunsun; **Dinle**, **Söyle** ve **Biliyorum** ayrı düğmeler olarak bulunabilsin.
- [ ] **Bekliyor — Odak ve geri alma:** VoiceOver açıkken **Biliyorum → Geri al** dene. Durum değişikliği duyulsun; odak kaybolmasın ve kaydırılan içerikteki son düğmeye ulaşılabilsin.

## Bulgu kaydı

- [ ] **Bekliyor — Sonuçları kaydet:** Her bulguya build, iPhone/iOS, kelime, yazı boyutu/görünüm, yapılan dokunuşlar ve mümkünse ekran görüntüsü ekle. CI sonucunu ve bu cihaz gözlemini ayrı yaz.
