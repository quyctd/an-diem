# App Store screenshots

Fully automated pipeline: real device captures with curated mock data → branded
marketing panels at App Store 6.9" size (1320×2868).

## One command

```sh
tools/screenshots/capture.sh   # build + boot sim → raw/<screen>.png
tools/screenshots/render.sh    # frame + headline → out/<N>-<screen>.png  ← upload these
```

`out/*.png` are the final images to drop into App Store Connect (6.9" slot; Apple
scales them down to cover 6.7"/6.5"). They're numbered `1-…` … `5-…` so Connect —
which sorts screenshots alphabetically by filename — lays them out in that order.

## How it works

1. **Capture** (`capture.sh`) builds Phorm, boots an **iPhone 17 Pro Max** sim
   (native 1320×2868), overrides the status bar to the clean 9:41 / full-wifi /
   100% state, then launches the app three times in **screenshot mode** — once per
   screen — and grabs a PNG each time. No UI tapping: the app routes straight to
   each screen.

2. **Screenshot mode** lives in `Phorm/Screenshots/ScreenshotSupport.swift` and is
   activated only by `SCREENSHOT=1` (passed via `SIMCTL_CHILD_*`). It swaps the
   CloudKit store for an in-memory store seeded with a story-shaped session
   (clear leader → ấn vàng, clear last seat → tem chéo) and renders the screen
   named by `SCREEN=session|summary|roundEntry`. Zero effect on normal builds.

3. **Render** (`render.sh`) draws `frame.html` — a Hà Nội cũ cream-paper panel with
   a cinnabar headline + gold seal — around each raw capture, via headless Chrome,
   at exactly 1320×2868.

## Tuning

- **Mock data / headlines:** edit the curated data in `ScreenshotSupport.swift`
  (players, `roundScores`, `roundEntryPrefill`) and the per-panel copy in the
  `PANELS` object in `frame.html`.
- **Add a screen:** add a `case` to `ScreenshotMode.Screen` + `ScreenshotRoot`,
  then add it to the `SCREENS` arrays in both scripts and a `PANELS` entry.
- **More device sizes:** change `DEVICE_TYPE` in `capture.sh` (e.g. a 6.5" Pro Max)
  — output dimensions follow the simulator automatically.

`raw/` = clean device captures · `out/` = framed marketing images · `.build/` =
throwaway derived data (gitignored).
