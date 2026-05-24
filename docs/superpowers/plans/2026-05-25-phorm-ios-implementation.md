# Phorm iOS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the native iOS MVP of Phorm — an offline-first Vietnamese card-game score tracker — per the spec at `docs/superpowers/specs/2026-05-25-phorm-ios-implementation-design.md`.

**Architecture:** Direct `@Observable` + `@Query` SwiftUI on iOS 17+. SwiftData + CloudKit (`.automatic`) for storage and free iPhone↔iPad sync. Pure-function logic layer (`AutoFill`, `Totals`, `SessionShare`, `SessionActions`) keeps the active-session invariant and URL handoff testable. Sheet-local `@Observable` (`RoundDraft`) owns transient round-entry state.

**Tech Stack:** Swift 5.9+, SwiftUI, SwiftData, CloudKit (`iCloud.com.quyctd.phorm`), Swift Testing (`import Testing`). Xcode 15+ required. URL scheme `phorm://import?s=<base64url(zlib(JSON))>`. **Project file generation:** [xcodegen](https://github.com/yonaskolb/XcodeGen) — `phorm-ios/project.yml` is the source of truth; `phorm-ios.xcodeproj/` is regenerated and gitignored.

**Source docs (read first):**
- `docs/superpowers/specs/2026-05-25-phorm-ios-implementation-design.md` — implementation spec (this plan implements it)
- `PLAN.md` — product/UX (14 locked decisions)
- `DESIGN.md` — visual tokens (colors, type, materials, radius, spacing)
- `PRODUCT.md` — brand voice, anti-references, accessibility
- `design-walkthrough.html` — visual reference for every screen

**File-structure overview (gets built up across the plan):**

```
saam-app/
├── PLAN.md                                          # amended in Task A1
├── README.md                                        # pointer added in Task A1
├── .gitignore                                       # Xcode entries appended in Task A1
└── phorm-ios/                                       # new — created in Task B1
    ├── phorm-ios.xcodeproj                          # Task B1
    ├── README.md                                    # Task B5 (CloudKit setup notes)
    ├── Phorm/
    │   ├── PhormApp.swift                           # Task C1, G1
    │   ├── Info.plist                               # Task B2
    │   ├── Phorm.entitlements                       # Task B2
    │   ├── Models/
    │   │   ├── Session.swift                        # Task C1
    │   │   ├── Round.swift                          # Task C1
    │   │   └── PlayerScore.swift                    # Task C1
    │   ├── Logic/
    │   │   ├── AutoFill.swift                       # Task D1
    │   │   ├── Totals.swift                         # Task D2
    │   │   ├── SessionShare.swift                   # Tasks D3, D4
    │   │   └── SessionActions.swift                 # Tasks D5–D8
    │   ├── State/
    │   │   └── RoundDraft.swift                     # Task F1
    │   ├── DesignSystem/
    │   │   ├── Color+Tokens.swift                   # Task E1
    │   │   ├── Font+Tokens.swift                    # Task E2
    │   │   ├── Material+Tokens.swift                # Task E3
    │   │   ├── Radius.swift, Spacing.swift          # Task E4
    │   │   └── View+Helpers.swift                   # Task E3
    │   ├── Views/
    │   │   ├── HomeView.swift                       # Task G2
    │   │   ├── EmptyHomeView.swift                  # Task G2
    │   │   ├── NewSessionView.swift                 # Tasks H1–H3
    │   │   ├── SessionView.swift                    # Tasks I3, I4
    │   │   ├── RoundEntryView.swift                 # Tasks J2–J4
    │   │   ├── SummaryView.swift                    # Task K2
    │   │   ├── HistoryView.swift                    # Task K3
    │   │   ├── ImportConfirmView.swift              # Task L1
    │   │   └── Components/
    │   │       ├── ScoreChip.swift                  # Task I1
    │   │       ├── TotalsChipRow.swift              # Task I1
    │   │       ├── RoundCard.swift                  # Task I2
    │   │       ├── Keypad.swift                     # Task J1
    │   │       ├── SumIndicator.swift               # Task J3
    │   │       ├── RankingCard.swift                # Task K1
    │   │       └── HistoryRow.swift                 # Task K3
    │   └── Resources/
    │       └── Assets.xcassets                      # Task E1 (color sets)
    └── PhormTests/
        ├── AutoFillTests.swift                      # Task D1
        ├── TotalsTests.swift                        # Task D2
        ├── SessionShareTests.swift                  # Tasks D3, D4
        └── SessionActionsTests.swift                # Tasks D5–D8
```

---

## Phase A — Repo prep

### Task A1: Amend PLAN.md, extend .gitignore, add README pointer

**Files:**
- Modify: `PLAN.md` (Tech stack section)
- Modify: `.gitignore`
- Modify: `README.md`

- [ ] **Step 1: Read current state**

Read `PLAN.md` § "Tech stack" (around line 34–43), `.gitignore`, and `README.md` so you know exactly what's already there and don't duplicate.

- [ ] **Step 2: Amend PLAN.md tech-stack line**

In `PLAN.md`, replace the line that reads:

```
- **Repo**: mới, riêng — `phorm-ios` (không nằm trong repo `phorm-app` này; repo hiện tại giữ làm reference cho UX history)
```

with:

```
- **Repo**: iOS code lives in `./phorm-ios/` subfolder of this repo (one git history for spec + code; decision logged in `docs/superpowers/specs/2026-05-25-phorm-ios-implementation-design.md`)
```

- [ ] **Step 3: Extend `.gitignore`**

Append (only if not already present):

```
# Xcode
xcuserdata/
*.xcuserstate
.swiftpm/
DerivedData/
build/
.DS_Store

# xcodegen-generated project (regenerate with `xcodegen generate`)
phorm-ios/phorm-ios.xcodeproj/
```

- [ ] **Step 4: Add README pointer**

In `README.md`, add a section right after the existing intro (keep existing content intact):

```markdown
## iOS app

The native iOS implementation lives in [`./phorm-ios/`](./phorm-ios/). See the spec at [`docs/superpowers/specs/2026-05-25-phorm-ios-implementation-design.md`](docs/superpowers/specs/2026-05-25-phorm-ios-implementation-design.md) and the step-by-step plan at [`docs/superpowers/plans/2026-05-25-phorm-ios-implementation.md`](docs/superpowers/plans/2026-05-25-phorm-ios-implementation.md).
```

- [ ] **Step 5: Commit**

```bash
git add PLAN.md .gitignore README.md
git commit -m "Prep repo for ./phorm-ios subfolder"
```

---

## Phase B — Xcode project via xcodegen

> **Tooling:** This phase uses [xcodegen](https://github.com/yonaskolb/XcodeGen) so the project file is generated from a YAML spec and the subagent can drive the whole flow without Xcode GUI clicks. The `.xcodeproj/` is gitignored; `project.yml` is the source of truth.
>
> **One manual user step is unavoidable:** before TestFlight or any device build, open Xcode once and set the signing team in Signing & Capabilities → Team. Simulator builds work without it.

### Task B1: Install xcodegen + folder skeleton

**Files:**
- Create: `phorm-ios/Phorm/Models/.gitkeep`
- Create: `phorm-ios/Phorm/Logic/.gitkeep`
- Create: `phorm-ios/Phorm/State/.gitkeep`
- Create: `phorm-ios/Phorm/DesignSystem/.gitkeep`
- Create: `phorm-ios/Phorm/Views/Components/.gitkeep`
- Create: `phorm-ios/Phorm/Resources/Assets.xcassets/Contents.json`
- Create: `phorm-ios/Phorm/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`
- Create: `phorm-ios/PhormTests/.gitkeep`

- [ ] **Step 1: Install xcodegen (idempotent)**

```bash
which xcodegen >/dev/null 2>&1 || brew install xcodegen
xcodegen --version
```

Expected: prints a version like `2.41.0` or newer.

- [ ] **Step 2: Create folder skeleton**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app
mkdir -p phorm-ios/Phorm/{Models,Logic,State,DesignSystem,Views/Components,Resources/Assets.xcassets/AppIcon.appiconset}
mkdir -p phorm-ios/PhormTests
# .gitkeep files so empty dirs are tracked
touch phorm-ios/Phorm/Models/.gitkeep \
      phorm-ios/Phorm/Logic/.gitkeep \
      phorm-ios/Phorm/State/.gitkeep \
      phorm-ios/Phorm/DesignSystem/.gitkeep \
      phorm-ios/Phorm/Views/Components/.gitkeep \
      phorm-ios/PhormTests/.gitkeep
```

- [ ] **Step 3: Write `Assets.xcassets/Contents.json`**

```json
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

- [ ] **Step 4: Write `AppIcon.appiconset/Contents.json` (placeholder icon)**

```json
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

> The empty AppIcon set causes a build warning ("App icon set has no images") but builds succeed. Proper icon is post-MVP.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/
git commit -m "phorm-ios: folder skeleton + empty Assets.xcassets"
```

### Task B2: Write `project.yml`, entitlements, placeholder Swift

**Files:**
- Create: `phorm-ios/project.yml`
- Create: `phorm-ios/Phorm/Phorm.entitlements`
- Create: `phorm-ios/Phorm/PhormApp.swift`
- Create: `phorm-ios/PhormTests/PhormTests.swift`

- [ ] **Step 1: Write `phorm-ios/project.yml`**

```yaml
name: phorm-ios
options:
  bundleIdPrefix: com.quyctd
  deploymentTarget:
    iOS: "17.0"
  developmentLanguage: en
  groupSortPosition: top
  generateEmptyDirectories: true
settings:
  base:
    SWIFT_VERSION: "5.9"
    CODE_SIGN_STYLE: Automatic
    # Leave DEVELOPMENT_TEAM unset; user picks it once in Xcode for device builds.
    # Simulator builds work without it.
targets:
  Phorm:
    type: application
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - path: Phorm
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.quyctd.phorm
        CODE_SIGN_ENTITLEMENTS: Phorm/Phorm.entitlements
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        GENERATE_INFOPLIST_FILE: "YES"
        INFOPLIST_KEY_CFBundleDisplayName: Phorm
        INFOPLIST_KEY_UILaunchScreen_Generation: "YES"
        INFOPLIST_KEY_UIApplicationSceneManifest_Generation: "YES"
        INFOPLIST_KEY_UISupportedInterfaceOrientations: "UIInterfaceOrientationPortrait"
        INFOPLIST_KEY_UIBackgroundModes: "remote-notification"
    info:
      path: Phorm/Info.plist
      properties:
        CFBundleDisplayName: Phorm
        UIBackgroundModes:
          - remote-notification
        CFBundleURLTypes:
          - CFBundleTypeRole: Editor
            CFBundleURLName: com.quyctd.phorm.import
            CFBundleURLSchemes:
              - phorm
        UILaunchScreen:
          UIColorName: ""
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
  PhormTests:
    type: bundle.unit-test
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - path: PhormTests
    dependencies:
      - target: Phorm
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.quyctd.phorm.Tests
        GENERATE_INFOPLIST_FILE: "YES"
schemes:
  Phorm:
    build:
      targets:
        Phorm: all
        PhormTests: [test]
    test:
      targets:
        - PhormTests
      gatherCoverageData: false
```

> `info.path` declares an Info.plist file but `GENERATE_INFOPLIST_FILE: YES` makes Xcode auto-generate one merged with the listed `properties`. This is xcodegen's idiomatic way to inject custom plist keys without hand-managing the whole file.

- [ ] **Step 2: Write `phorm-ios/Phorm/Phorm.entitlements`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTD/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.quyctd.phorm</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>aps-environment</key>
    <string>development</string>
</dict>
</plist>
```

- [ ] **Step 3: Write placeholder `PhormApp.swift`**

`phorm-ios/Phorm/PhormApp.swift`:

```swift
import SwiftUI

@main
struct PhormApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Phorm — placeholder")
        }
    }
}
```

This is a placeholder; Task C1 wires the real `ModelContainer`.

- [ ] **Step 4: Write sanity test**

`phorm-ios/PhormTests/PhormTests.swift`:

```swift
import Testing
@testable import Phorm

