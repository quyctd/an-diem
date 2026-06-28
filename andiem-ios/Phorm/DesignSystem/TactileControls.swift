import SwiftUI

// MARK: - Buttons

/// Tết-red (day) / gold (night) filled CTA — radius 13, bottom bevel, depresses on press.
/// Matches `.tc-btn` in themes-preview.html.
struct TactilePrimaryButton: View {
    let title: String
    var enabled: Bool = true
    var action: () -> Void
    @GestureState private var pressed = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .continuous)
        Text(title)
            .font(.phormButton)
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundStyle(Color.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(shape.fill(enabled ? Color.phormPrimary : Color.phormPrimaryDisabled))
            // Bottom-bevel strip on a saturated fill — intended tactile depth, not a card overlay.
            .overlay(shape.fill(Color.black.opacity(0.18)).mask(alignment: .bottom) { Rectangle().frame(height: 3) })
            .clipShape(shape)
            .offset(y: pressed ? 2 : 0)
            .contentShape(shape)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($pressed) { _, s, _ in if !s { s = true; Haptics.tap() } }
                    .onEnded { _ in if enabled { action() } }
            )
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: pressed)
            .disabled(!enabled)
    }
}

/// Outlined secondary CTA — transparent fill, accent border + text, radius 13.
/// Paired with primary, e.g. "Chia sẻ" + "Phiên mới" on end-of-session.
struct TactileOutlineButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.phormButton)
                .tracking(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.phormPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(Color.phormPrimary, lineWidth: 1)
                )
                // Stroke-only background isn't opaque, so SwiftUI's hit area
                // collapses to the text. Force the full frame to be tappable.
                .contentShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
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

// MARK: - Rules

/// 1px adaptive divider — subtle dark on day, subtle light on night.
struct RuleHairline: View {
    var body: some View {
        Rectangle().fill(Color.hairline).frame(height: 1)
    }
}

/// 2px gold gradient rule (fades at both ends) — summary header divider.
struct GoldRule: View {
    var body: some View {
        LinearGradient(colors: [.clear, .phormGoldBright, .clear], startPoint: .leading, endPoint: .trailing)
            .frame(height: 2)
            .opacity(0.6)
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
