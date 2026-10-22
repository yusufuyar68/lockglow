# Lockglow kart yazımı: ortak kurallar (kisisel_v1, 2. tur, 2026-10-17)

Lockglow, Türkçe konuşan bir öğrencinin (seviyesi **A2 ve altı**, hedefi **günlük İngilizce**) iPhone kilit ekranında ve uygulamada gördüğü kelime kartlarını gösterir. Bu turda sana bir kelime listesi veriliyor. Her kelime için bir kart yazacaksın.

## Çalışma yeri (yalnızca burası)

- Depo kökü: bu deponun klasörü (Claude Code'un çalışma klasörü ya da onun geçici bir worktree'si)
- Kartlarını **yalnızca** sana verilen klasöre yaz: `content/drafts/kisisel_v1/<akış>/part_01.json`, `part_02.json`, … Her dosyada **10 kart**; sonuncu daha az olabilir.
- Başka hiçbir dosyayı değiştirme. `git commit`, `git push` ya da başka bir git yazma komutu çalıştırma. Paket kurma.

## Önce oku

1. Biçim örneği: `content/drafts/kisisel_v1/s1/part_01.json`. Dosya kabuğu aynı olsun: `{"schema_version": "1.0", "l1_langs": ["tr"], "generated_on": "2026-10-17", "entries": [...]}`.
2. Kalıp ifade örnekleri: `content/drafts/kisisel_v1/s2/` (`traffic jam`: `type: collocation`, `pos: phr`). Phrasal verb örnekleri: `content/drafts/kisisel_v1/s4/`.
3. Altın örnekler: `content-pipeline/data/gold_cards.json`.
4. Kurallar: `content-pipeline/vocabpipe/validate.py`. Uzunluk sınırları `LIMITS` içinde; örneğin `def.micro` en fazla 28, `tr.gloss` en fazla 28, `tr.gloss_short` en fazla 16 karakter.
5. Üretim kuralları, en güncel hâli: `git show pipeline/critic-quiz-backtranslation:content-pipeline/vocabpipe/prompts.py` (yalnızca oku). İçindeki `SYSTEM_A` kurallarına uy.
6. Var olan kartlar: önce listeyi üret: `python -I -X utf8 docs/icerik_uretimi/araclar/dump_lemmas.py content/drafts/kisisel_v1 mevcut_kelimeler.txt` (çıktıyı depoya koyma). Aynı kelimenin aynı anlamını tekrar yazma. Listende var olan bir kartla çakışan kelime görürsen atla ve raporda söyle.

## Kart alanları

- `id`: `en.<lemma>.<pos>.<sense_no>`. Boşluk yerine `_` kullan (`en.by_the_way.phr.1`).
- `meta`: `{"status": "draft", "qa_flags": [], "prompt_ver": "kisisel-2026-10-17", "model": "claude-sonnet (in-session subagent)", "source": "kisisel_v1"}`.
- `level`: listede verilen seviye, `level_source`: `editorial_estimate`, `freq`: `null`. Frekans uydurma.
- `pos`, `type`:
  - kelimeler `type: word`;
  - phrasal verb'ler `type: phrasal_verb`, `pos: phv`;
  - kalıp ifadeler `type: phrase` ya da `collocation` ya da `idiom`, `pos: phr` ya da `idm`. Doğrulayıcının kabul ettiği değerlere bak.
- **Anlam:** Çok anlamlı kelimede (get, have, keep, light…) listede yazan anlamı seç. Yazmıyorsa A2 öğrencisinin günlük hayatta en çok karşılaşacağı anlamı seç. `sense_note`'a kısaca yaz (ör. "receive", "become").
- `ipa.us` ve `ipa.uk`: eğik çizgiler arasında. Çok heceli kelimede vurgu işareti (ˈ) olsun. Tek heceli kelimede vurgu işareti olmasın.
- **Tanımlar:** `def.micro` en fazla 28 karakter, parantez yok. `def.short` en fazla 80, `def.long` en fazla 220 karakter. Hepsi A2 İngilizcesiyle olsun. Tanımda başlık kelimeyi kullanma.
- **Örnekler:** 3 örnek. Birincisi kısa, kendi başına anlaşılır ve kilit ekranında güvenle görünebilir olsun.
  - İsimler çeşitli olsun: Türkçe (Ayşe, Mehmet, Elif…) ve uluslararası. Hep aynı isimleri kullanma.
  - Her örnekte `tr` çevirisi olsun. Çeviri doğal Türkçe olsun ve İngilizcede olmayan bilgi eklemesin. Kartın kelimesinin karşılığı çeviride görünsün.