@Suite("Sanity")
struct SanityTests {
    @Test func canImportAppModule() {
        #expect(Bool(true))
    }
}
```

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/
git commit -m "phorm-ios: project.yml + entitlements + placeholder app + sanity test"
```

### Task B3: Generate project, verify build + tests

**Files:** none new — verifies the previous tasks.

- [ ] **Step 1: Generate the Xcode project**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/phorm-ios
xcodegen generate
```

Expected: `Created project at /Users/dinhquy/Documents/quyctd/saam-app/phorm-ios/phorm-ios.xcodeproj`.

- [ ] **Step 2: Pick an available iOS 17 simulator**

```bash
xcrun simctl list devices available | grep -iE "iPhone (15|16) Pro" | head -3
```

Take note of one device name like `iPhone 15 Pro`. If none match, use any iOS 17.x device from the listing. Below, replace `iPhone 15 Pro` with whatever you picked.

- [ ] **Step 3: Verify build (simulator, no signing)**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/phorm-ios
xcodebuild \
  -project phorm-ios.xcodeproj \
  -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build 2>&1 | tail -50
```

Expected: `** BUILD SUCCEEDED **` near the end.

- [ ] **Step 4: Verify tests**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/phorm-ios
xcodebuild \
  -project phorm-ios.xcodeproj \
  -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  test 2>&1 | tail -30
```

Expected: `** TEST SUCCEEDED **`. 1 test passes (`SanityTests.canImportAppModule`).

> If you see `** TEST FAILED **` with "missing module Testing", confirm Xcode is 15.0+ (`xcodebuild -version`) — Swift Testing ships with Xcode 15.

- [ ] **Step 5: Confirm `.xcodeproj` is gitignored**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app
git status --short phorm-ios/phorm-ios.xcodeproj
```

Expected: no output (file is ignored). If output appears, the .gitignore entry from Task A1 is missing — fix and re-stage.

### Task B4: CloudKit provisioning notes

**Files:**
- Create: `phorm-ios/README.md`

- [ ] **Step 1: Write README**

```markdown
# Phorm iOS

Implementation of the Phorm score tracker. See `../docs/superpowers/specs/2026-05-25-phorm-ios-implementation-design.md` for the architecture spec and `../docs/superpowers/plans/2026-05-25-phorm-ios-implementation.md` for the implementation plan.

## Requirements
- Xcode 15.0+
- iOS 17.0+ (deployment target)
- [xcodegen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- Apple Developer account in Xcode → Settings → Accounts (only needed for device builds + CloudKit)

## Generating the project

The Xcode project file is generated from `project.yml`; it is **not** checked into git.

```sh
cd phorm-ios
xcodegen generate
open phorm-ios.xcodeproj
```

Regenerate whenever `project.yml` changes.

## Building & testing from the CLI

```sh
# Build (simulator, no signing required)
xcodebuild -project phorm-ios.xcodeproj -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO build

# Run unit tests
xcodebuild -project phorm-ios.xcodeproj -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO test
```

## One-time setup for device builds

1. Open `phorm-ios.xcodeproj` in Xcode.
2. Select the Phorm target → Signing & Capabilities → set **Team** to your Apple Developer team.
3. Xcode auto-provisions the bundle ID + CloudKit container on first build.

## CloudKit container

Container ID: `iCloud.com.quyctd.phorm`

On first device build, Xcode auto-creates the container in the developer portal. Verify at https://developer.apple.com/account/resources/identifiers/list/cloudContainer.

After the first run that writes data, the CloudKit Console (https://icloud.developer.apple.com/dashboard/) shows the schema. **Before TestFlight, promote the schema from Development → Production** via the Console.

If you build on simulator only, CloudKit calls will fail silently (no container provisioned). The app works local-only; SwiftData persists locally.
```

- [ ] **Step 2: Commit**

```bash
git add phorm-ios/README.md
git commit -m "phorm-ios: README with xcodegen + CloudKit setup notes"
```

---

## Build & regen convention (applies to Phases C–M)

After **adding** any new Swift file or asset, regenerate the project before building/testing — xcodegen captures the file list at generate time and `xcodebuild` won't see new files otherwise:

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/phorm-ios
xcodegen generate
```

`xcodegen generate` is idempotent and runs in <1 sec. Modifying an existing file does **not** require regen.

The canonical build + test commands (use whichever simulator name Task B3 confirmed available):

```bash
# Build
xcodebuild -project phorm-ios.xcodeproj -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO build 2>&1 | tail -30

# Test
xcodebuild -project phorm-ios.xcodeproj -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO test 2>&1 | tail -40
```

Whenever a task says "Build (⌘B)" or "Run tests (⌘U)", run the CLI equivalents above (after `xcodegen generate` if files were added).

---

## Phase C — Data model

### Task C1: Define `Session`, `Round`, `PlayerScore` + wire `ModelContainer`

**Files:**
- Create: `phorm-ios/Phorm/Models/Session.swift`
- Create: `phorm-ios/Phorm/Models/Round.swift`
- Create: `phorm-ios/Phorm/Models/PlayerScore.swift`
- Modify: `phorm-ios/Phorm/PhormApp.swift`

- [ ] **Step 1: Create `Session.swift`**

```swift
import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date.now
    var archivedAt: Date?
    var playerNames: [String] = []

    @Relationship(deleteRule: .cascade, inverse: \Round.session)
    var rounds: [Round]? = []

    init(
        id: UUID = UUID(),
        name: String = "",
        createdAt: Date = .now,
        archivedAt: Date? = nil,
        playerNames: [String] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.archivedAt = archivedAt
        self.playerNames = playerNames
    }
}
```

- [ ] **Step 2: Create `Round.swift`**

```swift
import Foundation
import SwiftData

@Model
final class Round {
    var id: UUID = UUID()
    var index: Int = 0
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.round)
    var scores: [PlayerScore]? = []

    var session: Session?

    init(
        id: UUID = UUID(),
        index: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.index = index
        self.createdAt = createdAt
    }
}
```

- [ ] **Step 3: Create `PlayerScore.swift`**

```swift
import Foundation
import SwiftData

@Model
final class PlayerScore {
    var playerName: String = ""
    var value: Int = 0
    var round: Round?

    init(playerName: String = "", value: Int = 0) {
        self.playerName = playerName
        self.value = value
    }
}
```

- [ ] **Step 4: Wire `ModelContainer` in `PhormApp.swift`**

Replace the entire contents of `phorm-ios/Phorm/PhormApp.swift` with:

```swift
import SwiftUI
import SwiftData

@main
struct PhormApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Text("Phorm — models loaded")
        }
        .modelContainer(container)
    }
}
```

- [ ] **Step 5: Build (⌘B) — verify models compile**

Expected: Build Succeeded. If the SwiftData macro fails to expand, clean the build folder (⇧⌘K) and rebuild.

- [ ] **Step 6: Run (⌘R) — verify ModelContainer init doesn't crash**

App should launch and display "Phorm — models loaded". Cmd+Q simulator.

- [ ] **Step 7: Commit**

```bash
git add phorm-ios/Phorm/Models/ phorm-ios/Phorm/PhormApp.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: Session/Round/PlayerScore models + CloudKit ModelContainer"
```

---

## Phase D — Pure logic (TDD)

### Task D1: `AutoFill.suggestion(for:)` — test first, then impl

**Files:**
- Create: `phorm-ios/PhormTests/AutoFillTests.swift`
- Create: `phorm-ios/Phorm/Logic/AutoFill.swift`

- [ ] **Step 1: Write failing tests**

`phorm-ios/PhormTests/AutoFillTests.swift`:

```swift
import Testing
@testable import Phorm

@Suite("AutoFill")
struct AutoFillTests {
    @Test func returnsNilWhenAllEmpty() {
        #expect(AutoFill.suggestion(for: [nil, nil, nil, nil]) == nil)
    }

    @Test func returnsNilWhenOnlyOneFilled() {
        #expect(AutoFill.suggestion(for: [5, nil, nil, nil]) == nil)
    }

    @Test func suggestsNegativeSumWhenAllButOneFilled() {
        #expect(AutoFill.suggestion(for: [1, 2, 3, nil]) == -6)
    }

    @Test func returnsNilWhenAllFilled() {
        #expect(AutoFill.suggestion(for: [1, 2, 3, -6]) == nil)
    }

    @Test func handlesNegativesAndZeros() {
        #expect(AutoFill.suggestion(for: [-3, 0, 5, nil]) == -2)
    }

    @Test func suggestsZeroWhenFilledAlreadyBalance() {
        #expect(AutoFill.suggestion(for: [1, -1, nil]) == 0)
    }
}
```

- [ ] **Step 2: Run tests — verify they fail**

⌘U. Expected: 6 failures, all with "Cannot find 'AutoFill' in scope".

- [ ] **Step 3: Implement `AutoFill`**

`phorm-ios/Phorm/Logic/AutoFill.swift`:

```swift
import Foundation

/// Pure function for the round-entry auto-fill hint.
/// Per PLAN.md §7: suggestion appears only when exactly N-1 of N cells are filled.
enum AutoFill {
    /// Returns the value that would balance the round (negative of the current sum)
    /// iff exactly one entry is `nil`. Otherwise returns `nil` (no hint shown).
    static func suggestion(for entries: [Int?]) -> Int? {
        let filled = entries.compactMap { $0 }
        guard entries.count - filled.count == 1 else { return nil }
        return -filled.reduce(0, +)
    }
}
```

- [ ] **Step 4: Run tests — verify pass**

⌘U. Expected: all 6 AutoFill tests pass.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/Logic/AutoFill.swift phorm-ios/PhormTests/AutoFillTests.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: AutoFill.suggestion(for:) + tests"
```

### Task D2: `Totals.cumulative` / `Totals.ranking` — test first

**Files:**
- Create: `phorm-ios/PhormTests/TotalsTests.swift`
- Create: `phorm-ios/Phorm/Logic/Totals.swift`

- [ ] **Step 1: Write failing tests**

`phorm-ios/PhormTests/TotalsTests.swift`:

```swift
import Testing
import SwiftData
@testable import Phorm

@MainActor
@Suite("Totals")
struct TotalsTests {
    /// In-memory ModelContainer fixture — no CloudKit, no disk.
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test func emptySessionReturnsAllZeros() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        let session = Session(playerNames: ["An", "Bình", "Cường", "Dũng"])
        ctx.insert(session)

        let totals = Totals.cumulative(for: session)
        #expect(totals == ["An": 0, "Bình": 0, "Cường": 0, "Dũng": 0])
    }

    @Test func multiRoundSumsCorrectly() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        let session = Session(playerNames: ["An", "Bình", "Cường"])
        ctx.insert(session)

        for (idx, scores) in [
            ["An": -5, "Bình": 2, "Cường": 3],
            ["An": 1,  "Bình": -4, "Cường": 3]
        ].enumerated() {
            let r = Round(index: idx + 1)
            r.session = session
            ctx.insert(r)
            for (name, v) in scores {
                let s = PlayerScore(playerName: name, value: v)
                s.round = r
                ctx.insert(s)
            }
        }

        let totals = Totals.cumulative(for: session)
        #expect(totals == ["An": -4, "Bình": -2, "Cường": 6])
    }

    @Test func rankingSortsDescendingWithTieBreakByName() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        let session = Session(playerNames: ["Zebra", "Alpha", "Beta"])
        ctx.insert(session)
        let r = Round(index: 1)
        r.session = session
        ctx.insert(r)
        for (name, v) in [("Zebra", 5), ("Alpha", 5), ("Beta", -10)] {
            let s = PlayerScore(playerName: name, value: v)
            s.round = r
            ctx.insert(s)
        }

        let ranking = Totals.ranking(for: session)
        #expect(ranking.map(\.name) == ["Alpha", "Zebra", "Beta"])
        #expect(ranking.map(\.total) == [5, 5, -10])
    }
}
```

- [ ] **Step 2: Run tests — verify they fail**

⌘U. Expected: 3 failures, "Cannot find 'Totals' in scope".

- [ ] **Step 3: Implement `Totals`**

`phorm-ios/Phorm/Logic/Totals.swift`:

