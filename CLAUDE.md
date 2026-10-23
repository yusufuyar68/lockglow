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

## Tasarım kuralları: Apple dili (kullanıcının 2026-10-24 isteği)

Ürün bir **iPhone uygulaması**; site değil. Her tasarım işinde, mockup'ta ve kod değişikliğinde bu kurallar geçerli. Uymayan ekran varsa uydur.

- **Apple Human Interface Guidelines'tan ayrılma.** Gezinmede büyük başlık, alt sekme çubuğunda SF Symbols, Ayarlar ve listelerde iOS'un gruplu liste görünümü, ikinci derece sayfalarda sheet, onaylarda iOS uyarısı kullan. Standart denetimleri tercih et.
- **Yazı boyları Dynamic Type metin stillerinden gelir**, sabit punto yazılmaz:
  - Large Title 34;
  - Title 1 28, Title 2 22, Title 3 20;
  - Headline 17 kalın, Body 17;
  - Callout 16, Subheadline 15, Footnote 13;
  - Caption 1 12, Caption 2 11.

  Bir ekranda en çok 3–4 farklı boy kullan; hiyerarşi boy ve kalınlıkla kurulur. Türkçe arayüz SF Pro ile yazılır. İngilizce kelime ve örnek cümle New York (serif) ile yazılabilir. 11 pt'nin altına inme.
- **Renk Apple'ın anlamsal renk mantığıyla kurulur.**
  - Metin label / secondaryLabel / tertiaryLabel kademesiyle yazılır.
  - Zeminler systemBackground ve secondarySystemBackground, ayraçlar separator.
  - Tek vurgu rengi (tint) var: marka sarısı yalnız vurgu için kullanılır, büyük dolgu yapmaz.
  - Açık, koyu ve Yüksek Kontrast'ın her birinde metin kontrastı en az 4.5:1, büyük yazıda en az 3:1.
  - `LockglowTheme` token'ları bu kademeye uymalı.
- **Ölçüler:**
  - Kenar boşluğu 16 pt, 8 pt ızgara.
  - Dokunma alanı en az 44×44 pt.
  - Güvenli alan ve Dynamic Island'a saygı.
  - Widget'lar Apple'ın widget kenar boşluklarıyla.
- **Ekrana sığma:** her ekran iPhone SE (375×667) ile Pro Max arasında ve en büyük erişilebilir yazıda (AX5) kesilmeden çalışmalı. Metin "…" ile kesilmez, satır kayar ya da sayfa kayar. Değişiklikten sonra ekran görüntülerini (`screenshots.yml`) tek tek kontrol et: SE, büyük yazı, koyu mod, widget'lar.
- **Mockup'lar mobil:** telefon çerçevesinde, 390×844 pt iPhone ekranı; ayrıca widget ve kilit ekranı boyutları. Masaüstü ya da web sayfası düzeni değil.
