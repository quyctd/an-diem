---
version: beta
name: andiem-design-tactile
description: A tactile, brightened card-table score-tracker for iOS. Brand accents are Tết-red #E5483A + gold #F2B829. Score values are COLOR-FILLED tactile chips (up green #21BD73, down coral #FF6B3D, neutral #ECE4D6 day) with white bold tabular numbers and always-present +/− sign prefix. Seat/winner/last-place markers are round coin tokens with Arabic numbers. Keypad keys are 3D-bevel buttons that depress with haptics. Day/night surfaces follow system appearance: day warm cream #FBF4E6, night deep warm #241715. Halftone/grain textures retired on core screens — depth from chip and key shadows. Typography is clean system sans (SF Pro native; Inter in mockup) with tabular figures. Canonical visual reference is the TACTILE/PLAYFUL DIRECTION (tc-) section of themes-preview.html. SF Mono remains forbidden.

colors:
  # Day surfaces (light appearance)
  surface-day: "#FBF4E6"              # warm oat — day background
  surface-day-tile: "#FFFBF3"         # card / elevated surface (day)
  surface-day-panel: "#ECE4D6"        # deeper panel / neutral chip (day)

  # Night surfaces (dark appearance)
  surface-night: "#241715"            # deep warm dark — night background
  surface-night-elevated: "#2E1E1A"   # card / elevated surface (night)

  # Ink
  ink: "#2A211C"                      # ~12:1 on day — primary text (day)
  ink-muted: "#6B5A4A"                # ~4.8:1 on day — secondary labels, dates
  cream: "#F6ECDA"                    # primary text on night surface

  # Brand accents
  brand-red: "#E5483A"                # Tết-red — primary CTA, sign-toggle key, headers
  brand-red-deep: "#C03020"           # pressed / deep variant
  gold: "#F2B829"                     # winner coin, gold special token
  gold-dim: "#C49010"                 # disabled / pressed gold

  # Score chip fills (COLOR-FILLED tiles — chip fill is intentional, overrides prior text-only rule)
  chip-up: "#21BD73"                  # up / positive score — green chip fill
  chip-down: "#FF6B3D"                # down / negative score — coral chip fill
  chip-neutral: "#ECE4D6"             # zero / neutral score — muted chip (day)
  chip-text: "#FFFFFF"                # white bold number inside up/down chips
  chip-text-neutral: "#2A211C"        # dark number inside neutral chip

  # Score text (for non-chip contexts)
  score-up-day: "#1B6B47"             # deep jade — up on day surface (~5.5:1)
  score-down-day: "#A63A1E"           # burnt rust — down on day surface (~5.7:1)
  score-up-night: "#B6E0C2"           # mint — up on night surface (5.81:1)
  score-down-night: "#F2B488"         # peach — down on night surface (~5.2:1)

  # Warning / state
  warning: "#FF6B3D"                  # coral — unbalanced round total
  balanced: "#21BD73"                 # green — balanced round total

textures:
  grain-night-only:
    opacity: 0.25
    blendMode: overlay
    use: "Dark/night surfaces only — subtle warm grain. Day surfaces are flat (no halftone, no grain). Halftone-dot pattern retired entirely."
  chip-shadow:
    description: "inset 0 -3px 0 bottom-bevel + soft drop shadow on score chips"
    use: "Every score chip. Depth from shadow, not surface noise."
  key-shadow:
    description: "0 4px 0 bottom ridge on keypad keys; press = translateY(3px) + ridge shrink"
    use: "All keypad keys and confirm CTA. Paired with UIImpactFeedbackGenerator haptic."

