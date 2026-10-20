# Devir notu: Lockglow (2026-10-20)

Bu projeye başka bir Claude hesabı ya da oturumu devam edecekse **önce bu dosyayı baştan sona oku.** Ekran görüntülü durum özeti: [`docs/lockglow_ilerleme.html`](docs/lockglow_ilerleme.html). Tarayıcıda açılır.

## Kullanıcı (proje sahibi)

- **İletişim tarzı:**
  - Türkçe yazar; cevapları sade Türkçeyle ver.
  - İngilizcesi **A2 ve altı**. Hedefi günlük İngilizce.
  - Uygulamayı **önce kendisi için** yapıyor; mağaza sonra.
  - İşi çoğunlukla Claude'a bırakır ("devam", "sen hallet her şeyi"). Kısa ilerleme mesajları ve net sonraki adım bekler.
- **Ajan kullanımı:** Alt ajanlar **Sonnet**, koordinasyon ve son kontrol **Opus**.
- **Donanım:** Windows PC'de çalışıyor; Mac var ama kullanılmıyor, bütün iOS derlemeleri GitHub Actions'ta. iPhone'u iOS 26+.
- **Apple hesabı:** Ücretli Apple Developer hesabı var.
  - Ekip **Yusuf Uyar**, Team ID `3B57WU65P8`.
  - App Store Connect'te bir de "Ali Celebi" ekibi görünüyor. **Onu seçme.**
- **Hukuki durum:** Şirketi yok. Mağazaya çıkarken şahıs/GVK 20/B yolu SMMM ile konuşulacak.
- **Anthropic API anahtarı yok.** Kartlar oturum içi ajanlarla yazılıyor (`docs/icerik_uretimi/`).

## Proje

Lockglow, kilit ekranında ve ana ekranda İngilizce kelime gösteren, Türkçe açıklamalı bir iPhone uygulaması. "Widget Vocabulary: Learn Words" uygulamasının incelemesinden doğdu (`Widget_Vocabulary_Analiz_ve_Plan.md`, `raporlar/`).

- **Depo:** `github.com/yusuf68435/lockglow` (özel). `gh` CLI bu bilgisayarda `yusuf68435` olarak oturum açmış.
- **iOS:** `ios/`.
  - XcodeGen projesi (`project.yml`).
  - SwiftUI uygulama ve WidgetKit widget'ları.
  - `Packages/VocabKit` modülleri: CoreModels, TextFold, SharedState, Scheduler, ContentStore (GRDB), Learning.
  - Tanımlayıcılar: bundle `com.yusufuyar.vocabwidget` ve `.widgets`; App Group `group.com.yusufuyar.vocabwidget`; URL şeması `vocabwidget://`.
- **İçerik hattı:** `content-pipeline/` (Python `vocabpipe`): şema, doğrulayıcı, derleyici.
- **Kartlar:** `content/drafts/kisisel_v1/s0_ornek … s9`, toplam 752 taslak kart.
  - Uygulamaya derlenmiş hâli: `ios/App/Resources/content.sqlite` (`2026.10.20-kisisel-3`) ve `ios/Widgets/Resources/seed_words.json`.
  - Kart numaraları `content-pipeline/data/id_registry.json` içinde kalıcı. Uygulamadaki ilerleme bunlara bağlı, **elle düzenleme**.

## Durum

- **Uygulama:** CI'da Xcode 26.3 ile derleniyor. Simülatörde ekran görüntüleriyle denendi.
  - Sekmeler:
    - **Akış**
    - **Tekrar:** Leitner aralıklı tekrar; zamanı gelen kelimede 4 şıklı boşluk doldurma
    - **Sözlük:** Türkçe harf katlamalı arama
    - **Ayarlar:** widget sıklığı, günlük hedef, günlük hatırlatma, bildiğim kelimeler ve geri alma, widget sağlığı
  - Widget'lar: küçük, orta, kilit ekranı. "Sonraki" ve "Biliyorum" düğmeleri etkileşimli.
  - Sesli telaffuz cihazın kendi sesiyle (AVSpeechSynthesizer).
  - İlerleme dosyasının günlük yedeği alınıyor; bozuk dosya kenara alınıyor.
