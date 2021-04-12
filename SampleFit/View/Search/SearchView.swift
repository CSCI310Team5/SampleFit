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
    @ObservedObject var privateInformation:PrivateInformation
    
    var body: some View {
        NavigationViewWithSearchBar(text: $searchState.searchText, placeholder: "Videos, Users", scopes: SearchScope.allCases, tokenEventController: searchCategoryTokenController) {
            SearchContent(searchState: searchState, privateInformation: privateInformation)
                .toolbar(content: {
                    Button(action: {
                        privateInformation.emptySearchHistory()
                    }, label: {
                        Text("Empty Search History").foregroundColor(.gray)
                    })
                })
                .navigationTitle("Search")
        } onBegin: {
            searchState.isSearchBarActive = true
        } onCancel: {
            searchState.isSearchBarActive = false
            searchState.searchText = ""
        } onSearchClicked: {
            searchState.beginSearchIfNeededAndSetSearchStatus(email: privateInformation.email,token: privateInformation.authenticationToken)
            privateInformation.addSearchHistory(searchText: searchState.searchText)
        } onScopeChange: { (newScope) in
            searchState.scope = newScope
            if newScope == .user {
                searchCategoryTokenController.removeAllTokens()
            }
            searchState.beginSearchIfNeededAndSetSearchStatus(email: privateInformation.email,token: privateInformation.authenticationToken)
            privateInformation.addSearchHistory(searchText: searchState.searchText)
        } onTokenItemsChange: { (newTokenItems) in
            searchState.searchCategory = newTokenItems.map { $0 as! Exercise.Category }.first ?? nil
            searchState.beginSearchIfNeededAndSetSearchStatus(email: privateInformation.email,token: privateInformation.authenticationToken)
            privateInformation.addSearchHistory(searchText: searchState.searchText)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SearchContent: View {
    @ObservedObject var searchState: SearchState
    @ObservedObject var privateInformation: PrivateInformation
    var body: some View {
        VStack {
            switch searchState.searchStatus {
            case .notStarted:
                if searchState.isSearchBarActive {
                    SearchRecommendation(searchState: searchState)
                }else{
                    SearchHistory(searchState: searchState, privateInformation: privateInformation)
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
                SearchView(privateInformation: PrivateInformation.examplePrivateInformation)
            }
        }
        .environmentObject(userData)
    }
}
