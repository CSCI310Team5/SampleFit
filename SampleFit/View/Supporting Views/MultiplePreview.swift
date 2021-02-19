//
//  MultiplePreview.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct MultiplePreview<Content>: View where Content: View {
    let content: Content
    let embedInNavigationView: Bool
    
    init(embedInNavigationView: Bool, @ViewBuilder _ content: @escaping () -> Content) {
        self.embedInNavigationView = embedInNavigationView
        self.content = content()
    }
    var body: some View {
        if embedInNavigationView {
            Group {
                NavigationView {
                    content
                }
                .previewDisplayName("Light mode")
                
                NavigationView {
                    content
                }
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark mode")
                
                NavigationView {
                    content
                }
                .previewDevice("iPhone SE (2nd generation)")
                .previewDisplayName("iPhone SE")
            }
        } else {
            Group {
                content
                    .previewDisplayName("Light mode")
                
                content
                    .environment(\.colorScheme, .dark)
                    .previewDisplayName("Dark mode")
                
                content
                    .previewDevice("iPhone SE (2nd generation)")
                    .previewDisplayName("iPhone SE")
            }
        }
    }
}

struct SimplePreview_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            Text("Multiple Preview")
        }
    }
}
