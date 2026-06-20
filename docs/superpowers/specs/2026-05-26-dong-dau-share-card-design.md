# Đóng dấu — share card feature design

**Date:** 2026-05-26
**Owner:** quyctd
**Status:** Design locked, not yet implemented
**Visual reference:** [`themes-preview.html`](../../../themes-preview.html) — section "Đóng dấu" (frames F1–F5). The composition, typography, animation, color, and Vietnamese copy on that page **are the visual contract**. This document only specifies what is NOT visible in that mockup: data model, behavior logic, technical decisions, edge cases.

## Context

This is the first post-MVP feature for the iOS app already shipped (per recent commits `2522e80`, `402df90`). PLAN.md's `Out of scope (MVP)` listed "Image export bảng điểm" — this feature delivers a richer version of that, leaning on the Hà Nội cũ visual identity already in code.

The brainstorming decision was made over multiple rounds:
- **Reject** generic image export / cover-photo journal / lifetime stats as v2 features.
- **Reject** Vision-based face detection (privacy + scope creep).
- **Reject** auto-fire share after second tap (loses user agency).
- **Reject** auto-prompt photo on session end (forecloses ranking-first moment).
- **Reject** native iOS action sheet for source picker (visual whiplash on lacquer surface; precedent: commit `c39104b: phorm-ios: render sheets on cinnabar instead of system Material`).

## What is locked

| # | Decision | Source |
|---|---|---|
| 1 | **One photo, two taps** — group photo + manual tap winner face + manual tap loser face | Brainstorming round 3 |
| 2 | **Manual tap, no Vision** (Option A) — seal lands at exact tap point | User decision |
| 3 | **Camera AND library** as source options | User requirement |
| 4 | **Source picker is a custom lacquer bottom sheet**, not iOS-native action sheet | Per c39104b precedent |
| 5 | **9:16 export aspect** with center 56% safe-zone for square (Locket) crop | Design contract |
| 6 | **One render, every platform** — Locket, Instagram, Reels, TikTok, Zalo, Messenger | One file, no per-platform regeneration |
| 7 | **Photo optional** — share card always renders, with-or-without photo | Skip path never gated |
| 8 | **Edit happens before "Lưu & chia sẻ"** — not after, except via re-open from History | Single review checkpoint |
| 9 | **Store inputs, render output on demand** | Storage / CloudKit pressure |

## Data model

Add to existing `Session` `@Model`:

```swift
@Model class Session {
    // ... existing fields ...

    // New: Đóng dấu state. All three optional. nil = not yet stamped.
    var coverPhoto: Data?                   // JPEG ≤ 500KB, longest edge 1080px, EXIF-normalized
    var winnerSealCoord: SealCoord?         // normalized 0-1 within coverPhoto
    var loserCrossCoord: SealCoord?         // normalized 0-1 within coverPhoto
}

struct SealCoord: Codable {                 // Encodable struct, stored as JSON via @Attribute(.externalStorage) or transformable
    var x: Double                           // 0 = left edge of photo, 1 = right edge
    var y: Double                           // 0 = top, 1 = bottom
}
```

**Rationale for storing inputs, not the composed image:**

| Aspect | Store inputs (chosen) | Store output |
|---|---|---|
| Storage / session | ≤ 500KB | 2–5× larger (composed render is bigger than source photo) |
| Theme-swap | Old sessions render new lacquer if design evolves | Frozen at render-time |
| Re-edit | Cheap (recompose) | Requires either re-stamping or storing inputs too |
| Share latency | ~50ms ImageRenderer pass | ~5ms (cached) |

50ms re-render is invisible on share tap (Share sheet animation hides it). Storage matters more for CloudKit sync (1MB per CKRecord limit, though `Data` fields use external blob storage above ~10KB).

**Coordinate semantics:**
- `(0, 0)` is photo top-left, `(1, 1)` is photo bottom-right. Independent of display crop.
- nil = "not stamped" — render skips that overlay on the share canvas. The seal still appears in the ranking strip below the photo.
- For "photographer not in frame" case: user taps "Bỏ qua mặt" on the prompt (new affordance — see Edge Cases) → coord stays nil.

## Photo processing pipeline

When user selects/captures a photo:

1. **Normalize orientation.** Apply EXIF rotation to pixel data via `CGImage` / `UIImage.fixedOrientation()`. Many camera photos are stored sideways with rotation metadata; if not normalized, tap coords end up wrong on rendered output.
2. **Downscale.** Resize so longest edge = 1080px (matches export resolution). Smaller photos passed through unchanged.
3. **Compress.** JPEG quality 0.82. Empirically halves file size vs 0.95 with imperceptible quality loss for these use cases.
4. **Persist.** Assign to `session.coverPhoto`.

