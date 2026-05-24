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

Confident, fast, deliberate. Voice: terse, Vietnamese, no marketing fluff and no game-show energy. The interface feels like a pro tool that respects the user's time. Trust comes from numeric density and clarity, not from reassurance copy. Borrows the visual confidence of trading terminals and Apple's own data-dense apps (Stocks, Fitness, Health) and the precision of pro productivity tools (Linear, Raycast, Things 3). Tone in moments of warning is matter-of-fact, never apologetic and never alarming: "Tổng: −3 ⚠" tells the host something is off; it doesn't scold them.

## Anti-references

What this should NOT look or feel like:

- **Generic SaaS dashboards.** No Linear/Stripe/Notion sameness: no pastel gradients, no cream backgrounds, no Inter-everywhere, no identical card grids, no "Welcome back, here are your metrics" hero blocks.
- **Generic notes or spreadsheet apps.** No Apple Notes mimicry, no Numbers-style default tables, no soft-gray system blandness, no "this is just a list with a + button."
- **Casual game-tracker apps with cartoony energy.** No confetti, no mascot illustrations, no bright pastel celebration screens, no "🎉 You won!" toasts. The leaderboard's 🥇🥈🥉💀 is the only decoration the app earns; everything else stays restrained.
- **Gambling / casino chrome.** No felt-green tables, no playing-card iconography in UI, no slot-machine red, no trophy textures. The game happens off-screen; the app stays neutral.

## Design Principles

1. **Dumb tracker, not smart scorer.** The app records the points the table agreed on; it does not understand Phỏm or Sâm rules. No móm, no ù, no thối heo math. The table knows the rules; the app just keeps the ledger. Every feature proposal is filtered through this principle first.

2. **Defaults beat settings.** Every screen ships with a working default: auto-named session, auto-filled last cell, autosuggested player names from history, follows system appearance, sparse round entry. There is no setup flow, no settings page, no tutorial, no required tap before the first useful action.

3. **Open in 0 taps, log a round in N−1.** Speed is positioning, not optimization. App launch with an active session goes straight to the leaderboard. Round entry requires only N−1 numeric inputs; the last cell auto-fills. Anything that adds a tap to either path must justify itself against this principle.

4. **Native iOS, pro-tools register.** Borrow Apple's own data-dense confidence (Stocks, Fitness, Health) and trading-terminal density. Use Liquid Glass only where Apple uses it. Avoid both poles of failure: SaaS-dashboard sameness above, Notes-app blandness below. The app should feel like it belongs on iOS without disappearing into the system.

5. **Numbers carry the personality.** Chrome stays restrained: one yellow accent, one type family for copy, SF Mono for every digit so columns stay aligned as values tick. Score up/down is communicated by color and a non-color cue together. Any decoration that doesn't make a number more readable, or a tap more confident, is removed.

## Accessibility & Inclusion

- **WCAG AA contrast across both themes.** Light and dark are equal peers. All text, icons, and interactive elements clear 4.5:1 for normal text and 3:1 for large text and UI controls. Includes the yellow primary button against its surface and the green/red score text against any background it appears on.

- **Score up/down never relies on color alone.** Pair the green/red text color with a sign (+/−), arrow, or weight cue so red-green color-blind players parse the leaderboard correctly. Roughly 8% of male users are affected; for a table-of-friends app this is a real population.

- **Dynamic Type for Vietnamese body copy.** Button labels, headers, empty-state copy, and confirmation strings scale with the user's iOS text-size setting. SF Mono numerics may remain fixed-size to preserve column alignment on the leaderboard and round cards; this trade-off is deliberate.

- **Vietnamese-only for MVP.** No i18n scaffolding, no English fallbacks, no language picker. All UI copy is Vietnamese.
