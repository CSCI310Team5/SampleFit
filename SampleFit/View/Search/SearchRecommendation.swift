//
//  SearchRecommendation.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI

struct SearchRecommendation: View {
    @ObservedObject var searchState: SearchState

    var body: some View {
        switch searchState.scope {
        case .video:
            ExerciseSearchRecommendation()
        case .user:
            EmptyView()
        }
    }
}

struct ExerciseSearchRecommendation: View {
    @EnvironmentObject var userData: UserData
    var searchCategoryTokenController = SearchCategoryTokenEventController.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: nil, pinnedViews: .sectionHeaders) {
                Section(header:
                    // header banner
                    HStack {
                        Text("Suggested Searches")
                            .font(.headline)
                            .padding(.vertical, 4)
                            .padding(.leading, 15)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            Color.systemBackground
                            Color.systemFill
                        }
                    )
                ) {
                    ForEach(Exercise.Category.allCases, id: \.self) { category in
                        VStack {
                            
                            // recommended search button
                            Button(action: { searchCategoryTokenController.addToken(for: category) }) {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text(category.description)
                                            .foregroundColor(.accentColor)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                            .frame(minHeight: 44)
                            
                            Divider()
                        }
                    }
                    .padding(.leading, 24)
                    
                }
            }
        }
        .transition(.opacity)
    }
}


struct SearchRecommendation_Previews: PreviewProvider {
    @ObservedObject static var userData = UserData()
    @State private static var searchState = SearchState()
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            SearchRecommendation(searchState: searchState)
        }
        .environmentObject(userData)
    }
}
