import SwiftUI
import SwiftData
import UIKit

/// Đóng dấu — WYSIWYG editor.
/// Embeds the live `ShareCardView` so what you see while editing IS what gets
/// shared. The card's photo zone is interactive when the editor binding is
/// passed: tap-to-pick when empty, drag stickers when a photo is loaded.
struct StampEditorView: View {
    @Bindable var session: Session
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var photo: UIImage?
    @State private var winnerCoord: SealCoord?
    @State private var loserCoord: SealCoord?
    @State private var showSourcePicker: Bool
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false
    @State private var pendingClear: ShareCardView.SealTarget?
    @State private var activeDrag: ShareCardView.SealTarget?

    private var ranking: [(name: String, total: Int)] { Totals.ranking(for: session) }
    private var winnerName: String { ranking.first?.name ?? "" }
    private var loserName: String? {
        guard ranking.count >= 2, let last = ranking.last, last.name != ranking.first?.name else { return nil }
        return last.name
    }

    init(session: Session) {
        self._session = Bindable(session)
        let existing = ImageHelpers.image(from: session.coverPhoto)
        _photo = State(initialValue: existing)
        _winnerCoord = State(initialValue: session.winnerSealCoord)
        _loserCoord = State(initialValue: session.loserCrossCoord)
        // Open the picker automatically only on first entry (no existing photo).
        _showSourcePicker = State(initialValue: existing == nil)
    }

