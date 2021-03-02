//
//  MeView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import SwiftUI

struct MeView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var privateInformation: PrivateInformation
    var body: some View {
        List {
            
            Section {
                NavigationLink(destination: FavoriteExercisesList(privateInformation: privateInformation)) {
                    Label {
                        Text("Favorites")
                    } icon: {
                        Image(systemName: "star.fill")
                    }
                }
                
                NavigationLink(destination: FollowingUserList(privateInformation: privateInformation)) {
                    Label {
                        Text("Following")
                    } icon: {
                        Image(systemName: "person.fill")
                    }
                }
                
                NavigationLink(destination: NoResults(title: "No Uploads", description: "You haven't uploaded anything yet.").navigationBarTitle("Uploads", displayMode: .inline)) {
                    Label {
                        Text("Uploads")
                    } icon: {
                        Image(systemName: "arrow.up.circle")
                            .font(Font.body.bold())
                    }
                }
                
            }
            
            // Workout History
            Section(header: Text("History").font(.title2).bold().foregroundColor(.primary).textCase(.none)) {
                ForEach(privateInformation.workoutHistory) { workout in
                    WorkoutDisplayItem(workout: workout)
                }
            }
            
            Section {
                Button(action: { userData.signOut() }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
            
            
        }
        .listStyle(InsetGroupedListStyle())
        .toolbar {
            Image(systemName: "person.circle")
                .font(.title)
        }
        
        .navigationTitle("Me")
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            MeView(privateInformation: PrivateInformation.examplePrivateInformation)
        }
        .environmentObject(PrivateInformation.examplePrivateInformation)
        
    }
}
