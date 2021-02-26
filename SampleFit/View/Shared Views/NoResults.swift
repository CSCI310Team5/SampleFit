//
//  NoResults.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/22/21.
//

import SwiftUI

struct NoResults: View {
    var title: String
    var description: String
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title)
                .bold()
            Text(description)
                .foregroundColor(.secondary)
        }
    }
}

struct NoSearchResult: View {
    var searchText: String
    var body: some View {
        NoResults(title: "No Results", description: "for \"\(searchText)\"")
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
