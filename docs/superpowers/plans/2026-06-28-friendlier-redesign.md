# An Điểm Tactile/Playful Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the round-score experience from "a page you read" into "a card-table you play on" — tactile color-filled score chips with depth, a 3D pressable keypad with haptics, round coin seat tokens, a brightened day/night palette, plain table-talk wording, and clean sans type.

**Architecture:** Adaptive bright color tokens (day/night) repointed in `Color+Tokens.swift` via `Assets.xcassets`. New SwiftUI components — `ScoreChip` (filled tactile tile) and `Coin` (round seat/winner token, replacing the square `Seal`) — built once and reused by `RoundEntryView` and `SummaryView`. `Keypad` rebuilt with 3D keys + haptics. Lacquer halftone/grain texture retired on core screens; depth comes from chip/key shadows. The `TACTILE / PLAYFUL DIRECTION` section of `themes-preview.html` (CSS prefix `tc-`, frames T1–T4) is the canonical visual contract for exact colors, radii, shadows, and sizes.

**Tech Stack:** SwiftUI (iOS 17+), SwiftData, `Assets.xcassets` colorsets with `luminosity` light/dark variants, existing `Haptics` helper, Swift Testing for logic, `xcodebuild` for build verification. Scheme `Phorm`, simulator `iPhone 17`.

## Global Constraints

