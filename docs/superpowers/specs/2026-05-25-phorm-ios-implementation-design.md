# Phorm iOS — Implementation Design

**Date:** 2026-05-25
**Owner:** quyctd
**Status:** Approved (brainstorming round 1)

## Context

This spec covers the **implementation architecture** for the native iOS app already specified in PLAN.md (product/UX), PRODUCT.md (brand/voice), and DESIGN.md (visual tokens). The three source docs are inputs, not subjects of revision:

- PLAN.md's 14 numbered UX decisions are locked.
- DESIGN.md's color, typography, material, radius, and spacing tokens are the source of truth for the design-system Swift layer.
- PRODUCT.md's brand voice, anti-references, and accessibility commitments shape implementation choices.

This document only covers what those three docs leave open: code architecture, repo/project setup, and testing scope. Performance budgets are intentionally not specified — we trust SwiftUI/SwiftData defaults and profile only if a problem surfaces.

## Decisions made during brainstorming

| # | Decision | Notes |
|---|---|---|
| 1 | **iOS code lives in `./andiem-ios/` subfolder** of this repo | Overrides PLAN.md tech-stack line ("repo mới, riêng"). PLAN.md will be amended to match. One git history for spec + code. |
| 2 | **CloudKit day 1** with `.automatic` SwiftData CloudKit database | Active Apple Developer account confirmed. iPhone↔iPad sync from v0. |
| 3 | **Architecture: direct `@Observable` + `@Query`** | No MVVM, no repository pattern. Pure functions for logic. |
| 4 | **Single mutation surface: `SessionActions`** enum | Views never call `modelContext.insert` directly. Keeps active-session invariant in one file. |
| 5 | **Testing: Swift Testing for pure logic only** | ~20 cases across AutoFill, Totals, SessionShare, SessionActions. No UI tests, no CI. |

## Repo & project setup

### Location & Xcode project

- New folder: `./andiem-ios/` (inside this `an-diem` repo).
- Xcode project: `andiem-ios.xcodeproj` with two targets:
  - **`Phorm`** — iOS app, deployment target **iOS 17.0**, SwiftUI app lifecycle.
  - **`PhormTests`** — Swift Testing framework (`import Testing`), pure-logic unit tests only.
- Bundle ID: `com.quyctd.phorm`
- Display name: **Phorm**
- App icon: solid `#fcd535` square with "P" placeholder for v0; proper icon post-MVP.

### Capabilities & entitlements (`Phorm.entitlements`)

- iCloud → CloudKit, container `iCloud.com.quyctd.phorm`
- Background Modes → Remote notifications (silent push for CloudKit)
- URL Types → scheme `phorm` (handles `phorm://import?s=<base64url>`)

### Folder layout (`andiem-ios/Phorm/`)

```
Phorm/
├── PhormApp.swift              @main; ModelContainer; .onOpenURL routing
├── Models/                     @Model SwiftData entities
│   ├── Session.swift
│   ├── Round.swift
│   └── PlayerScore.swift       child entity (see "Data model")
├── Logic/                      pure functions — testable
│   ├── AutoFill.swift          suggestion(for: [Int?]) -> Int?
│   ├── Totals.swift            cumulative & ranking
│   ├── SessionShare.swift      encode/decode Session ↔ phorm:// URL
│   └── SessionActions.swift    archiveActive, createSession, appendRound, …
├── State/
│   └── RoundDraft.swift        @Observable; sheet-local round-entry state
├── Views/
│   ├── HomeView.swift          routes based on active session
│   ├── SessionView.swift
│   ├── NewSessionView.swift
│   ├── RoundEntryView.swift
│   ├── SummaryView.swift
│   ├── HistoryView.swift
│   ├── ImportConfirmView.swift
│   └── Components/             Keypad, ScoreChip, RoundCard, RankingCard, …
├── DesignSystem/               DESIGN.md tokens → Swift
│   ├── Color+Tokens.swift
│   ├── Font+Tokens.swift
│   ├── Material+Tokens.swift
│   ├── Radius.swift
│   ├── Spacing.swift
│   └── View+Helpers.swift
└── Resources/
    ├── Assets.xcassets         color tokens (adaptive light/dark)
    └── Phorm.entitlements + Info.plist
```

