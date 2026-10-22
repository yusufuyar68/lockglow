# Lockglow: Claude için başlangıç

Bu depo **Lockglow** projesi: kilit ekranında İngilizce kelime gösteren, Türkçe açıklamalı bir iPhone uygulaması. Proje başka bir Claude hesabından devralındı.

## Her yeni oturumda önce

1. `git pull` (depo: `github.com/yusufuyar68/lockglow`, 22 Ekim'den beri herkese açık: depoya gizli bilgi yazma).
2. **[`DEVIR.md`](DEVIR.md)'yi baştan sona oku.** Kullanıcı tanıtımı, projenin durumu, sıradaki işler ve çalışma kuralları orada.
3. Kullanıcı "klasörü incele", "devam" ya da benzeri bir şey yazarsa:
   - `DEVIR.md`'yi oku;
   - `README.md`'yi ve `ios/README.md`'yi oku;
   - `docs/icerik_uretimi/README.md`'yi oku;
   - kısa bir durum özeti ver;
   - "Hemen sıradaki iş" bölümünden devam et.

## Değişmeyen kurallar (ayrıntısı DEVIR.md'de)

- Kullanıcıyla **sade Türkçe** konuş. İngilizcesi A2 ve altı.
- Oturumlar ve alt ajanlar **Opus 5.5**, çok ajanlı denetim ve doğrulamayla (kullanıcının 2026-10-21 isteği); koordinasyon ve son kontrol sende.
- **Kimlik bilgilerine dokunma:**
  - parola, API anahtarı ya da token girmezsin, oluşturmazsın;
  - `.p8` dosyasını okumazsın;
  - Apple hesabına giriş yapmazsın.
  Bunları kullanıcı yapar.
- **İzin al:** Apple hesabında her değişiklik ve her form gönderimi için önce açık izin al.
- **CI:**
  - Swift testleri her push'ta Linux işinde koşar (bu PC'de Docker yok); macOS işini gerektiğinde `-f runner=macos-15-intel` ile çalıştır (arm64 kuyruğu takılabiliyor). Depo açık olduğu için dakikalar ücretsiz, makine sırası sınırlı.
  - Aynı dala push, o dalda koşan macOS işini iptal eder (`concurrency`); iş bitene kadar o dala push etme.
- **Kart numaraları:** `content-pipeline/data/id_registry.json`'ı elle düzenleme; uygulamadaki ilerleme bu numaralara bağlı.
- **Windows'ta Python:** `-X utf8` ile çalıştır. Dosyaları LF yaz.
- **Commit mesajları:** Türkçe. Mesajı bir dosyaya yazıp `git commit -F` kullan.
