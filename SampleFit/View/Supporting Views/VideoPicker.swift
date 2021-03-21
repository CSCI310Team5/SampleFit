//
//  VideoPicker.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/20/21.
//

import SwiftUI
import PhotosUI
import AVKit
import AVFoundation

/// You can use VideoPicker to select a single video from the user's photo library.
struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Binding var isLoading: Bool
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.videos])
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        var parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            if let result = results.first, let typeIdentifier = result.itemProvider.registeredTypeIdentifiers.first {
                DispatchQueue.main.async {
                    self.parent.isLoading = true
                }
                
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                    guard let url = url else {
                        print("VideoPicker: No URL returned.")
                        return
                    }

                    // copy video at temporary URL to a location we control
                    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let targetURL = documentDirectory.appendingPathComponent(url.lastPathComponent)
                    
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try? FileManager.default.removeItem(at: targetURL)
                    }
                    
                    try? FileManager.default.copyItem(at: url, to: targetURL)
                    self.parent.videoURL = targetURL
                    self.parent.isLoading = false
                }
            }
        }
    }
    
}

struct VideoPicker_Preview: View {
    @State private var url: URL?
    @State private var isLoading = false
    @State private var isPresented = false
    var body: some View {
        VStack {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    if url != nil {
                        VideoPlayer(player: AVPlayer(url: url!))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .frame(height: 250)
            
            Button("Choose Video", action: { isPresented = true })
        }
        .sheet(isPresented: $isPresented) {
            VideoPicker(videoURL: $url, isLoading: $isLoading, isPresented: $isPresented)
        }
    }
}

struct VideoPicker_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ImagePicker_Preview()
        }
    }
}
