# Lockglow

Türkçe konuşanlar başta olmak üzere İngilizce öğrenenler için kilit ekranı ve ana ekran widget'ıyla kelime öğreten iOS uygulaması.

| Klasör | İçerik | Nerede çalışır |
|---|---|---|
| [`Widget_Vocabulary_Analiz_ve_Plan.md`](Widget_Vocabulary_Analiz_ve_Plan.md) | Pazar analizi ve ürün planı (ana karar belgesi) | Okuma |
| [`raporlar/`](raporlar/) | 14 ayrıntılı araştırma raporu (01–13b) | Okuma |
| [`docs/contract/content-db.md`](docs/contract/content-db.md) | İçerik hattı ↔ uygulama veri sözleşmesi (SQLite şeması, widget dosyaları, döngü algoritması) | Referans |
| [`content-pipeline/`](content-pipeline/) | Kart şeması, doğrulama, Claude ile üretim, insan denetimi, SQLite paketleme (Python) | Windows / Mac |
| [`content/cards/`](content/cards/) | Editör onaylı kartlar: içeriğin kalıcı kaynağı | Veri |
| [`content/drafts/`](content/drafts/) | Denetlenmemiş taslak kartlar (kişisel set: 752 kart) | Veri |
| [`ios/`](ios/) | SwiftUI uygulaması + WidgetKit widget'ları + VocabKit paketi (XcodeGen) | **Yalnızca Mac (Xcode)** |
| [`docs/legal/`](docs/legal/) | Gizlilik politikası, KVKK aydınlatma + açık rıza, kullanım şartları (TR/EN), App Store gizlilik etiketi cevapları. **TASLAK, avukat onayı gerekir** | Okuma |
| [`marketing/`](marketing/) | Faz 0 açılış sayfası (`landing/`) ve 30 videoluk kanca bankası (`icerik/`) | Web / Okuma |
| [`veri/`](veri/) | 25 kartlık örnek veri seti | Veri |
| [`referans/`](referans/) | Rakip ekran görüntüleri (yalnızca iç analiz) | Okuma |

## Hızlı başlangıç

**İçerik hattı** (Python 3.11+):
```bash
cd content-pipeline && python -m pip install -e ".[dev]" && python -m pytest
```

**iOS** (Mac, Xcode 26+): adımlar [`ios/README.md`](ios/README.md)'de. Kısaca: `brew install xcodegen` → `ios/Config/Base.xcconfig`'te `BUNDLE_ID_PREFIX` ve `DEVELOPMENT_TEAM` → `cd ios && xcodegen generate` → `Lockglow.xcodeproj`'yi aç → iPhone'da çalıştır. Paket testleri: `cd ios/Packages/VocabKit && swift test`.

## Durum (2026-10-11)

- ✅ İçerik hattı: şema, 22 kurallı doğrulayıcı (artık quiz şıkkı tekrarını da yakalıyor), Claude Batch üretimi (A/B/C), insan denetimi, plan birleştirme, SQLite + seed paketleme, kişisel derleme. 72 test geçiyor.
- ✅ 50 kelimelik pilot plan hazır (`content-pipeline/plans/pilot_50.csv`). Kuru çalıştırma tahmini: ~$3–4.
- ✅ 1. parti kelime planı: 1.292 vitrin kategorisi kartı (`content-pipeline/plans/batch1_hero.csv` + `batch1_hero_NOTLAR.md`). Tahmin: ~$80–100.
- ✅ Faz 0 açılış sayfası (`marketing/landing/`, form bağlanana kadar demo modunda) ve 30 videoluk kanca bankası (`marketing/icerik/`).
- ✅ **Kişisel sürüm:** A2 seviyesindeki kurucu için A1–B1 günlük İngilizce seti `content/drafts/kisisel_v1/` içinde. Uygulamaya `python -m vocabpipe.personal` ile derleniyor.
  - **1. tur (2026-10-12):** 479 kart, 100 phrasal verb dahil.
  - **2. tur (2026-10-20):** 273 temel kart eklendi (fiiller, sıfat ve zarflar, kalıp ifadeler, günlük isimler). Toplam **752 kart**, `content_version` `2026.10.20-kisisel-3`.
  - Süreç: `docs/icerik_uretimi/`.
- ✅ Öğrenme motoru uygulamaya bağlandı: widget dokunuşları ilerlemeye işleniyor, "Tekrar" sekmesi (Bildim/Bilemedim), "Ayarlar" (değişim sıklığı, günlük yeni kelime, sıfırlama). Widget'ta Türkçe anlam önde.
- ✅ Yasal metin taslakları (`docs/legal/`). Avukat için 30 maddelik [TEYİT] listesi README'de.
- ✅ **Ad: Lockglow** (2026-10-11, 3. tur taraması: `raporlar/13b_sade_ingilizce_adlar.md`). Uygulama, açılış sayfası ve yasal taslaklar bu adla. ⚠️ Yayından önce: TÜRKPATENT araması (9, 41, 42. sınıflar) ve marka vekili görüşü. Bundle id'ler markadan bağımsız (`vocabwidget`). ~~Wordglance~~ marka taramasından geçemedi (`raporlar/11_isim_taramasi.md`).
- ✅ iOS uygulaması GitHub Actions'ta Xcode 26.3 ile derleniyor. Mac gerekmiyor.
  - Simülatörde ekran görüntüleriyle denendi (`screenshots.yml`).
  - Linux'ta 113 birim testi geçiyor (`ios/Tools/linux_check.sh`).
  - Sekmeler: Akış, Tekrar (Leitner + boşluk doldurma sorusu), Sözlük, Ayarlar (bildiğim kelimeler, hatırlatma, widget sağlığı).
  - Widget'lar: küçük, orta, kilit ekranı.
  - Telaffuz, günlük hatırlatma ve ilerleme yedeği var.
  - Bilinen riskler: `ios/README.md` → "Bilinen belirsizlikler".
- ✅ Apple kayıtları: App Group, iki App ID ve App Store Connect kaydı (Yusuf Uyar ekibi).
- 🟡 **TestFlight:** iş akışı hazır (`testflight.yml`), yalnızca App Store Connect API anahtarının GitHub'a eklenmesini bekliyor. Bunu kullanıcı yapmalı; adımlar `docs/testflight_kurulum.md`'de.
- ⏭ **Kaldığımız yer ve sıradaki işler:** [`DEVIR.md`](DEVIR.md). Durum özeti (ekran görüntülü): [`docs/lockglow_ilerleme.html`](docs/lockglow_ilerleme.html).
