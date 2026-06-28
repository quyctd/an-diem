# An Điểm Friendlier Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the two shipped-app complaints — low text contrast and unclear literary terminology — by making the app a real light(paper)/dark(lacquer) app with comfortable AA contrast and plain table-talk wording, while keeping the seal motif as a legible brand mark.

**Architecture:** Adaptive-in-place token layer. The hardcoded `phorm*` color statics in `Color+Tokens.swift` are repointed to `Color("AssetName")` backed by `Assets.xcassets` colorsets whose **light appearance = warm paper palette** and **dark appearance = lacquer palette**. View callsites keep the same token names, so the diff concentrates in the token layer + asset catalog. Terminology and seal-glyph changes are localized string/component edits. The `themes-preview.html` mockup is updated first as the visual reference; SwiftUI follows.

**Tech Stack:** SwiftUI (iOS 17+), SwiftData, `Assets.xcassets` colorsets with `luminosity` appearance variants, Swift Testing (`import Testing`) for logic, `xcodebuild` for build verification.

## Global Constraints

- iOS 17+, SwiftUI only (no UIKit views; UIKit allowed only for the existing texture baking in `LacquerSurface.swift`).
- Vietnamese-only UI copy. No English strings, no i18n scaffolding.
- Score up/down must ALWAYS pair color with the explicit `+`/`−` sign prefix (color-blind requirement). Up = green family, down = warm-rust family. Text color only, never card fill.
- Single accent color: gold-leaf. Do not introduce a second accent. The seal/stamp is the only decoration the app earns.
- No Liquid Glass / glassmorphism. No SF Mono — numerals stay Noto Serif Display / IBM Plex Serif.
- Target AA: body/normal text ≥ 4.5:1; large/display ≥ 3:1. Both surfaces measured.
- Appearance follows system. No mode-picker UI, no onboarding.
- Build/test scheme: `Phorm`. Simulator: `iPhone 17`. Tests use Swift Testing (`@Suite`/`@Test`/`#expect`).
- Exact paper/lacquer hex values (locked in spec `docs/superpowers/specs/2026-06-28-friendlier-redesign-design.md`):
  - Paper ground `#F2E9D8`; ink primary `#2E1C16`; ink secondary `#6B5A4A`; accent cinnabar `#8C2A22`; up jade `#1B6B47`; down rust `#A63A1E`.
  - Lacquer ground `#8C2A22`; cream `#F3E8D2`; cream-dim `#D6C4A0`; up mint `#B6E0C2`; down peach `#F2B488`; gold `#D9B25A`; gold-bright `#E8C570`; onPrimary ink `#5A1612`.

---

## File map

- `themes-preview.html` — update mockup to both surfaces + plain wording (Task 1).
- `andiem-ios/PhormTests/SealGlyphTests.swift` — **create**: unit tests for Arabic rank output (Task 2).
- `andiem-ios/Phorm/Views/Components/Seal.swift` — `SealGlyph.forRank` → Arabic; doc-comment update (Task 2).
- `andiem-ios/Phorm/Views/RoundEntryView.swift:211` — auto-fill seal glyph `封` → `=` (Task 2).
- `andiem-ios/Phorm/Resources/Assets.xcassets/*.colorset` — **create** 6 adaptive colorsets (Task 3).
- `andiem-ios/Phorm/DesignSystem/Color+Tokens.swift` — repoint statics to `Color("…")` (Task 3).
- `andiem-ios/Phorm/DesignSystem/LacquerSurface.swift` — paper-vs-lacquer surface treatment (Task 4).
- `andiem-ios/Phorm/Views/SummaryView.swift` — plain wording + seal glyph "1" / down-seal (Task 5).
- `DESIGN.md`, `CLAUDE.md`, `PRODUCT.md` — doc anchors (Task 6).

---

## Task 1: Update `themes-preview.html` to dual surface + plain wording

The repo's canonical visual reference. Locks the exact paper palette visually **before** any Swift change. No automated test — ends with a user visual-review checkpoint.

**Files:**
- Modify: `themes-preview.html`