- iOS 17+, SwiftUI only (UIKit allowed only for existing texture/image helpers).
- Vietnamese-only UI copy. No English strings, no i18n scaffolding.
- **Every score number keeps an explicit `+`/`−` sign prefix** (color-blind safety; the chip fill is an addition, not a replacement, for that cue).
- Score chips are **color-filled** (up `#21BD73`, down `#FF6B3D`, neutral `#ECE4D6` day) with white bold tabular numbers — this intentionally overrides the old "score color is text-only" rule.
- Playful = material depth + motion + color. **Never** mascots, confetti, emoji, or 🎉-style copy.
- Single brand-accent family: Tết-red `#E5483A` + gold `#F2B829`. Gold carries the winner coin / special keys.
- Clean sans only (system SF Pro; Inter is the mockup target). Numbers use `.monospacedDigit()` (tabular). SF Mono forbidden.
- Appearance follows system. No onboarding / mode-picker.
- Canonical visual contract: `themes-preview.html` → `TACTILE / PLAYFUL DIRECTION` section (`tc-` classes, T1–T4). When this plan and the mockup disagree, the mockup wins — read exact values from it.
- Exact palette (verbatim): day bg `#FBF4E6`, tile `#FFFBF3`, ink `#2A211C`; night bg `#241715`, ink `#F6ECDA`; accent `#E5483A`; gold `#F2B829`; chip-up `#21BD73`; chip-down `#FF6B3D`; chip-neutral-day `#ECE4D6`; on-chip text `#FFFFFF`.
- Build verification command (every visual task): `cd andiem-ios && xcodebuild build -scheme Phorm -destination 'platform=iOS Simulator,name=iPhone 17' 2>&1 | tail -15` → expect `** BUILD SUCCEEDED **`. Interactive UI confirmation is deferred to the user (simulator click injection can't drive SwiftUI).

---

## File map

- `themes-preview.html` — tactile mockup (Task 1, **already done**: commits `827a98f`, `8984a7c`, `0ffcbb3`).
- `andiem-ios/Phorm/Resources/Assets.xcassets/*.colorset` — bright adaptive colorsets (Task 2).
- `andiem-ios/Phorm/DesignSystem/Color+Tokens.swift` — repoint statics (Task 2).
- `andiem-ios/Phorm/DesignSystem/Font+Tokens.swift` — serif → clean sans (Task 3).
- `andiem-ios/Phorm/DesignSystem/LacquerSurface.swift` — flat bright surfaces, retire texture (Task 4).
- `andiem-ios/Phorm/Views/Components/ScoreChip.swift` — **create** tactile chip (Task 5).
- `andiem-ios/Phorm/Views/Components/Coin.swift` — **create** round coin token; `andiem-ios/PhormTests/SealGlyphTests.swift` — **create** (Task 6).
- `andiem-ios/Phorm/Views/Components/Seal.swift` — `SealGlyph` → Arabic; deprecate square `Seal` in favor of `Coin` (Task 6).
- `andiem-ios/Phorm/Views/Components/Keypad.swift`, `andiem-ios/Phorm/DesignSystem/Haptics.swift` — tactile keypad (Task 7).
- `andiem-ios/Phorm/Views/RoundEntryView.swift` — tactile rebuild (Task 8).
- `andiem-ios/Phorm/Views/SummaryView.swift`, `SessionView.swift` — tactile + plain wording (Task 9).
- `DESIGN.md`, `CLAUDE.md`, `PRODUCT.md` — doc anchors (Task 10).

---

## Task 2: Bright tactile color tokens (day/night adaptive)

Repoint the high-traffic color statics to bright adaptive colorsets. View callsites keep their token names.

**Files:**
- Create colorsets under `andiem-ios/Phorm/Resources/Assets.xcassets/`: `SurfaceRoot`, `SurfaceTile`, `InkPrimary`, `InkSecondary`, `BrandAccent`, `BrandGold`, `ChipUp`, `ChipDown`, `ChipNeutral`, `OnChip` (each a `.colorset/Contents.json`).
- Modify: `andiem-ios/Phorm/DesignSystem/Color+Tokens.swift`.

**Interfaces:**
- Produces adaptive statics (same names used in views): `phormSurfaceCinnabar` → `Color("SurfaceRoot")`; `phormCream` → `Color("InkPrimary")`; `phormCreamDim`/`phormMuted` → `Color("InkSecondary")`; `phormPrimary` → `Color("BrandAccent")`; `phormGoldBright` → `Color("BrandGold")`; `scorePositive` → `Color("ChipUp")`; `scoreNegative`/`warning` → `Color("ChipDown")`. New: `Color.surfaceTile = Color("SurfaceTile")`, `Color.chipNeutral = Color("ChipNeutral")`, `Color.onChip = Color("OnChip")`.

- [ ] **Step 1: Create the 10 colorsets**

For each, create `<Name>.colorset/Contents.json` with an unqualified (light) color = day value and a `luminosity: dark` entry = night value, using this shape (example `BrandAccent`):

```json
{
  "colors" : [
    { "idiom" : "universal", "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0xE5", "green" : "0x48", "blue" : "0x3A" } } },
    { "idiom" : "universal", "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ], "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0xE5", "green" : "0x48", "blue" : "0x3A" } } }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

Hex pairs (light day / dark night):

| Colorset | Day | Night |
|---|---|---|
| `SurfaceRoot` | `0xFB,0xF4,0xE6` | `0x24,0x17,0x15` |
| `SurfaceTile` | `0xFF,0xFB,0xF3` | `0x3A,0x28,0x24` |
| `InkPrimary` | `0x2A,0x21,0x1C` | `0xF6,0xEC,0xDA` |
| `InkSecondary` | `0x6B,0x5A,0x4A` | `0xC9,0xB7,0x9C` |
| `BrandAccent` | `0xE5,0x48,0x3A` | `0xE5,0x48,0x3A` |
| `BrandGold` | `0xF2,0xB8,0x29` | `0xF2,0xB8,0x29` |
| `ChipUp` | `0x21,0xBD,0x73` | `0x21,0xBD,0x73` |
| `ChipDown` | `0xFF,0x6B,0x3D` | `0xFF,0x6B,0x3D` |
| `ChipNeutral` | `0xEC,0xE4,0xD6` | `0x4A,0x39,0x34` |
| `OnChip` | `0xFF,0xFF,0xFF` | `0xFF,0xFF,0xFF` |

- [ ] **Step 2: Repoint statics in `Color+Tokens.swift`**

Change these statics to asset references (keep names; update doc comments):

```swift
    static let phormPrimary    = Color("BrandAccent")   // Tết-red accent / focus ring / CTA
    static let phormGoldBright = Color("BrandGold")     // winner coin, special keys
    static let phormCream      = Color("InkPrimary")    // primary text (adaptive)
    static let phormCreamDim   = Color("InkSecondary")
    static let phormMuted      = Color("InkSecondary")
    static let phormSurfaceCinnabar = Color("SurfaceRoot")
    static let scorePositive   = Color("ChipUp")
    static let scoreNegative   = Color("ChipDown")
    static let warning         = Color("ChipDown")
    /// Card / tile surface — chips, active-row card, panels.
    static let surfaceTile     = Color("SurfaceTile")
    /// Neutral/zero chip fill.
    static let chipNeutral     = Color("ChipNeutral")
    /// Text on a color-filled chip (white).
    static let onChip          = Color("OnChip")
```

Leave `onPrimary`, `phormPrimaryActive`, `phormPrimaryDisabled`, `phormSurfaceCinnabarDeep`, and the alternate surfaces as-is for now (Task 4 / later tasks adjust usage).

- [ ] **Step 3: Build to verify it compiles and asset names resolve**

Run the Global-Constraints build command. Expected: `** BUILD SUCCEEDED **`. Confirm each `Color("…")` name exactly matches a created `.colorset` directory.

- [ ] **Step 4: Commit**

```bash
git add andiem-ios/Phorm/Resources/Assets.xcassets andiem-ios/Phorm/DesignSystem/Color+Tokens.swift
git commit -m "feat: bright tactile day/night color tokens"
```

---

## Task 3: Clean sans typography

Rework type tokens from editorial serif (currently New York fallback) to system SF Pro. No view callsites change.

**Files:** Modify `andiem-ios/Phorm/DesignSystem/Font+Tokens.swift`.

**Interfaces:** Token names unchanged; only `design:` and name-italic change. Helper `scaledSerif` → `scaledSans`. Adds `phormNumberEntryFocused` for Task 8.

- [ ] **Step 1: Swap every `design: .serif` → `design: .default`**

Apply to all tokens: `phormDisplayMd`, `phormTitleLg`, `phormTitleMd`, `phormTitleSm`, `phormBodyMd`, `phormBodySm`, `phormCaption`, `phormButton`, `phormNameDisplay`, `phormNameMd`, `phormNumberHero`, `phormNumberRanking`, `phormNumberEntry`, `phormNumberMd`, `phormNumberSm`, `phormNumberChip`, `phormNumberScript`, `phormKeypadDigit`. Keep all sizes, weights, and `.monospacedDigit()`.

- [ ] **Step 2: De-serif names + scaled helper; add focused numeral**

Rename helper `scaledSerif` → `scaledSans` using `.withDesign(.default)`, update its callers (`phormHeroDisplay`, `phormDisplayLg`, `phormCaptionSection`). Drop `.italic()` on names; distinguish `phormNumberScript` by weight not italic; add the focused token:

```swift
    static let phormNameDisplay  = Font.system(size: 22, weight: .semibold, design: .default)
    static let phormNameMd       = Font.system(size: 18, weight: .semibold, design: .default)
    static let phormNumberScript = Font.system(size: 22, weight: .regular, design: .default).monospacedDigit()
    /// Focused round-entry value — dominant number on the entry screen. 34pt / 800.
    static let phormNumberEntryFocused = Font.system(size: 34, weight: .heavy, design: .default).monospacedDigit()
```

- [ ] **Step 3: Update the file doc comment** to describe system SF Pro (humanist sans, full Vietnamese diacritics, Dynamic Type), tabular figures for numerals, SF Mono still forbidden.

- [ ] **Step 4: Build** (Global-Constraints command). Expected `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**

```bash
git add andiem-ios/Phorm/DesignSystem/Font+Tokens.swift
git commit -m "feat: clean sans typography (drop serif register)"
```

---

## Task 4: Flat bright surfaces (retire lacquer texture on core screens)

The tactile direction gets depth from chips/keys, not surface noise. `LacquerBackground` becomes a plain adaptive surface (no halftone, no heavy vignette).

**Files:** Modify `andiem-ios/Phorm/DesignSystem/LacquerSurface.swift:13-53`.

**Interfaces:** `LacquerBackground` and `.lacquerBackground(_:)` keep their signatures; body simplified.

- [ ] **Step 1: Simplify `LacquerBackground.body`**

Replace the `body` (lines 16-44) so it renders just the adaptive surface with an optional very-faint grain in dark only (keep the precomputed `phormGrain` for night warmth; drop halftone + bright vignette):

```swift
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            surface
            if scheme == .dark {
                Image(uiImage: .phormGrain)
                    .resizable(resizingMode: .tile)
                    .blendMode(.overlay)
                    .opacity(0.25)
                    .allowsHitTesting(false)
            }
        }
    }
```

(Leave the `phormHalftone`/`phormGrain` static tile definitions in the file; only the `body` stops using halftone. The default `surface` parameter stays `.phormSurfaceCinnabar`, now `SurfaceRoot`.)

- [ ] **Step 2: Build** (Global-Constraints command). Expected `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add andiem-ios/Phorm/DesignSystem/LacquerSurface.swift
git commit -m "feat: flat bright surface, retire halftone texture"
```

---

## Task 5: `ScoreChip` tactile component

A reusable color-filled chip tile with depth and a size variant. Used by round entry and summary.

**Files:** Create `andiem-ios/Phorm/Views/Components/ScoreChip.swift`.

**Interfaces:**
- Consumes: `Color.scorePositive`/`scoreNegative`/`chipNeutral`/`onChip`, `ScoreFormat.signed(_:)`.
- Produces: `ScoreChip(value: Int?, size: ScoreChip.Size, isFocused: Bool)` where `enum Size { case small, large }`. `value == nil` or `0` → neutral chip; `>0` → up fill; `<0` → down fill. Renders `ScoreFormat.signed(value ?? 0)` (or a placeholder when nil) in `OnChip` white, tabular bold. Visual contract = `tc-chip-*` in the mockup: radius 14, bottom bevel `inset 0 -3px`, soft drop shadow, large ≈82×50 / small ≈58×36, focus ring (accent) when `isFocused`.

- [ ] **Step 1: Implement `ScoreChip`**

```swift
import SwiftUI

/// Color-filled tactile score tile — the card-table "piece". Up = green, down = coral,
/// zero/empty = neutral. White tabular number with explicit +/− sign. Matches `tc-chip-*`.
struct ScoreChip: View {
    enum Size { case small, large }

    let value: Int?
    var size: Size = .small
    var isFocused: Bool = false

    private var fill: Color {
        switch value ?? 0 {
        case let v where v > 0: return .scorePositive
        case let v where v < 0: return .scoreNegative
        default:                return .chipNeutral
        }
    }
    private var label: String { value == nil ? "0" : ScoreFormat.signed(value!) }
    private var isZeroOrEmpty: Bool { (value ?? 0) == 0 }
    private var dims: (w: CGFloat, h: CGFloat, font: CGFloat, radius: CGFloat) {
        size == .large ? (82, 50, 30, 16) : (58, 36, 20, 14)
    }

    var body: some View {
        Text(label)
            .font(.system(size: dims.font, weight: .heavy, design: .default).monospacedDigit())
            .foregroundStyle(isZeroOrEmpty ? Color.phormMuted : Color.onChip)
            .frame(width: dims.w, height: dims.h)
            .background(
                RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                    .fill(fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                            .fill(Color.black.opacity(0.12))
                            .mask(alignment: .bottom) { Rectangle().frame(height: 3) }
                    )
                    .shadow(color: fill.opacity(0.35), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                    .strokeBorder(Color.phormPrimary, lineWidth: isFocused ? 3 : 0)
            )
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: size)
            .accessibilityLabel(Text(label))
    }
}

#Preview {
    HStack(spacing: 12) {
        ScoreChip(value: 12, size: .large, isFocused: true)
        ScoreChip(value: -7)
        ScoreChip(value: 0)
        ScoreChip(value: nil)
    }
    .padding()
    .background(Color.phormSurfaceCinnabar)
}
```

- [ ] **Step 2: Build** (Global-Constraints command). Expected `** BUILD SUCCEEDED **` (the `#Preview` compiles it).

- [ ] **Step 3: Commit**

```bash
git add andiem-ios/Phorm/Views/Components/ScoreChip.swift
git commit -m "feat: ScoreChip tactile filled tile component"
```

---

## Task 6: `Coin` token + Arabic rank (replace square seal)

Round coin seat/winner token replacing the square `Seal`; rank content becomes Arabic. Includes the unit-testable `SealGlyph` change.

**Files:**
- Create: `andiem-ios/Phorm/Views/Components/Coin.swift`, `andiem-ios/PhormTests/SealGlyphTests.swift`.
- Modify: `andiem-ios/Phorm/Views/Components/Seal.swift` (`SealGlyph.forRank` → Arabic).

**Interfaces:**
- Produces: `SealGlyph.forRank(_:) -> String` returns Arabic (`"1"`…, `""` for <1). `Coin(text: String, variant: Coin.Variant, size: CGFloat)` with `enum Variant { case seat, winner, last }` — round token: `seat` = tile fill + ink number, `winner` = gold radial + dark number, `last` = muted coral ring + ink number. Visual contract = `tc-coin*` in the mockup.

- [ ] **Step 1: Write the failing `SealGlyph` test**

Create `andiem-ios/PhormTests/SealGlyphTests.swift`:

```swift
import Testing
@testable import Phorm

@Suite("SealGlyph")
struct SealGlyphTests {
    @Test func ranksRenderAsArabic() {
        #expect(SealGlyph.forRank(1) == "1")
        #expect(SealGlyph.forRank(8) == "8")
        #expect(SealGlyph.forRank(12) == "12")
    }
    @Test func nonPositiveIsEmpty() {
        #expect(SealGlyph.forRank(0) == "")
        #expect(SealGlyph.forRank(-3) == "")
    }
}
```

- [ ] **Step 2: Run to verify it fails**

`cd andiem-ios && xcodebuild test -scheme Phorm -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:PhormTests/SealGlyph 2>&1 | tail -20` → FAIL (`forRank(1)` currently `"壹"`).

- [ ] **Step 3: Make `SealGlyph` return Arabic**

In `Seal.swift` replace the `SealGlyph` enum body:

```swift
/// Rank numerals for tokens — plain Arabic so a Vietnamese player reads them instantly.
enum SealGlyph {
    static func forRank(_ rank: Int) -> String { rank >= 1 ? "\(rank)" : "" }
}
```

- [ ] **Step 4: Create the `Coin` component**

```swift
import SwiftUI

/// Round seat / winner token — the tactile "coin". Replaces the square Seal.
/// Matches `tc-coin*` in themes-preview.html.
struct Coin: View {
    enum Variant { case seat, winner, last }

    let text: String
    var variant: Variant = .seat
    var size: CGFloat = 32

    private var fill: AnyShapeStyle {
        switch variant {
        case .seat:   return AnyShapeStyle(Color.surfaceTile)
        case .winner: return AnyShapeStyle(RadialGradient(colors: [Color.phormGoldBright, Color.phormGoldBright.opacity(0.78)], center: .topLeading, startRadius: 1, endRadius: size))
        case .last:   return AnyShapeStyle(Color.scoreNegative.opacity(0.16))
        }
    }
    private var textColor: Color {
        switch variant {
        case .seat:   return .phormCreamDim
        case .winner: return Color(red: 0x3A/255, green: 0x22/255, blue: 0x06/255)
        case .last:   return .scoreNegative
        }
    }
    private var ring: Color {
        switch variant {
        case .seat:   return .phormCreamStroke
        case .winner: return .phormGoldBright
        case .last:   return .scoreNegative.opacity(0.5)
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.46, weight: .bold, design: .default).monospacedDigit())
            .foregroundStyle(textColor)
            .frame(width: size, height: size)
            .background(Circle().fill(fill))
            .overlay(Circle().strokeBorder(ring, lineWidth: variant == .seat ? 1 : 2))
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 14) {
        Coin(text: "1", variant: .winner, size: 40)
        Coin(text: "2")
        Coin(text: "4", variant: .last)
    }.padding().background(Color.phormSurfaceCinnabar)
}
```

- [ ] **Step 5: Run the test to verify it passes**

`cd andiem-ios && xcodebuild test -scheme Phorm -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:PhormTests/SealGlyph 2>&1 | tail -20` → PASS. (Also runs the build, compiling `Coin`'s `#Preview`.)

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/Phorm/Views/Components/Coin.swift andiem-ios/Phorm/Views/Components/Seal.swift andiem-ios/PhormTests/SealGlyphTests.swift
git commit -m "feat: round Coin token + Arabic rank (replace Hán seal glyphs)"
```

---

## Task 7: Tactile keypad (3D keys + haptics)

Rebuild the keypad keys as chunky 3D buttons that depress on press, with haptic feedback.

**Files:** Modify `andiem-ios/Phorm/Views/Components/Keypad.swift`; use `andiem-ios/Phorm/DesignSystem/Haptics.swift`.

**Interfaces:**
- Consumes: existing `Keypad` public API (`onKey`, `onSave`, `canSave`, `sign`), `Haptics`, `Color.surfaceTile`/`phormPrimary`/`phormGoldBright`/`onChip`/`phormCream`.
- Produces: same `Keypad` init signature; internal key view becomes a tactile button. Visual contract = `tc-key*` in the mockup: gradient face, `box-shadow 0 4px 0` bottom ridge (SwiftUI: a darker capsule/rounded-rect offset below, or bottom inset), press → `translateY(3px)` + ridge shrink. Sign key tinted brand-accent; save/CTA gets the 3D bottom edge.

- [ ] **Step 1: Read the current `Keypad.swift`** to learn its exact key layout, the `onKey` payload type, and how the sign key + delete + save are wired. Preserve all behavior.

- [ ] **Step 2: Add a tactile key button style**

Implement a reusable key button that renders a rounded-rect face over a darker "ridge" rectangle offset `+4` in y, and on press translates the face down by 3 and shrinks the visible ridge, firing `Haptics`. Use the existing `Haptics` API discovered in Step 1 (e.g. a light impact). Example shape (adapt names to the actual file):

```swift
private struct TactileKey<Label: View>: View {
    var fill: Color = .surfaceTile
    var ridge: Color = Color.black.opacity(0.18)
    let action: () -> Void
    @ViewBuilder var label: () -> Label
    @GestureState private var pressed = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        label()
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(shape.fill(fill))
            .background(shape.fill(ridge).offset(y: pressed ? 1 : 4))
            .offset(y: pressed ? 3 : 0)
            .contentShape(shape)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($pressed) { _, s, _ in if !s { s = true; Haptics.tap() } }
                    .onEnded { _ in action() }
            )
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: pressed)
    }
}
```

(If `Haptics` has no `tap()`, use whatever light-impact method it exposes; do not add a new dependency.)

- [ ] **Step 3: Apply `TactileKey` to digits, sign, delete, and save**

Wrap each existing key with `TactileKey`. Sign key `fill: .phormPrimary` with `.onChip` glyph; save/confirm uses `.phormPrimary` fill, `.onChip` label, same ridge treatment. Digits use `.surfaceTile` with `.phormCream` text. Keep the existing grid layout and callbacks.

- [ ] **Step 4: Build** (Global-Constraints command). Expected `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**

