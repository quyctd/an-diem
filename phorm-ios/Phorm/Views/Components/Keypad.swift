import SwiftUI

/// Custom numeric keypad — lives at the bottom of RoundEntryView on lacquer.
/// Sharp 2pt corners, dark tint, cream ink. Save CTA is the gold primary button.
struct Keypad: View {
    let onKey: (KeypadKey) -> Void
    let onSave: () -> Void
    let canSave: Bool
    /// Current sticky sign — drives the `+`/`−` highlight in the sign key.
    /// Pass `+1` or `-1`; defaults to `+1` if not supplied (preserves the older callsite).
    var sign: Int = 1

    private let layout: [[KeyKind]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.sign,     .digit(0), .delete]
    ]

    private enum KeyKind {
        case digit(Int)
        case sign
        case delete
    }

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 6) {
                ForEach(0..<layout.count, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<layout[row].count, id: \.self) { col in
                            key(layout[row][col])
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                Button {
                    Haptics.nav()
                    onKey(.next)
                } label: {
                    Text("Tiếp")
                        .font(.phormButton)
                        .tracking(1.5)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.phormCream)
                        .frame(width: 90, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(Color.phormCream.opacity(0.30), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                LacquerPrimaryButton(
                    title: "Đóng dấu — lưu vòng",
                    enabled: canSave,
                    action: {
                        Haptics.success()
                        onSave()
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func key(_ kind: KeyKind) -> some View {
        Button {
            switch kind {
            case .digit(let d):
                Haptics.tap()
                onKey(.digit(d))
            case .sign:
                Haptics.toggle()
                onKey(.sign)
            case .delete:
                Haptics.toggle()
                onKey(.delete)
            }
        } label: {
            keyLabel(for: kind)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(keyBackgroundFill(kind))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .stroke(signKeyBorderColor(kind), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    /// Sign-mode accent — mint when add, ochre when subtract. The sign key uses
    /// this for its glyph, border, and background tint so the active mode is
    /// loud enough that the host won't mistake `+` for `−` mid-typing.
    private var modeColor: Color {
        sign < 0 ? .scoreNegative : .scorePositive
    }

    /// Sign key border picks up the mode color at 0.7 opacity — strong enough
    /// to read as "this key is what colors the cells above."
    private func signKeyBorderColor(_ kind: KeyKind) -> Color {
        if case .sign = kind { return modeColor.opacity(0.70) }
        return Color.phormCream.opacity(0.18)
    }

    /// Background of the sign key gets a faint mode-color wash on top of the
    /// utility-key dark tint — same trick as the focused cell.
    private func keyBackgroundFill(_ kind: KeyKind) -> Color {
        if case .sign = kind { return modeColor.opacity(0.18) }
        return isUtility(kind) ? Color.black.opacity(0.28) : Color.black.opacity(0.18)
    }

    @ViewBuilder
    private func keyLabel(for kind: KeyKind) -> some View {
        switch kind {
        case .digit(let d):
            Text("\(d)")
                .font(.phormKeypadDigit)
                .foregroundStyle(Color.phormCream)
        case .sign:
            // Active glyph is bigger and mode-colored; inactive shrinks and dims.
            // Asymmetry is the affordance — the bigger one is what gets typed.
            HStack(spacing: 6) {
                Text("+")
                    .font(.system(size: sign > 0 ? 28 : 18, weight: .bold, design: .serif))
                    .foregroundStyle(sign > 0 ? Color.scorePositive : Color.phormCream.opacity(0.22))
                Text("\u{2212}")
                    .font(.system(size: sign < 0 ? 28 : 18, weight: .bold, design: .serif))
                    .foregroundStyle(sign < 0 ? Color.scoreNegative : Color.phormCream.opacity(0.22))
            }
        case .delete:
            Image(systemName: "delete.left")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.phormCreamDim)
        }
    }

    private func isUtility(_ k: KeyKind) -> Bool {
        switch k { case .sign, .delete: return true; case .digit: return false }
    }
}