**Interfaces:**
- Produces: visually-confirmed paper palette hexes (ground `#F2E9D8`, ink `#2E1C16`, secondary `#6B5A4A`, accent cinnabar `#8C2A22`, up jade `#1B6B47`, down rust `#A63A1E`) reused verbatim by Task 3, and confirmed wording "Nhất bàn" / "Bét bàn" reused by Task 5.

- [ ] **Step 1: Add a light(paper) variant of the four key screens**

In `themes-preview.html`, duplicate the existing four-screen `.hanoi` mockup block into a second "paper" section. For the paper section set the screen background to `#F2E9D8`, body text/numerals to `#2E1C16`, secondary labels to `#6B5A4A`, section headers/accents to cinnabar `#8C2A22`, positive scores to jade `#1B6B47` (with `+` prefix), negative scores to rust `#A63A1E` (with `−`/U+2212 prefix). Keep the existing cinnabar block as the "night/lacquer" reference and change only its negative-score color to peach `#F2B488`.

- [ ] **Step 2: Apply plain wording in both sections**

Replace user-facing labels in the summary screen markup: "Vô địch ván" → "Nhất bàn"; remove the "Ấn vàng" callout label (keep the gold seal shape beside the champion); "Tem cuối bàn" → "Bét bàn"; any tied-state copy → "Hoà — chưa rõ ai nhất, ai bét". Replace Hán seal glyphs (`壹`/`封`/`贰`…) with Arabic `1 2 3 …`; replace the `×` last marker with a muted rank seal (de-emphasized ring, no aggressive X).

- [ ] **Step 3: Open in browser and self-check contrast**

Open `themes-preview.html` locally. Verify by eye that on the paper section every score, label, and numeral is comfortably legible, and the night section's negative scores (peach) read clearly. Adjust only if a value looks visibly wrong; if so, record the corrected hex (it overrides the spec value for Task 3).

- [ ] **Step 4: Commit**

```bash
git add themes-preview.html
git commit -m "design: dual-surface (paper/lacquer) + plain wording in themes-preview"
```

- [ ] **Step 5: USER VISUAL CHECKPOINT**

Ask the user to review via raw.githack (`https://raw.githack.com/quyctd/an-diem/<branch>/themes-preview.html`) and confirm the paper palette + wording before proceeding to Swift. Record any hex/wording corrections; they override the spec defaults downstream.

---

## Task 2: Arabic rank seals (drop Hán glyphs)

Pure-logic + component change. The only unit-testable task.

**Files:**
- Create: `andiem-ios/PhormTests/SealGlyphTests.swift`
- Modify: `andiem-ios/Phorm/Views/Components/Seal.swift:60-72` (the `SealGlyph` enum), and its doc comments at `:3-7`, `:60`
- Modify: `andiem-ios/Phorm/Views/RoundEntryView.swift:211` (auto-fill badge glyph)

**Interfaces:**
- Consumes: nothing.
- Produces: `SealGlyph.forRank(_ rank: Int) -> String` now returns Arabic decimal (`"1"`, `"2"`, … ; `""` for rank < 1). Callsites in `RoundEntryView.swift:178` and `SessionView.swift:186` are unchanged (they already pass the result through). `Seal` keeps `enum Variant { case default, winner, last }` and `init(glyph:variant:size:)` unchanged.

- [ ] **Step 1: Write the failing test**

Create `andiem-ios/PhormTests/SealGlyphTests.swift`:

```swift
import Testing
@testable import Phorm

@Suite("SealGlyph")
struct SealGlyphTests {
    @Test func ranksRenderAsArabicDecimals() {
        #expect(SealGlyph.forRank(1) == "1")
        #expect(SealGlyph.forRank(2) == "2")
        #expect(SealGlyph.forRank(8) == "8")
        #expect(SealGlyph.forRank(12) == "12")
    }

    @Test func nonPositiveRankIsEmpty() {
        #expect(SealGlyph.forRank(0) == "")
        #expect(SealGlyph.forRank(-3) == "")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd andiem-ios && xcodebuild test -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:PhormTests/SealGlyph 2>&1 | tail -20
```
Expected: FAIL — `forRank(1)` currently returns `"壹"`, not `"1"`.