```bash
git add andiem-ios/Phorm/Views/Components/Keypad.swift andiem-ios/Phorm/DesignSystem/Haptics.swift
git commit -m "feat: tactile 3D keypad keys with haptic press"
```

---

## Task 8: `RoundEntryView` tactile rebuild

Compose the new pieces into the hero screen: coin seat tokens, `ScoreChip` per player, the focused row enlarged on a tile card with the rest receding, a "Tổng" pill, plain wording, on the flat bright surface.

**Files:** Modify `andiem-ios/Phorm/Views/RoundEntryView.swift` (`playerRow`, `cellView`, `cellValue`, `cellBackground`, `validationRow`, `bottomDock`).

**Interfaces:** Consumes `ScoreChip`, `Coin`, `SealGlyph` (Arabic), `Color.surfaceTile`, `phormNumberEntryFocused`, `ScoreFormat`. No new public symbols.

- [ ] **Step 1: Read the current `RoundEntryView.swift` in full** to map the existing row/cell/dock structure and the `draft` state (`focusedIndex`, `autoFillIndex`, `entries`, `signMode`, `liveSum`).

- [ ] **Step 2: Rebuild `playerRow`** so each row is: `Coin(text: SealGlyph.forRank(idx+1), variant: seatVariant)` + name + `ScoreChip(value: draft.entries[idx], size: isFocused ? .large : .small, isFocused: isFocused)`. The focused row sits on a `surfaceTile` rounded card with shadow and full opacity; inactive non-auto rows at `opacity(0.42)`. The auto-fill row uses a gold-tinted chip/coin but is quieter than the focused row. Keep the existing tap-to-focus and the `cellValue` typed/auto/placeholder logic, now rendered through `ScoreChip` (the chip shows the typed value; the focused empty state shows the sign placeholder).

