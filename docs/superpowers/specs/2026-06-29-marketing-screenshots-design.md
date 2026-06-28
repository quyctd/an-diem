# Marketing screenshot pipeline (ichi-style) — design

Date: 2026-06-29
Status: Approved, ready for implementation plan

## Problem

App Store marketing screenshots are currently built by `submission/screenshots.html`
— a hand-rebuilt HTML/CSS reconstruction of the app's UI rendered to PNG. It is bad:

- **Not real.** It re-draws the screens by hand, so it drifts from the actual app and
  must be maintained separately from the SwiftUI code.
- **Muddy composition.** A small CSS "phone" floats in a large oxblood field —
  dark-red device on dark-red background, low contrast, wasted space.
- **Crude frame.** The device is a CSS gradient box with a fake dynamic island, not a
  real hardware render.

The sibling project `ichi` (`/Users/dinhquy/Documents/quyctd/ichi/marketing/`) solves
this well: real simulator screenshots composited into a real iPhone device render with a
clean captioned card, via a small Pillow script (`compose_listing.py`). This spec adapts
that pipeline to Phorm.

## Goal

Replace the HTML mockup with a reproducible pipeline that frames **real screenshots of
the actual app** (the build-8 lacquer/serif design) into App Store listing frames.

Non-goals: changing the app's visual design; reconciling CLAUDE.md (which currently
describes the later tactile design) with the reverted lacquer code — flagged separately.

## Locked decisions

- **Pipeline model:** real sim screenshots → Pillow compositor → real device frame.
  Mirror ichi's structure and `compose_listing.py` engine.
- **Capture:** fully autonomous (no hand-driving the SwiftUI UI). Reach each screen via
  DEBUG-only launch hooks added to the app.
- **Card:** cream `#F3E8D2` background; headline lead = cinnabar-deep `#5A1612` ink,
  accent = gold `#D9B25A`. Dark-red device pops against light cream.
- **Headline face:** Noto Serif Display (the brand display serif), vendored into the
  marketing folder — matches the lacquer app, unlike ichi's SF.
- **Device frame:** Black Titanium iPhone 16 Pro (reused from ichi).
- **Six frames, hero = leaderboard.**

## Layout / file structure

New `andiem-ios/marketing/` (mirrors ichi):

```
andiem-ios/marketing/
  raw/                     real sim screenshots (6 PNGs), the compositor input
  frames/                  real iPhone 16 Pro render (Black Titanium, transparent screen)
  fonts/                   vendored Noto Serif Display (.ttf) for the captions
  listing/iphone-6.9/      final 1290×2796 (App Store primary set)
  listing/iphone-6.5/      final 1242×2688 (completeness)
  contact-sheet.png        all six at a glance
  compose_listing.py       Pillow compositor
  README.md                regenerate + recapture instructions
```

The old `submission/screenshots.html` and `submission/screenshots/` are retired —
deleted after the new output is confirmed good.

## Component 1 — DEBUG screenshot hooks (app source)

New file `Phorm/Logic/ScreenshotSupport.swift`, entirely under `#if DEBUG`. No effect on
release builds.

**Seeding (`PHORM_SEED=demo`):**
- Read in `PhormApp.init`. When set, build the `ModelContainer` with
  `isStoredInMemoryOnly: true` (and no CloudKit) instead of the persistent store, then
  insert a curated demo dataset:
  - One active session: players `Quý · Nam · Linh · Hoàng`, ~6 rounds with realistic
    per-round scores producing a clear leader (ấn vàng) and last place. Name e.g.
    "Phỏm tối thứ Sáu".
  - A few archived sessions (varied names, dates, player counts) so History looks lived-in.
- Demo data is deterministic (fixed values, no randomness) so screenshots are stable.

**Routing (`PHORM_OPEN=<screen>`):**
- Values: `leaderboard` (default populated SessionView), `roundEntry`, `summary`,
  `history`, `newSession`, `empty`.