- [ ] **Step 3: Replace the Hán table with Arabic output**

In `andiem-ios/Phorm/Views/Components/Seal.swift`, replace the `SealGlyph` enum (lines 60-72) with:

```swift
/// Rank numerals for seals — plain Arabic so a Vietnamese player reads them at a glance.
enum SealGlyph {
    /// 1-based rank → "1" / "2" / "3" … ("" for rank < 1).
    static func forRank(_ rank: Int) -> String {
        guard rank >= 1 else { return "" }
        return "\(rank)"
    }
}
```

Also update the `Seal` struct doc comment (lines 3-7) to drop the "Hán-Việt numeral" / "ấn vàng / tem chéo" wording, e.g.:

```swift
/// Rank seal — the gold-leaf stamp brand mark. Content is plain Arabic rank.
/// Variants: `.winner` (solid gold, dark ink, glow), `.last` (muted ring),
/// `.default` (gold border + faint gold tint).
```

- [ ] **Step 4: Update the auto-fill badge glyph**

In `andiem-ios/Phorm/Views/RoundEntryView.swift:211`, change the decorative auto-fill seal from the Hán `封` to a legible "computed" mark:

```swift
                Seal(glyph: "=", variant: .winner, size: 22)
```

(The `=` reads as "auto-computed", consistent with the `−(sum)` auto-fill semantics.)

- [ ] **Step 5: Update the in-file `#Preview` and run tests**

In `Seal.swift` the `#Preview` (lines 74-90) passes `SealGlyph.forRank(...)` (fine) and two literals `"封"`/`"×"` (lines 85-86) — change those two to `"1"` and `"4"` so the preview matches. Then run:

```bash
cd andiem-ios && xcodebuild test -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:PhormTests/SealGlyph 2>&1 | tail -20
```
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/PhormTests/SealGlyphTests.swift \
  andiem-ios/Phorm/Views/Components/Seal.swift \
  andiem-ios/Phorm/Views/RoundEntryView.swift
git commit -m "feat: legible Arabic rank seals, drop Hán glyphs"
```

---

## Task 3: Adaptive color tokens (paper light / lacquer dark)

The core contrast fix. Create 6 adaptive colorsets and repoint the high-traffic statics to them. View callsites are untouched.

**Files:**
- Create: 6 colorsets under `andiem-ios/Phorm/Resources/Assets.xcassets/`:
  `InkPrimary.colorset`, `InkSecondary.colorset`, `SurfaceRoot.colorset`, `ScoreUp.colorset`, `ScoreDown.colorset`, `GoldLabel.colorset` (each with `Contents.json`)
- Modify: `andiem-ios/Phorm/DesignSystem/Color+Tokens.swift`

**Interfaces:**
- Consumes: paper hexes confirmed in Task 1.
- Produces: these statics become adaptive (same names, used in views unchanged):
  `phormCream` → `Color("InkPrimary")`; `phormCreamDim` & `phormMuted` → `Color("InkSecondary")`; `phormSurfaceCinnabar` → `Color("SurfaceRoot")`; `scorePositive` → `Color("ScoreUp")`; `scoreNegative` & `warning` → `Color("ScoreDown")`; `phormGoldBright` → `Color("GoldLabel")`. `phormPrimary` (gold), `onPrimary` (`#5A1612`), and `phormSurfaceCinnabarDeep` (`#5A1612`) stay fixed (they read on both surfaces).

- [ ] **Step 1: Create the colorset directories and `Contents.json`**

For each colorset, create `andiem-ios/Phorm/Resources/Assets.xcassets/<Name>.colorset/Contents.json` with two color entries: an unqualified (light) entry = paper value, and a `luminosity: dark` entry = lacquer value. Use this template (example shown for `InkPrimary`; substitute the hex pair per the table below):

