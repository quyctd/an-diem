---
version: alpha
name: phorm-design-hanoi-cu
description: A confident Vietnamese-vernacular score-tracker interface for iOS — a Phỏm/Sâm Lốc card-game scorekeeper where one player at a table holds the phone and records points after each round. Visual identity is drawn from Vietnamese print history (matchbox labels, Bia Hà Nội bottles, lacquerware seals, áo dài silk) read through a modern designer's eye, NOT pastiche. Each session lives on one drenched lacquer surface (cinnabar / ochre / jade / oxblood); chrome is sparse, halftone-textured, and serves the numbers. Display serifs (Noto Serif Display + Cormorant Garamond + IBM Plex Serif tabular figures) carry the personality — numerals have weight, italics, ink. The winner earns a gold seal (ấn vàng); the last place gets a tem chéo (×). The visual reference is themes-preview.html in this repo. Liquid Glass is REPLACED by halftone + paper grain texture.

colors:
  # Lacquer surfaces — each session drenched in one
  surface-cinnabar: "#8c2a22"           # default — Tết-red lacquer
  surface-cinnabar-deep: "#5a1612"      # vignette / button text on gold
  surface-cinnabar-light: "#a8362d"     # specular highlight
  surface-ochre: "#a8754a"              # alternate session color — aged wood
  surface-ochre-deep: "#6e4527"
  surface-jade: "#3d6b5c"               # alternate — old jade
  surface-jade-deep: "#22443a"
  surface-oxblood: "#5d1a18"            # late-night variant of cinnabar
  surface-oxblood-deep: "#3a0e0c"

  # Ink — cream paper that the lacquer "writes" with
  cream: "#f3e8d2"                      # 6.96:1 on cinnabar — primary text
  cream-dim: "#d6c4a0"                  # 4.94:1 — secondary text, labels
  cream-faint: "rgba(243, 232, 210, 0.34)"  # UI hairline ~3:1
  cream-stroke: "rgba(243, 232, 210, 0.18)"  # decorative dividers

  # Gold — accent / seal / primary action
  gold: "#d9b25a"                       # 4.27:1 on cinnabar — display sizes only (≥18px)
  gold-bright: "#e8c570"                # 5.10:1 — small labels, AA Normal
  gold-dim: "#a88438"                   # disabled / pressed
  gold-leaf-tint: "rgba(217, 178, 90, 0.12)"  # gold tablet bg (used with cream text)

  # Score semantics — mint up, ochre down (both with explicit +/− sign)
  mint: "#b6e0c2"                       # 5.81:1 on cinnabar — positive scores
  mint-dim: "#86b69a"                   # positive on lighter surfaces
  ochre-warm: "#e6a665"                 # 4.02:1 — negative, ≥18px only
  ochre-deep: "#a86524"                 # negative on cream surfaces

  # Warning / informational
  warning: "#e6a665"                    # reuses ochre — non-zero round total
  warning-tint: "rgba(230, 166, 101, 0.16)"

textures:
  halftone-dots:
    cssBackground: "radial-gradient(rgba(243, 232, 210, 0.06) 1px, transparent 1px)"
    size: "4px 4px"
    blendMode: screen
    use: "Background dot pattern on every lacquer surface — adds depth without competing"
  paper-grain:
    source: "SVG fractalNoise baseFrequency=0.85 numOctaves=2"
    opacity: 0.55
    blendMode: overlay
    use: "Subtle warm grain overlay so surfaces don't look flat-digital"
  vignette-warm:
    cssBackground: "radial-gradient(circle at 30% 20%, rgba(255,220,180,0.10), transparent 55%), radial-gradient(circle at 70% 80%, rgba(0,0,0,0.18), transparent 60%)"
    use: "Center-weights attention on hero screens (leaderboard, end-of-session)"