```swift
import Foundation

enum Totals {
    /// Cumulative score per player across all rounds in the session.
    /// Players present in `session.playerNames` but absent from a round's
    /// `PlayerScore` set contribute 0 (sparse rounds — PLAN.md §7).
    static func cumulative(for session: Session) -> [String: Int] {
        var result: [String: Int] = Dictionary(
            uniqueKeysWithValues: session.playerNames.map { ($0, 0) }
        )
        for round in session.rounds ?? [] {
            for score in round.scores ?? [] {
                result[score.playerName, default: 0] += score.value
            }
        }
        return result
    }

    /// `(name, total)` sorted descending by `total`. Ties broken by `name`
    /// ascending for stable ordering across renders.
    static func ranking(for session: Session) -> [(name: String, total: Int)] {
        cumulative(for: session)
            .map { (name: $0.key, total: $0.value) }
            .sorted { lhs, rhs in
                if lhs.total != rhs.total { return lhs.total > rhs.total }
                return lhs.name < rhs.name
            }
    }
}
```

- [ ] **Step 4: Run tests — verify pass**

⌘U. Expected: all 3 Totals tests pass (plus prior 6 AutoFill).

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/Logic/Totals.swift phorm-ios/PhormTests/TotalsTests.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: Totals.cumulative + Totals.ranking + tests"
```

### Task D3: `SessionDTO` + `SessionShare.url(for:)` — test first

**Files:**
- Create: `phorm-ios/PhormTests/SessionShareTests.swift`
- Create: `phorm-ios/Phorm/Logic/SessionShare.swift`

- [ ] **Step 1: Write failing tests (encode only — decode in D4)**

`phorm-ios/PhormTests/SessionShareTests.swift`:

```swift
import Testing
import Foundation
import SwiftData
@testable import Phorm

@MainActor
@Suite("SessionShare")
struct SessionShareTests {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Helper: build a session with N rounds × M players, each with random-ish scores.
    static func makeSession(in ctx: ModelContext, players: [String], rounds: Int) -> Session {
        let s = Session(playerNames: players)
        ctx.insert(s)
        for i in 0..<rounds {
            let r = Round(index: i + 1)
            r.session = s
            ctx.insert(r)
            // simple zero-sum: first player loses, rest each gain (N-1) shared / (N-1) = 1
            for (idx, name) in players.enumerated() {
                let v = idx == 0 ? -(players.count - 1) : 1
                let ps = PlayerScore(playerName: name, value: v)
                ps.round = r
                ctx.insert(ps)
            }
        }
        return s
    }

    @Test func urlHasPhormImportScheme() throws {
        let container = try Self.makeContainer()
        let s = Self.makeSession(in: container.mainContext, players: ["An", "Bình"], rounds: 1)
        let url = try SessionShare.url(for: s)
        #expect(url.scheme == "phorm")
        #expect(url.host == "import")
        let q = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "s" })?.value
        #expect(q != nil && !q!.isEmpty)
    }

    @Test func realisticSessionFitsUnderSixKB() throws {
        let container = try Self.makeContainer()
        let s = Self.makeSession(in: container.mainContext,
                                 players: ["An", "Bình", "Cường", "Dũng"],
                                 rounds: 20)
        let url = try SessionShare.url(for: s)
        #expect(url.absoluteString.utf8.count < 6_000)
    }
}
```

- [ ] **Step 2: Run tests — verify they fail**

⌘U. Expected: 2 failures, "Cannot find 'SessionShare' in scope".

- [ ] **Step 3: Implement `SessionDTO` + `SessionShare.url(for:)`**

`phorm-ios/Phorm/Logic/SessionShare.swift`:

```swift
import Foundation

// MARK: - Wire-format DTOs

struct SessionDTO: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let createdAt: Date
    let players: [String]
    let rounds: [RoundDTO]

    struct RoundDTO: Codable, Equatable {
        let index: Int
        let createdAt: Date
        let scores: [String: Int]   // playerName → value
    }
}

extension SessionDTO {
    /// Lossy snapshot of a `Session` for URL handoff. `archivedAt` is intentionally
    /// dropped — the receiver decides activation locally.
    init(from session: Session) {
        self.id = session.id
        self.name = session.name
        self.createdAt = session.createdAt
        self.players = session.playerNames
        self.rounds = (session.rounds ?? [])
            .sorted { $0.index < $1.index }
            .map { round in
                let scores = Dictionary(
                    uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
                )
                return RoundDTO(index: round.index, createdAt: round.createdAt, scores: scores)
            }
    }
}

// MARK: - URL encode/decode

enum SessionShare {
    enum ShareError: Error {
        case invalidURL
        case invalidPayload
    }

    /// `Session` → `SessionDTO` → JSON → zlib → base64url → `phorm://import?s=<…>`
    static func url(for session: Session) throws -> URL {
        let dto = SessionDTO(from: session)
        let json = try JSONEncoder().encode(dto)
        let zlib = try (json as NSData).compressed(using: .zlib) as Data
        let b64url = zlib.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        var c = URLComponents()
        c.scheme = "phorm"
        c.host = "import"
        c.queryItems = [URLQueryItem(name: "s", value: b64url)]
        guard let url = c.url else { throw ShareError.invalidPayload }
        return url
    }
}
```

- [ ] **Step 4: Run tests — verify pass**

⌘U. Expected: D3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/Logic/SessionShare.swift phorm-ios/PhormTests/SessionShareTests.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: SessionShare.url(for:) + SessionDTO + tests"
```

### Task D4: `SessionShare.decode(_:)` — test first

**Files:**
- Modify: `phorm-ios/PhormTests/SessionShareTests.swift`
- Modify: `phorm-ios/Phorm/Logic/SessionShare.swift`

- [ ] **Step 1: Add failing decode tests**

Append to `phorm-ios/PhormTests/SessionShareTests.swift` (inside the `SessionShareTests` struct, before the closing brace):

```swift
    @Test func encodeDecodeRoundtrip() throws {
        let container = try Self.makeContainer()
        let original = Self.makeSession(in: container.mainContext,
                                        players: ["An", "Bình", "Cường"],
                                        rounds: 3)
        let originalDTO = SessionDTO(from: original)
        let url = try SessionShare.url(for: original)

        let decoded = try SessionShare.decode(url)
        #expect(decoded == originalDTO)
    }

    @Test func roundtripPreservesVietnameseDiacritics() throws {
        let container = try Self.makeContainer()
        let s = Self.makeSession(in: container.mainContext,
                                 players: ["Đức", "Bằng", "Hưng", "Hoàng"],
                                 rounds: 1)
        let url = try SessionShare.url(for: s)
        let decoded = try SessionShare.decode(url)
        #expect(decoded.players == ["Đức", "Bằng", "Hưng", "Hoàng"])
    }

    @Test func invalidSchemeThrows() {
        let url = URL(string: "https://example.com/import?s=abc")!
        #expect(throws: SessionShare.ShareError.self) {
            try SessionShare.decode(url)
        }
    }

    @Test func missingQueryThrows() {
        let url = URL(string: "phorm://import")!
        #expect(throws: SessionShare.ShareError.self) {
            try SessionShare.decode(url)
        }
    }
```

- [ ] **Step 2: Run tests — verify they fail**

⌘U. Expected: 4 new failures, "Cannot find 'decode' in scope".

- [ ] **Step 3: Implement `decode(_:)`**

Append inside the `SessionShare` enum in `phorm-ios/Phorm/Logic/SessionShare.swift`:

```swift
    /// Reverse of `url(for:)`. Throws `ShareError.invalidURL` for bad scheme/host/query
    /// or `ShareError.invalidPayload` for malformed base64/zlib/JSON.
    static func decode(_ url: URL) throws -> SessionDTO {
        guard url.scheme == "phorm", url.host == "import" else {
            throw ShareError.invalidURL
        }
        guard let raw = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "s" })?.value,
              !raw.isEmpty else {
            throw ShareError.invalidURL
        }

        // base64url → base64 (re-pad)
        var b64 = raw
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let pad = (4 - b64.count % 4) % 4
        b64.append(String(repeating: "=", count: pad))

        guard let zlib = Data(base64Encoded: b64) else {
            throw ShareError.invalidPayload
        }
        do {
            let json = try (zlib as NSData).decompressed(using: .zlib) as Data
            return try JSONDecoder().decode(SessionDTO.self, from: json)
        } catch {
            throw ShareError.invalidPayload
        }
    }
```

- [ ] **Step 4: Run tests — verify pass**

⌘U. Expected: all SessionShare tests pass.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/Logic/SessionShare.swift phorm-ios/PhormTests/SessionShareTests.swift
git commit -m "phorm-ios: SessionShare.decode(_:) + roundtrip tests"
```

### Task D5: `SessionActions` test fixture + `archiveActive`

**Files:**
- Create: `phorm-ios/PhormTests/SessionActionsTests.swift`
- Create: `phorm-ios/Phorm/Logic/SessionActions.swift`

- [ ] **Step 1: Write failing test**

`phorm-ios/PhormTests/SessionActionsTests.swift`:

```swift
import Testing
import SwiftData
import Foundation
@testable import Phorm

@MainActor
@Suite("SessionActions")
struct SessionActionsTests {
    static func makeContext() throws -> ModelContext {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(for: schema, configurations: [config])
        return container.mainContext
    }

    @Test func archiveActiveSetsArchivedAt() throws {
        let ctx = try Self.makeContext()
        let s = Session(playerNames: ["An"])
        ctx.insert(s)
        try ctx.save()
        #expect(s.archivedAt == nil)

        try SessionActions.archiveActive(in: ctx)
        #expect(s.archivedAt != nil)
    }
}
```

- [ ] **Step 2: Run — verify it fails**

⌘U. Expected: "Cannot find 'SessionActions' in scope".

- [ ] **Step 3: Implement `archiveActive`**

`phorm-ios/Phorm/Logic/SessionActions.swift`:

```swift
import Foundation
import SwiftData

/// The single mutation surface for Session / Round / PlayerScore.
/// Views call into here; they do not insert / delete on `ModelContext` directly.
/// This is where the "one active session at a time" invariant lives.
enum SessionActions {
    /// Mark every currently-active session (archivedAt == nil) as archived = now.
    /// Idempotent: safe to call when no active session exists.
    static func archiveActive(in context: ModelContext) throws {
        let descriptor = FetchDescriptor<Session>(
            predicate: #Predicate { $0.archivedAt == nil }
        )
        let active = try context.fetch(descriptor)
        for session in active {
            session.archivedAt = .now
        }
        try context.save()
    }
}
```

- [ ] **Step 4: Run — verify pass**

⌘U. Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/Logic/SessionActions.swift phorm-ios/PhormTests/SessionActionsTests.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: SessionActions.archiveActive + tests"
```

### Task D6: `SessionActions.createSession` (archives previous)

**Files:**
- Modify: `phorm-ios/PhormTests/SessionActionsTests.swift`
- Modify: `phorm-ios/Phorm/Logic/SessionActions.swift`

- [ ] **Step 1: Add failing test**

Append inside `SessionActionsTests`:

```swift
    @Test func createSessionArchivesPreviousActive() throws {
        let ctx = try Self.makeContext()
        let first = Session(name: "first", playerNames: ["An"])
        ctx.insert(first)
        try ctx.save()

        let second = try SessionActions.createSession(
            name: "second",
            playerNames: ["Bình", "Cường"],
            in: ctx
        )

        #expect(first.archivedAt != nil)
        #expect(second.archivedAt == nil)
        #expect(second.playerNames == ["Bình", "Cường"])
    }
```

- [ ] **Step 2: Run — verify it fails**

⌘U. Expected: "Type 'SessionActions' has no member 'createSession'".

- [ ] **Step 3: Implement**

Append inside `SessionActions`:

```swift
    /// Archive the current active session (if any) and create a new one.
    /// Returns the inserted, saved Session.
    @discardableResult
    static func createSession(
        name: String,
        playerNames: [String],
        in context: ModelContext
    ) throws -> Session {
        try archiveActive(in: context)
        let session = Session(name: name, playerNames: playerNames)
        context.insert(session)
        try context.save()
        return session
    }
```

- [ ] **Step 4: Run — verify pass**

