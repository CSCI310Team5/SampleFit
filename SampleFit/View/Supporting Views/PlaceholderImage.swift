//
//  PlaceholderImage.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI

struct PlaceholderImage: View {
    var body: some View {
        Rectangle()
            .fill(Color.systemFill)
    }
}

struct PlaceholderImage_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            PlaceholderImage()
                .frame(width: 240, height: 180)
        }
    }
}