typography:
  # All fonts: clean system sans — SF Pro (iOS native) / Inter (mockup target in themes-preview.html)
  # All numerics: .monospacedDigit() / font-variant-numeric: tabular-nums
  # SF Mono is FORBIDDEN. Serif register (Noto Serif Display, Cormorant Garamond, IBM Plex Serif, Spectral) is retired.

  display-hero:
    fontFamily: "SF Pro Display, Inter, system-ui"
    fontWeight: 700
    fontSize: 32px
    lineHeight: 1.08
    letterSpacing: -0.012em
    use: "End-of-session champion name, empty state hero"
  display-md:
    fontFamily: "SF Pro Display, Inter, system-ui"
    fontWeight: 700
    fontSize: 24px
    lineHeight: 1.12
    letterSpacing: -0.01em
    use: "Session title in nav header, end-of-session subtitle"
  display-sm:
    fontFamily: "SF Pro Text, Inter, system-ui"
    fontWeight: 600
    fontSize: 20px
    lineHeight: 1.2
    use: "Sheet headers (round entry 'Vòng N'), section dividers"
  name-display:
    fontFamily: "SF Pro Text, Inter, system-ui"
    fontWeight: 500
    fontSize: 18px
    lineHeight: 1.1
    use: "Player names on leaderboard, end screen, round-entry rows — clean medium-weight sans"
  num-hero:
    fontFamily: "SF Pro Display, Inter, system-ui"
    fontWeight: 700
    fontSize: 44px
    lineHeight: 1
    letterSpacing: -0.02em
    fontVariantNumeric: "tabular-nums"
    use: "Champion score on end-of-session — biggest number on screen"
  num-display-lg:
    fontFamily: "SF Pro Display, Inter, system-ui"
    fontWeight: 700
    fontSize: 26px
    lineHeight: 1
    fontVariantNumeric: "tabular-nums"
    use: "Leaderboard totals, ranking values"
  num-display-md:
    fontFamily: "SF Pro Text, Inter, system-ui"
    fontWeight: 700
    fontSize: 22px
    lineHeight: 1
    fontVariantNumeric: "tabular-nums"
    use: "Round-entry value inputs (focused row grows to ~34pt bold)"
  num-body:
    fontFamily: "SF Pro Text, Inter, system-ui"
    fontWeight: 400
    fontSize: 15px
    fontVariantNumeric: "tabular-nums"
    use: "Round history strip, validation totals, history index dates"
  num-autofill:
    fontFamily: "SF Pro Text, Inter, system-ui"
    fontWeight: 300
    fontSize: 22px
    fontVariantNumeric: "tabular-nums"
    use: "Auto-fill computed values — lighter weight (300) signals 'the app wrote this'"
  body:
    fontFamily: "SF Pro Text, Inter, system-ui"
    fontWeight: 400
    fontSize: 15px
    lineHeight: 1.5
    use: "Body copy, descriptions, footer notes"
  label-caps:
    fontFamily: "SF Pro Text, Inter, system-ui"
    fontWeight: 500
    fontSize: 11px
    letterSpacing: 0.06em
    textTransform: uppercase
    use: "Section labels — 'PHIÊN ĐANG CHƠI', 'VÒNG', 'TỔNG'"
  button:
    fontFamily: "SF Pro Text, Inter, system-ui"
    fontWeight: 600
    fontSize: 15px
    use: "Primary CTAs — 'VÒNG MỚI', 'LƯU VÒNG'"

rounded:
  none: 0
  xs: 4px
  sm: 8px
  md: 12px
  chip: 14px       # score chips
  coin: 999px      # coin tokens (circular)
  pill: 999px      # total pill badge
  key: 12px        # keypad keys

spacing:
  base: 4px
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 20px
  xl: 28px
  xxl: 40px
  section: 56px