⌘U. Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/Logic/SessionActions.swift phorm-ios/PhormTests/SessionActionsTests.swift
git commit -m "phorm-ios: SessionActions.createSession + tests"
```

### Task D7: `appendRound`, `updateRound`, `deleteRound`

**Files:**
- Modify: `phorm-ios/PhormTests/SessionActionsTests.swift`
- Modify: `phorm-ios/Phorm/Logic/SessionActions.swift`

- [ ] **Step 1: Add failing tests**

Append inside `SessionActionsTests`:

```swift
    @Test func appendRoundIncrementsIndex() throws {
        let ctx = try Self.makeContext()
        let s = try SessionActions.createSession(
            name: "t", playerNames: ["An", "Bình"], in: ctx
        )

        try SessionActions.appendRound(scores: ["An": -3, "Bình": 3], to: s, in: ctx)
        try SessionActions.appendRound(scores: ["An": 2,  "Bình": -2], to: s, in: ctx)

        let rounds = (s.rounds ?? []).sorted { $0.index < $1.index }
        #expect(rounds.map(\.index) == [1, 2])
        #expect(rounds[0].scores?.count == 2)
    }

    @Test func deleteRoundCascadesPlayerScores() throws {
        let ctx = try Self.makeContext()
        let s = try SessionActions.createSession(
            name: "t", playerNames: ["An", "Bình"], in: ctx
        )
        try SessionActions.appendRound(scores: ["An": -3, "Bình": 3], to: s, in: ctx)
        let round = (s.rounds ?? []).first!

        try SessionActions.deleteRound(round, in: ctx)

        let remaining = try ctx.fetch(FetchDescriptor<PlayerScore>())
        #expect(remaining.isEmpty)
        #expect((s.rounds ?? []).isEmpty)
    }

    @Test func updateRoundReplacesScores() throws {
        let ctx = try Self.makeContext()
        let s = try SessionActions.createSession(
            name: "t", playerNames: ["An", "Bình"], in: ctx
        )
        try SessionActions.appendRound(scores: ["An": -3, "Bình": 3], to: s, in: ctx)
        let round = (s.rounds ?? []).first!

        try SessionActions.updateRound(round, scores: ["An": 5, "Bình": -5], in: ctx)

        let scores = Dictionary(
            uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
        )
        #expect(scores == ["An": 5, "Bình": -5])
    }
```

- [ ] **Step 2: Run — verify failures**

⌘U. Expected: 3 failures referring to missing members.

- [ ] **Step 3: Implement**

Append inside `SessionActions`:

```swift
    /// Append a new round to the session with the given scores.
    /// `scores` keys should match `session.playerNames`; absent keys → 0 (sparse).
    static func appendRound(
        scores: [String: Int],
        to session: Session,
        in context: ModelContext
    ) throws {
        let nextIndex = (session.rounds ?? []).count + 1
        let round = Round(index: nextIndex)
        round.session = session
        context.insert(round)
        for name in session.playerNames {
            let value = scores[name] ?? 0
            let ps = PlayerScore(playerName: name, value: value)
            ps.round = round
            context.insert(ps)
        }
        try context.save()
    }

    /// Replace a round's PlayerScore set with the given map. Keeps the round's
    /// `index` and `createdAt` intact.
    static func updateRound(
        _ round: Round,
        scores: [String: Int],
        in context: ModelContext
    ) throws {
        for existing in round.scores ?? [] {
            context.delete(existing)
        }
        let players = round.session?.playerNames ?? Array(scores.keys)
        for name in players {
            let value = scores[name] ?? 0
            let ps = PlayerScore(playerName: name, value: value)
            ps.round = round
            context.insert(ps)
        }
        try context.save()
    }

    /// Delete a round; cascade rule on `Round.scores` removes child PlayerScores.
    static func deleteRound(_ round: Round, in context: ModelContext) throws {
        context.delete(round)
        try context.save()
    }
```

- [ ] **Step 4: Run — verify pass**

⌘U. Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/Logic/SessionActions.swift phorm-ios/PhormTests/SessionActionsTests.swift
git commit -m "phorm-ios: SessionActions append/update/deleteRound + tests"
```

### Task D8: `importSession` + `endSession`

**Files:**
- Modify: `phorm-ios/PhormTests/SessionActionsTests.swift`
- Modify: `phorm-ios/Phorm/Logic/SessionActions.swift`

- [ ] **Step 1: Add failing tests**

Append inside `SessionActionsTests`:

```swift
    @Test func importSessionArchivesCurrentAndActivatesIncoming() throws {
        let ctx = try Self.makeContext()
        let current = try SessionActions.createSession(
            name: "current", playerNames: ["An"], in: ctx
        )
        try SessionActions.appendRound(scores: ["An": 0], to: current, in: ctx)
        let exported = try SessionShare.url(for: current)

        // Simulate receive on (logically) another device by decoding back
        let dto = try SessionShare.decode(exported)
        let imported = try SessionActions.importSession(dto, in: ctx)

        #expect(current.archivedAt != nil)
        #expect(imported.archivedAt == nil)
        #expect(imported.playerNames == ["An"])
        #expect((imported.rounds ?? []).count == 1)
    }

    @Test func endSessionSetsArchivedAt() throws {
        let ctx = try Self.makeContext()
        let s = try SessionActions.createSession(
            name: "t", playerNames: ["An"], in: ctx
        )
        try SessionActions.endSession(s, in: ctx)
        #expect(s.archivedAt != nil)
    }
```

- [ ] **Step 2: Run — verify failures**

⌘U. Expected: 2 failures.

- [ ] **Step 3: Implement**

Append inside `SessionActions`:

```swift
    /// End an active session (manual "Kết thúc"). Just sets archivedAt.
    static func endSession(_ session: Session, in context: ModelContext) throws {
        session.archivedAt = .now
        try context.save()
    }

    /// Archive the current active session, then materialize an incoming DTO
    /// into a new active Session (with all rounds + scores rebuilt).
    /// Returns the inserted, saved Session.
    @discardableResult
    static func importSession(
        _ dto: SessionDTO,
        in context: ModelContext
    ) throws -> Session {
        try archiveActive(in: context)
        let session = Session(
            id: dto.id,
            name: dto.name,
            createdAt: dto.createdAt,
            archivedAt: nil,
            playerNames: dto.players
        )
        context.insert(session)
        for roundDTO in dto.rounds.sorted(by: { $0.index < $1.index }) {
            let round = Round(index: roundDTO.index, createdAt: roundDTO.createdAt)
            round.session = session
            context.insert(round)
            for name in dto.players {
                let value = roundDTO.scores[name] ?? 0
                let ps = PlayerScore(playerName: name, value: value)
                ps.round = round
                context.insert(ps)
            }
        }
        try context.save()
        return session
    }
```

- [ ] **Step 4: Run — verify all pass**

⌘U. Expected: all ~22 tests pass.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/Logic/SessionActions.swift phorm-ios/PhormTests/SessionActionsTests.swift
git commit -m "phorm-ios: SessionActions importSession + endSession + tests"
```

---

## Phase E — Design system

> Every step here references `DESIGN.md` for the source-of-truth hex / sizes / radii. Don't paraphrase — copy the exact values listed in the YAML frontmatter.

### Task E1: Color tokens (asset catalog + extensions)

**Files:**
- Modify: `phorm-ios/Phorm/Resources/Assets.xcassets/` (add color sets)
- Create: `phorm-ios/Phorm/DesignSystem/Color+Tokens.swift`

- [ ] **Step 1: Write 10 `.colorset/Contents.json` files**

Asset Catalog color sets are folders containing a `Contents.json` describing light + dark variants. Write the JSON files directly — no Xcode GUI needed.

Schema (single colorset Contents.json — light & dark pair, opaque):

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : { "alpha" : "1.000", "red" : "0xFF", "green" : "0xFF", "blue" : "0xFF" }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        { "appearance" : "luminosity", "value" : "dark" }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : { "alpha" : "1.000", "red" : "0x0B", "green" : "0x0E", "blue" : "0x11" }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

For tinted colors, replace the `alpha` value (e.g., `"alpha" : "0.16"` for 16%).

Create one folder + Contents.json per color set under `phorm-ios/Phorm/Resources/Assets.xcassets/`:

| Folder | Light (Any) hex | Light alpha | Dark hex | Dark alpha |
|---|---|---|---|---|
| `Canvas.colorset` | `0xFFFFFF` | 1.000 | `0x0B0E11` | 1.000 |
| `SurfaceCard.colorset` | `0xFFFFFF` | 1.000 | `0x1E2329` | 1.000 |
| `SurfaceElevated.colorset` | `0xF5F5F5` | 1.000 | `0x2B3139` | 1.000 |
| `SurfaceSoft.colorset` | `0xFAFAFA` | 1.000 | `0x1E2329` | 1.000 |
| `Hairline.colorset` | `0xEAECEF` | 1.000 | `0x2B3139` | 1.000 |
| `Body.colorset` | `0x181A20` | 1.000 | `0xEAECEF` | 1.000 |
| `MutedStrong.colorset` | `0x707A8A` | 1.000 | `0x929AA5` | 1.000 |
| `FocusRowTint.colorset` | `0xFCD535` | 0.16 | `0xFCD535` | 0.12 |
| `ScorePositiveTint.colorset` | `0xE8FAF2` | 1.000 | `0x0ECB81` | 0.14 |
| `ScoreNegativeTint.colorset` | `0xFDECEF` | 1.000 | `0xF6465D` | 0.14 |

Hex must be in `0xRR`, `0xGG`, `0xBB` form (zero-padded uppercase). Components keys appear in the exact order shown: `alpha`, `red`, `green`, `blue` (Xcode is order-tolerant but consistency helps diffs).

After writing all 10 colorsets, run `xcodegen generate` so the new files are picked up.

- [ ] **Step 2: Create `Color+Tokens.swift`**

`phorm-ios/Phorm/DesignSystem/Color+Tokens.swift`:

```swift
import SwiftUI

extension Color {
    // MARK: - Brand (identical in both modes)
    static let phormPrimary         = Color(red: 0xFC/255, green: 0xD5/255, blue: 0x35/255)   // #FCD535
    static let phormPrimaryActive   = Color(red: 0xF0/255, green: 0xB9/255, blue: 0x0B/255)   // #F0B90B
    static let phormPrimaryDisabled = Color(red: 0x3A/255, green: 0x3A/255, blue: 0x1F/255)   // #3A3A1F
    static let onPrimary            = Color(red: 0x18/255, green: 0x1A/255, blue: 0x20/255)   // #181A20

    // MARK: - Score semantics (identical in both modes — text color)
    static let scorePositive = Color(red: 0x0E/255, green: 0xCB/255, blue: 0x81/255)   // #0ECB81
    static let scoreNegative = Color(red: 0xF6/255, green: 0x46/255, blue: 0x5D/255)   // #F6465D
    static let warning       = Color(red: 0xFF/255, green: 0x95/255, blue: 0x00/255)   // #FF9500
    static let phormMuted    = Color(red: 0x70/255, green: 0x7A/255, blue: 0x8A/255)   // #707A8A — neutral in both modes

    // MARK: - Adaptive (resolved from Assets.xcassets)
    static let canvas             = Color("Canvas")
    static let surfaceCard        = Color("SurfaceCard")
    static let surfaceElevated    = Color("SurfaceElevated")
    static let surfaceSoft        = Color("SurfaceSoft")
    static let hairline           = Color("Hairline")
    static let bodyText           = Color("Body")
    static let mutedStrong        = Color("MutedStrong")
    static let focusRowTint       = Color("FocusRowTint")
    static let scorePositiveTint  = Color("ScorePositiveTint")
    static let scoreNegativeTint  = Color("ScoreNegativeTint")
}
```

- [ ] **Step 3: Build — verify color names resolve**

⌘B. If Xcode reports "Color set named 'X' not found", the asset set name was misspelled in Step 1. Names are case-sensitive.

- [ ] **Step 4: Commit**

```bash
git add phorm-ios/Phorm/DesignSystem/Color+Tokens.swift phorm-ios/Phorm/Resources/Assets.xcassets phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: DESIGN.md color tokens (brand + adaptive light/dark)"
```

### Task E2: Font tokens

**Files:**
- Create: `phorm-ios/Phorm/DesignSystem/Font+Tokens.swift`

- [ ] **Step 1: Create `Font+Tokens.swift`**

```swift
import SwiftUI
import UIKit

