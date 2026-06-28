import SwiftUI

extension View {
    /// Opaque tactile card: surfaceCard fill, soft drop shadow, 1px hairline ring, rounded corners.
    /// Replaces every `Color.black.opacity(...)` card background. `elevated` deepens the shadow
    /// (used for the active/focused leaderboard row).
    func tactileCard(radius: CGFloat = 14, elevated: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return self
            .background(shape.fill(Color.cardSurface))
            .background(shape.fill(Color.cardSurface).shadow(color: .cardShadow, radius: elevated ? 16 : 10, y: elevated ? 4 : 2))
            .overlay(shape.strokeBorder(Color.hairline, lineWidth: 1))
            .clipShape(shape)
    }
}

/// Header round-count badge — Tết-red (day) / gold (night) raised box. `tc-` header chip.
struct RoundBadge: View {
    let count: Int
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        VStack(spacing: 1) {
            Text("Vòng")
                .font(.phormCaptionSection)
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.onPrimary.opacity(0.85))
            Text(String(format: "%02d", count))
                .font(.system(size: 18, weight: .heavy, design: .default).monospacedDigit())
                .foregroundStyle(Color.onPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(shape.fill(Color.phormPrimary))
        // Bottom-bevel strip on the saturated badge — intended tactile depth, not a card overlay.
        .overlay(shape.fill(Color.black.opacity(0.20)).mask(alignment: .bottom) { Rectangle().frame(height: 2) })
        .clipShape(shape)
        .shadow(color: Color.phormPrimary.opacity(0.35), radius: 6, y: 2)
    }
}

/// Capsule status pill — round-entry "Tổng" balance indicator. ok/warn/neutral.
struct StatusPill: View {
    enum Style { case ok, warn, neutral }
    let text: String
    var style: Style = .neutral

    private var fg: Color {
        switch style {
        case .ok: return .scorePositive
        case .warn: return .scoreNegative
        case .neutral: return .phormCreamDim
        }
    }
    private var bg: Color {
        switch style {
        case .ok: return Color.scorePositive.opacity(0.14)
        case .warn: return Color.scoreNegative.opacity(0.14)
        case .neutral: return Color.chipNeutral
        }
    }
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .default).monospacedDigit())
            .foregroundStyle(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule(style: .continuous).fill(bg))
            .overlay(Capsule(style: .continuous).strokeBorder(fg.opacity(0.28), lineWidth: 1))
    }
}
