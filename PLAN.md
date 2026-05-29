# Phỏm/Sâm Score Tracker — iOS native app

## Context

Personal-use app để ghi điểm khi chơi bài (Phỏm/Sâm Lốc/bất kỳ) tại bàn vật lý. Mục tiêu: 1 chủ trò cầm 1 phone ghi điểm sau mỗi ván, không cần internet, không cần đăng nhập, mở app là chơi. Đã từng có bản web PWA (repo này) nhưng quyết định làm lại từ đầu dưới dạng **native iOS Swift** trong **repo riêng** để tối ưu trải nghiệm + tận dụng iCloud sync giữa các thiết bị riêng.

Vấn đề muốn giải: tránh nhẩm tổng trong đầu giữa ván, tránh cãi nhau "tao ăn mày bao nhiêu", giữ lại lịch sử để cuối buổi tính tiền nhanh — không phải để dạy app luật chơi.

## 3 nguyên tắc nền

1. **Offline-first** — chạy hoàn toàn không cần mạng. iCloud sync là background bonus.
2. **Fast** — mở app là chơi. Mỗi ván chỉ gõ N-1 số (auto-fill ô cuối).
3. **No onboarding** — không signup, không tutorial, không setting bắt buộc. Defaults tốt sẵn.

## Quyết định UX (chốt)

| # | Quyết định | Detail |
|---|---|---|
| 1 | **Dumb tracker** | Gõ điểm thuần cho từng người mỗi ván, app cộng dồn. Không hiểu luật, không "smart scorer" với móm/ù/thối. |
| 2 | **1 device + iCloud** | Pure offline single-device, nhưng SwiftData + CloudKit sync giữa các thiết bị cùng Apple ID (free, 0 onboarding). Không multi-user collab. |
| 3 | **Share = URL handoff** | Share session bằng URL có encoded state. Người nhận click → confirm import → session cũ tự archive. Không cần backend. Không có image export. |
| 4 | **Startup**: vào thẳng | App mở → có session active → bảng điểm hiện luôn (0 tap). Chưa có → 1 nút to "Tạo session mới" + icon History ở góc. |
| 5 | **Players**: autosuggest | Tạo session: hiển thị nhóm session gần nhất với chip "Dùng lại" 1-tap. Hoặc gõ tên có autocomplete từ history. Không có màn "Quản lý người chơi" riêng. Player = string, không có entity. |
| 6 | **Players locked** | List player cố định khi tạo session. Muốn thay = kết thúc, tạo mới. |
| 7 | **Round entry: smart auto-fill** | Mỗi ô default placeholder `0` mờ. **Ô trống = 0 ngầm**. Auto-fill chỉ kích hoạt khi N-1 ô đã gõ → ô cuối hiển thị suggested value mờ italic. Footer sum live indicator (xanh `Tổng: 0 ✓` / cam `Tổng: -3 ⚠`). Tap Lưu cho phép sum ≠ 0 với warning nhẹ. **Hệ quả**: chặt heo 2 người = chỉ gõ 2 ô (payer & receiver), rest = 0 tự động. Không force zero-sum. |
| 8 | **Custom keypad** | App tự vẽ keypad dưới đáy entry sheet, có ±, Next, ⌫. Không dùng system keyboard. |
| 9 | **Edit tự do** | Tap row ván cũ → sửa inline. Swipe-to-delete có confirm. Tổng tự tính lại. |
| 10 | **Layout R1**: round cards | Top: chip tổng từng người scroll ngang. Body: list ván mới-trên-cùng (mỗi ván 1 card, scroll dọc). FAB "+ Ván" sticky → full-screen entry sheet. |
| 11 | **End-of-session**: leaderboard | Bấm "Kết thúc" hoặc tạo session mới → màn Tổng kết: ranking, tổng, số ván, MVP/loser. Không có money/settlement. |
| 12 | **Session naming**: auto + editable | Default = timestamp "24/05/2026 19:30". Tap header để sửa. |
| 13 | **URL receive flow** | Click link → màn confirm "Nhận session X (Y người, Z ván) từ ai đó. [Mở] [Hủy]". Mở = save + activate, session active cũ auto-archive. |
| 14 | **Không game type label** | Generic. Muốn phân biệt Phỏm/Sâm → nhét vào tên session. |

