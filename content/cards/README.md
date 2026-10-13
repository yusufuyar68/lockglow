# Onaylı kartlar

Bu klasördeki her dosya editör onayından geçmiş bir karttır (status: reviewed/approved).
Yalnızca `python -m vocabpipe.review apply` ile eklenir. Uygulama veritabanı buradan derlenir:

```bash
cd content-pipeline
python -m vocabpipe.build_db ../content/cards --out build/content.sqlite --seed-out build/seed_words.json
```
