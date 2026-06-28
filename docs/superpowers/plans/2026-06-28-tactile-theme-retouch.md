# Tactile Theme Retouch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish the half-done migration of `andiem-ios` from the retired dark "lacquer" view idiom to the tactile/playful warm system, so every screen matches the `tc-` mockup instead of rendering muddy gray on the warm cream surface.

**Architecture:** Three layers, compiler-guided. (1) Fix/extend the color asset + token foundation. (2) Build tactile primitives (card modifier, updated chip/coin/keypad, new badge/pill, renamed buttons). (3) Migrate each screen to consume the primitives and drop lacquer-era literals. Logic is untouched; this is a view-layer change.

**Tech Stack:** SwiftUI (iOS 17+), SwiftData, XcodeGen-generated project, asset-catalog adaptive colors.

## Global Constraints

- **iOS 17+, SwiftUI only** — no UIKit views (UIKit allowed only for existing image/render helpers).
- **Vietnamese-only copy** — do not add, translate, or alter any user-facing strings.
- **No logic changes** — Totals/AutoFill/SessionShare/SessionActions and all `Models/`, `Logic/`, `State/` files stay byte-identical. View-layer styling only.
- **Color-blind contract intact** — every score keeps its explicit `+`/`−` sign prefix (`ScoreFormat.signed`) and `.monospacedDigit()`. Chip color is additive, never the only cue.
- **No SF Mono, no serif** — typography stays `.system(design: .default)`.
- **Single source of truth** — all tactile colors come from `Color+Tokens.swift` / asset catalog. Zero raw hex literals or `Color.black.opacity(...)` card fills in `Views/` (the photo-composite exception in Task 14 is the only allowance).
- **Canonical reference:** `themes-preview.html` `tc-` section; values transcribed in `docs/superpowers/specs/2026-06-28-tactile-theme-retouch-design.md`.
- **Project regen:** after adding/removing any file under `andiem-ios/Phorm/`, run `xcodegen generate` before building (the `.xcodeproj` is generated, globs `Phorm/`). New `.colorset` dirs do not require regen but are picked up by the asset compiler on build.
- **Build command** (run from `andiem-ios/`):
  ```sh
  xcodebuild -project andiem-ios.xcodeproj -scheme Phorm \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    CODE_SIGNING_ALLOWED=NO build
  ```
- **Test command** (same dir): replace `build` with `test`.
- **Commit after every task.** Branch: create `tactile-retouch` off `main` before Task 1.

---

## File Structure

**Assets** (`andiem-ios/Phorm/Resources/Assets.xcassets/`)
- Modify: `SurfaceCard.colorset` (black-overlay → opaque card), `Hairline.colorset` (cream → adaptive subtle divider)
- Create: `KeyFaceTop`, `KeyFaceBottom`, `KeyRidge`, `KeySignFaceTop`, `KeySignFaceBottom`, `KeySignRidge`, `KeySignInk`, `CoinSeat`, `CoinSeatBevel`, `ChipNeutralBevel`, `CardShadow` colorsets

**Design system** (`andiem-ios/Phorm/DesignSystem/`)
- Modify: `Color+Tokens.swift` (new constants), `LacquerSurface.swift`→`AppBackground.swift` (rename), `LacquerControls.swift`→`TactileControls.swift` (rename + button restyle)
- Create: `TactileSurfaces.swift` (`tactileCard()` modifier, `Hairline`, `GoldRule`, `RoundBadge`, `StatusPill`)

**Components** (`andiem-ios/Phorm/Views/Components/`)
- Modify: `ScoreChip.swift`, `Coin.swift`, `Keypad.swift`, `RoundCard.swift`, `HistoryRow.swift`

**Screens** (`andiem-ios/Phorm/Views/`)
- Modify: `SessionView`, `RoundEntryView`, `SummaryView`, `NewSessionView`, `HistoryView`, `EmptyHomeView`, `ImportConfirmView`, `SplashView`, `Components/Seal.swift`, and `Stamp/{StampSourcePicker,StampEditorView,StampOnPhotoView,ShareCardView}.swift`

---

## Task 0: Branch

- [ ] **Step 1: Create the working branch**

Run (from repo root `/Users/dinhquy/Documents/quyctd/saam-app`):
```bash
git checkout -b tactile-retouch
```
Expected: `Switched to a new branch 'tactile-retouch'`

---

## Task 1: Color foundation — fix & extend assets + tokens

**Files:**
- Modify: `andiem-ios/Phorm/Resources/Assets.xcassets/SurfaceCard.colorset/Contents.json`
- Modify: `andiem-ios/Phorm/Resources/Assets.xcassets/Hairline.colorset/Contents.json`
- Create: 11 new `.colorset` dirs (listed below)
- Modify: `andiem-ios/Phorm/DesignSystem/Color+Tokens.swift`

**Interfaces:**
- Produces (asset names usable via `Color("…")`): `KeyFaceTop`, `KeyFaceBottom`, `KeyRidge`, `KeySignFaceTop`, `KeySignFaceBottom`, `KeySignRidge`, `KeySignInk`, `CoinSeat`, `CoinSeatBevel`, `ChipNeutralBevel`, `CardShadow`
- Produces (Color constants): `.cardSurface`, `.keyFaceTop`, `.keyFaceBottom`, `.keyRidge`, `.keySignFaceTop`, `.keySignFaceBottom`, `.keySignRidge`, `.keySignInk`, `.coinSeat`, `.coinSeatBevel`, `.chipNeutralBevel`, `.chipUpBevel`, `.chipDownBevel`, `.cardShadow`, `.coinGoldStops` ([Color]), `.lastMarkerFill`, `.lastMarkerInk`, `.lastMarkerBevel`

- [ ] **Step 1: Fix `SurfaceCard` to an opaque card color**

