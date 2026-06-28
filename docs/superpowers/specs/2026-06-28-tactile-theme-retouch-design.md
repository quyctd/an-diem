# Tactile theme retouch — design

**Date:** 2026-06-28
**Scope:** `andiem-ios/` SwiftUI app — all in-app screens + the share/stamp flow.
**Goal:** Finish the half-done migration from the retired dark "lacquer/cinnabar" register to the **tactile / playful** warm system (`tc-` section of `themes-preview.html`, codified in `DESIGN.md`). Token *values* were already swapped; the view layer still encodes dark-surface assumptions and renders muddy on the warm cream day surface.

## Problem

The redesign swapped color-token values to the warm system (cream day / deep-warm night, Tết-red + gold, color-filled chips) but left view-level styling in the old lacquer idiom. The same anti-patterns repeat across nearly every screen:

1. **`Color.black.opacity(0.18)` as card/tile fill** — designed to darken a dark lacquer surface; on warm cream it renders as dead taupe-gray. Affects `RoundCard`, `HistoryRow`, `ImportConfirmView`, the SessionView recent strip, `NewSessionView` cards, and the stamp sheets. This is the most visible defect (the gray "Một vòng" strip and "Từng vòng" card in the reference screenshot).
2. **`Color.phormCream.opacity(…)` strokes/fills** — `phormCream` resolves to *primary ink* (dark on day). Using it at low opacity for hairlines/strokes assumes a light-on-dark surface; on day it's a faint dark smudge instead of the intended subtle divider. There is already a correct `hairline` adaptive asset that should be used instead.
3. **Sharp `cornerRadius: 3/4` everywhere** — the terminal/lacquer register. The tactile language is rounded: chips 11–16, cards 12–16, keys 11–14, buttons 13.
4. **CTA gradients fade to `phormSurfaceCinnabarDeep`** (dark oxblood) — reads as a reddish-brown bruise creeping up from the bottom of a cream screen. Should fade to the surface color so the CTA floats cleanly.
5. **Depth via black overlays instead of soft shadows + bevels** — the tactile system gets depth from `inset bottom-bevel + soft drop shadow` (chips/coins/keys) and `0 4px 0 ridge` (keys/buttons), not from darkening overlays.
6. **Misleading `Lacquer*` names** — `LacquerBackground`, `LacquerPrimaryButton`, `LacquerHairline`, `lacquerBackground()`, plus "cinnabar/lacquer" doc comments. The lacquer register is explicitly retired in `PRODUCT.md`; the names now mislead.

## Canonical values (from `themes-preview.html` `tc-`)

These are the target treatments. Day values listed; night variants in parentheses where they diverge.

**Score chip** (`.tc-chip`)
- radius: 14 (lg 16, sm 11)
- up fill `#21BD73`, shadow `inset 0 -3px 0 #0F8A48, 0 4px 14px rgba(33,189,115,.30), 0 2px 4px rgba(0,0,0,.12)`
- down fill `#FF6B3D`, shadow `inset 0 -3px 0 #CC451C, 0 4px 14px rgba(255,107,61,.30), 0 2px 4px rgba(0,0,0,.12)`
- neutral fill `#ECE4D6`, text `#8B7969`, shadow `inset 0 -3px 0 #BEB09A, 0 2px 6px rgba(0,0,0,.07)` (night `#3A2724` / text `#9A7F6F` / bevel `#211510`)
- focus ring: surface-gap then accent ring — `0 0 0 2.5px <surface>, 0 0 0 5px <accent>` (accent = Tết-red day, gold night)

**Coin** (`.tc-coin`)
- seat day: fill `#EDE1CE`, text `#8B7969`, `inset 0 -2px 0 #C0AC90, 0 1px 3px rgba(0,0,0,.10)` (night fill `#352420` / text `#9A7F6F` / bevel `#1C1009`)
- gold: `linear-gradient(135deg, #FFD761, #F2B829 55%, #C8920D)`, text `#4A2800`
- active (focused row): `box-shadow 0 0 0 2px <accent>, inset 0 -2px 0 <seat-bevel>` over surface-root fill
- last/bét marker: fill `#F5E6E0`, text `#C04018`, bevel `#D9BFBA`, glyph `×`
- sizes: lg 36 (40 for champion), sm 26

**Key** (`.tc-key`)
- radius 11, gradient `#FFFBF3 → #EDE0CC`, ridge `0 4px 0 #BCAD95, 0 1px 2px rgba(0,0,0,.08)`; press = `translateY(3px)` + ridge → `0 1px 0`
- sign key day: gradient `#FFF0E0 → #F0D8B8`, text `#C13020`, ridge `#BF9060` (night gradient `#3D2418 → #2C1508`, text gold, ridge `#140700`)
- delete key: same face as digit, muted glyph `#9A8472`
- night digit face: gradient `#352520 → #291810`, ridge `#110806`