### Repo hygiene

- Extend root `.gitignore` with Xcode artifacts: `xcuserdata/`, `*.xcuserstate`, `.swiftpm/`, `DerivedData/`, `.DS_Store`, `build/`.
- Amend PLAN.md tech-stack line ("**Repo**: mới, riêng …") to reflect subfolder decision.
- Update root README.md with a pointer to `./andiem-ios/`.
- No SwiftLint, no swift-format, no CI for MVP.
- Tests run via ⌘U in Xcode.

## Data model

CloudKit constrains SwiftData: every property needs a default or must be optional; no unique constraints; relationships must be optional; `[String: Int]` dictionaries can't go directly into a `@Model`. So we use a child entity (`PlayerScore`) instead of `Round.scores: [String: Int]` from the PLAN.md sketch.

```swift
@Model final class Session {
    var id: UUID = UUID()
    var name: String = ""                 // default = timestamp; user-editable
    var createdAt: Date = Date.now
    var archivedAt: Date?                 // nil = active; one active at a time
    var playerNames: [String] = []        // ordered, locked after create
    @Relationship(deleteRule: .cascade, inverse: \Round.session)
    var rounds: [Round]? = []
}

@Model final class Round {
    var id: UUID = UUID()
    var index: Int = 0                    // 1-based
    var createdAt: Date = Date.now
    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.round)
    var scores: [PlayerScore]? = []
    var session: Session?
}

@Model final class PlayerScore {
    var playerName: String = ""
    var value: Int = 0
    var round: Round?
}
```

**Why `PlayerScore` child entity** (vs JSON blob on `Round`):
- CloudKit-native: each score is a `CKRecord` field, queryable and indexable.
- Cleaner SwiftData previews / inspector.
- Enables future "totals per player across sessions" without decoding blobs.
- Trade-off: more allocations on Save (N `PlayerScore` per round). Negligible for realistic N ≤ 8.

**Active-session invariant** ("one active at a time") is enforced in `SessionActions` (business logic), not as a SwiftData constraint — CloudKit can't express it natively.

## Logic layer (pure functions, testable)

All four are `enum` namespaces — no instances, no state.

### `AutoFill`

```swift
enum AutoFill {
    /// Returns the auto-fill suggestion for the single empty slot iff exactly
    /// N-1 of N entries are filled. Otherwise nil (no suggestion shown).
    static func suggestion(for entries: [Int?]) -> Int? {
        let filled = entries.compactMap { $0 }
        guard entries.count - filled.count == 1 else { return nil }
        return -filled.reduce(0, +)
    }
}
```

Semantics per PLAN.md §7:
- Empty cell = 0 implicit when saving (sparse rounds like chặt-heo).
- Auto-fill activates **only** when N−1 cells are filled — never on fewer.
- Auto-fill is a hint; user may tap it to override.

### `Totals`

```swift
enum Totals {
    /// Cumulative score per player across all rounds. Players missing from a
    /// round's PlayerScore set contribute 0 (sparse rounds).
    static func cumulative(for session: Session) -> [String: Int]

    /// (name, total) sorted descending by total. Ties broken by playerName
    /// for stable ordering across renders.
    static func ranking(for session: Session) -> [(name: String, total: Int)]
}
```