components:
  button-primary:
    backgroundColor: "{colors.brand-red}"
    textColor: "#FFFFFF"
    typography: "{typography.button}"
    rounded: "{rounded.md}"
    padding: 14px 24px
    boxShadow: "0 4px 0 {colors.brand-red-deep}"
    note: "3D bevel — press = translateY(3px) + shadow collapse + haptic. Used on 'VÒNG MỚI', 'LƯU VÒNG'."
  button-secondary-outline:
    backgroundColor: transparent
    textColor: "{colors.brand-red}"
    border: "1.5px solid {colors.brand-red}"
    typography: "{typography.button}"
    rounded: "{rounded.md}"
    padding: 12px 24px
    note: "Used for 'CHIA SẺ' and other secondary CTAs"
  coin-winner:
    size: 32px
    shape: circle
    backgroundColor: "{colors.gold}"
    textColor: "#2A211C"
    content: "Arabic seat number (1, 2, 3, 4)"
    boxShadow: "0 2px 6px rgba(242,184,41,0.4)"
    use: "Winner 'Nhất bàn' — gold coin."
    contrast: "Ink on gold ~8:1 ✓"
  coin-default:
    size: 32px
    shape: circle
    backgroundColor: "{colors.surface-day-panel}"
    border: "1.5px solid rgba(42,33,28,0.15)"
    textColor: "{colors.ink}"
    content: "Arabic seat number"
    use: "Seat marker — non-winning slots (day). Night: elevated surface variant."
  coin-last:
    size: 32px
    shape: circle
    backgroundColor: "rgba(255,107,61,0.15)"
    border: "1.5px solid {colors.chip-down}"
    textColor: "{colors.chip-down}"
    content: "Arabic seat number"
    use: "Last place 'Bét bàn' — muted coral coin. Not an aggressive ×."
  chip-score-up:
    rounded: "{rounded.chip}"
    backgroundColor: "{colors.chip-up}"
    textColor: "{colors.chip-text}"
    sign: "+ (explicit prefix — always present)"
    boxShadow: "inset 0 -3px 0 rgba(0,0,0,0.18), 0 2px 4px rgba(33,189,115,0.25)"
    use: "Positive score chip — color-filled. Sign is required for color-blind safety."
  chip-score-down:
    rounded: "{rounded.chip}"
    backgroundColor: "{colors.chip-down}"
    textColor: "{colors.chip-text}"
    sign: "− (explicit prefix — always present)"
    boxShadow: "inset 0 -3px 0 rgba(0,0,0,0.18), 0 2px 4px rgba(255,107,61,0.25)"
    use: "Negative score chip — color-filled. Sign is required for color-blind safety."
  chip-score-neutral:
    rounded: "{rounded.chip}"
    backgroundColor: "{colors.chip-neutral}"
    textColor: "{colors.chip-text-neutral}"
    use: "Zero / neutral score chip (day). Night variant: darker muted tone."
  keypad-key:
    rounded: "{rounded.key}"
    backgroundColor: "white (day) / #3A2820 (night)"
    boxShadow: "0 4px 0 rgba(0,0,0,0.18)"
    typography: "SF Pro Display 700 20px"
    press: "translateY(3px) + shadow collapses + UIImpactFeedbackGenerator(.light)"
    use: "All digit and operator keys"
  keypad-sign-toggle:
    backgroundColor: "{colors.brand-red}"
    textColor: "#FFFFFF"
    boxShadow: "0 4px 0 {colors.brand-red-deep}"
    note: "Sign-toggle key uses brand-red accent"
  cell-input-active:
    backgroundColor: "white (day) — elevated card"
    border: "2px solid {colors.brand-red}"
    textColor: "{colors.ink}"
    typography: "SF Pro Display 700 ~34pt"
    note: "Focused row: chip grows ~1.4× (tc-chip-lg), name full opacity, elevated white card, bright focus ring"
  cell-input:
    opacity: "~0.4 on name + value"
    note: "Inactive rows recede: smaller chip, dimmed — no layout collapse"
  cell-input-autofill:
    textColor: "{colors.ink}"
    typography: "{typography.num-autofill}"
    note: "Auto-fill computed value — lighter weight (300) distinguishes 'app wrote this'"
  total-pill:
    rounded: "{rounded.pill}"
    backgroundColor: "{colors.balanced} (= 0) / {colors.warning} (≠ 0)"
    textColor: "#FFFFFF"
    use: "'Tổng' pill badge — balanced green 'cân' / unbalanced coral ⚠. State-aware."
  card-history:
    backgroundColor: "white (day) / {colors.surface-night-elevated} (night)"
    rounded: "{rounded.md}"
    padding: 12px 16px
    use: "History list entries"
  validation-balanced:
    textColor: "{colors.balanced}"
    glyph: "= 0 · cân"
  validation-unbalanced:
    textColor: "{colors.warning}"
    glyph: "Tổng: −3 ⚠"
    note: "Soft warning — non-blocking. Save remains tappable."
---

## Overview

Phorm is a Vietnamese-vernacular score-tracker for Phỏm / Sâm Lốc / any zero-sum card game. The host at the table holds the phone between rounds and records points; the app totals them and produces a leaderboard. This document describes the visual language — see the **`TACTILE / PLAYFUL DIRECTION` (`tc-`) section of `themes-preview.html`** for the canonical visual reference; this doc captures the tokens and component specs so the iOS implementation can pull from a single source.

The visual identity rests on **Tết-red + gold brand accents, color-filled tactile score chips, and round coin tokens** — score entry should feel like placing physical pieces on a card table. Surfaces are bright warm cream by day and deep warm dark by night, following the system appearance setting.

## Surfaces — bright day / deep night, following system

