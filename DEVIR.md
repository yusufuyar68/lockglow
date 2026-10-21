# Devir notu: Lockglow (2026-10-21)

Bu projeye başka bir Claude hesabı ya da oturumu devam edecekse **önce bu dosyayı baştan sona oku.** Ekran görüntülü durum özeti: [`docs/lockglow_ilerleme.html`](docs/lockglow_ilerleme.html). Tarayıcıda açılır.

## Kullanıcı (proje sahibi)

- **İletişim tarzı:**
  - Türkçe yazar; cevapları sade Türkçeyle ver.
  - İngilizcesi **A2 ve altı**. Hedefi günlük İngilizce.
  - Uygulamayı **önce kendisi için** yapıyor; mağaza sonra.
  - İşi çoğunlukla Claude'a bırakır ("devam", "sen hallet her şeyi"). Kısa ilerleme mesajları ve net sonraki adım bekler.
- **Ajan kullanımı:** 2026-10-21'den beri kullanıcı oturumların ve alt ajanların **Opus 5.5** ile, çok ajanlı denetim/doğrulamayla (ultracode) çalışmasını istiyor. Koordinasyon ve son kontrol ana oturumda.
- **Donanım:** Windows PC'de çalışıyor; Mac var ama kullanılmıyor, bütün iOS derlemeleri GitHub Actions'ta. iPhone'u iOS 26+.
- **Apple hesabı:** Ücretli Apple Developer hesabı var.
  - Ekip **Yusuf Uyar**, Team ID `3B57WU65P8`.
  - App Store Connect'te bir de "Ali Celebi" ekibi görünüyor. **Onu seçme.**
- **Hukuki durum:** Şirketi yok. Mağazaya çıkarken şahıs/GVK 20/B yolu SMMM ile konuşulacak.
- **Anthropic API anahtarı yok.** Kartlar oturum içi ajanlarla yazılıyor (`docs/icerik_uretimi/`).

## Proje

Lockglow, kilit ekranında ve ana ekranda İngilizce kelime gösteren, Türkçe açıklamalı bir iPhone uygulaması. "Widget Vocabulary: Learn Words" uygulamasının incelemesinden doğdu (`Widget_Vocabulary_Analiz_ve_Plan.md`, `raporlar/`).

- **Depo:** `github.com/yusufuyar68/lockglow` (özel). 2026-10-20'de eski `yusuf68435/lockglow` deposundan taşındı (eski adres git'te `eski` adıyla duruyor). `gh` CLI bu bilgisayarda `yusufuyar68` olarak oturum açmış.
- **iOS:** `ios/`.
  - XcodeGen projesi (`project.yml`).
  - SwiftUI uygulama ve WidgetKit widget'ları.
  - `Packages/VocabKit` modülleri: CoreModels, TextFold, SharedState, Scheduler, ContentStore (GRDB), Learning.
  - Tanımlayıcılar: bundle `com.yusufuyar.vocabwidget` ve `.widgets`; App Group `group.com.yusufuyar.vocabwidget`; URL şeması `vocabwidget://`.
- **İçerik hattı:** `content-pipeline/` (Python `vocabpipe`): şema, doğrulayıcı, derleyici.
- **Kartlar:** `content/drafts/kisisel_v1/s0_ornek … s13`, toplam 933 taslak kart.
  - Uygulamaya derlenmiş hâli: `ios/App/Resources/content.sqlite` (`2026.10.21-kisisel-5`) ve `ios/Widgets/Resources/seed_words.json`.
  - Kart numaraları `content-pipeline/data/id_registry.json` içinde kalıcı. Uygulamadaki ilerleme bunlara bağlı, **elle düzenleme**.

## Durum

- **Uygulama:** CI'da Xcode 26.3 ile derleniyor (Intel macOS makinesi, aşağıya bak).
  - Sekmeler:
    - **Akış:** kelime kartları; "Söyle" mikrofon düğmesi (cihaz içi telaffuz alıştırması)
    - **Tekrar:** Leitner; yeni kartta Bilemedim / Zor / Bildim / Kolay; zamanı gelen kelimede 4 şıklı boşluk doldurma
    - **Sözlük:** Türkçe harf katlamalı arama
    - **Ayarlar:** widget sıklığı, günlük hedef, konular (deste seçimi), günlük hatırlatma, bildiğim kelimeler, widget sağlığı
  - **Açılış akışı:** ilk açılışta seviye, konu, widget kurma rehberi, ilk kelime (mevcut kullanıcıya gösterilmez).
  - Widget'lar: küçük, orta, kilit ekranı. "Sonraki", "Biliyorum" ve **hoparlör** (AudioPlaybackIntent, uygulama açılmadan okur).
  - İlerleme dosyasının günlük yedeği alınıyor; gizlilik manifestinde UserDefaults (CA92.1) ve FileTimestamp (C617.1).
- **İçerik:** 933 kart (`2026.10.21-kisisel-5`): s1–s9 + s10 iş, s11 seyahat, s12 sağlık, s13 sosyal hayat.
- **Testler:** her push'ta ücretsiz Linux Swift işi (`build.yml` → `swift-linux`, `linux_check.sh` Docker'da) ve 72 Python testi + `--strict` doğrulama. macOS işi elle: ~170 paket testi + uygulama/widget derlemesi.
- **Apple:** App Group (`group.com.yusufuyar.vocabwidget`) iki App ID'ye **atandı** (2026-10-20, Developer portalı). App Store Connect API anahtarı (`ZLU4D5GWLX`, Admin) GitHub'da.
- **TestFlight:** çalışıyor. Build 18 (20 Ekim) ve **build 22** (21 Ekim: 933 kart, Zor/Kolay, widget sesi) yüklendi. İmza her çalıştırmada geçici sertifika + profillerle (`docs/testflight_kurulum.md` → 2b).