Used by `SessionView` chip row (each player's running total) and `SummaryView` ranking cards.

### `SessionShare`

DTO is decoupled from `@Model` so the wire format is stable across SwiftData schema migrations.

```swift
struct SessionDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let createdAt: Date
    let players: [String]
    let rounds: [RoundDTO]
    struct RoundDTO: Codable {
        let index: Int
        let createdAt: Date
        let scores: [String: Int]    // playerName → value
    }
}

enum SessionShare {
    /// Session → SessionDTO → JSON → zlib → base64url → phorm://import?s=<…>
    static func url(for session: Session) throws -> URL

    /// Reverse of `url(for:)`. Throws on bad scheme/host/query/decode.
    static func decode(_ url: URL) throws -> SessionDTO
}
```

Wire format details:
- URL shape: `phorm://import?s=<base64url-encoded zlib of JSON DTO>`
- Base64url variant: `+` → `-`, `/` → `_`, no `=` padding (padded back on decode)
- zlib via `(data as NSData).compressed(using: .zlib)`
- Sanity target: realistic 4-player × 20-round session encodes under ~6 KB (well within AirDrop's URL handling).

### `SessionActions`

The single mutation surface for views. Every state-changing operation goes through here.

```swift
enum SessionActions {
    static func archiveActive(in: ModelContext) throws
    static func createSession(name: String, playerNames: [String], in: ModelContext) throws -> Session
    static func appendRound(scores: [String: Int], to: Session, in: ModelContext) throws
    static func updateRound(_ round: Round, scores: [String: Int], in: ModelContext) throws
    static func deleteRound(_ round: Round, in: ModelContext) throws
    static func endSession(_ session: Session, in: ModelContext) throws        // sets archivedAt
    static func importSession(_ dto: SessionDTO, in: ModelContext) throws -> Session   // archives current first
}
```

`createSession` and `importSession` both call `archiveActive` first — that's where the "1 active at a time" invariant lives.

## Round entry state machine

`RoundDraft` owns the round-entry sheet's transient state. Lives only as long as the sheet; persisted to SwiftData only on Save.

```swift
@Observable final class RoundDraft {
    let playerNames: [String]
    var entries: [Int?]              // length == N; nil = blank
    var focusedIndex: Int?           // keypad target

    var liveSum: Int { entries.compactMap { $0 }.reduce(0, +) }
    var autoFillValue: Int? { AutoFill.suggestion(for: entries) }

    /// The single blank slot when N-1 are filled — but only if NOT currently
    /// focused (the focused row shows a cursor, not an auto-fill hint).
    var autoFillIndex: Int? {
        guard autoFillValue != nil, let i = entries.firstIndex(of: nil) else { return nil }
        return i == focusedIndex ? nil : i
    }

    func keypad(_ key: KeypadKey)    // digit / sign / delete / next
    func nextField()                  // jump to next non-auto blank row

    /// entries → [String: Int]; auto value materialized at autoFillIndex;
    /// remaining nil → 0 (sparse rounds are valid, PLAN.md §7).
    func materialize() -> [String: Int]
}

enum KeypadKey { case digit(Int), sign, delete, next, save }
```

Edit-existing flow seeds `entries` from `round.scores` (decoded from `[PlayerScore]`).

Sheet flow:
1. Sheet opens → `RoundDraft` instantiated → focus row 0.
2. Keypad taps mutate `entries[focusedIndex]` in-memory only.
3. Live sum + auto-fill recompute on every change (cheap, O(N)).
4. "Lưu ván" → `SessionActions.appendRound(scores: draft.materialize(), to: session, in: context)`.
5. Sheet dismisses → `RoundDraft` deallocates.

## App entry & routing

```swift
@main struct PhormApp: App {
    let container: ModelContainer = {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        return try! ModelContainer(for: schema, configurations: config)
    }()

    @State private var pendingImport: SessionDTO?

    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(container)
                .onOpenURL { url in
                    pendingImport = try? SessionShare.decode(url)
                }
                .sheet(item: $pendingImport) { dto in
                    ImportConfirmView(dto: dto)
                        .interactiveDismissDisabled()
                }
        }
    }
}

struct HomeView: View {
    @Query(filter: #Predicate<Session> { $0.archivedAt == nil },
           sort: \.createdAt, order: .reverse)
    private var active: [Session]

    var body: some View {
        NavigationStack {
            if let session = active.first {
                SessionView(session: session)
            } else {
                EmptyHomeView()
            }
        }
    }
}
```

URL import flow (per PLAN.md "Pattern cần làm"):
- `.onOpenURL` decodes to a `SessionDTO` and binds `pendingImport`.
- `ImportConfirmView` presents **above** the current `SessionView` (sheet, not replace) — Hủy returns to the existing session intact.
- "Mở session này" calls `SessionActions.importSession(dto, in: context)` which archives the current active first, then activates the imported one.

## Design system Swift layer

Translates DESIGN.md's YAML tokens into Swift extensions and modifiers.

### `Color+Tokens.swift`

Two categories:

**Identical in both modes** (plain `Color` extensions):
`phormPrimary`, `phormPrimaryActive`, `phormPrimaryDisabled`, `scorePositive`, `scoreNegative`, `warning`, `muted` (#707a8a is neutral and reads correctly in both modes).

**Adaptive** (declared in `Assets.xcassets` with light + dark hex pairs):
`canvas`, `surfaceCard`, `surfaceElevated`, `surfaceSoft`, `hairline`, `body`, `mutedStrong`, `focusRowTint`, `scorePositiveTint`, `scoreNegativeTint`.

Asset Catalog gives free **Reduce Transparency** and **Increase Contrast** adaptation per the PRODUCT.md accessibility commitments.

### `Font+Tokens.swift`

Split policy per DESIGN.md and PRODUCT.md§Accessibility: editorial copy scales with Dynamic Type, numerics stay fixed for column alignment.

**Strategy:** map editorial tokens onto SwiftUI's built-in text styles wherever DESIGN.md sizes line up with iOS defaults (most do). Built-in styles get Dynamic Type for free without depending on undocumented font names. For outliers, use a `UIFontMetrics`-scaled `UIFont` wrapped in `Font(_:)`.

DESIGN.md → SwiftUI mapping:

| Token | Size / weight | Mapping |
|---|---|---|
| `title-sm` | 17 / 600 | `.headline` (matches exactly) |
| `body-md` | 15 / 400 | `.subheadline` (matches exactly) |
| `body-sm` | 13 / 400 | `.footnote` (matches exactly) |
| `caption` | 12 / 500 | `.caption` (weight applied via `.weight(.medium)`) |
| `title-lg` | 22 / 600 | `.title2` (matches) |
| `title-md` | 20 / 600 | `.title3` (matches) |
| `display-md` | 28 / 600 | `.title` (matches) |
| `display-lg` | 32 / 700 | `UIFontMetrics(.largeTitle).scaledFont(for: 32 bold)` |
| `hero-display` | 40 / 700 | `UIFontMetrics(.largeTitle).scaledFont(for: 40 bold)` |
| `caption-section` | 10 / 600 tracked uppercase | `UIFontMetrics(.caption2).scaledFont(for: 10 semibold)` + `.tracking(0.6)` + `.textCase(.uppercase)` |
| `button` | 17 / 600 | `.headline` |
| `keypad-digit` | 26 / 400 | `Font.system(size: 26, weight: .regular, design: .default)` — fixed, doesn't scale (key size is bounded by keypad layout) |

```swift
extension Font {
    // Editorial — built-in text styles scale via Dynamic Type
    static let titleSm = Font.headline
    static let bodyMd  = Font.subheadline
    static let bodySm  = Font.footnote
    static let caption = Font.caption.weight(.medium)
    static let titleLg = Font.title2.weight(.semibold)
    static let titleMd = Font.title3.weight(.semibold)
    static let displayMd = Font.title.weight(.semibold)
    // displayLg / heroDisplay / captionSection use UIFontMetrics — see helper below

    // Numerics — fixed size, SF Mono, do NOT scale (column alignment is non-negotiable)
    static let numberRanking = Font.system(size: 28, weight: .bold,     design: .monospaced)
    static let numberEntry   = Font.system(size: 22, weight: .semibold, design: .monospaced)
    static let numberMd      = Font.system(size: 17, weight: .medium,   design: .monospaced)
    static let numberSm      = Font.system(size: 15, weight: .medium,   design: .monospaced)
    static let numberChip    = Font.system(size: 17, weight: .bold,     design: .monospaced)
}

// Helper for editorial outliers that need exact non-standard sizes
private func scaled(_ size: CGFloat, weight: UIFont.Weight, relativeTo style: UIFont.TextStyle) -> Font {
    let base = UIFont.systemFont(ofSize: size, weight: weight)
    return Font(UIFontMetrics(forTextStyle: style).scaledFont(for: base))
}
```

### `Material+Tokens.swift`

DESIGN.md's four glass variants map onto SwiftUI's built-in materials (iOS 17+ renders them; iOS 18+ upgrades automatically to Liquid Glass):

| DESIGN.md token | SwiftUI material |
|---|---|
| `glass-regular-*` | `.regularMaterial` |
| `glass-thick-sheet` | `.thickMaterial` (sheets use this by default) |
| `glass-clear` | `.ultraThinMaterial` |

A `.glassSpecularTop()` modifier adds the 1px top-edge specular gradient (`glass-specular` → clear) called out in DESIGN.md.

### `Radius.swift` / `Spacing.swift`

```swift
enum Radius {
    static let xs: CGFloat = 4;   static let sm: CGFloat = 8
    static let md: CGFloat = 12;  static let lg: CGFloat = 16
    static let xl: CGFloat = 22;  static let pill: CGFloat = 9999
}
enum Spacing {
    static let xxs: CGFloat = 4;  static let xs: CGFloat = 8
    static let sm: CGFloat = 12;  static let md: CGFloat = 16
    static let lg: CGFloat = 20;  static let xl: CGFloat = 28
    static let xxl: CGFloat = 40; static let section: CGFloat = 56
}
```

Every rounded surface uses `RoundedRectangle(cornerRadius: …, style: .continuous)` — enforced by the `.continuousRounded(_)` helper in `View+Helpers.swift`.

## Testing

Target: `PhormTests` using Swift Testing (`import Testing`, `@Test`, `#expect`). ~22 cases total across 4 files. No UI tests, no snapshot tests, no CI.

| File | Cases | Coverage |
|---|---:|---|
| `AutoFillTests.swift` | 6 | all-nil; 1-of-4 filled; 3-of-4 filled (→ −sum); all filled; negatives & zeros; already-balanced returns 0 |
| `TotalsTests.swift` | 3 | empty session → all zeros; multi-round summation; ranking sort with tie-break by playerName |
| `SessionShareTests.swift` | 4 | encode→decode roundtrip; roundtrip with Vietnamese-diacritic player names; URL byte budget < 6 KB for 4-player × 20-round session; invalid URL throws |
| `SessionActionsTests.swift` | 5 | archiveActive sets archivedAt; createSession archives previous active; appendRound increments index; deleteRound cascades PlayerScore; importSession archives current then activates DTO |

`SessionActionsTests` uses an in-memory `ModelContainer` fixture:

```swift
let container = try ModelContainer(
    for: Schema([Session.self, Round.self, PlayerScore.self]),
    configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
)
```

Tests run on `@MainActor` so `ModelContext` is accessible without isolation gymnastics.

## Performance principles (no formal budgets)

- Keypad taps mutate `RoundDraft.entries` in-memory only — no SwiftData write per keystroke.
- `Totals.cumulative` is O(rounds × playerScores), computed on the fly. For realistic sessions (≤ 100 rounds × ≤ 8 players) that's < 1k ops per render; no memoization needed.
- `@Query` for active session uses `FetchDescriptor(fetchLimit: 1)` where the SwiftUI macro doesn't suffice.
- History list paginates only if it ever exceeds ~200 sessions (not an MVP concern).

If profiling later flags a hotspot, revisit then. Don't pre-optimize.

## Out of scope (this spec)

Mirrors PLAN.md "Out of scope (MVP)" plus these implementation-level cuts:

- SwiftLint / swift-format
- CI (GitHub Actions or otherwise)
- UI tests, snapshot tests
- Performance benchmarks / instrumentation
- Custom app icon (placeholder only for v0)
- Settings/preferences screen of any kind
- Crash reporting / analytics

## Open items (track during implementation)

- **CloudKit container provisioning** — needs an Apple Developer portal step (create `iCloud.com.quyctd.phorm` container, link to Phorm app ID). Document the steps in `andiem-ios/README.md` once done.
- **App icon** — placeholder `#fcd535` "P" tile for v0; commission or design proper icon post-MVP.
- **DESIGN.md vs iOS version** — DESIGN.md mentions "iOS 26"; the implementation targets iOS 17.0+. SwiftUI material APIs are forward-compatible (regular/thick render natively, upgrade to Liquid Glass automatically on iOS 18+). No spec change needed.
- **PLAN.md amendment** — change the "Repo: mới, riêng" line in PLAN.md §Tech-stack to reflect the `./andiem-ios/` subfolder decision (do this as part of the implementation plan's first step).