- [ ] **Step 3: Replace the "Tổng" `validationRow` with a pill badge** — a rounded `Capsule` with `ScoreFormat.signed(sum)`: balanced (sum 0) → `chipUp`-tinted "0 · cân"; else `chipDown`-tinted "\(signed) ⚠". Matches `tc-tong` in the mockup.

- [ ] **Step 4: Update `bottomDock`** — drop the heavy `phormSurfaceCinnabarDeep` gradient; let the keypad (now tactile) sit on the flat surface with a light top hairline. Keep the `Keypad(...)` call unchanged.

- [ ] **Step 5: Grep for leftover literary/Hán/serif-isms in this file** — `grep -n "壹\|封\|×\|italic\|phormSurfaceCinnabarDeep" andiem-ios/Phorm/Views/RoundEntryView.swift` — resolve any user-facing ones.

- [ ] **Step 6: Build** (Global-Constraints command). Expected `** BUILD SUCCEEDED **`.

- [ ] **Step 7: Commit**

```bash
git add andiem-ios/Phorm/Views/RoundEntryView.swift
git commit -m "feat: tactile round-entry — chips, coins, active-row card, Tổng pill"
```

---

## Task 9: `SummaryView` (+ `SessionView`) tactile + plain wording

Apply chips/coins and plain table-talk wording to the end-of-session and leaderboard surfaces.

