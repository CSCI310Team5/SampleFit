//
//  ExerciseDetail.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI
import Combine
import AVKit

struct ExerciseDetail: View {
    @ObservedObject var privateInformation: PrivateInformation
    @ObservedObject var exercise: Exercise
    @Environment(\.openURL) var openURL
    @State private var hideThumbnail = false
    @State private var livestreamOverlayIsPresented = false
    @State private var isLivestreamAtFullCapacityAlertPresented = false
    
    var body: some View {

        ScrollView {
            VStack {
                if exercise.playbackType == .recordedVideo {
                    
                    VideoPlayer(player: AVPlayer(url:URL(string: exercise.contentLink)!))
                        .frame(height: 250).onAppear(perform: {
                            privateInformation.addHistory(exercise: exercise)
                        })
                    
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
                                if exercise.isExpired {
                                    Text("This livestream has ended.")
                                } else {
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
                        }
                        
                        Spacer()
                        
                        
                        if exercise.playbackType == .recordedVideo{
                            // favorite button
                            Button(action: { privateInformation.toggleExerciseInFavorites(exercise) }) {
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
                    
                    if(exercise.playbackType == .recordedVideo){
                        HStack{
                            Spacer()
//                            Text("Likes: \(exercise.likes ?? 0)").foregroundColor(.gray)
                        }
                        .offset(y:-10)
                        .padding(.top, -10)

                    }
                    
                    if exercise.playbackType == .live {
                        if URL(string: exercise.contentLink) != nil {
                            Button("Join Live Stream") {
                                joinLivestream()
                            }
                            .font(.headline)
                            .foregroundColor(Color.systemBackground)
                            .frame(minWidth: 100, maxWidth: 150)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 7.5)
                                    .fill(Color.accentColor)
                            )
                            .disabled(exercise.isExpired)
                            
                        } else {
                            Button("Invalid zoom link", action: {})
                                .foregroundColor(Color.systemBackground)
                                .frame(minWidth: 100, maxWidth: 150)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 7.5)
                                        .fill(Color.accentColor)
                                )
                                .disabled(true)
                        }
                    }
                    
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
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
            
            .sheet(isPresented: $livestreamOverlayIsPresented, onDismiss: {}) {
                LivestreamStatusView(isPresented: $livestreamOverlayIsPresented, exercise: exercise)
                    .environmentObject(privateInformation)
            }
            
            // description
            Text(exercise.description)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            Divider()
                .padding(.horizontal, 20)
            
            
            if exercise.comment ?? false{
                CommentView(exercise: exercise,privateInformation: privateInformation)
            }
            
        }
        .alert(isPresented: $isLivestreamAtFullCapacityAlertPresented, content: {
            Alert(title: Text("The room is full. Try again later."))
        })
        
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            exercise.checkExpiration()
        }
    }
    
    var joinLivestreamCancellable: AnyCancellable?
    
    func joinLivestream() {
        // check if we should allow user to join livestream
        // FIXME: Make call to network query controller. If returning false, don't execute the following code.
        exercise.joinLivestream(authenticationToken: privateInformation.authenticationToken, email: privateInformation.email)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if exercise.canJoinLivestream {
                print("Can join livestream")
                openURL(URL(string: exercise.contentLink)!)
                livestreamOverlayIsPresented = true
            } else {
                print("No can do.")
                isLivestreamAtFullCapacityAlertPresented = true
            }
        }
    }
}

struct ExerciseDetail_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetail(privateInformation: PrivateInformation.examplePrivateInformation, exercise: Exercise.exampleExercise)
    }
}
