//
//  FractionalWidthView.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct FractionalWidthView<Content: View>: View {
    var fraction: CGFloat
    var content: Content
    init(fraction: CGFloat, content: () -> Content) {
        self.fraction = fraction
        self.content = content()
    }
    var body: some View {
        ZStack(alignment: .leading) {
            content
            Rectangle()
                .fill(Color.clear)
                .frame(width: UIScreen.main.bounds.width * fraction)
        }
    }
}

struct ConstantWidthView_Previews: PreviewProvider {
    static var previews: some View {
        FractionalWidthView(fraction: 0.3) {
            Text("Weight")
        }
        .border(Color.red)
    }
}
