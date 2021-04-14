//
//  WorkoutHistoryView.swift
//  SampleFit
//
//  Created by apple on 4/6/21.
//

import SwiftUI

struct WorkoutHistoryView: View {
    @ObservedObject var privateInformation: PrivateInformation
    @State private var showingAlert: Bool = false;
    var body: some View {
        WorkoutHistoryList(workoutHistory: privateInformation.workoutHistory)
            .toolbar(content: {
                Button(action: {
                    print("clicked")
                    showingAlert.toggle()
                }, label: {
                    Text("Empty")
                })
            })
        .alert(isPresented:$showingAlert) {
            Alert(
                title: Text("Are you sure you want to empty your history?"),
                message: Text("There is no undo"),
                primaryButton: .destructive(Text("Empty")) {
                    privateInformation.emptyWorkoutHistory()
                },
                secondaryButton: .cancel()
            )
        }
        .navigationBarTitle("Workout History", displayMode: .inline)
    }
}

struct WorkoutHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            WorkoutHistoryView(privateInformation: PrivateInformation.examplePrivateInformation)
        }
    }
}