Surfaces follow system appearance:
- **Day (light):** `{colors.surface-day}` (`#FBF4E6`) warm oat — everyday canvas. Cards/elevated tiles are `{colors.surface-day-tile}` (`#FFFBF3`).
- **Night (dark):** `{colors.surface-night}` (`#241715`) deep warm dark. Cards use `{colors.surface-night-elevated}`.

The app **follows system appearance** with two equal surface peers. No single drenched lacquer surface per session; chromatic identity persists through the Tết-red + gold brand accents, not a single surface hue.

Halftone-dot pattern and paper-grain texture are **retired on day surfaces**. On night surfaces, a subtle grain overlay (25% opacity, overlay blend) adds warmth. All depth cues on day surfaces come from chip shadows and key shadows.

### System appearance

Surfaces flip between the warm-cream day canvas and the deep-warm night canvas as the user toggles system appearance. No configuration required — the app follows system default.

## Colors

### Day palette

- **Surface day** (`{colors.surface-day}` — `#FBF4E6`): Warm oat background.
- **Tile / elevated** (`{colors.surface-day-tile}` — `#FFFBF3`): Card backgrounds, focused row.
- **Panel** (`{colors.surface-day-panel}` — `#ECE4D6`): Deeper surfaces, neutral chip background.
- **Ink** (`{colors.ink}` — `#2A211C`): ~12:1 on day. Primary text, numerals.
- **Ink muted** (`{colors.ink-muted}` — `#6B5A4A`): ~4.8:1. Secondary labels, dates, meta.

### Night palette

- **Surface night** (`{colors.surface-night}` — `#241715`): Deep warm dark background.
- **Cream** (`{colors.cream}` — `#F6ECDA`): Primary text on night surface.
- Night surface carries the Tết-lacquer lineage — warm and deep, tuned for comfortable AA contrast.

### Brand accents (`{colors.brand-red}`, `{colors.gold}`)

- **Tết-red** (`{colors.brand-red}` — `#E5483A`): Primary CTA fill, sign-toggle keypad key, section headers. The brand's identity anchor.
- **Gold** (`{colors.gold}` — `#F2B829`): Winner coin, gold special tokens. Carries the "Nhất bàn" celebration moment.

### Score chips (`{colors.chip-*}`)

Score chips are **color-filled tactile tiles** — this intentionally overrides the prior "score color is text only, never card fill" rule. Both up and down chips always include an explicit `+`/`−` sign prefix for color-blind safety.

- **Up chip** (`{colors.chip-up}` — `#21BD73`): Green fill + white bold number.
- **Down chip** (`{colors.chip-down}` — `#FF6B3D`): Coral fill + white bold number.
- **Neutral/zero chip** (`{colors.chip-neutral}` — `#ECE4D6` day): Muted fill + dark number.
- **Sign prefix** is always present regardless of chip color — the sign is the primary color-blind cue; the chip color is additive.

### Score text (non-chip contexts)

For leaderboard rows or dense contexts where a full chip is not used:
- **Up (day):** `{colors.score-up-day}` (`#1B6B47`) deep jade — ~5.5:1 on day.
- **Down (day):** `{colors.score-down-day}` (`#A63A1E`) burnt rust — ~5.7:1 on day.
- **Up (night):** `{colors.score-up-night}` (`#B6E0C2`) mint — 5.81:1 on night.
- **Down (night):** `{colors.score-down-night}` (`#F2B488`) peach — ~5.2:1 on night.

## Textures

Halftone-dot pattern and paper-grain are **retired on day (bright) surfaces**. On night surfaces, the grain overlay (25% opacity, overlay blend) is retained for warmth. Depth and tactility on day surfaces come entirely from:

1. `{textures.chip-shadow}` — bevel band + drop shadow on every score chip
2. `{textures.key-shadow}` — 4px bottom ridge on keypad keys, collapses on press

The iOS implementation must NOT apply grain to light/day surfaces.

## Typography

### Font Family

The app uses **clean system sans** throughout:

- **SF Pro** (iOS native) — zero font bundling, full Vietnamese diacritic coverage, Dynamic Type support. This is the iOS build target.
- **Inter** is the mockup target in `themes-preview.html` (CDN). The iOS build uses SF Pro.

There is **no serif** in the app. The serif print register (Noto Serif Display, Cormorant Garamond, IBM Plex Serif, Spectral) is retired. Brand character comes from Tết-red + gold + coin/chip tactility, not the typeface.

