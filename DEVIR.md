# Devir notu: Lockglow (2026-10-22)

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
  - App Store Connect'te başka bir ekip daha görünüyor. **Yalnızca Yusuf Uyar ekibini seç.**
- **Hukuki durum:** Şirketi yok. Mağazaya çıkarken şahıs/GVK 20/B yolu SMMM ile konuşulacak.
- **Anthropic API anahtarı yok.** Kartlar oturum içi ajanlarla yazılıyor (`docs/icerik_uretimi/`).

## Proje

Lockglow, kilit ekranında ve ana ekranda İngilizce kelime gösteren, Türkçe açıklamalı bir iPhone uygulaması. "Widget Vocabulary: Learn Words" uygulamasının incelemesinden doğdu (`Widget_Vocabulary_Analiz_ve_Plan.md`, `raporlar/`).

- **Depo:** `github.com/yusufuyar68/lockglow`, **herkese açık** (2026-10-22: Actions dakikaları bitince kullanıcı açık depoyu seçti; öncesinde gizli bilgi taraması yapıldı). Depoya parola, anahtar, kişisel bilgi ya da Apple/üçüncü taraf kimliği yazma. 2026-10-20'de eski `yusuf68435/lockglow` deposundan taşındı (eski adres git'te `eski` adıyla duruyor). `gh` CLI bu bilgisayarda `yusufuyar68` olarak oturum açmış.
- **iOS:** `ios/`.
  - XcodeGen projesi (`project.yml`).
  - SwiftUI uygulama ve WidgetKit widget'ları.
  - `Packages/VocabKit` modülleri: CoreModels, TextFold, SharedState, Scheduler, ContentStore (GRDB), Learning.
  - Tanımlayıcılar: bundle `com.yusufuyar.vocabwidget` ve `.widgets`; App Group `group.com.yusufuyar.vocabwidget`; URL şeması `vocabwidget://`.
- **İçerik hattı:** `content-pipeline/` (Python `vocabpipe`): şema, doğrulayıcı, derleyici.
- **Kartlar:** `content/drafts/kisisel_v1/s0_ornek … s19`, toplam 1.203 taslak kart.
  - Uygulamaya derlenmiş hâli: `ios/App/Resources/content.sqlite` (`2026.10.22-kisisel-9`, şema 2: `card_l1.gloss_short`, `card_confusable`) ve `ios/Widgets/Resources/seed_words.json`.
  - Kart numaraları `content-pipeline/data/id_registry.json` içinde kalıcı. Uygulamadaki ilerleme bunlara bağlı, **elle düzenleme**.

## Durum

- **Uygulama:** CI'da Xcode 26.3 ile derleniyor (Intel macOS makinesi, aşağıya bak).
  - Sekmeler:
    - **Akış:** kelime kartları; "Söyle" mikrofon düğmesi (cihaz içi telaffuz alıştırması)
    - **Tekrar:** yeni kelimeler 5'li "Tanış + Hatırla" turlarında (karışan eşler aynı tura girmez); zamanı gelen kelime kutu 1–3'te 4 şıklı boşluk doldurma (doğruda Zordu/Kolaydı), kutu 4–5'te Bulamadım/Buldum; yanlış cevap 2 basamak indirir; "Biliyorum" 3 gün sonra bir kez sınanır. "Kitaplığın" bağlantısı sakin ilerleme ekranını açar.
    - **Sözlük:** Türkçe harf katlamalı arama, son aramalar, konuya göre göz at, süzgeç (Henüz bilmediklerim / Öğreniyorum / Bildiklerim)
    - **Ayarlar:** widget sıklığı (30–240 dk), günlük hedef (seviyeden: A1–A2 5, B1 10), konular, günlük hatırlatma (kelime öğreten metin, görmezden gelinince geri çekilir), **kendi kelimeni ekle**, bildiğim kelimeler, widget sağlığı (yerel ölçüm ve Söyle tanılaması)
  - **Açılış akışı:** ilk açılışta seviye, konu, widget kurma rehberi, ilk kelime (mevcut kullanıcıya gösterilmez).
  - Widget'lar: küçük, orta, kilit ekranı. "Sonraki", "Biliyorum" ve **hoparlör** (AudioPlaybackIntent, uygulama açılmadan okur).
  - İlerleme dosyasının günlük yedeği alınıyor; gizlilik manifestinde UserDefaults (CA92.1) ve FileTimestamp (C617.1).
- **İçerik:** 1.158 kart (`2026.10.22-kisisel-8`): s1–s9 + s10 iş, s11 seyahat, s12 sağlık, s13 sosyal hayat, s14 ev, s15 alışveriş ve para, s16 zaman, hava ve doğa, s17 teknoloji, s18 eğitim. 103 kartta widget için kısa anlam, 332 karışan çift kaydı, 9 kişisel konu kartı (`sensitivity` 1: uygulamada görünür, widget'ta ve bildirimde görünmez).
- **Testler:** her push'ta Linux Swift işi (`build.yml` → `swift-linux`; ~370 test; `linux_check.sh` Docker'da, AppModel de sahte modüllerle derlenir) ve Python testleri + `--strict` doğrulama. macOS işi elle: ~395 paket testi + uygulama/widget derlemesi.
- **Apple:** App Group (`group.com.yusufuyar.vocabwidget`) iki App ID'ye **atandı** (2026-10-20, Developer portalı). App Store Connect API anahtarı (Admin, adı `lockglow-ci`) GitHub gizli değişkenlerinde.
- **TestFlight:** çalışıyor. Build 18, 22, 23, 26 yüklendi; 22 Ekim akşamı **build 27** (`main` 2af9c39: bütün is3 işleri, kendi kelime, ilerleme ekranı, 1.158 kart) **build 28** (`main` 3f48c18: 10 is4 oturumunun hepsi, 1.203 kart), **build 29** (1026122: widget ve ekran görüntüsü düzeltmeleri) ve **build 30** (`main` d12f08b: kilit ekranı büyük yazı uzlaştırması). Build 29'da yükleme bir kez geçici "No Accounts with App Store Connect Access" hatası verdi; `gh run rerun <id> --failed` ile geçti. İmza her çalıştırmada geçici sertifika + profillerle (`docs/testflight_kurulum.md` → 2b).

