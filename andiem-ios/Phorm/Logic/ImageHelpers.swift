import Foundation
import UIKit

/// Đóng dấu — photo processing pipeline.
/// Spec §Photo processing pipeline: EXIF normalize → downscale (longest edge 1080) → JPEG q=0.82.
enum ImageHelpers {
    /// Output target: longest edge of the persisted JPEG.
    /// 1080 matches the share-card export resolution so the photo never has to
    /// upscale on render.
    static let maxLongestEdge: CGFloat = 1080

    /// JPEG quality picked empirically — halves file size vs 0.95 with imperceptible
    /// loss at this resolution.
    static let jpegQuality: CGFloat = 0.82

    /// Apply EXIF rotation, downscale, and JPEG-compress an incoming UIImage.
    /// Returns nil only if JPEG encoding fails (extremely rare).
    static func normalizeForStamp(_ image: UIImage) -> Data? {
        let upright = redrawWithoutOrientation(image)
        let scaled = downscale(upright, longestEdge: maxLongestEdge)
        return scaled.jpegData(compressionQuality: jpegQuality)
    }

    /// Redraw a UIImage so its pixel data reflects the EXIF-applied orientation.
    /// Without this, `.imageOrientation` is metadata and tap coords on the
    /// displayed image won't match coords against the underlying CGImage.
    static func redrawWithoutOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    /// Scale so the longest edge ≤ `longestEdge`. Pass-through if already smaller.
    static func downscale(_ image: UIImage, longestEdge: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > longestEdge else { return image }
        let scale = longestEdge / longest
        let newSize = CGSize(
            width: floor(image.size.width * scale),
            height: floor(image.size.height * scale)
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0  // pixels match logical size — keeps file small
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Convenience: decode persisted JPEG back to a UIImage for display.
    static func image(from data: Data?) -> UIImage? {
        guard let data else { return nil }
        return UIImage(data: data)
    }
}
