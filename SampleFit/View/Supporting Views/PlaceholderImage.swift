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
            .fill(Color.allColors.randomElement()!)
            .opacity(Double.random(in: 0.2...0.5))

    }
}

struct PlaceholderImage_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderImage()
    }
}
