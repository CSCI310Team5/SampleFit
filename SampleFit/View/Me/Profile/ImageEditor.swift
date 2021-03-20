//
//  ImageEditor.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/8/21.
//

import SwiftUI

struct ImageEditor: View {
    @ObservedObject var draftProfile: PublicProfile
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack(spacing: 12) {
            CircleImage(image: draftProfile.image!, isEditingActive: true)
                .onTapGesture {
                    self.isImagePickerPresented = true
                }
                
            Button(action: { isImagePickerPresented = true }) {
                Text("Edit")
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $draftProfile.image, isPresented: $isImagePickerPresented)
        }
        
    }
}

struct ImageEditor_Previews: PreviewProvider {
    static var previews: some View {
        ImageEditor(draftProfile: PublicProfile.exampleProfile)
    }
}