It is currently `black @ 0.18 / 0.26` — the muddy overlay. Replace `SurfaceCard.colorset/Contents.json` with opaque card surfaces (day `#FFFBF3`, night `#2E1E1A`):
```json
{
  "colors": [
    { "color": { "color-space": "srgb", "components": { "alpha": "1.000", "red": "0xFF", "green": "0xFB", "blue": "0xF3" } }, "idiom": "universal" },
    { "appearances": [ { "appearance": "luminosity", "value": "dark" } ], "color": { "color-space": "srgb", "components": { "alpha": "1.000", "red": "0x2E", "green": "0x1E", "blue": "0x1A" } }, "idiom": "universal" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

- [ ] **Step 2: Fix `Hairline` to a subtle adaptive divider**

Currently light cream for both modes (near-invisible on day). Replace `Hairline.colorset/Contents.json` with faint dark on day, faint light on night:
```json
{
  "colors": [
    { "color": { "color-space": "srgb", "components": { "alpha": "0.060", "red": "0x00", "green": "0x00", "blue": "0x00" } }, "idiom": "universal" },
    { "appearances": [ { "appearance": "luminosity", "value": "dark" } ], "color": { "color-space": "srgb", "components": { "alpha": "0.090", "red": "0xFF", "green": "0xFF", "blue": "0xFF" } }, "idiom": "universal" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

- [ ] **Step 3: Create the 11 new colorsets**

For each, create `andiem-ios/Phorm/Resources/Assets.xcassets/<Name>.colorset/Contents.json` with the day (`universal`) + dark components below. Use this template, substituting the hex bytes:
```json
{
  "colors": [
    { "color": { "color-space": "srgb", "components": { "alpha": "1.000", "red": "0xRR", "green": "0xGG", "blue": "0xBB" } }, "idiom": "universal" },
    { "appearances": [ { "appearance": "luminosity", "value": "dark" } ], "color": { "color-space": "srgb", "components": { "alpha": "1.000", "red": "0xRR", "green": "0xGG", "blue": "0xBB" } }, "idiom": "universal" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

| Name | Day (RR GG BB) | Night (RR GG BB) |
|---|---|---|
| `KeyFaceTop` | FF FB F3 | 35 25 20 |
| `KeyFaceBottom` | ED E0 CC | 29 18 10 |
| `KeyRidge` | BC AD 95 | 11 08 06 |
| `KeySignFaceTop` | FF F0 E0 | 3D 24 18 |
| `KeySignFaceBottom` | F0 D8 B8 | 2C 15 08 |
| `KeySignRidge` | BF 90 60 | 14 07 00 |
| `KeySignInk` | C1 30 20 | F2 B8 29 |
| `CoinSeat` | ED E1 CE | 35 24 20 |
| `CoinSeatBevel` | C0 AC 90 | 1C 10 09 |
| `ChipNeutralBevel` | BE B0 9A | 21 15 10 |
| `CardShadow` | 00 00 00 (alpha `0.070`) | 00 00 00 (alpha `0.380`) |

Note: `CardShadow` uses `alpha 0.070` (day) / `0.380` (night) instead of `1.000`.

- [ ] **Step 4: Add token constants in `Color+Tokens.swift`**

Update the file header comment (replace the "Hà Nội cũ / trading-terminal" wording with: `/// Tactile/playful warm palette — see DESIGN.md (tc-) and themes-preview.html.`). Then add, inside the `extension Color`, a new MARK section:
```swift
    // MARK: - Tactile depth (bevels, ridges, key faces — Task 1 foundation)
    /// Opaque card surface — tactile cards, summary rows, recent-strip container.
    static let cardSurface       = Color("SurfaceCard")
    /// Keypad digit/delete key face gradient stops + ridge.
    static let keyFaceTop        = Color("KeyFaceTop")
    static let keyFaceBottom     = Color("KeyFaceBottom")
    static let keyRidge          = Color("KeyRidge")
    /// Keypad sign key face + ridge + glyph ink.
    static let keySignFaceTop    = Color("KeySignFaceTop")
    static let keySignFaceBottom = Color("KeySignFaceBottom")
    static let keySignRidge      = Color("KeySignRidge")
    static let keySignInk        = Color("KeySignInk")
    /// Neutral coin face + bottom bevel.
    static let coinSeat          = Color("CoinSeat")
    static let coinSeatBevel     = Color("CoinSeatBevel")
    /// Neutral chip bottom bevel.
    static let chipNeutralBevel  = Color("ChipNeutralBevel")
    /// Soft drop-shadow ink for tactile cards (adaptive alpha).
    static let cardShadow        = Color("CardShadow")
    /// Fixed chip bottom-bevel inks (same across appearances — chip fills are fixed too).
    static let chipUpBevel       = Color(red: 0x0F/255, green: 0x8A/255, blue: 0x48/255) // #0F8A48
    static let chipDownBevel     = Color(red: 0xCC/255, green: 0x45/255, blue: 0x1C/255) // #CC451C
    /// Gold coin radial/linear gradient stops (135°): FFD761 → F2B829 → C8920D.
    static let coinGoldStops: [Color] = [
        Color(red: 0xFF/255, green: 0xD7/255, blue: 0x61/255),
        Color(red: 0xF2/255, green: 0xB8/255, blue: 0x29/255),
        Color(red: 0xC8/255, green: 0x92/255, blue: 0x0D/255)
    ]
    /// Last-place (Bét) coin marker — fixed across appearances.
    static let lastMarkerFill    = Color(red: 0xF5/255, green: 0xE6/255, blue: 0xE0/255) // #F5E6E0
    static let lastMarkerInk     = Color(red: 0xC0/255, green: 0x40/255, blue: 0x18/255) // #C04018
    static let lastMarkerBevel   = Color(red: 0xD9/255, green: 0xBF/255, blue: 0xBA/255) // #D9BFBA
```

- [ ] **Step 5: Build**

Run the build command (no new `.swift` files, so no `xcodegen` needed; the asset compiler picks up new colorsets).
Expected: `** BUILD SUCCEEDED **`. (Nothing renders differently yet — `SurfaceCard` is unused until Task 3.)

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/Phorm/Resources/Assets.xcassets andiem-ios/Phorm/DesignSystem/Color+Tokens.swift
git commit -m "theme: fix SurfaceCard/Hairline assets + add tactile depth tokens"
```

---

## Task 2: Rename Lacquer* → Tactile*, restyle buttons

**Files:**
- Rename: `andiem-ios/Phorm/DesignSystem/LacquerSurface.swift` → `AppBackground.swift`
- Rename: `andiem-ios/Phorm/DesignSystem/LacquerControls.swift` → `TactileControls.swift`
- Modify: every file referencing a `Lacquer*` symbol (see grep in Step 4)

**Interfaces:**
- Produces: `AppBackground` (struct), `View.appBackground(_:)`, `TactilePrimaryButton`, `TactileOutlineButton`, `Hairline`→ **renamed `RuleHairline` to avoid clashing with the new `Hairline` view added in Task 3** (see note), `GoldRule` (replaces `LacquerThickRule`). `SectionLabel`, `ScoreFormat` keep their names.

> Note: To prevent a name clash with the richer `Hairline` view introduced in Task 3, rename `LacquerHairline` → `RuleHairline` here. Task 3 does not add a separate hairline view after all — callers use `RuleHairline`. (This supersedes the spec's "`Hairline`" naming.)

- [ ] **Step 1: Rename the two files**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/andiem-ios/Phorm/DesignSystem
git mv LacquerSurface.swift AppBackground.swift
git mv LacquerControls.swift TactileControls.swift
```

- [ ] **Step 2: Update `AppBackground.swift` internals**

In the renamed file, rename `struct LacquerBackground` → `struct AppBackground`, the extension method `func lacquerBackground(...)` → `func appBackground(...)`, and update the doc comments to drop "lacquer". Keep the night-grain behavior unchanged. The default surface param stays `.phormSurfaceCinnabar` (a SurfaceRoot alias — still valid).

- [ ] **Step 3: Restyle buttons + rules in `TactileControls.swift`**

Replace `LacquerPrimaryButton` with a tactile version (radius 13, bottom bevel via inset, press translateY). Full replacement for the primary button:
```swift
/// Tết-red (day) / gold (night) filled CTA — radius 13, bottom bevel, depresses on press.
/// Matches `.tc-btn` in themes-preview.html.
struct TactilePrimaryButton: View {
    let title: String
    var enabled: Bool = true
    var action: () -> Void
    @GestureState private var pressed = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .continuous)
        Text(title)
            .font(.phormButton)
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundStyle(Color.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(shape.fill(enabled ? Color.phormPrimary : Color.phormPrimaryDisabled))
            .overlay(shape.fill(Color.black.opacity(0.18)).mask(alignment: .bottom) { Rectangle().frame(height: 3) })
            .offset(y: pressed ? 2 : 0)
            .contentShape(shape)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($pressed) { _, s, _ in if !s { s = true; Haptics.tap() } }
                    .onEnded { _ in if enabled { action() } }
            )
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: pressed)
            .disabled(!enabled)
    }
}
```
> The `black.opacity(0.18)` here is a *bottom-bevel mask on a saturated red/gold fill* (3pt strip), not a card surface — it is the intended tactile bevel and is exempt from the no-black-overlay rule.

Replace `LacquerOutlineButton` → `TactileOutlineButton`: identical body but `cornerRadius: 13` (was 3).

Replace `LacquerHairline` → `RuleHairline`, switching the fill from `Color.phormCream.opacity(0.18)` to `Color.hairline`:
```swift
/// 1px adaptive divider — subtle dark on day, subtle light on night.
struct RuleHairline: View {
    var body: some View { Rectangle().fill(Color.hairline).frame(height: 1) }
}
```

Replace `LacquerThickRule` → `GoldRule` (the summary divider from the mockup — a centered gold gradient rule):
```swift
/// 2px gold gradient rule (fades at both ends) — summary header divider.
struct GoldRule: View {
    var body: some View {
        LinearGradient(colors: [.clear, .phormGoldBright, .clear], startPoint: .leading, endPoint: .trailing)
            .frame(height: 2)
            .opacity(0.6)
    }
}
```

- [ ] **Step 4: Find and rewrite all call sites**

Run:
```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/andiem-ios
grep -rln "Lacquer\|lacquerBackground" Phorm/
```
For each file, apply these symbol renames (mechanical):
`LacquerPrimaryButton`→`TactilePrimaryButton`, `LacquerOutlineButton`→`TactileOutlineButton`, `LacquerHairline`→`RuleHairline`, `LacquerThickRule`→`GoldRule`, `LacquerBackground`→`AppBackground`, `.lacquerBackground(`→`.appBackground(`. Also update any code comment containing "lacquer"/"cinnabar lacquer" to "tactile surface".

- [ ] **Step 5: Regenerate + build**

```bash
xcodegen generate
```
Then run the build command.
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 6: Verify no stragglers**

Run:
```bash
grep -rn "Lacquer\|lacquerBackground" Phorm/ ; echo "exit=$?"
```
Expected: no matches (grep `exit=1`).

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "theme: rename Lacquer* → Tactile*/AppBackground, restyle CTA buttons (radius 13, press bevel)"
```

---

## Task 3: `tactileCard()` modifier + RoundBadge + StatusPill

**Files:**
- Create: `andiem-ios/Phorm/DesignSystem/TactileSurfaces.swift`

**Interfaces:**
- Produces: `View.tactileCard(radius:elevated:)` modifier; `RoundBadge(count:)` view; `StatusPill(text:style:)` view with `StatusPill.Style { ok, warn, neutral }`.

- [ ] **Step 1: Write `TactileSurfaces.swift`**

```swift
import SwiftUI

extension View {
    /// Opaque tactile card: surfaceCard fill, soft drop shadow, 1px hairline ring, rounded corners.
    /// Replaces every `Color.black.opacity(...)` card background. `elevated` deepens the shadow
    /// (used for the active/focused leaderboard row).
    func tactileCard(radius: CGFloat = 14, elevated: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return self
            .background(shape.fill(Color.cardSurface))
            .background(shape.fill(Color.cardSurface).shadow(color: .cardShadow, radius: elevated ? 16 : 10, y: elevated ? 4 : 2))
            .overlay(shape.strokeBorder(Color.hairline, lineWidth: 1))
            .clipShape(shape)
    }
}

/// Header round-count badge — Tết-red (day) / gold (night) raised box. `.tc` header chip.
struct RoundBadge: View {
    let count: Int
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        VStack(spacing: 1) {
            Text("Vòng")
                .font(.phormCaptionSection)
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.onPrimary.opacity(0.85))
            Text(String(format: "%02d", count))
                .font(.system(size: 18, weight: .heavy, design: .default).monospacedDigit())
                .foregroundStyle(Color.onPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(shape.fill(Color.phormPrimary))
        .overlay(shape.fill(Color.black.opacity(0.20)).mask(alignment: .bottom) { Rectangle().frame(height: 2) })
        .shadow(color: Color.phormPrimary.opacity(0.35), radius: 6, y: 2)
    }
}

/// Capsule status pill — round-entry "Tổng" balance indicator. ok/warn/neutral.
struct StatusPill: View {
    enum Style { case ok, warn, neutral }
    let text: String
    var style: Style = .neutral

    private var fg: Color {
        switch style { case .ok: return .scorePositive; case .warn: return .scoreNegative; case .neutral: return .phormCreamDim }
    }
    private var bg: Color {
        switch style {
        case .ok: return Color.scorePositive.opacity(0.14)
        case .warn: return Color.scoreNegative.opacity(0.14)
        case .neutral: return Color.chipNeutral
        }
    }
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .default).monospacedDigit())
            .foregroundStyle(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule(style: .continuous).fill(bg))
            .overlay(Capsule(style: .continuous).strokeBorder(fg.opacity(0.28), lineWidth: 1))
    }
}
```

- [ ] **Step 2: Regenerate + build**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/andiem-ios && xcodegen generate
```
Then build. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "theme: add tactileCard modifier + RoundBadge + StatusPill primitives"
```

---

## Task 4: ScoreChip — exact tc-chip treatment

**Files:**
- Modify: `andiem-ios/Phorm/Views/Components/ScoreChip.swift`

**Interfaces:**
- Consumes: `.chipUpBevel`, `.chipDownBevel`, `.chipNeutralBevel`, `.chipNeutral`, `.scorePositive`, `.scoreNegative` (Task 1).
- Produces: unchanged public API `ScoreChip(value:size:isFocused:)`.

- [ ] **Step 1: Replace the chip body**

Update `dims` radii to `(82,50,30,16)` large / `(58,36,20,11)` small (small radius 14→11). Replace the `.background`/`.overlay` chain so the bevel color matches the fill semantics and the focus ring uses the surface-gap + accent style:
```swift
    private var bevel: Color {
        switch value ?? 0 {
        case let v where v > 0: return .chipUpBevel
        case let v where v < 0: return .chipDownBevel
        default:                return .chipNeutralBevel
        }
    }
    private var glow: Color {
        switch value ?? 0 {
        case let v where v > 0: return Color.scorePositive.opacity(0.30)
        case let v where v < 0: return Color.scoreNegative.opacity(0.30)
        default:                return .clear
        }
    }
