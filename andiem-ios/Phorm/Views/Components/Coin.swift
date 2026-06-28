import SwiftUI

/// Round seat / winner token — the tactile "coin". Matches `tc-coin*` in themes-preview.html.
struct Coin: View {
    enum Variant { case seat, winner, last, active }

    let text: String
    var variant: Variant = .seat
    var size: CGFloat = 32

    private var fill: AnyShapeStyle {
        switch variant {
        case .seat, .active:
            return AnyShapeStyle(Color.coinSeat)
        case .winner:
            return AnyShapeStyle(LinearGradient(colors: Color.coinGoldStops, startPoint: .topLeading, endPoint: .bottomTrailing))
        case .last:
            return AnyShapeStyle(Color.lastMarkerFill)
        }
    }
    private var textColor: Color {
        switch variant {
        case .seat, .active: return .phormCreamDim
        case .winner:        return Color(red: 0x4A/255, green: 0x28/255, blue: 0x00/255) // #4A2800
        case .last:          return .lastMarkerInk
        }
    }
    private var bevel: Color {
        switch variant {
        case .seat, .active: return .coinSeatBevel
        case .winner:        return Color(red: 0xC8/255, green: 0x92/255, blue: 0x0D/255) // #C8920D
        case .last:          return .lastMarkerBevel
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.44, weight: .bold, design: .default).monospacedDigit())
            .foregroundStyle(textColor)
            .frame(width: size, height: size)
            .background(
                Circle().fill(fill)
                    .overlay(
                        Circle().fill(bevel)
                            .mask(alignment: .bottom) { Rectangle().frame(height: 2) }
                    )
                    .clipShape(Circle())
            )
            .overlay(Circle().strokeBorder(variant == .active ? Color.phormPrimary : .clear, lineWidth: 2))
            .shadow(color: .black.opacity(0.10), radius: 2, y: 1)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 14) {
        Coin(text: "1", variant: .winner, size: 40)
        Coin(text: "2")
        Coin(text: "3", variant: .active)
        Coin(text: "×", variant: .last)
    }.padding().background(Color.phormSurfaceCinnabar)
}
