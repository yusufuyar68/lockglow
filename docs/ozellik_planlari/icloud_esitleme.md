# iCloud ile eşitle (2026-10-23, is5-icloud)

İlerleme ve kendi kelimeler iCloud'a yedeklenir ve aynı Apple hesabındaki cihazlar arasında eşitlenir. **Varsayılan kapalı.** Ayarlar'da "İlerleme" bölümünde "iCloud ile eşitle" satırı ayrı bir ekran açar.

**Durum:** kod hazır, Linux'ta testli. **iCloud yeteneği App ID'de açılmadan çalışmaz:** bu derlemede anahtar kapalı kalır ve "iCloud ile eşitleme bu sürümde henüz hazır değil." yazar. Açmak için aşağıdaki "Apple tarafı" adımları gerekir.

## 1. Seçim: üç yol

| | iCloud Drive belgesi | CloudKit (özel veritabanı) | `NSUbiquitousKeyValueStore` |
|---|---|---|---|
| Apple tarafı | iCloud kapsayıcısı oluştur, App ID'ye ata | iCloud kapsayıcısı + CloudKit şeması; şemayı her değişiklikte "Production"a taşı (TestFlight üretim ortamını kullanır) | Yalnız App ID'de iCloud yeteneği; kapsayıcı yok |
| Kullanıcıda | iCloud Drive açık olmalı | iCloud hesabı | iCloud hesabı; iCloud Drive kapalı olsa da çalışır |
| Kod | Dosya koordinasyonu (`NSFileCoordinator`), indirilmemiş dosya (`.icloud`), çakışan sürümler (`NSFileVersion`), `NSMetadataQuery` | Kayıt türleri, bölge, değişiklik jetonu, `CKSyncEngine`, hesap durumu, sessiz bildirim | Bir anahtar oku/yaz, bir bildirim dinle |
| Boyut | Sınırsız (kullanıcının alanı) | Çok büyük | **Uygulama başına 1 MB** |
| Çakışma | Dosya düzeyinde sürümler; elle çözülür | Kayıt düzeyinde; elle çözülür | Anahtar düzeyinde son yazan kazanır; biz birleştiririz |
| İlk indirme | Elle beklenir | Elle beklenir | iCloud ilk indirmeden önce yazılanı **kendisi atar** ve haber verir: yeni bir cihaz eski kopyanın üstüne yazamaz |

**Seçilen: `NSUbiquitousKeyValueStore`.** En küçük ve en az parçalı yol. Apple tarafında tek adım var, şema ya da kapsayıcı yok. iCloud Drive kapalıyken de çalışır. Birleştirmeyi zaten biz yaptığımız için anahtar düzeyindeki "son yazan kazanır" sorun olmaz.

**Boyut:** kopya zlib ile sıkıştırılır. Bir kelimenin kaydı JSON'da 150–270 bayt; sıkışınca birkaç on bayt. 3.000 kayıt yaklaşık 100–150 KB eder. 900 KB'ı geçen kopya yazılmaz, ekran "Kopya iCloud'un sınırını aştı" der (`SyncKeyValueCloud.byteLimit`). Kayıt çok büyürse CloudKit'e geçmek ayrı iş olur; kopyanın biçimi (`SyncSnapshot`) aynen kullanılabilir.

## 2. Biçim

### iCloud'daki kopya (`SyncSnapshot`, `Learning/SyncSnapshot.swift`)