```
Then the body's background/overlay:
```swift
            .background(
                RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                    .fill(fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                            .fill(bevel)
                            .mask(alignment: .bottom) { Rectangle().frame(height: 3) }
                    )
                    .shadow(color: glow, radius: 14, y: 4)
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: dims.radius + 2.5, style: .continuous)
                    .strokeBorder(Color.phormSurfaceCinnabar, lineWidth: isFocused ? 2.5 : 0)
                    .padding(-2.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: dims.radius + 5, style: .continuous)
                    .strokeBorder(Color.phormPrimary, lineWidth: isFocused ? 2.5 : 0)
                    .padding(-5)
            )
```
Keep neutral text color as `Color.phormMuted` (resolves to ink-secondary; matches the `#8B7969`-family). Update the `#Preview` background to `Color.phormSurfaceCinnabar` (already is).

> The two `black.opacity` uses here are the chip's own bottom-bevel mask + soft drop shadow — intended depth, exempt.

- [ ] **Step 2: Build**

Build. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add andiem-ios/Phorm/Views/Components/ScoreChip.swift
git commit -m "theme: ScoreChip — bevel + colored glow + surface-gap focus ring (tc-chip)"
```

---

## Task 5: Coin — tc-coin treatment + active variant

**Files:**
- Modify: `andiem-ios/Phorm/Views/Components/Coin.swift`

**Interfaces:**
- Consumes: `.coinSeat`, `.coinSeatBevel`, `.coinGoldStops`, `.lastMarkerFill/Ink/Bevel`.
- Produces: `Coin(text:variant:size:)` with `Variant { seat, winner, last, active }` (adds `.active`).

- [ ] **Step 1: Rewrite Coin**

```swift
import SwiftUI

