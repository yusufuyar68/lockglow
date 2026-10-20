# Lockglow: Claude için başlangıç

Bu depo **Lockglow** projesi: kilit ekranında İngilizce kelime gösteren, Türkçe açıklamalı bir iPhone uygulaması. Proje başka bir Claude hesabından devralındı.

## Her yeni oturumda önce

1. `git pull` (depo: `github.com/yusuf68435/lockglow`, özel).
2. **[`DEVIR.md`](DEVIR.md)'yi baştan sona oku.** Kullanıcı tanıtımı, projenin durumu, sıradaki işler ve çalışma kuralları orada.
3. Kullanıcı "klasörü incele", "devam" ya da benzeri bir şey yazarsa:
   - `DEVIR.md`'yi oku;
   - `README.md`'yi ve `ios/README.md`'yi oku;
   - `docs/icerik_uretimi/README.md`'yi oku;
   - kısa bir durum özeti ver;
   - "Hemen sıradaki iş" bölümünden devam et.

## Değişmeyen kurallar (ayrıntısı DEVIR.md'de)

- Kullanıcıyla **sade Türkçe** konuş. İngilizcesi A2 ve altı.
- Alt ajanlar **Sonnet**, koordinasyon ve son kontrol sende.
- **Kimlik bilgilerine dokunma:**
  - parola, API anahtarı ya da token girmezsin, oluşturmazsın;
  - `.p8` dosyasını okumazsın;
  - Apple hesabına giriş yapmazsın.
  Bunları kullanıcı yapar.
- **İzin al:** Apple hesabında her değişiklik ve her form gönderimi için önce açık izin al.
- **macOS dakikaları 10 kat sayılıyor:**
  - push öncesi `bash ios/Tools/linux_check.sh` çalıştır;
  - `screenshots.yml`'yi az çalıştır;
  - TestFlight için kota bırak.
- **Kart numaraları:** `content-pipeline/data/id_registry.json`'ı elle düzenleme; uygulamadaki ilerleme bu numaralara bağlı.
- **Windows'ta Python:** `-X utf8` ile çalıştır. Dosyaları LF yaz.
- **Commit mesajları:** Türkçe. Mesajı bir dosyaya yazıp `git commit -F` kullan.
