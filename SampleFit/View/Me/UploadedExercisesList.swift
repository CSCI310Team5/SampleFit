//
//  UploadedExercisesList.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

struct UploadedExercisesList: View {
    @ObservedObject var privateInformation: PrivateInformation
    @Environment(\.editMode) var editMode
    @State private var isNewUploadSheetPresented = false
    var body: some View {
        Group {
            if privateInformation.uploadedExercises.isEmpty {
                NoResults(title: "No Uploads", description: "You haven't uploaded anything yet.")
                    .animation(.easeInOut)
                    .transition(.opacity)
            } else {
                List {
                    ForEach(privateInformation.uploadedExercises) { exercise in
                        NavigationLink(destination: ExerciseDetail(privateInformation: privateInformation, exercise: exercise)) {
                            // hide detail and shrink row item on edit
                            ExerciseListDisplayItem(exercise: exercise, hideDetails: editMode?.wrappedValue == .active)
                                .scaleEffect(editMode?.wrappedValue == .active ? 0.9 : 1)
                        }
                    }
                    .onDelete {
                        self.privateInformation.removeExerciseFromUploads(at: $0)
                    }
                }
                .listStyle(PlainListStyle())
                .toolbar {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $isNewUploadSheetPresented) {
            Text("New upload sheet")
        }
        .navigationBarItems(trailing:
            Button(action: { isNewUploadSheetPresented = true }) {
                Image(systemName: "plus")
            }
        )
        .navigationBarTitle("Uploads", displayMode: .inline)

    }
}

struct UploadedExercisesList_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            UploadedExercisesList(privateInformation: PrivateInformation.examplePrivateInformation)
        }
    }
}
