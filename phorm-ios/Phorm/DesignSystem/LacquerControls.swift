import SwiftUI

// MARK: - Buttons

/// Gold-filled primary CTA — uppercase, tracked, sharp 3pt radius.
/// Matches `.h-btn-primary` in themes-preview.html.
struct LacquerPrimaryButton: View {
    let title: String
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.phormButton)
                .tracking(2.0)
                .textCase(.uppercase)
                .foregroundStyle(Color.onPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(enabled ? Color.phormPrimary : Color.phormPrimaryDisabled)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.25), radius: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// Gold-outlined secondary CTA — transparent fill, gold border, gold text.
/// Paired with primary, e.g. "Chia sẻ" + "Phiên mới" on end-of-session.
struct LacquerOutlineButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.phormButton)
                .tracking(2.0)
                .textCase(.uppercase)
                .foregroundStyle(Color.phormPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .stroke(Color.phormPrimary, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section label

/// Small uppercase letter-spaced label — "PHIÊN ĐANG CHƠI", "VÒNG", "TỔNG", "VÔ ĐỊCH VÁN".
/// 9pt Spectral 500, tracking 0.18em. Cream-dim default, gold-bright variant for hero contexts.
struct SectionLabel: View {
    let text: String
    var tone: Tone = .dim

    enum Tone { case dim, gold }

    var body: some View {
        Text(text)
            .font(.phormCaptionSection)
            .tracking(1.6)
            .textCase(.uppercase)
            .foregroundStyle(tone == .gold ? Color.phormGoldBright : Color.phormCreamDim)
    }
}

// MARK: - Hairlines

/// 1px cream hairline at 18% opacity — primary section divider.
struct LacquerHairline: View {
    var body: some View {
        Rectangle()
            .fill(Color.phormCream.opacity(0.18))
            .frame(height: 1)
    }
}

/// 2px cream rule at 32% opacity — thicker divider for hero headers.
struct LacquerThickRule: View {
    var body: some View {
        Rectangle()
            .fill(Color.phormCream.opacity(0.32))
            .frame(height: 2)
    }
}

// MARK: - Score formatting

enum ScoreFormat {
    /// Signed display: +5, −3, 0. Uses U+2212 (true minus) — wider than hyphen, balances `+`.
    static func signed(_ value: Int) -> String {
        if value > 0 { return "+\(value)" }
        if value < 0 { return "\u{2212}\(abs(value))" }
        return "0"
    }

    static func color(for value: Int) -> Color {
        if value > 0 { return .scorePositive }
        if value < 0 { return .scoreNegative }
        return .phormCream
    }
}