- `l1.tr.gloss`: en yaygın, gerçek Türkçe karşılık. `alt`: gerçek başka karşılıklar; açıklama cümlesi yazma.
- `l1.tr.gloss_short`: yalnızca `gloss` 16 karakteri geçince yaz (doğrulayıcı ister). Kilit ekranında 16–18 karakter sığıyor ve anlam hiçbir zaman "…" ile kesilmiyor; sığmazsa bu kısa biçim görünür.
  - En çok 16 karakter (boşluklar dahil). Tam, doğal bir Türkçe karşılık olsun: kesilmiş söz, "…", kısaltma, parantez yok.
  - Kartın anlamını korusun; olumsuzluğu kaybetmesin (disagree → "hemfikir olmamak", "hemfikir olmak" değil).
  - Önce `alt`'a bak: 16 karakteri geçmeyen, doğru ve doğal bir aday varsa onu seç. Yoksa `gloss`'un ilk virgülden önceki kısmını ya da yeni bir kısa karşılık yaz ("biraz rahatsız olmak" → "biraz rahatsız").
  - Fiilde ve phrasal verb'de `-mek/-mak` ile bitsin. Tek başına okununca başka anlama kaymasın ("katılmak" "join" gibi okunur; agree için "hemfikir olmak").
- `confusables`: öğrencinin bu kelimeyle **gerçekten** karıştırdığı İngilizce kelimeler, en çok 3 (ör. borrow → `["lend"]`). Yoksa alanı hiç yazma.
  - Ölçüt: Türkçede aynı karşılık (say/tell → söylemek, make/do → yapmak), yazılışı ya da sesi benzer (receipt/recipe, quiet/quite), sahte dost (actually ↔ currently) ya da bilinen kullanım farkı (bored/boring, already/yet). Düz eş anlamlı, aynı konudan kelime ya da basit zıt anlamlı **değildir**.
  - Eş destede kart olarak varsa lemma'sını aynen yaz ve o kartın `confusables`'ına da bu kelimeyi ekle (iki yönlü). Eski `tags.flags` içindeki `confusable:<kelime>` biçimini kullanma.
- `tags.sensitivity`: varsayılan `0`. Kart kişisel bir konudaysa `1` yap: romantik ilişki ya da ayrılık (ex, crush, divorce, break up), utandırıcı beden ya da sağlık konusu (throw up), alkol, kaba kelime, işini ya da parasını kaybetmek (get fired, broke). Bu kartlar kilit ekranında ve orta widget'ta varsayılan olarak gösterilmez; aile ya da iş arkadaşı kilit ekranını görebilir. Akış'ta ve Tekrar'da kalırlar. Sıradan aile, sağlık, para ve duygu kelimeleri `0`'dır. Yalnızca ilk örnek kişiselse önce başka bir örneği başa almayı düşün.
- `l1.tr.mistakes`: **yalnızca Türkçe konuşanların gerçekten yaptığı** hatalar. Hata yoksa boş liste. Uydurma hata, kötü bir karttan daha kötüdür.
  - Tipik gerçek hatalar: "I am agree", "I am understand", "Can you say me", "How many money", "an information", "informations", "advices", "news are", "I have 25 years old", "make a photo", "close the light", "open the TV", "since 3 years".
  - `why` alanı Türkçenin nasıl yanılttığını anlatsın.
- `l1.tr.note`: kısa ve yararlı bir Türkçe not; yoksa `null`.
  - **Yazım kuralı:** İngilizce bir sözcükten sonra eki ayrı yazma ('freezer' dır, 'host' tur YASAK). Cümleyi ekleme gerek kalmayacak biçimde kur: "… 'host' denir", "… 'host' olur".
- `quiz`:
  - Boşluklu cümle `______` (6 alt çizgi) içersin ve boşluğa **tek bir doğru cevap** gelsin.
  - Çeldiriciler aynı türden ve akla yatkın olsun, ama o cümlede **açıkça yanlış** olsun. Çeldiricilerden biri de doğru sayılabiliyorsa cümleyi değiştir.
  - Cevap cümlenin içinde geçmesin.
  - Cevap başlık kelimenin bağlama uyan biçimi olabilir: "got", "children".
- `etymology`: yalnızca emin olduğun gerçek köken (`confidence: high` ya da `medium`). Emin değilsen ya da kalıp ifadeyse `null`. Halk etimolojisi yazma.
- `tags.primary_topic`: `content-pipeline/data/taxonomy.json` içindeki gerçek bir kategori ID'si olsun.
- `false_friend`: yalnızca Türkçe için gerçek sahte dostlarda doldur (sympathetic ≠ sempatik, actually ≠ aktüel gibi; library Türkçe için sahte dost değildir). Değilse `null`.

## Bitirmeden önce

Şunu çalıştır ve **0 hata · 0 uyarı** görene kadar düzelt:

```
cd <depo kökü>/content-pipeline
python -m vocabpipe.validate --strict ../content/drafts/kisisel_v1/<akış>
```

Ardından kartlarını bir kez daha baştan sona oku. A2 öğrencisinin gözüyle bak: Türkçe doğal mı, örnekler gerçek hayattan mı, quiz tek cevaplı mı?

## Rapor (son mesajın)

Kısa tut:
- kaç kart yazdın;
- atladığın kelimeler ve nedenleri;
- doğrulayıcı sonucu (son satırı aynen);
- emin olmadığın 3–5 madde (ör. bir IPA, bir Türkçe karşılık).