Tek anahtar: `lockglow.sync.1`. Değeri zlib ile sıkıştırılmış JSON (anahtarlar sıralı, tarihler 1970'ten saniye, `progress.json` gibi):

```json
{
  "format": 1,
  "reset_at": 1761234567.25,
  "cards": [ {"word_id": 12, "state": "learning", "box": 2, "...": "WordProgress alanları"} ],
  "words": [ {"uuid": "…", "lemma": "awkward", "meaning_tr": "garip", "example_en": "…", "note": "…",
              "created_at": …, "updated_at": …, "progress": {"word_id": 0, "...": "…"}} ],
  "deleted": ["uuid", "…"]
}
```

- `cards`: kartların ilerlemesi, kart numarasıyla (her cihazda aynı).
- `words`: kendi kelimeler **uuid** ile. İlerlemeleri kelimenin içinde, `word_id` 0 ile.
- `deleted`: silinen kendi kelimelerin uuid'leri. Bu kelimeyi hâlâ tutan cihaz da siler.
- `reset_at`: eşitleme açıkken "İlerlemeyi sıfırla" zamanı.
- **Daha yeni `format`** hiç okunmaz ve **üstüne yazılmaz**. Ekran "Uygulamayı güncelle" der. Okunamayan kopyanın da üstüne yazılmaz.
- `WordProgress` ya da `CustomWord`'e alan eklenirse `format` artırılmalı. Yoksa eski sürüm her kaydı yeni alan olmadan geri yazar. `SyncSnapshotTests` alan sayısını sayar ve hatırlatır.

### Kimlik çakışması yok, yerel dosyalarda biçim değişikliği yok

Her cihaz kendi kelimelerini `CustomWordID.first` (1.000.000)'dan numaralar. İki cihaz farklı kelimelere aynı numarayı verebilir. Bu yüzden:

- iCloud'da kendi kelimenin kimliği **uuid**'dir. Her cihaz kendi numarasını korur ve numara → uuid eşlemesini kendi notunda tutar (`SyncState.uuids`).
- Başka cihazdan gelen kelime bu cihazda **bir sonraki boş numarayı** alır. Hiçbir cihazda var olan numara değişmez. Bu yüzden `progress.json`, widget planı, widget olayları ve `review_log.jsonl` hiç yeniden numaralanmaz.
- `custom_words.json` **değişmedi** (`format` 1). Göç yok; eski sürüm dosyayı aynen okur.
- Henüz uuid'i olmayan bir kelime, iCloud'da kimsenin almadığı aynı İngilizce kelimeyi bulursa onun uuid'ini alır (büyük/küçük harf fark etmez). Böylece aynı kelimeyi iki cihazda eklemek tek kelime olur. Not dosyası kaybolsa da kelimeler uuid'lerini yeniden bulur.

### Bu cihazın notu (`SyncState`, Application Support/`sync_state.json`)

`joined` (eşitleme açıldıktan sonra en az bir kez eşitlendi), `reset_at`, `uuids` (numara → uuid), `base` (son ortak kopya). Kaybolursa bir şey kaybolmaz: sonraki eşitleme "ilk açılış" gibi çalışır.

## 3. Birleştirme kuralları (`SyncMerge`, `Learning/SyncMerge.swift`)

Her cihazın kendi dosyaları asıl kayıttır; iCloud cihazların buluştuğu yerdir. **iCloud'da olmadığı için bu cihazdan hiçbir şey silinmez.** Yalnız açık bir silme (`deleted`) ya da sıfırlama (`reset_at`) bir şey kaldırır.

**İlerleme, kelime kelime** (üç yollu: bu cihaz, iCloud, son ortak kopya):

1. İki taraf aynıysa: kalır.
2. Son eşitlemeden beri **yalnız bir taraf** değiştirdiyse: o taraf kazanır. "Öğrenmeye geri al" ve 5 saniyelik "Geri al" yeni tarih yazmaz. Bu kural onları korur.
3. **İki taraf da** değiştirdiyse: **son cevap zamanı (`lastReviewedAt`) yeni olan kazanır.** Eşitse sırayla `lastSeenAt` yeni olan, cevabı çok olan, widget görmesi çok olan. Tam eşitlikte her cihaz aynı kaydı seçer.
4. Tarih hassasiyeti: `Date()` JSON'dan biraz farklı döner. Birleştirme iki tarafı da JSON'dan geçirip karşılaştırır, böylece değişmemiş kayıt "değişti" sayılmaz.

**Kendi kelimeler, uuid ile:**

- Metin: aynı kural, tarih olarak `updatedAt`.
- Bu cihazda silinen kelime (son ortak kopyada vardı, şimdi yok) her yerde silinir. **Ama** başka cihaz o arada kelimeyi düzenlediyse **düzenleme kazanır** ve kelime eski numarası ve ilerlemesiyle geri gelir.
- Başka cihazda silinen kelime burada da silinir, **burada** o arada düzenlenmediyse. İlerleme kaydı `progress.json`'da kalır (uygulamadaki silmede olduğu gibi; numara yeniden verilmez).
- "Vazgeç" ile geri getirilen kelime, silme iCloud'a gitmiş olsa bile kalır ve her yere geri döner.

**Sıfırlama:** eşitleme açıkken "İlerlemeyi sıfırla" `reset_at`'i yazar. Yeni sıfırlama kazanır: öbür tarafın **o zamandan önceki** ilerlemesi düşer, sonraki ilerleme kalır. Kendi kelimeler sıfırlanmaz, yalnız ilerlemeleri.

**Eşitlemeyi açmak yalnız ekler** (`joined` false): ilk eşitlemede bu cihazda hiçbir şey silinmez ya da sıfırlanmaz. Bu cihazdaki her kelime kalır; başka yerde silinmiş olsa da geri döner. Kapatıp açmak, ya da iCloud hesabı değişince açmak da böyledir.

**Yedekten dönen dosya:** `progress.json` ya da `custom_words.json` açılışta yedekten döndüyse (Ayarlar'daki uyarı), ilk eşitleme son ortak kopyayı kullanmaz. Eksik kelime silme sayılmaz; iCloud'dan geri gelir. Eski kayıt "değişiklik" sayılmaz; yeni kayıt kazanır.

## 4. Ne zaman eşitlenir

- Açılışta, içerik, ilerleme ve kelimeler yüklendikten sonra.
- Uygulama öne gelince ve arka plana geçince (`UIApplication` bildirimleri).
- iCloud başka cihazın kopyasını getirince (`didChangeExternallyNotification`).
- Anahtar açılınca, "Şimdi eşitle"de ve "İlerlemeyi sıfırla"dan hemen sonra.

Her eşitleme önce bekleyen widget dokunuşlarını alır. Sonra sırayla: kelimeleri kaydet, ilerlemeyi kaydet, iCloud'a yaz, notu kaydet. Bu cihazda kayıt başarısız olursa iCloud'a hiçbir şey gitmez. iCloud'a yazılamazsa not eski ortak kopyayı korur; sonraki eşitleme yeniden gönderir.

**iCloud bildirimleri:**

- ilk indirme bitti: son ortak kopya unutulur, yeniden eşitlenir;
- sınır aşıldı: durum satırı yazar;
- **hesap değişti: eşitleme kapanır**, ekran "iCloud hesabı değişti. Eşitlemeyi kapattık; istersen yeniden aç." der. Başka kişinin iCloud'una bu cihazın kelimeleri gitmesin.

## 5. Ekran

Ayarlar → İlerleme → "iCloud ile eşitle" (değer: Açık/Kapalı) → `SyncSettingsView`:

- anahtar "iCloud ile eşitle" (iCloud yoksa kapalı ve dokunulmaz); altında sorun varsa uyarı satırı;
- "Durum": "Son eşitleme: bugün 14:32" ve "Şimdi eşitle";
- "Ne eşitlenir?": cevaplar ve bildiğin kelimeler; kendi kelimeler; ayarlar, günlük sayılar ve son aramalar eşitlenmez;
- "iCloud'daki kopyayı sil" (onayla): iCloud'daki kopya silinir, eşitleme kapanır, telefondaki her şey kalır.

"Son eşitleme" bu cihazın iCloud kopyasıyla son buluşmasıdır. iCloud kopyayı diğer cihazlara kendisi, uygun olunca gönderir (genelde birkaç saniye ile birkaç dakika).

## 6. Apple tarafı (kullanıcı yapar)

Kod iCloud yeteneği olmadan **sessizce kapalı** kalır: `NSUbiquitousKeyValueStore.synchronize()` yetki yoksa `false` döner, anahtar açılamaz. Açmak için:

1. **Developer portalı** (developer.apple.com → Certificates, Identifiers & Profiles → Identifiers):
   - **Yusuf Uyar** ekibini seç.
   - `com.yusufuyar.vocabwidget` App ID'sini aç (widget'ınkini değil: `….widgets` iCloud'a gerek duymaz).
   - Capabilities listesinde **iCloud** kutusunu işaretle. Kapsayıcı (container) seçmeye gerek yok; anahtar-değer deposu kapsayıcısız çalışır.
   - **Save**. "Profiller geçersiz olacak" uyarısında **Confirm**. TestFlight iş akışı her çalıştırmada profili yeniden oluşturduğu için başka bir şey gerekmez.
2. **Kod tarafı** (Claude yapar, portal adımından sonra): `ios/project.yml` → `Lockglow` hedefi → `entitlements.properties` içine bir satır:

   ```yaml
       entitlements:
         path: App/Lockglow.entitlements
         properties:
           com.apple.security.application-groups:
             - $(APP_GROUP_ID)
           # iCloud ile eşitle (SyncKeyValueCloud): iCloud yeteneği App ID'de açık olmalı, yoksa imzalama bozulur.
           com.apple.developer.ubiquity-kvstore-identifier: $(TeamIdentifierPrefix)$(CFBundleIdentifier)
   ```

   Bu satır portal adımından **önce** eklenirse TestFlight profili bu yetkiyi içermez ve imzalama durur. Bu yüzden bu dalda eklenmedi.
3. **Deneme:** yeni TestFlight derlemesi, iki cihaz (ya da cihazı silip yeniden kurmak). Aşağıdaki kontrol listesi.

App Store Connect'te iş yok. Gizlilik etiketi değişmez: veriler kullanıcının kendi iCloud'una gider, bize gelmez ("Data Not Collected" kalır). Gizlilik manifestine yeni API yok.

## 7. Gizlilik

- iCloud'a giden: kartların ilerlemesi (numara, kutu, tarihler), kendi kelimeler (kelime, anlam, örnek, not) ve silinenlerin uuid'leri. Cihaz adı, hesap bilgisi, ayarlar, ölçümler, son aramalar ve tekrar günlüğü gitmez.
- Veriler kullanıcının iCloud hesabında durur; geliştirici göremez. Varsayılan kapalı; kullanıcı açar.
- Kayıtlar (`Logger`) hiçbir kelime metni içermez; yalnız hata türü.
- "iCloud'daki kopyayı sil" kopyayı kaldırır. Eşitlemesi açık başka cihaz kopyayı yeniden yükler; ekran bunu söyler.
- `docs/legal/gizlilik_politikasi_tr.md` (ve EN) güncellenmeli; öneri metni oturum notunda (`is5-icloud.md`).

## 8. Bilinen sınırlar

- **Aynı anda iki cihaz** aynı kelimeyi eklerse ve ikisi de birbirini görmeden yazarsa kelime iki kez görünebilir. Birini silmek yeter. Sırayla eşitlenince olmaz.
- **İki cihaz aynı anda yazarsa** iCloud birini tutar. Kaybeden cihaz sonraki bildirimde birleştirir ve yeniden yazar; kayıp olmaz. Yalnız tarihsiz bir değişiklik ("Öğrenmeye geri al") bu yarışta kaybolabilir.
- "Biliyorum" yeni bir **cevap** değildir. Bir cihazda "Biliyorum", öbüründe ondan **önce** verilmiş ama sonra gelen bir cevap varsa son cevap kazanır ve "Biliyorum" kaybolur (kural 3).
- Geç gelen widget cevabı `lastReviewedAt`'i geriye çekebilir (is4-ogrenme notu). Öbür cihazda daha yeni cevap varsa o kazanır.
- **Saat farkı:** sıfırlama ve "son cevap" cihaz saatine bakar. Saati yanlış cihaz yanlış tarafı kazandırabilir.
- **Sıfırlama** eşitleme açık olmayan cihaza gitmez. O cihazda sonradan eşitleme açılırsa onun ilerlemesi korunur ve iCloud'a eklenir (açmak yalnız ekler).
- `review_log.jsonl` (FSRS günlüğü), günlük sayılar, ölçümler ve ayarlar cihaza özel kalır. Başka cihazdan gelen cevap günlüğe yazılmaz; FSRS bağlanınca o kelimeler `incomplete` sayılır.
- Silinenler listesi (`deleted`) hiç kısalmaz; kelime başına yaklaşık 40 bayt.

## 9. Testler

- `SyncMergeTests` (Linux): ilk eşitleme; iki cihaz aynı numarayı verince çakışma yok; aynı kelime iki cihazda tek kelime; son cevap kazanır; tarihsiz değişiklik ve "Geri al" korunur; kurallar iki cihazda aynı kaydı seçer; yarışta eski kopya yeni cevabı silmez; silme yayılır; düzenleme silmeye üstün gelir (iki sırayla); "Vazgeç" silmeden sonra; yedekten dönen kelime ve ilerleme; sıfırlama yayılır, sonraki ilerleme kalır; eşitlemeyi açmak yalnız ekler; ikinci çalıştırmada değişiklik yok; yükleme başarısızsa ortak kopya eski kalır; silinen iCloud kopyası yeniden yazılır; üç cihaz, 20 rastgele senaryo: hepsi aynı sonuca varır ve her kartın en yeni cevabı kalır.
- `SyncSnapshotTests` (Linux): biçim, yeni biçim ve bozuk kopya, düzenleme, alan sayısı hatırlatmaları, durum dosyası.

## 10. Cihazda denenecekler (iCloud yeteneği açılınca)

1. Ayarlar → İlerleme → iCloud ile eşitle → aç. "Son eşitleme: bugün …" görünür.
2. İkinci cihazda (aynı Apple hesabı) aç: birinci cihazın kelimeleri ve ilerlemesi gelir; ikinci cihazın kendi kelimeleri de birinciye gider (birinciyi öne getir).
3. Birinci cihazda bir kelimeyi Tekrar'da cevapla, uygulamayı arka plana al. İkinci cihazı öne getir: kelimenin basamağı aynı.
4. Kendi kelimeyi bir cihazda sil: öbüründe de silinir. Düzenle: öbüründe değişir.
5. "İlerlemeyi sıfırla" (eşitleme açık): öbür cihazda da sıfırlanır; kendi kelimeler kalır.
6. iCloud'dan çıkış yap / başka hesap: eşitleme kapanır ve uyarı görünür.
7. Uçak modunda cevapla, sonra bağlan: değişiklik gider.