All numerics use `.monospacedDigit()` / `font-variant-numeric: tabular-nums` for column alignment. This is proportional sans with tabular figures — not SF Mono. **SF Mono is forbidden** everywhere in the app.

Player names drop italic-serif "signature" styling → clean medium-weight sans. Auto-fill computed values use a lighter weight (`{typography.num-autofill}` — weight 300) to signal "the app wrote this" vs. host-entered values.

### Vietnamese diacritic coverage

SF Pro covers the full Vietnamese diacritic set. Verify representative names at small sizes:
- Quý (ý), Nam, Linh, Hoàng (à)
- Diacritic stack: ặ, ằ, ẵ, ẳ, ậ, ầ, ẫ, ẩ, ấ, ố, ợ, ự, ỵ, ỳ
- Đ / đ rendering at label-caps tier (~11px uppercase letter-spaced)

## Layout

### Spacing

Same scale (`{spacing.xxs}` 4px → `{spacing.section}` 56px). Screen margins 20px on iPhone. The app stays dense — most surfaces use 12–20px between elements, not 32–56px.

### Container philosophy

**Cards on a bright canvas.** Separation uses:

1. Card tiles (`{components.card-history}`) — white day / elevated night
2. Subtle hairline (`rgba(0,0,0,0.08)`) — section dividers on day
3. Focused-row elevation — active input row on white card, inactive rows recede

The focused-row dominance (active chip ~1.4× size, elevated white card; inactive chips ~0.4 opacity) is the core visual hierarchy in round entry.

## Components

The component table in the YAML frontmatter is the source of truth. Highlights:

### Buttons

`{components.button-primary}` — Tết-red fill, white text, 3D bottom ridge shadow. Press = translateY(3px) + ridge collapse + light haptic. One CTA per screen — never two equal-weight primary buttons.

`{components.button-secondary-outline}` — Transparent fill, red border, red text.

### Coin tokens (rank markers)

Coins replace the prior square seals. Three variants:

- `{components.coin-winner}` — solid gold disc, Arabic seat number, gold glow shadow. The "Nhất bàn" celebration moment. No Hán glyphs.
- `{components.coin-default}` — muted panel fill, Arabic seat number. Non-winning slots.
- `{components.coin-last}` — muted coral ring, Arabic seat number. Last place "Bét bàn". Not an aggressive ×.

### Score chips

`{components.chip-score-up}` / `{components.chip-score-down}` / `{components.chip-score-neutral}` are the core display unit for every score value. Always rendered with explicit `+`/`−` sign prefix. Bottom-bevel shadow + drop shadow read as physical pieces.

### Round-entry cells

Active row: chip grows to ~tc-chip-lg (≈1.4×), elevated white card, 2px brand-red focus ring. Inactive rows: ~0.4 opacity. Auto-fill row: lighter-weight sans number. No layout collapse between states.

### Keypad

`{components.keypad-key}` — 3D bevel keys (gradient face + 4px bottom ridge). Press = translateY(3px) + haptic. Sign-toggle key in brand-red. Confirm CTA gets same 3D treatment.

### Total pill

`{components.total-pill}` — rounded pill badge, state-aware: green "cân" (balanced = 0) / coral ⚠ (unbalanced). Non-blocking — save remains tappable at all states.

## Motion

Motion is physical and immediate:

- **Chip resize** (~200ms, spring): Active row chip grows; inactive chips shrink. Happens on every row-focus change.
- **Key press** (~80ms): translateY(3px) + shadow collapse. Instant feel.
- **Coin reveal** (~400ms, spring): Coin scales in on summary screen appearance.

Don't introduce bounce, elastic, or confetti motion. The app is matter-of-fact.

## Accessibility

### Contrast — measured per surface

Day surface (`#FBF4E6`):

| Combination | Ratio | WCAG | Use |
|---|---|---|---|
| Ink on day | ~12:1 | AA+ | Body text |
| Ink-muted on day | ~4.8:1 | AA Normal | Labels, meta |
| Brand-red on day | ~6.5:1 | AA+ | Headers, CTAs |
| Score-up jade on day | ~5.5:1 | AA Normal | Up score text |
| Score-down rust on day | ~5.7:1 | AA Normal | Down score text |
| Gold on day | ~3.5:1 | Large only | Winner coin (large bold) |

Night surface (`#241715`):

