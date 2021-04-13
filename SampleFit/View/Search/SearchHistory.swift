//
//  SearchHistory.swift
//  SampleFit
//
//  Created by apple on 4/11/21.
//

import SwiftUI

struct SearchHistory: View {
    @ObservedObject var searchState: SearchState
    @ObservedObject var privateInformation: PrivateInformation
    var body: some View {
        List{
            if(!privateInformation.searchHistory.isEmpty){
            ForEach(0..<privateInformation.searchHistory.count){
                index in
                Button(action: {
                    searchState.searchText=privateInformation.searchHistory[index]
                }, label: {
                    Text(privateInformation.searchHistory[index])
                })
            }}
        }
    }
}

struct SearchHistory_Previews: PreviewProvider {
    static var previews: some View {
        SearchHistory(searchState: SearchState(),privateInformation: PrivateInformation.examplePrivateInformation)
    }
}
