# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a **design/planning repo, not the iOS app codebase.** Per `PLAN.md`, the actual native iOS implementation lives in a separate repo (`phorm-ios`). This repo holds the spec, the design system, and an interactive HTML mockup that drives that implementation.

Contents:
- `PLAN.md` — the source of truth for product scope, UX decisions (numbered 1–14, treat as locked), data model sketch, screens, and manual verification steps.
- `DESIGN.md` — design tokens as YAML-in-Markdown frontmatter: colors, Liquid Glass materials, typography (SF Pro Display/Text + SF Mono for all numerics), spacing, components. ~860 lines; read the frontmatter, don't paraphrase it.
- `design-walkthrough.html` — single-file Tailwind (CDN) mockup of every screen. Open directly in a browser, or view via raw.githack: https://raw.githack.com/quyctd/saam-app/main/design-walkthrough.html
- `README.md` — short pointer to the above.

There is no Swift code, no `package.json`, no build/lint/test pipeline in this repo. Don't fabricate one.

## Working in this repo

- Editing `design-walkthrough.html`: it's standalone — no build step. Open the file in a browser to preview changes. Tailwind is loaded from `cdn.jsdelivr.net/npm/@tailwindcss/browser@4`.
- Editing `PLAN.md` / `DESIGN.md`: prose/spec changes only. The 14 numbered UX decisions in PLAN.md are intentional commitments — don't soften, expand, or "improve" them without explicit ask. Same for the "Out of scope (MVP)" list at the bottom.
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

## Design system anchors (from DESIGN.md)

- Single brand color: saturated yellow `#fcd535` carries every primary action. Don't introduce a second accent.
- Score semantics: green `#0ecb81` = up, red `#f6465d` = down — **as text color, never as card fill.**
- Surfaces use Liquid Glass materials (nav bars, sheets, in-app keypad). Four variants defined in DESIGN.md `materials:` — use those, don't invent new blurs.
- All numeric values (round scores, totals, rankings) use SF Mono so digits stay column-aligned.
- App follows system appearance — light and dark are equal peers, not one as primary.