A helper `ImageHelpers.normalizeForStamp(_ image: UIImage) -> Data` encapsulates all four steps.

## Rendering pipeline

The 9:16 share card is composed via SwiftUI + `ImageRenderer`:

```swift
@MainActor
func renderShareCard(session: Session) -> UIImage? {
    let view = ShareCardView(session: session)
        .frame(width: 1080, height: 1920)
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1.0    // proposedSize is already at export resolution
    return renderer.uiImage
}
```

`ShareCardView` reuses the same Hà Nội tokens (cinnabar, gold, cream, Noto Serif Display, IBM Plex Serif) already defined in the Theme layer. **No new design tokens introduced.**

Render is invoked synchronously on the share tap; SwiftUI `ImageRenderer` runs on the main thread. For 1080×1920 with a single embedded `UIImage` it completes in ~30–80ms on iPhone 14+. Acceptable.

## Sharing

Wrap the rendered `UIImage` in a `Transferable` and use SwiftUI's `ShareLink`:

```swift
struct StampedShareCard: Transferable {
    let image: UIImage
    let session: Session

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { card in
            card.image.jpegData(compressionQuality: 0.92) ?? Data()
        }
        .suggestedFileName { "an-diem-\($0.session.shortName).jpg" }
    }
}
```

iOS share sheet automatically lists all installed apps with image-receivable extensions (Zalo, Messenger, Instagram, Locket, TikTok, etc.). No per-app integration needed.

## File structure additions (`phorm-ios/Phorm/`)

```
Phorm/
├── Models/
│   └── Session.swift                    [MODIFY] — add stamp fields
├── Views/
│   ├── Summary/
│   │   └── SummaryView.swift            [MODIFY] — add dashed callout + Đóng dấu CTA
│   └── Stamp/                           [NEW]
│       ├── StampFlowView.swift          coordinator: picker → tap → review → share
│       ├── StampSourcePicker.swift      F2 (lacquer bottom sheet)
│       ├── StampOnPhotoView.swift       F3/F4 (full-bleed photo + tap-to-seal)
│       └── ShareCardView.swift          F5 (9:16 canvas, used by ImageRenderer)
├── Utilities/
│   └── ImageHelpers.swift               [NEW] — EXIF fix, downscale, JPEG compress
└── Actions/
    └── SessionActions.swift             [MODIFY] — add `stampSession`, `clearStamp`
```

Existing pattern from spec `2026-05-25-phorm-ios-implementation-design.md` §3-4: views never call `modelContext` directly — go through `SessionActions`. Same applies for stamp mutations.

## iOS native pieces

| Function | API |
|---|---|
| Camera capture | `UIImagePickerController` with `sourceType = .camera` via `UIViewControllerRepresentable` wrapper. Modern alternative `AVFoundation` is overkill for one snap. |
| Library selection | `PhotosPicker` (SwiftUI, iOS 16+) — no `NSPhotoLibraryUsageDescription` needed |
| Share sheet | `ShareLink(item:)` with `Transferable` |
| Image rendering | `ImageRenderer` (iOS 16+) |
| EXIF normalize | `CGImage.fixedOrientation` extension |

## Permissions (Info.plist)

Add:
```xml
<key>NSCameraUsageDescription</key>
<string>Phorm dùng camera để chụp ảnh đóng dấu cuối phiên.</string>
```

Do NOT add `NSPhotoLibraryUsageDescription` — `PhotosPicker` is limited-permission by design.

## Edge cases

### E1. Photographer not in frame
The winner (or loser) is the one holding the phone and isn't in the group photo.
- On F3/F4, add a small tertiary action: *"Không có trong ảnh"* below the prompt.
- Tapping it leaves the corresponding coord nil and advances to the next prompt (or to F4-final if both are skipped).
- Render: seal/× still appears in the ranking strip; just no face overlay.
- This is "lore của ai cầm máy" — acceptable, no selfie fallback.

### E2. No-photo path
User taps `Bỏ qua` on F1 → skip to F5 directly.
- `ShareCardView` detects `session.coverPhoto == nil` → photo zone replaced with a centered ornamental block:
  - Large 印 seal (140pt, gold) center
  - Below: session title in italic Noto Serif Display
  - Ranking strip below unchanged
- Result: still a sharable 9:16 lacquer card, no photo. Purely additive feature.

### E3. Re-edit
User opens Summary again (active session or from History) on a session that has been stamped.
- Photo + seals visible in the dashed callout slot (now showing "Đã đóng dấu" + thumbnail).
- Tap photo → re-opens StampOnPhotoView with existing seals → can:
  - Drag a seal to reposition (gesture: pan)
  - Long-press a seal to clear (with confirm)
  - Tap "Đổi ảnh" → re-opens source picker → new photo replaces, seals reset
