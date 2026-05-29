# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This repo holds the spec, the design system, and the iOS app implementation (`andiem-ios/`).

Contents:
- `PLAN.md` — the source of truth for product scope, UX decisions (numbered 1–14, treat as locked), data model sketch, screens, and manual verification steps.
- `PRODUCT.md` — the brand brief: who the user is, product purpose, voice, anti-references, design principles, accessibility commitments. Shorter than DESIGN.md/PLAN.md; read it whole when product framing matters.
- `DESIGN.md` — design tokens for the **Hà Nội cũ** visual language (Vietnamese vernacular print). YAML-in-Markdown frontmatter: lacquer surfaces (cinnabar/ochre/jade), cream ink, gold-leaf accent, Noto Serif Display + Cormorant Garamond + IBM Plex Serif typography, halftone/grain textures, components. Read the frontmatter, don't paraphrase it.
- `themes-preview.html` — single-file Tailwind (CDN) mockup of the Hà Nội cũ direction across four key screens. This is the canonical visual reference. View via raw.githack: https://raw.githack.com/quyctd/an-diem/main/themes-preview.html
- `design-walkthrough.html` — older mockup of the prior trading-terminal direction. **Superseded by `themes-preview.html`** but kept for diff reference.
- `andiem-ios/` — the SwiftUI iOS implementation.
- `README.md` — short pointer to the above.

## Working in this repo

- Editing `themes-preview.html`: it's standalone — no build step. Open the file in a browser to preview changes. Tailwind is loaded from `cdn.jsdelivr.net/npm/@tailwindcss/browser@4`. Google Fonts (Noto Serif Display, Cormorant Garamond, IBM Plex Serif, Spectral) load via CDN.
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
- **Reference register: Vietnamese vernacular print** — Diêm Thống Nhất matchbox labels, vỏ chai Bia Hà Nội, lacquerware seals, áo dài silk patterns — read through a contemporary designer's eye, not pastiche. The app should feel like a lacquered scorebook a friend group keeps.
- **Anti-references — reject on sight:** SaaS-dashboard sameness, Notes-app blandness, **trading-terminal nihilism** (Bloomberg-on-black, Binance-yellow, SF Mono LED — the category reflex; reject it), cartoony game-tracker energy (confetti, mascots, "🎉 You won!"), gambling/casino chrome, nostalgia kitsch (literal aged-paper textures). The winner's **ấn vàng** (gold seal) and last-place **tem chéo** (×) are the only decoration the app earns.
- **Score up/down must pair color with a non-color cue** — mint (+) up, ochre (−) down, always with explicit sign prefix. Color-blind parsing is a hard requirement, not a nice-to-have.
- **WCAG AA, measured per surface.** Cinnabar lacquer is the contrast-critical layer; tokens declare their ratio explicitly. Cream on cinnabar 6.96:1, gold-bright on cinnabar 5.10:1 (small labels), gold on cinnabar 4.27:1 (display ≥18px only).

## Design system anchors (from DESIGN.md)

- Single accent color: **gold-leaf** `#d9b25a` (large) + `#e8c570` (small labels). Carries every primary CTA, focus border, and the winner's seal. Don't introduce a second accent.
- Score semantics: **mint** `#b6e0c2` = up (5.81:1), **ochre-warm** `#e6a665` = down (4.02:1, large only). Text color, never card fill. Always paired with `+`/`−` sign.
- **No Liquid Glass.** Surfaces are lacquer (cinnabar `#8c2a22` default + ochre/jade/oxblood variants), overlaid with halftone dots + paper grain. The texture system replaces glassmorphism entirely.
- **No SF Mono.** Forbidden — its presence is a category-reflex failure. Numerals use **Noto Serif Display** (hero/display ≥20px) and **IBM Plex Serif** with `tabular-nums` (body/small). Italic Cormorant Garamond for player names and auto-fill computed values.
- App does NOT have binary light/dark equal peers. One drenched lacquer surface per session; iOS appearance subtly deepens/lightens, but chromatic identity persists.
- Canonical visual reference is `themes-preview.html`. When the doc disagrees with the preview, the preview wins; update the doc.
