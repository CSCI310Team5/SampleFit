//
//  ExerciseDetail.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI
import AVKit

struct ExerciseDetail: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var privateInformation: PrivateInformation
    @State var exercise: Exercise
    @State private var hideThumbnail = false
    
    var body: some View {
        // FIXME: need to deal with the overlaying image
        ScrollView {
            VStack {
                if exercise.playbackType == .recordedVideo {
                    
                    VideoPlayer(player: AVPlayer(url:URL(string: exercise.contentLink)!)){
                        
                        Group {
                            if exercise.image != nil {
                                Image(uiImage:exercise.image!)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        
                    }
                    .frame(height: 250)
                    
                }else{
                    if exercise.image != nil {
                        Image(uiImage: exercise.image!) .resizable().scaledToFit()
                    }
                }
                // Exercise information
                VStack(alignment: .leading) {
                    
                    // Name label and favorite button
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(exercise.name)
                                .font(.title)
                                .bold()
                                .padding(.bottom, 8)
                            
                            if exercise.playbackType != .recordedVideo{
                                HStack(spacing: 6) {
                                    LiveIndicator()
                                    Text("LIVE")
                                        .font(.caption)
                                    Spacer()
                                    Text(exercise.durationDescription).font(.caption)
                                    Spacer()
                                    Text("\(exercise.peopleLimit) People Max").font(.caption)
                                }
                            }
                        }
                        
                        Text(exercise.description)
                        
                        Spacer()
                        
                        if exercise.playbackType == .recordedVideo{
                            // favorite button
                            Button(action: { privateInformation.toggleExerciseInFavorites(exercise, email: userData.publicProfile.identifier, token: userData.token) }) {
                                if privateInformation.hasFavorited(exercise) {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(20)
                                        .foregroundColor(.yellow)
                                } else {
                                    Image(systemName: "star")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(20)
                                }
                            }
                            .offset(x: 20, y: -15)
                            .padding(.trailing, 6)}
                    }
                    
                    if exercise.playbackType == .live {
                        Link("Join Live Stream", destination: URL(string: "google.com")!).font(.headline)
                            .foregroundColor(Color.systemBackground)
                            .frame(minWidth: 100, maxWidth: 150)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 7.5)
                                    .fill(Color.accentColor)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // description
                Text(exercise.description)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
            }
            .listRowInsets(EdgeInsets())
            
            // link to user detail
            NavigationLink(destination: UserDetail(user: exercise.owningUser, privateInformation: privateInformation)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise.owningUser.identifier)
                            .font(.body)
                        Text("Creator")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                
            }
            .padding(20)
            
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            exercise.owningUser.getRemainingUserInfo(userEmail: exercise.owningUser.identifier)
        }
    }
}

struct ExerciseDetail_Previews: PreviewProvider {
    @ObservedObject static var exercise: Exercise = Exercise.exampleExercisesFull[2]
    
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ExerciseDetail(privateInformation: PrivateInformation.examplePrivateInformation, exercise: exercise)
        }
    }
}
