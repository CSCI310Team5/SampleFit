//
//  UploadedExercisesList.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

struct UploadedExercisesList: View {
    @ObservedObject var publicProfile: PublicProfile
    @ObservedObject var privateProfile: PrivateInformation
    @EnvironmentObject var userData: UserData
    @Environment(\.editMode) var editMode
    @State private var isNewUploadSheetPresented = false
    var body: some View {
        Group {
            if publicProfile.uploadedExercises.isEmpty {
                NoResults(title: "No Uploads", description: "You haven't uploaded anything yet.")
                    .animation(.easeInOut)
                    .transition(.opacity)
            } else {
                List {
                    ForEach(publicProfile.uploadedExercises) { exercise in
                        NavigationLink(destination: ExerciseDetail(privateInformation: privateProfile, exercise: exercise)) {
                            // hide detail and shrink row item on edit
                            ExerciseListDisplayItem(exercise: exercise, hideDetails: editMode?.wrappedValue == .active)
                                .scaleEffect(editMode?.wrappedValue == .active ? 0.9 : 1)
                        }
                    }
                    .onDelete {
                        self.publicProfile.removeExerciseFromUploads(at: $0)
                    }
                }
                .listStyle(PlainListStyle())
                .toolbar {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $isNewUploadSheetPresented) {
            UploadSheetView(publicProfile: publicProfile, isPresented: $isNewUploadSheetPresented)
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
            UploadedExercisesList( publicProfile: PublicProfile.exampleProfile, privateProfile: PrivateInformation.examplePrivateInformation)
        }
    }
}