```json
{
  "colors" : [
    {
      "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0x2E", "green" : "0x1C", "blue" : "0x16" } },
      "idiom" : "universal"
    },
    {
      "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ],
      "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0xF3", "green" : "0xE8", "blue" : "0xD2" } },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

Hex pairs (light / dark):

| Colorset | Light (paper) | Dark (lacquer) |
|---|---|---|
| `InkPrimary` | `0x2E,0x1C,0x16` | `0xF3,0xE8,0xD2` |
| `InkSecondary` | `0x6B,0x5A,0x4A` | `0xD6,0xC4,0xA0` |
| `SurfaceRoot` | `0xF2,0xE9,0xD8` | `0x8C,0x2A,0x22` |
| `ScoreUp` | `0x1B,0x6B,0x47` | `0xB6,0xE0,0xC2` |
| `ScoreDown` | `0xA6,0x3A,0x1E` | `0xF2,0xB4,0x88` |
| `GoldLabel` | `0x8C,0x2A,0x22` | `0xE8,0xC5,0x70` |

- [ ] **Step 2: Repoint the statics in `Color+Tokens.swift`**

In `andiem-ios/Phorm/DesignSystem/Color+Tokens.swift`, change these six static definitions from fixed RGB to asset references (keep the doc comments, update the contrast notes):

```swift
    /// Primary text. Adaptive: espresso ink on paper / cream on lacquer.
    static let phormCream    = Color("InkPrimary")
    /// Secondary text, labels, dates. Adaptive: taupe / cream-dim.
    static let phormCreamDim = Color("InkSecondary")
    /// Neutral muted (alias of secondary).
    static let phormMuted    = Color("InkSecondary")
    /// Root session surface. Adaptive: warm paper / cinnabar lacquer.
    static let phormSurfaceCinnabar = Color("SurfaceRoot")
    /// Positive scores. Adaptive: deep jade / mint. Always with `+` sign.
    static let scorePositive = Color("ScoreUp")
    /// Negative scores. Adaptive: burnt rust / peach. Always with `−` sign.
    static let scoreNegative = Color("ScoreDown")
    /// Soft warning (non-zero round total) — reuses the down color.
    static let warning       = Color("ScoreDown")
    /// Brighter gold for small labels. Adaptive: cinnabar on paper / gold on lacquer.
    static let phormGoldBright = Color("GoldLabel")
```

Leave `phormPrimary`, `phormPrimaryActive`, `phormPrimaryDisabled`, `onPrimary`, `phormSurfaceCinnabarDeep`, and the alternate surfaces (`phormSurfaceOchre/Jade/Oxblood`) as their existing fixed values.

- [ ] **Step 3: Classify `phormSurfaceCinnabarDeep` usages**

Run:
```bash
cd andiem-ios && grep -rn "phormSurfaceCinnabarDeep" Phorm --include="*.swift"
```
For each hit, confirm it is used as dark ink / accent / vignette (reads on both surfaces) and NOT as a full-screen surface fill. If any hit fills a root background, note it for the Task 4 verification (it must instead use `phormSurfaceCinnabar`). Expected: all uses are ink/vignette/deep-panel accents — no change needed. Record findings in the commit message.

- [ ] **Step 4: Build to verify it compiles and assets resolve**

Run:
```bash
cd andiem-ios && xcodebuild build -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 17' 2>&1 | tail -15
```
Expected: `** BUILD SUCCEEDED **`. (Missing-asset names would surface as runtime fallback, not build failure — so also confirm each `Color("…")` name matches a created colorset directory exactly.)

- [ ] **Step 5: Capture light + dark screenshots for review**

Build/run is verified; UI driving is deferred to the user (see memory: simulator click injection doesn't reach SwiftUI). Use the existing screenshot tooling if it runs headlessly:
```bash
cd andiem-ios && ./tools/screenshots/capture.sh 2>&1 | tail -10 || echo "capture needs manual run"
```
If capture is not automatable, ask the user to run the app in both Light and Dark appearance (Simulator → Settings → Developer → Dark Appearance) and confirm legibility.

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/Phorm/Resources/Assets.xcassets \
  andiem-ios/Phorm/DesignSystem/Color+Tokens.swift
git commit -m "feat: adaptive paper/lacquer color tokens for AA contrast"
```

