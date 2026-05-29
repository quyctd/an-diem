# Ấn Điểm

Sổ điểm cho bàn Phỏm, Sâm Lốc. Mở app là chơi.

<img src="https://andiem.quyctd.dev/icon.png" width="120" alt="Ấn Điểm icon">

[![App Store](https://img.shields.io/badge/App_Store-0D96F6?style=flat&logo=app-store&logoColor=white)](https://apps.apple.com/app/idREPLACE-ME)

---

## Cái có

- **Mở app là vào ngay** phiên đang chơi — không đăng ký, không đăng nhập
- **Ô cuối tự cộng**, tổng luôn về 0 — chỉ cần nhập N−1 người
- **Ấn vàng** cho người dẫn đầu, **tem chéo** cho người chót
- **Đồng bộ iCloud** giữa các máy cùng Apple ID
- **Chia sẻ phiên qua link** cho bạn bè import nhanh
- **Offline-first** — chơi ở đâu cũng được, không cần mạng

## Cái không

- Không đánh bài thật trong app
- Không cá cược, tiền thật, phần thưởng
- Không tính luật Phỏm / Sâm tự động — app chỉ ghi điểm, không phân định thắng thua
- Không quảng cáo, không tracking

## Yêu cầu

- iOS 17+
- iPhone

---

## Mã nguồn

Toàn bộ code nằm trong [`./andiem-ios/`](./andiem-ios/). App được viết bằng SwiftUI + SwiftData, sync qua CloudKit.

Xem chi tiết thiết kế và kế hoạch phát triển trong:
- [`PLAN.md`](./PLAN.md) — UX, data model, screens
- [`DESIGN.md`](./DESIGN.md) — design system Hà Nội cũ
- [`themes-preview.html`](https://raw.githack.com/quyctd/an-diem/main/themes-preview.html) — mockup trực quan
