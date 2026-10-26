# Native aktarım kontrol kaydı

26 Ekim 2026. Bu kayıt gerçek Swift/iOS koşularını tarayıcı prototipinden ayrı tutar.

| Kod | Koşu | Sonuç |
|---|---|---|
| `87dd656` | [Linux ve içerik 40273891243](https://github.com/yusufuyar68/lockglow/actions/runs/40273891243) | Başarılı. Linux: 1.066 test, 5 platform atlaması, 0 hata. İçerik testleri ve katı doğrulama geçti. |
| `87dd656` | [Mac 40273891429](https://github.com/yusufuyar68/lockglow/actions/runs/40273891429) | Paket: 1.093 test, 0 hata. iOS test derlemesi, yeni hosted test hedefinin `CoreModels` statik paketini uygulamayla iki kez bağlaması nedeniyle durdu. Simülatör testleri çalışmadı; Faz 1 geçmedi. |
| `e6978c6` | [Linux ve içerik 40274925070](https://github.com/yusufuyar68/lockglow/actions/runs/40274925070) | Başarılı. |
| `e6978c6` | [Mac 40274925032](https://github.com/yusufuyar68/lockglow/actions/runs/40274925032) | Çift paket bağlantısı düzeldi. Hosted testte salt okunur `colorSchemeContrast` ortamına yazma derleme hatası yakalandı. Bu atama kaldırıldı; kontrastı host'un UIKit sistem özelliği verir. Simülatör testleri henüz çalışmadı. |

İndirilen özgün günlükler çalışma alanındaki `docs/tasarim/codex/kontrol/native/faz1/40273891429/native-out/` dizinindedir. CI düzeltmesinde derleme adımı paket testlerinden önce gelir; tüm kabul testleri yine aynı kod üzerinde çalışır.

## Kanıtın sınırı

Hosted görüntü testindeki programatik kaydırma ve erişilebilirlik eylemi, gerçek parmak hareketinin iç/dış kaydırmaya yönlendirilmesini kanıtlamaz. Gerçek uygulama UI testi “Biliyorum → geri al” durum geçişini ölçer; önceki vadenin birebir kurtarılması öğrenme motorunun ayrı testlerindedir. Görüntü ekleri üretildiğinde ayrıca görsel olarak incelenir.

Fiziksel iPhone'da widget yenilenmesi, mikrofon/konuşma modeli, ses oturumu ve VoiceOver okuması ayrıca doğrulanacak. TestFlight yüklemesi yapılmadı.
