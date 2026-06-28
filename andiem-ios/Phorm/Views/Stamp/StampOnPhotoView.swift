import SwiftUI

/// Shared sticker visuals for Đóng dấu — the gold ấn vàng and cream tem chéo
/// landed on a face. Used by both the editor (StampEditorView) and the rendered
/// share card (ShareCardView).
///
/// Sizing convention: intrinsic size is 52pt for the seal, 56pt for the cross.
/// Callers scale via `.scaleEffect(...)` to match the canvas they live on.

/// The gold ấn vàng — 52×52, rounded 6, rotated −7°.
struct LargeWinnerSeal: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.94, green: 0.84, blue: 0.52),
                            Color(red: 0.85, green: 0.70, blue: 0.35),
                            Color(red: 0.72, green: 0.58, blue: 0.26)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.30),
                        startRadius: 0,
                        endRadius: 40
                    )
                )
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.phormPrimary.opacity(0.5), lineWidth: 1.5)
            Text("壹")
                .font(.system(size: 24, weight: .heavy, design: .default))
                .foregroundStyle(Color(red: 0.29, green: 0.08, blue: 0.06))
                .baselineOffset(-1)
        }
        .frame(width: 52, height: 52)
        .rotationEffect(.degrees(-7))
        .shadow(color: .black.opacity(0.4), radius: 6, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.phormPrimary.opacity(0.20))
                .blur(radius: 8)
                .padding(-6)
                .allowsHitTesting(false)
                .zIndex(-1)
        )
    }
}

/// The cream × tem chéo — 56×56, rotated 4°.
struct LargeLoserCross: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.phormCream.opacity(0.92))
                .frame(width: 56, height: 4)
                .rotationEffect(.degrees(45))
                .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
            Capsule()
                .fill(Color.phormCream.opacity(0.92))
                .frame(width: 56, height: 4)
                .rotationEffect(.degrees(-45))
                .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
        }
        .frame(width: 56, height: 56)
        .rotationEffect(.degrees(4))
    }
}
