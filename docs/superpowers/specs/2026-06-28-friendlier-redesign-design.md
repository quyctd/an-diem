# An Điểm — Friendlier Redesign (contrast + plain wording)

**Date:** 2026-06-28
**Status:** Approved design — TACTILE/PLAYFUL revision is authoritative (see top section)
**Scope:** Live-app feedback fix — color contrast is hard to follow, and the literary
terms "Ấn vàng" / "Tem cuối bàn" / "Vô địch ván" aren't clear for normal play.

---

## ⭐ AUTHORITATIVE REVISION (2026-06-28): Tactile / Playful direction

After reviewing the dual-surface + plain-wording mockup, the user widened the goal twice:
(1) fix font + sizing because the **input was hard to focus on**, then (2) the design felt
like **"reading a page, not playing"** — so the final, approved direction is **tactile and
brightened**: score entry should feel like **placing physical pieces on a card table**.

**This revision supersedes sections A, G, and H below** (the restrained two-surface palette,
the text-color-only score rule, and the dim-only focus treatment). Sections B (plain wording),
C (legible seals — now coins), D (preview-first), E (docs), and F (clean sans) still hold.

**The canonical visual contract is the `TACTILE / PLAYFUL DIRECTION` section at the top of
`themes-preview.html`** (CSS prefix `tc-`, frames T1–T4). Exact colors, radii, shadows, and
sizes live there — implementers read values from it; this spec captures the decisions.

