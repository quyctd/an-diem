import SwiftUI
import UIKit

/// F5 — the composed 9:16 lacquer share artifact.
/// Sized at exactly 1080×1920 logical points so `ImageRenderer(scale: 1)` produces
/// a 1080×1920 pixel JPEG. Center 56% of height is the Locket-safe square zone.
struct ShareCardView: View {
    let session: Session

    /// Optional editor handles. nil → static render (ImageRenderer use).
    /// non-nil → photo zone becomes interactive (tap-to-pick, drag stickers).
    /// Everything outside the photo zone stays read-only either way.
    let editor: Editor?

    enum SealTarget { case winner, loser }

    struct Editor {
        @Binding var photo: UIImage?
        @Binding var winnerCoord: SealCoord?
        @Binding var loserCoord: SealCoord?
        var activeDrag: SealTarget?
        var onPhotoTap: () -> Void
        var onSealDragChanged: (SealTarget, CGPoint, CGRect) -> Void
        var onSealDragEnded: (SealTarget) -> Void
        var onSealLongPress: (SealTarget) -> Void
    }

    init(session: Session, editor: Editor? = nil) {
        self.session = session
        self.editor = editor
    }

    static let exportSize = CGSize(width: 1080, height: 1920)

    private var ranking: [(name: String, total: Int)] { Totals.ranking(for: session) }
    private var winnerName: String? { ranking.first?.name }
    private var loserName: String? {
        guard ranking.count >= 2, let last = ranking.last else { return nil }
        return last.name == winnerName ? nil : last.name
    }
    private var roundCount: Int { (session.rounds ?? []).count }

    /// Resolves to the editor's in-flight photo when editing, falling back to
    /// the persisted session.coverPhoto otherwise.
    private var effectivePhoto: UIImage? {
        editor?.photo ?? ImageHelpers.image(from: session.coverPhoto)
    }
    private var effectiveWinnerCoord: SealCoord? {
        editor?.winnerCoord ?? session.winnerSealCoord
    }
    private var effectiveLoserCoord: SealCoord? {
        editor?.loserCoord ?? session.loserCrossCoord
    }

    var body: some View {
        ZStack {
            lacquerGround

            // The "scorebook page" — inner gold-hairline frame inset from edges
            innerFrame

            // Top-left: 印 seal corner ornament
            VStack {
                HStack {
                    cornerSeal
                        .padding(.leading, 90)
                        .padding(.top, 100)
                    Spacer()
                }
                Spacer()
            }

            // Top-right: date + tally
            VStack {
                HStack {
                    Spacer()
                    cornerMeta
                        .padding(.trailing, 90)
                        .padding(.top, 100)
                }
                Spacer()
            }

            // Main vertical composition
            VStack(spacing: 0) {
                Spacer().frame(height: 240)
                headerZone
                Spacer().frame(height: 48)

                if let photo = effectivePhoto {
                    photoZone(photo: photo)
                        .padding(.horizontal, 60)
                } else if editor != nil {
                    emptyPhotoZone
                        .padding(.horizontal, 60)
                } else {
                    noPhotoZone
                        .padding(.horizontal, 60)
                }

                Spacer().frame(height: 40)

                rankingStrip
                    .padding(.horizontal, 120)

                Spacer()
                Spacer().frame(height: 200)
            }

            // Colophon — pinned to bottom
            VStack {
                Spacer()
                colophon
                    .padding(.bottom, 70)
            }
        }
        .frame(width: Self.exportSize.width, height: Self.exportSize.height)
        .background(Color.phormSurfaceOxblood)
        .clipped()
    }