## Hemen sıradaki iş

1. **Dahili test grubu:** App Store Connect → Lockglow → TestFlight → Internal Testing'de grup açıp kullanıcıyı (hesap sahibi) ekle, en yeni build'i ver. Kullanıcı izin verdi (2026-10-21); **App Store Connect girişini kullanıcı yapar** (tarayıcı paneli).
2. Söyle + açılış akışını içeren yeni build: `gh workflow run testflight.yml -R yusufuyar68/lockglow --ref main -f runner=macos-15-intel`.
3. Kullanıcı iPhone'a TestFlight'ı kurar; ilk deneme `ios/README.md` → kontrol listesi. Gelen geri bildirimle düzelt.
4. Arayüz tasarımı (`tasarim/arayuz-mockup` dalı, `docs/tasarim/`) bitince main'e birleştir ve uygulamaya renk/tipografi olarak taşı.

## Çalışma kuralları (önemli)

- **Kimlik bilgileri:**
  - Claude parola, API anahtarı ya da token girmez veya oluşturmaz.
  - `.p8` dosyasının içeriğini okumaz.
  - Apple hesabına giriş yapmaz.
  - Bunları kullanıcı yapar. Anahtar yalnızca kullanıcının çalıştırdığı betikle GitHub'a gider.
- **Apple hesabında değişiklik ve form gönderme:** Her seferinde açık izin al. Verilmiş izinler: App Group, iki App ID, uygulama kaydı (eski); TestFlight iş akışının geçici dağıtım sertifikası ve profilleri oluşturup emekliye ayırması (2026-10-20); App Group'un iki App ID'ye atanması (yapıldı); dahili test grubu (2026-10-21).
- **Sertifikalar:** Ekipte aynı anda yalnızca bir Apple Distribution sertifikası olabiliyor; iOS Distribution'ın 3 yeri Expo'da. Expo sertifikalarına ve 'Created via API' adlı iki eski geliştirme sertifikasına dokunma.
- **Kişisel bilgiler:** Apple sayfalarında görünen telefon ya da adres bilgilerini hiçbir yere yazma. Kullanıcının e-postasını dış servislere gönderme.
- **Git:**
  - Bu özel depoya push için onay var. Commit mesajları Türkçe.
  - Ana çalışma klasörü bazen başka bir oturumun dalında olabilir: `pipeline/critic-quiz-backtranslation`. O dalda içerik hattı istem kuralları var: eleştirmen rubriği, tek doğru cevap kuralı. Henüz main'e birleşmedi; birleştirmeden önce kullanıcıya sor.
  - `main` üzerinde çalışırken o dala dokunma; geçici bir worktree kullan:
    ```
    git worktree add --detach <geçici-klasör> origin/main
    ```
- **GitHub Actions kotası:**
  - Özel depoda macOS dakikaları **10 kat** sayılıyor. Depo 20 Ekim'de `yusufuyar68` hesabına taşındı; kota bu hesabın kotası (ücretsiz planda ayda 2000 dakika).
  - `build.yml`'nin macOS işi yalnızca elle çalışır; Linux Swift testleri her push'ta bedava.
  - **arm64 macOS kuyruğu** 20–21 Ekim'de saatlerce iş almadı ("not acquired by Runner"). Bütün iş akışlarında `-f runner=macos-15-intel` seçeneği var; Intel makine hemen başlıyor.
  - Değişiklikleri biriktir; `screenshots.yml`'yi tur başına bir kez çalıştır (~12 dk).
  - TestFlight için mutlaka kota bırak (~10 dk/çalıştırma).
- **Marka:** Tanıtım sayfasını (`marketing/landing/`) TÜRKPATENT araması ve marka vekili görüşünden önce yayımlama.
- **Windows:**
  - Python'u `-X utf8` ile çalıştır.
  - Dosya yazarken `newline="\n"` kullan; depo LF ister (`.gitattributes`).
  - PowerShell 5.1 tırnaklı commit mesajlarını bozuyor; mesajı bir dosyaya yazıp `git commit -F` kullan.

## Açık işler (öncelik sırasıyla)

1. **TestFlight test grubu** (yukarıda; kullanıcının App Store Connect girişini bekliyor).
2. **Telefonda deneme ve düzeltmeler.** Gerçek widget yenilenmesi, bildirim zamanlaması ve ses kalitesi yalnızca cihazda görülür (`ios/README.md` → "Bilinen belirsizlikler").
3. **İçerik:**
   - Her akışın `REVIEW.md` sonunda "anadili Türkçe birinin bakması gerekenler" listesi var. Kullanıcı isterse onunla birlikte geç.
   - s10–s13 eklendi (2026-10-21). Yeni akış eklerken önce `docs/icerik_uretimi/README.md`'yi oku.
   - Her derlemede `--content-version`'ı artır.
4. **Uygulama:** FSRS (v1.2); `raporlar/14_guncel_fark_raporu.md` ve `docs/ozellik_planlari/` içindeki kalan öneriler (kendi kelimeni ekleme, Denetim Merkezi/StandBy, iCloud yedeği). Yapılanlar: Zor/Kolay, widget sesi, Söyle, açılış + deste (ekranları cihazda henüz görülmedi).
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

## Yeni Claude oturumuna ilk mesaj

- Kökteki [`CLAUDE.md`](CLAUDE.md) her oturumda kendiliğinden okunur ve buraya yönlendirir. Kullanıcının yalnızca "klasörü detaylıca incele" yazması yeter.
- Daha ayrıntılı ilk mesaj [`YENI_OTURUM_MESAJI.md`](YENI_OTURUM_MESAJI.md) dosyasında.
