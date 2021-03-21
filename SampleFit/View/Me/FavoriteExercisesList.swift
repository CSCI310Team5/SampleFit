//
//  FavoriteExercisesList.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import SwiftUI

struct FavoriteExercisesList: View {
    @ObservedObject var privateInformation: PrivateInformation
    @EnvironmentObject var userData: UserData
    @Environment(\.editMode) var editMode
    var body: some View {
        Group {
            if privateInformation.favoriteExercises.isEmpty {
                NoResults(title: "No Favorites", description: "You haven't added anything to favorites yet.")
                    .animation(.easeInOut)
                    .transition(.opacity)
            } else {
                List {
                    ForEach(privateInformation.favoriteExercises) { exercise in
                        NavigationLink(destination: ExerciseDetail(privateInformation: privateInformation, exercise: exercise)) {
                            // hide detail and shrink row item on edit
                            ExerciseListDisplayItem(exercise: exercise, hideDetails: editMode?.wrappedValue == .active)
                                .scaleEffect(editMode?.wrappedValue == .active ? 0.9 : 1)
                        }
                    }
                    .onDelete {
                        self.privateInformation.removeExerciseFromFavorites(at: $0)
                    }
                }
                .listStyle(PlainListStyle())
                .toolbar {
                    EditButton()
                }
            }
        }
        .navigationBarTitle("Favorites", displayMode: .inline)
    }
}

struct FavoritesList_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            FavoriteExercisesList(privateInformation: PrivateInformation.examplePrivateInformation)
        }
    }
}
