import SwiftUI

/// Round seat / winner token — the tactile "coin". Replaces the square Seal.
/// Matches `tc-coin*` in themes-preview.html.
struct Coin: View {
    enum Variant { case seat, winner, last }

    let text: String
    var variant: Variant = .seat
    var size: CGFloat = 32

    private var fill: AnyShapeStyle {
        switch variant {
        case .seat:   return AnyShapeStyle(Color.surfaceTile)
        case .winner: return AnyShapeStyle(RadialGradient(colors: [Color.phormGoldBright, Color.phormGoldBright.opacity(0.78)], center: .topLeading, startRadius: 1, endRadius: size))
        case .last:   return AnyShapeStyle(Color.scoreNegative.opacity(0.16))
        }
    }
    private var textColor: Color {
        switch variant {
        case .seat:   return .phormCreamDim
        case .winner: return Color(red: 0x3A/255, green: 0x22/255, blue: 0x06/255)
        case .last:   return .scoreNegative
        }
    }
    private var ring: Color {
        switch variant {
        case .seat:   return .phormCreamStroke
        case .winner: return .phormGoldBright
        case .last:   return .scoreNegative.opacity(0.5)
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.46, weight: .bold, design: .default).monospacedDigit())
            .foregroundStyle(textColor)
            .frame(width: size, height: size)
            .background(Circle().fill(fill))
            .overlay(Circle().strokeBorder(ring, lineWidth: variant == .seat ? 1 : 2))
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 14) {
        Coin(text: "1", variant: .winner, size: 40)
        Coin(text: "2")
        Coin(text: "4", variant: .last)
    }.padding().background(Color.phormSurfaceCinnabar)
}
