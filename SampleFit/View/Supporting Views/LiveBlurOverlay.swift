//
//  LiveBlurOverlay.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/23/21.
//

import SwiftUI

struct LiveBlurOverlay: View {
    var body: some View {
        Text("LIVE")
            .foregroundColor(.white)
            .font(.subheadline)
            .bold()
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                BlurView()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            )
            .padding(6)
        
    }
}


struct LiveBlurOverlay_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            LiveBlurOverlay()
        }
    }
}