extension Font {
    // MARK: - Editorial (scales with Dynamic Type via system text styles)
    static let phormTitleSm   = Font.headline                              // 17 / 600
    static let phormBodyMd    = Font.subheadline                           // 15 / 400
    static let phormBodySm    = Font.footnote                              // 13 / 400
    static let phormCaption   = Font.caption.weight(.medium)               // 12 / 500
    static let phormTitleLg   = Font.title2.weight(.semibold)              // 22 / 600
    static let phormTitleMd   = Font.title3.weight(.semibold)              // 20 / 600
    static let phormDisplayMd = Font.title.weight(.semibold)               // 28 / 600
    static let phormButton    = Font.headline                              // 17 / 600

    // MARK: - Editorial outliers — UIFontMetrics-scaled
    static let phormDisplayLg    = Font.scaled(32, weight: .bold,     relativeTo: .largeTitle)
    static let phormHeroDisplay  = Font.scaled(40, weight: .bold,     relativeTo: .largeTitle)
    static let phormCaptionSection = Font.scaled(10, weight: .semibold, relativeTo: .caption2)

    // MARK: - Numerics (fixed size — column alignment over Dynamic Type)
    static let phormNumberRanking = Font.system(size: 28, weight: .bold,     design: .monospaced)
    static let phormNumberEntry   = Font.system(size: 22, weight: .semibold, design: .monospaced)
    static let phormNumberMd      = Font.system(size: 17, weight: .medium,   design: .monospaced)
    static let phormNumberSm      = Font.system(size: 15, weight: .medium,   design: .monospaced)
    static let phormNumberChip    = Font.system(size: 17, weight: .bold,     design: .monospaced)

    // MARK: - Keypad (fixed — bounded by key size)
    static let phormKeypadDigit = Font.system(size: 26, weight: .regular)

    // MARK: - Helpers
    fileprivate static func scaled(
        _ size: CGFloat,
        weight: UIFont.Weight,
        relativeTo style: UIFont.TextStyle
    ) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return Font(UIFontMetrics(forTextStyle: style).scaledFont(for: base))
    }
}
```

- [ ] **Step 2: Build — verify**

⌘B. Expected: Build Succeeded.

- [ ] **Step 3: Commit**

```bash
git add phorm-ios/Phorm/DesignSystem/Font+Tokens.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: DESIGN.md font tokens (editorial Dynamic Type + fixed SF Mono numerics)"
```

### Task E3: Material tokens + View helpers

**Files:**
- Create: `phorm-ios/Phorm/DesignSystem/Material+Tokens.swift`
- Create: `phorm-ios/Phorm/DesignSystem/View+Helpers.swift`

- [ ] **Step 1: Create `Material+Tokens.swift`**

```swift
import SwiftUI

/// DESIGN.md `materials:` mapped to SwiftUI's built-in Material values.
/// SwiftUI handles Reduce Transparency / Increase Contrast automatically.
enum PhormMaterial {
    /// Nav bar, autosuggest dropdown, secondary glass button — DESIGN.md `glass-regular-*`.
    static let glassRegular: Material = .regularMaterial

    /// Round-entry sheet, new-session sheet, import-confirm sheet, keypad container
    /// — DESIGN.md `glass-thick-sheet`. Sheets get this by default in iOS 17+.
    static let glassThickSheet: Material = .thickMaterial

    /// Floating overlays over rich content — DESIGN.md `glass-clear`.
    static let glassClear: Material = .ultraThinMaterial
}
```

- [ ] **Step 2: Create `View+Helpers.swift`**

```swift
import SwiftUI

extension View {
    /// Continuous-corner squircle clip. Enforces the iOS platform corner curve everywhere.
    func continuousRounded(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// 1px top-edge specular highlight on glass surfaces (DESIGN.md `glass-specular`).
    func glassSpecularTop() -> some View {
        overlay(alignment: .top) {
            LinearGradient(
                colors: [Color.white.opacity(0.14), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 1)
            .allowsHitTesting(false)
        }
    }
}
```

- [ ] **Step 3: Build & commit**

⌘B → Build Succeeded.

```bash
git add phorm-ios/Phorm/DesignSystem/Material+Tokens.swift phorm-ios/Phorm/DesignSystem/View+Helpers.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: glass materials + continuousRounded/glassSpecularTop helpers"
```

### Task E4: Radius + Spacing tokens

**Files:**
- Create: `phorm-ios/Phorm/DesignSystem/Radius.swift`
- Create: `phorm-ios/Phorm/DesignSystem/Spacing.swift`

- [ ] **Step 1: Create `Radius.swift`**

```swift
import CoreGraphics

enum Radius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 22
    static let pill: CGFloat = 9999
}
```

- [ ] **Step 2: Create `Spacing.swift`**

```swift
import CoreGraphics

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let xxl: CGFloat = 40
    static let section: CGFloat = 56
}
```

- [ ] **Step 3: Build & commit**

⌘B → Build Succeeded.

```bash
git add phorm-ios/Phorm/DesignSystem/Radius.swift phorm-ios/Phorm/DesignSystem/Spacing.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: Radius + Spacing tokens"
```

---

## Phase F — Sheet-local state

### Task F1: `RoundDraft` + `KeypadKey`

**Files:**
- Create: `phorm-ios/Phorm/State/RoundDraft.swift`

- [ ] **Step 1: Create file**

```swift
import Foundation
import Observation

enum KeypadKey: Equatable {
    case digit(Int)   // 0...9
    case sign
    case delete
    case next
}

/// Sheet-local round-entry state. Lives only as long as the round-entry sheet;
/// nothing persists until `materialize()` is handed to `SessionActions.appendRound`
/// / `.updateRound`.
@Observable
final class RoundDraft {
    let playerNames: [String]
    var entries: [Int?]
    var focusedIndex: Int?

    init(playerNames: [String], existing: [String: Int]? = nil) {
        self.playerNames = playerNames
        if let existing {
            self.entries = playerNames.map { existing[$0] }
        } else {
            self.entries = Array(repeating: nil, count: playerNames.count)
        }
        self.focusedIndex = playerNames.indices.first
    }

    // MARK: - Derived

    var liveSum: Int { entries.compactMap { $0 }.reduce(0, +) }

    var autoFillValue: Int? { AutoFill.suggestion(for: entries) }

    /// Row index that should display the italic-muted auto-fill hint.
    /// Returns nil when no hint should show (e.g., user is focused on the empty slot).
    var autoFillIndex: Int? {
        guard autoFillValue != nil,
              let blank = entries.firstIndex(where: { $0 == nil }) else { return nil }
        return blank == focusedIndex ? nil : blank
    }

    var isSumBalanced: Bool { liveSum == 0 }

    // MARK: - Keypad input

    func keypad(_ key: KeypadKey) {
        guard let i = focusedIndex else { return }
        switch key {
        case .digit(let d):
            let current = entries[i] ?? 0
            let sign = current < 0 ? -1 : 1
            let abs = Swift.abs(current)
            let next = abs * 10 + d
            entries[i] = sign * next
        case .sign:
            if let v = entries[i] { entries[i] = -v }
            else { entries[i] = 0 } // sign on empty sets up a negative
        case .delete:
            guard let v = entries[i] else { return }
            let abs = Swift.abs(v) / 10
            entries[i] = abs == 0 ? nil : (v < 0 ? -abs : abs)
        case .next:
            nextField()
        }
    }

    /// Jump focus to the next row, skipping the auto-fill row.
    func nextField() {
        guard let current = focusedIndex else {
            focusedIndex = playerNames.indices.first
            return
        }
        let count = playerNames.count
        var candidate = (current + 1) % count
        while candidate != current && candidate == autoFillIndex {
            candidate = (candidate + 1) % count
        }
        focusedIndex = candidate
    }

    // MARK: - Save

    /// Materialize entries into a `[playerName: value]` map.
    /// - Auto-fill value lands at `autoFillIndex` (if any).
    /// - Remaining `nil` entries become 0 (sparse rounds, PLAN.md §7).
    func materialize() -> [String: Int] {
        var result: [String: Int] = [:]
        let auto = autoFillValue
        let autoIdx = autoFillIndex
        for (i, name) in playerNames.enumerated() {
            if let v = entries[i] {
                result[name] = v
            } else if i == autoIdx, let auto {
                result[name] = auto
            } else {
                result[name] = 0
            }
        }
        return result
    }
}
```

- [ ] **Step 2: Build — verify**

⌘B. Expected: Build Succeeded.

- [ ] **Step 3: Commit**

```bash
git add phorm-ios/Phorm/State/RoundDraft.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: RoundDraft @Observable + KeypadKey"
```

---

## Phase G — App entry + routing

### Task G1: PhormApp scene + `.onOpenURL` import wiring

**Files:**
- Modify: `phorm-ios/Phorm/PhormApp.swift`

- [ ] **Step 1: Update `PhormApp.swift`**

Replace contents with:

```swift
import SwiftUI
import SwiftData

@main
struct PhormApp: App {
    let container: ModelContainer

    @State private var pendingImport: SessionDTO?

    init() {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .onOpenURL { url in
                    pendingImport = try? SessionShare.decode(url)
                }
                .sheet(item: $pendingImport) { dto in
                    ImportConfirmView(dto: dto, onDismiss: { pendingImport = nil })
                        .interactiveDismissDisabled()
                }
        }
        .modelContainer(container)
    }
}
```

> `HomeView` and `ImportConfirmView` don't exist yet — Step 2 builds will fail until G2 and L1 add them. That's expected; we wire scaffolding first.

- [ ] **Step 2: Skip build for now**

Don't build yet — `HomeView` / `ImportConfirmView` missing. Move to G2.

### Task G2: `HomeView` + `EmptyHomeView`

**Files:**
- Create: `phorm-ios/Phorm/Views/HomeView.swift`
- Create: `phorm-ios/Phorm/Views/EmptyHomeView.swift`
- Create: `phorm-ios/Phorm/Views/SessionView.swift` (stub — fleshed out in Phase I)
- Create: `phorm-ios/Phorm/Views/ImportConfirmView.swift` (stub — fleshed out in Phase L)
- Create: `phorm-ios/Phorm/Views/NewSessionView.swift` (stub — fleshed out in Phase H)

- [ ] **Step 1: Create `HomeView.swift`**

```swift
import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<Session> { $0.archivedAt == nil },
           sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
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

- [ ] **Step 2: Create `EmptyHomeView.swift`**

```swift
import SwiftUI

struct EmptyHomeView: View {
    @State private var showNewSession = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(Color.phormMuted)
            Text("Chưa có ván nào")
                .font(.phormTitleLg)
                .foregroundStyle(Color.bodyText)
            Text("Tạo session mới để bắt đầu ghi điểm")
                .font(.phormBodyMd)
                .foregroundStyle(Color.phormMuted)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                showNewSession = true
            } label: {
                Text("+ Tạo session mới")
                    .font(.phormButton)
                    .foregroundStyle(Color.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.phormPrimary)
                    .continuousRounded(Radius.lg)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Spacing.xl)
        .background(Color.canvas)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    HistoryView()
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(Color.phormPrimary)
                }
            }
        }
        .sheet(isPresented: $showNewSession) {
            NewSessionView()
        }
    }
}
```

- [ ] **Step 3: Create stubs for `SessionView`, `NewSessionView`, `ImportConfirmView`, `HistoryView`, `SummaryView`**

`phorm-ios/Phorm/Views/SessionView.swift`:

```swift
import SwiftUI

struct SessionView: View {
    let session: Session
    var body: some View { Text("SessionView — \(session.name)") }
}
```

`phorm-ios/Phorm/Views/NewSessionView.swift`:

```swift
import SwiftUI

struct NewSessionView: View {
    var body: some View { Text("NewSessionView stub") }
}
```

`phorm-ios/Phorm/Views/ImportConfirmView.swift`:

```swift
import SwiftUI

struct ImportConfirmView: View {
    let dto: SessionDTO
    let onDismiss: () -> Void
    var body: some View { Text("ImportConfirmView — \(dto.name)") }
}
```

`phorm-ios/Phorm/Views/HistoryView.swift`:

```swift
import SwiftUI

struct HistoryView: View {
    var body: some View { Text("HistoryView stub") }
}
```

`phorm-ios/Phorm/Views/SummaryView.swift`:

```swift
import SwiftUI

struct SummaryView: View {
    let session: Session
    var body: some View { Text("SummaryView — \(session.name)") }
}
```

- [ ] **Step 4: Build & run**

⌘B → Build Succeeded. ⌘R → simulator shows "Chưa có ván nào" with the yellow "+ Tạo session mới" button. Tapping it presents the NewSessionView stub. Top-right clock icon opens HistoryView stub.

- [ ] **Step 5: Commit**

```bash
git add phorm-ios/Phorm/PhormApp.swift phorm-ios/Phorm/Views/ phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: HomeView routing + EmptyHomeView + view stubs"
```

---

## Phase H — New session flow

### Task H1: `NewSessionView` — player chips, name editor, basic create

**Files:**
- Modify: `phorm-ios/Phorm/Views/NewSessionView.swift`

- [ ] **Step 1: Replace stub with full implementation**

```swift
import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var sessionName: String = Self.defaultName()
    @State private var players: [String] = []
    @State private var nameInput: String = ""

    private static func defaultName() -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy HH:mm"
        return f.string(from: .now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    sectionLabel("TÊN SESSION")
                    TextField("", text: $sessionName)
                        .font(.phormTitleSm)
                        .foregroundStyle(Color.bodyText)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .frame(height: 50)
                        .background(Color.surfaceElevated)
                        .continuousRounded(Radius.md)

                    sectionLabel("NGƯỜI CHƠI")
                    chipFlow
                    addPlayerField
                }
                .padding(Spacing.lg)
            }
            .background(Color.canvas)
            .navigationTitle("Session mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundStyle(Color.phormPrimary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    create()
                } label: {
                    Text("Bắt đầu →")
                        .font(.phormButton)
                        .foregroundStyle(Color.onPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(players.count >= 2 ? Color.phormPrimary : Color.phormPrimaryDisabled)
                        .continuousRounded(Radius.lg)
                }
                .disabled(players.count < 2)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.sm)
            }
        }
    }

    @ViewBuilder private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.phormCaptionSection)
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(Color.phormMuted)
    }

    private var chipFlow: some View {
        FlowLayout(spacing: Spacing.xs) {
            ForEach(Array(players.enumerated()), id: \.offset) { idx, name in
                HStack(spacing: Spacing.xs) {
                    Text(name).font(.phormBodyMd).foregroundStyle(Color.bodyText)
                    Button {
                        players.remove(at: idx)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.phormMuted)
                    }
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 6)
                .background(Color.surfaceElevated)
                .continuousRounded(Radius.pill)
            }
        }
    }

    private var addPlayerField: some View {
        HStack {
            TextField("+ Thêm người…", text: $nameInput)
                .font(.phormBodyMd)
                .submitLabel(.done)
                .onSubmit { commitPlayer() }
            if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                Button("Thêm") { commitPlayer() }
                    .foregroundStyle(Color.phormPrimary)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .strokeBorder(Color.hairline, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
        )
    }

    private func commitPlayer() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !players.contains(trimmed) else { return }
        players.append(trimmed)
        nameInput = ""
    }

    private func create() {
        do {
            _ = try SessionActions.createSession(
                name: sessionName.trimmingCharacters(in: .whitespaces),
                playerNames: players,
                in: context
            )
            dismiss()
        } catch {
            // PLAN says no fancy error UI; this should not realistically fail in MVP
            print("createSession failed: \(error)")
        }
    }
}

// MARK: - FlowLayout (chips wrap to next line)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
```

- [ ] **Step 2: Build & run**

⌘B → Build Succeeded. ⌘R. From the empty home tap "+ Tạo session mới" → sheet appears with name field + dashed "+ Thêm người…" input. Type "An" → return → chip appears. Add "Bình" → "Bắt đầu" lights up yellow.

- [ ] **Step 3: Sanity: create a session, verify routing**

Add 2 players → "Bắt đầu". Sheet dismisses. Home view should now route to `SessionView` stub showing "SessionView — <name>". Cmd+Q simulator.

- [ ] **Step 4: Commit**

```bash
git add phorm-ios/Phorm/Views/NewSessionView.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: NewSessionView with chips + create flow"
```

### Task H2: Reuse-group card + autosuggest from distinct names

**Files:**
- Modify: `phorm-ios/Phorm/Views/NewSessionView.swift`

- [ ] **Step 1: Add reuse-group card + autosuggest**

In `NewSessionView`, at the top of the file add a `@Query` for past sessions, then inject UI for the reuse card and an autosuggest dropdown.

Add inside `NewSessionView`:

```swift
    @Query(sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
    private var allSessions: [Session]

    /// Distinct player names across history, ordered by recency of last appearance.
    private var distinctPlayerNames: [String] {
        var seen = Set<String>(), result: [String] = []
        for s in allSessions {
            for name in s.playerNames where !seen.contains(name) {
                seen.insert(name); result.append(name)
            }
        }
        return result
    }

    private var lastGroup: Session? {
        allSessions.first(where: { !$0.playerNames.isEmpty })
    }

    private var autosuggestMatches: [String] {
        let q = nameInput.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return [] }
        return distinctPlayerNames
            .filter { $0.lowercased().contains(q) && !players.contains($0) }
            .prefix(5)
            .map { $0 }
    }
```

Insert the reuse card at the top of the `VStack` (before "TÊN SESSION"):

```swift
                    if let group = lastGroup, players.isEmpty {
                        reuseCard(group)
                    }
```

Add the helper inside `NewSessionView`:

```swift
    @ViewBuilder private func reuseCard(_ group: Session) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Nhóm vừa rồi")
                    .font(.phormCaptionSection)
                    .tracking(0.6).textCase(.uppercase)
                    .foregroundStyle(Color.phormMuted)
                Text(group.playerNames.joined(separator: " · "))
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.bodyText)
            }
            Spacer()
            Button {
                players = group.playerNames
            } label: {
                Text("Dùng lại")
                    .font(.phormCaption)
                    .foregroundStyle(Color.onPrimary)
                    .padding(.horizontal, Spacing.sm + 2)
                    .padding(.vertical, 6)
                    .background(Color.phormPrimary)
                    .continuousRounded(Radius.pill)
            }
        }
        .padding(Spacing.md)
        .background(.regularMaterial)
        .continuousRounded(Radius.lg)
    }
```

Replace `addPlayerField` body to show suggestions:

```swift
    private var addPlayerField: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                TextField("+ Thêm người…", text: $nameInput)
                    .font(.phormBodyMd)
                    .submitLabel(.done)
                    .onSubmit { commitPlayer() }
                if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                    Button("Thêm") { commitPlayer() }
                        .foregroundStyle(Color.phormPrimary)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(Color.hairline, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            )

            if !autosuggestMatches.isEmpty {
                VStack(spacing: 0) {
                    ForEach(autosuggestMatches, id: \.self) { name in
                        Button {
                            players.append(name); nameInput = ""
                        } label: {
                            HStack {
                                Text(name)
                                    .font(.phormBodyMd)
                                    .foregroundStyle(Color.bodyText)
                                Spacer()
                            }
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                        }
                        if name != autosuggestMatches.last { Divider().background(Color.hairline) }
                    }
                }
                .background(.regularMaterial)
                .continuousRounded(Radius.md)
            }
        }
    }
```

- [ ] **Step 2: Build & run**

⌘B → Build Succeeded. ⌘R → after creating one session and starting a second, the reuse card appears at top with the previous players + a "Dùng lại" pill. Typing a partial name surfaces autosuggest.

- [ ] **Step 3: Commit**

```bash
git add phorm-ios/Phorm/Views/NewSessionView.swift
git commit -m "phorm-ios: NewSessionView reuse-group card + autosuggest"
```

---

## Phase I — Session screen

### Task I1: `ScoreChip` + `TotalsChipRow`

**Files:**
- Create: `phorm-ios/Phorm/Views/Components/ScoreChip.swift`
- Create: `phorm-ios/Phorm/Views/Components/TotalsChipRow.swift`

- [ ] **Step 1: `ScoreChip.swift`**

```swift
import SwiftUI

struct ScoreChip: View {
    let playerName: String
    let value: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(playerName)
                .font(.phormCaption)
                .foregroundStyle(Color.mutedStrong)
            Text(formatted)
                .font(.phormNumberChip)
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 8)
        .background(background)
        .continuousRounded(Radius.md)
    }

    private var formatted: String {
        if value > 0 { return "+\(value)" }
        return "\(value)" // already prefixed with -
    }

    private var valueColor: Color {
        if value > 0 { return .scorePositive }
        if value < 0 { return .scoreNegative }
        return .bodyText
    }

    private var background: Color {
        if value > 0 { return .scorePositiveTint }
        if value < 0 { return .scoreNegativeTint }
        return .surfaceElevated
    }
}
```

- [ ] **Step 2: `TotalsChipRow.swift`**

```swift
import SwiftUI

struct TotalsChipRow: View {
    let session: Session

    private var ordered: [(name: String, total: Int)] {
        Totals.ranking(for: session)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("TỔNG")
                .font(.phormCaptionSection)
                .tracking(0.6).textCase(.uppercase)
                .foregroundStyle(Color.phormMuted)
                .padding(.horizontal, Spacing.md)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(ordered, id: \.name) { entry in
                        ScoreChip(playerName: entry.name, value: entry.total)
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .padding(.vertical, Spacing.sm)
        .background(Color.surfaceCard)
    }
}
```

- [ ] **Step 3: Build & commit**

⌘B → Build Succeeded.

```bash
git add phorm-ios/Phorm/Views/Components/ScoreChip.swift phorm-ios/Phorm/Views/Components/TotalsChipRow.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: ScoreChip + TotalsChipRow"
```

### Task I2: `RoundCard`

**Files:**
- Create: `phorm-ios/Phorm/Views/Components/RoundCard.swift`

- [ ] **Step 1: Create file**

```swift
import SwiftUI

struct RoundCard: View {
    let round: Round
    let playerOrder: [String]

    private var timestamp: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: round.createdAt)
    }

    private var scoreByName: [String: Int] {
        Dictionary(
            uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Ván \(round.index)")
                    .font(.phormCaption.weight(.semibold))
                    .foregroundStyle(Color.phormMuted)
                Spacer()
                Text(timestamp)
                    .font(.phormCaption)
                    .foregroundStyle(Color.phormMuted)
            }

            FlowLayout(spacing: Spacing.sm) {
                ForEach(playerOrder, id: \.self) { name in
                    HStack(spacing: 4) {
                        Text(name).font(.phormBodyMd).foregroundStyle(Color.phormMuted)
                        Text(format(scoreByName[name] ?? 0))
                            .font(.phormNumberMd)
                            .foregroundStyle(color(for: scoreByName[name] ?? 0))
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.surfaceCard)
        .continuousRounded(Radius.lg)
    }

    private func format(_ v: Int) -> String { v > 0 ? "+\(v)" : "\(v)" }
    private func color(for v: Int) -> Color {
        if v > 0 { return .scorePositive }
        if v < 0 { return .scoreNegative }
        return .bodyText
    }
}
```

- [ ] **Step 2: Build & commit**

```bash
git add phorm-ios/Phorm/Views/Components/RoundCard.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: RoundCard"
```

### Task I3: `SessionView` shell + FAB

**Files:**
- Modify: `phorm-ios/Phorm/Views/SessionView.swift`

- [ ] **Step 1: Replace stub with full SessionView**