- **Testler:**
  - 113 Swift testi (Linux, Docker): `bash ios/Tools/linux_check.sh`.
  - 72 Python testi.
  - Her akış `--strict` doğrulamadan 0 uyarıyla geçiyor.
- **Apple kayıtları:** App Group, iki App ID ve App Store Connect uygulama kaydı oluşturuldu (Yusuf Uyar ekibi).
- **TestFlight:** `.github/workflows/testflight.yml` hazır. GitHub gizli değişkenleri (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`) eklenmedikçe imzasız kuru çalıştırma yapar. **20 Ekim itibarıyla gizli değişken sayısı 0.**

## Hemen sıradaki iş: TestFlight

1. **Kullanıcı** App Store Connect'te bir API anahtarı oluşturur. Adımlar `docs/testflight_kurulum.md`'de:
   - Users and Access → Integrations → App Store Connect API → Team Keys → "+";
   - erişim **Admin**: bulut imza sertifikası için gerekli; App Manager "No profiles" hatası verir;
   - Generate, sonra Download.
2. **Kullanıcı** depo kökünde şunu çalıştırır ve Issuer ID sorulunca yapıştırır:
   ```
   powershell -ExecutionPolicy Bypass -File tools\testflight_anahtar_ekle.ps1
   ```
   Betik, İndirilenler'deki en yeni `AuthKey_*.p8` dosyasını alır.
   - Orada Temmuz 2026 tarihli eski bir anahtar dosyası da var, başka ekipten olabilir.
   - Yeni anahtar indirildiyse betik onu seçer.
3. Kontrol: `gh api repos/yusuf68435/lockglow/actions/secrets -q .total_count` sonucu 3 olmalı. Sonra:
   ```
   gh workflow run testflight.yml -R yusuf68435/lockglow --ref main
   ```
   Günlükleri izle. Hata olursa `docs/testflight_kurulum.md` → sorun giderme.
4. Yükleme App Store Connect'te göründükten sonra, **kullanıcıdan açık izin alıp** bir dahili test grubu oluştur ve onu ekle. Kullanıcı iPhone'a TestFlight uygulamasını kurar ve daveti kabul eder.
5. Telefondaki ilk deneme: `ios/README.md` → kontrol listesi (süreklilik, widget düğmeleri, hatırlatma saati, ses). Gelen geri bildirimle düzelt.

## Çalışma kuralları (önemli)

- **Kimlik bilgileri:**
  - Claude parola, API anahtarı ya da token girmez veya oluşturmaz.
  - `.p8` dosyasının içeriğini okumaz.
  - Apple hesabına giriş yapmaz.
  - Bunları kullanıcı yapar. Anahtar yalnızca kullanıcının çalıştırdığı betikle GitHub'a gider.
- **Apple hesabında değişiklik ve form gönderme:** Her seferinde açık izin al. Önceki izinler yalnızca App Group, iki App ID ve uygulama kaydı içindi.
- **Kişisel bilgiler:** Apple sayfalarında görünen telefon ya da adres bilgilerini hiçbir yere yazma. Kullanıcının e-postasını dış servislere gönderme.
- **Git:**
  - Bu özel depoya push için onay var. Commit mesajları Türkçe.
  - Ana çalışma klasörü bazen başka bir oturumun dalında olabilir: `pipeline/critic-quiz-backtranslation`. O dalda içerik hattı istem kuralları var: eleştirmen rubriği, tek doğru cevap kuralı. Henüz main'e birleşmedi; birleştirmeden önce kullanıcıya sor.
  - `main` üzerinde çalışırken o dala dokunma; geçici bir worktree kullan:
    ```
    git worktree add --detach <geçici-klasör> origin/main
    ```
- **GitHub Actions kotası:**
  - Özel depoda macOS dakikaları **10 kat** sayılıyor. Ekim'de ~91 macOS dakikası, yani ≈910/2000 kullanıldı (tahmin).
  - `build.yml`'nin macOS işi yalnızca elle çalışır.
  - Push'tan önce `ios/Tools/linux_check.sh` (bedava) çalıştır.
  - Değişiklikleri biriktir; `screenshots.yml`'yi tur başına bir kez çalıştır (~12 dk).
  - TestFlight için mutlaka kota bırak (~10 dk/çalıştırma).
- **Marka:** Tanıtım sayfasını (`marketing/landing/`) TÜRKPATENT araması ve marka vekili görüşünden önce yayımlama.
- **Windows:**
  - Python'u `-X utf8` ile çalıştır.
  - Dosya yazarken `newline="\n"` kullan; depo LF ister (`.gitattributes`).
  - PowerShell 5.1 tırnaklı commit mesajlarını bozuyor; mesajı bir dosyaya yazıp `git commit -F` kullan.

## Açık işler (öncelik sırasıyla)

1. **TestFlight** (yukarıda; kullanıcının adımını bekliyor).
2. **Telefonda deneme ve düzeltmeler.** Gerçek widget yenilenmesi, bildirim zamanlaması ve ses kalitesi yalnızca cihazda görülür (`ios/README.md` → "Bilinen belirsizlikler").
3. **İçerik:**
   - Her akışın `REVIEW.md` sonunda "anadili Türkçe birinin bakması gerekenler" listesi var. Kullanıcı isterse onunla birlikte geç.
   - Önerilen eklemeler: `smell` için ikinci anlam ("It smells good"); yeni akışlar (ör. B1 iş, seyahat, sağlık kalıpları). Önce `docs/icerik_uretimi/README.md`'yi oku.
   - Her derlemede `--content-version`'ı artır.
4. **Uygulama:** FSRS (v1.2), "zor/kolay" cevapları, widget'tan çıkmadan ses.
5. **Yayın işleri (kullanıcı):**
   - TÜRKPATENT "Lockglow" araması (sınıf 9, 41, 42);
   - lockglow.com/.app alan adları;
   - marka vekili;
   - SMMM;
   - `docs/legal/` taslaklarının avukat kontrolü.

## Önemli dosyalar

| Dosya | Ne |
|---|---|
| `README.md` | Genel durum ve klasör haritası |
| `ios/README.md` | iOS mimarisi, kurulum, kontrol listesi, bilinen belirsizlikler |
| `docs/testflight_kurulum.md` | TestFlight anahtar adımları ve sorun giderme |
| `tools/testflight_anahtar_ekle.ps1` | Anahtarı GitHub'a ekleyen betik (kullanıcı çalıştırır) |
| `docs/icerik_uretimi/` | Kart yazma, denetim ve çeldirici kuralları ile araçlar |
| `content/drafts/README.md` | Taslak setin geçmişi |
| `content-pipeline/README.md` | Doğrulama, derleme ("Kişisel derleme") |
| `.github/workflows/` | `build.yml`, `screenshots.yml`, `testflight.yml` |

## Yeni Claude oturumuna ilk mesaj (kopyala-yapıştır)

> Lockglow projesine devam ediyoruz. Depo bu klasörde ve github.com/yusuf68435/lockglow'da. Önce `git pull` yap. Sonra `DEVIR.md`'yi baştan sona oku ve oradaki çalışma kurallarına uy. Alt ajanlar Sonnet olsun, sen koordine et. Bana sade Türkçeyle yaz. İlk iş: TestFlight anahtarının GitHub'a eklenip eklenmediğini kontrol et. Eklenmediyse bana adım adım yardım et.
