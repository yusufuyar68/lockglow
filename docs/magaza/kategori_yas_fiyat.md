# Kategori, yaş sınırı ve fiyat önerisi

> **TASLAK (22 Ekim 2026).** Hukuki görüş değildir. Vergi ve satıcı (trader) konuları SMMM ve avukatla netleşecek (`DEVIR.md` → "Yayın işleri").
>
> **Marka uyarısı:** "Lockglow" adı için TÜRKPATENT araması ve marka vekili görüşü yapılmadı. Mağazaya göndermeden önce bu iki adım tamamlanmalı.

## Kısa öneri

| Konu | Öneri |
|---|---|
| Birincil kategori | **Eğitim (Education)** |
| İkincil kategori | **Başvuru Kaynakları (Reference)** |
| Yaş sınırı | **13+** (ayrıntı aşağıda; 4+ istenirse içerikte 3 kart değişir) |
| Fiyat | **Ücretsiz, uygulama içi satın alma yok** |
| Ülkeler | **Önce yalnızca Türkiye** |
| Abonelik | Şimdi yok; ileride bir fikir olarak not (en altta) |

## Kategori

- Apple'ın tanımında **Education** açıkça "vocabulary" ve "language learning" örneklerini içeriyor; **Reference** ise "dictionary" ([Choosing a category](https://developer.apple.com/app-store/categories/)).
- Türkiye'deki rakiplerin neredeyse hepsi Eğitim'de (Duolingo, Kolay İngilizce, Atlas, Orbit, Monkey Taps). Kullanıcı orada arıyor.
- İkincil Reference, Sözlük sekmesine uyar.
- **Games > Word seçmeyin** (`raporlar/08` §7.2). Uygun olmayan kategori kurala aykırı.
- Kategori adı arama dizinine girer; bu yüzden "eğitim" anahtar kelimelere yazılmadı.

## Yaş sınırı

Apple 2025'te yaş sistemini değiştirdi: **4+, 9+, 13+, 16+, 18+**. Yeni soru listesi 31 Ocak 2026'dan beri zorunlu ([Age ratings values and definitions](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions)).

### Önerilen cevaplar

| Soru grubu | Cevap | Gerekçe |
|---|---|---|
| Profanity / Crude Humor | None | Argo kartları 2 tane, küfür yok |
| Horror / Fear | None | — |
| **Alcohol, Tobacco, or Drug Use or References** | **Infrequent** (dürüst yol) ya da None | Kartlarda birkaç **gönderme** var: `give_up` ("give up smoking", sigarayı bırakmak), `allow` ("They allow smoking here"), `glass` ("wine glass"). Hiçbiri özendirici değil, ama "references" kelimesi soruda geçiyor |
| Medical or Treatment Information | None **[TEYİT]** | Apple tanımı: tanı ya da hastalık yönetimi rehberliği (ilaç rehberliği, tedavi bilgisi). "Sağlık & Vücut" konusu (74 kartın ana konusu; konu seçicide 106 kart) dil öğretimi; "Take this medicine twice a day" bir örnek cümle, tavsiye değil. Infrequent denirse sonuç yine 13+ |
| Health or Wellness Topics | None | Apple tanımı: öz bakım ya da yaşam tarzı önerisi (kalori, diyet, egzersiz). Uygulamada yok |
| Sexuality / Nudity | None | — |
| Violence (cartoon, realistic, weapons) | None | Taramada şiddet cümlesi çıkmadı ("painkiller" kelime yapısı açıklaması hariç) |
| Gambling, contests, loot box | None | — |
| Parental controls / age assurance | No | — |
| Unrestricted web access | No | Uygulamada tarayıcı yok |
| User-generated content | No | Kullanıcı içerik paylaşamıyor |
| Messaging / chat, social media | No | — |
| Advertising | No | Reklam yok |

İçerik taraması: 22 Ekim 2026, `content.sqlite` (933 kart); 23 Ekim 2026'da 1.203 kartla (`2026.10.23-kisisel-10`) yinelendi, sonuç aynı: alkol ve tütün göndermesi yalnız `give_up` ("give up smoking", Dikkat kutusunda), `allow` ("smoking") ve `glass` ("wine") kartlarında; şiddet, uyuşturucu, kumar ve cinsellik yok ("knife" mutfak bıçağı, "fight" yastık kavgası ya da tartışma anlamında). İlaç kelimeleri (medicine, painkiller) de çıktı; dil öğretimi bağlamında (tablodaki "Medical" satırı).

### Neden 13+?

