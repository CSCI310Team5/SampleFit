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

class SearchState: ObservableObject {
    @Published var searchText = ""
    @Published var isSearching = false
    @Published var scope = SearchScope.video
    @Published var searchCategory: Exercise.Category?
    var showsSuggestedSearch: Bool {
        return searchText.isEmpty && searchCategory == nil
    }
    @Published var exerciseSearchResults: [Exercise] = []
    @Published var userSearchResults: [PersonalInformation] = []
    var searchCancellable: AnyCancellable?
    
    func beginSearch() {
        self.searchCancellable?.cancel()

        switch scope {
        case .video:
            self.searchCancellable = NetworkQueryController.shared.searchExerciseResults(searchText: searchText, category: searchCategory)
                .replaceError(with: [])
                .map { $0.sorted(by: <) }
                .assign(to: \.exerciseSearchResults, on: self)
        case .user:
            self.searchCancellable = NetworkQueryController.shared.searchUserResults(searchText: searchText)
                .replaceError(with: [])
                .map { $0.sorted(by: <) }
                .assign(to: \.userSearchResults, on: self)
        }
    }
    
    static func exampleStateWithResultsFilled(inScope scope: SearchScope) -> SearchState {
       let searchState = SearchState()
        searchState.scope = scope
        searchState.exerciseSearchResults = Exercise.exampleExercisesAllPushup
        searchState.userSearchResults = PersonalInformation.examplePersonalInformation
        return searchState
    }
}
