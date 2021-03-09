//
//  CircleImage.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/8/21.
//

import SwiftUI

struct CircleImage: View {
    var image: Image
    var isEditingActive = false
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(isEditingActive ? Color.blue : Color.gray, lineWidth: isEditingActive ? 2 : 0.25))
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            CircleImage(image: Image("jogging-1"))
        }
    }
}
