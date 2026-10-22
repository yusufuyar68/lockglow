# App/Resources

`content.sqlite` here is produced by the content pipeline and bundled into the app (read-only, opened straight from the bundle).

Current file: **personal build** (`content_version` `2026.10.22-kisisel-6`): 1068 A1–B1 everyday cards written in-session as drafts (`content/drafts/kisisel_v1/`, streams s0–s16) and checked by critic agents, all free, not reviewed by a human editor. The first 752 card JSONs were decoded with the Swift `CardDetail` on 2026-10-20 (752/752, every quiz has 4 distinct options); `en.smell.v.2` (added later the same day) has not been decoded in Swift yet. Rebuild it after editing the drafts:

```bash
cd content-pipeline
python -m vocabpipe.personal ../content/drafts/kisisel_v1 --out ../ios/App/Resources/content.sqlite --seed-out ../ios/Widgets/Resources/seed_words.json
```

A release build comes from reviewed cards instead (`python -m vocabpipe.build_db ../content/cards ...`, see `content-pipeline/README.md`). Card ids are permanent (`content-pipeline/data/id_registry.json`): keep that file, the app's learning progress is keyed by them.

Run `xcodegen generate` again after adding or replacing files so Xcode picks them up.
This README is excluded from the app bundle (see `project.yml`).
