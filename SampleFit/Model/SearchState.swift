//
//  SearchState.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/20/21.
//

import Foundation
import Combine

enum SearchScope: String, CaseIterable, CustomStringConvertible {
    case video = "Video"
    case user = "User"
    var description: String {
        return self.rawValue
    }
}

enum SearchStatus {
    case notStarted
    case userIsTyping
    case loading
    case noResults
    case hasResults
}

/// Use `SearchState` to allow search related views to coordinate search data and status.
class SearchState: ObservableObject {
    typealias SearchCategory = Exercise.Category
    
    @Published var searchText = "" {
        willSet {
            searchTextWillChange()
            setSearchStatus(newSearchText: newValue, newSearchCategory: searchCategory)
        }
    }
    @Published var isSearchBarActive = false {
        willSet {
            if newValue == false { searchStatus = .notStarted }
        }
    }
    @Published var scope = SearchScope.video
    @Published var searchCategory: SearchCategory? {
        willSet {
            setSearchStatus(newSearchText: searchText, newSearchCategory: newValue)
        }
    }
    @Published var searchStatus: SearchStatus = .notStarted
    @Published var exerciseSearchResults: [Exercise] = []
    @Published var userSearchResults: [PublicProfile] = []
    var searchCancellable: AnyCancellable?
    var searchStatusCancellable: AnyCancellable?
    
    func beginSearchIfNeededAndSetSearchStatus() {
        self.searchCancellable?.cancel()
        self.searchStatusCancellable?.cancel()
        self.exerciseSearchResults = []
        self.userSearchResults = []
        // only search when necessary
        guard !searchText.isEmpty || searchCategory != nil else {
            searchStatus = .notStarted
            return
        }
        // begin search
        searchStatus = .loading

        switch scope {
        case .video:
            self.searchCancellable = NetworkQueryController.shared.searchExerciseResults(searchText: searchText, category: searchCategory)
                .receive(on: DispatchQueue.main)
                .replaceError(with: [])
                .map { $0.sorted(by: <) }
                .handleEvents(receiveOutput: {
                    self.searchStatus = $0.isEmpty ? .noResults : .hasResults
                })
                .assign(to: \.exerciseSearchResults, on: self)
        case .user:
            self.searchCancellable = NetworkQueryController.shared.searchUserResults(searchText: searchText)
                .receive(on: DispatchQueue.main)
                .sink{[unowned self] returnedList in
                    for r in returnedList{
                        let profile = PublicProfile(identifier: r.email, fullName: nil)
                        profile.nickname = r.nickname
                        profile.uploadedExercises = []
                        if r.avatar != nil && !r.avatar!.isEmpty{
                            profile.loadAvatar(url: r.avatar!)
                        }
                        userSearchResults.append(profile)
                    }
                    userSearchResults.sort(by: <)
                    self.searchStatus = userSearchResults.isEmpty ? .noResults : .hasResults
                }
        }
    }
    
    private func setSearchStatus(newSearchText: String, newSearchCategory: SearchCategory?) {
        if newSearchText.isEmpty && newSearchCategory == nil {
            searchStatus = .notStarted
        }
    }
    
    private func searchTextWillChange() {
        searchStatus = .userIsTyping
        searchCancellable?.cancel()
        searchStatusCancellable?.cancel()
    }
    
    static func exampleStateWithResultsFilled(inScope scope: SearchScope) -> SearchState {
       let searchState = SearchState()
        searchState.scope = scope
        searchState.exerciseSearchResults = Exercise.exampleExercisesAllPushup
        searchState.userSearchResults = PublicProfile.exampleProfiles
        return searchState
    }
}