- Tap "Lưu & chia sẻ" → re-renders + opens share sheet again.

### E4. EXIF orientation
A photo taken in portrait but with metadata flag for rotation will tap-coord wrong if not normalized. Step 1 of photo processing pipeline handles this.

### E5. Player count edge cases
- **2 players:** winner = #1, loser = #2. Both prompted normally.
- **3 players:** winner = #1, loser = #3. #2 not stamped.
- **5+ players:** still only #1 and #last get stamps. Middle ranks ignored for seals (kept in ranking strip).
- **Tie at first or last:** rank ties are not handled by current Session model anyway; skip Đóng dấu disabled with explanatory caption *"Phiên có tổng bằng nhau, không xác định vô địch/cuối bàn"*.

### E6. Storage growth
With CloudKit sync, each session now carries ~500KB of photo data. For a heavy user (1000 sessions over years) this is ~500MB. CloudKit free tier gives 5GB per user — comfortable headroom. Add a setting *"Xóa ảnh phiên cũ"* in a later release if needed; not MVP-of-feature.

### E7. Re-stamping clears old share output cache
N/A under chosen architecture (Option A: no cached output). If we ever cache, invalidate on stamp mutation.

## Acceptance criteria

A reviewer should be able to verify each item in <5 minutes on a real iPhone:

1. Open an existing session → end it → SummaryView shows ranking + dashed-gold callout + "Đóng dấu" button (gold primary, F1 in mockup).
2. Tap "Đóng dấu" → lacquer bottom sheet rises with drag handle, two source tiles (Chụp ngay gold-outlined, Thư viện cream-outlined), Hủy text below.
3. Tap "Chụp ngay" → iOS camera capture appears; tap "Thư viện" → PhotosPicker grid appears.
4. After photo selected → full-bleed photo screen with bottom prompt "Chạm vào [Winner]", pulsing gold target ring near the expected face area, 1/2 counter top-right.
5. Tap photo → gold seal lands at tap point, rotated −7°, 700ms stamp-in animation.
6. Prompt updates to "Chạm vào [Loser]", counter shows 2/2.
7. Tap photo → cream × cross lands at tap point, rotated 4°, animation.
8. Bottom shows side-by-side caption strip (winner name+score, loser name+score) + "Đổi" outline + "Lưu & chia sẻ" gold primary.
9. Tap "Lưu & chia sẻ" → ImageRenderer composes 9:16 card → iOS share sheet appears with Image content + filename `an-diem-<session>.jpg`.
10. Share to AirDrop / save to Photos → file is exactly 1080×1920 JPEG with the lacquer composition matching F5.
11. Cropped 1:1 from the export → still shows photo + both seals + 印 corner ornament (safe-zone test).
12. Re-open the session via History → SummaryView shows the photo thumb + "Đã đóng dấu" — tap re-enters StampOnPhotoView with seals already placed.
13. **No-photo path:** new session, tap "Bỏ qua" on F1 → tap "Chia sẻ" elsewhere (e.g., header) → share card renders with ornamental 印 block instead of photo zone, ranking + footer present.
14. **Photographer-not-in-frame path:** in F3, tap "Không có trong ảnh" → seal skipped → ranking row for that player still shows the seal mark next to their name.
15. **Edge case rank ties:** create a session where two players have equal final totals → tap "Đóng dấu" → callout disabled with explanatory caption.
16. CloudKit sync: stamp on iPhone → wait → open same session on iPad → photo + seals appear with no further action.

## Out of scope for this feature

These are deliberately deferred to future work:
- Multiple photos per session (one cover photo, one moment)
- Photo annotations / round-specific notes (separate journal feature)
- Player avatars / face matching across sessions
- Sticker variants beyond ấn vàng + tem chéo (locked: those are the only two)
- Custom share card templates / theming
- Video export (Reels-style animated)
- Settlement / money calculation (separate feature on its own roadmap)
- Lifetime stats (separate feature)
- Vision face detection (rejected: Option A locked)

## Open questions for implementer

These should be answered before writing code, but don't block design lock:

1. **PhotosPicker filter:** restrict to `.images` only (not `.videos`)? Yes — locked.
2. **Camera UI:** custom-styled with lacquer overlay, or use `UIImagePickerController` defaults? Defaults are fine — capture is brief and exits back to the lacquer app immediately. Don't over-design.
3. **Animation timing on the 700ms stamp-in:** matches the existing `h-stamp-in` keyframes in themes-preview.html. Mirror this in Swift with `withAnimation(.spring(response: 0.7, dampingFraction: 0.6))`.
4. **Drag-to-reposition seal:** debounce on release. Don't update SwiftData mid-drag.
5. **iPad layout:** out of scope. Run as universal but no layout optimization.
