import SwiftUI

extension View {
    /// Continuous-corner squircle clip. Enforces the iOS platform corner curve everywhere.
    func continuousRounded(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// 1px top-edge specular highlight on glass surfaces (DESIGN.md `glass-specular`).
    func glassSpecularTop() -> some View {
        overlay(alignment: .top) {
            LinearGradient(
                colors: [Color.white.opacity(0.14), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 1)
            .allowsHitTesting(false)
        }
    }
}
