//
//  ExerciseListDisplayItem.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI

struct ExerciseListDisplayItem: View {
    @ObservedObject var exercise: Exercise
    var body: some View {
        HStack(alignment: .center) {
            // image
            Group {
                if exercise.image != nil {
                    exercise.image!
                        .resizable()
                        .scaledToFill()
                } else {
                    PlaceholderImage()
                }
            }
            .frame(width: 200, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .clipped()
            .overlay(
                Text("LIVE")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .bold()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        BlurView()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    )
                    .padding(6)
            , alignment: .bottomLeading)
                        
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    if exercise.playbackType == .recordedVideo {
                        Text(exercise.durationDescription)
                    } else {
                        // live
                        Text(exercise.durationDescription)
                            .bold()
                            .foregroundColor(.red)
                    }
                    Text("·")
                        .font(.title3)
                    Text(exercise.category.description)
                }
                .font(.caption)
                
                Text(exercise.name)
            }
            
            Spacer()

        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
    }
}


struct ExerciseDisplayItem_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
//            ExerciseListDisplayItem(exercise: Exercise.exampleExercisesAllPushup[1])
            ExerciseListDisplayItem(exercise: Exercise.exampleExercisesAllPushup[2])
        }
    }
}
