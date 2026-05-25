# App Store Connect — metadata (vi)

Copy these fields straight into App Store Connect. Primary language: **Tiếng Việt (Vietnam)**. Bundle: `com.quyctd.phorm`.

## App information

| Field | Value |
|---|---|
| Name | `Phorm` |
| Subtitle (≤30) | `Ghi điểm Phỏm & Sâm Lốc` |
| Category — Primary | **Games** → **Card** |
| Category — Secondary | **Utilities** |
| Bundle ID | `com.quyctd.phorm` |
| SKU | `phorm-ios-001` |
| Age rating | 4+ (xem `review-notes.md`) |
| Price | Free (Tier 0) |
| Availability | Vietnam first; bật toàn cầu nếu muốn (UI chỉ tiếng Việt — flag cho người duyệt biết) |

## Keywords (≤100 ký tự, phẩy ngăn cách)

```
phỏm,sâm lốc,sâm,tá lả,ghi điểm,bảng điểm,bài,sổ điểm,offline,icloud
```
*(98 ký tự — vẫn còn dư 2)*

## Promotional text (≤170, đổi được không cần build mới)

```
Mở app là chơi. App tự cân tổng từng vòng — bàn lo luật, app lo cộng. Sổ điểm cho Phỏm, Sâm Lốc. Offline, đồng bộ iCloud giữa máy của bạn.
```

## Description (≤4000)

```
Sổ ghi điểm cho Phỏm, Sâm Lốc, hay bất kỳ ván bài zero-sum.

Mở máy là vào ngay phiên đang chơi. Mỗi vòng chỉ nhập điểm — app lo phần còn lại, tổng tự cân bằng 0. Không nhẩm trong đầu, không bấm máy tính giữa ván. Cuối buổi: ấn vàng cho người dẫn đầu, tem chéo cho người cuối bàn.

• Mở 0 chạm vào phiên đang chơi
• App tự cân tổng từng vòng
• Đồng bộ iCloud giữa máy của riêng bạn
• Chia sẻ phiên qua link
• Offline — không tài khoản, không quảng cáo, không thu thập dữ liệu
• Giao diện sơn mài, chữ serif — không LED đen-vàng

—

Phorm là sổ điểm cho bàn bạn bè. Không cược tiền thật, không vòng quay, không phần thưởng.
```

## What's New in this version (≤4000) — phiên bản đầu tiên

```
Bản đầu tiên.
```

*(Bản đầu thường để vậy. Lần sau dùng: "• Sửa X • Thêm Y" — terse, có gạch đầu dòng.)*

## URLs

| Field | Value |
|---|---|
| Marketing URL | (tuỳ chọn — có thể để trống) |
| Support URL | **bắt buộc** — gợi ý: `https://github.com/quyctd/saam-app/issues` hoặc trang GitHub Pages tự dựng |
| Privacy Policy URL | **bắt buộc** — host file `submission/privacy-policy.html` (xem dưới) |

## App Privacy (nutrition labels)

Khai báo: **Data Not Collected**. Không có một mục nào cần tick.

iCloud sync giữa máy của user — Apple coi đây là Apple-provided service, **không tính** là collection.

## Copyright

```
© 2026 quyctd
```

## Contact info (App Review)

- **First name / Last name**: tên thật
- **Phone**: số điện thoại bạn cầm được khi App Review gọi
- **Email**: quy.dc98@gmail.com

## Build

Pick build `1.0 (3)` từ TestFlight. Nếu sửa entitlements (xem `checklist.md` mục 1), bump lên `1.0 (4)` và upload lại.