## Hemen sıradaki iş

1. **is4 oturumları (22 Ekim akşamı açıldı, 10 tane; hepsi `entegrasyon-4` üzerinden `main`'e birleşti ve kapatıldı, build 28–30). Yarım kalan: is4-widget ve is4-ekran'ın son ekran görüntüsü incelemesi (notlarında "kalan iş"; küçük/orta widget için büyük yazı yedeği kararı).** tekrar ekranı, akış+sözlük, ayarlar+açılış, Söyle, widget, gece teması (C seçeneği), öğrenme motoru (kesin cevap zamanı, tazeleme 30→60→120, FSRS gölge), sağlamlık (zamanlayıcı/TextFold), ekran görüntüleri+UI testleri, içerik s19. Her biri `origin/entegrasyon-3`'ten kendi `is4-*` dalında çalışır ve dosya sahipliği ayrıdır. Bitenleri yeni bir entegrasyon dalında (`entegrasyon-4`, `main`'den) birleştir, macOS CI yeşilse `main`'e ileri sar. Devir notları: `side-session-notes\…\is4-*.md`.
2. **Dahili test grubu hazır** ("Ben", bütün derlemeler): `gh workflow run testflight_group.yml`. Yeni build: `gh workflow run testflight.yml -R yusufuyar68/lockglow --ref main -f runner=macos-15-intel`.
3. Kullanıcı iPhone'da TestFlight'tan dener; ilk deneme `ios/README.md` → kontrol listesi. Gelen geri bildirimle düzelt.
4. `ios/README.md` dondurulmuş durumda: oturumların notlarındaki öneri metinlerini (is3-*.md, is4-*.md) koordinatör toplu işler.

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
  - `pipeline/critic-quiz-backtranslation` (eleştirmen rubriği, tek doğru cevap kuralı) 2026-10-21'de main'e birleşti.
  - Paralel oturumlar ana klasörde dal değiştirmez; kendi worktree'lerinde çalışır (`git worktree add -b <dal> <yol> origin/main`). Dallarını koordinatör oturum kontrol edip main'e birleştirir (kullanıcı izni 2026-10-21).
  - `main`'e yalnız ileri sarma ile birleştir: `git checkout main && git merge --ff-only <entegrasyon-dalı> && git push origin main` (refspec'le doğrudan push otomatik denetimde engelleniyor).
- **GitHub Actions kotası:**
  - Depo 22 Ekim'den beri açık: standart makinelerde dakikalar ücretsiz. Yine de makine sırası sınırlı (aynı anda birkaç macOS işi).
  - `build.yml`'nin macOS işi yalnızca elle çalışır; Linux Swift testleri her push'ta.
  - `build.yml`'de `concurrency: cancel-in-progress` var: aynı dala push, o dalda koşan elle başlatılmış macOS işini **iptal eder**. macOS işini başlattıktan sonra bitene kadar o dala push etme.
  - **arm64 macOS kuyruğu** 20–21 Ekim'de saatlerce iş almadı ("not acquired by Runner"). Bütün iş akışlarında `-f runner=macos-15-intel` seçeneği var; Intel makine hemen başlıyor.
  - Değişiklikleri biriktir; `screenshots.yml`'yi tur başına bir kez çalıştır (~12 dk).
  - TestFlight için mutlaka kota bırak (~10 dk/çalıştırma).
- **Marka:** Tanıtım sayfasını (`marketing/landing/`) TÜRKPATENT araması ve marka vekili görüşünden önce yayımlama.
- **Windows:**
  - Python'u `-X utf8` ile çalıştır.
  - Dosya yazarken `newline="\n"` kullan; depo LF ister (`.gitattributes`).
  - PowerShell 5.1 tırnaklı commit mesajlarını bozuyor; mesajı bir dosyaya yazıp `git commit -F` kullan.

## Açık işler (öncelik sırasıyla)

1. **Telefonda ilk deneme** (TestFlight hazır; kullanıcı daveti kabul edecek).
2. **Telefonda deneme ve düzeltmeler.** Gerçek widget yenilenmesi, bildirim zamanlaması ve ses kalitesi yalnızca cihazda görülür (`ios/README.md` → "Bilinen belirsizlikler").
3. **İçerik:**
   - Her akışın `REVIEW.md` sonunda "anadili Türkçe birinin bakması gerekenler" listesi var. Kullanıcı isterse onunla birlikte geç.
   - s10–s13 eklendi (2026-10-21). Yeni akış eklerken önce `docs/icerik_uretimi/README.md`'yi oku.
   - Her derlemede `--content-version`'ı artır.
4. **Uygulama:** FSRS'e geçiş (`docs/ozellik_planlari/fsrs.md`; motor `Learning/FSRS.swift` hazır, bağlı değil); `docs/ozellik_planlari/` içindeki kalan öneriler (Denetim Merkezi/StandBy, iCloud yedeği). Yapılanlar: Tanış+Hatırla, Biliyorum kontrolü, kendi kelime, ilerleme ekranı, sözlük geliştirmesi, öğreten bildirimler, yerel ölçüm, kontrast/gece teması (ekranların çoğu cihazda henüz görülmedi).
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
