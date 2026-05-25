import SwiftUI
import UIKit

/// Hà Nội cũ lacquer surface — replaces Liquid Glass entirely.
/// Mirrors `.hanoi` in `themes-preview.html`:
///   1. drenched cinnabar (or alternate surface) base
///   2. warm vignette (radial gradients)
///   3. halftone dots (4pt grid, screen blend)
///   4. paper grain (fractal noise, overlay blend)
///
/// The halftone + grain textures are precomputed once into tileable UIImages
/// so re-renders don't redraw thousands of paths.
struct LacquerBackground: View {
    var surface: Color = .phormSurfaceCinnabar

    var body: some View {
        ZStack {
            surface

            // Warm vignette — center brightens, corners deepen
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.86, blue: 0.70).opacity(0.10),
                    .clear,
                    Color.black.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Halftone dots, screen blend
            Image(uiImage: .phormHalftone)
                .resizable(resizingMode: .tile)
                .blendMode(.screen)
                .allowsHitTesting(false)

            // Paper grain, overlay blend
            Image(uiImage: .phormGrain)
                .resizable(resizingMode: .tile)
                .blendMode(.overlay)
                .opacity(0.55)
                .allowsHitTesting(false)
        }
    }
}

extension View {
    /// Drench the view's background in one lacquer surface with halftone + grain.
    /// Use this on the *root* of every screen — content sits directly on top.
    func lacquerBackground(_ surface: Color = .phormSurfaceCinnabar) -> some View {
        background(LacquerBackground(surface: surface).ignoresSafeArea())
    }
}

// MARK: - Precomputed texture tiles

private extension UIImage {
    /// 4×4 tile with one cream pinprick — composites into the halftone dot grid.
    static let phormHalftone: UIImage = {
        let size = CGSize(width: 4, height: 4)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor(red: 0.95, green: 0.91, blue: 0.82, alpha: 0.10).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }()

    /// 200×200 deterministic grain tile — re-seeded each app launch but stable across renders.
    static let phormGrain: UIImage = {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        var rng = SeededRandom(seed: 0xC0FFEE)
        return renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            for _ in 0..<7000 {
                let x = CGFloat(rng.nextUnit()) * size.width
                let y = CGFloat(rng.nextUnit()) * size.height
                let dark = rng.nextUnit() < 0.55
                let alpha = CGFloat(rng.nextUnit()) * 0.18 + 0.04
                let color: UIColor = dark
                    ? UIColor(white: 0.05, alpha: alpha)
                    : UIColor(red: 0.95, green: 0.92, blue: 0.85, alpha: alpha * 0.6)
                color.setFill()
                ctx.cgContext.fillEllipse(in: CGRect(x: x, y: y, width: 1.2, height: 1.2))
            }
        }
    }()
}

/// xorshift64 — small, fast, deterministic. Only used to bake the grain tile once.
private struct SeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
    mutating func nextUnit() -> Double {
        Double(next() & 0xFFFFFF) / Double(0xFFFFFF)
    }
}