### Intentional anti-reference overrides
PRODUCT.md previously forbade colored score fills ("score color is text only, never card
fill"), confetti/game energy, and a louder register. The user has explicitly steered past
the first and the restraint. Still rejected: mascots, confetti, emoji, 🎉-style copy. Playful
comes from **material depth + motion + color pops**, not cartoon.

### Tactile system (authoritative)
- **Bright palette (both appearances).** Day: bg `#FBF4E6`, tile `#FFFBF3`, ink `#2A211C`.
  Night: bg `#241715`, ink/cream `#F6ECDA`. Brand accent (Tết-red) `#E5483A`; gold (winner /
  special) `#F2B829`. Lacquer halftone/grain texture is **retired** on the core screens —
  depth now comes from chip/key shadows, not surface noise.
- **Score chips are COLOR-FILLED tiles** (overrides text-only rule): up `#21BD73`, down
  `#FF6B3D`, neutral/zero `#ECE4D6` (day). White bold tabular number. **Always keep the
  explicit `+`/`−` sign prefix** (color-blind safety preserved via sign + the chip itself).
  Chip = rounded-rect (r≈14px), solid fill, `inset 0 -3px` bottom-bevel band + soft drop
  shadow → reads as a physical piece.
- **Active-row dominance:** focused player's chip ≈1.4× (`tc-chip-lg`) with a bright focus
  ring, elevated on a white card; inactive rows ~0.40 opacity, smaller chip — no layout
  collapse. Replaces section G's dim-only treatment.
- **Keypad = tactile 3D keys:** gradient face + `box-shadow: 0 4px 0` bottom ridge; press =
  `translateY(3px)` + ridge shrink (in-app: pair with existing `Haptics`). Sign-toggle key
  uses the brand accent. Confirm CTA gets the same 3D bottom edge.
- **Seat marker = round coin token** (Arabic seat number); winner = gold coin, champion row
  framed gold. Last place = muted coin (coral), not an aggressive ×.
- **"Tổng" = a rounded pill badge**, state-aware (balanced green "cân" / unbalanced orange ⚠).
- Type: clean sans (Inter target / system SF Pro fallback), `tabular-nums` on all numbers.

Everything below this section is retained for rationale/history; where it disagrees with this
revision or with the `tc-` mockup, **this revision and the mockup win.**

---

## Problem

The shipped app (v1.0.2) drenches every screen in a single saturated cinnabar lacquer
surface and labels the winner/last-place with print-register Vietnamese ("Ấn vàng",
"Tem cuối bàn", "Vô địch ván") plus Hán-numeral seals (壹/封/× cross). Real users report:

1. **Contrast is hard to follow.** Cream/gold/mint text rides a textured mid-red surface
   at 4–5:1. The worst offenders: ochre-negative scores at **4.02:1** (AA *large-only*) and
   gold at **4.27:1** (display-only). In the target setting — low light, split attention,
   one tired scribe between rounds — those thin margins read as illegible.
2. **Terminology isn't clear for normal play.** "Ấn vàng" (gold seal), "Tem cuối bàn"
   (last-place stamp), "Vô địch ván" (champion of the round) are poetic, not table talk.
   The Hán seal glyphs (壹/封) are opaque to a Vietnamese player — 壹 doesn't read as "1st".

## Decisions (locked via brainstorming)

- **Scope:** Open rethink — the drenched-lacquer-everywhere direction is itself the root
  cause and is up for change. Both contrast and terminology are real blockers.
- **Surface:** Light by day, lacquer by night. Calm warm-paper everyday canvas; deep
  cinnabar lacquer kept for night. Both tuned to comfortable AA. **Follow system** default.
- **Wording:** Plain table talk — "Nhất bàn" / "Bét bàn". Drop "Ấn vàng / Tem cuối bàn /
  Vô địch ván" as primary labels.
- **Seal motif:** Keep the round lacquer-**seal shape** as the brand mark; drop the Hán
  glyphs. Put legible Arabic rank (or initial) inside. Winner = gold seal showing `1`;
  last place = a muted down-seal, not an aggressive ×.
- **Token architecture:** Make existing `phorm*` hex tokens **adaptive in place**
  (light/dark resolved per token) rather than introducing a fresh semantic layer — keeps
  the diff focused on the fix, no mass view-callsite migration.

This **overturns prior locked commitments** that must be rewritten as part of this work:
- DESIGN.md / CLAUDE.md: "App does NOT have binary light/dark equal peers… one drenched
  lacquer surface per session" → replaced by the dual-surface system below.
- PRODUCT.md: terminology anchors referencing "ấn vàng" / "tem chéo" as primary labels.

## A. Color system — two surfaces, both AA-comfortable

All up/down scores **always keep the `+`/`−` sign prefix** (color-blind requirement),
and are **text color only**, never card fill. With the new values, sign + color now also
carry real contrast headroom on both surfaces.

### Day — warm paper (new everyday canvas)

| Role | Value | Contrast on ground |
|---|---|---|
| Ground | `#F2E9D8` warm oat | — |
| Card / elevated | `#FBF5E9` lighter / `#EADFC8` deeper panel | — |
| Body ink / numerals | `#2E1C16` espresso | ~12:1 ✓✓ |
| Muted labels / dates | `#6B5A4A` taupe | ~4.8:1 ✓ |
| Accent / headers / CTA fill | cinnabar `#8C2A22` | ~6.5:1 ✓ |
| **Up** score | deep jade `#1B6B47` | ~5.5:1 ✓ |
| **Down** score | burnt rust `#A63A1E` | ~5.7:1 ✓ |
| Hairline | `#000` @ 0.12 | — |
| Winner seal | gold disc `#D9B25A` + ink `#5A1612` content (6.76:1 inside); thin cinnabar ring for definition on light | — |

### Night — lacquer (kept identity, two fixes only)

Cinnabar `#8C2A22` stays the night base; iOS dark appearance may deepen it subtly. Only
the two failing colors change:

| Role | Now | New | Contrast on cinnabar |
|---|---|---|---|
| **Down** score | `#E6A665` (4.02:1, large-only) | `#F2B488` peach | ~5.2:1 ✓ (passes normal text) |
| Gold (small labels) | `#E8C570` | unchanged | 5.10:1 ✓ |
| Gold (display ≥18px) | `#D9B25A` | unchanged | 4.27:1 (display-only) |
| Cream body | `#F3E8D2` | unchanged | 6.96:1 ✓ |
| **Up** score (mint) | `#B6E0C2` | unchanged | 5.81:1 ✓ |

### Token architecture

`Color+Tokens.swift`: the hardcoded lacquer hexes (`phormSurfaceCinnabar`, `phormCream`,
`phormCreamDim`, `scorePositive`, `scoreNegative`, `phormPrimary`, etc.) become **adaptive**
— resolved per appearance from `Assets.xcassets` colorsets (the colorset scaffolding for
Canvas/SurfaceCard/Body/ScorePositiveTint/ScoreNegativeTint already exists; extend it to
cover the lacquer family). View callsites keep the same token names, so the diff stays in
the token layer + `Assets.xcassets`, not across every view.

`LacquerSurface.swift`: surface treatment becomes appearance-aware — paper grain (subtle)
on light, lacquer + halftone on dark. No glassmorphism either way.

## B. Plain table talk — terminology map

| Where (SummaryView.swift) | Now | New |
|---|---|---|
| Champion section label (`championBlock`, ~line 150) | "Vô địch ván" | **"Nhất bàn"** |
| Gold-seal callout (~line 165) | "Ấn vàng" | *(label removed; gold seal is the decoration beside "Nhất bàn")* |
| Last-place section label (`lastPlaceBlock`, ~line 214) | "Tem cuối bàn" | **"Bét bàn"** |
| Tied-state copy (~line 241) | "Phiên có tổng bằng nhau, không xác định vô địch/cuối bàn" | "Hoà — chưa rõ ai nhất, ai bét" |
| Unstamped tied label (~line 239) | "Chưa đóng dấu được" | unchanged (already plain) |

EmptyHomeView copy ("Mở là chơi — cuối bàn rõ ai ăn ai thua…") is already plain — keep.
Splash / wordmark "Ấn Điểm" is the brand name — keep.

## C. Seal motif — keep the stamp, drop the Hán

- `Seal.swift`: keeps `winner` / `last` / `default` variants and the round stamp shape.
  Content is now legible text passed in (Arabic numeral or initial), not a Hán glyph.
- `SealGlyph.forRank` (used in `RoundEntryView.swift` ~line 178): stops mapping rank →
  Hán numerals; returns Arabic position (`1 2 3 4`) — or player initial, decide in impl.
- Seat seals in round entry: Arabic position.
- Winner (SummaryView + RoundEntry auto-fill seal): gold seal showing `1`.
- Last place: muted **down-seal** (de-emphasized ring), replacing the `×` cross — beside
  "Bét bàn". No aggressive X.

## D. Validate in `themes-preview.html` first

Per repo convention, `themes-preview.html` is the canonical visual reference. The
implementation plan must **update it first** to show both surfaces (day paper + night
lacquer) and the plain wording across the four key screens, for raw.githack review,
**before** touching SwiftUI. Cheaper iteration loop than rebuilding the app per tweak.

## F. Typography — fully clean sans (scope expansion, 2026-06-28)

Live feedback widened the ask beyond color/wording: also fix **font** and **sizing**, because
the round-entry **input is hard to focus on**. Decisions:

- **Drop the serif print register entirely.** Rework `Font+Tokens.swift` so every token's
  `design: .serif` becomes **`.default` (SF Pro)** — a humanist sans with full Vietnamese
  diacritic coverage and built-in Dynamic Type. Default is **system SF Pro** (zero font
  bundling); bundling Inter is a deferred option, not taken unless asked.
- Numerals keep `.monospacedDigit()` (tabular figures for column alignment). This is *not*
  SF Mono — proportional sans with tabular figures — and is the legible/friendly choice.
- Player names drop italic-serif "signature" styling → clean medium-weight sans. The
  auto-fill computed value keeps one subtle distinction (lighter weight) so "the app wrote
  this" still reads vs. host-entered values.
- **Brand survives the serif loss** through the lacquer color, warm paper, and seal motif —
  not through the typeface. This is an accepted tradeoff, not an oversight.

## G. Input-focus hierarchy — the core fix (layout unchanged)

The round-entry screen currently signals the active cell only with a 14%-opacity tint + a
thin 1.5px border, and all values are the same 22pt — nothing dominates, so the eye can't
find where it's typing. Fix, within the existing layout:

- **Focused row grows:** numeral `22pt → ~34pt` bold, name full opacity, cell fill stronger
  (modeColor ~0.20) + 2px border, more vertical padding.
- **Inactive rows recede:** numeral ~20pt, name + value dimmed (~0.5 opacity).
- **Auto-fill row** stays distinct (gold) but quieter than the focused row.
- Net: at any moment exactly one row clearly reads as "where I'm typing."

## H. Sizing — hierarchy only, no global inflation

No blanket size increase and no touch-target changes. The only size moves are the
active-vs-inactive and primary-vs-secondary contrasts in F/G.

## E. Docs to update (source-of-truth, part of the work)

- `DESIGN.md` — replace "one drenched surface / no light-dark peers" frontmatter and score
  tokens with the dual-surface system + new jade/rust (day) and peach (night) values. Also
  replace the serif/"No SF Mono / numerals use serif" typography section with the clean-sans
  system (F).
- `CLAUDE.md` — update the "App does NOT have binary light/dark" and terminology anchors, and
  the "No SF Mono / Noto Serif numerals" anchor → clean sans + tabular figures.
- `PRODUCT.md` — update anti-reference/terminology anchors referencing "ấn vàng" / "tem
  chéo" as primary labels (the seal *shape* stays; the *labels* go plain), and note the brand
  now rests on lacquer color + paper + seal, not the serif register.
- `design-walkthrough.html` — leave untouched (kept for diff reference).

## Out of scope

- No change to the offline-first / SwiftData+CloudKit data model.
- No change to round-entry interaction (N−1 auto-fill), session handoff URL scheme, or the
  đóng dấu / share-card stamp feature behavior (only its labels/colors inherit the above).
- No new accent color; gold-leaf remains the single accent. No glassmorphism, no SF Mono.
- No onboarding / mode-picker UI — appearance follows system, zero config.

## Manual verification

1. Light mode: every score/label/numeral on the round-entry and summary screens is
   comfortably legible; spot-check down-scores (rust) and up-scores (jade) at body size.
2. Dark mode: down-scores (peach) are legible at normal text size, not just large.
3. Summary shows "Nhất bàn" / "Bét bàn"; no "Ấn vàng" / "Tem cuối bàn" / "Vô địch ván" /
   Hán seal glyphs remain anywhere user-facing.
4. Seat + winner + last seals show Arabic content; last place is muted, not an aggressive ×.
5. Toggle system appearance mid-session — surface flips paper↔lacquer, identity persists.
