//
//  UserDetail.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/20/21.
//

import SwiftUI

struct UserDetail: View {
    @EnvironmentObject var userData: UserData
    var user: PublicProfile
    @ObservedObject var privateInformation: PrivateInformation
    
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                FollowButton(following: privateInformation.hasFollowed(user), action: { privateInformation.toggleUserInFollowed(user, token: userData.token , email: userData.publicProfile.identifier) }).padding()
            }
            
            VStack{
                CircleImage(image: user.image).padding(.bottom)
                Text(user.identifier).bold().font(.headline).padding()
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
            
        }
    }
}

struct UserDetail_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            UserDetail(user: PublicProfile.exampleProfiles[0], privateInformation: PrivateInformation.examplePrivateInformation)
        }
    }
}