## Tech stack

- **Repo**: iOS code lives in `./andiem-ios/` subfolder of this repo (one git history for spec + code; decision logged in `docs/superpowers/specs/2026-05-25-andiem-ios-implementation-design.md`)
- **Platform**: iOS native, target **iOS 17+** (để dùng SwiftData)
- **UI**: SwiftUI (không UIKit)
- **Storage**: SwiftData với CloudKit container → tự sync iCloud
- **Share**: `ShareLink` SwiftUI → bung share sheet hệ thống (có AirDrop)
- **URL handoff**: custom URL scheme (vd: `phorm://import?s=<base64>`) + `.onOpenURL` listener
- **Encoding**: session state → JSON → gzip → base64 url-safe → URL parameter
- **Min iPad support**: nice-to-have (SwiftUI universal), không phải MVP requirement

## Data model (sketch SwiftData)

```swift
@Model class Session {
    var id: UUID
    var name: String              // auto timestamp, user editable
    var createdAt: Date
    var archivedAt: Date?         // nil = active; chỉ 1 active tại 1 thời điểm
    var players: [String]         // tên thuần, locked sau khi tạo
    @Relationship(deleteRule: .cascade) var rounds: [Round]
}

@Model class Round {
    var id: UUID
    var index: Int                 // 1-based
    var scores: [String: Int]      // playerName → điểm ván đó
    var createdAt: Date
    var session: Session?
}
```

- `players` là `[String]` (không có Player entity) → URL handoff trivial, autosuggest = query distinct names across sessions.
- Tổng = computed `session.players.map { name in rounds.reduce(0) { $0 + ($1.scores[name] ?? 0) } }`
- "1 active tại 1 thời điểm" enforce ở business logic khi tạo/import: archive cái cũ trước.

## Screens

1. **HomeView (root)** — quyết định route khi launch:
   - `activeSession != nil` → push `SessionView(activeSession)`
   - `activeSession == nil` → empty state với nút "Tạo session mới" + icon History (top-right)

2. **NewSessionView** (sheet) — input list player:
   - Chip "Dùng lại nhóm vừa rồi (An/Bình/Cường/Dũng)" 1-tap
   - Hoặc TextField "+ Thêm người" với autosuggest từ distinct history names
   - Tên session = default timestamp, sửa được
   - Nút "Bắt đầu" → tạo Session, archive session active cũ (nếu có), push SessionView

3. **SessionView** (R1 layout):
   - Top NavBar: title (editable), Share button (`ShareLink`), menu (⋮: Kết thúc, Xóa)
   - Chip tổng scroll ngang
   - LazyVStack list Round cards (newest first), tap để sửa, swipe-to-delete
   - FAB "+ Ván" → present `.fullScreenCover` RoundEntryView

4. **RoundEntryView** (full-screen sheet):
   - List dọc của player + ô số bên phải
   - N-1 ô gõ tay, ô còn lại auto-fill mờ (-sum), tap để override
   - Custom keypad dưới đáy: 0-9, ±, ⌫, "Lưu ván" big button
   - Swipe-down hoặc ✕ để hủy

5. **SummaryView** (modal hoặc push khi kết thúc):
   - Ranking với **ấn vàng** (gold seal) cho vô địch và **tem chéo** (×) cho người cuối — visual identity từ DESIGN.md, không dùng medal emoji.
   - Tổng từng người, số ván, ngày
   - Open lại từ History anytime
   - `ShareLink` cuối màn