    var body: some View {
        ZStack {
            LacquerBackground(surface: .phormSurfaceOxblood).ignoresSafeArea()

            VStack(spacing: 0) {
                topChrome
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.sm)

                Spacer(minLength: Spacing.sm)

                // The live share card — scaled to fit screen, fully interactive.
                cardPreview
                    .padding(.horizontal, Spacing.md)

                Spacer(minLength: Spacing.sm)

                bottomChrome
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
            }
        }
        .sheet(isPresented: $showSourcePicker) {
            StampSourcePicker(isPresented: $showSourcePicker) { image in
                applyPicked(image)
                showSourcePicker = false
            }
            .presentationDetents([.fraction(0.42)])
            .presentationBackground(Color.phormSurfaceCinnabarDeep)
            .presentationDragIndicator(.visible)
        }
        .confirmationDialog(
            "Xoá huy hiệu này?",
            isPresented: Binding(
                get: { pendingClear != nil },
                set: { if !$0 { pendingClear = nil } }
            ),
            presenting: pendingClear
        ) { which in
            Button("Xoá", role: .destructive) {
                switch which {
                case .winner: winnerCoord = nil
                case .loser: loserCoord = nil
                }
            }
            Button("Hủy", role: .cancel) {}
        } message: { _ in
            Text("Bạn có thể đưa huy hiệu trở lại bằng nút bên dưới.")
        }
        .sheet(isPresented: $showShareSheet, onDismiss: { dismiss() }) {
            if let shareImage {
                ShareSheet(image: shareImage)
                    .presentationBackground(Color.phormSurfaceCinnabarDeep)
            }
        }
    }

    // MARK: - Card preview (scaled live ShareCardView)

    private var cardPreview: some View {
        GeometryReader { geo in
            let cardWidth = min(geo.size.width, geo.size.height * 9.0 / 16.0)
            let cardHeight = cardWidth * 16.0 / 9.0
            let scale = cardWidth / ShareCardView.exportSize.width

            ShareCardView(session: session, editor: editorBinding)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: cardWidth, height: cardHeight, alignment: .topLeading)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(9.0 / 16.0, contentMode: .fit)
    }

    private var editorBinding: ShareCardView.Editor {
        ShareCardView.Editor(
            photo: $photo,
            winnerCoord: $winnerCoord,
            loserCoord: $loserCoord,
            activeDrag: activeDrag,
            onPhotoTap: { showSourcePicker = true },
            onSealDragChanged: { target, location, imageRect in
                activeDrag = target
                let clamped = CGPoint(
                    x: max(imageRect.minX, min(location.x, imageRect.maxX)),
                    y: max(imageRect.minY, min(location.y, imageRect.maxY))
                )
                let nx = (clamped.x - imageRect.minX) / imageRect.width
                let ny = (clamped.y - imageRect.minY) / imageRect.height
                let coord = SealCoord(x: Double(nx), y: Double(ny))
                switch target {
                case .winner: winnerCoord = coord
                case .loser: loserCoord = coord
                }
            },
            onSealDragEnded: { _ in
                activeDrag = nil
                Haptics.tap()
            },
            onSealLongPress: { target in
                Haptics.warn()
                pendingClear = target
            }
        )
    }

    // MARK: - Photo picked

    private func applyPicked(_ image: UIImage) {
        // Use the raw UIImage. Native iOS rendering auto-applies EXIF
        // orientation everywhere we display it (editor + ImageRenderer), so
        // seal coords stay aligned across editor + export.
        photo = image
        // Auto-place seals on first photo — won't stomp existing coords.
        if winnerCoord == nil {
            winnerCoord = SealCoord(x: 0.32, y: 0.42)
        }
        if loserCoord == nil, loserName != nil {
            loserCoord = SealCoord(x: 0.68, y: 0.42)
        }
    }

    // MARK: - Top chrome

    private var topChrome: some View {
        HStack(alignment: .center) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.phormCreamDim)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.black.opacity(0.28)))
            }
            .buttonStyle(.plain)

            Spacer()

            SectionLabel(text: "Kéo huy hiệu vào mặt người", tone: .gold)
        }
    }

    // MARK: - Bottom chrome

    private var bottomChrome: some View {
        VStack(spacing: Spacing.sm) {
            if photo != nil {
                stickerChips
            }
            actionRow
        }
    }

    /// Status chips — toggle visibility of each seal. Tap a hidden chip to
    /// restore that seal at its default position; long-press on the actual
    /// sticker is the way to hide it.
    private var stickerChips: some View {
        HStack(spacing: Spacing.sm) {
            chip(target: .winner, glyph: "1", name: winnerName, isPlaced: winnerCoord != nil)
            if let loserName {
                chip(target: .loser, glyph: "Bét", name: loserName, isPlaced: loserCoord != nil)
            }
        }
    }

    private func chip(target: ShareCardView.SealTarget, glyph: String, name: String, isPlaced: Bool) -> some View {
        Button {
            guard !isPlaced else { return }
            switch target {
            case .winner: winnerCoord = SealCoord(x: 0.32, y: 0.42)
            case .loser:  loserCoord = SealCoord(x: 0.68, y: 0.42)
            }
            Haptics.tap()
        } label: {
            HStack(spacing: 8) {
                Text(glyph)
                    .font(.system(size: 14, weight: .heavy, design: .default))
                    .foregroundStyle(isPlaced ? Color.onPrimary : Color.phormPrimary)
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(isPlaced ? Color.phormPrimary : Color.phormPrimary.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color.phormPrimary, lineWidth: 1)
                    )
                Text(name)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundStyle(Color.phormCream)
                    .lineLimit(1)
                if !isPlaced {
                    Text("đưa lại")
                        .font(.phormCaptionSection)
                        .tracking(1.4)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.phormGoldBright)
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.black.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Color.phormCream.opacity(isPlaced ? 0.18 : 0.32), lineWidth: 1)
            )
            .opacity(isPlaced ? 1.0 : 0.85)
        }
        .buttonStyle(.plain)
    }

    private var actionRow: some View {
        HStack(spacing: Spacing.sm) {
            Button {
                showSourcePicker = true
            } label: {
                Text(photo == nil ? "Thêm ảnh" : "Đổi ảnh")
                    .font(.phormButton)
                    .tracking(2.0)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.phormPrimary)
                    .frame(width: 116, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color.phormPrimary, lineWidth: 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            }
            .buttonStyle(.plain)

            LacquerPrimaryButton(title: photo == nil ? "Chia sẻ" : "Lưu & chia sẻ") {
                commitAndShare()
            }
        }
    }

    // MARK: - Commit + share

    @MainActor
    private func commitAndShare() {
        let photoData: Data? = {
            guard let photo else { return nil }
            // Re-use persisted bytes if nothing has visibly changed.
            if let existing = session.coverPhoto,
               let existingImage = UIImage(data: existing),
               existingImage.size == photo.size,
               session.winnerSealCoord == winnerCoord,
               session.loserCrossCoord == loserCoord {
                return existing
            }
            // No size cap — encode at high quality, fall back to PNG, then to
            // the previously-persisted bytes if both encoders fail.
            if let data = photo.jpegData(compressionQuality: 0.9) ?? photo.pngData() {
                return data
            }
            return session.coverPhoto
        }()

        do {
            try SessionActions.stampSession(
                photo: photoData,
                winner: winnerCoord,
                loser: loserCoord,
                on: session,
                in: context
            )
        } catch {
            print("stampSession failed: \(error)")
        }

        guard let rendered = ShareCardView.render(session: session) else {
            dismiss()
            return
        }
        shareImage = rendered
        showShareSheet = true
    }
}