/// Round seat / winner token — the tactile "coin". Matches `tc-coin*`.
struct Coin: View {
    enum Variant { case seat, winner, last, active }

    let text: String
    var variant: Variant = .seat
    var size: CGFloat = 32

    private var fill: AnyShapeStyle {
        switch variant {
        case .seat, .active: return AnyShapeStyle(Color.coinSeat)
        case .winner: return AnyShapeStyle(LinearGradient(colors: Color.coinGoldStops, startPoint: .topLeading, endPoint: .bottomTrailing))
        case .last:   return AnyShapeStyle(Color.lastMarkerFill)
        }
    }
    private var textColor: Color {
        switch variant {
        case .seat, .active: return .phormCreamDim
        case .winner: return Color(red: 0x4A/255, green: 0x28/255, blue: 0x00/255) // #4A2800
        case .last:   return .lastMarkerInk
        }
    }
    private var bevel: Color {
        switch variant {
        case .seat, .active: return .coinSeatBevel
        case .winner: return Color(red: 0xC8/255, green: 0x92/255, blue: 0x0D/255)
        case .last:   return .lastMarkerBevel
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.44, weight: .bold, design: .default).monospacedDigit())
            .foregroundStyle(textColor)
            .frame(width: size, height: size)
            .background(
                Circle().fill(fill)
                    .overlay(Circle().fill(bevel).mask(alignment: .bottom) { Rectangle().frame(height: 2) }.clipShape(Circle()))
            )
            .overlay(Circle().strokeBorder(variant == .active ? Color.phormPrimary : .clear, lineWidth: 2))
            .shadow(color: .black.opacity(0.10), radius: 2, y: 1)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 14) {
        Coin(text: "1", variant: .winner, size: 40)
        Coin(text: "2")
        Coin(text: "3", variant: .active)
        Coin(text: "×", variant: .last)
    }.padding().background(Color.phormSurfaceCinnabar)
}
```

- [ ] **Step 2: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add andiem-ios/Phorm/Views/Components/Coin.swift
git commit -m "theme: Coin — tc-coin seat/winner/last + active focus variant"
```

