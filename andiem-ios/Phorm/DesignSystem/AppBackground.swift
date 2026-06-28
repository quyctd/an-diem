import SwiftUI
import UIKit

/// Adaptive tactile surface background — flat on day (light appearance), with subtle grain on night (dark appearance).
/// Replaces Liquid Glass and the prior halftone/vignette layers entirely.
///
/// Dark mode only: overlays a 25% grain tile (`.overlay` blend) on top of the deep warm night surface.
/// Day/light mode: the surface color is rendered flat — no halftone, no grain.
///
/// The grain tile is precomputed once into a tileable UIImage so re-renders don't redraw thousands of paths.
struct AppBackground: View {
    var surface: Color = .phormSurfaceCinnabar
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            surface
            if scheme == .dark {
                Image(uiImage: .phormGrain)
                    .resizable(resizingMode: .tile)
                    .blendMode(.overlay)
                    .opacity(0.25)
                    .allowsHitTesting(false)
            }
        }
    }
}

extension View {
    /// Apply the adaptive surface background to the view's background.
    /// Use this on the *root* of every screen — day surfaces are flat; night surfaces add a subtle grain overlay.
    func appBackground(_ surface: Color = .phormSurfaceCinnabar) -> some View {
        background(AppBackground(surface: surface).ignoresSafeArea())
    }
}

// MARK: - Precomputed texture tiles

private extension UIImage {
    /// 4×4 tile with one cream pinprick — currently unused / retired from the surface system.
    /// Halftone-dot compositing was removed when the design moved to flat day surfaces + night-only grain.
    /// This tile is kept for reference but is not applied by any active view.
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