```swift
import SwiftUI
import SwiftData

struct SessionView: View {
    let session: Session
    @Environment(\.modelContext) private var context
    @State private var showRoundEntry = false
    @State private var editingRound: Round?
    @State private var showEndConfirm = false

    private var sortedRounds: [Round] {
        (session.rounds ?? []).sorted { $0.index > $1.index }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    TotalsChipRow(session: session)
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(sortedRounds) { round in
                            RoundCard(round: round, playerOrder: session.playerNames)
                                .onTapGesture { editingRound = round }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        try? SessionActions.deleteRound(round, in: context)
                                    } label: {
                                        Label("Xóa", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 96) // FAB clearance
                }
            }
            .background(Color.canvas)

            fab
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                NavBarTitle(session: session)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink(item: (try? SessionShare.url(for: session)) ?? URL(string: "phorm://error")!) {
                        Label("Chia sẻ", systemImage: "square.and.arrow.up")
                    }
                    NavigationLink {
                        SummaryView(session: session)
                    } label: {
                        Label("Tổng kết", systemImage: "trophy")
                    }
                    Button {
                        showEndConfirm = true
                    } label: {
                        Label("Kết thúc", systemImage: "checkmark.seal")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.phormPrimary)
                }
            }
        }
        .sheet(isPresented: $showRoundEntry) {
            RoundEntryView(session: session, mode: .new)
        }
        .sheet(item: $editingRound) { round in
            RoundEntryView(session: session, mode: .edit(round))
        }
        .alert("Kết thúc session?", isPresented: $showEndConfirm) {
            Button("Hủy", role: .cancel) {}
            Button("Kết thúc", role: .destructive) {
                try? SessionActions.endSession(session, in: context)
            }
        }
    }

    private var fab: some View {
        Button {
            showRoundEntry = true
        } label: {
            Text("+ Ván \((session.rounds ?? []).count + 1)")
                .font(.phormButton)
                .foregroundStyle(Color.onPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.phormPrimary)
                .continuousRounded(Radius.lg)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }
}

private struct NavBarTitle: View {
    let session: Session
    @State private var editing = false
    @State private var draft: String = ""

    var body: some View {
        Group {
            if editing {
                TextField("", text: $draft, onCommit: commit)
                    .font(.phormTitleSm)
                    .multilineTextAlignment(.center)
                    .onAppear { draft = session.name }
            } else {
                VStack(spacing: 0) {
                    Text(session.name)
                        .font(.phormTitleSm)
                        .foregroundStyle(Color.bodyText)
                    Text("\(session.playerNames.count) người · \((session.rounds ?? []).count) ván")
                        .font(.phormCaption)
                        .foregroundStyle(Color.phormMuted)
                }
                .onTapGesture { editing = true }
            }
        }
    }

    private func commit() {
        session.name = draft.trimmingCharacters(in: .whitespaces)
        editing = false
    }
}
```

> `RoundEntryView` doesn't exist yet — comes in Phase J. Build will fail until then.

- [ ] **Step 2: Add `RoundEntryView` stub so build compiles**

`phorm-ios/Phorm/Views/RoundEntryView.swift`:

```swift
import SwiftUI

struct RoundEntryView: View {
    enum Mode {
        case new
        case edit(Round)
    }
    let session: Session
    let mode: Mode
    var body: some View { Text("RoundEntryView stub") }
}
```

- [ ] **Step 3: Build & run**

⌘B → Build Succeeded. ⌘R. Create a session → SessionView appears with TỔNG row (empty), no round cards yet, "+ Ván 1" FAB at the bottom. Top-right menu shows Chia sẻ / Tổng kết / Kết thúc.

- [ ] **Step 4: Commit**

```bash
git add phorm-ios/Phorm/Views/SessionView.swift phorm-ios/Phorm/Views/RoundEntryView.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: SessionView shell + FAB + nav bar + RoundEntry stub"
```

---

## Phase J — Round entry

### Task J1: `Keypad` component

**Files:**
- Create: `phorm-ios/Phorm/Views/Components/Keypad.swift`

- [ ] **Step 1: Create file**

```swift
import SwiftUI

struct Keypad: View {
    let onKey: (KeypadKey) -> Void
    let onSave: () -> Void
    let canSave: Bool

    private let layout: [[KeyKind]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.sign,     .digit(0), .delete]
    ]

    private enum KeyKind { case digit(Int), sign, delete }

    var body: some View {
        // DESIGN.md: keypad inherits the sheet's thickMaterial — no own background
        // (avoids "glass on glass" stacking).
        VStack(spacing: 6) {
            ForEach(0..<layout.count, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<layout[row].count, id: \.self) { col in
                        key(layout[row][col])
                    }
                }
            }
            // PLAN.md §8: keypad has Next button (jumps focus past auto-fill row).
            Button { onKey(.next) } label: {
                Text("Tiếp →")
                    .font(.phormButton)
                    .foregroundStyle(Color.bodyText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.surfaceCard)
                    .continuousRounded(Radius.md)
            }
            Button(action: onSave) {
                Text("Lưu ván →")
                    .font(.phormButton)
                    .foregroundStyle(Color.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(canSave ? Color.phormPrimary : Color.phormPrimaryDisabled)
                    .continuousRounded(Radius.lg)
            }
            .disabled(!canSave)
        }
        .padding(8)
    }

    @ViewBuilder
    private func key(_ kind: KeyKind) -> some View {
        Button {
            switch kind {
            case .digit(let d): onKey(.digit(d))
            case .sign:         onKey(.sign)
            case .delete:       onKey(.delete)
            }
        } label: {
            Group {
                switch kind {
                case .digit(let d): Text("\(d)").font(.phormKeypadDigit)
                case .sign:         Image(systemName: "plus.forwardslash.minus").font(.system(size: 22))
                case .delete:       Image(systemName: "delete.left.fill").font(.system(size: 22))
                }
            }
            .foregroundStyle(Color.bodyText)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isUtility(kind) ? Color.surfaceCard : Color.surfaceElevated)
            .continuousRounded(Radius.md)
        }
    }

    private func isUtility(_ k: KeyKind) -> Bool {
        switch k { case .sign, .delete: return true; case .digit: return false }
    }
}
```

- [ ] **Step 2: Build & commit**

```bash
git add phorm-ios/Phorm/Views/Components/Keypad.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: Keypad component (digits + ± + delete + Save)"
```

### Task J2: `SumIndicator`

**Files:**
- Create: `phorm-ios/Phorm/Views/Components/SumIndicator.swift`

- [ ] **Step 1: Create file**

```swift
import SwiftUI

struct SumIndicator: View {
    let sum: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: isOk ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(isOk ? Color.scorePositive : Color.warning)
            Text("Tổng các ô")
                .font(.phormCaption)
                .foregroundStyle(Color.mutedStrong)
            Text(isOk ? "0 ✓" : "\(sum) ⚠")
                .font(.phormTitleSm)
                .foregroundStyle(isOk ? Color.scorePositive : Color.warning)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
        .background(background)
        .continuousRounded(Radius.md)
    }

    private var isOk: Bool { sum == 0 }
    private var background: Color {
        isOk ? Color.scorePositiveTint : Color.warning.opacity(0.14)
    }
}
```

- [ ] **Step 2: Build & commit**

```bash
git add phorm-ios/Phorm/Views/Components/SumIndicator.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: SumIndicator (ok / warning)"
```

### Task J3: `RoundEntryView` — full implementation

**Files:**
- Modify: `phorm-ios/Phorm/Views/RoundEntryView.swift`

- [ ] **Step 1: Replace stub with full view**

```swift
import SwiftUI
import SwiftData

struct RoundEntryView: View {
    enum Mode {
        case new
        case edit(Round)
    }

    let session: Session
    let mode: Mode

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var draft: RoundDraft

    init(session: Session, mode: Mode) {
        self.session = session
        self.mode = mode
        switch mode {
        case .new:
            _draft = State(initialValue: RoundDraft(playerNames: session.playerNames))
        case .edit(let round):
            let map = Dictionary(
                uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
            )
            _draft = State(initialValue: RoundDraft(playerNames: session.playerNames, existing: map))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            playerList
            Spacer(minLength: 0)
            SumIndicator(sum: draft.liveSum)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.sm)
            Keypad(
                onKey: { draft.keypad($0) },
                onSave: save,
                canSave: true
            )
        }
        .background(.thickMaterial)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.phormMuted)
            }
            Spacer()
            Text(headerTitle)
                .font(.phormTitleSm)
                .foregroundStyle(Color.bodyText)
            Spacer()
            if case .edit(let round) = mode {
                Button(role: .destructive) {
                    try? SessionActions.deleteRound(round, in: context)
                    dismiss()
                } label: {
                    Text("Xóa").foregroundStyle(Color.scoreNegative)
                }
            } else {
                Color.clear.frame(width: 40)
            }
        }
        .padding(Spacing.md)
    }

    private var headerTitle: String {
        switch mode {
        case .new: return "Ván \((session.rounds ?? []).count + 1)"
        case .edit(let r): return "Sửa ván \(r.index)"
        }
    }

    private var playerList: some View {
        VStack(spacing: 0) {
            ForEach(Array(draft.playerNames.enumerated()), id: \.offset) { idx, name in
                row(idx: idx, name: name)
                if idx != draft.playerNames.count - 1 {
                    Divider().background(Color.hairline)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    @ViewBuilder
    private func row(idx: Int, name: String) -> some View {
        let isFocused = draft.focusedIndex == idx
        let isAuto = draft.autoFillIndex == idx
        HStack {
            Text(name)
                .font(.phormTitleSm)
                .foregroundStyle(Color.bodyText)
            Spacer()
            valueText(idx: idx, isFocused: isFocused, isAuto: isAuto)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.sm)
        .background(isFocused ? Color.focusRowTint : .clear)
        .overlay(alignment: .bottom) {
            if isFocused { Rectangle().fill(Color.phormPrimary).frame(height: 2) }
        }
        .contentShape(Rectangle())
        .onTapGesture { draft.focusedIndex = idx }
    }

    @ViewBuilder
    private func valueText(idx: Int, isFocused: Bool, isAuto: Bool) -> some View {
        if isAuto, let v = draft.autoFillValue {
            Text("\(formatted(v)) auto")
                .font(.phormNumberEntry)
                .foregroundStyle(Color.phormMuted)
                .italic()
        } else if let v = draft.entries[idx] {
            Text(formatted(v))
                .font(.phormNumberEntry)
                .foregroundStyle(isFocused ? Color.phormPrimary : Color.bodyText)
        } else {
            Text("0")
                .font(.phormNumberEntry)
                .foregroundStyle(Color.phormMuted)
        }
    }

    private func formatted(_ v: Int) -> String {
        v > 0 ? "+\(v)" : "\(v)"
    }

    private func save() {
        let scores = draft.materialize()
        do {
            switch mode {
            case .new:
                try SessionActions.appendRound(scores: scores, to: session, in: context)
            case .edit(let round):
                try SessionActions.updateRound(round, scores: scores, in: context)
            }
            dismiss()
        } catch {
            print("save round failed: \(error)")
        }
    }
}
```

- [ ] **Step 2: Build & run**

⌘B → Build Succeeded. ⌘R. Create session with 4 players → tap "+ Ván 1" → sheet appears with 4 player rows, custom keypad below, sum indicator showing "0 ✓". Tap "1" → "An" row shows `+1`, focus highlight is yellow. Tap row "Bình" → focus moves. Fill 3 rows with `1, 2, 3` → 4th row shows italic `-6 auto`. Tap "Lưu ván →" → sheet dismisses → RoundCard appears in list, TỔNG chips update.

Also test: tap an existing RoundCard → edit sheet opens with pre-filled values + a "Xóa" button in the header.

- [ ] **Step 3: Commit**

```bash
git add phorm-ios/Phorm/Views/RoundEntryView.swift
git commit -m "phorm-ios: RoundEntryView with focus, auto-fill, sum indicator, save/edit"
```

---

## Phase K — Summary & history

### Task K1: `RankingCard` (first / default / last variants)

**Files:**
- Create: `phorm-ios/Phorm/Views/Components/RankingCard.swift`

- [ ] **Step 1: Create file**

