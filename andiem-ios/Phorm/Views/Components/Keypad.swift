import SwiftUI

/// Custom numeric keypad at the bottom of RoundEntryView.
/// Keys are 3-D tactile: a warm gradient face over a colored ridge, depressing on press + haptic.
/// Save CTA gets the same ridge treatment with a Tết-red fill.
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
                // "Tiếp" — neutral tactile key.
                TactileKey(
                    face: keyFace, ridge: .keyRidge,
                    haptic: { Haptics.nav() },
                    a11yLabel: "Người tiếp theo",
                    action: { onKey(.next) }
                ) {
                    Text("Tiếp")
                        .font(.phormButton)
                        .tracking(1.5)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.bodyText)
                        .frame(width: 90, height: 52)
                }

                // Save CTA — tactile 3D with Tết-red fill.
                TactileKey(
                    face: LinearGradient(
                        colors: canSave ? [Color.phormPrimary, Color.phormPrimaryActive]
                                        : [Color.phormPrimaryDisabled, Color.phormPrimaryDisabled],
                        startPoint: .top, endPoint: .bottom
                    ),
                    ridge: Color.black.opacity(0.30),
                    haptic: { Haptics.success() },
                    a11yLabel: "Lưu vòng",
                    action: { if canSave { onSave() } }
                ) {
                    Text("Lưu vòng")
                        .font(.phormButton)
                        .tracking(2.0)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .disabled(!canSave)
            }
        }
    }

    @ViewBuilder
    private func key(_ kind: KeyKind) -> some View {
        TactileKey(
            face: face(kind),
            ridge: ridge(kind),
            haptic: keyHaptic(kind),
            a11yLabel: keyA11yLabel(kind),
            action: { keyAction(kind) }
        ) {
            keyLabel(for: kind)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
    }

    /// Warm key face gradient (digit/delete keys).
    private var keyFace: LinearGradient {
        LinearGradient(colors: [.keyFaceTop, .keyFaceBottom], startPoint: .top, endPoint: .bottom)
    }
    /// Sign key face gradient (warmer, paired with red/gold glyph ink).
    private var signFace: LinearGradient {
        LinearGradient(colors: [.keySignFaceTop, .keySignFaceBottom], startPoint: .top, endPoint: .bottom)
    }
    /// Sign key gets the sign face; all other keys use the neutral key face.
    private func face(_ kind: KeyKind) -> LinearGradient {
        if case .sign = kind { return signFace }
        return keyFace
    }
    private func ridge(_ kind: KeyKind) -> Color {
        if case .sign = kind { return .keySignRidge }
        return .keyRidge
    }

    /// Haptic fired on press-down — toggle for state-changing keys, tap for digits.
    private func keyHaptic(_ kind: KeyKind) -> () -> Void {
        switch kind {
        case .digit: return { Haptics.tap() }
        case .sign, .delete: return { Haptics.toggle() }
        }
    }

    /// Fires the appropriate callback for each key kind.
    private func keyAction(_ kind: KeyKind) {
        switch kind {
        case .digit(let d): onKey(.digit(d))
        case .sign:         onKey(.sign)
        case .delete:       onKey(.delete)
        }
    }

    /// VoiceOver label for each key.
    private func keyA11yLabel(_ kind: KeyKind) -> String {
        switch kind {
        case .digit(let d): return "\(d)"
        case .sign:         return "Đổi dấu"
        case .delete:       return "Xóa"
        }
    }

    /// Sign-mode accent — mint when add, ochre when subtract. The sign key uses
    /// this for its glyph so the active mode is loud enough that the host won't
    /// mistake `+` for `−` mid-typing.
    private var modeColor: Color {
        sign < 0 ? .scoreNegative : .scorePositive
    }

    @ViewBuilder
    private func keyLabel(for kind: KeyKind) -> some View {
        switch kind {
        case .digit(let d):
            Text("\(d)")
                .font(.phormKeypadDigit)
                .foregroundStyle(Color.bodyText)
        case .sign:
            // Active glyph is bigger and mode-colored; inactive shrinks and dims.
            // Asymmetry is the affordance — the bigger one is what gets typed.
            HStack(spacing: 6) {
                Text("+")
                    .font(.system(size: sign > 0 ? 28 : 18, weight: .bold, design: .default))
                    .foregroundStyle(sign > 0 ? Color.scorePositive : Color.keySignInk.opacity(0.30))
                Text("\u{2212}")
                    .font(.system(size: sign < 0 ? 28 : 18, weight: .bold, design: .default))
                    .foregroundStyle(sign < 0 ? Color.scoreNegative : Color.keySignInk.opacity(0.30))
            }
        case .delete:
            Image(systemName: "delete.left")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.mutedStrong)
        }
    }
}

// MARK: - Tactile key

/// Chunky 3-D key: a rounded face sits over a darker ridge offset 4 pt below.
/// On press the face translates down 3 pt and the ridge shrinks — simulating a
/// physical button depression. A haptic fires on touch-down, the action on release.
private struct TactileKey<Label: View>: View {
    var face: LinearGradient
    var ridge: Color
    var haptic: () -> Void = { Haptics.tap() }
    var a11yLabel: String = ""
    let action: () -> Void
    @ViewBuilder var label: () -> Label
    @GestureState private var pressed = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        label()
            .background(shape.fill(face))
            .background(shape.fill(ridge).offset(y: pressed ? 1 : 4))
            .offset(y: pressed ? 3 : 0)
            .contentShape(shape)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($pressed) { _, s, _ in if !s { s = true; haptic() } }
                    .onEnded { _ in action() }
            )
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: pressed)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(a11yLabel)
    }
}