**Primary button** (`.tc-btn`)
- day: fill `#E5483A` (Tết-red), white text, radius 13, height 44–52, `inset 0 -3px 0 #B42C1E` bottom bevel; press `translateY(3px)`
- night: fill gold `#F2B829`, ink text `#2A1800`
- outline (secondary): transparent fill, accent border, accent text, radius 13

**Active row card** (`.tc-row-active`)
- fill `#FFFBF3`, radius 16, `0 2px 16px rgba(0,0,0,.07), 0 0 0 1px rgba(0,0,0,.04)` (night translucent white + stronger shadow)
- inactive rows: no card, just padding (used in round-entry list)

**Summary row** (`.tc-sum-row`): fill `#FFFBF3`, radius 12, `0 1px 6px rgba(0,0,0,.05)`. Winner: radius 14, `0 0 0 2px #F2B829, 0 4px 20px rgba(242,184,41,.22)`.

**Round badge** (header): Tết-red (day) / gold (night) rounded box, radius 10, `inset 0 -2px 0 <deep>, 0 2px 6px <accent glow>`, uppercase "VÒNG" caption + tabular count.

**Status pill** (`.tc-pill`): capsule. ok = green-tint fill + green text + green border; warn = coral-tint; neutral = panel fill + muted border.

## Approach

**Centralize the tactile language in the design system, then migrate screens to consume it.** This matches CLAUDE.md's "single source of truth" rule and keeps the per-screen diffs small and consistent. Three layers:

### Layer 1 — Color foundation (`DesignSystem/Color+Tokens.swift` + Assets)

