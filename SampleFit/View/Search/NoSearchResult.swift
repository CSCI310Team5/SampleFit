//
//  NoSearchResult.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/22/21.
//

import SwiftUI

struct NoSearchResult: View {
    var searchText: String
    var body: some View {
        VStack(spacing: 8) {
            Text("No Results")
                .font(.title)
                .bold()
            Text("for \"\(searchText)\"")
                .foregroundColor(.secondary)
        }
    }
}

struct NoSearchResult_Previews: PreviewProvider {
    static var searchText = "Ba ba baba text"
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            NoSearchResult(searchText: searchText)
        }
    }
}