**Files:** Modify `andiem-ios/Phorm/Views/SummaryView.swift` (champion ~145-180, runners ~182-206, last ~210-228, tied ~239-242); `andiem-ios/Phorm/Views/SessionView.swift:185-186` (leaderboard coin).

**Interfaces:** Consumes `ScoreChip`, `Coin`, `SealGlyph`. Copy only otherwise.

- [ ] **Step 1: Champion block** — label "Vô địch ván" → **"Nhất bàn"**; show `Coin(text: "1", variant: .winner, size: 40)` + champion name + `ScoreChip(value: total, size: .large)`; remove the "Ấn vàng" callout label and its bordered box (no empty box left behind).

- [ ] **Step 2: Runners + last** — runner totals render as small `ScoreChip`s; last-place label "Tem cuối bàn" → **"Bét bàn"**, marker = `Coin(text: "\(ranking.count)", variant: .last)` (muted coral coin, not `×`).

- [ ] **Step 3: Tied copy** — "Phiên có tổng bằng nhau, không xác định vô địch/cuối bàn" → **"Hoà — chưa rõ ai nhất, ai bét"**.

- [ ] **Step 4: `SessionView` leaderboard** — replace the square `Seal(glyph: SealGlyph.forRank(rank), …)` at line ~185 with `Coin(text: SealGlyph.forRank(rank), variant: coinVariant(rank))` (winner for rank 1, last for the bottom seat per existing `sealVariant` logic, else seat).