```swift
import SwiftUI

struct RankingCard: View {
    enum Position { case first, mid(Int), last }
    let position: Position
    let name: String
    let total: Int
    let wins: Int

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(glyph)
                .font(.system(size: 28))
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.bodyText)
                Text("\(wins) ván thắng")
                    .font(.phormBodySm)
                    .foregroundStyle(Color.phormMuted)
            }
            Spacer()
            Text(totalFormatted)
                .font(.phormNumberRanking)
                .foregroundStyle(totalColor)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Color.surfaceCard)
        .overlay(border)
        .continuousRounded(Radius.lg)
    }

    private var glyph: String {
        switch position {
        case .first:        return "🥇"
        case .mid(2):       return "🥈"
        case .mid(3):       return "🥉"
        case .mid(let n):   return "\(n)"
        case .last:         return "💀"
        }
    }

    private var totalFormatted: String { total > 0 ? "+\(total)" : "\(total)" }

    private var totalColor: Color {
        if total > 0 { return .scorePositive }
        if total < 0 { return .scoreNegative }
        return .bodyText
    }

    @ViewBuilder
    private var border: some View {
        switch position {
        case .first:
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .strokeBorder(Color.phormPrimary, lineWidth: 2)
        case .last:
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .strokeBorder(Color.scoreNegative, lineWidth: 2)
        case .mid:
            EmptyView()
        }
    }
}
```

- [ ] **Step 2: Build & commit**

```bash
git add phorm-ios/Phorm/Views/Components/RankingCard.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: RankingCard variants (first / mid / last)"
```

### Task K2: `SummaryView`

**Files:**
- Modify: `phorm-ios/Phorm/Views/SummaryView.swift`

- [ ] **Step 1: Replace stub**

```swift
import SwiftUI

struct SummaryView: View {
    let session: Session

    private var ranking: [(name: String, total: Int)] { Totals.ranking(for: session) }

    private var winsByPlayer: [String: Int] {
        var wins: [String: Int] = [:]
        for round in session.rounds ?? [] {
            let scores = round.scores ?? []
            if let max = scores.map(\.value).max() {
                for s in scores where s.value == max && s.value > 0 {
                    wins[s.playerName, default: 0] += 1
                }
            }
        }
        return wins
    }

    private var durationStr: String {
        let interval = (session.archivedAt ?? .now).timeIntervalSince(session.createdAt)
        let h = Int(interval) / 3600
        let m = (Int(interval) % 3600) / 60
        return h > 0 ? "\(h)h \(m)p" : "\(m)p"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                VStack(spacing: 8) {
                    Text("🏆").font(.system(size: 32))
                    Text(session.name)
                        .font(.phormTitleLg)
                        .foregroundStyle(Color.bodyText)
                    Text("\((session.rounds ?? []).count) ván · \(session.playerNames.count) người · \(durationStr)")
                        .font(.phormBodySm)
                        .foregroundStyle(Color.phormMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(Color.surfaceCard)
                .continuousRounded(Radius.lg)

                ForEach(Array(ranking.enumerated()), id: \.offset) { i, entry in
                    RankingCard(
                        position: position(for: i, total: ranking.count),
                        name: entry.name,
                        total: entry.total,
                        wins: winsByPlayer[entry.name] ?? 0
                    )
                }

                if let url = try? SessionShare.url(for: session) {
                    ShareLink(item: url) {
                        Text("⤴ Chia sẻ session")
                            .font(.phormButton)
                            .foregroundStyle(Color.onPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.phormPrimary)
                            .continuousRounded(Radius.lg)
                    }
                    .padding(.top, Spacing.md)
                }
            }
            .padding(Spacing.lg)
        }
        .background(Color.canvas)
        .navigationTitle("Tổng kết")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func position(for index: Int, total: Int) -> RankingCard.Position {
        if index == 0 { return .first }
        if index == total - 1 && total >= 4 { return .last }
        return .mid(index + 1)
    }
}
```

- [ ] **Step 2: Build & run**

⌘B → Build Succeeded. ⌘R → create session with rounds, tap menu → Tổng kết. Verify ranking, totals, winners count, share link.

- [ ] **Step 3: Commit**

```bash
git add phorm-ios/Phorm/Views/SummaryView.swift
git commit -m "phorm-ios: SummaryView with ranking + share link"
```

### Task K3: `HistoryView` + `HistoryRow`

**Files:**
- Create: `phorm-ios/Phorm/Views/Components/HistoryRow.swift`
- Modify: `phorm-ios/Phorm/Views/HistoryView.swift`

- [ ] **Step 1: Create `HistoryRow.swift`**

```swift
import SwiftUI

struct HistoryRow: View {
    let session: Session

    private var relativeTime: String {
        RelativeDateTimeFormatter().localizedString(
            for: session.createdAt, relativeTo: .now
        )
    }

    private var winner: (name: String, total: Int)? {
        Totals.ranking(for: session).first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(session.name)
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.bodyText)
                Spacer()
                Text(relativeTime)
                    .font(.phormCaption)
                    .foregroundStyle(Color.phormMuted)
            }
            Text(session.playerNames.joined(separator: " · "))
                .font(.phormBodySm)
                .foregroundStyle(Color.phormMuted)
            HStack(spacing: Spacing.xs) {
                Text("\((session.rounds ?? []).count) ván")
                    .font(.phormCaption)
                    .foregroundStyle(Color.bodyText)
                    .padding(.horizontal, Spacing.xs + 2)
                    .padding(.vertical, 4)
                    .background(Color.surfaceElevated)
                    .continuousRounded(Radius.sm)
                if let w = winner, w.total > 0 {
                    Text("🥇 \(w.name) +\(w.total)")
                        .font(.phormCaption.weight(.semibold))
                        .foregroundStyle(Color.scorePositive)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.surfaceCard)
        .continuousRounded(Radius.lg)
    }
}
```

- [ ] **Step 2: Replace `HistoryView` stub**

```swift
import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
    private var sessions: [Session]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                if sessions.isEmpty {
                    Text("Chưa có session nào")
                        .font(.phormBodyMd)
                        .foregroundStyle(Color.phormMuted)
                        .padding(.top, Spacing.xxl)
                }
                ForEach(sessions) { session in
                    NavigationLink {
                        SummaryView(session: session)
                    } label: {
                        HistoryRow(session: session)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            context.delete(session)
                            try? context.save()
                        } label: {
                            Label("Xóa", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .background(Color.canvas)
        .navigationTitle("Lịch sử")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

- [ ] **Step 3: Build & run**

⌘B → Build Succeeded. ⌘R → after creating + ending one session, tap the clock icon from empty home → HistoryView shows the row. Tap → SummaryView. Long-press → Xóa.

- [ ] **Step 4: Commit**

```bash
git add phorm-ios/Phorm/Views/Components/HistoryRow.swift phorm-ios/Phorm/Views/HistoryView.swift phorm-ios/phorm-ios.xcodeproj
git commit -m "phorm-ios: HistoryView + HistoryRow"
```

---

## Phase L — Share & URL handoff

### Task L1: `ImportConfirmView` full implementation

**Files:**
- Modify: `phorm-ios/Phorm/Views/ImportConfirmView.swift`

- [ ] **Step 1: Replace stub**

```swift
import SwiftUI
import SwiftData

struct ImportConfirmView: View {
    let dto: SessionDTO
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.phormPrimary)
                        .frame(width: 80, height: 80)
                    Text("📥").font(.system(size: 36))
                }
                .padding(.top, Spacing.lg)
                Text("Nhận session")
                    .font(.phormTitleLg)
                    .foregroundStyle(Color.bodyText)
                Text("Ai đó gửi cho bạn 1 session qua AirDrop")
                    .font(.phormBodySm)
                    .foregroundStyle(Color.phormMuted)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(dto.name)
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.bodyText)
                Text(dto.players.joined(separator: " · "))
                    .font(.phormBodySm)
                    .foregroundStyle(Color.phormMuted)
                HStack(spacing: Spacing.xs) {
                    chip("\(dto.players.count) người")
                    chip("\(dto.rounds.count) ván")
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceElevated)
            .continuousRounded(Radius.lg)

            Text("Session đang chơi của bạn sẽ tự lưu vào History trước khi mở session này.")
                .font(.phormCaption)
                .foregroundStyle(Color.phormMuted)
                .multilineTextAlignment(.center)

            VStack(spacing: Spacing.sm) {
                Button(action: confirm) {
                    Text("Mở session này")
                        .font(.phormButton)
                        .foregroundStyle(Color.onPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.phormPrimary)
                        .continuousRounded(Radius.lg)
                }
                Button("Hủy") {
                    onDismiss(); dismiss()
                }
                .foregroundStyle(Color.phormPrimary)
            }
        }
        .padding(Spacing.lg)
        .background(.thickMaterial)
        .presentationDetents([.medium, .large])
    }

    private func chip(_ s: String) -> some View {
        Text(s)
            .font(.phormCaption)
            .foregroundStyle(Color.bodyText)
            .padding(.horizontal, Spacing.xs + 2)
            .padding(.vertical, 4)
            .background(Color.surfaceCard)
            .continuousRounded(Radius.sm)
    }

    private func confirm() {
        do {
            _ = try SessionActions.importSession(dto, in: context)
            onDismiss()
            dismiss()
        } catch {
            print("import failed: \(error)")
        }
    }
}
```

- [ ] **Step 2: Build & smoke-test on simulator**

⌘B → Build Succeeded. ⌘R.

Smoke test (single device, simulator):
1. Create session "A" with 2 players → add a round → menu → Chia sẻ → copy the `phorm://import?s=...` URL from the share sheet (use "Copy" in the share menu).
2. In Safari simulator, paste the URL into the address bar → press Go. Simulator should switch to Phorm and present ImportConfirmView with session "A"'s preview.
3. Tap "Mở session này" → import succeeds → SessionView shows session "A" (now a *copy*); the original is archived.

If the Safari → app handoff doesn't trigger, double-check Info.plist URL Types entry (Task B2).

- [ ] **Step 3: Commit**

```bash
git add phorm-ios/Phorm/Views/ImportConfirmView.swift
git commit -m "phorm-ios: ImportConfirmView with preview + import action"
```

---

## Phase M — Final verification

### Task M1: Run full test suite + manual PLAN.md checklist

**Files:** none

- [ ] **Step 1: Run all unit tests**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app/phorm-ios
xcodegen generate
xcodebuild -project phorm-ios.xcodeproj -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO test 2>&1 | tail -40
```

Expected: `** TEST SUCCEEDED **` with ~22 tests passing across AutoFill / Totals / SessionShare / SessionActions / Sanity. If any fail, fix before continuing.

- [ ] **Step 2: Walk PLAN.md §Verification (13 steps) on simulator**

PLAN.md has a numbered manual verification checklist (steps 1–13). Walk each one. Note any deviations from expected behavior in `phorm-ios/NOTES.md` (create if needed).

Critical paths to verify:
- Cold start with no session → empty state ✓
- Create 4-player session → blank SessionView ✓
- Add round (3 manual + 1 auto) → save → card appears, totals update ✓
- Sparse round (chặt heo: 2 cells balanced, 2 blank → 0 ngầm) → save with "Tổng 0 ✓" ✓
- Sparse with sum ≠ 0 → warning indicator but save still works ✓
- Edit round → totals reactively recompute ✓
- Swipe / long-press delete → card disappears, totals update ✓
- Reuse-group card on second session creation ✓
- Kết thúc → SummaryView → archive into History ✓
- History → tap → SummaryView read-only ✓
- Share URL → Safari paste → ImportConfirmView ✓
- iCloud sync (skip if only one device) — PLAN step 12 ✓
- Offline (airplane mode) — all flows still work, sync defers ✓

- [ ] **Step 3: Commit any verification notes**

If you created `phorm-ios/NOTES.md`:

```bash
git add phorm-ios/NOTES.md
git commit -m "phorm-ios: manual verification notes"
```

- [ ] **Step 4: Final sanity build for archive**

Product → Archive (or just ⌘B with Release configuration via Edit Scheme → Run → Build Configuration). Expected: Build Succeeded.

That's the MVP.

---

## Out-of-plan follow-ups (not blocking MVP ship)

- Replace placeholder app icon with proper design
- Promote CloudKit schema Development → Production (via CloudKit Console) before any TestFlight
- Consider adding a Live Activity for "ván đang chơi" (post-MVP, listed in DESIGN.md §Known Gaps)
- Tinted / Clear Home Screen icon variants (post-MVP)
