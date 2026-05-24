---
version: alpha
name: saam-app-design
description: A confident score-tracker interface for iOS — a personal-use Phỏm/Sâm card-game scorekeeper where one player at a table holds the phone and records points after each round. The product follows the system appearance (light and dark are equal peers), with a single saturated yellow (#FCD535) carrying every primary action and brand moment. Surfaces use Apple's Liquid Glass material — translucent navigation bars, sheets, and the in-app keypad — so chrome layers into the canvas instead of pasting on top. SF Pro Display / SF Pro Text handle copy; SF Mono handles every numeric (round scores, running totals, rankings) so digits stay column-aligned as values tick. Green (#0ecb81) marks a player who is up; red (#f6465d) marks a player who is down — applied as text color, never as a card fill.

colors:
  primary: "#fcd535"
  primary-active: "#f0b90b"
  primary-disabled: "#3a3a1f"
  ink: "#181a20"
  body: "#eaecef"
  body-on-light: "#181a20"
  muted: "#707a8a"
  muted-strong: "#929aa5"
  hairline-on-light: "#eaecef"
  hairline-on-dark: "#2b3139"
  border-strong: "#cdd1d6"
  canvas-light: "#ffffff"
  canvas-dark: "#0b0e11"
  surface-card-dark: "#1e2329"
  surface-elevated-dark: "#2b3139"
  surface-soft-light: "#fafafa"
  surface-strong-light: "#f5f5f5"
  on-primary: "#181a20"
  on-dark: "#ffffff"
  score-positive: "#0ecb81"
  score-negative: "#f6465d"
  score-positive-tint-light: "#e8faf2"
  score-negative-tint-light: "#fdecef"
  score-positive-tint-dark: "rgba(14, 203, 129, 0.14)"
  score-negative-tint-dark: "rgba(246, 70, 93, 0.14)"
  warning: "#ff9500"
  info: "#3b82f6"
  info-ring: "#3b82f6"
  glass-tint-dark: "rgba(30, 35, 41, 0.62)"
  glass-tint-light: "rgba(255, 255, 255, 0.68)"
  glass-stroke-dark: "rgba(255, 255, 255, 0.08)"
  glass-stroke-light: "rgba(24, 26, 32, 0.06)"
  glass-specular: "rgba(255, 255, 255, 0.14)"
  focus-row-tint-dark: "rgba(252, 213, 53, 0.12)"
  focus-row-tint-light: "rgba(252, 213, 53, 0.16)"

materials:
  glass-regular-dark:
    base: "{colors.glass-tint-dark}"
    backdropFilter: "blur(28px) saturate(180%)"
    stroke: "1px {colors.glass-stroke-dark}"
    specularHighlight: "{colors.glass-specular}"
    use: "Navigation bar, in-app keypad container, autosuggest dropdown over dark canvas"
  glass-regular-light:
    base: "{colors.glass-tint-light}"
    backdropFilter: "blur(28px) saturate(180%)"
    stroke: "1px {colors.glass-stroke-light}"
    specularHighlight: "{colors.glass-specular}"
    use: "Navigation bar, in-app keypad container, autosuggest dropdown over light canvas"
  glass-clear:
    base: "rgba(255, 255, 255, 0.04)"
    backdropFilter: "blur(40px) saturate(160%)"
    stroke: "1px {colors.glass-stroke-dark}"
    specularHighlight: "{colors.glass-specular}"
    use: "Floating sticky FAB over the scrolling round-card list"
  glass-thick-sheet:
    base: "rgba(11, 14, 17, 0.78)"
    backdropFilter: "blur(48px) saturate(180%)"
    stroke: "1px {colors.glass-stroke-dark}"
    specularHighlight: "{colors.glass-specular}"
    use: "Full-screen round-entry sheet, new-session sheet, import-confirm modal — readability dominates"

typography:
  hero-display:
    fontFamily: "SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: 40px
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: -0.6px
  display-lg:
    fontFamily: "SF Pro Display, sans-serif"
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: -0.4px
  display-md:
    fontFamily: "SF Pro Display, sans-serif"
    fontSize: 28px
    fontWeight: 600
    lineHeight: 1.15
    letterSpacing: -0.3px
  title-lg:
    fontFamily: "SF Pro Display, sans-serif"
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: -0.1px
  title-md:
    fontFamily: "SF Pro Display, sans-serif"
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.35
    letterSpacing: 0
  title-sm:
    fontFamily: "SF Pro Text, sans-serif"
    fontSize: 17px
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: 0
  number-ranking:
    fontFamily: "SF Mono, sans-serif"
    fontSize: 28px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: -0.2px
  number-entry:
    fontFamily: "SF Mono, sans-serif"
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0
  number-md:
    fontFamily: "SF Mono, sans-serif"
    fontSize: 17px
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: 0
  number-sm:
    fontFamily: "SF Mono, sans-serif"
    fontSize: 15px
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: 0
  number-chip:
    fontFamily: "SF Mono, sans-serif"
    fontSize: 17px
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: 0
  body-md:
    fontFamily: "SF Pro Text, sans-serif"
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: 0
  body-sm:
    fontFamily: "SF Pro Text, sans-serif"
    fontSize: 13px
    fontWeight: 400
    lineHeight: 1.45
    letterSpacing: 0
  caption:
    fontFamily: "SF Pro Text, sans-serif"
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.35
    letterSpacing: 0.1px
  caption-section:
    fontFamily: "SF Pro Text, sans-serif"
    fontSize: 10px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0.6px
    textTransform: uppercase
  button:
    fontFamily: "SF Pro Text, sans-serif"
    fontSize: 17px
    fontWeight: 600
    lineHeight: 1
    letterSpacing: 0
  keypad-digit:
    fontFamily: "SF Pro Display, sans-serif"
    fontSize: 26px
    fontWeight: 400
    lineHeight: 1
    letterSpacing: 0

rounded:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 22px
  pill: 9999px
  full: 9999px

spacing:
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
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button}"
    rounded: "{rounded.lg}"
    padding: 16px 24px
    height: 54px
    note: "Used full-width on empty state, new-session 'Bắt đầu', round-entry 'Lưu ván', and as the sticky bottom FAB '+ Ván N'"
  button-primary-active:
    backgroundColor: "{colors.primary-active}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.lg}"
  button-primary-disabled:
    backgroundColor: "{colors.primary-disabled}"
    textColor: "{colors.muted}"
    rounded: "{rounded.lg}"
  button-secondary-glass:
    material: "{materials.glass-regular-dark} | {materials.glass-regular-light}"
    textColor: "{colors.on-dark} | {colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.lg}"
    padding: 16px 24px
    height: 54px
  button-destructive-text:
    backgroundColor: transparent
    textColor: "{colors.score-negative}"
    typography: "{typography.title-sm}"
  button-tertiary-text:
    backgroundColor: transparent
    textColor: "{colors.primary}"
    typography: "{typography.button}"
  button-compact-pill:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.caption}"
    rounded: "{rounded.pill}"
    padding: 6px 14px
    height: 28px
  reuse-group-card:
    material: "{materials.glass-regular-dark} | {materials.glass-regular-light}"
    textColor: "{colors.on-dark} | {colors.ink}"
    accentColor: "{colors.primary}"
    typography: "{typography.title-sm}"
    rounded: "{rounded.lg}"
    padding: 16px 20px
  nav-bar-glass:
    material: "{materials.glass-regular-dark} | {materials.glass-regular-light}"
    titleColor: "{colors.on-dark} | {colors.ink}"
    subtitleColor: "{colors.muted-strong} | {colors.muted}"
    typography: "{typography.title-sm}"
    height: 56px
  empty-state:
    backgroundColor: "{colors.canvas-dark} | {colors.canvas-light}"
    iconColor: "{colors.muted}"
    titleColor: "{colors.body} | {colors.ink}"
    subtitleColor: "{colors.muted}"
    typography: "{typography.body-md}"
    padding: 0 32px
  totals-chip-row:
    backgroundColor: "{colors.surface-card-dark} | {colors.canvas-light}"
    sectionLabelColor: "{colors.muted}"
    typography: "{typography.caption-section}"
    padding: 12px 16px
    gap: 8px
  score-chip-positive:
    backgroundColor: "{colors.score-positive-tint-dark} | {colors.score-positive-tint-light}"
    nameColor: "{colors.muted-strong} | {colors.muted}"
    valueColor: "{colors.score-positive}"
    valueTypography: "{typography.number-chip}"
    rounded: "{rounded.md}"
    padding: 8px 12px
  score-chip-negative:
    backgroundColor: "{colors.score-negative-tint-dark} | {colors.score-negative-tint-light}"
    nameColor: "{colors.muted-strong} | {colors.muted}"
    valueColor: "{colors.score-negative}"
    valueTypography: "{typography.number-chip}"
    rounded: "{rounded.md}"
    padding: 8px 12px
  score-chip-zero:
    backgroundColor: "{colors.surface-elevated-dark} | {colors.surface-strong-light}"
    nameColor: "{colors.muted-strong} | {colors.muted}"
    valueColor: "{colors.body} | {colors.ink}"
    valueTypography: "{typography.number-chip}"
    rounded: "{rounded.md}"
    padding: 8px 12px
  round-card:
    backgroundColor: "{colors.surface-card-dark} | {colors.canvas-light}"
    textColor: "{colors.body} | {colors.ink}"
    labelColor: "{colors.muted}"
    typography: "{typography.body-md}"
    rounded: "{rounded.lg}"
    padding: 16px
    gap: 12px
  round-card-score-positive:
    backgroundColor: transparent
    textColor: "{colors.score-positive}"
    typography: "{typography.number-md}"
  round-card-score-negative:
    backgroundColor: transparent
    textColor: "{colors.score-negative}"
    typography: "{typography.number-md}"
  fab-bottom-cta:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button}"
    rounded: "{rounded.lg}"
    padding: 16px 24px
    height: 54px
    margin: 0 20px
    positioning: "sticky, anchored above safe area, full-width minus 20px gutters"
  sheet-surface:
    material: "{materials.glass-thick-sheet}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.xl}"
    padding: "20px (varies by surface)"
    note: "Full-screen RoundEntryView, NewSessionView, ImportConfirmView use this material as the sheet floor"
  round-entry-row:
    backgroundColor: transparent
    nameColor: "{colors.body} | {colors.ink}"
    valueColor: "{colors.body} | {colors.ink}"
    nameTypography: "{typography.title-sm}"
    valueTypography: "{typography.number-entry}"
    rounded: "{rounded.sm}"
    padding: 12px 8px
    divider: "1px {colors.hairline-on-dark} | {colors.hairline-on-light}"
  round-entry-row-focused:
    backgroundColor: "{colors.focus-row-tint-dark} | {colors.focus-row-tint-light}"
    nameColor: "{colors.body} | {colors.ink}"
    valueColor: "{colors.primary}"
    valueTypography: "{typography.number-entry}"
    rounded: "{rounded.sm}"
    padding: 12px 8px
    accent: "2px bottom border {colors.primary}"
  score-auto-fill-text:
    backgroundColor: transparent
    textColor: "{colors.muted}"
    typography: "{typography.number-entry}"
    fontStyle: italic
    suffix: "auto"
  sum-indicator-ok:
    backgroundColor: "{colors.score-positive-tint-dark} | {colors.score-positive-tint-light}"
    labelColor: "{colors.muted-strong} | {colors.muted}"
    valueColor: "{colors.score-positive}"
    valueTypography: "{typography.title-sm}"
    rounded: "{rounded.md}"
    padding: 10px 16px
    glyph: "checkmark.circle.fill (SF Symbol)"
  sum-indicator-warning:
    backgroundColor: "rgba(255, 149, 0, 0.14)"
    labelColor: "{colors.muted-strong} | {colors.muted}"
    valueColor: "{colors.warning}"
    valueTypography: "{typography.title-sm}"
    rounded: "{rounded.md}"
    padding: 10px 16px
    glyph: "exclamationmark.triangle.fill (SF Symbol)"
  keypad-container:
    material: "{materials.glass-thick-sheet}"
    padding: 8px
    gap: 6px
    columns: 3
    safeAreaInset: bottom
  keypad-key-digit:
    backgroundColor: "{colors.surface-elevated-dark} | {colors.canvas-light}"
    textColor: "{colors.on-dark} | {colors.ink}"
    typography: "{typography.keypad-digit}"
    rounded: "{rounded.md}"
    height: 56px
  keypad-key-utility:
    backgroundColor: "{colors.surface-card-dark} | {colors.surface-soft-light}"
    textColor: "{colors.body} | {colors.ink}"
    typography: "{typography.keypad-digit}"
    rounded: "{rounded.md}"
    height: 56px
    note: "Used for ± and ⌫ (SF Symbol delete.left.fill)"
  text-field:
    backgroundColor: "{colors.surface-elevated-dark} | {colors.surface-strong-light}"
    textColor: "{colors.body} | {colors.ink}"
    placeholderColor: "{colors.muted}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    padding: 12px 16px
    height: 50px
  text-field-name-inline:
    backgroundColor: transparent
    textColor: "{colors.body} | {colors.ink}"
    typography: "{typography.title-sm}"
    note: "Inline-edit session name in nav bar — no chrome until focused"
  player-chip-removable:
    backgroundColor: "{colors.surface-elevated-dark} | {colors.surface-strong-light}"
    textColor: "{colors.body} | {colors.ink}"
    typography: "{typography.body-md}"
    rounded: "{rounded.pill}"
    padding: 6px 12px
    height: 32px
    removeGlyph: "xmark.circle.fill (SF Symbol)"
  player-chip-input-placeholder:
    backgroundColor: transparent
    textColor: "{colors.muted}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    padding: 10px 14px
    border: "1.5px dashed {colors.hairline-on-dark} | {colors.hairline-on-light}"
  autosuggest-dropdown:
    material: "{materials.glass-regular-dark} | {materials.glass-regular-light}"
    rowTextColor: "{colors.body} | {colors.ink}"
    rowMetaColor: "{colors.muted}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    padding: 4px 0
    rowPadding: 12px 16px
  ranking-card-first:
    backgroundColor: "{colors.surface-card-dark} | {colors.canvas-light}"
    accentBorder: "2px {colors.primary}"
    titleColor: "{colors.body} | {colors.ink}"
    metaColor: "{colors.muted}"
    valueColor: "{colors.score-positive}"
    valueTypography: "{typography.number-ranking}"
    rounded: "{rounded.lg}"
    padding: 16px 20px
    glyph: "🥇 (emoji, 28pt)"
  ranking-card-default:
    backgroundColor: "{colors.surface-card-dark} | {colors.canvas-light}"
    titleColor: "{colors.body} | {colors.ink}"
    metaColor: "{colors.muted}"
    valueColor: "computed: {colors.score-positive} if value > 0 else {colors.score-negative}"
    valueTypography: "{typography.number-ranking}"
    rounded: "{rounded.lg}"
    padding: 16px 20px
    glyph: "🥈 / 🥉 / numeral (28pt)"
  ranking-card-last:
    backgroundColor: "{colors.surface-card-dark} | {colors.canvas-light}"
    accentBorder: "2px {colors.score-negative}"
    titleColor: "{colors.body} | {colors.ink}"
    metaColor: "{colors.muted}"
    valueColor: "{colors.score-negative}"
    valueTypography: "{typography.number-ranking}"
    rounded: "{rounded.lg}"
    padding: 16px 20px
    glyph: "💀 (28pt)"
  summary-header:
    backgroundColor: "{colors.surface-card-dark} | {colors.canvas-light}"
    titleColor: "{colors.body} | {colors.ink}"
    metaColor: "{colors.muted}"
    titleTypography: "{typography.title-lg}"
    metaTypography: "{typography.body-sm}"
    padding: 24px 20px
    centered: true
    glyph: "🏆 (32pt)"
  history-row:
    backgroundColor: "{colors.surface-card-dark} | {colors.canvas-light}"
    titleColor: "{colors.body} | {colors.ink}"
    playersColor: "{colors.muted}"
    timeColor: "{colors.muted}"
    countChipBg: "{colors.surface-elevated-dark} | {colors.surface-strong-light}"
    winnerChipColor: "{colors.score-positive}"
    rounded: "{rounded.lg}"
    padding: 16px
  import-confirm-modal:
    material: "{materials.glass-thick-sheet}"
    iconBg: "{colors.primary}"
    iconColor: "{colors.on-primary}"
    titleColor: "{colors.on-dark}"
    titleTypography: "{typography.title-lg}"
    previewBg: "{colors.surface-elevated-dark}"
    previewRounded: "{rounded.lg}"
    padding: 24px
  share-sheet:
    note: "Uses iOS system share sheet — Liquid Glass material is provided by UIKit. App contributes only the URL + display title."
