# saam-app

Personal-use iOS score tracker app cho Phỏm / Sâm Lốc / mọi card game zero-sum.

## Files

- [`PLAN.md`](./PLAN.md) — design plan đầy đủ: UX decisions, tech stack (SwiftUI + SwiftData + CloudKit), data model, screens, verification steps
- [`design-walkthrough.html`](./design-walkthrough.html) — interactive walkthrough mockup các màn hình chính. Mở trực tiếp trong browser hoặc xem online:

  https://raw.githack.com/quyctd/saam-app/main/design-walkthrough.html

## Tech

- iOS 17+, SwiftUI, SwiftData + CloudKit
- Offline-first, no backend, no auth
- Sync giữa thiết bị cùng Apple ID qua iCloud
- Share session với người ngoài qua URL handoff (encoded state)