6. **HistoryView**:
   - List sessions sorted newest first
   - Mỗi row: name, ngày, chip player, ranking compact
   - Tap → SummaryView (read-only); long-press để delete
   - Filter/search defer post-MVP

7. **ImportConfirmView** (triggered by `.onOpenURL`):
   - "Nhận session X (N người, M ván)" preview
   - [Mở] [Hủy]
   - Mở = save SwiftData + archive active cũ + activate cái mới

## Pattern cần làm

- **State stack tránh deep-link clash**: khi mở app từ URL trong lúc đang chơi → modal ImportConfirmView **trên** SessionView, không thay thế. Hủy = trở về session cũ.
- **Keypad focus state**: track ô input nào đang active, "Next" trong keypad jump sang ô tiếp theo skip ô auto.
- **Auto-fill recalc khi sửa ván cũ**: edit 1 ô → ô auto-fill ván đó tự update; toàn bộ tổng leaderboard reactive.

## Verification

Cách test end-to-end (manual + simulator):

1. **Cold start**: xóa app → mở → thấy empty state với nút "Tạo session mới".
2. **Tạo session**: nhập 4 tên → bấm Bắt đầu → vào SessionView trống.
3. **Add round**: tap "+ Ván" → entry sheet → gõ 3 số → ô 4 auto-fill đúng -(tổng) → "Lưu" → card xuất hiện, chip tổng update.
4. **Auto-fill override**: tạo ván mới → tap ô auto-fill → gõ số khác → 1 ô khác trống trở thành auto.
4b. **Sparse round (chặt heo)**: tạo ván mới → chỉ gõ 2 ô (An -5, Bình +5), 2 ô khác để trống → footer "Tổng: 0 ✓" → tap Lưu → ván save với Cường=0, Dũng=0 ngầm.
4c. **Sparse sai**: gõ 2 ô sum ≠ 0 → footer cảnh báo cam → tap Lưu vẫn save (warning nhẹ) HOẶC gõ thêm ô → khi còn 1 ô trống → auto-fill kích hoạt.
5. **Edit ván cũ**: tap row ván 1 → sửa 1 ô → tổng leaderboard update reactive.
6. **Swipe delete**: swipe row → "Xóa" → confirm → ván biến mất, tổng update.
7. **Reuse last group**: tạo session 2 → chip "Dùng lại nhóm vừa rồi" hiện 4 tên cũ → tap → vào thẳng.
8. **End session**: ⋮ → Kết thúc → SummaryView hiện đúng ranking → archive trong History.
9. **History**: tap icon góc → list session → tap session cũ → SummaryView read-only.
10. **URL share**: SessionView → Share button → AirDrop sheet hiện → AirDrop sang iPhone/iPad khác.
11. **URL receive**: trên thiết bị nhận click link → ImportConfirmView hiện preview đúng → Mở → session vào active + cái cũ archive.
12. **iCloud sync**: iPhone 1 + iPad cùng Apple ID → tạo ván trên iPhone → kéo refresh trên iPad (hoặc đợi push) → thấy ván mới.
13. **Offline**: bật airplane mode → tất cả thao tác trên vẫn chạy (chỉ iCloud sync hoãn đến khi có mạng).

Không có unit test bắt buộc cho MVP — personal app, dependency thấp. Có thể thêm sau cho Round score calc + URL encoder/decoder nếu thấy cần.

## Out of scope (MVP)

- Money / giá điểm / settlement
- Multi-user real-time collab (multi-device cùng Apple ID đã đủ)
- Game-aware scoring (móm/ù/thối heo penalty math)
- Game type label / preset
- Stats lifetime ("An winning rate")
- History search/filter
- iPad-optimized layout (chạy được nhưng không tối ưu)
- macOS / Mac Catalyst
- Image export bảng điểm
- Light/dark theme customization (theo system)
- Localization tiếng Anh (chỉ tiếng Việt cho MVP)
