# A yönünün gerçek iOS uygulamasına aktarımı

25 Ekim 2026. Kaynak: `yusufuyar68/lockglow`, başlangıç `ac3cbed`.

## Çalışma kuralı

Her fazda kaynak değişikliği, ilgili otomatik test ve native simülatör kanıtı ayrı kaydedilir. Başarısız kapı düzeltilmeden sonraki fazın uygulamasına geçilmez. Windows'ta kaynak incelemesi ve içerik denetimi yapılır; Swift ve iOS testleri GitHub Actions'ın Linux/macOS makinelerinde çalışır. HTML testleri iOS testi yerine geçmez.

Mevcut Leitner/FSRS, gerçek kart kimlikleri, ses ve veri sözleşmeleri esastır. Prototipin A/B/C kimlikleri, sabit 3/1/2/5 gün politikası ve 3/5/8 günlük seçenekleri taşınmaz. Native uygulamada gerçek konu seçimi ve 5/10/15/20 günlük hedefler vardır. Tam 1.383 kartlık içerik bu depodadır.

## Fazlar

| Faz | İş ve kabul kapısı | Durum |
|---|---|---|
| 0 | Kaynak, talimatlar, temiz ayrı dal; mevcut kodun başarılı temel derlemesini doğrulama | Tamamlandı |
| 1 | A kartının okuma sırası, satır içi örnek/çeviri, ayrı Biliyorum, yeşil yerel palet ve hafif açık yüzey; native derleme, SE/Pro, AX ve gerçek kaydırma görüntüleri | Çalışılıyor |
| 2 | Mevcut öğrenme ve geri almanın işlevsel eşdeğerliği; gerçek AppModel ile tam snapshot geri yükleme ve yeni cevabı koruma testleri | Sırada |
| 3 | Mevcut açılış, düzey/konu, widget rehberi ve ilk kelimenin gerçek veriyle doğrulanması | Sırada |
| 4 | Widget görünüm/hata durumları, içerik hassasiyeti, gerçek yedek/birleştirme ve ses kontrolleri | Sırada |
| 5 | Tüm yeni kodda paket testleri, native derleme ve son SE/Pro/koyu/AX görsel incelemesi | Sırada |

## Başlangıç kanıtı

- Masaüstündeki kaynak depoda değişiklik yoktu; `is6-hig`, `ac3cbed`.
- Çalışma ayrı `codex/ios-a-transfer` dalındadır. Asıl klasörde dal değiştirilmez.
- Önceki uygulama kodu `f13b15c` için [Linux/Python build 40188851249](https://github.com/yusufuyar68/lockglow/actions/runs/40188851249) ve [native görüntü koşusu 40184027401](https://github.com/yusufuyar68/lockglow/actions/runs/40184027401) başarılıdır. `ac3cbed` ile fark yalnız üç Markdown dosyasıdır; native kod aynıdır. Eski yeşil yeni değişikliğin kanıtı sayılmaz.

## İlk kod incelemesinde bulunanlar

Native uygulama prototipten daha ayrıntılıdır: kalıcı gerçek kart numaraları, seçilebilir Leitner/FSRS, kısa pencerede tam geri alma, günlük atomik yedek, bozuk dosyayı koruma, kendi kelimeleri ve birleştirmeli veri içe aktarma vardır. Bunların yerine örnek tarayıcı motoru konmaz.

Olay işleme incelemesi, ilerleme kaydından sonra widget olay dosyasını silmenin başarısız olması hâlinde aynı olayın yeniden uygulanması riskini gösterdi. Bu kaynak incelemesi bulgusudur; cihazda gözlemlenmiş bir hata gibi sunulmaz.

26 Ekim kapsam düzeltmesi: bu eski riskin kalıcı çözümü atomik ilerleme + işlenmiş olay kimlikleri, bütün kayıt yolları, yedek kurtarma ve eski sürüme dönüşü birlikte ele alan bir veri geçişi gerektiriyor. Tasarım aktarımının öğrenme eşdeğerliği kapısı mevcut dosya biçimiyle sınanır; veri geçişi ayrı dayanıklılık işidir. Risk çözülmüş gibi işaretlenmez. Böylece görsel aktarım kendi başına kullanıcının kayıt biçimini değiştirmez.

Gerçek koşuların başarıları, hataları ve kanıt sınırları [KONTROL.md](KONTROL.md) dosyasındadır.

## Cihazda ayrıca doğrulanacaklar

Simülatör derlemesi fiziksel iPhone doğrulaması değildir. Widget bütçesi, kilitli ekranda gerçek yenileme, ses oturumu, mikrofon/konuşma modeli ve VoiceOver'ın gerçek okuması telefonda ayrıca denenir. TestFlight yüklemesi bu test iş akışının parçası değildir.
