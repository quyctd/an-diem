# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This repo holds the spec, the design system, and the iOS app implementation (`andiem-ios/`).

Contents:
- `PLAN.md` — the source of truth for product scope, UX decisions (numbered 1–14, treat as locked), data model sketch, screens, and manual verification steps.
- `PRODUCT.md` — the brand brief: who the user is, product purpose, voice, anti-references, design principles, accessibility commitments. Shorter than DESIGN.md/PLAN.md; read it whole when product framing matters.
- `DESIGN.md` — design tokens for the **tactile/playful** visual language (Tết-red + gold + coin/chip tactility). YAML-in-Markdown frontmatter: bright day/night surfaces, color-filled score chips, coin tokens, 3D keypad keys, clean sans typography. Read the frontmatter, don't paraphrase it.
- `themes-preview.html` — single-file Tailwind (CDN) mockup. The canonical visual reference is the **`TACTILE / PLAYFUL DIRECTION` (`tc-`)** section of this file. View via raw.githack: https://raw.githack.com/quyctd/an-diem/main/themes-preview.html
- `design-walkthrough.html` — older mockup of the prior trading-terminal direction. **Superseded by `themes-preview.html`** but kept for diff reference.
- `andiem-ios/` — the SwiftUI iOS implementation.
- `README.md` — short pointer to the above.

## Working in this repo

- Editing `themes-preview.html`: it's standalone — no build step. Open the file in a browser to preview changes. Tailwind is loaded from `cdn.jsdelivr.net/npm/@tailwindcss/browser@4`. Google Fonts (Inter) load via CDN.
- Editing `PLAN.md` / `PRODUCT.md` / `DESIGN.md`: prose/spec changes only. The 14 numbered UX decisions in PLAN.md, the 5 design principles + anti-references in PRODUCT.md, and the token frontmatter in DESIGN.md are intentional commitments — don't soften, expand, or "improve" them without explicit ask. Same for the "Out of scope (MVP)" list at the bottom of PLAN.md.
- Editing `andiem-ios/`: SwiftUI codebase. Theme tokens (colors, fonts) should pull from a single source of truth that mirrors DESIGN.md's YAML frontmatter — don't scatter hex literals across views.
- `.expect/` is gitignored except for `.gitignore` itself — it's scratch for the `mcp__expect__*` browser tools and shouldn't be checked in.

## Non-negotiable product principles (from PLAN.md)

These shape every suggestion, even small ones:

1. **Offline-first.** No backend, no auth, no required network. iCloud sync is a background bonus, not a dependency.
2. **Fast.** Mở app là chơi. Each round entry should require only N−1 numeric inputs (the last cell auto-fills as `-(sum)`).
3. **No onboarding.** No signup, no tutorial, no required settings. Defaults must be good.
4. **Dumb tracker, not smart scorer.** App records points; it does not understand Phỏm/Sâm rules (no móm/ù/thối logic).
5. **Sparse round entry is valid.** Empty cell = 0 implicit. Auto-fill activates only when N−1 cells are filled. Sum ≠ 0 is allowed with a soft warning, not blocked.
6. **Vietnamese-only for MVP.** All UI copy is Vietnamese. Don't propose English strings or i18n scaffolding.

## Tech stack the spec commits to

When discussing implementation (even though the code is elsewhere), assume:
- iOS 17+, SwiftUI only (no UIKit)
- SwiftData with CloudKit container for storage + sync
- `ShareLink` + custom URL scheme `phorm://import?s=<base64>` for session handoff (JSON → gzip → base64url)
- Players are `[String]` on `Session`, not a separate entity — keeps URL handoff trivial and autosuggest = distinct names across sessions.

## Brand & voice anchors (from PRODUCT.md)

- **User is the host at the table** — one Vietnamese-speaking adult holding the phone between rounds in a low-light social setting, attention split. Optimize for the scribe, not the strongest player.
- **Confident, fast, deliberate.** Voice is terse Vietnamese with no marketing fluff and no game-show energy. Warnings are matter-of-fact ("Tổng: −3 ⚠"), never apologetic or alarming.
- **Reference register: card-table tactility + Vietnamese vernacular accents.** Brand rests on Tết-red `#E5483A` + gold `#F2B829` coin/chip tactility — not the serif/lacquer print register. The app should feel like placing physical pieces on a card table, with a warm Vietnamese frame.
- **Anti-references — reject on sight:** SaaS-dashboard sameness, Notes-app blandness, **trading-terminal nihilism** (Bloomberg-on-black, Binance-yellow, SF Mono LED — the category reflex; reject it), cartoony game-tracker energy (confetti, mascots, emoji, "🎉 You won!"), gambling/casino chrome, nostalgia kitsch (literal aged-paper textures). Playful comes from material depth + color pops, not cartoon energy. The gold winner coin ("Nhất bàn") is the only celebratory moment the app earns.
- **Score up/down must pair color with a non-color cue** — chips are color-filled (green `#21BD73` up, coral `#FF6B3D` down) AND always carry an explicit `+`/`−` sign prefix. The sign is the color-blind contract; the chip color is additive. Color-blind parsing is a hard requirement, not a nice-to-have.
- **WCAG AA, measured per surface.** Day surface (`#FBF4E6`): ink ~12:1, up-score jade ~5.5:1, down-score rust ~5.7:1. Night surface (`#241715`): cream ~12:1, up-score mint 5.81:1, down-score peach ~5.2:1. Tokens declare their ratio explicitly.

## Design system anchors (from DESIGN.md)

- Brand accents: **Tết-red** `#E5483A` (primary CTA, sign-toggle key, headers) + **gold** `#F2B829` (winner coin, special tokens). Don't introduce a third accent.
- Score semantics: **color-filled chips** — up `#21BD73` green fill, down `#FF6B3D` coral fill, neutral `#ECE4D6` (day). White bold number inside. The "text color only, never card fill" rule is intentionally overridden. Always paired with `+`/`−` sign prefix (color-blind requirement).
- **No Liquid Glass.** Surfaces follow system appearance: day warm cream `#FBF4E6`, night deep warm `#241715`. Halftone-dot pattern retired on all screens. Night surface retains subtle grain (25% opacity). Depth from chip and key shadows.
- **No SF Mono.** Forbidden — its presence is a category-reflex failure. Typography is clean system sans: **SF Pro** (iOS native, zero bundling) with `.monospacedDigit()` on all numerics. The serif register (Noto Serif Display, Cormorant Garamond, IBM Plex Serif, Spectral) is retired. Auto-fill uses lighter weight (300) to signal "app wrote this."
- App **follows system appearance** with two equal surfaces. Day: warm cream `#FBF4E6`. Night: deep warm `#241715`. Chromatic identity persists through Tết-red + gold accents, not a single drenched surface color.
- Canonical visual reference is the **`TACTILE / PLAYFUL DIRECTION` (`tc-`) section of `themes-preview.html`**. When the doc disagrees with the `tc-` mockup, the mockup wins; update the doc.
