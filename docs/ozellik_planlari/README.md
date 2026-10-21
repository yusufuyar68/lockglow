# Özellik planları (21 Ekim 2026)

Bu klasör üç özelliğin teknik planını tutar. Hiçbiri kod değil, plan. Üçü de "sıfırdan yazma, var olan dalın üstüne ekle" ilkesiyle yazıldı. Planlar paralel yazıldığı için aralarında çelişkiler çıktı; **bu README onları çözer ve çakıştıklarında planlardan önceliklidir.** Planlar bu kararlara göre düzeltilene kadar önce buraya bak.

> **Nasıl hazırlandı:** 17 ajanlık bir iş akışı yazdı: 4 okuyucu, 3 tasarımcı, 6 denetçi, 3 düzeltici ve 1 eleştirmen. Denetçiler 60 bulgu getirdi, hepsi planlara işlendi. Planların tamamı satır satır doğrulanmadı. Aşağıdaki maddeleri koordinatör oturum dallardaki koda karşı ayrıca kontrol etti (21 Ekim, `origin` dalları).

## Doğrulanmış bulgular (önce bunlar)

| # | Bulgu | Kanıt | Durum |
|---|---|---|---|
| 1 | Gizlilik manifestinde dosya zaman damgası bildirimi eksik. App Store yüklemesinde uyarı ya da ret riski var. | `ProgressStore.swift:115-163` `attributesOfItem` ve `.modificationDate` kullanıyor. `ios/App/PrivacyInfo.xcprivacy` yalnız `UserDefaults` bildiriyor. | Doğru. `NSPrivacyAccessedAPICategoryFileTimestamp` + `C617.1` eklenmeli. |
| 2 | Deste süzgeci yalnız ana konuya (`primary_topic`) bakıyor. Seyahat 55 yerine 20 kelime, İş yeri 22 yerine 12 kelime gösteriyor. | `origin/ios/acilis-deste` `ContentStore.swift:59,82` | Doğru. Üyelik mi ana konu mu, kullanıcı kararı (deste planı, soru 1). |
| 3 | Güncelleyen mevcut kullanıcıya (sahibin kendi telefonu) açılış turu bir kez açılır. | Dal `AppModel.swift:36`: `showsOnboarding = !AppPreferences.onboardingCompleted`. İlerleme ya da plan kontrolü yok. | Doğru. Zararsız (Atla var), ama `OnboardingGate` önerisi geçerli. |
| 4 | Widget'tan açılan kelime seçili konularda değilse uygulama Akış'ı açar, kelimeyi göstermez. | Dal `RootView.swift`, `handle(_:)`: yalnız `feedWords` içinde arıyor. | Doğru. Deste planındaki detay sayfası önerisi geçerli. |
| 5 | Söyle mikrofonu açarken yalnız uygulamanın `Speaker`'ını durduruyor. Widget hoparlörünün (`WordSpeechPlayer`, `ios/widget-ses`) sesi sürebilir. | `origin/ios/telaffuz` `PronunciationRecognizer.swift:139-143` | Doğru. İki dal birleşirken ortak bir `stopAll()` kancası gerekir. |
| 6 | CI'da `linux_check.sh` işi yok. Bu PC'de Docker olmadığı için paket testleri push'tan önce hiç koşmuyor. | `.github/workflows/build.yml`: Ubuntu'da yalnız `python` işi var. `linux_check.sh` başlıktaki yorumda yalnız "push'tan önce çalıştır" diye geçiyor. | Doğru. Ubuntu'da ücretsiz bir `linux` işi önerisi geçerli. |

## Üç plan

