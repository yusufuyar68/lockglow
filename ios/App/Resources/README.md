# App/Resources

`content.sqlite` here is produced by the content pipeline and bundled into the app (read-only, opened straight from the bundle).

Current file: **personal build** (`content_version` `2026.10.26-kisisel-15`): 1,983 A1–B2 everyday cards (A1 192, A2 580, B1 611, B2 600) written in-session as drafts (`content/drafts/kisisel_v1/`, streams s0–s32) and checked by critic agents, all free, not reviewed by a human editor. The first 752 card JSONs were decoded with the Swift `CardDetail` on 2026-10-20 (752/752, every quiz has 4 distinct options); `en.smell.v.2` (added later the same day) has not been decoded in Swift yet. Rebuild it after editing the drafts:

```bash
cd content-pipeline
python -m vocabpipe.personal ../content/drafts/kisisel_v1 --out ../ios/App/Resources/content.sqlite --seed-out ../ios/Widgets/Resources/seed_words.json --content-version 2026.10.26-kisisel-15
```

A release build comes from reviewed cards instead (`python -m vocabpipe.build_db ../content/cards ...`, see `content-pipeline/README.md`). Card ids are permanent (`content-pipeline/data/id_registry.json`): keep that file, the app's learning progress is keyed by them.

`RecordedSpeech/` holds the recorded clips of "Dinle" (one folder per voice, `voices.json` lists them), made by `python -X utf8 -m vocabpipe.recorded_speech` (see `docs/ses_kaydi.md`). It is bundled as one folder reference (`project.yml`). With no clips (`voices.json` empty) the device's voice reads everything.

Run `xcodegen generate` again after adding or replacing files so Xcode picks them up.
This README is excluded from the app bundle (see `project.yml`).
