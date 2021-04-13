//
//  SearchView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/12/21.
//

import SwiftUI
import Combine

struct SearchView: View {
    @StateObject private var searchState = SearchState()
    var searchCategoryTokenController = SearchCategoryTokenEventController.shared
    var searchCancellable: AnyCancellable?
    
    var body: some View {
        NavigationViewWithSearchBar(text: $searchState.searchText, placeholder: "Videos, Users", scopes: SearchScope.allCases, tokenEventController: searchCategoryTokenController) {
            SearchContent(searchState: searchState)
                .navigationTitle("Search")
        } onBegin: {
            searchState.searchDidBegin()
        } onCancel: {
            searchState.searchDidCancel()
        } onSearchClicked: {
            searchState.beginSearchIfNeededAndSetSearchStatus()
        } onScopeChange: { (newScope) in
            searchState.scope = newScope
            if newScope == .user {
                searchCategoryTokenController.removeAllTokens()
            }
            searchState.beginSearchIfNeededAndSetSearchStatus()
        } onTokenItemsChange: { (newTokenItems) in
            searchState.searchCategory = newTokenItems.map { $0 as! Exercise.Category }.first ?? nil
            searchState.beginSearchIfNeededAndSetSearchStatus()
        }
        .edgesIgnoringSafeArea(.all)

    }
    
}

struct SearchContent: View {
    @ObservedObject var searchState: SearchState
    
    var body: some View {
        VStack {
            switch searchState.searchStatus {
            case .notStarted:
                if searchState.isSearchBarActive {
                    SearchRecommendation(searchState: searchState)
                }
            case .userIsTyping:
                EmptyView()
            case .loading:
                LoadingView()
            case .noResults:
                NoSearchResult(searchText: searchState.searchText)
            case .hasResults:
                SearchResult(searchState: searchState)
                
            }
            
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var userData = UserData()
    @State private static var text = ""
    static var scope: SearchScope = .video
    static var previews: some View {
        Group {
            MultiplePreview(embedInNavigationView: false) {
                SearchView()
            }
        }
        .environmentObject(userData)
    }
}
