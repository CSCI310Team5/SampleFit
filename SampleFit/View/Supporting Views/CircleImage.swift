//
//  CircleImage.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/8/21.
//

import SwiftUI

struct CircleImage: View {
    var image: UIImage?
    var isEditingActive = false
    var body: some View {
        Image(uiImage: (image ?? UIImage(systemName: "person.fill.questionmark"))!)
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
            CircleImage(image: UIImage(systemName: "jogging-1")!)
        }
    }
}
