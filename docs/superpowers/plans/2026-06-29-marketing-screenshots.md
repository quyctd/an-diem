# Marketing Screenshot Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the hand-built `submission/screenshots.html` mockup with an ichi-style pipeline — real simulator screenshots of the lacquer app, composited into a real iPhone 16 Pro frame on a cream captioned card.

**Architecture:** A DEBUG-only Swift hook seeds deterministic demo data into an in-memory store and routes the app to a target screen on launch (driven by `PHORM_SEED` / `PHORM_OPEN` env vars). A capture script boots an iPhone 16 Pro simulator and grabs six screenshots autonomously. A Python/Pillow compositor frames each shot and writes App Store-sized listing PNGs.

**Tech Stack:** SwiftUI + SwiftData (iOS 17), Swift Testing, `xcrun simctl`, Python 3 + Pillow.

## Global Constraints

- App design shown is the **lacquer/serif** build-8 design (cinnabar `#8C2A22`, oxblood `#5D1A18`, gold `#D9B25A`, cream `#F3E8D2`). Do NOT restyle the app.
- All seed/route code is **`#if DEBUG` only** — zero effect on release builds. Verify exclusion.
- Card background = cream `#F3E8D2`; headline lead = cinnabar-deep `#5A1612`; accent = gold `#D9B25A`.
- Headline face = **Noto Serif Display** (vendored), not SF.
- Device frame = **Black Titanium iPhone 16 Pro**, reused from ichi.
- Capture on an **iPhone 16 Pro** simulator (screen 1206×2622) to match the frame's screen cutout.
- Outputs: 6.9" `1290×2796` (primary) + 6.5" `1242×2688` + `contact-sheet.png`.
- Six frames, hero first. Captions (lead / accent) are fixed:
  01 leaderboard `Ấn vàng` / `cho người dẫn đầu.` · 02 roundEntry `N−1 ô số.` / `Ô cuối tự cộng.` · 03 summary `Kết bàn.` / `Lưu lại.` · 04 history `Mọi phiên cũ` / `vẫn ở chỗ cũ.` · 05 newSession `Đặt tên.` / `Vào bàn ngay.` · 06 empty `Mở app` / `là chơi.`
- App bundle id: `com.quyctd.phorm`. Xcode scheme: `Phorm`. Test target: `PhormTests`.

---

### Task 1: Scaffold `marketing/` with reused frame + vendored font

**Files:**
- Create: `andiem-ios/marketing/.gitignore`
- Create: `andiem-ios/marketing/frames/Apple iPhone 16 Pro Black Titanium.png` (copied)
- Create: `andiem-ios/marketing/fonts/NotoSerifDisplay[wdth,wght].ttf` (downloaded)
- Create dirs: `andiem-ios/marketing/raw/`, `listing/iphone-6.9/`, `listing/iphone-6.5/`

**Interfaces:**
- Produces: frame PNG at `marketing/frames/Apple iPhone 16 Pro Black Titanium.png`; font at `marketing/fonts/NotoSerifDisplay[wdth,wght].ttf`. Task 3 (compositor) consumes both.

- [ ] **Step 1: Create folders**

```bash
cd andiem-ios
mkdir -p marketing/raw marketing/frames marketing/fonts marketing/listing/iphone-6.9 marketing/listing/iphone-6.5
```

- [ ] **Step 2: Reuse the device frame from ichi**

```bash
cp "/Users/dinhquy/Documents/quyctd/ichi/marketing/frames/Apple iPhone 16 Pro Black Titanium.png" \
   marketing/frames/
```

Verify it has an alpha channel (transparent screen):

```bash
sips -g hasAlpha "marketing/frames/Apple iPhone 16 Pro Black Titanium.png"
```
Expected: `hasAlpha: yes`

- [ ] **Step 3: Vendor Noto Serif Display (variable ttf)**

```bash
curl -L -o "marketing/fonts/NotoSerifDisplay[wdth,wght].ttf" \
  "https://github.com/google/fonts/raw/main/ofl/notoserifdisplay/NotoSerifDisplay%5Bwdth,wght%5D.ttf"
```
Expected: a file > 200 KB. Verify: `ls -l "marketing/fonts/NotoSerifDisplay[wdth,wght].ttf"`

