//
//  ExerciseSearchResultList.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import SwiftUI

struct ExerciseSearchResultList: View {
    @EnvironmentObject var userData: UserData
    var exercises: [Exercise]
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink(destination: ExerciseDetail(privateInformation: userData.privateInformation, exercise: exercise)) {
                    ExerciseListDisplayItem(exercise: exercise)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct ExerciseList_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ExerciseSearchResultList(exercises: Exercise.exampleExercisesSmall)
                .environmentObject(UserData())
        }
    }
}