---

## Overview

The design system runs a personal-use card-game score tracker (Phỏm / Sâm Lốc / any pen-and-paper game) where one person at the table holds the phone and records points after each round. The product is built on three rules — offline-first, fast, no onboarding — and the visual language follows the same restraint: one accent color, two type families, one chrome material, no decoration.

The base atmosphere is built around a single, ubiquitous accent: **signal yellow** (`{colors.primary}` — #FCD535). Yellow carries the empty-state primary CTA, the "+ Ván" sticky FAB at the bottom of every session, the "Lưu ván" confirm in the round-entry sheet, the focus highlight on the active input row, the active leader's first-place accent border, and the brand mark in the nav bar. There is no secondary brand color. The system trusts the yellow voltage to do the brand work, and it carries it.

Surfaces follow Apple's **Liquid Glass** material model. The navigation bar, the custom in-app keypad, the autosuggest dropdown, and the floating "+ Ván" FAB are translucent panels that refract the canvas and content beneath them, picking up subtle specular highlights at their edges. Full-screen sheets (round entry, new session, import confirm) use the heavier `{materials.glass-thick-sheet}` where readability dominates over translucency. Content surfaces — round cards, ranking cards, history rows, totals chips — stay opaque so the glass language reads as chrome, not wallpaper.

Type runs Apple's **SF Pro Display / SF Pro Text** stack for editorial copy, and **SF Mono** for every numerical surface — round scores, running totals on chips, ranking values, sum indicators. The split is functional: SF Mono's tabular figures align in chip columns and on the round-entry list as digits tick, while SF Pro Text handles paragraph-level legibility. Display sizes use weight 600–700 — heavier than typical iOS marketing because the app is fundamentally a number-reading surface.

The product **follows the system appearance**: iOS decides whether to render in light or dark, and every screen renders correctly in either. Tokens come in `-dark` and `-light` pairs (canvas, surface, hairline, glass tint) and the renderer picks the matching one from `userInterfaceStyle`. The same yellow CTAs, the same green / red score semantics, and the same component shapes thread through both — only canvas, surface, and text tones flip.

**Green** (`{colors.score-positive}` — #0ecb81) marks a player who is **up** for the session — positive running total. **Red** (`{colors.score-negative}` — #f6465d) marks a player who is **down** — negative running total. Same hex applies at the round-card level (a single round's score) and the session-total level (cumulative chips, ranking card). These are price-direction colors borrowed from trading interfaces — same semantics (gain / loss), different domain (card scores instead of asset prices). Never use them as card backgrounds — always as text color, with optional faint tinted fills on chips (`{colors.score-positive-tint-light}` / `-dark`) to lift them off the surface.

**Key Characteristics:**
- Single accent color: `{colors.primary}` (#FCD535) does all brand voltage — primary CTAs, focus highlights, first-place accent border, brand mark. Identical hex in both modes.
- iOS system type: `SF Pro Display` for headlines and large titles, `SF Pro Text` for body and buttons, `SF Mono` for every number. Round scores, chip totals, ranking values, sum indicators — all SF Mono for column-aligned tabular figures.
- Liquid Glass chrome: nav bar, keypad container, autosuggest dropdown, FAB use `{materials.glass-regular-*}`; full-screen sheets use `{materials.glass-thick-sheet}`. Content cards (round, ranking, history) stay opaque.
- System-driven appearance: every screen has a light and dark realization; iOS picks based on the user's preference. Canvas, surface, hairline, glass tint, and body text tokens flip; yellow and score semantics do not.
- Score color semantics: green up / red down for cumulative totals and per-round scores. Text color, not card surface. Zero is a neutral token (`{component.score-chip-zero}`) — never green or red.
- Border radius follows iOS conventions: `{rounded.sm}` (8px) for keypad keys and inline focus chips, `{rounded.md}` (12px) for text fields, `{rounded.lg}` (16px) for content cards, ranking cards, history rows, and primary buttons, `{rounded.xl}` (22px) for full-screen sheet corners — all rendered with the iOS continuous corner curve.
- Tight spacing: `{spacing.section}` (56px) between editorial bands is rare — the app is dense by design. Screen margins are 20px; round cards stack at 12px gap; chips in the totals row gap at 8px.

## Colors

### Brand & Accent
- **Signal Yellow** (`{colors.primary}` — #FCD535): The single brand color. Primary CTA backgrounds, the "+ Ván" FAB, "Lưu ván" / "Bắt đầu" / "Tạo session mới", the focus tint on the active round-entry row, the first-place ranking accent border, and the icon background on the import-confirm modal.
- **Signal Yellow Active** (`{colors.primary-active}` — #f0b90b): The pressed-state variant.
- **Signal Yellow Disabled** (`{colors.primary-disabled}` — #3a3a1f): A desaturated dark-yellow used on disabled CTAs over dark canvas.

### Surface

Surfaces come in mirrored light / dark pairs. Components reference a semantic role (`canvas`, `surface-card`, `surface-elevated`); the renderer resolves the matching hex from `userInterfaceStyle`.

**Dark realization:**
- **Canvas Dark** (`{colors.canvas-dark}` — #0b0e11): The primary screen floor in dark mode. Near-black with a slight warm tint — never pure black.
- **Surface Card Dark** (`{colors.surface-card-dark}` — #1e2329): Opaque round cards, ranking cards, history rows, summary header. The default "elevated content" surface on dark.
- **Surface Elevated Dark** (`{colors.surface-elevated-dark}` — #2b3139): One step lighter — text-field background, keypad digit-key background, history row chips.

**Light realization:**
- **Canvas Light** (`{colors.canvas-light}` — #ffffff): The primary screen floor in light mode. Also the surface for opaque cards on light (round cards, ranking cards, history rows).
- **Surface Soft Light** (`{colors.surface-soft-light}` — #fafafa): Keypad utility-key background, disabled states.
- **Surface Strong Light** (`{colors.surface-strong-light}` — #f5f5f5): Text-field background, history row chips.

### Glass Tint
- **Glass Tint Dark** (`{colors.glass-tint-dark}` — rgba(30, 35, 41, 0.62)): The translucent base for `{materials.glass-regular-dark}`. Sits over `{colors.canvas-dark}` and picks up content tint as content scrolls beneath.
- **Glass Tint Light** (`{colors.glass-tint-light}` — rgba(255, 255, 255, 0.68)): Light-mode equivalent.
- **Glass Stroke Dark / Light**: 1px hairline at the panel edge — defines the glass without reading as a hard border.
- **Glass Specular** (`{colors.glass-specular}` — rgba(255, 255, 255, 0.14)): The faint highlight running along the top edge of every glass panel.

### Hairlines & Borders
- **Hairline on Light** (`{colors.hairline-on-light}` — #eaecef): 1px divider between round-entry rows on light cards, between history rows.
- **Hairline on Dark** (`{colors.hairline-on-dark}` — #2b3139): Same role on dark.
- **Border Strong** (`{colors.border-strong}` — #cdd1d6): Disabled secondary button border.

### Text
- **Ink** (`{colors.ink}` — #181a20): The strongest text on light surfaces. Round-card player names, ranking names, history titles.
- **Body on Dark** (`{colors.body}` — #eaecef): Default running-text on dark canvas — deliberately not pure white.
- **Body on Light** (`{colors.body-on-light}` — #181a20): Reuses ink.
- **Muted** (`{colors.muted}` — #707a8a): Round-card meta ("Ván 3 · 19:48"), history row meta ("Hôm qua"), section labels ("TỔNG", "Tên session"), player chip name labels.
- **Muted Strong** (`{colors.muted-strong}` — #929aa5): Slightly stronger muted for player names inside score chips on dark.
- **On Primary** (`{colors.on-primary}` — #181a20): Black text on yellow primary CTAs.
- **On Dark** (`{colors.on-dark}` — #ffffff): Pure white for highest-contrast titles on dark sheet surfaces.

### Score Semantics
- **Score Positive** (`{colors.score-positive}` — #0ecb81): Cumulative total is up for the session; a single round's score is positive; sum indicator is balanced (0 ✓). Applied as text color in score chips, round cards, ranking cards, sum indicator. Paired with a `+` prefix for positive numbers.
- **Score Negative** (`{colors.score-negative}` — #f6465d): Cumulative total is down; a single round's score is negative. Paired with a `−` prefix (rendered automatically by the value).
- **Score Positive / Negative Tints** (`*-tint-light` / `*-tint-dark`): Faint background fills used only on `{component.score-chip-positive}` / `{component.score-chip-negative}` to lift the chip off the surface row. Never used on round cards or ranking cards.
- **Warning** (`{colors.warning}` — #ff9500): The cumulative sum of round-entry inputs is non-zero — possible miskeypress. Surfaces only in `{component.sum-indicator-warning}`. iOS system orange.

### Focus & Info
- **Focus Row Tint** (`{colors.focus-row-tint-*}` — yellow at 12–16% alpha): The background of the active input row in the round-entry sheet. A yellow wash so the focus state inherits the brand voltage rather than borrowing iOS system blue.
- **Info Ring** (`{colors.info-ring}` — #3b82f6): External-keyboard focus ring for text fields. Only surfaces on iPad with hardware keyboard.

## Materials (Liquid Glass)

Liquid Glass is the system's chrome material — translucent surfaces that refract whatever sits beneath, edge-lit with a faint specular highlight along the top. Glass is for **chrome, not content**: nav bar, keypad container, autosuggest dropdown, the sticky FAB, and full-screen sheets. Content surfaces (round cards, ranking cards, history rows, summary header) stay opaque so the glass language doesn't dilute into wallpaper.

| Token | Backdrop | Tint | Use |
|---|---|---|---|
| `{materials.glass-regular-dark}` | blur(28px) saturate(180%) | `{colors.glass-tint-dark}` | Nav bar, autosuggest dropdown, secondary glass button on dark |
| `{materials.glass-regular-light}` | blur(28px) saturate(180%) | `{colors.glass-tint-light}` | Same on light canvas |
| `{materials.glass-clear}` | blur(40px) saturate(160%) | rgba(255, 255, 255, 0.04) | Reserved for floating elements over rich content (rarely used in this app) |
| `{materials.glass-thick-sheet}` | blur(48px) saturate(180%) | rgba(11, 14, 17, 0.78) | Full-screen RoundEntryView, NewSessionView, ImportConfirmView, keypad container |

Every glass surface carries a 1px stroke (`{colors.glass-stroke-dark}` / `-light`) and a top-edge specular highlight (`{colors.glass-specular}`). In SwiftUI, render with `.background(.regularMaterial)` or `.background(.thickMaterial)` — these adapt automatically to **Reduce Transparency** and **Increase Contrast** accessibility settings. When Reduce Transparency is on, glass falls back to its solid tint equivalent (`{colors.surface-card-dark}` / `{colors.canvas-light}` for `regular`; `{colors.canvas-dark}` for `thick`).

## Typography

### Font Family
- **SF Pro Display** — display, title, large headlines (≥20pt) and the keypad digits.
- **SF Pro Text** — body, button labels, captions, section labels (<20pt).
- **SF Mono** — every number: round scores, chip values, ranking values, sum indicator, auto-fill suggestions.

All three ship with iOS — no licensing, no custom font loading. Web preview fallback walks `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`.

### Hierarchy

| Token | Size | Weight | Use |
|---|---|---|---|
| `{typography.hero-display}` | 40px / 700 | Empty-state title (rare — most screens skip this size) |
| `{typography.display-lg}` | 32px / 700 | Summary header title |
| `{typography.display-md}` | 28px / 600 | Standalone modal titles (import confirm) |
| `{typography.title-lg}` | 22px / 600 | Summary header session name, import-confirm "Nhận session" |
| `{typography.title-md}` | 20px / 600 | Sheet headers, section dividers |
| `{typography.title-sm}` | 17px / 600 | Nav bar title, round-entry row player name, FAQ-style rows, list section headers |
| `{typography.number-ranking}` | 28px / 700 | Ranking card score value — SF Mono, biggest number on the screen |
| `{typography.number-entry}` | 22px / 600 | Round-entry row score value — SF Mono, large enough to read across the table |
| `{typography.number-md}` | 17px / 500 | Round-card inline scores — SF Mono |
| `{typography.number-sm}` | 15px / 500 | Secondary numeric meta — SF Mono |
| `{typography.number-chip}` | 17px / 700 | Score chip running total — SF Mono, bold for chip readability |
| `{typography.body-md}` | 15px / 400 | Default body — SF Pro Text |
| `{typography.body-sm}` | 13px / 400 | Import-confirm meta, history row players list |
| `{typography.caption}` | 12px / 500 | Round-card "Ván N" label, time meta |
| `{typography.caption-section}` | 10px / 600 uppercase tracked | Section labels ("TỔNG", "TÊN SESSION", "NHÓM VỪA CHƠI") |
| `{typography.button}` | 17px / 600 | Every primary, secondary, and destructive button label |
| `{typography.keypad-digit}` | 26px / 400 | The single digits 0–9 on the custom keypad — SF Pro Display, regular weight to match iOS system keyboard character weight |

### Principles
Display sizes use weight 700 — heavier than typical iOS marketing — because the app is a number-reading surface that needs to compete with table conversation across a physical card table.

Every number renders in **SF Mono**, even when surrounding labels use SF Pro Text. Round scores, chip totals, ranking values, sum indicator — all SF Mono. The tabular figures keep digit columns aligned in the round-entry list as players' values tick up and down independently.

All text sizes respond to **Dynamic Type** at the body / caption / button tier. Number sizes (`number-entry`, `number-ranking`, `number-chip`) may opt out of Dynamic Type where layout would break, but body and meta text must scale.

## Layout

### Spacing System
- **Base unit:** 4px.
- **Tokens:** `{spacing.xxs}` 4px · `{spacing.xs}` 8px · `{spacing.sm}` 12px · `{spacing.md}` 16px · `{spacing.lg}` 20px · `{spacing.xl}` 28px · `{spacing.xxl}` 40px · `{spacing.section}` 56px.
- **Screen margins:** 20px horizontal on iPhone (16px in compact list rows where chrome competes); 24px on iPad regular-width.
- **Vertical stack gaps:** `{spacing.sm}` (12px) between round cards in the SessionView list; `{spacing.xs}` (8px) between chips in the totals row; `{spacing.md}` (16px) between summary-view ranking cards.
- **Card internal padding:** `{spacing.md}` (16px) for round cards and history rows; `{spacing.lg}` (20px) for ranking cards and summary header; `{spacing.xl}` (28px) only on celebration-tier surfaces (summary intro on iPad).

### Grid & Container
- **Single column** on iPhone — no multi-column layouts in MVP.
- **iPad regular width:** sessions can render in a split view (sidebar = history, detail = active session); ranking cards switch to 2-up to use horizontal real estate.
- **Round-entry sheet:** edge-to-edge on iPhone with 20px horizontal padding inside the sheet; max 540pt centered on iPad.

### Whitespace Philosophy
The app is dense by intent — the user is mid-game at a physical table and needs to glance at totals without scrolling. Most surfaces use 12–20px between elements rather than 32–56px. Where breathing room appears (summary header, empty state), it's deliberate and signals "this is a moment," not "this is decorative."

## Elevation & Depth

| Level | Treatment | Use |
|---|---|---|
| Flat | No material, no border | Empty-state body, scrollable list backgrounds |
| Soft hairline | 1px `{colors.hairline-on-dark}` / `{colors.hairline-on-light}` | Round-entry row divider, history row divider |
| Opaque card | `{colors.surface-card-dark}` / `{colors.canvas-light}` | Round cards, ranking cards, history rows, summary header |
| Liquid Glass chrome | `{materials.glass-regular-dark}` / `{materials.glass-regular-light}` | Nav bar, autosuggest dropdown |
| Liquid Glass sheet | `{materials.glass-thick-sheet}` | Round-entry sheet, new-session sheet, import-confirm modal, keypad container |
| Focus tint | `{colors.focus-row-tint-*}` (yellow at 12–16%) | Active round-entry row |
| Accent border | 2px `{colors.primary}` or `{colors.score-negative}` | First-place / last-place ranking card |
| Focus ring (iPad) | `0 0 0 2px {colors.info-ring}` at 50% alpha | Text field with hardware keyboard |

The elevation philosophy is **glass for chrome, color blocks for content**. No drop shadows on content cards. Depth comes from the contrast between `{colors.canvas-dark}` and `{colors.surface-card-dark}` (a 12-step lightness jump) and from the refraction Liquid Glass produces against whatever scrolls beneath it.

## Shapes

### Border Radius Scale

| Token | Value | Use |
|---|---|---|
| `{rounded.xs}` | 4px | Small inline badges |
| `{rounded.sm}` | 8px | Round-entry row tint background, focus chips |
| `{rounded.md}` | 12px | Score chips, text fields, sum indicator, keypad keys, history row count chips |
| `{rounded.lg}` | 16px | Round cards, ranking cards, history rows, primary buttons, summary header |
| `{rounded.xl}` | 22px | Full-screen sheet top corners — matches iOS sheet curvature |
| `{rounded.pill}` | 9999px | Player chips (removable), "Dùng lại" compact pill CTA |
| `{rounded.full}` | 9999px / 50% | Avatar circles (if added), icon backgrounds (import-confirm) |

Every rounded surface uses the **continuous (squircle) corner curve**. In SwiftUI, this is the default for `RoundedRectangle(cornerRadius:style: .continuous)`; on UIKit, set `layer.cornerCurve = .continuous`. No exceptions — the squircle is part of the platform's visual language.

### Iconography
- **SF Symbols** for every glyph: nav bar back chevron, share button (`square.and.arrow.up`), more menu (`ellipsis`), delete (`xmark.circle.fill`), checkmark (`checkmark.circle.fill`), warning (`exclamationmark.triangle.fill`), keypad delete (`delete.left.fill`), keypad sign (`plus.forwardslash.minus`).
- **Emoji** for celebratory accents only: 🥇🥈🥉💀🏆🎴📥 in summary and import-confirm. Emoji are deliberately separate from SF Symbols — they signal "moment," not "control."
- Glyphs use semantic SF Symbol weight; tab-bar / nav-bar glyphs default to `.regular`, primary action glyphs `.semibold`.

## Components

### Navigation Bar

**`nav-bar-glass`** — The top navigation bar across every screen. Material `{materials.glass-regular-dark}` / `-light` resolved from `userInterfaceStyle`, with the 1px glass stroke and top-edge specular. Height 56pt (excluding the safe area). The bar scrolls under content with translucency — content peeks through during scroll, the defining iOS interaction.

Layout: leading SF Symbol button (back chevron, or hamburger on root), centered title in `{typography.title-sm}` with optional subtitle ("4 người · 3 ván") in `{typography.caption}` muted, trailing cluster of 1–2 SF Symbol buttons (share, more menu).

On `SessionView`, the title is the session name and is **tap-to-edit** in place (`{component.text-field-name-inline}`). No separate "rename" affordance.

### Buttons

**`button-primary`** — The signature CTA. Background `{colors.primary}`, text `{colors.on-primary}` (black on yellow), type `{typography.button}` (17pt / 600), padding 16px × 24px, height 54pt, rounded `{rounded.lg}` (16px) with continuous corner curve. Used full-width on:
- Empty state: "+ Tạo session mới" at the bottom
- New session sheet: "Bắt đầu →" at the bottom
- Round entry sheet: "Lưu ván →" below the keypad
- Sticky bottom FAB on `SessionView`: "+ Ván 4"
- Import confirm modal: "Mở session này"
- Summary view: "⤴ Chia sẻ session"

Pressed: `button-primary-active`. Disabled: `button-primary-disabled`.

**`button-secondary-glass`** — Used over canvas for less-emphasized actions. Material glass instead of an opaque fill — secondary actions live in the chrome layer. Used for "Hủy" / "Đóng" pairs where the destructive / dismissive option needs visual demotion below `{component.button-primary}`.

**`button-destructive-text`** — Inline red text button for "Xóa" in nav bar of edit-round sheet, in history long-press menu, and in confirmation modals. Text only, no background, type `{typography.title-sm}` in `{colors.score-negative}`.

**`button-tertiary-text`** — Inline yellow text link for "Sửa" / "Skip" / inline cancel. Type inherits `{typography.button}`.

**`button-compact-pill`** — Compact yellow pill CTA used inside dense surfaces. Currently used on the "Dùng lại" affordance inside `{component.reuse-group-card}`. Height 28pt, padding 6px × 14px, type `{typography.caption}`, rounded `{rounded.pill}`.

### Empty State

**`empty-state`** — `HomeView` when there is no active session. Centered vertical stack: oversized SF Symbol or emoji glyph at ~64pt, muted, with a `{typography.body-md}` title and a `{typography.body-sm}` subtitle below. The `{component.button-primary}` "+ Tạo session mới" anchors the bottom of the screen with 32pt safe-area inset.

### Reuse Group Card

**`reuse-group-card`** — The "Dùng lại nhóm vừa rồi" affordance at the top of `NewSessionView`. Material `{materials.glass-regular-*}`, rounded `{rounded.lg}`. Contains the player names joined with "·" in `{typography.title-sm}`, a meta line ("Tối 22/05/2026") in `{typography.caption}` muted, and a right-aligned "Dùng lại" link in `{colors.primary}` typography `{typography.caption}` 600 weight. Single-tap = autofill the player chips below.

### Totals Chip Row

**`totals-chip-row`** — The horizontal scroll row at the top of `SessionView` showing each player's cumulative session total. Container: `{colors.surface-card-dark}` / `{colors.canvas-light}` background, 12px vertical padding, 16px horizontal padding, with a `{typography.caption-section}` "TỔNG" label above the chip row. Chips gap at 8px and overflow scrolls horizontally (no scroll indicators).

**`score-chip-positive`** — A single player's chip when their cumulative total is up. Background `{colors.score-positive-tint-dark}` / `-light`, player name in `{typography.caption}` `{colors.muted-strong}` / `{colors.muted}`, value in `{typography.number-chip}` `{colors.score-positive}`. Rounded `{rounded.md}`, padding 8px × 12px.

**`score-chip-negative`** — Symmetric variant for negative totals.

**`score-chip-zero`** — Neutral variant for a player at exactly 0. Background `{colors.surface-elevated-dark}` / `{colors.surface-strong-light}`, value in body color — never green or red.

### Round Card

**`round-card`** — A single round in the `SessionView` list. Background `{colors.surface-card-dark}` / `{colors.canvas-light}`, rounded `{rounded.lg}`, padding 16px. Header row: "Ván N" label in `{typography.caption}` 600 muted, right-aligned timestamp ("19:48") in `{typography.caption}` muted. Body: inline-wrapped score pairs — player name in `{typography.body-md}` muted, value in `{component.round-card-score-positive}` (green) or `{component.round-card-score-negative}` (red) following the name with a small gap.

Tap = open round-entry sheet in edit mode (pre-filled with this round's scores). Swipe left = "Xóa" with confirm.

**`round-card-score-positive`** / **`round-card-score-negative`** — The colored inline score values inside `{component.round-card}`. Always paired with `+` or `−` prefix and typography `{typography.number-md}` in SF Mono.

### FAB (Floating CTA)

**`fab-bottom-cta`** — The full-width "+ Ván N" button anchored at the bottom of `SessionView`. Same shape and color as `{component.button-primary}` but pinned via safe-area inset rather than scrolled inline. Sits above the list with 20px horizontal margin and 12pt above the home indicator. The `SessionView` list has a matching bottom inset (~80pt) so the last round card is never hidden behind the FAB.

### Sheets

**`sheet-surface`** — The material applied to all full-screen sheets: `NewSessionView`, `RoundEntryView`, `ImportConfirmView`. Material `{materials.glass-thick-sheet}`, top corners rounded `{rounded.xl}` (22px), drag-down dismiss enabled. Each sheet has its own header layout (✕ left, title center, action right) following iOS sheet conventions.

### Round Entry

**`round-entry-row`** — A single player row inside the round-entry sheet. Player name on the left in `{typography.title-sm}`, score value on the right in `{typography.number-entry}` (SF Mono 22pt). 12px vertical padding, 8px horizontal padding, 1px bottom hairline divider. Default state: value in body text color.

**`round-entry-row-focused`** — When this row's input is the active focus target. Background `{colors.focus-row-tint-dark}` / `-light` (yellow at 12–16% alpha), 2px bottom border in `{colors.primary}`, value color flips to `{colors.primary}` with a cursor. Tap the keypad → digits append to this row's value. Tap "Next" on the keypad (or tap a different row) → focus moves.

**`score-auto-fill-text`** — Italic muted text in `{colors.muted}` showing the suggested value for the last empty row when N−1 rows have been filled, formatted as `"+1 auto"`. Tap to materialize and edit (becomes a real input; another row's auto-fill activates instead).

**`sum-indicator-ok`** — A pill below the player list showing the live sum of all entered scores when sum = 0 (zero-sum round, ready to save). Background `{colors.score-positive-tint-*}`, label "Tổng các ô" in `{typography.caption}` muted, value "0 ✓" in `{typography.title-sm}` `{colors.score-positive}`, paired with `checkmark.circle.fill` SF Symbol.

**`sum-indicator-warning`** — Same pill when sum ≠ 0. Background rgba(255, 149, 0, 0.14), value color `{colors.warning}`, paired with `exclamationmark.triangle.fill`. Tap "Lưu" is still allowed (warning is informational, not blocking) — sparse rounds like "chặt heo" rely on empty = 0 ngầm and may not balance perfectly without auto-fill.

### Custom Keypad

The app draws its own numeric keypad inside `RoundEntryView` rather than presenting the system numeric keyboard. This gives us:
- A `±` key (sign toggle) the system keyboard does not provide
- Persistent visibility (system keyboard slides up and may occlude rows)
- A "Lưu ván" action button anchored directly beneath the keys
- A keypad that feels integrated with the sheet's Liquid Glass material

**`keypad-container`** — Material `{materials.glass-thick-sheet}` (inherits from the sheet, so the keypad looks like a continuation of the sheet's bottom edge rather than a separate panel). 8px outer padding, 6px gap between keys, 3 columns, pinned to the bottom safe-area inset.

**`keypad-key-digit`** — Digits 0–9. Background `{colors.surface-elevated-dark}` / `{colors.canvas-light}`, text in body color, type `{typography.keypad-digit}` (26pt SF Pro Display regular), rounded `{rounded.md}`, height 56pt. Pressed state: yellow tint flash (`{colors.primary}` at 30% alpha) for 100ms.

**`keypad-key-utility`** — `±` (sign toggle) and `⌫` (delete, rendered as `delete.left.fill` SF Symbol). Slightly darker / softer background than digit keys (`{colors.surface-card-dark}` / `{colors.surface-soft-light}`) to mark them as modifiers rather than entries.

Below the keypad: a full-width `{component.button-primary}` "Lưu ván →" anchored above the home indicator.

### Text Fields & Player Input

**`text-field`** — Standard text input on `NewSessionView` and inline edit surfaces. Background `{colors.surface-elevated-dark}` / `{colors.surface-strong-light}`, rounded `{rounded.md}`, padding 12px × 16px, height 50pt. Placeholder in `{colors.muted}`.

**`text-field-name-inline`** — The session name edit field in the nav bar. No chrome at rest — the title looks like static text. Tap → cursor appears, keyboard rises, text field expands inline. Commit = blur. No separate save button.

**`player-chip-removable`** — A confirmed player in the new-session player list. Background `{colors.surface-elevated-dark}` / `{colors.surface-strong-light}`, text in body color, trailing `xmark.circle.fill` SF Symbol (muted) for removal. Rounded `{rounded.pill}`, padding 6px × 12px, height 32pt.

**`player-chip-input-placeholder`** — The "+ Thêm người..." dashed-border input that follows the chip row. Background transparent, 1.5px dashed border in hairline color, rounded `{rounded.md}`, padding 10px × 14px. On focus → border solidifies to `{colors.primary}` and triggers `{component.autosuggest-dropdown}`.

**`autosuggest-dropdown`** — Floating glass dropdown beneath the player input. Material `{materials.glass-regular-*}`, rounded `{rounded.md}`, 4px outer padding. Each row: player name in `{typography.body-md}` body color + frequency meta ("(7 buổi)") in `{typography.caption}` muted, 12px × 16px padding. Tap row = adds chip, clears input.

### Ranking Cards

**`ranking-card-first`** — The first-place row in `SummaryView`. Background `{colors.surface-card-dark}` / `{colors.canvas-light}`, 2px accent border in `{colors.primary}`, rounded `{rounded.lg}`. Layout: 🥇 emoji (28pt) on the left, player name in `{typography.title-sm}`, "N ván thắng" meta in `{typography.body-sm}` muted, right-aligned value in `{typography.number-ranking}` (SF Mono 28pt) colored by sign.

**`ranking-card-default`** — Same layout for 2nd, 3rd, etc. — but no accent border. Glyph is 🥈 / 🥉 for 2nd and 3rd, then a muted numeral (`{colors.muted}`) for ranks 4+.

**`ranking-card-last`** — The last-place row. Same as default but with a 2px `{colors.score-negative}` accent border and a 💀 glyph. Activates only when 4 or more players in the session.

### Summary Header

**`summary-header`** — The intro band at the top of `SummaryView`. Background `{colors.surface-card-dark}` / `{colors.canvas-light}`, centered, 24px × 20px padding. Stack: 🏆 emoji (32pt), session name in `{typography.title-lg}`, meta in `{typography.body-sm}` muted ("19 ván · 4 người · 2h 14p").

### History Row

**`history-row`** — A single session preview in `HistoryView`. Background `{colors.surface-card-dark}` / `{colors.canvas-light}`, rounded `{rounded.lg}`, padding 16px. Stack:
- Row 1: session name in `{typography.title-sm}` + right-aligned relative time ("Hôm qua", "3 ngày trước") in `{typography.caption}` muted.
- Row 2: player names joined with "·" in `{typography.body-sm}` muted.
- Row 3: a `{component.score-chip-zero}`-style count chip ("19 ván") + winner highlight ("🥇 Cường +12") in `{typography.caption}` 600 colored `{colors.score-positive}`.

Tap = push `SummaryView` (read-only). Long-press = action menu (Xóa).

### Import Confirm Modal

**`import-confirm-modal`** — The screen surfaced by `.onOpenURL` when the user clicks a shared session link. Material `{materials.glass-thick-sheet}`, presented as a full-screen modal over whatever was on screen. Layout:
- Top: circular icon container (80×80, `{colors.primary}` background, 📥 emoji) centered above a `{typography.title-lg}` title ("Nhận session") and a `{typography.body-sm}` muted subtitle ("Ai đó gửi cho bạn 1 session qua AirDrop").
- Middle: preview card on `{colors.surface-elevated-dark}` background rounded `{rounded.lg}`, showing session name + player list + count chips (people, rounds, duration).
- Bottom note: small muted line — "Session đang chơi của bạn sẽ tự lưu vào History trước khi mở session này."
- Footer: `{component.button-primary}` "Mở session này" + `{component.button-tertiary-text}` "Hủy" stacked.

Confirms an active session's auto-archive before activating the incoming one.

### Share Sheet

**`share-sheet`** — The iOS system share sheet, presented via SwiftUI `ShareLink`. The app contributes the URL (`phorm://import?s=<base64>`) and a display title only — every visual surface (the rounded white panel, the AirDrop row, the app row) is provided by UIKit and is already a Liquid Glass material in iOS 26.

## Do's and Don'ts

### Do
- Reserve `{colors.primary}` (signal yellow) for primary actions, focus highlights, first-place accent, and the brand mark. Never use it for secondary or decorative purposes — yellow's scarcity is what makes it powerful.
- Keep `{component.button-primary}` (yellow with black text) as the universal primary CTA across both light and dark modes. The same button appears identically on `{colors.canvas-dark}` and `{colors.canvas-light}`.
- Use Liquid Glass materials for chrome (nav bar, keypad container, autosuggest, sheets), not for content cards. A glass round-card would dilute the chrome / content boundary.
- Use `{colors.score-positive}` (green) and `{colors.score-negative}` (red) only for score sign — running totals, per-round values, sum indicator. Never for general "success" / "error" / "confirm" / "cancel" affordances.
- Use SF Mono for every number. Round scores, chip totals, ranking values, sum indicator — all SF Mono. Mixing SF Pro Text into a number breaks tabular alignment as digits change.
- Follow the system appearance. Every screen — empty state, session, entry, summary, history, import — must render correctly in both light and dark, switched by `userInterfaceStyle`. Define both realizations at build time; never force a single mode.
- Set `cornerCurve = .continuous` on every rounded surface. The iOS squircle is part of the platform language.
- Respect Reduce Transparency: when the user enables it, fall back from glass materials to opaque tints automatically (use `.regularMaterial` / `.thickMaterial` and SwiftUI handles this).
- Pair score numbers with explicit `+` / `−` prefixes — color alone is not enough for users with color-vision differences.

### Don't
- Don't introduce a second brand color. The system has exactly one accent (`{colors.primary}`); any expansion dilutes the brand identity.
- Don't use yellow for body text, large surface fills, or non-primary actions. It is for focal-point CTAs and brand moments only.
- Don't use `{colors.score-positive}` / `{colors.score-negative}` as card backgrounds. They are score-sign signals, expressed as text color or small tinted chip fill — never as a card surface.
- Don't soften display weight. `{typography.hero-display}` and `{typography.display-lg}` are intentionally weight 700.
- Don't stack glass on glass. A glass card inside a glass sheet inside a glass nav bar reads as muddy fog — opaque content surfaces are the right answer when glass would nest.
- Don't add atmospheric gradients to the canvas (mesh, aurora, glow effects). The system trusts color-block contrast and Liquid Glass refraction.
- Don't invert `{component.button-primary}`'s text color. Black on yellow is the system's signature in both modes — white text on yellow loses contrast and brand recognition.
- Don't replace SF Pro / SF Mono with custom typefaces. The whole point of the iOS stack is automatic Dynamic Type, optical sizing, and zero-load font availability.
- Don't force a single appearance. The app must respect the user's system setting — no in-app "always dark" override unless surfaced as an explicit, persisted user preference.
- Don't ship a screen with only one realization. Every surface needs both light and dark visuals before it can land.
- Don't use the iOS system numeric keyboard inside `RoundEntryView`. The custom `{component.keypad-container}` is intentional — it provides `±`, persistent visibility, and a tighter integration with the sheet material.

## Responsive Behavior

### Device Classes

| Class | Width | Key Changes |
|---|---|---|
| iPhone compact (SE) | 320–375pt | Round-entry rows tighten to 10pt vertical padding; keypad keys shrink to 48pt height; ranking-card glyphs stay 28pt |
| iPhone regular | 376–428pt | Default sizing across all components |
| iPad regular width | 768–1024pt | Split view available (sidebar = `HistoryView`, detail = active `SessionView`); ranking cards in `SummaryView` lay out 2-up; sheets cap at 540pt centered |
| iPad wide | > 1024pt | Same as regular width with the sidebar pinned; content column caps at 600pt for readability |

### Touch Targets
- Primary CTAs render at 54pt height (`{component.button-primary}`) — exceeds the iOS HIG 44pt minimum.
- Keypad keys hit 56pt height — comfortably above 44pt for tapping with a single thumb mid-game.
- Round-entry rows hit 44pt+ effective target via padding.
- Round-card tap target is the entire card (~80pt tall with content).
- Compact pill ("Dùng lại") sits at 28pt visually but its parent row extends the tap target to 60pt+.

### Adaptation Strategy
- Glass materials adapt automatically to system appearance — `.regularMaterial` / `.thickMaterial` flip tint with light / dark mode without manual swapping.
- The sticky FAB hides on scroll-down and reappears on scroll-up (iOS standard pattern) so it never blocks more than two round cards at once.
- Round-entry sheet on iPad presents as a `.formSheet` (centered, ~540pt × 600pt) rather than full-screen.
- All numeric SF Mono sizes hold across device classes — readability across the table is non-negotiable.

## Accessibility

- **Dynamic Type:** All body, caption, button, and meta text scales with the user's preferred text size. Number sizes may opt out where layout would break, but score chips and round-entry values must scale to at least `xxLarge`.
- **Reduce Transparency:** When enabled, every Liquid Glass material falls back to its solid tint equivalent (`{colors.surface-card-dark}` / `{colors.canvas-light}` for `regular`; `{colors.canvas-dark}` for `thick`). Specular highlights and strokes are removed.
- **Increase Contrast:** Hairlines bump from `{colors.hairline-on-dark}` to `{colors.border-strong}`; muted text upgrades from `{colors.muted}` to `{colors.body}`; glass tints become more opaque.
- **VoiceOver:** Every score chip exposes a semantic label that reads "Cường, plus 5 points" — not "+5". Round cards read "Ván 3, 19:48: An -2, Bình +4, Cường +1, Dũng -3." Ranking cards read "First place, Cường, plus 12." The keypad announces each key by name.
- **Color blindness:** Score colors are paired with explicit `+` / `−` prefixes; ranking cards pair color with a medal glyph (🥇🥈🥉💀); sum indicators pair color with an SF Symbol (`checkmark.circle.fill` / `exclamationmark.triangle.fill`).
- **Keyboard / external input:** Focus ring (`{colors.info-ring}` at 50% alpha) renders around any focused text field on iPad with external keyboard.
- **Haptics:** Light impact on keypad press; medium impact on "Lưu ván" success; warning notification on sum-mismatch save; selection feedback on chip tap. All routed through `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator`.

## Iteration Guide

1. Focus on ONE component at a time. Reference its YAML key directly (`{component.button-primary}`, `{component.score-chip-positive}`).
2. When adding a new component, decide first whether it's chrome (use a glass material) or content (use an opaque surface). Mixing the two reads as muddy.
3. Specify both light and dark realizations for every new component. Reference the semantic token role (`canvas`, `surface-card`, `body-text`) and let the renderer resolve `-light` / `-dark` from `userInterfaceStyle`. A component with only one realization is incomplete.
4. Variants of an existing component (`-positive`, `-negative`, `-focused`) live as separate entries in `components:` — never as nested state objects.
5. Use `{token.refs}` everywhere prose mentions a color, a radius, a typography role, or a spacing value.
6. Never document hover. The system documents Default and Pressed states only (iOS has no hover).
7. Numbers always use SF Mono; copy always uses SF Pro Text / Display. Mixing them is a system violation.
8. Score green / red are semantic sign tokens — never repurpose them for "success" or "error" generic states.
9. Every rounded surface uses the continuous corner curve. No exceptions.

## Known Gaps

- Animation and transition timings (sheet present / dismiss, keypad press flash, chip total tick-update, round-card insert) are not formalized — defer to SwiftUI's default `.animation(.snappy)` / `.spring()` curves until measured.
- The split-view / sidebar layout on iPad regular width is described in principle but the specific sidebar component (history row treatment, active session highlight) is not specified.
- Widget and Live Activity treatments (Lock Screen "ván đang chơi" indicator) are out of scope for MVP.
- Tinted / Clear icon variants for the iOS Home Screen are not specified — provide a standard `AppIcon` + a dark-mode variant at minimum.
- The visual treatment of an undo / multi-step rollback after destructive actions is not designed — MVP plan trusts the user, no undo stack.
- Localization beyond Vietnamese is out of scope for MVP; the system has not been pressure-tested against long English labels in `{component.button-primary}` / chip widths.
