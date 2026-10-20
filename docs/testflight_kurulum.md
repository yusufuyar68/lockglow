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

## 2b. İmza nasıl yapılıyor (kullanıcıdan bir şey gerekmez)

Xcode'un API anahtarıyla otomatik imzası App Groups'u okuyamıyor (`/xcbuild/v1/appGroups` → 401). Hesaptaki 3 dağıtım sertifikası da Expo'ya ait (özel anahtarları burada yok). Bu yüzden her çalıştırmada:

1. `ios/Tools/asc_signing.py setup` bulut makinesinde yeni bir anahtar üretir, API ile **geçici** bir dağıtım sertifikası ve iki `IOS_APP_STORE` profili (`Lockglow CI <run>-<deneme> <bundle id>`) oluşturur. Profiller App Group içermezse iş erkenden durur;
2. arşiv bu profillerle elle imzalanıp yüklenir;
3. `cleanup` işi (Linux) **nöbet değişimi** yapar. Apple, iptal edilen dağıtım sertifikasıyla imzalanmış ve incelemeye gönderilmemiş derlemeleri "Invalid Binary" sayabilir. Bu yüzden:
   - yeni derleme App Store Connect'te işlenince (`VALID`) **yalnızca eski** `Lockglow CI` profilleri silinir ve onların sertifikaları iptal edilir; son derlemeyi imzalayan sertifika korunur (eski TestFlight derlemeleri bu yüzden geçersiz olabilir, önemli olan en yenisi);
   - yükleme hiç denenmediyse o çalıştırmanın sertifikası ve profilleri hemen silinir;
   - yükleme yarım kaldıysa ya da iş iptal edildiyse hiçbir şey silinmez, bir sonraki başarılı çalıştırma toplar;
   - `Lockglow CI` dışındaki bir profilin kullandığı sertifika (Expo, diğer uygulamalar) asla iptal edilmez.

Kullanıcı bu geçici sertifika/profil yöntemine 2026-10-20'de izin verdi. Başka sertifika ve profillere dokunulmaz ('Created via API' adlı iki eski geliştirme sertifikası bilerek bırakıldı).

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
- `No profiles for 'com.yusufuyar.vocabwidget'` + `Authentication failed` → otomatik imza App Groups'u okuyamıyor; iş akışı bu yüzden elle imzalar (adım 2b).
- `Geçici dağıtım sertifikası oluşturulamadı` → Apple'ın sertifika sınırı dolu; önce yer açmak gerekir (kullanıcıya sor).
- `cleanup` işi hata verdiyse: bir sonraki başarılı çalıştırma eski `Lockglow CI` neslini toplar; acelesi yoksa elle bir şey yapma.
- `Cannot determine the Apple ID from Bundle ID` / uygulama bulunamadı → adım 3 henüz yapılmadı.
- `The bundle version must be higher` → iş akışını yeniden çalıştır (build numarası her çalıştırmada artar).
