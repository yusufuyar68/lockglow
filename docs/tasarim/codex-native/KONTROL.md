# Native aktarım kontrol kaydı

26 Ekim 2026. Bu kayıt gerçek Swift/iOS koşularını tarayıcı prototipinden ayrı tutar.

| Kod | Koşu | Sonuç |
|---|---|---|
| `87dd656` | [Linux ve içerik 40273891243](https://github.com/yusufuyar68/lockglow/actions/runs/40273891243) | Başarılı. Linux: 1.066 test, 5 platform atlaması, 0 hata. İçerik testleri ve katı doğrulama geçti. |
| `87dd656` | [Mac 40273891429](https://github.com/yusufuyar68/lockglow/actions/runs/40273891429) | Paket: 1.093 test, 0 hata. iOS test derlemesi, yeni hosted test hedefinin `CoreModels` statik paketini uygulamayla iki kez bağlaması nedeniyle durdu. Simülatör testleri çalışmadı; Faz 1 geçmedi. |
| `e6978c6` | [Linux ve içerik 40274925070](https://github.com/yusufuyar68/lockglow/actions/runs/40274925070) | Başarılı. |
| `e6978c6` | [Mac 40274925032](https://github.com/yusufuyar68/lockglow/actions/runs/40274925032) | Çift paket bağlantısı düzeldi. Hosted testte salt okunur `colorSchemeContrast` ortamına yazma derleme hatası yakalandı. Bu atama kaldırıldı; kontrastı host'un UIKit sistem özelliği verir. Simülatör testleri henüz çalışmadı. |
| `81e2702` | [Mac 40275485823](https://github.com/yusufuyar68/lockglow/actions/runs/40275485823) | Uygulama, widget ve testler derlendi; Mac paketleri geçti. SE'de gerçek Biliyorum/geri al testi geçti. Hosted palet, açık/koyu/yüksek kontrast/AX5 genişlik testleri geçti. Uzun kartın kaydırma/geometri kontrolleri geçti; yerel erişilebilirlik ağacından Neden? düğmesini bulma adımı başarısız. Görüntüde düğme tam görünüyor. Pro varyantına geçilmedi. |

İndirilen özgün günlükler çalışma alanındaki `docs/tasarim/codex/kontrol/native/faz1/40273891429/native-out/` dizinindedir. CI düzeltmesinde derleme adımı paket testlerinden önce gelir; tüm kabul testleri yine aynı kod üzerinde çalışır.

## Kanıtın sınırı

Hosted görüntü testindeki programatik kaydırma ve erişilebilirlik eylemi, gerçek parmak hareketinin iç/dış kaydırmaya yönlendirilmesini kanıtlamaz. Gerçek uygulama UI testi “Biliyorum → geri al” durum geçişini ölçer; önceki vadenin birebir kurtarılması öğrenme motorunun ayrı testlerindedir. Görüntü ekleri üretildiğinde ayrıca görsel olarak incelenir.

`81e2702` görsel incelemesi: yeşil, yüzey ve okuma başlığı doğru; SE'de örneğin büyük bir ayrıntı düğmesine erken kısalması A'nın doğrudan okuma akışını zayıflatıyor. Son kısaltma basamakları yerine tam örneği koruyan kaydırma tercih edilecek. Uzun karttaki son eylem kontrolü, gerçek XCUITest sürücüsüne taşınır; yalnız Debug simülatörde açılan fixture, içerik veritabanına yazılmaz. Hosted testte geometri ve iki genişlikte görüntüler korunur.

Test sürelerinin uygulanması için CI'da zaman aşımı açıkça etkinleştirilir; `executionTimeAllowance` tek başına bu özelliği açmaz ([Apple XCTest belgesi](https://developer.apple.com/documentation/xctest/xctestcase/executiontimeallowance)).

Fiziksel iPhone'da widget yenilenmesi, mikrofon/konuşma modeli, ses oturumu ve VoiceOver okuması ayrıca doğrulanacak. TestFlight yüklemesi yapılmadı.