typography:
  display-hero:
    fontFamily: "Noto Serif Display, Cormorant Garamond, serif"
    fontWeight: 800
    fontSize: 32px
    lineHeight: 1.08
    letterSpacing: -0.012em
    use: "End-of-session champion name, empty state hero"
  display-md:
    fontFamily: "Noto Serif Display, serif"
    fontWeight: 700
    fontSize: 24px
    lineHeight: 1.12
    letterSpacing: -0.01em
    italic: optional
    use: "Session title in nav header, end-of-session subtitle"
  display-sm:
    fontFamily: "Noto Serif Display, serif"
    fontWeight: 700
    fontSize: 20px
    lineHeight: 1.2
    use: "Sheet headers (round entry 'Vòng N'), section dividers"
  name-display:
    fontFamily: "Cormorant Garamond, serif"
    fontWeight: 600
    fontStyle: italic
    fontSize: 22px
    lineHeight: 1.1
    letterSpacing: -0.005em
    use: "Player names on leaderboard, end screen, history rows — italic gives signature feel"
  name-md:
    fontFamily: "Cormorant Garamond, serif"
    fontWeight: 600
    fontSize: 18px
    use: "Player names in round-entry rows, history meta"
  num-hero:
    fontFamily: "Noto Serif Display, serif"
    fontWeight: 800
    fontSize: 44px
    lineHeight: 1
    letterSpacing: -0.02em
    fontVariantNumeric: "tabular-nums"
    use: "Champion +24 on end-of-session — biggest number on screen"
  num-display-lg:
    fontFamily: "Noto Serif Display, serif"
    fontWeight: 800
    fontSize: 26px
    lineHeight: 1
    fontVariantNumeric: "tabular-nums"
    use: "Leaderboard totals, ranking values"
  num-display-md:
    fontFamily: "Noto Serif Display, serif"
    fontWeight: 800
    fontSize: 22px
    lineHeight: 1
    fontVariantNumeric: "tabular-nums"
    use: "Round-entry value inputs"
  num-body:
    fontFamily: "IBM Plex Serif, serif"
    fontWeight: 500
    fontSize: 15px
    fontVariantNumeric: "tabular-nums"
    use: "Round history strip, validation totals, history index dates"
  num-body-sm:
    fontFamily: "IBM Plex Serif, serif"
    fontWeight: 500
    fontSize: 11px
    fontVariantNumeric: "tabular-nums"
    use: "Round history chips, dense meta"
  num-script:
    fontFamily: "Cormorant Garamond, serif"
    fontWeight: 500
    fontStyle: italic
    fontVariantNumeric: "tabular-nums"
    use: "Auto-fill computed values — distinguishes 'machine wrote this' from 'host wrote this'"
  body:
    fontFamily: "Spectral, Georgia, serif"
    fontWeight: 400
    fontSize: 15px
    lineHeight: 1.5
    use: "Body copy, descriptions, footer notes"
  label-caps:
    fontFamily: "Spectral, serif"
    fontWeight: 500
    fontSize: 9px
    letterSpacing: 0.18em
    textTransform: uppercase
    use: "Section labels — 'PHIÊN ĐANG CHƠI', 'VÒNG', 'TỔNG', 'VÔ ĐỊCH VÁN'"
  button:
    fontFamily: "Spectral, serif"
    fontWeight: 600
    fontSize: 14px
    letterSpacing: 0.04em
    textTransform: uppercase
    use: "Primary CTAs — 'VÒNG MỚI', 'ĐÓNG DẤU — LƯU VÒNG'"

