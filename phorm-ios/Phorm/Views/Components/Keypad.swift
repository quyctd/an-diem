import SwiftUI

struct Keypad: View {
    let onKey: (KeypadKey) -> Void
    let onSave: () -> Void
    let canSave: Bool

    private let layout: [[KeyKind]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.sign,     .digit(0), .delete]
    ]

    private enum KeyKind { case digit(Int), sign, delete }

    var body: some View {
        // DESIGN.md: keypad inherits the sheet's thickMaterial — no own background
        // (avoids "glass on glass" stacking).
        VStack(spacing: 6) {
            ForEach(0..<layout.count, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<layout[row].count, id: \.self) { col in
                        key(layout[row][col])
                    }
                }
            }
            // PLAN.md §8: keypad has a Next button (jumps focus past auto-fill row).
            Button { onKey(.next) } label: {
                Text("Tiếp →")
                    .font(.phormButton)
                    .foregroundStyle(Color.bodyText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.surfaceCard)
                    .continuousRounded(Radius.md)
            }
            Button(action: onSave) {
                Text("Lưu ván →")
                    .font(.phormButton)
                    .foregroundStyle(Color.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(canSave ? Color.phormPrimary : Color.phormPrimaryDisabled)
                    .continuousRounded(Radius.lg)
            }
            .disabled(!canSave)
        }
        .padding(8)
    }

    @ViewBuilder
    private func key(_ kind: KeyKind) -> some View {
        Button {
            switch kind {
            case .digit(let d): onKey(.digit(d))
            case .sign:         onKey(.sign)
            case .delete:       onKey(.delete)
            }
        } label: {
            Group {
                switch kind {
                case .digit(let d): Text("\(d)").font(.phormKeypadDigit)
                case .sign:         Image(systemName: "plus.forwardslash.minus").font(.system(size: 22))
                case .delete:       Image(systemName: "delete.left.fill").font(.system(size: 22))
                }
            }
            .foregroundStyle(Color.bodyText)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isUtility(kind) ? Color.surfaceCard : Color.surfaceElevated)
            .continuousRounded(Radius.md)
        }
    }

    private func isUtility(_ k: KeyKind) -> Bool {
        switch k { case .sign, .delete: return true; case .digit: return false }
    }
}