- [ ] **Step 4: Keep generated output out of git but track inputs**

Create `andiem-ios/marketing/.gitignore`:

```gitignore
# Generated output — regenerate with compose_listing.py
listing/
contact-sheet.png
# Raw captures are regenerated from the app; keep them out of git too
raw/*.png
```

- [ ] **Step 5: Verify Pillow is available**

```bash
python3 -c "import PIL; print(PIL.__version__)" || python3 -m pip install --user Pillow
```
Expected: a version string prints.

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/marketing/.gitignore "andiem-ios/marketing/frames" "andiem-ios/marketing/fonts"
git commit -m "marketing: scaffold folder, reuse iPhone 16 Pro frame, vendor Noto Serif Display"
```

---

### Task 2: Pillow compositor `compose_listing.py`

**Files:**
- Create: `andiem-ios/marketing/compose_listing.py`
- Test: `andiem-ios/marketing/test_compose.py`

**Interfaces:**
- Consumes: `frames/Apple iPhone 16 Pro Black Titanium.png`, `fonts/NotoSerifDisplay[wdth,wght].ttf`, `raw/<NN-name>.png` (created by Task 6).
- Produces: `listing/iphone-6.9/NN.png` (1290×2796), `listing/iphone-6.5/NN.png` (1242×2688), `contact-sheet.png`. `make_device(screen_path, target_w)` returns an RGBA device image. The `FRAMES` list maps `shot` filename → `lead`/`pop` caption.

- [ ] **Step 1: Write the failing test**

`andiem-ios/marketing/test_compose.py` — a dependency-free self-checker (no pytest):

```python
import os, sys, subprocess
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))

def main():
    # Synthesize a stand-in "raw" screenshot for every frame the compositor expects.
    import compose_listing as C
    os.makedirs(os.path.join(ROOT, "raw"), exist_ok=True)
    for fr in C.FRAMES:
        Image.new("RGB", (1206, 2622), (0x8C, 0x2A, 0x22)).save(os.path.join(ROOT, "raw", fr["shot"]))

    subprocess.run([sys.executable, os.path.join(ROOT, "compose_listing.py")], check=True)

    one = os.path.join(ROOT, "listing", "iphone-6.9", "01.png")
    assert os.path.exists(one), "6.9 frame 01 not generated"
    assert Image.open(one).size == (1290, 2796), "wrong 6.9 size"
    assert Image.open(os.path.join(ROOT, "listing", "iphone-6.5", "01.png")).size == (1242, 2688), "wrong 6.5 size"
    assert os.path.exists(os.path.join(ROOT, "contact-sheet.png")), "contact sheet missing"
    print("OK: compose_listing produces correctly-sized frames")