---

## Task 4: Adaptive lacquer surface (paper grain by day, lacquer by night)

The `LacquerBackground` currently always draws cinnabar + halftone + heavy vignette. On the paper surface it must render as calm warm paper with only subtle grain (no screen-blend halftone, no dark vignette eating contrast).

**Files:**
- Modify: `andiem-ios/Phorm/DesignSystem/LacquerSurface.swift:13-53`

**Interfaces:**
- Consumes: `Color("SurfaceRoot")` (via `phormSurfaceCinnabar`, now adaptive) from Task 3.
- Produces: `LacquerBackground` and `.lacquerBackground(_:)` unchanged in signature; texture intensity now reacts to color scheme.

- [ ] **Step 1: Make texture intensity react to color scheme**

In `andiem-ios/Phorm/DesignSystem/LacquerSurface.swift`, add `@Environment(\.colorScheme) private var scheme` to `LacquerBackground` and gate the heavy lacquer textures so they only apply in dark mode. Replace the `body` (lines 16-44) with:

```swift
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            surface

            if scheme == .dark {
                // Lacquer night: warm vignette + halftone + grain
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.86, blue: 0.70).opacity(0.10),
                        .clear,
                        Color.black.opacity(0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(uiImage: .phormHalftone)
                    .resizable(resizingMode: .tile)
                    .blendMode(.screen)
                    .allowsHitTesting(false)
                Image(uiImage: .phormGrain)
                    .resizable(resizingMode: .tile)
                    .blendMode(.overlay)
                    .opacity(0.55)
                    .allowsHitTesting(false)
            } else {
                // Paper day: only faint grain, no vignette/halftone
                Image(uiImage: .phormGrain)
                    .resizable(resizingMode: .tile)
                    .blendMode(.multiply)
                    .opacity(0.05)
                    .allowsHitTesting(false)
            }
        }
    }
```

- [ ] **Step 2: Build to verify it compiles**