| Dosya | Ne | Taban |
|---|---|---|
| `acilis_akisi.md` | 4 sayfalık açılış turu (seviye, konular, widget rehberi, ilk kelime). Dalda hazır olanın üstüne eklenenler: mevcut kullanıcı tespiti (`OnboardingGate`), konular sayfasında yükleme ve özet, yedek kural, rehber metinleri, ilk kelime hata durumu | `origin/ios/acilis-deste` (ea3e8ce, 3 commit, CI yeşil, henüz main'de değil) |
| `deste_secimi.md` | Konu (deste) seçimi farkları: `card_category` üyelik sayımı, seçim özeti, widget'tan açılan ama destede olmayan kelime için detay sheet'i | aynı dal |
| `soyle_telaffuz.md` | Söyle: cihaz içi sesli telaffuz. Aşama 1 dalda hazır (tek kelime sayfası). Aşama 2: Tekrar'da 8 kelimelik tur. Aşama 3: koşullu kalıcı istatistik | `origin/ios/telaffuz` (2 commit, hiç derlenmedi) |

İlk ikisi aynı tabanı ve aynı dosyaları paylaşır (`AppModel`, `DeckFilter`, `TopicPickerView`, `SettingsView`, `ContentLoader`). Tek iş olarak uygulanır.

## Ortak kararlar (tek doğru kaynak)

**Tercih anahtarları** (`UserDefaults.standard`, `lockglow.` öneki; hepsi acilis-deste dalında tanımlı, yeni anahtar eklenmez):

| Anahtar | Tür | Varsayılan |
|---|---|---|
| `lockglow.onboardingCompleted` | Bool | yok. Yoksa ve `widget_plan.json` varsa tur açılmaz ve `true` yazılır; plan da yoksa tur açılır |
| `lockglow.selectedTopicIDs` | `[String]` (erişimci `Set<String>`) | yok ya da boş = tüm konular |
| `lockglow.startLevel` | `"A1"`, `"A2"`, `"B1"` | yok = A1 sırası |
| `lockglow.dailyNewWords` (var) | 5, 10, 15, 20 | 10 |

Söyle yeni anahtar, dosya ya da App Group yazımı eklemez (`SayMemory` yalnız bellekte). Kalıcı Söyle sayısı (Aşama 3) yalnız cihaz testi isterse `pronunciation.json` olarak ayrı dosya olur. `WidgetWord`, `WidgetPlan`, `widget_plan.json` ve `seed_words.json` sözleşmesi değişmez.

**Kurallar**
- Seviye süzgeç değil sıralamadır (`DeckFilter.ordered`); hiçbir kelime düşmez. Konu süzgeci boş seçimde ve eşleşme yoksa hepsini döndürür; seçim akışı hiç boşaltmaz.
- `AppModel.words` tüm kelimelerdir (Sözlük, sayımlar, vadesi gelen tekrarlar). `feedWords` kullanıcının destesidir (Akış, widget kuyruğu, yeni kelimeler). Konu süzgeci yalnız `feedWords`'tedir.
- Konu sayımı ve süzgeç `card_category` üyeliğine göre (deste planı), tekrarsız birleşim. Seçim özeti için tek hesap `DeckFilter.summary`. Gün tahmini yok.
- "Yeni kelime" tek tanım: `progress[id]?.state ?? .new == .new` (`ReviewPlanner.newWords` ile aynı). `hasNewWords` ve özet bunu çağırır.
- Seçili konuların yeni kelimeleri bitince widget, Tekrar ve hatırlatma tüm konulardan devam eder (`newWordFeed`, tek bayrak `newWordsComeFromAllTopics`). Akış seçili konuları göstermeye devam eder. Deste planındaki "Tekrar durur, 'Konuları düzenle' çıkar" kararı geçersiz.
- Widget'ta görünen kelime seçim değişince sabit kalır (`pinFirst: currentWord`).
- `WordCardView(word:detail:showsSay:)`: tek parametre adı, varsayılan true. Turun "İlk kelime" sayfası `false` verir (izin penceresi garantisi).
- Yeni ekranlar `Palette` ve `GlowButtonStyle` kullanır (ham hex ve `.borderedProminent` yok). Asset Catalog geçişi yalnız `GlowStyle.swift`'te olur.

**Kanonik metinler**
- Konular ekranı (Ayarlar): "Widget'ta, Akış'ta ve Tekrar'ın yeni kelimelerinde seçtiğin konular döner. Hiç seçmezsen hepsi gelir. Seçtiğin konuların yeni kelimeleri bitince diğer konulardan devam edilir. Öğrendiğin kelimelerin tekrarı her konuda sürer." Turun 2. sayfasında ilk üç cümle.
- Ayarlar > Öğrenme altbilgisi: "Yeni kelimeler bu seviyeden başlar. Değiştirince widget'taki kelime bir sonraki değişime kadar aynı kalır." Yalnız `newWordsComeFromAllTopics` iken ek satır: "Seçtiğin konuların yeni kelimeleri bitti; yeni kelimeler diğer konulardan geliyor."
- Özet satırı: deste planındaki tablo ("Seçili: N kelime", yeni sayısı satırı).

## Uygulama sırası (tek sıra)

Neden bu sıra: önce bağımsız ve riski sıfır olanlar, sonra iki planın ortak tabanı, en son belirsiz olan. Sahibin Mac'i yok, doğrulama GitHub Actions'ta ve macOS dakikası 10 kat sayılıyor (kota 2000, 17 Ekim'de ~810 kullanılmıştı); bu yüzden her adımda tek `build.yml` ve tek `screenshots.yml`.

0. **Bugün, paralel, kod riski yok.**
   - `PrivacyInfo.xcprivacy`'ye `FileTimestamp` + `C617.1`: main'de tek commit (üç planın ortak işi; `ProgressStore` dosya zaman damgası kullanıyor).
   - `build.yml`'ye ubuntu `linux_check.sh` işi (çarpan 1; bu PC'de Docker yok). Üç planın testleri buna dayanır.
   - `ios/telaffuz` yalnız derlenir ve TestFlight ile cihazda denenir (kod yazmadan). Neden erken: hiç derlenmemiş, en belirsiz iş, diğerlerini beklemez. Sonuç Söyle'nin karar kapısı.
   - `tasarim/arayuz-mockup`: çalışma kopyası commit edilir (bugün onboarding ekranları yalnız commit'siz kopyada), kanonik metinlere göre güncellenir, Söyle ekranları eklenir.
1. **`ios/widget-ses` -> main.** CI yeşil, bağımsız, çakışması yalnız README ve küçük. Söyle'nin ses oturumu işi ve rehberin "hoparlör düğmesi" notu buna dayanır. Cihazda hoparlör denenir.
2. **`ios/acilis-deste` <- main birleştir, `build.yml` yeşil, üstüne `OnboardingGate` commit'i, sonra main'e.** İki planın tabanı. Gate, TestFlight güncellemesinde sahibe turun görünmemesi için bu adımda gelir. Cihazda dalın README madde 46 listesi denenir.
3. **Deste + açılış farkı, tek dal (`ios/deste-fark`).** Commit sırası: (a) üyelik sayımı, `topicsByCard`, stub, `DeckFilter` imzası ve `summary`; (b) `hasNewWords`, `newWordFeed`, `AppModel` bayrağı, Tekrar ve hatırlatma; (c) `DeckSummaryLine`, `TopicPickerView` (`scenePhase`), turun 2. sayfası, altbilgi, `showsSay` parametresi; (d) tur sayfa 3-4 metinleri ve hata durumu; (e) detay sheet'i ve bekleyen kelime kuralı; (f) UI testleri; (g) belgeler. Neden önce üyelik: özet görünümü ve tur ona bağlı; imza değişikliği en geç buraya gelirse iki kez yazılmaz.
4. **`ios/telaffuz` -> main (Aşama 1).** Üçüncü adımdan sonra: `showsSay` bağlanır, stil `Palette` ile, `WordSpeech.stopAll` kancası, mikrofon ikon düğmesi, UI test eki (8b, 11). Cihaz testi: README "Söyle: cihazda denenecekler" ve widget hoparlörüne basıp hemen Söyle'ye girme.
5. **Karar kapısı (sahip, cihazda).** Tek kelime sayfası yetiyorsa Aşama 2 yapılmaz. Gerekirse: `PracticePlanner` (feed olarak Tekrar'ın `newWordFeed`'i), `SayEntryCard`, `SayRoundView`, tanılama. Tek sunum kuralına uyar.
6. **Mağaza öncesi, şimdi değil.** iOS 17-25 yolu (G1), "Söyle tanılama" `#if DEBUG`, KVKK:37 ve `docs/legal/README.md:72` mikrofon cümleleri, ücretli kategorilerin (`access = 'P'`) seçicide görünmesi, Palette'in Asset Catalog'a taşınması, koşullu işler (`ordered(lowerEvery:)`, Aşama 3).

`content.sqlite` yeniden derlemesi (s10-s12 sonrası) kodu değiştirmez ama tüm sayıları kaydırır; 3. adımdan sonra kendi dalında yapılır.

## Diğer dallarla ilişki

- `ios/zor-kolay`: main'e birleşti (315787f). Önkoşul değil. Planlar yalnız `ReviewView.startScreen` ve `nextReviewSession` satırına dokunur.
- `ios/widget-ses`: 1. adım. `telaffuz` ile metinsel çakışma yok (git ile denendi); ses oturumu çakışması kod işidir (yukarıda).
- `ios/acilis-deste` ve `ios/telaffuz`: birleşirken yalnız `ios/README.md` çakışır (`FeedView.swift` farklı bölgeler). README numaraları korunur (44, 45, 46; Söyle numarasız bölüm), yeni numara açılmaz.
- Mockup: kanonik metinlerin ve Söyle ekranlarının kaynağı olacak; commit'siz kopya önce kaydedilmeli.
- Terim notu: görev özetindeki "61 kategori" yanlış, veritabanında 60 var. 25 kategorinin ana konulu kartı, 34'ünün üyelik kartı var.

## Sahibe sorulacaklar (tek liste)

1. `ios/acilis-deste` ve `ios/telaffuz` devralınsın mı (önerim: evet)?
2. Konu sayımı üyelikle mi (önerim) ana konuyla mı?
3. Seçili konular bitince Tekrar diğer konulardan devam etsin mi (önerim: evet, yukarıdaki karar bu)?
4. Turu sen de bir kez görmek ister misin? Varsayılan görmez; Ayarlar > Yardım'dan açılır.
5. Söyle için Tekrar'da 8 kelimelik tur gerekli mi? Cihaz testinden sonra karar.
6. A2 seçince A1 en sona kalsın mı, yoksa alt seviyeden serpiştirilsin mi? Önerim: 1-2 hafta dalın sırasıyla kullan.
7. macOS kotası bu plana yeter mi? (Yaklaşık dört build, üç screenshots, dört TestFlight.)
