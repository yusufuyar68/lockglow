# TestFlight ile telefona kurulum (Mac gerekmez)

GitHub'daki `testflight` iş akışı uygulamayı Mac sunucusunda imzalar ve App Store Connect'e yükler. Sen telefonundaki **TestFlight** uygulamasından kurarsın. Her build 90 gün geçerlidir; yeni sürümü yine aynı yoldan alırsın.

Senin yapman gerekenler (yaklaşık 10 dakika, bir kez): **1–3**. Claude gerisini yapar ama anahtarı ve şifreleri **giremez**, onları sen girersin.

## 1. App Store Connect API anahtarı oluştur

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Users and Access** (Kullanıcılar ve Erişim) → üstte **Integrations** sekmesi → **App Store Connect API** → **Team Keys**.
2. İlk kez giriyorsan **Request Access** çıkabilir: tıkla, şartları kabul et (hesap sahibi sensin).
3. **+** (Generate API Key): ad `GitHub Lockglow`, erişim **Admin** → **Generate**. (Admin gerekir: imza sertifikasını Apple'ın bulutunda otomatik oluşturabilmek için.)
4. Listede anahtarın satırından **Download** ile `AuthKey_XXXXXXXXXX.p8` dosyasını indir. **Yalnızca bir kez indirilebilir**; güvenli bir yerde sakla, kimseyle paylaşma.
5. Sayfada iki değeri not et: **Issuer ID** (listenin üstünde, uzun bir kimlik) ve anahtarın **Key ID**'si (10 karakter).

## 2. Anahtarı GitHub'a gizli değişken olarak ekle

İki yoldan biri:

**Terminalden** (indirdiğin klasörde; her komut değeri senden ister, yapıştırıp Enter'a bas):

```bash
gh secret set ASC_KEY_ID -R yusufuyar68/lockglow
```
```bash
gh secret set ASC_ISSUER_ID -R yusufuyar68/lockglow
```
```bash
gh secret set ASC_KEY_P8 -R yusufuyar68/lockglow < AuthKey_XXXXXXXXXX.p8
```

**ya da tarayıcıdan:** github.com/yusufuyar68/lockglow → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**. Adlar: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` (sonuncusuna `.p8` dosyasını bir metin düzenleyicide açıp **tüm içeriğini** yapıştır).

Gizli değişkenler GitHub'da şifreli tutulur; iş akışı anahtarı yalnızca derleme sırasında kullanır ve sonunda siler.

## 2b. Dağıtım sertifikasını GitHub'a ekle (2026-10-20'den beri gerekli)

Xcode'un API anahtarıyla otomatik imzası App Groups'u okuyamıyor (`/xcbuild/v1/appGroups` → 401), bu yüzden iş akışı elle imzalar. Bunun için bir iOS dağıtım sertifikası (`.p12`) gerekir. Hesapta Apple'ın sınırı olan 3 dağıtım sertifikası zaten var (Expo'nun oluşturdukları); yenisini açmak yerine Expo'dakini kullanıyoruz:

1. Bir Expo projesinde (bu bilgisayarda: `Desktop\sürpriz claude\surprise-planner`) `npx eas-cli credentials -p ios` → **production** → **credentials.json: Upload/Download credentials…** → **Download credentials from EAS to credentials.json**.
2. Lockglow klasöründe: `powershell -ExecutionPolicy Bypass -File tools\dagitim_sertifikasi_ekle.ps1` → `DIST_P12_BASE64` ve `DIST_P12_PASSWORD` eklenir.
3. Expo klasöründeki `credentials.json` ve `credentials\` klasörünü sil ya da güvenli bir yere taşı.

İş akışı App Store profillerini (`IOS_APP_STORE`, iki bundle id) API ile kendisi bulur ya da oluşturur (`ios/Tools/asc_profiles.py`).

## 3. App Store Connect'te uygulama kaydı aç

Önce Claude iş akışını bir kez çalıştırır: bu ilk çalıştırma bundle id'yi (`com.yusufuyar.vocabwidget`) Apple'a kaydeder. Kayıt yoksa yükleme adımı hata verir, bu beklenen bir durumdur. Sonra:

App Store Connect → **Apps** (Uygulamalar) → **+** → **New App**:
- Platform: **iOS**
- Ad: **Lockglow** (App Store'da benzersiz olmalı; yayından önce değiştirilebilir)
- Ana dil: **Türkçe**
- Bundle ID: listeden **com.yusufuyar.vocabwidget**
- SKU: `lockglow-ios`
- Kullanıcı erişimi: Tam erişim

Uygulama yayınlanmaz; yalnızca TestFlight için kayıt açılır.

## 4. Yükleme ve kurulum

1. Claude `testflight` iş akışını yeniden çalıştırır. Yükleme bitince App Store Connect build'i 5–30 dakika işler.
2. App Store Connect → uygulama → **TestFlight** → **Internal Testing** (Dahili Test) → **+** ile bir grup oluştur ve kendini ekle.
3. iPhone'a App Store'dan **TestFlight** uygulamasını kur, aynı Apple ID ile aç: Lockglow listede görünür → **Install**.
4. Kilit ekranına widget ekle: kilit ekranına basılı tut → **Özelleştir** → kilit ekranı → widget alanı → **Lockglow**. Ana ekrana: boş yere basılı tut → **+** → **Lockglow**.

## Sorun çıkarsa

İş akışının günlükleri `testflight-logs` adıyla saklanır; Claude bunları okuyup düzeltebilir. Sık görülenler:
- `No profiles for 'com.yusufuyar.vocabwidget'` + `Authentication failed` → otomatik imza App Groups'u okuyamıyor; adım 2b (elle imza) gerekir.
- `Bu .p12 sertifikası App Store Connect'te yok` → Expo'daki sertifika iptal edilmiş; başka bir projeden indir.
- `Cannot determine the Apple ID from Bundle ID` / uygulama bulunamadı → adım 3 henüz yapılmadı.
- `The bundle version must be higher` → iş akışını yeniden çalıştır (build numarası her çalıştırmada artar).