Run:
```bash
cd andiem-ios && xcodebuild build -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 17' 2>&1 | tail -15
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: USER VISUAL CHECKPOINT (light + dark)**

Ask the user to confirm: in Light appearance the background is calm paper (no red cast, faint grain only) and text is crisp; in Dark appearance the lacquer + halftone + vignette still read as before. Adjust grain opacity/blend only if the user reports it muddies the paper.

- [ ] **Step 4: Commit**

```bash
git add andiem-ios/Phorm/DesignSystem/LacquerSurface.swift
git commit -m "feat: paper surface by day, lacquer texture only at night"
```

---

## Task 5: Plain table-talk wording + legible seals in summary

Localized string + seal-content edits in the summary screen.

**Files:**
- Modify: `andiem-ios/Phorm/Views/SummaryView.swift` (champion block ~150-179, last-place block ~210-228, tied copy ~239-242)

**Interfaces:**
- Consumes: `Seal` + `SealGlyph` from Task 2 (`.winner`/`.last` variants, Arabic content).
- Produces: no new symbols; user-facing copy only.

- [ ] **Step 1: Relabel the champion block**

In `andiem-ios/Phorm/Views/SummaryView.swift`, in `championBlock(name:total:)`:
- Change the section label (line ~150) from `SectionLabel(text: "Vô địch ván", tone: .gold)` to `SectionLabel(text: "Nhất bàn", tone: .gold)`.
- Change the winner seal glyph (line ~164) from `Seal(glyph: "壹", variant: .winner, size: 34)` to `Seal(glyph: "1", variant: .winner, size: 34)`.
- Remove the `Text("Ấn vàng")` label (lines ~165-167) and its leading `Seal`+`Text` `HStack` decoration block reduces to just the gold seal beside the champion. If removing the whole boxed callout (lines ~163-178) reads cleaner, keep only the gold `Seal(glyph: "1", variant: .winner, size: 34)` as a trailing accent on the name row; do not leave an empty bordered box.

- [ ] **Step 2: Relabel the last-place block**

In `lastPlaceBlock(name:)`:
- Change `SectionLabel(text: "Tem cuối bàn")` (line ~214) to `SectionLabel(text: "Bét bàn")`.
- Change the last seal (line ~220) from `Seal(glyph: "×", variant: .last, size: 28)` to `Seal(glyph: "\(ranking.count)", variant: .last, size: 28)` so it shows the (de-emphasized) last rank number, not an aggressive ×.

- [ ] **Step 3: Soften the tied-state copy**

Change the tied-rank explanatory text (line ~241) from `"Phiên có tổng bằng nhau, không xác định vô địch/cuối bàn"` to `"Hoà — chưa rõ ai nhất, ai bét"`. (Leave the `"Chưa đóng dấu được"` label at line ~239; it is already plain.)

- [ ] **Step 4: Grep for any remaining literary terms**

Run:
```bash
cd andiem-ios && grep -rn "Vô địch\|Ấn vàng\|Tem cuối bàn\|壹\|封\|贰\|叁\|肆\|×" Phorm --include="*.swift"
```
Expected: no user-facing matches remain (screenshot-support doc comments in `ScreenshotSupport.swift` are non-user-facing — update their comments for accuracy but they don't render).

- [ ] **Step 5: Build to verify it compiles**

Run:
```bash
cd andiem-ios && xcodebuild build -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 17' 2>&1 | tail -15
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/Phorm/Views/SummaryView.swift
git commit -m "feat: plain table-talk wording (Nhất bàn / Bét bàn) in summary"
```

---

## Task 6: Update source-of-truth docs

The design docs are intentional commitments; this redesign overturns several, so they must be rewritten to match.

**Files:**
- Modify: `DESIGN.md`, `CLAUDE.md`, `PRODUCT.md`

**Interfaces:** none (prose).

- [ ] **Step 1: Update `DESIGN.md`**

Replace the "one drenched lacquer surface / no light-dark equal peers" framing with the dual-surface system. Update the score-token section: day values jade `#1B6B47` (up) / rust `#A63A1E` (down); night values mint `#B6E0C2` (up) / peach `#F2B488` (down, replacing the failing `#E6A665`). Add the paper palette (ground `#F2E9D8`, ink `#2E1C16`, secondary `#6B5A4A`). Note seal content is Arabic, not Hán. State the canonical reference is the dual-surface `themes-preview.html`.

- [ ] **Step 2: Update `CLAUDE.md`**

In the "Design system anchors" section, replace "App does NOT have binary light/dark equal peers… one drenched lacquer surface per session" with the paper-by-day / lacquer-by-night model (follow system). Update the score-semantics line to the new adaptive up/down values. Update the brand/voice anchor that names "ấn vàng / tem chéo" so it describes the seal *shape* as the earned decoration with plain labels ("Nhất bàn / Bét bàn") and Arabic rank content.

- [ ] **Step 3: Update `PRODUCT.md`**

Adjust the brand anchor and accessibility-commitments lines: keep the gold seal as the one earned decoration but state its labels are plain table talk and its content is legible Arabic. Update the WCAG line to reflect both surfaces are measured AA (paper ink ~12:1, day scores ≥5.5:1; night cream 6.96:1, night down-score peach ~5.2:1).

- [ ] **Step 4: Commit**

```bash
git add DESIGN.md CLAUDE.md PRODUCT.md
git commit -m "docs: dual-surface + plain-wording redesign (supersede locked anchors)"
```

---

## Final verification

- [ ] Full test suite green: `cd andiem-ios && xcodebuild test -scheme Phorm -destination 'platform=iOS Simulator,name=iPhone 17' 2>&1 | tail -20` → all tests pass (existing Totals/AutoFill/SessionShare/SessionActions + new SealGlyph).
- [ ] No user-facing literary terms or Hán glyphs remain (Task 5 Step 4 grep clean).
- [ ] User confirms, via simulator in both Light and Dark appearance: round-entry and summary scores/labels are comfortably legible; summary shows "Nhất bàn" / "Bét bàn"; seals show Arabic content; last place is muted, not an aggressive ×; surface flips paper↔lacquer with system appearance and brand identity persists.
