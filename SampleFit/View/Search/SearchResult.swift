//
//  SearchResult.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI

struct SearchResult: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var searchState: SearchState
    var body: some View {
        switch searchState.scope {
        case .video:
            ExerciseSearchResultList(exercises: searchState.exerciseSearchResults)
        case .user:
            UserSearchResultList(users: searchState.userSearchResults, privateInformation: userData.privateInformation)
        }
    }
}

struct SearchResult_Previews: PreviewProvider {
    @ObservedObject static var userData = UserData()
    @State private static var videoSearchState = SearchState.exampleStateWithResultsFilled(inScope: .video)
    @State private static var userSearchState = SearchState.exampleStateWithResultsFilled(inScope: .user)
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
//            SearchResult(searchState: userSearchState)
            SearchResult(searchState: videoSearchState)
        }
        .environmentObject(userData)
    }
}
