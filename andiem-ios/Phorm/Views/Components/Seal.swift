import SwiftUI

/// Rank seal — the "ấn vàng" / "tem chéo" gold-leaf box from themes-preview.html.
/// Three variants:
///   - `.winner`: solid gold fill, cinnabar-deep glyph, glow halo. Position 1 only.
///   - `.last`:   cream-dim border + cream-dim ×. Renders in 4+ player sessions.
///   - `.default`: gold border + faint gold tint + gold Hán-Việt numeral. Mid ranks.
struct Seal: View {
    enum Variant { case `default`, winner, last }

    let glyph: String
    var variant: Variant = .default
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(fillColor)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1.5)
            Text(glyph)
                .font(.system(size: glyphSize, weight: .heavy, design: .default))
                .foregroundStyle(glyphColor)
                .baselineOffset(-1)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(variant == .last ? 2 : -3))
        .shadow(
            color: variant == .winner ? .phormPrimary.opacity(0.32) : .clear,
            radius: variant == .winner ? 2 : 0,
            y: 0
        )
        .accessibilityHidden(true)
    }

    private var fillColor: Color {
        switch variant {
        case .winner:  return .phormPrimary
        case .default: return .phormPrimary.opacity(0.08)
        case .last:    return .clear
        }
    }
    private var borderColor: Color {
        switch variant {
        case .winner:  return .phormPrimary
        case .default: return .phormPrimary
        case .last:    return .phormCreamDim
        }
    }
    private var glyphColor: Color {
        switch variant {
        case .winner:  return .onPrimary
        case .default: return .phormPrimary
        case .last:    return .phormCreamDim
        }
    }
    private var glyphSize: CGFloat { size * 0.58 }
}

/// Rank numerals for tokens — plain Arabic so a Vietnamese player reads them instantly.
enum SealGlyph {
    static func forRank(_ rank: Int) -> String { rank >= 1 ? "\(rank)" : "" }
}

#Preview {
    ZStack {
        AppBackground().ignoresSafeArea()
        VStack(spacing: 24) {
            HStack(spacing: 18) {
                Seal(glyph: SealGlyph.forRank(1), variant: .winner)
                Seal(glyph: SealGlyph.forRank(2))
                Seal(glyph: SealGlyph.forRank(3))
                Seal(glyph: SealGlyph.forRank(4), variant: .last)
            }
            HStack(spacing: 12) {
                Seal(glyph: "封", variant: .winner, size: 22)
                Seal(glyph: "Bét", variant: .last, size: 22)
            }
        }
    }
}
