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
            
            Section(header: Text("History").font(.title2).bold().foregroundColor(.primary).textCase(.none)) {
                NavigationLink(
                    destination: WorkoutHistoryView(privateInformation: privateInformation),
                    label: {
                        Text("🔥Workout History🔥")
                    })
                
                NavigationLink(
                    destination: WatchHistoryView(privateInformation: privateInformation),
                    label: {
                        Text("Video Watching History")
                    })
            }
            
    
            
            
            Section{
                Button(action: { userData.signOut() }) {
                    Text("Sign Out")
                }

                Button(action: {showingAlert.toggle()}, label: {
                    Text("Delete Account").foregroundColor(.red)
                }).alert(isPresented:$showingAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete your account?"),
                        message: Text("There is no undo"),
                        primaryButton: .destructive(Text("Delete")) {
                            //FIXME: api to be connected
                            userData.signOut()
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