---

## Task 6: Keypad — warm gradient keys + sign/Tiếp restyle

**Files:**
- Modify: `andiem-ios/Phorm/Views/Components/Keypad.swift`

**Interfaces:**
- Consumes: `.keyFaceTop/Bottom`, `.keyRidge`, `.keySignFaceTop/Bottom`, `.keySignRidge`, `.keySignInk`.
- Produces: unchanged `Keypad(onKey:onSave:canSave:sign:)`.

- [ ] **Step 1: Give `TactileKey` a gradient face + warm ridge**

Change `TactileKey` to take a `face: LinearGradient` and `ridge: Color` instead of a flat `fill`. Update its body:
```swift
private struct TactileKey<Label: View>: View {
    var face: LinearGradient
    var ridge: Color
    var haptic: () -> Void = { Haptics.tap() }
    var a11yLabel: String = ""
    let action: () -> Void
    @ViewBuilder var label: () -> Label
    @GestureState private var pressed = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        label()
            .background(shape.fill(face))
            .background(shape.fill(ridge).offset(y: pressed ? 1 : 4))
            .offset(y: pressed ? 3 : 0)
            .contentShape(shape)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($pressed) { _, s, _ in if !s { s = true; haptic() } }
                    .onEnded { _ in action() }
            )
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: pressed)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(a11yLabel)
    }
}
```

- [ ] **Step 2: Wire the key faces**

Add helpers on `Keypad` and update the two `TactileKey(...)` call sites (digit/del grid + Save CTA). Digit/delete keys use the neutral face; the sign key uses the sign face; the Save CTA uses a solid red→deeper-red gradient face with `.keyRidge`-equivalent (use `Color.phormPrimaryActive`):
```swift
    private var keyFace: LinearGradient {
        LinearGradient(colors: [.keyFaceTop, .keyFaceBottom], startPoint: .top, endPoint: .bottom)
    }
    private var signFace: LinearGradient {
        LinearGradient(colors: [.keySignFaceTop, .keySignFaceBottom], startPoint: .top, endPoint: .bottom)
    }
    private func face(_ kind: KeyKind) -> LinearGradient {
        if case .sign = kind { return signFace }
        return keyFace
    }
    private func ridge(_ kind: KeyKind) -> Color {
        if case .sign = kind { return .keySignRidge }
        return .keyRidge
    }
```
In `key(_:)` pass `face: face(kind), ridge: ridge(kind)`. For the Save CTA `TactileKey`, pass:
```swift
                    face: LinearGradient(colors: canSave ? [Color.phormPrimary, Color.phormPrimaryActive] : [Color.phormPrimaryDisabled, Color.phormPrimaryDisabled], startPoint: .top, endPoint: .bottom),
                    ridge: Color.black.opacity(0.30),
```

- [ ] **Step 3: Restyle the digit/sign/delete glyph colors**

In `keyLabel(for:)`: digit text → `Color.bodyText` (ink, legible on the light key face) instead of `Color.phormCream`; sign glyphs keep mode colors but the inactive glyph uses `Color.keySignInk.opacity(0.30)` (was `phormCream.opacity(0.22)`); delete glyph → `Color.mutedStrong`. Replace the "Tiếp" secondary button (currently sharp radius + cream-opacity stroke) with a tactile neutral key:
```swift
                TactileKey(
                    face: keyFace, ridge: .keyRidge,
                    haptic: { Haptics.nav() }, a11yLabel: "Người tiếp theo",
                    action: { onKey(.next) }
                ) {
                    Text("Tiếp").font(.phormButton).tracking(1.5).textCase(.uppercase)
                        .foregroundStyle(Color.bodyText)
                        .frame(width: 90, height: 52)
                }
```
Update the doc comments to drop "on lacquer".

- [ ] **Step 4: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**

```bash
git add andiem-ios/Phorm/Views/Components/Keypad.swift
git commit -m "theme: Keypad — warm gradient key faces, tactile sign/Tiếp keys"
```

---

## Task 7: RoundCard + HistoryRow → tactileCard

**Files:**
- Modify: `andiem-ios/Phorm/Views/Components/RoundCard.swift`
- Modify: `andiem-ios/Phorm/Views/Components/HistoryRow.swift`