- [ ] **Step 5: Grep both files** — `grep -n "Vô địch\|Ấn vàng\|Tem cuối bàn\|壹\|封\|×" andiem-ios/Phorm/Views/SummaryView.swift andiem-ios/Phorm/Views/SessionView.swift` → no user-facing matches.

- [ ] **Step 6: Build** (Global-Constraints command). Expected `** BUILD SUCCEEDED **`.

- [ ] **Step 7: Commit**

```bash
git add andiem-ios/Phorm/Views/SummaryView.swift andiem-ios/Phorm/Views/SessionView.swift
git commit -m "feat: tactile summary + leaderboard, plain table-talk wording"
```

---

## Task 10: Update source-of-truth docs

**Files:** Modify `DESIGN.md`, `CLAUDE.md`, `PRODUCT.md`.

- [ ] **Step 1: `DESIGN.md`** — replace the lacquer-surface/serif/text-only-score sections with the tactile system: bright day/night palette (values from Global Constraints), color-filled chips with sign prefix, coin tokens, 3D keypad, clean sans + tabular figures, retired halftone. Point to the `tc-` section of `themes-preview.html` as canonical.

- [ ] **Step 2: `CLAUDE.md`** — update Design-system anchors: dual bright surface (follow system), tactile chips override the text-only-score rule, coins replace seals, sans replaces serif, Tết-red + gold accents.

- [ ] **Step 3: `PRODUCT.md`** — note the approved override: colored score chips + brighter playful register are intentional; still-rejected list stays (mascots/confetti/emoji). Brand rests on Tết-red + gold + coin/chip tactility.

- [ ] **Step 4: Commit**

```bash
git add DESIGN.md CLAUDE.md PRODUCT.md
git commit -m "docs: tactile/playful redesign (supersede prior anchors)"
```

---

## Final verification

- [ ] Full suite green: `cd andiem-ios && xcodebuild test -scheme Phorm -destination 'platform=iOS Simulator,name=iPhone 17' 2>&1 | tail -20` (existing Totals/AutoFill/SessionShare/SessionActions + new SealGlyph).
- [ ] No user-facing literary terms / Hán glyphs / serif remain (Task 8/9 greps clean).
- [ ] **USER visual confirmation in the simulator**, Light + Dark: round entry shows color-filled chips with the focused row enlarged on a card and others receding; keypad keys depress with haptics; coins show Arabic; "Tổng" is a pill; summary shows "Nhất bàn"/"Bét bàn" with a gold winner coin; surfaces are bright and flip day/night with system appearance.
