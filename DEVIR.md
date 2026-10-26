# Devir notu: Lockglow (2026-10-23)

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
- **Kartlar:** `content/drafts/kisisel_v1/s0_ornek … s32`, toplam 1.983 taslak kart (A1 192, A2 580, B1 719, B2 492; s23–s32'deki 108 kart 2026-10-26 seviye kararıyla B1'e indi).
  - Uygulamaya derlenmiş hâli: `ios/App/Resources/content.sqlite` (`2026.10.26-kisisel-18`, şema 2: `card_l1.gloss_short`, `card_confusable`, `card.symbol` kelime görselleri: `docs/ozellik_planlari/kelime_gorselleri.md`) ve `ios/Widgets/Resources/seed_words.json`.
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
- **İçerik:** 1.983 kart (`2026.10.26-kisisel-18`; 72 kartta SF Symbol görseli): s1–s9 + s10 iş, s11 seyahat, s12 sağlık, s13 sosyal hayat, s14 ev, s15 alışveriş ve para, s16 zaman, hava ve doğa, s17 teknoloji, s18 eğitim, s19 boş zaman, s20 günlük konuşma kalıpları, s21 duygular ve kişilik, s22 deyimler ve phrasal verb'ler; B2 (60'ar kart): s23 iş ve kariyer, s24 siyaset ve toplum, s25 çevre ve bilim, s26 sağlık ve spor, s27 teknoloji ve medya, s28 ilişkiler ve iletişim, s29 seyahat ve kültür, s30 görüş, okul ve zihin, s31 para ve ekonomi, s32 phrasal verb'ler ve deyimler. 193 kartta widget için kısa anlam (ana anlamın kısaltması), 918 karışan çift kaydı, 9 kişisel konu kartı (`sensitivity` 1: uygulamada görünür, widget'ta ve bildirimde görünmez).
- **Testler:** her push'ta Linux Swift işi (`build.yml` → `swift-linux`; ~370 test; `linux_check.sh` Docker'da, AppModel de sahte modüllerle derlenir) ve Python testleri + `--strict` doğrulama. macOS işi elle: ~395 paket testi + uygulama/widget derlemesi.
- **Apple:** App Group (`group.com.yusufuyar.vocabwidget`) iki App ID'ye **atandı** (2026-10-20, Developer portalı). App Store Connect API anahtarı (Admin, adı `lockglow-ci`) GitHub gizli değişkenlerinde.
- **TestFlight:** çalışıyor. Build 18, 22, 23, 26 yüklendi; 22 Ekim akşamı **build 27** (`main` 2af9c39: bütün is3 işleri, kendi kelime, ilerleme ekranı, 1.158 kart) **build 28** (`main` 3f48c18: 10 is4 oturumunun hepsi, 1.203 kart), **build 29** (1026122: widget ve ekran görüntüsü düzeltmeleri) **build 30** (`main` d12f08b), **build 31** (aa7ef5d: ekran görüntüsü incelemesinin düzeltmeleri), **build 32** (b9005c8: büyük widget, kilit ekranı ilerleme widget'ı, Denetim Merkezi kontrolleri, Siri/Kısayollar, Canlı Etkinlik, yeni Sözlük, yeni ikon) **build 33** (`main` d02a254, 23 Ekim: 24 is5 oturumunun işi, 1.323 kart, iPad) ve **build 34** (`main` 8ae42a5, 24 Ekim: 30 is5 oturumunun hepsi, 1.383 kart, FSRS, iCloud hazırlığı, Watch kodu, Apple tasarım kuralları CLAUDE.md'de) ve **build 35** (`main` 763de20, 24 Ekim: Apple sistem renkleri ve Dynamic Type boyları, boş açılan "Neden?" sayfası düzeltildi, Kadın/Erkek ses seçimi), **build 36** (`main` 6d5cb40, 24 Ekim: is6-ekran ekran görüntüsü düzeltmeleri, içerik `2026.10.24-kisisel-13`) ve **build 39** (`main` f13b15c, 25 Ekim: is6-hig ile is6-ekran birleşti, gece ana düğmesi dolgulu). Build 37 iptal edilen bir denemede harcandı; **build 38** (`main` 2f4b893) kullanıcı istemeden yüklendi, build 39 da sormadan yüklendi: kural, TestFlight'tan önce kullanıcıya sormak (bellek: build-sormadan-alma). Build 29'da yükleme bir kez geçici "No Accounts with App Store Connect Access" hatası verdi; `gh run rerun <id> --failed` ile geçti. İmza her çalıştırmada geçici sertifika + profillerle (`docs/testflight_kurulum.md` → 2b).

