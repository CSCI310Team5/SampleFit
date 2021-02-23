//
//  BlurView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/23/21.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    var effect: UIVisualEffect = UIBlurEffect(style: .systemThinMaterial)
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            Text("Some Text")
                .padding()
                .background(
                    BlurView()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                )
        }
    }
}
