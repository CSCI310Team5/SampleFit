//
//  CommentListView.swift
//  SampleFit
//
//  Created by apple on 4/24/21.
//

import SwiftUI

struct CommentHelperView: View {
    @ObservedObject var user: PublicProfile
    @ObservedObject var privateInformation: PrivateInformation
    
    var body: some View {
        
        VStack {
                
                HStack {
                    Spacer()
                    if user.identifier != privateInformation.email{
                        FollowButton(following: privateInformation.hasFollowed(user), action: { privateInformation.toggleUserInFollowed(user, token: privateInformation.authenticationToken , email: privateInformation.email) }).padding()
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
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    user.getRemainingUserInfo(userEmail: user.identifier)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    user.getExerciseUploads(userEmail: user.identifier)
                }
               
                
                
            }
    }
}

struct CommentHelperView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}
