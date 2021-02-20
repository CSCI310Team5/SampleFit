//
//  SearchResult.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI

struct SearchResult: View {
    @ObservedObject var searchState: SearchState
    var body: some View {
        switch searchState.scope {
        case .video:
            ExerciseSearchResult(exercises: searchState.exerciseSearchResults)
        case .user:
            UserSearchResult(users: searchState.userSearchResults)
        }
    }
}

struct ExerciseSearchResult: View {
    var exercises: [Exercise]
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink(destination: ExerciseDetail(exercise: exercise)) {
                    ExerciseListDisplayItem(exercise: exercise)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct UserSearchResult: View {
    var users: [PersonalInformation]
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(users) { user in
                    NavigationLink(destination: UserDetail(user: user)) {
                        UserListDisplayItem(user: user)
                            .padding(.top, user == users[0] ? 4 : 0)
                    }
                }
            }
            
        }
    }
}



struct SearchResult_Previews: PreviewProvider {
    @ObservedObject static var userData = UserData()
    @State private static var videoSearchState = SearchState.exampleStateWithResultsFilled(inScope: .video)
    @State private static var userSearchState = SearchState.exampleStateWithResultsFilled(inScope: .user)
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            SearchResult(searchState: userSearchState)
            SearchResult(searchState: videoSearchState)
        }
        .environmentObject(userData)
    }
}
