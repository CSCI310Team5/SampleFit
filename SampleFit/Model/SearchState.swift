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
    @Published var userSearchResults: [PersonalInformation] = []
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
                .replaceError(with: [])
                .map { $0.sorted(by: <) }
                .assign(to: \.exerciseSearchResults, on: self)
            self.searchStatusCancellable = NetworkQueryController.shared.searchExerciseResults(searchText: searchText, category: searchCategory)
                .replaceError(with: [])
                .map { return $0.isEmpty ? SearchStatus.noResults : SearchStatus.hasResults }
                .assign(to: \.searchStatus, on: self)
        case .user:
            self.searchCancellable = NetworkQueryController.shared.searchUserResults(searchText: searchText)
                .replaceError(with: [])
                .map { $0.sorted(by: <) }
                .assign(to: \.userSearchResults, on: self)
            self.searchStatusCancellable = NetworkQueryController.shared.searchUserResults(searchText: searchText)
                .replaceError(with: [])
                .map { return $0.isEmpty ? SearchStatus.noResults : SearchStatus.hasResults }
                .assign(to: \.searchStatus, on: self)
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
        searchState.userSearchResults = PersonalInformation.examplePersonalInformation
        return searchState
    }
}
