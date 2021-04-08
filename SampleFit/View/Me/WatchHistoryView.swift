//
//  WatchHistoryView.swift
//  SampleFit
//
//  Created by apple on 4/6/21.
//

import SwiftUI

struct WatchHistoryView: View {
    @ObservedObject var privateInformation: PrivateInformation
    @State private var showingAlert: Bool = false
    
    @Environment(\.editMode) var editMode
    var body: some View {
        Group {
            if privateInformation.watchedExercises.isEmpty {
                NoResults(title: "No History", description: "You haven't watched any videos yet.")
                    .animation(.easeInOut)
                    .transition(.opacity)
            } else {
                List {
                    ForEach(privateInformation.watchedExercises.reversed()) { exercise in
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
            }
        }
        .toolbar(content: {
                    Button(action: {
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
                    privateInformation.emptyWatchHistory()
                },
                secondaryButton: .cancel()
            )
        }

        .navigationBarTitle("Watched Video History", displayMode: .inline)
        .onAppear(perform: {
            privateInformation.getWatchedHistory()
        })
    }
}

struct WatchHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        WatchHistoryView(privateInformation: PrivateInformation.examplePrivateInformation)
    }
}