- A single DEBUG entry point reads the env once and exposes the requested target. The
  relevant container views (SessionView, EmptyHomeView) gain a DEBUG-only `.onAppear`
  hook that auto-presents the target sheet/destination when it matches. `empty` forces
  the empty-home path (no seeded active session); `newSession` opens the New Session
  sheet from empty-home.
- Keep all env reading in `ScreenshotSupport.swift`; views call into it, so the hook
  surface in each view is one guarded line.

Touched app files: `PhormApp.swift` (container selection + initial route), `SessionView.swift`
and `EmptyHomeView.swift` (one guarded appear-hook each), new `ScreenshotSupport.swift`.

## Component 2 — capture (script / driver)

Captures run on an **iPhone 16 Pro** simulator (screen 1206×2622) to match the reused
frame's screen cutout. For each of the six screens:

1. Boot the sim; build + install the DEBUG app once.
2. `xcrun simctl status_bar <udid> override --time "9:41" --batteryState charged
   --batteryLevel 100 --cellularBars 4 --wifiBars 3`.
3. `SIMCTL_CHILD_PHORM_SEED=demo SIMCTL_CHILD_PHORM_OPEN=<screen> xcrun simctl launch <udid> com.quyctd.phorm`
   (terminate between shots so each launch routes fresh).
4. Brief settle, then `xcrun simctl io <udid> screenshot raw/<NN-name>.png`.

This is wrapped in a script (extend the existing `andiem-ios/tools/capture-screenshots.sh`
or a new `marketing/capture.sh`) so the full set regenerates with one command. The
`empty` shot needs no seed (or a seed variant with no active session).

## Component 3 — compositor (`compose_listing.py`)

Adapted from ichi's script (same Pillow engine). Per frame:

1. Resize the raw screenshot to the frame's screen cutout, round its corners to the screen
   radius, paste it *behind* the device PNG so the titanium body masks the corners.
2. Soft Gaussian drop shadow from the device silhouette.
3. Draw the two-tone serif headline (lead in cinnabar-deep ink, accent in gold), left
   aligned, auto-sized so each line fits one line within the margins.
4. Device large and centered, bleeding off the bottom edge.
5. Save 6.9" (1290×2796) and a 6.5" (1242×2688) downscale.

Then assemble `contact-sheet.png` (all six in a row).

Constants adapted from ichi: `BG=#F3E8D2`, `INK=#5A1612`, `POP=#D9B25A`,
`FRAME_FILE="Apple iPhone 16 Pro Black Titanium.png"`, `SCREEN_BOX=(72,70,1276,2690)`,
`SCREEN_R=96`. Headline font loaded from `fonts/` (Noto Serif Display) instead of SFNS.

## Frames (content)

Hero first. Two-tone Vietnamese captions:

| #  | Screen / PHORM_OPEN        | Lead (ink)    | Accent (gold)         |
|----|----------------------------|---------------|-----------------------|
| 01 | leaderboard (hero)         | Ấn vàng       | cho người dẫn đầu.    |
| 02 | roundEntry                 | N−1 ô số.     | Ô cuối tự cộng.       |
| 03 | summary                    | Kết bàn.      | Lưu lại.              |
| 04 | history                    | Mọi phiên cũ  | vẫn ở chỗ cũ.         |
| 05 | newSession                 | Đặt tên.      | Vào bàn ngay.         |
| 06 | empty                      | Mở app        | là chơi.              |

## Success criteria

- `python3 marketing/compose_listing.py` regenerates all six 6.9" + 6.5" frames and the
  contact sheet from `raw/` with no manual editing.
- The capture step produces all six `raw/*.png` autonomously (no hand-driving), status
  bar reading 9:41, seeded demo data visible.
- Final frames: real device render, cream card, dark-red screenshots clearly legible,
  serif two-tone headlines, device bleeding off the bottom — visually comparable to
  ichi's contact sheet.
- Release builds are unaffected by the DEBUG hooks (verify the seed/open code is excluded).

## Open follow-up (out of scope)

CLAUDE.md still describes the tactile design; the code is now lacquer (post-revert). Sync
later if desired.
