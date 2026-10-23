# Hazır ses kayıtları (akıcı İngilizce)

"Dinle" düğmesi önce uygulamanın içindeki **hazır kayda** bakar. Kayıt bir yapay zekâ ses servisiyle bir kez üretilir, uygulamaya girer, telefonda internetsiz çalar. Kaydı olmayan metni (kendi eklediğin kelimeler, yeni kartlar) telefonun kendi sesi okur.

- **Ses karakteri:** Ayarlar → Ses ve aksan → Ses karakteri: **Kadın** ya da **Erkek**. Hazır kayıt bu karakterle çalar; telefon sesi de bu karakterdeki en iyi sesi seçer.
- Ses listesinden adıyla bir telefon sesi seçersen (ör. Ava) hazır kayıt yerine o ses okur. **Otomatik**'e dönünce hazır kayıt geri gelir.
- İngiltere aksanı seçiliyse ve o aksanın kaydı yoksa telefonun İngiltere sesi okur.

## Kayıtları üretmek

Kod: `content-pipeline/vocabpipe/recorded_speech.py`. Çıktı: `ios/App/Resources/RecordedSpeech/`.

1. **Anahtarı al (sen yaparsın).** OpenAI: platform.openai.com → API keys. Hesaba birkaç dolar bakiye yükle. Anahtarı hiçbir dosyaya yazma, depoya koyma.
2. **ffmpeg kur** (dosyaları küçültür; yoksa uygulama ~2,5 kat büyür):

   ```bash
   winget install Gyan.FFmpeg
   ```
3. **Önce maliyete bak** (servise gitmez):

   ```bash
   cd content-pipeline && python -X utf8 -m vocabpipe.recorded_speech --dry-run
   ```
   Bugünkü içerik: 5624 metin x 2 ses, ~6 $, uygulamaya ~80 MB (ffmpeg ile).
4. **Deneme:** 20 metinle dene, sesleri dinle. Anahtarı yalnız bu pencere için ver (PowerShell): `$env:OPENAI_API_KEY = "..."`, sonra:

   ```bash
   cd content-pipeline && python -X utf8 -m vocabpipe.recorded_speech --limit 20
   ```
5. **Hepsi:** aynı komut, `--limit` olmadan. Yarıda kalırsa yeniden çalıştır; biten kayıtları atlar.
6. Mac'te `xcodegen generate`, sonra derle.

## Seçenekler

- `--provider google`: Google Cloud Text-to-Speech (Chirp 3 HD sesleri). ABD **ve** İngiltere aksanı verir (`--accents us uk`). Anahtar `GOOGLE_TTS_API_KEY`. Kurulumu daha uzun: proje, faturalandırma ve API'yi açmak gerekir.
- `--kinds lemma example pair collocation mistake`: kalıpları ve "doğrusu" cümlelerini de seslendirir (uygulama ~40 MB daha büyür).
- Sesler: OpenAI kadın **nova**, erkek **onyx**; Google kadın **Aoede**, erkek **Charon**. Değiştirmek için betikteki `VOICES`'a bak. Ses değiştirirsen o sesin klasörünü (`RecordedSpeech/us-female/`) silip yeniden üret.
- Kart metni değişirse yalnız yeni metinler üretilir; eski dosyalar kalır (zararsız, yer kaplar). Temizlemek için klasörü silip yeniden üret.

## Bilmen gerekenler

- OpenAI kuralları, sesin yapay zekâ ile üretildiğinin kullanıcıya söylenmesini istiyor. Mağaza açıklamasına ya da Ayarlar'a "Sesler yapay zekâ ile üretildi" notu eklenmeli (henüz eklenmedi).
- Kayıt dosyası türk isimlerini (Ayşe, Çağla) servis nasıl okursa öyle okur; telefon sesindeki özel okunuş kuralları (`SpeechText`) kayıtlarda yok.
- Cihazda denenmedi: kaydın çalması, hızın (Yavaş/Normal/Hızlı) kayda uygulanması, widget hoparlörünün kaydı çalması.