rounded:
  none: 0
  xs: 2px            # inputs, score cells — tighter than iOS default to match print register
  sm: 3px            # buttons, history cards
  md: 4px            # seals (squares with slight rounding)
  pill: 999px
  full: 999px        # rare — avatar circles only if added

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
    backgroundColor: "{colors.gold}"
    textColor: "{colors.surface-cinnabar-deep}"          # 6.76:1 — ink on gold
    typography: "{typography.button}"
    rounded: "{rounded.sm}"
    padding: 14px 24px
    boxShadow: "0 1px 0 rgba(0,0,0,0.25), inset 0 1px 0 rgba(255,255,255,0.18)"
    note: "Used on 'VÒNG MỚI', 'ĐÓNG DẤU — LƯU VÒNG', 'PHIÊN MỚI', 'Mở session này'"
  button-secondary-outline:
    backgroundColor: transparent
    textColor: "{colors.gold}"
    border: "1px solid {colors.gold}"
    typography: "{typography.button}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
    note: "Used for 'CHIA SẺ' and other paired secondary CTAs"
  seal-default:
    width: 32px
    height: 32px
    border: "1.5px solid {colors.gold}"
    backgroundColor: "{colors.gold-leaf-tint}"
    textColor: "{colors.gold}"
    rounded: "{rounded.md}"
    transform: "rotate(-3deg)"
    use: "Rank box (壹/贰/叁/肆) on leaderboard — non-winning slots"
    contrast: "3.38:1 (Large only — text is ≥18px display 700)"
  seal-winner:
    width: 32px
    height: 32px
    backgroundColor: "{colors.gold}"
    textColor: "{colors.surface-cinnabar-deep}"
    border: "1.5px solid {colors.gold}"
    boxShadow: "0 0 0 2px rgba(217, 178, 90, 0.32)"
    rounded: "{rounded.md}"
    transform: "rotate(-3deg)"
    use: "First-place rank box — 'ấn vàng' (gold seal)"
    contrast: "6.76:1 ✓ AA Normal"
  seal-last:
    width: 32px
    height: 32px
    border: "1.5px solid {colors.cream-dim}"
    textColor: "{colors.cream-dim}"
    rounded: "{rounded.md}"
    transform: "rotate(2deg)"
    glyph: "× (tem chéo)"
    use: "Last-place rank box — pairs with 4+ players only"
    contrast: "4.94:1 ✓"
  seal-stamp-mini:
    width: 22px
    height: 22px
    fontSize: 11px
    backgroundColor: "{colors.gold}"
    textColor: "{colors.surface-cinnabar-deep}"
    border: "1px solid {colors.gold}"
    rounded: "{rounded.md}"
    glyph: "封 (sealed) on auto-fill cell; positioned absolute -top-2 -right-2"
    animation: "h-stamp 700ms cubic-bezier(0.22, 1, 0.36, 1) — scale-and-rotate in"
    contrast: "6.76:1 ✓"
  cell-input:
    backgroundColor: "rgba(0,0,0,0.12)"
    border: "1px solid {colors.cream-faint}"
    textColor: "{colors.cream}"
    typography: "{typography.num-display-md}"
    rounded: "{rounded.xs}"
    padding: 8px 12px
    width: 100px
  cell-input-active:
    backgroundColor: "rgba(217, 178, 90, 0.14)"
    border: "1px solid {colors.gold}"
    boxShadow: "inset 0 0 0 1px {colors.gold}"
    textColor: "{colors.gold}"
    caret: "{colors.gold}"
    note: "Active focus on the row currently receiving keypad input"
  cell-input-sealed:
    backgroundColor: "rgba(217, 178, 90, 0.06)"
    border: "1px solid {colors.gold-dim}"
    textColor: "{colors.gold}"
    note: "Auto-fill cell — paired with {components.seal-stamp-mini}"
  card-history:
    backgroundColor: "rgba(0,0,0,0.18)"
    border: "1px solid {colors.cream-faint}"
    leftAccent: "3px solid {colors.gold}"
    rounded: "{rounded.sm}"
    padding: 12px 16px
    use: "History list entries on cinnabar surface"
  validation-balanced:
    textColor: "{colors.mint}"
    typography: "{typography.num-body}"
    glyph: "= 0 · cân"
    contrast: "5.81:1 ✓"
  validation-unbalanced:
    textColor: "{colors.warning}"
    typography: "{typography.num-body}"
    glyph: "Tổng: −3 ⚠"
    note: "Soft warning — non-blocking. Save remains tappable."
  score-positive:
    textColor: "{colors.mint}"
    typography: "{typography.num-display-lg}"
    sign: "+ (explicit prefix)"
    contrast: "5.81:1 ✓"
  score-negative:
    textColor: "{colors.ochre-warm}"
    typography: "{typography.num-display-lg}"
    sign: "− (explicit prefix)"
    contrast: "4.02:1 — Large only (≥18px)"
    note: "At small sizes (<18px), use {colors.cream} instead and rely on the − sign"
