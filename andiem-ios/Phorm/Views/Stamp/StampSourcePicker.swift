import SwiftUI
import PhotosUI
import UIKit

/// F2 — Đóng dấu source picker.
/// Lacquer-styled bottom sheet (NOT iOS native action sheet) per c39164d precedent.
/// Drag handle + 2 source tiles (Chụp ngay gold-outlined / Thư viện cream-outlined) + Hủy text.
struct StampSourcePicker: View {
    @Binding var isPresented: Bool
    var onPick: (UIImage) -> Void

    @State private var pickerItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: Spacing.lg)

            SectionLabel(text: "Chọn ảnh nhóm", tone: .gold)
            Text("— cho khoảnh khắc đóng ấn —")
                .font(.phormCaptionSection)
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.phormCreamDim)
                .padding(.top, 4)

            HStack(spacing: Spacing.sm) {
                cameraTile
                libraryTile
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)

            Button {
                isPresented = false
            } label: {
                Text("Hủy")
                    .font(.phormCaptionSection)
                    .tracking(1.6)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.phormCreamDim)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .photosPicker(
            isPresented: Binding(
                get: { pickerItem == nil && pickerOpen },
                set: { if !$0 { pickerOpen = false } }
            ),
            selection: $pickerItem,
            matching: .images
        )
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        onPick(image)
                        pickerItem = nil
                        pickerOpen = false
                    }
                } else {
                    await MainActor.run { pickerItem = nil }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                showCamera = false
                if let image { onPick(image) }
            }
            .ignoresSafeArea()
        }
    }

    @State private var pickerOpen = false

    private var cameraTile: some View {
        Button {
            Haptics.tap()
            showCamera = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "camera")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Color.phormPrimary)
                Text("Chụp ngay")
                    .font(.phormCaptionSection)
                    .tracking(1.6)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.phormPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.phormPrimary.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.phormPrimary, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var libraryTile: some View {
        Button {
            Haptics.tap()
            pickerOpen = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Color.phormCream)
                Text("Thư viện")
                    .font(.phormCaptionSection)
                    .tracking(1.6)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.phormCream)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.black.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.phormCream.opacity(0.34), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Camera (UIImagePickerController wrapper)

/// `UIImagePickerController(sourceType: .camera)` wrapped for SwiftUI.
/// Per spec §iOS native pieces: "Modern alternative AVFoundation is overkill for one snap."
struct CameraPicker: UIViewControllerRepresentable {
    var onCapture: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // Fall back to the photo library if camera isn't available (e.g. simulator).
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage?) -> Void
        init(onCapture: @escaping (UIImage?) -> Void) { self.onCapture = onCapture }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true) { [onCapture] in onCapture(image) }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) { [onCapture] in onCapture(nil) }
        }
    }
}

