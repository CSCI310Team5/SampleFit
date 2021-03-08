//
//  DisclosureIndicator.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

struct DisclosureIndicator: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(Color(UIColor.systemGray3))
            .font(Font.headline.bold())
            .scaleEffect(0.85)
    }
}

struct DisclosureIndicator_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            HStack {
                Text("What")
                DisclosureIndicator()
            }
        }
    }
}
