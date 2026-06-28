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
        size == .large ? (82, 50, 30, 16) : (58, 36, 20, 14)
    }

    var body: some View {
        Text(label)
            .font(.system(size: dims.font, weight: .heavy, design: .default).monospacedDigit())
            .foregroundStyle(isZeroOrEmpty ? Color.phormMuted : Color.onChip)
            .frame(width: dims.w, height: dims.h)
            .background(
                RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                    .fill(fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                            .fill(Color.black.opacity(0.12))
                            .mask(alignment: .bottom) { Rectangle().frame(height: 3) }
                    )
                    .shadow(color: fill.opacity(0.35), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: dims.radius, style: .continuous)
                    .strokeBorder(Color.phormPrimary, lineWidth: isFocused ? 3 : 0)
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
