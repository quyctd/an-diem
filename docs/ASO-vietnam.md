# ASO — App Store Optimization (Vietnam)

App Store Optimization copy for **Ấn Điểm**, targeting the Vietnam App Store.
Paste these into App Store Connect → the **vi (Vietnamese)** localization.

> **Set Vietnamese as the *primary* App Store localization.** Apple indexes the
> name/subtitle/keywords fields per-localization; a VN-primary listing is
> non-negotiable for this market.

---

## The problem this fixes

The live listing (id `6772962052`) currently ships:

| Field | Live now | Why it fails in VN |
|---|---|---|
| Name | `Andiem Score Tracker` | English; zero VN search volume |
| Subtitle | `zero-sum game score tracker` | English jargon nobody searches |
| Category | **Card** (Games) | All ranking competitors sit in **Tiện Ích / Utilities** |
| Description | Opens in English | First line should be the VN hook |

The demand vocabulary is concentrated and clear: **ghi điểm** / **ghi điểm đánh
bài** (the #1 phrase), **tính điểm**, plus game qualifiers **phỏm, tá lả, sâm
lốc, tiến lên**, and modifiers **offline** / **không quảng cáo**.

Competitor benchmark (VN App Store, category Tiện Ích):
- **Ghi điểm bài** — 4.8★, ~3,400 ratings. Subtitle is a keyword string:
  *"Ghi điểm đánh bài tiến lên"*. The leader to beat.
- **Ghi Điểm Đánh Bài Offline** — 4.6★. Lead copy: *"Thời đại 4.0 đánh bài ghi
  điểm cần gì đến giấy và bút."*

---

## Fields to paste

### App Name (≤30 chars) — keep brand, add the money phrase
```
Ấn Điểm – Ghi Điểm Đánh Bài
```
27 chars. Brand stays first for identity; "Ghi Điểm Đánh Bài" captures the #1 query.

### Subtitle (≤30 chars) — spend entirely on game names
```
Phỏm, Tá Lả, Sâm Lốc, Tiến Lên
```
30 chars exactly. The four highest-volume game qualifiers; none overlap the name.

### Keywords field (≤100 chars, comma-separated, NO spaces)
```
offline,tính,bảng,sổ,tiền,ăn,chắn,ù,tây,đếm,tổng,nhẩm,kèo,ván,hội,bạn,nhậu,bắc,nam
```
Rules applied:
- **Never repeat** words already in name/subtitle (ghi, điểm, đánh, bài, phỏm,
  tá, lả, sâm, lốc, tiến, lên) — repetition wastes the field.
- No plurals; no spaces after commas (Apple ignores spaces).
- Single tokens index combinatorially across commas: `tính`+`điểm` → "tính
  điểm" for free.
- `bắc` / `nam` catch "phỏm miền bắc" / "tiến lên miền nam".
- Verify the live char counter in App Store Connect before saving.

### Promotional text (≤170 chars — editable anytime, no review; use for seasonal pushes)
```
Mở app là chơi. Ghi điểm cả bàn Phỏm, Tá Lả, Sâm Lốc, Tiến Lên — không giấy bút, không nhẩm tổng. Bảng xếp hạng sẵn sàng khi tàn cuộc. Hoàn toàn offline, không quảng cáo.
```

### Description (front-load first ~2 lines; in-brand terse voice, no game-show energy)
```
Mở app là chơi. Ấn Điểm ghi điểm cho cả bàn Phỏm, Tá Lả, Sâm Lốc, Tiến Lên — không cần giấy bút, không cần nhẩm tổng trong đầu.

• Mở máy vào thẳng ván đang chơi, 0 thao tác thừa.
• Mỗi ván chỉ nhập điểm cho N−1 người, ô cuối tự điền.
• Bảng xếp hạng luôn sẵn sàng khi tàn cuộc — ai ăn, ai thua, rõ trong một cái liếc.
• Người thắng đóng ấn vàng, người bét nhận tem chéo.
• Sửa điểm thoải mái, lưu lịch sử từng bàn.
• Gợi ý tên người chơi từ các bàn trước.

Hoạt động hoàn toàn offline. Không đăng ký, không cần mạng, không quảng cáo. Đồng bộ iCloud giữa các máy của bạn chạy ngầm — app không bao giờ hỏi, không bao giờ chờ.

Ấn Điểm là cuốn sổ điểm sơn mài của hội bài: nó ghi điểm cả bàn đã thống nhất, không phân xử luật (không tính móm, ù, thối). Bàn biết luật — app giữ sổ.
```

---

## Non-text levers (these move installs more than copy)

1. **Category → Tiện Ích (Utilities).** Where every ranking competitor lives.
   Placing a tracker in Games/Card buries it and risks rejection. Secondary:
   leave empty.
2. **VN as primary localization** (see top note).
3. **Screenshots.** First 2 are 80%+ of the conversion decision. Show the
   **leaderboard with the ấn vàng seal** and **round entry mid-input**, each with
   a 3–5 word Vietnamese caption baked in (e.g. *"Tàn cuộc — ai ăn ai thua, rõ
   ngay"*). Don't ship bare screenshots.
4. **Ratings.** The leader's moat is 3,400 ratings at 4.8★. Add a
   `requestReview()` prompt after a session is *finished* (the satisfied moment),
   not on launch.

---

## Priority order

1. **Rename (name + subtitle) + recategorize to Tiện Ích** — biggest lever, do first.
2. Keywords field + VN-primary localization.
3. Captioned screenshots.
4. Post-session `requestReview()` prompt (small code change in `SessionActions`).

---

## Landing page (separate web-SEO index)

`quyctd/blog → public/an-diem/` already uses the correct brand "Ấn Điểm". Tuned
up 2026-06-20: `<title>`, meta description, og:description, and hero lede now
include **Tá Lả / Tiến Lên** and the search verb **ghi điểm**. The App Store
listing — not the landing page — is the discoverability bottleneck.

## Competitor references

- Ghi điểm bài — https://apps.apple.com/vn/app/ghi-điểm-bài/id1406224934?l=vi
- Ghi Điểm Đánh Bài Offline — https://apps.apple.com/vn/app/ghi-điểm-đánh-bài-offline/id1644362222
- Ghi điểm bài tiến lên — https://apps.apple.com/id/app/ghi-điểm-bài-tiến-lên/id6450334449