1. **Tutarlılık:** Gizlilik politikası "13 yaşın altındaki çocuklara yönelik değildir" diyor (`docs/legal/gizlilik_politikasi_tr.md` §9). 4+ derecesi bununla çelişkili görünür.
2. **Dürüst cevap:** Apple'ın tablosunda "Infrequent alcohol, tobacco, or drug use or references" doğrudan **13+** veriyor (Frequent → 18+). Tanım "references to … the consumption of … tobacco" (sigara içme göndermesi) içeriyor; "give up smoking" buna girer (22 Ekim 2026'da bakıldı).
3. **Hedef kitle:** Lise öğrencisi ve yetişkin A2 öğrencisi. Rakiplerden Monkey Taps 13+, Orbit 4+.

**4+ istenirse:** `give_up`, `allow` ve `glass` kartlarındaki cümleler değiştirilir (içerik hattında, `docs/icerik_uretimi/` kurallarıyla), alkol/tütün sorusuna None denir **ve** gizlilik politikası §9 yeniden yazılır. "For Kids" / "Çocuklar için" ifadesi **hiçbir zaman** kullanılmaz (Kids kategorisine ayrılmış, Kural 2.3.8).

## Fiyat

**Öneri: Ücretsiz, satın alma yok.** Gerekçeler:

- Uygulama önce kullanıcının kendisi için. Ödeme sistemi (StoreKit, RevenueCat) **kodda yok** (`docs/legal/app_store_privacy_etiketi.md` §2A).
- Ücretli satış ya da abonelik için önce **Paid Apps Agreement**, banka bilgisi ve vergi formu gerekir (`raporlar/09` §1.3–1.4). Bunlar SMMM görüşmesinden sonra. Ücretsiz uygulama için **Free Apps Agreement** yeterli **[TEYİT]**.
- Rakiplere karşı en güçlü cümle "reklam yok, hesap yok, gizli ücret yok" (bkz. `rakiplerden_ogrenilenler.md` 1–4).
- Yasal metinler sadeleşir: abonelik, analitik ve yurt dışı aktarım bölümleri gerekmez (`docs/legal/README.md` §4.1).

### Ülkeler: önce yalnızca Türkiye

- **AB (DSA) satıcı beyanı:** AB'de dağıtım için Apple, geliştiriciden "trader" (tacir) olup olmadığını sorar. Tacir sayılırsa **adres, telefon ve e-posta AB ürün sayfalarında herkese açık** görünür (`raporlar/09` §1.2). Gelir yoksa "non-trader" demek mümkün olabilir **[TEYİT: avukat]**. En basit yol: ilk sürümü AB'ye açmamak.
- İçerik Türkçe konuşanlar için; başka ülkede kitle küçük.
- İleride: Kıbrıs, Almanya, Hollanda gibi Türkçe konuşan nüfusu olan ülkeler (AB beyanı ve gizlilik metinleri GDPR bölümleriyle birlikte). Ayrıntılı plan: [`avrupa_acilis_plani.md`](avrupa_acilis_plani.md).

## İleride abonelik fikri (yalnızca not, karar değil)

Raporlardaki öneriler; **şimdi uygulanmayacak**. Kullanıcı mağaza ve gelir kararını verdiğinde yeniden bakılır.

- **Ücretsiz kalacaklar:** Bütün widget'lar ve bugünkü 1.203 kelime. Reklam hiçbir zaman (`Widget_Vocabulary_Analiz_ve_Plan.md` §5.2; `raporlar/14` §3).
- **Ücretli olabilecekler:** yeni desteler (ör. iş, seyahat genişlemesi), temalar, ek alıştırmalar.
- **Biçim:** Yıllık + 7 günlük deneme ve isteğe bağlı ömür boyu. **Haftalık plan yok** (Orbit şikâyetleri, `raporlar/02` §4a).
- **Fiyat çıpası (Ekim 2026):** Kolay İngilizce yıllık ₺299,99, ömür boyu ₺499,99 (`raporlar/14` §3). Planın eski önerisi yıllık ₺899,99 (`Plan` §9.2) bu çıpaya göre yüksek kalıyor.
- **Kurallar:** Kural 3.1.2 (başlık, süre, fiyat, yenileme, iptal, bağlantılar; deneme bitiş tarihi); TR'de fiyat artışı belirli eşiği geçerse abone onayı (`raporlar/05` §2). Small Business Program'da komisyon %15 (`raporlar/09` §1.5).
- **Yasal etki:** Abonelik gelince `docs/legal/` tam paketi (RevenueCat bölümleri, kullanım şartlarındaki abonelik metni) geri gelir; App Privacy etiketi Bölüm 2'ye döner.
