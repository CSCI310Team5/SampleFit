//
//  ExerciseDetail.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI
import AVKit

struct ExerciseDetail: View {
    @ObservedObject var exercise: Exercise
    @State private var favorited = false
    @State private var isWorkingout = false
    
    var body: some View {
        // FIXME: Fake player now
        ScrollView(showsIndicators: false) {
            VStack {
                VideoPlayer(player: nil) {
                    Group {
                        if exercise.image != nil {
                            exercise.image!
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    
                }
                .frame(height: 250)
                
                // Exercise information
                VStack(alignment: .leading) {
                    
                    // Name label and favorite button
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(exercise.name)
                                .font(.title)
                                .bold()
                                .padding(.bottom, 8)
                            
                            if exercise.playbackType == .recordedVideo {
                                Text(exercise.durationDescription)
                            } else {
                                HStack(spacing: 6) {
                                    LiveIndicator()
                                    Text(exercise.durationDescription)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // favorite button
                        Button(action: { withAnimation { favorited.toggle() } }) {
                            if favorited {
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
                        .padding(.trailing, 6)
                    }
                    
                    // Start/stop workout button
                    Button(action: { withAnimation {isWorkingout.toggle()} }) {
                        Group {
                            if isWorkingout {
                                HStack {
                                    Image(systemName: "pause.circle.fill")
                                        .font(.title3)
                                    Text("End Workout")
                                }
                                
                            } else {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title3)
                                    Text("Start Workout")
                                }
                            }
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
                    }
                    .padding(.vertical)
                    
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
            
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExerciseDetail_Previews: PreviewProvider {
    @ObservedObject static var exercise: Exercise = Exercise.sampleExercisesFull[10]

    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ExerciseDetail(exercise: exercise)
        }
    }
}
