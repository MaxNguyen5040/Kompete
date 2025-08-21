import SwiftUI

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    var onPicked: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
//        print("Creating video player view")
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary // Use the photo library as the source
        picker.mediaTypes = ["public.movie"] // Restrict to videos only
        picker.delegate = context.coordinator // Set the delegate to the coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL { // Get the selected video's URL
                parent.videoURL = url
                parent.onPicked() // Call the completion handler to process the video
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