Add adaptive colorset assets for the day/night-divergent tactile colors (those that can't be derived cleanly):
- `KeyFaceTop`, `KeyFaceBottom`, `KeyRidge` — digit/delete key gradient + ridge
- `KeySignFaceTop`, `KeySignFaceBottom`, `KeySignRidge`, `KeySignInk` — sign key
- `CoinSeat`, `CoinSeatBevel` — neutral coin
- `ChipNeutralBevel` — neutral chip bottom-bevel
- `CardShadowInk` — soft shadow color (low-alpha black day, deeper night)

Chip up/down bevels (`#0F8A48`, `#CC451C`) and gold-coin gradient stops are fixed across appearances → keep as code constants on `Color`. Add named constants for all of these so no raw hex/`black.opacity` literals remain in views.

Add the missing semantic constants the views need: `Color.cardSurface` (→ `SurfaceCard`), and confirm `surfaceTile`, `chipNeutral`, `hairline`, `surfaceSoft`, `focusRowTint` are wired.

### Layer 2 — Tactile primitives (design system components + modifiers)

- **`tactileCard()` View modifier** — `surfaceCard` fill, radius 14 (param), soft drop shadow (`CardShadowInk`), 1px hairline ring. Replaces every `black.opacity(0.18)` card background. Used by `RoundCard`, `HistoryRow`, `ImportConfirmView`, summary rows, recent-strip container.
- **`ScoreChip`** — update to exact `tc-chip` treatment: radius 11/14/16 by size, inset bottom-bevel overlay (color-matched), colored glow + soft drop shadow, neutral text `#8B7969`, focus ring = surface-gap + accent ring. Keep the existing API (`value`, `size`, `isFocused`).
- **`Coin`** — update `seat`/`winner`/`last` to `tc-coin` values (seat fill+bevel, gold 135° gradient, last `×` marker), add an `active` focus-ring treatment used by the round-entry focused row.
- **`Keypad` / `TactileKey`** — give keys the warm gradient face + `KeyRidge` ridge (currently flat `surfaceTile` + cold `black.opacity(0.25)`); restyle the sign key to the light face + red/gold glyph per mockup; restyle the "Tiếp" secondary key to the tactile outline (radius 11, no cream-opacity stroke).
- **Rename `Lacquer*` → tactile/neutral names** (mechanical, compiler-verified):
  - `LacquerPrimaryButton` → `TactilePrimaryButton` (radius 13, press `translateY` + inset bevel)
  - `LacquerOutlineButton` → `TactileOutlineButton` (radius 13)
  - `LacquerHairline` → `Hairline` (use `hairline` asset, not cream-opacity)
  - `LacquerThickRule` → `GoldRule` (the summary divider becomes the gold gradient rule from the mockup)
  - `LacquerBackground` / `lacquerBackground()` → `AppBackground` / `appBackground()`
  - `SectionLabel`, `ScoreFormat` unchanged.
- **New `RoundBadge`** — the header round-count badge (Tết-red/gold raised box). Used by SessionView + RoundEntryView headers.
- **New `StatusPill`** — capsule with `.ok` / `.warn` / `.neutral` styles. Replaces RoundEntryView's ad-hoc validation pill; available for the round-entry "Tổng" status.

### Layer 3 — Per-screen migration

Each screen swaps to the primitives above and drops the lacquer-era literals.

- **SessionView** (leaderboard, the reference screenshot): header round count → `RoundBadge`; leader (rank 1) row → active `tactileCard` with raised treatment, runners as plain rows (mirrors mockup hierarchy); recent strip → small color-filled chips on a `tactileCard`, not gray boxes; "Từng vòng" cards via `RoundCard` (now `tactileCard`); CTA gradient fades to surface (`canvas`) not cinnabarDeep.
- **RoundEntryView**: close button bg → `surfaceSoft`/tactile, not `black.opacity`; focused-row card → `tactileCard`/active treatment; validation pill → `StatusPill`; bottom dock hairline → `hairline`; background/presentationBackground → surface token; title subtitle ink → `phormCreamDim` not `phormCream.opacity`.
- **SummaryView**: thick rule → `GoldRule`; champion + runners → `tc-sum-winner`/`tc-sum-row` cards; last-place marker → coin `×` style; Đóng dấu callouts → rounded radius (13) + correct tint/stroke (drop sharp 3pt + cream-opacity); CTA buttons → `Tactile*`; CTA fade to surface.
- **NewSessionView**: all `black.opacity(0.18)` card/field fills → `tactileCard`/`surfaceTile`; field strokes → `hairline`/focus accent; player chips/add-row tactile; primary button + CTA fade.
- **HistoryView / HistoryRow**: `LacquerHairline` → `Hairline`; row → `tactileCard` (drop black overlay + cream-opacity stroke + sharp radius).
- **EmptyHomeView**: button → `Tactile*`; `phormCream.opacity` body → `phormCreamDim`; background rename.
- **ImportConfirmView**: card → `tactileCard`; hairline + button + radius cleanup.
- **SplashView / Seal**: background rename; update "cinnabar lacquer" comment; Seal radius/treatment to match (Seal is largely superseded by Coin — keep but de-lacquer).
- **Stamp flow** (`StampSourcePicker`, `StampEditorView`, `StampOnPhotoView`, `ShareCardView`):
  - `StampSourcePicker` (bottom sheet): options → `tactileCard`/tactile rows, drop black-overlay + cream-opacity + sharp radius.
  - `StampEditorView` (editor chrome): toolbar buttons/cards → tactile; the **photo-composite layers** (`StampOnPhotoView` seal/cross over the user's photo) keep their dark drop-shadows — those sit on an arbitrary photo, not the app surface, so high-contrast shadows are correct. Only the surrounding editor chrome gets retouched.
  - `ShareCardView`: this is a **deliberately composed dark share artifact** (oxblood ground) — its darkness is intentional and stays. Retouch only for internal consistency with the tactile chip/coin language (chips/coins on the card adopt the updated `tc-` treatment), keeping the dark oxblood ground. No conversion to cream.

## Out of scope

- No layout/IA restructuring beyond what the tactile hierarchy implies (leader-as-card). No new screens, no copy changes (Vietnamese strings unchanged), no logic changes.
- No change to the `ShareCardView` dark ground or the photo-composite shadow treatment.
- No Dynamic Type / a11y regressions — keep `.monospacedDigit()`, sign prefixes, and contrast tokens intact.

## Verification

- `xcodebuild` (per `andiem-ios-build-setup` memory: trust xcodebuild over SourceKit) compiles clean after each layer.
- Existing `PhormTests` (Totals, AutoFill, SessionShare, SessionActions, SealGlyph) still pass — this is a view-layer change; logic untouched.
- Visual confirmation deferred to the user (build + look); the `tc-` mockup is the pixel reference.
- Manual sweep: grep shows zero remaining `Color.black.opacity` card fills and zero `phormCream.opacity` strokes in non-photo views; zero `Lacquer*` symbols; CTA gradients reference surface tokens.

## Risk / sequencing

Foundation → primitives → screens, so the compiler guides the migration (renames break callsites loudly). Screens are independent after the primitives land, enabling incremental review. Lowest-risk first (Session/RoundEntry/Summary — the core loop), then the rest, then the stamp flow last (most isolated).
