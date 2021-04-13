//
//  WorkoutHistoryList.swift
//  SampleFit
//
//  Created by Zihan Qi on 4/12/21.
//

import SwiftUI

struct WorkoutHistoryList: View {
    var workoutHistory: [Workout]
    var body: some View {
        Group {
            if !workoutHistory.isEmpty {
                List {
                    ForEach(workoutHistory.reversed()) { workout in
                        WorkoutDisplayItem(workout: workout)
                    }
                }
                .listStyle(PlainListStyle())
            }else{
                NoResults(title: "No History", description: "No exercise history yet, start workout today!")
                    .animation(.easeInOut)
                    .transition(.opacity)
            }
        }
    }
}

struct WorkoutHistoryList_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            WorkoutHistoryList(workoutHistory: Workout.exampleWorkouts)
        }
    }
}