**Interfaces:**
- Consumes: `.tactileCard()` (Task 3).

- [ ] **Step 1: RoundCard**

Remove the `Rectangle().fill(Color.phormPrimary).frame(width: 3)` left edge **or** keep a rounded accent — replace it with a 3pt rounded gold/red accent bar inside the card. Replace the outer `.background(Color.black.opacity(0.18))` + `.overlay(stroke phormCream.opacity)` + `.clipShape` chain with `.tactileCard(radius: 14)`. Change the inner player name color from `Color.phormCream.opacity(0.86)` to `Color.bodyText`. Keep "Vòng N" gold label + timestamp. Resulting structure:
```swift
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.phormPrimary).frame(width: 3)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // ... unchanged header (Vòng N + timestamp) ...
                VStack(spacing: 6) {
                    ForEach(playerOrder, id: \.self) { name in
                        let value = scoreByName[name] ?? 0
                        HStack {
                            Text(name).font(.phormNameMd).foregroundStyle(Color.bodyText)
                            Spacer()
                            Text(ScoreFormat.signed(value)).font(.phormNumberMd)
                                .foregroundStyle(ScoreFormat.color(for: value))
                        }
                    }
                }
            }
            .padding(.vertical, Spacing.sm)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .tactileCard(radius: 14)
    }
```

- [ ] **Step 2: HistoryRow**

Apply the same swap: replace the `black.opacity(0.18)` background + `phormCream.opacity(0.18)` stroke + sharp radius with `.tactileCard(radius: 14)`. Change any `phormCream.opacity` text to `bodyText`/`phormCreamDim`. Update the "on lacquer" doc comment.

- [ ] **Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**

```bash
git add andiem-ios/Phorm/Views/Components/RoundCard.swift andiem-ios/Phorm/Views/Components/HistoryRow.swift
git commit -m "theme: RoundCard + HistoryRow → tactileCard"
```

---

## Task 8: SessionView (leaderboard, the reference screen)

**Files:**
- Modify: `andiem-ios/Phorm/Views/SessionView.swift`

- [ ] **Step 1: Header round count → RoundBadge**

In `headerStrip`, replace the trailing `VStack(SectionLabel("Vòng") + Text("%02d"))` with `RoundBadge(count: (session.rounds ?? []).count)`.

- [ ] **Step 2: Leader row as elevated card**

In `leaderboardRow`, wrap the rank-1 row's `HStack` content with padding + `.tactileCard(radius: 16, elevated: true)`, and use `Coin(... variant: .active ...)` is not needed — keep rank coins. Apply card only to `rank == 1`; runners stay as plain rows. Add the card via a conditional modifier:
```swift
        .padding(rank == 1 ? Spacing.sm : 0)
        .modifier(ConditionalCard(active: rank == 1))
```
Add a small helper at file scope:
```swift
private struct ConditionalCard: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View { active ? AnyView(content.tactileCard(radius: 16, elevated: true)) : AnyView(content) }
}
```
Change leaderboard row name/text colors from `phormCream` to `bodyText` so they read on both the cream root and the card.

- [ ] **Step 3: Recent strip → chips on a card**

In `recentStrip`, replace each cell's `RoundedRectangle(cornerRadius: 3).fill(Color.black.opacity(0.18))` background with a `ScoreChip(value: value, size: .small)` (drop the manual `Text` + background; map the strip to chips). Wrap the `LazyVGrid` in `.padding(Spacing.sm).tactileCard(radius: 14)`.

- [ ] **Step 4: CTA fade to surface**

In `cta`, change the gradient colors from `.phormSurfaceCinnabarDeep.opacity(...)` to the root surface: `[.clear, Color.canvas.opacity(0.0), Color.canvas]` — i.e.
```swift
            LinearGradient(colors: [Color.canvas.opacity(0), Color.canvas.opacity(0.85), Color.canvas], startPoint: .top, endPoint: .bottom)
```
Replace `LacquerHairline()` (now `RuleHairline()`) usage if present — already handled in Task 2.

- [ ] **Step 5: Regenerate (new file-scope type added) + build**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/andiem-ios && xcodegen generate
```
Build. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/Phorm/Views/SessionView.swift
git commit -m "theme: SessionView — RoundBadge, leader card, chip recent strip, surface CTA fade"
```

---

## Task 9: RoundEntryView

**Files:**
- Modify: `andiem-ios/Phorm/Views/RoundEntryView.swift`

- [ ] **Step 1: Close button + focused-row card + validation pill**

- Header close button: replace `.background(Circle().fill(Color.black.opacity(0.18)))` with `.background(Circle().fill(Color.surfaceTile)).overlay(Circle().strokeBorder(Color.hairline, lineWidth: 1))`.
- Title subtitle: change `Color.phormCream.opacity(0.82)` → `Color.phormCreamDim`.
- Focused player row: replace the inline `RoundedRectangle(cornerRadius: 12).fill(Color.surfaceTile).shadow(black .28)` background (lines ~221-226) with the shared card: `.background(isFocused ? AnyView(Color.clear.tactileCard(radius: 14, elevated: true)) : AnyView(Color.clear))`. Keep the `Coin(... variant: (isFocused||isAuto) ? .winner : .seat ...)` — change focused to `.active` for the seat: `coinVariant = isFocused ? .active : (isAuto ? .winner : .seat)`.
- `validationRow`: replace the manual `Text(...).background(Capsule().fill(... .opacity(0.14)))` with `StatusPill(text: ok ? "Tổng: 0 · cân ✓" : "Tổng: \(ScoreFormat.signed(sum)) ⚠", style: ok ? .ok : .warn)`.

- [ ] **Step 2: Bottom dock + background tokens**