    /// Inner gold hairline frame, inset 50pt from the card edge with ornamental
    /// corner ticks. Gives the composition the feel of a printed page rather
    /// than a 9:16 layout.
    private var innerFrame: some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color.phormPrimary.opacity(0.28), lineWidth: 1.5)
                .padding(50)
            // Four corner ticks — small gold L-marks at intersections.
            ForEach([UnitPoint.topLeading, .topTrailing, .bottomLeading, .bottomTrailing], id: \.self) { corner in
                cornerTick(at: corner)
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func cornerTick(at corner: UnitPoint) -> some View {
        let isTop = corner.y < 0.5
        let isLeading = corner.x < 0.5
        ZStack(alignment: isTop
               ? (isLeading ? .topLeading : .topTrailing)
               : (isLeading ? .bottomLeading : .bottomTrailing)) {
            Color.clear
            // Horizontal and vertical strokes meeting at the corner.
            Rectangle()
                .fill(Color.phormPrimary.opacity(0.85))
                .frame(width: 22, height: 1.5)
                .padding(isTop ? .top : .bottom, 50)
                .padding(isLeading ? .leading : .trailing, 50)
            Rectangle()
                .fill(Color.phormPrimary.opacity(0.85))
                .frame(width: 1.5, height: 22)
                .padding(isTop ? .top : .bottom, 50)
                .padding(isLeading ? .leading : .trailing, 50)
        }
    }

    // MARK: - Ground

    private var lacquerGround: some View {
        ZStack {
            Color.phormSurfaceOxblood
            // Center vignette — brighter gold-tint top
            RadialGradient(
                colors: [Color.phormPrimary.opacity(0.18), .clear],
                center: UnitPoint(x: 0.5, y: 0.06),
                startRadius: 0,
                endRadius: 700
            )
            // Deep bottom vignette
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.40)],
                center: UnitPoint(x: 0.5, y: 1.0),
                startRadius: 200,
                endRadius: 1300
            )
            // Halftone dots — re-tile precomputed image
            Image(uiImage: .shareHalftone)
                .resizable(resizingMode: .tile)
                .blendMode(.screen)
                .opacity(0.85)
                .allowsHitTesting(false)
        }
    }

    // MARK: - Corners

    private var cornerSeal: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.phormPrimary.opacity(0.12))
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color.phormPrimary, lineWidth: 1.8)
            Text("印")
                .font(.system(size: 32, weight: .heavy, design: .serif))
                .foregroundStyle(Color.phormPrimary)
        }
        .frame(width: 64, height: 64)
        .rotationEffect(.degrees(-4))
    }

    /// Top-right corner — weekday + date + tally strokes for round count.
    /// The tally is the printer's mark: one short vertical stroke per round,
    /// wrapped after 5 (the "gate" / IIII+slash convention rendered as inked rules).
    private var cornerMeta: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text(weekdayLine.uppercased())
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .tracking(4.0)
                .foregroundStyle(Color.phormGoldBright)
            Text(dateLine)
                .font(.system(size: 30, weight: .medium, design: .serif).monospacedDigit())
                .tracking(2.0)
                .foregroundStyle(Color.phormCream)
            tallyStrokes(count: roundCount)
                .padding(.top, 4)
        }
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "dd · MM · yyyy"
        return f.string(from: session.archivedAt ?? session.createdAt)
    }

    private var weekdayLine: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "EEEE"
        return f.string(from: session.archivedAt ?? session.createdAt)
    }

    /// Printer-style tally: vertical strokes grouped in 5s, with the 5th drawn
    /// as a diagonal cross-stroke through the previous four (the Vietnamese
    /// matchbox-counter convention, also the Western IIII⁄).
    @ViewBuilder
    private func tallyStrokes(count: Int) -> some View {
        // Cap visible groups so we don't run past the gold frame. Most sessions
        // are under 20 rounds; for outliers we show "20+".
        let visible = min(count, 20)
        let fullGroups = visible / 5
        let remainder = visible % 5
        HStack(alignment: .center, spacing: 10) {
            if count > 20 {
                Text("20+")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(Color.phormCreamDim)
            }
            ForEach(0..<fullGroups, id: \.self) { _ in
                tallyGroup(strokes: 5)
            }
            if remainder > 0 {
                tallyGroup(strokes: remainder)
            }
            Text("vòng")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .tracking(2.4)
                .foregroundStyle(Color.phormCreamDim)
                .textCase(.uppercase)
                .padding(.leading, 4)
        }
    }

    private func tallyGroup(strokes: Int) -> some View {
        ZStack {
            HStack(spacing: 4) {
                ForEach(0..<min(strokes, 4), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.phormPrimary)
                        .frame(width: 1.5, height: 22)
                }
            }
            if strokes >= 5 {
                Rectangle()
                    .fill(Color.phormPrimary)
                    .frame(width: 28, height: 1.5)
                    .rotationEffect(.degrees(-18))
            }
        }
        .frame(height: 22)
    }

    // MARK: - Header

    private var headerZone: some View {
        VStack(spacing: 24) {
            // Eyebrow flanked by paired rules — the print-page running head.
            HStack(spacing: 18) {
                Rectangle()
                    .fill(Color.phormPrimary.opacity(0.55))
                    .frame(width: 60, height: 1)
                Text("phiên kết thúc")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .tracking(6.0)
                    .foregroundStyle(Color.phormGoldBright)
                    .textCase(.uppercase)
                Rectangle()
                    .fill(Color.phormPrimary.opacity(0.55))
                    .frame(width: 60, height: 1)
            }

            // The title — biggest type on the card, two lines max, allowed to
            // breathe. Cormorant italic via .serif fallback.
            Text(session.name)
                .font(.system(size: 110, weight: .bold, design: .serif).italic())
                .foregroundStyle(Color.phormCream)
                .multilineTextAlignment(.center)
                .lineSpacing(-8)
                .lineLimit(2)
                .minimumScaleFactor(0.55)
                .padding(.horizontal, 120)
                .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
        }
    }

    // MARK: - Photo zone (Locket-style: square, rounded all four corners,
    // ambient backdrop that bleeds the photo's colors into the lacquer)

    @ViewBuilder
    private func photoZone(photo: UIImage) -> some View {
        ZStack {
            // Ambient: blurred photo bleeds its edge colors into the rounded
            // container — the iOS Music / Locket trick, no color sampling.
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .blur(radius: 60)
                .opacity(0.55)

            // Sharp photo with seals — inset so the blurred halo shows around it.
            photoWithSeals(photo: photo)
                .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                .padding(36)
                .shadow(color: .black.opacity(0.32), radius: 20, y: 12)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 80, style: .continuous))
        .shadow(color: .black.opacity(0.40), radius: 28, y: 16)
    }

    /// Editor-only — tap-to-pick empty state shaped like the photo zone so the
    /// layout doesn't jump when the photo gets added.
    private var emptyPhotoZone: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.phormSurfaceCinnabar.opacity(0.85),
                    Color.phormSurfaceCinnabarDeep
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(Color.phormPrimary.opacity(0.12))
                    Circle()
                        .strokeBorder(Color.phormPrimary, lineWidth: 2)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 84, weight: .regular))
                        .foregroundStyle(Color.phormPrimary)
                }
                .frame(width: 220, height: 220)

                Text("Chạm để thêm ảnh nhóm")
                    .font(.system(size: 32, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.phormCream)
                Text("Chụp ngay · hoặc thư viện")
                    .font(.system(size: 22, weight: .medium, design: .serif))
                    .tracking(3.0)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.phormCreamDim)
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 80, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 80, style: .continuous)
                .strokeBorder(Color.phormPrimary.opacity(0.30), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.40), radius: 28, y: 16)
        .contentShape(Rectangle())
        .onTapGesture { editor?.onPhotoTap() }
    }

    @ViewBuilder
    private func photoWithSeals(photo: UIImage) -> some View {
        GeometryReader { geo in
            // Locket-style center crop — photo fills the square frame (no
            // letterboxing). Edge faces *may* get cropped; group photos tend to
            // keep faces near center so this is the acceptable trade-off.
            let imageRect = filledPhotoRect(photo: photo, in: geo.size)
            ZStack {
                Image(uiImage: photo)
                    .resizable()
                    .frame(width: imageRect.width, height: imageRect.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // Subtle vignette inside the photo
                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [.clear, Color(red: 0.20, green: 0.08, blue: 0.04).opacity(0.45)],
                            center: .center,
                            startRadius: min(geo.size.width, geo.size.height) * 0.35,
                            endRadius: min(geo.size.width, geo.size.height) * 0.65
                        )
                    )
                    .frame(width: geo.size.width, height: geo.size.height)

                // Seals sized at ~16% of the visible photo edge.
                let sealScale = min(geo.size.width, geo.size.height) / 325
                if let coord = effectiveWinnerCoord {
                    sealView(target: .winner, scale: sealScale)
                        .position(displayPoint(for: coord, in: imageRect))
                        .gesture(sealDragGesture(target: .winner, imageRect: imageRect))
                        .onLongPressGesture(minimumDuration: 0.55) {
                            editor?.onSealLongPress(.winner)
                        }
                }
                if let coord = effectiveLoserCoord {
                    sealView(target: .loser, scale: sealScale)
                        .position(displayPoint(for: coord, in: imageRect))
                        .gesture(sealDragGesture(target: .loser, imageRect: imageRect))
                        .onLongPressGesture(minimumDuration: 0.55) {
                            editor?.onSealLongPress(.loser)
                        }
                }
            }
            .clipped()
        }
    }

    @ViewBuilder
    private func sealView(target: SealTarget, scale: CGFloat) -> some View {
        let isActive = editor?.activeDrag == target
        Group {
            switch target {
            case .winner: LargeWinnerSeal()
            case .loser:  LargeLoserCross()
            }
        }
        .scaleEffect(scale * (isActive ? 1.12 : 1.0))
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }

    private func sealDragGesture(target: SealTarget, imageRect: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard editor != nil else { return }
                editor?.onSealDragChanged(target, value.location, imageRect)
            }
            .onEnded { _ in
                guard editor != nil else { return }
                editor?.onSealDragEnded(target)
            }
    }

    /// Image displayed at `.scaledToFill` semantics: scale = max(c/w, c/h),
    /// center the (possibly oversized) image rect. Returned rect may extend
    /// outside the container — caller clips.
    private func filledPhotoRect(photo: UIImage, in containerSize: CGSize) -> CGRect {
        let scale = max(
            containerSize.width / max(photo.size.width, 1),
            containerSize.height / max(photo.size.height, 1)
        )
        let displaySize = CGSize(width: photo.size.width * scale, height: photo.size.height * scale)
        let origin = CGPoint(
            x: (containerSize.width - displaySize.width) / 2,
            y: (containerSize.height - displaySize.height) / 2
        )
        return CGRect(origin: origin, size: displaySize)
    }

    private func displayPoint(for coord: SealCoord, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + CGFloat(coord.x) * rect.width,
            y: rect.minY + CGFloat(coord.y) * rect.height
        )
    }

    // MARK: - No-photo path

    /// E2 — no photo path. Same Locket-style square + rounded corners, but the
    /// surface is a cinnabar-tinted card with the 印 seal centered.
    private var noPhotoZone: some View {
        ZStack {
            // Cinnabar card body — pulls a hair brighter than the lacquer ground.
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.phormSurfaceCinnabar.opacity(0.95),
                            Color.phormSurfaceCinnabarDeep
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .strokeBorder(Color.phormPrimary.opacity(0.28), lineWidth: 1)

            // Centered 印 — bigger, no decorative box around it; the rounded card
            // is the container now.
            Text("印")
                .font(.system(size: 320, weight: .heavy, design: .serif))
                .foregroundStyle(Color.phormPrimary)
                .shadow(color: .black.opacity(0.30), radius: 8, y: 4)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .shadow(color: .black.opacity(0.35), radius: 24, y: 14)
    }

    // MARK: - Ranking strip — manuscript-table layout

    /// Team-page treatment: every player reads at the same weight. Champion is
    /// marked with a small 壹 seal next to the name (gold), last seat with a ×
    /// tem chéo when the table has 4+ players. No size hierarchy, no opacity
    /// fades — this is a moment-capture, not a podium.
    private var rankingStrip: some View {
        VStack(spacing: 0) {
            ForEach(Array(ranking.enumerated()), id: \.element.name) { idx, entry in
                rankingRow(
                    rank: idx + 1,
                    name: entry.name,
                    total: entry.total,
                    isWinner: idx == 0 && entry.total > 0,
                    isLastSeat: idx == ranking.count - 1 && ranking.count >= 4
                )
                if idx < ranking.count - 1 {
                    Rectangle()
                        .fill(Color.phormCream.opacity(0.18))
                        .frame(height: 1)
                        .padding(.vertical, 14)
                }
            }
        }
    }

    @ViewBuilder
    private func rankingRow(rank: Int, name: String, total: Int, isWinner: Bool, isLastSeat: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 18) {
            Text(rankGlyph(rank: rank))
                .font(.system(size: 22, weight: .semibold, design: .serif).monospacedDigit())
                .tracking(2.0)
                .foregroundStyle(Color.phormCreamDim)
                .frame(width: 56, alignment: .leading)
            HStack(alignment: .firstTextBaseline, spacing: 14) {
                Text(name)
                    .font(.system(size: 48, weight: .semibold, design: .serif).italic())
                    .foregroundStyle(isWinner ? Color.phormPrimary : Color.phormCream)
                    .lineLimit(1)
                if isWinner {
                    inlineWinnerMark
                } else if isLastSeat {
                    inlineLastMark
                }
            }
            DottedLeader()
                .stroke(
                    Color.phormCream.opacity(0.28),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [0.1, 14])
                )
                .frame(height: 2.5)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
            Text(ScoreFormat.signed(total))
                .font(.system(size: 52, weight: .heavy, design: .serif).monospacedDigit())
                .foregroundStyle(isWinner ? Color.phormPrimary : ScoreFormat.color(for: total))
        }
    }

    /// Small inline 壹 seal beside the winner's name — subtle marker, not a
    /// trophy. Half the size of the on-photo seal.
    private var inlineWinnerMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.phormPrimary)
            Text("壹")
                .font(.system(size: 18, weight: .heavy, design: .serif))
                .foregroundStyle(Color.onPrimary)
        }
        .frame(width: 34, height: 34)
        .rotationEffect(.degrees(-4))
    }

    /// Small inline × beside the last seat's name (4+ player tables only).
    private var inlineLastMark: some View {
        ZStack {
            Capsule()
                .fill(Color.phormCreamDim)
                .frame(width: 24, height: 2)
                .rotationEffect(.degrees(45))
            Capsule()
                .fill(Color.phormCreamDim)
                .frame(width: 24, height: 2)
                .rotationEffect(.degrees(-45))
        }
        .frame(width: 24, height: 24)
    }

    /// "I" for champion, "II"/"III"/"IV" for runners — borrowed from the
    /// matchbox-label / lottery-ticket print register; numeric digits stay
    /// reserved for actual scores.
    private func rankGlyph(rank: Int) -> String {
        switch rank {
        case 1: return "I"
        case 2: return "II"
        case 3: return "III"
        case 4: return "IV"
        case 5: return "V"
        default: return String(format: "%02d", rank)
        }
    }

    // MARK: - Colophon — bottom print mark

    /// Two-line stamped colophon: ẤN ĐIỂM wordmark with flanking ornament dots,
    /// then "sổ điểm bàn bạc" subline tracked wide. Reads like the printer's
    /// imprint at the foot of a lacquered ledger page.
    private var colophon: some View {
        VStack(spacing: 12) {
            HStack(spacing: 24) {
                colophonOrnament(side: .leading)
                Text("ẤN ĐIỂM")
                    .font(.system(size: 36, weight: .heavy, design: .serif))
                    .tracking(10.0)
                    .foregroundStyle(Color.phormGoldBright)
                colophonOrnament(side: .trailing)
            }
            Text("sổ điểm bàn bạc")
                .font(.system(size: 18, weight: .medium, design: .serif))
                .tracking(8.0)
                .foregroundStyle(Color.phormCreamDim)
                .textCase(.uppercase)
        }
    }

    /// Short gold rule with a centered dot — printer's-ornament style.
    @ViewBuilder
    private func colophonOrnament(side: HorizontalAlignment) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.phormPrimary.opacity(0.6))
                .frame(width: 80, height: 1)
            Circle()
                .fill(Color.phormPrimary)
                .frame(width: 4, height: 4)
            Rectangle()
                .fill(Color.phormPrimary.opacity(0.6))
                .frame(width: 16, height: 1)
        }
        .environment(\.layoutDirection, side == .leading ? .leftToRight : .rightToLeft)
    }
}

// MARK: - DottedLeader

/// Horizontal hairline used as the ranking-row's dotted leader.
/// Stroked with `dash: [0.1, n]` + `lineCap: .round` to produce dots, not dashes.
private struct DottedLeader: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Renderer

extension ShareCardView {
    /// Compose `ShareCardView` into a 1080×1920 UIImage via SwiftUI `ImageRenderer`.
    /// Per spec: ~30–80ms on iPhone 14+, acceptable on share tap.
    @MainActor
    static func render(session: Session) -> UIImage? {
        let view = ShareCardView(session: session)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1.0
        renderer.proposedSize = ProposedViewSize(width: Self.exportSize.width, height: Self.exportSize.height)
        return renderer.uiImage
    }
}

// MARK: - Halftone tile (matches LacquerSurface but kept self-contained for the renderer)

private extension UIImage {
    static let shareHalftone: UIImage = {
        let size = CGSize(width: 4, height: 4)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor(red: 0.95, green: 0.91, blue: 0.82, alpha: 0.10).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }()
}
