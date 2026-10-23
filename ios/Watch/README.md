# Lockglow Apple Watch (is5-watch)

İzle uygulaması ve kadran komplikasyonları. watchOS 10 hedefler, tek hedefli SwiftUI izle uygulamasıdır.

> **Durum (23 Ekim 2026):** Kod yazıldı; CI'da simülatör için imzasız derleniyor. İzle hedefi **iPhone uygulamasına henüz gömülü değil** ve hiçbir iPhone şemasında yok. Bu yüzden TestFlight derlemeleri yalnızca iPhone uygulamasını içerir. Gömmek için aşağıdaki "Apple'daki adımlar" gerekir.

## Ne yapar

- **İzle uygulaması:** kadrandaki kelimeyi gösterir: İngilizce kelime, Türkçe anlam ve örnek cümle. Köşedeki **Dinle** düğmesi kelimeyi okur. Altta **Sonraki kelime** ve **Biliyorum** düğmeleri var.
- **Komplikasyonlar:** dikdörtgen, satır içi, yuvarlak ve köşe aileleri. Kelime her saat başı (yerel saat) değişir. Türkçe anlam hiç kesilmez: sığmazsa kısa biçimi, o da sığmazsa yalnız kelime görünür.
- **Veri:** telefon, widget planını (`widget_plan.json` biçimi) WatchConnectivity ile izleye gönderir. İzle kendi başına not vermez; yalnızca "Biliyorum" ve "Sonraki kelime" olaylarını telefona yollar. Telefon bunları widget olaylarıyla aynı kutuya (`events/`) yazar ve uygulama her zamanki gibi işler.

## Dosyalar

```
Watch/
├─ App/        LockglowWatch (izle uygulaması)
│  ├─ LockglowWatchApp.swift   giriş, arka plan görevleri
│  ├─ WatchModel.swift         dönüş, iki düğme
│  ├─ WatchSession.swift       telefondan plan al, olayları gönder
│  ├─ WatchSpeaker.swift       Dinle (cihazdaki ABD İngilizcesi sesi)
│  ├─ WatchWordView.swift      tek ekran
│  └─ Assets.xcassets          simge (iPhone simgesinin kopyası), AccentColor
├─ Widgets/    LockglowWatchWidgets (komplikasyonlar)
└─ Shared/     iki hedefte de derlenir: WatchStore (dosyalar), WatchGloss, WatchTheme
```

Telefon tarafı: `App/WatchBridge.swift` (WatchConnectivity) ve `App/WatchPlanRelay.swift` (AppModel plan yazınca haber verir). Saf mantık VocabKit'te, Linux'ta test edilir: `SharedState/WatchSync.swift` (gönderilen biçim, `WatchKnownLedger`) ve `Scheduler/WatchRotation.swift` (saatlik dönüş).

## Akış

1. Uygulama `widget_plan.json` yazınca `WatchBridge` planı kırpar (kişisel konular çıkar, en çok 48 kelime, karışan çiftler çıkar) ve `updateApplicationContext` ile gönderir. Kadranda Lockglow komplikasyonu varsa en çok 2 saatte bir `transferCurrentComplicationUserInfo` da kullanılır; bu, izle uygulamasını arka planda uyandırır.
2. İzle yeni planı kendi App Group klasörüne aynı biçimde yazar. Son 3 günde izlede "Biliyorum" denen kelimeler plandan çıkarılır (`WatchKnownLedger`), çünkü telefon o olayı henüz almamış olabilir. Ekrandaki kelime yeni planda varsa izle o kelimeden devam eder (`WatchRotation.stateKeepingWord`); telefon da plan yazarken görünen kelimeyi korur. Arka planda gelen veri için iki yol var: SwiftUI `.backgroundTask(.watchConnectivity)` ve `WKApplicationDelegate.handle(_:)`. İzledeki bütün dosya yazmaları `WatchSession`'ın tek sırasından geçer.
3. İzledeki düğmeler izlenin kendi `widget_state.json` dosyasını günceller ve olayı `events/` kutusuna koyar. `WatchSession` kutuyu `transferUserInfo` ile boşaltır. Sistem olayı telefon alana kadar saklar.
4. Telefon olayı aldığında (uygulama açıkken ya da açıldığında) App Group `events/` kutusuna `source: "watch"` ile yazar. `AppModel.ingestWidgetEvents()` onu bir sonraki çalışmada işler: `known` → 3 gün sonra bir kez sorulur, `next` → yalnız görüldü sayılır.

## CI

`build.yml` → `ios` işi, "Apple Watch uygulaması + komplikasyonlar derle" adımı:

```
xcodebuild -scheme LockglowWatch -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Makinede watchOS simülatör SDK'sı yoksa adım önce `xcodebuild -downloadPlatform watchOS` çalıştırır.

## Apple'daki adımlar (kullanıcı yapar)

1. Developer portalında iki yeni App ID: `com.yusufuyar.vocabwidget.watchkitapp` ve `com.yusufuyar.vocabwidget.watchkitapp.widgets`.
2. İkisine de App Groups yeteneği ve mevcut `group.com.yusufuyar.vocabwidget` grubu.
3. Sonra kodda: `project.yml` içinde `Lockglow` hedefine `- target: LockglowWatch` bağımlılığı (gömme) ve `testflight.yml`'de bu iki kimlik için profiller (`asc_signing.py setup` listesine iki bundle id). Bu iki adım, App ID'ler oluşmadan yapılırsa TestFlight işi bozulur.

## Cihazda bakılacaklar

- Dinle sesi izlenin hoparlöründen geliyor mu?
- Komplikasyon, telefon uygulaması kapandıktan sonra yeni kelimeleri alıyor mu (arka plan uyandırması)?
- Telefon uygulaması açılınca izledeki "Biliyorum" telefonda bildiğin kelimelere geçiyor mu?