- `bottomDock`: change the top hairline `Color.phormCreamStroke` → `Color.hairline`; background `Color.phormSurfaceCinnabar` stays (it's SurfaceRoot — correct).
- `.lacquerBackground(.phormSurfaceCinnabar)` already became `.appBackground(.phormSurfaceCinnabar)` in Task 2 — leave.

- [ ] **Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**

```bash
git add andiem-ios/Phorm/Views/RoundEntryView.swift
git commit -m "theme: RoundEntryView — tactile close/focus card, StatusPill, hairline dock"
```

---

## Task 10: SummaryView

**Files:**
- Modify: `andiem-ios/Phorm/Views/SummaryView.swift`

- [ ] **Step 1: Champion + runners as cards**

- `championBlock`: wrap the row in `.padding(Spacing.md)` + a gold-ringed card:
```swift
        .padding(Spacing.md)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.cardSurface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.phormGoldBright, lineWidth: 2))
        .shadow(color: Color.phormGoldBright.opacity(0.22), radius: 20, y: 4)
```
- `runnersBlock`: wrap each runner `HStack` in `.padding(.horizontal, Spacing.md).padding(.vertical, Spacing.sm).tactileCard(radius: 12)`. Change `phormCream` name text → `bodyText`.
- `lastPlaceBlock`: change the top-edge `Rectangle().fill(Color.phormCream.opacity(0.18))` → `Color.hairline`; change last coin to `Coin(text: "×", variant: .last, size: 28)`.

- [ ] **Step 2: Callouts + CTA**

- `unstampedCallout` + `stampedCallout`: change `cornerRadius: 3` → `13` on all `RoundedRectangle`s and `.contentShape`; keep the dashed/solid `phormPrimary` strokes; change body text `phormCream.opacity(...)` → `phormCreamDim`/`bodyText`.
- The thick rule `LacquerThickRule()` is now `GoldRule()` (Task 2) — leave.
- `cta` gradient: change `.phormSurfaceCinnabar.opacity(...)` fade to `[Color.canvas.opacity(0), Color.canvas.opacity(0.85), Color.canvas]`.
- Header `phormCream` title stays (text on root) but verify it's `bodyText` family for day legibility — change `Color.phormCream` → `Color.bodyText` for `session.name`.

- [ ] **Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**

```bash
git add andiem-ios/Phorm/Views/SummaryView.swift
git commit -m "theme: SummaryView — winner/runner cards, GoldRule, rounded callouts, surface CTA fade"
```

---

## Task 11: NewSessionView

**Files:**
- Modify: `andiem-ios/Phorm/Views/NewSessionView.swift`

- [ ] **Step 1: Replace all card/field fills + strokes**

Apply consistently across the file (grep shows occurrences at ~100, 124, 128, 157, 165, 167-170, 168, 219-222, 251, 255, 334, 339-342, 361):
- `Color.black.opacity(0.18)` card/field backgrounds → `.tactileCard(radius: 14)` (for card containers) or `Color.surfaceTile` fill + `Color.hairline` stroke (for input fields/chips).
- `Color.phormCream.opacity(0.30)` field strokes → `nameInputFocused ? Color.phormPrimary : Color.hairline`.
- `Color.phormCream.opacity(0.18)`/`0.12` → `Color.hairline` / `Color.surfaceTile`.
- All `cornerRadius: 3`/`4` on fields/chips → `12` (`10` for small pills).
- The bottom CTA gradient `.phormSurfaceCinnabarDeep.opacity(...)` → `[Color.canvas.opacity(0), Color.canvas.opacity(0.85), Color.canvas]`.
- `RRR` player name / add-row text using `phormCream` → `bodyText`.

> Read the file first; apply each occurrence with the matching replacement above. The primary button is already `TactilePrimaryButton` from Task 2.

- [ ] **Step 2: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add andiem-ios/Phorm/Views/NewSessionView.swift
git commit -m "theme: NewSessionView — tactile cards/fields, surface CTA fade"
```

---

## Task 12: HistoryView, EmptyHomeView, ImportConfirmView, SplashView, Seal

**Files:**
- Modify: `HistoryView.swift`, `EmptyHomeView.swift`, `ImportConfirmView.swift`, `SplashView.swift`, `Components/Seal.swift`

- [ ] **Step 1: HistoryView**

`RuleHairline()` already swapped (Task 2). Change `Color.phormCream.opacity(0.5)` (empty/secondary text, line ~104) → `Color.phormCreamDim`. Row styling lives in HistoryRow (Task 7).

- [ ] **Step 2: EmptyHomeView**

`Color.phormCream.opacity(0.65)` (line ~33) → `Color.phormCreamDim`. Buttons already `Tactile*`. Background already `appBackground` (Task 2).

- [ ] **Step 3: ImportConfirmView**

Card at line ~65: `Color.black.opacity(0.20)` background + `phormCream.opacity(0.18)` stroke + `cornerRadius: 4` → `.tactileCard(radius: 14)`. `phormCream.opacity(0.6)` text (line ~20) → `phormCreamDim`. The `cornerRadius: 3` chip at ~82 → `12`.

- [ ] **Step 4: SplashView + Seal**

- SplashView: update the "cinnabar lacquer" doc comment (line ~3) to "tactile gold seal + wordmark". `LacquerBackground()` already `AppBackground()` (Task 2). Verify the gold seal still uses `Coin`/gold tokens; if it uses `Seal`, leave visuals but ensure no `black.opacity` card fill.
- Seal.swift: this is largely superseded by `Coin`. Update its `cornerRadius: 4` → `12` and any `phormCreamStroke` → `Color.hairline`; update the "on lacquer" comment. Do not delete (still referenced by SplashView/previews).

- [ ] **Step 5: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/Phorm/Views/HistoryView.swift andiem-ios/Phorm/Views/EmptyHomeView.swift andiem-ios/Phorm/Views/ImportConfirmView.swift andiem-ios/Phorm/Views/SplashView.swift andiem-ios/Phorm/Views/Components/Seal.swift
git commit -m "theme: History/Empty/Import/Splash/Seal — tactile cards + token cleanup"
```

---

## Task 13: Stamp flow

**Files:**
- Modify: `Stamp/StampSourcePicker.swift`, `Stamp/StampEditorView.swift`, `Stamp/StampOnPhotoView.swift`, `Stamp/ShareCardView.swift`

- [ ] **Step 1: StampSourcePicker (bottom sheet chrome)**

Option rows/cards (lines ~104, 108, 111, 134, 135, 138, 139, 141): `Color.black.opacity(0.18)` fills → `.tactileCard(radius: 14)` or `Color.surfaceTile`; `phormCream.opacity(0.34)` strokes → `Color.hairline`; `cornerRadius: 3` → `12`. Update the "Lacquer-styled bottom sheet" comment to "tactile bottom sheet".

- [ ] **Step 2: StampEditorView (editor chrome only)**

Editor chrome: circle button bg `Color.black.opacity(0.28)` (line ~173) → `Color.surfaceTile` + hairline; card `black.opacity(0.18)` (~244) → `.tactileCard`; strokes `phormCream.opacity(...)` (~248) → `Color.hairline`/accent; `cornerRadius: 3/4` on chrome → `12`. **Leave** `LacquerBackground(surface: .phormSurfaceOxblood)` and `presentationBackground(.phormSurfaceCinnabarDeep)` — the editor sits on the dark composed-artifact ground intentionally (these became `AppBackground(...)` in Task 2). The `TactilePrimaryButton` is already updated.

- [ ] **Step 3: StampOnPhotoView (photo composite — minimal)**

This renders the seal/cross **over the user's photo**. Its `black.opacity(0.4/0.5)` drop shadows and `phormCream.opacity(0.92)` fills are intentional high-contrast-on-arbitrary-photo treatments — **leave them**. Only confirm no app-surface card uses a muddy overlay here (there are none). No change expected; document with a one-line comment `// Photo-composite shadows are intentional (sit over arbitrary photos) — exempt from the no-black-overlay rule.`

- [ ] **Step 4: ShareCardView (dark artifact — chip/coin consistency only)**

This is the composed 9:16 dark share image; the **oxblood ground stays**. Only ensure the chips/coins drawn on it use the updated `ScoreChip`/`Coin` components (they will automatically via Tasks 4-5 if it uses those components; if it hand-rolls chip/coin shapes, update those hand-rolled shapes' radii to match 11/14 and bevel direction). Do **not** convert the ground, gradients, or the `black.opacity` ambient/drop shadows (lines ~174, 316, 338, 342, 386, 512, 515) — those are deliberate artifact depth. Update only the doc comment "lacquer share artifact" → "dark share artifact".

- [ ] **Step 5: Regenerate (if any new file-scope helpers) + build**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/andiem-ios && xcodegen generate && \
xcodebuild -project andiem-ios.xcodeproj -scheme Phorm -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO build
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/Phorm/Views/Stamp/
git commit -m "theme: Stamp flow — tactile editor/sheet chrome; keep dark share artifact + photo shadows"
```

---

## Task 14: Final sweep + tests

**Files:** none (verification only)

- [ ] **Step 1: Assert anti-patterns are gone from app surfaces**

Run (from `andiem-ios/`):
```bash
echo "--- black-overlay card fills (should be ONLY chip/coin/key bevels, button bevels, RoundBadge, and Stamp photo/artifact) ---"
grep -rn "black.opacity" Phorm/Views/ | grep -v "Stamp/" | grep -v "ScoreChip\|Coin.swift\|Keypad\|TactileControls\|TactileSurfaces"
echo "--- phormCream.opacity strokes (should be none in non-Stamp views) ---"
grep -rn "phormCream.opacity\|phormCreamStroke" Phorm/Views/ | grep -v "Stamp/"
echo "--- Lacquer symbols (should be none) ---"
grep -rn "Lacquer\|lacquerBackground" Phorm/ ; echo "lacquer-exit=$?"
echo "--- cinnabarDeep CTA fades (should be none) ---"
grep -rn "phormSurfaceCinnabarDeep" Phorm/Views/ | grep -v "Stamp/"
```
Expected: the first two print nothing (or only intentional bevel lines you can justify), `lacquer-exit=1`, the fourth prints nothing.

- [ ] **Step 2: Run the test suite**

```bash
xcodebuild -project andiem-ios.xcodeproj -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO test
```
Expected: `** TEST SUCCEEDED **` (Totals, AutoFill, SessionShare, SessionActions, SealGlyph all pass — logic untouched).

- [ ] **Step 3: Commit any sweep fixes**

```bash
git add -A && git commit -m "theme: final tactile sweep — verified no lacquer-era surface literals remain" --allow-empty
```

---

## Self-Review (completed)

- **Spec coverage:** Foundation (Task 1) ✓; primitives — card/badge/pill (3), chip (4), coin (5), keypad (6), buttons+rename (2) ✓; per-screen — Session (8), RoundEntry (9), Summary (10), NewSession (11), History/Empty/Import/Splash/Seal (12), Stamp (13) ✓; ShareCardView/photo exceptions ✓; verification (14) ✓.
- **Asset bug caught beyond spec:** `SurfaceCard` and `Hairline` assets needed *fixing*, not just consuming — folded into Task 1.
- **Type consistency:** `tactileCard(radius:elevated:)`, `RoundBadge(count:)`, `StatusPill(text:style:)`, `Coin.Variant.active`, `TactilePrimaryButton`/`TactileOutlineButton`/`RuleHairline`/`GoldRule`/`AppBackground`/`appBackground()` used consistently across tasks. `RuleHairline` chosen over spec's `Hairline` to avoid a clash.
- **Placeholders:** none — each step has concrete JSON/Swift/commands.