---

## Overview

Phorm is a Vietnamese-vernacular score-tracker for Phỏm / Sâm Lốc / any zero-sum card game. The host at the table holds the phone between rounds and records points; the app totals them and produces a leaderboard. This document describes the visual language — see `themes-preview.html` in this repo for the canonical visual reference; this doc captures the tokens and component specs so the iOS implementation can pull from a single source.

The visual identity is **Vietnamese vernacular print, read through modern design discipline**: lacquer surfaces (cinnabar, ochre, jade), gold-leaf seals (ấn vàng) for the winner, halftone-dot texture, paper grain, display serifs with character. Numerals are not LED — they are inked Cormorant and Noto Serif Display, with IBM Plex Serif tabular figures for column alignment in dense surfaces. The app reads like a lacquered scorebook a friend group keeps, not a trading terminal.

## Surfaces — one drenched color per session

Every session lives on **one lacquer surface**. The default is `{colors.surface-cinnabar}` (#8c2a22) — Tết-red. Alternate session colors (`-ochre`, `-jade`, `-oxblood`) can rotate per session, either auto-assigned or pickable at session create.

There is **no neutral grey, no system canvas** anywhere in the app. The surface is always drenched. This is the principle that separates Phorm from category competitors — the app's screen is the lacquer; everything else is ink, gold, and texture on top.

Every lacquer surface carries three overlays in this order (z-index 1 → 3):

1. `{textures.halftone-dots}` — radial-gradient dot pattern, screen blend, very low opacity
2. `{textures.paper-grain}` — SVG fractal-noise overlay, overlay blend, ~55% opacity
3. Content (z-index 3)

Result: depth and warmth that flat OLED can't produce on its own. This is the visual identity layer; the iOS implementation must reproduce both overlays.

### System appearance

The app does NOT have binary light/dark equal peers. Surface chromatic identity persists across system settings; iOS appearance only subtly deepens or lightens the surface (e.g., cinnabar → cinnabar-deep at night).

## Colors

### Lacquer surfaces (`{colors.surface-*}`)

Pick ONE per session. The surface is the screen, edge-to-edge, with overlays applied. No multi-surface layering, no card-on-canvas pattern with contrasting fills — the surface is the ground, content sits directly on it.

- **Cinnabar** (`{colors.surface-cinnabar}` — `#8c2a22`): Default. Tết red. The reference image in `themes-preview.html` is rendered on this.
- **Ochre** (`{colors.surface-ochre}` — `#a8754a`): Aged wood, late-afternoon warmth. Alternate session color.
- **Jade** (`{colors.surface-jade}` — `#3d6b5c`): Old jade green, cooler register. Alternate.
- **Oxblood** (`{colors.surface-oxblood}` — `#5d1a18`): Deeper cinnabar for night sessions; what the system shifts cinnabar toward in dark mode.

### Ink (`{colors.cream-*}`)

Cream is the "paper" the lacquer is "printed on". Use it for every body-text and label tier.

- **Cream** (`{colors.cream}` — `#f3e8d2`): 6.96:1 on cinnabar. Primary text on every lacquer surface.
- **Cream Dim** (`{colors.cream-dim}` — `#d6c4a0`): 4.94:1. Secondary text, labels, dates, meta.
- **Cream Faint** (`{colors.cream-faint}` — `rgba(243,232,210,0.34)`): UI hairlines (3.02:1, passes 3:1 minimum).
- **Cream Stroke** (`{colors.cream-stroke}` — `rgba(243,232,210,0.18)`): Decorative section dividers (not contrast-critical).

### Gold (`{colors.gold*}`)

Gold is the *single* accent — primary CTAs, the winner's seal, focus borders on active cells, the left-edge rule on history cards. There is no second accent color.

- **Gold** (`{colors.gold}` — `#d9b25a`): 4.27:1 on cinnabar. Use for **display-tier text only** (≥18px) and UI element backgrounds.
- **Gold Bright** (`{colors.gold-bright}` — `#e8c570`): 5.10:1. Required variant for **small-text labels** (9–12px) on cinnabar — passes AA Normal at any size.
- **Gold Dim** (`{colors.gold-dim}` — `#a88438`): Pressed state, disabled affordance.
- **Gold Leaf Tint** (`{colors.gold-leaf-tint}` — `rgba(217,178,90,0.12)`): The faint tablet background used inside the winner's seal box.

### Score semantics (`{colors.mint}` / `{colors.ochre-warm}`)

- **Mint** (`{colors.mint}` — `#b6e0c2`): 5.81:1 on cinnabar. Positive scores at ALL sizes.
- **Ochre Warm** (`{colors.ochre-warm}` — `#e6a665`): 4.02:1 on cinnabar. Negative scores **at ≥18px display weight only**. At small sizes, use `{colors.cream}` and rely on the `−` sign for direction.

Both pair with an explicit `+`/`−` prefix — color-blind users see direction from the sign, not the hue.

## Textures

The halftone-dot + paper-grain combination is the visual identity at the surface level. Both must be present on every lacquer surface:

```css
.lacquer::before {
  content: "";
  position: absolute; inset: 0;
  background-image: radial-gradient(rgba(243, 232, 210, 0.06) 1px, transparent 1px);
  background-size: 4px 4px;
  mix-blend-mode: screen;
}
.lacquer::after {
  content: "";
  position: absolute; inset: 0;
  background-image: url("data:image/svg+xml;utf8,<svg ...>");  /* fractalNoise */
  mix-blend-mode: overlay;
  opacity: 0.55;
}
```

In SwiftUI, reproduce halftone via a tiled `Canvas` or a repeating `PatternImage`; reproduce grain via a precomputed PNG/SVG noise texture overlaid with `.blendMode(.overlay)`. Both should adapt opacity to Reduce Motion / Reduce Transparency (lower opacity or remove entirely if the user has enabled these).

## Typography

### Font Family

Three families, each with one job:

- **Noto Serif Display** — large display sizes (≥20px), session titles, numerals at hero scales. Full Vietnamese diacritic coverage.
- **Cormorant Garamond** — italic player names (gives a signature feel), auto-fill computed numerals (italic signals "machine wrote this"), display tags. Vietnamese-ready.
- **IBM Plex Serif** — small-size numerals with tabular figures for column alignment (round history strips, dense meta, validation totals).
- **Spectral** — body copy, UI labels, descriptions. Vietnamese-ready, pairs cleanly with the other serifs.

There is **no sans-serif** in the app. The entire interface runs on serif type. Numbers are inked, not displayed.

All four families are available via Google Fonts; for iOS, bundle them as in-app fonts and register via Info.plist. SF Mono is **forbidden** — its presence anywhere in the app is a category-reflex failure.

### Vietnamese diacritic verification

The picked typefaces all support Vietnamese diacritics, but verify against representative names in design review:

- Quý (ý), Nam, Linh, Hoàng (à)
- Diacritic stack: ặ, ằ, ẵ, ẳ, ậ, ầ, ẫ, ẩ, ấ, ố, ồ, ỗ, ổ, ố, ợ, ờ, ỡ, ở, ớ, ự, ừ, ữ, ử, ứ, ỵ, ỳ, ỹ, ỷ, ý
- Đ / đ rendering at small sizes (label-caps tier — 9px uppercase letter-spaced)

If any font fails on small-size Đ rendering, override to Noto Sans (with Đ verified) for labels only; keep the serifs everywhere else.

## Layout

### Spacing

Same scale as before (`{spacing.xxs}` 4px → `{spacing.section}` 56px). Screen margins 20px on iPhone. The app stays dense — most surfaces use 12–20px between elements, not 32–56px.

### Container philosophy

**No cards on neutral canvas.** Content sits directly on the lacquer surface. Where separation is needed, use:

1. A horizontal cream-faint hairline (1px at 34% opacity) — section dividers
2. A horizontal cream-stroke decorative line (1px at 18% opacity) — visual breathing
3. The `{components.card-history}` darker-tint card — *only* for history rows where the meta density warrants a visual frame

Never wrap content in nested cards. The lacquer + halftone + paper grain is the visual framing.

## Components

The component table in the YAML frontmatter is the source of truth. Highlights:

### Buttons

`{components.button-primary}` — Gold-filled, cinnabar-deep text, uppercase Spectral label, sharp 3px radius (tighter than iOS default to match the print register). One CTA per screen — never two equal-weight primary buttons.

`{components.button-secondary-outline}` — Transparent fill, gold border, gold text. Paired with primary for cases like "Chia sẻ + Phiên mới" on the end-of-session screen.

### Seals (rank boxes)

The leaderboard rank seals are the heart of the visual identity. Three variants:

- `{components.seal-default}` — gold-border + faint gold tint + gold character (壹/贰/叁/肆 for positions 1-4 by default; can use Latin 1/2/3/4 if users prefer)
- `{components.seal-winner}` — solid gold fill + cinnabar-deep character + glow shadow. The "ấn vàng" — the only true celebration the app earns.
- `{components.seal-last}` — cream-dim border + cream-dim ×. Only renders on 4+-player sessions.

### Round-entry cells

`{components.cell-input}` → `{components.cell-input-active}` → `{components.cell-input-sealed}` shows the progression: idle → focused (gold border + cursor) → auto-filled (gold-dim border + computed value in `{typography.num-script}` italic + `{components.seal-stamp-mini}` 封 stamp).

The 封 stamp animates in with `h-stamp 700ms` when the last cell auto-fills — the single most "fun" moment in the app.

### History card

`{components.card-history}` — darker-tint card on the lacquer, with a 3px gold left-edge rule. Newest sessions at full opacity; older sessions fade to 70%, then 50%, then drop to a flat row treatment (no card frame at all) for archive depth.

## Motion

Motion is sparse and physical, not bouncy. Three vocabulary elements:

- **h-stamp** (700ms, cubic-bezier(0.22, 1, 0.36, 1)): Scale 0.7 → 1.08 → 1, rotate −8° → −3°. Used for any seal stamp landing (winner ấn vàng on end-of-session, 封 on auto-fill).
- **float-in** (600ms): Translate Y +8px → 0 with opacity fade. Used for leaderboard rows on initial load, staggered 80ms apart.
- **caret blink** (1s steps(1)): The text-entry cursor in active cells.

Don't introduce bounce, elastic, or confetti motion. The app is matter-of-fact.

## Accessibility

### Contrast — measured on cinnabar (`#8c2a22`)

All small-text + UI combinations have been measured. The audit lives at the top of each token in the YAML frontmatter (`contrast:` field). Summary:

| Combination | Ratio | WCAG | Use |
|---|---|---|---|
| Cream on cinnabar | 6.96:1 | AA+ Normal | Body text |
| Cream-dim on cinnabar | 4.94:1 | AA Normal | Labels, meta |
| Gold-bright on cinnabar | 5.10:1 | AA Normal | Small gold labels |
| Gold on cinnabar | 4.27:1 | AA Large only | Display sizes ≥18px |
| Mint on cinnabar | 5.81:1 | AA Normal | Positive scores |
| Ochre-warm on cinnabar | 4.02:1 | AA Large only | Negative scores ≥18px |
| Cinnabar-deep on gold | 6.76:1 | AA Normal+ | Button text, seal characters |
| Cream-faint on cinnabar (UI line) | 3.02:1 | 3:1 minimum | Hairlines |

When extending to other surfaces (ochre, jade, oxblood), the same audit must be re-run; token contrast ratios are **surface-specific**, not absolute.

### Color-blind parity

Score direction is always communicated by:

1. Mint vs. ochre text color (primary)
2. Explicit `+` / `−` sign prefix (color-blind backup)
3. For ranking: ấn vàng (winner) vs. tem chéo × (last) — visual shape, not color

Never rely on hue alone.

### Dynamic Type

Spectral body, Cormorant name, Spectral label-caps all scale with iOS Dynamic Type. Numeric tiers (`num-hero`, `num-display-lg`, `num-display-md`) opt out at the leaderboard / round-entry tier to preserve column alignment — deliberate trade-off, deliberate weight tradeoff.

### Reduce Motion / Reduce Transparency

- Reduce Motion: drop `h-stamp` animation (instant snap-in); drop `float-in` (no row stagger).
- Reduce Transparency: deepen `{textures.paper-grain}` to opaque tint or drop it entirely; halftone dots can remain (decorative, no content sits behind them).

## Do's and Don'ts

### Do
- Drench each session in a single lacquer surface. The surface IS the screen.
- Apply halftone + paper grain to every lacquer surface, every screen. Both layers, in order.
- Use `{colors.gold}` for display-tier text (≥18px) and `{colors.gold-bright}` for small labels. Two-tone gold is the system's contrast contract.
- Use the winner seal (ấn vàng) as the *only* celebratory moment. Restraint everywhere else.
- Pair score colors with `+` / `−` prefixes. Always.
- Set all display fonts to verify Vietnamese diacritic rendering at small sizes — Đ is the canary.
- Render every numeric in `font-variant-numeric: tabular-nums` so columns stay aligned.

### Don't
- Don't introduce a second accent color. Gold does all accent work — no secondary brand color.
- Don't use SF Mono anywhere. Forbidden.
- Don't use Liquid Glass. The texture system replaces it.
- Don't use cards-on-neutral-canvas patterns. Content sits directly on the lacquer.
- Don't add confetti, mascots, or "🎉 You won!" moments. The ấn vàng is the celebration.
- Don't tint scores green/red as card backgrounds. Color is text only.
- Don't replace gold with brighter yellow "to be safer" — `{colors.gold-bright}` exists for small labels; the rich `{colors.gold}` is the brand voltage.
- Don't soften the display weight. Noto Serif Display 700–800 is the floor for the hero tier.
- Don't override the surface color per screen unless it's an alternate-session-color setup. One session = one surface.

## Iteration Guide

1. Visual canon is `themes-preview.html` at the repo root. When tokens here disagree with the preview, the preview wins; update the doc.
2. When proposing a new component, decide first: does it live on the lacquer surface (yes — 95% of cases) or is it a chrome layer (rare — only for sheets/modals)? Lacquer-native components inherit halftone + grain; chrome components need their own surface treatment specified.
3. Reference tokens (`{colors.cinnabar}`, `{typography.num-display-md}`) in component definitions, not raw hex. Centralized tokens enforce the contrast contract.
4. Variants of an existing component (`-active`, `-sealed`, `-winner`) live as separate entries in `components:`, not as nested state objects.
5. Every new component must declare its contrast ratio against its surface in the YAML. If it fails AA, the component fails review.
6. Numbers always use Noto Serif Display (large) or IBM Plex Serif (small) with `font-variant-numeric: tabular-nums`. Italic Cormorant is reserved for computed/auto-fill values and player names; never use it for committed score values.

## Known Gaps

- Animation timings for sheet present / dismiss are not formalized — use SwiftUI default `.snappy` / `.spring()` until measured.
- The split-view layout on iPad regular width is not designed (the lacquer surface assumes single-pane). When iPad lands, decide: full-bleed surface on both panes (two lacquer canvases) or chrome boundary between sidebar and detail.
- Widget / Lock-Screen treatments are out of scope for MVP.
- App Icon: a cinnabar tile with a gold 壹 seal centered is the proposed direction; needs explicit asset work.
- Empty state visual is not in `themes-preview.html` yet — needs to be designed before HomeView builds.
- Alternate-session-color picker UX is not designed — for MVP, cinnabar is the only surface.
