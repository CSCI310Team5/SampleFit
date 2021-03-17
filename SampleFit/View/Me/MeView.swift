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
    @State private var isProfileSheetPresented = false
    var body: some View {
        List {
            Section {
                // profile details
                NavigationLink(destination: ProfileHost(publicProfile: userData.publicProfile)) {
                    Label {
                        Text("Profile Details")
                    } icon: {
                        Image(systemName: "person.fill")
                    }
                }
                
                // profile details
                NavigationLink(destination: SecurityView().environmentObject(userData)) {
                    Label {
                        Text("Password & Security")
                    } icon: {
                        Image(systemName: "key.fill")
                    }
                }
            }

            
            Section {
                NavigationLink(destination: FavoriteExercisesList(privateInformation: privateInformation)) {
                    Label {
                        Text("Favorites")
                    } icon: {
                        Image(systemName: "star.fill")
                    }
                }
                
                NavigationLink(destination: UploadedExercisesList(publicProfile: userData.publicProfile, privateProfile: privateInformation)) {
                    Label {
                        Text("Uploads")
                    } icon: {
                        Image(systemName: "arrow.up.circle")
                            .font(Font.body.bold())
                    }
                }
                
                NavigationLink(destination: FollowingUserList(privateInformation: privateInformation)) {
                    Label {
                        Text("Following")
                    } icon: {
                        Image(systemName: "person.2.fill")
                    }
                }
            }
            
            // Workout History
            if !privateInformation.workoutHistory.isEmpty {
                Section(header: Text("Workout History").font(.title2).bold().foregroundColor(.primary).textCase(.none)) {
                    ForEach(privateInformation.workoutHistory) { workout in
                        WorkoutDisplayItem(workout: workout)
                    }
                }
            }
            
            // Sign out button
            Section {
                Button(action: { userData.signOut() }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
            
            
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Me")
    }
}

struct MeView_Previews: PreviewProvider {
    static var userData = UserData.signedInUserData
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            MeView(privateInformation: userData.privateInformation)
        }
        .environmentObject(userData)
        
    }
}
