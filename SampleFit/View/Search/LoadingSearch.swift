//
//  LoadingSearch.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/22/21.
//

import SwiftUI

struct LoadingSearch: View {
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Searching")
                .foregroundColor(.secondary)
        }
    }
}

struct LoadingSearch_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            LoadingSearch()
        }
    }
}
