import SwiftUI
import UIKit

/// Wraps `UIActivityViewController` with the rendered UIImage as the activity item.
/// Passing UIImage directly (not a tmp file URL) ensures iOS treats the share as
/// an image — "Save Image" appears in the activity list and Locket/Messages/
/// Mail embed it inline rather than as a file attachment.
struct ShareSheet: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
