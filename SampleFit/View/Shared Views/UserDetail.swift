//
//  UserDetail.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/20/21.
//

import SwiftUI

struct UserDetail: View {
    @EnvironmentObject var userData: UserData

    @ObservedObject var user: PublicProfile
    @ObservedObject var privateInformation: PrivateInformation
    

    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                if user.identifier != userData.publicProfile.identifier{
                    FollowButton(following: privateInformation.hasFollowed(user), action: { privateInformation.toggleUserInFollowed(user, token: userData.token , email: userData.publicProfile.identifier) }).padding()
                }
                else{
                    Text("").padding()
                }
            }
            
            VStack{
                CircleImage(image: user.image).padding(.bottom)
                
                HStack {
                    Text(user.identifier).bold().font(.headline).padding()
                    if !user.nickname.isEmpty {Text("(\(user.nickname))")}
                }
                
            }.padding(.bottom).padding(.top,-20)
            
            
            Section{
                if user.uploadedExercises.isEmpty{
                    NoResults(title: "No Video uploads", description: "\(user.identifier) has not uploaded any video")
                }
                else{
                    Section(header: Text("Video Uploads").font(.title2).bold().foregroundColor(.primary).textCase(.none)) {
                        ExerciseSearchResultList(exercises: user.uploadedExercises)
                    }
                }
            }.padding()
            
            Spacer()
        }
        .navigationTitle("\(user.identifier)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            //before the opening of this view, all publicprofile of other users don't have [exercise] for uploadedvideo， thus calling the function to get this specific user's uploaded list just now -- memory saving
            user.getExerciseUploads(userEmail: user.identifier)
        }
    }
}

struct UserDetail_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            UserDetail(user: PublicProfile.exampleProfiles[0], privateInformation: PrivateInformation.examplePrivateInformation).environmentObject(UserData())
        }
    }
}
