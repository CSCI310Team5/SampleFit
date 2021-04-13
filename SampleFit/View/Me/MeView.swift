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
    @State private var showingAlert = false
    
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
                .accessibility(localIdentifier: .uploadsSection)
                
                NavigationLink(destination: FollowingUserList(privateInformation: privateInformation)) {
                    Label {
                        Text("Following")
                    } icon: {
                        Image(systemName: "person.2.fill")
                    }
                }
            }
            
            Section {
                NavigationLink(destination: WorkoutHistoryView(privateInformation: privateInformation)) {
                    Label {
                        Text("Workout History")
                    } icon: {
                        Image(systemName: "flame.fill")
                    }
                }
                
                
                
                NavigationLink(destination: WatchHistoryView(privateInformation: privateInformation)) {
                    Label {
                        Text("Video Watching History")
                    } icon: {
                        Image(systemName: "clock")
                            .font(Font.body.bold())
                    }
                }
                
                NavigationLink(destination: WorkoutCalendar(privateInformation: privateInformation)) {
                    Label {
                        Text("Workout Calendar")
                    } icon: {
                        Image(systemName: "calendar")
                            .font(Font.body.bold())
                    }
                }
            }
            
            Section{
                Button(action: { userData.signOut() }) {
                    Text("Sign Out")
                }
            }
            
            Section {
                Button(action: {showingAlert.toggle()}, label: {
                    Text("Delete Account").foregroundColor(.red)
                }).alert(isPresented:$showingAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete your account?"),
                        message: Text("There is no undo"),
                        primaryButton: .destructive(Text("Delete")) {
                            userData.deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
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
