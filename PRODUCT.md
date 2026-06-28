# Product

## Register

product

## Users

The host at the card-game table. One person at a physical Phỏm / Sâm Lốc table holds the phone between rounds and types in points for everyone. The host is the scribe, not necessarily the strongest player. Vietnamese-speaking adults in social settings: a living-room coffee table at night, a kitchen between rounds, a quiet bar booth. Light is varied and rarely ideal. Attention is split — the host is in conversation, watching the next deal, and entering scores all at once. The phone is set down and picked up dozens of times per session.

What they need from the app: end the argument over "tao ăn mày bao nhiêu", stop the mid-game mental math, and have a clean leaderboard ready when the table settles up.

## Product Purpose

Record points across rounds for Phỏm, Sâm Lốc, or any zero-sum card game so the table doesn't have to nhẩm tổng in their heads, and so settlement at the end takes seconds instead of minutes. The app is a ledger, not a referee. It captures what the players agreed each round was worth and totals it; it never decides scoring outcomes.

Success looks like: app cold-launches into an active session in 0 taps. A round is logged in N−1 numeric inputs and one Save tap. A session that finished an hour ago is still discoverable in two taps. iCloud sync between the host's own devices is a background bonus; the app never asks for it, never blocks on it, never mentions it.

## Brand Personality

Confident, fast, deliberate. Voice: terse, Vietnamese, no marketing fluff and no game-show energy. The interface feels like a pro tool that respects the user's time. Trust comes from numeric density, typographic confidence, and clarity — not from reassurance copy. Visual register: card-table tactility with Vietnamese accents — Tết-red + gold, color-filled score chips as physical pieces, clean sans numerals. Not a lacquered scorebook, not an LED board. Character comes from material depth and color pop, not the typeface. Tone in moments of warning is matter-of-fact, never apologetic and never alarming: "Tổng: −3 ⚠" tells the host something is off; it doesn't scold them.

## Anti-references

What this should NOT look or feel like:

- **Generic SaaS dashboards.** No Linear/Stripe/Notion sameness: no pastel gradients, no Inter-everywhere, no identical card grids, no "Welcome back, here are your metrics" hero blocks.
- **Generic notes or spreadsheet apps.** No Apple Notes mimicry, no Numbers-style default tables, no soft-gray system blandness, no "this is just a list with a + button."
- **Trading-terminal nihilism.** No Bloomberg-orange-on-black, no Binance-yellow-on-charcoal, no SF Mono LED readouts. The category reflex for a "data-dense card-game tracker" is *exactly* this — reject it on sight.
- **Casual game-tracker apps with cartoony energy.** No confetti, no mascot illustrations, no bright pastel celebration screens, no "🎉 You won!" toasts, no emoji. Playful comes from material depth + color pops, not cartoon energy. The gold winner coin ("Nhất bàn") is the only celebratory moment the app earns; everything else stays restrained.
- **Gambling / casino chrome.** No felt-green tables, no playing-card iconography in UI, no slot-machine red, no trophy textures. The game happens off-screen; the app stays neutral.
- **Nostalgia kitsch.** Vernacular references are filtered through modern design discipline. No literal matchbox-cover photo backgrounds, no fake-aged paper textures applied without restraint, no "retro" framing chrome.

## Design Principles

1. **Dumb tracker, not smart scorer.** The app records the points the table agreed on; it does not understand Phỏm or Sâm rules. No móm, no ù, no thối heo math. The table knows the rules; the app just keeps the ledger. Every feature proposal is filtered through this principle first.

2. **Defaults beat settings.** Every screen ships with a working default: auto-named session, auto-filled last cell, autosuggested player names from history, follows system appearance, sparse round entry. There is no setup flow, no settings page, no tutorial, no required tap before the first useful action.

3. **Open in 0 taps, log a round in N−1.** Speed is positioning, not optimization. App launch with an active session goes straight to the leaderboard. Round entry requires only N−1 numeric inputs; the last cell auto-fills. Anything that adds a tap to either path must justify itself against this principle.

4. **Native iOS, tactile Vietnamese register.** Built in SwiftUI and respects iOS interaction grammar (sheets, ShareLink, system gestures), but the visual identity is rooted in tactile card-table physicality — bright warm surfaces, color-filled score chips, 3D-bevel keys, gold winner coin — not Apple's default chrome. Brand rests on Tết-red + gold coin/chip tactility, not the serif/lacquer print register. The app should feel like it was made for *this* table, not localized from English. Avoid both poles of failure: SaaS-dashboard sameness above, terminal-dark category reflex below.

5. **Tactile chips carry the personality.** Surfaces follow system appearance (bright warm cream by day, deep warm dark by night). Score values are color-filled chips — green up, coral down — that read as physical pieces on a card table. Typography is clean sans with tabular figures (SF Pro), not monospaced LED. Score chips always carry an explicit `+`/`−` sign prefix. The winner earns a gold coin ("Nhất bàn") and last place is marked "Bét bàn." Beyond those, no decoration earns its place.

## Accessibility & Inclusion

- **WCAG AA contrast, measured per surface.** The dual day/night surface system is the contrast-critical layer; all small-text + UI combinations are measured against the active surface. Day (`#FBF4E6`): ink body ~12:1 ✓, ink-muted labels ~4.8:1 ✓, up-score jade ~5.5:1 ✓, down-score rust ~5.7:1 ✓. Night (`#241715`): cream body ~12:1 ✓, up-score mint 5.81:1 ✓, down-score peach ~5.2:1 ✓. Gold winner coin uses gold fill + dark ink at ~8:1 — the contrast is the design, not an afterthought.

- **System appearance selects between two equal surfaces.** The app follows system appearance: bright warm cream by day, deep warm dark by night. Chromatic identity persists through Tết-red + gold brand accents, not a single drenched surface color. Both surfaces are tuned to comfortable AA contrast.

- **Score up/down never relies on color alone.** Color-filled chips (green up / coral down) always carry an explicit `+`/`−` sign prefix so red-green color-blind players parse the leaderboard correctly. Roughly 8% of male users are affected; for a table-of-friends app this is a real population. The winner/last-place coins add a second non-color cue (gold coin vs. coral coin).

- **Dynamic Type for Vietnamese body copy.** Button labels, headers, empty-state copy, and confirmation strings scale with the user's iOS text-size setting. SF Pro numerics use `.monospacedDigit()` and may opt out of Dynamic Type at the leaderboard / round-entry tier to preserve column alignment — this trade-off is deliberate.

- **Vietnamese-only for MVP.** No i18n scaffolding, no English fallbacks, no language picker. All UI copy is Vietnamese. Typography is SF Pro, which provides full Vietnamese diacritic coverage. Verify rendering at small sizes (Đ, Ô, Ư, ỷ, ặ, etc.) in design review.
