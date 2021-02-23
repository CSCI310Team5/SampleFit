//
//  TestView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct TestView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}


struct TestView_Previews: PreviewProvider {
    @State static var text: String = ""
    static var previews: some View {
        Rectangle()
            .fill(Color.gray)
            .background(TestView())
        
    }
}
