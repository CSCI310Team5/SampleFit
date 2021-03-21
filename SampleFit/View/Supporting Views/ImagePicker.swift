//
//  ImagePicker.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/8/21.
//

import SwiftUI
import PhotosUI

/// You can use ImagePicker to select a single image from the user's photo album.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        guard let image = image as? UIImage else {
                            print("ImagePicker: image loading error.")
                            return
                        }
//                        let newImage = Image(uiImage: image)
                        self.parent.image = image
                    }
                }
            } else {
                // image cannot be loaded
                print("ImagePicker: no loadable item.")
            }
            
        }
    }
    
}

struct ImagePicker_Preview: View {
    @State private var image = UIImage(systemName: "person.fill.questionmark")
    @State private var isPresented = false
    var body: some View {
        Image(uiImage: image!)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray, lineWidth: 0.25))
            .onTapGesture {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                ImagePicker(image: $image, isPresented: $isPresented)
            }
    }
}

struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ImagePicker_Preview()
        }
    }
}
