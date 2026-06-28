import SwiftUI

/// Color-filled tactile score tile — the card-table "piece". Up = green, down = coral,
/// zero/empty = neutral. White tabular number with explicit +/− sign. Matches `tc-chip-*`.
struct ScoreChip: View {
    enum Size { case small, large }

    let value: Int?
    var size: Size = .small
    var isFocused: Bool = false

    private var fill: Color {
        switch value ?? 0 {
        case let v where v > 0: return .scorePositive
        case let v where v < 0: return .scoreNegative
        default:                return .chipNeutral
        }
    }
    private var label: String { value == nil ? "0" : ScoreFormat.signed(value!) }
    private var isZeroOrEmpty: Bool { (value ?? 0) == 0 }
    private var dims: (w: CGFloat, h: CGFloat, font: CGFloat, radius: CGFloat) {
        size == .large ? (82, 50, 30, 16) : (58, 36, 20, 11)
    }
    /// Bottom-bevel ink matched to the fill semantics (tc-chip).
    private var bevel: Color {
        switch value ?? 0 {
        case let v where v > 0: return .chipUpBevel
        case let v where v < 0: return .chipDownBevel
        default:                return .chipNeutralBevel
        }
    }
    /// Colored ambient glow under up/down chips; none for neutral.
    private var glow: Color {
        switch value ?? 0 {
        case let v where v > 0: return Color.scorePositive.opacity(0.30)
        case let v where v < 0: return Color.scoreNegative.opacity(0.30)
        default:                return .clear
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: dims.font, weight: .heavy, design: .default).monospacedDigit())
            .foregroundStyle(isZeroOrEmpty ? Color.phormMuted : Color.onChip)
            .frame(width: dims.w, height: dims.h)
            .background(
                RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                    .fill(fill)
                    // Bottom-bevel strip — tactile depth on the chip's own fill.
                    .overlay(
                        RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                            .fill(bevel)
                            .mask(alignment: .bottom) { Rectangle().frame(height: 3) }
                    )
                    .shadow(color: glow, radius: 14, y: 4)
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            )
            // Focus ring: surface-gap then accent ring (tc-chip-focus).
            .overlay(
                RoundedRectangle(cornerRadius: dims.radius + 2.5, style: .continuous)
                    .strokeBorder(Color.phormSurfaceCinnabar, lineWidth: isFocused ? 2.5 : 0)
                    .padding(-2.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: dims.radius + 5, style: .continuous)
                    .strokeBorder(Color.phormPrimary, lineWidth: isFocused ? 2.5 : 0)
                    .padding(-5)
            )
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: size)
            .accessibilityLabel(Text(label))
    }
}

#Preview {
    HStack(spacing: 12) {
        ScoreChip(value: 12, size: .large, isFocused: true)
        ScoreChip(value: -7)
        ScoreChip(value: 0)
        ScoreChip(value: nil)
    }
    .padding()
    .background(Color.phormSurfaceCinnabar)
}