## Hemen sıradaki iş

1. **is6 (24–25 Ekim): Apple tasarım dili ve ekran görüntüsü incelemesi.** Kullanıcı istedi: ekrana sığmayanları tek tek kontrol et, Apple dilinden ayrılma, yazı boylarını ve renkleri Apple'a uydur (kurallar `CLAUDE.md` → "Tasarım kuralları"). Mobil mockup (12 iPhone ekranı, Apple kurallarıyla): https://claude.ai/artifact/KZnFUKmjPWszcPB7qAetKg
   - **is6-hig, ilk kısım (build 35):** tema token'ları Apple'ın sistem renklerine (zemin #F2F2F7, kart beyaz, metin kademeleri), yazılar Dynamic Type ölçeğine (İngilizce kelime 34, örnek cümle Body 17) geçti.
   - **is6-ekran (build 36, `main` 6d5cb40):** 763de20'nin 1.242 görüntüsü yedi ajanla incelendi, bulgular beş ajanla düzeltildi: SE'de açılmayan Söyle sayfası, "Devamı" çakışması, cümle kur sonucunun alt çubuk altında kalması, klavye altında kalan alanlar, gece temasında siyah sayfalar, sönük görünmeyen pasif ana düğme; widget'larda "…" ile kesilen örnek cümleler (artık yalnız bütün cümle; "Ms.", "a.m." cümleyi bölmüyor), büyük yazıda değişen Türkçe anlam, yan cümleden kelime taşıyan hata satırı, kilit ekranı ilerleme satırının kısa biçimleri, Canlı Etkinlik bitince onay işareti; içerik `2026.10.24-kisisel-13` (kısa anlamlar ana anlamın kısaltması). Ekran görüntüsü koşusu 40084142304 (yeşil).
   - **is6-hig, ikinci kısım (`is6-hig` dalı):** aynı görüntüler ayrıca incelendi, düzeltmeler üç tur ekran görüntüsüyle doğrulandı: iOS'un standart bölümlü denetimi, Akış başlığı öteki sekmelerle aynı hizada, tur sayacı tek boyda, Sözlük rozeti ve satır düzeni, kısa sayfalar gece yükseltilmiş zeminde (`Theme.sheetBg`); widget'larda büyük yazı basamakları (sığmazsa birer boy küçülür, daha büyük ayar hiçbir zaman daha az ya da daha küçük göstermez; `ogrenme_ilkeleri.md` güncellendi), orta/büyük widget'ta boşluk yerine "Yeni kelime", quiz'de seçilen satır; SE'de Tekrar başlangıcı, hatırlatma sayfası ve tur özeti ayraçları, Akış gölgesi.
   - **Birleşme ve gece düğmesi (build 39, `main` f13b15c, 25 Ekim):** `is6-hig` ile `main` (is6-ekran) birleşti (8177d66): iki tarafın düzeltmelerinin hepsi kaldı, aynı sorunu iki yoldan çözen yerlerde tek çözüm seçildi (çoğunlukla is6-hig'inki, daha çok doğrulandığı için). Kullanıcının isteğiyle gece ana düğmesi Apple gibi dolgulu (beyaz zemin, siyah yazı; 96835f5); pasif ana düğme gri dolgu ve gri yazı (3,9:1, eskiden 1,7–1,9:1), "eklendi" bildirimi ters renkli değil (f13b15c). Son görsel kontrol: SE, Pro, koyu ve widget görüntüleri iki atayla karşılaştırıldı, gerileme yok. Build 37 iptal edildi, 38 öbür oturumda istenmeden yüklendi.
   - **Kalanlar:**
     - Satır içi kilit ekranı widget'ı uzun ifadelerde (misunderstanding, the day before yesterday) Türkçe anlamı gösteremiyor: ≤12 karakterlik kısa anlam verisi gerekir.
     - Küçük/orta widget'ın büyük yazı yedeği (is4'ten beri açık karar): is6-hig'in basamak kuralı uygulandı; kullanıcı build 37'de AX boylarında görüp onaylasın.
     - Veri ajanının işaretlediği "geç olsun", "uzun zamandır", "nasıldı?" kısa anlamlarına anadili Türkçe biri baksın.
     - Sözlük kelime sayfasında kaydırınca çubukta çıkan başlık geri alındı (e299e3d: sayfa kaymadan da çıkıyordu); doğru ölçümle yeniden yapılmalı.
     - Ekran görüntüsü işi bazen sekme değişiminde dakikalarca "idle" olmuyor ve sorgular zaman aşımına düşüyor. Yoklamanın aldığı yığın dökümünde (koşu 40139292325) uygulamanın bütün iş parçacıkları boştaydı: sorun uygulamada değil, CI simülatöründe XCUITest'in erişilebilirlik bağlantısında. Süre sınırı 200 dk; bir geçiş düşerse yeniden koşmak yetiyor.
     - Küçük kalanlar (son kontrolden): orta widget "under the weather" AX1/AX3'te tanımı atıyor; büyük quiz'de uzun kelime cevaptan sonra biraz küçülüyor; Tekrar tur özetinde ana düğme "Tamam", Cümle kur özetinde "Bir tur daha" (rol tutarsızlığı); bölümlü denetimler sistem boyunda 32 pt.
     - Uygulamanın Dikkat parçası (`CardDetailViews.swift`, `MistakeSnippet`) "Ms.", "a.m." kısaltmalarını widget'taki gibi (`WidgetSentenceEnd`) tanımıyor; küçük bir eşitleme işi.
   - **is5 oturumları (23 Ekim, 30 oturum):** hepsi `entegrasyon-5` üzerinden `main`'e birleşti ve kapatıldı (build 33–34). `is5-performans` dalı bilerek birleştirilmedi: yerine `is5-performans-2` girdi.
   - **Kullanıcı adımları:** iCloud (App ID'de iCloud kutusu, sonra `project.yml`'e entitlement satırı: `is5-icloud.md`), Apple Watch (iki yeni App ID + App Group, sonra saati TestFlight'a gömme: `is5-watch.md`). Gizlilik politikası iCloud açılmadan güncellenmeli. İçerik için 37 soru: `docs/icerik_uretimi/sorular_kullaniciya.md`.
2. **is4 oturumları (22 Ekim akşamı açıldı, 10 tane; hepsi `entegrasyon-4` üzerinden `main`'e birleşti ve kapatıldı, build 28–30). Yarım kalan: is4-widget ve is4-ekran'ın son ekran görüntüsü incelemesi (notlarında "kalan iş"; küçük/orta widget için büyük yazı yedeği kararı).** tekrar ekranı, akış+sözlük, ayarlar+açılış, Söyle, widget, gece teması (C seçeneği), öğrenme motoru (kesin cevap zamanı, tazeleme 30→60→120, FSRS gölge), sağlamlık (zamanlayıcı/TextFold), ekran görüntüleri+UI testleri, içerik s19. Her biri `origin/entegrasyon-3`'ten kendi `is4-*` dalında çalışır ve dosya sahipliği ayrıdır. Bitenleri yeni bir entegrasyon dalında (`entegrasyon-4`, `main`'den) birleştir, macOS CI yeşilse `main`'e ileri sar. Devir notları: `side-session-notes\…\is4-*.md`.
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