| Combination | Ratio | WCAG | Use |
|---|---|---|---|
| Cream on night | ~12:1 | AA+ | Body text |
| Score-up mint on night | 5.81:1 | AA Normal | Up score text |
| Score-down peach on night | ~5.2:1 | AA Normal | Down score text |

When extending tokens, re-run the audit per surface — ratios are surface-specific.

### Color-blind parity

Score direction is always communicated by:

1. Chip color (green up / coral down) — primary visual cue
2. Explicit `+` / `−` sign prefix — **always present, always color-blind-safe**
3. Coin shape for ranking — gold coin (winner) vs. coral coin (last place)

Never rely on hue alone. The sign prefix is the hard requirement; chip color is additive.

### Dynamic Type

Body copy, names, label-caps, button labels scale with iOS Dynamic Type. Numeric tiers (`num-hero`, `num-display-lg`, `num-display-md`) opt out at the leaderboard / round-entry tier to preserve column alignment — deliberate trade-off.

### Reduce Motion / Reduce Transparency

- Reduce Motion: skip chip resize animation (instant snap); skip key press animation.
- Reduce Transparency: grain overlay already off on day; on night, grain can be removed entirely. No content sits behind either layer.

## Do's and Don'ts

### Do
- Apply bright warm-cream day surface and deep warm night surface, following system appearance.
- Use color-filled score chips (green up / coral down) with explicit `+`/`−` sign always.
- Use round coin tokens with Arabic numbers for seat/winner/last-place markers.
- Use 3D-bevel keypad keys with haptic press.
- Use Tết-red for primary CTAs and the sign-toggle key.
- Use the gold winner coin as the only true celebration — "Nhất bàn" is the sole celebratory moment.
- Pair score chips with `+`/`−` prefixes. Always. The sign is the color-blind contract.
- Render every numeric with `.monospacedDigit()` / `tabular-nums` so columns stay aligned.

### Don't
- Don't use a single drenched lacquer surface per session. Surfaces follow system appearance.
- Don't apply halftone dots to any surface. Halftone pattern is retired entirely.
- Don't apply grain to day/light surfaces. Grain is night-only, 25% opacity.
- Don't use SF Mono anywhere. Forbidden.
- Don't use serif typefaces (Noto Serif Display, Cormorant Garamond, IBM Plex Serif, Spectral). The serif register is retired.
- Don't use Liquid Glass or glassmorphism.
- Don't use square seals (ấn vàng / tem chéo) or Hán glyphs (壹/封/×). Use coin tokens with Arabic numbers.
- Don't add confetti, mascots, emoji, or "🎉 You won!" moments. The gold coin is the celebration.
- Don't use the old literary labels ("Ấn vàng", "Tem cuối bàn", "Vô địch ván") in user-facing copy. Use "Nhất bàn" / "Bét bàn".
- Don't introduce a third accent beyond Tết-red + gold.

## Iteration Guide

1. Visual canon is the **`TACTILE / PLAYFUL DIRECTION` (`tc-`) section of `themes-preview.html`** at the repo root. When tokens here disagree with the `tc-` mockup, the mockup wins; update the doc.
2. When proposing a new component, decide: does it sit on the bright canvas (yes — 95% of cases) or is it a chrome layer (rare — sheets/modals)? Canvas-native components inherit the card-tile and shadow system; chrome components need surface treatment specified.
3. Reference tokens (`{colors.chip-up}`, `{typography.num-display-md}`) in component definitions, not raw hex. Centralized tokens enforce the contrast contract.
4. Variants of an existing component (`-active`, `-autofill`, `-winner`) live as separate entries in `components:`, not as nested state objects.
5. Every new component must declare its contrast ratio against its surface. If it fails AA, the component fails review.
6. Numbers always use SF Pro with `.monospacedDigit()`. Lighter weight (300) for computed/auto-fill values; never serif, never SF Mono.

## Known Gaps

- Animation timings for sheet present / dismiss are not formalized — use SwiftUI default `.snappy` / `.spring()` until measured.
- The split-view layout on iPad regular width is not designed. When iPad lands, decide: full-bleed bright canvas on both panes, or chrome boundary.
- Widget / Lock-Screen treatments are out of scope for MVP.
- App Icon: Tết-red tile with a gold coin `1` centered is the proposed direction; needs explicit asset work.
- Night surface grain opacity may need tuning per device (OLED vs. LCD) — verify on hardware.
- Alternate-session-color picker UX is not designed — for MVP, appearance follows system only.
