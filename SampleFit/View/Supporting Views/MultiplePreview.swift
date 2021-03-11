//
//  MultiplePreview.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct MultiplePreview<Content: View>: View {
    let content: Content
    let embedInNavigationView: Bool
    
    init(embedInNavigationView: Bool, content: () -> Content) {
        self.embedInNavigationView = embedInNavigationView
        self.content = content()
    }
    var body: some View {
        Group {
            content
                .navigationBarHidden(!embedInNavigationView)
                .previewDisplayName("Light mode")
            
            content
                .navigationBarHidden(!embedInNavigationView)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark mode")
            
            content
                .navigationBarHidden(!embedInNavigationView)
                .previewDevice("iPhone SE (2nd generation)")
                .previewDisplayName("iPhone SE")
        }
    }
}

struct SimplePreview_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ChangePasswordView(isPresented: .constant(false))
        }
    }
}