if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd andiem-ios/marketing && python3 test_compose.py
```
Expected: FAIL — `ModuleNotFoundError: No module named 'compose_listing'`.

- [ ] **Step 3: Write the compositor**

`andiem-ios/marketing/compose_listing.py`:

```python
#!/usr/bin/env python3
"""Compose App Store listing frames: a two-tone serif headline over a real
iPhone 16 Pro render (frameit device PNG) with a Phorm screenshot composited in."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.abspath(__file__))
SHOTS = os.path.join(ROOT, "raw")
FRAMES_DIR = os.path.join(ROOT, "frames")
FONTS_DIR = os.path.join(ROOT, "fonts")
OUT69 = os.path.join(ROOT, "listing", "iphone-6.9")
OUT65 = os.path.join(ROOT, "listing", "iphone-6.5")
for d in (OUT69, OUT65):
    os.makedirs(d, exist_ok=True)

SERIF = os.path.join(FONTS_DIR, "NotoSerifDisplay[wdth,wght].ttf")

def font(size, weight="Bold"):
    f = ImageFont.truetype(SERIF, size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f

def hx(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

W, H = 1290, 2796  # App Store 6.9"

FRAME_FILE = "Apple iPhone 16 Pro Black Titanium.png"
SCREEN_BOX = (72, 70, 1276, 2690)   # left, top, right, bottom (frame-native px)
SCREEN_R = 96
INSET = 2
_frame_cache = {}

def load_frame():
    if FRAME_FILE not in _frame_cache:
        _frame_cache[FRAME_FILE] = Image.open(os.path.join(FRAMES_DIR, FRAME_FILE)).convert("RGBA")
    return _frame_cache[FRAME_FILE]

def round_corners(im, r):
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, im.size[0], im.size[1]], radius=r, fill=255)
    out = im.convert("RGBA")
    out.putalpha(mask)
    return out

def make_device(screen_path, target_w):
    frame = load_frame()
    fw, fh = frame.size
    sx, sy, ex, ey = SCREEN_BOX
    sw, sh = (ex - sx) - 2 * INSET, (ey - sy) - 2 * INSET
    shot = Image.open(screen_path).convert("RGB").resize((sw, sh), Image.LANCZOS)
    shot = round_corners(shot, SCREEN_R)
    dev = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    dev.alpha_composite(shot, (sx + INSET, sy + INSET))
    dev.alpha_composite(frame)
    scale = target_w / fw
    return dev.resize((target_w, round(fh * scale)), Image.LANCZOS)

# hero first; captions are locked in the plan's Global Constraints.
FRAMES = [
    dict(shot="01-leaderboard.png", lead="Ấn vàng",      pop="cho người dẫn đầu."),
    dict(shot="02-round-entry.png", lead="N−1 ô số.",    pop="Ô cuối tự cộng."),
    dict(shot="03-summary.png",     lead="Kết bàn.",     pop="Lưu lại."),
    dict(shot="04-history.png",     lead="Mọi phiên cũ", pop="vẫn ở chỗ cũ."),
    dict(shot="05-new-session.png", lead="Đặt tên.",     pop="Vào bàn ngay."),
    dict(shot="06-empty.png",       lead="Mở app",       pop="là chơi."),
]

BG  = hx("F3E8D2")   # cream card
INK = hx("5A1612")   # cinnabar-deep lead
POP = hx("D9B25A")   # gold accent

MARGIN = 104
HEAD_TOP = 170
DEVICE_W = 1130
DEV_TOP = 612
LH = 1.04

def fit_size(draw, lead, pop, maxw, hi=150, lo=82):
    for s in range(hi, lo - 1, -2):
        f = font(s, "Bold")
        if draw.textlength(lead, font=f) <= maxw and draw.textlength(pop, font=f) <= maxw:
            return s
    return lo

for i, fr in enumerate(FRAMES, 1):
    canvas = Image.new("RGBA", (W, H), BG + (255,))
    draw = ImageDraw.Draw(canvas)
    maxw = W - 2 * MARGIN

    size = fit_size(draw, fr["lead"], fr["pop"], maxw)
    hfont = font(size, "Bold")
    lh = int(size * LH)
    draw.text((MARGIN, HEAD_TOP), fr["lead"], font=hfont, fill=INK)
    draw.text((MARGIN, HEAD_TOP + lh), fr["pop"], font=hfont, fill=POP)

    dev = make_device(os.path.join(SHOTS, fr["shot"]), DEVICE_W)
    dev_x = (W - DEVICE_W) // 2

    alpha = dev.split()[3]
    sil = Image.composite(Image.new("RGBA", dev.size, (0, 0, 0, 70)),
                          Image.new("RGBA", dev.size, (0, 0, 0, 0)), alpha)
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    shadow.alpha_composite(sil, (dev_x, DEV_TOP + 30))
    shadow = shadow.filter(ImageFilter.GaussianBlur(46))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(dev, (dev_x, DEV_TOP))

    out = f"{i:02d}.png"
    rgb = canvas.convert("RGB")
    rgb.save(os.path.join(OUT69, out))
    rgb.resize((1242, 2688), Image.LANCZOS).save(os.path.join(OUT65, out))
    print("✓", out, f'{fr["lead"]} {fr["pop"]}')

# contact sheet
TH_H = 828
TH_W = round(TH_H * W / H)
GAP, PAD_CS = 18, 22
sheet_w = len(FRAMES) * TH_W + (len(FRAMES) - 1) * GAP + 2 * PAD_CS
sheet = Image.new("RGB", (sheet_w, TH_H + 2 * PAD_CS), (255, 255, 255))
for i in range(1, len(FRAMES) + 1):
    th = Image.open(os.path.join(OUT69, f"{i:02d}.png")).resize((TH_W, TH_H), Image.LANCZOS)
    sheet.paste(th, (PAD_CS + (i - 1) * (TH_W + GAP), PAD_CS))
sheet.save(os.path.join(ROOT, "contact-sheet.png"))
print("✓ contact-sheet.png")
print("\nDone →", OUT69)
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd andiem-ios/marketing && python3 test_compose.py
```
Expected: `OK: compose_listing produces correctly-sized frames`.

- [ ] **Step 5: Eyeball the synthetic output**

Open `andiem-ios/marketing/contact-sheet.png` — six cream cards, black device frames, serif two-tone captions (lead ink + gold accent), solid-cinnabar placeholder screens. Confirms framing before real captures exist.

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/marketing/compose_listing.py andiem-ios/marketing/test_compose.py
git commit -m "marketing: Pillow compositor (cream card, serif two-tone, reused frame)"
```

---

### Task 3: Demo-data seeder (`ScreenshotSupport.swift`)

**Files:**
- Create: `andiem-ios/Phorm/Logic/ScreenshotSupport.swift`
- Test: `andiem-ios/PhormTests/ScreenshotSupportTests.swift`

**Interfaces:**
- Produces (all `#if DEBUG`): enum `ScreenshotScreen { case leaderboard, roundEntry, summary, history, newSession, empty }`; `ScreenshotSupport.openTarget: ScreenshotScreen?` (reads `PHORM_OPEN`); `ScreenshotSupport.seedRequested: Bool` (reads `PHORM_SEED == "demo"`); `ScreenshotSupport.seed(into context: ModelContext, activeSession: Bool)`. Task 4 consumes `seedRequested`/`seed`; Task 5 consumes `openTarget`.

- [ ] **Step 1: Write the failing test**

`andiem-ios/PhormTests/ScreenshotSupportTests.swift`:

```swift
import Testing
import SwiftData
@testable import Phorm

@MainActor
@Suite("ScreenshotSupport")
struct ScreenshotSupportTests {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test func seedWithActiveSessionCreatesPopulatedLeaderboard() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        ScreenshotSupport.seed(into: ctx, activeSession: true)

        let active = try ctx.fetch(FetchDescriptor<Session>(predicate: #Predicate { $0.archivedAt == nil }))
        #expect(active.count == 1)
        let s = active[0]
        #expect(s.playerNames == ["Quý", "Nam", "Linh", "Hoàng"])
        #expect((s.rounds ?? []).count == 6)

        // Deterministic leader is Quý, last is Hoàng.
        let ranking = Totals.ranking(for: s)
        #expect(ranking.first?.name == "Quý")
        #expect(ranking.last?.name == "Hoàng")

        // Archived sessions exist for History.
        let archived = try ctx.fetch(FetchDescriptor<Session>(predicate: #Predicate { $0.archivedAt != nil }))
        #expect(archived.count >= 3)
    }

    @Test func seedWithoutActiveSessionLeavesEmptyHome() throws {
        let container = try Self.makeContainer()
        let ctx = container.mainContext
        ScreenshotSupport.seed(into: ctx, activeSession: false)

        let active = try ctx.fetch(FetchDescriptor<Session>(predicate: #Predicate { $0.archivedAt == nil }))
        #expect(active.isEmpty)
        let archived = try ctx.fetch(FetchDescriptor<Session>(predicate: #Predicate { $0.archivedAt != nil }))
        #expect(archived.count >= 3)
    }
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd andiem-ios && xcodebuild test -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:PhormTests/ScreenshotSupport 2>&1 | tail -20
```
Expected: build failure — `cannot find 'ScreenshotSupport' in scope`.

- [ ] **Step 3: Write the seeder**

`andiem-ios/Phorm/Logic/ScreenshotSupport.swift`:

```swift
#if DEBUG
import Foundation
import SwiftData

/// Screens the screenshot harness can launch directly into (PHORM_OPEN).
enum ScreenshotScreen: String {
    case leaderboard, roundEntry, summary, history, newSession, empty
}

/// DEBUG-only launch hooks for autonomous App Store screenshot capture.
/// Driven by `PHORM_SEED=demo` and `PHORM_OPEN=<screen>` launch env vars.
enum ScreenshotSupport {
    static var seedRequested: Bool {
        ProcessInfo.processInfo.environment["PHORM_SEED"] == "demo"
    }

    static var openTarget: ScreenshotScreen? {
        ProcessInfo.processInfo.environment["PHORM_OPEN"].flatMap(ScreenshotScreen.init)
    }

    /// Targets that should NOT have an active session (so EmptyHomeView shows).
    static var wantsEmptyHome: Bool {
        switch openTarget {
        case .empty, .newSession: return true
        default: return false
        }
    }

    /// Insert deterministic demo data. `activeSession` controls whether a current
    /// (unarchived) session exists — false routes the app to EmptyHomeView.
    static func seed(into context: ModelContext, activeSession: Bool) {
        let players = ["Quý", "Nam", "Linh", "Hoàng"]
        // Per-round scores: columns sum to 0 each round; Quý leads, Hoàng trails.
        let perRound: [[Int]] = [
            [ 4, -1, -1, -2],
            [-2,  6, -1, -3],
            [ 3, -1,  2, -4],
            [ 5, -2, -1, -2],
            [-1,  3,  1, -3],
            [ 2, -1, -2,  1],
        ]

        if activeSession {
            let s = Session(name: "Phỏm tối thứ Sáu", createdAt: .now, playerNames: players)
            context.insert(s)
            for (i, row) in perRound.enumerated() {
                let r = Round(index: i + 1)
                r.session = s
                context.insert(r)
                for (p, v) in zip(players, row) {
                    let ps = PlayerScore(playerName: p, value: v)
                    ps.round = r
                    context.insert(ps)
                }
            }
        }

        // Archived sessions for History — deterministic dates relative to a fixed anchor.
        let anchor = Date(timeIntervalSince1970: 1_716_000_000) // 2024-05-18, stable
        let archived: [(String, [String], Int)] = [
            ("Sâm Lốc nhà Hoàng", ["Quý", "Hoàng", "Mai"], 7),
            ("Cafe sau giờ làm",   ["Nam", "Linh", "Trang", "Quý"], 14),
            ("Sinh nhật Linh",     ["Linh", "Quý", "Nam", "Mai", "Trang"], 21),
            ("Tất niên xóm",       ["An", "Bình", "Cường", "Dũng"], 28),
        ]
        for (name, names, daysAgo) in archived {
            let created = anchor.addingTimeInterval(Double(-daysAgo) * 86_400)
            let s = Session(name: name, createdAt: created, archivedAt: created.addingTimeInterval(7200), playerNames: names)
            context.insert(s)
            let r = Round(index: 1)
            r.session = s
            context.insert(r)
            // simple closed round so totals render
            var vals = Array(repeating: -2, count: names.count)
            vals[0] = (names.count - 1) * 2
            for (p, v) in zip(names, vals) {
                let ps = PlayerScore(playerName: p, value: v)
                ps.round = r
                context.insert(ps)
            }
        }
        try? context.save()
    }
}
#endif
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd andiem-ios && xcodebuild test -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:PhormTests/ScreenshotSupport 2>&1 | tail -20
```
Expected: `Test Suite 'ScreenshotSupport' passed`.

- [ ] **Step 5: Commit**

```bash
git add andiem-ios/Phorm/Logic/ScreenshotSupport.swift andiem-ios/PhormTests/ScreenshotSupportTests.swift
git commit -m "feat(debug): ScreenshotSupport demo seeder for screenshot capture"
```

---

### Task 4: Wire `PHORM_SEED` into the app container

**Files:**
- Modify: `andiem-ios/Phorm/PhormApp.swift`

**Interfaces:**
- Consumes: `ScreenshotSupport.seedRequested`, `ScreenshotSupport.wantsEmptyHome`, `ScreenshotSupport.seed(into:activeSession:)` from Task 3.
- Produces: a DEBUG build where `PHORM_SEED=demo` boots into an in-memory store populated with demo data.

- [ ] **Step 1: Replace the `init()` container setup**

In `andiem-ios/Phorm/PhormApp.swift`, replace the body of `init()` (lines 11-23) with:

```swift
    init() {
        let schema = Schema([Session.self, Round.self, PlayerScore.self])
        #if DEBUG
        if ScreenshotSupport.seedRequested {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            do {
                let c = try ModelContainer(for: schema, configurations: [config])
                ScreenshotSupport.seed(into: c.mainContext, activeSession: !ScreenshotSupport.wantsEmptyHome)
                container = c
                return
            } catch {
                fatalError("Screenshot seed container failed: \(error)")
            }
        }
        #endif
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }
```

- [ ] **Step 2: Hide the splash when seeding (it would cover the screenshot)**

In `PhormApp.swift`, change the splash state declaration:

```swift
    @State private var showSplash = true
```
to:

```swift
    #if DEBUG
    @State private var showSplash = !ScreenshotSupport.seedRequested
    #else
    @State private var showSplash = true
    #endif
```

- [ ] **Step 3: Build for simulator to verify it compiles**

```bash
cd andiem-ios && xcodebuild build -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Manual smoke — seeded launch shows the leaderboard**

```bash
SIM="iPhone 16 Pro"
xcrun simctl boot "$SIM" 2>/dev/null || true
APP=$(find ~/Library/Developer/Xcode/DerivedData -name Phorm.app -path "*Debug-iphonesimulator*" | head -1)
xcrun simctl install "$SIM" "$APP"
SIMCTL_CHILD_PHORM_SEED=demo xcrun simctl launch "$SIM" com.quyctd.phorm
sleep 3
xcrun simctl io "$SIM" screenshot /tmp/seed-check.png
```
Open `/tmp/seed-check.png` — expect the populated SessionView (Quý leading, four players), no splash.

- [ ] **Step 5: Commit**

```bash
git add andiem-ios/Phorm/PhormApp.swift
git commit -m "feat(debug): seed in-memory store + skip splash when PHORM_SEED set"
```

---

### Task 5: `PHORM_OPEN` routing hooks

**Files:**
- Modify: `andiem-ios/Phorm/Views/SessionView.swift`
- Modify: `andiem-ios/Phorm/Views/EmptyHomeView.swift`

**Interfaces:**
- Consumes: `ScreenshotSupport.openTarget` from Task 3.
- Produces: launching with `PHORM_OPEN=<screen>` lands on that screen. `leaderboard` needs no routing (default). `roundEntry`/`summary`/`history` route from SessionView; `newSession` routes from EmptyHomeView; `empty` shows EmptyHomeView with no action.

- [ ] **Step 1: Add programmatic destinations + route state to SessionView**

In `SessionView.swift`, add two `@State` flags next to the existing ones (after line 11):

```swift
    @State private var showSummaryRoute = false
    @State private var showHistoryRoute = false
```

Add navigation destinations — place alongside the existing `.sheet` modifiers (after line 108):

```swift
        .navigationDestination(isPresented: $showSummaryRoute) {
            SummaryView(session: session)
        }
        .navigationDestination(isPresented: $showHistoryRoute) {
            HistoryView()
        }
```

Add the DEBUG route hook — attach `.onAppear` to the root view of `SessionView` (the outermost container in `body`, same level as `.lacquerBackground()` on line 70):

```swift
        #if DEBUG
        .onAppear {
            switch ScreenshotSupport.openTarget {
            case .roundEntry: showRoundEntry = true
            case .summary:    showSummaryRoute = true
            case .history:    showHistoryRoute = true
            default:          break
            }
        }
        #endif
```

- [ ] **Step 2: Add the newSession route hook to EmptyHomeView**

In `EmptyHomeView.swift`, attach to the root view (same level as the existing `.sheet`/`.navigationDestination` on lines 60-64):

```swift
        #if DEBUG
        .onAppear {
            if ScreenshotSupport.openTarget == .newSession { showNewSession = true }
        }
        #endif
```

- [ ] **Step 3: Build to verify it compiles**

```bash
cd andiem-ios && xcodebuild build -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Manual smoke — route to round entry**

```bash
SIM="iPhone 16 Pro"
APP=$(find ~/Library/Developer/Xcode/DerivedData -name Phorm.app -path "*Debug-iphonesimulator*" | head -1)
xcrun simctl install "$SIM" "$APP"
xcrun simctl terminate "$SIM" com.quyctd.phorm 2>/dev/null || true
SIMCTL_CHILD_PHORM_SEED=demo SIMCTL_CHILD_PHORM_OPEN=roundEntry xcrun simctl launch "$SIM" com.quyctd.phorm
sleep 3
xcrun simctl io "$SIM" screenshot /tmp/route-check.png
```
Open `/tmp/route-check.png` — expect the RoundEntry sheet with keypad.

- [ ] **Step 5: Commit**

```bash
git add andiem-ios/Phorm/Views/SessionView.swift andiem-ios/Phorm/Views/EmptyHomeView.swift
git commit -m "feat(debug): PHORM_OPEN routing to each capture screen"
```

---

### Task 6: Autonomous capture script

**Files:**
- Create: `andiem-ios/marketing/capture.sh`

**Interfaces:**
- Consumes: the DEBUG app (Tasks 4-5), `PHORM_SEED`/`PHORM_OPEN` hooks.
- Produces: `marketing/raw/{01-leaderboard,02-round-entry,03-summary,04-history,05-new-session,06-empty}.png` — the compositor's input (Task 2 `FRAMES` filenames).

- [ ] **Step 1: Write the capture script**

`andiem-ios/marketing/capture.sh`:

```bash
#!/usr/bin/env bash
# Capture all six App Store raw screenshots autonomously (no hand-driving).
# Builds the DEBUG app, boots an iPhone 16 Pro sim, and launches once per screen
# via PHORM_SEED/PHORM_OPEN, screenshotting each.
set -euo pipefail

SIM_NAME="${PHORM_SIM:-iPhone 16 Pro}"
BUNDLE_ID="com.quyctd.phorm"
DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(cd "$DIR/.." && pwd)"
RAW="$DIR/raw"; mkdir -p "$RAW"

# screen key -> raw filename (must match compose_listing.py FRAMES)
SCREENS=(
  "leaderboard:01-leaderboard.png"
  "roundEntry:02-round-entry.png"
  "summary:03-summary.png"
  "history:04-history.png"
  "newSession:05-new-session.png"
  "empty:06-empty.png"
)

echo "Booting $SIM_NAME…"
xcrun simctl boot "$SIM_NAME" 2>/dev/null || true
open -a Simulator

echo "Building DEBUG Phorm…"
xcodebuild build -scheme Phorm \
  -destination "platform=iOS Simulator,name=$SIM_NAME" \
  -derivedDataPath "$IOS_DIR/build" CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
APP=$(find "$IOS_DIR/build/Build/Products" -name Phorm.app -path "*Debug-iphonesimulator*" | head -1)
xcrun simctl install "$SIM_NAME" "$APP"

# 9:41, full battery/signal — clean status bar
xcrun simctl status_bar "$SIM_NAME" override \
  --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3

for entry in "${SCREENS[@]}"; do
  key="${entry%%:*}"; file="${entry##*:}"
  xcrun simctl terminate "$SIM_NAME" "$BUNDLE_ID" 2>/dev/null || true
  SIMCTL_CHILD_PHORM_SEED=demo SIMCTL_CHILD_PHORM_OPEN="$key" \
    xcrun simctl launch "$SIM_NAME" "$BUNDLE_ID" >/dev/null
  sleep 3
  xcrun simctl io "$SIM_NAME" screenshot "$RAW/$file"
  echo "✓ $file"
done

echo "Done → $RAW"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x andiem-ios/marketing/capture.sh
```

- [ ] **Step 3: Commit**

```bash
git add andiem-ios/marketing/capture.sh
git commit -m "marketing: autonomous capture.sh (seed + route + screenshot all 6)"
```

---

### Task 7: End-to-end run, README, retire old HTML

**Files:**
- Create: `andiem-ios/marketing/README.md`
- Delete: `submission/screenshots.html`, `submission/screenshots/`

**Interfaces:**
- Consumes: Tasks 1-6.
- Produces: real `listing/` frames + `contact-sheet.png`; the old HTML pipeline removed.

- [ ] **Step 1: Capture the real screenshots**

```bash
cd andiem-ios && ./marketing/capture.sh
```
Expected: six `✓` lines; `marketing/raw/` holds 6 PNGs at 1206×2622. Spot-check one: `sips -g pixelWidth -g pixelHeight marketing/raw/01-leaderboard.png`.

- [ ] **Step 2: Compose the listing from real shots**

```bash
cd andiem-ios/marketing && python3 compose_listing.py
```
Expected: six `✓ NN.png` lines + `✓ contact-sheet.png`.

- [ ] **Step 3: Verify the result**

Open `andiem-ios/marketing/contact-sheet.png`. Confirm: real lacquer screens legible inside black device frames, cream cards, serif two-tone captions, status bar reads 9:41, device bleeds off the bottom. Compare against `/Users/dinhquy/Documents/quyctd/ichi/marketing/contact-sheet.png` for parity of polish. If a caption overflows or a screen is wrong, fix `FRAMES`/seed and re-run before continuing.

- [ ] **Step 4: Write the README**

`andiem-ios/marketing/README.md`:

```markdown
# Marketing assets

App Store listing screenshots for Phorm — real app screenshots framed in a real
iPhone 16 Pro render with a captioned cream card.

- `listing/iphone-6.9/` — final 1290×2796 (App Store 6.9", primary set)
- `listing/iphone-6.5/` — final 1242×2688 (6.5", completeness)
- `contact-sheet.png` — all six at a glance
- `raw/` — clean simulator screenshots (input), regenerated by `capture.sh`
- `frames/` — real iPhone 16 Pro render (frameit-frames, transparent screen)
- `fonts/` — vendored Noto Serif Display (caption face)
- `compose_listing.py` — composites `raw/` into the device render with a captioned card
- `capture.sh` — boots an iPhone 16 Pro sim and captures all six screens autonomously

## Regenerate

```sh
./marketing/capture.sh            # capture raw/*.png from the app (DEBUG seed+route)
python3 marketing/compose_listing.py   # → listing/ + contact-sheet.png
```

Captures use the app's DEBUG-only `PHORM_SEED=demo` (in-memory demo data) and
`PHORM_OPEN=<screen>` (route on launch) hooks in `Phorm/Logic/ScreenshotSupport.swift`.
Edit captions/order in the `FRAMES` list inside `compose_listing.py`.
```

- [ ] **Step 5: Retire the old HTML pipeline**

```bash
cd /Users/dinhquy/Documents/quyctd/saam-app
git rm -r submission/screenshots.html submission/screenshots
```

- [ ] **Step 6: Commit**

```bash
git add andiem-ios/marketing/README.md
git commit -m "marketing: README + retire HTML mockup pipeline; real ichi-style frames"
```

---

## Notes for the executor

- The compositor's `SCREEN_BOX`/`SCREEN_R` are measured for ichi's exact frame PNG; since we reuse that same PNG, they transfer unchanged. If you ever swap the frame, re-measure per the README in ichi.
- If `iPhone 16 Pro` isn't an installed simulator, set `PHORM_SIM` to one that is (e.g. `PHORM_SIM="iPhone 16 Pro" ./marketing/capture.sh`) — but keep it a non-Max Pro so the 1206×2622 screen matches the frame cutout.
- Demo seed values are deterministic on purpose (stable screenshots across runs). Don't introduce randomness.
```
